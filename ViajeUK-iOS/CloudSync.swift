//
//  CloudSync.swift
//  Sincronización compartida entre Exe y Mica usando CloudKit (base pública).
//
//  Modelo: un único registro "shared-trip-2026" en la base pública del contenedor
//  CloudKit de la app. Cada dispositivo:
//   • Sube su estado (push) cuando hay un cambio (con debounce).
//   • Baja y FUSIONA el estado remoto (pull) al iniciar, al volver al frente y
//     cuando llega una notificación silenciosa de CloudKit.
//  La fusión es por clave (unión); ante conflicto en la misma clave gana el más nuevo.
//

import Foundation
import CloudKit
import Combine

@MainActor
final class CloudSync: ObservableObject {
    static let shared = CloudSync()

    weak var store: AppState?

    enum Status: Equatable {
        case unknown
        case unavailable(String)
        case syncing
        case synced(Date)
        case error(String)
    }
    @Published var status: Status = .unknown
    @Published var lastEditor: String = ""

    private let container = CKContainer.default()
    private var db: CKDatabase { container.publicCloudDatabase }
    private let recordType = "TripState"
    private let recordName = "shared-trip-2026"
    private var recordID: CKRecord.ID { CKRecord.ID(recordName: recordName) }

    private var debounceTask: Task<Void, Never>?
    private var pollTask: Task<Void, Never>?
    private var inFlight = false
    private var subscribed = UserDefaults.standard.bool(forKey: "ck.subscribed")

    var editorName: String { UserDefaults.standard.string(forKey: "editorName") ?? "Alguien" }

    // MARK: Arranque
    func start() async {
        let st = try? await container.accountStatus()
        switch st {
        case .some(.available):
            break
        case .some(.noAccount):
            status = .unavailable("Iniciá sesión en iCloud (Ajustes) para compartir"); return
        default:
            status = .unavailable("iCloud no disponible en este dispositivo"); return
        }
        await ensureSubscription()
        await sync()
        startPolling()
    }

    // MARK: Polling en primer plano (la vía confiable de "tiempo real")
    /// Refresca cada ~12 s mientras la app está abierta. Se frena al pasar a segundo plano.
    func startPolling() {
        pollTask?.cancel()
        pollTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 12_000_000_000)
                if Task.isCancelled { break }
                await self?.sync(showProgress: false)
            }
        }
    }
    func stopPolling() { pollTask?.cancel(); pollTask = nil }

    // MARK: Push con debounce
    func scheduleSync() {
        debounceTask?.cancel()
        debounceTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 1_200_000_000)
            if Task.isCancelled { return }
            await self?.sync()
        }
    }

    // MARK: Sync (pull + merge + push en un solo paso)
    func sync(showProgress: Bool = true) async {
        guard let store else { return }
        if inFlight { return }              // evita solapamientos (polling + edición + push)
        inFlight = true
        defer { inFlight = false }
        if showProgress { status = .syncing }
        do {
            let record: CKRecord
            let merged: PersistState
            if let remote = try await fetchRecord() {
                if let s = decode(remote) {
                    merged = store.mergeFromCloud(s)
                    lastEditor = (remote["editor"] as? String) ?? lastEditor
                } else {
                    merged = store.snapshot()
                }
                record = remote
            } else {
                record = CKRecord(recordType: recordType, recordID: recordID)
                merged = store.snapshot()
            }
            try writeFields(record, merged)
            _ = try await db.save(record)
            status = .synced(Date())
        } catch {
            await handle(error)
        }
    }

    private func handle(_ error: Error) async {
        let ns = error as NSError
        if let ck = error as? CKError, ck.code == .serverRecordChanged,
           let server = ns.userInfo[CKRecordChangedErrorServerRecordKey] as? CKRecord {
            // Conflicto: fusionar con la versión del servidor y reintentar una vez.
            guard let store else { return }
            if let s = decode(server) {
                let merged = store.mergeFromCloud(s)
                do {
                    try writeFields(server, merged)
                    _ = try await db.save(server)
                    status = .synced(Date())
                    return
                } catch {
                    status = .error("conflicto al reintentar")
                    return
                }
            }
            status = .error("conflicto")
        } else {
            status = friendly(error)
        }
    }

    /// Traduce errores típicos de CloudKit a un mensaje claro (y no bloqueante).
    private func friendly(_ error: Error) -> Status {
        let desc = error.localizedDescription.lowercased()
        if let ck = error as? CKError {
            switch ck.code {
            case .permissionFailure:
                // Lectura OK (recibe cambios) pero no puede escribir el registro de otro.
                return .unavailable("Recibís los cambios ✓, pero falta permiso para enviar: en CloudKit Console dale ‘Write’ al rol Authenticated Users para el tipo TripState (ver README).")
            case .notAuthenticated:
                return .unavailable("Iniciá sesión en iCloud en este iPhone (Ajustes → tu nombre).")
            case .missingEntitlement, .badContainer:
                return .unavailable("CloudKit no configurado: activá iCloud → CloudKit en Xcode (contenedor iCloud.<tu bundle id>).")
            case .networkUnavailable, .networkFailure:
                return .unavailable("Sin conexión — se sincroniza al volver internet.")
            default: break
            }
        }
        if desc.contains("container") || desc.contains("configuration") {
            return .unavailable("CloudKit sin configurar: activá iCloud → CloudKit en Xcode (contenedor iCloud.<tu bundle id>).")
        }
        return .error(error.localizedDescription)
    }

    // MARK: Helpers CloudKit
    private func fetchRecord() async throws -> CKRecord? {
        do {
            return try await db.record(for: recordID)
        } catch let e as CKError where e.code == .unknownItem {
            return nil   // todavía no existe el registro compartido
        }
    }

    private func decode(_ record: CKRecord) -> PersistState? {
        guard let json = record["json"] as? String,
              let data = json.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(PersistState.self, from: data)
    }

    private func writeFields(_ record: CKRecord, _ s: PersistState) throws {
        let data = try JSONEncoder().encode(s)
        let json = String(data: data, encoding: .utf8) ?? "{}"
        record["json"] = json as NSString
        record["updatedAt"] = s.updatedAt as NSDate
        record["editor"] = editorName as NSString
    }

    // MARK: Suscripción para notificaciones silenciosas
    private func ensureSubscription() async {
        guard !subscribed else { return }
        let sub = CKQuerySubscription(
            recordType: recordType,
            predicate: NSPredicate(value: true),
            subscriptionID: "trip-updates",
            options: [.firesOnRecordCreation, .firesOnRecordUpdate]
        )
        let info = CKSubscription.NotificationInfo()
        info.shouldSendContentAvailable = true     // push silencioso (sin alerta)
        sub.notificationInfo = info
        do {
            _ = try await db.save(sub)
            subscribed = true
            UserDefaults.standard.set(true, forKey: "ck.subscribed")
        } catch {
            // Silencioso: la app sigue funcionando con sync al abrir / volver al frente.
        }
    }

    // MARK: Texto de estado para la UI
    var statusText: String {
        switch status {
        case .unknown: return "Conectando…"
        case .unavailable(let m): return m
        case .syncing: return "Sincronizando…"
        case .synced(let d):
            let f = DateFormatter(); f.dateFormat = "HH:mm"
            return "Sincronizado \(f.string(from: d))" + (lastEditor.isEmpty ? "" : " · última edición: \(lastEditor)")
        case .error(let m): return "Error: \(m)"
        }
    }
    var statusOK: Bool { if case .synced = status { return true }; return false }
}

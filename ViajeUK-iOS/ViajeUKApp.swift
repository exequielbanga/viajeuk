//
//  ViajeUKApp.swift
//  App nativa iOS (SwiftUI) para organizar el viaje a UK de Exe & Mica.
//  Con sincronización compartida en la nube (CloudKit) entre ambos.
//

import SwiftUI
import UIKit
import CloudKit

@main
struct ViajeUKApp: App {
    @StateObject private var store = AppState()
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .environmentObject(CloudSync.shared)
                .tint(.ukRed)
                .task {
                    CloudSync.shared.store = store
                    store.cloud = CloudSync.shared
                    await CloudSync.shared.start()
                }
                .onChange(of: scenePhase) { phase in
                    switch phase {
                    case .active:
                        Task { await CloudSync.shared.sync() }
                        CloudSync.shared.startPolling()
                    case .background, .inactive:
                        CloudSync.shared.stopPolling()
                    @unknown default:
                        break
                    }
                }
        }
    }
}

/// Maneja el registro de notificaciones remotas y las notificaciones silenciosas de CloudKit.
final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        application.registerForRemoteNotifications()
        return true
    }

    // Push silencioso de CloudKit → bajar y fusionar cambios del otro.
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any]) async -> UIBackgroundFetchResult {
        await CloudSync.shared.sync()
        return .newData
    }
}

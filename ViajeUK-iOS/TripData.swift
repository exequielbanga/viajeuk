//
//  TripData.swift
//  Datos embebidos del viaje (equivalente a las constantes de la web).
//

import Foundation

enum TripData {

    // MARK: Imágenes (hotlink a Unsplash / Wikimedia, verificadas)
    static let imgLondon    = "https://images.unsplash.com/photo-1486299267070-83823f5448dd?w=1200&q=80"
    static let imgLondonAlt = "https://images.unsplash.com/photo-1520986606214-8b456906c813?w=1200&q=80"
    static let imgOxford    = "https://commons.wikimedia.org/wiki/Special:FilePath/Radcliffe_Camera,_Oxford_-_Oct_2006.jpg?width=1100"
    static let imgCotswolds = "https://commons.wikimedia.org/wiki/Special:FilePath/Bibury_Arlington_Row.jpg?width=1100"
    static let imgYork      = "https://commons.wikimedia.org/wiki/Special:FilePath/York_Minster_from_M%26S.JPG?width=1100"
    static let imgEdinburgh = "https://commons.wikimedia.org/wiki/Special:FilePath/Edinburgh_Castle_from_the_south_east.JPG?width=1100"

    // MARK: Plan (se asignan ids por posición en `normalized`)
    static func makePlan() -> [CityBlock] {
        // Links de Google Maps (de la columna Link de la hoja)
        let airbnb         = "https://maps.app.goo.gl/jDUNFEDPzbHU2Xsv9"
        let mapO2          = "https://maps.app.goo.gl/3kM8QRU7UwB6TPABA"
        let mapRamen       = "https://maps.app.goo.gl/W9Fu8F23dAdjZojSA"
        let mapCaminata    = "https://maps.app.goo.gl/Q1zsSAmtWf3Y4mUu7"
        let mapTea         = "https://maps.app.goo.gl/W8S14i3hZwBcnftB7"
        let mapNotting     = "https://maps.app.goo.gl/c65g4y9GNan5BhXv9"
        let mapWestpoint   = "https://maps.app.goo.gl/YS6QYbkaWcJCh9ez9"
        let mapTwinings    = "https://maps.app.goo.gl/6U8RRju4mjjwismXA"
        let mapDialHouse   = "https://maps.app.goo.gl/P7dCy3AZdEkxYodL6"
        let mapCotswolds   = "https://maps.app.goo.gl/RiUnyKZq1AAmiqNRA"
        let mapShambles    = "https://maps.app.goo.gl/rkrLx8NuoFNsfTms5"
        let mapLils        = "https://maps.app.goo.gl/jmt8kXZ1QEreRwrG7"
        let mapPremierEdin = "https://maps.app.goo.gl/LZAfqP7W7WLPp7PaA"
        let vio            = "https://www.vio.com/Hotel/117111638/en"
        // Personas
        let J = "Juntos", E = "Exe", M = "Mica"

        var blocks: [CityBlock] = [
            CityBlock(city: "Londres — Llegada", dates: "Jue 9 – Vie 10 Jul", image: imgLondon, loc: "London", days: [
                DayPlan(title: "Jueves 9 Jul", items: [
                    ItineraryItem(act: "Vuelo Buenos Aires → Londres", det: "Vuelo internacional (avión), 2 personas. Salida de noche, llegada el viernes.", price: 2290, cat: "Vuelos", res: true, paid: false, persona: J)
                ]),
                DayPlan(title: "Viernes 10 Jul", items: [
                    ItineraryItem(time: "11:30", act: "Outlet O2", det: "ICON Outlet en The O2 — compras", price: 600, cat: "Actividades", res: true, paid: false, map: mapO2, persona: J),
                    ItineraryItem(time: "15:00", act: "Llegada al AirBnb", det: "Londres", res: true, paid: false, map: airbnb, persona: J),
                    ItineraryItem(time: "18–21", act: "Mica — cena de laboratorio", res: true, paid: false, persona: M),
                    ItineraryItem(time: "18–21", act: "Exe — tarde/noche libre", det: "Ramen mientras Mica cena con el laboratorio", res: false, paid: false, map: mapRamen, free: true, freeID: "vie10", persona: E),
                    ItineraryItem(act: "AirBnb", det: "Londres", price: 173, cat: "Alojamiento", res: true, paid: false, map: airbnb)
                ])
            ]),
            CityBlock(city: "Londres — Semana del congreso", dates: "Sáb 11 – Mar 14 Jul", image: imgLondonAlt, loc: "London", days: [
                DayPlan(title: "Sábado 11 Jul", items: [
                    ItineraryItem(time: "8–17", act: "Mica — congreso", det: "Mica en el congreso hasta las 17:00", res: true, paid: false, persona: M),
                    ItineraryItem(time: "8–17", act: "Exe — caminata", det: "Seven Dials, mercados y Borough Market", cat: "Actividades", res: false, paid: false, map: mapCaminata, free: true, freeID: "sab11", persona: E),
                    ItineraryItem(time: "18:00", act: "Afternoon tea", det: "Clásico británico", price: 200, cat: "Comidas", res: true, paid: false, map: mapTea, persona: J),
                    ItineraryItem(act: "AirBnb", price: 173, cat: "Alojamiento", res: true, paid: false, map: airbnb)
                ]),
                DayPlan(title: "Domingo 12 Jul", items: [
                    ItineraryItem(time: "Todo el día", act: "Exe — Canterbury", det: "Mica en el congreso (hasta 19:30)", price: 45, cat: "Actividades", res: true, paid: false, free: true, freeID: "dom12", persona: E),
                    ItineraryItem(act: "AirBnb", price: 173, cat: "Alojamiento", res: true, paid: false, map: airbnb)
                ]),
                DayPlan(title: "Lunes 13 Jul", items: [
                    ItineraryItem(time: "Todo el día", act: "Exe — Cambridge", det: "Mica en el congreso (hasta 19:30)", price: 50, cat: "Actividades", res: true, paid: false, free: true, freeID: "lun13", persona: E),
                    ItineraryItem(act: "AirBnb", price: 173, cat: "Alojamiento", res: true, paid: false, map: airbnb)
                ]),
                DayPlan(title: "Martes 14 Jul", items: [
                    ItineraryItem(time: "Todo el día", act: "Exe — Bath", det: "Mica en el congreso (hasta 23:00)", price: 70, cat: "Actividades", res: true, paid: false, free: true, freeID: "mar14", persona: E),
                    ItineraryItem(act: "AirBnb", price: 173, cat: "Alojamiento", res: true, paid: false, map: airbnb)
                ])
            ]),
            CityBlock(city: "Londres — Turismo juntos", dates: "Mié 15 – Jue 16 Jul", image: imgLondon, loc: "London", days: [
                DayPlan(title: "Miércoles 15 Jul", items: [
                    ItineraryItem(time: "10:00", act: "Exe lleva las cosas al nuevo hotel", det: "Mica en el congreso hasta las 14:00", res: false, paid: false, persona: E),
                    ItineraryItem(time: "12:00", act: "Llegada al nuevo hotel", det: "Cambio de alojamiento", res: false, paid: false, link: vio, persona: E),
                    ItineraryItem(time: "19:00", act: "Notting Hill y Portobello Market", det: "Paseo por el barrio y el mercado", res: false, paid: false, map: mapNotting, persona: J),
                    ItineraryItem(act: "Westpoint Hotel London Paddington", price: 150, cat: "Alojamiento", res: false, paid: false, map: mapWestpoint)
                ]),
                DayPlan(title: "Jueves 16 Jul", items: [
                    ItineraryItem(act: "Twinings", det: "Casa de té histórica en The Strand", res: false, paid: false, map: mapTwinings, persona: J),
                    ItineraryItem(act: "Tower of London", det: "Torre histórica y joyas de la corona", price: 94, cat: "Actividades", res: false, paid: false, persona: J),
                    ItineraryItem(act: "Tower Bridge", det: "Subida al puente", price: 43, cat: "Actividades", res: false, paid: false, persona: J),
                    ItineraryItem(act: "Hay's Galleria", det: "Mercadito junto al río", res: false, paid: false, persona: J),
                    ItineraryItem(act: "London Bridge", res: false, paid: false, persona: J),
                    ItineraryItem(act: "Borough Market", det: "Mercado gastronómico", res: false, paid: false, persona: J),
                    ItineraryItem(time: "20:00", act: "Sky Garden", det: "Mirador (reserva gratis o copa)", price: 40, cat: "Actividades", res: false, paid: false, persona: J),
                    ItineraryItem(act: "Westpoint Hotel London Paddington", price: 150, cat: "Alojamiento", res: false, paid: false, map: mapWestpoint)
                ])
            ]),
            CityBlock(city: "Oxford & Cotswolds", dates: "Vie 17 – Sáb 18 Jul", image: imgOxford, loc: "Oxford", days: [
                DayPlan(title: "Viernes 17 Jul", items: [
                    ItineraryItem(time: "10:20–11:30", act: "Tren Londres → Oxford", price: 52, cat: "Transporte", res: false, paid: false, link: "https://www.omio.com", persona: J),
                    ItineraryItem(time: "12:00", act: "Almuerzo", det: "En el centro de Oxford", res: false, paid: false, persona: J),
                    ItineraryItem(time: "14:00", act: "Check-in The Dial House", det: "Ir y volver al centro en uber", res: false, paid: false, map: mapDialHouse, persona: J),
                    ItineraryItem(time: "15:00", act: "Recorrer las universidades", det: "A definir — colegios y Radcliffe Camera", res: false, paid: false, persona: J),
                    ItineraryItem(act: "The Dial House", det: "Oxford", price: 155, cat: "Alojamiento", res: true, paid: false, map: mapDialHouse)
                ]),
                DayPlan(title: "Sábado 18 Jul", items: [
                    ItineraryItem(time: "Día", act: "Excursión a los Cotswolds", det: "Día completo: Bibury y Bourton-on-the-Water. Volvemos a dormir a Oxford.", price: 200, cat: "Actividades", res: false, paid: false, map: mapCotswolds, free: true, freeID: "sab18", persona: J),
                    ItineraryItem(act: "The Dial House", det: "Oxford — misma estadía que el viernes", price: 155, cat: "Alojamiento", res: false, paid: false, map: mapDialHouse)
                ])
            ]),
            CityBlock(city: "York", dates: "Dom 19 – Lun 20 Jul", image: imgYork, loc: "York", days: [
                DayPlan(title: "Domingo 19 Jul", items: [
                    ItineraryItem(time: "9:20–15:00", act: "Tren Oxford → York", price: 250, cat: "Transporte", res: false, paid: false, link: "https://www.omio.com.ar", persona: J),
                    ItineraryItem(time: "15:00", act: "Llegada al hotel", det: "Lil's on the Waterfront", res: false, paid: false, persona: J),
                    ItineraryItem(time: "16:00", act: "Murallas y The Shambles", det: "Paseo por el casco medieval", res: false, paid: false, map: mapShambles, persona: J),
                    ItineraryItem(act: "Lil's on the Waterfront", det: "York", price: 107, cat: "Alojamiento", res: false, paid: false, map: mapLils)
                ]),
                DayPlan(title: "Lunes 20 Jul", items: [
                    ItineraryItem(time: "Día", act: "Día libre en York", det: "A definir — murallas, The Shambles, Minster", free: true, freeID: "lun20", persona: J),
                    ItineraryItem(act: "Lil's on the Waterfront", det: "York", price: 107, cat: "Alojamiento", res: false, paid: false, map: mapLils)
                ])
            ]),
            CityBlock(city: "Edimburgo", dates: "Mar 21 – Mié 22 Jul", image: imgEdinburgh, loc: "Edinburgh", days: [
                DayPlan(title: "Martes 21 Jul", items: [
                    ItineraryItem(time: "8:30–11:15", act: "Tren York → Edimburgo", price: 120, cat: "Transporte", res: false, paid: false, persona: J),
                    ItineraryItem(time: "15:00", act: "Check-in hotel", det: "Premier Inn Edinburgh East", res: false, paid: false, persona: J),
                    ItineraryItem(time: "Tarde", act: "Tarde libre en Edimburgo", det: "A definir — Royal Mile, Castillo", free: true, freeID: "mar21", persona: J),
                    ItineraryItem(act: "Premier Inn", det: "Edimburgo", price: 268, cat: "Alojamiento", res: false, paid: false, map: mapPremierEdin)
                ]),
                DayPlan(title: "Miércoles 22 Jul", items: [
                    ItineraryItem(time: "Día", act: "Día libre en Edimburgo", det: "A definir — Arthur's Seat, Calton Hill, whisky", free: true, freeID: "mie22", persona: J),
                    ItineraryItem(act: "Premier Inn", det: "Edimburgo", price: 268, cat: "Alojamiento", res: false, paid: false, map: mapPremierEdin)
                ])
            ]),
            CityBlock(city: "Londres — Cierre", dates: "Jue 23 – Sáb 25 Jul", image: imgLondonAlt, loc: "London", days: [
                DayPlan(title: "Jueves 23 Jul", items: [
                    ItineraryItem(time: "10:00–14:30", act: "Tren Edimburgo → Londres", price: 252, cat: "Transporte", res: false, paid: false, link: "https://rail.ninja", persona: J),
                    ItineraryItem(time: "15:00", act: "Check-in hotel", det: "Londres", res: false, paid: false, persona: J),
                    ItineraryItem(act: "Parque St James", res: false, paid: false, persona: J),
                    ItineraryItem(act: "Buckingham Palace", det: "Fachada y cambio de guardia", res: false, paid: false, persona: J),
                    ItineraryItem(act: "Big Ben", res: false, paid: false, persona: J),
                    ItineraryItem(act: "Abadía de Westminster", res: false, paid: false, persona: J),
                    ItineraryItem(act: "Hotel a definir", det: "Londres", price: 150, cat: "Alojamiento", res: false, paid: false, link: vio)
                ]),
                DayPlan(title: "Viernes 24 Jul", items: [
                    ItineraryItem(time: "Día", act: "Día libre en Londres", det: "Último día — lo que haya quedado pendiente", free: true, freeID: "vie24", persona: J),
                    ItineraryItem(act: "Hotel a definir", det: "Londres", price: 150, cat: "Alojamiento", res: false, paid: false, link: vio)
                ]),
                DayPlan(title: "Sábado 25 Jul", items: [
                    ItineraryItem(act: "Vuelo de regreso a Buenos Aires", det: "Fin del viaje (avión)", cat: "Vuelos", res: false, paid: false, persona: J)
                ])
            ])
        ]
        normalize(&blocks)
        return blocks
    }

    static func normalize(_ blocks: inout [CityBlock]) {
        for bi in blocks.indices {
            blocks[bi].id = "b\(bi)"
            for di in blocks[bi].days.indices {
                blocks[bi].days[di].id = "\(bi)-\(di)"
                for ii in blocks[bi].days[di].items.indices {
                    blocks[bi].days[di].items[ii].id = "\(bi)-\(di)-\(ii)"
                }
            }
        }
    }

    static func makeExtras() -> [ExtraCost] {
        [
            ExtraCost(act: "Asistencia al viajero", price: 533, cat: "Otros"),
            ExtraCost(act: "Compras varias", price: 85, cat: "Otros"),
            ExtraCost(act: "Comidas (estimado)", price: 2400, cat: "Comidas")
        ]
    }

    static let categoryOrder = ["Vuelos", "Alojamiento", "Transporte", "Actividades", "Comidas", "Otros"]

    // MARK: Sugerencias días libres (incluye sugerencias "AI ·")
    static let suggestions: [Suggestion] = [
        // De la lista original
        Suggestion(name: "British Museum", cost: 0, time: "½ día"),
        Suggestion(name: "National Gallery", cost: 0, time: "2-3 h"),
        Suggestion(name: "Museo de Historia Natural", cost: 0, time: "½ día"),
        Suggestion(name: "Museo Nacional de la Armada", cost: 0, time: "2 h"),
        Suggestion(name: "London Museum", cost: 0, time: "2 h"),
        Suggestion(name: "Soho · Seven Dials · Neal's Yard · Carnaby St", cost: 0, time: "tarde"),
        Suggestion(name: "Leadenhall Market + Catedral de San Pablo", cost: 32, time: "½ día"),
        Suggestion(name: "Buckingham Palace (cambio de guardia 11:00 gratis)", cost: 88, time: "½ día"),
        Suggestion(name: "Kensington Palace", cost: 67, time: "½ día"),
        Suggestion(name: "Horizon 22 — mirador (gratis, con reserva)", cost: 0, time: "1 h"),
        Suggestion(name: "Outlet shopping (Bicester Village)", cost: 0, time: "½ día"),
        Suggestion(name: "Pub crawl por los clásicos", cost: 40, time: "noche"),
        Suggestion(name: "Canterbury (día completo)", cost: 60, time: "día"),
        Suggestion(name: "Brighton — ciudad costera (día completo)", cost: 60, time: "día"),
        Suggestion(name: "Cambridge (día completo)", cost: 60, time: "día"),
        Suggestion(name: "York: murallas medievales + The Shambles", cost: 0, time: "½ día"),
        Suggestion(name: "York: Jorvik Viking Centre", cost: 18, time: "2 h"),
        Suggestion(name: "York: York Minster (catedral)", cost: 20, time: "2 h"),
        Suggestion(name: "Edimburgo: Royal Mile + Castillo", cost: 25, time: "½ día"),
        Suggestion(name: "Edimburgo: Arthur's Seat (caminata)", cost: 0, time: "3 h"),
        Suggestion(name: "Edimburgo: Calton Hill al atardecer", cost: 0, time: "1 h"),
        Suggestion(name: "Edimburgo: tour de whisky escocés", cost: 35, time: "2 h"),
        Suggestion(name: "Cotswolds: Bibury + Bourton-on-the-Water", cost: 0, time: "día"),
        Suggestion(name: "Cotswolds: tour guiado de pueblos", cost: 90, time: "día"),
        // Sugerencias de la IA (prefijo AI ·)
        Suggestion(name: "AI · Caminata South Bank: Tate Modern → Globe → Borough", cost: 0, time: "½ día"),
        Suggestion(name: "AI · Notting Hill + Portobello Road Market", cost: 0, time: "½ día"),
        Suggestion(name: "AI · Greenwich: meridiano, Cutty Sark y parque", cost: 0, time: "día"),
        Suggestion(name: "AI · Shoreditch: street art + mercados", cost: 0, time: "½ día"),
        Suggestion(name: "AI · Camden Market + paseo por Regent's Canal", cost: 0, time: "½ día"),
        Suggestion(name: "AI · Victoria & Albert Museum (gratis)", cost: 0, time: "½ día"),
        Suggestion(name: "AI · Tate Modern (arte moderno, gratis)", cost: 0, time: "2 h"),
        Suggestion(name: "AI · The View from The Shard (mirador)", cost: 40, time: "1 h"),
        Suggestion(name: "AI · London Eye", cost: 45, time: "1 h"),
        Suggestion(name: "AI · Harry Potter — Warner Bros Studio Tour", cost: 65, time: "día"),
        Suggestion(name: "AI · Musical en el West End", cost: 70, time: "noche"),
        Suggestion(name: "AI · Crucero por el Támesis", cost: 25, time: "2 h"),
        Suggestion(name: "AI · Abbey Road + St John's Wood", cost: 0, time: "1 h"),
        Suggestion(name: "AI · Covent Garden + artistas callejeros", cost: 0, time: "2 h"),
        Suggestion(name: "AI · Regent's Park + Primrose Hill (atardecer)", cost: 0, time: "2 h"),
        Suggestion(name: "AI · Hampstead Heath (vista de la ciudad)", cost: 0, time: "½ día"),
        Suggestion(name: "AI · Little Venice + barco a Camden", cost: 15, time: "2 h"),
        Suggestion(name: "AI · Windsor Castle (día)", cost: 90, time: "día"),
        Suggestion(name: "AI · Stonehenge + Bath (tour de día)", cost: 120, time: "día"),
        Suggestion(name: "AI · Leeds Castle, Kent (día)", cost: 80, time: "día"),
        Suggestion(name: "AI · Seven Sisters cliffs + Brighton (día)", cost: 60, time: "día"),
        Suggestion(name: "AI · Bletchley Park (día)", cost: 60, time: "día"),
        Suggestion(name: "AI · York: National Railway Museum (gratis)", cost: 0, time: "½ día"),
        Suggestion(name: "AI · York: tour de fantasmas nocturno", cost: 18, time: "1.5 h"),
        Suggestion(name: "AI · York: crucero por el río Ouse", cost: 20, time: "1 h"),
        Suggestion(name: "AI · York: excursión a Whitby (costa)", cost: 45, time: "día"),
        Suggestion(name: "AI · Edimburgo: tour a las Highlands + Loch Ness", cost: 75, time: "día"),
        Suggestion(name: "AI · Edimburgo: Dean Village + Water of Leith", cost: 0, time: "2 h"),
        Suggestion(name: "AI · Edimburgo: Palacio de Holyrood", cost: 25, time: "2 h"),
        Suggestion(name: "AI · Edimburgo: National Museum of Scotland (gratis)", cost: 0, time: "½ día"),
        Suggestion(name: "AI · Edimburgo: excursión a Stirling + Loch Lomond", cost: 70, time: "día"),
        Suggestion(name: "AI · Oxford: tour Harry Potter (Christ Church, Bodleian)", cost: 30, time: "½ día"),
        Suggestion(name: "AI · Oxford: paseo en punt por el río", cost: 25, time: "1 h"),
        Suggestion(name: "AI · Oxford: Ashmolean Museum (gratis)", cost: 0, time: "2 h"),
        Suggestion(name: "AI · Cotswolds: Castle Combe (pueblo de cuento)", cost: 0, time: "½ día"),
        Suggestion(name: "AI · Cotswolds: Blenheim Palace", cost: 45, time: "día"),
        Suggestion(name: "AI · Cotswolds: Bourton-on-the-Water + Model Village", cost: 10, time: "½ día")
    ]

    // MARK: Comidas por ciudad
    static func meals(loc: String, type: MealType) -> [MealOption] {
        (mealsData[loc]?[type] ?? []).map { MealOption(name: $0.0, pricePP: $0.1) }
    }

    private static let mealsData: [String: [MealType: [(String, Int)]]] = [
        "London": [
            .desayuno: [("Full English (The Breakfast Club)",19),("Café + croissant (Pret)",8),("Dishoom — bacon naan",13),("Granger & Co (brunch)",22),("The Wolseley (clásico)",30),("Regency Café (greasy spoon)",12),("Gail's Bakery",9),("Desayuno en el hotel",14),("Porridge & frutas",10),("Ottolenghi (brunch)",20)],
            .almuerzo: [("Borough Market street food",16),("Fish & chips (Poppies)",23),("Pub lunch",19),("Padella (pasta)",18),("Franco Manca (pizza napolitana)",15),("Wagamama (asiático)",18),("Pret / Leon (rápido)",12),("Brick Lane curry",17),("Camden Market food stalls",14),("Dishoom",20)],
            .merienda: [("Afternoon tea",50),("Café + scone",10),("Bubble tea en Chinatown",7),("Cream tea",18),("Gelato (Gelupo)",8),("Crosstown donuts",7),("Té en Fortnum & Mason",60),("Cafetería local",9),("Sketch — afternoon tea",80),("Sky Garden (café con vista)",12)],
            .cena: [("Dishoom (indio)",32),("Flat Iron (steak)",20),("Pub dinner",26),("Chinatown",23),("Honest Burgers",18),("Pizza Pilgrims",16),("Ramen (Kanada-Ya)",17),("The Ivy",55),("Sketch (experiencia)",70),("Gordon Ramsay (especial)",90),("Sushi (Eat Tokyo)",22)]
        ],
        "Oxford": [
            .desayuno: [("The Handle Bar Café",16),("Gail's Bakery",9),("Desayuno en el hotel",12),("Society Café",11),("Brew (brunch)",14),("Jericho Coffee Traders",9),("The Missing Bean",9),("Common Ground (café)",12),("Zappi's",10),("Pret a Manger",8)],
            .almuerzo: [("Oxford Covered Market",15),("The Vaults & Garden",18),("Pub lunch (The Bear)",17),("Pieminister (empanadas)",12),("Najar's Place (falafel)",10),("Sandwich en Taylors",11),("Brothers (Covered Market)",13),("Itsu",12),("Atomic Burger",16),("The Alternative Tuck Shop",10)],
            .merienda: [("The Grand Café (tea)",25),("Café Loco",10),("Vaults afternoon tea",22),("G&D's ice cream",7),("The Rose (cream tea)",18),("Queens Lane Coffee House",9),("Knoops (chocolate)",7),("Maison Blanc (patisserie)",10),("Society Café (cake)",9),("Gelato Boutique",7)],
            .cena: [("The Eagle and Child (pub)",23),("Turl Street Kitchen",28),("The Trout Inn",35),("Pierre Victoire (francés)",30),("Pizza (Mamma Mia)",18),("Edamame (japonés)",20),("The Oxford Kitchen",45),("Gee's Restaurant",40),("Branca (italiano)",28),("The Folly (riverside)",30)]
        ],
        "Cotswolds": [
            .desayuno: [("Desayuno en el hotel",13),("Bakery local",9),("Farm shop café",12),("Huffkins",14),("Bourton House tea",12),("The Bakery on the Water",11),("Lucy's Tearoom (Stow)",13),("Cotswold Cream Tea Co.",12),("The Old Bakery (Bibury)",11),("Trout Farm café",10)],
            .almuerzo: [("The Catherine Wheel (pub)",20),("Picnic en el pueblo",12),("Huffkins tea room",16),("Farm shop deli",14),("The Swan (Bibury)",28),("The Mousetrap Inn (Bourton)",20),("The Old New Inn",19),("Bourton Bakery sandwich",11),("The Porch House (Stow)",26),("Sheep on Sheep St.",24)],
            .merienda: [("Cream tea (scones)",15),("Tea room en Bourton",12),("Bantam Tea Rooms",14),("Helado artesanal",7),("Smiths of Bourton",12),("Lucy's Tearoom",13),("The Croft (Stow)",12),("Cotswold Ice Cream Co.",7),("Huffkins cream tea",16),("Bo Peep Tea Rooms",13)],
            .cena: [("The Swan at Bibury",35),("Pub de pueblo",25),("The Wild Rabbit (especial)",60),("The Bell at Sapperton",38),("The Lamb Inn",30),("The Kingsbridge Inn (Bourton)",28),("The Mousetrap Inn",26),("The Old Stocks (Stow)",40),("The Porch House",38),("Rose & Crown",27)]
        ],
        "York": [
            .desayuno: [("Bettys Café (clásico)",19),("Brew & Brownie",15),("Desayuno en el hotel",12),("Partisan",14),("Spring Espresso",10),("The Hairy Fig",12),("Bullion (brunch)",14),("Grindsmith",9),("Café No.8",16),("Perky Peacock (café)",9)],
            .almuerzo: [("Shambles Market food",13),("Pub lunch",18),("Mannion & Co",17),("Drake's fish & chips",16),("The Cornish Bakery",10),("York Roast Co (Yorkshire wrap)",11),("Ambiente Tapas",18),("Los Moros",16),("The Cheese Yard",12),("Shambles Kitchen wrap",12)],
            .merienda: [("Bettys afternoon tea",32),("York Cocoa Works",12),("Grays Court tea",28),("Brew & Brownie (cake)",10),("Spring Espresso (cake)",9),("The Hairy Fig",11),("Love Cheese",12),("Cardamom Coffee",9),("Bettys cream tea",20),("Crumbs Cupcakery",8)],
            .cena: [("Ambiente (italiano)",28),("The Shambles Kitchen",23),("Skosh (degustación)",50),("Los Moros (marroquí)",26),("The Star Inn the City",40),("Il Paradiso (pizza)",20),("Mannion & Co",30),("The Whippet Inn",32),("Le Cochon Aveugle (tasting)",70),("Rustique (francés)",28)]
        ],
        "Edinburgh": [
            .desayuno: [("Scottish breakfast (hotel)",13),("Söderberg (café)",10),("Urban Angel (brunch)",16),("Loudons",15),("Cairngorm Coffee",11),("The Milkman",10),("Hula Juice Bar",12),("The Pantry",16),("Brew Lab",9),("Century General Store",14)],
            .almuerzo: [("Oink (hog roast roll)",9),("Mums Comfort Food",18),("The Piemaker",7),("Union of Genius (sopas)",11),("Mary's Milk Bar",8),("Pub lunch",17),("Ting Thai Caravan",16),("Civerinos (pizza slice)",12),("The Bearded Baker",12),("Dishoom (lunch)",20)],
            .merienda: [("Té + shortbread",11),("The Milkman (café)",9),("Eteaket tea room",18),("Mary's Milk Bar (gelato)",7),("Lovecrumbs",9),("The Colonnades (afternoon tea)",40),("Mimi's Bakehouse",14),("Söderberg (kanelbulle)",8),("Cairngorm (cake)",9),("Fortitude Coffee",9)],
            .cena: [("Haggis en Arcade Bar",23),("Dishoom Edinburgh",32),("The Witchery (especial)",55),("Makars (escocés)",28),("The Devil's Advocate",30),("Wings (alitas)",18),("Ting Thai Caravan",20),("The Outsider",34),("Howies (Victoria St)",32),("Mother India's Café",24)]
        ]
    ]

    // MARK: Ideas (catálogo con estrellas y reseñas)
    // Datos de rating/reseñas aproximados (referencia Google Maps); la app puede filtrarlos.
    static let ideasCatalog: [Idea] = buildIdeas()

    private static func buildIdeas() -> [Idea] {
        // (ciudad, tipo, nombre, estrellas, reseñas, etiqueta de precio/"Gratis" o nil)
        typealias R = (String, IdeaType, String, Double, Int, String?)
        let rows: [R] = [
            // ===================== LONDRES =====================
            ("Londres", .mercado, "Borough Market", 4.6, 96000, nil),
            ("Londres", .mercado, "Camden Market", 4.4, 182000, nil),
            ("Londres", .mercado, "Old Spitalfields Market", 4.4, 27000, nil),
            ("Londres", .mercado, "Portobello Road Market", 4.4, 36000, nil),
            ("Londres", .mercado, "Leadenhall Market", 4.5, 22000, nil),
            ("Londres", .mercado, "Maltby Street Market", 4.5, 3600, nil),
            ("Londres", .desayuno, "Dishoom (bacon naan)", 4.7, 22000, nil),
            ("Londres", .desayuno, "The Wolseley", 4.5, 9800, nil),
            ("Londres", .desayuno, "Regency Café", 4.6, 3300, nil),
            ("Londres", .desayuno, "The Breakfast Club", 4.4, 4200, nil),
            ("Londres", .desayuno, "Granger & Co", 4.3, 2600, nil),
            ("Londres", .almuerzo, "Padella", 4.6, 9000, nil),
            ("Londres", .almuerzo, "Hawksmoor Seven Dials", 4.6, 9000, nil),
            ("Londres", .almuerzo, "Poppies Fish & Chips", 4.4, 5200, nil),
            ("Londres", .almuerzo, "Flat Iron", 4.6, 8000, nil),
            ("Londres", .almuerzo, "Franco Manca", 4.3, 2600, nil),
            ("Londres", .merienda, "Gelupo (gelato)", 4.6, 2300, nil),
            ("Londres", .merienda, "Crosstown Doughnuts", 4.6, 1500, nil),
            ("Londres", .merienda, "Maison Bertaux", 4.5, 1600, nil),
            ("Londres", .merienda, "Fortnum & Mason (tea room)", 4.5, 4800, nil),
            ("Londres", .afternoonTea, "The Ritz", 4.7, 7600, "USD 100"),
            ("Londres", .afternoonTea, "Claridge's", 4.7, 2400, "USD 95"),
            ("Londres", .afternoonTea, "Sketch (The Gallery)", 4.4, 9000, "USD 90"),
            ("Londres", .afternoonTea, "Fortnum & Mason — Diamond Jubilee", 4.6, 3800, "USD 85"),
            ("Londres", .rooftop, "Sky Garden", 4.5, 24000, "Gratis"),
            ("Londres", .rooftop, "Frank's Café (Peckham)", 4.4, 1900, nil),
            ("Londres", .rooftop, "Madison", 4.3, 2600, nil),
            ("Londres", .rooftop, "Aviary Rooftop", 4.3, 1700, nil),
            ("Londres", .cena, "Dishoom", 4.7, 22000, nil),
            ("Londres", .cena, "Hawksmoor", 4.6, 9000, nil),
            ("Londres", .cena, "Gymkhana", 4.6, 3500, nil),
            ("Londres", .cena, "The Ivy", 4.5, 14000, nil),
            ("Londres", .cena, "Brasserie Zédel", 4.5, 12000, nil),
            ("Londres", .pub, "The Churchill Arms", 4.6, 9500, nil),
            ("Londres", .pub, "The Mayflower", 4.6, 3200, nil),
            ("Londres", .pub, "Ye Olde Cheshire Cheese", 4.4, 4800, nil),
            ("Londres", .pub, "The Black Friar", 4.5, 4200, nil),
            ("Londres", .pub, "The George Inn", 4.4, 3900, nil),
            ("Londres", .pub, "The Lamb & Flag", 4.4, 2100, nil),
            ("Londres", .museo, "British Museum", 4.7, 220000, "Gratis"),
            ("Londres", .museo, "National Gallery", 4.6, 95000, "Gratis"),
            ("Londres", .museo, "Natural History Museum", 4.7, 185000, "Gratis"),
            ("Londres", .museo, "Victoria & Albert Museum", 4.7, 64000, "Gratis"),
            ("Londres", .museo, "Tate Modern", 4.5, 95000, "Gratis"),
            ("Londres", .visita, "Tower of London", 4.6, 95000, "USD 44"),
            ("Londres", .visita, "Westminster Abbey", 4.5, 64000, "USD 38"),
            ("Londres", .visita, "St Paul's Cathedral", 4.6, 38000, "USD 30"),
            ("Londres", .visita, "Buckingham Palace", 4.5, 82000, "USD 88"),
            ("Londres", .mirador, "The Shard", 4.5, 24000, "USD 40"),
            ("Londres", .mirador, "London Eye", 4.5, 120000, "USD 45"),
            ("Londres", .mirador, "Horizon 22", 4.6, 2000, "Gratis"),
            ("Londres", .parque, "Hyde Park", 4.7, 185000, "Gratis"),
            ("Londres", .parque, "St James's Park", 4.7, 64000, "Gratis"),
            ("Londres", .parque, "Regent's Park", 4.8, 45000, "Gratis"),
            ("Londres", .excursion, "Cambridge (día completo)", 4.7, 9000, "USD 60"),
            ("Londres", .excursion, "Brighton (día completo)", 4.6, 12000, "USD 60"),
            ("Londres", .excursion, "Canterbury (día completo)", 4.7, 6000, "USD 60"),
            ("Londres", .excursion, "Stonehenge + Bath (tour)", 4.6, 14000, "USD 120"),
            ("Londres", .excursion, "Windsor Castle (día)", 4.7, 38000, "USD 90"),

            // ===================== OXFORD =====================
            ("Oxford", .mercado, "Oxford Covered Market", 4.5, 8800, nil),
            ("Oxford", .mercado, "Gloucester Green Market", 4.2, 700, nil),
            ("Oxford", .desayuno, "Jericho Coffee Traders", 4.7, 600, nil),
            ("Oxford", .desayuno, "Society Café", 4.6, 900, nil),
            ("Oxford", .desayuno, "The Handle Bar Café", 4.4, 1900, nil),
            ("Oxford", .almuerzo, "Najar's Place (falafel)", 4.8, 700, nil),
            ("Oxford", .almuerzo, "The Covered Market (food)", 4.5, 8800, nil),
            ("Oxford", .almuerzo, "Pieminister", 4.4, 700, nil),
            ("Oxford", .merienda, "Knoops (chocolate)", 4.7, 400, nil),
            ("Oxford", .merienda, "G&D's Café (helado)", 4.5, 1200, nil),
            ("Oxford", .afternoonTea, "The Randolph (Morse Bar)", 4.5, 3000, "USD 45"),
            ("Oxford", .afternoonTea, "The Grand Café", 4.3, 2100, "USD 30"),
            ("Oxford", .afternoonTea, "Vaults & Garden", 4.4, 2600, "USD 28"),
            ("Oxford", .rooftop, "The Varsity Club (rooftop)", 4.3, 900, nil),
            ("Oxford", .cena, "The Oxford Kitchen", 4.6, 700, nil),
            ("Oxford", .cena, "Gee's Restaurant", 4.5, 2300, nil),
            ("Oxford", .cena, "The Trout Inn", 4.4, 4200, nil),
            ("Oxford", .cena, "Branca (italiano)", 4.3, 1500, nil),
            ("Oxford", .pub, "The Turf Tavern", 4.5, 4800, nil),
            ("Oxford", .pub, "The Bear Inn", 4.5, 2200, nil),
            ("Oxford", .pub, "The Eagle and Child", 4.4, 2600, nil),
            ("Oxford", .pub, "The White Horse", 4.4, 1500, nil),
            ("Oxford", .visita, "Christ Church College", 4.6, 9000, "USD 20"),
            ("Oxford", .visita, "Bodleian Library", 4.7, 4800, "USD 12"),
            ("Oxford", .visita, "Radcliffe Camera", 4.7, 3500, "Gratis"),
            ("Oxford", .museo, "Ashmolean Museum", 4.7, 6500, "Gratis"),
            ("Oxford", .paseo, "University Parks", 4.7, 1800, "Gratis"),
            ("Oxford", .paseo, "Punting en Magdalen Bridge", 4.6, 600, "USD 30"),

            // ===================== COTSWOLDS =====================
            ("Cotswolds", .mercado, "Stow Farmers' Market", 4.4, 300, nil),
            ("Cotswolds", .mercado, "Moreton-in-Marsh Market", 4.3, 500, nil),
            ("Cotswolds", .desayuno, "The Bakery on the Water (Bourton)", 4.5, 700, nil),
            ("Cotswolds", .desayuno, "Huffkins (Burford)", 4.4, 1100, nil),
            ("Cotswolds", .almuerzo, "The Sheep on Sheep St. (Stow)", 4.4, 700, nil),
            ("Cotswolds", .almuerzo, "The Mousetrap Inn (Bourton)", 4.4, 900, nil),
            ("Cotswolds", .merienda, "Bantam Tea Rooms (Chipping Campden)", 4.6, 700, nil),
            ("Cotswolds", .merienda, "Tilly's Tea House (Stow)", 4.5, 900, nil),
            ("Cotswolds", .afternoonTea, "The Lygon Arms (Broadway)", 4.5, 1900, "USD 45"),
            ("Cotswolds", .afternoonTea, "Lucy's Tearoom (Stow)", 4.6, 500, "USD 28"),
            ("Cotswolds", .cena, "The Wild Rabbit (Kingham)", 4.5, 700, nil),
            ("Cotswolds", .cena, "The Bell at Sapperton", 4.6, 600, nil),
            ("Cotswolds", .cena, "The Lamb Inn (Burford)", 4.5, 900, nil),
            ("Cotswolds", .cena, "The Porch House (Stow)", 4.4, 1300, nil),
            ("Cotswolds", .pub, "The Eight Bells (Chipping Campden)", 4.6, 700, nil),
            ("Cotswolds", .pub, "The Old New Inn (Bourton)", 4.3, 900, nil),
            ("Cotswolds", .pub, "The Swan (Bibury)", 4.3, 2100, nil),
            ("Cotswolds", .paseo, "Arlington Row (Bibury)", 4.7, 4200, "Gratis"),
            ("Cotswolds", .paseo, "Río Windrush (Bourton)", 4.7, 9000, "Gratis"),
            ("Cotswolds", .visita, "Blenheim Palace", 4.7, 26000, "USD 45"),

            // ===================== YORK =====================
            ("York", .mercado, "Shambles Market", 4.4, 9000, nil),
            ("York", .mercado, "York Designer Outlet", 4.3, 12000, nil),
            ("York", .desayuno, "Bettys Café Tea Rooms", 4.5, 9800, nil),
            ("York", .desayuno, "Spring Espresso", 4.7, 900, nil),
            ("York", .desayuno, "Brew & Brownie", 4.5, 2600, nil),
            ("York", .almuerzo, "Los Moros", 4.7, 1500, nil),
            ("York", .almuerzo, "Mannion & Co", 4.6, 2300, nil),
            ("York", .almuerzo, "York Roast Co", 4.4, 2600, nil),
            ("York", .merienda, "York Cocoa Works", 4.5, 1800, nil),
            ("York", .merienda, "Gray's Court", 4.6, 1100, nil),
            ("York", .afternoonTea, "Bettys (afternoon tea)", 4.5, 9800, "USD 45"),
            ("York", .afternoonTea, "Gray's Court", 4.6, 1100, "USD 38"),
            ("York", .rooftop, "Rooftop @ Malmaison", 4.2, 400, nil),
            ("York", .cena, "Skosh", 4.7, 1500, nil),
            ("York", .cena, "Le Cochon Aveugle", 4.7, 600, nil),
            ("York", .cena, "Ambiente Tapas", 4.5, 2600, nil),
            ("York", .cena, "The Star Inn the City", 4.4, 3500, nil),
            ("York", .pub, "The Blue Bell", 4.6, 1100, nil),
            ("York", .pub, "House of Trembling Madness", 4.5, 3200, nil),
            ("York", .pub, "Guy Fawkes Inn", 4.4, 2300, nil),
            ("York", .pub, "Ye Olde Starre Inne", 4.3, 2100, nil),
            ("York", .visita, "York Minster", 4.7, 26000, "USD 20"),
            ("York", .visita, "The Shambles", 4.6, 22000, "Gratis"),
            ("York", .museo, "National Railway Museum", 4.7, 26000, "Gratis"),
            ("York", .paseo, "Murallas de la ciudad", 4.7, 9000, "Gratis"),

            // ===================== EDIMBURGO =====================
            ("Edimburgo", .mercado, "Grassmarket", 4.5, 9000, nil),
            ("Edimburgo", .mercado, "Stockbridge Market (dom.)", 4.5, 600, nil),
            ("Edimburgo", .desayuno, "The Pantry", 4.6, 1800, nil),
            ("Edimburgo", .desayuno, "Cairngorm Coffee", 4.6, 1100, nil),
            ("Edimburgo", .desayuno, "Urban Angel", 4.4, 1500, nil),
            ("Edimburgo", .almuerzo, "Oink (hog roast roll)", 4.6, 3500, nil),
            ("Edimburgo", .almuerzo, "Ting Thai Caravan", 4.6, 2600, nil),
            ("Edimburgo", .almuerzo, "Mums Great Comfort Food", 4.4, 2300, nil),
            ("Edimburgo", .merienda, "Mary's Milk Bar (gelato)", 4.7, 1500, nil),
            ("Edimburgo", .merienda, "Lovecrumbs", 4.6, 900, nil),
            ("Edimburgo", .afternoonTea, "The Colonnades (Signet Library)", 4.7, 900, "USD 60"),
            ("Edimburgo", .afternoonTea, "The Dome", 4.6, 4800, "USD 45"),
            ("Edimburgo", .afternoonTea, "Prestonfield House", 4.7, 2600, "USD 55"),
            ("Edimburgo", .rooftop, "Cold Town House (rooftop)", 4.3, 2300, nil),
            ("Edimburgo", .rooftop, "The Lookout by Gardener's Cottage", 4.4, 1900, nil),
            ("Edimburgo", .rooftop, "Forth Floor (Harvey Nichols)", 4.4, 1500, nil),
            ("Edimburgo", .cena, "The Witchery by the Castle", 4.6, 4200, nil),
            ("Edimburgo", .cena, "Wedgwood the Restaurant", 4.8, 1800, nil),
            ("Edimburgo", .cena, "Dishoom Edinburgh", 4.6, 12000, nil),
            ("Edimburgo", .cena, "The Outsider", 4.5, 2300, nil),
            ("Edimburgo", .pub, "The Bow Bar", 4.6, 1800, nil),
            ("Edimburgo", .pub, "The Sheep Heid Inn", 4.5, 3200, nil),
            ("Edimburgo", .pub, "Sandy Bell's (música en vivo)", 4.6, 900, nil),
            ("Edimburgo", .pub, "Greyfriars Bobby's Bar", 4.3, 4200, nil),
            ("Edimburgo", .visita, "Edinburgh Castle", 4.6, 64000, "USD 24"),
            ("Edimburgo", .visita, "Real Mary King's Close", 4.7, 22000, "USD 24"),
            ("Edimburgo", .visita, "Palace of Holyroodhouse", 4.6, 9000, "USD 22"),
            ("Edimburgo", .museo, "National Museum of Scotland", 4.7, 38000, "Gratis"),
            ("Edimburgo", .parque, "Arthur's Seat", 4.8, 26000, "Gratis"),
            ("Edimburgo", .mirador, "Calton Hill", 4.7, 14000, "Gratis"),
            ("Edimburgo", .excursion, "Highlands + Loch Ness (tour)", 4.7, 18000, "USD 75"),
            ("Edimburgo", .excursion, "St Andrews (día)", 4.7, 9000, "USD 40"),
        ]
        return rows.map { r in
            var i = Idea(name: r.2, city: r.0, type: r.1, stars: r.3, reviews: r.4)
            if let l = r.5 {
                if l.caseInsensitiveCompare("Gratis") == .orderedSame { i.free = "Gratis" } else { i.cost = l }
            }
            return i
        }
    }

    static let sheetID = "1IfUD4eHgmnd-VFAuUMe5yyLziJD1qQXvcE71V3LMHoA"
    static let lastSync = "27 jun 2026"
}

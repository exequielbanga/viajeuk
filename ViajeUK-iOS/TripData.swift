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
        let airbnb = "https://maps.app.goo.gl/jDUNFEDPzbHU2Xsv9"
        let vio = "https://www.vio.com/Hotel/117111638/en"
        let premierOxford = "https://www.premierinn.com/gb/en/hotels/england/oxfordshire/oxford/oxford-botley.html"
        let bookingYork = "https://www.booking.com/hotel/gb/lils-on-the-waterfront.es.html"
        let premierEdin = "https://www.premierinn.com/gb/en/hotels/scotland/lothian/edinburgh/edinburgh-east.html"

        var blocks: [CityBlock] = [
            CityBlock(city: "Londres — Llegada", dates: "Jue 9 – Vie 10 Jul", image: imgLondon, loc: "London", days: [
                DayPlan(title: "Jueves 9 Jul", items: [
                    ItineraryItem(act: "Vuelo Buenos Aires → Londres", det: "Vuelo internacional, 2 personas", price: 2290, cat: "Vuelos", res: true, paid: false),
                    ItineraryItem(act: "Check-in AirBnb", det: "Londres", res: true, paid: false, map: airbnb)
                ]),
                DayPlan(title: "Viernes 10 Jul", items: [
                    ItineraryItem(time: "11:30", act: "Dejar valijas en Bounce", det: "Guarda de equipaje", price: 25, cat: "Otros", res: true, paid: false),
                    ItineraryItem(time: "15:00", act: "Check-in AirBnb", res: true, paid: false),
                    ItineraryItem(time: "18:00", act: "Mica — cena en Fingers", det: "Plan de Mica", res: true, paid: false),
                    ItineraryItem(time: "18:00", act: "Exe libre", det: "Mientras Mica cena, Exe arma su noche", free: true, freeID: "vie10"),
                    ItineraryItem(act: "AirBnb (noche)", det: "Londres", price: 173, cat: "Alojamiento", res: true, paid: false, map: airbnb)
                ])
            ]),
            CityBlock(city: "Londres — Semana del congreso", dates: "Sáb 11 – Mar 14 Jul", image: imgLondonAlt, loc: "London", days: [
                DayPlan(title: "Sábado 11 Jul", items: [
                    ItineraryItem(time: "Mañana", act: "Exe libre", det: "Mica en el congreso hasta las 17:00", price: 600, cat: "Actividades", res: true, paid: false, free: true, freeID: "sab11"),
                    ItineraryItem(time: "18:00", act: "Afternoon tea", det: "Juntos — clásico británico", price: 200, cat: "Comidas", res: true, paid: false),
                    ItineraryItem(act: "AirBnb (noche)", price: 173, cat: "Alojamiento", res: true, paid: false, map: airbnb)
                ]),
                DayPlan(title: "Domingo 12 Jul", items: [
                    ItineraryItem(time: "Todo el día", act: "Exe libre", det: "Mica en el congreso (hasta 19:30)", price: 45, cat: "Actividades", res: true, paid: false, free: true, freeID: "dom12"),
                    ItineraryItem(act: "AirBnb (noche)", price: 173, cat: "Alojamiento", res: true, paid: false, map: airbnb)
                ]),
                DayPlan(title: "Lunes 13 Jul", items: [
                    ItineraryItem(time: "Todo el día", act: "Exe libre", det: "Mica en el congreso (hasta 19:30)", price: 50, cat: "Actividades", res: true, paid: false, free: true, freeID: "lun13"),
                    ItineraryItem(act: "AirBnb (noche)", price: 173, cat: "Alojamiento", res: true, paid: false, map: airbnb)
                ]),
                DayPlan(title: "Martes 14 Jul", items: [
                    ItineraryItem(time: "Todo el día", act: "Exe libre", det: "Mica en el congreso (hasta 23:00)", price: 70, cat: "Actividades", res: true, paid: false, free: true, freeID: "mar14"),
                    ItineraryItem(act: "AirBnb (noche)", price: 173, cat: "Alojamiento", res: true, paid: false, map: airbnb)
                ])
            ]),
            CityBlock(city: "Londres — Turismo juntos", dates: "Mié 15 – Jue 16 Jul", image: imgLondon, loc: "London", days: [
                DayPlan(title: "Miércoles 15 Jul", items: [
                    ItineraryItem(time: "10:00", act: "Exe lleva las cosas al nuevo hotel", det: "Mica en el congreso hasta las 14:00", res: false, paid: false),
                    ItineraryItem(time: "12:00", act: "Llegada al nuevo hotel", det: "Cambio de alojamiento", res: false, paid: false, link: vio),
                    ItineraryItem(time: "16:00", act: "Camden Town", det: "Mercado y barrio alternativo", res: false, paid: false),
                    ItineraryItem(time: "19:00", act: "Notting Hill", det: "Paseo por el barrio", res: false, paid: false),
                    ItineraryItem(act: "Hotel (noche)", price: 150, cat: "Alojamiento", res: false, paid: false, link: vio)
                ]),
                DayPlan(title: "Jueves 16 Jul", items: [
                    ItineraryItem(act: "Tower of London", det: "Torre histórica y joyas de la corona", price: 94, cat: "Actividades", res: false, paid: false),
                    ItineraryItem(act: "Tower Bridge", det: "Subida al puente", price: 43, cat: "Actividades", res: false, paid: false),
                    ItineraryItem(act: "Hay's Galleria", det: "Mercadito junto al río", res: false, paid: false),
                    ItineraryItem(act: "London Bridge", res: false, paid: false),
                    ItineraryItem(act: "Borough Market", det: "Mercado gastronómico", res: false, paid: false),
                    ItineraryItem(time: "20:00", act: "Sky Garden", det: "Mirador (reserva gratis o copa)", price: 40, cat: "Actividades", res: false, paid: false),
                    ItineraryItem(act: "Hotel (noche)", price: 150, cat: "Alojamiento", res: false, paid: false)
                ])
            ]),
            CityBlock(city: "Oxford", dates: "Vie 17 Jul", image: imgOxford, loc: "Oxford", days: [
                DayPlan(title: "Viernes 17 Jul", items: [
                    ItineraryItem(time: "10:20–11:30", act: "Tren Londres → Oxford", price: 52, cat: "Transporte", res: false, paid: false, link: "https://www.omio.com"),
                    ItineraryItem(time: "15:00", act: "Hotel Premier Inn (check-in)", det: "Oxford Botley", res: false, paid: false, link: premierOxford),
                    ItineraryItem(act: "Recorrer la universidad", det: "A definir — colegios y Radcliffe Camera", res: false, paid: false),
                    ItineraryItem(act: "The Dial House", det: "Cena / experiencia", price: 155, cat: "Comidas", res: false, paid: false, link: "https://secure.booking.com")
                ])
            ]),
            CityBlock(city: "Cotswolds", dates: "Sáb 18 Jul", image: imgCotswolds, loc: "Cotswolds", days: [
                DayPlan(title: "Sábado 18 Jul", items: [
                    ItineraryItem(time: "Día", act: "Día libre en los Cotswolds", det: "Pueblos de piedra dorada: Bibury, Bourton-on-the-Water", price: 200, cat: "Actividades", res: false, paid: false, free: true, freeID: "sab18"),
                    ItineraryItem(act: "Hotel Premier Inn (noche)", det: "Oxford", price: 155, cat: "Alojamiento", res: false, paid: false, link: premierOxford)
                ])
            ]),
            CityBlock(city: "York", dates: "Dom 19 – Lun 20 Jul", image: imgYork, loc: "York", days: [
                DayPlan(title: "Domingo 19 Jul", items: [
                    ItineraryItem(time: "9:20–15:00", act: "Tren Oxford → York", price: 250, cat: "Transporte", res: false, paid: false, link: "https://www.omio.com.ar"),
                    ItineraryItem(time: "15:00", act: "Llegada al hotel", det: "Lil's on the Waterfront", res: false, paid: false, link: bookingYork),
                    ItineraryItem(time: "Tarde", act: "Tarde libre en York", det: "A definir", free: true, freeID: "dom19"),
                    ItineraryItem(act: "Hotel (noche)", price: 107, cat: "Alojamiento", res: false, paid: false, link: bookingYork)
                ]),
                DayPlan(title: "Lunes 20 Jul", items: [
                    ItineraryItem(time: "Día", act: "Día libre en York", det: "A definir — murallas, The Shambles, Minster", free: true, freeID: "lun20"),
                    ItineraryItem(act: "Hotel (noche)", price: 107, cat: "Alojamiento", res: false, paid: false, link: bookingYork)
                ])
            ]),
            CityBlock(city: "Edimburgo", dates: "Mar 21 – Mié 22 Jul", image: imgEdinburgh, loc: "Edinburgh", days: [
                DayPlan(title: "Martes 21 Jul", items: [
                    ItineraryItem(time: "8:30–11:15", act: "Tren York → Edimburgo", price: 120, cat: "Transporte", res: false, paid: false),
                    ItineraryItem(time: "15:00", act: "Hotel (check-in)", det: "Premier Inn Edinburgh East", res: false, paid: false, link: premierEdin),
                    ItineraryItem(time: "Tarde", act: "Tarde libre en Edimburgo", det: "A definir — Royal Mile, Castillo", free: true, freeID: "mar21"),
                    ItineraryItem(act: "Hotel (noche)", price: 268, cat: "Alojamiento", res: false, paid: false, link: premierEdin)
                ]),
                DayPlan(title: "Miércoles 22 Jul", items: [
                    ItineraryItem(time: "Día", act: "Día libre en Edimburgo", det: "A definir — Arthur's Seat, Calton Hill, whisky", free: true, freeID: "mie22"),
                    ItineraryItem(act: "Hotel (noche)", price: 268, cat: "Alojamiento", res: false, paid: false, link: premierEdin)
                ])
            ]),
            CityBlock(city: "Londres — Cierre", dates: "Jue 23 – Sáb 25 Jul", image: imgLondonAlt, loc: "London", days: [
                DayPlan(title: "Jueves 23 Jul", items: [
                    ItineraryItem(time: "7:30–12:00", act: "Tren Edimburgo → Londres", price: 252, cat: "Transporte", res: false, paid: false, link: "https://rail.ninja"),
                    ItineraryItem(time: "15:00", act: "Check-in hotel", det: "Londres", res: false, paid: false),
                    ItineraryItem(act: "Parque St James", res: false, paid: false),
                    ItineraryItem(act: "Buckingham Palace", det: "Fachada y cambio de guardia", res: false, paid: false),
                    ItineraryItem(act: "Big Ben", res: false, paid: false),
                    ItineraryItem(act: "Abadía de Westminster", res: false, paid: false),
                    ItineraryItem(act: "Hotel (noche)", price: 150, cat: "Alojamiento", res: false, paid: false, link: vio)
                ]),
                DayPlan(title: "Viernes 24 Jul", items: [
                    ItineraryItem(time: "Día", act: "Día libre en Londres", det: "Último día — lo que haya quedado pendiente", free: true, freeID: "vie24"),
                    ItineraryItem(act: "Hotel (noche)", price: 150, cat: "Alojamiento", res: false, paid: false, link: vio)
                ]),
                DayPlan(title: "Sábado 25 Jul", items: [
                    ItineraryItem(act: "Vuelo de regreso a Buenos Aires", det: "Fin del viaje", res: false, paid: false)
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
            .merienda: [("Afternoon tea",50),("Café + scone",10),("Bubble tea en Chinatown",7),("Cream tea",18),("Gelato (Gelupo)",8),("Crosstown donuts",7),("Té en Fortnum & Mason",60),("Cafetería local",9)],
            .cena: [("Dishoom (indio)",32),("Flat Iron (steak)",20),("Pub dinner",26),("Chinatown",23),("Honest Burgers",18),("Pizza Pilgrims",16),("Ramen (Kanada-Ya)",17),("The Ivy",55),("Sketch (experiencia)",70),("Gordon Ramsay (especial)",90),("Sushi (Eat Tokyo)",22)]
        ],
        "Oxford": [
            .desayuno: [("The Handle Bar Café",16),("Gail's Bakery",9),("Desayuno en el hotel",12),("Society Café",11),("Brew (brunch)",14)],
            .almuerzo: [("Oxford Covered Market",15),("The Vaults & Garden",18),("Pub lunch (The Bear)",17),("Pieminister (empanadas)",12),("Najar's Place (falafel)",10)],
            .merienda: [("The Grand Café (tea)",25),("Café Loco",10),("Vaults afternoon tea",22),("G&D's ice cream",7)],
            .cena: [("The Eagle and Child (pub)",23),("Turl Street Kitchen",28),("The Trout Inn",35),("Pierre Victoire (francés)",30),("Pizza (Mamma Mia)",18),("Edamame (japonés)",20)]
        ],
        "Cotswolds": [
            .desayuno: [("Desayuno en el hotel",13),("Bakery local",9),("Farm shop café",12),("Huffkins",14)],
            .almuerzo: [("The Catherine Wheel (pub)",20),("Picnic en el pueblo",12),("Huffkins tea room",16),("Farm shop deli",14)],
            .merienda: [("Cream tea (scones)",15),("Tea room en Bourton",12),("Bantam Tea Rooms",14),("Helado artesanal",7)],
            .cena: [("The Swan at Bibury",35),("Pub de pueblo",25),("The Wild Rabbit (especial)",60),("The Bell at Sapperton",38),("The Lamb Inn",30)]
        ],
        "York": [
            .desayuno: [("Bettys Café (clásico)",19),("Brew & Brownie",15),("Desayuno en el hotel",12),("Partisan",14)],
            .almuerzo: [("Shambles Market food",13),("Pub lunch",18),("Mannion & Co",17),("Drake's fish & chips",16),("The Cornish Bakery",10)],
            .merienda: [("Bettys afternoon tea",32),("York Cocoa Works",12),("Grays Court tea",28),("Brew & Brownie (cake)",10)],
            .cena: [("Ambiente (italiano)",28),("The Shambles Kitchen",23),("Skosh (degustación)",50),("Los Moros (marroquí)",26),("The Star Inn the City",40),("Il Paradiso (pizza)",20)]
        ],
        "Edinburgh": [
            .desayuno: [("Scottish breakfast (hotel)",13),("Söderberg (café)",10),("Urban Angel (brunch)",16),("Loudons",15),("Cairngorm Coffee",11)],
            .almuerzo: [("Oink (hog roast roll)",9),("Mums Comfort Food",18),("The Piemaker",7),("Union of Genius (sopas)",11),("Mary's Milk Bar",8),("Pub lunch",17)],
            .merienda: [("Té + shortbread",11),("The Milkman (café)",9),("Eteaket tea room",18),("Mary's Milk Bar (gelato)",7)],
            .cena: [("Haggis en Arcade Bar",23),("Dishoom Edinburgh",32),("The Witchery (especial)",55),("Makars (escocés)",28),("The Devil's Advocate",30),("Wings (alitas)",18),("Ting Thai Caravan",20)]
        ]
    ]

    // MARK: Ideas / Pubs
    static let ideasLondon: [Idea] = [
        Idea(name: "British Museum", free: "Gratis"), Idea(name: "National Gallery", free: "Gratis"),
        Idea(name: "Museo de Historia Natural", free: "Gratis"), Idea(name: "Museo Nacional de la Armada", free: "Gratis"),
        Idea(name: "London Museum", free: "Gratis"), Idea(name: "Galería Nacional", free: "Gratis"),
        Idea(name: "Horizon 22 (mirador)", free: "Gratis"), Idea(name: "Soho · Seven Dials · Neal's Yard · Carnaby St", free: "Gratis"),
        Idea(name: "Leadenhall Market + San Pablo", cost: "USD 32"), Idea(name: "Buckingham Palace", cost: "USD 88"),
        Idea(name: "Cambio de guardia (11:00)", free: "Gratis"), Idea(name: "Kensington Palace", cost: "USD 67"),
        Idea(name: "Outlet shopping", cost: "—"),
        Idea(name: "South Bank: Tate Modern → Globe → Borough", free: "Gratis", ai: true),
        Idea(name: "Greenwich (meridiano + parque)", free: "Gratis", ai: true),
        Idea(name: "Shoreditch street art", free: "Gratis", ai: true),
        Idea(name: "The View from The Shard", cost: "USD 40", ai: true),
        Idea(name: "Harry Potter — Warner Bros Studio", cost: "USD 65", ai: true),
        Idea(name: "Musical en el West End", cost: "USD 70", ai: true),
        Idea(name: "Crucero por el Támesis", cost: "USD 25", ai: true)
    ]
    static let ideasTrips: [Idea] = [
        Idea(name: "Canterbury — ciudad histórica", cost: "Día completo"),
        Idea(name: "Brighton — ciudad costera", cost: "Día completo"),
        Idea(name: "Cambridge — ciudad universitaria", cost: "Día completo"),
        Idea(name: "Windsor Castle", cost: "USD 90 · día", ai: true),
        Idea(name: "Stonehenge + Bath", cost: "USD 120 · día", ai: true),
        Idea(name: "Highlands + Loch Ness (desde Edimburgo)", cost: "USD 75 · día", ai: true),
        Idea(name: "Whitby (costa, desde York)", cost: "USD 45 · día", ai: true),
        Idea(name: "Blenheim Palace (Cotswolds)", cost: "USD 45 · día", ai: true)
    ]
    static let pubs = ["The Marquis","The Black Friar","The Lamb and Flag","The George","The Mayflower","The King's Arms","The Seven Stars"]

    static let sheetID = "17lOnQGgIU0spGig9Hn7U43lg3dEZ6Q0bEWp9JfhpL6g"
    static let lastSync = "20 jun 2026"
}

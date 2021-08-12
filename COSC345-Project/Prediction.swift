//
//  Prediction.swift
//  COSC345-Project
//
//  Created by Hunter Kingsbeer on 28/05/21.
//

import Foundation
import SwiftUI

/// Determines the category of a receipt via specific key words present in the body text.
struct Prediction {
    
    /// Text is passed through keywords, in order to find category with most matches
    /// Parameter : body text of receipt to predict
    static func pointPrediction(text: String) -> String {
        // NEEDS TO BE STREAMLINED TO FIRST VIEW MINIMAL KEY WORDS
        // IF MATCHES MINIMAL KEY WORDS IN CATEGORY, ONLY SEARCH CATEGORIES THAT IT MATCHS
            // ELSE SEARCH ALL CATEGORIES
        // THIS SHOULD CUT DOWN ON SEARCHING ALL CATEGORY KEYWORDS WHEN UN-NEEDED
        
        // Gets the possible predicted categories based on keywords
        let predictedTypes: [(title: String, matches: Int)] = predictedCategories(text: text)
        // Holds the index of the prediction with most matches. Format =(count, index)
        var bestPrediction = (title: "Default", matches: 0)
        
        for prediction in predictedTypes where prediction.matches > bestPrediction.matches {
            // if current prediction has higher num of matches, becomes new highest index
            bestPrediction.title = prediction.title.capitalized
            bestPrediction.matches = prediction.matches
        }
        // return prediction with highest num of matches
        print("Final Prediction: \(bestPrediction.title)")
        return bestPrediction.title
    }
    
    /// Input text is compared against keywords in order to find matching words to make our prediction.
    /// Parameter : Body text of the receipt to predict.
    /// Return : [String] of predicted category titles.
    static func predictedCategories(text: String) -> [(String, Int)] {
        var predictedType: [(title: String, matches: Int)] = [("", 0)]
        
        for category in categoryKeywords {
            let count = matchString(keywords: category.1, input: text)
            if count > 0 {
                print("Category Prediction: \(category.0), \(count) matches." )
                predictedType.append((category.0, count))
            }
        }
        return predictedType
    }
    
    /// Counts the number of words in the receipt text input that match the category's keywords.
    /// Parameter : Keywords - array of keywords to search, Input - text to match against keywords
    /// Return : The number of matched words.
    static func matchString(keywords: [String], input: String) -> Int {
        var count = 0
        for keyword in keywords {
            if input.lowercased().contains(keyword){
                print("\nMatched word '\(keyword)'")
                count += 1
            }
        }
        return count
    }
    
    /// Collections of keywords associated with each category.
    /// Format : [("TitleOfCategory1", ["key", "words"]), ("TitleOfCategory2", ["key", "words"])]
    
    // TODO: rework these into overshadowing categories and then into subcategories
    static let categoryKeywords = [(title: "groceries",
                                    keywords: ["grocer", "grocery", "supermarket", "market",
                                              "grcoeries", "new world", "countdown", "veggie boys",
                                              "veggieboys", "count down", "newworld", "food town",
                                              "foodtown", "unimart", "uni mart", "kosco",
                                              "paknsave", "pak n save", "four square",
                                              "foursquare", "super value", "supervalue",
                                              "freshchoice", "fresh choice", "woolworths",
                                              "wool worths", "night n day", "night 'n day",
                                              "food", "mart", "fruit", "vegetables", "veges",
                                              "veggies", "mart", "minimart", "produce",
                                              "butcher", "butchers", "butchery", "chicken",
                                              "beef", "pork", "milk", "cheese", "sauce"]),
                               
                                   (title: "retail",
                                    keywords: ["harvey norman", "noel leeming", "noel leemings",
                                                "jb", "hi-fi", "the warehouse", "the ware house",
                                                "hifi", "department", "furniture", "tech",
                                                "technology", "smiths", "smiths city", "mall",
                                                "souvenirs", "eletronics", "beds", "sport",
                                                "sports", "trade", "flooring", "bathrooms",
                                                "bed", "bedding", "outlet", "post", "world",
                                                "craft", "crafts", "supply", "garden", "stihl",
                                                "appliance", "headphone", "phone", "computer",
                                                "laptop", "watch"]),
                                   
                                   (title: "technology",
                                    keywords: ["jb hi-fi", "jb hifi", "cello", "noel leeming",
                                              "jaycar", "smiths city", "smith city", "computer",
                                              "laptop", "phone", "tablet", "monitor", "screen",
                                              "speaker", "speakers", "headphones", "headset",
                                              "earphones", "ear buds", "mouse", "keyboard",
                                              "router"]),
                                   
                                   (title: "hardware",
                                    keywords: ["mitre 10", "bunnings", "placemakers", "tool",
                                              "saw", "drill", "knife", "axe", "hammer",
                                              "screwdriver", "pliers", "wrench", "trowel",
                                              "rivet", "nail", "glue", "shovel", "chisel",
                                              "clamp", "file", "spanner", "level", "measuring tape",
                                              "tape measure", "level", "wire cutters", "tape",
                                              "ladder"]),
                                   
                                   (title: "appliance",
                                    keywords: ["smyths living", "kitchen things", "noel leeming",
                                              "quality appliances", "appliance king", "briscoes",
                                              "harvey norman", "jb hi-fi", "jb hifi", "the warehouse",
                                              "dishwasher", "washing machine", "dryer", "oven",
                                              "microwave", "refridgerator", "fridge", "freezer",
                                              "stove", "juicer", "mixer", "fryer", "food processor",
                                              "blender"]),
                               
                                   (title: "clothing",
                                    keywords: ["clothing", "toff's", "toffs", "second hand",
                                              "secondhand", "opshop", "outlet", "footwear",
                                              "shoes", "shoe", "sneaker", "sneakers", "boot",
                                              "boots", "jacket", "jackets", "puffer", "pant",
                                              "pantyhose", "shirt", "t-shirt", "pavement",
                                              "void", "huffer", "postie", "jean",
                                              "postie plus", "postie+", "amazon", "cotton on",
                                              "cottonon", "cotton:on", "hallenstein", "shorts",
                                              "hallensteins", "barkers", "barker", "suit",
                                              "sweater", "sweatshirt", "sweatshirts", "hood",
                                              "hoodie", "hoody", "swimsuit", "bikini", "tee"]),
                                   
                                   (title: "pets",
                                    keywords: ["dog", "puppy", "cat", "kitten", "hamster", "gerbil",
                                              "mouse", "bird", "parrot", "litter", "litter box", "bowl",
                                              "pet food", "pet box", "pet carrier"]),
                                   
                                   (title: "baby & toddler",
                                    keywords: ["nappy", "nappies", "diapers", "stroller", "baby carrier",
                                              "car seat", "play mat", "pacifier", "bottle warmer", "bib",
                                              "high chair", "baby formula", "baby lotion", "crib",
                                              "cradle", "bassinet", "baby monitor", "mittens", "onesie",
                                              "booties", "rompers", "baby swing", "bottle sterilizer"]),
                                   
                                   (title: "luggage",
                                    keywords: ["bag", "suitcase", "backpack", "satchel", "fanny pack",
                                              "duffel", "tote", "trunk", "pet box", "pet carrier",
                                              "ski bag", "handbag", "carry on case", "poster tube",
                                              "instrument case", "hard shell", "hat bag", "briefcase",
                                              "camera bag", "pelican case", "ride-on case",
                                              "ride on case", "packs", "dry box", "messenger bags",
                                              "garment bags"]),
                                   
                                   (title: "health & beauty",
                                    keywords: ["soap", "shampoo", "conditioner", "deodorant",
                                              "throat lozenge", "face mask", "thermometer",
                                              "painkillers", "paracetamol", "panadol", "ibuprofen",
                                              "nurofen", "plaster", "bandage", "bandaid", "band aid",
                                              "vitamins", "vitamin", "vapo rub", "vapodrops",
                                              "disinfectant", "antiseptic", "dettol", "deep heat",
                                              "emulgel", "berocca", "antihistamine", "hayfever",
                                              "allergy relief", "savlon", "lemsip", "centrum",
                                              "nuromol", "voltaren", "codral", "probiotics",
                                              "moisturiser", "antiperspirant", "hand wash",
                                              "hand sanitizer", "toothpaste", "toothbrush",
                                              "mouthwash", "floss", "lip balm", "hand cream",
                                              "facial cleanser", "nail polish", "aftershave",
                                              "mascara", "razor", "toiletry bag", "concealer",
                                              "tweezers", "foundation", "face powder", "face primer",
                                              "eyelash glue", "contour powder", "contour cream",
                                              "bronzer", "highlighter", "lipgloss",
                                              "makeup remover", "blush", "setting spray"]),
                                   
                                   (title: "home & garden",
                                    keywords: ["mckenzie & willis", "mckenzie and willis",
                                               "harvey norman", "my mate johns", "my mate john's",
                                               "big save furniture", "early settler",
                                               "smiths city", "smith city", "hunter home",
                                               "bedpost", "bedsrus", "farmers", "table", "desk",
                                               "chair", "stool", "recliner", "couch", "sofa",
                                               "ottoman", "bed", "drawer", "drawers", "cabinet",
                                               "shears", "loppers", "garden fork", "trowel",
                                               "spade", "rake", "hoe", "hose", "watering can",
                                               "wheelbarrow", "pot", "plant", "bird house",
                                               "bird bath", "pruner", "fertilizer", "compost",
                                               "trowel", "weeder", "garden fork", "broom",
                                               "axe", "hedge clippers", "mattock", "saw",
                                               "spreader", "cultivator", "secateurs", "seeds",
                                               "lettuce", "potatoes", "asparagus", "kale",
                                               "cauliflower", "tomato", "spinach", "silverbeet",
                                               "capsicum", "broccoli", "thyme", "sage", "rosemary",
                                               "parsley", "origanum", "mint", "coriander", "chives",
                                               "basil", "tarragon", "borage", "rocket", "rhubarb",
                                               "oregano", "basil", "marjoram", "fennel", "dill",
                                               "coriander", "chamomile", "garlic", "cucumber",
                                               "shallot", "lisianthus", "salvia", "dianthus",
                                               "lavender", "floraviva", "primula balerina",
                                               "pansy", "violet", "verbena", "primrose", "petunia",
                                               "silverdust", "snap dragon", "alyssum", "cyclamen",
                                               "rose", "bacopa", "heliotrope", "daisy", "carnation",
                                               "dalaya", "daffodil", "lily"]),
                                   
                                   (title: "office supplies",
                                    keywords: ["stapler", "staples", "paper", "printer", "pens",
                                              "pencils", "scissors", "paper clips",
                                              "binder clips", "tape", "tape dispenser", "highlighter",
                                              "permanent markers", "glue", "glue stick", "rubber band",
                                              "pencil sharpener", "hole punch", "calculator",
                                              "envelopes", "stamps", "sticky notes", "notepads",
                                              "ink", "toner", "cartridge", "file cabinent",
                                              "file folders", "file labels", "binders",
                                              "index dividers", "calendar", "planner", "whiteboard",
                                              "white board", "papper shredder", "scanner",
                                              "label maker"]),
                                   
                                   (title: "apparel & accessories",
                                    keywords: ["sunglasses", "apron", "necklace", "watch",
                                              "tie", "purse", "ring", "gloves", "scarf", "umbrella",
                                              "earmuffs", "hair clip", "bobby pin", "hair band",
                                              "safety pin", "watch"]),
                                   
                                   (title: "arts & entertainment",
                                    keywords: ["dvd", "cd", "blu-ray", "playstation", "xbox", "switch",
                                              "nintendo", "ps4", "ps5", "sony", "microsoft", "paint brush",
                                              "paint", "watercolour", "acrylic", "eraser", "sketchbook",
                                              "ruler", "palette", "canvas", "ink", "easel", "varnish",
                                              "crayons", "tempera", "controller", "pastels", "clay",
                                              "plasticine", "felt", "scissors", "glue", "tape", "charcoal",
                                              "card", "paper"]),
                                   
                                   (title: "software",
                                    keywords: ["ide", "integrated development environment", "app",
                                              "application", "video game", "cad", "cadd",
                                              "computer aided design", "computer-aided design",
                                              "game engine", "unity", "unreal", "game maker",
                                              "daw", "digital audio workstation", "ableton live",
                                              "fl studio", "fruity loops", "logic Pro", "bitwig",
                                              "reason", "reaper", "studio one", "pro tools",
                                              "protools", "word processor", "image editor",
                                              "photoshop", "video editor", "adobe", "premiere pro",
                                              "vegas pro", "after effects", "wondershare",
                                              "filmora pro", "autodesk flame", "autodesk smoke",
                                              "avid media composer", "camtasia", "davinci resolve",
                                              "final cut pro"]),
                                   
                                   (title: "toys & games",
                                    keywords: ["puzzle", "wasjig", "board game", "monopoly", "chess",
                                              "checkers", "draughts", "catan", "dice", "dnd",
                                              "d&d", "dungeons and dragons", "dice", "cards"]),
                                   
                                   (title: "sports",
                                    keywords: ["football", "soccer", "rugby", "cricket",
                                              "basketball", "ball", "stick", "boots", "gloves",
                                              "frisbee", "mouthguard", "shin pads", "elbow pads",
                                              "helmet", "whistle", "goal", "post", "net", "uniform",
                                              "cones", "weights"]),
                                   
                                   (title: "vehicles",
                                    keywords: ["timing chain", "camshaft", "crankshaft", "spark plug",
                                              "cylinder head", "valve", "piston", "battery",
                                              "gearbox", "alternator", "radiator", "coolant", "mags",
                                              "rims", "hub", "wheel", "shocks", "shock absorber",
                                              "brakes", "brake pads", "brake calipers", "brake discs",
                                              "catalytic converter", "muffler", "turbocharger",
                                              "supercharger", "intake", "tyres", "tires"]),
                                   
    ]
    
    /// Searches through keywordLists. Checking the title (category.0) until it matches, upon which it returns said category.
    /// Parameter : Title - the title of the desired category.
    /// Return : The category that is requested.
    static func getCategory(title: String) -> (String, [String]) {
        for category in categoryKeywords {
            if category.0.lowercased() == title.lowercased() {
                return category
            }
        }
        return ("", [""])
    }
}

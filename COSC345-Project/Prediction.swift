//
//  Prediction.swift
//  COSC345-Project
//
//  Created by Hunter Kingsbeer on 28/05/21.
//

import Foundation
import SwiftUI

/// ``HomeView``
/// is a View struct that displays the home page of the application. This homepage shows the user its receipts, the folders, the title bar (doubling as a search bar).
/// - Called by ContentView.
struct Prediction {
    /* NEEDS TO BE STREAMLINED TO FIRST VIEW MINIMAL KEY WORDS
    IF MATCHES MINIMAL KEY WORDS IN CATEGORY, ONLY SEARCH CATEGORIES THAT IT MATCHS
        ELSE SEARCH ALL CATEGORIES
    THIS SHOULD CUT DOWN ON SEARCHING ALL CATEGORY KEYWORDS WHEN UN-NEEDED IN THE FINAL VERSION */
    
    ///``pointPrediction``
    /// is the parent function that manages the processing of the receipt text to predict it's folder assignment.
    /// It first uses predictedCategories to to get an idea of the various categories it may be associated with, then checks each category's number of matches and assigns a best prediction based on the matches.
    /// - Parameter text: the body of text (extracted from a receipt) to be processed and have the category predicted from.
    /// - Returns: A string holding the predicted folder title the receipt should be assigned to.
    static func pointPrediction(text: String) -> String {
        ///``predictionTypes`` gets an array of the possible predicted folders that may apply to the text being predicted.
        let predictedTypes: [(title: String, matches: Int)] = predictedCategories(text: text)
        
        ///``bestPrediction`` holds the title and number of matches of the best predicted folder.
        var bestPrediction = (title: "Default", matches: 0)
        
        for prediction in predictedTypes where prediction.matches > bestPrediction.matches {
            // if current prediction has higher num of matches, it becomes new bestPrediction
            bestPrediction.title = prediction.title.capitalized
            bestPrediction.matches = prediction.matches
        }
        print("Final Prediction: \(bestPrediction.title).")
        return bestPrediction.title
    }
    
    ///``predictedCategories``
    /// is a function that takes a text input, and compares it against the categoryKeywords array to assign a point to each category depending on if it matches with it's keywords.
    /// - Parameter text: the body of text (extracted from a receipt) to be processed to form the number of folder predictions.
    /// - Returns: [(String, Int)] of tuples, which contain the Categories title, along with the number of matches the text had with its keywords.
    static func predictedCategories(text: String) -> [(String, Int)] {
        var predictedType: [(title: String, matches: Int)] = [("", 0)]
        
        for category in categoryKeywords {
            let count = matchString(keywords: category.1, input: text)
            if count > 0 {
                print("Category Prediction: \(category.0), \(count) matches.\n" )
                predictedType.append((category.0, count))
            }
        }
        return predictedType
    }
    
    ///``matchString``
    /// is a function that counts how many matches a word .
    /// It functions by looping over each word in the categories keywords, incrementing a counter for each matching word. The count is returns at the end of the loop.
    /// - Parameter text: the body of text (extracted from a receipt) to be processed to form the number of folder predictions.
    /// - Returns: [(String, Int)] of tuples, which contain the Category title, along with the number of matches the input text had with its keywords.
    static func matchString(keywords: [String], input: String) -> Int {
        var count = 0
        for keyword in keywords {
            if input.lowercased().contains(keyword){
                print("Matched word: '\(keyword)'.")
                count += 1
            }
        }
        return count
    }
    
    ///``categoryKeywords`` is an array of tuples that are used as the basis for the folder prediction process.
    /// It is made up of a title of the category, along with its keywords associated with the category.
    /// - Tuple format
    ///     - (title: "Categories Title", keywords:["keywords", "associated", "with", "the", "category"])
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
                                              "clamp", "file", "spanner", "level", "measuring tape", "timber",
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
                                   
                                   (title: "pets",
                                    keywords: ["Animates", "dog", "puppy", "cat", "kitten", "hamster", "gerbil",
                                              "mouse", "bird", "parrot", "litter", "litter box", "bowl",
                                              "food", "pet box", "pet carrier"]),
                                   
                                   /*(title: "baby & toddler",
                                    keywords: ["nappy", "nappies", "diapers", "stroller", "baby carrier", "car seat", "play mat", "pacifier", "bottle warmer", "bib",
                                              "high chair", "baby formula", "baby lotion", "crib", "cradle", "bassinet", "baby monitor", "mittens", "onesie",
                                              "booties", "rompers", "baby swing", "bottle sterilizer"]),
                                   (title: "luggage",
                                    keywords: ["bag", "suitcase", "backpack", "satchel", "fanny pack", "duffel", "tote", "trunk", "pet box", "pet carrier",
                                              "ski bag", "handbag", "carry on case", "poster tube", "instrument case", "hard shell", "hat bag", "briefcase",
                                              "camera bag", "pelican case", "ride-on case", "ride on case", "packs", "dry box", "messenger bags", "garment bags"]),*/
                                   
                                   (title: "health & beauty",
                                    keywords: ["pharmacy", "soap", "shampoo", "conditioner", "deodorant",
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
                                    keywords: ["mckenzie willis",
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
                                              "label maker", "paper plus"]),
                                   
                                   (title: "apparel",
                                    keywords: ["sunglasses", "apron", "necklace", "watch",
                                              "tie", "purse", "ring", "gloves", "scarf", "umbrella",
                                              "earmuffs", "hair clip", "bobby pin", "hair band",
                                              "safety pin", "watch", "clothing", "toff's", "toffs",
                                              "second hand", "secondhand", "opshop", "outlet",
                                              "footwear", "shoes", "shoe", "sneaker", "sneakers",
                                              "boot", "boots", "jacket", "jackets", "puffer",
                                              "pant", "pantyhose", "shirt", "t-shirt",
                                              "pavement", "void", "huffer", "postie", "jean",
                                              "postie plus", "postie+", "amazon", "cotton on",
                                              "cottonon", "cotton:on", "hallenstein", "shorts",
                                              "hallensteins", "barkers", "barker", "suit",
                                              "sweater", "sweatshirt", "sweatshirts", "hood",
                                              "hoodie", "hoody", "swimsuit", "bikini", "tee"]),
                                   
                                   (title: "arts & entertainment",
                                    keywords: ["paper plus", "dvd", "cd", "blu-ray", "paint brush",
                                              "paint", "watercolour", "acrylic", "eraser", "sketchbook",
                                              "ruler", "palette", "canvas", "ink", "easel", "varnish",
                                              "crayons", "tempera", "controller", "pastels", "clay",
                                              "plasticine", "felt", "scissors", "glue", "tape", "charcoal",
                                              "card", "paper"]),
                                   
                                   (title: "software",
                                    keywords: ["ide", "integrated development environment", "app", "jetbrains",
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
                                              "final cut pro", "java", "python", "swift"]),
                                   
                                   (title: "toys & games",
                                    keywords: ["puzzle", "wasjig", "board game", "monopoly", "chess",
                                              "checkers", "draughts", "catan", "dice", "dnd",
                                              "d&d", "dungeons and dragons", "dice", "cards",
                                              "playstation", "xbox", "switch", "nintendo",
                                              "ps4", "ps5", "sony", "microsoft", "game"]),
                                   
                                   (title: "sports",
                                    keywords: ["football", "soccer", "rugby", "cricket",
                                              "basketball", "ball", "stick", "boots", "gloves",
                                              "frisbee", "mouthguard", "shin pads", "elbow pads",
                                              "helmet", "whistle", "goal", "post", "net", "uniform",
                                              "cones", "weights", "nike", "adidas"]),
                                   
                                   (title: "vehicles",
                                    keywords: ["timing chain", "camshaft", "crankshaft", "spark plug",
                                              "cylinder head", "valve", "piston", "battery",
                                              "gearbox", "alternator", "radiator", "coolant", "mags",
                                              "rims", "hub", "wheel", "shocks", "shock absorber",
                                              "brakes", "brake pads", "brake calipers", "brake discs",
                                              "catalytic converter", "muffler", "turbocharger",
                                              "supercharger", "intake", "tyres", "tires"])]
    
    ///``getCategory``
    /// Returns a category with the matching title passed to it in the parameter.
    /// - Parameter title: the title of the category you want to get.
    /// - Returns: the category that matches the title parameter. Returns an empty object if there are no matches.
    static func getCategory(title: String) -> (String, [String]) {
        for category in categoryKeywords {
            if category.title.lowercased() == title.lowercased() {
                return category
            }
        }
        return ("", [""])
    }
}

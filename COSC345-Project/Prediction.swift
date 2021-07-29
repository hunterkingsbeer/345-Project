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
        // THIS SHOULD CUT DOWN ON SEARCHING ALL CATEGORY KEYWORDS WHEN UNNEEDED
        
        // Gets the possible predicted categories based on keywords
        let predictedTypes: [(title: String, matches: Int)] = predictedCategories(text: text)
        // Holds the index of the prediction with most matches. Format =(count, index)
        var bestPrediction = (title: "Default", matches: 0)
        
        for prediction in predictedTypes {
            if prediction.matches > bestPrediction.matches {
                // if current prediction has higher num of matches, becomes new highest index
                bestPrediction.title = prediction.title.capitalized
                bestPrediction.matches = prediction.matches
            }
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
    static let categoryKeywords = [(title: "groceries", keywords: ["grocer", "grocery", "supermarket", "market",
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
                               
                                   (title: "retail", keywords: ["harvey norman", "noel leeming", "noel leemings",
                                                    "jb","hi-fi", "the warehouse", "the ware house",
                                                    "hifi", "department", "furniture", "tech",
                                                    "technology", "smiths", "smiths city", "mall",
                                                    "stationery", "farmers", "gift", "gifts", "souvenirs",
                                                    "eletronics", "beds", "sport", "sports", "trade",
                                                    "flooring", "bathrooms", "bed", "bedding", "outlet",
                                                    "post", "world", "craft", "crafts", "supply",
                                                    "garden", "stihl", "appliance", "headphone", "phone",
                                                    "computer", "laptop", "watch"]),
                               
                                   (title: "clothing", keywords: ["clothing", "toff's", "toffs", "second hand",
                                                      "secondhand", "opshop", "outlet", "footwear",
                                                      "shoes", "shoe", "sneaker", "sneakers", "boot",
                                                      "boots", "jacket", "jackets", "puffer", "pant",
                                                      "pantyhose", "shirt", "t-shirt", "pavement",
                                                      "void", "huffer", "postie", "jean",
                                                      "postie plus", "postie+", "amazon", "cotton on",
                                                      "cottonon", "cotton:on", "hallenstein", "shorts",
                                                      "hallensteins", "barkers", "barker", "suit",
                                                      "sweater", "sweatshirt", "sweatshirts", "hood",
                                                      "hoodie", "hoody", "swimsuit", "bikini", "tee"])
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

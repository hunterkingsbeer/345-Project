//
//  Prediction.swift
//  COSC345-Project
//
//  Created by Hunter Kingsbeer on 28/05/21.
//

import Foundation
import SwiftUI

struct Prediction {
    
    /// for grocery stores
    static var groceries = ["grocer", "grocery", "supermarket", "market",
                            "grcoeries", "new world", "countdown", "veggie boys",
                            "veggieboys", "count down", "newworld", "food town",
                            "foodtown", "unimart", "uni mart", "kosco",
                            "paknsave", "pak n save", "four square",
                            "foursquare" , "super value", "supervalue",
                            "freshchoice", "fresh choice", "woolworths",
                            "wool worths", "night n day", "night 'n day",
                            "food", "mart", "fruit", "vegetables", "veges",
                            "veggies", "mart", "minimart", "produce",
                            "butcher", "butchers", "butchery", "chicken",
                            "beef", "pork", "milk", "cheese", "sauce"]
    
    /// for very general department store
    // VERY general category that will be shortened in beta
    static var retail = ["harvey norman", "noel leeming", "noel leemings",
                         "jb","hi-fi", "the warehouse", "the ware house",
                         "hifi", "store", "department", "furniture", "tech",
                         "technology", "smiths", "smiths city", "mall",
                         "stationery", "farmers", "gift", "gifts", "souvenirs",
                         "eletronics", "beds", "sport", "sports", "trade",
                         "flooring", "bathrooms", "bed", "bedding", "outlet",
                         "post", "world", "craft", "crafts", "supply",
                         "garden", "stihl", "appliance", "headphone", "phone",
                         "computer", "laptop", "watch"]
    
    /// for clothing stores
    static var clothing = ["clothing", "toff's", "toffs", "second hand",
                           "secondhand", "opshop", "restore", "outlet",
                           "footwear", "shoes", "shoe", "sneaker",
                           "sneakers", "boot", "boots", "jacket", "jackets",
                           "puffer", "pant", "pantyhose", "shirt", "t-shirt",
                           "pavement", "void", "huffer", "postie", "jean",
                           "postie plus", "postie+","amazon","cotton on",
                           "cottonon", "cotton:on", "hallenstein", "shorts",
                           "hallensteins", "barkers", "barker", "suit",
                           "sweater", "sweatshirt", "sweatshirts", "hood",
                           "hoodie", "hoody", "swimsuit", "bikini"]
    
    /// Predict Folder Type -- Input the text compared against keywords to predict a folder name
    static func predictFolderType(text: String) -> String {
        if matchString(parameters: Prediction.groceries, input: text){
            print("Prediction: Groceries")
            return "Groceries"
            
        } else if matchString(parameters: Prediction.retail, input: text){
            print("Prediction: Retail")
            return "Retail"
            
        } else if matchString(parameters: Prediction.clothing, input: text){
            print("Prediction: Clothing")
            return "Clothing"
            
        } else {
            print("Prediction: Default")
            return "Default"
        }
    }
}

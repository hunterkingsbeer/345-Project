//
//  UtilityFunctions.swift
//  COSC345-Project
//
//  Created by Hunter Kingsbeer on 28/05/21.
//

import Foundation
import SwiftUI

/// Get Folder Type -- Input the scanned text and the function will return a String that it thinks is the matching folder
func setFolderType (text: String) -> String {
    let groceries = ["new world", "paknsave", "countdown"]
    let retail = ["harvey norman", "noel leeming", "smith city", "jb hifi", "farmers"]
    let clothing = ["cotton on", "hallensteins", "countdown"]
    
    if matchString(parameters: groceries, input: text){
        print("\n\nGroceries")
        return "Groceries"
    } else if matchString(parameters: retail, input: text){
        print("\n\nRetail")
        return "Retail"
    } else if matchString(parameters: clothing, input: text){
        print("\n\nClothing")
        return "Clothing"
    }
    print("\n\nDefault")
    return "Default"
}

func matchString(parameters: [String], input: String) -> Bool{
    let text = input.components(separatedBy: " ")
    for word in text { // look at every word in the inputted text
        for parameter in parameters { // and check it against the parameter
            print("Word: '\(word)' Parameter: '\(parameter)'")
            if word.lowercased() == parameter.lowercased(){
                print("\n\n\n\n\n\n\n\n\n\n\n\n\nTRUE!!!!!!")
                return true
            }
        }
    }
    return false
}

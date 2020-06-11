//
//  PrefixData.swift
//  CallParser
//
//  Created by Peter Bourget on 6/6/20.
//  Copyright © 2020 Peter Bourget. All rights reserved.
//

import Foundation

// I put the children in this struct as well
public struct PrefixData {
    
    enum CharacterType: String {
        case numeric = "#"
        case alphabetical = "@"
        case alphanumeric = "?"
        case dash = "-"
        case dot = "."
        case slash = "/"
        case empty = ""
    }
    
    var mainPrefix = ""             //label ie: 3B6
    var fullPrefix = ""             // ie: 3B6.3B7
    var kind = PrefixKind.pfNone    //kind
    var country = ""                //country
    var province = ""               //province
    var city = ""                    //city
    var dxcc_entity = 0              //dxcc_entity
    var cq = Set<Int>()           //cq_zone
    var itu = Set<Int>()                    //itu_zone
    var continent = ""              //continent
    var timeZone = ""               //time_zone
    var latitude = "0.0"            //lat
    var longitude = "0.0"           //long
    
    //var isParent = false
    //var hasChildren = false
    //var children = [PrefixData]()
    // expanded masks
    var expandedMaskList: [[String]]
    var primaryMaskSets: [[Set<String>]]
    var secondaryMaskSets: [[Set<String>]]
    var rawMasks = [String]()
    
    
    var adif = false
    var wae = 0
    var wap = ""
    var admin1 = ""
    var admin2 = ""
    var startDate = ""
    var endDate = ""
    var isIota = false // implement
    var comment = ""
    
    var id = 1
    // for debugging
    var maskCount = 0
    
    let totalAlphaBets: Double
    let totalNumbers: Double
    var counter = 0.0
    
    let alphabet: [Character] = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]
    let numbers: [Character] = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
    
    init () {
        totalAlphaBets = Double(alphabet.count)
        totalNumbers = Double(numbers.count)
        expandedMaskList = [[String]]()
        primaryMaskSets = [[Set<String>]]()
        secondaryMaskSets = [[Set<String>]]()
    }
    
    /**
     Parse the FullPrefix to get the MainPrefix
     - parameters:
     - fullPrefix: fullPrefix value.
     */
    mutating func setMainPrefix(fullPrefix: String) {
      if let index = fullPrefix.range(of: ".")?.upperBound {
        mainPrefix = String(fullPrefix[index...])
        } else {
            mainPrefix = fullPrefix
        }
    }
    
    /**
     If this is a top level set the kind and adif flags.
     - parameters:
     - prefixKind: PrefixKind
     */
    mutating func setDXCC(prefixKind: PrefixKind) {
       
        self.kind = prefixKind
        
        if prefixKind == PrefixKind.pfDXCC {
            adif = true
            //isParent = true
        } else {
            
        }
    }
  
  /**
   Some entities have multiple CQ and ITU zones
   - parameters:
   - zones: String
   */
  mutating func buildZoneList(zones: String) -> Set<Int> {
    
    let zoneArrayString = zones.split(separator: ",")
    
    return Set(zoneArrayString.map { Int($0)! })
  }
    
    /**
     Save the original unexpanded mask.
     - parameters:
     - mask: mask to be processed.
     */
//    mutating  func storeMask(mask: String) {
//        //print("\n mask: \(mask)")
//        self.rawMasks.append(mask)
//        expandMaskEx(mask: mask)
//    }
    
    
    // SET for C# https://www.codeproject.com/Articles/8575/Yet-Another-C-set-class
    
    
//    mutating func expandMaskEx(mask: String) {
//        var expandedMask = Set<String>([])
//        expandedMaskList = [String]()
//        var newMask = mask
//        var counter = 0
//
//        //for item in mask {
//        while counter < mask.count {
//
//            let index = mask.index(mask.startIndex, offsetBy: counter)
//            let item = String(mask[index])
//
//            switch item {
//            case "[": // process as component
//                let index = newMask.firstIndex(of: "]")!
//                var nextIndex = newMask.index(after: index)
//                let maskPart = newMask.prefix(upTo: nextIndex)
//
//                //processMaskComponent(mask: String(maskPart))
//                processLeftOverEx(leftOver: String(maskPart))
//                // now remove everything we processed
//                counter += (maskPart.count)
//                nextIndex = mask.index(mask.startIndex, offsetBy: counter)
//                newMask = String(mask[nextIndex..<mask.endIndex])
//            case "@", "#", "?":
//              expandedMaskList.append(contentsOf: getMetaMaskSet(character: String(item)))
//                counter += 1
//                let nextIndex = mask.index(mask.startIndex, offsetBy: counter)
//                newMask = String(mask[nextIndex..<mask.endIndex])
//            default: // single character
//                //expandedMask = Set<String>([])
//                expandedMask.insert(String(item))
//                expandedMaskList.append(contentsOf: expandedMask)
//                counter += 1
//                let nextIndex = mask.index(mask.startIndex, offsetBy: counter)
//                newMask = String(mask[nextIndex..<mask.endIndex])
//            }
//        }
        
        //primaryMaskSets.append(expandedMaskSetList)
        // just cosmetic cleanup
        //expandedMaskList = [String]()
   // }
    
    // have [xxxxxx]
//    mutating func processMaskComponent(mask: String) {
//
//        var expandedMask = Set<String>([])
//
//        processLeftOverEx(leftOver: mask)
//
//        //return expandedMask
//
//    }
    
    /**
     Expand the mask to list every component.
     if the first character is a [ then remove it and start again
     If the first character is a number or letter than add to array.
     Send whatever is left over to be processesd.
     - parameters:
     - mask: mask to be expanded.
     */
//    mutating func expandMaskoo(mask: String) {
//
//        var leftOver = ""
//        var expandedMask = Set<String>([])
//        expandedMaskList = [String]()
//
//        // determine if the first character is a "["
//        if mask.prefix(1).rangeOfCharacter(from: CharacterSet.alphanumerics.inverted) != nil {
//            if mask.prefix(1) == "[" {
//                let newMask = String(mask.suffix(mask.count - 1))
//                expandMaskoo(mask: newMask)
//            }
//        }
//
//        // determine if first char is alphanumeric
//        if mask.prefix(1).rangeOfCharacter(from: CharacterSet.alphanumerics) != nil {
//            if mask.contains("[") {
//                let index = mask.firstIndex(of: "[")!
//                if index == mask.index(mask.startIndex, offsetBy: 1) {
//                    expandedMask.insert(String(mask.prefix(1)))
//                  expandedMaskList.append(contentsOf: expandedMask)
//                    leftOver = String(mask.suffix(mask.count - 2))
//                }
//                else {
//                    leftOver = String(mask)
//                }
//            } else {
//                leftOver = String(mask)
//            }
//        }
//
//        if !leftOver.isEmpty {
//            // if the leftover == the mask then treat each char as a separate component
//            if !leftOver.contains("]") {
//                leftOver.insert("]", at: leftOver.startIndex)
//                processLeftOver(leftOver: leftOver)
//            } else {
//                processLeftOver(leftOver: leftOver)
//            }
//        }
//    }
//
//    /**
//     Split string and eliminate "[" or "]" and empty entries.
//     Save the mask after it has been processed.
//     - parameters:
//     - leftOver: left over string to be processed.
//     */
//    mutating func processLeftOverEx(leftOver: String)  {
//
//        let separators = CharacterSet(charactersIn: "][")
//        var maskcomponents = leftOver.components(separatedBy: separators)
//
//        maskcomponents = maskcomponents.filter({ $0 != ""})
//
//        if maskcomponents.count > 1 {
//            assertionFailure("Too many pieces here")
//        }
//
//        parseMask(components: maskcomponents[0])
//
//
////        primaryMaskSets.append(expandedMaskSetList)
////        // just cosmetic cleanup
////        expandedMaskSetList = [Set<String>]()
//    }
    
    
    /**
     Split string and eliminate "[" or "]" and empty entries.
     Save the mask after it has been processed.
     - parameters:
     - leftOver: left over string to be processed.
     */
//    mutating func processLeftOver(leftOver: String)  {
//
//        let separators = CharacterSet(charactersIn: "][")
//        var maskcomponents = leftOver.components(separatedBy: separators)
//
//        // if more than one then take the last component - it was after the last "]"
//        // each character needs to be treated as a separate entry
//        if maskcomponents.count > 1 {
//            let component = maskcomponents[maskcomponents.count - 1]
//            maskcomponents.removeLast()
//            for item in component{
//                maskcomponents.append(String(item))
//            }
//
//        }
//
//        maskcomponents = maskcomponents.filter({ $0 != ""})
//
//        for components in maskcomponents {
//            parseMask(components: components)
//        }
//
//        //primaryMaskSets.append(expandedMaskSetList)
//        //print("ex: \(consolidatedMaskSets[maskCount])")
//        // just cosmetic cleanup
//        expandedMaskList = [String]()
//    }
    
    /**
     Look at each character and see if it is a meta character to be expanded
     or a "-" which indicates a range. Otherewise store it as is.
     - parameters:
     - components: string to be processed.
     */
//    mutating func parseMask(components: String) {
//        var currentCharacter = ""
//        var nextCharacter = ""
//        var counter = 0
//        var expandedMask = Set<String>([])
//        var tempMask = Set<String>([])
//
//        for _ in components {
//            // if first is nil, we are finished
//            guard components.character(at: counter) != nil else {
//              expandedMaskList.append(contentsOf: expandedMask)
//                return
//            }
//
//            if String(components.character(at: counter) ?? "").isEmpty {
//              expandedMaskList.append(contentsOf: expandedMask)
//                return
//            }
//
//            // TODO: double check the [0-9-W] is processed correctly - 7[RT-Y][016-9@] - [AKW]L#/
//
//            // need to check if next char is a meta char
//            currentCharacter = String(components.character(at: counter) ?? "")
//
//            tempMask = getMetaMaskSet(character: currentCharacter)
//            expandedMask = expandedMask.union(tempMask)
//            while tempMask.count != 0 { // in case of ##
//                counter += 1
//                currentCharacter = String(components.character(at: counter) ?? "")
//                tempMask = getMetaMaskSet(character: currentCharacter)
//                expandedMask = expandedMask.union(tempMask)
//            }
//
//            currentCharacter = String(components.character(at: counter) ?? "")
//            nextCharacter = String(components.character(at: counter + 1) ?? "")
//
//            // is the nextChar a "-" ??
//            //if it is send the current char and the second next off to be processed
//            if CharacterType(rawValue: nextCharacter) == CharacterType.dash {
//                counter += 1
//                nextCharacter = String(components.character(at: counter + 1) ?? "")
//                tempMask = buildRange(currentCharacter: currentCharacter, nextCharacter: nextCharacter)
//                expandedMask = expandedMask.union(tempMask)
//                counter += 2
//            } else {
//                if !currentCharacter.isEmpty {
//                    if CharacterType(rawValue: currentCharacter) == CharacterType.dash {
//                       // 0-9-W get previous character
//                        let previousCharacter = String(components.character(at: counter - 1) ?? "")
//                        tempMask = buildRange(currentCharacter: previousCharacter, nextCharacter: nextCharacter)
//                        expandedMask = expandedMask.union(tempMask)
//                        counter += 1
//                    } else {
//                        expandedMask.insert(currentCharacter)
//                    }
//                }
//                counter += 1
//            }
//        } // end for
//      expandedMaskList.append(contentsOf: expandedMask)
//    }
//
//    func findIndex(value searchValue: String, in array: [String]) -> Int?
//    {
//        for (index, value) in array.enumerated()
//        {
//            if value == searchValue {
//                return index
//            }
//        }
//
//        return nil
//    }
    
    /**
     A "-" was found which indicates a range. Build the alpha or numeric range to return.
     - parameters:
     - currentCharacter: string to be processed.
     - nextCharacter: look ahead string to be processed.
     */
//    mutating func buildRange(currentCharacter: String, nextCharacter: String) -> Set<String> {
//        var expandedMask = Set<String>([])
//        if currentCharacter.isInteger && nextCharacter.isInteger {
//            if currentCharacter < nextCharacter {
//                let start = getNumberIndex(char: currentCharacter)
//                let end = getNumberIndex(char: nextCharacter)
//                for i in start...end {
//                    let a = getNumberFromArr(index: i)
//                    expandedMask.insert(String(a))
//                }
//            } else {
//                // 31 = V31/
//                expandedMask.insert(currentCharacter)
//              expandedMaskList.append(contentsOf: expandedMask)
//
//                expandedMask = Set<String>([])
//                expandedMask.insert(nextCharacter)
//              expandedMaskList.append(contentsOf: expandedMask)
//                expandedMask = Set<String>([])
//            }
//        }
//
//        if !currentCharacter.isInteger && !nextCharacter.isInteger {
//            let start = getCharacterIndex(char: currentCharacter)
//            let end = getCharacterIndex(char: nextCharacter)
//            for i in start...end {
//                let a = getCharFromArr(index: i)
//                expandedMask.insert(String(a))
//            }
//        }
//
//        if currentCharacter.isInteger && !nextCharacter.isInteger {
//            let start = getCharacterIndex(char: nextCharacter)
//            let end = getCharacterIndex(char: "Z")
//            for i in start...end {
//                let a = getCharFromArr(index: i)
//                expandedMask.insert(String(a))
//            }
//
//            //assertionFailure("I didn't think this would happen. (1)")
//            return expandedMask
//        }
//
//        if !currentCharacter.isInteger && nextCharacter.isInteger {
//            assertionFailure("I didn't think this would happen. (2)")
//            return expandedMask
//        }
//
//        return expandedMask
//    }
    
    /**
     A #, ? or @  was found which indicates a range. Build the alpha or numeric range to return.
     - parameters:
     - character: character to be processed.
     */
//    func getMetaMaskSet(character: String) -> Set<String> {
//        
//        var expandedMask = Set<String>([])
//        
//        guard let characterType = CharacterType(rawValue: character) else {
//            return expandedMask
//        }
//        
//        //print(character)
//        switch characterType {
//        case .numeric:
//            for (_, char) in numbers.sorted().enumerated() {
//                expandedMask.insert(String(char))
//            }
//            break
//        case .alphanumeric:
//            for (_, char) in numbers.sorted().enumerated() {
//                expandedMask.insert(String(char))
//            }
//            for (_, char) in alphabet.sorted().enumerated() {
//                expandedMask.insert(String(char))
//            }
//            break
//        case .alphabetical:
//            for (_, char) in alphabet.sorted().enumerated() {
//                expandedMask.insert(String(char))
//            }
//            break
//        default:
//            break
//        }
//        
//        return expandedMask
//    }
    
    // MARK: Utility Functions ----------------------------------------------------
    
    //https://stackoverflow.com/questions/38838133/how-to-increment-string-in-swift
    /**
     Get the character index or number index from alphabets and numbers arrays.
     - parameters:
     - character: character to be processed.
     */
    func getCharFromArr(index i:Int) -> Character {
        if(i < alphabet.count){
            return alphabet[i]
        }else{
            print("wrong index")
            return ""
        }
    }
    
    func getNumberFromArr(index i:Int) -> Character {
        if(i < numbers.count){
            return numbers[i]
        }else{
            print("wrong index")
            return ""
        }
    }
    
    func getCharacterIndex(char: String) -> Int {
        
        for item in alphabet {
            if char == String(item) {
                return alphabet.firstIndex(of: Character(char)) ?? 99
            }
        }
        return 99
    }
    
    func getNumberIndex(char: String) -> Int {
        
        for item in numbers {
            if char == String(item) {
                return numbers.firstIndex(of: Character(char)) ?? 99
            }
        }
        return 99
    }
} // end PrefixData

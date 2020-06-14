//
//  PrefixData.swift
//  CallParser
//
//  Created by Peter Bourget on 6/6/20.
//  Copyright © 2020 Peter Bourget. All rights reserved.
//

import Foundation

public struct PrefixData: Hashable {
    
    enum CharacterType: String {
        case numeric = "#"
        case alphabetical = "@"
        case alphanumeric = "?"
        case dash = "-"
        case dot = "."
        case slash = "/"
        case empty = ""
    }
  
    public var indexKey = Set<Character>()
    public var maskList = [[String]]()
    
    var mainPrefix = ""             //label ie: 3B6
    var fullPrefix = ""             // ie: 3B6.3B7
    var kind = PrefixKind.None    //kind
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
        
        if prefixKind == PrefixKind.DXCC {
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
   Check if a portable mask exists.
   */
  public func portableMaskExists(call: String) -> Bool {
    
    let first = call[0]
    let second = call[1]
    var third: String
    var fourth: String
    var fifth: String
    var sixth: String
    
    
    for item in maskList where item.count == call.count {
      
      // can I compare this with call???
      let joined = item.joined()
      if joined == call {
        return true
      }
      
      switch call.count {
        
      case 2:
          if item[0] == String(first) && item[1] == String(second) {
              return true
          }
        
      case 3:
        third = String(call[2])
        if item[0] == String(first) && item[1] == String(second) && item[2] == String(third){
            return true
        }
        
        case 4:
        third = String(call[2])
        fourth = String(call[3])
        if item[0] == String(first) && item[1] == String(second) && item[2] == String(third) && item[3] == String(fourth){
            return true
        }
        
      case 5:
        third = String(call[2])
        fourth = String(call[3])
        fifth = String(call[4])
        if item[0] == String(first) && item[1] == String(second) && item[2] == String(third) && item[3] == String(fourth)  && item[4] == String(fifth){
            return true
        }
        
        case 6:
        third = String(call[2])
        fourth = String(call[3])
        fifth = String(call[4])
        sixth = String(call[5])
        if item[0] == String(first) && item[1] == String(second) && item[2] == String(third) && item[3] == String(fourth)  && item[4] == String(fifth) && item[5] == String(sixth){
            return true
        }
      
      default:
        break
      }
    }
    
    return false
  }
  /**
   

   */
  
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

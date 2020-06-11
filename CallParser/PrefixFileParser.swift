//
//  PrefixFileParser.swift
//  CallParser
//
//  Created by Peter Bourget on 6/6/20.
//  Copyright © 2020 Peter Bourget. All rights reserved.
//

import Foundation
import Network

/** utility functions to run a UI or background thread
 // USAGE:
 BG() {
 everything in here will execute in the background
 }
 https://www.electrollama.net/blog/2017/1/6/updating-ui-from-background-threads-simple-threading-in-swift-3-for-ios
 */
func BG(_ block: @escaping ()->Void) {
    DispatchQueue.global(qos: .background).async(execute: block)
}

/**  USAGE:
 UI() {
 everything in here will execute on the main thread
 }
 */
func UI(_ block: @escaping ()->Void) {
    DispatchQueue.main.async(execute: block)
}

// also look at https://stackoverflow.com/questions/24092884/get-nth-character-of-a-string-in-swift-programming-language

// https://www.agnosticdev.com/content/how-get-first-or-last-characters-string-swift-4
extension String {
    
    func index(at position: Int, from start: Index? = nil) -> Index? {
        let startingIndex = start ?? startIndex
        return index(startingIndex, offsetBy: position, limitedBy: endIndex)
    }
    
    func character(at position: Int) -> String? {
        guard position >= 0 && position <= self.count - 1, let indexPosition = index(at: position) else {
            return nil
        }
        return String(self[indexPosition])
    }
    
    var isInteger: Bool {
        return Int(self) != nil
    }
}

extension Int {
    func isSuccessor(first: Int, second: Int) -> Bool {
        if second - first == 1 {
            return true
        }
        return false
    }
}

// MARK: - String Extension ----------------------------------------------------------------------------

// https://stackoverflow.com/questions/32305891/index-of-a-substring-in-a-string-with-swift
extension StringProtocol where Index == String.Index {
    
  // if let index = mask.index(of: "]")
  func index(of string: Self, options: String.CompareOptions = []) -> Index? {
        return range(of: string, options: options)?.lowerBound
    }
  
   //let end = mask.endIndex(of: "]")!
    func endIndex(of string: Self, options: String.CompareOptions = []) -> Index? {
        return range(of: string, options: options)?.upperBound
    }
  
    func indexes(of string: Self, options: String.CompareOptions = []) -> [Index] {
        var result: [Index] = []
        var start = startIndex
        while start < endIndex,
            let range = self[start..<endIndex].range(of: string, options: options) {
                result.append(range.lowerBound)
                start = range.lowerBound < range.upperBound ? range.upperBound :
                    index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
  
    func ranges(of string: Self, options: String.CompareOptions = []) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var start = startIndex
        while start < endIndex,
            let range = self[start..<endIndex].range(of: string, options: options) {
                result.append(range)
                start = range.lowerBound < range.upperBound ? range.upperBound :
                    index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
}

//  https://stackoverflow.com/questions/24092884/get-nth-character-of-a-string-in-swift-programming-language
extension String {
    subscript (i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }
    subscript (bounds: CountableRange<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[start ..< end]
    }
    subscript (bounds: CountableClosedRange<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[start ... end]
    }
    subscript (bounds: CountablePartialRangeFrom<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(endIndex, offsetBy: -1)
        return self[start ... end]
    }
    subscript (bounds: PartialRangeThrough<Int>) -> Substring {
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[startIndex ... end]
    }
    subscript (bounds: PartialRangeUpTo<Int>) -> Substring {
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[startIndex ..< end]
    }
}

extension Substring {
    subscript (i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }
    subscript (bounds: CountableRange<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[start ..< end]
    }
    subscript (bounds: CountableClosedRange<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[start ... end]
    }
    subscript (bounds: CountablePartialRangeFrom<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(endIndex, offsetBy: -1)
        return self[start ... end]
    }
    subscript (bounds: PartialRangeThrough<Int>) -> Substring {
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[startIndex ... end]
    }
    subscript (bounds: PartialRangeUpTo<Int>) -> Substring {
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[startIndex ..< end]
    }
}

// MARK: - PrefixKind Struct ----------------------------------------------------------------------------

enum PrefixKind:  String {
    case pfNone
    case pfDXCC
    case pfProvince
    case pfStation
    case pfDelDXCC
    case pfOldPrefix
    case pfNonDXCC
    case pfInvalidPrefix
    case pfDelProvince
    case pfCity
}

// MARK: - CallParser Class ----------------------------------------------------------------------------

@available(OSX 10.14, *)
public class PrefixFileParser: NSObject, ObservableObject {
    
    public var prefixList = [PrefixData]()
    public var callSignDictionary = [String: PrefixData]()
    public var portablePrefixes = [String: PrefixData]()
    public var childPrefixList = [PrefixData]()
    var prefixData = PrefixData()
    
    var recordKey = "prefix"
    var nodeName: String?
    var currentValue: String?
    
    // initializer
    public override init() {
        super.init()
      
      parsePrefixFile()
    }
    
    /**
     Start parsing the embedded xml file
     - parameters:
     */
    public func parsePrefixFile() {
        
        recordKey = "prefix"
        
      /**
       if let path = Bundle.main.url(forResource: "Books", withExtension: "xml") {
           if let parser = XMLParser(contentsOf: path) {
               parser.delegate = self
               parser.parse()
           }
       }
       */
      // define the bundle
        let bundle = Bundle(identifier: "com.w6op.CallParser")
        guard let url = bundle!.url(forResource: "PrefixList", withExtension: "xml") else {
            print("Invalid call sign: ")
            return
            // later make this throw
        }
        
        // define the xmlParser
        guard let parser = XMLParser(contentsOf: url) else {
            print("Parser init failed: ")
            return
            // later make this throw
        }
        
        parser.delegate = self
      
        // this is called when the parser has completed parsing the document
        if parser.parse() {
            // if this is the first instance of that prefix continue to next item in list
            // put all the children in their parent
            //var count = 0
            for i in 0..<self.prefixList.count {
              for mask in prefixList[i].primaryMaskSets {
                _ = mask.count
                //let primaryMaskList = expandMask(element: mask)
              }
             //
//                if prefixList[i].kind == PrefixKind.pfDXCC {
//                    count = i
//                } else {
//                    //prefixList[count].hasChildren = true
//                    //prefixList[count].children.append(prefixList[i])
//                    // save the children's masks in the parent
//                    for mask in prefixList[i].primaryMaskSets {
//                        prefixList[count].secondaryMaskSets.append(mask)
//                    }
//                }
            }
        }
    }
  
  /**
   
   */
  func expandMask(element: String) -> [[String]] {
    var primaryMaskList = [[String]]()
    
    let mask = element.trimmingCharacters(in: .whitespacesAndNewlines)
    
    var position = 0
    let offset = mask.startIndex
    
      while position < mask.count {
        // determine if the first character is a "[" [JT][019]
        if mask[mask.index(offset, offsetBy: position)] == "[" {
            let start = mask.index(offset, offsetBy: position)
          let remainder = mask[mask.index(offset, offsetBy: position)..<mask.endIndex]
            let end = remainder.endIndex(of: "]")!
            let substring = mask[start..<end]
            // [JT]
            primaryMaskList.append(expandGroup(group: String(substring)))
            
            for _ in substring {
              position += 1
            }
            
          
        } else {
          let char = mask[mask.index(offset, offsetBy: position)] //mask[position]
          let subItem = expandMetaCharacters(mask: String(char))
          let subArray = subItem.map { String($0) }
          primaryMaskList.append(subArray)
          position += 1
        }
      }
 
    return primaryMaskList
  }
  
  /**
   Build the array from the mask
   */
  func buildArray(charList: [String], expandedmask: String) -> [String] {
    
    
    return [String]()
  }
  
  func expandGroup(group: String) -> [String]{
    
    var maskList = [String]()
    
    let array = group.components(separatedBy: CharacterSet(charactersIn: "[]")).filter({ $0 != ""})
    
    for item in array {
      var index = 0
      let subArray = item.map { String($0) }
      //for item in subArray {
      while (index < subArray.count) {
        let item = subArray[index]
        switch item{
        case "#", "@", "?":
          let subItem = expandMetaCharacters(mask: item)
          let subArray = subItem.map { String($0) }
          maskList.append(contentsOf: subArray)
        case "-":
          let first = subArray.before("-")!
          let second = subArray.after("-")!
          let subArray = expandRange(first: String(first), second: String(second))
          maskList.append(contentsOf: subArray)
          index += 1
          break
        default:
          maskList.append(contentsOf: [String](arrayLiteral: item))
        }
        index += 1
      }
    }
    
    return maskList
  }
  
  /**
   Replace meta characters with the strings they represent.
   No point in doing if # exists as strings are very short.
   # = digits, @ = alphas and ? = alphas and numerics
   -parameters:
   -String:
   */
  func expandMetaCharacters(mask: String) -> String {

    var expandedCharacters: String
    
    expandedCharacters = mask.replacingOccurrences(of: "#", with: "0123456789")
    expandedCharacters = expandedCharacters.replacingOccurrences(of: "@", with: "ABCDEFGHIJKLMNOPQRSTUVWXYZ")
    expandedCharacters = expandedCharacters.replacingOccurrences(of: "?", with: "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")
    //expando = expando.replacingOccurrences(of: "-", with: "...")
   
    return expandedCharacters
  }
  
   func expandRange(first: String, second: String) -> [String] {
    
    let alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    var expando = [String]()
    
    // 1-5
    if first.isInteger && second.isInteger {
      if let a = Int(first){
        if let b = Int(second){
          let intArray: [Int] = Array(a...b)
          expando = intArray.dropFirst().map { String($0) }
        }
      }
    }
    
    // 0-C - NOT TESTED
    if first.isInteger && !second.isInteger {
      if let a = Int(first){
          let range: Range<String.Index> = alphabet.range(of: second)!
          let index: Int = alphabet.distance(from: alphabet.startIndex, to: range.lowerBound)
         
          let intArray: [Int] = Array(a...9)
          let myRange: ClosedRange = 0...index
      
        for item in alphabet[myRange] {
          expando.append(String(item))
          print (item)
        }
       
      }
    }
    
    // W-3 - NOT TESTED
    if !first.isInteger && second.isInteger {
      if let a = Int(second){
          let range: Range<String.Index> = alphabet.range(of: first)!
          let index: Int = alphabet.distance(from: alphabet.startIndex, to: range.lowerBound)
         
          let intArray: [Int] = Array(0...a)
          let myRange: ClosedRange = index...25
      
        for item in alphabet[myRange] {
          expando.append(String(item))
          print (item)
        }
       
      }
    }
    
    // A-G
    if !first.isInteger && !second.isInteger {
    
      let range: Range<String.Index> = alphabet.range(of: first)!
      let index: Int = alphabet.distance(from: alphabet.startIndex, to: range.lowerBound)
      
      let range2: Range<String.Index> = alphabet.range(of: second)!
      let index2: Int = alphabet.distance(from: alphabet.startIndex, to: range2.lowerBound)
      
      let myRange: ClosedRange = index...index2
     
      for item in alphabet[myRange] {
        expando.append(String(item))
      }
      
      // the first character has already been stored
      expando.remove(at: 0)
    }
      
    return expando
  }
  
} // end class

//extension String {
//    var isInt: Bool {
//        return Int(self) != nil
//    }
//}

//https://stackoverflow.com/questions/45340536/get-next-or-previous-item-to-an-object-in-a-swift-collection-or-array
extension BidirectionalCollection where Iterator.Element: Equatable {
    typealias Element = Self.Iterator.Element

    func after(_ item: Element, loop: Bool = false) -> Element? {
        if let itemIndex = self.firstIndex(of: item) {
            let lastItem: Bool = (index(after:itemIndex) == endIndex)
            if loop && lastItem {
                return self.first
            } else if lastItem {
                return nil
            } else {
                return self[index(after:itemIndex)]
            }
        }
        return nil
    }

    func before(_ item: Element, loop: Bool = false) -> Element? {
        if let itemIndex = self.firstIndex(of: item) {
            let firstItem: Bool = (itemIndex == startIndex)
            if loop && firstItem {
                return self.last
            } else if firstItem {
                return nil
            } else {
                return self[index(before:itemIndex)]
            }
        }
        return nil
    }
}

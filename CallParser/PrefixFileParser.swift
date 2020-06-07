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
    func index(of string: Self, options: String.CompareOptions = []) -> Index? {
        return range(of: string, options: options)?.lowerBound
    }
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
        
        // remove all the children and store them separately
//        for (i,prefix) in prefixList.enumerated().reversed()
//        {
//            if prefix.isParent == false
//            {
//                childPrefixList.append(prefix)
//                prefixList.remove(at: i)
//            }
//        }
        
        //return prefixList
    }
  
  func expandMask(element: String) -> Set<[String]> {
    
    
    
    return Set<[String]>()
  }
} // end class

//
//  CallParserCommon.swift
//  CallParser
//
//  Created by Peter Bourget on 6/13/20.
//  Copyright © 2020 Peter Bourget. All rights reserved.
//

import Foundation

// MARK: - PrefixKind Enum ----------------------------------------------------------------------------

enum PrefixKind:  String {
    case None = "pfNone"
    case DXCC = "pfDXCC"
    case Province = "pfProvince"
    case Station = "pfStation"
    case DelDXCC = "pfDelDXCC"
    case OldPrefix = "pfOldPrefix"
    case NonDXCC = "pfNonDXCC"
    case InvalidPrefix = "pfInvalidPrefix"
    case DelProvince = "pfDelProvince"
    case City = "pfCity"
}

// MARK: - CallSignFlags Enum ----------------------------------------------------------------------------

enum CallSignFlags:  String {
  case None = "cfNone"
  case Invalid = "cfInvalid"
  case   Maritime = "cfMaritime"
  case Portable = "cfPortable"
  case Special = "cfSpecial"
  case Club = "cfClub"
  case Beacon = "cfBeacon"
  case Lotw = "cfLotw"
  case AmbigPrefix = "cfAmbigPrefix"
  case Qrp = "cfQrp"
}

// MARK: - Valid Structures Enum ----------------------------------------------------------------------------

/**
 ValidStructures = ':C:C#:C#M:C#T:CM:CM#:CMM:CMP:CMT:CP:CPM:CT:PC:PCM:PCT:';
 */
enum CallStructureType: String {
  case Call = "C"
  case CallDigit = "C#"
  case CallDigitPortable = "C#M"
  case CallDigitText = "C#T"
  case CallPortable = "CM"
  case CallPortableDigit = "CM#"
  case CallPortablePortable = "CMM"
  case CallPortablePrefix = "CMP"
  case CallPortableText = "CMT"
  case CallPrefix = "CP"
  case CallPrefixPortable = "CPM"
  case CallText = "CT"
  case PrefixCall = "PC"
  case PrefixCallPortable = "PCM"
  case PrefixCallText = "PCT"
  case Invalid = "Invalid"
}

enum StringTypes: String {
  case Numeric
  case Text
  case Invalid
  case Valid
}


enum ComponentType {
  case CallSign
  case CallOrPrefix
  case Prefix
  case Text
  case Numeric
  case Portable
  case Unknown
  case Invalid
  case Valid
}



// also look at https://stackoverflow.com/questions/24092884/get-nth-character-of-a-string-in-swift-programming-language

// https://www.agnosticdev.com/content/how-get-first-or-last-characters-string-swift-4
// Build your own String Extension for grabbing a character at a specific position
// usage if let character = str.character(at: 3)
// nil returned if value to large for string
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
    
    // test if a character is an int
    var isInteger: Bool {
        return Int(self) != nil
    }
  
    var isNumeric: Bool {
        guard self.count > 0 else { return false }
        let nums: Set<Character> = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
        return Set(self).isSubset(of: nums)
    }
  
  var isAlphabetic: Bool {
      guard self.count > 0 else { return false }
      let alphas: Set<Character> = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
      return Set(self).isSubset(of: alphas)
    }
  
  func isAlphanumeric() -> Bool {
      return self.rangeOfCharacter(from: CharacterSet.alphanumerics.inverted) == nil && self != ""
    }
  }

// if the digit is the next in value 5,6 = true
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
/**
 USAGE:
 let str = "abcde"
 if let index = str.index(of: "cd") {
     let substring = str[..<index]   // ab
     let string = String(substring)
     print(string)  // "ab\n"
 }
 
 let str = "Hello, playground, playground, playground"
 str.index(of: "play")      // 7
 str.endIndex(of: "play")   // 11
 str.indices(of: "play")    // [7, 19, 31]
 str.ranges(of: "play")     // [{lowerBound 7, upperBound 11}, {lowerBound 19, upperBound 23}, {lowerBound 31, upperBound 35}]
 */
extension StringProtocol where Index == String.Index {
    
  // if let index = mask.index(of: "]")
//  func index<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
//      range(of: string, options: options)?.lowerBound
//  }
//  func index(of string: Self, options: String.CompareOptions = []) -> Index? {
//        return range(of: string, options: options)?.lowerBound
//    }
  
   //let end = mask.endIndex(of: "]")!
  // I THINK THIS IS THE ONLY ONE I USE
  func endIndex<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
      range(of: string, options: options)?.upperBound
  }
//    func endIndex(of string: Self, options: String.CompareOptions = []) -> Index? {
//        return range(of: string, options: options)?.upperBound
//    }
  
//  func indices<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Index] {
//      var indices: [Index] = []
//      var startIndex = self.startIndex
//      while startIndex < endIndex,
//          let range = self[startIndex...]
//              .range(of: string, options: options) {
//              indices.append(range.lowerBound)
//              startIndex = range.lowerBound < range.upperBound ? range.upperBound :
//                  index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
//      }
//      return indices
//  }
//    func indexes(of string: Self, options: String.CompareOptions = []) -> [Index] {
//        var result: [Index] = []
//        var start = startIndex
//        while start < endIndex,
//            let range = self[start..<endIndex].range(of: string, options: options) {
//                result.append(range.lowerBound)
//                start = range.lowerBound < range.upperBound ? range.upperBound :
//                    index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
//        }
//        return result
//    }
  
  
//  func ranges<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Range<Index>] {
//      var result: [Range<Index>] = []
//      var startIndex = self.startIndex
//      while startIndex < endIndex,
//          let range = self[startIndex...]
//              .range(of: string, options: options) {
//              result.append(range)
//              startIndex = range.lowerBound < range.upperBound ? range.upperBound :
//                  index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
//      }
//      return result
//  }
//    func ranges(of string: Self, options: String.CompareOptions = []) -> [Range<Index>] {
//        var result: [Range<Index>] = []
//        var start = startIndex
//        while start < endIndex,
//            let range = self[start..<endIndex].range(of: string, options: options) {
//                result.append(range)
//                start = range.lowerBound < range.upperBound ? range.upperBound :
//                    index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
//        }
//        return result
//    }
  // https://stackoverflow.com/questions/30018006/understanding-the-removerange-documentation
  subscript(_ offset: Int) -> Element { self[index(startIndex, offsetBy: offset)] }
  subscript(_ range: Range<Int>) -> SubSequence { prefix(range.lowerBound+range.count).suffix(range.count) }
  subscript(_ range: ClosedRange<Int>) -> SubSequence { prefix(range.lowerBound+range.count).suffix(range.count) }
  subscript(_ range: PartialRangeThrough<Int>) -> SubSequence { prefix(range.upperBound.advanced(by: 1)) }
  subscript(_ range: PartialRangeUpTo<Int>) -> SubSequence { prefix(range.upperBound) }
  subscript(_ range: PartialRangeFrom<Int>) -> SubSequence { suffix(Swift.max(0, count-range.lowerBound)) }
  }
/*
 FOR ABOVE:
 let test = "Hello USA 🇺🇸!!! Hello Brazil 🇧🇷!!!"
 test[safe: 10]   // "🇺🇸"
 test[11]   // "!"
 test[10...]   // "🇺🇸!!! Hello Brazil 🇧🇷!!!"
 test[10..<12]   // "🇺🇸!"
 test[10...12]   // "🇺🇸!!"
 test[...10]   // "Hello USA 🇺🇸"
 test[..<10]   // "Hello USA "
 test.first   // "H"
 test.last    // "!"

 // Subscripting the Substring
  test[...][...3]  // "Hell"

 // Note that they all return a Substring of the original String.
 // To create a new String from a substring
 test[10...].string  // "🇺🇸!!! Hello Brazil 🇧🇷!!!"
 */

//  https://stackoverflow.com/questions/24092884/get-nth-character-of-a-string-in-swift-programming-language
extension String {
//    subscript (i: Int) -> Character {
//        return self[index(startIndex, offsetBy: i)]
//    }
//    subscript (bounds: CountableRange<Int>) -> Substring {
//        let start = index(startIndex, offsetBy: bounds.lowerBound)
//        let end = index(startIndex, offsetBy: bounds.upperBound)
//        return self[start ..< end]
//    }
    subscript (bounds: CountableClosedRange<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[start ... end]
    }
//    subscript (bounds: CountablePartialRangeFrom<Int>) -> Substring {
//        let start = index(startIndex, offsetBy: bounds.lowerBound)
//        let end = index(endIndex, offsetBy: -1)
//        return self[start ... end]
//    }
//    subscript (bounds: PartialRangeThrough<Int>) -> Substring {
//        let end = index(startIndex, offsetBy: bounds.upperBound)
//        return self[startIndex ... end]
//    }
//    subscript (bounds: PartialRangeUpTo<Int>) -> Substring {
//        let end = index(startIndex, offsetBy: bounds.upperBound)
//        return self[startIndex ..< end]
//    }
}

//extension Substring {
//    subscript (i: Int) -> Character {
//        return self[index(startIndex, offsetBy: i)]
//    }
//    subscript (bounds: CountableRange<Int>) -> Substring {
//        let start = index(startIndex, offsetBy: bounds.lowerBound)
//        let end = index(startIndex, offsetBy: bounds.upperBound)
//        return self[start ..< end]
//    }
//    subscript (bounds: CountableClosedRange<Int>) -> Substring {
//        let start = index(startIndex, offsetBy: bounds.lowerBound)
//        let end = index(startIndex, offsetBy: bounds.upperBound)
//        return self[start ... end]
//    }
//    subscript (bounds: CountablePartialRangeFrom<Int>) -> Substring {
//        let start = index(startIndex, offsetBy: bounds.lowerBound)
//        let end = index(endIndex, offsetBy: -1)
//        return self[start ... end]
//    }
//    subscript (bounds: PartialRangeThrough<Int>) -> Substring {
//        let end = index(startIndex, offsetBy: bounds.upperBound)
//        return self[startIndex ... end]
//    }
//    subscript (bounds: PartialRangeUpTo<Int>) -> Substring {
//        let end = index(startIndex, offsetBy: bounds.upperBound)
//        return self[startIndex ..< end]
//    }
//}

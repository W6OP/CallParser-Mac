//
//  CallParserCommon.swift
//  CallParser
//
//  Created by Peter Bourget on 6/13/20.
//  Copyright © 2020 Peter Bourget. All rights reserved.
//

import Foundation

// MARK: - PrefixKind Enum ----------------------------------------------------------------------------

public enum PrefixKind:  String {
  case none = "pfNone"
  case dXCC = "pfDXCC"
  case province = "pfProvince"
  case station = "pfStation"
  case delDXCC = "pfDelDXCC"
  case oldPrefix = "pfOldPrefix"
  case nonDXCC = "pfNonDXCC"
  case invalidPrefix = "pfInvalidPrefix"
  case delProvince = "pfDelProvince"
  case city = "pfCity"
}

// MARK: - CallSignFlags Enum ----------------------------------------------------------------------------

public enum CallSignFlags:  String {
  case none = "cfNone"
  case invalid = "cfInvalid"
  case maritime = "cfMaritime"
  case portable = "cfPortable"
  case special = "cfSpecial"
  case club = "cfClub"
  case beacon = "cfBeacon"
  case lotw = "cfLotw"
  case ambigPrefix = "cfAmbigPrefix"
  case qrp = "cfQrp"
}

// MARK: - Valid Structures Enum ----------------------------------------------------------------------------

/**
 ValidStructures = ':C:C#:C#M:C#T:CM:CM#:CMM:CMP:CMT:CP:CPM:CT:PC:PCM:PCT:';
 */
public enum CallStructureType: String {
  case call = "C"
  case callDigit = "C#"
  case callDigitPortable = "C#M"
  case callDigitText = "C#T"
  case callPortable = "CM"
  case callPortableDigit = "CM#"
  case callPortablePortable = "CMM"
  case callPortablePrefix = "CMP"
  case callPortableText = "CMT"
  case callPrefix = "CP"
  case callPrefixPortable = "CPM"
  case callText = "CT"
  case prefixCall = "PC"
  case prefixCallPortable = "PCM"
  case prefixCallText = "PCT"
  case invalid = "Invalid"
}

enum StringTypes: String {
  case numeric
  case text
  case invalid
  case valid
}


enum ComponentType {
  case callSign
  case callOrPrefix
  case prefix
  case text
  case numeric
  case portable
  case unknown
  case invalid
  case valid
}

// EndingPreserve = ':R:P:M:';
// EndingIgnore = ':AM:MM:QRP:A:B:BCN:LH:';
public enum CallSignType: String {
  case a = "A"
  case adif = "ADIF"
  case b = "B"
  case bcn = "Beacon"
  case lh = "LH"
  case m = "Mobile"
  case mm = "Marine Mobile"
  case p = "Portable"
  case qrp = "Low Power"
  case r = "Rover"
}

enum SearchBy: String {
  case prefix
  case call
  case none
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
  
  // here to end
  // https://stackoverflow.com/questions/29971505/filter-non-digits-from-string
  var onlyDigits: String { return onlyCharacters(charSets: [.decimalDigits]) }
  var onlyLetters: String { return onlyCharacters(charSets: [.letters]) }
  
  private func filterCharacters(unicodeScalarsFilter closure: (UnicodeScalar) -> Bool) -> String {
    return String(String.UnicodeScalarView(unicodeScalars.filter { closure($0) }))
  }
  
  private func filterCharacters(definedIn charSets: [CharacterSet], unicodeScalarsFilter: (CharacterSet, UnicodeScalar) -> Bool) -> String {
    if charSets.isEmpty { return self }
    let charSet = charSets.reduce(CharacterSet()) { return $0.union($1) }
    return filterCharacters { unicodeScalarsFilter(charSet, $0) }
  }
  
  func removeCharacters(charSets: [CharacterSet]) -> String { return filterCharacters(definedIn: charSets) { !$0.contains($1) } }
  func removeCharacters(charSet: CharacterSet) -> String { return removeCharacters(charSets: [charSet]) }
  
  func onlyCharacters(charSets: [CharacterSet]) -> String { return filterCharacters(definedIn: charSets) { $0.contains($1) } }
  func onlyCharacters(charSet: CharacterSet) -> String { return onlyCharacters(charSets: [charSet]) }
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
 */

/// For string slices
extension StringProtocol where Index == String.Index {
  //let end = mask.endIndex(of: "]")!
  func endIndex<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
    range(of: string, options: options)?.upperBound
  }
 
  // get substrings (slices) using a subscript or range
  // https://stackoverflow.com/questions/30018006/understanding-the-removerange-documentation
  subscript(_ offset: Int) -> Element { self[index(startIndex, offsetBy: offset)] }
  subscript(_ range: Range<Int>) -> SubSequence { prefix(range.lowerBound+range.count).suffix(range.count) }
  subscript(_ range: ClosedRange<Int>) -> SubSequence { prefix(range.lowerBound+range.count).suffix(range.count) }
  subscript(_ range: PartialRangeThrough<Int>) -> SubSequence { prefix(range.upperBound.advanced(by: 1)) }
  subscript(_ range: PartialRangeUpTo<Int>) -> SubSequence { prefix(range.upperBound) }
  subscript(_ range: PartialRangeFrom<Int>) -> SubSequence { suffix(Swift.max(0, count-range.lowerBound)) }
}

 // Note that they all return a Substring of the original String.
 // To create a new String from a substring
 //test[10...].string  // "🇺🇸!!! Hello Brazil 🇧🇷!!!


// https://rbnsn.me/multi-core-array-operations-in-swift
//public extension Array {
//    /// Synchronous
//    func concurrentMap<T>(transform: @escaping (Element) -> T) -> [T] {
//        let result = UnsafeMutablePointer<T>.allocate(capacity: count)
//
//        DispatchQueue.concurrentPerform(iterations: count) { i in
//            result.advanced(by: i).initialize(to: transform(self[i]))
//        }
//
//        let finalResult = Array<T>(UnsafeBufferPointer(start: result, count: count))
//        result.deallocate()
//
//        return finalResult
//    }
//
//    /// Synchronous
//    func concurrentForEach(action: @escaping (Element) -> Void) {
//        _ = concurrentMap { _ = action($0) }
//    }
//}

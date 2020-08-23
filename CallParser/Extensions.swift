//
//  Extensions.swift
//  CallParser
//
//  Created by Peter Bourget on 8/22/20.
//  Copyright © 2020 Peter Bourget. All rights reserved.
//

import Foundation

// MARK: - Array Extension ----------------------------------------------------------------------------

// great but a little slow
extension Array where Element: Equatable {
    func all(where predicate: (Element) -> Bool) -> [Element]  {
        return self.compactMap { predicate($0) ? $0 : nil }
    }
}

// MARK: - String Extensions ----------------------------------------------------------------------------

/// https://stackoverflow.com/questions/24092884/get-nth-character-of-a-string-in-swift-programming-language
//extension String {
//    subscript (i: Int) -> Character {
//        return self[index(startIndex, offsetBy: i)]
//    }
//
//    subscript (bounds: CountableRange<Int>) -> Substring {
//        let start = index(startIndex, offsetBy: bounds.lowerBound)
//        let end = index(startIndex, offsetBy: bounds.upperBound)
//        if end < start { return "" }
//        return self[start..<end]
//    }
//
//    subscript (bounds: CountableClosedRange<Int>) -> Substring {
//        let start = index(startIndex, offsetBy: bounds.lowerBound)
//        let end = index(startIndex, offsetBy: bounds.upperBound)
//        if end < start { return "" }
//        return self[start...end]
//    }
//
//    subscript (bounds: CountablePartialRangeFrom<Int>) -> Substring {
//        let start = index(startIndex, offsetBy: bounds.lowerBound)
//        let end = index(endIndex, offsetBy: -1)
//        if end < start { return "" }
//        return self[start...end]
//    }
//
//    subscript (bounds: PartialRangeThrough<Int>) -> Substring {
//        let end = index(startIndex, offsetBy: bounds.upperBound)
//        if end < startIndex { return "" }
//        return self[startIndex...end]
//    }
//
//    subscript (bounds: PartialRangeUpTo<Int>) -> Substring {
//        let end = index(startIndex, offsetBy: bounds.upperBound)
//        if end < startIndex { return "" }
//        return self[startIndex..<end]
//    }
//}

// MARK: - String Protocol Extensions
// https://stackoverflow.com/questions/32305891/index-of-a-substring-in-a-string-with-swift

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

// MARK: - String Extensions

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



// MARK: - Extension Collection ----------------------------------------------------------------------------

// if the digit is the next in value 5,6 = true
extension Int {
  func isSuccessor(first: Int, second: Int) -> Bool {
    if second - first == 1 {
      return true
    }
    return false
  }
}


/// Trim String in Swift, Remove spaces and other similar symbols (for example, new lines and tabs).
/// Usage: var str1 = "  a b c d e   \n"
/// var str2 = str1.trimmed
/// str1.trim()
//extension String {
//    var trimmed: String {
//        self.trimmingCharacters(in: .whitespacesAndNewlines)
//    }
//
//    mutating func trim() {
//        self = self.trimmed
//    }
//}

/// Int.toDouble() and Double.toInt()
/// These methods can be useful if you work with optionals. If you have non-optional Int, you can convert it with Double(a), where a is an integer variable. But if a is optional, you can’t do it.
//extension Int {
//    func toDouble() -> Double {
//        Double(self)
//    }
//}
//
//extension Double {
//    func toInt() -> Int {
//        Int(self)
//    }
//}

/// String.toDate(…) and Date.toString(…)
/// Getting the Date from String and formatting the Date to display it or send to API are common tasks. The standard way to convert takes three lines of code. Let’s see how to make it shorter:
/// Usage: let strDate = "2020-08-10 15:00:00"
/// let date = strDate.toDate(format: "yyyy-MM-dd HH:mm:ss")
/// let strDate2 = date?.toString(format: "yyyy-MM-dd HH:mm:ss")
//extension String {
//    func toDate(format: String) -> Date? {
//        let df = DateFormatter()
//        df.dateFormat = format
//        return df.date(from: self)
//    }
//}
//
//extension Date {
//    func toString(format: String) -> String {
//        let df = DateFormatter()
//        df.dateFormat = format
//        return df.string(from: self)
//    }
//}

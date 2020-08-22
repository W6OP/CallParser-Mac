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

// MARK: - String Protocol Extensions ----------------------------------------------------------------------------
// https://stackoverflow.com/questions/32305891/index-of-a-substring-in-a-string-with-swift




// MARK: - Extension Collection ----------------------------------------------------------------------------

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

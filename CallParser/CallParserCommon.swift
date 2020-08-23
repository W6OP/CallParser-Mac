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



// if the digit is the next in value 5,6 = true
//extension Int {
//  func isSuccessor(first: Int, second: Int) -> Bool {
//    if second - first == 1 {
//      return true
//    }
//    return false
//  }
//}


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

//
//  CallLookup.swift
//  CallParser
//
//  Created by Peter Bourget on 6/6/20.
//  Copyright © 2020 Peter Bourget. All rights reserved.
//

import Foundation
import Combine

public struct Hit {
    public var call = ""                   //call sign as input
    public var kind = PrefixKind.None    //kind
    public var country = ""                //country
    public var province = ""               //province
    public var city = ""                   //city
    public var dxcc_entity = 0            //dxcc_entity
    public var cq = Set<Int>()                    //cq_zone
    public var itu = Set<Int>()                   //itu_zone
    public var continent = ""              //continent
    public var timeZone = ""               //time_zone
    public var latitude = "0.0"            //lat
    public var longitude = "0.0"           //long
    public var wae = 0
    public var wap = ""
    public var admin1 = ""
    public var admin2 = ""
    public var startDate = ""
    public var endDate = ""
    public var isIota = false // implement
    public var comment = ""
  
    public var callSignFlags: [CallSignFlags]
    
    init(callSign: String, prefixData: PrefixData) {
        call = callSign
        kind = prefixData.kind
        country = prefixData.country
        province = prefixData.province
        city = prefixData.city
        dxcc_entity = prefixData.dxcc
        cq = prefixData.cq
        itu = prefixData.itu
        continent = prefixData.continent
        timeZone = prefixData.timeZone
        latitude = prefixData.latitude
        longitude = prefixData.longitude
        wae = prefixData.wae
        wap = prefixData.wap
        admin1 = prefixData.admin1
        admin2 = prefixData.admin2
        startDate = prefixData.startDate
        endDate = prefixData.endDate
        isIota = prefixData.isIota
        comment = prefixData.comment
      
      callSignFlags = prefixData.callSignFlags
      
    }
}

/**
 Look up the data on a call sign.
 */
public class CallLookup: ObservableObject{
    
    var hitList: [Hit]!
    var adifs: [Int : PrefixData]
    var prefixList = [PrefixData]()
    var CallSignPatterns: [String: [PrefixData]]
    var portablePrefixes: [String: [PrefixData]]

    /**
     Initialization.
     - parameters:
     - prefixList: The parent prefix list to use for searches.
     */
    public init(prefixFileParser: PrefixFileParser) {

       CallSignPatterns = prefixFileParser.CallSignPatterns;
       adifs = prefixFileParser.adifs;
       portablePrefixes = prefixFileParser.portablePrefixes;

    }
    
    /**
     Entry point for searching with a call sign.
     - parameters:
     - callSign: The call sign we want to process.
     */
    public func lookupCall(call: String) throws -> [Hit] {
      
            hitList = [Hit]()
            processCallSign(callSign: call.uppercased())
     
            return self.hitList ?? [Hit]()
    }
    
    /**
     Process a call sign into its component parts ie: W6OP/V31
     - parameters:
     - call: The call sign to be processed.
     */
    func processCallSign(callSign: String) {
      
        var call = ""// = callSign
      
      // strip leading or trailing "/"  /W6OP/
      if callSign.first(where: {$0 == "/"}) != nil {
        call = String(callSign.suffix(callSign.count - 1))
      }
      
      if callSign.last(where: {$0 == "/"}) != nil {
        call = String(call.prefix(call.count - 1))
      }
      

      let callStructure = CallStructure(callSign: callSign, portablePrefixes: portablePrefixes);

        if (callStructure.callStructureType != CallStructureType.Invalid) {
          collectMatches(callStructure: callStructure, fullCall: callSign);
       }
    }
    
    /**
     First see if we can find a match for the max prefix of 4 characters.
     Then start removing characters from the back until we can find a match.
     Once we have a match we will see if we can find a child that is a better match.
     - parameters:
     - callSign: The call sign we are working with.
     */
  func collectMatches(callStructure: CallStructure, fullCall: String) {
        
      let callStructureType = callStructure.callStructureType
    
    switch (callStructureType) // GT3UCQ/P
    {
        case CallStructureType.CallPrefix:
          if checkForPortablePrefix(callStructure: callStructure, fullCall: fullCall) { return }

        case CallStructureType.PrefixCall:
          if checkForPortablePrefix(callStructure: callStructure, fullCall: fullCall) { return }

        case CallStructureType.CallPortablePrefix:
          if checkForPortablePrefix(callStructure: callStructure, fullCall: fullCall) { return }

        case CallStructureType.CallPrefixPortable:
          if checkForPortablePrefix(callStructure: callStructure, fullCall: fullCall) { return }

        case CallStructureType.PrefixCallPortable:
          if checkForPortablePrefix(callStructure: callStructure, fullCall: fullCall) { return }

        case CallStructureType.PrefixCallText:
          if checkForPortablePrefix(callStructure: callStructure, fullCall: fullCall) { return }

        case CallStructureType.CallDigit:
          if checkReplaceCallArea(callStructure: callStructure, fullCall: fullCall) { return }
        break
        default:
            break
    }
    
    if searchMainDictionary(callStructure: callStructure, fullCall: fullCall, saveHit: true).result == true
    {
        return;
    }
}
  
  /**
   Search the CallSignDictionary for a hit with the full call. If it doesn't
   hit remove characters from the end until hit or there are no letters fleft.
   */
  func  searchMainDictionary(callStructure: CallStructure, fullCall: String, saveHit: Bool) -> (mainPrefix: String, result: Bool)
  {
    _ = callStructure.baseCall
    let prefix = callStructure.prefix
    
    var pattern: String
    var searchBy = SearchBy.Prefix
    
    switch (true) {
      
    case callStructure.callStructureType == CallStructureType.PrefixCall
      || callStructure.callStructureType == CallStructureType.PrefixCallPortable
      || callStructure.callStructureType == CallStructureType.PrefixCallText
      && prefix!.count == 1:
      
      pattern = callStructure.buildPattern(candidate: callStructure.prefix)
      
    case callStructure.callStructureType == CallStructureType.PrefixCall:
      pattern = callStructure.buildPattern(candidate: callStructure.prefix)
      
    case callStructure.callStructureType == CallStructureType.PrefixCall:
      pattern = callStructure.buildPattern(candidate: callStructure.prefix)
      
    case callStructure.callStructureType == CallStructureType.PrefixCallText:
      pattern = callStructure.buildPattern(candidate: callStructure.prefix)
      
    default:
      searchBy = SearchBy.BaseCall
      pattern = callStructure.buildPattern(candidate: callStructure.baseCall)
    }
    
    return performSearch(candidate: pattern, callStructure: callStructure, searchBy: searchBy, saveHit: saveHit)
  }
  
  /**
    first we look in all the "." patterns for calls like KG4AA vs KG4AAA
    
    pass in the callStructure and a flag to use prefix or baseCall
    */
  func performSearch(candidate: String, callStructure: CallStructure, searchBy: SearchBy, saveHit: Bool) -> (mainPrefix: String, result: Bool) {
    
    var pattern = candidate + "."
    var temp = Set<PrefixData>()
    var list = Set<PrefixData>()
    var firstLetter: Character
    var searchTerm = ""
    
    switch searchBy {
    case .BaseCall:
      let baseCall = callStructure.baseCall
      searchTerm = baseCall!
      firstLetter = baseCall![0]
    default:
      let prefix = callStructure.prefix
      firstLetter = prefix![0]
      searchTerm = prefix!
      if prefix!.count > 1 {
      }
    }
    
    while (pattern.count > 1)
    {
      if let valuesExists = CallSignPatterns[pattern] {
        temp = Set<PrefixData>()
        for prefixData in valuesExists {
    
          if prefixData.indexKey.contains(firstLetter) {
            if pattern.last == "." {
              if prefixData.maskExists(call: searchTerm, length: pattern.count - 1) {
                temp.insert(prefixData)
                break
              }
            } else {
              if prefixData.maskExists(call: searchTerm, length: pattern.count) {
                temp.insert(prefixData)
                break
              }
            }
          }
        }
      }

      if temp.count != 0 {
        list = list.union(temp)
        break
      }

      pattern.removeLast()
    }


    return refineHits(list: list, callStructure: callStructure, searchBy: searchBy, saveHit: saveHit)
  }
  
  /**
  now we have a list of posibilities // HG5ACZ/P
  */
  func refineHits(list: Set<PrefixData>, callStructure: CallStructure, searchBy: SearchBy, saveHit: Bool) -> (mainPrefix: String, result: Bool) {
     
    var firstLetter: Character
    var nextLetter: String = ""
    let baseCall = callStructure.baseCall
    var foundItems =  Set<PrefixData>()
    
    switch searchBy {
    case .BaseCall:
      
      firstLetter = baseCall![0]
      nextLetter = String(baseCall![1])
    default:
      let prefix = callStructure.prefix
      firstLetter = prefix![0]
      if prefix!.count > 1 {
         nextLetter = String(prefix![1])
      }
    }
    
    switch list.count {
      case 0:
        return (mainPrefix: "", result: false)
      case 1:
        foundItems = list
      default:
        for prefixData in list {
          var rank = 0
          var previous = true
          let primaryMaskList = prefixData.getMaskList(first: String(firstLetter), second: nextLetter, stopFound: false)
          
          for maskList in primaryMaskList {
            var position = 2
            previous = true
            
            let length = min(maskList.count, baseCall!.count)
            for index in 2...length {
              let anotherLetter = baseCall![index]
              if maskList[position].contains(String(anotherLetter)) && previous {
                rank = position + 1
              } else {
                previous = false
                break
              }
              position += 1
            }
            
            if rank == length || maskList.count == 2 {
              var data = prefixData
              data.rank = rank
              foundItems.insert(data)
            }
          }
        }
      }
      
      if foundItems.count > 0 {
        if !saveHit {
          let items = Array(foundItems)
          return (mainPrefix: items[0].mainPrefix, result: true)
        } else {
          let found = Array(foundItems)
          buildHit(foundItems: found, callStructure: callStructure, prefix: baseCall!, fullCall: callStructure.baseCall)
          return (mainPrefix: "", result: true)
        }
      }

      return (mainPrefix: "", result: false)
  }
  
  /**
   Portable prefixes are prefixes that end with "/"
   */
  func checkForPortablePrefix(callStructure: CallStructure, fullCall: String) -> Bool {
    
    let prefix = callStructure.prefix + "/"
    var list = [PrefixData]()
    var temp = [PrefixData]()
    let firstLetter = prefix[0]
    let pattern = callStructure.buildPattern(candidate: prefix)
    
    if let query = portablePrefixes[pattern] {
      
      for prefixData in query {
        temp.removeAll()
        if prefixData.indexKey.contains(firstLetter) {
          if prefixData.portableMaskExists(call: prefix) {
            temp.append(prefixData)
          }
        }
        
        if temp.count != 0 {
          list = Array(Set(list + temp))
          //list.UnionWith(temp);
          break
        }
      }
    }
    
    if list.count > 0
    {
      buildHit(foundItems: list, callStructure: callStructure, prefix: prefix, fullCall: fullCall);
        return true;
    }
    
    return false
  }
  
  /**
   Build the hit and add it to the hitlist.
   */
  func buildHit(foundItems: [PrefixData], callStructure: CallStructure , prefix: String, fullCall: String) {
    
    let sortedItems = foundItems.sorted(by: { (prefixData0: PrefixData, prefixData1: PrefixData) -> Bool in
      return prefixData0.rank < prefixData1.rank
    })
    
    for prefixData in sortedItems {
      let hit = Hit(callSign: fullCall, prefixData: prefixData)
      
      //callSignInfoCopy.CallSignFlags.UnionWith(callStructure.CallSignFlags);
      hitList.append(hit)
    }
  }
  
    /**
     Search through the secondary prefixes.
     - parameters:
     - callSign: The call sign we are working with.
     - numberPart: The number in the call.
     */
//    func searchSecondaryPrefixes(callSign: String) -> [PrefixData] {
//        
//        var maxCount = 0
//        var match = false
//        var matches = [PrefixData]()
//        
//        let callSetList = getCallSetList(callSign: callSign)
//
//        for prefixData in prefixList {
//            if prefixData.primaryMaskSets.count > 1 {
//                for primaryMask in prefixData.primaryMaskSets {
//                    let array = [primaryMask, callSetList]
//                    if let min = array.max(by: {$1.count < $0.count}) {
//                        maxCount = min.count
//                    }
//                    
//                    for i in 0..<maxCount {
//                        if callSetList[i].intersection(primaryMask[i]).count != 0 {
//                            match = true
//                        } else {
//                            match = false
//                            break
//                        }
//                    }
//                    
//                    if match == true {
//                        matches.insert(prefixData, at: 0)
//                    }
//                }
//            }
//        }
//        
//        return matches
//    }
    
    /**
     With one or matches look for children and see if we can narrow
     the location down more. Create a Hitlist for the primary or DXCC
     entry. Add a hitlist for the most likely child.
     - parameters:
     - matches: The array of PrefixData to look at.
     - callSign: The call sign we are working with.
     */
//    func processMatches(matches: [PrefixData], callSign: String) {
//        
//        var callSet: Set<String>
//        var callSetList = [Set<String>]()
//      
//        // this needs to be the suffix if LU2ART/W4
//        for item in callSign{
//            callSet = Set<String>()
//            callSet.insert(String(item))
//            callSetList.append(callSet)
//        }
//        
//        for match in matches {
//            populateHitList(prefixData: match, callSign: callSign)
////            if match.hasChildren {
////                // now go through each child and find intersections
////                for child in match.children {
////                    for mask in child.primaryMaskSets{
////                        if compareMask(mask: mask, callSetList: callSetList) {
////                            populateHitList(prefixData: child, callSign: callSign)
////                        }
////                    }
////                }
////            }
//        }
//    }
    
    /**
     Compare the mask with the Set created with the call sign.
     - parameters:
     - mask: The prefix to search for matches with.
     - callSetList: The set representing the call sign.
     */
//        func compareMask(mask: [Set<String>], callSetList: [Set<String>]) -> Bool {
//
//            var maxCount = 0
//            var match = false
//
//            // first find out which set is the smallest and we will only match that number a chars
//            let array = [mask, callSetList]
//            if let min = array.max(by: {$1.count < $0.count}) {
//                maxCount = min.count
//            }
//
//            for i in 0..<maxCount {
//                //print("i:\(i) call:\(callSetList[i]) mask:\(mask[i])")
//                if callSetList[i].intersection(mask[i]).count != 0 {
//                    match = true
//                } else {
//                    match = false
//                    return match
//                }
//            }
//
//            return match
//        }
    
    /**
     Add to the HitList array if a match.
     - parameters:
     - prefixData: The prefixData to add to the array.
     - callSign: The call sign we are working with.
     */
//        func populateHitList(prefixData: PrefixData, callSign: String) {
//
//            if hitList == nil {
//                hitList = [Hit]()
//            }
//
//            hitList.append(Hit(callSign: callSign, prefixData: prefixData))
//        }
    
    /**
     Create a Set from the call sign to do Set operations with.
     - parameters:
     - callSign: The call sign to make into a Set.
     */
//    func getCallSetList(callSign: String) -> [Set<String>] {
//
//        let callPart = callSign.prefix(4)
//
//        var callSet: Set<String>
//        var callSetList = [Set<String>]()
//
//        // this needs to be the suffix if LU2ART/W4
//        for item in callPart{
//            callSet = Set<String>()
//            callSet.insert(String(item))
//            callSetList.append(callSet)
//        }
//
//        return callSetList
//    }
  
  /**
   Check if the call area needs to be replaced and do so if necessary.
   If the original call gets a hit, find the MainPrefix and replace
   the call area with the new call area. Then do a search with that.
   */
  func checkReplaceCallArea(callStructure: CallStructure, fullCall: String) -> Bool {
    
    let digits = callStructure.baseCall.onlyDigits
    var position = 0
    //(mainPrefix: String, result: Bool)
    
    // UY0KM/0 - prefix is single digit and same as call
    if callStructure.prefix == String(digits[0]) {
      callStructure.callStructureType = CallStructureType.Call
      return true
    }
    
    // W6OP/4 will get replace by W4
      let found  = searchMainDictionary(callStructure: callStructure, fullCall: fullCall, saveHit: false)
      if found.result {
        
        let oldDigit = callStructure.prefix
        callStructure.prefix = replaceCallArea(mainPrefix: found.mainPrefix, prefix: callStructure.prefix, position: &position)
        
        
      }
    
    return false
  }
  
  
  func replaceCallArea(mainPrefix: String, prefix: String,  position: inout Int) -> String{
    
    return ""
  }
  /**
   /// <summary>
          /// Check if the call area needs to be replaced and do so if necessary.
          /// If the original call gets a hit, find the MainPrefix and replace
          /// the call area with the new call area. Then do a search with that.
          /// </summary>
          /// <param name="callStructure"></param>
          /// <param name="fullCall"></param>
          private bool CheckReplaceCallArea(CallStructure callStructure, string fullCall)
          {
              // UY0KM/0
              if (callStructure.Prefix != callStructure.BaseCall.FirstOrDefault(c => char.IsDigit(c)).ToString())
              {
                  try
                  {
                      if (SearchMainDictionary(callStructure, fullCall, false, out string mainPrefix))
                      {
                          var oldDigit = callStructure.Prefix;
                          callStructure.Prefix = ReplaceCallArea(mainPrefix, callStructure.Prefix, out int position);
                          switch (callStructure.Prefix)
                          {
                              case "":
                                  // M0CCA/6 - main prefix is "G", F8ATS/9 - Should I replace the digit?
                                  callStructure.CallStructureType = CallStructureType.Call;
                                  break;
                              default:
                                  // replace the digit in case we don't find it by it's main prefix
                                  callStructure.BaseCall = callStructure.BaseCall.Remove(position - 1, 1).Insert(position - 1, oldDigit);
                                  callStructure.CallStructureType = CallStructureType.PrefixCall;
                                  break;
                          }

                          CollectMatches(callStructure, fullCall);
                          return true;
                      }
                  }
                  catch (Exception ex)
                  {
                      var a = 1;
                  }
              }

              return false;
          }

          /// <summary>
          /// Replace the call area with the prefix digit.
          /// </summary>
          /// <param name="mainPrefix"></param>
          /// <param name="callArea"></param>
          /// <returns></returns>
          private string ReplaceCallArea(string mainPrefix, string callArea, out int position)
          {
              char[] OneCharPrefs = new char[] { 'I', 'K', 'N', 'W', 'R', 'U' };
              char[] XNUM_SET = new char[] { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '#', '[' };

              int p = 0;

              switch (mainPrefix.Length)
              {
                  case 1:
                      if (OneCharPrefs.Contains(mainPrefix.First()))
                      {
                          p = 2;
                      }
                      else if (mainPrefix.All(char.IsLetter))
                      {
                          position = 99;
                          return "";
                      }
                      break;
                  case 2:
                      if (OneCharPrefs.Contains(mainPrefix.First()) && XNUM_SET.Contains(mainPrefix.Skip(1).First()))
                      {
                          p = 2;
                      }
                      else
                      {
                          p = 3;
                      }
                      break;
                  default:
                      if (OneCharPrefs.Contains(mainPrefix.First()) && XNUM_SET.Contains(mainPrefix.Skip(1).Take(1).First()))
                      {
                          p = 2;
                      }
                      else
                      {
                          if (XNUM_SET.Contains(mainPrefix.Skip(2).Take(1).First()))
                          {
                              p = 3;
                          }
                          else
                          {
                              p = 4;
                          }
                      }
                      break;
              }

              position = p;

              return $"{mainPrefix.Substring(0, p - 1)}{callArea}";
          }
   */
    
    
} // end struct

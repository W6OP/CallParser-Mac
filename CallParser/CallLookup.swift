//
//  CallLookup.swift
//  CallParser
//
//  Created by Peter Bourget on 6/6/20.
//  Copyright © 2020 Peter Bourget. All rights reserved.
//

import Foundation
import Combine

public struct Hit: Identifiable, Hashable {
  
    public var id = UUID()
  
    public var call = ""                   //call sign as input
    public var kind = PrefixKind.none    //kind
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
    
  let queue = DispatchQueue(label: "com.w6op.calllookupqueue", qos: .userInitiated, attributes: .concurrent)
    //let semaphore = DispatchSemaphore(value: 30)
    
  var hitList = [Hit]()
    @Published public var prefixDataList = [Hit]()
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

       CallSignPatterns = prefixFileParser.callSignPatterns;
       adifs = prefixFileParser.adifs;
       portablePrefixes = prefixFileParser.portablePrefixes;

    }
    
  public init() {
    CallSignPatterns = [String: [PrefixData]]()
    adifs = [Int : PrefixData]()
    portablePrefixes = [String: [PrefixData]]()
  }
  
    /**
     Entry point for searching with a call sign.
     - parameters:
     - callSign: The call sign we want to process.
     */
    public func lookupCall(call: String) -> [Hit] {
      
            hitList = [Hit]()
      queue.async {
        self.processCallSign(callSign: call.uppercased())
      }
      
      UI{
        self.prefixDataList = Array(self.hitList)
      }
            
      return hitList
    }
  
  /**
   
   */
  func lookupCallBatch(callList: [String]) -> [Hit] {
    
    //var count = 0
    hitList = [Hit]()
    hitList.reserveCapacity(callList.count)
    prefixDataList = [Hit]()
    prefixDataList.reserveCapacity(callList.count)
    
    DispatchQueue.global(qos: .userInitiated).sync {
      DispatchQueue.concurrentPerform(iterations: callList.count - 1) { index in
      self.processCallSign(callSign: callList[index].uppercased())
      }
    }
    
    // -------------------------------------------------------------------------
    // let _ =  DispatchQueue.concurrentPerform(iterations: callList.count - 1, execute: { index in
    //      //print("testConcurrence thread=\(Thread.current)")
    //      self.processCallSign(callSign: callList[index].uppercased())
    //
    //      })
    // -------------------------------------------------------------------------
    
    // -------------------------------------------------------------------------
    //      for call in callList {
    //        queue.async {
    //        self.processCallSign(callSign: call.uppercased())
    //        self.semaphore.signal()
    //      }
    //        semaphore.wait()
    //        count += 1
    //         if count > 3000 {
    //           break
    //         }
    //    }
    // -------------------------------------------------------------------------
    
    UI {
      self.prefixDataList = Array(self.hitList.prefix(2000)) // .prefix(1000)
      print ("Hit List: \(self.hitList.count) -- PrifixDataList: \(self.prefixDataList.count)")
    }
    
    return hitList
  }
  
  /**
   Load the compound call file for testing.
   - parameters:
   */
  public func loadCompoundFile() -> [Hit] {
    var batch = [String]()
    
    let bundle = Bundle(identifier: "com.w6op.CallParser")
    guard let url = bundle!.url(forResource: "pskreporter", withExtension: "csv") else {
      print("Invalid prefix file: ")
      return [Hit]()
      // later make this throw
    }
    do {
      let contents = try String(contentsOf: url)
      let text: [String] = contents.components(separatedBy: "\r\n")
      print("Loaded: \(text.count)")
      for callSign in text{
        //print(callSign)
        batch.append(callSign)
        //try? print(lookupCall(call: callSign))
      }
    } catch {
      // contents could not be loaded
      print("Invalid compund file: ")
    }
    
    return lookupCallBatch(callList: batch)
    
  }
  
  /**
  Run the batch job with the compound call file.
  - parameters:
  */
  public func runBatchJob() {
    
  }
    
    /**
     Process a call sign into its component parts ie: W6OP/V31
     - parameters:
     - call: The call sign to be processed.
     */
    func processCallSign(callSign: String) {
      
        var cleanedCall = ""// = callSign
      
      // if there are spaces in the call don't process it
      cleanedCall = callSign.replacingOccurrences(of: " ", with: "")
        if cleanedCall.count != callSign.count {
          return
        }
      
      // strip leading or trailing "/"  /W6OP/
      if callSign.prefix(1) == "/" {
        cleanedCall = String(callSign.suffix(callSign.count - 1))
      }
      
      if callSign.suffix(1) == "/" {
        cleanedCall = String(cleanedCall.prefix(cleanedCall.count - 1))
      }
      

      let callStructure = CallStructure(callSign: cleanedCall, portablePrefixes: portablePrefixes);

        if (callStructure.callStructureType != CallStructureType.invalid) {
          //BG{
            self.collectMatches(callStructure: callStructure)
          //}
       }
    }
    
    /**
     First see if we can find a match for the max prefix of 4 characters.
     Then start removing characters from the back until we can find a match.
     Once we have a match we will see if we can find a child that is a better match.
     - parameters:
     - callSign: The call sign we are working with.
     */
  func collectMatches(callStructure: CallStructure) {
        
    let callStructureType = callStructure.callStructureType
    
    switch (callStructureType) // GT3UCQ/P
    {
        case CallStructureType.callPrefix:
          if checkForPortablePrefix(callStructure: callStructure) { return }

        case CallStructureType.prefixCall:
          if checkForPortablePrefix(callStructure: callStructure) { return }

        case CallStructureType.callPortablePrefix:
          if checkForPortablePrefix(callStructure: callStructure) { return }

        case CallStructureType.callPrefixPortable:
          if checkForPortablePrefix(callStructure: callStructure) { return }

        case CallStructureType.prefixCallPortable:
          if checkForPortablePrefix(callStructure: callStructure) { return }

        case CallStructureType.prefixCallText:
          if checkForPortablePrefix(callStructure: callStructure) { return }

        case CallStructureType.callDigit:
          if checkReplaceCallArea(callStructure: callStructure) { return }
      
        default:
            break
    }
    
    if searchMainDictionary(callStructure: callStructure, saveHit: true).result == true
    {
        return;
    }
}
  
  /**
   Search the CallSignDictionary for a hit with the full call. If it doesn't
   hit remove characters from the end until hit or there are no letters fleft.
   */
  func  searchMainDictionary(callStructure: CallStructure, saveHit: Bool) -> (mainPrefix: String, result: Bool)
  {
    let prefix = callStructure.prefix
    
    var pattern: String
    var searchBy = SearchBy.prefix
    
    switch (true) {
      
    case callStructure.callStructureType == CallStructureType.prefixCall
      || callStructure.callStructureType == CallStructureType.prefixCallPortable
      || callStructure.callStructureType == CallStructureType.prefixCallText
      && prefix!.count == 1:
      
      // TODO: ist this redundant, could I have saved it earlier?
      pattern = callStructure.buildPattern(candidate: callStructure.prefix)
      
    case callStructure.callStructureType == CallStructureType.prefixCall:
      pattern = callStructure.buildPattern(candidate: callStructure.prefix)
      
    case callStructure.callStructureType == CallStructureType.prefixCall:
      pattern = callStructure.buildPattern(candidate: callStructure.prefix)
      
    case callStructure.callStructureType == CallStructureType.prefixCallText:
      pattern = callStructure.buildPattern(candidate: callStructure.prefix)
      
    default:
      searchBy = SearchBy.call
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
    case .call:
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
    case .call:
      
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
          buildHit(foundItems: found, prefix: baseCall!, fullCall: callStructure.fullCall)
          return (mainPrefix: "", result: true)
        }
      }

      return (mainPrefix: "", result: false)
  }
  
  /**
   Portable prefixes are prefixes that end with "/"
   */
  func checkForPortablePrefix(callStructure: CallStructure) -> Bool {
    
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
      buildHit(foundItems: list, prefix: prefix, fullCall: callStructure.fullCall);
        return true;
    }
    
    return false
  }
  
  /**
   Build the hit and add it to the hitlist.
   */
  func buildHit(foundItems: [PrefixData], prefix: String, fullCall: String) {
    
    let sortedItems = foundItems.sorted(by: { (prefixData0: PrefixData, prefixData1: PrefixData) -> Bool in
      return prefixData0.rank < prefixData1.rank
    })
    
    //https://rbnsn.me/multi-core-array-operations-in-swift
    //    sortedItems.concurrentForEach {prefixData in
    //      let hit = Hit(callSign: fullCall, prefixData: prefixData)
    //      self.hitList.append(hit)
    //    }
    
    for prefixData in sortedItems {
      let hit = Hit(callSign: fullCall, prefixData: prefixData)
      queue.async(flags: .barrier) {
        self.hitList.append(hit)
      }
    }
  }
 
  /**
   Check if the call area needs to be replaced and do so if necessary.
   If the original call gets a hit, find the MainPrefix and replace
   the call area with the new call area. Then do a search with that.
   */
  func checkReplaceCallArea(callStructure: CallStructure) -> Bool {
    
    let digits = callStructure.baseCall.onlyDigits
    var position = 0
    
    // UY0KM/0 - prefix is single digit and same as call
    if callStructure.prefix == String(digits[0]) {
      var callStructure = callStructure
      callStructure.callStructureType = CallStructureType.call
      collectMatches(callStructure: callStructure);
      return true
    }
    
    // W6OP/4 will get replace by W4
      let found  = searchMainDictionary(callStructure: callStructure, saveHit: false)
      if found.result {
        var callStructure = callStructure
        callStructure.prefix = replaceCallArea(mainPrefix: found.mainPrefix, prefix: callStructure.prefix, position: &position)
        
        switch callStructure.prefix {
          
        case "":
          callStructure.callStructureType = CallStructureType.call
          
        default:
          callStructure.callStructureType = CallStructureType.prefixCall
        }
        
        collectMatches(callStructure: callStructure)
        return true;
      }
    
    return false
  }
  
  
  /**
   
   */
  func replaceCallArea(mainPrefix: String, prefix: String,  position: inout Int) -> String{
    
    let oneCharPrefixes: [Character] = ["I", "K", "N", "W", "R", "U"]
    let XNUM_SET: [Character] = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "#", "["]
  
    switch mainPrefix.count {
    case 1:
      if oneCharPrefixes.contains(mainPrefix[0]){
        // I9MRY/1 - mainPrefix = I --> I1
        position = 2
      } else  if mainPrefix.isAlphabetic {
        // FA3L/6 - mainPrefix is F
        position = 99
        return ""
      }

    case 2:
      if oneCharPrefixes.contains(mainPrefix[0]) && XNUM_SET.contains(mainPrefix[1]) {
        // W6OP/4 - main prefix = W6 --> W4
        position = 2
      } else {
        // AL7NS/4 - main prefix = KL --> KL4
        position = 3
      }

    default:
      if oneCharPrefixes.contains(mainPrefix[0]) && XNUM_SET.contains(mainPrefix[1]){
        position = 2
      }else {
        if XNUM_SET.contains(mainPrefix[2]) {
          // JI3DT/6 - mainPrefix = JA3 --> JA6
          position = 3
        } else {
          // 3DLE/1 - mainprefix = 3DA --> 3DA1
          position = 4
        }
      }
    }

    // append call area to mainPrefix
    return mainPrefix.prefix(position - 1) + prefix + "/"
  }
  
  /**
   
   */
    
    
} // end struct

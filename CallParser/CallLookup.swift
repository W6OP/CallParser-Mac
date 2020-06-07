//
//  CallLookup.swift
//  CallParser
//
//  Created by Peter Bourget on 6/6/20.
//  Copyright © 2020 Peter Bourget. All rights reserved.
//

import Foundation
import Combine

public struct HitList {
    var call = ""                   //call sign as input
    var kind = PrefixKind.pfNone    //kind
    var country = ""                //country
    var province = ""               //province
    var city = ""                   //city
    var dxcc_entity = ""            //dxcc_entity
    var cq = ""                     //cq_zone
    var itu = ""                    //itu_zone
    var continent = ""              //continent
    var timeZone = ""               //time_zone
    var latitude = "0.0"            //lat
    var longitude = "0.0"           //long
    
    init(callSign: String, prefixData: PrefixData) {
        self.call = callSign
        self.kind = prefixData.kind
        self.country = prefixData.country
        self.province = prefixData.province
        self.city = prefixData.city
        self.dxcc_entity = prefixData.dxcc_entity
        self.cq = prefixData.cq
        self.itu = prefixData.itu
        self.continent = prefixData.continent
        self.timeZone = prefixData.timeZone
        self.latitude = prefixData.latitude
        self.longitude = prefixData.longitude
    }
}

/**
 Look up the data on a call sign.
 */
public class CallLookup: ObservableObject{
    
    // EndingPreserve = ':R:P:M:';
    // EndingIgnore = ':AM:MM:QRP:A:B:BCN:LH:';
    enum CallSignType: String {
        case A = "A"
        case ADIF = "ADIF"
        case B = "B"
        case BCN = "Beacon"
        case LH = "LH"
        case M = "Mobile"
        case MM = "Marine Mobile"
        case P = "Portable"
        case QRP = "Low Power"
        case R = "Rover"
    }
    
    var hitList: [HitList]!
    var prefixList: [PrefixData]
    var childPrefixList: [PrefixData]

    /**
     Initialization.
     - parameters:
     - prefixList: The parent prefix list to use for searches.
     - childPrefixList: the child prefix list to use for searches.
     */
    public init(prefixList: [PrefixData], childPrefixList: [PrefixData]) {
        self.prefixList = prefixList
        self.childPrefixList = childPrefixList
    }
    
    /**
     Entry point for searching with a call sign.
     - parameters:
     - callSign: The call sign we want to process.
     */
    public func lookupCall(call: String) throws -> [HitList] {
      
            self.processCallSign(callSign: call.uppercased())
     
            return self.hitList ?? [HitList]()
      
    }
    
    /**
     Process a call sign into its component parts ie: W6OP/V31
     - parameters:
     - call: The call sign to be processed.
     */
    func processCallSign(callSign: String) {
        
        var prefix = ""
        var call = callSign
        
        let components = callSign.components(separatedBy: "/")
        
        switch (components.count) {
        case 1:
            collectMatches(callSign: callSign)
        case 2:
            let array = [components[0], components[1]]
            if let min = array.max(by: {$1.count < $0.count}) {
                prefix = min
            }
            
            if let max = array.max(by: {$1.count > $0.count}) {
                call = max
            }
            // call can be W4/LU2ART or LU2ART/W4
            call = "\(prefix)/\(call)"
            collectMatches(callSign: prefix)
        case 3..<100:
            // illegal call format
            // do something - throw
            assertionFailure("what happened here")
            break
        default:
            // should I do anything here?
            break
        }
    }
    
    /**
     First see if we can find a match for the max prefix of 4 characters.
     Then start removing characters from the back until we can find a match.
     Once we have a match we will see if we can find a child that is a better match.
     - parameters:
     - callSign: The call sign we are working with.
     */
    func collectMatches(callSign: String) {
        
        var callPart = callSign.prefix(4)
        var matches = prefixList.filter({ $0.mainPrefix == callPart})
        
        switch matches.count {
        case 1:
            populateHitList(prefixData: matches[0], callSign: callSign)
        default:
            callPart.removeLast()
            while matches.count == 0 {
                matches = prefixList.filter({ $0.mainPrefix == String(callPart)})
                callPart.removeLast()
                if callPart.isEmpty {
                    break
                }
            }
            
            // no match so search secondary prefixes
            switch matches.count {
            case 0:
                matches = searchSecondaryPrefixes(callSign: callSign)
                switch matches.count {
                case 0:
                    searchChildren(callSign: callSign)
                default:
                    processMatches(matches: matches, callSign: callSign)
                }
            default:
                processMatches(matches: matches, callSign: callSign)
            }
        }
    }
    
    /**
     Search through the secondary prefixes.
     - parameters:
     - callSign: The call sign we are working with.
     - numberPart: The number in the call.
     */
    func searchSecondaryPrefixes(callSign: String) -> [PrefixData] {
        
        var maxCount = 0
        var match = false
        var matches = [PrefixData]()
        
        let callSetList = getCallSetList(callSign: callSign)

        for prefixData in prefixList {
            if prefixData.primaryMaskSets.count > 1 {
                for primaryMask in prefixData.primaryMaskSets {
                    let array = [primaryMask, callSetList]
                    if let min = array.max(by: {$1.count < $0.count}) {
                        maxCount = min.count
                    }
                    
                    for i in 0..<maxCount {
                        if callSetList[i].intersection(primaryMask[i]).count != 0 {
                            match = true
                        } else {
                            match = false
                            break
                        }
                    }
                    
                    if match == true {
                        matches.insert(prefixData, at: 0)
                    }
                }
            }
        }
        
        return matches
    }
    
  
    /**
     Look at the mask in every child of every parent
     - parameters:
     - callSign: the call sign to search with.
     */
    func searchChildren(callSign: String) {

        let callSetList = getCallSetList(callSign: callSign)
        
        for child in childPrefixList {
            for mask in child.primaryMaskSets{
                if compareMask(mask: mask, callSetList: callSetList) {
                    populateHitList(prefixData: child, callSign: callSign)
                }
            }
        }
    }
    
    /**
     With one or matches look for children and see if we can narrow
     the location down more. Create a Hitlist for the primary or DXCC
     entry. Add a hitlist for the most likely child.
     - parameters:
     - matches: The array of PrefixData to look at.
     - callSign: The call sign we are working with.
     */
    func processMatches(matches: [PrefixData], callSign: String) {
        
        var callSet: Set<String>
        var callSetList = [Set<String>]()
      
        // this needs to be the suffix if LU2ART/W4
        for item in callSign{
            callSet = Set<String>()
            callSet.insert(String(item))
            callSetList.append(callSet)
        }
        
        for match in matches {
            populateHitList(prefixData: match, callSign: callSign)
            if match.hasChildren {
                // now go through each child and find intersections
                for child in match.children {
                    for mask in child.primaryMaskSets{
                        if compareMask(mask: mask, callSetList: callSetList) {
                            populateHitList(prefixData: child, callSign: callSign)
                        }
                    }
                }
            }
        }
    }
    
    /**
     Compare the mask with the Set created with the call sign.
     - parameters:
     - mask: The prefix to search for matches with.
     - callSetList: The set representing the call sign.
     */
        func compareMask(mask: [Set<String>], callSetList: [Set<String>]) -> Bool {
            
            var maxCount = 0
            var match = false
            
            // first find out which set is the smallest and we will only match that number a chars
            let array = [mask, callSetList]
            if let min = array.max(by: {$1.count < $0.count}) {
                maxCount = min.count
            }
            
            for i in 0..<maxCount {
                //print("i:\(i) call:\(callSetList[i]) mask:\(mask[i])")
                if callSetList[i].intersection(mask[i]).count != 0 {
                    match = true
                } else {
                    match = false
                    return match
                }
            }
            
            return match
        }
    
    /**
     Add to the HitList array if a match.
     - parameters:
     - prefixData: The prefixData to add to the array.
     - callSign: The call sign we are working with.
     */
        func populateHitList(prefixData: PrefixData, callSign: String) {
            
            if hitList == nil {
                hitList = [HitList]()
            }
            
            hitList.append(HitList(callSign: callSign, prefixData: prefixData))
        }
    
    /**
     Create a Set from the call sign to do Set operations with.
     - parameters:
     - callSign: The call sign to make into a Set.
     */
    func getCallSetList(callSign: String) -> [Set<String>] {
        
        let callPart = callSign.prefix(4)
        
        var callSet: Set<String>
        var callSetList = [Set<String>]()
        
        // this needs to be the suffix if LU2ART/W4
        for item in callPart{
            callSet = Set<String>()
            callSet.insert(String(item))
            callSetList.append(callSet)
        }
        
        return callSetList
    }
    
    
} // end struct

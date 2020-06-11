//
//  XmlParser.swift
//  CallParser
//
//  Created by Peter Bourget on 6/6/20.
//  Copyright © 2020 Peter Bourget. All rights reserved.
//

import Foundation

// https://stackoverflow.com/questions/31083348/parsing-xml-from-url-in-swift/31084545#31084545
// https://www.ioscreator.com/tutorials/parse-xml-ios-tutorial
@available(OSX 10.14, *)
extension PrefixFileParser: XMLParserDelegate {
  
  /**
   Initialize data structures on start
   - parameters:
   - parser: XmlParser
   */
  public func parserDidStartDocument(_ parser: XMLParser) {
    
    // array of array of prefixData (CallSignInfo)
    prefixList = [PrefixData]()
  }
  
  /**
   Initialize PrefixData each time we make a pass. This is called each
   time a new prefix element is found
   - parameters:
   -
   */
  public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
    
    currentValue = ""
    nodeName = elementName
    
    if elementName == recordKey {
      prefixData = PrefixData()
    } else if elementName == "Error" {
      print(elementName)
    }
    //print(elementName)
  }
  
  /**
   Getting the value of each element
   - parameters:
   -
   */
  public func parser(_ parser: XMLParser, foundCharacters string: String) {
   
    let currentValue = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    
    if (!currentValue.isEmpty) {
      switch (nodeName){
      case "mask":
        prefixData.expandedMaskList = expandMask(element: currentValue)
        //prefixData.storeMask(mask: currentValue )
        //prefixData.rawMasks.append(currentValue )
      case "label":
        prefixData.fullPrefix = currentValue
        prefixData.setMainPrefix(fullPrefix: currentValue )
      case "kind":
        prefixData.setDXCC(prefixKind: PrefixKind(rawValue: currentValue )!)
      case "country":
        prefixData.country  = currentValue
      case "province":
        prefixData.province  = currentValue
      case "dxcc_entity":
        prefixData.dxcc_entity  = Int(currentValue ) ?? 0
      case "cq_zone":
        prefixData.cq  = prefixData.buildZoneList(zones: currentValue )
      case "itu_zone":
        prefixData.itu  = prefixData.buildZoneList(zones: currentValue )
      case "continent":
        prefixData.continent  = currentValue
      case "time_zone":
        prefixData.timeZone  = currentValue
      case "lat":
        prefixData.latitude  = currentValue
      case "long":
        prefixData.longitude  = currentValue
      case "city":
        prefixData.city = currentValue
      case "wap_entity":
        prefixData.wap = currentValue
      case "wae_entity":
        prefixData.wae = Int(currentValue ) ?? 0
      case "province_id":
        prefixData.admin1 = currentValue
      case "start_date":
        prefixData.startDate = currentValue
      case "end_date":
        prefixData.endDate = currentValue
      case .none:
        break
      case .some(_):
        break
      }
    }
  }
  
  /**
   At the end of each prefix element save the value
   - parameters:
   -
   */
  public func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
    
    //        switch (elementName){
    //        case "mask":
    //            prefixData.storeMask(mask: currentValue ?? "")
    //            prefixData.rawMasks.append(currentValue ?? "")
    //        case "label":
    //            prefixData.fullPrefix = currentValue ?? ""
    //            prefixData.setMainPrefix(fullPrefix: currentValue ?? "")
    //        case "kind":
    //            prefixData.setDXCC(prefixKind: PrefixKind(rawValue: currentValue ?? PrefixKind.pfNone.rawValue)!)
    //        case "country":
    //            prefixData.country  = currentValue ?? ""
    //        case "province":
    //            prefixData.province  = currentValue ?? ""
    //        case "dxcc_entity":
    //          prefixData.dxcc_entity  = Int(currentValue ?? "0") ?? 0
    //        case "cq_zone":
    //          prefixData.cq  = prefixData.buildZoneList(zones: currentValue ?? "0")
    //        case "itu_zone":
    //            prefixData.itu  = prefixData.buildZoneList(zones: currentValue ?? "0")
    //        case "continent":
    //            prefixData.continent  = currentValue ?? ""
    //        case "time_zone":
    //            prefixData.timeZone  = currentValue ?? ""
    //        case "lat":
    //            prefixData.latitude  = currentValue ?? ""
    //        case "long":
    //            prefixData.longitude  = currentValue ?? ""
    //        case "city":
    //            prefixData.city = currentValue ?? ""
    //        case "wap_entity":
    //            prefixData.wap = currentValue ?? ""
    //        case "wae_entity":
    //            prefixData.wae = Int(currentValue ?? "0") ?? 0
    //        case "province_id":
    //            prefixData.admin1 = currentValue ?? ""
    //        case "start_date":
    //            prefixData.startDate = currentValue ?? ""
    //        case "end_date":
    //            prefixData.endDate = currentValue ?? ""
    //        default:
    //            currentValue = nil
    //        }
    
    //currentValue = ""
    
    if elementName == recordKey {
      prefixList.append(prefixData)
    }
  }
  
  /**
   Parsing has finished
   - parameters:
   -
   */
  public func parserDidEndDocument(_ parser: XMLParser) {
    print("document finished")
  }
  
  /**
   Just in case, if there's an error, report it.
   - parameters:
   -
   */
  public func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
    
    print(parseError)
    currentValue = ""
  }
}

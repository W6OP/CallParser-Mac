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
    //prefixList = [PrefixData]()
    
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
      tempMaskList = [String]()
    } else if elementName == "Error" {
      print(elementName)
    }
    //print(elementName)
  }
  
  /**
   Getting the value of each element. This differs from the C# version
   as I pass in the entire prefix node to the CallSignInfo (PrefixData)
   class and let it parse it. I can't do that easily in Swift.
   - parameters:
   -
   */
  public func parser(_ parser: XMLParser, foundCharacters string: String) {
   
    let currentValue = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    
    if (!currentValue.isEmpty) {
      switch (nodeName){
      case "mask":
          prefixData.tempMaskList.append(currentValue)
//        expandedMaskList = expandMask(element: currentValue)
//        prefixData.setPrimaryMaskList(value: expandedMaskList)
//        buildPattern(primaryMaskList: expandedMaskList)
      case "label":
        prefixData.fullPrefix = currentValue
        prefixData.setMainPrefix(fullPrefix: currentValue )
      case "kind":
        prefixData.setPrefixKind(prefixKind: PrefixKind(rawValue: currentValue )!)
      case "country":
        prefixData.country  = currentValue
      case "province":
        prefixData.province  = currentValue
      case "dxcc_entity":
        prefixData.dxcc  = Int(currentValue ) ?? 0
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
   
    if elementName == recordKey {
      
      if prefixData.kind == PrefixKind.DXCC {
        let key = Int(prefixData.dxcc)
        adifs[key] = prefixData
      }
      
      if prefixData.kind == PrefixKind.InvalidPrefix {
        adifs[0] = prefixData
      }
      
      if prefixData.wae != 0 {
        adifs[prefixData.wae] = prefixData
      }
      
      if prefixData.kind == PrefixKind.Province && prefixData.admin1 == "" {
        
        if var valueExists = admins[prefixData.admin1] {
          valueExists.append(prefixData)
        } else {
          admins[prefixData.admin1] = [PrefixData](arrayLiteral: prefixData)
        }
      }
      for currentValue in prefixData.tempMaskList {
        let expandedMaskList = expandMask(element: currentValue)
        prefixData.setPrimaryMaskList(value: expandedMaskList)
        buildPattern(primaryMaskList: expandedMaskList)
      }
      
    }
  }
  
  /**
   Parsing has finished
   - parameters:
   -
   */
  public func parserDidEndDocument(_ parser: XMLParser) {
    print("document finished")
    print("CallSignDictionary Count: \(callSignDictionary.count)")
    print("PortablePrefixes Count: \(portablePrefixes.count)")
    for (key, value) in callSignDictionary {
      print("\(key) : \(value.count)")
    }
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
/**
 Key = #@##, Value = 6 ---------- 6
 Key = @@#@., Value = 18 -------- 57
 Key = #@, Value = 61 ----------59                    pattern  String  "@@#@."
 Key = @@#@#, Value = 39 **************************** @@#@? AX9[ABD-KOPQS-VYZ][.ABD-KOPQS-VYZ] VK9 Australia external
 Key = @#@., Value = 5 --------------- 5
 Key = @@#@@#, Value = 1 **********************
 Key = #@#@, Value = 45 ------------ 45
 Key = @##, Value = 85 -------------- 85
 Key = @@#@@@/@., Value = 1 ---------- 1
 Key = #@@, Value = 39 ------------- 39
 Key = #@####@, Value = 3 ------------- 3
 Key = @@#, Value = 745 -------------- 745
 Key = @#@@., Value = 111 -------------- 111
 Key = @@#@@., Value = 18  ------------ 19
 Key = @@##@@@., Value = 2 -------------2
 Key = @@#@@@@, Value = 2 -----------2
 Key = @@#@@@, Value = 24 ------------- 23
 Key = @##@@, Value = 4 ------------- 4
 Key = @#@@@@, Value = 5 ------------ 5
 Key = #@#, Value = 239 ---------- 239
 Key = @###, Value = 4 ------------ 4
 Key = @#@@@., Value = 90 -----------90
 Key = @#, Value = 83 ------------- 81
 Key = @##@., Value = 1 ----------- 1
 Key = @@##, Value = 78 ******************************
 Key = @##@, Value = 55 ------------- 55
 Key = #@###@, Value = 3 ----------3
 Key = @@#@@@., Value = 2 *****************************
 Key = @@, Value = 105  -----------105
 Key = @@#@@, Value = 117 ---------- 78
 Key = @#@, Value = 16 ----------- 16
 Key = @@#@, Value = 551 ------------551
 Key = #@##@, Value = 3 ------------ 3

 @@##@@@. : 2
 @##@ : 55
 @@## : 78
 @@ : 105
 @@#@@@ : 23
 @@#@@@. : 2
 #@###@ : 3
 #@# : 239
 @#@@@. : 90
 @@# : 745
 #@##@ : 3
 @@#@@@@ : 2
 @@#@. : 57
 @##@. : 1
 #@#@ : 45
 @#@@. : 111
 @# : 81
 @@#@ : 551
 @@#@@ : 78
 @#@. : 5
 #@####@ : 3
 #@@ : 39
 @## : 85
 @#@@@@ : 5
 @### : 4
 @@#@@. : 19
 @##@@ : 4
 #@## : 6
 @@#@@@/@. : 1
 #@ : 59
 @#@ : 16
 */

//
//  CallStructure.swift
//  CallParser
//
//  Created by Peter Bourget on 6/13/20.
//  Copyright © 2020 Peter Bourget. All rights reserved.
//

import Foundation

public class CallStructure {
  
  
  private var singleCharacterPrefixes: [String] = ["F", "G", "M", "I", "R", "W" ]
  
  public var prefix: String!
  public var baseCall: String!
  private var suffix1: String!
  private var suffix2: String!
  
  private var callSignFlags = [CallSignFlags]()
  public var callStructureType = CallStructureType.Invalid
  private var portablePrefixes: [String: [PrefixData]]!
  
  /**
   Constructor
   */
  public init(callSign: String, portablePrefixes: [String: [PrefixData]]) {
    self.portablePrefixes = portablePrefixes
    
    splitCallSign(callSign: callSign);
  }
  
  /**
   Split the call sign into indvidual componenets
   */
  func splitCallSign(callSign: String) {
    
    if callSign.components(separatedBy:"/").count > 3 {
      return
    }
    
    let components = callSign.components(separatedBy:"/")
    
    for item in components {
      if getComponentType(callSign: item) == StringTypes.Invalid {
        return
      }
    }
    
    analyzeComponents(components: components);
    
  }
  
  /*/
   Just a quick test for grossly invalid call signs.
   */
  func getComponentType(callSign: String) -> StringTypes {
    
    let state = false
    
    // THIS NEEDS CHECKING
    switch state {
    case callSign.trimmingCharacters(in: .whitespaces).isEmpty:
      return StringTypes.Valid
    case callSign.trimmingCharacters(in: .punctuationCharacters).isEmpty:
      return StringTypes.Valid
    case callSign.trimmingCharacters(in: .illegalCharacters).isEmpty:
      return StringTypes.Valid
    default:
      return StringTypes.Invalid
    }
  }
  
  /**
   
   */
  func analyzeComponents(components: [String]) {
    
    switch components.count {
    case 0:
      return
    case 1:
      if verifyIfCallSign(component: components[0]) == ComponentType.CallSign
      {
        baseCall = components[0];
        callStructureType = CallStructureType.Call;
      }
      else
      {
        callStructureType = CallStructureType.Invalid;
      }
      break
    case 2:
      processComponents(component0: components[0], component1: components[1]);
      break
    case 3:
      processComponents(component0: components[0], component1: components[1], component2: components[2]);
      break
    default:
      return
    }
    
  }
  
  /**
   
   */
  func processComponents(component0: String, component1: String) {
    
    //var componentType = ComponentType.Invalid
    var component0Type: ComponentType
    var component1Type: ComponentType
    
    component0Type = getComponentType(candidate: component0, position: 1)
    component1Type = getComponentType(candidate: component1, position: 2)
    
    if component0Type == ComponentType.Unknown || component1Type == ComponentType.Unknown {
      //ResolveAmbiguities(component0Type, component1Type, out component0Type, out component1Type);
      resolveAmbiguities(componentType0: component0Type, componentType1: component1Type, component0Type: &component0Type, component1Type: &component1Type);
    }
    
    baseCall = component0
    prefix = component1
    
    // ValidStructures = 'C#:CM:CP:CT:PC:'
    
    let state = true
    
    switch state {
    // if either is invalid short cicuit all the checks and exit immediately
    case component0Type == ComponentType.Invalid || component1Type == ComponentType.Invalid:
      return
      
    // CP
    case component0Type == ComponentType.CallSign && component1Type == ComponentType.Prefix:
      callStructureType = CallStructureType.CallPrefix
      
    // PC
    case component0Type == ComponentType.Prefix && component1Type == ComponentType.CallSign:
      callStructureType = CallStructureType.PrefixCall
      setCallSignFlags(component1: component0, component2: "")
      baseCall = component1;
      prefix = component0;
      
    // PP
    case component0Type == ComponentType.Prefix && component1Type == ComponentType.Portable:
      callStructureType = CallStructureType.Invalid
      
    // CC  ==> CP - check BU - BY - VU4 - VU7
    case component0Type == ComponentType.CallSign && component1Type == ComponentType.CallSign:
      if (component1.prefix(1) == "B") {
        callStructureType = CallStructureType.CallPrefix;
        setCallSignFlags(component1: component0, component2: "");
      } else if component0.prefix(3) == "VU4" || component0.prefix(3) == "VU7" {
        callStructureType = CallStructureType.CallPrefix;
        setCallSignFlags(component1: component1, component2: "");
      }
      
    // CT
    case component0Type == ComponentType.CallSign && component1Type == ComponentType.Text:
      callStructureType = CallStructureType.CallText
      setCallSignFlags(component1: component1, component2: "")
      
    // C#
    case component0Type == ComponentType.CallSign && component1Type == ComponentType.Numeric:
      callStructureType = CallStructureType.CallDigit
      setCallSignFlags(component1: component1, component2: "")
      
    // CM
    case component0Type == ComponentType.CallSign && component1Type == ComponentType.Portable:
      callStructureType = CallStructureType.CallPortable
      setCallSignFlags(component1: component1, component2: "")
      
    // PU
    case component0Type == ComponentType.Prefix && component1Type == ComponentType.Unknown:
      callStructureType = CallStructureType.PrefixCall
      baseCall = component1;
      prefix = component0;
      
    default:
      return
    }
  }
  
  /**
   
   */
  func processComponents(component0: String, component1: String, component2: String) {
    
    var component0Type: ComponentType
    var component1Type: ComponentType
    var component2Type: ComponentType
    
    component0Type = getComponentType(candidate: component0, position: 1)
    component1Type = getComponentType(candidate: component1, position: 2)
    component2Type = getComponentType(candidate: component2, position: 3)
    
    if component0Type == ComponentType.Unknown || component1Type == ComponentType.Unknown {
      resolveAmbiguities(componentType0: component0Type, componentType1: component1Type, component0Type: &component0Type, component1Type: &component1Type)
    }
    
    baseCall = component0
    prefix = component1
    suffix1 = component2;
    
    // ValidStructures = 'C#M:C#T:CM#:CMM:CMP:CMT:CPM:PCM:PCT:'
    let state = false
    switch state {
    // if either is invalid short cicuit all the checks and exit immediately
    case component0Type == ComponentType.Invalid || component1Type == ComponentType.Invalid || component2Type == ComponentType.Invalid:
      return
      
    // C#M
    case component0Type == ComponentType.CallSign && component1Type == ComponentType.Numeric && component2Type == ComponentType.Portable:
      callStructureType = CallStructureType.CallDigitPortable
      setCallSignFlags(component1: component2, component2: "")
      
      
    // C#T
    case component0Type == ComponentType.CallSign && component1Type == ComponentType.Numeric && component2Type == ComponentType.Text:
      callStructureType = CallStructureType.CallDigitText
      setCallSignFlags(component1: component2, component2: "")
      
      
    // CMM
    case component0Type == ComponentType.CallSign && component1Type == ComponentType.Portable && component2Type == ComponentType.Portable:
      callStructureType = CallStructureType.CallPortablePortable
      setCallSignFlags(component1: component1, component2: "")
      
      
    // CMP
    case component0Type == ComponentType.CallSign && component1Type == ComponentType.Portable && component2Type == ComponentType.Prefix:
      baseCall = component0
      prefix = component2
      suffix1 = component1
      callStructureType = CallStructureType.CallPortablePrefix
      setCallSignFlags(component1: component1, component2: "")
      
      
    // CMT
    case component0Type == ComponentType.CallSign && component1Type == ComponentType.Portable && component2Type == ComponentType.Text:
      callStructureType = CallStructureType.CallPortableText
      setCallSignFlags(component1: component1, component2: "")
      return;
      
    // CPM
    case component0Type == ComponentType.CallSign && component1Type == ComponentType.Prefix && component2Type == ComponentType.Portable:
      callStructureType = CallStructureType.CallPrefixPortable
      setCallSignFlags(component1: component2, component2: "")
      
      
    // PCM
    case component0Type == ComponentType.Prefix && component1Type == ComponentType.CallSign && component2Type == ComponentType.Portable:
      baseCall = component1
      prefix = component0
      suffix1 = component2
      callStructureType = CallStructureType.PrefixCallPortable
      
    // PCT
    case component0Type == ComponentType.Prefix && component1Type == ComponentType.CallSign && component2Type == ComponentType.Text:
      baseCall = component1
      prefix = component0
      suffix1 = component2
      callStructureType = CallStructureType.PrefixCallText
      
      
    case component0Type == ComponentType.CallSign && component1Type == ComponentType.Portable && component2Type == ComponentType.Numeric:
      baseCall = component0
      prefix = component2
      suffix1 = component1
      setCallSignFlags(component1: component2, component2: "")
      callStructureType = CallStructureType.CallDigitPortable
      
    default:
      return
    }
  }
  
  /**
   
   */
  func setCallSignFlags(component1: String, component2: String){
    
    switch component1 {
    case "R":
      callSignFlags.append(CallSignFlags.Beacon)
      
      case "B":
      callSignFlags.append(CallSignFlags.Beacon)
      
    case "P":
      if component2 == "QRP" {
        callSignFlags.append(CallSignFlags.Qrp)
      }
      callSignFlags.append(CallSignFlags.Portable)
      
      case "QRP":
      if component2 == "P" {
        callSignFlags.append(CallSignFlags.Portable)
      }
      callSignFlags.append(CallSignFlags.Qrp)
      
      case "M":
      callSignFlags.append(CallSignFlags.Portable)
      
    case "MM":
      callSignFlags.append(CallSignFlags.Maritime)
      
    default:
      callSignFlags.append(CallSignFlags.Portable)
    }
  }
  
  /**
   ///FStructure:= StringReplace(FStructure, 'UU', 'PC', [rfReplaceAll]);
   ///FStructure:= StringReplace(FStructure, 'CU', 'CP', [rfReplaceAll]);
   ///FStructure:= StringReplace(FStructure, 'UC', 'PC', [rfReplaceAll]);
   ///FStructure:= StringReplace(FStructure, 'UP', 'CP', [rfReplaceAll]);
   ///FStructure:= StringReplace(FStructure, 'PU', 'PC', [rfReplaceAll]);
   ///FStructure:= StringReplace(FStructure, 'U', 'C', [rfReplaceAll]);
   */
  func resolveAmbiguities(componentType0: ComponentType, componentType1: ComponentType, component0Type: inout ComponentType, component1Type: inout ComponentType){
    
    let state = false
    
    switch state {
    // UU --> PC
    case componentType0 == ComponentType.Unknown && componentType1 == ComponentType.Unknown:
      component0Type = ComponentType.Prefix
      component1Type = ComponentType.CallSign
      return
      
    // CU --> CP
    case componentType0 == ComponentType.CallSign && componentType1 == ComponentType.Unknown:
      component0Type = ComponentType.CallSign
      component1Type = ComponentType.Prefix
      return
      
    // UC --> PC
    case componentType0 == ComponentType.Unknown && componentType1 == ComponentType.CallSign:
      component0Type = ComponentType.Prefix
      component1Type = ComponentType.CallSign
      return
      
    // UP --> CP
    case componentType0 == ComponentType.Unknown && componentType1 == ComponentType.Prefix:
      component0Type = ComponentType.CallSign
      component1Type = ComponentType.Prefix
      return
      
    // PU --> PC
    case componentType0 == ComponentType.Prefix && componentType1 == ComponentType.Unknown:
      component0Type = ComponentType.Prefix
      component1Type = ComponentType.CallSign
      return
      
    // U --> C
    case componentType0 == ComponentType.Unknown:
      component0Type = ComponentType.CallSign
      component1Type = componentType1
      return
      
    // U --> C
    case componentType1 == ComponentType.Unknown:
      component1Type = ComponentType.CallSign;
      component0Type = componentType0;
      return
      
    case true:
      break
    case false:
      break
    }
    
    component0Type = ComponentType.Unknown
    component1Type = ComponentType.Unknown
  }
  
  /*
     
           
   */
  
  /**
   one of "@","@@","#@","#@@" followed by 1-4 digits followed by 1-6 letters
   ValidPrefixes = ':@:@@:@@#:@@#@:@#:@#@:@##:#@:#@@:#@#:#@@#:';
   ValidStructures = ':C:C#:C#M:C#T:CM:CM#:CMM:CMP:CMT:CP:CPM:CT:PC:PCM:PCT:';
   */
  func getComponentType(candidate: String, position: Int) -> ComponentType {
    
    let validPrefixes = ["@", "@@", "@@#", "@@#@", "@#", "@#@", "@##", "#@", "#@@", "#@#", "#@@#"]
    let validPrefixOrCall = ["@@#@", "@#@"]
    var componentType = ComponentType.Unknown
    
    let pattern = buildPattern(candidate: candidate)
    
    let test = true
    switch test {
    case position == 1 && candidate == "MM":
      return ComponentType.Prefix
    case position == 1 && candidate.count == 1:
      return verifyIfPrefix(candidate: candidate, position: position)
    case isSuffix(candidate: candidate):
      return ComponentType.Portable
    case candidate.count == 1:
      if candidate.isInteger {
        return ComponentType.Numeric
      } else {
        return ComponentType.Text
      }
    case candidate.isAlphabetic:
      if candidate.count > 2 {
        return ComponentType.Text
      }
      if verifyIfPrefix(candidate: candidate, position: position) == ComponentType.Prefix
      {
        return ComponentType.Prefix;
      }
      return ComponentType.Text;
      
      // this first case is somewhat redundant
    case validPrefixOrCall.contains(pattern):
      if verifyIfPrefix(candidate: candidate, position: position) != ComponentType.Prefix
      {
        return ComponentType.CallSign;
      } else {
        if verifyIfCallSign(component: candidate) == ComponentType.CallSign {
          componentType = ComponentType.Unknown
        } else {
          componentType = ComponentType.Prefix
        }
      }
      return componentType
      
    case validPrefixes.contains(pattern) && verifyIfPrefix(candidate: candidate, position: position) == ComponentType.Prefix:
      return ComponentType.Prefix
      
    case verifyIfCallSign(component: candidate) == ComponentType.CallSign:
      return ComponentType.CallSign
      
    default:
      if candidate.isAlphabetic {
        return ComponentType.Text
      }
    }
    
    return ComponentType.Unknown
  }
  
  /**
   
   
   */
  
  
  
  /**
   one of "@","@@","#@","#@@" followed by 1-4 digits followed by 1-6 letters
   create pattern from call and see if it matches valid patterns
   */
  func verifyIfCallSign(component: String) -> ComponentType {
    
    let test = true
    var candidate = component
    let first = candidate[0]
    let second = candidate[1]
    var range = candidate.startIndex...candidate.index(candidate.startIndex, offsetBy: 1)
    
    switch test {
    case first.isLetter && second.isLetter: // "@@"
      candidate.removeSubrange(range)
    case first.isLetter: // "@"
      candidate.remove(at: candidate.startIndex)
    case String(first).isInteger && second.isLetter && candidate[2].isLetter: //"#@@"
      range = candidate.startIndex...candidate.index(candidate.startIndex, offsetBy: 2)
      candidate.removeSubrange(range)
    case String(first).isInteger && second.isLetter: // "#@"
      range = candidate.startIndex...candidate.index(candidate.startIndex, offsetBy: 1)
      candidate.removeSubrange(range)
    default:
      break
    }
    
    var digits = 0
    
    while String(candidate[0]).isInteger {
      digits += 1
      candidate.remove(at: candidate.startIndex)
      if candidate.count == 0 {
        return ComponentType.Invalid
      }
    }
    
    if digits > 0 && digits <= 4 {
      if candidate.count <= 6 {
        if candidate.rangeOfCharacter(from: CharacterSet.alphanumerics) != nil {
          return ComponentType.CallSign // needs checking
        }
      }
    }
    
    return ComponentType.Invalid
  }
  
  /**
   est if a candidate is truly a prefix.
   */
  func verifyIfPrefix(candidate: String, position: Int) -> ComponentType {
    
    let validprefixes = ["@", "@@", "@@#", "@@#@", "@#", "@#@", "@##", "#@", "#@@", "#@#", "#@@#"]
    
    let pattern = buildPattern(candidate: candidate)
    
    if candidate.count == 1 {
      switch position {
      case 1:
        if singleCharacterPrefixes.contains(candidate){
          return ComponentType.Prefix;
        }
        else {
          return ComponentType.Text
        }
      default:
        return ComponentType.Text
      }
    }
    
    if validprefixes.contains(pattern){
      if portablePrefixes[pattern + "/"] != nil {
        return ComponentType.Prefix
      }
    }
    
    return ComponentType.Text;
  }
  
  
  /**
   Build a pattern that models the string passed in.
   This is essentialy a duplicate of one in PrefixFileParser
   TODO: Reconcile the two
   */
  func buildPatternOld(candidate: String) -> String {

    var pattern = ""

    if candidate.allSatisfy({String($0).isInteger}){
      pattern += "#"
    } else if candidate.allSatisfy({!String($0).isInteger}){
      switch candidate[0] {
      case "/":
        pattern += "/"
      case ".":
        pattern += "."
      default:
        pattern += "@"
      }
    } else { // "?"
      pattern += "?"
    }
    
    if pattern.contains("?") {
      // # @  - only one (invalid prefix) has two ?  -- @# @@
      var tempPattern = pattern.replacingOccurrences(of: "?", with: "#")
      tempPattern = pattern.replacingOccurrences(of: "?", with: "@")
      return tempPattern
    }
    
    return pattern
  }
  
  /**
   Build the pattern from the mask
   KG4@@.
   [AKNW]H7K[./]
   AX9[ABD-KOPQS-VYZ][.ABD-KOPQS-VYZ] @@#@. and @@#@@.
   The [.A-KOPQS-VYZ] mask for the second letter of the suffix means that the call should either end there (no second letter) or be one of the listed letters.
   */
  func buildPattern(candidate: String)-> String {
    var pattern = ""
    
    for item in candidate {
      switch true {
        
      case String(item).isInteger:
        pattern += "#"
        
      case String(item).isAlphabetic:
        pattern += "@"
        
      case item == "/":
        pattern += "/"
        
      case item == ".":
        pattern += "."
      
      default:
        // should never default
        print("hit default - buildPattern")
      }
    }
      return pattern
  }

  
  /*
   */
  func isSuffix(candidate: String) -> Bool {
    let validSuffixes = ["A", "B", "M", "P", "MM", "AM", "QRP", "QRPP", "LH", "LGT", "ANT", "WAP", "AAW", "FJL"]
    
    if validSuffixes.contains(candidate){
      return true
    }
    
    return false
  }
  
  /**
   Should this string be considered as text.
   */
  func iSText(candidate: String) -> Bool {
    
    // /1J
    if candidate.count == 2 {
      return true
    }
    
    // /JOHN
    if candidate.isAlphabetic {
      return true
    }
    
    // /599
    if candidate.isNumeric {
      return true
    }
    
    if candidate.isAlphanumeric() {
      return false
    }
    
    return false
  }
  
  
  
  
  
} // end class

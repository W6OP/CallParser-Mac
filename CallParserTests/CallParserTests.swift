//
//  CallParserTests.swift
//  CallParserTests
//
//  Created by Peter Bourget on 8/31/20.
//  Copyright © 2020 Peter Bourget. All rights reserved.
//

import XCTest
import CallParser

class CallParserTests: XCTestCase {

    var callParser: PrefixFileParser!
    var callLookup: CallLookup!
    var  prefixData: PrefixData!
  
  override func setUp() {
    let callParser = PrefixFileParser()
    _ = CallLookup(prefixFileParser: callParser)
    prefixData = PrefixData()
  }
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testmaskExists() throws {
      
      let units = ["W", "6", "O", "P", "", "", ""]
      let length = 2
      
      
      
      //let found = prefixData.maskExists(units: units, length: length)
      //XCTAssert(found == true)
        
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}

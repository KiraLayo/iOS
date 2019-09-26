//
//  AlgorithmTests.swift
//  AlgorithmTests
//
//  Created by yp-tc-m-2548 on 2019/9/18.
//  Copyright © 2019年 com.KiraLayo. All rights reserved.
//

import XCTest
import Algorithm

class AlgorithmTests: XCTestCase {
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let nums = [4,2,3,1];
        
        Sort.bubbleSort3(nums: nums);
    }
    func testFor() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let nums = [3,2,1,3,1];
        
        var singleNum = 0;
        
        for num in nums {
            singleNum ^= num;
        }
        
        print(singleNum);
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}

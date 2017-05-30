//
//  PjsipTest.m
//  TouchPalDialer
//
//  Created by lingmeixie on 15/11/12.
//
//

#import <XCTest/XCTest.h>
#import "PJCore.h"


@interface PjsipTest : XCTestCase

@end

@implementation PjsipTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    [[PJCore instance] inviteCall:@"+8618621193170"];
    //(@"%d:%@",5,@"13:55:12.000       stream.c  ...fec free , repaired_pkts: 2\n");
   
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end

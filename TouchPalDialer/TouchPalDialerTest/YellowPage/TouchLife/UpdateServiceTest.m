//
//  UpdateServiceTest.m
//  TouchPalDialer
//
//  Created by tanglin on 15/9/10.
//
//

#import "UpdateServiceTest.h"
#import "UpdateService.h"

@implementation UpdateServiceTest
- (void)setUp
{
    [super setUp];
}
    
- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)test_getSelectedCity
{
    NSString * city1 = [[UpdateService instance] getSelectedCity:@""];
    STAssertTrue(city1, @"全国");
    
    NSString * city2 = [[UpdateService instance] getSelectedCity:@"上海"];
    STAssertTrue(city2, @"上海");
    
    NSString * city3 = [[UpdateService instance] getSelectedCity:@"shanghai"];
    STAssertTrue(city3, @"上海");
    
    NSString * city4 = [[UpdateService instance] getSelectedCity:@"临安"];
    STAssertTrue(city4, @"全国");
    
    
}

@end

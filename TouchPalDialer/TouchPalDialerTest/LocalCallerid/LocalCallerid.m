//
//  LocalCallerid.m
//  TouchPalDialer
//
//  Created by 袁超 on 15/9/10.
//
//

#import "LocalCallerid.h"
#import "QueryCallerid.h"
#import "PhoneConvertUtil.h"

@interface LocalCallerid() {
    NSArray *numberArray;
    NSArray *resultArray;
}

@end

@implementation LocalCallerid

- (void)setUp
{
    [super setUp];
    numberArray = [NSArray arrayWithObjects:@"10086", nil];
    resultArray = [NSArray arrayWithObjects:@"中国移动(10086热线)", nil];
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testQueryCallerid {
//    for (int i = 0; i < numberArray.count; i++) {
//        CallerIDInfoModel *model = [[QueryCallerid shareInstance] getLocalCallerid:numberArray[i]];
//        XCTAssertNotNil(model, @"callerid query is nil");
//        if (![model.name isEqualToString:resultArray[i]] || [model.callerType isEqualToString:resultArray[i]]) {
//            XCTAssertFalse(NO);
//        }
//    }
}

- (void)testInfoConvertToPhoneNumber {
    long long phoneLong = 861036789065L;
    NSString *realResult = @"+861053791111";
    NSString *result = [PhoneConvertUtil LongToNSString:phoneLong];
    XCTAssertTrue([realResult isEqualToString:result], @"convert result:%@ is not correct result:%@", result, realResult);
}

@end

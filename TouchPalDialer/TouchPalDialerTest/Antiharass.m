//
//  Antiharass.m
//  TouchPalDialer
//
//  Created by game3108 on 15/9/25.
//
//

#import <XCTest/XCTest.h>
#import "UserDefaultsManager.h"
#import "AntiharassDB.h"
#import "AntiharassUtil.h"
#import "FileUtils.h"
#import "AntiharassInfo.h"
#import "AntiharassAdressbookUtil.h"
#import "TPAddressBookWrapper.h"

@interface Antiharass : XCTestCase

@end

@implementation Antiharass

//- (void)setUp {
//    [super setUp];
//    // Put setup code here. This method is called before the invocation of each test method in the class.
//}
//
//- (void)tearDown {
//    // Put teardown code here. This method is called after the invocation of each test method in the class.
//    [super tearDown];
//}

//- (void)testExample {
//    // This is an example of a functional test case.
//    // Use XCTAssert and related functions to verify your tests produce the correct results.
//}
//
//- (void)testPerformanceExample {
//    // This is an example of a performance test case.
//    [self measureBlock:^{
//        // Put the code you want to measure the time of here.
//    }];
//}
//
//- (void)testAntiharassOn{
//    bool ifAntiharass = [UserDefaultsManager boolValueForKey:ANTIHARASS_IS_ON];
//    if ( !ifAntiharass )
//        return;
//    AntiharassType type = [UserDefaultsManager intValueForKey:ANTIHARASS_TYPE defaultValue:0];
//    NSString *dbName = [AntiharassUtil getDBName:type];
//    NSString *filePATH = [FileUtils getAbsoluteFilePath:dbName];
//    NSFileManager *fm= [NSFileManager defaultManager];
//    if (![fm fileExistsAtPath:filePATH])
//        return;
//    AntiharassDB *antiDB = [[AntiharassDB alloc]initWithDBFile:filePATH];
//    [antiDB connectDataBase];
//    
//    NSArray *dbArray = [antiDB queryAllAntiharassInfo];
//    
//    if ( [dbArray count] < 20 )
//        return;
//        
//    AntiharassInfo *info1 = [dbArray objectAtIndex:([dbArray count]/2)];
//    AntiharassInfo *info2 = [dbArray objectAtIndex:([dbArray count]/3)];
//    AntiharassInfo *info3 = [dbArray objectAtIndex:([dbArray count]/4)];
//    
//    NSString *info1Number = [self getNumber:info1.number];
//    NSString *info1Label = [self getTagNameFromTagIndex:info1.tag];
//    
//    NSString *info2Number = [self getNumber:info2.number];
//    NSString *info2Label = [self getTagNameFromTagIndex:info2.tag];
//    
//    NSString *info3Number = [self getNumber:info3.number];
//    NSString *info3Label = [self getTagNameFromTagIndex:info3.tag];
//    
//    bool info1Bool = NO;
//    bool info2Bool = NO;
//    bool info3Bool = NO;
//    
//    ABAddressBookRef addressBook =  [TPAddressBookWrapper RetrieveAddressBookRefForCurrentThread];
//    NSArray *array = (__bridge NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook);
//    for (id obj in array) {
//        ABRecordRef people = (__bridge ABRecordRef)obj;
//        if ( [AntiharassAdressbookUtil isTouchpalAntiharass:people] ){
//            ABMultiValueRef phones = ABRecordCopyValue(people, kABPersonPhoneProperty);
//            if (phones) {
//                int count = ABMultiValueGetCount(phones);
//                for (CFIndex i = 0; i < count; i++) {
//                    CFStringRef label = ABMultiValueCopyLabelAtIndex(phones, i);
//                    CFStringRef tmpString = ABAddressBookCopyLocalizedLabel(label);
//                    NSString *labelString = (__bridge NSString *)tmpString;
//                    
//                    CFStringRef tmpStringValue = ABMultiValueCopyValueAtIndex(phones, i);
//                    NSString *valueString = (__bridge NSString *)tmpStringValue;
//                    
//                    if ( [valueString isEqualToString:info1Number] && [labelString isEqualToString:info1Label] ){
//                        info1Bool = YES;
//                    }else if ( [valueString isEqualToString:info2Number] && [labelString isEqualToString:info2Label]  ){
//                        info2Bool = YES;
//                    }else if ( [valueString isEqualToString:info3Number] && [labelString isEqualToString:info3Label]  ){
//                        info3Bool = YES;
//                    }
//                }
//            }
//        }
//    }
//    
//    XCTAssertTrue(info1Bool,@"info1 not found!");
//    XCTAssertTrue(info2Bool,@"info2 not found!");
//    XCTAssertTrue(info3Bool,@"info3 not found!");
//}
//
//- (NSString *) getTagNameFromTagIndex:(NSInteger)tagIndex{
//    switch (tagIndex) {
//        case 1:
//            return @"触宝识别｜房产中介";
//        case 5:
//            return @"触宝识别｜业务推销";
//        case 10:
//            return @"触宝识别｜骚扰电话";
//        case 11:
//            return @"触宝识别｜诈骗钓鱼";
//        default:
//            return nil;
//    }
//}
//
//- (NSString *)getNumber:(NSString *)numberStr{
//    NSString *temptStr = numberStr;
//    if ( [numberStr hasPrefix:@"+"] ){
//        temptStr = [numberStr substringFromIndex:1];
//    }
//    return [NSString stringWithFormat:@"*%@;",temptStr];
//}


@end

//
//  UmMessageTest.m
//  TouchPalDialer
//
//  Created by 袁超 on 15/9/10.
//
//

#import "UmMessageTest.h"
#import "AutoTag.h"
#import "AutoTagMessage.h"

@implementation UmMessageTest


- (void)testMessageNeedAutoTag {
    NSString *content = @"打不出去";
    NSString *realTag = @"[VOIP]";
    NSString *tag = @"";
    AutoTag *autoTag = [[AutoTag alloc]init];
    NSMutableArray *array = [autoTag getAutoTagArray];
    for (AutoTagMessage *message in array) {
        for (NSString *keyword in message.keywordsArray) {
            if ([content rangeOfString:keyword].location != NSNotFound) {
                tag = [NSString stringWithFormat:@"[%@]", message.mark];
                break;
            }
        }
    }
    NSLog(@"test ummessage in class");
    XCTAssertTrue([realTag isEqualToString:tag]);
}

@end

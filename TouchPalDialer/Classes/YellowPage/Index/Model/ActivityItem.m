//
//  ActivityItem.m
//  TouchPalDialer
//
//  Created by tanglin on 15-5-11.
//
//

#import <Foundation/Foundation.h>
#import "ActivityItem.h"
#import "IndexFilter.h"

@implementation ActivityItem

- (id)initWithJson:(NSDictionary*)json
{
    self = [super init];
    self.count = [json objectForKey:@"count"];
    self.iconPicLink = [json objectForKey:@"iconPicLink"];
    self.iconZipLink = [json objectForKey:@"iconZipLink"];
    self.filter = [[IndexFilter alloc]initWithJson:[json objectForKey:@"filter"]];

    return self;
}

- (BOOL) isValid
{
    if (self.filter == nil || [self.filter isValid]) {
        return YES;
    }
    
    return NO;
}
@end

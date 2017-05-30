//
//  SectionSeparator.m
//  TouchPalDialer
//
//  Created by tanglin on 15-4-14.
//
//

#import <Foundation/Foundation.h>
#import "SectionSeparator.h"
#import "IndexFilter.h"

@implementation SectionSeparator

- (id) initWithJson: (NSDictionary*) json
{
    self = [super init];
    self.attrs = [json objectForKey:@"attrs"];
    self.filter = [[IndexFilter alloc]initWithJson:[json objectForKey:@"filter"]];

    return self;
}

@end
//
//  SectionTrack.m
//  TouchPalDialer
//
//  Created by tanglin on 15/10/26.
//
//

#import "SectionTrack.h"

@implementation SectionTrack

@synthesize filter;

-(id) initWithJson:(NSDictionary*) json
{
    self = [super init];
    self.items = [[NSMutableArray alloc]init];
    self.filter = [[IndexFilter alloc]initWithJson:[json objectForKey:@"filter"]];
    
    return self;
}

@end

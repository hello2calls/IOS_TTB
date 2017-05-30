//
//  NSStack.m
//  TouchPalDialer
//
//  Created by tanglin on 15/9/1.
//
//

#import "NSStack.h"

#import <Foundation/Foundation.h>

@interface NSStack()
{
    NSMutableArray* m_array;
}
@end


#import "NSStack.h"


@implementation NSStack
@synthesize count;

- (id)init
{
    if( self=[super init] )
    {
        m_array = [[NSMutableArray alloc] init];
        count = 0;
    }
    return self;
}

- (void)push:(id)anObject
{
    [m_array addObject:anObject];
    count = m_array.count;
}

- (id)pop
{
    id obj = nil;
    if(m_array.count > 0)
    {
        obj = [m_array lastObject];
        [m_array removeLastObject];
        count = m_array.count;
    }
    return obj;
}

- (id) top
{
    id obj = nil;
    if(m_array.count > 0)
    {
        obj = [m_array lastObject];
    }
    return obj;
}

- (void)clear
{
    [m_array removeAllObjects];
    count = 0;
}


@end

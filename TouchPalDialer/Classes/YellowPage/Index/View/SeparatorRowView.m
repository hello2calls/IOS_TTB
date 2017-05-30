//
//  SeparatorRowView.m
//  TouchPalDialer
//
//  Created by tanglin on 15-4-14.
//
//

#import <Foundation/Foundation.h>
#import "SeparatorRowView.h"
#import "SectionSeparator.h"
#import "IndexConstant.h"
#import "ImageUtils.h"

@implementation SeparatorRowView

- (id)initWithFrame:(CGRect)frame andData:(SectionSeparator *)data andIndexPath:(NSIndexPath*)indexPath
{
    self = [super initWithFrame:frame];
    self.backgroundColor = [ImageUtils colorFromHexString:SEPARATOR_BG_COLOR andDefaultColor:nil];
    [self setTag:SEPARATOR_TAG];
    
    return self;
}

@end
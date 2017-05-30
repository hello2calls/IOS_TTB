//
//  FooterRowView.m
//  TouchPalDialer
//
//  Created by tanglin on 15-4-2.
//
//

#import <Foundation/Foundation.h>
#import "FooterRowView.h"
#import "TPDialerResourceManager.h"
#import "SectionFooter.h"
#import "ImageUtils.h"
#import "IndexConstant.h"
#import "UIDataManager.h"

@interface FooterRowView()
{
    SectionFooter* sectionFooter;
    UILabel* footer;
}

@end
@implementation FooterRowView

- (id)initWithFrame:(CGRect)frame andData:(SectionFooter *)data
{
    self = [super initWithFrame:frame];
    footer = [[UILabel alloc] initWithFrame:self.bounds];
    footer.text = data.normal;
    footer.font = [UIFont fontWithName:@"Helvetica-Light" size:FOOTER_TEXT_SIZE];
    footer.textColor = [ImageUtils colorFromHexString:FOOTER_TEXT_COLOR andDefaultColor:nil];
    footer.textAlignment = NSTextAlignmentCenter;
    footer.backgroundColor = [ImageUtils colorFromHexString:SEPARATOR_BG_COLOR andDefaultColor:nil];
    [self addSubview:footer];
    sectionFooter = data;
    [self setTag:FOOTER_TAG];
    
    return self;
}

- (void) drawView
{
    if ([[UIDataManager instance] isCrazyScroll]) {
        footer.text = sectionFooter.crazy;
    } else {
        footer.text = sectionFooter.normal;
    }
    if (footer.text == nil || footer.text.length <= 0) {
        footer.text = sectionFooter.normal;
    }
}


@end
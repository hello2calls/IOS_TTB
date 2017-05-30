//
//  FooterRowView.h
//  TouchPalDialer
//
//  Created by tanglin on 15-4-2.
//
//

@class SectionFooter;
@interface FooterRowView : UILabel

- (id)initWithFrame:(CGRect)frame andData:(SectionFooter*)data;
- (void)drawView;

@end
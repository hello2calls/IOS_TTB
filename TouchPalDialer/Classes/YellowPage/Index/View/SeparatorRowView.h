//
//  SeparatorRowView.h
//  TouchPalDialer
//
//  Created by tanglin on 15-4-14.
//
//

#ifndef TouchPalDialer_SeparatorRowView_h
#define TouchPalDialer_SeparatorRowView_h
@class SectionSeparator;
@class IndexFilter;
@interface SeparatorRowView : UIView

- (id)initWithFrame:(CGRect)frame andData:(SectionSeparator *)data andIndexPath:(NSIndexPath*)indexPath;

@end

#endif

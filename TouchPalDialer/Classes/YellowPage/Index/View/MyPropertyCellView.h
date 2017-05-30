//
//  MyPropertyCellView.h
//  TouchPalDialer
//
//  Created by tanglin on 16/7/7.
//
//

#import "YPUIView.h"
#import "SectionMyProperty.h"
#import "CategoryItem.h"

@interface MyPropertyCellView : YPUIView

- (void) drawView;
- (void) resetWithMyProperty:(SectionMyProperty*)myProperty andRowIndex:(NSInteger)rowIdx andColumnIndex:(NSInteger)columnIdx;
- (id)initWithFrame:(CGRect)frame andContentType:(NSInteger) type;

@end

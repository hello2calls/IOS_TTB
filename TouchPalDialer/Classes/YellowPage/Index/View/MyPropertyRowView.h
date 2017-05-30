//
//  MyPropertyRowView.h
//  TouchPalDialer
//
//  Created by tanglin on 16/7/7.
//
//

#import "YPUIView.h"
#import "SectionMyProperty.h"

@interface MyPropertyRowView : YPUIView

- (id)initWithFrame:(CGRect)frame andData:(SectionMyProperty *)dataArray andIndex:(NSIndexPath*)path;
- (void) resetDataWithMyProperty:(SectionMyProperty*)item andIndexPath:(NSIndexPath*)indexPath;
@property (nonatomic, retain) NSMutableArray* cellViews;
@property (nonatomic, retain) SectionMyProperty* sectionMyProperty;
@property (nonatomic, retain) NSIndexPath* indexPath;

@end

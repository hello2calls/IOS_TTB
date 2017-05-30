//
//  BaseRowView.h
//  TouchPalDialer
//
//  Created by tanglin on 15-4-9.
//
//

#import "SectionGroup.h"

@interface BaseRowView : UIView
@property (nonatomic, retain) SectionGroup* itemData;

-(void) drawView;
-(void) updateData:(SectionGroup*)item;
-(UIView *) createViewItemWithFrame:(CGRect)frame;

@end
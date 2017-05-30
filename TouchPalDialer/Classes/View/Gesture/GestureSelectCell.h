//
//  GestureSelectCell.h
//  TouchPalDialer
//
//  Created by ThomasYe on 13/8/18.
//
//

#import <Foundation/Foundation.h>
#import "SelectCellView.h"

@interface GestureSelectCell : SelectCellView
- (void)refreshDefault:(ContactCacheDataModel *)person  withIsCheck:(BOOL)is_check isShowNumber:(BOOL)is_show;

@end

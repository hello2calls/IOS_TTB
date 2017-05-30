//
//  ShowList&MoveRight.h
//  TableViewMultiSelect
//
//  Created by Liangxiu on 8/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PushRightView : UIView

-(id)initWithButton:(UIButton *)actionButton
        movableView:(UIView *)movableView
          belowView:(UIView *)belowView
     remainingWidth:(CGFloat)remainingWidth;
- (void)restoreViewLocation;
- (void)moveToRight;
@end

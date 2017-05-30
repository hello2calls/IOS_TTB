//
//  TPHeaderButton.h
//  TouchPalDialer
//
//  Created by zhang Owen on 10/13/11.
//  Copyright 2011 Cootek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "consts.h"
#import "TPUIButton.h"



@interface TPHeaderButton : TPUIButton {

}
@property (nonatomic,assign) BOOL ifHighlight;
- (id)initWithFrame:(CGRect)frame;
- (id)initLeftBtnWithFrame:(CGRect)frame;
- (id)initRightBtnWithFrame:(CGRect)frame;
- (void)showBtn;
- (void)hideBtn;
@end

//
//  BlockUserView.h
//  TouchPalDialer
//
//  Created by Alice on 11-12-20.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol blockViewDelegate
@optional
-(void)onCancelBlock;
@end


@interface BlockUserView : UIAlertView<UIAlertViewDelegate> {
	UIAlertView *m_alert;
	BOOL is_cancel_click;
	id <blockViewDelegate> __unsafe_unretained delegate;
}
@property(nonatomic,retain)UIAlertView *m_alert;
@property(nonatomic,assign)BOOL is_cancel_click;
@property(nonatomic,assign)id   <blockViewDelegate> delegate;
- (id)initWithMessage:(CGRect)frame withMessage:(NSString *)msg;
- (id)initWithMessage:(CGRect)frame withLongMessage:(NSString *)msg;
- (void)alertDismiss;
@end

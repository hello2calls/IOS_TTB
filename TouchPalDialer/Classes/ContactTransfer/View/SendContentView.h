//
//  SendContentView.h
//  TouchPalDialer
//
//  Created by siyi on 16/3/21.
//
//

#ifndef SendContentView_h
#define SendContentView_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol SendContentViewDelegate <NSObject>
- (void) onClickSendStatusCircle;  // cancel sending or resending
@end

@interface SendContentView : UIView
- (instancetype) initWithFrame:(CGRect)frame status:(NSInteger)currentStatus;
- (void) startRingAnimation;
- (void) stopRingAnimation;

@property (nonatomic, assign) NSInteger status;
@property (nonatomic) id<SendContentViewDelegate> delegate;

@end

#endif /* SendContentView_h */

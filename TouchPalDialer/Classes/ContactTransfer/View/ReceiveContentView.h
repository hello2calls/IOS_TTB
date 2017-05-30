//
//  ReceiveContentView.h
//  TouchPalDialer
//
//  Created by siyi on 16/3/21.
//
//

#ifndef ReceiveContentView_h
#define ReceiveContentView_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol ReceiveContentViewDelegate <NSObject>
- (void) onClickContainer;
@end

@interface ReceiveContentView : UIView
- (instancetype) initWithFrame:(CGRect)frame status:(NSInteger)status;
- (instancetype) initWithFrame:(CGRect)frame;

- (void) startRingAnimation;
- (void) stopRingAnimation;

@property (nonatomic, assign) NSInteger status;
@property (nonatomic) id<ReceiveContentViewDelegate> delegate;

@end

#endif /* ReceiveContentView_h */

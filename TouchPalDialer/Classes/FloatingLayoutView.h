//
//  FloatingButtonView.h
//  TouchPalDialer
//
//  Created by Tengchuan Wang on 16/1/19.
//
//

#ifndef FloatingButtonView_h
#define FloatingButtonView_h
#import "YPUIView.h"
#import "CTUrl.h"

@protocol GameMenusDelegate <NSObject>

@optional
- (void)exitGame;


@end

@interface FloatingLayoutView : YPUIView <UIGestureRecognizerDelegate>
- (id) initWithCTUrl:(CTUrl*)ctUrl;
- (void) drawRect:(CGRect)rect;
- (void) resetCoordinate;
@property(nonatomic, retain) id<GameMenusDelegate> gameDelegate;

@end

#endif /* FloatingButton_h */

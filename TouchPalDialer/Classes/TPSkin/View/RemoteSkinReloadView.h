//
//  RemoteSkinReloadView.h
//  TouchPalDialer
//
//  Created by Leon Lu on 13-5-20.
//
//

#import <UIKit/UIKit.h>

@class RemoteSkinReloadView;

@protocol RemoteSkinReloadViewDelegate <NSObject>
- (void)remoteSkinReloadViewClicked:(RemoteSkinReloadView *)view;
@end

@interface RemoteSkinReloadView : UIView
@property (nonatomic, assign) id<RemoteSkinReloadViewDelegate> delegate;
@end

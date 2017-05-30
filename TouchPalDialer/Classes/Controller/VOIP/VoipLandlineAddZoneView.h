//
//  VoipLandlineAddZoneView.h
//  TouchPalDialer
//
//  Created by game3108 on 15/3/9.
//
//

#import <UIKit/UIKit.h>

@protocol VoipLandlineAddZoneViewDelegate <NSObject>
- (void)sureButtonAction:(NSString *)number;
- (void)cancelButtonAction;
@end


@interface VoipLandlineAddZoneView : UIView
@property (nonatomic,assign) id<VoipLandlineAddZoneViewDelegate> delegate;
- (instancetype)initWithFrame:(CGRect)frame andNumber:(NSString *)number;
@end

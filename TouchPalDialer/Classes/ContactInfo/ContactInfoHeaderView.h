//
//  ContactInfoHeaderView.h
//  TouchPalDialer
//
//  Created by game3108 on 15/7/24.
//
//

#import <UIKit/UIKit.h>
#import "ContactInfoModel.h"

@protocol ContactInfoHeaderViewDelegate <NSObject>
- (void)onLeftButtonAction;
- (void)onRightButtonAction;
@end

@interface ContactInfoHeaderView : UIView
@property (nonatomic, assign) id<ContactInfoHeaderViewDelegate> delegate;
- (instancetype)initWithFrame:(CGRect)frame andInfoModel:(ContactInfoModel *)infoModel;
- (void)refreshHeaderView:(ContactInfoModel *)infoModel;
@end

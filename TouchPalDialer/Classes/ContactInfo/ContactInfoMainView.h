//
//  ContactInfoMainView.h
//  TouchPalDialer
//
//  Created by game3108 on 15/7/16.
//
//

#import <UIKit/UIKit.h>
#import "ContactInfoModel.h"

@protocol ContactInfoMainViewDelegate <NSObject>
- (void)onIconButtonAction;
- (void)onButtonPressed:(NSInteger)tag;
@end

@interface ContactInfoMainView : UIView
@property (nonatomic,assign) id<ContactInfoMainViewDelegate> delegate;
@property (nonatomic) ContactInfoModel *infoModel;

- (instancetype)initWithFrame:(CGRect)frame infoModel:(ContactInfoModel *)infoModel;
- (void)refreshView:(ContactInfoModel *)infoModel;
- (void)refreshButtonView:(ContactInfoModel *)infoModel;
- (void)doViewShrunk;
@end

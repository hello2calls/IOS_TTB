//
//  ContactInfoMainButtonView.h
//  TouchPalDialer
//
//  Created by game3108 on 15/7/20.
//
//

#import <UIKit/UIKit.h>
#import "ContactInfoButtonModel.h"

@protocol ContactInfoButtonViewDelegate <NSObject>
- (void)onButtonPressed:(NSInteger)tag;
@end

@interface ContactInfoButtonView : UIView
@property (nonatomic,assign) id<ContactInfoButtonViewDelegate> delegate;
- (instancetype)initWithFrame:(CGRect)frame andInfoModel:(ContactInfoModel *)infoModel;
- (void)refreshButtonView:(ContactInfoModel *)infoModel;
@end

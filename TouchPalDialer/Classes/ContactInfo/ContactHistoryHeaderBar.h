//
//  ContactHistoryHeaderBar.h
//  TouchPalDialer
//
//  Created by game3108 on 15/7/23.
//
//

#import <UIKit/UIKit.h>
#import "ContactInfoModel.h"

@protocol ContactHistoryHeaderBarDelegate <NSObject>
- (void) headerLeftButtonAction:(ContactHeaderMode)mode;
- (void) headerRightButtonAction:(ContactHeaderMode)mode;
@end

@interface ContactHistoryHeaderBar : UIView
@property (nonatomic, assign) id<ContactHistoryHeaderBarDelegate> delegate;
- (instancetype)initWithFrame:(CGRect)frame andModel:(ContactInfoModel *)infoModel;
- (void)refreshHeaderMode:(ContactHeaderMode)mode;
@end

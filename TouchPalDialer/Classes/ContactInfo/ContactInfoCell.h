//
//  ContactInfoCell.h
//  TouchPalDialer
//
//  Created by game3108 on 15/7/22.
//
//

#import <UIKit/UIKit.h>
#import "ContactInfoCellModel.h"

@protocol ContactInfoCellProtocol <NSObject>
- (void)onCellRightButtonPressed:(ContactInfoCellModel *)model;
@end

@interface ContactInfoCell : UITableViewCell
@property (nonatomic,assign) id<ContactInfoCellProtocol> delegate;
- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier
         ContactInfoCellModel:(ContactInfoCellModel *)model
                     personId:(NSInteger)personId;
- (void)refreshView:(ContactInfoCellModel *)model;
- (void)showBottomLine;
- (void)hideBottomLine;
@end

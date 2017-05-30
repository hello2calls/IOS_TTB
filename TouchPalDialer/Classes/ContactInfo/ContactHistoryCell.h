//
//  ContactHistoryCell.h
//  TouchPalDialer
//
//  Created by game3108 on 15/7/23.
//
//

#import <UIKit/UIKit.h>
#import "CallLogDataModel.h"

@interface ContactHistoryCell : UITableViewCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier
                 callLogModel:(CallLogDataModel *)model;
- (void) refreshView:(CallLogDataModel *)model;
- (void)showBottomLine;
- (void)hideBottomLine;
@end

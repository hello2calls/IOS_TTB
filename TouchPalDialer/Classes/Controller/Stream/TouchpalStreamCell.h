//
//  TouchpalStreamCell.h
//  TouchPalDialer
//
//  Created by game3108 on 15/1/26.
//
//

#import <UIKit/UIKit.h>
#import "C2CHistoryInfo.h"

@interface TouchpalStreamCell : UITableViewCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier info:(C2CHistoryInfo *)info;
- (void)setData:(C2CHistoryInfo *)info;
@end

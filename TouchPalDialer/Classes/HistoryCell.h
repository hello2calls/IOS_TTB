//
//  HistoryCell.h
//  TouchPalDialer
//
//  Created by by.huang on 2017/7/9.
//
//

#import <UIKit/UIKit.h>

@interface HistoryCell : UITableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

+(NSString *)identify;

@end

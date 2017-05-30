//
//  ContactSpecialCell.h
//  TouchPalDialer
//
//  Created by game3108 on 15/4/21.
//
//

#import <UIKit/UIKit.h>
#import "ContactSpecialInfo.h"

#define MAIN_SUB_DIFF (6)

@protocol ContactSpecialCellDelegate
- (void)onButtonPressed: (SpecialNodeType)type;
@end

@interface ContactSpecialCell : UITableViewCell
@property (nonatomic,assign) id<ContactSpecialCellDelegate> delegate;
-(instancetype)initWithStyle:(UITableViewCellStyle)style
             reuseIdentifier:(NSString *)reuseIdentifier
                    delegate:(id<ContactSpecialCellDelegate>)delegate
          contactSpecialInfo:(ContactSpecialInfo *)info;
-(void)setData:(ContactSpecialInfo *)info;
- (void) showBottomLine;
- (void) hideBottomLine;
@end

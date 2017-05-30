//
//  VoipFriendViewCell.h
//  TouchPalDialer
//
//  Created by game3108 on 14-11-11.
//
//

#import <UIKit/UIKit.h>

@interface VoipFriendViewCell : UITableViewCell
- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
           personId:(NSInteger)personId
               size:(CGSize)size
              image:(UIImage*)image;

- (void)setData:(NSInteger)personID;
@end
    
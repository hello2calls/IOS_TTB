//
//  UserStreamViewController.h
//  TouchPalDialer
//
//  Created by game3108 on 15/1/26.
//
//

#import <UIKit/UIKit.h>

@interface UserStreamViewController : UIViewController
@property (nonatomic ,assign) NSInteger bonusType;
- (id)initWithBonusType:(NSInteger)bonusType andHeaderTitle:(NSString*)headerTitle bgColor:(UIColor*)color;
@end

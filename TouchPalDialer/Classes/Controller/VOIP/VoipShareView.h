//
//  VoipShareView.h
//  TouchPalDialer
//
//  Created by game3108 on 14-11-6.
//
//

#import <UIKit/UIKit.h>

@interface VoipShareView : UIView
@property (nonatomic, retain) NSString *fromWhere;
@property (nonatomic, retain) NSString *msgPhone;
- (id)initWithFrame:(CGRect)frame title:(NSString*)title msg:(NSString*)msg url:(NSString*)url;
- (void)setHeadTitle:(NSString*)headTitle;
@end

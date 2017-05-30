//
//  AskLikeShareView.h
//  TouchPalDialer
//
//  Created by game3108 on 16/3/9.
//
//

#import <UIKit/UIKit.h>



@interface AskLikeShareView : UIView
@property (nonatomic, copy) void (^clickBlock)();
- (instancetype) initWithFrame:(CGRect)frame andDictionary:(NSDictionary *)dict;
@end

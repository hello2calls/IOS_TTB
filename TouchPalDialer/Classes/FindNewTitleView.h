//
//  FindNewTitleView.h
//  TouchPalDialer
//
//  Created by tanglin on 15/12/31.
//
//

#import <UIKit/UIKit.h>

@interface FindNewTitleView : UIView

@property(nonatomic, strong)NSString* title;
@property(nonatomic, assign)BOOL isClicked;

+(CGFloat) getOneLineHeightByTitle:(NSString *)title withWidth:(CGFloat) width;
+(CGFloat) getHeightByTitle:(NSString *)title withWidth:(CGFloat) width;
+(CGFloat) getHeightByTitle:(NSString *)title withWidth:(CGFloat) width withLines:(NSInteger) lines;
@end

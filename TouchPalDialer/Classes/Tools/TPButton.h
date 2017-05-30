//
//  TPButton.h
//  TouchPalDialer
//
//  Created by 袁超 on 15/5/14.
//
//

#import <UIKit/UIKit.h>

typedef enum {
    GRAY_LINE,
    BLUE_LINE,
    GREEN_SOLID,
    BLUE_SOLID,
    ORANGE_SOLID,
    
} ButtonType;

@interface TPButton : UIButton

- (instancetype)initWithFrame:(CGRect)frame withType:(ButtonType)type withFirstLineText:(NSString*)firstText withSecondLineText:(NSString*)secondText;
- (void) setFirstLineText:(NSString*)text;
- (void) setSecondLineText:(NSString*)text;
- (void) setSkin;

@end

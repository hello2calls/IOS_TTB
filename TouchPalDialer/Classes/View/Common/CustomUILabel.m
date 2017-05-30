//
//  CustomUILabel.m
//  TouchPalDialer
//
//  Created by Liangxiu on 15/2/12.
//
//

#import "CustomUILabel.h"

@interface CustomUILabel ()
@property (nonatomic, retain)UIColor *originalColor;
@end

@implementation CustomUILabel

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    self.originalColor = nil;
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    self.highlighted = YES;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    self.highlighted = NO;
    if (_pressBlock) {
        _pressBlock();
    }
}

- (void)setUserInteractionEnabled:(BOOL)userInteractionEnabled {
    [super setUserInteractionEnabled:userInteractionEnabled];
    if (_originalColor == nil) {
        self.originalColor = self.textColor;
    }
    if (userInteractionEnabled) {
        self.textColor = _originalColor;
    } else {
        self.textColor = _disableColor;
    }
}
@end

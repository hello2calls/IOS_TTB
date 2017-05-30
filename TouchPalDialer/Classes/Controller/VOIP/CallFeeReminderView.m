//
//  CallFeeReminderView.m
//  TouchPalDialer
//
//  Created by Liangxiu on 14/12/4.
//
//

#import "CallFeeReminderView.h"
#import "TPDialerResourceManager.h"
#import "VoipConsts.h"

@implementation CallFeeReminderView {
    UILabel *_label;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        imageView.image = [TPDialerResourceManager getImage:@"call_fee_remind@2x.png"];
        [self addSubview:imageView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height - 30*WIDTH_ADAPT)];
        label.text = NSLocalizedString(@"call_fee_remind", @"");
        label.font = [UIFont systemFontOfSize:17*WIDTH_ADAPT];
        label.backgroundColor = [UIColor clearColor];
        label.numberOfLines = 3;
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor blackColor];
        [self addSubview:label];
        _label = label;
    }
    return self;
}

- (void)setText:(NSString *)text andSize:(UIFont *)size {
    [_label setText:text];
    _label.font = size;
}

- (UILabel*)getLabel{
    return _label;
}

- (void)dealloc {

}
@end

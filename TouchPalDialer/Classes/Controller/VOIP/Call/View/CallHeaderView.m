//
//  CallHeaderDisplay.m
//  TouchPalDialer
//
//  Created by Liangxiu on 15/4/16.
//
//

#import "CallHeaderView.h"
#import "UserDefaultsManager.h"

@interface DisplayMode : NSObject
@property (nonatomic, strong)NSString *text;
@property (nonatomic, assign)BOOL highLight;
- (id)initWithText:(NSString *)text andHigh:(BOOL)hightLight;
@end

@implementation DisplayMode
- (id)initWithText:(NSString *)text andHigh:(BOOL)hightLight {
    self = [super init];
    if (self) {
        self.text = text;
        self.highLight = hightLight;
    }
    return self;
}
@end


@implementation CallHeaderView {
    UILabel *_label1;
    UILabel *_label2;
    NSMutableArray *_contents;
    char _currentIndex;
    CGRect _baseFrame;
    CGRect _displayArea;
    UIColor *_highColor;
}
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _displayArea = frame;
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor blackColor];
        self.alpha = 0.5;
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(16, TPHeaderBarHeightDiff(), frame.size.width - 2* 16, frame.size.height-TPHeaderBarHeightDiff())];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        [self addSubview:label];
        _label1 = label;
        _baseFrame = label.frame;
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(16, frame.size.height, _label1.frame.size.width, _label1.frame.size.height)];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        [self addSubview:label];
        _label2 = label;
    
        self.hidden = YES;
        _contents = [NSMutableArray arrayWithCapacity:3];
        _currentIndex = 0;
        _highColor = [UIColor redColor];
    }
    return self;
}

- (void)displayNext {
    if (_hiddenHeaderView) {
        return;
    }
    if (_contents.count == 0) {
        return;
    }
    self.hidden = NO;
    _currentIndex--;
    if (_currentIndex == -1) {
        _currentIndex = _contents.count - 1;
    }
    
    if (_contents.count > 1) {
        [self animateDisplay];
    } else {
        DisplayMode *mode = _contents[_currentIndex];
        _label1.text = mode.text;
        if (mode.highLight) {
            _label1.textColor = _highColor;
        }
    }
}

- (void)animateDisplay{
    DisplayMode *mode = _contents[_currentIndex];
    _label2.text = mode.text;
    if (mode.highLight) {
        _label2.textColor = _highColor;
    }
    [UIView animateWithDuration:1 animations:^{
        _label1.frame = CGRectMake(_baseFrame.origin.x, -_baseFrame.size.height, _baseFrame.size.width, _baseFrame.size.height);
        _label2.frame = _baseFrame;
    } completion:^(BOOL finished) {
        if (finished) {
            _label1.frame = _baseFrame;
            _label1.text = _label2.text;
            cootek_log(@"label1 text: %@", _label1.text);
            _label1.textColor = _label2.textColor;
            _label2.frame = CGRectMake(_baseFrame.origin.x, _displayArea.size.height ,_baseFrame.size.width, _baseFrame.size.height);
            _label2.textColor = [UIColor whiteColor];
        }
    }];
}

- (void)showFreeGoingOut {
    [_contents addObject:[[DisplayMode alloc] initWithText:@"当前剩余免费时长已不足五分钟" andHigh:YES]];
}

- (void)chekToShowNumberHideWarning {
    if ( [UserDefaultsManager intValueForKey:VOIP_REGISTER_TIME defaultValue:0] >= 4 ) {
        [_contents addObject:[[DisplayMode alloc] initWithText:@"对方非触宝用户，本次可能不显号" andHigh:NO]];
    }
}

- (void)showNeedCellularData {
     [_contents addObject:[[DisplayMode alloc] initWithText:@"正在使用数据网络，每分钟约300KB" andHigh:NO]];
}

- (void)showRoamingFee {
    [_contents addObject:[[DisplayMode alloc] initWithText:@"运营商可能会收取接听或漫游费用" andHigh:NO]];
}

- (void)showNetworkNotStable {
    [_contents addObject:[[DisplayMode alloc] initWithText:@"当前网络不稳定，通话可能有杂音" andHigh:YES]];
}

- (void)hide {
    self.hidden = YES;
}

- (void)setHiddenHeaderView:(BOOL)hiddenHeaderView
{
    _hiddenHeaderView = hiddenHeaderView;
    if (hiddenHeaderView == YES) {
        [self hide];
    }
}

- (void)dealloc {

}

- (void)clearDisplay {
    [_contents removeAllObjects];
}

@end

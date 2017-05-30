//
//  FlowTopSectionView.m
//  TouchPalDialer
//
//  Created by game3108 on 15/1/28.
//
//

#import "WaveTopSectionView.h"
#import "FlowWaterWaveView.h"
#import "TPDialerResourceManager.h"
#define VOIP_BREATHING_OUTTER_CIRCLE_RADIUS 186

#define WIDTH_ADAPT TPScreenWidth()/375


@implementation WaveTopSectionView{
    UIView *_middleView;
    UILabel *_titleLabel;
    
    FlowWaterWaveView *wave1;
    FlowWaterWaveView *wave2;
    
    UILabel *flowLabel;
    
    NSTimer *timer;
    float number;
    BOOL _ifWave;
    NSInteger _waveNumber;
    NSInteger _maxValue;
    NSInteger _unitType;
    NSString *_unit;
    
    BOOL ifInAnimation;
}
- (id) initWithFrame:(CGRect)frame andBgColor:(UIColor*)bgColor andIfWave:(BOOL)ifWave andUnitType:(NSInteger)unitType{
    self = [super initWithFrame:frame];
    
    if (self){
        
        self.backgroundColor = bgColor;
        NSInteger middleViewRadius = VOIP_BREATHING_OUTTER_CIRCLE_RADIUS*WIDTH_ADAPT;
        
        _ifWave = ifWave;
        _maxValue = 0;
        _unitType = unitType;
        if (_unitType == 0) {
            _unit = @"分钟";
        } else {
            _unit = @"MB";
        }
        
        _middleView = [[UIView alloc]initWithFrame:CGRectMake((frame.size.width - middleViewRadius)/2, (frame.size.height - middleViewRadius + TPHeaderBarHeight())/2, middleViewRadius , middleViewRadius)];
        _middleView.layer.masksToBounds = YES;
        _middleView.layer.cornerRadius = middleViewRadius/2.0f;
        _middleView.layer.borderWidth = 4.0f;
        _middleView.layer.borderColor = [UIColor whiteColor].CGColor;
        [self addSubview:_middleView];
        
        if ( ifWave ){
            number = 0;
            
            _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 60*WIDTH_ADAPT, _middleView.frame.size.width, FONT_SIZE_1_5*WIDTH_ADAPT)];
            _titleLabel.text = @"流量余额";
            _titleLabel.textColor = [UIColor whiteColor];
            _titleLabel.textAlignment = NSTextAlignmentCenter;
            _titleLabel.font = [UIFont systemFontOfSize:FONT_SIZE_1_5*WIDTH_ADAPT];
            _titleLabel.backgroundColor = [UIColor clearColor];
            [_middleView addSubview:_titleLabel];
            
            flowLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, _middleView.frame.size.height - 100*WIDTH_ADAPT, _middleView.frame.size.width,FONT_SIZE_0*WIDTH_ADAPT)];
            flowLabel.textColor = [UIColor whiteColor];
            flowLabel.textAlignment = NSTextAlignmentCenter;
            flowLabel.font = [UIFont systemFontOfSize:FONT_SIZE_0*WIDTH_ADAPT];
            flowLabel.backgroundColor = [UIColor clearColor];
            [_middleView addSubview:flowLabel];
            
            wave1 = [[FlowWaterWaveView alloc]initWithFrame:CGRectMake(0, 0, _middleView.frame.size.width, _middleView.frame.size.height) andColor:[TPDialerResourceManager getColorForStyle:@"flow_wavewater_color"] andY:0 andA:1.0 andB:0];
            [_middleView addSubview:wave1];
            
            wave2 = [[FlowWaterWaveView alloc]initWithFrame:CGRectMake(0, 0, _middleView.frame.size.width, _middleView.frame.size.height) andColor:[TPDialerResourceManager getColorForStyle:@"flow_wavewater_color"] andY:0 andA:2.5 andB:(M_PI*M_PI/4)];
            [_middleView addSubview:wave2];
        }
    }
    
    return self;
}

- (UIView*) getMiddleView{
    return _middleView;
}

- (void)setTitle:(NSString *)title {
    _titleLabel.text = title;
}

- (void)setMaxValue:(NSInteger)maxValue {
    _maxValue = maxValue;
}

- (void)setDescription:(NSString *)description {
    
}

- (void) startWave:(NSInteger)currentValue{
    if ( _ifWave && !ifInAnimation && currentValue!= 0){
        number = 0;
        ifInAnimation = YES;
        wave1.currentLinePointY = 0;
        wave2.currentLinePointY = 0;
        flowLabel.text = [NSString stringWithFormat:@"0%@", _unit];
        _waveNumber = currentValue;
        [wave1 addTimer];
        [wave2 addTimer];
        timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(waveUp) userInfo:nil repeats:YES];
    } else if (currentValue == 0){
        _waveNumber = currentValue;
        flowLabel.text = [NSString stringWithFormat:@"%d%@",(int)_waveNumber, _unit];
    }
}


- (void)waveUp{
    float flowNumber = _waveNumber > _maxValue ? _maxValue : _waveNumber;
    float flowHeight = (_middleView.frame.size.height + 10)*flowNumber/_maxValue;
    if ( wave1.currentLinePointY < flowHeight || wave2.currentLinePointY < flowHeight){
        wave1.currentLinePointY += 1;
        wave2.currentLinePointY += 1;
        number += _waveNumber / flowHeight;
        flowLabel.text = [NSString stringWithFormat:@"%d%@",(int)number , _unit];
    }else{
        flowLabel.text = [NSString stringWithFormat:@"%d%@",(int)_waveNumber, _unit];
        [timer invalidate];
        double delayInSeconds = 3.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^{
            [wave1 removeTimer];
            [wave2 removeTimer];
            ifInAnimation = NO;
        });
        
    }
}

- (void)waveDown {
    float flowNumber = _waveNumber > _maxValue ? _maxValue : _waveNumber;
    float flowHeight = (_middleView.frame.size.height + 10)*flowNumber/_maxValue;
    if ( wave1.currentLinePointY > flowHeight || wave2.currentLinePointY > flowHeight){
        wave1.currentLinePointY -= 1;
        wave2.currentLinePointY -= 1;
        number -= _waveNumber / flowHeight;
        flowLabel.text = [NSString stringWithFormat:@"%d%@",(int)number , _unit];
    }else{
        flowLabel.text = [NSString stringWithFormat:@"%d%@",(int)_waveNumber, _unit];
        [timer invalidate];
        double delayInSeconds = 3.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^{
            [wave1 removeTimer];
            [wave2 removeTimer];
            ifInAnimation = NO;
        });
        
    }
}

- (void)adjustWave:(NSInteger)currentValue {
    if ( _ifWave && !ifInAnimation && currentValue!= _waveNumber){
        number = _waveNumber;
        ifInAnimation = YES;
        flowLabel.text = [NSString stringWithFormat:@"%d%@", _waveNumber,_unit];
        _waveNumber = currentValue;
        [wave1 addTimer];
        [wave2 addTimer];
        SEL selector;
        if (number > currentValue) {
            selector = @selector(waveDown);
        } else {
            selector = @selector(waveUp);
        }
        timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:selector userInfo:nil repeats:YES];
    } else if(ifInAnimation && currentValue!= _waveNumber) {
        [timer invalidate];
        _waveNumber = currentValue;
        SEL selector;
        if (number > currentValue) {
            selector = @selector(waveDown);
        } else {
            selector = @selector(waveUp);
        }
        timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:selector userInfo:nil repeats:YES];
    }
}

@end

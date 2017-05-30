//
//  AntiharassFirstStartView.m
//  TouchPalDialer
//
//  Created by game3108 on 15/9/16.
//
//

#import "AntiharassFirstStartView.h"
#import "TimerTickerManager.h"

@interface AntiharassFirstStartView()<TimerTickerDelegate>{
    TPButton *sureButton;
}

@end

@implementation AntiharassFirstStartView
- (instancetype)init{
    self = [super init];
    if ( self ){
        
        CGFloat middleViewHeight = 301;
        
        UIView *middleView = [[UIView alloc]initWithFrame:CGRectMake((TPScreenWidth()-280)/2, (TPScreenHeight()-middleViewHeight)/2, 280, middleViewHeight)];
        middleView.backgroundColor = [UIColor whiteColor];
        middleView.layer.masksToBounds = YES;
        middleView.layer.cornerRadius = 4.0f;
        [self addSubview:middleView];
        
        CGFloat globalY = 20;
        
        NSString *labelStr1 = NSLocalizedString(@"Since iOS functional limitations: We will of some high-frequency harassing phone calls to contacts stored in your address book", @"");
        NSMutableAttributedString *attributedString1 = [[NSMutableAttributedString alloc] initWithString:labelStr1];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineSpacing:6];
        [attributedString1 addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [labelStr1 length])];
        
        UILabel *firstLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, globalY, middleView.frame.size.width - 40 , 90)];
        firstLabel.attributedText = attributedString1;
        firstLabel.backgroundColor = [UIColor clearColor];
        firstLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:15];
        firstLabel.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_600"];
        firstLabel.numberOfLines = 4.0f;
        [middleView addSubview:firstLabel];
        
        globalY += firstLabel.frame.size.height + 5;
        NSString *labelStr2 = NSLocalizedString(@"Harassment number of the bank are based on your home ground intelligence generated, it is recommended that you regularly updated to ensure the recognition results", @"");;
        NSMutableAttributedString *attributedString2 = [[NSMutableAttributedString alloc] initWithString:labelStr2];
        [paragraphStyle setLineSpacing:6];
        [attributedString2 addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [labelStr2 length])];
        
        UILabel *firstLabel2 = [[UILabel alloc]initWithFrame:CGRectMake(20, globalY, middleView.frame.size.width - 40 , 90)];
        firstLabel2.attributedText = attributedString2;
        firstLabel2.backgroundColor = [UIColor clearColor];
        firstLabel2.font = [UIFont fontWithName:@"Helvetica-Light" size:15];
        firstLabel2.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_600"];
        firstLabel2.numberOfLines = 4.0f;
        [middleView addSubview:firstLabel2];
        
        globalY += firstLabel2.frame.size.height + 30;
        
        TPButton *cancelButton = [[TPButton alloc]initWithFrame:CGRectMake(20, globalY, 110, 46) withType:GRAY_LINE withFirstLineText:@"取消" withSecondLineText:nil];
        [cancelButton addTarget:self action:@selector(onCancelButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [middleView addSubview:cancelButton];
        
        sureButton = [[TPButton alloc]initWithFrame:CGRectMake(150, globalY, 110, 46) withType:BLUE_LINE withFirstLineText:@"继续(3)" withSecondLineText:nil];
        sureButton.enabled = NO;
        [sureButton setSkin];
        [sureButton addTarget:self action:@selector(onSureButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [middleView addSubview:sureButton];
        
        [TimerTickerManager startTimerTickerDown:self withTotalTicker:3];
    }
    return self;
}

- (void)onCancelButtonPressed{
    [DialerUsageRecord recordpath:PATH_ANTIHARASS kvs:Pair(ANTIHARASS_FIRST_START_CANCEL, @(1)), nil];
    [self.delegate clickCancelButton];
}

- (void)onSureButtonPressed{
    [DialerUsageRecord recordpath:PATH_ANTIHARASS kvs:Pair(ANTIHARASS_FIRST_START_OK, @(1)), nil];
    [self.delegate clickSureButton];
}

-(void) onTimerStop{
    [sureButton setFirstLineText:@"继续"];
    sureButton.enabled = YES;
    [sureButton setSkin];
}

-(void) onTimerTicker:(NSInteger) ticker{
    [sureButton setFirstLineText:[NSString stringWithFormat:@"继续(%d)",ticker]];
}

-(void)dealloc{
    [TimerTickerManager removeDelegate:self];
}

@end

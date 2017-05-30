//
//  AntiharassGuideView.m
//  TouchPalDialer
//
//  Created by game3108 on 15/9/17.
//
//

#import "AntiharassGuideView.h"

@implementation AntiharassGuideView

- (instancetype)init{
    self = [super init];
    if ( self ){
        UIView *middleView = [[UIView alloc]initWithFrame:CGRectMake((TPScreenWidth()-280)/2, (TPScreenHeight()-211)/2, 280, 211)];
        middleView.backgroundColor = [UIColor whiteColor];
        middleView.layer.masksToBounds = YES;
        middleView.layer.cornerRadius = 4.0f;
        [self addSubview:middleView];
        
        CGFloat globalY = 30;
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineSpacing:6];
        

        NSString *labelStr2 =NSLocalizedString(@"In order to answer questions that you may encounter in the course of, touch treasure carefully prepared a  ”Essentials“ , more  “how strange line identification number”  and other cheats Oh, go and see?", @"");
        NSMutableAttributedString *attributedString2 = [[NSMutableAttributedString alloc] initWithString:labelStr2];
        [attributedString2 addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [labelStr2 length])];
        
        UILabel *secondLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, globalY, middleView.frame.size.width - 40 , 90)];
        secondLabel.attributedText = attributedString2;
        secondLabel.backgroundColor = [UIColor clearColor];
        secondLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:15];
        secondLabel.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_600"];
        secondLabel.numberOfLines = 4;
        [middleView addSubview:secondLabel];
        
        globalY += secondLabel.frame.size.height + 30;

        TPButton *cancelButton = [[TPButton alloc]initWithFrame:CGRectMake(20, globalY, 110, 46) withType:GRAY_LINE withFirstLineText:@"下次再看" withSecondLineText:nil];
        [cancelButton addTarget:self action:@selector(onCancelButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [middleView addSubview:cancelButton];
        
        UIButton *sureButton = [[TPButton alloc]initWithFrame:CGRectMake(150, globalY, 110, 46) withType:BLUE_LINE withFirstLineText:@"马上就去" withSecondLineText:nil];
        [sureButton addTarget:self action:@selector(onSureButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [middleView addSubview:sureButton];
    }
    return self;
}

- (void)onCancelButtonPressed{
    [DialerUsageRecord recordpath:PATH_ANTIHARASS kvs:Pair(ANTIHARASS_GUIDE_VIEW_CANCEL, @(1)), nil];
    [self.delegate clickCancelButton];
}

- (void)onSureButtonPressed{
    [DialerUsageRecord recordpath:PATH_ANTIHARASS kvs:Pair(ANTIHARASS_GUIDE_VIEW_OK, @(1)), nil];
    [self.delegate clickSureButton];
}

@end

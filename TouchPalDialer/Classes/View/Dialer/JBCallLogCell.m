//
//  JBCallLogCell.m
//  TouchPalDialer
//
//  Created by xie lingmei on 12-7-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "JBCallLogCell.h"
#import "Person.h"
#import "NumberPersonMappingModel.h"
#import "ContactCacheDataManager.h"
#import "ImageCacheModel.h"
#import "FunctionUtility.h"
#import "TPDialerResourceManager.h"
#import "CootekNotifications.h"
#import "TouchPalDialerAppDelegate.h"
#import "ContactInfoManager.h"

#define MIN_ICOMMING_CALL_CONTINUE_TIME 4

@implementation JBCallLogCell

@synthesize nameColor;
@synthesize detailButton2 = detailButton2;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier 
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        int padding = 4;
        int timeWidth = 40;
        int nameWidth = self.numberLabel.frame.size.width;
        int origin = self.numberLabel.frame.origin.x;
        self.nameLabel.frame = CGRectMake(self.nameLabel.frame.origin.x, self.nameLabel.frame.origin.y,
                                          nameWidth-(timeWidth+padding),self.nameLabel.frame.size.height);
        self.numberLabel.frame = CGRectMake(self.numberLabel.frame.origin.x+20,self.numberLabel.frame.origin.y,
                                            nameWidth-(timeWidth+padding)-20,self.numberLabel.frame.size.height);
        nameWidth = self.nameLabel.frame.size.width;
        
        // type button
        typeButton = [[TPUIButton alloc]initWithFrame:CGRectMake(self.nameLabel.frame.origin.x+4,
                                                                 self.numberLabel.frame.origin.y+3, 13, 10)];
        typeButton.enabled = NO;
        [self.userContentView addSubview:typeButton];
        typeButton.hidden = YES;
        
        //time
        timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(origin+nameWidth,self.nameLabel.frame.origin.y,timeWidth,self.nameLabel.frame.size.height)];
        timeLabel.backgroundColor = [UIColor clearColor];
        timeLabel.font = [UIFont systemFontOfSize:13];
		
        timeLabel.textAlignment = NSTextAlignmentRight;
        [self.userContentView addSubview:timeLabel];
        //days
        dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(origin+nameWidth,self.numberLabel.frame.origin.y,timeWidth,self.numberLabel.frame.size.height)];
        dateLabel.backgroundColor = [UIColor clearColor];
		dateLabel.font = [UIFont systemFontOfSize:13];
		
        dateLabel.textAlignment = NSTextAlignmentRight;
        [self.userContentView addSubview:dateLabel];

        // detail button
        detailButton = [[TPUIButton alloc]initWithFrame:CGRectMake(280, 0, 50, 50)];
        [detailButton addTarget:self action:@selector(accessoryButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.userContentView addSubview:detailButton];
        
        detailButton2 = [[TPUIButton alloc]initWithFrame:CGRectMake(260, 0, 20, 50)];
//		[self.userContentView addSubview:detailButton2];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doWhenEditing) name:N_EDIT_NOTIFICATION object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doWhenDoneEditing) name:N_DONE_NOTIFICATION object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dialerWillAppear) name:N_DAILER_WILL_APPEAR object:nil];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (self.editing) {
        [self hideDateLabel];
    }
}

- (void)setDataToCell{
    if(self.currentData == nil) {
        return;
    }
    CallLogDataModel *currentCallLogData = (CallLogDataModel *)self.currentData;
    if (currentCallLogData.callType == CallLogIncomingMissedType) {
         self.textNameColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"common_missedCall_text_color"];
    }else{
        self.textNameColor = nameColor;
    }
    [super setDataToCell];
    //time
    timeLabel.text = [FunctionUtility getLocalShortTimeString:currentCallLogData.callTime];//@"12:49";
    //date
    dateLabel.text = [FunctionUtility dateString:currentCallLogData.callTime];
    
    [typeButton setImage:[self getNormalCallImage:currentCallLogData.callType] forState:UIControlStateNormal];
    [typeButton setImage:[self getNormalCallImage:currentCallLogData.callType] forState:UIControlStateDisabled];
}

- (BOOL)isShowNumberAttr{
    return YES;
}

- (void)accessoryButtonClicked:(id)sender {
    CallLogDataModel *currentCallLogData = (CallLogDataModel *)self.currentData;
	if (currentCallLogData) {
        if (currentCallLogData.personID > 0) {
            [[ContactInfoManager instance] showContactInfoByPersonId:currentCallLogData.personID];
        }else if (currentCallLogData.personID <= 0 ) {
            [[ContactInfoManager instance] showContactInfoByPhoneNumber:currentCallLogData.number];
        } 
        [self goToDetail];
    }
}
- (UIImage *)getNormalCallImage:(CallLogType)type{
    switch (type) {
        case CallLogIncomingType:
            return [[TPDialerResourceManager sharedManager] getCachedImageByName:@"dialer_incoming_icon_normal@2x.png"];
            break;
        case CallLogOutgoingType:
            return [[TPDialerResourceManager sharedManager] getCachedImageByName:@"dialer_outcoming_icon_normal@2x.png"];
            break;
        case CallLogIncomingMissedType:
            return [[TPDialerResourceManager sharedManager] getCachedImageByName:@"dialer_missed_icon_normal@2x.png"];
            break;  
        default:
            break;
    }
    return nil;
}
- (UIImage *)getHightlightCallImage:(CallLogType)type{
    switch (type) {
        case CallLogIncomingType:
            return [[TPDialerResourceManager sharedManager] getCachedImageByName:@"dialer_incoming_icon_hg@2x.png"];
            break;
        case CallLogOutgoingType:
            return [[TPDialerResourceManager sharedManager] getCachedImageByName:@"dialer_outcoming_icon_hg@2x.png"];
            break;
        case CallLogIncomingMissedType:
            return [[TPDialerResourceManager sharedManager] getCachedImageByName:@"dialer_missed_icon_hg@2x.png"];
            break;  
        default:
            break;
    }
    return nil;
}

- (id)selfSkinChange:(NSString *)style{
    NSDictionary *propertyDic = [[TPDialerResourceManager sharedManager] getPropertyDicByStyle:style];
    [super selfSkinChange:style];
    self.nameColor = self.textNameColor;
    UIColor *color = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:[propertyDic objectForKey:@"timeLabel_textColor"]];
    timeLabel.textColor =color;
    color = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:[propertyDic objectForKey:@"dateLabel_textColor"]];
    dateLabel.textColor = color;
    
    [detailButton setBackgroundImage:[[TPDialerResourceManager sharedManager] getCachedImageByName:[propertyDic objectForKey:@"detailButton_backgroundImage"]] forState:UIControlStateNormal];
    [detailButton setBackgroundImage:[[TPDialerResourceManager sharedManager] getCachedImageByName:[propertyDic objectForKey:@"detailButton_backgroundImage_ht"]] forState:UIControlStateHighlighted];
    [detailButton2 setBackgroundImage:[[TPDialerResourceManager sharedManager] getCachedImageByName:[propertyDic objectForKey:@"detailButton_backgroundImage"]] forState:UIControlStateNormal];
    [detailButton2 setBackgroundImage:[[TPDialerResourceManager sharedManager] getCachedImageByName:[propertyDic  objectForKey:@"detailButton_backgroundImage_ht"]] forState:UIControlStateHighlighted];
    
    UIView *backView = [[UIView alloc] initWithFrame:self.frame];
    backView.backgroundColor = [UIColor clearColor];
    self.backgroundView = backView;
    NSNumber *toTop = [NSNumber numberWithBool:YES];
    return toTop;
}
- (void)doWhenEditing {
    dateLabel.hidden = YES;
    timeLabel.hidden = YES;
	detailButton.alpha = 1.0;
    detailButton2.alpha = 1.0;
    [self hideMarkButton];
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
	[UIView setAnimationDuration:0.3];
	[UIView setAnimationDelegate:self];
	detailButton.alpha = 0;
    detailButton2.alpha = 0;
	[UIView commitAnimations];
}

- (void)dialerWillAppear
{
    dateLabel.hidden = [self hasMarkButton];
    timeLabel.hidden = [self hasMarkButton];
	detailButton.alpha = 1.0;
    detailButton2.alpha = 1.0;
}

- (void)removeMarkButton
{
    [super removeMarkButton];
    [self showDateLabel];
}

- (void)hideDateLabel
{
    dateLabel.hidden = YES;
    timeLabel.hidden = YES;
}

- (void)showDateLabel
{
    dateLabel.hidden = self.editing;
    timeLabel.hidden = self.editing;
}

- (void)doWhenDoneEditing
{
    dateLabel.hidden = NO;
    timeLabel.hidden = NO;
	detailButton.alpha = 0;
    detailButton2.alpha = 0;
    [self showMarkButton];
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveLinear];
	[UIView setAnimationDuration:0.3];
	[UIView setAnimationDelegate:self];
	detailButton.alpha = 1.0;
    detailButton2.alpha = 1.0;
	[UIView commitAnimations];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setLongGestureMode:(BOOL)inLongGesture
{
    [super setLongGestureMode:inLongGesture];
    detailButton.enabled = !inLongGesture;
    detailButton2.enabled = !inLongGesture;
    if(inLongGesture){
        [self hideMarkButton];
    }else{
        [self showMarkButton];
    }
}

//for callerTellUGC mark button
- (void)showMarkButton
{
    if ([self hasMarkButton]) {
        [super showMarkButton];
        [self hideDateLabel];
    }
}

- (void)hideMarkButton
{
    if ([self hasMarkButton]) {
        [super hideMarkButton];
        [self showDateLabel];
    }
}

@end

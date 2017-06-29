//
//  CallLogCell.m
//  TouchPalDialer
//
//  Created by zhang Owen on 11/10/11.
//  Copyright 2011 Cootek. All rights reserved.
//

#import "CallLogCell.h"
#import "TouchPalDialerAppDelegate.h"
// model
#import "PhoneNumber.h"
#import "ImageCacheModel.h"
#import "Person.h"
#import "consts.h"
#import "TPDialerResourceManager.h"
#import "ContactCacheDataManager.h"
#import "CootekNotifications.h"
#import "FunctionUtility.h"
#import "ContactInfoManager.h"
#import "UILabel+TPHelper.h"
#import "NSString+TPHandleNil.h"
#import "DateTimeUtil.h"
#import "UILabel+DynamicHeight.h"


static CGFloat sMaxDateWidth = 0.0;
static CGFloat sMaxDateHeight = 0.0;

@interface CallLogCell(){
    BOOL ifVoip;
}

@end

@implementation CallLogCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.ifCalllogCell = YES;
        CGRect contentFrame = self.userContentView.frame;
        self.userContentView.frame = CGRectMake(contentFrame.origin.x, contentFrame.origin.y,
                                                contentFrame.size.width, CALLLOG_CELL_HEIGHT);
        
        self.operView.frame = CGRectMake(0, CALLLOG_CELL_HEIGHT, contentFrame.size.width, CALLLOG_CELL_HEIGHT);
        CGAffineTransform trans = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 0.01);
        self.operView.transform = trans;
        
        CGFloat xFromRight = 0;
        CGFloat gX = 0;
        
        // voip label as an icon
        voipLabel = [[UILabel alloc] initWithFrame:CGRectMake(
                    (CALLLOG_CELL_MARGIN_LEFT - FONT_SIZE_3_5) / 2,
                    (CALLLOG_CELL_HEIGHT -FONT_SIZE_3_5)/2,
                    FONT_SIZE_3_5,
                    FONT_SIZE_3_5)];
        voipLabel.backgroundColor = [UIColor clearColor];
        voipLabel.font = [UIFont fontWithName:@"iPhoneIcon3" size:FONT_SIZE_3_5];
        gX = CGRectGetMaxX(voipLabel.frame);
        
        // detail button
        CGFloat detailWidth = 50;
        xFromRight = detailWidth;
        detailButton = [[TPUIButton alloc]initWithFrame:CGRectMake(
                TPScreenWidth()- xFromRight, 0, detailWidth,  CALLLOG_CELL_HEIGHT)]; // keep this size unchanged
        detailButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [detailButton addTarget:self action:@selector(accessoryButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        
        UIFont *dateFont = [UIFont systemFontOfSize:FONT_SIZE_5];
        if (sMaxDateWidth == 0.0) {
            NSString *tmpString = [self getDateStringByDate:[NSDate date]];
            tmpString = [tmpString stringByAppendingString:@"41"]; // in case of different width of numbers
            UILabel *tmpLabel = [[UILabel alloc] initWithTitle:tmpString font:dateFont isFillContentSize:YES];
            sMaxDateWidth = tmpLabel.frame.size.width;
            sMaxDateHeight = tmpLabel.frame.size.height;
        }
        
        //date label
        CGSize dateLabelSize = CGSizeMake(sMaxDateWidth, sMaxDateHeight);
        xFromRight += dateLabelSize.width;
        dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(
                                                              TPScreenWidth() - xFromRight, (CALLLOG_CELL_HEIGHT - sMaxDateHeight) / 2,
                                                              sMaxDateWidth, sMaxDateHeight)];
        dateLabel.backgroundColor = [UIColor clearColor];
        dateLabel.textAlignment = NSTextAlignmentRight;
        dateLabel.font = dateFont;
        xFromRight += 20;
        
        // separator line
        CGFloat lineHeight = 0.5;
        self.bottomLine.frame = CGRectMake(CALLLOG_CELL_MARGIN_LEFT, CALLLOG_CELL_HEIGHT - lineHeight,
                                           CALLLOG_CELL_MARGIN_LEFT, lineHeight);
        
        // name label, number label
        [self adjustNumberAndName:(TPScreenWidth() - xFromRight - gX) originX:gX];
        
        // notifications
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doWhenEditing) name:N_EDIT_NOTIFICATION object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doWhenDoneEditing) name:N_DONE_NOTIFICATION object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dailerApper) name:N_DAILER_WILL_APPEAR object:nil];
        
        
        // view tree
        [self.userContentView addSubview:voipLabel];
        [self.userContentView addSubview:dateLabel];
        [self.userContentView addSubview:detailButton];
        
        // view positions
        [self adjustNameAndNumberLabel];
        
    }
	
    return self;
}

- (void)doWhenEditing {
	detailButton.alpha = 1.0;
	[self hideMarkButton];
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
	[UIView setAnimationDuration:0.3];
	[UIView setAnimationDelegate:self];
	detailButton.alpha = 0;
	[UIView commitAnimations];
	
}

- (void)doWhenDoneEditing {
	detailButton.alpha = 0;
	[self showMarkButton];
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveLinear];
	[UIView setAnimationDuration:0.3];
	[UIView setAnimationDelegate:self];
	detailButton.alpha = 1.0;
	[UIView commitAnimations];
	
}
- (void)dailerApper{
    dateLabel.hidden = [self hasMarkButton];
    detailButton.alpha = 1.0;
}

- (void)refreshWithEditingState:(BOOL)isediting {
	if (isediting) {
		detailButton.alpha = 0;
	} else {
		detailButton.alpha = 1.0;
	}
}

- (void) adjustNumberAndName:(CGFloat)width  originX:(CGFloat)orginX{
    NSString *tmpString = @"123ABC上海";
    
    CGFloat numberHeight = [[UILabel alloc] initWithTitle:tmpString font:self.numberLabel.font isFillContentSize:YES].frame.size.height;
    CGFloat nameHeight = [[UILabel alloc] initWithTitle:tmpString font:self.nameLabel.font isFillContentSize:YES].frame.size.height;
    
    CGFloat gY = (self.userContentView.frame.size.height - numberHeight - nameHeight - NAME_LABEL_DIFF) / 2;
    self.nameLabel.frame = CGRectMake(orginX, gY, width, nameHeight);
    gY += nameHeight;
    
    gY += NAME_LABEL_DIFF;
    self.numberLabel.frame = CGRectMake(orginX, gY, width, numberHeight);
    gY += numberHeight;
}

- (void)accessoryButtonClicked:(id)sender {
    if (self.editingStyle == UITableViewCellEditingStyleDelete){
            return;
    }
    CallLogDataModel *currentCallLogData = (CallLogDataModel *)self.currentData;
	if (currentCallLogData) {
        if (currentCallLogData.personID > 0) {
            [[ContactInfoManager instance] showContactInfoByPersonId:currentCallLogData.personID];
        }else if (currentCallLogData.personID <= 0) {
            [[ContactInfoManager instance] showContactInfoByPhoneNumber:currentCallLogData.number];
        }
    }
}
- (void)setDataToCell{
    if(self.currentData == nil) {
        return;
    }
    CallLogDataModel *currentCallLogData = (CallLogDataModel *)self.currentData;
    [super setDataToCell];
    
    // date string
    NSString *dateString = nil;
    
    NSDate *now = [NSDate date];
    NSDate *date = [[NSDate date] initWithTimeIntervalSince1970:currentCallLogData.callTime];
    NSTimeInterval delta = [now timeIntervalSinceDate:date];
    
    dateString = [self getDateStringByDate:date];
    if (delta >= 0) {
        NSTimeInterval todayElapsed = [DateTimeUtil timeElapsedInToday];
        if (delta <= todayElapsed) {
            NSDateComponents *comps = [DateTimeUtil dateComponentsFromDate:date];
            NSString *minuteString = [@(comps.minute) stringValue];
            NSString *hourString = [@(comps.hour) stringValue];
            if (minuteString.length < 2) {
                minuteString = [@"0" stringByAppendingString:minuteString];
            }
            if (hourString.length < 2) {
                hourString = [@"0" stringByAppendingString:hourString];
            }
            dateString = [NSString stringWithFormat:@"%@:%@", hourString, minuteString];
            
        } else if (delta <= todayElapsed + 1 * DAY_IN_SECOND) {
            dateString = NSLocalizedString(@"Yesterday", @"昨天");
            
        } else if (delta <= 7 * DAY_IN_SECOND) {
            dateString = [DateTimeUtil weekdayStringFromDate:date];
        }
    }
    
    [self setDateText:dateString];
    [self setVoipLabel:currentCallLogData];
}

- (void) setDateText:(NSString *)dateString {
    dateLabel.text = dateString;
}

- (void)setVoipLabel:(CallLogDataModel *)data{
    voipLabel.hidden = !data.ifVoip;
    if ( data.ifVoip ){
        if ([FunctionUtility CheckIfExistInBindSuccessListarrayWithPhone:data.number]) {
            voipLabel.font = [UIFont fontWithName:@"iPhoneIcon1" size:FONT_SIZE_3_5];
            voipLabel.text = @"r";
            voipLabel.textColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"0xfc5c8d"];
        }else {
//            voipLabel.font = [UIFont fontWithName:@"iPhoneIcon3" size:FONT_SIZE_3_5];
//            voipLabel.text = @"o";
//            voipLabel.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_green_500"];
        }
    }
}


- (BOOL)isShowNumberAttr{
    return YES;
}
- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)selfSkinChange:(NSString *)style{
    [super selfSkinChange:style];
    NSDictionary *propertyDic = [[TPDialerResourceManager sharedManager] getPropertyDicByStyle:style];
    
    UIImage *normalImage = [[TPDialerResourceManager sharedManager] getCachedImageByName:[propertyDic objectForKey:@"detailButton_backgroundImage"]];
    UIImage *htImage = [[TPDialerResourceManager sharedManager] getCachedImageByName:[propertyDic objectForKey:@"detailButton_backgroundImage_ht"]];
    
    [detailButton setImage:normalImage forState:UIControlStateNormal];
    [detailButton setImage:htImage forState:UIControlStateHighlighted];
    
    UIColor *datecolor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:[propertyDic objectForKey:@"dateLabel_textColor"]];
    dateLabel.textColor = datecolor;
    
    UIView *backView = [[UIView alloc] initWithFrame:self.frame];
    backView.backgroundColor = [UIColor clearColor];
    self.backgroundView = backView;
    
    NSNumber *toTop = [NSNumber numberWithBool:YES];
    return toTop;
}

- (void)setLongGestureMode:(BOOL)inLongGesture
{
    [super setLongGestureMode:inLongGesture];
    detailButton.enabled = !inLongGesture;
    if(inLongGesture){
        [self hideMarkButton];
    }else{
        [self showMarkButton];
    }
}

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

- (void)removeMarkButton
{
    [super removeMarkButton];
    [self showDateLabel];
}

- (void)hideDateLabel
{
    dateLabel.hidden = YES;
//    timeLabel.hidden = YES;
}

- (void)showDateLabel
{
    dateLabel.hidden = self.editing;
//    timeLabel.hidden = self.editing;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat _markStickerX = 0;
    for (TPDrawRichText *s in self.numberLabel.elements) {
        _markStickerX += [s minWidthOfContent];
    }
    
    self.userContentView.frame = CGRectMake(0, 0, TPScreenWidth(), CALLLOG_CELL_HEIGHT);
    
    self.numberLabel.frame = CGRectMake(35, self.numberLabel.frame.origin.y, self.numberLabel.frame.size.width, self.numberLabel.frame.size.height);
    
    self.nameLabel.frame = CGRectMake(35, self.nameLabel.frame.origin.y, self.nameLabel.frame.size.width, self.nameLabel.frame.size.height);
    
    self.markSticker.frame = CGRectMake(_markStickerX + 41, self.markSticker.frame.origin.y, self.markSticker.frame.size.width, self.markSticker.frame.size.height);
    
//    voipLabel.frame = CGRectMake(10, voipLabel.frame.origin.y, voipLabel.frame.size.width, voipLabel.frame.size.height);
    
    if (!self.isEditing) {
        self.bottomLine.frame = CGRectMake(CALLLOG_CELL_MARGIN_LEFT, self.bottomLine.frame.origin.y,
                                           TPScreenWidth()*2, self.bottomLine.frame.size.height);
    }else {
        self.userContentView.frame = CGRectMake(0, 0, TPScreenWidth() - 60, CALLLOG_CELL_HEIGHT);
        self.bottomLine.frame = CGRectMake(74, self.bottomLine.frame.origin.y, TPScreenWidth()*2, self.bottomLine.frame.size.height);
    }
    
    UIColor *lineColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"baseContactCell_downSeparateLine_color"];
    self.bottomLine.backgroundColor = lineColor;
}

#pragma mark helper
- (NSString *) getDateStringByDate:(NSDate *)date {
    NSDateComponents *comps = [DateTimeUtil dateComponentsFromDate:date];
    NSMutableString *dayString = [[NSMutableString alloc] initWithString:[@(comps.day) stringValue]];
    if (dayString.length == 1) {
        [dayString insertString:@"0" atIndex:0];
    }
    
    NSMutableString *monthString = [[NSMutableString alloc] initWithString:[@(comps.month) stringValue]];
    if (monthString.length == 1) {
        [monthString insertString:@"0" atIndex:0];
    }
    
    NSString *yearString = [@(comps.year) stringValue];
    NSInteger len = yearString.length;
    if (len > 2) {
        yearString = [yearString substringFromIndex:(len -2)];
    }
    return [NSString stringWithFormat:@"%@/%@/%@", yearString, [monthString copy], [dayString copy]];
}

@end

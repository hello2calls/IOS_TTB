//
//  YellowMainDetailCell.m
//  TouchPalDialer
//
//  Created by xie lingmei on 12-8-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "YellowMainDetailCell.h"
#import "TPDialerResourceManager.h"
#import "YellowChildDetailViewController.h"
#import "TouchPalDialerAppDelegate.h"
#import "YellowEntryModel.h"
#import "NSString+PhoneNumber.h"

@implementation YellowMainDetailCell
@synthesize delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // detail button
        reportButton_ = [[TPUIButton alloc]initWithFrame:CGRectMake(280, 0, 40, 50)];
		[reportButton_ addTarget:self action:@selector(reportData:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:reportButton_];
        //[reportButton_ setTitle:NSLocalizedString(@"Report", @"") forState:UIControlStateNormal];
        reportButton_.titleLabel.font = [UIFont systemFontOfSize:CELL_FONT_XXSMALL];
        reportButton_.titleLabel.adjustsFontSizeToFitWidth = YES;
		[reportButton_ release];
        
        nameLabel.frame = CGRectMake(10, 5, 250, 25);
        numberLabel.frame = CGRectMake(10, 30, 250, 20);
    }
    return self;
}
- (void)setDataToCell{
    YellowEntryModel *currentResultData = (YellowEntryModel *)self.currentData;
    if(currentResultData == nil) {
        return;
    } 
    NSString  *name = currentResultData.shortName;
    if ([name length] == 0) {
        name = currentResultData.name;
    }
    NSString  *number = [currentResultData.defaultNumber formatPhoneNumber];
    [self refreshCellView:name withNumber:number];
}
- (void)setContributeMode:(BOOL)isContibute{
    reportButton_.hidden = !isContibute;
    self.detailButton.hidden = isContibute;
}
- (void)reportData:(TPUIButton *)reportButton{
    [delegate reportShopWithCell:self];
}
- (void)accessoryButtonClicked:(id)sender{
    cootek_log(@"accessoryButtonClicked *********** go to detail");
    [self goToDetail];
}
- (void)goToDetail{
    [delegate onWillGoDetail:self];
}
- (id)selfSkinChange:(NSString *)style{
    [super selfSkinChange:style]; 
    NSDictionary *propertyDic = [[TPDialerResourceManager sharedManager] getPropertyDicByStyle:style];
    [reportButton_ setBackgroundImage:[[TPDialerResourceManager sharedManager] getImageByName:[propertyDic objectForKey:@"reportButton_imageForNormal"]] forState:UIControlStateNormal];
    [reportButton_ setBackgroundImage:[[TPDialerResourceManager sharedManager] getImageByName:[propertyDic objectForKey:@"reportButton_imageForHighlightedState"]] forState:UIControlStateHighlighted];
    
    NSNumber *toTop = [NSNumber numberWithBool:NO];
    return toTop;
}

-(void)dealloc{
    [super dealloc];
}

- (BOOL)supportLongGestureMode
{
    return YES;
}

@end

@implementation YellowMainMoreDetailCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [super addDetailButton];
        //disCountLabel
        distanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(200,30,80,20)];
        distanceLabel.backgroundColor = [UIColor clearColor];
        distanceLabel.font = [UIFont systemFontOfSize:CELL_FONT_SMALL];
        distanceLabel.textAlignment = UITextAlignmentRight;
        [self addSubview:distanceLabel];
        [distanceLabel release];
        
        //imageView
    }
    return self;
}
- (void)setDataToCell{
    YellowEntryModel *currentResultData = (YellowEntryModel *)self.currentData;
    [super setDataToCell];
    distanceLabel.text = currentResultData.distance;
}
- (void)setContributeMode:(BOOL)isContibute{
    [super setContributeMode:isContibute];
    distanceLabel.hidden = isContibute;
}
- (id)selfSkinChange:(NSString *)style{
    NSDictionary *propertyDic = [[TPDialerResourceManager sharedManager] getPropertyDicByStyle:style];
    [super selfSkinChange:style]; 
    
    UIColor *color = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:[propertyDic objectForKey:@"numberLabel_textColor"]];
    distanceLabel.textColor =color;
    
    NSNumber *toTop = [NSNumber numberWithBool:NO];
    return toTop;
}

- (void)setLongGestureMode:(BOOL)inLongGesture
{
    [super setLongGestureMode:inLongGesture];
    self.detailButton.enabled = !inLongGesture;
}

@end

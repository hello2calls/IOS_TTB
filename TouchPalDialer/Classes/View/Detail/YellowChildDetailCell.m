//
//  YellowChildDetailCell.m
//  TouchPalDialer
//
//  Created by xie lingmei on 12-8-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "YellowChildDetailCell.h"
#import "TPDialerResourceManager.h"
#import "LabelDataModel.h"
#import "NSString+PhoneNumber.h"

@interface YellowBranchDetailCell(){
    TPUIButton *reportButton_;
}

@end
@implementation YellowBranchDetailCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        iconView_ = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
		iconView_.backgroundColor = [UIColor clearColor];
		[self addSubview:iconView_];
        [iconView_ release];
        
        reportButton_ = [[TPUIButton alloc]initWithFrame:CGRectMake(280, 0, 40, 50)];
		[reportButton_ addTarget:self action:@selector(reportData:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:reportButton_];
		[reportButton_ release];
        
        nameLabel.frame = CGRectMake(50, 5, 256, 25);
		numberLabel.frame = CGRectMake(50, 30, 216, 20);
    }
    return self;
}
- (void)setDataToCell{
    NSString *currentResultData = (NSString *)self.currentData;
    if(currentResultData == nil) {
        return;
    } 
    NSString  *number = [currentResultData formatPhoneNumber];
    NSString  *tag = NSLocalizedString(@"Phone",@"");
    iconView_.image = [[TPDialerResourceManager sharedManager] getImageByName:@"yellowPage_detail_icon_call@2x.png"];
    [self refreshCellView:number withNumber:tag];
}
- (void)reportData:(TPUIButton *)reportButton{
}
- (void)setContributeMode:(BOOL)isContibute{
    reportButton_.hidden = !isContibute;
}
- (id)selfSkinChange:(NSString *)style{
    [super selfSkinChange:style]; 
    NSDictionary *propertyDic = [[TPDialerResourceManager sharedManager] getPropertyDicByStyle:style];
    [reportButton_ setImage:[[TPDialerResourceManager sharedManager] getImageByName:[propertyDic objectForKey:@"reportButton_imageForNormal"]] forState:UIControlStateNormal];
    [reportButton_ setImage:[[TPDialerResourceManager sharedManager] getImageByName:[propertyDic objectForKey:@"reportButton_imageForHighlightedState"]] forState:UIControlStateHighlighted];

    NSNumber *toTop = [NSNumber numberWithBool:NO];
    return toTop;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

@implementation YellowBranchAddressDetailCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //disCountLabel
        distanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(110,26,200,20)];
        distanceLabel.backgroundColor = [UIColor clearColor];
        distanceLabel.font = [UIFont systemFontOfSize:CELL_FONT_SMALL];
        distanceLabel.textAlignment = UITextAlignmentRight;
        [self addSubview:distanceLabel];
        [distanceLabel release];
        
        UIImage *imageDistance = [[TPDialerResourceManager sharedManager] getImageByName:@"detail_yellowpage_distance_icon@2x.png"];
        distanceIconView = [[UIImageView alloc] initWithImage:imageDistance];
        [self addSubview:distanceIconView];
        [distanceIconView release];
      
        //imageView
        nameLabel.numberOfLines = 0;
        nameLabel.lineBreakMode = UILineBreakModeWordWrap;
        nameLabel.adjustsFontSizeToFitWidth = YES;
    }
    return self;
}
- (void)setDataToCell{
    LabelDataModel *currentResultData = (LabelDataModel *)self.currentData;
    if(currentResultData == nil) {
        return;
    } 
    NSString  *name = currentResultData.labelKey;
    NSString  *number =  NSLocalizedString(@"Address",@"");;
    CGSize size = [name sizeWithFont:[UIFont boldSystemFontOfSize:CELL_FONT_LARGE] 
                                constrainedToSize:CGSizeMake(256,50*3) 
                                    lineBreakMode:UILineBreakModeWordWrap];
    CGSize sizeDistance = [currentResultData.labelValue  sizeWithFont:[UIFont systemFontOfSize:CELL_FONT_SMALL] 
                   constrainedToSize:CGSizeMake(150,20) 
                       lineBreakMode:UILineBreakModeWordWrap];
    int lineheight = 20;
    int height = (size.height/lineheight)*nameLabel.frame.size.height;
    if (size.height > nameLabel.frame.size.height) {
        nameLabel.frame = CGRectMake(nameLabel.frame.origin.x,nameLabel.frame.origin.y,256,height);
        numberLabel.frame = CGRectMake(numberLabel.frame.origin.x,height + nameLabel.frame.origin.y + 5,100,20);
       
    }
    distanceLabel.frame = CGRectMake(TPScreenWidth()-sizeDistance.width-10,height + nameLabel.frame.origin.y + 5,sizeDistance.width,distanceLabel.frame.size.height);
    
    iconView_.image = [[TPDialerResourceManager sharedManager] getImageByName:@"yellowPage_detail_icon_address@2x.png"];
    [self refreshCellView:name withNumber:number];
    if ([currentResultData.labelValue length] > 0 && [currentResultData.labelValue hasSuffix:NSLocalizedString(@"m", @"") ]) {
      
        distanceIconView.frame = CGRectMake(distanceLabel.frame.origin.x-distanceIconView.frame.size.width, distanceLabel.frame.origin.y+5, distanceIconView.frame.size.width, distanceIconView.frame.size.height);
        cootek_log(@"x=%f,y=%f,width=%f,height=%f",distanceIconView.frame.origin.x,distanceIconView.frame.origin.y,distanceIconView.frame.size.width,distanceIconView.frame.size.height);
        distanceLabel.text = currentResultData.labelValue;   
        distanceIconView.hidden = NO;
    }else {
        distanceIconView.hidden = YES;
    }
}
- (void)setContributeMode:(BOOL)isContibute{
    [super setContributeMode:isContibute];
    distanceLabel.hidden = isContibute;
}
- (id)selfSkinChange:(NSString *)style{
    NSDictionary *propertyDic = [[TPDialerResourceManager sharedManager] getPropertyDicByStyle:style];
    [super selfSkinChange:style]; 
    
    UIColor *color = [[TPDialerResourceManager sharedManager] 
                      getUIColorFromNumberString:[propertyDic objectForKey:@"numberLabel_textColor"]];
    distanceLabel.textColor =color;
    
    NSNumber *toTop = [NSNumber numberWithBool:YES];
    return toTop;
}
-(void)dealloc{
    [super dealloc];
}
@end
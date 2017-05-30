//
//  ContactInfoMainView.m
//  TouchPalDialer
//
//  Created by game3108 on 15/7/16.
//
//

#import "ContactInfoMainView.h"
#import "TPDialerResourceManager.h"
#import "TPHeaderButton.h"
#import "ContactInfoButtonView.h"
#import "FunctionUtility.h"
#import "TouchPalMembersManager.h"
#import "FunctionUtility.h"
#import "ContactCacheDataManager.h"

#define MAIN_HEIGHT ((TPScreenHeight()>600)?280:(240+TPHeaderBarHeightDiff()))
#define CIRCLE_HEIGHT (TPScreenHeight()>600?106:86)

@interface ContactInfoMainView()<ContactInfoButtonViewDelegate>{
    UIImageView *bgView;
    UIButton *iconButton;
    UIImageView *imageView;
    UILabel *firstLabel;
    UILabel *secondLabel;
    ContactInfoButtonView *_buttonView;
    
    CGFloat _firstLabelHeight;
    CGFloat _iconRadius;
    
    CGFloat _buttonViewSecondDis;
    CGFloat _firstSecondDis;
}

@end

@implementation ContactInfoMainView

- (instancetype)initWithFrame:(CGRect)frame infoModel:(ContactInfoModel *)infoModel{
    self = [super initWithFrame:frame];
    if ( self ){
        _infoModel = infoModel;
        self.backgroundColor = [FunctionUtility getBgColorOfLongPressView];
        
        bgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        bgView.alpha = 0.3;
        if ( infoModel.bgImage != nil ){
            bgView.image = infoModel.bgImage;
        }
        else
            bgView.hidden = YES;
        [self addSubview:bgView];
        
        float globalY = 30 + TPHeaderBarHeightDiff();
        
        iconButton = [[UIButton alloc] initWithFrame:CGRectMake((TPScreenWidth()-CIRCLE_HEIGHT)/2, globalY, CIRCLE_HEIGHT, CIRCLE_HEIGHT)];
        iconButton.layer.masksToBounds = YES;
        iconButton.layer.cornerRadius = iconButton.frame.size.width/2;
        iconButton.layer.borderWidth = 2.5;
        [iconButton setBackgroundColor:[UIColor clearColor]];
        [iconButton addTarget:self action:@selector(onIconButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [self refreshIconButtonBorder];
        [self addSubview:iconButton];
        _iconRadius = iconButton.frame.size.width / 2;
        
        imageView = [[UIImageView alloc]initWithFrame:CGRectMake((iconButton.frame.size.width-(CIRCLE_HEIGHT-6))/2, (iconButton.frame.size.height-(CIRCLE_HEIGHT-6))/2, CIRCLE_HEIGHT-6, CIRCLE_HEIGHT-6)];
        imageView.layer.masksToBounds = YES;
        imageView.layer.cornerRadius = imageView.frame.size.width/2;
        imageView.image = infoModel.photoImage;
        imageView.backgroundColor = [UIColor clearColor];
        [iconButton addSubview:imageView];
        
        globalY += iconButton.frame.size.height + 8;
        _firstLabelHeight = globalY;
        
        firstLabel = [[UILabel alloc]initWithFrame:CGRectMake(50, globalY, TPScreenWidth()-100, 18)];
        firstLabel.textColor = [UIColor whiteColor];
        firstLabel.backgroundColor = [UIColor clearColor];
        firstLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:FONT_SIZE_3];
        firstLabel.textAlignment = NSTextAlignmentCenter;
        firstLabel.text = infoModel.firstStr;
        [self addSubview:firstLabel];
        
        globalY += firstLabel.frame.size.height + 8;
        _firstSecondDis = firstLabel.frame.size.height + 8;
        
        secondLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, globalY, TPScreenWidth()-40, 14)];
        secondLabel.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_white_transparency_700"];
        secondLabel.backgroundColor = [UIColor clearColor];
        secondLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:FONT_SIZE_5];
        secondLabel.textAlignment = NSTextAlignmentCenter;
        secondLabel.text = infoModel.secondStr;
        [self addSubview:secondLabel];
        
        _buttonViewSecondDis = self.frame.size.height - 60 - globalY;
        _buttonView = [[ContactInfoButtonView alloc]initWithFrame:CGRectMake(0,self.frame.size.height - 60, self.frame.size.width, 60) andInfoModel:infoModel];
        _buttonView.delegate = self;
        [self addSubview:_buttonView];
        
    }
    return self;
}

- (void)refreshView:(ContactInfoModel *)infoModel{
    _infoModel = infoModel;
    if ( infoModel.bgImage != nil ){
        bgView.hidden = NO;
        bgView.image = infoModel.bgImage;
    }
    else
        bgView.hidden = YES;
    
    imageView.image = infoModel.photoImage;
    [self refreshIconButtonBorder];
    firstLabel.text = infoModel.firstStr;
    secondLabel.text = infoModel.secondStr;
    [_buttonView refreshButtonView:infoModel];
}

- (void)refreshButtonView:(ContactInfoModel *)infoModel{
    _infoModel = infoModel;
    [_buttonView refreshButtonView:infoModel];
}

- (void)doViewShrunk{
    CGRect firstFrame = firstLabel.frame;
    CGRect secondFrame = secondLabel.frame;
    CGRect buttonFrame = _buttonView.frame;
    CGFloat moveHeight = MAIN_HEIGHT - self.frame.size.height;
    CGFloat aimHeight = _firstLabelHeight - TPHeaderBarHeightDiff() - 13.5;
    CGFloat firstLabelMoveHeight = aimHeight - moveHeight ;
    CGFloat shrunkRadius = moveHeight;
    if ( moveHeight > _iconRadius ){
        shrunkRadius = _iconRadius;
    }
    iconButton.transform = CGAffineTransformScale(CGAffineTransformIdentity,1-shrunkRadius/_iconRadius,1-shrunkRadius/_iconRadius);

    if ( firstLabelMoveHeight >= 0 ){
        firstLabel.frame = CGRectMake(firstFrame.origin.x,_firstLabelHeight - moveHeight, firstFrame.size.width, firstFrame.size.height);
        secondLabel.alpha = 1;
        _buttonView.alpha = secondLabel.alpha;
    }else{
        firstLabel.frame = CGRectMake(firstFrame.origin.x,TPHeaderBarHeightDiff() + 13.5, firstFrame.size.width, firstFrame.size.height);
        CGFloat restHeight = 195 - aimHeight;
        secondLabel.alpha = 1 - (moveHeight - aimHeight)/restHeight;
        _buttonView.alpha = secondLabel.alpha;
        
    }
    secondLabel.frame = CGRectMake(secondFrame.origin.x,firstLabel.frame.origin.y + _firstSecondDis , secondFrame.size.width, secondFrame.size.height);
    _buttonView.frame = CGRectMake(buttonFrame.origin.x,secondLabel.frame.origin.y +  _buttonViewSecondDis , buttonFrame.size.width, buttonFrame.size.height);
}

- (void)onIconButtonAction{
    [_delegate onIconButtonAction];
}

- (void) refreshIconButtonBorder {
    UIColor *iconBorderColor = iconBorderColor = [TPDialerResourceManager getColorForStyle:@"tp_color_white_transparency_700"];
    ContactCacheDataModel *cachedModel = [[ContactCacheDataManager instance] contactCacheItem:_infoModel.personId];
    if (cachedModel != nil && cachedModel.image != nil) {
        iconBorderColor = [TPDialerResourceManager getColorForStyle:@"tp_color_white_transparency_200"];
    }
    iconButton.layer.borderColor = iconBorderColor.CGColor;
}

#pragma mark ContactInfoButtonViewDelegate

- (void)onButtonPressed:(NSInteger)tag{
    [_delegate onButtonPressed:tag];
}

@end

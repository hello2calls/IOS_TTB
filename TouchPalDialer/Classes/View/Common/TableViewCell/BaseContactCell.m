//
//  BaseContactCell.m
//  TouchPalDialer
//
//  Created by xie lingmei on 12-8-9.
//  Frame modified by Chen Lu on 12-9-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "BaseContactCell.h"
#import "TouchPalDialerAppDelegate.h"
#import "TPDialerResourceManager.h"
#import "ContactsCellStrategy.h"
#import "UILayoutUtility.h"
#import "AppSettingsModel.h"
#import "TouchpalMembersManager.h"
#import "FunctionUtility.h"
#import "AllViewController.h"
#import "UILabel+TPHelper.h"
#import "UILabel+DynamicHeight.h"
#import "FunctionUtility.h"
#import "UserDefaultsManager.h"
#define MIN_MOVE_LENGTH 70

@interface BaseContactCell(){
    id<ContactsCellStrategyDelegate> actionStrategy_;
    BOOL(^isExcuteAction_)();

    CGPoint startPoint_;
    UIImageView *imageBgView_;
    UIImageView *iconView_;
    UIImageView *hgCircleView_;
    MoveOrientationType orientation_;

    BOOL isStartAnimation_;
    float rotateAngle;
    CGRect _operViewFrame;
}
@end

@implementation BaseContactCell
@synthesize faceSticker;
@synthesize markSticker;
@synthesize nameLabel;
@synthesize numberLabel;
@synthesize userContentView = userContentView_;
@synthesize actionStrategy = actionStrategy_;
@synthesize isExcuteAction = isExcuteAction_;
@synthesize htNumberColor;
@synthesize htNameTextColor;
@synthesize textNumberColor;
@synthesize textNameColor;
@synthesize isHighlightedName;
@synthesize isHighlightedNumber;
@synthesize bottomLine;
@synthesize partBottomLine;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        UIView *view = [[UIView alloc] initWithFrame:self.frame];
        self.userContentView = view;

        // name label.
		nameLabel = [[TPRichLabel alloc] initWithFrame:CGRectMake(CONTACT_CELL_MARGIN_LEFT, TOP_PADDING, TPScreenWidth()-124, 25)];
        nameLabel.font = [UIFont boldSystemFontOfSize:FONT_SIZE_3];

		// number label.
		numberLabel = [[TPRichLabel alloc] init];
        numberLabel.font = [UIFont systemFontOfSize:FONT_SIZE_5];
        float height = numberLabel.font.lineHeight + LABEL_DIFF;
        numberLabel.frame = CGRectMake(64, CELL_HEIGHT - height - BOTTOM_PADDING, TPScreenWidth()-124, height);

		faceSticker = [[FaceSticker alloc] initFaceStickerForCell:CGRectMake(CONTACT_CELL_LEFT_GAP, (CONTACT_CELL_HEIGHT - CONTACT_CELL_PHOTO_DIAMETER) / 2, CONTACT_CELL_PHOTO_DIAMETER, CONTACT_CELL_PHOTO_DIAMETER)];

		markSticker = [[CallerTypeSticker alloc] initWithFrame:CGRectMake(12, CELL_HEIGHT- height - BOTTOM_PADDING - 1.5, 55, height)];
        markSticker.backgroundColor = [UIColor clearColor];
        markSticker.hidden = YES;

        UIColor *lineColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"baseContactCell_downSeparateLine_color"];
        bottomLine = [[UILabel alloc]initWithFrame:CGRectMake(15, CONTACT_CELL_HEIGHT-0.5, TPScreenWidth()*2, 0.5)];
        bottomLine.backgroundColor = lineColor;
        bottomLine.hidden = YES;

        partBottomLine = [[UILabel alloc]initWithFrame:CGRectMake(CONTACT_CELL_LEFT_GAP, CELL_HEIGHT-0.5, TPScreenWidth()-24-CONTACT_CELL_LEFT_GAP, 0.5)];
        partBottomLine.backgroundColor = lineColor;
        partBottomLine.hidden = YES;

        _operViewFrame = CGRectMake(0, CONTACT_CELL_HEIGHT, TPScreenWidth(), CONTACT_CELL_HEIGHT);
        self.operView = [[UIView alloc] initWithFrame:_operViewFrame];
        self.operView.hidden = YES;

        NSString *userLabelString = NSLocalizedString(@"voip_cootek_user_label", "");
        UIFont *userLabelFont = [UIFont fontWithName:@"iPhoneIcon3" size:18];
        _ifCootekUserView = [[UILabel alloc] initWithTitle:userLabelString font:userLabelFont isFillContentSize:YES];
        CGSize targetSize = _ifCootekUserView.frame.size;
        _ifCootekUserView.frame = CGRectMake(
                    TPScreenWidth() - INDEX_SECTION_VIEW_WIDTH - COOTEK_USER_ICON_MARGIN_RIGHT - targetSize.width,
                    (CONTACT_CELL_HEIGHT- targetSize.height)/2,
                    targetSize.width, targetSize.height);
        _ifCootekUserView.textColor = [TPDialerResourceManager getColorForStyle:@"voip_cootekUser_label_color"];
        _ifCootekUserView.textAlignment = NSTextAlignmentCenter;
        _ifCootekUserView.backgroundColor = [UIColor clearColor];
        _ifCootekUserView.hidden = YES;


        // view settings
        // for self.contentView
        [self.contentView addSubview:view];
        [self.userContentView addSubview:nameLabel];
        [self.userContentView addSubview:numberLabel];
        [self.userContentView addSubview:faceSticker];
        [self.userContentView addSubview:markSticker];
        [self.userContentView addSubview:_ifCootekUserView];

        // view tree
        [self addSubview:bottomLine];
        [self addSubview:self.operView];
    }
    return self;
}

-(void)openSlideItem
{
    [self.actionStrategy createPanGestureFor:self actionMethod:@selector(panMoveHandler:)];
}

-(void)closeSlideItem
{
    [self.actionStrategy removePanGestureFor:self];
}

- (void)showAnimation {

    
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionTransitionFlipFromTop
                     animations:^{
                         self.operView.transform = CGAffineTransformIdentity;
                     }
                     completion:^(BOOL finished) {
                         if (finished) {
                             
                             NSLog([self.operView debugDescription]);
                         }
                         
                     }];

}

- (void)exitAnimation {
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.operView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 0.01);
                     }
                     completion:^(BOOL finished) {
                         NSLog(@"weyl: 3");
                         NSLog([self.operView debugDescription]);
                     }];
}

- (void)showPartOfBottomLine {
    partBottomLine.hidden = NO;
    bottomLine.hidden = YES;
}

- (void)showAllBottomLine {
    partBottomLine.hidden = YES;
    bottomLine.hidden = NO;
}

- (void)hideBottomLine {
    partBottomLine.hidden = YES;
    bottomLine.hidden = YES;
}


- (void)refreshCellView:(NSString *)number
     withNumberHitRange:(NSRange )numberRange
               withName:(NSString *)name
       withNameHitArray:(NSMutableArray *)nameHitArray{
    //name
    NSArray *elements = nil;
    if (isHighlightedName) {
        elements = [TPRichLabelUtils createHighlightElements:name
                                                   textColor:textNameColor
                                                 httextColor:htNameTextColor
                                                        font:[UIFont boldSystemFontOfSize:17]
                                                   highlight:nameHitArray];


    }else{
        elements = [TPRichLabelUtils createDefaultElements:name
                                                 textColor:textNameColor
                                                      font:[UIFont boldSystemFontOfSize:17]];
    }
    nameLabel.elements = elements;

    if (isHighlightedNumber) {
        elements = [TPRichLabelUtils createDefaultElements:number
                                                 textColor:textNumberColor
                                                      font:[UIFont systemFontOfSize:CELL_FONT_SMALL]];
    }else{
        elements = [TPRichLabelUtils createNumberHighlightElements:number
                                                   textColor:textNumberColor
                                                 httextColor:htNumberColor
                                                        font:[UIFont systemFontOfSize:CELL_FONT_SMALL]
                                                   highlight:numberRange];
    }
    numberLabel.elements = elements;



}

- (void)refreshCellView:(UIImage *)facePhoto
             withNumber:(NSString *)number
     withNumberHitRange:(NSRange )numberRange
               withName:(NSString *)name
       withNameHitArray:(NSMutableArray *)nameHitArray
{
    //image
    self.faceSticker.headImageView.image = facePhoto;
    self.faceSticker.typeLabel.text = @"";
    [self refreshCellView:number withNumberHitRange:numberRange withName:name withNameHitArray:nameHitArray];

}
- (id)selfSkinChange:(NSString *)style{
    NSDictionary *propertyDic = [[TPDialerResourceManager sharedManager] getPropertyDicByStyle:style];

    self.textNameColor = [[TPDialerResourceManager sharedManager]
                 getUIColorFromNumberString:[propertyDic objectForKey:@"nameLabel_textColor"]];
    UIColor *hColor ;
    BOOL isVersionSix = [UserDefaultsManager boolValueForKey:ENABLE_V6_TEST_ME defaultValue:NO];
    if (isVersionSix) {
       hColor = [TPDialerResourceManager getColorForStyle:@"skinDefaultHighlightText_color"];
    }

    self.htNameTextColor =isVersionSix ? hColor : [[TPDialerResourceManager sharedManager]
                   getUIColorFromNumberString:[propertyDic objectForKey:@"nameLabel_highlightColor"]];
    nameLabel.backgroundColor = [UIColor clearColor];

    self.textNumberColor = [[TPDialerResourceManager sharedManager]
                       getUIColorFromNumberString:[propertyDic objectForKey:@"numberLabel_textColor"]];
    self.htNumberColor = isVersionSix ? hColor : [[TPDialerResourceManager sharedManager]
                     getUIColorFromNumberString:[propertyDic objectForKey:@"numberLabel_highlightColor"]];
    numberLabel.backgroundColor = [UIColor clearColor];

    self.markSticker.dotLabel.textColor = textNumberColor;

    if([propertyDic objectForKey:@"selectedBackgroundColor"]){
        UIView *selectedView = [[UIView alloc] initWithFrame:self.frame];
        selectedView.backgroundColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:[propertyDic objectForKey:@"selectedBackgroundColor"]];
        self.selectedBackgroundView = selectedView;
    }
    NSNumber *toTop = [NSNumber numberWithBool:YES];
    userContentView_.layer.backgroundColor = [[TPDialerResourceManager sharedManager]
                                              getUIColorFromNumberString:@"defaultCellBackground_color"].CGColor;
    return toTop;
}

- (void)panMoveHandler:(UIPanGestureRecognizer *)gesture{

    //remove the entrance of swiping the cell, but keep the other codes, since the amount is huge and the logic is
    //a little bit complex
    CGPoint point = [gesture translationInView:self];
    if (gesture.state == UIGestureRecognizerStateEnded) {
        [self removeImageView];
        if ((point.x >= MIN_MOVE_LENGTH&&orientation_ == MoveOrientationTypeRight)
            ||(point.x <= -MIN_MOVE_LENGTH&&orientation_ == MoveOrientationTypeLeft)) {
            [actionStrategy_ onPanClick:self.currentData type:orientation_];
        }
    }else if (gesture.state == UIGestureRecognizerStateChanged){
        if (orientation_ == MoveOrientationTypeUnknow) {
            orientation_ = point.x > 0 ? MoveOrientationTypeRight:MoveOrientationTypeLeft;
            [self createIconView];
            if (CGColorEqualToColor(userContentView_.layer.backgroundColor,nameLabel.backgroundColor.CGColor)) {
                userContentView_.layer.backgroundColor = self.selectedBackgroundView.backgroundColor.CGColor;
            }
        }
        if (fabs(point.x) < MIN_MOVE_LENGTH && orientation_ != MoveOrientationTypeUnknow) {
            [self backAnimations];
            [self setBackColor];
        }else if (fabs(point.x) > MIN_MOVE_LENGTH){
            [self setColor];
            [self animations];
        }
        CGFloat oldHeight = userContentView_.frame.size.height;
        userContentView_.frame = CGRectMake(point.x,0, TPScreenWidth(), oldHeight);
    }else if (gesture.state == UIGestureRecognizerStateBegan){
        orientation_ = MoveOrientationTypeUnknow;
        [self createImageView];
    }else if(gesture.state == UIGestureRecognizerStateCancelled
             || gesture.state == UIGestureRecognizerStateFailed){
        [self removeImageView];
    }
}

- (void)onClick{
    if (isExcuteAction_()) {
        [actionStrategy_ onClick:self.currentData];
    }
}
-(void)animations{
    if (isStartAnimation_) {
        return;
    }
    //icon view
    CABasicAnimation* rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];

    if (orientation_ == MoveOrientationTypeRight) {
        switch ([AppSettingsModel appSettings].listSwipeRight) {
            case CellListFunctionTypeOnCall:
                rotationAnimation.toValue = [NSNumber numberWithFloat:-(0.75*M_PI)];
                rotateAngle = 0;
                break;
            case CellListFunctionTypeSendSms:
                rotationAnimation.toValue = [NSNumber numberWithFloat:-(2*M_PI)];
                rotateAngle = 2*M_PI;
                break;
            default:
                break;
        }

    }else if (orientation_ == MoveOrientationTypeLeft){
        switch ([AppSettingsModel appSettings].listSwipeLeft) {
            case CellListFunctionTypeOnCall:
                rotationAnimation.toValue = [NSNumber numberWithFloat:-(0.75*M_PI)];
                rotateAngle = 0;
                break;
            case CellListFunctionTypeSendSms:
                rotationAnimation.toValue = [NSNumber numberWithFloat:-(2*M_PI)];
                rotateAngle = 2*M_PI;
                break;
            default:
                break;
        }

    }
    rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    rotationAnimation.beginTime = 0.0f;
    rotationAnimation.duration = 0.3f;
    [rotationAnimation setRemovedOnCompletion:NO];
    [rotationAnimation setFillMode:kCAFillModeForwards];

    UIImage *hgImage = [actionStrategy_ imageForMove:orientation_ isNormalImage:NO];
    CABasicAnimation* imageAnimation = [CABasicAnimation animationWithKeyPath:@"contents"];
    imageAnimation.fromValue = (id)iconView_.image.CGImage;
    imageAnimation.toValue = (id)hgImage.CGImage;
    imageAnimation.autoreverses = NO;
    [imageAnimation setRemovedOnCompletion:NO];
    [imageAnimation setFillMode:kCAFillModeForwards];
    imageAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    imageAnimation.beginTime = 0.6f;
    imageAnimation.duration = 0.4f;

    CAAnimationGroup *groupIcon = [CAAnimationGroup animation];
    [groupIcon setDuration:1.0];
    [groupIcon setRemovedOnCompletion:NO];
    [groupIcon setFillMode:kCAFillModeForwards];
    [groupIcon setAnimations:[NSArray arrayWithObjects:rotationAnimation,imageAnimation,nil]];
    [iconView_.layer addAnimation:groupIcon forKey:nil];

    //hg circle view move in
    CABasicAnimation* imageHgInAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    imageHgInAnimation.fromValue = [NSNumber numberWithFloat:0.0];
    imageHgInAnimation.toValue = [NSNumber numberWithFloat:1.0];
    imageHgInAnimation.autoreverses = NO;
    [imageHgInAnimation setRemovedOnCompletion:NO];
    [imageHgInAnimation setFillMode:kCAFillModeForwards];
    imageHgInAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    imageHgInAnimation.beginTime = 0.3f;
    imageHgInAnimation.duration = 0.7f;

    CAAnimationGroup *hgIcon = [CAAnimationGroup animation];
    [hgIcon setDuration:1.0];
    [hgIcon setRemovedOnCompletion:NO];
    [hgIcon setFillMode:kCAFillModeForwards];
    [hgIcon setAnimations:[NSArray arrayWithObjects:imageHgInAnimation,nil]];
    [hgCircleView_.layer addAnimation:hgIcon forKey:nil];

    isStartAnimation_ = YES;
}
-(void)backAnimations{
    if (isStartAnimation_) {
        //icon view
        CABasicAnimation* rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        rotationAnimation.toValue = [NSNumber numberWithFloat:rotateAngle];
        rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        rotationAnimation.beginTime = 0.2f;
        rotationAnimation.duration = 0.3f;
        [rotationAnimation setRemovedOnCompletion:NO];
        [rotationAnimation setFillMode:kCAFillModeForwards];

        UIImage *hgImage = [actionStrategy_ imageForMove:orientation_ isNormalImage:YES];
        CABasicAnimation* imageAnimation = [CABasicAnimation animationWithKeyPath:@"contents"];
        imageAnimation.fromValue = (id)iconView_.image.CGImage;
        imageAnimation.toValue = (id)hgImage.CGImage;
        imageAnimation.autoreverses = NO;
        [imageAnimation setRemovedOnCompletion:NO];
        [imageAnimation setFillMode:kCAFillModeForwards];
        imageAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        imageAnimation.beginTime = 0.0f;
        imageAnimation.duration = 0.2f;

        CAAnimationGroup *groupIcon = [CAAnimationGroup animation];
        [groupIcon setDuration:0.5];
        [groupIcon setRemovedOnCompletion:NO];
        [groupIcon setFillMode:kCAFillModeForwards];
        [groupIcon setAnimations:[NSArray arrayWithObjects:rotationAnimation,imageAnimation,nil]];
        [iconView_.layer addAnimation:groupIcon forKey:nil];

        //hg circle view move in
        CABasicAnimation* imageHgInAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        imageHgInAnimation.fromValue = [NSNumber numberWithFloat:1.0];
        imageHgInAnimation.toValue = [NSNumber numberWithFloat:0.0];
        imageHgInAnimation.autoreverses = NO;
        [imageHgInAnimation setRemovedOnCompletion:NO];
        [imageHgInAnimation setFillMode:kCAFillModeForwards];
        imageHgInAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        imageHgInAnimation.beginTime = 0.0f;
        imageHgInAnimation.duration = 0.3f;

        CAAnimationGroup *hgIcon = [CAAnimationGroup animation];
        [hgIcon setDuration:0.3];
        [hgIcon setRemovedOnCompletion:NO];
        [hgIcon setFillMode:kCAFillModeForwards];
        [hgIcon setAnimations:[NSArray arrayWithObjects:imageHgInAnimation,nil]];
        [hgCircleView_.layer addAnimation:hgIcon forKey:nil];

        isStartAnimation_ = NO;
    }
}

-(void)setColor
{
    if (orientation_ == MoveOrientationTypeRight) {
        switch ([AppSettingsModel appSettings].listSwipeRight) {
            case CellListFunctionTypeOnCall: {
                [UIView animateWithDuration:0.6 animations:^{
                    [imageBgView_ setBackgroundColor:[[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"common_swipe_call_color"]];}];
                break;
            }
            case CellListFunctionTypeSendSms: {
                [UIView animateWithDuration:0.6 animations:^{
                    [imageBgView_ setBackgroundColor:[[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"common_swipe_sms_color"]];}];
                break;
            }
            default:
                break;
        }

    }else if (orientation_ == MoveOrientationTypeLeft){
        switch ([AppSettingsModel appSettings].listSwipeLeft) {
            case CellListFunctionTypeOnCall: {
                [UIView animateWithDuration:0.6 animations:^{
                    [imageBgView_ setBackgroundColor:[[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"common_swipe_call_color"]];}];
                break;
            }
            case CellListFunctionTypeSendSms: {
                    [UIView animateWithDuration:0.6 animations:^{
                        [imageBgView_ setBackgroundColor:[[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"common_swipe_sms_color"]];}];
                break;
            }
            default:
                break;
        }

    }
}

-(void)setBackColor
{
    [UIView animateWithDuration:0.6 animations:^{
        [imageBgView_ setBackgroundColor:[[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"common_swipe_default_color"]];}];

}

#pragma UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    CGPoint point = [gestureRecognizer locationInView:self];
    BOOL isExcute = NO;
    if (isExcuteAction_) {
        isExcute = isExcuteAction_();
    }
    if (fabs(point.x -startPoint_.x) > fabs(point.y-startPoint_.y)&&isExcute) {
        return YES;
    }else{
        return NO;
    }
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    startPoint_ = [touch locationInView:self];
    return YES;
}
- (void)removeImageView {
    CGFloat oldHeight = userContentView_.frame.size.height;
    userContentView_.frame = CGRectMake(0,0, TPScreenWidth(), oldHeight);
    userContentView_.layer.backgroundColor = [[TPDialerResourceManager sharedManager]
                                              getUIColorFromNumberString:@"defaultCellBackground_color"].CGColor;
    if (imageBgView_) {
        [iconView_.layer removeAllAnimations];
        [imageBgView_ removeFromSuperview];
        iconView_ = nil;
        imageBgView_ = nil;
        hgCircleView_ = nil;
   }
}
- (void)createIconView{
    UIImage *normalIcon = [actionStrategy_ imageForMove:orientation_ isNormalImage:YES];
    iconView_ = [[UIImageView alloc] initWithImage:normalIcon];
    CGFloat y = (self.contentView.frame.size.height - normalIcon.size.height) / 2;
    if (orientation_ == MoveOrientationTypeRight) {
        iconView_ .frame = CGRectMake(0, y, normalIcon.size.width,normalIcon.size.height);
    }else if (orientation_ == MoveOrientationTypeLeft){
        iconView_ .frame = CGRectMake(TPScreenWidth()-normalIcon.size.width, y, normalIcon.size.width,normalIcon.size.height);
    }

    [imageBgView_ addSubview:iconView_];

    isStartAnimation_ = NO;
}
- (void)createImageView{
    userContentView_.layer.backgroundColor = [[TPDialerResourceManager sharedManager]
                                              getUIColorFromNumberString:@"defaultCellBackground_color"].CGColor;


    imageBgView_ = [[UIImageView alloc]init];
    imageBgView_.frame = CGRectMake(0,0, TPScreenWidth(), self.userContentView.frame.size.height);
    [imageBgView_ setBackgroundColor:[[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"common_swipe_default_color"]];
    [self.contentView insertSubview:imageBgView_ belowSubview:userContentView_];

}

- (BOOL)supportLongGestureMode
{
    return YES;
}

- (void)adjustNameAndNumberLabel {
    CGFloat middleSpacer = 4;
    CGFloat cellHeight = self.userContentView.frame.size.height;
    NSMutableArray *labels = [[NSMutableArray alloc] initWithCapacity:2];
    for(UILabel *label in @[nameLabel, numberLabel]) {
        if (!label.isHidden) {
            [labels addObject:label];
        }
    }
    CGFloat totalHeight = 0;
    for(UILabel *label in labels) {
        [self setFillContentHeight:label];
        totalHeight += label.frame.size.height;
    }
    
    if (totalHeight > 0) {
        if (labels.count > 1) {
            totalHeight += middleSpacer;
        }
        CGFloat gY = 0;
        NSInteger count = labels.count;
        for(NSInteger i = 0; i < count; i++) {
            UILabel *label = labels[i];
            CGRect oldFrame = label.frame;
            if (i == 0) {
                gY = (cellHeight - totalHeight) / 2;
            } else {
                gY += middleSpacer;
            }
            label.frame = CGRectMake(oldFrame.origin.x, gY, oldFrame.size.width, oldFrame.size.height);
            gY += label.frame.size.height;
        }
    }
    if (!self.numberLabel.isHidden) {
        CGRect markFrame = markSticker.frame;
        CGFloat offsetY = (self.numberLabel.frame.size.height - markFrame.size.height) / 2;
        markSticker.frame = CGRectMake(markFrame.origin.x, self.numberLabel.frame.origin.y + offsetY, markFrame.size.width, markFrame.size.height);
    }
}
        
- (void) setFillContentHeight:(UILabel *) label {
    if (label == nil) {
        return;
    }
    NSString *testString = @"12ab你好";
    UILabel *testNameLabel = [[UILabel alloc] initWithTitle:testString font:label.font isFillContentSize:YES];
    CGRect oldFrame = label.frame;
    label.frame = CGRectMake(oldFrame.origin.x, oldFrame.origin.y,
                             oldFrame.size.width, testNameLabel.frame.size.height);
}

- (void) adjustHeightOfLabel:(UILabel *)label {
    if (label == nil) {
        return;
    }
    NSString *tmpString = @"123ABC上海";
    CGFloat height = [[UILabel alloc] initWithTitle:tmpString font:label.font isFillContentSize:YES].frame.size.height;
    CGRect oldFrame = label.frame;
    label.frame = CGRectMake(oldFrame.origin.x, oldFrame.origin.y, oldFrame.size.width, height);
}
@end

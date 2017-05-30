//
//  UITableViewCell+TPDExtension.m
//  TouchPalDialer
//
//  Created by weyl on 16/9/19.
//
//

#import "UITableViewCell+TPDExtension.h"
#import <Masonry.h>
#import <UIImageView+WebCache.h>
#import "TPDialerResourceManager.h"



@implementation UITableViewCell (TPDExtension)
ADD_DYNAMIC_PROPERTY(UIView*,tpd_img1,setTpd_img1);
ADD_DYNAMIC_PROPERTY(UILabel*,tpd_label1,setTpd_label1);
ADD_DYNAMIC_PROPERTY(UILabel*,tpd_label2,setTpd_label2);
ADD_DYNAMIC_PROPERTY(UIView*,tpd_img2,setTpd_img2);
ADD_DYNAMIC_PROPERTY(UIView*,tpd_img3,setTpd_img3);
ADD_DYNAMIC_PROPERTY(UIButton*,tpd_container,setTpd_container);
ADD_DYNAMIC_PROPERTY(double (^)(),tpd_getHeight,setTpd_getHeight);
ADD_DYNAMIC_PROPERTY(void (^)(id sender),tpd_action,setTpd_action);

+(UITableViewCell*)tpd_tableViewCellStyle1:(NSArray*)controlArr action:(void(^)(id))block{
    return [UITableViewCell tpd_tableViewCellStyle1:controlArr action:block reuseId:@"tpd_tableViewCellStyle1"];
    
} 

//
+(UITableViewCell*)tpd_tableViewCellStyle1:(NSArray*)controlArr action:(void(^)(id))block reuseId:(NSString*)reuseId{
    
    UIView *img1 = [UIImageView tpd_imageView:controlArr[0]];
    
    UILabel* label1 = [[UILabel tpd_commonLabel] tpd_withText:controlArr[1] color:RGB2UIColor(0x333333)  font:17];
    label1.textAlignment = NSTextAlignmentLeft;
    
    UILabel* label2 = [[UILabel tpd_commonLabel] tpd_withText:controlArr[2] color:RGB2UIColor(0x666666) font:14];
    label2.textAlignment = NSTextAlignmentRight;
    
    UIView *img2 = [UIImageView tpd_imageView:controlArr[3]];
    
    UIButton* container = [UIButton tpd_buttonStyleCommon];
    
    [container addSubview:img1];
    [container addSubview:label1];
    [container addSubview:label2];
    [container addSubview:img2];
    
    [img1 updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(container).offset(15);
        make.centerY.equalTo(container);
    }];
    
    if ([controlArr[0] isEqualToString:@""]) {
        [label1 updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(img1);
            make.centerY.equalTo(img1);
        }];
    }else{
        [label1 updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(img1).offset(30);
            make.centerY.equalTo(img1);
        }];
    }
    
    if ([controlArr[3] isEqualToString:@""]) {
        [label2 updateConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(container).offset(-15);
            make.centerY.equalTo(container);
        }];
    }else{
        [label2 updateConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(img2.left).offset(-15);
            make.centerY.equalTo(container);
        }];
    }
    
    [img2 updateConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(container).offset(-15);
        make.centerY.equalTo(container);
    }];
    
    UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseId];
    cell.backgroundColor = [UIColor whiteColor];
    [cell addSubview:container];
    [container updateConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(cell);
        //        make.cen
    }];
    if (block) {
        [container addBlockEventWithEvent:UIControlEventTouchUpInside withBlock:^{
            block(self);
        }];
    }
    
    cell.tpd_img1 = img1;
    cell.tpd_label1 = label1;
    cell.tpd_label2 = label2;
    cell.tpd_img2 = img2;
    cell.tpd_action = block;
    cell.tpd_container = container;
    
    cell.tpd_label1.lineBreakMode = NSLineBreakByTruncatingTail;
    cell.tpd_label1.numberOfLines = 1;
    
    return cell;
}


+(UITableViewCell*)tpd_tableViewCellStyleImageLabel2:(NSArray*)controlArr action:(void(^)(id))block reuseId:(NSString*)reuseId{
    UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseId];
    [cell tpd_tableViewCellStyleImageLabel2:controlArr action:block reuseId:reuseId];
    
    return cell;
}

-(UITableViewCell*)tpd_tableViewCellStyleImageLabel2:(NSArray*)controlArr action:(void(^)(id))block reuseId:(NSString*)reuseId{
    UIView *img1 = [UIImageView tpd_imageView:controlArr[0]];
    
    UILabel* label1 = [[UILabel tpd_commonLabel] tpd_withText:controlArr[1] color:RGB2UIColor(0x333333) font:15];
    label1.textAlignment = NSTextAlignmentLeft;
    
    UILabel* label2 = [[UILabel tpd_commonLabel] tpd_withText:controlArr[2] color:RGB2UIColor(0x666666) font:14];
    label2.textAlignment = NSTextAlignmentRight;
    
    UIButton* container = [UIButton tpd_buttonStyleCommon];
    
    [container addSubview:img1];
    [container addSubview:label1];
    [container addSubview:label2];
    
    [img1 updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(container).offset(15);
        make.centerY.equalTo(container);
    }];
    
    if ([controlArr[0] isEqualToString:@""]) {
        [label1 updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(img1);
            make.bottom.equalTo(container.centerY);
        }];
    }else{
        [label1 updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(img1).offset(46);
            make.bottom.equalTo(container.centerY);
        }];
    }
     
    [label2 updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(label1);
        make.top.equalTo(container.centerY).offset(5);
    }];
    
    self.backgroundColor = [UIColor whiteColor];
    [self addSubview:container];
    [container updateConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(self);
        //        make.cen
    }];
    if (block) {
        [container addBlockEventWithEvent:UIControlEventTouchUpInside withBlock:^{
            block(self);
        }];
    }
    [container setBackgroundImage:[UIImage tpd_imageWithColor:RGB2UIColor2(244, 244, 244)] forState:UIControlStateHighlighted];

    self.tpd_img1 = img1;
    self.tpd_label1 = label1;
    self.tpd_label2 = label2;
    self.tpd_container = container;
    self.tpd_action = block;
    
    return self;
}

+(UITableViewCell*)tpd_tableViewCellStyleLabelImageLabel:(NSArray*)controlArr action:(void(^)(id sender))block reuseId:(NSString*)reuseId
{
    UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseId];
    [cell tpd_tableViewCellStyleLabelImageLabel:controlArr action:block reuseId:reuseId];
    
    return cell;
}

-(UITableViewCell*)tpd_tableViewCellStyleLabelImageLabel:(NSArray*)controlArr action:(void(^)(id sender))block reuseId:(NSString*)reuseId
{
    UILabel* label1 = [[UILabel tpd_commonLabel] tpd_withText:controlArr[0] color:RGB2UIColor(0x333333) font:18];
    label1.textAlignment = NSTextAlignmentLeft;
    label1.numberOfLines = 1;
    label1.lineBreakMode = NSLineBreakByTruncatingTail;
    
    UIView *img1 = [UIImageView tpd_imageView:controlArr[1]];
    
    UILabel* label2 = [[UILabel tpd_commonLabel] tpd_withText:controlArr[2] color:RGB2UIColor(0x666666) font:12];
    label2.textAlignment = NSTextAlignmentLeft;
    label2.numberOfLines = 2;
    label2.lineBreakMode = NSLineBreakByTruncatingTail;
    
    UIButton* container = [UIButton tpd_buttonStyleCommon];
    
    [container addSubview:img1];
    [container addSubview:label1];
    [container addSubview:label2];
    
    CGFloat width_adapt = TPScreenWidth()/360 > 1 ? TPScreenWidth()/360 : 1;
    CGFloat leftMargin = 14;
    CGFloat topMargin = 14;
    CGFloat topMargin2 = 12;
    if (width_adapt  <= 1.001) {
        leftMargin = leftMargin - 4;
        topMargin = topMargin - 4;
        topMargin2 = topMargin2 - 4;
    }
    
    [img1 updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(container).offset(leftMargin);
        make.right.equalTo(container).offset(-leftMargin);
    }];
    
    [label1 updateConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(img1);
        make.bottom.equalTo(img1.top).offset(-topMargin2);
        make.top.equalTo(container).offset(topMargin);
    }];
    
    [label2 updateConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(img1);
        make.top.equalTo(img1.bottom).offset(topMargin2);
        make.bottom.equalTo(container).offset(-topMargin2);
    }];
    
    self.backgroundColor = [UIColor whiteColor];
    [self addSubview:container];
    [container updateConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(self);
    }];
    if (block) {
        [container addBlockEventWithEvent:UIControlEventTouchUpInside withBlock:^{
            block(self);
        }];
    }
    [container setBackgroundImage:[UIImage tpd_imageWithColor:RGB2UIColor2(244, 244, 244)] forState:UIControlStateHighlighted];
    
    self.tpd_img1 = img1;
    self.tpd_label1 = label1;
    self.tpd_label2 = label2;
    self.tpd_container = container;
    self.tpd_action = block;
    
    return self;
}

+(UITableViewCell*)tpd_tableViewCellStyleLabelImage3Label:(NSArray*)controlArr action:(void(^)(id sender))block reuseId:(NSString*)reuseId
{
    UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseId];
    [cell tpd_tableViewCellStyleLabelImage3Label:controlArr action:block reuseId:reuseId];
    
    return cell;
}

-(UITableViewCell*)tpd_tableViewCellStyleLabelImage3Label:(NSArray*)controlArr action:(void(^)(id sender))block reuseId:(NSString*)reuseId
{
    UIView *img1 = [UIImageView tpd_imageView:controlArr[0]];
    UIView *img2 = [UIImageView tpd_imageView:controlArr[1]];
    UIView *img3 = [UIImageView tpd_imageView:controlArr[2]];
    UIView* imageContaner = [UIView tpd_horizontalGroupWith:@[img1, img2, img3] horizontalPadding:10 verticalPadding:0 interPadding:8 weightArr:@[@1,@1,@1]];
    imageContaner.userInteractionEnabled = NO;
    
    UILabel* label1 = [[UILabel tpd_commonLabel] tpd_withText:controlArr[3] color:RGB2UIColor(0x333333) font:18];
    label1.textAlignment = NSTextAlignmentLeft;
    label1.numberOfLines = 1;
    label1.lineBreakMode = NSLineBreakByTruncatingTail;

    UILabel* label2 = [[UILabel tpd_commonLabel] tpd_withText:controlArr[4] color:RGB2UIColor(0x666666) font:12];
    label2.textAlignment = NSTextAlignmentLeft;
    label2.numberOfLines = 1;
    label2.lineBreakMode = NSLineBreakByTruncatingTail;
    
    UIButton* container = [UIButton tpd_buttonStyleCommon];
    
    [container addSubview:imageContaner];
    [container addSubview:label1];
    [container addSubview:label2];
    CGFloat width_adapt = TPScreenWidth()/360 > 1 ? TPScreenWidth()/360 : 1;
    CGFloat leftMargin = 2;
    CGFloat topMargin = 14;
    CGFloat topMargin2 = 12;
    if (width_adapt  <= 1.001) {
        leftMargin = leftMargin - 4;
        topMargin = topMargin - 4;
        topMargin2 = topMargin2 - 4;
    }
    [imageContaner updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(container).offset(leftMargin);
        make.right.equalTo(container).offset(-leftMargin);
    }];
    
    [label1 updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(container).offset(topMargin);
        make.left.equalTo(imageContaner.left).offset(10);
        make.right.equalTo(imageContaner.right).offset(-10);
        make.bottom.equalTo(img1.top).offset(-topMargin2);
    }];
    
    [label2 updateConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(label1);
        make.top.equalTo(imageContaner.bottom).offset(topMargin2);
        make.bottom.equalTo(container.bottom).offset(-topMargin2);
    }];
    
    self.backgroundColor = [UIColor whiteColor];
    [self addSubview:container];
    [container updateConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    if (block) {
        [container addBlockEventWithEvent:UIControlEventTouchUpInside withBlock:^{
            block(self);
        }];
    }

    [container setBackgroundImage:[UIImage tpd_imageWithColor:RGB2UIColor2(244, 244, 244)] forState:UIControlStateHighlighted];
    
    self.tpd_img1 = img1;
    self.tpd_img2 = img2;
    self.tpd_img3 = img3;
    self.tpd_label1 = label1;
    self.tpd_label2 = label2;
    self.tpd_container = container;
    self.tpd_action = block;
    
    return self;
}

#pragma mark - seperate line

-(UIView*)tpd_withFullSeperateLine{
    return [self tpd_seperateLineWithEdgeInsets:UIEdgeInsetsZero];
}

-(UIView*)tpd_withSeperateLine{
    UIView* sepLine = [[UIView alloc] init];
    sepLine.backgroundColor = RGB2UIColor(0xe0e0e0);
    [self addSubview:sepLine];
    [sepLine updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.right.equalTo(self);
        make.height.equalTo(.5f);
        make.left.equalTo(self.tpd_label1);
    }];
    
    return self;
}

-(UIView*)tpd_seperateLineWithEdgeInsets:(UIEdgeInsets)edgeInsets{
    UIView* sepLineTop = [[UIView alloc] init];
    sepLineTop.backgroundColor = RGB2UIColor(0xe0e0e0);
    [self addSubview:sepLineTop];
    [sepLineTop updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self);
        make.height.equalTo(.5f);
        make.left.equalTo(edgeInsets.left);
        make.right.equalTo(-edgeInsets.right);
    }];
    
    return self;
}

@end

//
//  TPDSheet.m
//  TouchPalDialer
//
//  Created by weyl on 16/11/28.
//
//

#import "TPDSheet.h"
#import "TPDLib.h"
#import "CallLogDataModel.h"
#import <Masonry.h>

@implementation TPDSheet

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+(UIView*)longPressSheet:(id)dataModel ClickAction:(void (^)(UICallLogAction))clickAction{
    WEAK(self)
    CallLogDataModel* d = dataModel;
    UITableViewCell* topCell = [[[[UITableViewCell tpd_tableViewCellStyleImageLabel2:@[@"common_photo_contact_for_list@2x.png", @"12312", @"上海联通"] action:^(id sender) {
    } reuseId:@"TPDLongPressActionSheetCell"] tpd_withHeight:66] tpd_withCornerRadius:10.f] tpd_withBackgroundColor:[UIColor whiteColor]].cast2UITableViewCell;
    
    [topCell.tpd_img1 updateConstraints:^(MASConstraintMaker *make) {
        make.height.width.equalTo(40);
    }];
    [topCell.tpd_img1 tpd_withCornerRadius:20.f];
    topCell.tpd_img1.backgroundColor = RGB2UIColor2(217,217,217);
    
    
    UITableViewCell* callCell = [[UITableViewCell tpd_tableViewCellStyle1:@[@"iphone-ttf:iPhoneIcon4:j:30:tp_color_grey_600",@"呼叫",@"",@""] action:^(id sender) {
//        [weakself cancelLongPress];
//        [weakself makeCall:dataModel];
    }] tpd_withHeight:66].cast2UITableViewCell;
    [callCell.tpd_label1 updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(callCell.tpd_img1).offset(50);
    }];
    [callCell.tpd_container setBackgroundImage:[UIImage tpd_imageWithColor:RGB2UIColor(0xeeeeee)] forState:UIControlStateHighlighted];
    [callCell setTpd_action:^(id sender) {
        clickAction(UICallLogActionPhoneCall);
    }];
    
    UITableViewCell* smsCell = [[UITableViewCell tpd_tableViewCellStyle1:@[@"iphone-ttf:iPhoneIcon5:B:30:tp_color_grey_600",@"短信",@"",@""] action:^(id sender) {
//        [weakself sendMessage:d.number];
//        [weakself clearInput];
//        [weakself showKeyPad:NO];
    }] tpd_withHeight:66].cast2UITableViewCell;
    [smsCell.tpd_label1 updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(smsCell.tpd_img1).offset(50);
    }];
    [smsCell.tpd_container setBackgroundImage:[UIImage tpd_imageWithColor:RGB2UIColor(0xeeeeee)] forState:UIControlStateHighlighted];
    
    UITableViewCell* copyNumCell = [[UITableViewCell tpd_tableViewCellStyle1:@[@"iphone-ttf:iPhoneIcon5:e:30:tp_color_grey_600",@"复制号码",@"",@""] action:^(id sender) {
//        [weakself cancelLongPress];
//        [weakself copyPhoneNumber:dataModel];
    }] tpd_withHeight:66].cast2UITableViewCell;
    [copyNumCell.tpd_label1 updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(copyNumCell.tpd_img1).offset(50);
    }];
    [copyNumCell.tpd_container setBackgroundImage:[UIImage tpd_imageWithColor:RGB2UIColor(0xeeeeee)] forState:UIControlStateHighlighted];
    
    
    UITableViewCell* newContactCell = [[UITableViewCell tpd_tableViewCellStyle1:@[@"iphone-ttf:iPhoneIcon4:i:30:tp_color_grey_600",@"新建联系人",@"",@""] action:^(id sender) {
        
    }] tpd_withHeight:66].cast2UITableViewCell;
    [newContactCell.tpd_label1 updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(newContactCell.tpd_img1).offset(50);
    }];
    [newContactCell.tpd_container setBackgroundImage:[UIImage tpd_imageWithColor:RGB2UIColor(0xeeeeee)] forState:UIControlStateHighlighted];
    
    UITableViewCell* addContactCell = [[UITableViewCell tpd_tableViewCellStyle1:@[@"iphone-ttf:iPhoneIcon4:e:30:tp_color_grey_600",@"添加到现有联系人",@"",@""] action:^(id sender) {
        
    }] tpd_withHeight:66].cast2UITableViewCell;
    [addContactCell.tpd_label1 updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(addContactCell.tpd_img1).offset(50);
    }];
    [addContactCell.tpd_container setBackgroundImage:[UIImage tpd_imageWithColor:RGB2UIColor(0xeeeeee)] forState:UIControlStateHighlighted];
    
    NSArray* displayedCells = nil;
    
    if ([[dataModel name] length] > 0) {
        displayedCells = @[[callCell tpd_seperateLineWithEdgeInsets:UIEdgeInsetsMake(0, 15, 0, 0)],[smsCell tpd_seperateLineWithEdgeInsets:UIEdgeInsetsMake(0, 15, 0, 0)],[copyNumCell tpd_seperateLineWithEdgeInsets:UIEdgeInsetsMake(0, 15, 0, 0)]];
    }else{
        displayedCells = @[[callCell tpd_seperateLineWithEdgeInsets:UIEdgeInsetsMake(0, 15, 0, 0)],[smsCell tpd_seperateLineWithEdgeInsets:UIEdgeInsetsMake(0, 15, 0, 0)],[copyNumCell tpd_seperateLineWithEdgeInsets:UIEdgeInsetsMake(0, 15, 0, 0)],[newContactCell tpd_seperateLineWithEdgeInsets:UIEdgeInsetsMake(0, 15, 0, 0)],[addContactCell tpd_seperateLineWithEdgeInsets:UIEdgeInsetsMake(0, 15, 0, 0)]];
    }
    
    
    UIView* wrapper = [[[[[UIView alloc] init] tpd_addSubviewsWithVerticalLayout:displayedCells offsets:@[@0,@0,@0,@0,@0]] tpd_withCornerRadius:10.f] tpd_withBackgroundColor:[UIColor whiteColor]];
    
    
    UIView* wrapper2 = [[[[UIView alloc] init] tpd_addSubviewsWithVerticalLayout:@[topCell, wrapper] offsets:@[@0,@15]] tpd_wrapperWithEdgeInsets:UIEdgeInsetsMake(20, 20, 20, 20)];
    
    UIView* ret = [wrapper2 tpd_maskViewContainer:^(id sender) {
        
    }];
    
    
    [wrapper2 makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(ret);
        make.top.equalTo(ret.bottom);
    }];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [wrapper2 remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(ret);
        }];
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            [ret layoutIfNeeded];
        } completion:^(BOOL finished){
            
        }];
    });
    
    return ret;
}


+(UIView*)contactOperationSheet{
    
    
    
}
@end

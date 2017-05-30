//
//  HangupHeaderView.h
//  TouchPalDialer
//
//  Created by Liangxiu on 15/6/9.
//
//

#import <UIKit/UIKit.h>
#import "HangupViewModelGenerator.h"
#import "CallViewController.h"


@interface HangupHeaderView : UIView
- (id)initWithModel:(HeaderViewModel *)model;
- (instancetype)initWithNumber:(NSString *)number callMode:(CallMode)callMode;
- (instancetype)initWithNumberArr:(NSArray *)numberArr callMode:(CallMode)callMode ;
@property (nonatomic) UILabel *mainLabel;
@property (nonatomic) UILabel *altLabel;

@end


@interface OnCallHeaderVeiw: HangupHeaderView
@end

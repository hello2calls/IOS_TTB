//
//  SelectCellView.h
//  TouchPalDialer
//
//  Created by Alice on 11-8-23.
//  Copyright 2011 Cootek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SelectViewProtocal.h"
#import "FaceSticker.h"
#import "CootekTableViewCell.h"
#import "HighLightLabel.h"
#import "ContractResultModel.h"
#import "ContactCacheDataModel.h"
#import "BaseContactCell.h"

@interface SelectCellView : BaseContactCell {
	NSInteger personID;
	BOOL isChecked;
	
	NSString *fullName;
    NSString *attrName;
	NSString *m_main_number;

	id<SelectViewProtocalDelegate> __unsafe_unretained select_delegate;
    UILabel *select_image_view;
    BOOL needShowNumber_;
}

@property(nonatomic,assign)NSInteger personID;
@property(nonatomic,assign)BOOL	isChecked;
@property(nonatomic,assign)BOOL	isSingleCheckMode;

@property(nonatomic,retain)UILabel *select_image_view;

@property(nonatomic,retain)NSString *fullName;
@property(nonatomic,retain)NSString *attrName;
@property(nonatomic,retain)NSString *m_main_number;
@property(nonatomic,assign)id<SelectViewProtocalDelegate>select_delegate;
@property(nonatomic,retain) UILabel *partBottomLine;

- (void)loadPersonData:(UIImage *)imgPhoto withNumberRange:(NSRange)numberRange withNameRange:(NSMutableArray *)nameArray withShowNumber:(BOOL)is_show;
- (void)refreshDefault:(ContactCacheDataModel *)person  withIsCheck:(BOOL)is_check;
- (void)refreshDefault:(ContactCacheDataModel *)person  withIsCheck:(BOOL)is_check isShowNumber:(BOOL)is_show;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
- (void)refreshSearchData:(ContractResultModel *)personSearchData withIsCheck:(BOOL)is_check;
- (void)setCheckImage;
- (void)hideBottomLine;
- (void)showBottomLine;
@end

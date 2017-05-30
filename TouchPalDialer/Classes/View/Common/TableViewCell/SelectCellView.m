//
//  SelectCellView.m
//  TouchPalDialer
//
//  Created by Alice on 11-8-23.
//  Copyright 2011 Cootek. All rights reserved.
//

#import "SelectCellView.h"
#import "ContactCacheDataManager.h"
#import "Person.h"
#import "HighLightLabel.h"
#import "PhoneNumber.h"
#import "NumberPersonMappingModel.h"
#import "CootekNotifications.h"
#import "ImageCacheModel.h"
#import "UIView+WithSkin.h"
#import "TPDialerResourceManager.h"
#import "SkinHandler.h"
#import "NSString+PhoneNumber.h"
#import "PersonDBA.h"
#import "AllViewController.h"
#import "FunctionUtility.h"
#import "TouchpalMembersManager.h"
#import "UserDefaultsManager.h"

@implementation SelectCellView
@synthesize personID;
@synthesize isChecked;
@synthesize fullName;
@synthesize attrName;
@synthesize select_image_view;
@synthesize select_delegate;
@synthesize m_main_number;
@synthesize isSingleCheckMode;
@synthesize partBottomLine;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
		self.backgroundColor = [UIColor clearColor];
        
        CGRect contentFrame = CGRectMake(0, 0, TPScreenWidth() - INDEX_SECTION_VIEW_WIDTH, CONTACT_CELL_HEIGHT);
        self.userContentView.frame = contentFrame;
        
        //check Image
        // ticker
        // right margin of the ticker is 15dp
        CGFloat tickerLength = 25;
        UILabel *select_img_view=[[UILabel alloc] initWithFrame:
                    CGRectMake(contentFrame.size.width - tickerLength - 15,
                               (contentFrame.size.height - tickerLength) / 2,tickerLength,
                               tickerLength)];
        select_img_view.text = @"v";
        select_img_view.font = [UIFont fontWithName:@"iPhoneIcon2" size:24];
        select_img_view.textColor = [TPDialerResourceManager getColorForStyle:@"selectViewButtonArrowColor_normal_color"];
		self.select_image_view = select_img_view;
        
        CGFloat lineHeight = 0.5;
        UIColor *lineColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"baseContactCell_downSeparateLine_color"];
        partBottomLine = [[UILabel alloc]initWithFrame:CGRectMake(CONTACT_CELL_MARGIN_LEFT, contentFrame.size.height - lineHeight, contentFrame.size.width - CONTACT_CELL_MARGIN_LEFT, lineHeight)];
        partBottomLine.backgroundColor = lineColor;
        
//        [FunctionUtility setBorderForViewArray:@[select_img_view, partBottomLine, self.faceSticker, self.userContentView]];
        
        // view settings
        self.numberLabel.hidden = YES;
        self.nameLabel.hidden = NO;
        
        [self adjustNameAndNumberLabel];
        
        // view tree
        [self.userContentView addSubview:select_img_view];
        [self addSubview:partBottomLine];
    }
    return self;
}

- (void)hideBottomLine {
    partBottomLine.hidden = YES;
}
- (void)showBottomLine {
    partBottomLine.hidden = NO;
}

- (void)refreshDefault:(ContactCacheDataModel *)person  withIsCheck:(BOOL)is_check{
    [self refreshDefault:person withIsCheck:is_check isShowNumber:NO];
}
-(void)refreshDefault:(ContactCacheDataModel *)person  withIsCheck:(BOOL)is_check isShowNumber:(BOOL)is_show{
    self.backgroundColor = [UIColor clearColor];
    // Initialization code.
    self.isChecked = is_check;
    
    ContactCacheDataModel *person_tmp = (ContactCacheDataModel *)person;
    self.personID = person_tmp.personID;
    PhoneDataModel *phone = (PhoneDataModel *)[person_tmp mainPhone];
    self.m_main_number = phone.number;
    self.attrName = [m_main_number formatPhoneNumber];
    
    ContactCacheDataModel *model = [[ContactCacheDataManager instance] contactCacheItem:personID];
    self.fullName = model.displayName;
    
    UIImage* defaultFacePhoto = [model image];
    if (!defaultFacePhoto) {
        defaultFacePhoto =  [PersonDBA getDefaultImageByPersonID:self.personID
                                                    isCootekUser:[TouchpalMembersManager isRegisteredByContactCachedModel:model]];
    }
    [self loadPersonData:defaultFacePhoto withNumberRange:NSMakeRange(0, 0) withNameRange:nil withShowNumber:is_show];
    
}
- (void)loadPersonData:(UIImage *)imgPhoto withNumberRange:(NSRange)numberRange withNameRange:(NSMutableArray *)nameArray withShowNumber:(BOOL)is_show{
    if (!isSingleCheckMode) {
        if (isChecked) {
            select_image_view.textColor = [TPDialerResourceManager getColorForStyle:[SelectCellView colorString]];
        }else {
            select_image_view.textColor = [TPDialerResourceManager getColorForStyle:@"selectViewButtonArrowColor_normal_color"];
        }
    }
    if([self.fullName length] == 0){
        self.fullName = NSLocalizedString(@"(No name)",@"(No name)");
    }
    NSArray *elements = nil;
    if (nameArray) {
        elements = [TPRichLabelUtils createHighlightElements:fullName
                                                   textColor:self.textNameColor
                                                 httextColor:self.htNameTextColor
                                                        font:[UIFont systemFontOfSize:CELL_FONT_LARGE]
                                                   highlight:nameArray];
        
        
    }else{
        elements = [TPRichLabelUtils createDefaultElements:fullName
                                                 textColor:self.textNameColor
                                                      font:[UIFont systemFontOfSize:CELL_FONT_LARGE]];
    }
    self.nameLabel.elements = elements;
    if (is_show) {
        needShowNumber_ = YES;
        NSRange range = {0,0};
        if (NSEqualRanges(numberRange,range)) {
            elements = [TPRichLabelUtils createDefaultElements:self.attrName
                                                     textColor:self.textNumberColor
                                                          font:[UIFont systemFontOfSize:CELL_FONT_SMALL]];
        }else{
            elements = [TPRichLabelUtils createNumberHighlightElements:self.attrName
                                                             textColor:self.textNumberColor
                                                           httextColor:self.htNumberColor
                                                                  font:[UIFont systemFontOfSize:CELL_FONT_SMALL]
                                                             highlight:numberRange];
        }
        self.numberLabel.elements = elements;
    }else{
        needShowNumber_ = NO;
    }
    
    self.faceSticker.headImageView.image = imgPhoto;
    self.faceSticker.typeLabel.text = @"";
	self.faceSticker.currentNumber=self.m_main_number;
	self.faceSticker.personID = self.personID;
}
-(void)refreshSearchData:(ContractResultModel *)personSearchData withIsCheck:(BOOL)is_check
{
	ContractResultModel *person_tmp=(ContractResultModel *)personSearchData;
    self.personID=person_tmp.personID;
	self.isChecked = is_check;
    self.fullName = person_tmp.name;
    self.attrName = [person_tmp.number formatPhoneNumber];
    
    if (isSingleCheckMode) {
        self.m_main_number = self.attrName;
    }
	
    NSRange hit_number_range = NSMakeRange(0, 0);
	if (person_tmp.name == nil || [person_tmp.hitNameInfo count] == 0) {
		hit_number_range = person_tmp.hitNumberInfo;
	}
    
	ContactCacheDataModel *person_img = [[ContactCacheDataManager instance] contactCacheItem:personID];
	self.m_main_number = [person_img mainPhone].number;
    if (person_tmp.number != nil) {
        self.m_main_number = person_tmp.number;
    }
    UIImage* defaultFacePhoto = [person_img image];
    if (defaultFacePhoto == nil) {
        defaultFacePhoto =  [PersonDBA getDefaultImageByPersonID:self.personID
                                isCootekUser:[TouchpalMembersManager isRegisteredByPersonId:self.personID]];
    }
    [self loadPersonData:defaultFacePhoto withNumberRange:hit_number_range withNameRange:person_tmp.hitNameInfo withShowNumber:YES];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}
- (void)setCheckImage{
	self.isChecked=!isChecked;
	SelectModel *item=[[SelectModel alloc] init];
	item.personID=self.personID;
	item.isChecked=self.isChecked;
    item.number = self.m_main_number;
    if (isSingleCheckMode) {
        [select_delegate selectItem:item withObject:self];
    }else {
        if(isChecked) {
            select_image_view.textColor = [TPDialerResourceManager getColorForStyle:[SelectCellView colorString]];
        }
        else {
            select_image_view.textColor = [TPDialerResourceManager getColorForStyle:@"selectViewButtonArrowColor_normal_color"];
        }
        [select_delegate selectItem:item];
    }
}
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)layoutSubviews{
    [super layoutSubviews];
//    CGFloat labelRightGap = isSingleCheckMode ? 0 : 50;
    if (!needShowNumber_) {
//        self.nameLabel.frame = CGRectMake(55, IOS8 ? 21 : 17, 260 - labelRightGap, 30);
//        self.faceSticker.frame = CGRectMake(5 ,8 ,40,40);
//        self.numberLabel.frame = CGRectMake(55, 30+2.5, 260 - labelRightGap, 20);
    }else {
//        self.nameLabel.frame = CGRectMake(55, IOS8 ? 12 : 9, 260 - labelRightGap, 25);
//        self.faceSticker.frame = CGRectMake(5 ,8 ,40,40);
//        self.numberLabel.frame = CGRectMake(55, 30+2.5, 260 - labelRightGap, 20);
    }
}
+ (NSString *)colorString {
    if ([UserDefaultsManager boolValueForKey:ENABLE_V6_TEST_ME defaultValue:NO]) {
        return @"skinSectionIndexPopupBackground_color";
    }else{
        return @"selectViewButtonArrowColor_pressed_color";
    }
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    [SkinHandler removeRecursively:self];
}
@end

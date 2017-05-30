//
//  ContactSearchResultCell.m
//  TouchPalDialer
//
//  Created by Sendor on 11-8-22.
//  Copyright 2011 Cootek. All rights reserved.
//

#import "ContactSearchResultCell.h"
#import "Person.h"
#import "PersonDBA.h"
#import "CallStatusFaceView.h"
#import "NumberPersonMappingModel.h"
#import "FunctionUtility.h"
#import "ContactCacheDataManager.h"
#import "TPDialerResourceManager.h"
#import "UIView+WithSkin.h"
#import "SkinHandler.h"
#import "TPDrawRich.h"
#import "TouchpalMembersManager.h"
#import "UserDefaultsManager.h"
#import "AllViewController.h"
#import "UILabel+DynamicHeight.h"
#import "UILabel+TPHelper.h"

@interface ContactSearchResultCell ()
@property (nonatomic,retain) UIColor *textColor;
@property (nonatomic,retain) UIColor *hgTextColor;
@end

static const NSInteger TAG_FACE = 101;
static const NSInteger TAG_MAIN_TITLE = 102;
static const NSInteger TAG_ALT_TITLE = 103;
static const NSInteger TAG_MAIN_SINGLE_TITLE = 104;
static const NSInteger TAG_ATTACH_SINGLE_TITLE = 105;

static CGFloat sCootekUserViewWidth = 0.0;
static CGFloat sCootekUserViewHeight = 0.0;

@implementation ContactSearchResultCell {
    CGRect _contentFrame;
    CGFloat _mainLabelHeight;
    CGFloat _altLabelHeight;
}

@synthesize currentData;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code.
    }
    return self;
}

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier 
     withContactData:(ContractResultModel*)searchContactData {

    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CGRect contentFrame = CGRectMake(0, 0, TPScreenWidth(), CONTACT_CELL_HEIGHT);
        _contentFrame = contentFrame;
        // Image
		self.backgroundColor=[UIColor clearColor];
		self.contentView.backgroundColor=[UIColor clearColor];
        
        // face view, user's avatar image
        CallStatusFaceView* face = [[CallStatusFaceView alloc] initWithFrame:CGRectMake(CONTACT_CELL_LEFT_GAP, (contentFrame.size.height - CONTACT_CELL_PHOTO_DIAMETER) / 2, CONTACT_CELL_PHOTO_DIAMETER, CONTACT_CELL_PHOTO_DIAMETER)];
        face.tag = TAG_FACE;
        
        // background view
        UIView *selectedView = [[UIView alloc] initWithFrame:contentFrame];
        selectedView.backgroundColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"defaultCellSelected_color"];
        self.selectedBackgroundView = selectedView;
        
        // text colors
        self.hgTextColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"highlightLabel_highlight_color"];
        self.textColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"highlightLabel_text_color"];
        
        // operation view when long expressed
        self.operViewCon = [[UIView alloc] initWithFrame:CGRectMake(0, CONTACT_CELL_HEIGHT, contentFrame.size.width, contentFrame.size.height)];
        self.operViewCon.hidden = YES;
        CGAffineTransform trans = CGAffineTransformScale(self.operViewCon.transform, 1.0, 0.01);
        self.operViewCon.transform = trans;
        
        
        // badge for cootek user
        CGSize userViewSize = CGSizeMake(60, 20);
        UIFont *font = [UIFont fontWithName:@"iPhoneIcon3" size:18];
        NSString *userIconString = NSLocalizedString(@"voip_cootek_user_label", "");
        if (sCootekUserViewWidth == 0) {
            [self calculateCootekUserViewSizeByText:userIconString font:font];
        }
        _ifCootekUserView = [[UILabel alloc] initWithFrame:CGRectMake(contentFrame.size.width - CONTACT_CELL_PHOTO_MARGIN_RIGHT - sCootekUserViewWidth, (contentFrame.size.height - sCootekUserViewHeight) / 2, sCootekUserViewWidth, sCootekUserViewHeight)];
        _ifCootekUserView.text = userIconString;
        _ifCootekUserView.font = font;
        _ifCootekUserView.hidden = YES;
        
        _ifCootekUserView.textColor = [TPDialerResourceManager getColorForStyle:@"voip_cootekUser_label_color"];
        _ifCootekUserView.backgroundColor = [UIColor clearColor];
        
        // main title
        CGFloat textAreaWith = (contentFrame.size.width - CONTACT_CELL_MARGIN_LEFT - userViewSize.width - CONTACT_CELL_PHOTO_MARGIN_RIGHT);
        _mainLabelHeight = 20;
        _altLabelHeight = 18;
        CGFloat mainLabelY = (contentFrame.size.height - _mainLabelHeight - _altLabelHeight - 6) / 2;
        CGFloat altLabelY = mainLabelY + _mainLabelHeight + 6;
        UILabel* mainTitle = [[UILabel alloc] initWithFrame:CGRectMake(CONTACT_CELL_MARGIN_LEFT, mainLabelY, textAreaWith, _mainLabelHeight)];
        mainTitle.tag = TAG_MAIN_TITLE;
        
        // alt title
        TPRichLabel *altTitle = [[TPRichLabel alloc] initWithFrame:CGRectMake(CONTACT_CELL_MARGIN_LEFT, altLabelY, textAreaWith, _altLabelHeight)];
        altTitle.tag = TAG_ALT_TITLE;
        
        // name title
        TPRichLabel *nameLabel = [[TPRichLabel alloc] initWithFrame:CGRectMake(CONTACT_CELL_MARGIN_LEFT, mainLabelY, textAreaWith, _mainLabelHeight)];
        nameLabel.tag = TAG_MAIN_SINGLE_TITLE;
        
        // number label
        TPRichLabel *numberLabel = [[TPRichLabel alloc] initWithFrame:CGRectMake(CONTACT_CELL_MARGIN_LEFT, mainLabelY, textAreaWith, _mainLabelHeight)];
        numberLabel.tag = TAG_ATTACH_SINGLE_TITLE;
        
        // view tree
        [self addSubview:self.operViewCon];
        [self.contentView addSubview:face];
        [self.contentView addSubview:mainTitle];
        [self.contentView addSubview:altTitle];
        [self.contentView addSubview:nameLabel];
        [self.contentView addSubview:numberLabel];
        [self.contentView addSubview:_ifCootekUserView];
        
        // update data
        [self updateData:searchContactData];
        
//        [FunctionUtility setBorderForViewArray:@[self, face, mainTitle, altTitle, nameLabel, numberLabel, _ifCootekUserView]];
//        [FunctionUtility setBorderForView:numberLabel colorStyle:@"tp_color_blue_500"];
        
    }
    return self;
}

- (void) updateData:(ContractResultModel *)data {
    self.currentData = data;
    
    UIView* mainTitle = [self.contentView viewWithTag:TAG_MAIN_TITLE];
    UIView* altTitle = [self.contentView viewWithTag:TAG_ALT_TITLE];
    UIView* nameLabel = [self.contentView viewWithTag:TAG_MAIN_SINGLE_TITLE];
    UIView* numberLabel = [self.contentView viewWithTag:TAG_ATTACH_SINGLE_TITLE];
    
    mainTitle.hidden = YES;
    altTitle.hidden = YES;
    nameLabel.hidden = YES;
    numberLabel.hidden = YES;
    
    if (currentData.name && [currentData.hitNameInfo count] > 0) {
        [self addMainInfoAsSingleTitle:currentData];
    } else {
        if ([FunctionUtility isNilOrEmptyString:currentData.name]) {
            [self addAttachInfoAsSingleTitle:currentData];
        } else {
            [self addNameAsMainTitle:currentData.name];
            [self addAttachInfoAsSubTitle:currentData];
        }
    }
    
    ContactCacheDataModel* personData = [[ContactCacheDataManager instance] contactCacheItem:currentData.personID];
    _ifCootekUserView.hidden = ![TouchpalMembersManager isRegisteredByContactCachedModel:personData];
    
    UIImage *tmpImg = [PersonDBA getImageByRecordID:currentData.personID];
    if (!tmpImg) {
        tmpImg = [PersonDBA getDefaultImageByPersonID:currentData.personID
                                         isCootekUser:!self.ifCootekUserView.hidden];
    }
    CallStatusFaceView* face = (CallStatusFaceView*)[self.contentView viewWithTag:TAG_FACE];
    [face setFaceImage:tmpImg];
}

- (void)showAnimation {
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionTransitionFlipFromTop
                     animations:^{
                         self.operViewCon.transform = CGAffineTransformScale(self.operViewCon.transform, 1.0, 100.0);
                     }
                     completion:nil];
    [UIView animateWithDuration:0.2f animations:^(){
        self.operViewCon.frame = CGRectMake(0, CONTACT_CELL_HEIGHT, TPScreenWidth(), CONTACT_CELL_HEIGHT);
    }completion:^(BOOL finished){}];
}

- (void)exitAnimation {
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.operViewCon.transform = CGAffineTransformScale(self.operViewCon.transform, 1.0, 0.01);
                     }
                     completion:nil];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}

- (void)dealloc {
    [SkinHandler removeRecursively:self];
}

- (void)addNameAsMainTitle:(NSString*)name {
    UILabel* mainTitle = (UILabel*)[self.contentView viewWithTag:TAG_MAIN_TITLE];
    mainTitle.hidden = NO;
    mainTitle.text = name;
    mainTitle.font = [UIFont systemFontOfSize:CELL_FONT_LARGE];
    mainTitle.backgroundColor = [UIColor clearColor];
    mainTitle.textColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"defaultCellMainText_color"];
}

- (void)addAttachInfoAsSubTitle:(ContractResultModel*)searchContactData{
    NSArray *elements;
    elements = [TPRichLabelUtils createNumberHighlightElements:searchContactData.number
                                                     textColor:[[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"defaultCellDetailText_color"]
                                                   httextColor:self.hgTextColor
                                                          font:[UIFont systemFontOfSize:CELL_FONT_SMALL]
                                                     highlight:[searchContactData hitNumberInfo]];
    TPRichLabel *numberLabel = (TPRichLabel*)[self.contentView viewWithTag:TAG_ALT_TITLE];
    numberLabel.hidden = NO;
    numberLabel.backgroundColor = [UIColor clearColor];
    numberLabel.elements = elements;
}

- (void)addMainInfoAsSingleTitle:(ContractResultModel*)searchContactData {
    NSArray *elements;
    NSArray *hitNameInfo = [searchContactData hitNameInfo];
    if(hitNameInfo){
        elements = [TPRichLabelUtils createHighlightElements:searchContactData.name
                                                   textColor:self.textColor
                                                 httextColor:self.hgTextColor
                                                        font:[UIFont systemFontOfSize:CELL_FONT_LARGE]
                                                   highlight:hitNameInfo];
    }else{
        elements = [TPRichLabelUtils createDefaultElements:searchContactData.name
                                                 textColor:self.textColor
                                                      font:[UIFont systemFontOfSize:CELL_FONT_LARGE]];
    }
    TPRichLabel *nameLabel = (TPRichLabel*)[self.contentView viewWithTag:TAG_MAIN_SINGLE_TITLE];
    CGFloat y = (_contentFrame.size.height - _mainLabelHeight) / 2;
    [FunctionUtility setY:y forView:nameLabel];
    nameLabel.hidden = NO;
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.elements = elements;
}

- (void)addAttachInfoAsSingleTitle:(ContractResultModel*)searchContactData {
    NSArray *elements;
    elements = [TPRichLabelUtils createNumberHighlightElements:searchContactData.number
                                                     textColor:self.textColor
                                                   httextColor:self.hgTextColor
                                                          font:[UIFont systemFontOfSize:CELL_FONT_LARGE]
                                                     highlight:[searchContactData hitNumberInfo]];
    TPRichLabel *numberLabel = (TPRichLabel*)[self.contentView viewWithTag:TAG_ATTACH_SINGLE_TITLE];
    CGFloat y = (_contentFrame.size.height - _mainLabelHeight) / 2;
    [FunctionUtility setY:y forView:numberLabel];
    numberLabel.hidden = NO;
    numberLabel.backgroundColor = [UIColor clearColor];
    numberLabel.elements = elements;
}

- (BOOL)supportLongGestureMode
{
    return YES;
}

- (void)setLongGestureMode:(BOOL)inLongGesture {
    // do nothing
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    CGContextFillRect(context, rect);
    
    //下分割线
    UIColor *color = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"baseContactCell_downSeparateLine_color"];
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    CGFloat lineHeight = 0.5;
    CGContextStrokeRect(context, CGRectMake(CONTACT_CELL_MARGIN_LEFT, rect.size.height - lineHeight, rect.size.width - CONTACT_CELL_MARGIN_LEFT, lineHeight));
}

#pragma mark view helper
/**
 *  calculate the CGSize the cootek user view
 */
- (void) calculateCootekUserViewSizeByText:(NSString *)userIconString font:(UIFont *)font {
    UILabel *label = [[UILabel alloc] initWithTitle:userIconString font:font isFillContentSize:YES];
    CGSize size = label.frame.size;
    sCootekUserViewWidth = size.width;
    sCootekUserViewHeight = size.height;
}

@end

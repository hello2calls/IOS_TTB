//
//  ContactInfoViewCopyController.m
//  TouchPalDialer
//
//  Created by H L on 2016/11/16.
//
//

#import "ContactInfoViewCopyController.h"

//#import "ContactInfoViewController.h"
#import "TPDialerResourceManager.h"
#import "ContactInfoMainView.h"
#import "ContactInfoButtonView.h"
#import "ContactInfoCellModel.h"
#import "ContactInfoHeaderView.h"
#import "CootekNotifications.h"
#import "UserDefaultsManager.h"
#import "TouchpalMembersManager.h"
#import "ContactCacheDataModel.h"
#import "ContactCacheDataManager.h"
#import "ContactInfoModel.h"
#import "TPDialerResourceManager.h"
#import "TPHeaderButton.h"
#import "ContactInfoButtonView.h"
#import "FunctionUtility.h"
#import "TouchPalMembersManager.h"
#import "FunctionUtility.h"
#import "ContactCacheDataManager.h"
#import "TPDialerResourceManager.h"
#import "ContactInfoButtonModel.h"
#import "TPDialerResourceManager.h"
#import "ContactInfoCellModel.h"
#import "TPDialerResourceManager.h"
#import "FunctionUtility.h"
#import "ScrollViewButton.h"
#import "UserDefaultsManager.h"
#import "FunctionUtility.h"

#define MAIN_HEIGHT ((TPScreenHeight()>600)?280:(240+TPHeaderBarHeightDiff()))
#define CIRCLE_HEIGHT (TPScreenHeight()>600?106:86)


#define MAIN_HEIGHT ((TPScreenHeight()>600)?280:(240+TPHeaderBarHeightDiff()))
#define kBlueColor [UIColor colorWithRed:3/255.f green:169/255.f blue:244/255.f alpha:1]
#define kGrayColor [UIColor colorWithRed:153/255.f green:153/255.f blue:153/255.f alpha:1]
#define kSeparateLineColor [UIColor colorWithRed:238/255.f green:238/255.f blue:238/255.f alpha:1]

@interface ColorTool : NSObject
//
+ (UIColor *)getHighLightColor ;

@end
@implementation ColorTool
+ (UIColor *)getHighLightColor {
    return [TPDialerResourceManager getColorForStyle:@"skinDefaultHighlightText_color"];
}

@end

@protocol TPContactInfoCellProtocol <NSObject>
- (void)onCellRightButtonPressed:(ContactInfoCellModel *)model;
@end

@interface ContactInfoCellCopy : UITableViewCell
@property (nonatomic,assign) id<TPContactInfoCellProtocol> delegate;
- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier
         ContactInfoCellModel:(ContactInfoCellModel *)model
                     personId:(NSInteger)personId;
- (void)refreshView:(ContactInfoCellModel *)model;
- (void)showBottomLine;
- (void)hideBottomLine;
@end

@interface ContactInfoCellCopy(){
    ContactInfoCellModel *_model;
    
    UILabel *_mainLabel;
    UILabel *_subLabel;
    
    ScrollViewButton *_rightButton;
    UILabel *_rightMiddleIcon;
    
    UIView *_bottomLine;
    UIImageView *_invitingImageView;
}

@end

@implementation ContactInfoCellCopy

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier
         ContactInfoCellModel:(ContactInfoCellModel *)model
                     personId:(NSInteger)personId{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if ( self ){
        _model = model;
        
        self.contentView.backgroundColor = [UIColor whiteColor];
        UIView *view_bg = [[UIView alloc]initWithFrame:self.frame];
        view_bg.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_black_transparency_100"];
        self.selectedBackgroundView = view_bg;
        
        _mainLabel = [[UILabel alloc]initWithFrame:CGRectMake(16, 12, TPScreenWidth()-32, 20)];
        _mainLabel.backgroundColor = [UIColor clearColor];
        _mainLabel.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_800"];
        _mainLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:17];
        _mainLabel.numberOfLines = 0;
        _mainLabel.text = model.mainStr;
        [self addSubview:_mainLabel];
        
        _subLabel = [[UILabel alloc]initWithFrame:CGRectMake(16, 40, TPScreenWidth()-32, 14)];
        _subLabel.backgroundColor = [UIColor clearColor];
        _subLabel.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_400"];
        _subLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:13];
        _subLabel.text = model.subStr;
        [self addSubview:_subLabel];
        
        UIColor *buttonColor = [TPDialerResourceManager getColorForStyle:@"skinDefaultHighlightText_color"];
        
        _rightButton = [[ScrollViewButton alloc]initWithFrame:CGRectMake(TPScreenWidth() - 60, 0, 60, 66)];
        _rightButton.highlightColor = [TPDialerResourceManager getColorForStyle:@"tp_color_black_transparency_100"];
        _rightButton.titleLabel.font = [UIFont fontWithName:@"iPhoneIcon5" size:24];
        [_rightButton setTitleColor:buttonColor forState:UIControlStateNormal];
        [_rightButton addTarget:self action:@selector(onCellRightButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_rightButton];
        
        _rightMiddleIcon = [[UILabel alloc]initWithFrame:CGRectMake(TPScreenWidth() - 120, 0, 60, 66)];
        _rightMiddleIcon.backgroundColor = [UIColor clearColor];
        _rightMiddleIcon.font = [UIFont fontWithName:@"iPhoneIcon3" size:24];
        _rightMiddleIcon.textAlignment = NSTextAlignmentCenter;
        _rightMiddleIcon.textColor = buttonColor;
        [self addSubview:_rightMiddleIcon];
        
        _bottomLine = [[UIView alloc]initWithFrame:CGRectMake(16 , 63.5, TPScreenWidth()-16, 0.5)];
        _bottomLine.backgroundColor = kSeparateLineColor;//[TPDialerResourceManager getColorForStyle:@"tp_color_grey_150"];
        [self addSubview:_bottomLine];
        
        [self showButton];
        [self adjustHeight];
    }
    
    return self;
}

- (void)showBottomLine{
    _bottomLine.hidden = NO;
}

- (void)hideBottomLine{
    _bottomLine.hidden = YES;
}

- (void)adjustHeight{
    CGSize mainSize = [_model.mainStr sizeWithFont:[UIFont fontWithName:@"Helvetica-Light" size:17]
                                 constrainedToSize:CGSizeMake(TPScreenWidth()-32, 100)];
    NSInteger mainLabelHeight = ceil(mainSize.height) > 20? ceil(mainSize.height) : 20;
    CGFloat cellHeight = mainLabelHeight + 46 > 66 ? mainLabelHeight + 48 : 66;
    switch (_model.cellType) {
        case CellPhone:
        case CellInviting:
        {
            _mainLabel.frame = CGRectMake(16, 12, TPScreenWidth()-152, mainLabelHeight);
            _subLabel.frame = CGRectMake(16, cellHeight - 26, TPScreenWidth()-152, 14);
            break;
        }
        case CellFaceTime:
            
        {
            _mainLabel.frame = CGRectMake(16, 24, TPScreenWidth()-152, mainLabelHeight);
            break;
        }
        default: {
            _mainLabel.frame = CGRectMake(16, 12, TPScreenWidth()-32, mainLabelHeight);
            _subLabel.frame = CGRectMake(16, cellHeight - 26, TPScreenWidth()-32, 14);
            break;
        }
    }
    _bottomLine.frame = CGRectMake(16 , cellHeight - 2.5, TPScreenWidth()-16, 0.5);
}

- (void)showButton{
    _rightButton.hidden = YES;
    _rightButton.userInteractionEnabled = YES;
    _rightMiddleIcon.hidden = YES;
    _invitingImageView.hidden = YES;
    _rightButton.titleLabel.font = [UIFont fontWithName:@"iPhoneIcon5" size:24];
    _rightMiddleIcon.font = [UIFont fontWithName:@"iPhoneIcon3" size:24];
    [_rightButton setImage:nil forState:UIControlStateNormal];
    if ( _model.cellType == CellFaceTime ){
        [_rightButton setTitle:@"U" forState:UIControlStateNormal];//摄像头
        _rightButton.hidden = NO;
        _rightButton.userInteractionEnabled = NO;
    }else if ( _model.cellType == CellPhone ){
        [_rightButton setTitle:@"B" forState:UIControlStateNormal];//短信
        _rightMiddleIcon.text = @"z";//电话
        _rightButton.hidden = NO;
        _rightMiddleIcon.hidden = NO;
    } else if (_model.cellType == CellInviting) {
        _rightButton.hidden = NO;
        _rightButton.userInteractionEnabled = NO;
        UIImage *invitingIcon = [TPDialerResourceManager getImage:@"cell-inviting-icon@2x.png"];
        [_rightButton setTitle:nil forState:UIControlStateNormal];
        [_rightButton setImage:invitingIcon forState:UIControlStateNormal];
        if (![UserDefaultsManager boolValueForKey:INVITING_IN_CONTACT_SUCCEED defaultValue:NO]) {
            _rightButton.hidden = NO;
        } else {
            _rightButton.hidden = NO;
            
        }
    }
    
}


- (void)refreshView:(ContactInfoCellModel *)model{
    _model = model;
    _mainLabel.text = model.mainStr;
    _subLabel.text = model.subStr;
    [self showButton];
    [self adjustHeight];
}

- (void)onCellRightButtonPressed{
    [_delegate onCellRightButtonPressed:_model];
    [_rightButton clearHighlightState];
}


@end








@protocol TPContactInfoButtonViewDelegate <NSObject>
- (void)onButtonPressed:(NSInteger)tag;
@end

@interface ContactInfoButtonViewCopy : UIView
@property (nonatomic,assign) id<TPContactInfoButtonViewDelegate> delegate;
- (instancetype)initWithFrame:(CGRect)frame andInfoModel:(ContactInfoModel *)infoModel;
- (void)refreshButtonView:(ContactInfoModel *)infoModel;
@end

@implementation ContactInfoButtonViewCopy
- (instancetype)initWithFrame:(CGRect)frame andInfoModel:(ContactInfoModel *)infoModel{
    self = [super initWithFrame:frame];
    
    if ( self ){
        self.backgroundColor = [UIColor clearColor];//[TPDialerResourceManager getColorForStyle:@"tp_color_black_transparency_50"];
        [self generateButton:infoModel];
    }
    
    return self;
}

- (void)generateButton:(ContactInfoModel *)infoModel{
    NSArray *buttonArray = [self generateArray:infoModel];
    int buttonSize = [buttonArray count];
    for ( int i = 0 ; i < buttonSize ; i ++){
        
        ContactInfoButtonModel *info = [buttonArray objectAtIndex:i];
        
        UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(self.frame.size.width*(i%buttonSize)/buttonSize, 0, self.frame.size.width/buttonSize, self.frame.size.height)];
        button.backgroundColor = [UIColor clearColor];
        button.tag = info.buttonTag;
        [button addTarget:self action:@selector(onButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [button setBackgroundImage:[FunctionUtility imageWithColor:[TPDialerResourceManager getColorForStyle:@"tp_color_black_transparency_100"] withFrame:CGRectMake(0, 0, button.frame.size.width, button.frame.size.height)] forState:UIControlStateHighlighted];
       
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0 +  self.frame.size.width / buttonSize * i - .7, 0, .7, self.frame.size.height - 15)];
        line.backgroundColor = kSeparateLineColor;
        [self addSubview:line];

        [self addSubview:button];
        
        UILabel *iconLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 8, button.frame.size.width, 24)];
        iconLabel.font = [UIFont fontWithName:@"iPhoneIcon5" size:24];
        iconLabel.text = info.iconStr;
        iconLabel.textColor = [ColorTool getHighLightColor];
        iconLabel.textAlignment = NSTextAlignmentCenter;
        iconLabel.backgroundColor = [UIColor clearColor];
        [button addSubview:iconLabel];
        
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 40, button.frame.size.width, 12)];
        titleLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:11];
        titleLabel.text = info.titleStr;
        titleLabel.textColor = kGrayColor;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.backgroundColor = [UIColor clearColor];
        [button addSubview:titleLabel];
    }
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, self.frame.size.height - .7, self.frame.size.width, .7)];
    line.backgroundColor = kSeparateLineColor;
    [self addSubview:line];
    
}

- (NSArray *) generateArray:(ContactInfoModel *)infoModel{
    NSMutableArray *buttonArray = [NSMutableArray array];
    InfoType infoType = infoModel.infoType;
    if ( infoType == knownInfo ){
        ContactInfoButtonModel *info = [[ContactInfoButtonModel alloc]init];
        info.iconStr = @"H";
        info.titleStr = NSLocalizedString(@"contact_info_call_log", "");
        info.buttonTag = knownCalllog;
        [buttonArray addObject:info];
        
        info = [[ContactInfoButtonModel alloc]init];
        info.iconStr = @"T";
        info.titleStr = NSLocalizedString(@"detail_shortcut_gesture", "");
        info.buttonTag = knownGesture;
        [buttonArray addObject:info];
        
        info = [[ContactInfoButtonModel alloc]init];
        info.iconStr = @"N";
        info.titleStr = NSLocalizedString(@"detail_shortcut_share", "");
        info.buttonTag = knownShare;
        [buttonArray addObject:info];
        
    }else{
        ContactInfoButtonModel *info = [[ContactInfoButtonModel alloc]init];
        info.iconStr = @"H";
        info.titleStr = NSLocalizedString(@"contact_info_call_log", "");
        info.buttonTag = unknownCallog;
        [buttonArray addObject:info];
        
        info = [[ContactInfoButtonModel alloc]init];
        info.iconStr = @"e";
        info.titleStr = NSLocalizedString(@"Copy", "");
        info.buttonTag = unknownCopy;
        [buttonArray addObject:info];
        
        info = [[ContactInfoButtonModel alloc]init];
        info.iconStr = @"N";
        info.titleStr = NSLocalizedString(@"Share", "");
        info.buttonTag = unknownShare;
        [buttonArray addObject:info];
    }
    return buttonArray;
}

- (void)refreshButtonView:(ContactInfoModel *)infoModel{
    for(UIView *view in [self subviews])
    {
        [view removeFromSuperview];
    }
    [self generateButton:infoModel];
}

- (void)onButtonPressed:(UIButton *)sender{
    [_delegate onButtonPressed:sender.tag];
}

@end






@protocol TPContactInfoMainViewDelegate <NSObject>
- (void)onIconButtonAction;
- (void)onButtonPressed:(NSInteger)tag;
@end

@interface ContactInfoMainViewCopy : UIView
@property (nonatomic,assign) id<TPContactInfoMainViewDelegate> delegate;
@property (nonatomic) ContactInfoModel *infoModel;

- (instancetype)initWithFrame:(CGRect)frame infoModel:(ContactInfoModel *)infoModel;
- (void)refreshView:(ContactInfoModel *)infoModel;
- (void)refreshButtonView:(ContactInfoModel *)infoModel;
- (void)doViewShrunk;
@end





@interface ContactInfoMainViewCopy()<TPContactInfoButtonViewDelegate>{
    UIImageView *bgView;
    UIButton *iconButton;
    UIImageView *imageView;
    UILabel *firstLabel;
    UILabel *secondLabel;
    ContactInfoButtonViewCopy *_buttonView;
    
    CGFloat _firstLabelHeight;
    CGFloat _iconRadius;
    
    CGFloat _buttonViewSecondDis;
    CGFloat _firstSecondDis;
}

@end

@implementation ContactInfoMainViewCopy

- (instancetype)initWithFrame:(CGRect)frame infoModel:(ContactInfoModel *)infoModel{
    self = [super initWithFrame:frame];
    if ( self ){
        _infoModel = infoModel;
        self.backgroundColor = [UIColor whiteColor];//[FunctionUtility getBgColorOfLongPressView];
        
        //        bgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        //        bgView.alpha = 0.3;
        //        if ( infoModel.bgImage != nil ){
        //            bgView.image = infoModel.bgImage;
        //        }
        //        else
        //            bgView.hidden = YES;
        //        [self addSubview:bgView];
        
        float globalY = 30 + TPHeaderBarHeightDiff();
        
        iconButton = [[UIButton alloc] initWithFrame:CGRectMake((TPScreenWidth()-CIRCLE_HEIGHT)/2, globalY, CIRCLE_HEIGHT, CIRCLE_HEIGHT)];
//        iconButton.layer.masksToBounds = YES;
        iconButton.layer.cornerRadius = iconButton.frame.size.width/2;
//        iconButton.layer.borderWidth = 2.5;
        [iconButton setBackgroundColor:[UIColor clearColor]];
        [iconButton addTarget:self action:@selector(onIconButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [self refreshIconButtonBorder];
        [self addSubview:iconButton];
        _iconRadius = iconButton.frame.size.width / 2;
        
        imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, CIRCLE_HEIGHT, CIRCLE_HEIGHT)];
        imageView.layer.masksToBounds = YES;
        imageView.layer.cornerRadius = imageView.frame.size.width/2;
        imageView.layer.shadowColor = kSeparateLineColor.CGColor;
        iconButton.layer.shadowRadius = 3;
        iconButton.layer.shadowOpacity = .2;
        iconButton.layer.shadowOffset = CGSizeMake(0, 3);
        
        imageView.image = infoModel.photoImage;
        imageView.backgroundColor = [UIColor colorWithRed:217/255.f green:217/255.f blue:217/255.f alpha:1];
        [iconButton addSubview:imageView];
        
        globalY += iconButton.frame.size.height + 8;
        _firstLabelHeight = globalY;
        
        firstLabel = [[UILabel alloc]initWithFrame:CGRectMake(50, globalY, TPScreenWidth()-100, 24)];
        firstLabel.textColor = [UIColor blackColor];
        firstLabel.backgroundColor = [UIColor clearColor];
        firstLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:FONT_SIZE_3];
        firstLabel.textAlignment = NSTextAlignmentCenter;
        firstLabel.text = infoModel.firstStr;
        [self addSubview:firstLabel];
        
        globalY += firstLabel.frame.size.height + 8;
        _firstSecondDis = firstLabel.frame.size.height + 8;
        
        secondLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, globalY, TPScreenWidth()-40, 14)];
        secondLabel.textColor = [UIColor blackColor];
        secondLabel.backgroundColor = [UIColor clearColor];
        secondLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:FONT_SIZE_5];
        secondLabel.textAlignment = NSTextAlignmentCenter;
        secondLabel.text = infoModel.secondStr;
        [self addSubview:secondLabel];
        
        _buttonViewSecondDis = self.frame.size.height - 60 - globalY;
        _buttonView = [[ContactInfoButtonViewCopy alloc]initWithFrame:CGRectMake(0,self.frame.size.height - 60, self.frame.size.width, 60) andInfoModel:infoModel];
        _buttonView.delegate = self;
        [self addSubview:_buttonView];
        
    }
    return self;
}

- (void)refreshView:(ContactInfoModel *)infoModel{
    //    _infoModel = infoModel;
    //    if ( infoModel.bgImage != nil ){
    //        bgView.hidden = NO;
    //        bgView.image = infoModel.bgImage;
    //    }
    //    else
    //        bgView.hidden = YES;
    
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



@protocol TPContactInfoHeaderViewDelegate <NSObject>
- (void)onLeftButtonAction;
- (void)onRightButtonAction;
@end

@interface ContactInfoHeaderViewCopy : UIView
@property (nonatomic, assign) id<TPContactInfoHeaderViewDelegate> delegate;
- (instancetype)initWithFrame:(CGRect)frame andInfoModel:(ContactInfoModel *)infoModel;
- (void)refreshHeaderView:(ContactInfoModel *)infoModel;
@end


@interface ContactInfoHeaderViewCopy(){
    UIButton *_headerButton;
}

@end

@implementation ContactInfoHeaderViewCopy

- (instancetype)initWithFrame:(CGRect)frame andInfoModel:(ContactInfoModel *)infoModel{
    self = [super initWithFrame:frame];
    
    if ( self ){
        self.backgroundColor = [UIColor clearColor];
        
        UIButton *leftButton = [[UIButton alloc]initWithFrame:CGRectMake(0, TPHeaderBarHeightDiff(), 50, 45)];
//        [leftButton setBackgroundImage:[TPDialerResourceManager getImage:@"white_navigation_back_icon@2x.png"] forState:UIControlStateNormal];
        [leftButton setTitle:@"L" forState:UIControlStateNormal];
        [leftButton setTitleColor:[ColorTool getHighLightColor] forState:UIControlStateNormal];
        leftButton.titleLabel.font = [UIFont fontWithName:@"iPhoneIcon4" size:24];
        [leftButton addTarget:self action:@selector(onLeftButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:leftButton];
        
        _headerButton = [[UIButton alloc]initWithFrame:CGRectMake(TPScreenWidth() - 80, TPHeaderBarHeightDiff(), 80, 45)];
        [_headerButton setTitle:NSLocalizedString(@"Edit", "") forState:UIControlStateNormal];
        _headerButton.titleLabel.font = [UIFont systemFontOfSize:FONT_SIZE_3];
        [_headerButton setTitleColor:[ColorTool getHighLightColor] forState:UIControlStateNormal];
        [self addSubview:_headerButton];
        [_headerButton addTarget:self action:@selector(onRightButtonAction) forControlEvents:UIControlEventTouchUpInside];
        if ( infoModel.infoType == knownInfo )
            [_headerButton setTitle:NSLocalizedString(@"Edit", "") forState:UIControlStateNormal];
        else if ( infoModel.infoType == unknownInfo )
            [_headerButton setTitle:NSLocalizedString(@"Save", "") forState:UIControlStateNormal];
    }
    
    return self;
}

- (void)onLeftButtonAction{
    [_delegate onLeftButtonAction];
}

- (void)onRightButtonAction{
    [_delegate onRightButtonAction];
}

- (void)refreshHeaderView:(ContactInfoModel *)infoModel{
    if ( infoModel.infoType == knownInfo )
        [_headerButton setTitle:NSLocalizedString(@"Edit", "") forState:UIControlStateNormal];
    else if ( infoModel.infoType == unknownInfo )
        [_headerButton setTitle:NSLocalizedString(@"Save", "") forState:UIControlStateNormal];
}

@end










@interface ContactInfoViewCopyController()
<TPContactInfoMainViewDelegate,
UITableViewDataSource,
UITableViewDelegate,
TPContactInfoCellProtocol,
TPContactInfoHeaderViewDelegate>{
    ContactInfoMainViewCopy *_mainView;
    ContactInfoHeaderViewCopy *_headerView;
    UITableView *_tableView;
    
    NSString *_copyStr;
    BOOL _scrollDown;
    CGFloat _lastMainHeight;
}

@end


@implementation ContactInfoViewCopyController

- (void)viewDidLoad{
    self.view.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_50"];
    
    NSDictionary *propertyDict = [[TPDialerResourceManager sharedManager] getPropertyDicByStyle:@"KnownContactInforViewController_style"];
    self.view.backgroundColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:[propertyDict objectForKey:@"backgroundColor"]];
    
    _mainView = [[ContactInfoMainViewCopy alloc]initWithFrame:CGRectMake(0, 0, TPScreenWidth(), MAIN_HEIGHT) infoModel:_infoModel];
    _mainView.delegate = self;
    [self.view addSubview:_mainView];
    _lastMainHeight = _mainView.frame.size.height;
    
    _headerView = [[ContactInfoHeaderViewCopy alloc]initWithFrame:CGRectMake(0, 0, TPScreenWidth(), 45 +TPHeaderBarHeightDiff()) andInfoModel:_infoModel];
    _headerView.delegate = self;
    [self.view addSubview:_headerView];
    
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, _mainView.frame.size.height, TPScreenWidth(), TPScreenHeight()-_mainView.frame.size.height)];
    _tableView.showsVerticalScrollIndicator = NO;
//    _tableView.bounces = NO;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_50"];
    [self.view addSubview:_tableView];
    
    //long press copy
    UILongPressGestureRecognizer *longPressReger = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onTableViewLongPress:)];
    [_tableView addGestureRecognizer:longPressReger];
    longPressReger.minimumPressDuration = 0.8;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    [FunctionUtility setStatusBarStyleToDefault:YES];

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    [FunctionUtility setStatusBarStyleToDefault:NO];

}

- (void) refreshButtonView{
    [_mainView refreshButtonView:_infoModel];
    [_headerView refreshHeaderView:_infoModel];
}

- (void) refreshView{
    [_mainView refreshView:_infoModel];
    [_headerView refreshHeaderView:_infoModel];
    [_tableView reloadData];
}

- (void) refreshTableView{
    [_tableView reloadData];
}

-(void)dealloc{
    [_delegate deallocTheController];
}

- (void)onTableViewLongPress:(UILongPressGestureRecognizer *)gesture
{
    CGPoint point = [gesture locationInView:_tableView];
    NSIndexPath *indexPath = [_tableView indexPathForRowAtPoint:point];
    if(gesture.state == UIGestureRecognizerStateBegan){
        NSInteger section = indexPath.section;
        NSInteger row = indexPath.row;
        
        ContactInfoCellCopy *cell = (ContactInfoCellCopy *)[_tableView cellForRowAtIndexPath:indexPath];
        [self becomeFirstResponder];
        UIMenuController *copy  = [UIMenuController sharedMenuController];
        [copy setTargetRect:[cell frame] inView:_tableView];
        [copy setMenuVisible:YES animated:YES];
        ContactInfoCellModel *info = [self getInfoBySection:section row:row];
        _copyStr = info.mainStr;
    }
}

#pragma mark ContactInfoHeaderViewDelegate

- (void)onLeftButtonAction{
    [_delegate popViewController];
}

- (void)onRightButtonAction{
    [_delegate onRightButtonAction];
}

#pragma mark ContactInfoMainViewDelegate

- (void)onIconButtonAction{
    [_delegate onIconButtonAction];
}

#pragma mark ContactInfoButtonViewDelegate

- (void)onButtonPressed:(NSInteger)tag{
    [_delegate onButtonPressed:tag];
}


#pragma mark ContactInfoCellProtocol
- (void)onCellRightButtonPressed:(ContactInfoCellModel *)model{
    [_delegate onCellRightButtonPressed:model];
}
#pragma mark tableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    //    int sectionCount = 2; //for number array
    //    if (_subArray.count > 0) {
    //        sectionCount++;
    //    }
    //    if (_shareArray.count > 0) {
    //        sectionCount++;
    //    }
    
    //    return sectionCount;
    BOOL isRegistered = NO;
    NSInteger personId = _infoModel.personId;
    if (personId > 0) {
        // only for contacts
        ContactCacheDataModel* personData = [[ContactCacheDataManager instance] contactCacheItem:personId];
        for (PhoneDataModel *phone in personData.phones) {
            NSString *number = [PhoneNumber getCNnormalNumber:phone.number];
            NSInteger resultCode = [TouchpalMembersManager isNumberRegistered:number];
            if (resultCode == 1){
                isRegistered = YES;
            }
        }
    }
    
    if ([UserDefaultsManager boolValueForKey:IS_VOIP_ON] && !isRegistered) {
        
        return 3;
        
    }else{
        return 2;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    BOOL isRegistered = NO;
    NSInteger personId = _infoModel.personId;
    if (personId > 0) {
        // only for contacts
        ContactCacheDataModel* personData = [[ContactCacheDataManager instance] contactCacheItem:personId];
        for (PhoneDataModel *phone in personData.phones) {
            NSString *number = [PhoneNumber getCNnormalNumber:phone.number];
            NSInteger resultCode = [TouchpalMembersManager isNumberRegistered:number];
            if (resultCode == 1){
                isRegistered = YES;
            }
        }
    }
    if ([UserDefaultsManager boolValueForKey:IS_VOIP_ON] && !isRegistered) {
        // if logged in;
        // the first section is the number array, the second array is the share array
        // the third section only exsits only if the number is in the contact list.
        switch (section) {
            case 0: {
                return _numberArray.count;
            }
            case 1: {
                return _shareArray.count;
            }
            case 2: {
                return _subArray.count;
            }
            default:
                break;
        }
        
    } else {
        // not logged in, do not contain the share array section
        switch (section) {
            case 0: {
                return _numberArray.count;
            }
            case 1: {
                return _subArray.count;
            }
                
            default:
                break;
        }
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    ContactInfoCellModel *info = [self getInfoBySection:section row:row];
    
    if ( info.cellType == CellPhone || info.cellType == CellFaceTime) {
        return 66;
    } else if (info.cellType == CellInviting) {
        //in the share array
        return 66;
    }
    
    CGSize mainSize = [info.mainStr sizeWithFont:[UIFont fontWithName:@"Helvetica-Light" size:17]
                               constrainedToSize:CGSizeMake(TPScreenWidth()-32, 100)];
    NSInteger mainLabelHeight = ceil(mainSize.height) > 20? ceil(mainSize.height) : 20;
    return mainLabelHeight + 46 > 66 ? mainLabelHeight + 46 : 66;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdentifier = @"contact_info";
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    
    ContactInfoCellCopy *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    ContactInfoCellModel *info = [self getInfoBySection:section row:row];
    if (cell == nil ){
        cell = [[ContactInfoCellCopy alloc]initWithStyle:UITableViewCellStyleDefault
                                         reuseIdentifier:cellIdentifier
                                    ContactInfoCellModel:info
                                                personId:_infoModel.personId];
        cell.delegate = self;
    }else{
        [cell refreshView:info];
    }
    
    if ((int)[indexPath row]+1 == (int)[tableView numberOfRowsInSection:[indexPath section]]) {
        [cell hideBottomLine];
    } else {
        [cell showBottomLine];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    //    if ( section == 0 ) {
    //        return 0;
    //    }
    
    NSInteger totlalSection = [self numberOfSectionsInTableView:tableView];
    if (totlalSection == 3) {
        // if logged in;
        // the first section is the number array, the second array is the share array
        // the third section only exsits only if the number is in the contact list.
        switch (section) {
            case 0: {
                return 0 ;
            }
            case 1: {
                return _shareArray.count ? 20 : 0;
            }
            case 2: {
                return 20;
            }
            default:
                break;
        }
        
    } else {
        // not logged in, do not contain the share array section
        switch (section) {
            case 0: {
                return 0;
            }
            case 1: {
                return 20;
            }
                
            default:
                break;
        }
    }
    
    return 20;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, TPScreenWidth(), 20)];
    headerView.backgroundColor = [UIColor clearColor];
    return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    ContactInfoCellModel *info = [self getInfoBySection:section row:row];
    [_delegate onSelectCell:info];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat yOffset = scrollView.contentOffset.y;
    cootek_log(@"offset:%.2f", yOffset);
    if ( yOffset == 0 )
        return;
    CGRect mainFrame = _mainView.frame;
    CGRect tableFrame = _tableView.frame;
    CGFloat moveHeight = mainFrame.size.height - yOffset;
    CGFloat mainHeight = 0;
    
    if ( mainFrame.size.height > _lastMainHeight )
        _scrollDown = YES;
    else
        _scrollDown = NO;
    _lastMainHeight = mainFrame.size.height;
    
    if ( moveHeight < 45 + TPHeaderBarHeightDiff() ){
        mainHeight = 45 + TPHeaderBarHeightDiff();
    }else if ( moveHeight > MAIN_HEIGHT ){
        mainHeight = MAIN_HEIGHT;
    }else{
        mainHeight = moveHeight;
        //scrollView.contentOffset = CGPointMake(0, 0);
    }
    _mainView.frame = CGRectMake(mainFrame.origin.x, mainFrame.origin.y , mainFrame.size.width, mainHeight);
    _tableView.frame = CGRectMake(tableFrame.origin.x, mainHeight, tableFrame.size.width, TPScreenHeight() - mainHeight);
    
    [_mainView doViewShrunk];
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [[NSNotificationCenter defaultCenter]postNotificationName:N_SCROLL_ENABLE object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:KEY_SCROLL]];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if ( !decelerate )
        [self scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self scrollView];
}


- (void)scrollView{
    if ( _tableView.contentOffset.y != 0 )
        [[NSNotificationCenter defaultCenter]postNotificationName:N_SCROLL_ENABLE object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:KEY_SCROLL]];
    else
        [[NSNotificationCenter defaultCenter]postNotificationName:N_SCROLL_ENABLE object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:KEY_SCROLL]];
    
    if ( _mainView.frame.size.height >= MAIN_HEIGHT || _mainView.frame.size.height <= 45 + TPHeaderBarHeightDiff() ){
        return;
    }
    CGRect mainFrame = _mainView.frame;
    CGRect tableFrame = _tableView.frame;
    CGFloat mainHeight = 0;
    if ( _scrollDown ){
        if ( _mainView.frame.size.height > 45 + TPHeaderBarHeightDiff() + (MAIN_HEIGHT - 45 - TPHeaderBarHeightDiff())*0.4  )
            mainHeight = MAIN_HEIGHT;
        else
            mainHeight = 45 + TPHeaderBarHeightDiff();
    }else{
        if ( _mainView.frame.size.height > 45 + TPHeaderBarHeightDiff() + (MAIN_HEIGHT - 45 - TPHeaderBarHeightDiff())*0.7 )
            mainHeight = MAIN_HEIGHT;
        else
            mainHeight = 45 + TPHeaderBarHeightDiff();
    }
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^(){
                         _mainView.frame = CGRectMake(mainFrame.origin.x, mainFrame.origin.y , mainFrame.size.width, mainHeight);
                         _tableView.frame = CGRectMake(tableFrame.origin.x, mainHeight, tableFrame.size.width, TPScreenHeight() - mainHeight);
                         [_mainView doViewShrunk];
                     }
                     completion:^(BOOL finish){
                         if ( finish )
                             [[NSNotificationCenter defaultCenter]postNotificationName:N_SCROLL_ENABLE object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:KEY_SCROLL]];
                     }];
}

#pragma mark UIResponderStandardEditActions
-(BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    return (action == @selector(copy:));
}

- (void)copy:(id)sender {
    if (_copyStr == nil) {
        return;
    }
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    [UserDefaultsManager setBoolValue:YES forKey:PASTEBOARD_COPY_FROM_TOUCHPAL];
    [pasteboard setString:_copyStr];
    [self resignFirstResponder];
}

- (ContactInfoCellModel *) getInfoBySection:(NSInteger) section row:(NSInteger)row {
    ContactInfoCellModel * info = nil;
    
    BOOL isRegistered = NO;
    NSInteger personId = _infoModel.personId;
    if (personId >= 0) {
        // only for contacts
        ContactCacheDataModel* personData = [[ContactCacheDataManager instance] contactCacheItem:personId];
        for (PhoneDataModel *phone in personData.phones) {
            NSString *number = [PhoneNumber getCNnormalNumber:phone.number];
            NSInteger resultCode = [TouchpalMembersManager isNumberRegistered:number];
            if (resultCode == 1){
                isRegistered = YES;
            }
        }
    }
    
    if ([UserDefaultsManager boolValueForKey:IS_VOIP_ON] && !isRegistered) {
        // if logged in;
        // the first section is the number array, the second array is the share array
        // the third section only exsits only if the number is in the contact list.
        switch (section) {
            case 0: {
                info = [_numberArray objectAtIndex:row];
                break;
            }
            case 1: {
                info = [_shareArray objectAtIndex:row];
                break;
            }
            case 2: {
                info = [_subArray objectAtIndex:row];
                break;
            }
            default:
                break;
        }
        
        return info;
    } else {
        // not logged in, do not contain the share array section
        switch (section) {
            case 0: {
                info = [_numberArray objectAtIndex:row];
                break;
            }
            case 1: {
                info = [_subArray objectAtIndex:row];
                break;
            }
            default:
                break;
        }
        return info;
    }
    return info;
}

@end


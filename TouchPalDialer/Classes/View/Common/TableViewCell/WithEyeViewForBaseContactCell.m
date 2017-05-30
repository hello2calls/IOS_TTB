//
//  WityEyeViewForBaceContactCell.m
//  TouchPalDialer
//
//  Created by 亮秀 李 on 9/24/12.
//
//

#import "WithEyeViewForBaseContactCell.h"
#import "TouchPalDialerAppDelegate.h"
#import "PhoneNumber.h"
#import "FunctionUtility.h"
#import "DialResultModel.h"
#import "SmartDailerSettingModel.h"
#import "TPDialerResourceManager.h"
#import "Person.h"
#import "ImageCacheModel.h"
#import "AppSettingsModel.h"
#import "TouchpalMembersManager.h"
#import "CallLogCell.h"

@interface WithEyeViewForBaseContactCell(){
    int _markStickerX;
}
@property(nonatomic,retain)  UIColor   *callerTypeTextColor;
@property(nonatomic,retain)  UIColor   *callerTypeBgColor;
@property(nonatomic,retain)  UIColor   *callerTypeVipBgColor;
@property(nonatomic,retain)  UIColor   *callerTypePassBgColor;
@property(nonatomic,retain)  UIView    *markView;

- (NSMutableArray *)nameElements:(id<BaseContactsDataSource,BaseCallerIDDataSource>)data;
- (NSMutableArray *)numberElements:(id<BaseContactsDataSource,BaseCallerIDDataSource>)data;
- (NSString *)callerIDName:(id<BaseContactsDataSource,BaseCallerIDDataSource>)data;
- (NSString *)callerIDType:(id<BaseContactsDataSource,BaseCallerIDDataSource>)data;
- (NSArray *)createNumberElement:(NSString *)number;
- (TPDrawRichText *)createNameMissedCountElement:(id<BaseContactsDataSource,BaseCallerIDDataSource>)data;
- (void)changeHighLight:(id<BaseContactsDataSource,BaseCallerIDDataSource>)data;
@end

@implementation WithEyeViewForBaseContactCell
@synthesize callerTypeTextColor;
@synthesize callerTypeBgColor;
@synthesize callerTypeVipBgColor;
@synthesize callerTypePassBgColor;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        //左右划
        self.actionStrategy = [[PanContactsCellStrategy alloc] init];
        if ([[AppSettingsModel appSettings]slide_confirm]) {
            [self openSlideItem];
        }else{
            [self closeSlideItem];
        }
    }
    return self;
}

- (NSString *)callerIDName:(id<BaseContactsDataSource,BaseCallerIDDataSource>)data {
    NSString *callerName = @"";
    if ([data respondsToSelector:@selector(callerID)]) {
        CallerIDInfoModel  *callerIDModel = data.callerID;
        if([callerIDModel isCallerIdUseful] &&(SmartDailerSettingModel.isChinaSim)){
            callerName = callerIDModel.name;
        }
    }
    return callerName;
}
- (NSString *)callerIDType:(id<BaseContactsDataSource,BaseCallerIDDataSource>)data{
    NSString *callerType = @"";
    if ([data respondsToSelector:@selector(callerID)]) {
        CallerIDInfoModel  *callerIDModel = data.callerID;
        if([callerIDModel isCallerIdUseful] &&(SmartDailerSettingModel.isChinaSim)){
            callerType = callerIDModel.localizedTag;
        }
    }
    return callerType;
}
- (void)drawMark:(id<BaseContactsDataSource,BaseCallerIDDataSource>)data {
    
    NSInteger personID = data.personID;
    NSString *callerType = [self callerIDType:data];
    
    NSArray *elements = [self numberElements:data];
    self.numberLabel.elements = elements;
    _markStickerX = 0;
    for (TPDrawRichText *s in self.numberLabel.elements) {
        _markStickerX += [s minWidthOfContent];
    }
    self.faceSticker.hidden = YES;
    self.markSticker.hidden = YES;
    self.markSticker.frame = CGRectMake(_markStickerX + 21, self.markSticker.frame.origin.y, self.markSticker.frame.size.width, self.markSticker.frame.size.height);
    self.markSticker.typeImageView.image = nil;
    self.markSticker.typeLabel.backgroundColor = [UIColor clearColor];
    self.markSticker.typeLabel.text = @"";
    
	if (personID <= 0) {
        if ([callerType length] > 0) {
            self.markSticker.hidden = NO;
            self.markSticker.dotLabel.hidden = NO;
            self.markSticker.typeLabel.text = callerType;
            self.markSticker.typeLabel.textColor = [TPDialerResourceManager getColorForStyle:@"facesSticker_type_color"];
        }
    }
}
- (void)drawNumber:(id<BaseContactsDataSource,BaseCallerIDDataSource>)data{
    NSArray *elements = [self numberElements:data];
    self.numberLabel.elements = elements;
    self.numberLabel.frame = CGRectMake(12, self.numberLabel.frame.origin.y, self.numberLabel.frame.size.width, self.numberLabel.frame.size.height);
}
- (void)drawName:(id<BaseContactsDataSource,BaseCallerIDDataSource>)data{
    NSArray *elements = [self nameElements:data];
    self.nameLabel.elements = elements;
    self.nameLabel.frame = CGRectMake(12, self.nameLabel.frame.origin.y, self.nameLabel.frame.size.width, self.nameLabel.frame.size.height);
}

- (NSArray *)numberElements:(id<BaseContactsDataSource,BaseCallerIDDataSource>)data{
    NSInteger personID = data.personID;
    NSString  *number = data.number;
    NSString *callerType = [self callerIDType:data];
    NSString *callerName = [self callerIDName:data];
    NSMutableArray *elements = [NSMutableArray arrayWithCapacity:1];
    
    NSString *numberDisplay = [self numberString:personID
                                          number:number
                                      callerName:callerName
                                      callerType:callerType];
    [elements addObjectsFromArray:[self createNumberElement:numberDisplay]];
    return elements;
}
-(NSString *)numberString:(NSInteger)personID
                   number:(NSString *)number
               callerName:(NSString *)callerName
               callerType:(NSString *)callerType{
    NSString  *display = number;
    AppSettingsModel* appSettingsModel = [AppSettingsModel appSettings];
    if (appSettingsModel.display_location) {
        NSString *numberAttr =[[PhoneNumber sharedInstance] getNumberAttribution:number withType:attr_type_short];
        if ([numberAttr length] > 0) {
            if (personID > 0 || [callerName length] > 0) {
                display = [NSString stringWithFormat:@"%@ · %@", display,numberAttr];
            }else{
                display = numberAttr;
            }
        }
    }
    return display;
}
-(void)changeHighLight:(id<BaseContactsDataSource,BaseCallerIDDataSource>)data{
    if ([self.currentData isKindOfClass:[SearchItemModel class]]) {
        SearchItemModel *tmpData = (SearchItemModel *)data;
        NSRange range = tmpData.hitNumberInfo;
        tmpData.hitNameInfo = [NSMutableArray arrayWithObjects:@(range.location),@(range.length),nil];
        self.isHighlightedNumber = NO;
    }
}
- (NSMutableArray *)nameElements:(id<BaseContactsDataSource,BaseCallerIDDataSource>)data{
    NSInteger personID = data.personID;
    NSMutableArray *elements = [NSMutableArray arrayWithCapacity:1];
    NSString  *name = data.name;
    
    if (!(personID >0)) {
        NSString *callerName = [self callerIDName:data];
        if ([callerName length] > 0){
            name = callerName;
        }
    }
    if ([name length] == 0) {
        name = data.number;
        [self changeHighLight:data];
    }else{
        self.isHighlightedNumber = YES;
    }
    [elements addObjectsFromArray:[self createNameElement:name]];
    TPDrawRichText *element = [self createNameMissedCountElement:data];
    if (element) {
        [elements addObject:element];
    }
    return elements;
}
- (TPDrawRichText *)createNameMissedCountElement:(id<BaseContactsDataSource,BaseCallerIDDataSource>)data{
    if ([data isKindOfClass:[CallLogDataModel class]]) {
        CallLogDataModel *log = (CallLogDataModel *)data;
        NSInteger count = log.missedCount;
        if (count > 1) {
            NSString *str = [NSString stringWithFormat:@" (%d)",count];
            TPDrawRichText *element = [[TPDrawRichText alloc] initWithText:str
                                                                       font:[UIFont boldSystemFontOfSize:FONT_SIZE_5]
                                                                      color: self.textNumberColor
                                       ];
            element.isAlwaysShow = YES;
            return element;
        }
    }
    return nil;
}
- (NSArray *)createNameElement:(NSString *)name{
    NSArray *elements = nil;
    if ([self isHighlightedName] && [self.currentData isKindOfClass:[SearchItemModel class]]) {
        NSArray * hitNameIfo = [self.currentData hitNameInfo];
        if (hitNameIfo) {
            elements = [TPRichLabelUtils createHighlightElements:name
                                                       textColor:self.textNameColor
                                                     httextColor:self.htNameTextColor
                                                            font:[UIFont boldSystemFontOfSize:FONT_SIZE_3]
                                                       highlight:hitNameIfo];
        }
    }
    if (!elements) {
        UIColor *nameLabelColor = self.textNameColor;
        if ([self.currentData isKindOfClass:[CallLogDataModel class]]) {
            CallLogDataModel *dataT = (CallLogDataModel *)self.currentData;
            if (dataT.callType == CallLogIncomingMissedType) {
                nameLabelColor = [UIColor redColor];
            }
        }
        elements = [TPRichLabelUtils createDefaultElements:name
                                                 textColor:nameLabelColor
                                                      font:[UIFont boldSystemFontOfSize:FONT_SIZE_3]
                    ];
    }
    return elements;
    
}
- (NSArray *)createNumberElement:(NSString *)number{
    NSArray *elements = nil;
    if ([self isHighlightedNumber] && [self.currentData isKindOfClass:[SearchItemModel class]]) {
        NSRange numberRange = [self.currentData hitNumberInfo];
        NSRange range = {0,0};
        if (!NSEqualRanges(numberRange,range)){
            elements = [TPRichLabelUtils createNumberHighlightElements:number
                                                             textColor:self.textNumberColor
                                                           httextColor:self.htNumberColor
                                                                  font:[UIFont boldSystemFontOfSize:FONT_SIZE_5]
                                                             highlight:numberRange];
        }
    }
    if (!elements) {
        elements = [TPRichLabelUtils createDefaultElements:number
                                                 textColor:self.textNumberColor
                                                      font:[UIFont systemFontOfSize:FONT_SIZE_5]
                    ];
    }
    return elements;
}
- (void)setDataToCell{
    [self drawName:self.currentData];
    [self drawNumber:self.currentData];
    [self drawMark:self.currentData];
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    if ( _ifCalllogCell ){
        return;
    }
    CGRect contentFrame = self.userContentView.frame;
    if (!self.isEditing) {
        self.userContentView.frame = CGRectMake(0, 0, TPScreenWidth(), contentFrame.size.height);
        [FunctionUtility setX:CALLLOG_CELL_MARGIN_LEFT forView:self.numberLabel];
        [FunctionUtility setX:CALLLOG_CELL_MARGIN_LEFT forView:self.nameLabel];
        [FunctionUtility setX:(_markStickerX + 21) forView:self.markSticker];
        
    }else {
        self.userContentView.frame = CGRectMake(11, 0, 260, contentFrame.size.height);
        self.numberLabel.frame = CGRectMake(22, self.numberLabel.frame.origin.y, self.numberLabel.frame.size.width, self.numberLabel.frame.size.height);
        self.nameLabel.frame = CGRectMake(22, self.nameLabel.frame.origin.y, self.nameLabel.frame.size.width, self.nameLabel.frame.size.height);
        self.markSticker.frame = CGRectMake(_markStickerX + 28, self.markSticker.frame.origin.y, self.markSticker.frame.size.width, self.markSticker.frame.size.height);
    }
}
- (id)selfSkinChange:(NSString *)style{
    [super selfSkinChange:style];
    NSDictionary *properDic = [[TPDialerResourceManager sharedManager]
                               getPropertyDicByStyle:@"default_CallLogAddOnForSmartEyeView_style"];
    
    self.callerTypeTextColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:[properDic objectForKey:@"callerTypeLabel_text_color"]];
    self.callerTypeBgColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:[properDic objectForKey:@"callerTypeLabel_background_color"]];
    self.callerTypePassBgColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:[properDic objectForKey:@"callerTypeValidLabel_background_color"]];
    self.callerTypeVipBgColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:[properDic objectForKey:@"callerTypeVipLabel_background_color"]];
    
    NSNumber *toTop = [NSNumber numberWithBool:YES];
    return toTop;
}

- (void)removeMarkButton{
    [self.markView removeFromSuperview];
    self.markView = nil;
}

- (BOOL)hasMarkButton {
    return self.markView != nil;
}

//for callerTellUGC mark button
- (void)showMarkButton{
    self.markView.hidden = NO;
}

- (void)hideMarkButton{
    self.markView.hidden = YES;
}

- (void)setEditing:(BOOL)editing{
    [super setEditing:editing];
    if(self.markView){
        if(editing){
            [self hideMarkButton];
        }else{
            [self showMarkButton];
        }
    }
}

@end

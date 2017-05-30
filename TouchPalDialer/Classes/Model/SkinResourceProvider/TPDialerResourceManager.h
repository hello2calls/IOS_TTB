

#import <Foundation/Foundation.h>
#import "TPDialerResource.h"
#import "TPDialerColor.h"
#import "ExpandBase.h"

#define N_SKIN_SHOULD_CHANGE @"N_SKIN_SHOULD_CHANGE"
#define N_SKIN_DID_CHANGE @"N_SKIN_DID_CHANGE"
#define DEFAULT_UIVIEW_STYLE @"defaultUIView_style"
#define DEFAULT_UILABEL_STYLE @"defaultUILabel_style"
#define DEFAULT_TPUIButton_STYLE @"defaultTPUIButton_style"
#define DEFAULT_UITABLEVIEW_STYLE @"defaultUITableView_style"
#define DEFAULT_UITABLEVIEWCELL_STYLE @"defaultUITableViewCell_style"

#define BACK_GROUND_IMAGE @"backgroundImage"
#define BACK_GROUND_IMAGE_HT @"backgroundImage_ht"
#define BACK_GROUND_IMAGE_SELECTED @"backgroundImage_selected"
#define BACK_GROUND_COLOR @"backgroundColor"
#define FONT @"font"
#define TEXT_COLOR_FOR_STYLE @"textColor"
#define HT_TEXT_COLOR_FOR_STYLE @"textColor_ht"
#define DISABLED_TEXT_COLOR_FOR_STYLE @"textColor_disabled"

#define BACK_GROUND_COLOR @"backgroundColor"
#define BACK_GROUND_COLOR_HT @"backgroundColor_ht"
#define CLEAR_COLOR @"clearColor"
#define ICON_IMAGE @"iconImage"
#define FONT_SUFFIX @"_font"
#define COLOR_SUFFIX @"_color"
#define IMAGE_SUFFIX @"_image"
#define STYLE_SUFFIX @"_style"
#define TP_COLOR_PREFIX @"tp_color_"
//TPUIButton
#define IMAGE_FOR_NORMAL_STATE @"imageForStateNormal"
#define IMAGE_FOR_HIGHLIGHTED_STATE @"imageForHighlightedState"
#define IMAGE_FOR_SELECTED_STATE @"imageForSelectedState"
#define IMAGE_FOR_DISABLED_STATE @"imagaForDisabledState"
//UITableView
#define SEPERATOR_COLOR @"seperatorColor"
//UITableViewCell
#define SELECTED_BACKGROUND_COLOR @"selectedBackgroundColor"
#define DETAIL_LABEIL_TEXT_COLOR @"detailLabel_textColor"

//UIImageColor
#define DEFAULT_SKIN_MINIONS  @"cootek.dialer.iphone.public.skin.minions"
#define DEFAULT_SKIN_DORAEMON  @"cootek.dialer.iphone.public.skin.doraemon"
#define DEFAULT_SKIN_THEME3  @"cootek.dialer.iphone.public.skin.alternate2"
#define DEFAULT_SKIN_THEME2  @"cootek.dialer.iphone.public.skin.alternate1"
#define DEFAULT_SKIN_THEME   @"cootek.dialer.iphone.public.skin.default"
#define SKIN_ID_PRFIX @"cootek.dialer.iphone.public.skin"

@interface TPDialerResourceManager : NSObject 
{
    TPDialerResource* __strong _resource;
    NSMutableDictionary __strong *cachedImageDic;
    NSMutableDictionary __strong *cachedColorDic;
    NSMutableDictionary __strong *rootSkinHandlers;
    NSMutableArray __strong *rootViews;
    NSString __strong *skinTheme_;
    NSString __strong *soundsPath_;
}

@property(nonatomic,retain)NSMutableArray *allSkinInfoList;
@property(nonatomic,retain)TPDialerResource *skinResource;
@property(nonatomic,retain)NSMutableDictionary *codePropertyDic;
@property(nonatomic,retain)NSMutableDictionary *soundsDic;
@property(nonatomic,retain)NSDictionary *tpColorDic;
@property(nonatomic,retain)NSString *skinTheme;
@property(nonatomic,retain)NSString *soundsPath;
@property(nonatomic,assign)BOOL isChangeThemeForSound;

+ (TPDialerResourceManager *)sharedManager;
- (UIColor *)getUIColorFromNumberString:(NSString *)colorString;
+ (UIFont *)getFontFromNumberString:(NSString *)fontString;
- (NSDictionary *)getPropertyDicByStyle:(NSString *)style;
- (UIImage *)getImageByName:(NSString *)imageName;
- (UIImage *)getCachedImageByName:(NSString *)imageName;
- (UIImage *)getImageInDefaultPackageByName:(NSString *)imageName;
- (id)getResourceByStyle:(NSString*)style needCache:(BOOL)cache;
- (id)getResourceByStyle:(NSString*)style;
- (TPDialerColor *)getTPDialerColorByNumberString:(NSString *)colorString;
- (void)addSkinHandlerForView:(UIView*) rootView;
- (void)removeSkinHandlerForView:(UIView*) rootView;
- (id)getResourceNameByStyle:(NSString *)style;
- (id)getResourceNameInDefaultPackageByStyle:(NSString *)style;
- (TinyColor)getTinyColorForStyle:(NSString *)style;
- (UIColor *)getUIColorInDefaultPackageByNumberString:(NSString *)colorString;
- (void) makeSureStatusBarChanged;

- (void)loadAllSkinInfoList;
+ (NSArray *)getDownLoadSkinDirArray;
- (NSArray *)downloadedSkinInfos;
- (BOOL)isSkinExisting:(NSString *)skinID;
- (BOOL)isSkinExpired:(NSString *)skinID;
- (NSString *)setSkinThemeToDefault;//还原默认的path
+ (NSString *)downloadSkinPath;
- (BOOL)isUsingDefaultSkin;
+ (UIColor *)getColorForStyle:(NSString *)colorString;
+ (UIColor *)getColorInDefaultPackageForStyle:(NSString *)colorString;
+ (UIImage *)getImage:(NSString *)imageName;
+ (id)getResource:(NSString *)resource;
- (NSDictionary *) getPropertyDicInDefaultPackageByStyle:(NSString *)style;
-(BOOL)ifSkinThemeHasSound;

+(UIImage*)convertViewToImage:(UIView*)v rect:(CGRect)rect;

+ (UIImage *) getImageByColorName:(NSString *)colorName withFrame: (CGRect) frame;

+ (NSData *) imageDataFromPackageWithFileName:(NSString *)fileName;
@end	


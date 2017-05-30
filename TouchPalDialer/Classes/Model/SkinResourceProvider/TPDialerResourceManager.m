



#import "TPDialerResourceManager.h"
#import "TPDialerResource.h"
#import "TPDialerColor.h"
#import "AppSettingsModel.h"
#import "TouchPalDialerAppDelegate.h"
#import "SkinHandler.h"
#import "FunctionUtility.h"
#import "ImageCacheModel.h"
#import <ZipArchive/ZipArchive.h>
#import "UserDefaultsManager.h"
#import "TouchPalVersionInfo.h"
#import "TPSkinInfo.h"
#import "DialerUsageRecord.h"
#import "WebSkinInfoProvider.h"

#import "ImageUtils.h"
#import "CommercialSkinManager.h"
static TPDialerResourceManager *sharedInstance = nil;

@implementation TPDialerResourceManager
@synthesize allSkinInfoList;
@synthesize skinResource;
@synthesize codePropertyDic;

+ (void)initialize
{
    sharedInstance = [[TPDialerResourceManager alloc] init];
}

+ (TPDialerResourceManager *) sharedManager
{
	return sharedInstance;
}

- (id)init
{
    self = [super init];
    allSkinInfoList = [[NSMutableArray alloc] initWithCapacity:2];
    rootSkinHandlers = [[NSMutableDictionary alloc] init];
    rootViews = [[NSMutableArray alloc] init];
    codePropertyDic = [[NSMutableDictionary alloc] init];
    cachedColorDic = [[NSMutableDictionary alloc] init];
    cachedImageDic = [[NSMutableDictionary alloc] init];
    _tpColorDic = [[NSDictionary alloc]init];
    
    [self loadAllSkinInfoList];    
    [self updateResource];
    
    NSString *flag = (NSString *) [self getResourceNameByStyle:@"statusBar_isDefaultStyle"];
    if ([flag isEqualToString:@"1"]) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    } else {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }

    if ([[UIDevice currentDevice].systemVersion intValue] < 7) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotiSkinShouldChange) name:N_SKIN_SHOULD_CHANGE object:nil];
	return self;
}



- (void) makeSureStatusBarChanged
{
    NSString *flag = (NSString *) [self getResourceNameByStyle:@"statusBar_isDefaultStyle"];
    if ([flag isEqualToString:@"1"]) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    } else {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }
    
    if ([[UIDevice currentDevice].systemVersion intValue] < 7) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }
}

+ (NSArray *)loadSkinPacks:(NSString*)skinRootDir
{
    NSError *error = nil;
    NSMutableArray *skinInfoList = [[NSMutableArray alloc] init];
    NSArray *fileList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:skinRootDir error:&error];
    BOOL isDir = NO;
    for (NSString* file in fileList) {
        NSString *path = [skinRootDir stringByAppendingPathComponent:file];
        [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:(&isDir)];
        if (isDir) {
            NSString *infoPlistAbsPath = [path stringByAppendingPathComponent:@"info.plist"];
            NSString *InfoPlistAbsPath = [path stringByAppendingPathComponent:@"skin-info.plist"];
            TPSkinInfo *skinInfo = nil;
            if ([[NSFileManager defaultManager] fileExistsAtPath:infoPlistAbsPath]) {
                skinInfo = [[TPSkinInfo alloc] initWithContentsOfFile:infoPlistAbsPath];
            } else {
                skinInfo = [[TPSkinInfo alloc] initWithContentsOfFile:InfoPlistAbsPath];
            }
            
            if (skinInfo != nil) {
                if (skinInfo.isBuiltIn) {
                    skinInfo.previewPath = [WebSkinInfoProvider previewImagePathForBuiltinSkin:file];
                } else {
                    skinInfo.previewPath = [WebSkinInfoProvider previewImagePath:file];
                }
                skinInfo.previewUrl = [WebSkinInfoProvider previewImageUrl:file];
                [skinInfoList addObject:skinInfo];
            }
        }
        isDir = NO;
    }
    [WebSkinInfoProvider sortSkinByTime:skinInfoList];
    return skinInfoList;
}

- (void)loadAllSkinInfoList
{
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(loadAllSkinInfoList) withObject:nil waitUntilDone:YES];
        return;
    }
    
    self.allSkinInfoList = [NSMutableArray array];
    
    //Load downloaded skins
    [self.allSkinInfoList addObjectsFromArray:[self downloadedSkinInfos]];

    //Load built-in skins
    [self.allSkinInfoList addObjectsFromArray:[self builtInSkinInfos]];
}

- (NSArray *)builtInSkinInfos
{
    NSString *builtInRootDir = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Skin"];
    NSArray *tmpArr = [TPDialerResourceManager loadSkinPacks:builtInRootDir];
    return tmpArr;
}

+ (NSArray *)getDownLoadSkinDirArray
{
    NSString *downloadedRootDir = [TPDialerResourceManager downloadSkinPath];
    NSError *error = nil;
    NSArray *fileList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:downloadedRootDir error:&error];
    return fileList;
}

- (NSArray *)downloadedSkinInfos
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *downloadedRootDir = [TPDialerResourceManager downloadSkinPath];
    BOOL downLoadSkinExist = [fileManager fileExistsAtPath:downloadedRootDir];
    if (!downLoadSkinExist) {
        return [NSArray array];
    }
    NSArray *tmpArr = [TPDialerResourceManager loadSkinPacks:downloadedRootDir];
    return tmpArr;
}

+ (NSString *)downloadSkinPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:@"Skin"];
}

- (BOOL)isSkinExisting:(NSString *)skinID
{
    for (TPSkinInfo *skin in allSkinInfoList) {
        if([skin.skinID isEqualToString:skinID]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)isSkinExpired:(NSString *)skinID
{
    BOOL isVersionSix = [UserDefaultsManager boolValueForKey:ENABLE_V6_TEST_ME defaultValue:NO];
    for(TPSkinInfo *skin in allSkinInfoList){
        if([skin.skinID isEqualToString:skinID]){
            if(skin.version < [LOWEST_SKIN_VERSION_CAN_BE_USED intValue]){
                return YES;
            } else {
                if (!isVersionSix) {
                    if(skin.version >= [NEW_SKIN_VERSION_CAN_BE_USED intValue]){
                        return YES;
                    }
                }
                return NO;
            }
        }
    }
    // skin not found
    return YES;
}

- (NSString *)skinTheme//获得主题
{
    if (skinTheme_) {
        return skinTheme_;
    }
    //v5 -> v6 皮肤重置
//    if ([UserDefaultsManager boolValueForKey:ENABLE_V6_TEST_ME defaultValue:NO]) {
//        self.skinTheme = DEFAULT_SKIN_THEME;
//    } else {
        self.skinTheme = [UserDefaultsManager stringForKey:APP_CURRENT_SKIN_ID defaultValue:DEFAULT_SKIN_THEME];
//    }

    return self.skinTheme;
}

- (void)setSkinTheme:(NSString *)skinThemeName//设置主题
{
    skinTheme_ = skinThemeName;
    [UserDefaultsManager setObject:skinTheme_ forKey:APP_CURRENT_SKIN_ID];
    _isChangeThemeForSound = YES;
    [UserDefaultsManager synchronize];
    if ([skinThemeName rangeOfString:@".AD."].length > 0) {
        if (![CommercialSkinManager checkIfCommercialSkinAndFileExistWithSkinID:skinThemeName]) {
            [UserDefaultsManager setBoolValue:YES forKey:[NSString stringWithFormat:@"selfUseSkin:%@",skinThemeName]];
        }
        [DialerUsageRecord recordpath:PATH_COMMERCIAL_SKIN kvs:Pair(USE_SKIN,skinThemeName), nil];
    }
}


//if ([TPDialerResourceManager sharedManager].skinTheme.){
//    AudioServicesPlaySystemSound(soundid+1200);
//    cootek_log(@"没有对应的音乐啦");
//    return;
//}
-(BOOL)ifSkinThemeHasSound{
    for (TPSkinInfo *skinInfo  in allSkinInfoList) {
        if ([skinInfo.name isEqualToString:skinTheme_]) {
            return skinInfo.hasSound;
        }
    }
    return NO;
}

- (NSString *)setSkinThemeToDefault
{
    self.soundsPath = @"Skin/default";
    return self.skinTheme = DEFAULT_SKIN_THEME;
}

- (BOOL)isUsingDefaultSkin
{
    return [self.skinTheme isEqualToString:DEFAULT_SKIN_THEME];
}

- (TPDialerColor *)getTPDialerColorByNumberString:(NSString *)colorString
{
    TPDialerColor *tpDialerColor = [[TPDialerColor alloc] initWithString:colorString];
    return tpDialerColor;
}

- (TinyColor)getTinyColorForStyle:(NSString *)style
{
    NSString *colorString = [self getResourceNameByStyle:style];
    while ([colorString hasSuffix:COLOR_SUFFIX]) {
        colorString = [self getResourceNameByStyle:colorString];
    }
    TPDialerColor *tpDialerColor =[[TPDialerColor alloc] initWithString:colorString];
    return TinyColorMake(tpDialerColor.R, tpDialerColor.G, tpDialerColor.B, tpDialerColor.alpha);
}

- (UIColor *)getUIColorInDefaultPackageByNumberString:(NSString *)colorString
{
    UIColor *color = nil;
    while ([colorString hasSuffix:COLOR_SUFFIX]) {
        colorString = [self getResourceNameInDefaultPackageByStyle:colorString];
    }
    while ([colorString hasPrefix:TP_COLOR_PREFIX]) {
        colorString = [self getTPColorByName:colorString];
    }
    if([colorString hasSuffix:@"@2x.png"]){
        if (TPScreenHeight()>=700) {
            colorString = [colorString stringByReplacingOccurrencesOfString:@"@2x" withString:@"@3x"];
        }
        return color = [UIColor colorWithPatternImage:[[TPDialerResourceManager sharedManager] getImageByName:colorString]];
    }
    
    TPDialerColor *tpDialerColor =[[TPDialerColor alloc] initWithString:colorString];
    color =  [UIColor colorWithRed:tpDialerColor.R green:tpDialerColor.G blue:tpDialerColor.B alpha:tpDialerColor.alpha];
    return color;
}

- (id)getTPColorByName:(NSString *)colorName{
    NSString *resourceName = [_tpColorDic objectForKey:colorName];
    return resourceName;
}

- (UIColor *)getUIColorFromNumberString:(NSString *)colorString
{
    NSString *temptColor = [colorString copy];
    if(colorString == nil) {
        return [UIColor clearColor];
    }
    UIColor *color = nil;
    TPDialerColor *colorTP = [cachedColorDic objectForKey:colorString];
    if(colorTP){
        return [UIColor colorWithRed:colorTP.R green:colorTP.G blue:colorTP.B alpha:colorTP.alpha];
    }
    while ([colorString hasSuffix:COLOR_SUFFIX]) {
        colorString = [self getResourceNameByStyle:colorString];
    }
    while ( [colorString hasPrefix:TP_COLOR_PREFIX] ){
        colorString = [self getTPColorByName:colorString];
    }
    if ( colorString == nil ){
        cootek_log(@"the color : %@ is not true",temptColor);
        return [UIColor clearColor];
    }
    if([colorString isEqualToString:@"clearColor"]){
        color = [UIColor clearColor];
    }
    if([colorString isEqualToString:@"grayColor"]){
        color = [UIColor grayColor];
    }
    if([colorString hasSuffix:@"@2x.png"]){
        return color = [UIColor colorWithPatternImage:[[TPDialerResourceManager sharedManager] getImageByName:colorString]];
    }
    if(color==nil){
        TPDialerColor *tpDialerColor =[[TPDialerColor alloc] initWithString:colorString];
        color =  [UIColor colorWithRed:tpDialerColor.R green:tpDialerColor.G blue:tpDialerColor.B alpha:tpDialerColor.alpha];
        [cachedColorDic setObject:tpDialerColor forKey:colorString];
    }
    
    return  color;
}

+ (UIFont *)getFontFromNumberString:(NSString *)fontString
{
     //may exist problem
     int font = [fontString intValue];
     int fontSize = font % 100;
     BOOL bold = font - 100 > 0 ? YES : NO;
     
     return bold ? [UIFont systemFontOfSize:fontSize] : [UIFont systemFontOfSize:fontSize];
}

- (TPDialerResourceManager *)resource
{
    return self;
}

- (TPDialerResource *)defaultResource
{
    return _resource;
}

- (void)updateResource
{
    [cachedColorDic removeAllObjects];
    [cachedImageDic removeAllObjects];
    [self.codePropertyDic removeAllObjects];
     
    NSString* curSkinID = self.skinTheme;
    if([self isSkinExpired:curSkinID]){
        curSkinID = [self setSkinThemeToDefault];
     }
    NSString* curSkinDir = nil;
    NSString* defaultSkinDir = nil;
    for (TPSkinInfo* skinInfo in allSkinInfoList) {
        if (skinInfo.isDefault) {
            defaultSkinDir = skinInfo.skinDir;
        }
        if (curSkinID!=nil && [curSkinID isEqualToString:skinInfo.skinID]) {
            curSkinDir = skinInfo.skinDir;
        }
    }
    
    if (_resource == nil) {
        _resource = [[TPDialerResource alloc] initWithDirectory:defaultSkinDir];
    }
    if ([_tpColorDic count] == 0 ){
        NSString *tpColorDir = [NSString stringWithFormat:@"%@/styles",defaultSkinDir];
        _tpColorDic = [[NSDictionary alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",tpColorDir ,@"color.plist"]];
    }
    
    if (curSkinID!=nil && [curSkinDir length] > 0) {
        //skin has been set by user
        NSString* oldSkinDir = skinResource.rootDir;
        if (oldSkinDir == nil) {
            oldSkinDir = _resource.rootDir;
        }
                
        if (![oldSkinDir isEqualToString:curSkinDir]) {
             self.skinResource = nil;
        }
        
        if (![curSkinDir isEqualToString:defaultSkinDir]) {
            self.skinResource = [[TPDialerResource alloc] initWithDirectory:curSkinDir];
            
        }
    }
}

-(NSDictionary *)getPropertyDicByStyle:(NSString *)style
{
     NSDictionary *dic = nil;
     
     if(skinResource!=nil){
          dic = [skinResource._styleDictionary objectForKey:style];
     }
     if(dic == nil){
          dic = [_resource._styleDictionary objectForKey:style];
     }
     if(dic == nil){
          dic = [codePropertyDic objectForKey:style];
     }
    
    if([dic isKindOfClass:[NSString class]] && [(NSString *)dic hasSuffix:STYLE_SUFFIX]){
         dic = [self getPropertyDicByStyle:(NSString *)dic];
    }else if([dic isKindOfClass:[NSDictionary class]]){
        return dic;
    }else{
        return nil;
    }
    return dic;
}

- (NSDictionary *) getPropertyDicInDefaultPackageByStyle:(NSString *)style {
    NSDictionary *dic = nil;
    if (style == nil) return nil;
    
    if(dic == nil){
        dic = [_resource._styleDictionary objectForKey:style];
    }
    if(dic == nil){
        dic = [codePropertyDic objectForKey:style];
    }
    
    if([dic isKindOfClass:[NSString class]] && [(NSString *)dic hasSuffix:STYLE_SUFFIX]){
        dic = [self getPropertyDicInDefaultPackageByStyle:(NSString *)dic];
    }else if([dic isKindOfClass:[NSDictionary class]]){
        return dic;
    }else{
        return nil;
    }
    return dic;
}

- (id)getResourceNameInDefaultPackageByStyle:(NSString *)style
{
    NSString *resourceName = nil;
      resourceName = [_resource._styleDictionary objectForKey:style];
    return resourceName;
}

- (id)getResourceNameByStyle:(NSString *)style
{
     NSString *resourceName = nil;
     if ( [style hasPrefix:TP_COLOR_PREFIX] ){
         return style;
     }
     if(skinResource!=nil){
         resourceName = [skinResource._styleDictionary objectForKey:style];
     }
     if(resourceName == nil){
         resourceName = [_resource._styleDictionary objectForKey:style];
     }
     if(resourceName == nil){
          resourceName = [codePropertyDic objectForKey:style];
     }
     return resourceName;
}

- (id)getResourceByStyle:(NSString *)style needCache:(BOOL)cache
{
    if ( [style hasPrefix:@"0x"] && style.length >= 8 && style.length <= 10)
        return [self getUIColorFromNumberString:style];
        
     id resourceName = [self getResourceNameByStyle:style];
     
     id resource_get = nil;
     if([resourceName isKindOfClass:[NSDictionary class]]){
        return resource_get;
     }
    
     if([resourceName isKindOfClass:[NSString class]]){
         
         if([style hasSuffix:IMAGE_SUFFIX]){
             if(cache){
                 resource_get = [[TPDialerResourceManager sharedManager] getCachedImageByName:resourceName];
             }else{
                 resource_get =  [[TPDialerResourceManager sharedManager] getImageByName:resourceName];
             }
             return resource_get;
         }
         if([style hasSuffix:COLOR_SUFFIX] || [style hasPrefix:TP_COLOR_PREFIX] ){
               resource_get = [self getUIColorFromNumberString:resourceName];
             return resource_get;
             
         }
     }
    if ([style hasPrefix:@"#"] && style.length >= 7 && style.length <= 9) {
       return [ImageUtils colorFromHexString:style andDefaultColor:nil];
    }
     return nil;
}

- (id)getResourceByStyle:(NSString *)style
{
     return  [self getResourceByStyle:style needCache:NO];
}

- (id)getResourceInDefaultPackageByStyle:(NSString *)style needCache:(BOOL)cache
{
    if ( [style hasPrefix:@"0x"] && style.length >= 8 && style.length <= 10)
        return [self getUIColorInDefaultPackageByNumberString:style];
    
    id resourceName = [self getResourceNameInDefaultPackageByStyle:style];
    
    id resource_get = nil;
    if([resourceName isKindOfClass:[NSDictionary class]]){
        return resource_get;
    }
    
    if([resourceName isKindOfClass:[NSString class]]){
        
        if([style hasSuffix:IMAGE_SUFFIX]){
            if(cache){
                //TO-DO, may need caches
                resource_get =  [[TPDialerResourceManager sharedManager] getImageInDefaultPackageByName:resourceName];
            }else{
                resource_get =  [[TPDialerResourceManager sharedManager] getImageInDefaultPackageByName:resourceName];
            }
            return resource_get;
        }
        if([style hasSuffix:COLOR_SUFFIX] || [style hasPrefix:TP_COLOR_PREFIX] ){
            resource_get = [self getUIColorInDefaultPackageByNumberString:resourceName];
            return resource_get;
            
        }
    }
    return nil;
}

- (id)getResourceInDefaultPackageByStyle:(NSString *)style
{
    return  [self getResourceInDefaultPackageByStyle:style needCache:NO];
}


- (UIImage *)getImageByName:(NSString *)imageName
{
     UIImage *image = nil;
     NSString *original_name = imageName;
     if ( [imageName hasPrefix:TP_COLOR_PREFIX] ){
         imageName = [self getTPColorByName:imageName];
     }
     if ([FunctionUtility is3x]) {
        imageName = [imageName stringByReplacingOccurrencesOfString:@"@2x" withString:@"@3x"];
     }
     if([imageName hasPrefix:@"0x"]){
         image = [FunctionUtility imageWithColor:[self getUIColorFromNumberString:imageName]];
     }else if([imageName hasSuffix:@"@3x.png"]){
         if(skinResource!=nil){
             image= [skinResource imageForFilename:imageName];
         }
         if (image == nil && [original_name hasSuffix:@"@2x.png"]) {
             image = [skinResource imageForFilename:original_name];
         }
         if (image == nil) {
             image = [_resource imageForFilename:imageName];
         }
         if (image == nil && [original_name hasSuffix:@"@2x.png"]) {
             image = [_resource imageForFilename:original_name];
         }
     } else if ([imageName hasSuffix:@"@2x.png"]) {
         if(skinResource!=nil){
             image= [skinResource imageForFilename:imageName];
         }
         
         if (image == nil) {
             image = [_resource imageForFilename:imageName];
         }
    }

     return image;
}

- (UIImage *)getCachedImageByName:(NSString *)imageName
{
     if(imageName==nil)
          return nil;
     UIImage *image = nil;
     image = [cachedImageDic objectForKey:imageName];
     if(image !=nil)
          return image;
     image =[FunctionUtility captureImage:[self getImageByName:imageName]];
     if(image!=nil){
        [cachedImageDic setObject:image forKey:imageName];
     }
     return image;
}

- (UIImage *)getImageInDefaultPackageByName:(NSString *)imageName
{
    UIImage *image = nil;
    NSString *name = imageName;
    if([imageName hasSuffix:@"@2x.png"]){
        if (TPScreenHeight()>=700) {
            name = [imageName stringByReplacingOccurrencesOfString:@"@2x" withString:@"@3x"];
        }
        image = [_resource imageForFilename:name];
        if ( image == nil ){
            image = [_resource imageForFilename:imageName];
        }
    }
    return image;
}

-(void)onNotiSkinShouldChange
{
     [self updateResource];
     
    for(int i=0; i< rootViews.count; i++) {
        UIView* view = [rootViews objectAtIndex:i];
        
        if(view!= nil) {
            [SkinHandler applySkinRecursivelyForView:view];
        }
    }
    
     [[ImageCacheModel getShareInstance] loadData];
    NSString *flag = (NSString *) [self getResourceNameByStyle:@"statusBar_isDefaultStyle"];
    if ([flag isEqualToString:@"1"]) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    } else {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }
     [[NSNotificationCenter defaultCenter] postNotificationName:N_SKIN_DID_CHANGE object:nil];
    
    
}

- (void)addSkinHandlerForView:(UIView*) rootView
{
    if(rootView == nil) {
        return;
    }
    
    [rootViews insertObject:rootView atIndex:0];
}

- (void)removeSkinHandlerForView:(UIView*) rootView
{
    if(rootView != nil) {
        [rootViews removeObject:rootView];
    }
}

+ (UIColor *)getColorForStyle:(NSString *)style{
    return [[self sharedManager] getResourceByStyle:style];
}

+ (UIColor *)getColorInDefaultPackageForStyle:(NSString *)colorString {
    return [[self sharedManager] getResourceInDefaultPackageByStyle:colorString];
}

+ (UIImage *)getImage:(NSString *)imageName {
    return [[self sharedManager] getImageByName:imageName];
}

+ (id)getResource:(NSString *)resource {
    return [[self sharedManager] getResourceByStyle:resource];
}
+(UIImage*)convertViewToImage:(UIView*)v rect:(CGRect)rect{
    CGSize s = v.bounds.size;
    cootek_log(@"contentsScale %f  scale %f",v.layer.contentsScale,[UIScreen mainScreen].scale);
//    UIGraphicsBeginImageContextWithOptions(s, NO, 0);
    UIGraphicsBeginImageContextWithOptions(s, NO, [UIScreen mainScreen].scale);
    [v.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage*image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
    
}

+ (UIImage *) getImageByColorName:(NSString *)colorName withFrame: (CGRect) frame {
    if (!colorName) {
        return nil;
    }
    UIColor *color = [TPDialerResourceManager getColorForStyle:colorName];
    if (!color) {
        return nil;
    }
    return [FunctionUtility imageWithColor:color withFrame:frame];
}

+ (NSData *) imageDataFromPackageWithFileName:(NSString *)fileName {
    if (fileName == nil || fileName.length == 0) {
        return nil;
    }
    NSString *currentThemeID = [TPDialerResourceManager sharedManager].skinTheme;
    NSString *currentSkinDir = nil;
    for(TPSkinInfo *skinInfo in [TPDialerResourceManager sharedManager].allSkinInfoList) {
        if ([skinInfo.skinID isEqualToString:currentThemeID]) {
            currentSkinDir = skinInfo.skinDir;
            break;
        }
    }
    if (currentSkinDir == nil) {
        return nil;
    }
    // an image file in `images/` dir
    NSString *path = [currentSkinDir stringByAppendingPathComponent:IMAGE_DIR];
    path = [path stringByAppendingPathComponent:fileName];
    
    return [NSData dataWithContentsOfFile:path];
}

@end

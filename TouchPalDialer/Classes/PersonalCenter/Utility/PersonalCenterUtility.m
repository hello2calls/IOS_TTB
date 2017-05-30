//
//  PersonalCenterUtility.m
//  TouchPalDialer
//
//  Created by 袁超 on 15/5/12.
//
//

#import "PersonalCenterUtility.h"
#import "UserDefaultsManager.h"
#import "TPDialerResourceManager.h"
#import <ZipArchive/ZipArchive.h>
#import "UsageConst.h"
#import "PersonInfo.h"

@implementation PersonalCenterUtility

+(UIImage *)getHeadViewUIImage {
    if ([UserDefaultsManager intValueForKey:PERSON_PROFILE_TYPE] == LOCAL_PHOTO) {
        NSString *url = [UserDefaultsManager stringForKey:PERSON_PROFILE_URL];
        if ([ALMARK isEqualToString:url]) {
            return [TPDialerResourceManager getImage:@"personal_center_icon_1@2x.png"];
        } else if ([MENG isEqualToString:url]) {
            return [TPDialerResourceManager getImage:@"personal_center_icon_2@2x.png"];
        } else if ([ADA isEqualToString:url]) {
            return [TPDialerResourceManager getImage:@"personal_center_icon_3@2x.png"];
        } else if ([LEMON isEqualToString:url]) {
            return [TPDialerResourceManager getImage:@"personal_center_icon_4@2x.png"];
        } else if ([ALEX isEqualToString:url]) {
            return [TPDialerResourceManager getImage:@"personal_center_icon_5@2x.png"];
        } else if ([ALICE isEqualToString:url]) {
            return [TPDialerResourceManager getImage:@"personal_center_icon_6@2x.png"];
        }
    }
    return [TPDialerResourceManager getImage:@"personal_center_icon_0@2x.png"];
}

+ (UIImage *)getHeadViewPhotoWithName:(NSString*)url {
    if ([ALMARK isEqualToString:url]) {
        return [TPDialerResourceManager getImage:@"personal_center_icon_1@2x.png"];
    } else if ([MENG isEqualToString:url]) {
        return [TPDialerResourceManager getImage:@"personal_center_icon_2@2x.png"];
    } else if ([ADA isEqualToString:url]) {
        return [TPDialerResourceManager getImage:@"personal_center_icon_3@2x.png"];
    } else if ([LEMON isEqualToString:url]) {
        return [TPDialerResourceManager getImage:@"personal_center_icon_4@2x.png"];
    } else if ([ALEX isEqualToString:url]) {
        return [TPDialerResourceManager getImage:@"personal_center_icon_5@2x.png"];
    } else if ([ALICE isEqualToString:url]) {
        return [TPDialerResourceManager getImage:@"personal_center_icon_6@2x.png"];
    }
    return [TPDialerResourceManager getImage:@"personal_center_icon_0@2x.png"];
}

+ (NSInteger)getHeadViewPhotoIndex:(NSString *)url {
    if ([ALMARK isEqualToString:url]) {
        return 0;
    } else if ([ADA isEqualToString:url]) {
        return 1;
    } else if ([ALEX isEqualToString:url]) {
        return 2;
    } else if ([MENG isEqualToString:url]) {
        return 3;
    } else if ([LEMON isEqualToString:url]) {
        return 4;
    } else if ([ALICE isEqualToString:url]) {
        return 5;
    }
    return -1;
}

+ (NSString *)getHeadViewPhotoNameFromIndex:(NSInteger)index {
    NSString *name = @"";
    switch (index) {
        case 0:
            name = ALMARK;
            break;
        case 1:
            name = ADA;
            break;
        case 2:
            name = ALEX;
            break;
        case 3:
            name = MENG;
            break;
        case 4:
            name = LEMON;
            break;
        case 5:
            name = ALICE;
            break;
        default:
            name = ALMARK;
            break;
    }
    return name;
    
}

+ (UIImage *)getMarketBannerImage:(NSString *)dirName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    NSString *dirPath = [documentDirectory stringByAppendingPathComponent:dirName];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    dirPath = [dirPath stringByAppendingPathComponent:[[fileManager contentsOfDirectoryAtPath:dirPath error:nil]objectAtIndex:0]];
    NSArray *array = [fileManager contentsOfDirectoryAtPath:dirPath error:nil];
    for (NSString *fileName in array) {
        if ([fileName rangeOfString:@"banner"].location !=NSNotFound) {
            NSString *imagePath = [dirPath stringByAppendingPathComponent:fileName];
            UIImage *image = [[UIImage alloc]initWithContentsOfFile:imagePath];
            return image;
        }
    }
    return nil;
}

+ (NSArray *)getMarketInnerGifArray:(NSString *)dirName {
    return [self getMarketGifArray:dirName forTypeStr:@"inner"];
}

+ (NSArray *)getMarketOutterGifArray:(NSString *)dirName {
    return [self getMarketGifArray:dirName forTypeStr:@"outter"];
}

+ (NSArray *)getMarketGifArray:(NSString *)dirName forTypeStr:(NSString*) typeStr {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    NSString *dirPath = [documentDirectory stringByAppendingPathComponent:dirName];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    dirPath = [dirPath stringByAppendingPathComponent:[[fileManager contentsOfDirectoryAtPath:dirPath error:nil]objectAtIndex:0]];
    NSArray *array = [fileManager contentsOfDirectoryAtPath:dirPath error:nil];
    
    for (NSString *fileName in array) {
        if ([fileName rangeOfString:typeStr].location !=NSNotFound) {
            NSString *gifPath = [dirPath stringByAppendingPathComponent:fileName];
            array = [fileManager contentsOfDirectoryAtPath:gifPath error:nil];
            NSMutableDictionary *imageDic = [[NSMutableDictionary alloc]initWithCapacity:array.count];
            for (NSString *imageName in array) {
                if ([imageName rangeOfString:@"png"].location != NSNotFound || [imageName rangeOfString:@"jpg"].location != NSNotFound || [imageName rangeOfString:@"jpeg"].location != NSNotFound) {
                    NSString *imagePath = [gifPath stringByAppendingPathComponent:imageName];
                    NSString *key = [imageName stringByDeletingPathExtension];
                    [imageDic setValue:imagePath forKey:key];
                }
            }
            NSMutableArray *imageMutableArray = [[NSMutableArray alloc]initWithCapacity:[imageDic allKeys].count];
            for (int i = 1; i <= [imageDic allKeys].count; i++) {
                NSString *key = [NSString stringWithFormat:@"%d",i];
                NSString *imagePath = [imageDic objectForKey:key];
                UIImage *image = [[UIImage alloc]initWithContentsOfFile:imagePath];
                [imageMutableArray addObject:image];
            }
            return imageMutableArray;
        }
    }
    return nil;
}

+ (ExtensionStaticToast*)getPersonalMarketExtensionStaticToast {
    NSArray *toastArray = [[NoahManager sharedPSInstance] getExtensionStaticToastAndKeyName:EXTENTION_MARKET];
    if (toastArray.count > 0) {
        ExtensionStaticToast *estToast = [toastArray objectAtIndex:0];
        if (estToast.tag.length > 0 && ([estToast.tag isEqualToString:@"allUser"] || [estToast.tag isEqualToString:@"needLogin"])) {
            return estToast;
        } else if ([UserDefaultsManager boolValueForKey:TOUCHPAL_USER_HAS_LOGIN]) {
            return estToast;
        }
        
    }
    return nil;
}


@end

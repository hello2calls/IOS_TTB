//
//  TPSkinInfo.m
//  TouchPalDialer
//
//  Created by Leon Lu on 13-5-13.
//
//

#import "TPSkinInfo.h"
#import "WebSkinInfoProvider.h"


@implementation TPSkinInfo

@synthesize isDefault;
@synthesize name;
@synthesize author;
@synthesize skinID;
@synthesize skinDir;
@synthesize version;
@synthesize skinIcon;
@synthesize isBuiltIn;
@synthesize hasSound;
@synthesize resourceURL;

- (id)initWithContentsOfFile:(NSString *)path
{
    if(self = [self init]) {
        NSDictionary *infoDict = [NSDictionary dictionaryWithContentsOfFile:path];
        self.isDefault = [[infoDict objectForKey:@"default"] boolValue];
        self.isNew = [[infoDict objectForKey:@"new"] boolValue];
        self.hasSound = [[infoDict objectForKey:@"sound"] boolValue];
        self.name = [infoDict objectForKey:NSLocalizedString(@"theme_name_en_us", @"")];
        self.skinID = [infoDict objectForKey:@"id"];
        self.skinDir = [path stringByDeletingLastPathComponent];
        self.version = [[infoDict objectForKey:@"version"] intValue];
        
        NSArray *arr = [self.skinDir componentsSeparatedByString:@"/"];
        NSString *shortName = (arr == nil) ? nil : arr[arr.count - 1];
        
        NSString *iconFullName = [NSString stringWithFormat:@"%@_%@%@", SKIN_ICON_IMAGE_PREFIX, shortName, @"@2x.png"];
        NSString *pathIcon = [NSString stringWithFormat:@"%@/%@/%@",skinDir,@"images", iconFullName];
        self.skinIcon = [UIImage imageWithContentsOfFile:pathIcon];
        self.isBuiltIn = [[infoDict objectForKey:@"builtIn"] boolValue];
        if ([name length] == 0 || [skinID length] == 0 || [skinDir length] == 0) {
            return nil;
        }
        if (self.skinIcon == nil) {
            return nil;
        }
        
        if (self.isBuiltIn) {
            self.previewPath = [WebSkinInfoProvider previewImagePathForBuiltinSkin:shortName];
            self.previewUrl = nil;
        } else {
            self.previewPath = [WebSkinInfoProvider previewImagePath:shortName];
            self.previewUrl = [WebSkinInfoProvider previewImageUrl:shortName];
        }
        
        // set priority
        self.priority = [WebSkinInfoProvider calculatePriorityByBuiltIn:self.isBuiltIn
                        hasSound:self.hasSound isNew:self.isNew];
    }
    
    return self;
}


@end

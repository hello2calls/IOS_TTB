//
//  TPSkinInfo.h
//  TouchPalDialer
//
//  Created by Leon Lu on 13-5-13.
//
//

#import <Foundation/Foundation.h>
#define ENABLE_SKIN_DEBUG (NO)


#define ENABLE_SKIN_AUTO_INSTALL (YES)
#define ICONS_FOLDER @"icons"

#define SKIN_PREVIEW_IMAGE_PREFIX @"skin_preview"
#define SKIN_ICON_IMAGE_PREFIX @"skin_icon"

#define ONLINE_PREVIEWS_FOLDER @"previews"
#define ONLINE_ICONS_FOLDER @"icons"


#define PRIORITY_SOUND (0x1)
#define PRIORITY_NEW  (0x2)
#define PRIORITY_BUILT_IN (0)

@interface TPSkinInfo : NSObject

- (id)initWithContentsOfFile:(NSString *)path;

@property(nonatomic, assign) BOOL isDefault;
@property(nonatomic, assign) BOOL isBuiltIn;
@property(nonatomic, assign) BOOL isNew;
@property(nonatomic, assign) BOOL hasSound;
@property(nonatomic, assign) NSInteger version;
@property(nonatomic, retain) NSString* name;
@property(nonatomic, retain) NSString* author;
@property(nonatomic, retain) NSString* skinID;
@property(nonatomic, retain) NSString* skinDir;
@property(nonatomic, retain) NSString *previewUrl;
@property(nonatomic, retain) NSString *previewPath;
@property(nonatomic, assign) NSInteger priority;

//for download use
@property(nonatomic, retain) UIImage* skinIcon;
@property(nonatomic, retain) NSString* resourceURL;
@end
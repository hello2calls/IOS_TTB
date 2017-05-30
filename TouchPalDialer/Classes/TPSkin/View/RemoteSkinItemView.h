//
//  RemoteSkinItemView.h
//  TouchPalDialer
//
//  Created by Leon Lu on 13-5-16.
//
//

#import <UIKit/UIKit.h>
#import "TPSkinInfo.h"

#define REMOTE_SKIN_ITEM_VIEW_WIDTH  (TPScreenWidth())
#define REMOTE_SKIN_ITEM_VIEW_HEIGHT 145.0f

typedef enum {
    RemoteSkinItemButtonStatusDownload,
    RemoteSkinItemButtonStatusCancel,
    RemoteSkinItemButtonStatusUse,
    
    SkinItemStatusNotDownloaded,
    SkinItemStatusDownloading,
    SkinItemStatusDownloaded,
    SkinItemStatusUsed,
    
    SkinItemActionDownload,
    SkinItemActionUse,
    SkinItemActionDelete,
} RemoteSkinItemButtonStatus;

@class RemoteSkinItemView;

@protocol RemoteSkinItemViewDelegate <NSObject>
- (void)remoteSkinItemViewButtonDidClick:(RemoteSkinItemView *)itemView;
- (void)buttonDidClick:(RemoteSkinItemView *)itemView;
- (void) remoteSkinItemIconDidClick:(RemoteSkinItemView *)itemView;
@end

@interface RemoteSkinItemView : UIView
@property (nonatomic, retain, readonly) TPSkinInfo *skinInfo;
@property (nonatomic, assign) RemoteSkinItemButtonStatus buttonStatus;
@property (nonatomic, assign) id<RemoteSkinItemViewDelegate> delegate;
@property (nonatomic, assign) float downloadProgress;
@property (nonatomic, assign) BOOL hornHidden;
- (id)initWithSkinInfo:(TPSkinInfo *)skinInfo;
- (void)setDownloadProgressAnimated:(float)downloadProgress;


@end

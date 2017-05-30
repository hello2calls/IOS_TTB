//
//  SkinPreviewViewController.h
//  TouchPalDialer
//
//  Created by siyi on 15/10/28.
//
//

#ifndef SkinPreviewViewController_h
#define SkinPreviewViewController_h

#import "TPSkinInfo.h"
#import "RemoteSkinReloadView.h"
#import "RemoteSkinItemView.h"
#import "CommonHeaderBar.h"

typedef NS_ENUM(NSInteger, ErrorType) {
    ERROR_NONE,
    ERROR_NO_NETWORK,
    ERROR_DOWNLOAD_FAILED,
    ERROR_LOCAL_FAILED,
};

@interface SkinPreviewViewController : UIViewController <RemoteSkinReloadViewDelegate, CommonHeaderBarProtocol>

- (instancetype) initWithSkinItemView: (id) skinItemView;

@end

#endif /* SkinPreviewViewController_h */

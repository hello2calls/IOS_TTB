//
//  YellowPageWebViewController.h
//  TouchPalDialer
//
//  Created by Simeng on 14-7-16.
//
//

#import "CootekWebViewController.h"
#import "PullDownSheet.h"
#import "EntranceIcon.h"

@interface YellowPageWebViewController : CootekWebViewController<EntranceIconDelegate>
@property(nonatomic, retain) TPHeaderButton *gobackBtn;
@property(nonatomic, retain) UIView *reloadView;
@property(nonatomic, retain) UIView *loadingView;
@property(nonatomic, retain) UIImageView *imageView;
@property(nonatomic, retain) UIImageView *wifiView;
@property(nonatomic, retain) UILabel *reloadLabel;
@property(nonatomic, retain) UIButton *reloadBtn;
@property(nonatomic, retain) UIImageView *loadingDissy;
@property(nonatomic, retain) UILabel *loadingLabel;
@property(nonatomic, assign) EntranceIcon *personalCenterButton;
@property(nonatomic, retain) NSString *funcStr;
- (void)exitEditingMode;
@end

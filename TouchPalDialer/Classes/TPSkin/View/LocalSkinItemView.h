//
//  LocalSkinItemView.h
//  TouchPalDialer
//
//  Created by Leon Lu on 13-5-15.
//
//

#import <UIKit/UIKit.h>
#import "TPSkinInfo.h"
#import "RemoteSkinItemView.h"


@class LocalSkinItemView;

@protocol LocalSkinItemViewDelegate <NSObject>
- (void)localSkinItemViewDeleteButtonDidClick:(LocalSkinItemView *)itemView;
- (void)localSkinItemViewDidClick:(LocalSkinItemView *)itemView;
- (void) localSkinItemIconDidClick:(LocalSkinItemView *)itemView;
@end

@interface LocalSkinItemView : UIView

- (id)initWithSkinInfo:(TPSkinInfo *)skinInfo;
@property (nonatomic, assign) BOOL showsCheckedView;
@property (nonatomic, assign) BOOL showsDeleteButton;
@property (nonatomic, assign) BOOL isChecked;
@property (nonatomic, retain) UILabel *horn;
@property (nonatomic, retain, readonly) TPSkinInfo *skinInfo;
@property (nonatomic, assign) id<LocalSkinItemViewDelegate> delegate;
@property (nonatomic, assign) BOOL inEditing;
- (void) setButtonStatus: (RemoteSkinItemButtonStatus)status isEditing: (BOOL)isEditing;
@property (nonatomic, assign) RemoteSkinItemButtonStatus buttonStatus;

@end

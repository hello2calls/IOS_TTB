//
//  VoipShareAllView.h
//  TouchPalDialer
//
//  Created by game3108 on 15/3/30.
//
//

#import <UIKit/UIKit.h>
#import "TPWebShareController.h"

typedef  enum {
    shareApp = 1,
    shareAntiFeature = 2,
} SystemShareType;

@interface VoipShareAllView : UIView
@property (nonatomic, retain) NSString *fromWhere;
@property (nonatomic, retain) NSString *msgPhone;
@property (nonatomic, retain) NSString *imageUrl;
@property (nonatomic, retain) UIImage *image;
@property (nonatomic,   copy) ShareResultCallback shareResultCallback;

- (id)initWithFrame:(CGRect)frame title:(NSString*)title msg:(NSString*)msg url:(NSString*)url image:(UIImage *)image;
- (id)initWithFrame:(CGRect)frame title:(NSString*)title msg:(NSString*)msg url:(NSString*)url buttonArray:(NSArray*)array;
- (void)setHeadTitle:(NSString*)headTitle;

+ (void)shareWithTitle:(NSString *)title msg:(NSString *)msg url:(NSString *)url imageUrl:(NSString *)iamgeUrl andFrom:(NSString *)source image:(UIImage *)image;

@end

//
//  WebLoadingView.h
//  TouchPalDialer
//
//  Created by siyi on 15/10/29.
//
//

#ifndef TPLoadingView_h
#define TPLoadingView_h

@interface TPLoadingView : UIView

- (instancetype) initWithImage:(UIImage *) image mainTitle:(NSString *) mainTitle subTitle:(NSString *)subTitle;
- (instancetype) initWithImagePath:(NSString *) imagePath mainTitle:(NSString *) mainTitle subTitle:(NSString *)subTitle;

- (instancetype) initWithImage:(UIImage *)image mainTitle:(NSString *)mainTitle;
- (instancetype) initWithImagePath:(UIImage *)image mainTitle:(NSString *)mainTitle;

- (void) startAnimation;
- (void) stopAnimation;

@property (nonatomic, retain) UILabel *mainTitleLabel;
@property (nonatomic, retain) UILabel *subTitleLabel;
@property (nonatomic, retain) UIImageView *loadingImageView;

@end

#endif /* TPLoadingView_h */

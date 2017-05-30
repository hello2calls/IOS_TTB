//
//  FeedsHeaderView.h
//  TouchPalDialer
//
//  Created by lin tang on 16/10/20.
//
//

#import <UIKit/UIKit.h>

@interface FeedsHeaderView : UIView
@property (nonatomic, retain) UILabel *refreshLabel;
@property (nonatomic, retain) UIImageView *refreshArrow;
@property (nonatomic, retain) UIActivityIndicatorView *refreshSpinner;
@property (nonatomic, copy) NSString *textPull;
@property (nonatomic, copy) NSString *textRelease;
@property (nonatomic, copy) NSString *textLoading;

- (void)loadRequestDataFailed;
- (void)startLoading ;
- (void)stopLoadingwithRefresh:(BOOL)refresh andBlock:(void(^)(void))block  andFeedsCount:(int)count;
- (void)stopLoadingComplete;
- (void)srcollViewWithOffset:(CGFloat) offsetY;

@end

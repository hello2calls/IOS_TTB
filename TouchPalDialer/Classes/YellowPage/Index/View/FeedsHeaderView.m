//
//  FeedsHeaderView.m
//  TouchPalDialer
//
//  Created by lin tang on 16/10/20.
//
//

#import "FeedsHeaderView.h"
#import "ImageUtils.h"
#import "IndexConstant.h"
#import "DialerUsageRecord.h"
#import "UsageConst.h"

#define REFRESH_HEADER_HEIGHT 52.0f
#define UPDATE_HEADER_HEIGHT 36.0f

@interface FeedsHeaderView()
{
    NSNumber* currentUpdateTime;
}
@end
@implementation FeedsHeaderView
@synthesize refreshLabel;
@synthesize refreshArrow;
@synthesize refreshSpinner;
@synthesize textPull;
@synthesize textLoading;
@synthesize textRelease;

-(instancetype) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        refreshLabel = [[UILabel alloc] initWithFrame:CGRectMake(TPScreenWidth() / 2, 0, TPScreenWidth() / 2, REFRESH_HEADER_HEIGHT)];
        refreshLabel.backgroundColor = [UIColor clearColor];
        refreshLabel.font = [UIFont systemFontOfSize:12.0];
        refreshLabel.textAlignment = NSTextAlignmentLeft;
        
        NSString *arrowPath = [[NSBundle mainBundle] pathForResource:@"webpages/res/image/arrow" ofType:@"png"];
        refreshArrow = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:arrowPath]];
        refreshArrow.frame = CGRectMake(TPScreenWidth() / 2 - 50,
                                        (floorf(REFRESH_HEADER_HEIGHT - 44) / 2),
                                        22, 36);
        
        refreshSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        refreshSpinner.frame = CGRectMake(TPScreenWidth() / 2 - 10, floorf((REFRESH_HEADER_HEIGHT - 20) / 2), 20, 20);
        refreshSpinner.hidesWhenStopped = YES;
        
        [self addSubview:refreshLabel];
        [self addSubview:refreshArrow];
        [self addSubview:refreshSpinner];
        
            [self setupStrings];
    }
    
    return self;
}


- (void)setupStrings{
    textPull = @"下拉可以刷新...";
    textRelease = @"释放开始刷新...";
    textLoading = @"";
}

- (void)loadRequestDataFailed
{
    refreshLabel.hidden = NO;
    refreshLabel.textColor = [UIColor redColor];
    refreshLabel.text = @"请确认网络连接是否正常后下拉重试";
    refreshLabel.font = [UIFont systemFontOfSize:12.0];
    refreshLabel.textAlignment = NSTextAlignmentCenter;
    refreshLabel.frame = CGRectMake(0, refreshLabel.frame.origin.y, TPScreenWidth(), refreshLabel.frame.size.height);
    refreshArrow.hidden = YES;
}

- (void)startLoading {
    currentUpdateTime = 0;
    refreshArrow.hidden = YES;
    refreshLabel.text = self.textLoading;
    refreshLabel.font = [UIFont systemFontOfSize:12.0];
    refreshLabel.textAlignment = NSTextAlignmentLeft;
    refreshLabel.frame = CGRectMake(TPScreenWidth() / 2, 0, TPScreenWidth() / 2, REFRESH_HEADER_HEIGHT);
    refreshLabel.backgroundColor = [UIColor clearColor];
    refreshLabel.hidden = NO;
    [refreshSpinner startAnimating];
}

- (void)stopLoadingwithRefresh:(BOOL)refresh andBlock:(void(^)(void))block  andFeedsCount:(int)count
{
    if (refresh && count > 0) {
         [DialerUsageRecord recordCustomEvent:PATH_FEEDS module:FEEDS_MODULE event:FEEDS_REFRESH_LOAD_SUCCESS];
        
        refreshArrow.hidden = YES;
        [refreshSpinner stopAnimating];
        refreshLabel.transform = CGAffineTransformMakeScale(0.8, 1.0);
        refreshLabel.font = [UIFont systemFontOfSize:16.0];
        refreshLabel.text = [NSString stringWithFormat:@"成功为您更新%d条新闻", count];
        refreshLabel.textColor = [ImageUtils colorFromHexString:FEEDS_UPDATE_TEXT_COLOR andDefaultColor:nil];
        refreshLabel.backgroundColor = [ImageUtils colorFromHexString:FEEDS_UPDATE_BG_COLOR andDefaultColor:nil];
        refreshLabel.frame = CGRectMake(0, 0, TPScreenWidth(), REFRESH_HEADER_HEIGHT);
        refreshLabel.textAlignment = NSTextAlignmentCenter;
        refreshLabel.hidden = NO;
        [UIView animateWithDuration:0.3 animations:^{
            refreshLabel.transform = CGAffineTransformMakeScale(1.1, 1.0);
        } completion:^(BOOL finished) {
            refreshLabel.transform = CGAffineTransformMakeScale(1.0, 1.0);
        }];
        
        NSNumber* refreshTime = [NSNumber numberWithDouble:[[NSDate new] timeIntervalSince1970]];
        currentUpdateTime = refreshTime;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            if (refreshTime.longLongValue == currentUpdateTime.longLongValue) {
                refreshLabel.backgroundColor = [UIColor clearColor];
                refreshLabel.hidden = NO;
                refreshLabel.text = @"";
                refreshLabel.textColor = [UIColor blackColor];
                if (block) {
                    block();
                }
            }
        });
    } else {
        if (block) {
            block();
        }
    }

}

- (void)stopLoadingComplete {
    // Reset the header
    refreshLabel.text = @"";
    refreshLabel.hidden = NO;
    [refreshSpinner stopAnimating];
}

- (void)srcollViewWithOffset:(CGFloat) offsetY
{
    refreshArrow.hidden = NO;
    refreshLabel.textAlignment = NSTextAlignmentLeft;
    refreshLabel.font = [UIFont systemFontOfSize:12.0];
    refreshLabel.backgroundColor = [UIColor clearColor];
    refreshLabel.frame = CGRectMake(TPScreenWidth() / 2, 0, TPScreenWidth() / 2, REFRESH_HEADER_HEIGHT);
    refreshLabel.textColor = [UIColor blackColor];
    // Update the arrow direction and label
    [UIView animateWithDuration:0.25 animations:^{
        if (offsetY< -REFRESH_HEADER_HEIGHT) {
            // User is scrolling above the header
            refreshLabel.text = self.textRelease;
            [refreshArrow layer].transform = CATransform3DMakeRotation(M_PI, 0, 0, 1);
        } else {
            // User is scrolling somewhere within the header
            refreshLabel.text = self.textPull;
            [refreshArrow layer].transform = CATransform3DMakeRotation(M_PI * 2, 0, 0, 1);
        }
    }];
}
@end

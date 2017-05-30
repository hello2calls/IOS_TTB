//
//  BannerScrollView.m
//  TouchPalDialer
//
//  Created by tanglin on 15-5-14.
//
//


#import <Foundation/Foundation.h>
#import "BannerScrollView.h"
#import "TPDialerResourceManager.h"
#import "TPUIButton.h"
#import "YellowPageWebViewController.h"
#import "UIDataManager.h"
#import "YellowPageMainTabController.h"
#import "CTUrl.h"
#import "IndexConstant.h"
#import "ImageUtils.h"
#import "IndexConstant.h"
#import "SectionBanner.h"
#import "SectionGroup.h"
#import "NSTimer+Addition.h"
#import "TPAnalyticConstants.h"
#import "DialerUsageRecord.h"
#import "EdurlManager.h"
#import "BannerItem.h"
#import "AdInfoModelManager.h"
#import "UpdateService.h"

#define BANNER_ANIMATION_INTERVAL_TIME 5
@interface BannerScrollView()
{
    CGFloat frameWidth;
    CGPoint startPoint;
    BOOL isLoop;
}

@property(nonatomic, retain) UIImageView* leftView;
@property(nonatomic, retain) UIImageView* centerView;
@property(nonatomic, retain) UIImageView* rightView;
@property(nonatomic, retain) UIImage* leftImage;
@property(nonatomic, retain) UIImage* centerImage;
@property(nonatomic, retain) UIImage* rightImage;
@property(nonatomic, retain) NSTimer* repeatingTimer;
@property(nonatomic, assign) NSInteger animationDuration;

@end
@implementation BannerScrollView

- (id)initWithFrame:(CGRect)frame andData:(SectionGroup *)group andPageControl:(UIPageControl *)pageControl {
    
    self = [super initWithFrame:frame];
    
    frameWidth = frame.size.width;
    CGFloat width = frameWidth * 3;
    
    self.contentSize = CGSizeMake(width, frame.size.height);
    
    self.item = group;
    self.pageControl = pageControl;
    
    self.delegate = self;
    self.animationDuration = BANNER_ANIMATION_INTERVAL_TIME;
    if (self.item.sectionArray.count <= 1) {
        self.pagingEnabled = NO;
        self.scrollEnabled = NO;
        isLoop = NO;
    } else {
        self.pagingEnabled = YES;
        isLoop = YES;
        self.repeatingTimer = [NSTimer scheduledTimerWithTimeInterval:self.animationDuration target:self selector:@selector(automaticScrollView:) userInfo:nil repeats:YES];
        
        [[NSRunLoop mainRunLoop] addTimer:self.repeatingTimer forMode:NSDefaultRunLoopMode];
    }
    [self initSubViews:frame];
    
    self.showsHorizontalScrollIndicator = false;
    self.bounces = NO;
    
    [self setTag:BANNER_TAG];
    
    
    return self;
}

- (void) initSubViews:(CGRect)frame
{
    
    CGFloat width = frame.size.width;
    CGFloat height = frame.size.height;
    
    CGRect leftFrame = CGRectMake(0, 0, width, height);
    UIImageView* leftV = [[UIImageView alloc]initWithFrame:leftFrame];
    self.leftView = leftV;
    
    self.leftView.frame = leftFrame;
    [self addSubview:self.leftView];
    
    CGRect centerFrame = CGRectMake(width, 0, width, height);
    UIImageView* centerV = [[UIImageView alloc]initWithFrame:centerFrame];
    self.centerView = centerV;
    
    self.centerView.frame = centerFrame;
    [self addSubview:self.centerView];
    
    CGRect rightFrame = CGRectMake(2 * width, 0, width, height);
    UIImageView* rightV = [[UIImageView alloc]initWithFrame:rightFrame];
    self.rightView = rightV;
    
    self.rightView.frame = rightFrame;
    [self addSubview:self.rightView];
    
    self.contentOffset = CGPointMake(width, 0);
    
    [self drawView:self.item];
}

-(void) drawView:(SectionGroup*)group
{
    self.item = group;
    if (self.item.sectionArray.count <= 1) {
        self.pagingEnabled = NO;
        self.scrollEnabled = NO;
        isLoop = NO;
        if (self.repeatingTimer) {
            [self.repeatingTimer pauseTimer];
        }
    } else {
        self.pagingEnabled = YES;
        self.scrollEnabled = YES;
        isLoop = YES;
        if (!self.repeatingTimer) {
            self.repeatingTimer = [NSTimer scheduledTimerWithTimeInterval:self.animationDuration target:self selector:@selector(automaticScrollView:) userInfo:nil repeats:YES];
            [[NSRunLoop mainRunLoop] addTimer:self.repeatingTimer forMode:NSDefaultRunLoopMode];
        } else {
           [self.repeatingTimer resumeTimerAfterTimeInterval:self.animationDuration];
        }
    }
    SectionBanner* current = [self.item.sectionArray objectAtIndex:self.item.current];
    self.leftImage = [self previosImage];
    self.centerImage = [ImageUtils getImageFromLocalWithUrl:((BaseItem *)[current.items objectAtIndex:0]).iconLink];
    self.rightImage = [self nextImage];
    self.leftView.image = self.leftImage;
    self.centerView.image = self.centerImage;
    self.rightView.image = self.rightImage;
    BannerItem* currentItem = [current.items objectAtIndex:0];
    [[EdurlManager instance] requestEdurl:currentItem.edMonitorUrl];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    if (self.pressed) {
        self.centerView.alpha = 0.75f;
    } else {
        self.centerView.alpha = 1;
    }
}

-(UIImage*) previosImage
{
    int preIndex = 0;
    if (self.item.current > 0) {
        preIndex = self.item.current - 1;
    } else {
        preIndex = self.item.sectionArray.count - 1;
    }
    SectionBanner* banner = [self.item.sectionArray objectAtIndex:preIndex];
    return [ImageUtils getImageFromLocalWithUrl:((BaseItem *)[banner.items objectAtIndex:0]).iconLink];
}

-(UIImage*) nextImage
{
    int nextIndex = 0;
    if (self.item.current == self.item.sectionArray.count - 1) {
        nextIndex = 0;
    } else {
        nextIndex = self.item.current + 1;
    }
    SectionBanner* banner = [self.item.sectionArray objectAtIndex:nextIndex];
    return [ImageUtils getImageFromLocalWithUrl:((BaseItem *)[banner.items objectAtIndex:0]).iconLink];
}



- (void) doClick {
    SectionBanner* banner = [self.item.sectionArray objectAtIndex:self.item.current];
    BannerItem* item = (BannerItem *)[banner.items objectAtIndex:0];
    UIViewController* controller = [item.ctUrl startWebView];
    
    [DialerUsageRecord recordYellowPage:EV_YELLOWPAGE_BANNER_ITEM kvs:Pair(@"action", @"selected"), Pair(@"index",@(self.item.current)), nil];
    
    if (item.tu) {
        AdInfoModel* model = [[AdInfoModel alloc]initWithS:item.s andTu:item.tu andAdid:item.adid];
        [AdInfoModelManager initWithAd:model webController:controller];
    }
    
    [[EdurlManager instance] sendCMonitorUrl:item];
    
}

- (void)automaticScrollView:(NSTimer *)timer
{
    CGPoint p = CGPointMake(self.contentOffset.x + self.frame.size.width, self.contentOffset.y);
    [self setContentOffset:p animated:true];
}

#pragma mark -
#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (isLoop) {
        [self.repeatingTimer pauseTimer];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (isLoop) {
        [self.repeatingTimer resumeTimerAfterTimeInterval:self.animationDuration];
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
   [self scrollOffsetReset:scrollView];
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self scrollOffsetReset:scrollView];
}

-(void)scrollOffsetReset:(UIScrollView *)scrollView
{
    if(scrollView.contentOffset.x >= - SCROLL_OFFSET_UNIT && scrollView.contentOffset.x <= SCROLL_OFFSET_UNIT)
    {
        if(self.item.current == 0) {
            self.item.current = self.item.sectionArray.count - 1;
        } else {
            self.item.current = self.item.current - 1;
        }
        
        if (self.item.sectionArray.count == 2) {
            UIImage* tempImage = self.leftView.image;
            self.leftView.image = self.centerView.image;
            self.rightView.image = self.centerView.image;
            self.centerView.image = tempImage;
        } else {
            UIImage* tempImage = self.leftView.image;
            self.leftView.image = [self previosImage];
            self.rightView.image = self.centerView.image;
            self.centerView.image = tempImage;
        }
    }
    if (scrollView.contentOffset.x >= 2 * frameWidth - SCROLL_OFFSET_UNIT && scrollView.contentOffset.x <= 2 * frameWidth + SCROLL_OFFSET_UNIT) {
        
        if(self.item.current == self.item.sectionArray.count - 1) {
            self.item.current = 0;
        } else {
            self.item.current = self.item.current + 1;
        }
        
        if (self.item.sectionArray.count == 2) {
            UIImage* tempImage = self.leftView.image;
            self.leftView.image = self.centerView.image;
            self.rightView.image = self.centerView.image;
            self.centerView.image = tempImage;
        } else {
            UIImage* tempImage = self.rightView.image;
            self.rightView.image = [self nextImage];
            self.leftView.image = self.centerView.image;
            self.centerView.image = tempImage;
        }
    }
    self.pageControl.currentPage = self.item.current;
    SectionBanner* banner = (SectionBanner *)[self.item.sectionArray objectAtIndex:self.pageControl.currentPage];
    BannerItem* currentItem = [banner.items objectAtIndex:0];
    [[EdurlManager instance] requestEdurl:currentItem.edMonitorUrl];
    
    scrollView.contentOffset = CGPointMake(frameWidth, 0);
}
@end

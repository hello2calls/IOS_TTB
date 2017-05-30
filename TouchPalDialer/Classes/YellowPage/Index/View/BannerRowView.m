//
//  BannerViewController.m
//  TouchPalDialer
//
//  Created by tanglin on 15-4-2.
//
//
#import "BannerRowView.h"
#import "BannerScrollView.h"
#import "SectionGroup.h"
#import "SectionBanner.h"
#import "IndexConstant.h"
#import "ImageUtils.h"
#import "BannerItem.h"

@interface BannerRowView()
{
    UIPageControl *pageControl;
}

@end
@implementation BannerRowView

- (id)initWithFrame:(CGRect)frame andData:(SectionGroup *)group
{
    self = [super initWithFrame:frame];
    
    
    pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(self.bounds.size.width - 150, INDEX_ROW_HEIGHT_BANNER - 30, 150, 40)];
    pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(self.bounds.size.width - 150, self.bounds.size.height - 30, 150, 40)];
    pageControl.backgroundColor = [UIColor clearColor];
    
    pageControl.pageIndicatorTintColor = [UIColor whiteColor];
    pageControl.currentPageIndicatorTintColor = [UIColor redColor];
    pageControl.numberOfPages = group.sectionArray.count;
    pageControl.currentPage = group.current;
    pageControl.hidesForSinglePage = YES;
    pageControl.defersCurrentPageDisplay = YES;
    
    self.scrollView = [[BannerScrollView alloc]initWithFrame:self.bounds andData:group andPageControl: pageControl];

    [self addSubview:self.scrollView];
    [self addSubview:pageControl];
    
    [self setTag:BANNER_TAG];
    
    return self;
}

- (void) resetWithBannerData:(SectionGroup* )data
{
    [self.scrollView drawView:data];
    pageControl.numberOfPages = data.sectionArray.count;
    pageControl.currentPage = data.current;
}

+ (BOOL)checkImageReady:(SectionGroup *)group
{
    for (SectionBanner* banner in group.sectionArray) {
        BannerItem* item = [banner.items objectAtIndex:0];
        if([ImageUtils getImageFromLocalWithUrl:item.iconLink] == nil) {
            return NO;
        }
    }
    return YES;
}


@end
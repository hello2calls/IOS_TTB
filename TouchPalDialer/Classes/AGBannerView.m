//
//  AGBannerView.m
//  CCMTClient
//
//  Created by LH on 16/4/28.
//  Copyright © 2016年 CCMT. All rights reserved.
//

#import "AGBannerView.h"
#import <UIKit/UIKit.h>
//#import "UtilityFunc.h"
#import "UIImageView+WebCache.h"

#define UserDefaults                        [NSUserDefaults standardUserDefaults]
#define Rect(x, y, w, h)                    CGRectMake(x, y, w, h)
#define Screen                              [UIScreen mainScreen]
#define ScreenRect                          [[UIScreen mainScreen] bounds]
#define ScreenSize                          [[UIScreen mainScreen] bounds].size
#define ScreenWidth                         [[UIScreen mainScreen] bounds].size.width
#define ScreenHeight                        [[UIScreen mainScreen] bounds].size.height
#define Size(w, h)                          CGSizeMake(w, h)
#define Point(x, y)                         CGPointMake(x, y)
#define RGB(r, g, b)                        [UIColor colorWithRed:(r)/255.f green:(g)/255.f blue:(b)/255.f alpha:1.f]
#define RGBA(r, g, b, a)                    [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define Wframe(a)                           (a/2)//(a/640.0) * ([[UIScreen mainScreen] bounds].size.width)
#define Hframe(b)                           (b/2)
#define choiceOfFrame                       ((([[UIScreen mainScreen] bounds].size.height)==480.0)?(568.0):([[UIScreen mainScreen] bounds].size.height))



typedef NS_ENUM (NSUInteger, AGslideViewType) {
    /// No truncate.
    AGslideViewTypeNoData        ,
    
    /// Truncate at the beginning of the line, leaving the end portion visible.
    AGslideViewTypeBannerIamges  ,
    
    /// Truncate in the middle of the line, leaving both the start and the end portions visible.
    AGslideViewTypeOhters        ,
};



@interface AGBannerView ()<UIScrollViewDelegate>

@property (nonatomic, copy  )      imageCLick  iamgeHandle;         //回调代码块
@property (nonatomic, strong) NSMutableArray*  imageArray;          //广告图数组
@property (nonatomic, strong) UIScrollView  *  backScrollView;      //背景滑动页面
@property (nonatomic, strong) UIPageControl *  page;                //背景滑动页面
@property (nonatomic, strong) NSTimer       *  timer;               //倒计时

@end

@implementation AGBannerView

- (instancetype)initWithImageArray:(NSArray *)imageArray clickHandler:(imageCLick)clickHandler{
    self = [super initWithFrame:CGRectMake(0, 00, ScreenWidth, ScreenWidth * 133 / 320)];
    
    if (self) {
        _rollingInterval = 5;
 
       if(![imageArray isKindOfClass:[NSArray class]] || imageArray.count == 0 ){
           [self viewConfig:AGslideViewTypeNoData];
           
       }else{
           
           _imageArray = [[NSMutableArray alloc]initWithArray:imageArray];
           
           [self viewConfig:AGslideViewTypeBannerIamges];
           
           _iamgeHandle = clickHandler;

       }
           

    }
    return self;


}

- (void)updateBannerByArray:(NSArray *)imageArray clickHandler:(imageCLick)clickHandler{
    
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];

    if (_imageArray == nil) {
        _imageArray = [NSMutableArray new];
    } else {
        [_imageArray removeAllObjects];
    }
 
    
    if(![imageArray isKindOfClass:[NSArray class]] || imageArray.count == 0 ){
        
        [self viewConfig:AGslideViewTypeNoData];

    }else{
        
        for (int i = 0 ; i < imageArray.count; i ++ ) {
            [_imageArray addObject:imageArray[i]];
        }
        [self viewConfig:AGslideViewTypeBannerIamges];
        _iamgeHandle = clickHandler;

    }

}
#pragma mark - view config

- (void)viewConfig:(AGslideViewType)type{
  
    
    if (type == AGslideViewTypeBannerIamges) {
     
        if (self.backScrollView == nil) {
            self.backScrollView = [[UIScrollView alloc]init];
        }
        int count = 0 ;
        if (_imageArray.count == 1) {
            count = 1;
        }else {
            count = _imageArray.count + 2;
        }

        self.backScrollView.frame = CGRectMake(0, 0, ScreenWidth, ScreenWidth * 133 / 320);
        self.backScrollView.contentSize = CGSizeMake(ScreenWidth *count, ScreenWidth * 133 / 320);
        self.backScrollView.backgroundColor = [UIColor whiteColor];
        self.backScrollView.pagingEnabled = YES;
        self.backScrollView.bounces = NO;
        self.backScrollView.showsHorizontalScrollIndicator = NO;
        self.backScrollView.contentOffset = CGPointMake(count == 1 ? 0: ScreenWidth, 0);
        self.backScrollView.delegate  = self;

        for (int index = 0 ; index < count ; index ++) {
        UIImageView *imageDisplayView = [[UIImageView alloc]initWithFrame:CGRectMake(0 + index * ScreenWidth, 0, ScreenWidth, ScreenWidth * 133 / 320)];
//            imageDisplayView.backgroundColor = [self randomColor];
            imageDisplayView.image  = [UIImage imageNamed:@"fb-hangup-callback-success"];
            imageDisplayView.contentMode = UIViewContentModeScaleAspectFit;

//            if (index == 0) {
//                [imageDisplayView sd_setImageWithURL:[NSURL URLWithString:[_imageArray lastObject]] placeholderImage:[UIImage imageNamed:@"bannerPlaceHolder"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) { }];
//            }
//            if (index == count - 1 && index != 0) {
//                [imageDisplayView sd_setImageWithURL:[NSURL URLWithString:_imageArray[0]] placeholderImage:[UIImage imageNamed:@"bannerPlaceHolder"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) { }];
//            }
//            if (index != 0  && index != count - 1) {
//                [imageDisplayView sd_setImageWithURL:[NSURL URLWithString:_imageArray[index - 1]] placeholderImage:[UIImage imageNamed:@"bannerPlaceHolder"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) { }];
//            }
//            if (index == 0) {
//                [imageDisplayView setImage:[UIImage imageNamed:@"1.png"]];
//            }
//            if (index == count - 1 && index != 0) {
//                [imageDisplayView setImage:[UIImage imageNamed:@"1.png"]];
//            }
//            if (index != 0  && index != count - 1) {
//                [imageDisplayView setImage:[UIImage imageNamed:@"guahao.png"]];
//            }
//
            
        imageDisplayView.userInteractionEnabled = YES;
        [self.backScrollView addSubview:imageDisplayView];
        imageDisplayView.tag = index + 1000;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapViewClick:)];
        [imageDisplayView addGestureRecognizer:tap];
           
           }
        [self addSubview:self.backScrollView];
      
        if (_imageArray.count > 1) {
            if (self.page == nil) {
                self.page = [[UIPageControl alloc]init];
            }
            CGFloat pageOffSet = _imageArray.count > 4 ? 90 : 70;
            _page.frame = CGRectMake(ScreenWidth - pageOffSet, ScreenWidth * 133 / 320 - 30, pageOffSet, 30);
            _page.numberOfPages = _imageArray.count;
            _page.currentPage = 0;
            [self addSubview:_page];
        }
        if (_imageArray.count != 1 ) {
            [self scrollViewAutoScrolllByTime:5];
        }

    } else {//无数据
        if (self.backScrollView == nil) {
            self.backScrollView = [[UIScrollView alloc]init];
        }
        self.backScrollView.frame = CGRectMake(0, 0, ScreenWidth, ScreenWidth * 133 / 320);
        self.backScrollView.contentSize = CGSizeMake(ScreenWidth , ScreenWidth * 133 / 320);
        self.backScrollView.backgroundColor = [UIColor whiteColor];
        self.backScrollView.pagingEnabled = YES;
        self.backScrollView.showsHorizontalScrollIndicator = NO;
        [self addSubview:_backScrollView];

        UIImageView *imageDisplayView = [[UIImageView alloc]initWithFrame:CGRectMake(0 , 0, ScreenWidth, ScreenWidth * 133 / 320)];
        imageDisplayView.backgroundColor = [UIColor grayColor];
        imageDisplayView.userInteractionEnabled = YES;
        [self.backScrollView addSubview:imageDisplayView];

    }

}

#pragma mark view config end


#pragma mark - click delegate
- (void)tapViewClick:(UITapGestureRecognizer*)tap{
    [self distantScroll];
    
    if (UIGestureRecognizerStateEnded == tap.state && _imageArray.count != 1) {
         [self continueScroll];
    }
    
  
    _iamgeHandle(_imageArray.count > 1 ? _page.currentPage : 0 );

}

#pragma mark  click end

#pragma mark - sroll delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{

        int intOffset = scrollView.contentOffset.x / 1;
        /* 0 1 2 3*/
    if (intOffset % (int)ScreenWidth != 0){
    
        
        return;
    }
    ;
        int pageNumber = scrollView.contentOffset.x / ScreenWidth;
        if (pageNumber == 0) {
            _page.currentPage = _imageArray.count - 1;
            [_backScrollView setContentOffset:CGPointMake(ScreenWidth *_imageArray.count , 0) animated:NO];
            return;
        }
        if (pageNumber == _imageArray.count + 1 ) {
            _page.currentPage = 1;
            [_backScrollView setContentOffset:CGPointMake(ScreenWidth , 0) animated:NO];
            return;
        }
        _page.currentPage = pageNumber-1;
}
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{

    int intOffset = scrollView.contentOffset.x / 1;
    if (intOffset % (int)ScreenWidth != 0 ){
        int pageNumber = scrollView.contentOffset.x / ScreenWidth;
        [_backScrollView setContentOffset:CGPointMake(ScreenWidth *(pageNumber + 1) , 0) animated:YES];
        NSLog(@"异常");
    }
    

}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    [self distantScroll];

}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [self continueScroll];

}

#pragma mark  sroll delegate end
#pragma mark - sroll tick delegate


- (void)scrollViewAutoScrolllByTime:(int)time{
    [self beginToScroll];
}

- (void)scrollViewPro{
    [self performSelectorOnMainThread:@selector(delayPerform) withObject:nil waitUntilDone:YES];
}

- (void)beginToScroll{
    
    NSDate *scheduledTime = [NSDate dateWithTimeIntervalSinceNow:4.0];
    _timer  = [[NSTimer alloc] initWithFireDate:scheduledTime
                                       interval:4
                                         target:self
                                       selector:@selector(scrollViewPro)
                                       userInfo:nil
                                        repeats:YES];
    
    NSRunLoop *runloop=[NSRunLoop currentRunLoop];
    [runloop addTimer:_timer forMode:NSDefaultRunLoopMode];

}

- (void)delayPerform{

    CGPoint point = _backScrollView.contentOffset;
    if((int)point.x % (int)_backScrollView.frame.size.width != 0)
    {
        point.x = _backScrollView.frame.size.width * (1 + (int)(point.x / _backScrollView.frame.size.width));
    }
    else{
        point.x += _backScrollView.frame.size.width;
    }
    
    [_backScrollView setContentOffset:point animated:YES];
    
}

- (void)distantScroll{
    [_timer setFireDate:[NSDate distantFuture]];
}

- (void)continueScroll{
    [_timer setFireDate:[NSDate dateWithTimeInterval:self.rollingInterval sinceDate:[NSDate date]]];
}

-(NSTimeInterval)rollingInterval {
    if (_rollingInterval < 1) {
        _rollingInterval = 1;
    }
    
    return _rollingInterval;
}

- (UIColor *)randomColor {
    
    return [UIColor colorWithRed:arc4random() % 101 / 100.f
                           green:arc4random() % 101 / 100.f
                            blue:arc4random() % 101 / 100.f
                           alpha:1];
}


#pragma mark  sroll tick delegate end
@end

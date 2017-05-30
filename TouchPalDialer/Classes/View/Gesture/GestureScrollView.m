//
//  GestureScrollView.m
//  TouchPalDialer
//
//  Created by Admin on 7/1/13.
//
//

#import "GestureScrollView.h"
#import "PageView.h"
#import "CootekNotifications.h"
#import "UIView+WithSkin.h"
#import "SkinHandler.h"
#import "GestureSinglePageView.h"
#import "TPPageController.h"

@interface GestureScrollView () 
@property(nonatomic,assign)	NSInteger pageNumber;
@property(nonatomic,assign) CGRect scrollViewFrame;
@end

@implementation GestureScrollView

@synthesize gestureCustomList;
@synthesize pageNumber;
@synthesize pageController;
@synthesize	scrollView;
@synthesize currentPage;
@synthesize scrollViewFrame;
@synthesize isEdit;

- (id)initWithFrame:(CGRect)frame isEdit:(BOOL)editMode WithCurrentPage:(NSInteger)cPage
{    
    self = [super initWithFrame:frame];
    if (self) {
        self.pageNumber = [self.gestureCustomList count]/9+1;
		self.currentPage=cPage;
        self.scrollViewFrame = frame;
        self.isEdit = editMode;
		[self loadScrollView];
    }
    return self;
}

- (void)loadScrollView
{
    self.gestureCustomList = [NSMutableArray arrayWithArray
                              :[[GestureModel getShareInstance].mGestureRecognier getGestureList]];
    self.pageNumber = [self.gestureCustomList count]/9+1;
    [self.scrollView removeFromSuperview];
    [self.pageController removeFromSuperview];
    // a page is the width of the scroll view
    self.scrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, TPScreenWidth(), TPScreenHeight()-90)];
    [self.scrollView setSkinStyleWithHost:self forStyle:NO_STYLE];
    
    if (self.pageNumber <= 1) {
        self.scrollView.scrollEnabled = NO;
    } else {
        self.scrollView.scrollEnabled = YES;
    }
    
    self.scrollView.pagingEnabled = YES;
    self.scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * pageNumber, scrollView.frame.size.height);
    self.scrollView.showsHorizontalScrollIndicator = YES;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.scrollsToTop = NO;
    self.scrollView.bounces = NO;
    self.scrollView.delegate = self;
    [self addSubview:self.scrollView];
    
    TPPageController *pageControl = [[TPPageController alloc] initWithFrame:CGRectMake(0, TPHeightFit(350),
                                                                                  TPScreenWidth(), 23)];
    pageControl.numberOfPages = self.pageNumber;
    [pageControl setSkinStyleWithHost:self forStyle:@"pageControl_style"];
    
    if (self.currentPage < self.pageNumber) {
        self.pageController.currentPage = self.currentPage;
    } else if (self.currentPage-1 > 0) {
        self.pageController.currentPage =  self.currentPage-1;
    } else {
        self.pageController.currentPage = 0;
    }
    
    //设置当前页
    pageControl.currentPage=self.currentPage;
    [pageControl addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventTouchUpInside];
    
    if (self.pageNumber <= 1) {
        pageControl.hidden = YES;
    } else {
        pageControl.hidden = NO;
    }
    
    self.pageController = pageControl;
    [self addSubview:pageControl];
    
    //设置scrollView的位置
    CGRect frame = self.scrollView.frame;
    frame.origin.x = self.scrollView.frame.size.width * self.currentPage;
    frame.origin.y = 0;
    [self.scrollView scrollRectToVisible:frame animated:YES];
    //加载所有页
    [self loadScrollPersonViews];
}

- (void)loadScrollPersonViews
{
    for (int i = 0; i < self.pageNumber; i++) {
        [self loadIndexPage:i];
    }
}

- (void)loadIndexPage:(NSInteger)index
{
    GestureSinglePageView *sPageView = [[GestureSinglePageView alloc]
                                        initWithPageNumber:index
                                        Frame:CGRectMake(TPScreenWidth()*index, 0,
                                                         scrollView.frame.size.width,
                                                         scrollView.frame.size.height)
                                        EditMode:isEdit];
    sPageView.parentView = self;
    [self.scrollView addSubview:sPageView];
}

- (void)setDeleteBtn: (BOOL) isEditMode
{
    for (UIView *subView in self.scrollView.subviews) {
        if ([subView isKindOfClass:[GestureSinglePageView class]]) {
            GestureSinglePageView *itemView = (GestureSinglePageView *)subView;
            if (isEditMode) {
                [itemView addDeleteBtn];
            } else {
                [itemView hideDeleteBtn];
            }
        }
    }
}

- (void)pageNumberChange
{
	self.pageNumber=[self.gestureCustomList count]/9+1;
	self.pageController.numberOfPages = self.pageNumber;
	self.scrollView.contentSize=CGSizeMake(self.scrollView.frame.size.width * self.pageNumber, self.scrollView.frame.size.height);
}


#pragma mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    // Switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = self.scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
	if (page!=self.currentPage) {
        self.currentPage=page;
		self.pageController.currentPage = page;
    }
}

- (void)changePage:(id)sender
{
    int page = self.pageController.currentPage;
    CGRect frame = self.scrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [self.scrollView scrollRectToVisible:frame animated:YES];
}

- (void)dealloc {
    [SkinHandler removeRecursively:self];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end

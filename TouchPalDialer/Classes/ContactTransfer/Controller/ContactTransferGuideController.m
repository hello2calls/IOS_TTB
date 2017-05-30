//
//  ContactTransferGuideController.m
//  TouchPalDialer
//
//  Created by siyi on 16/3/15.
//
//

#import "ContactTransferGuideController.h"
#import "ContactTransferPageInfo.h"
#import "ContactTransferGuidePageView.h"
#import "TPDialerResourceManager.h"
#import "FunctionUtility.h"
#import "ContactTransferMainController.h"
#import "UserDefaultsManager.h"
#import "CootekNotifications.h"

@implementation ContactTransferGuideController {
    NSArray *_pageInfos;
    NSMutableArray *_pageViews;
    CGFloat _pageWidth;
    CGFloat _pageHeight;
    NSInteger _focusedPageIndex;
    NSMutableArray *_indicatorViews;
}
- (instancetype) init {
    if (self = [super init]) {
        _pageInfos = [self getPageInfos];
        _focusedPageIndex = 0;
        _pageHeight = 0;
        _pageWidth = 0;
        if ([FunctionUtility systemVersionFloat] >= 7.0) {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
    }
    return self;
}

- (void) viewDidLoad {
    [super viewDidLoad];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

    _pageInfos = [self getPageInfos];
    _pageViews = [[NSMutableArray alloc] initWithCapacity:_pageInfos.count];

    CGFloat contentWidth = 0;

    UIScrollView *contentContainer = [[UIScrollView alloc] initWithFrame:CGRectZero];
    CGFloat contentX = 0;

    for (NSInteger count = _pageInfos.count, index = 0; index < count; index++) {
        ContactTransferPageInfo *pageInfo = _pageInfos[index];
        ContactTransferGuidePageView *pageView = [[ContactTransferGuidePageView alloc] initWithPageInfo:pageInfo];
        contentWidth += pageView.bounds.size.width;
        if (_pageWidth <= 0) {
            _pageWidth = pageView.bounds.size.width;
            _pageHeight = pageView.bounds.size.height;
        }
        CGRect selfFrame = pageView.frame;
        pageView.frame = CGRectMake(contentX, 0, selfFrame.size.width, selfFrame.size.height);
        [contentContainer addSubview:pageView];
        [_pageViews addObject:pageView];
        contentX += pageView.bounds.size.width;
    }

    contentContainer.contentSize = CGSizeMake(contentWidth, _pageHeight); // important!
    contentContainer.frame = CGRectMake(0, 0, _pageWidth, _pageHeight); // same height of the content area
    contentContainer.showsHorizontalScrollIndicator = NO; // scroll bar of the frame
    contentContainer.showsVerticalScrollIndicator = NO;
    contentContainer.bounces = NO;
    contentContainer.pagingEnabled = YES;
    contentContainer.delegate = self;

    // header view
    UIView *headerView = [self getHeaderView];

    // indicator view
    UIView *indicatorHolderView = [self getIndicatorHolderView];

    // set up view tree
    self.view.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_light_blue_500"];

    [self.view addSubview:contentContainer];
    [self.view addSubview:headerView];
    [self.view addSubview:indicatorHolderView];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    BOOL shown = [UserDefaultsManager boolValueForKey:CONTACT_TRANSFER_GUIDE_SHOWN defaultValue:NO];
    if (!shown) {
        [UserDefaultsManager setBoolValue:YES forKey:CONTACT_TRANSFER_GUIDE_SHOWN];
        [[NSNotificationCenter defaultCenter] postNotificationName:N_REFRESH_SPECIAL_CONTACT_NODE object:nil];
    }
}

- (void) updateIndicatorState:(NSInteger) focusedIndex {
    if (!_indicatorViews || _indicatorViews.count == 0) {
        return;
    }
    NSInteger indicatorCount = _indicatorViews.count;
    if (focusedIndex < 0 || focusedIndex >= indicatorCount) {
        return;
    }
    [self dimIndicator:_indicatorViews[_focusedPageIndex]];
    [self highlightIndicator:_indicatorViews[focusedIndex]];

    _focusedPageIndex = focusedIndex;
}

#pragma delegate: UIScrollViewDelegate
- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGPoint contentOffset = scrollView.contentOffset;
    NSInteger focusedIndex = contentOffset.x / _pageWidth;
    [self updateIndicatorState:focusedIndex];
}


#pragma mark get views
- (UIView *) getHeaderView {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, TPScreenWidth(), TPHeaderBarHeight())];
    headerView.backgroundColor = [UIColor clearColor];

    // header view: back button
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(5, TPHeaderBarHeightDiff(),50, 45)];
    cancelButton.backgroundColor = [UIColor clearColor];
    cancelButton.titleLabel.font = [UIFont fontWithName:@"iPhoneIcon1" size:22];
    [cancelButton setTitle:@"0" forState:UIControlStateNormal];

    [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [cancelButton addTarget:self action:@selector(goToBack) forControlEvents:UIControlEventTouchUpInside];

    //set up view tree
    [headerView addSubview:cancelButton];

    return headerView;
}

- (void) goToBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSArray *) getPageInfos {
    ContactTransferPageInfo *pageOneInfo = [[ContactTransferPageInfo alloc] init];
    pageOneInfo.mainTitle = NSLocalizedString(@"contact_transfer_guide_1_main_title", nil);
    pageOneInfo.altTitle = NSLocalizedString(@"contact_transfer_guide_1_alt_title", nil);
    pageOneInfo.imageName = NSLocalizedString(@"contact_transfer_guide_page01@2x.png", @"");
    pageOneInfo.pageIndex = 1;

    ContactTransferPageInfo *pageTwoInfo = [[ContactTransferPageInfo alloc] init];
    pageTwoInfo.mainTitle = NSLocalizedString(@"contact_transfer_guide_2_main_title", nil);
    pageTwoInfo.altTitle = NSLocalizedString(@"contact_transfer_guide_2_alt_title", nil);
    pageTwoInfo.imageName = NSLocalizedString(@"contact_transfer_guide_page02@2x.png", nil);
    pageTwoInfo.buttonTittle = NSLocalizedString(@"contact_transfer_guide_2_button_title", nil);
    pageTwoInfo.pageIndex = 2;
    pageTwoInfo.buttonAction = ^(){
        BOOL guideClicked = [UserDefaultsManager boolValueForKey:CONTACT_TRANSFER_GUIDE_CLICKED defaultValue:NO];
        if (!guideClicked) {
            [UserDefaultsManager setBoolValue:YES forKey:CONTACT_TRANSFER_GUIDE_CLICKED];
            ContactTransferMainController *mainController = [[ContactTransferMainController alloc] init];
            [self.navigationController pushViewController:mainController animated:YES];
            [FunctionUtility removeFromStackViewController:self];
        }
    };

    return @[pageOneInfo, pageTwoInfo];
}

- (UIView *) getIndicatorHolderView {
    NSInteger pageCount = _pageViews.count;
    if (pageCount == 0) {
        return nil;
    }
    UIView *indicatorHolder = [[UIView alloc] initWithFrame:CGRectZero];
    CGFloat gX = 0;
    CGFloat holderHeight = 0;
    if (pageCount > 0) {
        _indicatorViews = [[NSMutableArray alloc] initWithCapacity:pageCount];
    }
    for(NSInteger index = 0; index < pageCount; index++) {
        UIView *indicator = [self getIndicator];
        [_indicatorViews addObject:indicator];

        if (index == _focusedPageIndex) {
            [self highlightIndicator:indicator];
        }
        CGRect frame = indicator.frame;
        if (frame.size.height > holderHeight) {
            holderHeight = frame.size.height;
        }
        if (index == 0) {
            gX += 0;
        } else {
            gX += indicator.frame.origin.x;
        }
        indicator.frame = CGRectMake(gX, frame.origin.y, frame.size.width, frame.size.height);
        [indicatorHolder addSubview:indicator];
        gX += indicator.frame.size.width;
    }

    CGFloat marginBottom = 0;
    if (isIPhone5Resolution()) {
        marginBottom = INDICATOR_MARGIN_BOTTOM * TPScreenHeight();
    } else {
        marginBottom = INDICATOR_MARGIN_BOTTOM_SMALL * TPScreenHeight();
    }
    CGFloat originY = TPScreenHeight() - marginBottom - holderHeight;
    indicatorHolder.frame = CGRectMake((TPScreenWidth() - gX) / 2, originY, gX, holderHeight);
    return indicatorHolder;
}

- (UIView *) getIndicator {
    CGSize dotSize = CGSizeMake(INDICATOR_DIAMETER, INDICATOR_DIAMETER);
    UIView *indicator = [[UIView alloc] initWithFrame:CGRectMake(INDICATOR_GAP, 0, dotSize.width, dotSize.height)];
    indicator.backgroundColor = [UIColor clearColor];
    indicator.layer.cornerRadius = (dotSize.width) / 2;
    indicator.clipsToBounds = YES;
    [self dimIndicator:indicator];
    return indicator;
}


#pragma mark debug settings
- (void) highlightIndicator: (UIView *) indicator {
    if (!indicator) {
        return;
    }
    indicator.backgroundColor = [UIColor whiteColor];
}

- (void) dimIndicator: (UIView *) indicator {
    if (!indicator) {
        return;
    }
    indicator.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_white_transparency_300"];
}

- (void) outlineView:(UIView *)view borderColor:(UIColor *)color borderWidth:(CGFloat)width {
    if (!view || !color) {
        return;
    }
    view.layer.borderColor = color.CGColor;
    view.layer.borderWidth = width;
}

- (void) outlineView:(UIView *)view borderColor:(UIColor *)color {
    [self outlineView:view borderColor:color borderWidth:3];
}

- (void) outlineView:(UIView *)view {
    if (!view) {
        return;
    }
    [self outlineView:view borderColor:[UIColor redColor]];
}

@end

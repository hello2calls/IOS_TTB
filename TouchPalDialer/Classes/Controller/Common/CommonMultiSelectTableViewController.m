//
//  CommonMultiSelectTableViewController.m
//  TouchPalDialer
//
//  Created by Sendor on 11-9-21.
//  Copyright 2011 CooTekMyCompanyName__. All rights reserved.
//

#import "CommonMultiSelectTableViewController.h"
#import "HeaderBar.h"
#import "FunctionUtility.h"
#import "TPHeaderButton.h"
#import "TPDialerResourceManager.h"
#import "SkinHandler.h"
#import "UITableView+TP.h"
#import "UIButton+DoneButton.h"

@implementation CommonMultiSelectTableViewController {
    NSArray* data_list;
    UITableView* info_table_view;
    BOOL animateOut_;
}

@synthesize delegate;
@synthesize data_list;

#pragma mark -
#pragma mark Initialization

- (id)initWithStyle:(UITableViewStyle)style data:(NSArray*)dataList delegate:(id<CommonMultiSelectProtocol>)paraDelegate title:(NSString *)title needAnimateOut:(BOOL)animateOut{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization.
        animateOut_ = animateOut;
        self.data_list = dataList;
        self.delegate = paraDelegate;
        // content view;
        UIView* contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, TPScreenWidth(), TPAppFrameHeight())];
        contentView.backgroundColor = [UIColor clearColor];
        self.view = contentView;
        // HeaderBar
        HeaderBar* headBar = [[HeaderBar alloc] initHeaderBar];
        [headBar setSkinStyleWithHost:self forStyle:@"defaultHeaderView_style"];
        [contentView addSubview:headBar];
		
        TPHeaderButton *cancel_but = [[TPHeaderButton alloc] initLeftBtnWithFrame:CGRectMake(0, 0,50, 45)];
        [cancel_but setTitle:NSLocalizedString(@"Cancel", @"Cancel") forState:UIControlStateNormal];
        [cancel_but setSkinStyleWithHost:self forStyle:@"defaultTPHeaderButton_style"];
		[cancel_but addTarget:self action:@selector(goToBack) forControlEvents:UIControlEventTouchUpInside];
		[headBar addSubview:cancel_but];
        
        // select group label
        UILabel *titlelabel = [[UILabel alloc] initWithFrame:CGRectMake((TPScreenWidth()-160)/2, TPHeaderBarHeightDiff(), 160, 45)];
        [titlelabel setSkinStyleWithHost:self forStyle:@"defaultUILabel_style"];
        titlelabel.font = [UIFont systemFontOfSize:FONT_SIZE_3];
        titlelabel.textAlignment = NSTextAlignmentCenter;
        titlelabel.text = title;
        [headBar addSubview:titlelabel];
		
        // complete button
        TPHeaderButton *completeButton = [[TPHeaderButton alloc] initWithFrame:CGRectMake(TPScreenWidth()-50, 0, 50, 45)];
        [completeButton setSkinStyleWithHost:self forStyle:@"defaultUILabel_style"];
        [completeButton setTitle:NSLocalizedString(@"Done", @"") forState:UIControlStateNormal];
        [completeButton addTarget:self action:@selector(finishSelect) forControlEvents:UIControlEventTouchUpInside];
		[headBar addSubview:completeButton];
		
        // data table
        CommonMultiSelectTableView *multiSelectTableView = [[CommonMultiSelectTableView alloc] initWithFrame:CGRectMake(0, TPHeaderBarHeight(), TPScreenWidth(), TPHeightFit(415)) andDataList:dataList needAnimateIn:NO];
        [contentView addSubview:multiSelectTableView];
    }
    return self;
}



#pragma mark -
#pragma mark View lifecycle

- (void)goToBack
{
    [self dismissViewControllerAnimated:animateOut_ completion:^(){}];
}
- (void)finishSelect{
    
    if ([FunctionUtility systemVersionFloat] < 8.0) {
        [delegate checkFinish:data_list];
        [self goToBack];
    }else{
         [self goToBack];
        [delegate checkFinish:data_list];
    }
    
    
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
    cootek_log(@"Received memory warning in CommonMultiSelectTableViewController.");
}

- (void)dealloc {
    [SkinHandler removeRecursively:self];
}


@end


//
//  DefaultSettingPageView.m
//  TouchPalDialer
//
//  Created by Elfe Xu on 12-11-19.
//
//

#import "DefaultSettingPageView.h"
#import "TPDialerResourceManager.h"
#import "UIView+WithSkin.h"
#import "SkinHandler.h"

@interface DefaultSettingPageView() {
        UITableView* __strong tableView_;
        SettingPageModel *_model;
}
@end

@implementation DefaultSettingPageView

+(DefaultSettingPageView*) pageViewWithFrame:(CGRect) frame controller:(id<UITableViewDataSource, UITableViewDelegate>)controller andPageModel:(SettingPageModel *)pageModel{
    return [[DefaultSettingPageView alloc] initWithFrame:frame controller:controller andPageModel:pageModel];
}

- (id)initWithFrame:(CGRect)frame controller:(id<UITableViewDataSource, UITableViewDelegate>)controller andPageModel:(SettingPageModel *)pageModel
{
    self = [super initWithFrame:frame];
    if (self) {
        _model = pageModel;
        tableView_ = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) style:UITableViewStylePlain];
        tableView_.backgroundView = nil;
        tableView_.delegate = controller;
        tableView_.dataSource = controller;
        tableView_.bounces = YES;
        tableView_.separatorStyle = UITableViewCellSeparatorStyleNone;
        if (_model.cellHeight > 0) {
            tableView_.rowHeight = _model.cellHeight;
        }else{
            tableView_.rowHeight = 60;
        }
        
        tableView_.tableFooterView = [[UIView alloc] init];
        UIColor *lineColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"defaultUITableViewSeperator_color"];

        [tableView_ setSeparatorColor:lineColor];
        [tableView_ setSkinStyleWithHost:self forStyle:@"defaultBackground_color"];
        [self addSubview:tableView_];
    }
    return self;
}

-(void) refreshPage {
    [tableView_ reloadData];
}

-(void) dealloc {
    [SkinHandler removeRecursively:self];
}
@end

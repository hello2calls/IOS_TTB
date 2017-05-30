//
//  SettingViewController.m
//  TouchPalDialer
//
//  Created by Elfe Xu on 12-11-19.
//
//

#import "DefaultSettingViewController.h"
#import "DefaultSettingPageView.h"
#import "DefaultSettingCellView.h"
#import "UITableView+TP.h"
#import "TPDialerResourceManager.h"
#import "SkinHandler.h"
#import "GoDetailSettingItemModel.h"
#import "ActionableSettingItemModel.h"
#import "SwitchSettingItemModel.h"
#import "SingleSelectionSettingItemModel.h"
#import "NonOpSettingItemModel.h"
#import "SwitchSettingCellView.h"
#import "SingleSelectionSettingCellView.h"
#import "CootekNotifications.h"
#import "SettingsModelCreator.h"
#import "NonOpSettingCellView.h"
#import "CommonWebViewController.h"
#import "UserDefaultsManager.h"
#import "VoipConsts.h"
#import "FunctionUtility.h"
#import "DefaultUIAlertViewHandler.h"

#import "TPDialerResourceManager.h"
#import "DialerUsageRecord.h"
@interface DefaultSettingViewController() {
    SettingPageModel* __strong model_;
    UIView __strong *view_;
}

-(UIView*) pageviewForPage:(SettingPageModel*) page;
-(DefaultSettingCellView*) cellviewForItem:(SettingItemModel*) item position:(RoundedCellBackgroundViewPosition)position;

@end

@implementation DefaultSettingViewController

+(DefaultSettingViewController*) controllerWithPageModel:(SettingPageModel*) pageModel {
    return  [[DefaultSettingViewController alloc] initWithPageModel:pageModel];
}

- (id)initWithPageModel:(SettingPageModel*) pageModel
{
    self = [super init];
    if (self) {
        model_ = pageModel;
        if(model_.title) {
            self.headerTitle = NSLocalizedString(model_.title,@"");
        }
        if(model_.pageType == SETTING_PAGE_ABOUT) {
            [self setFeedbackInfo];
        }
    }
    return self;
}

- (void)setFeedbackInfo
{
    int x = 10;
    int y = 280 * 0.9;
    
    [self addLabelWithText:NSLocalizedString(@"Touchpal official website", @"") Url:NSLocalizedString(@"http://www.chubao.cn", @"") Point:CGPointMake(x, y)];
    y = y + 25;
    [self addLabelWithText:NSLocalizedString(@"QQ chat group", @"") Url:nil Point:CGPointMake(x, y)];
    y = y + 25;
    [self addLabelWithText:NSLocalizedString(@"Touchpal official Weibo", @"") Url:NSLocalizedString(@"http://e.weibo.com/touchpalcontacts", @"") Point:CGPointMake(x, y)];
    y = y + 25;
    [self addLabelWithText:NSLocalizedString(@"Touchpal official Wechat platform", @"") Url:nil Point:CGPointMake(x, y)];
}

- (void)addLabelWithText:(NSString *)text Url:(NSString *)url Point:(CGPoint)point
{
    int x = point.x;
    int y = point.y;

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(x, y, TPScreenWidth(), 25)];
    label.text = text;
    label.textColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"url_title_normal_color"];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:14];
    [self.view addSubview:label];
    
    if (url != nil) {
        
//        x = x + [label.text sizeWithAttributes:@{NSFontAttributeName:label.font}].width;
        x = x + [label.text sizeWithFont:label.font].width;
//        UIButton *urlBtn = [[UIButton alloc] initWithFrame:CGRectMake(x, y, [url sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]}].width, [url sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]}].height)];
        UIButton *urlBtn = [[UIButton alloc] initWithFrame:CGRectMake(x, y, [url sizeWithFont:[UIFont systemFontOfSize:14]].width, [url sizeWithFont:[UIFont systemFontOfSize:14]].height)];
        [urlBtn setTitle:url forState:UIControlStateNormal];
        [urlBtn setTitleColor:[[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"url_normal_color"] forState:UIControlStateNormal];
        [urlBtn setTitleColor:[[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"url_ht_color"] forState:UIControlStateHighlighted];
        urlBtn.titleEdgeInsets = UIEdgeInsetsMake(10, 0, 0, 0);
        urlBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [urlBtn addTarget:self action:@selector(urlBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:urlBtn];
    }
}

- (void)urlBtnPressed:(UIButton *)btn
{
    CommonWebViewController* webVC = [[CommonWebViewController alloc] init];
    webVC.url_string = btn.titleLabel.text;
    [self.navigationController pushViewController:webVC animated:YES];
}

#pragma mark - View lifecycle

- (void)loadView {
    [super loadView];
    view_ = [self pageviewForPage:model_];
    [self.view addSubview:view_];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [FunctionUtility setAppHeaderStyle];
    [super viewWillAppear:animated];
    [self reloadModelData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotiSettingsItemChanged:) name:N_SETTINGS_ITEM_CHANGED object:nil];

}

- (void)gotoBack {
    if (model_.pageType == SETTING_PAGE_MUTI_LANGUAGE && [UserDefaultsManager intValueForKey:LAST_APP_LANGUAGE defaultValue:LanguageStandard] != [UserDefaultsManager intValueForKey:APP_SET_KEY_MUTI_LANGUAGE defaultValue:LanguageStandard]) {
        [UserDefaultsManager setIntValue:[UserDefaultsManager intValueForKey:APP_SET_KEY_MUTI_LANGUAGE] forKey:LAST_APP_LANGUAGE];
        [DefaultUIAlertViewHandler showAlertViewWithTitle:@"切换语言需要重新启动触宝电话，确认切换？" message:nil okButtonActionBlock:^(){
            exit(0);
        }cancelActionBlock:^{
        }];
        
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)reloadModelData
{
    SettingPageModel* newModel = [[SettingsCreator creator] modelForPage:model_.pageType];
    model_ = newModel;
    if([view_ respondsToSelector:@selector(refreshPage)]) {
        [view_ performSelector:@selector(refreshPage)];
    }
}


#pragma UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return model_.sections.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    SettingSectionModel* s = [self sectionForIndex:section];
    if(s.title) {
        return NSLocalizedString(s.title, @"");
    } else {
        return @"";
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    SettingSectionModel* s = [self sectionForIndex:section];
    if(s != nil) {
        return s.items.count;
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SettingItemModel* item = [self itemForIndexPath:indexPath];
    if(item == nil) {
        return nil;
    }
    
    RoundedCellBackgroundViewPosition position = [tableView cellPositionOfIndexPath:indexPath];
    NSString* reuseIdentity = [DefaultSettingCellView reuseIdentifierForData:item inPosition:position];
    DefaultSettingCellView* view = [tableView dequeueReusableCellWithIdentifier:reuseIdentity];
    
    if(view == nil) {
        view = [self cellviewForItem:item position:position];
    } else {
        [view fillData:item];
    }
    view.textLabel.font = [UIFont systemFontOfSize:FONT_SIZE_3_5];
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    SettingItemModel* model = [self itemForIndexPath:indexPath];
    
    if([model isKindOfClass:[ActionableSettingItemModel class]]) {
        if ([model isKindOfClass:[GoDetailSettingItemModel class]] && ((GoDetailSettingItemModel *)model).settingPageType==SETTING_PAGE_CUSTOMIZE_ACTIONS) {
            [DialerUsageRecord recordpath:PATH_DIAL_SETTING kvs:Pair(ENTER_RIGET_LEFT_SETTING, @(1)), nil];
        }
        ActionableSettingItemModel* am = (ActionableSettingItemModel*) model;
        [am executeAction:self];
    }
    
    if(model.featureTip && model.featureTip.showTip) {
        [model.featureTip removeTip];
        [tableView reloadData];
    }
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *sectionHeader         = [[UIView alloc] init];

    sectionHeader.backgroundColor = [UIColor clearColor];
    return sectionHeader;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    
    UIView *sectionHeader         = [[UIView alloc] init];
    
    sectionHeader.backgroundColor = [UIColor clearColor];
    
    return sectionHeader;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 20;

}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{

    return 1;
}
-(SettingItemModel*) itemForIndexPath:(NSIndexPath *)indexPath {
    int sectionIndex = [indexPath section];
    int rowIndex = [indexPath row];
    SettingSectionModel* s = [self sectionForIndex:sectionIndex];
    if(s != nil) {
        if(rowIndex >= 0 && rowIndex < s.items.count) {
            return s.items[rowIndex];
        }
    }
    
    return nil;
}

-(SettingSectionModel*) sectionForIndex:(NSInteger) index {
    if(index >= 0 && index < model_.sections.count) {
        return model_.sections[index];
    }
    
    return nil;
}



// Create the view according to model.
// There are only a few different views so put the factory method in this class.
// In the future, if there are lots of different views,
// it would be better to have a separate view creator class.
-(UIView*) pageviewForPage:(SettingPageModel*) page {
    CGRect frame = CGRectMake(0, TPHeaderBarHeight(), TPScreenWidth(), TPAppFrameHeight()-50+TPHeaderBarHeightDiff());
    return [DefaultSettingPageView pageViewWithFrame:frame controller:self andPageModel:page];
}

-(DefaultSettingCellView*) cellviewForItem:(SettingItemModel*) item position:(RoundedCellBackgroundViewPosition)position{
    if([item isKindOfClass:[GoDetailSettingItemModel class]]) {
        return [DefaultSettingCellView defaultCellWithData:item forPosition:position selectionStyle:UITableViewCellSelectionStyleBlue accessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
    
    if([item isKindOfClass:[SingleSelectionSettingItemModel class]]) {
        SingleSelectionSettingItemModel *settingItemModel = (SingleSelectionSettingItemModel*)item;
        __weak DefaultSettingViewController *bself = self;
        settingItemModel.settingChangedBlock = ^{
            [[bself getModel] save];
        };
        return [SingleSelectionSettingCellView singleSelectionCellWithData:settingItemModel forPosition:position];
    }
    
    if([item isKindOfClass:[SwitchSettingItemModel class]]) {
        SwitchSettingItemModel* switchItem = (SwitchSettingItemModel*)item;
        SwitchSettingCellView* cell = [SwitchSettingCellView switchCellWithData:switchItem forPosition:position];
        __weak DefaultSettingViewController *bself = self;
        cell.actionBlock = ^{
            [[bself getModel] save];
        };
        cell.closeAlertStr = switchItem.closeAlertStr;
        return cell;
    }
    
    if([item isKindOfClass:[NonOpSettingItemModel class]]) {
        return [NonOpSettingCellView nonopCellWithData:(NonOpSettingItemModel*)item forPosition:position];
    }
    
    return [DefaultSettingCellView defaultCellWithData:item forPosition:position];
    
}

- (SettingPageModel *)getModel {
    return model_;
}

- (void)onNotiSettingsItemChanged:(NSNotification*)noti {
    if(![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(onNotiSettingsItemChanged:) withObject:noti waitUntilDone:YES];
        return;
    }
    
    BOOL needRefresh = NO;
    NSString* settingsKey = noti.object;
    for(NSString* str in model_.monitorKeys) {
        if([str isEqualToString:settingsKey]) {
            needRefresh = YES;
            break;
        }
    }

    if(needRefresh) {
        [self reloadModelData];
    }
}

@end

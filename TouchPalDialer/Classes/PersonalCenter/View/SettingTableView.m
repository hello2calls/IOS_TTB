//
//  PersonalCenterTableView.m
//  TouchPalDialer
//
//  Created by ALEX on 16/7/25.
//
//

#import "SettingTableView.h"
#import "TPDialerResourceManager.h"
#import "SettingCell.h"
#import "UIView+WithSkin.h"

static CGFloat kTableViewRowHeight = 60;
static CGFloat kTableViewSectionHeaderHeight = 20;
static CGFloat kTableViewRowAvatarHeight = 100;
static CGFloat kTableViewRowIconHeight = 100;

@interface SettingTableView ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,weak) UITableView *tableView;
@end

@implementation SettingTableView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        [self setupTableView];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(skinDidChange) name:N_SKIN_DID_CHANGE object:nil];
    }
    return self;
}

- (void)setupTableView{
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
    tableView.delegate              = self;
    tableView.dataSource            = self;
    tableView.sectionHeaderHeight   = kTableViewSectionHeaderHeight;
    tableView.separatorStyle        = UITableViewCellSeparatorStyleNone;
    tableView.showsVerticalScrollIndicator  = NO;
    tableView.showsHorizontalScrollIndicator = NO;
    
    tableView.backgroundView = nil;
    [tableView setSkinStyleWithHost:self forStyle:@"defaultBackground_color"];
    self.tableView = tableView;
    [self addSubview:tableView];
    
    tableView.tableFooterView = [[UIView alloc] init];
}

- (void)skinDidChange{
    
    if (self.tableView != nil) {
        [self.tableView removeFromSuperview];
    }
    
    [self setupTableView];

    [self.tableView reloadData];;
}

- (void)setFrame:(CGRect)frame{
    
    [super setFrame:frame];
    self.tableView.frame = self.bounds;
    
}

- (void)setFooterView:(UIView *)footerView{
    
    _footerView = footerView;
    self.tableView.tableFooterView = _footerView;
    [self.tableView reloadData];
}
- (void)setSettingArr:(NSMutableArray *)settingArr{
    _settingArr = settingArr;
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    SettingCell *cell = [SettingCell cellWithTableView:tableView settingItem:[_settingArr[indexPath.section] objectAtIndex:indexPath.row]];
    
    if (indexPath.item == 0 && indexPath.item == [_settingArr[indexPath.section] count] - 1) {
        cell.separateLineType = SettingCellSeparateLineTypeSingle;
    }else if(indexPath.item == 0){
        cell.separateLineType = SettingCellSeparateLineTypeHeader;
    }else if(indexPath.item == [_settingArr[indexPath.section] count] - 1){
        cell.separateLineType = SettingCellSeparateLineTypeFooter;
    }else{
         cell.separateLineType = SettingCellSeparateLineTypeNormal;
    }
    
    return cell;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _settingArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_settingArr[section] count];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *sectionHeader         = [[UIView alloc] init];
    if (self.headerView != nil && section == 0) {
        return self.headerView;
    }
    sectionHeader.backgroundColor = [UIColor clearColor];
    return sectionHeader;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *sectionHeader         = [[UIView alloc] init];
    sectionHeader.backgroundColor = [UIColor clearColor];
    return sectionHeader;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (self.headerView != nil && section == 0) {
        return self.headerView.tp_height;
    }else{
        return 20;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
   
    if (self.footerView != nil) {
        return 1;
    }
    
    if (section == self.settingArr.count - 1 ) {
        return 20;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    SettingItem *settingModel =[_settingArr[indexPath.section] objectAtIndex:indexPath.row];
    if ([settingModel isMemberOfClass:[SettingItem class]]) {
        
        return kTableViewRowHeight;
    }
    
    if ([settingModel isMemberOfClass:[AvatarSettingItem class]]) {
        if ([UIScreen mainScreen].bounds.size.height > 480) {
            return kTableViewRowAvatarHeight;
        }else{
            return 80;
        }
    }
    
    if ([settingModel isMemberOfClass:[IconSettingItem class]]) {
        return kTableViewRowIconHeight;
    }
    
    if ([settingModel isMemberOfClass:[AboatUsLogoItem class]]) {
        if ([UIScreen mainScreen].scale > 2) {
            return 240;
        }else{
            return 220;
        }
    }
    
    return kTableViewRowHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    SettingItem *settingModel =[_settingArr[indexPath.section] objectAtIndex:indexPath.row];
    if ([self.delegate respondsToSelector:@selector(settingTableView:didSelectSettingItem:)]) {
        [self.delegate settingTableView:self didSelectSettingItem:settingModel];
    }
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
//处理section的不悬浮，禁止section停留的方法
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    
//    CGFloat sectionHeaderHeight = self.headerView == nil ? kTableViewSectionHeaderHeight:self.headerView.height;
//    if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
//        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
//    } else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
//        scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
//    }
//    
//}
@end

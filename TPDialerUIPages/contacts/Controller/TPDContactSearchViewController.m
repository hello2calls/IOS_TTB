//
//  TPDContactSearchViewController.m
//  TouchPalDialer
//
//  Created by ALEX on 16/9/21.
//
//
#import "TPDialerResourceManager.h"
#import "EngineResultModel.h"
#import "TPDContactSearchViewController.h"
#import "CootekNotifications.h"

#import "ContactSearchModel.h"
#import "TPDContactInfoManagerCopy.h"
#import "TouchPalDialerAppDelegate+RDVTabBar.h"
#import <Masonry.h>

#import "UIColor+TPDExtension.h"
#import "UITableViewCell+TPDExtension.h"
#import "FunctionUtility.h"
#import "DialerUsageRecord.h"

@interface TPDContactSearchBar : UISearchBar<UITextFieldDelegate>

@end

@implementation TPDContactSearchBar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.placeholder = NSLocalizedString(@"search", @"");
        
        // 通过init初始化的控件大多都没有尺寸
        self.backgroundImage = [self imageWithColor:[UIColor clearColor] size:self.bounds.size];
        self.backgroundColor = [UIColor clearColor];
        
        UITextField * searchField = [self valueForKey:@"_searchField"];
        searchField.delegate = self;
        searchField.clearButtonMode = UITextFieldViewModeWhileEditing;
        searchField.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:.9];
        searchField.layer.cornerRadius = 14;
        searchField.layer.masksToBounds = YES;
        
        //放大镜
        //        [self setImage:[UIImage imageNamed:@"icon@3x"]
        //            forSearchBarIcon:UISearchBarIconSearch
        //                        state:UIControlStateNormal];
    }
    return self;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    self.text = @"";
    return YES;
    
}
//取消searchbar背景色
- (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size
{
    CGRect rect = CGRectMake(0, 0,[UIScreen mainScreen].bounds.size.width, 44);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
+(instancetype)searchBar
{
    return [[self alloc] init];
}


@end




@interface TPDContactSearchViewController ()<UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate>

@property (nonatomic, strong) ContactSearchModel    *searchEngine;
@property (nonatomic, strong) NSArray               *searchResults;
@property (nonatomic, weak)   UITableView           *searchResultTableView;
@property (nonatomic, weak)   TPDContactSearchBar           *searchBar;

@end

@implementation TPDContactSearchViewController

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.searchEngine query:_searchBar.text];
    [FunctionUtility updateStatusBarStyle];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupHeadView];
    
    [self setupSearchResutlTableView];
    
    self.searchEngine = [[ContactSearchModel alloc] initWithSearchType:ContactSearch];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getContactsSearchResutl:) name:N_CONTACT_SEARCH_RESULT_CHANGED object:nil];
}

- (void)setupHeadView {

    UIImageView *headView = [[UIImageView alloc] init];
    headView.userInteractionEnabled = YES;
    headView.image = [TPDialerResourceManager getImage:@"common_header_bg@2x.png"];
    [self.view addSubview:headView];
    
    [headView makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.left.equalTo(self.view);
        make.height.equalTo(64);
    }];
    
    TPDContactSearchBar *searchBar = [[TPDContactSearchBar alloc] init];
    searchBar.backgroundColor = [UIColor clearColor];
    searchBar.backgroundImage = [UIImage new];
    searchBar.placeholder = NSLocalizedString(@"search prompt", @"不记得名字？试试通过公司查找");
    searchBar.delegate = self;
    [headView addSubview:searchBar];
    self.searchBar = searchBar;
    
    [self performSelector:@selector(callKeyBoard) withObject:nil afterDelay:.1];
    
    [searchBar makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.equalTo(headView);
        make.top.equalTo(headView).offset(20);
        make.right.equalTo(headView).offset(-48);
    }];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [headView addSubview:button];
    [button addTarget:self action:@selector(cancelSearch) forControlEvents:UIControlEventTouchDown];
    [button makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.right.equalTo(searchBar);
        make.left.equalTo(searchBar.right).offset(5);
        make.right.equalTo(headView.right).offset(-5);
    }];
    [button setTitle:@"取消" forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:17];
    [button setTitleColor:[TPDialerResourceManager getColorForStyle:@"skinHeaderBarOperationText_normal_color"] forState:UIControlStateNormal];
    
    UITableView *searchResultTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [self.view addSubview:searchResultTableView];
    searchResultTableView.delegate = self;
    searchResultTableView.dataSource = self;
    self.searchResultTableView = searchResultTableView;
    
    [searchResultTableView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(headView.bottom);
        make.left.right.bottom.equalTo(self.view);
    }];

}

- (void)setupSearchResutlTableView {
    
   
    
}
 
- (void)cancelSearch {
    [self rdv_tabBarController].tabBarHidden = NO;
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)getContactsSearchResutl:(NSNotification *)noti {
    NSDictionary *dic = noti.userInfo;
    NSArray *resutl = dic[@"KEY_RESULT_LIST_CHANGED"];
    SearchResultModel *searchResult = [[noti userInfo] objectForKey:KEY_RESULT_LIST_CHANGED];
    self.searchResults = searchResult.searchResults;
    [self.searchResultTableView reloadData];
    NSLog(@"%@",resutl);
}

- (void)callKeyBoard {
    [self performSelectorOnMainThread:@selector(setupSearchBar) withObject:nil waitUntilDone:NO];
}

- (void)setupSearchBar {

    [self.searchBar becomeFirstResponder];
}
#pragma mark UISearchBarDelegate 
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    if ([searchText isEqualToString:@""]) {
        self.searchResults = @[];
        [self.searchResultTableView reloadData];
        return;
    }
    [self.searchEngine query:searchText];
    
}

#pragma mark UITableViewDataSource UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.searchResults.count;
    
    if (self.searchResults.count > 0 ) {
        [DialerUsageRecord recordpath:PATH_CONTACT_VERSIONSiXLATER
                                  kvs:Pair(PATH_CONTACT_VERSIONSiXLATER_SEARCHSUCCESS, @(1)), nil];

    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    SearchItemModel *searchItem = self.searchResults[indexPath.row];
    
    __weak typeof(self) weakself = self;

    UITableViewCell *cell = [UITableViewCell tpd_tableViewCellStyle1:@[@"",searchItem.name,searchItem.number ? searchItem.number : @"",@""] action:^(id sender) {
        [[TPDContactInfoManagerCopy instance] showContactInfoByPersonId:searchItem.personID inNav:weakself.navigationController];
        
    }];
    [cell.tpd_label2 updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(cell.tpd_label1.right).offset(15);
        make.width.lessThanOrEqualTo(120);
    }];
    
    EngineResultModel *model = [self.searchResults objectAtIndex:indexPath.row];
    UIColor *defaultColor = [UIColor blackColor];
    UIColor *hColor = [TPDialerResourceManager getColorForStyle:@"skinDefaultHighlightText_color"];
    UIFont *titleFont = [UIFont systemFontOfSize:17.f];
    UIFont *numberFont = [UIFont systemFontOfSize:14.f];
    
    
    
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:searchItem.name];
    [attributeString addAttribute:NSForegroundColorAttributeName value:defaultColor range:NSMakeRange(0, searchItem.name.length)];
    [attributeString addAttribute:NSFontAttributeName value:titleFont range:NSMakeRange(0, searchItem.name.length)];
    if (model.hitNameInfo.count > 0) {
        NSRange range1 = NSMakeRange([model.hitNameInfo[0] integerValue], self.searchBar.text.length);
        [attributeString addAttribute:NSForegroundColorAttributeName value:hColor range:range1];
    }
    cell.tpd_label1.attributedText = attributeString;

    
    if (searchItem.number) {
        NSMutableAttributedString *numberString = [[NSMutableAttributedString alloc] initWithString:searchItem.number];
        [numberString addAttribute:NSForegroundColorAttributeName value:defaultColor range:NSMakeRange(0, searchItem.number.length)];
        NSRange range2 = NSMakeRange(model.hitNumberInfo.location, self.searchBar.text.length);
        [numberString addAttribute:NSForegroundColorAttributeName value:hColor range:range2];
        [numberString addAttribute:NSFontAttributeName value:numberFont range:range2];
        cell.tpd_label2.attributedText = numberString;
    }
    
    
    cell.tpd_label1.numberOfLines = 1;
    cell.tpd_label2.numberOfLines = 1;
    cell.tpd_label1.lineBreakMode = NSLineBreakByTruncatingTail;
    cell.tpd_label2.lineBreakMode = NSLineBreakByTruncatingTail;
    
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 60;
}

#pragma mark UITableViewDelegate

#pragma mark - UIScrollViewDelegate 
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}


@end

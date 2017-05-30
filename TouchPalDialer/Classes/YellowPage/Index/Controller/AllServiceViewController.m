//
//  AllServiceViewController.m
//  TouchPalDialer
//
//  Created by tanglin on 15/11/6.
//
//
#import "UITableView+TP.h"

#import "AllServiceViewController.h"
#import "UIDataManager.h"
#import "IndexData.h"
#import "SectionRecommend.h"
#import "SectionNewCategory.h"
#import "SubCategoryItem.h"
#import "TouchPalDialerAppDelegate.h"
#import "NewCategoryItem.h"
#import "ServiceTitleView.h"
#import "IndexConstant.h"
#import "CootekNotifications.h"
#import "ImageUtils.h"
#import "CategoryRowView.h"
#import "ServiceCategoryRowView.h"
#import "ServiceHeaderView.h"
#import "TPHeaderButton.h"
#import "HeaderBar.h"
#import "SectionService.h"
#import "YellowPageMainQueue.h"
#import "UpdateService.h"
#import "IndexJsonUtils.h"

@interface AllServiceViewController(){
    TPHeaderButton* gobackBtn;
}
@end

@implementation AllServiceViewController
@synthesize contentTableView;
@synthesize titleTableView;
@synthesize headerView;

- (void) loadView
{
    [super loadView];
    
    NSString* title = @"全部服务";
    
    HeaderBar *headerBar = [[HeaderBar alloc] initHeaderBar];
    [headerBar setSkinStyleWithHost:self forStyle:@"defaultHeaderView_style"];
    [self.view addSubview:headerBar];
    self.headerView = headerBar;
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((TPScreenWidth()-120)/2, TPHeaderBarHeightDiff(), 120, 45)];
    [titleLabel setSkinStyleWithHost:self forStyle:@"defaultUILabel_style"];
    titleLabel.font = [UIFont systemFontOfSize:FONT_SIZE_3];
    titleLabel.text = title;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.headerView addSubview:titleLabel];
    
    gobackBtn = [[TPHeaderButton alloc] initLeftBtnWithFrame:CGRectMake(0, 0, 50, 45)];
    [gobackBtn setSkinStyleWithHost:self forStyle:@"default_backButton_style"];
    [gobackBtn addTarget:self action:@selector(gobackBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:gobackBtn];
    
    [self initCategory];
    
    
    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, TPHeaderBarHeight(), TPScreenWidth(), TPHeightFit(415))];
    
    [self.view addSubview:self.contentView];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.titleTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 80, TPHeightFit(415))];
    [titleTableView setSkinStyleWithHost:self forStyle:@"defaultBackground_color"];
    titleTableView.separatorStyle = UITableViewCellAccessoryNone;
    titleTableView.backgroundColor = [ImageUtils colorFromHexString: SERVICE_CELL_BG_COLOR andDefaultColor:nil];
    titleTableView.delegate = self;
    titleTableView.dataSource = self;
    titleTableView.showsVerticalScrollIndicator = NO;
    [titleTableView setExtraCellLineHidden];
    [self.contentView addSubview:titleTableView];

    
    
    UIView* lineView = [[UIView alloc]initWithFrame:CGRectMake(titleTableView.frame.origin.x + titleTableView.frame.size.width, 0, 0.5f, TPHeightFit(415))];
    lineView.backgroundColor = [ImageUtils colorFromHexString:SERVICE_TITILE_BORDER_COLOR andDefaultColor:nil];
    [self.contentView addSubview:lineView];
    
    
    self.contentTableView = [[UITableView alloc] initWithFrame:CGRectMake(lineView.frame.origin.x + lineView.frame.size.width, 0, TPScreenWidth() - lineView.frame.origin.x - lineView.frame.size.width, TPHeightFit(415)) style:UITableViewStylePlain];
    [contentTableView setSkinStyleWithHost:self forStyle:@"defaultBackground_color"];
    [contentTableView setExtraCellLineHidden];
    contentTableView.delegate = self;
    contentTableView.dataSource = self;
    contentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    contentTableView.showsVerticalScrollIndicator = NO;
    contentTableView.backgroundColor = [UIColor whiteColor];
    contentTableView.allowsSelection = NO;
    [self.contentView addSubview:contentTableView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTitle) name:N_SELECTED_SERVICE object:nil];
    
}

- (void) initCategory
{
    
    NSString* localIndexFilePath = INDEX_REQUEST_FILE;
    NSDictionary* localIndexDict = [IndexJsonUtils getDictoryFromLocalFile:localIndexFilePath];
    if (!localIndexDict) {
        localIndexDict = [IndexJsonUtils getDictoryFromLocalFile:INDEX_FILE];
    }
    
    NSString* localIndexFontFilePath = INDEX_FONT_FILE;
    [IndexJsonUtils getIndexFontFromLocalFile:localIndexFontFilePath];
    
    if (localIndexDict == nil || localIndexDict.count <= 0) {
        [[UpdateService instance] initZipFromLocal];
        localIndexDict = [IndexJsonUtils getDictoryFromLocalFile:localIndexFilePath];
    }
    
    
    [UIDataManager instance].recommends = nil;
    
    IndexData* data = [[IndexData alloc]initWithJsonForService:localIndexDict];

    [[UIDataManager instance] updateWithLocalData:data];
    [[UIDataManager instance] updateToUIData];
    
    
    NSMutableDictionary* categoryItems = [NSMutableDictionary new];
    self.categoryCount = [NSMutableDictionary new];
    self.classifyItems = [NSMutableArray new];
    self.serviceArray = [NSMutableArray new];
    
    for (SectionGroup* group in [UIDataManager instance].indexData.groupArray) {
        if ([SECTION_TYPE_CATEGORY isEqualToString:group.sectionType]) {
            SectionNewCategory* categorySection = (SectionNewCategory*)[group.sectionArray objectAtIndex:group.current];
            NSMutableArray* categories = [NSMutableArray new];
            [categories addObjectsFromArray:categorySection.items];
            [categories addObjectsFromArray:[[UIDataManager instance] categoryExtendData]];
            for (NewCategoryItem* newCategoryItem in categories) {
                if ([NEW_CATEGORY_TYPE_ITEMMORE isEqualToString: newCategoryItem.type]){
                    continue;
                }
                if (newCategoryItem.classify.count > 0 && [newCategoryItem isValid]) {
                    for (NSDictionary* classify in newCategoryItem.classify) {
                        if(classify && [classify.allKeys containsObject:@"id"] && [classify.allKeys containsObject:@"index"]) {
                            NSMutableArray* categories = [categoryItems objectForKey:[classify objectForKey:@"id"]];
                            if (!categories) {
                                categories = [NSMutableArray new];
                            }
                            [categories addObject:@{@"item":[newCategoryItem mutableCopy], @"index":[classify objectForKey:@"index"]}];
                            
                            categories = [[self sortByIndex:categories] mutableCopy];
                            
                            [categoryItems setObject:categories forKey:[classify objectForKey:@"id"]];
                        }
                    }
                } else {
                    for (SubCategoryItem* subCategory in newCategoryItem.subItems) {
                        for (CategoryItem* item in subCategory.cellCategories) {
                            if ([item isValid]) {
                                for (NSDictionary* classify in item.classify) {
                                    if(classify && [classify.allKeys containsObject:@"id"] && [classify.allKeys containsObject:@"index"]) {
                                        NSMutableArray* categories = [categoryItems objectForKey:[classify objectForKey:@"id"]];
                                        if (!categories) {
                                            categories = [NSMutableArray new];
                                        }
                                        [categories addObject:@{@"item":item, @"index":[classify objectForKey:@"index"]}];
                                        
                                        categories = [[self sortByIndex:categories] mutableCopy];
                                        
                                        [categoryItems setObject:categories forKey:[classify objectForKey:@"id"]];
                                    }
                                }
                            }
                            
                        }
                    }
                }
                
            }

        } else if ([SECTION_TYPE_RECOMMEND isEqualToString:group.sectionType]) {
            SectionRecommend* recommend = (SectionRecommend*)[group.sectionArray objectAtIndex:group.current];
            for (CategoryItem* item in recommend.items) {
                if ([item isValid]) {
                    for (NSDictionary* classify in item.classify) {
                        if(classify && [classify.allKeys containsObject:@"id"] && [classify.allKeys containsObject:@"index"]) {
                            NSMutableArray* categories = [categoryItems objectForKey:[classify objectForKey:@"id"]];
                            if (!categories) {
                                categories = [NSMutableArray new];
                            }
                            [categories addObject:@{@"item":item, @"index":[classify objectForKey:@"index"]}];
                            categories = [[self sortByIndex:categories] mutableCopy];
                            
                            [categoryItems setObject:categories forKey:[classify objectForKey:@"id"]];
                            
                            
                        }
                    }
                }
            }
        }
    }
   
    
    for (NSString* serviceId in [categoryItems allKeys]) {
        NSMutableArray* array = (NSMutableArray*)[categoryItems objectForKey:serviceId];
        [self.categoryCount setObject:[NSNumber numberWithInt:array.count] forKey:serviceId];
    }

    for (ServiceItem* item in [UIDataManager instance].classifyArray ) {
        SectionService* group = [[SectionService alloc] init];
        BOOL hasService = NO;
        for (NSDictionary* dic in [categoryItems objectForKey:item.identifier]) {
            [group.items addObject:[dic objectForKey:@"item"]];
            hasService = YES;
        }
        if (hasService) {
            group.identify = item.identifier;
            group.name = item.title;
            [self.serviceArray addObject:group];
            [self.classifyItems addObject:[item mutableCopy]];
        }
    }
}


- (NSArray *) sortByIndex:(NSMutableArray*)categoryArray
{
    NSComparator cmptr = ^(id obj1, id obj2){
        NSDictionary* dic1 = obj1;
        NSDictionary* dic2 = obj2;
        NSInteger target1 = [[dic1 objectForKey:@"index"] intValue];
        NSInteger target2 = [[dic2 objectForKey:@"index"] intValue];
        if (target1 > target2) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        
        if (target1 < target2) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedSame;
    };
    
    return [categoryArray sortedArrayUsingComparator:cmptr];;
}

- (void) gobackBtnPressed
{
    [[TouchPalDialerAppDelegate naviController]popViewControllerAnimated:YES];
}

- (void) refreshTitle
{
    int section = 0;
    for (ServiceItem* item in self.classifyItems) {
        if (item.isSelected) {
            break;
        }
        section++;
    }
    [self.titleTableView reloadData];
    
    NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:section];
    if (path.section == 0) {
        [self.contentTableView setContentOffset:CGPointZero animated:YES];
    } else {
        CGRect rectOfCellInTableView = [self getRectWithIndexPath:path];
        CGRect scrollToRect = CGRectMake(rectOfCellInTableView.origin.x, rectOfCellInTableView.origin.y - INDEX_ROW_HEIGHT_SERVICE_HEADER + 1, self.contentTableView.bounds.size.width, self.contentTableView.bounds.size.height);
        [self.contentTableView scrollRectToVisible:scrollToRect animated:YES];
    }
    
    
}

- (CGRect) getRectWithIndexPath:(NSIndexPath *)path
{
    CGRect rectOfCellInTableView = [self.contentTableView rectForRowAtIndexPath: path];
    int section = path.section;
    CGFloat offsetHeight = 0;
    ServiceItem* item = [self.classifyItems objectAtIndex:section];
    NSString* serviceId = item.identifier;
    int categoryCout = [[self.categoryCount objectForKey:serviceId] intValue];
    int count = (categoryCout + SERVICE_COLUMN_COUNT - 1) / SERVICE_COLUMN_COUNT;
    while (categoryCout == 0 && section >= 0) {
        item = [self.classifyItems objectAtIndex:--section];
        serviceId = item.identifier;
        categoryCout = [[self.categoryCount objectForKey:serviceId] intValue];
        count = (categoryCout + SERVICE_COLUMN_COUNT - 1) / SERVICE_COLUMN_COUNT;
        path = [NSIndexPath indexPathForRow:0 inSection:section];
        rectOfCellInTableView = [self.contentTableView rectForRowAtIndexPath: path];
        offsetHeight = offsetHeight + count * INDEX_ROW_HEIGHT_SERVICE_CONTENT + INDEX_ROW_HEIGHT_SERVICE_HEADER;
    }
    if (rectOfCellInTableView.size.height == 0) {
        rectOfCellInTableView = CGRectMake(0, offsetHeight, self.contentTableView.bounds.size.width, 100);
    } else {
       rectOfCellInTableView = CGRectMake(rectOfCellInTableView.origin.x, rectOfCellInTableView.origin.y + offsetHeight, self.contentTableView.bounds.size.width, 100);
    }
    return rectOfCellInTableView;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([scrollView isEqual:self.contentTableView]) {
        NSArray* indexPathes = [self.contentTableView indexPathsForVisibleRows];
        
        int section = [(NSIndexPath *)[indexPathes objectAtIndex:0] section];
        ServiceItem* item = (ServiceItem*)[self.classifyItems objectAtIndex:section];
        if (!item.isSelected){
            for (ServiceItem* item in self.classifyItems) {
                item.isSelected = NO;
            }
            item.isSelected = YES;
            [self.titleTableView reloadData];
            
        }
        
        NSIndexPath* path = (NSIndexPath *)[indexPathes objectAtIndex:0];
        NSIndexPath *titlePath = [NSIndexPath indexPathForRow:0 inSection:path.section];
        CGRect rectOfCellInTableView = [self.titleTableView rectForRowAtIndexPath: titlePath];
        [self.titleTableView scrollRectToVisible:rectOfCellInTableView animated:NO];
        
        CGFloat sectionHeaderHeight = INDEX_ROW_HEIGHT_SERVICE_HEADER;
        if (scrollView.contentOffset.y <= sectionHeaderHeight && scrollView.contentOffset.y >= 0) {
            scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
        } else if (scrollView.contentOffset.y >= sectionHeaderHeight) {
            scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
        }
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    cootek_log(@"Received memory warning in AllServiceViewController.");
}

#pragma mark tableView delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([tableView isEqual:self.contentTableView]) {
       return self.classifyItems.count;
    } else if([tableView isEqual:self.titleTableView]){
       return self.classifyItems.count;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([tableView isEqual:self.contentTableView]) {
        ServiceItem* item = [self.classifyItems objectAtIndex:section];
        NSString* serviceId = item.identifier;
        if (serviceId && [[self.categoryCount allKeys] containsObject:serviceId]) {
            return ([[self.categoryCount objectForKey:serviceId] intValue] + SERVICE_COLUMN_COUNT - 1) / SERVICE_COLUMN_COUNT;
        }
        
    } else if([tableView isEqual:self.titleTableView]){
        return 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"service"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"service"];
        if ([tableView isEqual:self.contentTableView]) {
            ServiceCategoryRowView* categoryView = [[ServiceCategoryRowView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, INDEX_ROW_HEIGHT_SERVICE_CONTENT)];
            [cell addSubview:categoryView];
        } else if ([tableView isEqual:self.titleTableView]) {
            ServiceTitleView* title = [[ServiceTitleView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, INDEX_ROW_HEIGHT_SERVICE_TITLE)];
            [cell addSubview:title];
        }
        cootek_log(@"cell new");
    } else {
        cootek_log(@"cell reused");
    }
    if ([tableView isEqual:self.contentTableView]) {
        BOOL isLastCategory = NO;
        ServiceCategoryRowView* view = (ServiceCategoryRowView *)[cell viewWithTag:ALL_SERVICE_TAG];
        if (indexPath.section == self.serviceArray.count - 1) {
            ServiceItem* item = [self.classifyItems objectAtIndex:indexPath.section];
            NSString* serviceId = item.identifier;
            int categoryCout = [[self.categoryCount objectForKey:serviceId] intValue];
            int count = (categoryCout + SERVICE_COLUMN_COUNT - 1) / SERVICE_COLUMN_COUNT;
            isLastCategory = (count == indexPath.row + 1);
        }
        [view resetDataWithCategoryItem:[self.serviceArray objectAtIndex:indexPath.section] andIndexPath:indexPath andIsLastCategory:isLastCategory];
    } else if ([tableView isEqual:self.titleTableView]) {
        ServiceTitleView* title = (ServiceTitleView *)[cell viewWithTag:ALL_SERVICE_TAG];
        [title resetWithService:self.classifyItems andIndexPath:indexPath];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat rowHeight = 0.0f;
    if ([tableView isEqual:self.contentTableView]) {
        NSInteger section = indexPath.section;
        if (self.serviceArray.count > 0 && section == self.serviceArray.count - 1) {
            ServiceItem* item = [self.classifyItems objectAtIndex:section];
            NSString* serviceId = item.identifier;
            int categoryCout = [[self.categoryCount objectForKey:serviceId] intValue];
            int count = (categoryCout + SERVICE_COLUMN_COUNT - 1) / SERVICE_COLUMN_COUNT;
            rowHeight = tableView.frame.size.height - (count - 1) * INDEX_ROW_HEIGHT_SERVICE_CONTENT - INDEX_ROW_HEIGHT_SERVICE_HEADER + 1;
        } else {
            rowHeight = INDEX_ROW_HEIGHT_SERVICE_CONTENT;
        }
    } else if ([tableView isEqual:self.titleTableView]){
        rowHeight = INDEX_ROW_HEIGHT_SERVICE_TITLE;
    }
    return rowHeight;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if ([tableView isEqual:self.contentTableView]) {
        return INDEX_ROW_HEIGHT_SERVICE_HEADER;
    } else {
        return 0;
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if ([tableView isEqual:self.contentTableView]) {
        static NSString * identy = @"header";
        
        UITableViewHeaderFooterView * hf = [tableView dequeueReusableHeaderFooterViewWithIdentifier:identy];
        
        if (!hf) {
            hf = [[UITableViewHeaderFooterView alloc]initWithReuseIdentifier:identy];
            ServiceHeaderView* header = [[ServiceHeaderView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, INDEX_ROW_HEIGHT_SERVICE_HEADER)];
            [hf addSubview:header];
        }
        ServiceHeaderView* header = (ServiceHeaderView *)[hf viewWithTag:SERVICE_HEADER_TAG];
        ServiceItem* item = [self.classifyItems objectAtIndex:section];
        NSString* serviceName = item.title;
        [header drawTitle:serviceName];
        return header;
    }
    return nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[YellowPageMainQueue instance] removeFirstTask];
}

@end

//
//  CitySelectViewController.m
//  TouchPalDialer
//
//  Created by tanglin on 15/8/26.
//
//

#import "CitySelectViewController.h"
#import "IndexConstant.h"
#import "CityModel.h"
#import "HeaderBar.h"
#import "TPHeaderButton.h"
#import "UITableView+TP.h"
#import "CitySelectRowView.h"
#import "LocalStorage.h"
#import "UpdateService.h"
#import "VerticallyAlignedLabel.h"
#import "TouchPalDialerAppDelegate.h"
#import "LetterCircleView.h"
#import "ImageUtils.h"
#import "YellowPageMainQueue.h"

@interface CitySelectViewController(){
    NSMutableArray* cityModels;
    NSArray* letterArray;
    TPHeaderButton* gobackBtn;
    CGFloat startY;
    LetterCircleView* letterCircleView;
    
}

@end
@implementation CitySelectViewController
@synthesize cityTableView;
@synthesize letterTableView;
@synthesize headerView;


- (void)loadView
{
    [super loadView];
    
    letterArray = @[@"⭐️",@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z"];
    
    NSString* title = @"选择城市";
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
    
    self.cityTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,TPHeaderBarHeight(), TPScreenWidth(), TPHeightFit(415)) style:UITableViewStylePlain];
    
    [cityTableView setExtraCellLineHidden];
    cityTableView.delegate = self;
    cityTableView.dataSource = self;
    cityTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [cityTableView setSkinStyleWithHost:self forStyle:@"defaultBackground_color"];
    cityTableView.showsVerticalScrollIndicator = NO;
    cityTableView.backgroundColor = [UIColor whiteColor];
    
    int rowHeight = TPHeightFit(415) / letterArray.count;
    int tableHeight = rowHeight * letterArray.count;
    self.letterTableView = [[UITableView alloc] initWithFrame:CGRectMake(TPScreenWidth() - 30, TPHeaderBarHeight() + (TPHeightFit(415) - tableHeight) / 2, 30, tableHeight)];
    [letterTableView setSkinStyleWithHost:self forStyle:@"defaultBackground_color"];
    letterTableView.separatorStyle = UITableViewCellAccessoryNone;
    letterTableView.backgroundColor = [UIColor whiteColor];
    letterTableView.delegate = self;
    letterTableView.dataSource = self;
    letterTableView.scrollEnabled = NO;
    
    [self getCityData];
    
    [self.view addSubview:cityTableView];
    [self.view addSubview:letterTableView];
    
    
    LetterCircleView* letterView = [[LetterCircleView alloc]initWithFrame:CGRectMake(TPScreenWidth() / 2 - 30, TPHeaderBarHeight() + TPHeightFit(415) / 2 - 30, 60, 60)];
    
    letterCircleView = letterView;
    [self.view addSubview:letterView];
    letterCircleView.hidden = YES;
    
    [self.view addSubview:letterTableView];
    UIPanGestureRecognizer *panGes = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panMoveHandler:)];
    [letterTableView addGestureRecognizer:panGes];
}


- (void)panMoveHandler:(UIPanGestureRecognizer *)gesture{
    
    CGPoint point = [gesture locationInView:self.letterTableView];
    CGFloat heightRow = self.letterTableView.frame.size.height / letterArray.count;
    if (point.y < 0) {
        point.y = 0.0f;
    } else if(point.y > self.letterTableView.frame.size.height) {
        point.y = self.letterTableView.frame.size.height;
    }
    
    int section = point.y / heightRow;
    [self drawFromLetterIndex:section];
    if (gesture.state == UIGestureRecognizerStateEnded) {
        letterCircleView.hidden = YES;
    }
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

- (void) gobackBtnPressed
{
    [[TouchPalDialerAppDelegate naviController]popViewControllerAnimated:YES];
}

- (void) getCityData
{
    cityModels = [[NSMutableArray alloc] init];
    NSArray *mainPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [mainPath objectAtIndex:0];
    NSString* citydata = [self readFromFile:[NSString stringWithFormat:@"%@/%@",[documentsDirectory stringByAppendingPathComponent:WORKING_SPACE],CITY_DATA_FILE]];
    NSData *data = [citydata dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error =nil;
    if (!data) {
        citydata = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@/%@",WORKING_SPACE,CITY_DATA_FILE] ofType:@""];
        data = [citydata dataUsingEncoding:NSUTF8StringEncoding];
    }
    NSArray *returnData= [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves|NSJSONReadingAllowFragments error:&error];
    for (NSDictionary* cityItem in returnData) {
        CityModel* model = [[CityModel alloc]init];
        model.capital = [cityItem objectForKey:@"capital"];
        model.value = [cityItem objectForKey:@"value"];
        if (model.value.count > 0) {
            model.expandable = [[cityItem objectForKey:@"expandable"] boolValue];
        } else if ([model.capital isEqualToString:@"当前定位城市"]){
            model.value = @[[LocalStorage getItemWithKey:QUERY_PARAM_LOC_CITY]];
            model.expandable = NO;
        }
        [cityModels addObject:model];
        model.isExpanded = NO;
        
    }
    
    if (cityModels.count == 0) {
        NSString *originWorkPath = [[NSBundle mainBundle] pathForResource:@"webpages" ofType:@""];
        NSString* citydata = [self readFromFile:[NSString stringWithFormat:@"%@/%@",originWorkPath,CITY_DATA_FILE]];
        NSData *data = [citydata dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error =nil;
        NSArray *returnData= [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves|NSJSONReadingAllowFragments error:&error];
        for (NSDictionary* cityItem in returnData) {
            CityModel* model = [[CityModel alloc]init];
            model.capital = [cityItem objectForKey:@"capital"];
            model.value = [cityItem objectForKey:@"value"];
            if (model.value.count > 0) {
                model.expandable = [[cityItem objectForKey:@"expandable"] boolValue];
            } else if ([model.capital isEqualToString:@"当前定位城市"]){
                model.value = @[[LocalStorage getItemWithKey:QUERY_PARAM_LOC_CITY]];
                model.expandable = NO;
            }
            [cityModels addObject:model];
            model.isExpanded = NO;
        }
    }
}

- (NSString *) readFromFile:(NSString *)filepath{
    if ([[NSFileManager defaultManager] fileExistsAtPath:filepath]){
        NSString *content = [[NSString alloc] initWithContentsOfFile:filepath encoding:NSUTF8StringEncoding error:nil];
        return content;
    } else {
        return nil;
    }
}


#pragma mark tableView delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([tableView isEqual:self.cityTableView]) {
        return cityModels.count;
    } else {
        return letterArray.count;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([tableView isEqual:self.cityTableView]) {
        CityModel* model = [cityModels objectAtIndex:section];
        if ([model.capital isEqualToString:@"热门城市"]) {
            return (model.value.count + 2) / 3 + 1;
        }
        return model.value.count + 1;
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"city"];
    if ([tableView isEqual:self.cityTableView]) {
        CityModel* model = [cityModels objectAtIndex:indexPath.section];
        if (cell) {
            CitySelectRowView* view = (CitySelectRowView*)[cell viewWithTag:CITY_SELECT_TAG];
            
            [view resetDataWithCityModel:model andIndexPath:indexPath];
            return cell;
        }
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"city"] ;
        cell.backgroundColor = [UIColor whiteColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        CitySelectRowView* view = [CitySelectRowView new];
        
        [cell addSubview:view];
        [view resetDataWithCityModel:model andIndexPath:indexPath];
        
    } else {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"city"] ;
        cell.backgroundColor = [UIColor whiteColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        int height = self.letterTableView.frame.size.height / letterArray.count;
        
        UIButton* letterBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, letterTableView.frame.size.width, height)];
        VerticallyAlignedLabel* view = [[VerticallyAlignedLabel alloc]initWithFrame:letterBtn.bounds];
        view.text = [letterArray objectAtIndex:indexPath.section];
        view.backgroundColor = [ImageUtils colorFromHexString:CITY_LETTER_BG andDefaultColor:nil];
        view.numberOfLines=1;
        view.font=[UIFont systemFontOfSize:12];
        view.textColor = [UIColor blackColor];
        view.verticalAlignment = VerticalAlignmentMiddle;
        letterBtn.tag = indexPath.section;
        view.textAlignment = NSTextAlignmentCenter;
        
        [letterBtn addSubview:view];
        [letterBtn addTarget:self action:@selector(btnTouchUp:) forControlEvents:UIControlEventTouchUpInside];
        [letterBtn addTarget:self action:@selector(btnTouchDown:) forControlEvents:UIControlEventTouchDown];
        [letterBtn addTarget:self action:@selector(btnTouchUp:) forControlEvents:UIControlEventTouchUpOutside];
        [cell addSubview:letterBtn];
    }
    
    return cell;
}

- (void)btnTouchUp:(id)sender{
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^{
        letterCircleView.hidden = YES;
    });
    UInt64 recordTime = [[NSDate date] timeIntervalSince1970]*1000;
    cootek_log(@" ---- btn up -----, %ld", recordTime);
}

- (void)btnTouchDown:(id)sender{
    
    UInt64 recordTime = [[NSDate date] timeIntervalSince1970]*1000;
    cootek_log(@" ---- btn down -----, %ld", recordTime);
    UIButton* btn = sender;
    [self drawFromLetterIndex:btn.tag];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat rowHeight = 0.0f;
    if ([tableView isEqual:self.cityTableView]) {
        CityModel* model = [cityModels objectAtIndex:indexPath.section];
        if (model.value.count > 0) {
            rowHeight = [CitySelectRowView getRowHeight:model andIndexPath:indexPath];
        }
    } else {
        int height = self.letterTableView.frame.size.height / letterArray.count;
        rowHeight = height;
        
    }
    return rowHeight;
}

-(void) drawFromLetterIndex:(NSInteger)section
{
    NSString* letter = [letterArray objectAtIndex:section];
    int index = 0;
    CityModel* model = nil;
    for (CityModel* m in cityModels) {
        if ([m.capital isEqualToString:letter] || ([m.capital isEqualToString:@"热门城市"] && [letter isEqualToString:@"⭐️"])) {
            model = m;
            break;
        }
        index++;
    }

    NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:index];
    CGRect rectOfCellInTableView = [self.cityTableView rectForRowAtIndexPath: path];
    CGRect scrollToRect = CGRectMake(rectOfCellInTableView.origin.x, rectOfCellInTableView.origin.y, self.cityTableView.bounds.size.width, self.cityTableView.bounds.size.height);

    [self.cityTableView scrollRectToVisible:scrollToRect animated:NO];
    
    letterCircleView.hidden = NO;
    letterCircleView.letter = letter;
    [letterCircleView setNeedsDisplay];
}
@end

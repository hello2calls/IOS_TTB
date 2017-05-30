//
//  CommonSingleSelectTableViewController.m
//  TouchPalDialer
//
//  Created by Sendor on 11-9-9.
//  Copyright 2011 Cootek. All rights reserved.
//

#import "CommonSingleSelectTableViewController.h"
#import "HeaderBar.h"
#import "TPHeaderButton.h"
#import "CootekTableViewCell.h"
#import "TPDialerResourceManager.h"
#import "SkinHandler.h"
#import "UITableView+TP.h"

@implementation CommonSingleSelectData

@synthesize name;
@synthesize data;

- (id)initWithName:(NSString*)paraName withData:(int)paraData {
    self = [super init];
    if (self != nil) {
        self.name = paraName;
        self.data = paraData;
    }
    return self;
}

@end

@implementation CommonSingleSelectTableViewController

@synthesize all_items;
@synthesize existed_datas;

#pragma mark -
#pragma mark Initialization


- (id)initWithAllItems:(NSArray*)allItems existedDatas:(NSArray*)existedDatas delegate:(id<CommonSingleSelectDelegate>)paraDelegate {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    self = [super init];
    if (self) {
        delegate = paraDelegate;
        self.all_items = allItems;
        self.existed_datas = existedDatas;
    }
    return self;
}

- (BOOL)isExistedData:(int)data {
    int existedCount = [existed_datas count];
    int i = 0;
    for (; i<existedCount; i++) {
        NSNumber* dataItem =  [existed_datas objectAtIndex:i];
        if ([dataItem intValue] == data) {
            return YES;
        }
    }
    return NO;
}


#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"defaultBackground_color"];
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    HeaderBar *header = [[HeaderBar alloc] initHeaderBar];
     [header setSkinStyleWithHost:self forStyle:@"defaultHeaderView_style"];
    [self.view addSubview:header];

    //返回
	//UIImage *cancel_icon = [UIImage imageNamed:@"common_navgation_back_icon@2x.png"];
	//TPHeaderButton *cancel_but = [[TPHeaderButton alloc] initWithBackFrame:CGRectMake(0, 0, cancel_icon.size.width, cancel_icon.size.height) withIcon:cancel_icon];
     TPHeaderButton *cancel_but = [[TPHeaderButton alloc] initLeftBtnWithFrame:CGRectMake(0, 0,50, 45)];
     [cancel_but setSkinStyleWithHost:self forStyle:@"default_backButton_style"];
	[cancel_but addTarget:self action:@selector(goToBack) forControlEvents:UIControlEventTouchUpInside];
	[header addSubview:cancel_but];
    
    //选择
    UILabel *mtitle=[[UILabel alloc] initWithFrame:CGRectMake(130, 8, 84, 30)];		
    mtitle.font=[UIFont systemFontOfSize:CELL_FONT_TITILE];
    mtitle.backgroundColor=[UIColor clearColor];
    mtitle.textColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"defaultText_color"];
    mtitle.textAlignment=NSTextAlignmentLeft;
    mtitle.text=NSLocalizedString(@"Add more", @"Add more");
    [header addSubview:mtitle];
    
    //表数据		
    UITableView *contenView = [[UITableView alloc] initWithFrame:CGRectMake(0, TPHeaderBarHeight(), TPScreenWidth(), TPHeightFit(415)) style:UITableViewStyleGrouped];
    contenView.backgroundView = nil;
    contenView.delegate = self;
    contenView.dataSource = self;
    [contenView setSkinStyleWithHost:self forStyle:@"defaultUITableView_style"];
    [self.view addSubview:contenView];
}
-(void)goToBack
{
    [self dismissViewControllerAnimated:YES completion:^(){}];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [all_items count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    CootekTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        RoundedCellBackgroundViewPosition position = [tableView cellPositionOfIndexPath:indexPath];
        cell = [[CootekTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier cellPosition:position] ;
    }
    // Configure the cell...
    int index = [indexPath row];
    CommonSingleSelectData* item = [all_items objectAtIndex:index];
    cell.textLabel.text = item.name;
    if ([self isExistedData:item.data]) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.userInteractionEnabled = NO;
        cell.textLabel.textColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"defaultTextGray_color"];
    }
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // set cell data to parent here...
    __strong CommonSingleSelectData* item = [all_items objectAtIndex:[indexPath row]];
    [self dismissViewControllerAnimated:NO completion:^(){}];
    [delegate onSelectedData:item.data];
}


- (void)dealloc {
    [SkinHandler removeRecursively:self];
}
@end


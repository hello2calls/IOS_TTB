//
//  GestureActionPickerViewController.m
//  TouchPalDialer
//
//  Created by xie lingmei on 12-5-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GestureActionPickerViewController.h"
#import "HeaderBar.h"
#import "TPHeaderButton.h"
#import "TPItemButton.h"
#import "ContactCacheDataManager.h"
#import "GestureEditViewController.h"
#import "GestureModel.h"
#import "GestureUtility.h"
#import "TPDialerResourceManager.h"
#import "SkinHandler.h"
#import "UITableView+TP.h"
#import "NSString+PhoneNumber.h"
#import "FunctionUtility.h"

#define ICON_VIEW_TAG 2000
@implementation GestureActionPickerViewController{

}

@synthesize personID;
@synthesize keyName;
@synthesize gestureTable;
@synthesize contactModel;
@synthesize phoneList;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (id)initWithPersonID:(NSInteger)tmppersonID
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.personID = tmppersonID;
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.contactModel =[[ContactCacheDataManager instance] contactCacheItem:personID];
    self.phoneList = [contactModel phones];
    
   
    self.headerTitle = contactModel.fullName;

    // content view
	UITableView *tmp_view_content = [[UITableView alloc]
                                     initWithFrame:CGRectMake(0, TPHeaderBarHeight(), TPScreenWidth(), TPScreenHeight() - 65)
                                     style:UITableViewStylePlain];
    [tmp_view_content setExtraCellLineHidden];
    [tmp_view_content setSkinStyleWithHost:self forStyle:@"defaultBackground_color"];
	self.gestureTable = tmp_view_content;
	gestureTable.delegate = self;
	gestureTable.dataSource = self;
    gestureTable.sectionHeaderHeight = 20;
    gestureTable.rowHeight = 60;
    gestureTable.separatorStyle = UITableViewCellSeparatorStyleNone;
	[self.view addSubview:gestureTable];
    
    [FunctionUtility updateStatusBarStyle];
}

#pragma mark - Table view delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[contactModel phones] count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    int row = [indexPath row];
    PhoneDataModel *phone = [phoneList objectAtIndex:row];
    NSString *key = [GestureUtility serializerName:phone.number withPersonID:personID withAction:ActionCall];
    self.keyName = key;
    
    GestureEditViewController *editGestureController = [[GestureEditViewController alloc]
                                                        initWithGestureName: key];
    
    Gesture *gesture = [[GestureModel getShareInstance].mGestureRecognier getGesture:key];
    UIImage *icon =  [gesture convertToImage];
    
    if (icon) {
        editGestureController.isEditGesture = YES;
    } else {
        editGestureController.isEditGesture = NO;
    }
    editGestureController.signedContact = YES;
    [self.navigationController  pushViewController:editGestureController animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    RoundedCellBackgroundViewPosition position = [tableView cellPositionOfIndexPath:indexPath];
    CootekTableViewCell *cell = [[CootekTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"" cellPosition:position] ;

    int row = [indexPath row];    
    PhoneDataModel *phone = [phoneList objectAtIndex:row];
    
    UILabel *gestureLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 185, 60)];
    gestureLabel.backgroundColor = [UIColor clearColor];
    gestureLabel.textColor = [TPDialerResourceManager getColorForStyle:@"defaultCellMainText_color"];
    gestureLabel.font=[UIFont systemFontOfSize:CELL_FONT_INPUT];
    gestureLabel.textAlignment=NSTextAlignmentLeft;
    gestureLabel.lineBreakMode=NSLineBreakByCharWrapping;
    gestureLabel.numberOfLines=0;
    gestureLabel.text = [phone.number formatPhoneNumber];
    [cell addSubview:gestureLabel];
    
    
    UILabel *arrowLabel         = [[UILabel alloc] init];
    arrowLabel.textColor        = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"generalSettingCell_infoText_color"];
    arrowLabel.backgroundColor  = [UIColor clearColor];
    arrowLabel.font             = [UIFont fontWithName:@"iPhoneIcon1" size:14];
    arrowLabel.text             = @"q";
    arrowLabel.frame            = CGRectMake(TPScreenWidth()-30, 0, 20, 60);
    arrowLabel.textAlignment    = NSTextAlignmentCenter;
    [cell addSubview:arrowLabel];
  
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

    UIView *header = [[UIView alloc] init];
    header.backgroundColor = [UIColor clearColor];
    return header;
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [gestureTable reloadData];
}
-(void)dealloc{
    [SkinHandler removeRecursively:self];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
- (void)gotoBack{
	[self.navigationController popViewControllerAnimated:YES];
}
@end

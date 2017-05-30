//
//  ExcludedListForSmartDialViewController.m
//  TouchPalDialer
//
//  Created by 亮秀 李 on 11/8/12.
//
//

#import "ExcludedListForSmartDialViewController.h"
#import "TPItemButton.h"
#import "CommonMultiSelectTableViewController.h"
#import "IPExcudeNumberModelManager.h"
#import "SettingCellView.h"
#import "SelectViewController.h"
#import "TouchPalDialerAppDelegate.h"
#import "TPDialerResourceManager.h"
#import "TPHeaderButton.h"
#import "FunctionUtility.h"
#import "LangUtil.h"
#import "DefaultUIAlertViewHandler.h"
#import "NSString+PhoneNumber.h"
#import "ContactCacheDataManager.h"

@interface ExcludedListForSmartDialViewController () <SettingCellDelegate,SelectViewProtocalDelegate,CommonMultiSelectProtocol>{
    UITableView *tableView_;
}
@property (nonatomic,retain) NSMutableArray *phoneNumbers;
@property (nonatomic,retain) NSDictionary *numberNameDic;
@property (nonatomic,retain) NSArray *personsThatIsNotInExcludedList;
@property (nonatomic,retain) NSMutableArray *selectExcludedPersonList;
@property (nonatomic,retain) NSString *cellKeyToBeRemoved;
@property (nonatomic,retain) NSString *headerText;
@property (nonatomic,weak) UIView *nullContentView;
@end

@implementation ExcludedListForSmartDialViewController
@synthesize numberNameDic;
@synthesize personsThatIsNotInExcludedList;
@synthesize selectExcludedPersonList;
@synthesize headerText;
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupNullContentView];
    
    TPHeaderButton *tmpAddMember = [[TPHeaderButton alloc] initRightBtnWithFrame:CGRectMake(TPScreenWidth()-50, 0, 50, 45)];
    [tmpAddMember setSkinStyleWithHost:self forStyle:@"defaultTPHeaderButton_style"];
    [tmpAddMember setTitle:NSLocalizedString(@"Add", @"") forState:UIControlStateNormal];
	[tmpAddMember addTarget:self action:@selector(openSelectExcludedView) forControlEvents:UIControlEventTouchUpInside];
    [self.headerBar addSubview:tmpAddMember];
	// Do any additional setup after loading the view.
    self.headerText =  NSLocalizedString(@"IP rules will not pop up for the following numbers:", @"");
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, TPHeaderBarHeight(), TPScreenWidth(), TPScreenHeight()-TPHeaderBarHeight()) style:UITableViewStylePlain];
    tableView.backgroundView = nil;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.sectionHeaderHeight = 20;
    tableView.rowHeight = 60;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [tableView setSkinStyleWithHost:self forStyle:@"defaultBackground_color"];
    tableView_ = tableView;
    [self.view addSubview:tableView];
    
    
    //data
    [self prepareData];
}

- (void)setupNullContentView
{
    UIView *nullContentView = [[UIView alloc] initWithFrame:CGRectMake(0, TPHeaderBarHeight(), TPScreenWidth(), TPScreenHeight() - TPHeaderBarHeight())];
    nullContentView.backgroundColor = [UIColor clearColor];
    self.nullContentView = nullContentView;
    [self.view addSubview:nullContentView];

    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.contentMode = UIViewContentModeCenter;
    UIImage *image = [TPDialerResourceManager getImage:@"smart_dial_setting_none_content@2x.png"];
    imageView.image = image;
    [nullContentView addSubview:imageView];
    
    UILabel *nullContentLabel = [[UILabel alloc] init];
    nullContentLabel.backgroundColor = [UIColor clearColor];
    nullContentLabel.text = @"此页暂无内容";
    nullContentLabel.textColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"defaultTextGray_color"];
    [nullContentLabel sizeToFit];
    [nullContentView addSubview:nullContentLabel];

    CGFloat mageViewX = (nullContentView.tp_width - image.size.width) / 2;
    CGFloat mageViewY = (nullContentView.tp_height - image.size.height - nullContentLabel.tp_height - 24) / 2;

    imageView.frame = CGRectMake(mageViewX, mageViewY - TPHeaderBarHeight() / 2, image.size.width, image.size.height);
    
    nullContentLabel.tp_y = imageView.tp_y + imageView.tp_height + 24;
    nullContentLabel.tp_x = (nullContentView.tp_width - nullContentLabel.tp_width) / 2;;
}

- (void)prepareData{
    NSArray *excludedList = [[IPExcudeNumberModelManager sharedManager] getExcludedFromSmartDialPersonList];
    //refresh excludedList according to the latest contact info
    NSArray *numberKeys = [excludedList sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString  *number1 = obj1;
        NSString *number2 = obj2;
        int personId1 = [NumberPersonMappingModel  queryContactIDByNumber:number1];
        int personId2 = [NumberPersonMappingModel  queryContactIDByNumber:number2];
        ContactCacheDataModel *person1 = [[ContactCacheDataManager instance] contactCacheItem:personId1];
        ContactCacheDataModel *person2 = [[ContactCacheDataManager instance] contactCacheItem:personId2];
        NSString *name1 = person1.displayName;
        NSString *name2 = person2.displayName;
        if(name1 == nil || [name1 length] == 0){
            name1 = [number1 digitNumber];
        }
        if(name2 == nil || [name2 length] == 0){
            name2 = [number2 digitNumber];
        }
        wchar_t char_1 = getFirstLetter(NSStringToFirstWchar(name1));
        wchar_t char_2 = getFirstLetter(NSStringToFirstWchar(name2));
        if (char_1 > char_2) {
            return NSOrderedDescending;
        } else if (char_1 == char_2) {
            return NSOrderedSame;
        } else {
            return NSOrderedAscending;
        }
    }];
    NSMutableDictionary *tmpNumberAndNameDic = [[NSMutableDictionary alloc] initWithCapacity:excludedList.count];
    
    for(NSString *number in numberKeys){
        int personId = [NumberPersonMappingModel queryContactIDByNumber:number];
        ContactCacheDataModel *person = [[ContactCacheDataManager instance] contactCacheItem:personId];
        NSString *name ;
        if(person == nil || [person.fullName length] == 0){
            name = [number digitNumber];
        } else {
            name = person.fullName;
        }
        [tmpNumberAndNameDic setObject:name forKey:number];
    }
    self.numberNameDic = tmpNumberAndNameDic;
    self.phoneNumbers = [NSMutableArray arrayWithArray:numberKeys];
    self.personsThatIsNotInExcludedList = [[IPExcudeNumberModelManager sharedManager] getPersonListThatIsNotInExcludedList];
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *sectionHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, TPScreenWidth(), tableView.sectionHeaderHeight)];
    sectionHeader.backgroundColor = [UIColor clearColor];
    return sectionHeader;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return tableView.sectionHeaderHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    tableView_.hidden = !self.phoneNumbers.count;
    self.nullContentView.hidden = self.phoneNumbers.count;
    return self.phoneNumbers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdentifier = @"ExcludeFromSmartDialCell";
    SettingCellView *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil){
        cell = [[SettingCellView alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier withCellType:UITableViewCellStyleSubtitle];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    }
    NSString *phoneNumber = [self.phoneNumbers objectAtIndex:[indexPath row]];
    cell.textLabel.text = [self.numberNameDic objectForKey:phoneNumber];
    cell.detailTextLabel.text = [phoneNumber formatPhoneNumber];
    cell.cellKey = [phoneNumber digitNumber];
    cell.delegate = self;
    cell.textLabel.textColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"generalSettingCell_MainText_color"];
    cell.textLabel.highlightedTextColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"generalSettingCell_MainText_color"];
    cell.detailTextLabel.textColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"generalSettingCell_infoText_color"];
    cell.detailTextLabel.highlightedTextColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"generalSettingCell_infoText_color"];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        NSString *phoneNumber = [self.phoneNumbers objectAtIndex:[indexPath row]];
        
        NSString *key = [phoneNumber digitNumber];
        [[IPExcudeNumberModelManager sharedManager] removeItemFromExcludedList:key];
        
        [self.phoneNumbers removeObject:phoneNumber];
        
        [tableView_ deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}
#pragma mark SettingCellDelegate
- (void)touchOperationButton:(NSString *)cellKey{
    self.cellKeyToBeRemoved = cellKey ;
    [DefaultUIAlertViewHandler showAlertViewWithTitle:NSLocalizedString(@"Are you sure to remove", @"") message:nil okButtonActionBlock:^{[self removeExcludedMember];}];
}
- (void)removeExcludedMember{
    [[IPExcudeNumberModelManager sharedManager] removeItemFromExcludedList:self.cellKeyToBeRemoved];
    [self refreshTableView];
}
- (void)refreshTableView{
    [self prepareData];
    [tableView_ reloadData];
}
- (void)gotoBack{
    [super gotoBack];
}
- (void)openSelectExcludedView{
    SelectViewController *selectViewContoller = [[SelectViewController alloc] init];
    selectViewContoller.delegate = self;
    selectViewContoller.dataList = self.personsThatIsNotInExcludedList;
    [self.navigationController pushViewController:selectViewContoller animated:YES];
}
- (void)selectViewFinish:(NSArray *)select_list{
    NSMutableArray* multiSelectDataList = [NSMutableArray arrayWithCapacity:3];
    NSMutableArray *tmpPhoneNumbers = [[NSMutableArray alloc] initWithCapacity:6];
    for (NSNumber *personNumber in select_list) {
        int personId = [personNumber intValue];
        ContactCacheDataModel *person = [[ContactCacheDataManager instance] contactCacheItem:personId];
        NSArray* phones = [person phones];
        int phonesCount = [phones count];
        if (phonesCount > 1) {
            NSMutableArray* multiSelectItems = [[NSMutableArray alloc] init];
            int j = 0;
            for (; j<phonesCount; j++) {
                PhoneDataModel* phoneData = [phones objectAtIndex:j];
                NSString *phoneNumber = phoneData.number;
                BOOL isPreChecked = NO;
                if([[IPExcudeNumberModelManager sharedManager] isThisNumberExcludedFromSmartDial:phoneNumber]){
                    continue;
                }
                
                MultiSelectItemData* itemDataPhones = [[MultiSelectItemData alloc] initWithData:j
                                                                                       withText:phoneNumber
                                                                                      isChecked:isPreChecked];
                [multiSelectItems addObject:itemDataPhones];
            }
            if(multiSelectItems.count>1){
                MultiSelectSectionData *multiSelectSectionData =
                [[MultiSelectSectionData alloc] initWithData:person.personID
                                                    withText:person.fullName
                                                   withItems:multiSelectItems];
                [multiSelectDataList addObject:multiSelectSectionData];
            }
            if(multiSelectItems.count==1){
                [tmpPhoneNumbers addObject:((MultiSelectItemData*)multiSelectItems[0]).text];
            }

        } else if (phonesCount == 1) {
            [tmpPhoneNumbers addObject:[person mainPhone].number];
        }
    }
    self.selectExcludedPersonList = tmpPhoneNumbers;
    
    // deal with multi-phoneNumbers
    if ([multiSelectDataList count] > 0) { // some person have more than 1 number, let user check them
        CommonMultiSelectTableViewController* multiSelectVC = [[CommonMultiSelectTableViewController alloc]
                                                               initWithStyle:UITableViewStylePlain
                                                               data:multiSelectDataList
                                                               delegate:self title:NSLocalizedString(@"Choose the number", @"") needAnimateOut:YES];
        [self.navigationController presentViewController:multiSelectVC animated:YES completion:^(){}];
        
    }else{
        [self addNewExcludedPeronList];
    }
}

- (void)selectViewCancel
{
    
}
#pragma mark CommonMultiSelectProtocol
- (void)checkFinish:(NSArray*)dataList{
    int sectionDataCount = [dataList count];
    int i = 0;
    for (; i<sectionDataCount; i++) {
        MultiSelectSectionData* sectionData = [dataList objectAtIndex:i];
        int itemsDataCount = [sectionData.items count];
        int j = 0;
        for (; j<itemsDataCount; j++) {
            MultiSelectItemData* itemData = [sectionData.items objectAtIndex:j];
            if (itemData.is_checked) {
                [self.selectExcludedPersonList addObject:itemData.text];
            }
        }
    }
    [self addNewExcludedPeronList];
    
}

-(void)addNewExcludedPeronList{
    [[IPExcudeNumberModelManager sharedManager] addItemsToExcludedList:self.selectExcludedPersonList];
    [self refreshTableView];
}

@end

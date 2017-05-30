//
//  ContactViewController.m
//  TouchPalDialer
//
//  Created by Sendor.Wang on 01/06/2012.
//  Copyright 2011 Cootek. All rights reserved.
//

#import "AllCopyViewController.h"
#import "TouchPalDialerAppDelegate.h"
#import "ContactModelNew+IndexA_Z.h"
#import "consts.h"
#import "CootekNotifications.h"
#import "HeaderBar.h"
#import "FunctionUtility.h"
#import "SearchResultModel.h"
#import "SkinHandler.h"
#import "TPDialerResourceManager.h"
#import "LangUtil.h"
#import "UITableView+TP.h"
#import "ContactViewController.h"
#import "ContactCacheDataManager.h"
#import "NSString+TPHandleNil.h"
#import "SmartGroupNode.h"
#import "GroupOperationCommandCreator.h"
#import "GroupIncludeCommand.h"
#import "Person.h"
#import "GroupedContactsModel.h"
#import "FavoriteView.h"
#import "FavoriteModel.h"
#import "RootScrollViewController.h"
#import "PersonDBA.h"
#import "ContactSpecialInfo.h"
#import "ContactTouchpalViewController.h"
#import "UserDefaultsManager.h"
#import "HandlerWebViewController.h"
#import "ContactSpecialInfo.h"
#import "ContactInfoManager.h"
#import "ContactTransferGuideController.h"
#import "ContactTransferMainController.h"
#import "DialerUsageRecord.h"
#import "TouchPalVersionInfo.h"
#import "UILayoutUtility.h"

@class DisplayRequirementsForFilter;

@interface AllCopyViewController (){
    NSDictionary *allContacts;
    NSArray *allContactKeys;
    TPUIButton *_backButton;
}
@property (nonatomic, retain)DisplayRequirementsForFilter *displayRequirementsForFilter;
@property (nonatomic, retain)BaseContactCell *longModeCell;
- (void)arrangeAllViewControllerToDisplayFilterContent;
- (void)addNewIndexSectionViewWithFrame:(CGRect)frame;
- (DisplayRequirementsForFilter *)changeNodeToDisplayRequirements:(LeafNodeWithContactIds *)node;
- (void)backToAllViewController;
- (void)cancelSearch;
- (void)prepareTheHeaderBarDisplayForFilterWithDisplayRequireMents:(DisplayRequirementsForFilter *)displayRequirement;
@end

@implementation AllCopyViewController

@synthesize all_content_view;
@synthesize m_searchbar;
@synthesize search_result_controller;
@synthesize search_engine;
@synthesize section_map;
@synthesize section_index_view;
@synthesize clear_view;
@synthesize hintViewGroup;
@synthesize hintViewUngroup;
@synthesize CellIdentifier;
@synthesize loadDataFromFilter;
@synthesize contactsFromFilter;
@synthesize sectionKeysFromFilter;
@synthesize restoreViewLocationDelegate;
@synthesize filterDescriptionLabel = filterDescriptionLabel_;
@synthesize contactsDisplayViewWithNoAZScrollist;
@synthesize displayType = displayType_;
@synthesize parentViewController1;
@synthesize contactIDsFromFilter;
@synthesize filterDisplayTitle;
@synthesize favArray;
@synthesize displayRequirementsForFilter = displayRequirementsForFilter_;
@synthesize leafNodeFromFilter;
@synthesize needCheck;
@synthesize longGestureController = longGestureController_;
@synthesize guideViewWhenNoContact;

- (void)loadView
{
    cootek_log(@"AllViewController->loadView");
    [self rdv_tabBarController].tabBarHidden = YES;
    
    // root view
    UIView *emptyview = [[UIView alloc] initWithFrame:CGRectMake(0, TPHeaderBarHeight(), TPScreenWidth() , TPScreenHeight()- 65 - 45)];
    self.view = emptyview;
    emptyview.backgroundColor  = [UIColor yellowColor];
    emptyview.backgroundColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"defaultBackground_color"];
    
    // search bar
    TPUISearchBar *tmpSearchBar = [[TPUISearchBar alloc] initWithFrame:CGRectMake(0, 0, TPScreenWidth(), 45)];
    self.m_searchbar = tmpSearchBar;
    [m_searchbar setSkinStyleWithHost:self forStyle:@"TPUISearchBar_default_style"];
    m_searchbar.delegate = self;
    [self.view addSubview:m_searchbar];
    
    // content view
    UITableView *tmp_view_content = [[UITableView alloc] initWithFrame:CGRectMake(0, m_searchbar.frame.size.height, TPScreenWidth(), TPScreenHeight()- 65 - 45) style:UITableViewStylePlain];
    [tmp_view_content setExtraCellLineHidden];
    [tmp_view_content setSkinStyleWithHost:self forStyle:@"UITableView_withBackground_style"];
    self.all_content_view = tmp_view_content;
    all_content_view.delegate = self;
    all_content_view.dataSource = self;
    all_content_view.sectionHeaderHeight = 23;
    all_content_view.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.view addSubview:all_content_view];
    
    // set section index view.
    SectionIndexView *tmpsection_index_view = [[SectionIndexView alloc] initSectionIndexView:[self getRectOfSectionIndexView]];
    self.section_index_view = tmpsection_index_view;
    [section_index_view setSkinStyleWithHost:self forStyle:DRAW_RECT_STYLE];
    section_index_view.delegate = self;
    section_index_view.hidden = YES;
    [self.view addSubview:section_index_view];
    
    // init clear view. when sectionindexview touching, show this.
    ClearView *tmp_clear = [[ClearView alloc] initWithFrame:CGRectMake(TPScreenWidth()-150, 120, 70, 70)];
    self.clear_view = tmp_clear;
    
    ContactSearchModel *tmpEngine = [[ContactSearchModel alloc] initWithSearchType:ContactSearch];
    self.search_engine = tmpEngine;
    
    // search result
    search_result_frame = CGRectMake(0, m_searchbar.frame.size.height, TPScreenWidth(), TPHeightFit(320));
    search_result_controller = [[SearchResultViewController alloc] initWithNibName:nil bundle:nil];
    search_result_controller.delegate = self;
    
    searchResultView = [[SelectSearchResultView alloc] initWithArray:nil andFrame:
                        CGRectMake(0, TPHeaderBarHeight(), TPScreenWidth(), TPHeightFit(320))];
    
    //for displaying contacts from filter that do not need A_Z scrollist
    contactsDisplayViewWithNoAZScrollist = [[FilterContactResultListView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:contactsDisplayViewWithNoAZScrollist];
    contactsDisplayViewWithNoAZScrollist.hidden = YES;
    
    self.CellIdentifier = [NSString stringWithFormat:@"%d",((NSInteger)arc4random())];
    self.loadDataFromFilter = NO;
    displayType_ = DisplayTypeDefault;
    
    needCheck = NO;
    searchResultView.select_delegate = self;
    searchResultView.isSingleCheckMode = NO;
    
    FavoriteNopersonHintView *hintGroup = [[FavoriteNopersonHintView alloc] initWithFrame:CGRectMake(0, 60, TPScreenWidth(), 200)];
    [hintGroup setSkinStyleWithHost:self forStyle:@"noGroupmemberHint_style"];
    self.hintViewGroup = hintGroup;
    self.hintViewGroup.hidden = YES;
    [self.view addSubview:hintGroup];
    [hintViewGroup.fav_button setTitle:NSLocalizedString(@"Add members", @"") forState:UIControlStateNormal];
    [hintViewGroup.fav_button addTarget:self action:@selector(onClickAddMembersButton) forControlEvents:UIControlEventTouchUpInside];
    
    FavoriteNopersonHintView *hintUngroup = [[FavoriteNopersonHintView alloc] initWithFrame:CGRectMake(0, 60, TPScreenWidth(), 200)];
    [hintUngroup setSkinStyleWithHost:self forStyle:@"noGroupmemberHint_style"];
    self.hintViewUngroup = hintUngroup;
    hintViewUngroup.fav_button.hidden = YES;
    self.hintViewUngroup.hidden = YES;
    [self.view addSubview:hintUngroup];
    UILabel *hintLabelUngroup = [[UILabel alloc] initWithFrame:CGRectMake(0, 225, TPScreenWidth(), 35)];
    [hintLabelUngroup setSkinStyleWithHost:self forStyle:@"ungroupNocontactHintLabel_style"];
    [hintLabelUngroup setText:NSLocalizedString(@"All_contacts_grouped", @"")];
    hintLabelUngroup.textAlignment = NSTextAlignmentCenter;
    [hintViewUngroup addSubview:hintLabelUngroup];
    
    self.favArray = [[FavoriteModel Instance] getFavriteList];
    
    //set root bar connection
    //    RootScrollViewController *ctl = [((UINavigationController*)[[[UIApplication sharedApplication]delegate]window].rootViewController).viewControllers objectAtIndex:0];
    //    ctl.contactViewController = self;
    //add listener
    [TouchpalMembersManager addListener:self];
    
    
    CGRect guideFrame = CGRectMake(0, 0, TPScreenWidth(),
                                   TPScreenHeight() - TPHeaderBarHeight() - TAB_BAR_HEIGHT);
    self.guideViewWhenNoContact = [[ContactEmptyGuideView alloc] initWithFrame:guideFrame];
    self.guideViewWhenNoContact.hidden = YES;
    [self.view addSubview:guideViewWhenNoContact];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeSkinTheme) name:N_SKIN_DID_CHANGE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tabelViewReload) name:N_REFRESH_TOUCHPAL_NODE_ALERT object:nil];
}

- (void)changeSkinTheme
{
    self.view.backgroundColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"defaultBackground_color"];
    
}

- (void)viewDidLoad
{
    cootek_log(@"AllViewController->viewDidLoad");
    if (needCheck) {
        search_result_controller.m_tableview.hidden = YES;
    } else {
        searchResultView.hidden = YES;
    }
    [super viewDidLoad];
    longGestureController_ = [[LongGestureController alloc] initWithViewController:((TouchPalDialerAppDelegate *)[[UIApplication sharedApplication] delegate]).activeNavigationController
                                                                         tableView:all_content_view
                                                                          delegate:self
                                                                     supportedType:LongGestureSupportedTypeAllContact];
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureHandler:)];
    recognizer.delegate = self;
    [all_content_view addGestureRecognizer:recognizer];
    
    section_index_view.hidden = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onContactDataChanged) name:N_SYSTEM_CONTACT_DATA_CHANGED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onContactDataChanged) name:N_PERSON_DATA_CHANGED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onContactDataChanged) name:N_FAVORITE_DATA_DELETE_ID object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onContactDataChanged) name:N_FAVORITE_DATA_CHANGED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showContactDetail:) name:N_FAV_TO_PERSON_DETAIL object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchDidFinish:) name:N_CONTACT_SEARCH_RESULT_CHANGED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchBarChangeBegin) name:N_REFRESH_CONTACT_DATA_BEGIN object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchBarChangeEnd) name:N_REFRESH_CONTACT_DATA_END object:nil];
    //for long press
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeCellIdentifier) name:N_SKIN_DID_CHANGE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cancelSearch) name:N_ONCLICK_FILTER_BEGINS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeFilterDisplayTitle:) name:N_FILTER_CONTACT_NUMBER_CHANGED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resignKeyboard) name:N_STARTING_SCROLLING object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cancelSearch) name:N_STARTING_SCROLLING object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onContactDataChanged) name:N_REFRESH_IS_VOIP_ON object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onContactDataChanged) name:N_REFRESH_ALL_VIEW_CONTROLLER object:nil];
    
    
}

-(NSMutableArray *)personArray{
    
    if (_personArray== nil){
        self.personArray =[NSMutableArray arrayWithCapacity:0];
    }
    return _personArray;
}

- (void)onContactDataChanged
{
    if ([NSThread isMainThread]) {
        [self refresh];
    } else {
        dispatch_sync(dispatch_get_main_queue(), ^(){
            [self refresh];
        });
    }
}

- (void)searchBarChangeBegin
{
    if (!needCheck){
        cootek_log(@"begin refresh data>>>>>>>>>");
        m_searchbar.userInteractionEnabled = NO;
        m_searchbar.text=@"";
        m_searchbar.placeholder=NSLocalizedString(@"Reindexing contacts....", @"");
    }
}

- (void)searchBarChangeEnd
{
    if (!needCheck) {
        cootek_log(@"end refresh data>>>>>>>>>");
        m_searchbar.userInteractionEnabled = YES;
        m_searchbar.placeholder=@"";
        [self updateSearchBarPlaceholder];
    }
}

- (void)showContactDetail:(NSNotification *)notification {
    NSDictionary *info_dic = [notification userInfo];
    int person_id = [[info_dic objectForKey:@"fav_person_id"] intValue];
    if (person_id > 0) {
        [[ContactInfoManager instance] showContactInfoByPersonId:person_id];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    cootek_log(@"==TAB== Contact all view will appear., self.view.hidden: %d", self.view.hidden);
    [clear_view removeFromSuperview];
    [super viewWillAppear:animated];
}

- (void)updateSearchBarPlaceholder
{
    // show contact count
    int allContactCount = [[[ContactCacheDataManager instance] getAllCacheContact] count];
    NSString *contactCountString = nil;
    if (allContactCount <= 0) {
        contactCountString = @"";
    } else if (1 == allContactCount) {
        contactCountString = NSLocalizedString(@"search in 1 contact", @"Search | 1 contact");
    } else {
        contactCountString = [NSString stringWithFormat:NSLocalizedString(@"search in %d contacts", @"search in %d contacts"), allContactCount];
    }
    self.m_searchbar.placeholder = contactCountString;
}

- (void)refresh
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[ContactModelNew getSharedContactModel] buildAZtoAllContacts];
        dispatch_sync(dispatch_get_main_queue(), ^{
            self.favArray = [[FavoriteModel Instance] getFavriteList];
            cootek_log(@"get notification: all contacts reloaded");
            [self updateSearchBarPlaceholder];
            cootek_log(@"all_content_view reload data start");
            [self tabelViewReload];
            cootek_log(@"all_content_view reload data end");
            [self buildSectionIndexView];
        });
    });
}

- (void)buildSectionIndexView {
    NSArray *marr = [NSArray arrayWithObjects:@"♡", @"#", @"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", @"*", nil];
    NSMutableDictionary *section_navigate_dic = [NSMutableDictionary dictionaryWithCapacity:[marr count]];
    int section = -1;
    for (int i = 0; i < [marr count]; i++) {
        if(!self.loadDataFromFilter){
            if ([allContactKeys indexOfObject:[marr objectAtIndex:i]] != NSNotFound) {
                section++;
            }
        }else{
            if ([self.sectionKeysFromFilter indexOfObject:[marr objectAtIndex:i]] != NSNotFound) {
                section++;
            }
        }
        NSString *content = [marr objectAtIndex:i];
        [section_navigate_dic setObject:[NSNumber numberWithInt:(section == -1 ? 0 : section)] forKey:content];
    }
    self.section_map = section_navigate_dic;
    
    BOOL isDataEmpty = (section == -1);
    section_index_view.hidden = isDataEmpty;
    self.guideViewWhenNoContact.hidden = (self.leafNodeFromFilter != nil || !isDataEmpty);
    self.m_searchbar.hidden = isDataEmpty;
}


- (void)refreshView
{
    self.favArray = [[FavoriteModel Instance] getFavriteList];
    [self updateSearchBarPlaceholder];
    [self tabelViewReload];
    [self buildSectionIndexView];
    if ( needCheck )
        [searchResultView refreshView];
    else
        [search_result_controller refreshView];
}

- (void)clearSectionIndexView
{
    [section_index_view clear];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    cootek_log(@"Received memory warning in AllViewController.");
}

- (void)dealloc
{
    
    for (UITapGestureRecognizer *gesture in [all_content_view gestureRecognizers]) {
        [all_content_view removeGestureRecognizer:gesture];
    }
    [longGestureController_ tearDown];
    [SkinHandler removeRecursively:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark TouchpalsChangeDelegate
- (void)onTouchpalChanges{
    [self onContactDataChanged];
}

#pragma mark tableView delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    int numberOfSections = loadDataFromFilter ? [self.sectionKeysFromFilter count] : [allContactKeys count];
    return numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int numberOfRows;
    if(!loadDataFromFilter){
        if ([self.favArray count] != 0 && section == 0) {
            return 1;
        } else {
            numberOfRows = [[allContacts objectForKey:[allContactKeys objectAtIndex:section]] count];
        }
    }else{
        numberOfRows = [[self.contactsFromFilter objectForKey:[self.sectionKeysFromFilter objectAtIndex:section]] count];
    }
    return numberOfRows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int favCount = [self.favArray count];
    int height = 0;
    if (favCount != 0 && [indexPath section] == 0 && !loadDataFromFilter) {
        height = [self heightForFav: favCount];
    } else {
        height = CONTACT_CELL_HEIGHT;
    }
    if ([longGestureController_ inLongGestureMode] && [longGestureController_.currentSelectIndexPath compare:indexPath] == NSOrderedSame) {
        return height + CONTACT_CELL_HEIGHT;
    } else {
        return height;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if ( [self ifSpecialKey:section] ){
        return 0;
    }
    return CONTACT_CELL_SECTION_HEADER_HEIGHT;
}

- (BOOL)ifSpecialKey:(NSInteger)section{
    if(!loadDataFromFilter){
        NSString *key = [allContactKeys objectAtIndex:section];
        if ( [key isEqualToString:@"special"] ){
            return YES;
        }
    }
    return NO;
}

- (CGFloat)heightForFav: (int) favCount
{
    CGFloat itemHeight = FAV_ROW_MARGIN_TOP + FAV_ICON_LENGTH + FAV_ICON_TEXT_GAP + FAV_TEXT_HEIGHT;
    return ((favCount - 1) / FAV_ROW_COUNT + 1) * itemHeight + FAV_ROW_MARGIN_BOTTOM;
}

- (void)favPersonPressed:(UIButton *)btn
{
    if ([longGestureController_ inLongGestureMode]) {
        [longGestureController_ exitLongGestureMode];
    }
    [m_searchbar resignFirstResponder];
    [self updateSearchBarPlaceholder];
    ContactCacheDataModel *person = [[ContactCacheDataManager instance] contactCacheItem:btn.tag];
    if (person) {
        FavoriteDataModel *favorite=[[FavoriteDataModel alloc] init];
        favorite.personID = btn.tag;
        favorite.personName = [person displayName];
        favorite.photoData = [person image];
        favorite.mainPhone = [person mainPhone];
        OperationScrollView *scroll = [[OperationScrollView alloc]  initWithPersonID:favorite withArray:person.phones];
        UIWindow *currentWindow = [[UIApplication sharedApplication].windows objectAtIndex:0];
        [currentWindow addSubview:scroll];
        [currentWindow bringSubviewToFront:scroll];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int section = [indexPath section];
    int row = [indexPath row];
    
    if ([self.favArray count] != 0 && section == 0 && !loadDataFromFilter) {
        // fav contacts list
        
        UITableViewCell *fCell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, TPScreenWidth(), 100)];
        CGFloat x = 0;
        CGFloat y = 0;
        NSInteger favSize = self.favArray.count;
        for (NSInteger count = 0;  count < favSize; count++) {
            FavoriteDataModel *m = self.favArray[count];
            
            // row positioning
            if (count % FAV_ROW_COUNT == 0) {
                x = CONTACT_CELL_LEFT_GAP;
                if (count == 0) {
                    y += FAV_ROW_MARGIN_TOP;
                } else {
                    y += FAV_ROW_MARGIN_BOTTOM + FAV_ICON_LENGTH + FAV_ICON_TEXT_GAP + FAV_TEXT_HEIGHT;
                }
            } else {
                x += FAV_ICON_GAP;
            }
            
            // photo button
            UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(x, y, FAV_ICON_LENGTH, FAV_ICON_LENGTH)];
            btn.tag = m.personID;
            btn.clipsToBounds = YES;
            btn.layer.cornerRadius = FAV_ICON_LENGTH / 2;
            btn.layer.borderColor = [TPDialerResourceManager getColorForStyle:@"tp_color_black_transparency_100"].CGColor;
            btn.layer.borderWidth = 0.5;
            [btn addTarget:self action:@selector(favPersonPressed:) forControlEvents:UIControlEventTouchUpInside];
            UIImage *photo = m.photoData;
            if (m.photoData == nil) {
                photo = [[TPDialerResourceManager sharedManager] getImageByName:@"fav_unknow_person_photo@2x.png"];
                
            } else {
                [btn setImage:[FunctionUtility getGradientImageFromStartColor:[UIColor clearColor] endColor:[[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"blackWith_0.2_alpha_color"] forSize:CGSizeMake(FAV_ICON_LENGTH, FAV_ICON_LENGTH)] forState:UIControlStateNormal];
                btn.imageEdgeInsets = UIEdgeInsetsMake(FAV_ICON_LENGTH/2, 0, 0, 0);
            }
            ContactCacheDataModel *cachedModel = [[ContactCacheDataManager instance] contactCacheItem:m.personID];
            BOOL isRegisterd = [TouchpalMembersManager isRegisteredByContactCachedModel:cachedModel];
            btn.backgroundColor = [FunctionUtility getPersonDefaultColorByPersonId:isRegisterd];
            [btn setBackgroundImage:photo forState:UIControlStateNormal];
            
            // description text
            UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(
                                                                           x, y + FAV_ICON_LENGTH + FAV_ICON_TEXT_GAP,
                                                                           FAV_ICON_LENGTH, FAV_TEXT_HEIGHT)];
            nameLabel.backgroundColor = [UIColor clearColor];
            nameLabel.font = [UIFont systemFontOfSize:14];
            nameLabel.text = m.personName;
            nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
            nameLabel.textAlignment = NSTextAlignmentCenter;
            nameLabel.textColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"person_head_char_color"];
            
            // view tree
            [fCell addSubview:btn];
            [fCell addSubview:nameLabel];
            
            x += FAV_ICON_LENGTH;
        }
        fCell.backgroundColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"fav_area_bg_color"];
        fCell.selectionStyle = UITableViewCellSelectionStyleNone;
        CGFloat lineHeight = 0.5;
        CGFloat cellHeight = [self heightForFav:[self.favArray count]];
        UIColor *lineColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"baseContactCell_downSeparateLine_color"];
        UILabel *bottomLine = [[UILabel alloc]initWithFrame:CGRectMake(
                                                                       CONTACT_CELL_MARGIN_LEFT, cellHeight - lineHeight,
                                                                       TPScreenWidth() - CONTACT_CELL_MARGIN_LEFT - INDEX_SECTION_VIEW_WIDTH, lineHeight)];
        bottomLine.backgroundColor = lineColor;
        
        // view tree
        [fCell addSubview:bottomLine];
        
        return fCell;
    }
    else if ( [self ifSpecialKey:section] ) {
        // special cell
        
        NSString *specialIdentifier = @"special_contact";
        ContactSpecialCell *cell = [tableView dequeueReusableCellWithIdentifier:specialIdentifier];
        ContactSpecialInfo *info = nil;
        if(!loadDataFromFilter){
            info = [[allContacts objectForKey:[allContactKeys objectAtIndex:section]] objectAtIndex:row];
        }
        if ( cell == nil ){
            cell = [[ContactSpecialCell alloc]initWithStyle:UITableViewCellStyleDefault
                                            reuseIdentifier:specialIdentifier
                                                   delegate:self
                                         contactSpecialInfo:info];
            [cell setSkinStyleWithHost:self forStyle:@"ContactItemCell_style"];
        }else{
            [cell setData:info];
        }
        if ( info == nil || self.leafNodeFromFilter == nil ){
            cell.hidden = NO;
        }else{
            cell.hidden = YES;
        }
        //
        if ((int)[indexPath row]+1 == (int)[all_content_view numberOfRowsInSection:[indexPath section]]) {
            [cell hideBottomLine];
        } else {
            [cell showBottomLine];
        }
        
        cell.backgroundColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"defaultCellBackground_color"];
        return cell;
        
    } else {
        // contact item cell
        
        ContactCacheDataModel* cachePersonData;
        if(!loadDataFromFilter){
            cachePersonData = (ContactCacheDataModel *)([[allContacts objectForKey:[allContactKeys objectAtIndex:section]] objectAtIndex:row]);
            
        }else{
            cachePersonData = (ContactCacheDataModel *)([[self.contactsFromFilter objectForKey:[self.sectionKeysFromFilter objectAtIndex:section]] objectAtIndex:row]);
            
        }
        ContactItemCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[ContactItemCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:CellIdentifier
                                                 personId:cachePersonData.personID
                                          isRequiredCheck:needCheck
                                             withDelegate:self
                                                     size:CGSizeMake(TPScreenWidth()-24, CONTACT_CELL_HEIGHT)];
            [cell setSkinStyleWithHost:self forStyle:@"ContactItemCell_style"];
        } else {
            cell.operView.hidden = YES;
            [cell hidePartBLine];
            [cell setSkinStyleWithHost:self forStyle:@"ContactItemCell_style"];
        }
        
        if ((int)[indexPath row]+1 == (int)[all_content_view numberOfRowsInSection:[indexPath section]]) {
            [cell hidePartBLine];
        } else {
            [cell showPartBLine];
        }
        
        if ( [longGestureController_ inLongGestureMode] && [longGestureController_.currentSelectIndexPath compare: indexPath] == NSOrderedSame) {
            
            [cell.operView addSubview:longGestureController_.operView.bottomView];
            [cell hidePartBLine];
            cell.operView.hidden = NO;
            [cell showAnimation];
            self.longModeCell = cell;
        }
        
        TPUIButton *photoButton = (TPUIButton *)[cell viewWithTag:PHOTO_BUTTON_TAG];
        if (!photoButton){
            photoButton = [[TPUIButton alloc] initWithFrame:CGRectMake(0, 0, CONTACT_CELL_HEIGHT, 50)];
            photoButton.backgroundColor = [UIColor clearColor];
            [cell addSubview:photoButton];
            photoButton.tag = PHOTO_BUTTON_TAG;
            [photoButton addTarget:self action:@selector(showOperView:) forControlEvents:UIControlEventTouchUpInside];
        }
        photoButton.titleLabel.text =  [NSString stringWithFormat:@"%ld:%ld", (long)indexPath.section, (long)indexPath.row];
        
        
        [(ContactItemCell *)cell setMemberCellDataWithCacheItemData:cachePersonData displayType:displayType_];
        cell.is_checked = cell.person_data.isChecked;
        [cell updateCheckStatus:cell.person_data.isChecked];
        
        cell.backgroundColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"defaultCellBackground_color"];
        return cell;
    }
}

- (void)showOperView:(UIButton *)sender {
    if ([longGestureController_ inLongGestureMode]) {
        [longGestureController_ exitLongGestureMode];
    } else {
        NSArray *tmp = [sender.titleLabel.text componentsSeparatedByString:@":"];
        NSIndexPath *currentIndex = [NSIndexPath indexPathForRow:[tmp[1] integerValue] inSection:[tmp[0] integerValue]];
        NSArray *indexPathArray = [all_content_view indexPathsForVisibleRows];
        for (int i = [indexPathArray count]-1; i >= [indexPathArray count]-2; i --) {
            if ([currentIndex compare:indexPathArray[i]] == NSOrderedSame) {
                longGestureController_.showScrollToShow = YES;
                break;
            }
        }
        longGestureController_.currentSelectIndexPath = currentIndex;
        [longGestureController_ enterLongGestureMode];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGRect holderFrame = CGRectMake(0, 0,
                                    tableView.frame.size.width - INDEX_SECTION_VIEW_WIDTH, CONTACT_CELL_SECTION_HEADER_HEIGHT);
    UIView *holderView = [[UIView alloc] initWithFrame:holderFrame];
    holderView.backgroundColor = [UIColor clearColor];
    
    UIView* headerView = [[UIView alloc] initWithFrame:holderFrame];
    [headerView setBackgroundColor:[[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"contactCellHeaderBG_color"]];
    
    UILabel *mlabel = [[UILabel alloc] initWithFrame:CGRectMake(CONTACT_CELL_LEFT_GAP, 0, TPScreenWidth(), CONTACT_CELL_SECTION_HEADER_HEIGHT)];
    mlabel.font = [UIFont systemFontOfSize:13];
    mlabel.backgroundColor = [UIColor clearColor];
    
    CGFloat lineHeight = 0.5;
    UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(CONTACT_CELL_LEFT_GAP, mlabel.frame.size.height - lineHeight, TPScreenWidth()-24-CONTACT_CELL_LEFT_GAP, lineHeight)];
    
    if(!loadDataFromFilter){
        if (section == 0 && [self.favArray count]!= 0) {
            mlabel.text = NSLocalizedString(@"My favorites", @"");
            lineLabel.backgroundColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"contactCellFavSectionHeader_color"];
            mlabel.textColor =[[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"contactCellFavSectionHeader_color"];
        } else {
            mlabel.text = [allContactKeys objectAtIndex:section];
            lineLabel.backgroundColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"contactCellSectionHeader_color"];
            mlabel.textColor =[[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"contactCellSectionHeader_color"];
        }
    }else{
        mlabel.text = [self.sectionKeysFromFilter objectAtIndex:section];
        lineLabel.backgroundColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"contactCellSectionHeader_color"];
        mlabel.textColor =[[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"contactCellSectionHeader_color"];
    }
    [headerView addSubview:mlabel];
    // work-around: the outmost parent view will be stretched to match the width of the table view;
    [holderView addSubview:headerView];
    
    return holderView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(![longGestureController_ inLongGestureMode]) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    } else {
        [longGestureController_ exitLongGestureMode];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ([longGestureController_ inLongGestureMode]) {
        [longGestureController_ exitLongGestureMode];
    }
    [m_searchbar resignFirstResponder];
    [self updateSearchBarPlaceholder];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewWrapperView"]) {
        return YES;
    }
    return  NO;
}

- (void)tapGestureHandler:(UITapGestureRecognizer *)recognizer {
    
    if ([longGestureController_ inLongGestureMode]) {
        [longGestureController_ exitLongGestureMode];
    }
    
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [m_searchbar resignFirstResponder];
    [self updateSearchBarPlaceholder];
}

#pragma mark ContactSpecialCellDelegate
- (void)onButtonPressed: (SpecialNodeType)type{
    if ([longGestureController_ inLongGestureMode]) {
        [longGestureController_ exitLongGestureMode];
    }
    type = NODE_UNKOWN;
    switch (type) {
        case NODE_TOUCHPALER: {
            if ( ![UserDefaultsManager boolValueForKey:VOIP_FIRST_VISIT_TOUCHPAL_PAGE_WITH_ALERT] ){
                [UserDefaultsManager setBoolValue:YES forKey:VOIP_FIRST_VISIT_TOUCHPAL_PAGE_WITH_ALERT];
                [[NSNotificationCenter defaultCenter] postNotificationName:N_REFRESH_TOUCHPAL_NODE_ALERT object:nil];
            }
            if (![UserDefaultsManager boolValueForKey:@"clickTouchpalViewController"]) {
                [all_content_view reloadData];
                [UserDefaultsManager setBoolValue:YES forKey:@"clickTouchpalViewController"];
            }
            ContactTouchpalViewController *con = [[ContactTouchpalViewController alloc]init];
            [[TouchPalDialerAppDelegate naviController] pushViewController:con animated:YES];
            break;
        }
            
        case NODE_CONTACT_TRANSFER: {
            UIViewController *controller = nil;
            if ([UserDefaultsManager boolValueForKey:CONTACT_TRANSFER_GUIDE_CLICKED defaultValue:NO]) {
                controller = [[ContactTransferMainController alloc] init];
            } else {
                controller = [[ContactTransferGuideController alloc] init];
            }
            if (controller) {
                [[TouchPalDialerAppDelegate naviController] pushViewController:controller animated:YES];
            }
            [DialerUsageRecord recordpath:PATH_CONTACT_TRANSFER
                                      kvs:Pair(CONTACT_TRANSFER_ENTRANCE_CLICK, @(1)), nil];
            break;
        }
        case NODE_CONTACT_SMART_GROUP: {
            ContactViewController *contactController =  (ContactViewController *)(self.parentViewController1);
            if ([contactController canPerformAction:@selector(onClickContactsFilter) withSender:nil]) {
                [contactController performSelectorOnMainThread:@selector(onClickContactsFilter) withObject:nil waitUntilDone:YES];
            }
            break;
        }
        case NODE_CONTACT_INVITE:{
            
            HandlerWebViewController *webVC = [[HandlerWebViewController alloc] init];
            NSString *url =  USE_DEBUG_SERVER ? TEST_INVITE_REWARDS_WEB : INVITE_REWARDS_WEB;
            webVC.url_string = [url stringByAppendingString:@"?share_from=PersonalCenter"];
            webVC.header_title = NSLocalizedString(@"invite_friends", @"邀请有奖");
            [[TouchPalDialerAppDelegate naviController] pushViewController:webVC animated:YES];
            
            [DialerUsageRecord recordpath:PATH_INVITE_PAGE kvs:Pair(@"invite_page_from", @(1)), nil];
            break;
        }
        case NODE_UNKOWN:
        default: {
            break;
        }
    }
}


#pragma mark SelectViewProtocalDelegate
-(void)selectItem:(SelectModel *)select_item withObject:(id)object{
    
}
-(void)selectItem:(SelectModel *)select_item {
    ContactCacheDataModel* cachePersonData;
    NSDictionary* tmpDiction;
    if(!loadDataFromFilter){
        tmpDiction = allContacts;
    }else{
        tmpDiction =self.contactsFromFilter;
    }
    
    for (NSArray * personSet in [tmpDiction allValues]) {
        for (NSObject * personData in personSet) {
            cachePersonData = (ContactCacheDataModel *)personData;
            if (cachePersonData.personID == select_item.personID) {
                cachePersonData.isChecked = !(cachePersonData.isChecked);
            }
        }
    }
    
}

-(BOOL)isSelectedPerson:(NSInteger)personID withObject:(id)object
{
    return NO;
}

- (BOOL)isSelectedPerson:(NSInteger)personID
{
    ContactCacheDataModel* cachePersonData;
    NSDictionary* tmpDiction;
    if(!loadDataFromFilter){
        tmpDiction = allContacts;
        
    }else{
        tmpDiction =self.contactsFromFilter;
    }
    
    for (NSArray * personSet in [tmpDiction allValues]) {
        for (NSObject * personData in personSet) {
            cachePersonData = (ContactCacheDataModel *)personData;
            if (cachePersonData.personID == personID) {
                if (cachePersonData.isChecked == YES) {
                    return YES;
                } else {
                    return NO;
                }
            }
        }
    }
    return NO;
}
-(void)cancelInput{
    [m_searchbar resignFirstResponder];
    [self updateSearchBarPlaceholder];
}



#pragma mark searchbar delegate methods.
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    if (all_content_view && all_content_view.isDecelerating) {
        NSIndexPath *indexPath = [all_content_view indexPathForRowAtPoint:[all_content_view contentOffset]];
        [all_content_view scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
    if([longGestureController_ inLongGestureMode])
    {
        [longGestureController_ exitLongGestureMode];
    }
    m_searchbar.placeholder = NSLocalizedString(@"search prompt", @"search prompt");
    [m_searchbar showBorder];
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    [m_searchbar hideBorder];
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [m_searchbar resignFirstResponder];
    [self updateSearchBarPlaceholder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    searchText = [NSString nilToEmptyTrimmed:searchText];
    if (searchText == nil || [searchText length] == 0 || [searchText length] > SEARCH_INPUT_MAX_LENGTH) {
        if (needCheck) {
            [searchResultView refreshMyResult:nil];
            [searchResultView removeFromSuperview];
        } else {
            [search_result_controller refreshMyResult:nil];
            [search_result_controller.view removeFromSuperview];
        }
    } else {
        [search_engine query:searchText];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [m_searchbar resignFirstResponder];
    [self updateSearchBarPlaceholder];
    m_searchbar.text = @"";
    if (needCheck) {
        [searchResultView refreshMyResult:nil];
        [searchResultView removeFromSuperview];
    } else {
        [search_result_controller refreshMyResult:nil];
        [search_result_controller.view removeFromSuperview];
    }
}

#pragma mark ContactItemCellProtocol delegate
- (void)clickCell:(UITableViewCell*)cell
{
    [m_searchbar resignFirstResponder];
    [self updateSearchBarPlaceholder];
    if(![longGestureController_ inLongGestureMode]) {
        NSIndexPath* indexPath = [(UITableView*)(all_content_view) indexPathForCell:cell];
        int section = [indexPath section];
        int rowIndex = [indexPath row];
        id personData;
        NSInteger person_id ;
        if(!loadDataFromFilter){
            personData = [[allContacts objectForKey:[allContactKeys objectAtIndex:section]] objectAtIndex:rowIndex];
            person_id = ((ContactCacheDataModel *)personData).personID;
        }else{
            personData = [[self.contactsFromFilter objectForKey:[self.sectionKeysFromFilter objectAtIndex:section]] objectAtIndex:rowIndex];
            person_id = ((ContactCacheDataModel *)personData).personID;
        }
        
        if (person_id > 0) {
            [[ContactInfoManager instance] showContactInfoByPersonId:person_id];
        }
        
        [self tableView:all_content_view didSelectRowAtIndexPath:indexPath];
    } else {
        [longGestureController_ exitLongGestureMode];
    }
}


#pragma mark -
#pragma mark SearchResultViewDelegate
- (void)resignKeyboard
{
    [m_searchbar resignFirstResponder];
    [self updateSearchBarPlaceholder];
}


#pragma mark -
#pragma mark SectionIndexDelegate

- (void)addClearView
{
    [clear_view setSkinStyleWithHost:self forStyle:@"ClearViewBackground_color"];
    clear_view.alpha = 0.8;
    clear_view.layer.masksToBounds = YES;
    clear_view.layer.cornerRadius = clear_view.frame.size.width / 2 ;
    [self.view addSubview:clear_view];
}

- (void)move:(double)top
{
    clear_view.frame = CGRectMake(clear_view.frame.origin.x, top,clear_view.frame.size.width , clear_view.frame.size.height);
}

- (void)beginNavigateSection:(NSString *)section_key
{
    [m_searchbar resignFirstResponder];
    [self updateSearchBarPlaceholder];
    if (0 == [allContactKeys count] && self.sectionKeysFromFilter.count==0) {
        return;
    }
    NSInteger section_number = [[section_map objectForKey:section_key]integerValue];
    if([all_content_view numberOfSections] ==0)
        return;
    BOOL ifHasFav = [allContactKeys containsObject:@"♡"];
    if ( [section_key isEqualToString:@"♡"] && !ifHasFav )
        return;
    BOOL ifHasSpecial = [allContactKeys containsObject:@"special"];
    if ( ifHasSpecial && ![section_key isEqualToString:@"♡"] ) {
        // fix-bug: the app will crash when scrolling to the bottom of the index bar
        int sectionSize = loadDataFromFilter ? [self.sectionKeysFromFilter count] : [allContactKeys count];
        if (section_number < sectionSize - 1) {
            // why should increase by 1?
            section_number = section_number + 1;
        }
    }
    int rows = [all_content_view numberOfRowsInSection:section_number];
    if (rows >1 ) {
        if(!loadDataFromFilter){
            NSIndexPath *mpath = [NSIndexPath indexPathForRow:0 inSection:section_number];
            [all_content_view scrollToRowAtIndexPath:mpath atScrollPosition:UITableViewScrollPositionTop animated:NO];
            [clear_view setSectionKey:[allContactKeys objectAtIndex:section_number]];
        }else{
            NSIndexPath *mpath = [NSIndexPath indexPathForRow:0 inSection:section_number];
            [all_content_view scrollToRowAtIndexPath:mpath atScrollPosition:UITableViewScrollPositionTop animated:NO];
            [clear_view setSectionKey:[self.sectionKeysFromFilter objectAtIndex:section_number]];
        }
    }
}

- (void)endNavigateSection
{
    [clear_view removeFromSuperview];
}

- (NSString *)trimmedSearchText
{
    return [NSString nilToEmptyTrimmed:m_searchbar.text];
}

#pragma mark -
#pragma mark click button action
- (void)cancelSearch
{
    [m_searchbar resignFirstResponder];
    [self updateSearchBarPlaceholder];
    m_searchbar.text = @"";
    if ([search_result_controller isViewLoaded]) {
        [search_result_controller refreshMyResult:nil];
        [search_result_controller.view removeFromSuperview];
    }
}

- (void)searchDidFinish:(id)tmpArray
{
    if (needCheck) {
        SearchResultModel *searchResult = [[tmpArray userInfo] objectForKey:KEY_RESULT_LIST_CHANGED];
        if ([m_searchbar.text length] == 0 ||
            ![m_searchbar.text isEqualToString:searchResult.searchKey]){
            return;
        }
        cootek_log(@"sresult array count is = %d,=%@", [searchResult.searchResults count],searchResult.searchKey);
        if (![searchResultView isDescendantOfView:self.view])
        {
            [self.view addSubview:searchResultView];
        }
        [searchResultView refreshMyResult:searchResult];
    } else {
        if([longGestureController_ inLongGestureMode]) {
            [longGestureController_ exitLongGestureMode];
        }
        
        SearchResultModel *result_arr = [[tmpArray userInfo] objectForKey:KEY_RESULT_LIST_CHANGED];
        if ([[self trimmedSearchText] length] == 0 ||
            result_arr.searchType != ContactSearch ||
            ![[self trimmedSearchText] isEqualToString:result_arr.searchKey]) {
            return;
        }
        if (![search_result_controller.view isDescendantOfView:self.view]) {
            [self.view addSubview:search_result_controller.view];
        }
        [search_result_controller refreshMyResult:result_arr];
    }
}

#pragma mark SearchResultViewDelegate
- (void)research
{
    if ([FunctionUtility isNilOrEmptyString:[self trimmedSearchText]]) {
        return;
    }
    if ([search_result_controller.view isDescendantOfView:self.view]) {
        // search
        [search_engine query:[self trimmedSearchText]];
    }
}

#pragma  mark Enter_or_exit_multiselect_mode
- (void)enterLongGestureMode
{
    if (longGestureController_.showScrollToShow) {
        longGestureController_.showScrollToShow = NO;
        [all_content_view scrollToRowAtIndexPath:longGestureController_.currentSelectIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    section_index_view.hidden = YES;
    [self tabelViewReload];
    [self resignKeyboard];
}

- (void)exitLongGestureMode
{
    [self.longModeCell exitAnimation];
    section_index_view.hidden = NO;
    [self tabelViewReload];
    //    [self refresh];
}

- (void)changeCellIdentifier
{
    self.CellIdentifier = [NSString stringWithFormat:@"%d",((NSInteger)arc4random())];
    search_result_controller.CellIdentifier = self.CellIdentifier;
    [self tabelViewReload];
    if(!contactsDisplayViewWithNoAZScrollist.hidden){
        [contactsDisplayViewWithNoAZScrollist reloadTable];
    }
    if([self trimmedSearchText].length>0){
        [search_result_controller.m_tableview reloadData];
    }
}

-(void)scrollToDismissFavort{
    [self.all_content_view scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionTop animated:YES];
    CGFloat  height = 0;
    if ([self.favArray count]> 0) {
        height=[self heightForFav:[self.favArray count]]+23;
    }
    self.all_content_view.contentOffset = CGPointMake(0, height);
}

- (void) setBackButtonHidden:(BOOL) hideBack {
    ContactViewController *contactController = (ContactViewController *)self.parentViewController1;
    contactController.backButton.hidden = hideBack;
    contactController.editButton.hidden = !hideBack;
}


- (void)refreshTableWithSelectedNodeWithoutRestore:(LeafNodeWithContactIds *)node{
    self.leafNodeFromFilter = node;
    typeof(self) weakSelf = self ;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        weakSelf.personArray =nil;
        for (NSNumber *personID in weakSelf.leafNodeFromFilter.contactIds) {
            ContactCacheDataModel *tmpPerson = [[ContactCacheDataManager instance] contactCacheItem:[personID intValue]];
            if (tmpPerson) {
                [weakSelf.personArray addObject:tmpPerson];
            }
        }
    });
    DisplayRequirementsForFilter *displayRequirements = [self changeNodeToDisplayRequirements:node];
    if(displayRequirements==nil || displayRequirements.datas==nil){
        [self backToAllViewController];
        hintViewGroup.hidden = YES;
        hintViewUngroup.hidden = YES;
        return;
    }
    
    [self setBackButtonHidden:NO]; // we need back button
    
    self.displayRequirementsForFilter = displayRequirements;
    [self prepareTheHeaderBarDisplayForFilterWithDisplayRequireMents:displayRequirements];
    
    if(displayRequirements.needAZScrollist){
        contactsDisplayViewWithNoAZScrollist.hidden = YES;
        //prepare data
        self.contactIDsFromFilter = displayRequirements.datas;
        self.loadDataFromFilter = YES;
        NSMutableArray *contactKeys = [[NSMutableArray alloc] initWithCapacity:28];
        NSMutableDictionary *contactContainers = [[NSMutableDictionary alloc] initWithCapacity:26];
        [ContactModelNew buildIndexArray:displayRequirements.datas toNewContactsContainer:contactContainers andKeyContainers:contactKeys];
        //delete special cell 
//        self.contactsFromFilter = contactContainers;
//        self.sectionKeysFromFilter = contactKeys;
        
        //display data
        if(displayRequirements.needDisplayNote){
            self.displayType = DisplayTypeNote;
        }else{
            self.displayType = DisplayTypeDefault;
        }
        [self arrangeAllViewControllerToDisplayFilterContent];
    } else {
        //use another view to display noAZScroll
        [contactsDisplayViewWithNoAZScrollist refreshTableWithSelectedNode:node];
        contactsDisplayViewWithNoAZScrollist.hidden = NO;
        [section_index_view removeFromSuperview];
        //section_index_view.hidden = YES;
        filterDescriptionLabel_.hidden = NO;
        allButtonInFilterResultDisplayView.hidden = YES;
        [self hideHeaderBarAndAddButton:YES];
    }
    if ([leafNodeFromFilter isKindOfClass:[GroupNode class]]) {
        if (((GroupNode *)leafNodeFromFilter).groupID != UNGROUPED_GROUP_ID) {
            hintViewGroup.hidden = [self haveContacts];
            hintViewUngroup.hidden = YES;
        } else {
            hintViewGroup.hidden = YES;
            hintViewUngroup.hidden = [self haveContacts];
        }
    } else {
        hintViewGroup.hidden = YES;
        hintViewUngroup.hidden = YES;
    }
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    cootek_log(@"calling_page, index_view: %@", NSStringFromCGRect(self.section_index_view.frame));
    cootek_log(@"calling_page, self.view: %@", NSStringFromCGRect(self.view.frame));
}

- (void)restoreViewLocation {
    [restoreViewLocationDelegate restoreViewLocation];
}

-(void)refreshTableWithSelectedNode:(LeafNodeWithContactIds *)node
{
    [self refreshTableWithSelectedNodeWithoutRestore:node];
    [restoreViewLocationDelegate restoreViewLocation];
}

- (void)arrangeAllViewControllerToDisplayFilterContent
{
    all_content_view.frame = CGRectMake(0, 0, TPScreenWidth(), TPHeightFit(365));
    [self tabelViewReload];
    [self addNewIndexSectionViewWithFrame:[self getRectOfSectionIndexView]];
    filterDescriptionLabel_.hidden = NO;
    self.m_searchbar.hidden = YES;
    allButtonInFilterResultDisplayView.hidden = YES;// here replaced by operation button
    [self hideHeaderBarAndAddButton:YES];
    [self.all_content_view setContentOffset:CGPointMake(0, 0) animated:NO];
}

- (void)backToAllViewController
{
    self.loadDataFromFilter = NO;
    //[self.leafNodeFromFilter removeObserverToDataChangedNofication];
    self.leafNodeFromFilter = nil;
    all_content_view.frame = CGRectMake(0, m_searchbar.frame.size.height, TPScreenWidth(), TPHeightFit(320));
    
    [self addNewIndexSectionViewWithFrame:[self getRectOfSectionIndexView]];
    
    filterDescriptionLabel_.hidden = YES;
    ((ContactViewController *)(self.parentViewController1)).titleBar.hidden = NO;
    if(allButtonInFilterResultDisplayView!=nil)
        allButtonInFilterResultDisplayView.hidden = YES;
    [self hideHeaderBarAndAddButton:NO];
    contactsDisplayViewWithNoAZScrollist.hidden = YES;
    self.displayType = DisplayTypeDefault;
    [self tabelViewReload];
    [[NSNotificationCenter defaultCenter] postNotificationName:N_CONTACT_BACK_TO_ALL object:nil];
    hintViewGroup.hidden = YES;
    hintViewUngroup.hidden = YES;
    [self setBackButtonHidden:YES]; // hide the back button, i.e. show the edit button
}

- (void)addNewIndexSectionViewWithFrame:(CGRect)frame
{
    [section_index_view removeFromSuperview];
    SectionIndexView *tmpsection_index_view = [[SectionIndexView alloc] initSectionIndexView:frame];
    self.section_index_view = tmpsection_index_view;
    [section_index_view setSkinStyleWithHost:self forStyle:DRAW_RECT_STYLE];
    section_index_view.delegate = self;
    [self.view addSubview:section_index_view];
    [self buildSectionIndexView];
    //[self onNotiPersonModelReloadedOnMainThread];
}

- (DisplayRequirementsForFilter *)changeNodeToDisplayRequirements:(LeafNodeWithContactIds *)node
{
    NSString * filterDescription = node.nodeDescription;
    if([node isKindOfClass:[LeafNodeWithContactIds class]]){
        LeafNodeWithContactIds *leafNodeItem = (LeafNodeWithContactIds *)node;
        DisplayRequirementsForFilter *displayRequirements = [DisplayRequirementsForFilter alloc];
        displayRequirements.datas = leafNodeItem.contactIds;
        displayRequirements.filterDescription = filterDescription;
        displayRequirements.needDisplayNote = [node.nodeDescription isEqualToString:NSLocalizedString(@"Note", @"")] ? YES : NO;
        displayRequirements.needAZScrollist = [node.nodeDescription isEqualToString:NSLocalizedString(@"Recently created", @"")] ? NO : YES;
        //[self.leafNodeFromFilter removeObserverToDataChangedNofication];
        //displayRequirements.needRefreshInFilterState = ![self.leafNodeFromFilter addObserverToDataChangedNotification];
        return displayRequirements;
    }
    return nil;
}

- (void)prepareTheHeaderBarDisplayForFilterWithDisplayRequireMents:(DisplayRequirementsForFilter *)displayRequirement
{
    if(filterDescriptionLabel_==nil){
        filterDescriptionLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(85,TPHeaderBarHeightDiff(),TPScreenWidth()-170,45)];
        [filterDescriptionLabel_ setSkinStyleWithHost:self.parentViewController1 forStyle:@"defaultUILabel_style"];
        filterDescriptionLabel_.lineBreakMode = NSLineBreakByTruncatingMiddle;
        filterDescriptionLabel_.textAlignment = NSTextAlignmentCenter;
        filterDescriptionLabel_.font = [UIFont systemFontOfSize:FONT_SIZE_2];
        [self.parentViewController1.view addSubview:filterDescriptionLabel_];
        ((ContactViewController *)(self.parentViewController1)).titleBar.hidden = YES;
        allButtonInFilterResultDisplayView = [[TPHeaderButton alloc] initRightBtnWithFrame:CGRectMake(TPScreenWidth()-50, 0, 50, 45)];
        [allButtonInFilterResultDisplayView setSkinStyleWithHost:self.parentViewController1 forStyle:@"defaultTPHeaderButton_style"];
        [allButtonInFilterResultDisplayView setTitle:NSLocalizedString(@"All", @"") forState:UIControlStateNormal];
        allButtonInFilterResultDisplayView.titleLabel.font = [UIFont systemFontOfSize:CELL_FONT_SMALL];
        [allButtonInFilterResultDisplayView addTarget:self action:@selector(backToAllViewController) forControlEvents:UIControlEventTouchUpInside];
        [self.parentViewController1.view addSubview:allButtonInFilterResultDisplayView];
        
    }
    
    if (![filterDescriptionLabel_.text isEqualToString:@"Contact"]) {
        ((ContactViewController *)(self.parentViewController1)).titleBar.hidden = YES;
    }
    
    StringNumberPair *title = [[StringNumberPair alloc] init];
    title.string = displayRequirement.filterDescription;
    title.number = displayRequirement.datas.count;
    self.filterDisplayTitle = title;
    filterDescriptionLabel_.text = title.stringNumberPair;
    //    ((ContactViewController *)(self.parentViewController1)).add_member_button.hidden = YES;
}

#pragma mark changeFilterDisplayTitle
-(void)changeFilterDisplayTitle:(NSNotification *)noti
{
    NSNumber *number = [noti object];
    self.filterDisplayTitle.number = [number intValue];
    filterDescriptionLabel_.text = self.filterDisplayTitle.stringNumberPair;
}

- (void)changeAllmemberChecked:(BOOL)state
{
    ContactCacheDataModel* cachePersonData;
    NSDictionary* tmpDiction;
    if(!loadDataFromFilter){
        tmpDiction = allContacts;
        
    }else{
        tmpDiction =self.contactsFromFilter;
    }
    
    for (NSArray * personSet in [tmpDiction allValues]) {
        for (NSObject * personData in personSet) {
            cachePersonData = (ContactCacheDataModel *)personData;
            cachePersonData.isChecked = state;
        }
    }
    [self refresh];
}

- (BOOL)allChecked
{
    BOOL allCheckedFlag = YES;
    ContactCacheDataModel* cachePersonData;
    NSDictionary* tmpDiction;
    if(!loadDataFromFilter){
        tmpDiction = allContacts;
        
    }else{
        tmpDiction =self.contactsFromFilter;
    }
    
    for (NSArray * personSet in [tmpDiction allValues]) {
        for (NSObject * personData in personSet) {
            cachePersonData = (ContactCacheDataModel *)personData;
            if (cachePersonData.isChecked == NO) {
                allCheckedFlag = NO;
            }
        }
    }
    return allCheckedFlag;
}

- (NSArray *)getAllCheckedPerson:(BOOL)needChecked
{
    NSMutableArray *checkedPerson = [[NSMutableArray alloc] initWithCapacity:0];
    ContactCacheDataModel* cachePersonData;
    NSDictionary* tmpDiction;
    if(!loadDataFromFilter){
        tmpDiction = allContacts;
        
    }else{
        tmpDiction =self.contactsFromFilter;
    }
    
    for (NSArray * personSet in [tmpDiction allValues]) {
        for (NSObject * personData in personSet) {
            cachePersonData = (ContactCacheDataModel *)personData;
            if (needChecked == YES) {
                if (cachePersonData.isChecked == YES) {
                    [checkedPerson addObject:cachePersonData];
                }
            } else {
                [checkedPerson addObject:cachePersonData];
            }
        }
    }
    
    return checkedPerson;
}

- (BOOL)haveContacts
{
    if(leafNodeFromFilter == nil){
        return (allContacts.count > 0);
    } else {
        return (leafNodeFromFilter.contactIds.count > 0);
    }
}

- (BOOL)havePhoneNumbers
{
    
    if (![self haveContacts]) {
        return NO;
    } else {
        if  (leafNodeFromFilter == nil) {
            for (NSArray *personList in [allContacts allValues]) {
                for (id tmpPerson in personList) {
                    if ([tmpPerson isKindOfClass:[ContactSpecialInfo class]]) {
                        break;
                    }
                    if ([tmpPerson isKindOfClass:[ContactCacheDataModel class]]) {
                        // tmpPerson may be a instance of ContactSpecialInfo which has no `phones` property
                        // referrence: [ContactModelNew buildIndexContacts:andIndexKeys:forPersonList:]
                        ContactCacheDataModel *person = (ContactCacheDataModel *)tmpPerson;
                        if (person && person.phones && person.phones.count > 0) {
                            return YES;
                        }
                    }
                }
            }
            return NO;
            
        } else {
            for (NSNumber *contactID in leafNodeFromFilter.contactIds) {
                NSArray *array = [Person getPhonesByRecordID:[contactID intValue]];
                if (contactID && array && array.count > 0) {
                    return YES;
                }
            }
            return NO;
        }
    }
}

- (void)restoreViewLocationWithNoChange
{
    [restoreViewLocationDelegate restoreViewLocation];
}

- (void)onClickAddMembersButton
{
    [[GroupOperationCommandCreator commandForType:CommandTypeGroupInclude withData:nil] onClickedWithPageNode:leafNodeFromFilter withPersonArray:self.personArray];
}

- (void)noFilter {
    [self backToAllViewController];
}

- (void)tabelViewReload {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *previousAllContacts = allContacts;
        allContacts = [[NSDictionary alloc]initWithDictionary:[ContactModelNew getSharedContactModel].all_contacts];
        allContactKeys = [[NSArray alloc]initWithArray:[ContactModelNew getSharedContactModel].all_contact_keys];
        [all_content_view reloadData];
        NSInteger insertedCount = [UserDefaultsManager intValueForKey:CONTACT_TRANSFER_INSERTED_COUNT defaultValue:0];
        if (previousAllContacts != nil && insertedCount > 0) {
            NSInteger previousPersonCount = [self getPersonCount:previousAllContacts];
            NSInteger personCount = [self getPersonCount:allContacts];
            NSInteger diff = personCount - previousPersonCount;
            cootek_log(@"contact_transfer, insertedCount: %d, diff: %d, personCount: %d, previousCount: %d", \
                       insertedCount, diff, personCount, previousPersonCount);
            // be conservative!
            if (diff >= insertedCount) {
                [UserDefaultsManager removeObjectForKey:CONTACT_TRANSFER_INSERTED_COUNT];
                [[NSNotificationCenter defaultCenter] postNotificationName:N_CONTACT_TRANSFER_CONTACTS_RELOADED object:nil];
            }
        }
    });
    
}

- (NSInteger) getPersonCount:(NSDictionary *)dict {
    NSInteger count = 0;
    if (!dict) {
        return 0;
    }
    for(NSArray *group in dict.allValues) {
        if (group) {
            count += group.count;
        }
    }
    return count;
}

- (CGRect) getRectOfSectionIndexView {
    CGFloat sectionViewHeight = (INDEX_SECTION_VIEW_HEIGHT_PERCENT) * TPScreenHeight();
    CGFloat searchBarHeight = self.m_searchbar.frame.size.height ;
    CGFloat y = (self.view.frame.size.height - searchBarHeight - sectionViewHeight) / 2 + searchBarHeight;
    return CGRectMake(TPScreenWidth() - INDEX_SECTION_VIEW_WIDTH, y, INDEX_SECTION_VIEW_WIDTH, sectionViewHeight);
}

- (void) hideHeaderBarAndAddButton:(BOOL)hidden {
    UIView *addButton = [self.parentViewController1.view viewWithTag:CONTACT_VIEW_CONTROLLER_ADD_BUTTON_TAG];
    UIView *headerBar = [self.parentViewController1.view viewWithTag:CONTACT_HEADER_BAR_TAG];
    
    addButton.hidden = hidden;
    headerBar.hidden = hidden;
}

@end


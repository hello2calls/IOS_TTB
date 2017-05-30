    //
//  SelectCountryViewController.m
//  TouchPalDialer
//
//  Created by Alice on 11-10-27.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SelectCountryViewController.h"
#import "HeaderBar.h"
#import "TPItemButton.h"
#import "TouchPalDialerAppDelegate.h"
#import "FunctionUtility.h"
#import "LangUtil.h"
#import "TPHeaderButton.h"
#import "CootekTableViewCell.h"
#import "TPDialerResourceManager.h"
#import "SkinHandler.h"
#import "FeatureGuideSelectCountryView.h"
#import "SectionIndexView.h"
#import "FeatureGuideSelectCarrierView.h"
#import "UITableView+TP.h"
#import "SmartDailerSettingModel.h"
#import "PredefCountriesUtil.h"
#import "UserDefaultsManager.h"
#define TOP10_COUNTRY_LIST_VIEW 190233

@interface SelectCountryViewController ()
@property (nonatomic,retain) NSDictionary *countryDict;
@property (nonatomic,retain) UITableView *m_table_view;
@property (nonatomic,retain) NSMutableDictionary *all_country_dic;
@property (nonatomic,retain) NSMutableDictionary *m_country_code_dic;
@property (nonatomic,retain) NSMutableArray *keys_arr;
@property (nonatomic,retain) NSMutableArray *tmp_mutablearr;

- (void)buildSectionKey;
- (void)showSelectCarrierWithName:(NSString *)name code:(NSString *)code;
@end

@implementation SelectCountryViewController
@synthesize delegate;
@synthesize m_table_view;
@synthesize all_country_dic;
@synthesize keys_arr;
@synthesize m_country_code_dic;
@synthesize tmp_mutablearr;
@synthesize countryDict = countryDict_;
@synthesize loadSimSettingData = loadSimSettingData_;

- (void)loadView {
	
	UIView *emptyview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, TPScreenWidth(), TPAppFrameHeight())];
	self.view = emptyview;
	emptyview.backgroundColor = [[TPDialerResourceManager sharedManager] getResourceByStyle:@"SelectCountryViewController_background_color"];
	
	// for header.
	HeaderBar *header = [[HeaderBar alloc] initHeaderBar];
    [header setSkinStyleWithHost:self forStyle:@"defaultHeaderView_style"];
	[self.view addSubview:header];
    
    titleLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(0, TPHeaderBarHeightDiff(), TPScreenWidth(), 45)];
    [titleLabel_ setSkinStyleWithHost:self forStyle:@"defaultUILabel_style"];
    titleLabel_.backgroundColor = [UIColor clearColor];
    titleLabel_.font = [UIFont systemFontOfSize:CELL_FONT_TITILE];
    titleLabel_.textAlignment = NSTextAlignmentCenter;
    titleLabel_.text = NSLocalizedString(@"Country or region", @"");
    [header addSubview:titleLabel_];
    

    BOOL isVersionSix = [UserDefaultsManager boolValueForKey:ENABLE_V6_TEST_ME defaultValue:NO];
    if(isVersionSix) {
        // back button
        UIColor *tColor = [TPDialerResourceManager getColorForStyle:@"skinHeaderBarOperationText_normal_color"];
        
        TPHeaderButton *backBtn = [[TPHeaderButton alloc] initLeftBtnWithFrame:CGRectMake(0, 0,50, 45)];
        backBtn.titleLabel.font = [UIFont fontWithName:@"iPhoneIcon1" size:22];
        [backBtn setTitle:@"0" forState:UIControlStateNormal];
        [backBtn setTitle:@"0" forState:UIControlStateHighlighted];
        [backBtn setTitleColor:tColor forState:UIControlStateNormal];
        backBtn.autoresizingMask = UIViewAutoresizingNone;
        [backBtn addTarget:self action:@selector(gotoBack) forControlEvents:UIControlEventTouchUpInside];
        [header addSubview:backBtn];
        
        titleLabel_.textColor = [TPDialerResourceManager getColorForStyle:@"skinHeaderBarTitleText_color"];
    }
    else {
        // BackButton
        TPHeaderButton *cancel_but = [[TPHeaderButton alloc] initLeftBtnWithFrame:CGRectMake(0, 0,50, 45)];
        [cancel_but setSkinStyleWithHost:self forStyle:@"default_backButton_style"];
        [cancel_but addTarget:self action:@selector(gotoBack) forControlEvents:UIControlEventTouchUpInside];
        [header addSubview:cancel_but];
        
    }

	
	//table
    UITableView *tmp_view_content = [[UITableView alloc] initWithFrame:
                                     CGRectMake(0,TPHeaderBarHeight(),TPScreenWidth(),TPHeightFit(415)) style:UITableViewStylePlain];
    tmp_view_content.delegate = self;
    tmp_view_content.dataSource = self;
    [tmp_view_content setExtraCellLineHidden];
    [tmp_view_content setSkinStyleWithHost:self forStyle:@"UITableView_withBackground_style"];
    self.m_table_view= tmp_view_content;
    [self.view addSubview:tmp_view_content];
    
    // set section index view.
	SectionIndexView *tmpsection_index_view = [[SectionIndexView alloc] initSectionIndexView:
                                               CGRectMake(TPScreenWidth()-24, TPHeaderBarHeight(), 24, TPHeightFit(415))];
    sectionIndexView_ = tmpsection_index_view;
    [sectionIndexView_ setSkinStyleWithHost:self forStyle:DRAW_RECT_STYLE];
	sectionIndexView_.delegate = self;
	sectionIndexView_.hidden = YES;
	[self.view addSubview:sectionIndexView_];
	
	// init clear view. when sectionindexview touching, show this.
    clearView_ = [[ClearView alloc] initWithFrame:CGRectMake(190, 120, 70, 70)];
    
    if(loadSimSettingData_){
        FeatureGuideSelectCountryView *top10CountryListView = [[FeatureGuideSelectCountryView alloc] initWithFrame:CGRectMake(0,TPHeaderBarHeight(),TPScreenWidth(),TPHeightFit(370))];
        top10CountryListView.selectRowdelegate = self;
        top10CountryListView.navigationController = self.navigationController;
        top10CountryListView.tag = TOP10_COUNTRY_LIST_VIEW;
        [self.view addSubview:top10CountryListView];
             TPItemButton *moreCountryButton = [[TPItemButton alloc] initWithFrame:CGRectMake(0, TPAppFrameHeight()-56+TPHeaderBarHeightDiff(), TPScreenWidth(), 56)];
        [moreCountryButton setTitleColor:[[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"SelectCountryViewController_moreCountryButtonText_color"] forState:UIControlStateNormal];
        if (isVersionSix) {
           [moreCountryButton setTitleColor:[TPDialerResourceManager getColorForStyle:@"skinHeaderBarTitleText_color"] forState:UIControlStateNormal];
        }else {
            [moreCountryButton setSkinStyleWithHost:self forStyle:@"defaultTPItemButton_style"];
        }

        [moreCountryButton setTitle:NSLocalizedString(@"All countries or regions", @"") forState:UIControlStateNormal];
            [moreCountryButton addTarget:self action:@selector(loadAllCountry:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:moreCountryButton];
    }else{
	    [self loadCountry];
    }
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
    cootek_log(@"Received memory warning in SelectCountryViewController.");
}

-(void)gotoBack
{
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark tableView delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return ([keys_arr count] > 0) ? [keys_arr count] : 0;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [[all_country_dic objectForKey:[keys_arr objectAtIndex:section]] count];	
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifierForSelectView = @"Cell_selectCountry";
	CootekTableViewCell *cell = [[CootekTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
													reuseIdentifier:CellIdentifierForSelectView];
    [cell setSkinStyleWithHost:self forStyle:@"CootekTableViewCell_style"];
	cell.selectionStyle = UITableViewCellSelectionStyleGray;
    
	
	int section = [indexPath section];
	int row = [indexPath row];

	
    NSMutableDictionary *country = (NSMutableDictionary *)([[all_country_dic objectForKey:[keys_arr objectAtIndex:section]] objectAtIndex:row]);
	NSString *countryName=[country objectForKey:@"name"];
	cell.textLabel.text=countryName;
    cell.textLabel.font = [UIFont systemFontOfSize:CELL_FONT_INPUT];
    //displaying the code number
    if(loadSimSettingData_){
        UILabel *codeLabel = [[UILabel alloc] initWithFrame:CGRectMake(TPScreenWidth()-220, 0, 180, cell.frame.size.height)];
        codeLabel.textColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"defaultCellMainText_color"];
        codeLabel.backgroundColor = [UIColor clearColor];
        codeLabel.text = [NSString stringWithFormat:@"+%@",[country objectForKey:@"code"]];
        codeLabel.font = [UIFont systemFontOfSize:16];
        codeLabel.textAlignment = NSTextAlignmentRight;
        [cell addSubview:codeLabel];
    }
    cell.textLabel.textColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"generalSettingCell_MainText_color"];
    cell.textLabel.highlightedTextColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"generalSettingCell_MainText_color"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	int section = [indexPath section];
	int row = [indexPath row];
	
    NSMutableDictionary *country = (NSMutableDictionary *)([[all_country_dic objectForKey:[keys_arr objectAtIndex:section]] objectAtIndex:row]);
	NSString *code=[country objectForKey:@"code"];
	NSString *name=[country objectForKey:@"name"];
    if(!loadSimSettingData_){
	    [delegate selectCountry];
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        if([code isEqualToString:@"86"]){
            [self showSelectCarrierWithName:name code:code];
        }else{
            [delegate selectCountryWithCountryName:name countryCode:code];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
	
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIImageView *tmpview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, TPScreenWidth(), 23)];
	tmpview.backgroundColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"UITableViewSectionHeaderBackground_color"];

	UILabel *mlabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 2, TPScreenWidth(), 18)];
	mlabel.backgroundColor = [UIColor clearColor];
	mlabel.textColor = [[TPDialerResourceManager sharedManager] getResourceByStyle:@"UITableViewSectionHeaderText_color"];
	mlabel.text = [keys_arr objectAtIndex:section];
	[tmpview addSubview:mlabel];
    
	return tmpview;
}

-(void)loadCountry
{
	NSMutableDictionary *tmpDicCounty=[[NSMutableDictionary alloc] init];
    self.m_country_code_dic = tmpDicCounty;
    NSArray *tmp_contact;
    if(countryDict_==nil){
        NSDictionary *tmp_dic = [PredefCountriesUtil partialCountryDict];
        for (id key in tmp_dic) {
            NSMutableDictionary *item=[tmp_dic objectForKey:key];
            [m_country_code_dic setObject:key forKey:[item objectForKey:@"code"]];
        }
        tmp_contact =[tmp_dic allValues];
    }else{
        for (id key in countryDict_) {
            NSMutableDictionary *item=[countryDict_ objectForKey:key];
            [m_country_code_dic setObject:key forKey:[item objectForKey:@"code"]];
        }
        tmp_contact =[countryDict_ allValues];
    }
    
	NSMutableArray *ori_arr = [NSMutableArray arrayWithCapacity:50];
	[ori_arr addObjectsFromArray:tmp_contact];
	NSArray *sorted_arr = [ori_arr sortedArrayUsingFunction:sorttByFirstCharCountry context:nil];
	
	self.all_country_dic = [NSMutableDictionary dictionaryWithCapacity:20];
	self.keys_arr = [NSMutableArray arrayWithCapacity:50];
	self.tmp_mutablearr = [NSMutableArray arrayWithCapacity:50];
	int i = 0;
	for (; i < [sorted_arr count]; i++) {
		NSMutableDictionary* item = [sorted_arr objectAtIndex:i];
		NSString *key_str;
		NSString *key_str_tmp = [item objectForKey:@"name"];
		
		key_str = wcharToNSString(getFirstLetter(NSStringToFirstWchar(key_str_tmp)));		
		if ([keys_arr count] == 0) {
			[keys_arr addObject:key_str];
			self.tmp_mutablearr = [NSMutableArray arrayWithCapacity:20];
			[tmp_mutablearr addObject:[sorted_arr objectAtIndex:i]];
			[all_country_dic setObject:tmp_mutablearr forKey:key_str];
		} else {
			NSString *compare_str = [keys_arr lastObject];
			if (![key_str isEqualToString:compare_str]) {
				[keys_arr addObject:key_str];
				self.tmp_mutablearr = [NSMutableArray arrayWithCapacity:20];
				[tmp_mutablearr addObject:[sorted_arr objectAtIndex:i]];
				[all_country_dic setObject:tmp_mutablearr forKey:key_str];
			} else {
				if (tmp_mutablearr != nil) {
					[tmp_mutablearr addObject:[sorted_arr objectAtIndex:i]];
				}
			}
		}
		
	}
    [self buildSectionKey];
}
- (void)loadAllCountry:(TPUIButton *)buttonCliked{
    buttonCliked.hidden = YES;
    [self.view viewWithTag:TOP10_COUNTRY_LIST_VIEW].hidden = YES;
    //get all dataSource
    sectionIndexView_.hidden = NO;
    self.countryDict = [PredefCountriesUtil allCountryDict];
    [self loadCountry];
    [m_table_view reloadData];
}
NSInteger sorttByFirstCharCountry(id obj1, id obj2, void *context) {
	NSString *obj1_str = [(NSMutableDictionary *)obj1 objectForKey:@"name"];
	NSString *obj2_str = [(NSMutableDictionary *)obj2 objectForKey:@"name"];
	wchar_t char_1 = getFirstLetter(NSStringToFirstWchar(obj1_str));
	wchar_t char_2 = getFirstLetter(NSStringToFirstWchar(obj2_str));
	if (char_1 > char_2) {
		return NSOrderedDescending;
	} else if (char_1 == char_2) {
		return NSOrderedSame;
	} else {
		return NSOrderedAscending;
	}
}
- (void)dealloc {
    [SkinHandler removeRecursively:self];
}
- (void)showSelectCarrierWithName:(NSString *)name code:(NSString *)code{
    titleLabel_.text = NSLocalizedString(@"Select SIM Carrier", @"");
    FeatureGuideSelectCarrierView *carrierListView = [[FeatureGuideSelectCarrierView alloc] initWithFrame:CGRectMake(0, TPHeaderBarHeight(), TPScreenWidth(), TPAppFrameHeight())];
     carrierListView.datas = [NSArray arrayWithObjects:@"China Mobile",@"China Unicom",@"China Telecom", nil];
     carrierListView.selectRowBlock = ^(NSString *selectData){
         
         [self.navigationController popViewControllerAnimated:YES];
         [delegate selectCountryWithCountryName:name countryCode:code carrier:selectData];

    };
    [self.view addSubview:carrierListView];
}

#pragma mark buildSecionKey
- (void)buildSectionKey{
    //NSArray *keys_arr = contactModelNew.all_contact_keys;
    NSArray *marr = [NSArray arrayWithObjects:@"#", @"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", @"*", nil];
    NSMutableDictionary *section_navigate_dic = [NSMutableDictionary dictionaryWithCapacity:[marr count]];
    int section = -1;
    for (int i = 0; i < [marr count]; i++) {
        if ([keys_arr indexOfObject:[marr objectAtIndex:i]] != NSNotFound) {
            section++;
        }
        NSString *content = [marr objectAtIndex:i];
        [section_navigate_dic setObject:[NSNumber numberWithInt:(section == -1 ? 0 : section)] forKey:content];
    }
    sectionMap_ = section_navigate_dic;
}

#pragma mark -
#pragma mark SectionIndexDelegate

- (void)addClearView {
    [clearView_ setSkinStyleWithHost:self forStyle:@"ClearViewBackground_color"];
    clearView_.alpha = 0.8;
	[self.view addSubview:clearView_];
}
- (void)move:(double)top{
    clearView_.frame = CGRectMake(clearView_.frame.origin.x, top,clearView_.frame.size.width , clearView_.frame.size.height);
}
- (void)beginNavigateSection:(NSString *)section_key{
    if (0 == [keys_arr count]) {
        return;
    }
    NSNumber *section_number = [sectionMap_ objectForKey:section_key];
    NSIndexPath *mpath = [NSIndexPath indexPathForRow:0 inSection:[section_number intValue]];
	[m_table_view scrollToRowAtIndexPath:mpath atScrollPosition:UITableViewScrollPositionTop animated:NO];
	[clearView_ setSectionKey:[keys_arr objectAtIndex:[section_number intValue]]];}

- (void)endNavigateSection {
	[clearView_ removeFromSuperview];
}
#pragma mark RegisterProtocoldelegate
-(void)selectCountryWithCountryName:(NSString *)name countryCode:(NSString *)code{
    if([code isEqualToString:@"86"]){
        [self showSelectCarrierWithName:name code:code];
    }else{
        [delegate selectCountryWithCountryName:name countryCode:code];
        [self gotoBack];
    }
}

@end

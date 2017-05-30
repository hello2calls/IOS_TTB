//
//  FeatureGuideSelectCountryView.m
//  TouchPalDialer
//
//  Created by 亮秀 李 on 8/30/12.
//
//

#import "FeatureGuideSelectCountryView.h"
#import "UIView+WithSkin.h"
#import "TPDialerResourceManager.h"
#import "FunctionUtility.h"
#import "CootekTableViewCell.h"
#import "SkinHandler.h"
#import "SmartDailerSettingModel.h"
#import "UITableView+TP.h"
#import "PredefCountriesUtil.h"

@interface FeatureGuideSelectCountryView ()
-(void)loadData;
@end

@implementation FeatureGuideSelectCountryView
@synthesize navigationController = navigationController_;
@synthesize selectRowdelegate = selectRowDelegate_;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        tableView_ = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) style:UITableViewStylePlain];
        [tableView_ setExtraCellLineHidden];
        tableView_.delegate = self;
        tableView_.dataSource = self;
        tableView_.rowHeight = 60;
        [tableView_ setSkinStyleWithHost:self forStyle:@"UITableView_withBackground_style"];
        [self addSubview:tableView_];
        [self loadData];
    }
    return self;
}

- (void)loadData
{
    NSArray *top10Countries = [PredefCountriesUtil top10CountryArray];
    countryData_  = [[NSMutableArray alloc] initWithArray:top10Countries];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return countryData_.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifierForSelectView = @"Cell_selectCountry_featureGuide";
	CootekTableViewCell *cell = [[CootekTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                            reuseIdentifier:CellIdentifierForSelectView];
    //[cell setSkinStyleWithHost:self forStyle:@"CootekTableViewCell_style"];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    NSDictionary *dataItem = [countryData_ objectAtIndex:[indexPath row]];
    cell.textLabel.text = [dataItem objectForKey:@"name"];
    cell.textLabel.font = [UIFont systemFontOfSize:CELL_FONT_INPUT];
    
    UILabel *codeLabel = [[UILabel alloc] initWithFrame:CGRectMake(TPScreenWidth()-220, 0, 210, tableView.rowHeight)];
    codeLabel.textColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"defaultCellMainText_color"];
    codeLabel.backgroundColor = [UIColor clearColor];
    codeLabel.text = [NSString stringWithFormat:@"+%@",[dataItem objectForKey:@"code"]];
    codeLabel.font = [UIFont systemFontOfSize:CELL_FONT_INPUT];
    codeLabel.textAlignment = NSTextAlignmentRight;
    [cell addSubview:codeLabel];
    cell.textLabel.textColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"generalSettingCell_MainText_color"];
    cell.textLabel.highlightedTextColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"generalSettingCell_MainText_color"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dataItem = [countryData_ objectAtIndex:[indexPath row]];
    [selectRowDelegate_ selectCountryWithCountryName:[dataItem objectForKey:@"name"] countryCode:[dataItem objectForKey:@"code"]];
    //[self gotoBack];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (void)gotoBack
{
    [navigationController_ popViewControllerAnimated:YES];
}

- (void)dealloc
{
    [SkinHandler removeRecursively:self];
}

@end

//
//  CommonMultiSelectTableView.m
//  TouchPalDialer
//
//  Created by 亮秀 李 on 11/9/12.
//
//

#import "CommonMultiSelectTableView.h"
#import "UIView+WithSkin.h"
#import "SkinHandler.h"
#import "UITableView+TP.h"
#import "TPDialerResourceManager.h"
#import "CommonDataCell.h"

@implementation MultiSelectItemData

@synthesize is_checked;
@synthesize data;
@synthesize text;

- (id)initWithData:(int)paraData withText:(NSString*)paraText isChecked:(int)isChecked {
    self = [super init];
    if (self) {
        self.data = paraData;
        self.text = paraText;
        self.is_checked = isChecked;
    }
    return self;
}

@end


@implementation MultiSelectSectionData

@synthesize data;
@synthesize text;
@synthesize items;

- (id)initWithData:(int)paraData withText:(NSString*)paraText withItems:(NSArray*)paraItems {
    self = [super init];
    if (self) {
        self.data = paraData;
        self.text = paraText;
        self.items = [NSArray arrayWithArray:paraItems];
    }
    return self;
}

@end


@interface CommonMultiSelectTableView () <CommonDataCellDelegate>
@property (nonatomic,retain) NSArray* dataList;
- (void) animatedShow;
@end

@implementation CommonMultiSelectTableView
@synthesize dataList;
- (id)initWithFrame:(CGRect)frame andDataList:(NSArray *)datas needAnimateIn:(BOOL)animate
{
    self = [super initWithFrame:frame];
    if (self) {
        self.dataList = datas;
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,0,frame.size.width,frame.size.height)];
        [tableView setSkinStyleWithHost:self forStyle:@"UITableView_withBackground_style"];
        [tableView setExtraCellLineHidden];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.sectionHeaderHeight = 23;
        [self addSubview:tableView];
        
        if(animate){
            [self animatedShow];
        }
        
    }
    return self;
}

- (void) animatedShow{
    CGRect oldFrame = self.frame;
    [UIView animateWithDuration:0.2f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{                         
                         self.frame = CGRectMake(0,TPAppFrameHeight(),oldFrame.size.width,oldFrame.size.height);
                         
                         self.frame = CGRectMake(0,0,oldFrame.size.width,oldFrame.size.height);                         
                     }
                     completion:^(BOOL finished){
                         if (finished) {
                             
                         }
                     }];
}

#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return [dataList count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    MultiSelectSectionData* sectionData = [dataList objectAtIndex:section];
    return [sectionData.items count];
}
//View for header in section
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    MultiSelectSectionData* sectionData = [dataList objectAtIndex:section];
    
    UIImageView *tmpview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, TPScreenWidth(), 23)];
	[tmpview setSkinStyleWithHost:self forStyle:@"UITableViewSectionHeaderBackground_color"];
    
	UILabel *mlabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 2, TPScreenWidth() - 10, 18)];
	mlabel.backgroundColor = [UIColor clearColor];
	mlabel.textColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"UITableViewSectionHeaderText_color"];
	mlabel.text = sectionData.text;
	[tmpview addSubview:mlabel];
	return tmpview;
    
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    int sectionIndex = [indexPath section];
    int rowIndex = [indexPath row];
    MultiSelectSectionData* sectionData = [dataList objectAtIndex:sectionIndex];
    MultiSelectItemData* itemData = [sectionData.items objectAtIndex:rowIndex];
    
    static NSString *CellIdentifier = @"Cell";
    CommonDataCell* cell = [[CommonDataCell alloc] initWithData:sectionData.data
                                                         subData:itemData.data
                                                           Image:nil
                                                       isChecked:itemData.is_checked
                                                           style:UITableViewCellStyleSubtitle
                                                 reuseIdentifier:CellIdentifier];
    
    cell.delegate = self;
    NSString *text = itemData.text;
    if (text == nil || [text isEqualToString:@""]) {
        text = sectionData.text;
    }
    [cell setCellText:text];
    
    return cell;
}

#pragma mark CommonDataCellDelagate
- (void)checkChanged:(BOOL)isChecked mainData:(int)mainData subData:(int)subData {
    int sectionDatasCount = [dataList count];
    int i = 0;
    for (; i<sectionDatasCount; i++) {
        MultiSelectSectionData* sectionData = [dataList objectAtIndex:i];
        if (sectionData.data == mainData) {
            int itemDatasCount = [sectionData.items count];
            int j = 0;
            for (; j<itemDatasCount; j++) {
                MultiSelectItemData* itemData = [sectionData.items objectAtIndex:j];
                if (itemData.data == subData) {
                    itemData.is_checked = isChecked;
                }
            }
            return;
        }
    }
}

-(void)dealloc{
    [SkinHandler removeRecursively:self];
}
@end

//
//  SettingSingleSelectViewController.m
//  TouchPalDialer
//
//  Created by Stony Wang on 12-3-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SettingSingleSelectViewController.h"
#import "SettingsItemCell.h"
#import "UITableView+TP.h"

@interface SettingSingleSelectViewController() <UITableViewDelegate, UITableViewDataSource> {
    NSInteger selectedIndex_;
    void(^selectBlock_)(NSInteger selectedIndex);
}
@end
@implementation SettingSingleSelectViewController

- (void)loadView
{
    [super loadView];
}
-(id)initWithTitles:(NSArray *)titles selectedIndex:(NSInteger)index andSelectBlock:(void(^)(NSInteger selectedIndex))selectBlock{
    self = [super init];
    if (self) {
        selectedIndex_ = index;
        app_settings_model = [AppSettingsModel appSettings];
        selectBlock_ = [selectBlock copy];
        cell_titles = [[NSArray alloc] initWithArray:titles];
    }
    return self;

}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [cell_titles count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    SettingsItemCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    RoundedCellBackgroundViewPosition postion = [tableView cellPositionOfIndexPath:indexPath];
    // Configure the cell...
    if (cell == nil){
        cell = [[SettingsItemCell alloc] initWithType:SettingsItemCellTypeNone
                                       reuseIdentifier:CellIdentifier
                                          cellPosition:postion];
    }
    cell.textLabel.text = [cell_titles objectAtIndex:[indexPath row]];
    cell.accessoryType = UITableViewCellAccessoryNone;
    if ([indexPath row] == selectedIndex_) {
        cell.checkMarkLabel.hidden = NO;
    } else {
        cell.checkMarkLabel.hidden = YES;
    }
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    selectedIndex_ = [indexPath row];
    selectBlock_(selectedIndex_);
    [tableView reloadData];
}

- (void)initializeCellTitles {
    cell_titles = [[NSArray alloc] initWithObjects:
                   NSLocalizedString(@"Default",@""),
                   NSLocalizedString(@"Greek",@""),
                   NSLocalizedString(@"Hebrew",@""),
                   NSLocalizedString(@"Persian",@""),
                   NSLocalizedString(@"Russian",@""), nil];
}
@end

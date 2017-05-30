
//
//  FeatureGuideSelectCarrierView.m
//  TouchPalDialer
//
//  Created by 亮秀 李 on 8/30/12.
//
//

#import "FeatureGuideSelectCarrierView.h"
#import "UIView+WithSkin.h"
#import "CootekTableViewCell.h"
#import "SkinHandler.h"
#import "UITableView+TP.h"
#import "TPDialerResourceManager.h"
#import "SettingCell.h"
#import "SmartDailerSettingModel.h"

@interface FeatureGuideSelectCarrierView ()
- (void) animatedShow;
@property (nonatomic,strong) NSIndexPath *selectIndexPath;

@end

@implementation FeatureGuideSelectCarrierView
@synthesize datas = datas_;
@synthesize selectRowBlock = selectRowBlock_;
- (id)initWithFrame:(CGRect)frame
{
    self = [self initWithFrame:frame needAnimation:YES];
    return self;
}
- (id)initWithFrame:(CGRect)frame needAnimation:(BOOL)animate{
    self = [super initWithFrame:frame];
    if (self) {
        UITableView *tmpTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) style:UITableViewStylePlain];
        [tmpTableView setExtraCellLineHidden];
        tmpTableView.delegate = self;
        tmpTableView.dataSource = self;
        tmpTableView.rowHeight = 60;
        tmpTableView.sectionHeaderHeight = 20;
        tmpTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tmpTableView setSkinStyleWithHost:self forStyle:@"defaultBackground_color"];
        [self addSubview:tmpTableView];
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
                         //self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
                         self.frame = CGRectMake(0,TPAppFrameHeight(),oldFrame.size.width,oldFrame.size.height);
                         
                         self.frame = CGRectMake(0,TPHeaderBarHeight(),oldFrame.size.width,oldFrame.size.height);
                         //self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
                         
                     }
                     completion:^(BOOL finished){
                         if (finished) {
                             
                         }
                     }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"SettingCarrierCell";//SettingCell.h
	SettingCell  *cell = (SettingCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  
    int row = [indexPath row];
    if (cell == nil) {
        cell = [[SettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        //[cell setSkinStyleWithHost:self forStyle:@"CootekTableViewCell_style"];
        cell.textLabel.textColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"generalSettingCell_MainText_color"];
        cell.textLabel.highlightedTextColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"generalSettingCell_MainText_color"];
        cell.textLabel.backgroundColor = [UIColor clearColor];
    }
    cell.separateLineType = SettingCellSeparateLineTypeSingle;
    cell.hiddenArrow = YES;
    

    
    NSString *carrier = [datas_ objectAtIndex:row];
    
    NSString *currentCarrier = [[SmartDailerSettingModel alloc] init].currentChinaCarrier;
    if ( [currentCarrier isEqualToString:carrier]) {
        self.selectIndexPath = indexPath;
        cell.checkMarkLabel.hidden = NO;
    } else {
        cell.checkMarkLabel.hidden = YES;
    }
    
    cell.textLabel.text = NSLocalizedString(carrier, @"");
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    return cell;
}
// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(datas_==nil || datas_.count ==0){
        return 0;
    }
    return [datas_ count];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    SettingCell *last = [tableView cellForRowAtIndexPath:self.selectIndexPath];
    last.checkMarkLabel.hidden = YES;
    
    self.selectIndexPath = indexPath;
    
    SettingCell *select = [tableView cellForRowAtIndexPath:self.selectIndexPath];
    select.checkMarkLabel.hidden = NO;
    
    if (selectRowBlock_) {
        selectRowBlock_([datas_ objectAtIndex:indexPath.row]);
    }
         
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *sectionHeader = [[UIView alloc] init];
    sectionHeader.backgroundColor = [UIColor clearColor];
    return sectionHeader;
    
}
- (void)dealloc{
    [SkinHandler removeRecursively:self];
    
}
@end

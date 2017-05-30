//
//  SmartEyeSettingView.h
//  TouchPalDialer
//
//  Created by 亮秀 李 on 9/26/12.
//
//

#import <UIKit/UIKit.h>
#import "CityDownCell.h"
#import "SettingCellView.h"
@interface SmartEyeSettingView : UIView <UITableViewDataSource,UITableViewDelegate,CityDataDownDelegate,SettingCellDelegate>{
    UITableView *cityTableView_;
    BOOL isDidLoadData_;
    BOOL isNoData_;
}
@property(nonatomic,retain)NSArray *unInstallCitys;
@property(nonatomic,retain)NSArray *installCitys;
@property(nonatomic,retain)YellowCityModel *nationCity;
-(void)changeSkin;
-(NSUInteger)cityCountNeedToUpdate;
@end

//
//  FeatureGuideSelectCountryView.h
//  TouchPalDialer
//
//  Created by 亮秀 李 on 8/30/12.
//
//

#import <UIKit/UIKit.h>
#import "RegisterProtocol.h"

@interface FeatureGuideSelectCountryView : UIView <UITableViewDataSource, UITableViewDelegate>{
    UITableView *tableView_;
    NSMutableArray *countryData_;
}
@property (nonatomic,assign)UINavigationController *navigationController;
@property (nonatomic,assign)id<RegisterProtocolDelegate> selectRowdelegate;
@end

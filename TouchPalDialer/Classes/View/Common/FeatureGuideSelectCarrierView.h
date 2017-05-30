//
//  FeatureGuideSelectCarrierView.h
//  TouchPalDialer
//
//  Created by 亮秀 李 on 8/30/12.
//
//

#import <UIKit/UIKit.h>

@interface FeatureGuideSelectCarrierView : UIView <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,retain) NSArray *datas;
@property (nonatomic,copy) void(^selectRowBlock)(id selectedData);

- (id)initWithFrame:(CGRect)frame needAnimation:(BOOL)animate;
@end

//
//  CitySelectRowView.h
//  TouchPalDialer
//
//  Created by tanglin on 15/8/26.
//
//

#import <UIKit/UIKit.h>
#import "CityModel.h"

@interface CitySelectRowView : UIView

@property(nonatomic, strong) CityModel* model;
@property(nonatomic, assign) int type;
@property(nonatomic, assign) int rowIndex;
@property(nonatomic, assign) NSIndexPath* indexPath;
@property(nonatomic, assign)BOOL pressed;
+ (CGFloat) getRowHeight:(CityModel*)cityModel andIndexPath:(NSIndexPath*)indexPath;
- (void) resetDataWithCityModel:(CityModel*)model andIndexPath:(NSIndexPath*)indexPath;
+ (int) getType:(CityModel*)cityModel andIndexPath:(NSIndexPath*)indexPath;

@end

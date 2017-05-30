//
//  ServiceTitleView.h
//  TouchPalDialer
//
//  Created by tanglin on 15/11/9.
//
//

#import "YPUIView.h"
#import "HighLightView.h"
#import "VerticallyAlignedLabel.h"
#import "ServiceItem.h"

@interface ServiceTitleView : YPUIView

@property(nonatomic, strong) HighLightView* highLightView;
@property(nonatomic, strong) VerticallyAlignedLabel* title;
@property(nonatomic, strong) ServiceItem* item;
@property(nonatomic, strong) NSMutableArray* serviceArray;

- (void) drawView:(ServiceItem*) service;
- (void) resetWithService:(NSArray*) serviceArray andIndexPath:(NSIndexPath*) indexPath;
@end

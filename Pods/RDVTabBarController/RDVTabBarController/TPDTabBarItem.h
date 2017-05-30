//
//  TPDTabBarItem.h
//  TouchPalDialer
//
//  Created by weyl on 16/12/23.
//
//

#import <UIKit/UIKit.h>

@interface TPDTabBarItem : UIControl
@property (nonatomic,strong) NSString* imageAndTextPrefix;
@property (nonatomic,strong) NSString* imagePrefix;
@property (nonatomic,strong) NSString* textPrefix;

-(double)itemHeight;
+(TPDTabBarItem*)dialTabItem;
+(TPDTabBarItem*)contactTabItem;
+(TPDTabBarItem*)discoveryTabItem;
+(TPDTabBarItem*)meTabItem;
-(void)reconfig;
@end

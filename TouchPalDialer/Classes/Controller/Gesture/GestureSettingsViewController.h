//
//  GestureSettingsViewController.h
//  TouchPalDialer
//
//  Created by Admin on 6/5/13.
//
//

#import <UIKit/UIKit.h>
#import "GestureModel.h"
#import "GestureUtility.h"
#import "TPUIButton.h"
#import "GestureScrollView.h"
#import "TPHeaderButton.h"

@interface GestureSettingsViewController : UIViewController
{
    TPHeaderButton *editGestureButton;
    DefaultGestureType defaultType;
    NSMutableArray *gestureCustomList;
    GestureActionType actionKey;
    GestureScrollView *showArea;

}
@property(nonatomic,retain)TPHeaderButton *editGestureButton;
@property(nonatomic,assign)DefaultGestureType defaultType;
@property(nonatomic,retain)NSMutableArray *gestureCustomList;
@property(nonatomic,assign)GestureActionType actionKey;

- (void)loadData;
- (void)loadGrid;
@end

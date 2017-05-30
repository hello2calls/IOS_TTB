//
//  TPSelectCopyViewController.h
//  TouchPalDialer
//
//  Created by H L on 2016/10/27.
//
//


#import <UIKit/UIKit.h>
#import "SelectViewProtocal.h"
#import "SelectView.h"

typedef enum {
    SelectViewContollerTypeNormal,
    SelectViewContollerTypeSimple,
} SelectViewContollerType;


@interface TPSelectCopyViewController: UIViewController<SelectViewProtocalDelegate> {
    id<SelectViewProtocalDelegate> __unsafe_unretained delegate;
    SelectView *select_view;
    SelectViewType viewType;
    NSString *commandName;
    BOOL autoDismiss;
}

@property(nonatomic,retain)SelectView *select_view;
@property(nonatomic,assign) id<SelectViewProtocalDelegate> delegate;
@property(nonatomic,retain)NSArray *dataList; //ContactCacheDataModel list
@property(nonatomic,assign)SelectViewType viewType;
@property(nonatomic, readwrite)SelectViewContollerType type;
@property(nonatomic,retain)NSString *commandName;
@property(nonatomic,assign)int groupID;

@property(nonatomic,assign)BOOL autoDismiss;
@property(nonatomic,assign)BOOL isChooseSingle;

@end

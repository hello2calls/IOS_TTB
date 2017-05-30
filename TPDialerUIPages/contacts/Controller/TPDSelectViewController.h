//
//  TPDSelectViewController.h
//  TouchPalDialer
//
//  Created by H L on 2016/11/30.
//
//

#import <UIKit/UIKit.h>
#import "SelectView.h"


@interface TPDSelectViewController : UIViewController<SelectViewProtocalDelegate>

@property(nonatomic, strong)SelectView                      *select_view;
@property(nonatomic, weak )id<SelectViewProtocalDelegate>   delegate;
//ContactCacheDataModel list
@property(nonatomic, strong)NSArray                         *dataList;
@property(nonatomic, assign)SelectViewType                  viewType;
@property(nonatomic, strong)NSString                        *commandName;
@property(nonatomic, readwrite)int                          type;

@property(nonatomic, assign)BOOL                            autoDismiss;
@property(nonatomic, assign)BOOL                            isChooseSingle;

- (instancetype)initWithFinishBlock:(void(^)(NSArray *dataList))finish CancelBlock:(void(^)(void))cancel ;

@end

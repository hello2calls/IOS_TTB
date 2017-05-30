//
//  SelectViewProtocal.h
//  TouchPalDialer
//
//  Created by Alice on 11-8-23.
//  Copyright 2011 Cootek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SelectModel.h"

@protocol SelectViewProtocalDelegate<NSObject>

@optional
-(void)selectViewCancel;
-(void)selectViewFinish:(NSArray *)select_list;
-(void)selectItem:(SelectModel *)select_item;
-(void)selectItem:(SelectModel *)select_item withObject:(id)object;
-(BOOL)isSelectedPerson:(NSInteger)personID;
-(BOOL)isSelectedPerson:(NSInteger)personID withObject:(id)object;
-(void)cancelInput;
-(void)willSelectView;
@end

//
//  ChangeGroupService.h
//  TouchPalDialer
//
//  Created by Sendor on 11-12-7.
//  Copyright 2011 Cootek. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ChangeGroupService : NSObject<UITextFieldDelegate>{
    int add_group_id;
    NSString __strong *add_group_name;
    UIAlertView *add_alert;
    UIAlertView *add_group_name_exist_warning_alert;
    
    int rename_group_id;
    NSString __strong *rename_group_name;
    NSString __strong *old_group_name;
    UIAlertView *rename_alert;
    UIAlertView *rename_group_name_exist_warning_alert;    
}

+ (ChangeGroupService*)getSharedChangeGroupService;

- (void)addGroup;
- (void)renameGroupById:(int)groupId oldName:(NSString*)oldName;
- (UIAlertView*)createTextFieldAlertViewWithTitle:(NSString*)title placeHolder:(NSString*)placeHolder oldValue:(NSString*)oldValue;

- (void)doAddGroup;
- (void)doRenameGroup;

@end

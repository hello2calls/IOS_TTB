//
//  ChangeGroupService.m
//  TouchPalDialer
//
//  Created by Sendor on 11-12-7.
//  Copyright 2011 Cootek. All rights reserved.
//

#import "ChangeGroupService.h"
#import "GroupModel.h"
#import "CootekNotifications.h"
#import "TPDialerResourceManager.h"

static ChangeGroupService* sharedModel = nil;

@implementation ChangeGroupService

+ (ChangeGroupService*)getSharedChangeGroupService {
	
	if (sharedModel) {
		return sharedModel;
	}
	
    @synchronized(self)	{
		if (!sharedModel)
		{
            sharedModel = [[self alloc] init];
        }
    }
	return  sharedModel;
}

- (id)init {
    self = [super init];
    if (self) {                
        add_group_id = 0;
        add_group_name = nil;
        add_alert = nil;
        add_group_name_exist_warning_alert = nil;

        rename_group_id = 0;
        rename_group_name = nil;
        rename_alert = nil;
        rename_group_name_exist_warning_alert = nil;
    }
    return self;
}


#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (0 == buttonIndex) {
        cootek_log(@"choose cancel ");
        return;
    }
    if ([alertView.title isEqualToString:NSLocalizedString(@"New group", @"New group")]) {
        add_group_name = [alertView textFieldAtIndex:0].text;
        BOOL isExisted = [[GroupModel pseudoSingletonInstance] isGroupExisted:add_group_name];
        if (isExisted) {
            add_group_name_exist_warning_alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning", @"")
                                                                            message:NSLocalizedString(@"The group exists already! Do you want to continue?", @"")
                                                                           delegate:self 
                                                                  cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                                                                  otherButtonTitles:NSLocalizedString(@"Ok", @"Ok"), nil];
            [add_group_name_exist_warning_alert show];
        } else {
            [self doAddGroup];
        }
    } else if ([alertView.title isEqualToString:NSLocalizedString(@"Rename group", @"Rename group")]) {
        rename_group_name = [alertView textFieldAtIndex:0].text;
        if ([rename_group_name isEqualToString:old_group_name]) {
            return;
        }
        BOOL isExisted = [[GroupModel pseudoSingletonInstance] isGroupExisted:rename_group_name];
        if (isExisted) {
            rename_group_name_exist_warning_alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning", @"")
                                                                               message:NSLocalizedString(@"The group exists already! Do you want to continue?", @"")
                                                                              delegate:self 
                                                                     cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                                                                     otherButtonTitles:NSLocalizedString(@"Ok", @"Ok"), nil];
            [rename_group_name_exist_warning_alert show];
        } else {
            [self doRenameGroup];
        }
    } else if (alertView == add_group_name_exist_warning_alert) {
        [self doAddGroup];
    } else if (alertView == rename_group_name_exist_warning_alert) {
        [self doRenameGroup];
    }       
}

- (void)addGroup {
    [self releaseUsedAlertView];
    if ([[GroupModel pseudoSingletonInstance] isExchangeType]) {
        UIAlertView *alert= [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Exchange Warning", @"Exchange Warning")
                                                       message:nil
                                                      delegate:nil
                                             cancelButtonTitle:NSLocalizedString(@"OK",@"OK")
                                             otherButtonTitles:nil];
        [alert show];
    } else  {
    // do add group
        add_alert = [self createTextFieldAlertViewWithTitle:NSLocalizedString(@"New group", @"New group")
                                            placeHolder:NSLocalizedString(@"Input group name", @"Input group name")  
                                               oldValue:nil];
        [add_alert show];
    }
}

- (void)renameGroupById:(int)groupId oldName:(NSString*)oldName {
    [self releaseUsedAlertView];
    old_group_name = oldName;
    rename_group_id = groupId;
    rename_alert = [self createTextFieldAlertViewWithTitle:NSLocalizedString(@"Rename group", @"Rename group") 
                                               placeHolder:nil 
                                                  oldValue:oldName];
    [rename_alert show];
}

- (UIAlertView*)createTextFieldAlertViewWithTitle:(NSString*)title placeHolder:(NSString*)placeHolder oldValue:(NSString*)oldValue {
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:title
                                                     message:nil 
                                                    delegate:self 
                                           cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                                           otherButtonTitles:NSLocalizedString(@"Ok", @"Ok"), nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField* textField = [alert textFieldAtIndex:0];
    textField.text = oldValue;
    textField.placeholder = placeHolder;
    [textField becomeFirstResponder];

    return alert;
}

- (void)doAddGroup {
    int groupId = [[GroupModel pseudoSingletonInstance] addGroup:add_group_name];
    if(groupId <= 0) {
        UIAlertView* errorAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error")
                                                             message:NSLocalizedString(@"Failed to add the group!", @"Failed to add the group!")
                                                            delegate:nil 
                                                   cancelButtonTitle:NSLocalizedString(@"Ok", @"Ok") 
                                                   otherButtonTitles:nil];
        [errorAlert show];
    }
}

- (void)doRenameGroup {
    BOOL result = [[GroupModel pseudoSingletonInstance] renameGroup:rename_group_id name:rename_group_name];
    if(!result) {
        UIAlertView* errorAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error")
                                                             message:NSLocalizedString(@"Failed to rename the group!", @"Failed to rename the group!")
                                                            delegate:nil 
                                                   cancelButtonTitle:NSLocalizedString(@"Ok", @"Ok") 
                                                   otherButtonTitles:nil];
        [errorAlert show];
    }
}

- (void)releaseUsedAlertView {
    if (add_alert != nil) {
        add_alert = nil;
    }
    if (rename_alert != nil) {
        rename_alert = nil;
    }
}
@end

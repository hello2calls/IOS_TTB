//
//  ControllerManager.m
//  TouchPalDialer
//
//  Created by tanglin on 15/9/17.
//
//

#import "ControllerManager.h"
#import <objc/runtime.h>
#import "TouchPalDialerAppDelegate.h"
#import "PersonInfoDescViewController.h"
#import "ContactInfoViewController.h"
#import "FunctionUtility.h"
#import "CommonUtil.h"
#import "NumberPersonMappingModel.h"
@implementation ControllerManager

+ (void)reflectDataFromOtherObject:(NSObject *)targetObject dataSource:(NSObject*)dataSource
{
    if ([dataSource isKindOfClass:[NSDictionary class]]) {
        NSDictionary* dic = (NSDictionary *)dataSource;
        for (NSString *key in [dic allKeys]) {
            if (![key isEqualToString:@"controller"] && [key length] > 0) {
                id propertyValue = [dataSource valueForKey:key];
                if (![propertyValue isKindOfClass:[NSNull class]] && propertyValue != nil) {
                    if ([propertyValue isKindOfClass:[NSDictionary class]]) {
                        NSString* clsName = [propertyValue objectForKey:@"className"];
                        if ([clsName length] > 0) {
                            NSObject *object = [[NSClassFromString(clsName) alloc] init];
                            for (NSString *k in [propertyValue allKeys]) {
                                if(![k isEqualToString:@"className"]) {
                                    [object setValue:[propertyValue objectForKey:k] forKey:k];
                                }
                            }
                            [targetObject setValue:object forKey:key];
                        }
                    } else {
                        [targetObject setValue:propertyValue forKey:key];
                    }
                }
            }
        }
    }
}

+ (UIViewController *)pushAndGetController:(NSDictionary *)nativeDic
{
    UINavigationController *navi = [((TouchPalDialerAppDelegate *)[[UIApplication sharedApplication] delegate]) activeNavigationController];

    
    NSString* controllerName = [nativeDic objectForKey:@"controller"];
    Class nameClass = NSClassFromString(controllerName);
    UIViewController *controller = [[NSClassFromString(controllerName) alloc] init];
    
    if ( [navi.topViewController isKindOfClass:[controller class]]){
        [navi popViewControllerAnimated:NO];
    }
    
    if (nameClass) {
        [ControllerManager reflectDataFromOtherObject:controller dataSource:nativeDic];
        [[TouchPalDialerAppDelegate naviController] pushViewController:controller animated:YES];
    }
    return controller;
}

+ (void) pushController:(NSDictionary *)nativeDic {
    [ControllerManager pushController:nativeDic withAnimate:YES];
}

+ (void) pushController:(NSDictionary* )nativeDic withAnimate:(BOOL)animate
{
    UIViewController *controller = nil;
    NSString *modelControllerName = [nativeDic objectForKey:@"model_controller"];
    NSString *phoneControllerName = [nativeDic objectForKey:@"phone_controller"];

    if ([modelControllerName length] > 0) {
        Class nameClass = NSClassFromString(modelControllerName);
        if (nameClass == nil) {
            return;
        }
        id nameController = [nameClass alloc];
        NSDictionary *dic = [nativeDic objectForKey:@"model"];
        if ([nameController respondsToSelector:@selector(initWithLinkDictionary:)]) {
            controller = [nameController initWithLinkDictionary:dic];
        }
    } else if ([phoneControllerName length] >0) {
        Class nameClass = NSClassFromString(phoneControllerName);
        if (nameClass == nil) {
            return;
        }
        NSString *phone = [nativeDic objectForKey:@"phone"];
            NSInteger personID = [NumberPersonMappingModel queryContactIDByNumber:phone];
            if (personID > 0) {
                [[ContactInfoManager instance] showContactInfoByPersonId:personID];
            }else if (personID <= 0) {
                [[ContactInfoManager instance] showContactInfoByPhoneNumber:phone];
            }
        
        return;
        
    }
    
    else {
        NSString* controllerName = [nativeDic objectForKey:@"controller"];
        Class nameClass = NSClassFromString(controllerName);
        if (nameClass) {
            controller = [[NSClassFromString(controllerName) alloc] init];
            [ControllerManager reflectDataFromOtherObject:controller dataSource:nativeDic];
        }
    }
    if (controller) {
        UINavigationController *navi = [TouchPalDialerAppDelegate naviController];
        BOOL needRemoveSelf = NO;
        id removeSelf = [nativeDic objectForKey:@"removeSelf"];
        if ([removeSelf isKindOfClass:[NSNumber class]]) {
            needRemoveSelf = [removeSelf intValue] == 1;
        }
        UIViewController *topController = navi.viewControllers.count > 1 ? navi.topViewController : nil;
        [navi pushViewController:controller animated:animate];
        
        if (needRemoveSelf && topController) {
            [FunctionUtility removeFromStackViewController:topController];
        }
    }
}
@end

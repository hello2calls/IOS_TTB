//
//  NotificationAlertManger.m
//  TouchPalDialer
//
//  Created by game3108 on 15/3/26.
//
//

#import "NotificationAlertManger.h"
#import "InviteShareViewFactory.h"
#import "TouchPalDialerAppDelegate.h"
#import "UMFeedbackController.h"
#import "UserDefaultsManager.h"
#import "AskLikeShareFirstViewController.h"
#import "AskLikeShareSecondViewController.h"
#import "PhonePadModel.h"
#import "CallLogDataModel.h"
#import "PhoneNumber.h"
#import "TouchpalMembersManager.h"
#import "ContactCacheDataManager.h"
#import "PersonDBA.h"

static NotificationAlertManger *instance;

@implementation NotificationAlertManger{
}

+ (void)initialize{
    instance = [[NotificationAlertManger alloc]init];
}

+ (instancetype)instance{
    return instance;
}


- (void)checkShowAlert{
    if ([UserDefaultsManager intValueForKey:@"ask_like_close_time" defaultValue:0] > 2)
        return;
    if ( ![UserDefaultsManager boolValueForKey:ASK_LIKE_VIEW_COULD_SHOW defaultValue:NO] )
        return;
    [UserDefaultsManager setBoolValue:NO forKey:ASK_LIKE_VIEW_COULD_SHOW];
    NSInteger now = [[NSDate date] timeIntervalSince1970];
    NSInteger show_time = [UserDefaultsManager intValueForKey:ASK_LIKE_VIEW_SHOW_TIME defaultValue:0];
    if (now < show_time)
        return;
    [UserDefaultsManager setIntValue:show_time+7*24*60*60 forKey:ASK_LIKE_VIEW_SHOW_TIME];
    
    NSDictionary *dict = @{@"ios_invite_icon":@"T",
                           @"ios_invite_icon_font":@"iPhoneIcon2",
                           @"invite_title_text":@"喜欢我们，就支持一下",
                           @"invite_first_title":@"有了您的支持，我们会做得更好",
                           @"invite_second_title":@"欢迎推荐触宝给更多朋友！",
                           @"invite_left_button_text":@"不喜欢",
                           @"invite_right_button_text":@"喜欢"};
    InviteShareData *data = [[InviteShareData alloc]initWithDictionary:dict];
    AskLikeView *view = [InviteShareViewFactory showAskLikeView:data inParent:[TouchPalDialerAppDelegate naviController].topViewController.view];
    __weak NotificationAlertManger *wself = self;
    view.cancelBlock = ^{
        [wself cancelButtonAction:data];
    };
    view.leftBlock = ^{
        [wself leftButtonAction:data];
    };
    view.rightBlock = ^{
        [wself rightButtonAction:data];
    };

}

- (void)cancelButtonAction:(InviteShareData *)data {
    NSInteger num = [UserDefaultsManager intValueForKey:@"ask_like_close_time" defaultValue:0];
    num = num + 1;
    [UserDefaultsManager setIntValue:num forKey:@"ask_like_close_time"];
}

- (void)leftButtonAction:(InviteShareData *)data {
    UMFeedbackController *vc = [[UMFeedbackController alloc]init];
    [[TouchPalDialerAppDelegate naviController] pushViewController:vc animated:YES];
}

- (void)rightButtonAction:(InviteShareData *)data {
    if ([UserDefaultsManager boolValueForKey:TOUCHPAL_USER_HAS_LOGIN]){
        dispatch_async(dispatch_get_main_queue(), ^{
            UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(0, 0, 80, 80)];
            [indicator setCenter:CGPointMake(TPScreenWidth()/2, TPScreenHeight()/2)];
            [indicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
            indicator.hidesWhenStopped = YES;
            [indicator startAnimating];
            UIWindow *uiWindow = [[UIApplication sharedApplication].windows objectAtIndex:0];
            [uiWindow addSubview:indicator];
            [uiWindow bringSubviewToFront:indicator];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSMutableArray *resultArray = [[NSMutableArray alloc]init];
                NSMutableArray *numberArray = [[NSMutableArray alloc]init];
                
                PhonePadModel *model = [PhonePadModel getSharedPhonePadModel];
                NSArray *calllog_list = model.calllog_list.searchResults;
                for ( NSInteger i = 0 ; i < calllog_list.count ; i ++ ){
                    CallLogDataModel *model = calllog_list[i];
                    bool isTouchpalUser = NO;
                    NSString *phoneNumber = nil;
                    NSInteger personID = model.personID;
                    if ( personID == -1 )
                        continue;
                    ContactCacheDataModel *contact = [[ContactCacheDataManager instance] contactCacheItem:personID];
                    for (PhoneDataModel *phoneData in contact.phones) {
                        NSString *normalNumber = [PhoneNumber getCNnormalNumber:phoneData.number];
                        if (normalNumber.length == 14 && [normalNumber hasPrefix:@"+861"]){
                            phoneNumber = normalNumber;
                        }else{
                            continue;
                        }
                        NSInteger resultCode = [TouchpalMembersManager isNumberRegistered:normalNumber];
                        if (resultCode == 1){
                            isTouchpalUser = YES;
                            break;
                        }
                    }
                    if (!isTouchpalUser&&phoneNumber){
                        if ( [numberArray containsObject:phoneNumber] )
                            continue;
                        UIImage *image= contact.image;
                        if ( !image ){
                            image = [PersonDBA getDefaultImageByPersonID:personID isCootekUser:isTouchpalUser];
                        }
                        [resultArray addObject:@{@"displayName":contact.displayName,
                                                 @"number":phoneNumber,
                                                 @"image":image}];
                        [numberArray addObject:phoneNumber];
                    }
                    if (resultArray.count >= 3){
                        break;
                    }
                }
                
                if (resultArray.count < 3){
                    NSArray *contact_list = [[ContactCacheDataManager instance] getAllCacheContact];
                    for (ContactCacheDataModel *contact in contact_list) {
                        bool isTouchpalUser = NO;
                        NSString *phoneNumber = nil;
                        for (PhoneDataModel *phoneData in contact.phones) {
                            NSString *normalNumber = [PhoneNumber getCNnormalNumber:phoneData.number];
                            if (normalNumber.length == 14 && [normalNumber hasPrefix:@"+861"]){
                                phoneNumber = normalNumber;
                            }else{
                                continue;
                            }
                            NSInteger resultCode = [TouchpalMembersManager isNumberRegistered:normalNumber];
                            if (resultCode == 1){
                                isTouchpalUser = YES;
                                break;
                            }
                        }
                        if (!isTouchpalUser&&phoneNumber){
                            if ( [numberArray containsObject:phoneNumber] )
                                continue;
                            UIImage *image= contact.image;
                            if ( !image ){
                                image = [PersonDBA getDefaultImageByPersonID:contact.personID isCootekUser:isTouchpalUser];
                            }
                            [resultArray addObject:@{@"displayName":contact.displayName,
                                                     @"number":phoneNumber,
                                                     @"image":image}];
                            [numberArray addObject:phoneNumber];
                        }
                        if (resultArray.count >= 3){
                            break;
                        }
                    }
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (resultArray.count){
                        AskLikeShareFirstViewController *vc = [[AskLikeShareFirstViewController alloc]init];
                        vc.resultArray = resultArray;
                        [[TouchPalDialerAppDelegate naviController] pushViewController:vc animated:YES];
                    }else{
                        AskLikeShareSecondViewController *vc = [[AskLikeShareSecondViewController alloc]init];
                        [[TouchPalDialerAppDelegate naviController] pushViewController:vc animated:YES];
                    }
                    
                    [indicator stopAnimating];
                });
            });
        });
    }else{
        AskLikeShareSecondViewController *vc = [[AskLikeShareSecondViewController alloc]init];
        [[TouchPalDialerAppDelegate naviController] pushViewController:vc animated:YES];
    }
    
    
    
}

@end

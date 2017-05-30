//
//  SelectController.m
//  TouchPalDialer
//
//  Created by game3108 on 16/4/12.
//
//

#import "SelectController.h"
#import "SelectViewController.h"
#import "TouchPalDialerAppDelegate.h"
#import "SelectArrayListFactory.h"
#import "ContactCacheDataManager.h"
#import "TouchpalMembersManager.h"
#import "SelectSingleController.h"

@interface SelectController()<SelectViewProtocalDelegate,SelectSingleControllerDeledate>{
    Boolean _isChooseSingle;
    void (^_resultBlock)(id);
    SelectType _selectType;
    SelectSingleController *_instrance;
}

@end


@implementation SelectController

+ (instancetype) sharedInstance{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void) pushSelectViewControllerBySelectType:(SelectType)type andIfSingle:(Boolean)ifSingle andResultBlock:(void(^)(id))resultBlock{
    _isChooseSingle = ifSingle;
    _resultBlock = resultBlock;
    _selectType = type;
    SelectViewController *select_temp = [[SelectViewController alloc] init];
    select_temp.dataList = [SelectArrayListFactory getSelectArrayBySelectType:type];
    select_temp.delegate = self;
    select_temp.commandName = @"选择联系人";
    if (ifSingle){
        select_temp.viewType = SelectViewNormal;
    }else{
        select_temp.viewType = SelectViewGroupCommandAll;
    }
    select_temp.isChooseSingle = ifSingle;
    UINavigationController *navController =
    ((TouchPalDialerAppDelegate *)[UIApplication sharedApplication].delegate).activeNavigationController;
    [navController pushViewController:select_temp animated:YES];
}

#pragma mark SelectViewProtocalDelegate
-(void)selectViewCancel{
    cootek_log(@"select cancel");
}

-(void)selectViewFinish:(NSArray *)select_list{
    NSMutableArray *resultArray = [[NSMutableArray alloc]init];
    for ( NSNumber *personID in select_list ){
        ContactCacheDataModel* personData = [[ContactCacheDataManager instance] contactCacheItem:[personID integerValue]];
        for (PhoneDataModel *phone in personData.phones) {
            if (_selectType == SelectTypeALL ){
                [resultArray addObject:@{@"name":personData.displayName,@"phone":phone.normalizedNumber}];
            }else if (_selectType == SelectTypeMOBILE){
                if ([phone.normalizedNumber hasPrefix:@"+861"] && phone.normalizedNumber.length == 14){
                    [resultArray addObject:@{@"name":personData.displayName,@"phone":phone.normalizedNumber}];
                }
            }else if (_selectType == SelectTypeCOOTEKER){
                NSInteger resultCode = [TouchpalMembersManager isNumberRegistered:phone.normalizedNumber];
                if ( resultCode == 1 ){
                    [resultArray addObject:@{@"name":personData.displayName,@"phone":phone.normalizedNumber}];
                }
            }
        }
        
    }
    
    _resultBlock([resultArray copy]);
}

-(void)selectItem:(SelectModel *)select_item{
    if (!_isChooseSingle)
        return;
    ContactCacheDataModel* personData = [[ContactCacheDataManager instance] contactCacheItem:select_item.personID];
    NSMutableArray *resultArray = [[NSMutableArray alloc]init];
    for (PhoneDataModel *phone in personData.phones) {
        if (_selectType == SelectTypeALL ){
            [resultArray addObject:@{@"name":personData.displayName,@"phone":phone.normalizedNumber}];
        }else if (_selectType == SelectTypeMOBILE){
            if ([phone.normalizedNumber hasPrefix:@"+861"] && phone.normalizedNumber.length == 14){
                [resultArray addObject:@{@"name":personData.displayName,@"phone":phone.normalizedNumber}];
            }
        }else if (_selectType == SelectTypeCOOTEKER){
            NSInteger resultCode = [TouchpalMembersManager isNumberRegistered:phone.normalizedNumber];
            if ( resultCode == 1 ){
                [resultArray addObject:@{@"name":personData.displayName,@"phone":phone.normalizedNumber}];
            }
        }
    }
    if ( resultArray.count > 1 ){
        _instrance = [[SelectSingleController alloc]init];
        _instrance.delegate = self;
        [_instrance showSelectViewBySelectArray:[resultArray copy]];
    } else if ( resultArray.count == 1) {
        _resultBlock([resultArray copy][0]);
    }
}

#pragma mark SelectSingleControllerDeledate

- (void)select:(NSDictionary *)dict{
    _resultBlock(dict);
    _instrance = nil;
}

@end

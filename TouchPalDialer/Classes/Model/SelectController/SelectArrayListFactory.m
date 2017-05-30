//
//  SelectArrayListFactory.m
//  TouchPalDialer
//
//  Created by game3108 on 16/4/12.
//
//

#import "SelectArrayListFactory.h"
#import "ContactCacheDataManager.h"
#import "TouchpalMembersManager.h"

@implementation SelectArrayListFactory
+ (NSArray *)getSelectArrayBySelectType:(SelectType) selectType{
    if ( selectType == SelectTypeALL ){
        return [self generateAllArray];
    }else if ( selectType == SelectTypeMOBILE ){
        return [self generateMobileArray];
    }else if ( selectType == SelectTypeCOOTEKER ){
        return [self generateCootekArray];
    }else{
        return nil;
    }
}

+ (NSArray *) generateAllArray{
    return [ContactCacheDataManager instance].getAllCacheContact;
}

+ (NSArray *) generateMobileArray{
    NSMutableArray *mobileArray = [[NSMutableArray alloc]init];
    NSArray *contacts = [ContactCacheDataManager instance].getAllCacheContact;
    for (ContactCacheDataModel *model in contacts) {
        for (PhoneDataModel *phone in model.phones) {
            NSString *number = [PhoneNumber getCNnormalNumber:phone.number];
            if ([number hasPrefix:@"+861"] && number.length == 14){
                [mobileArray addObject:model];
                break;
            }
        }
    }
    return [mobileArray copy];
}

+ (NSArray *) generateCootekArray{
    NSMutableArray *cootekArray = [[NSMutableArray alloc]init];
    NSArray *contacts = [ContactCacheDataManager instance].getAllCacheContact;
    for (ContactCacheDataModel *model in contacts) {
        for (PhoneDataModel *phone in model.phones) {
            NSString *number = [PhoneNumber getCNnormalNumber:phone.number];
            if ([number hasPrefix:@"+861"] && number.length == 14){
                NSInteger resultCode = [TouchpalMembersManager isNumberRegistered:number];
                if ( resultCode == 1 ){
                    [cootekArray addObject:model];
                    break;
                }
            }
        }
    }
    return [cootekArray copy];
}


@end

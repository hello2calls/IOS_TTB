//
//  ContactGroupModel.m
//  TouchPalDialer
//
//  Created by ALEX on 16/9/20.
//
//

#import "TPDContactGroupModel.h"
#include "LangUtil.h"
#import "AttributeModel.h"
#import "ContactPropertyCacheManager.h"
#import <AddressBook/ABPerson.h>
#import "ContactCacheDataManager.h"

@implementation TPDContactGroupModel

+ (NSArray *)loadCompaniesContactGroupModel {
 
    NSMutableDictionary *companyDictionary = [NSMutableDictionary dictionary];
    NSArray *companyArray = [[ContactPropertyCacheManager shareManager] valuesByPropertyID:kABPersonOrganizationProperty];
    
    for(AttributeModel *companyAttr in companyArray){
        NSString *company =  [companyAttr attribute];
        if(company.length > 0){
            NSMutableArray *IdsInCompany = [companyDictionary objectForKey:company];
            if(IdsInCompany == nil){
                IdsInCompany = [NSMutableArray array];
                 ContactCacheDataModel *contact = [[ContactCacheDataManager instance] contactCacheItem:companyAttr.personID];
                [IdsInCompany addObject:contact];
                [companyDictionary setValue:IdsInCompany forKey:company];
            }else{
                ContactCacheDataModel *contact = [[ContactCacheDataManager instance] contactCacheItem:companyAttr.personID];
                [IdsInCompany addObject:contact];
                [companyDictionary setValue:IdsInCompany forKey:company];
            }
        }
    }
    
    NSMutableArray *sortedContactGroups = [NSMutableArray array];
    
    NSArray *sortedCandidateKeyArr = [[companyDictionary allKeys] sortedArrayUsingComparator:^NSComparisonResult(NSString *  _Nonnull obj1, NSString *  _Nonnull obj2) {
        
        NSArray *obj1Arr = [companyDictionary objectForKey:obj1];
        NSArray *obj2Arr = [companyDictionary objectForKey:obj2];

        if (obj1Arr.count > obj2Arr.count) {
            return NSOrderedAscending;
        } else  if (obj1Arr.count == obj2Arr.count) {
            
            wchar_t letter_1 = NSStringToFirstWchar(obj1);
            wchar_t letter_2 = NSStringToFirstWchar(obj2);
            wchar_t char_1 = getFirstLetter(letter_1);
            wchar_t char_2 = getFirstLetter(letter_2);
            if (char_1 > char_2) {
                return NSOrderedDescending;
            } else if (char_1 == char_2) {
                if (letter_1 > letter_2) {
                    return NSOrderedDescending;
                } else if (letter_1 == letter_2) {
                    return NSOrderedSame;
                } else {
                    return NSOrderedAscending;
                }
            } else {
                return NSOrderedAscending;
            }

        } else {
            return NSOrderedDescending;
        }
    }];
    
    for (NSString *sortedCandidateKey in sortedCandidateKeyArr) {
        
        TPDContactGroupModel *groupModel = [[TPDContactGroupModel alloc] init];
        groupModel.candidateKey = [sortedCandidateKey copy];
        groupModel.contacts = [[companyDictionary valueForKey:sortedCandidateKey] copy];
        
        [sortedContactGroups addObject:groupModel];
    }
        
    return sortedContactGroups;
        
}

@end

//
//  AntiharassAdressbookUtil.m
//  TouchPalDialer
//
//  Created by game3108 on 15/9/11.
//
//

#import "AntiharassAdressbookUtil.h"
#import "AntiharassInfo.h"
#import "TPDialerResourceManager.h"

@implementation AntiharassAdressbookUtil

+ (BOOL) addAntiharassToAddressbook:(NSArray *)array andIndex:(NSInteger)index{
    CFErrorRef error = NULL;
    NSLog(@"%@", [self description]);
    ABAddressBookRef iPhoneAddressBook = [TPAddressBookWrapper RetrieveAddressBookRefForCurrentThread];
    ABRecordRef newPerson = ABPersonCreate();
    
    ABMutableMultiValueRef multiPhone =  ABMultiValueCreateMutable(kABMultiStringPropertyType);
    
    CFStringRef customLabel = (__bridge CFStringRef)[NSString stringWithFormat:@"#触宝防骚扰号码库chubao%d",index];
    NSString *number = [NSString stringWithFormat:@"#0触宝防骚扰号码库chubao%d",index];
    
    ABMultiValueAddValueAndLabel(multiPhone, (__bridge CFTypeRef)(number), customLabel, NULL);
    for (int i = 0 ; i < array.count ; i ++ ) {
        AntiharassInfo *info = [array objectAtIndex:i];
        NSString *infoNumber = info.number;
        if ( [infoNumber hasPrefix:@"+"] ){
            infoNumber = [infoNumber substringFromIndex:1];
        }
        NSString *number = [NSString stringWithFormat:@"*%@;",infoNumber];
        customLabel = [self getTagNameFromTagIndex:info.tag];
        ABMultiValueAddValueAndLabel(multiPhone, (__bridge CFTypeRef)(number), customLabel, NULL);
    }

    UIImage *headIcon = [TPDialerResourceManager getImage:@"antiharass_head_icon@2x.png"];
    if ( headIcon != nil ){
        NSData *dataRef = UIImagePNGRepresentation(headIcon);
        ABPersonSetImageData(newPerson, (__bridge CFDataRef) dataRef, NULL);
    }
    ABRecordSetValue(newPerson, kABPersonPhoneProperty, multiPhone,nil);
    CFRelease(multiPhone);
    ABAddressBookAddRecord(iPhoneAddressBook, newPerson, &error);
    ABAddressBookSave(iPhoneAddressBook, &error);
    CFRelease(customLabel);
    CFRelease(newPerson);
    if (error != NULL)
    {
        CFStringRef errorDesc = CFErrorCopyDescription(error);
        NSLog(@"antiharass save error %@", errorDesc);
        CFRelease(errorDesc);
        return NO;
    }else{
        //[UserDefaultsManager setBoolValue:YES forKey:VOIP_BACK_CALL_NAME_SAVED];
    }
    
    return YES;
}

+ (BOOL) removeAntiharassAddressbook{
    CFErrorRef error = NULL;
    ABAddressBookRef addressBook =  [TPAddressBookWrapper RetrieveAddressBookRefForCurrentThread];
    NSArray *array = (__bridge NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook);
    for (id obj in array) {
        ABRecordRef people = (__bridge ABRecordRef)obj;
        if ( [self isTouchpalAntiharass:people] )
            ABAddressBookRemoveRecord(addressBook, people, &error);
    }
    ABAddressBookSave(addressBook, &error);
    if (error != NULL){
        CFStringRef errorDesc = CFErrorCopyDescription(error);
        NSLog(@"antiharass delete error %@", errorDesc);
        CFRelease(errorDesc);
        return NO;
    }
    return YES;
}
+ (BOOL) removeAntiharassAddressbookAtbackgrondOfOthers{
    CFErrorRef error = NULL;
    ABAddressBookRef addressBook =  [TPAddressBookWrapper RetrieveAddressBookRefForCurrentThread];
    NSArray *array = (__bridge NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook);
    for (id obj in array) {
        ABRecordRef people = (__bridge ABRecordRef)obj;
        if ( [self isOtherAntiharass:people] )
            ABAddressBookRemoveRecord(addressBook, people, &error);
    }
    ABAddressBookSave(addressBook, &error);
    if (error != NULL){
        CFStringRef errorDesc = CFErrorCopyDescription(error);
        NSLog(@"antiharass delete error %@", errorDesc);
        CFRelease(errorDesc);
        return NO;
    }
    return YES;
}

+ (CFStringRef ) getTagNameFromTagIndex:(NSInteger)tagIndex{
    switch (tagIndex) {
        case 1:
            return (__bridge CFStringRef) @"触宝识别｜房产中介";
        case 5:
            return (__bridge CFStringRef) @"触宝识别｜业务推销";
        case 10:
            return (__bridge CFStringRef) @"触宝识别｜骚扰电话";
        case 11:
            return (__bridge CFStringRef) @"触宝识别｜诈骗钓鱼";
        default:
            return nil;
    }
}

+ (BOOL) isTouchpalAntiharass: (ABRecordRef) people{
    ABMultiValueRef phones = ABRecordCopyValue(people, kABPersonPhoneProperty);
    if (phones) {
        CFStringRef label = ABMultiValueCopyLabelAtIndex(phones, 0);
        CFStringRef tmpString = ABAddressBookCopyLocalizedLabel(label);
        NSString *labelString = (__bridge NSString *)tmpString;
        
        CFStringRef tmpStringValue = ABMultiValueCopyValueAtIndex(phones, 0);
        NSString *valueString = (__bridge NSString *)tmpStringValue;
        
        if ([labelString hasPrefix:@"#触宝防骚扰号码库chubao"] || [valueString hasPrefix:@"#0触宝防骚扰号码库chubao"] || [labelString hasPrefix:@"#触宝识别chubao"] || [valueString hasPrefix:@"#0触宝识别chubao"]){
            return YES;
        }
    }
    return NO;
}
+ (BOOL) isOtherAntiharass: (ABRecordRef) people{
    ABMultiValueRef phones = ABRecordCopyValue(people, kABPersonPhoneProperty);
    if (phones) {
        CFStringRef label = ABMultiValueCopyLabelAtIndex(phones, 0);
        CFStringRef tmpString = ABAddressBookCopyLocalizedLabel(label);
        NSString *labelString = (__bridge NSString *)tmpString;
        
        CFStringRef tmpStringValue = ABMultiValueCopyValueAtIndex(phones, 0);
        NSString *valueString = (__bridge NSString *)tmpStringValue;
        
        if (([labelString hasPrefix:@"标识"] &&[valueString hasPrefix:@"^haoma"])||([labelString hasPrefix:@"#360识别"] &&[valueString hasPrefix:@"#360haoma"]))
            return YES;
    }
    return NO;
}

@end

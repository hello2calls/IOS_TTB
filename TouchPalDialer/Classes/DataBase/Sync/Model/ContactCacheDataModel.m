//
//  ContactCacheDataModel.m
//  AddressBook_DB
//
//  Created by Alice on 11-7-25.
//  Copyright 2011 CooTek. All rights reserved.
//

#import "ContactCacheDataModel.h"
#import "NumberPersonMappingModel.h"
#import "PhoneDataModel.h"
#import "OrlandoEngine.h"
#import "PersonDBA.h"
#import "PhoneNumber.h"

@implementation ContactCacheDataModel

@synthesize personID;
@synthesize lastUpdateTime;

@synthesize fullName;
@synthesize displayName;
@synthesize jobTitle;
@synthesize birthday;
@synthesize company;
@synthesize note;
@synthesize nickName;
@synthesize createDate;
@synthesize department;
@synthesize number;

@synthesize IMs;
@synthesize localSocialProfiles;
@synthesize phones;
@synthesize abAddressBookPhones;
@synthesize address;
@synthesize URLs;
@synthesize emails;
@synthesize relatedNames;
@synthesize dates;
@synthesize isChecked;

@synthesize image;

+ (void)initialize
{
    currentPhoneID = 1;
}

+ (NSInteger)getCurrentPhoneId {
    return ++currentPhoneID;
}

-(id) initWithPersonID:(NSInteger)Id
              fullName:(NSString *)name
            lastUpdate:(NSInteger)time
                 Phone:(NSMutableArray *)numbers;
{
	self = [super init];
	if(self != nil){
        self.phones = numbers;
        self.personID = Id;
        self.fullName = [name length] > 0 ? name : @"";
        self.lastUpdateTime = time;
        self.isChecked = NO;
	}
	return self;
}

- (PhoneDataModel *)mainPhone
{
    if ([phones count] == 0) {
        return nil;
    }
    if ([phones count] == 1) {
        return [phones objectAtIndex:0];
    }
    LabelDataModel *num = [PersonDBA mainNumberByRecordID:personID];
    if ([num.labelValue length] > 0) {
        NSString *mainNum = [[PhoneNumber sharedInstance] getNormalizedNumber:num.labelValue];
        for (PhoneDataModel *phone in phones) {
            if ([phone.normalizedNumber isEqualToString:mainNum]) {
                return phone;
            }
        }
    }
    return [phones objectAtIndex:0];
}

- (NSString *)displayName
{
    if (displayName) {
        return displayName;
    }
    NSString *mTmpDisplayName = self.fullName;
    if ([mTmpDisplayName length] == 0) {
        NSArray *tmpEmails = [self emails];
        if ([tmpEmails count]  > 0) {
            for (int i = 0; i < [tmpEmails count]; i++) {
                LabelDataModel *email = [tmpEmails objectAtIndex:i];
                if ([email.labelValue length] > 0 ) {
                    mTmpDisplayName = email.labelValue;
                    break;
                }
            }
        }
        if ([mTmpDisplayName length] == 0) {
            PhoneDataModel *main_phone = [self mainPhone];
            if (main_phone) {
                mTmpDisplayName = main_phone.number;
            }
        }
    }
	self.displayName = mTmpDisplayName;
    return displayName;
}

- (void)addToEngine:(OrlandoEngine *)engineInstance
{
    BOOL isNumber = [phones count] > 0 ? YES : NO;
    [engineInstance addContactToEngine:personID fullName:fullName hasNumber:isNumber];
    for (PhoneDataModel *tmp in phones){
        tmp.phoneID = ++currentPhoneID;
        [engineInstance addNumberToContact:personID
                                withNumber:tmp.number
                               withPhoneID:currentPhoneID];
    }
}
- (void)initNameToEngine:(OrlandoEngine *)engineInstance
{
    BOOL isNumber = [phones count] > 0 ? YES : NO;
    [engineInstance initContactToEngine:personID fullName:fullName hasNumber:isNumber];
}

- (void)initNumberToEngine:(OrlandoEngine *)engineInstance
{
    for (PhoneDataModel *tmp in phones){
        [engineInstance initNumberToContact:personID
                                 withNumber:tmp.number
                                withPhoneID:tmp.phoneID];
    }
}
- (void)removeToEngine:(OrlandoEngine *)engineInstance
{
    for (PhoneDataModel *phone in phones){
        [[OrlandoEngine instance] deleteNumberToContact:phone.number
                                              contactID:personID
                                                phoneID:phone.phoneID];
    }
    [engineInstance deleteContactByPersonID:personID];
}

- (UIImage *)image
{
    if (!image) {
        self.image = [PersonDBA getImageByRecordID:personID];
    }
    return image;
}

- (NSArray *)emails
{
    if (!emails) {
        self.emails = [PersonDBA getEmailsByRecordID:personID];
    }
    return emails;
}

- (NSString *)note
{
    if (!note) {
        self.note = [PersonDBA getNoteByRecordID:personID];
    }
    return note;
}

- (NSString *)createDate
{
    if (!createDate) {
        self.createDate = [PersonDBA getCreateDateByRecordID:personID];
    }
    return createDate;
}

@end

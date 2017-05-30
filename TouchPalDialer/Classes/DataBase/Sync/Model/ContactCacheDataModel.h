//
//  ContactCacheDataModel.h
//  AddressBook_DB
//
//  Created by Alice on 11-7-25.
//  Copyright 2011 CooTek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LabelDataModel.h"
#import "PhoneDataModel.h"
#import "OrlandoEngine+Contact.h"

volatile static NSInteger currentPhoneID;

@interface ContactCacheDataModel : NSObject

@property(nonatomic,assign) NSInteger personID;
@property(nonatomic,assign) NSInteger lastUpdateTime;

@property(nonatomic,copy) NSString *fullName;
@property(nonatomic,copy) NSString *displayName;
@property(nonatomic,copy) NSString *company;
@property(nonatomic,copy) NSString *birthday;
@property(nonatomic,copy) NSString *note;
@property(nonatomic,copy) NSString *createDate;
@property(nonatomic,copy) NSString *nickName;
@property(nonatomic,copy) NSString *department;
@property(nonatomic,copy) NSString *jobTitle;
// [Thomas]hack for gesture search
@property(nonatomic,copy) NSString *number;

@property(nonatomic,retain) NSMutableArray *phones;
@property(nonatomic,retain) NSArray *abAddressBookPhones;
@property(nonatomic,retain) NSArray *emails;
@property(nonatomic,retain) NSArray *address;
@property(nonatomic,retain) NSArray *URLs;
@property(nonatomic,retain) NSArray *IMs;
@property(nonatomic,retain) NSArray *dates;
@property(nonatomic,retain) NSArray *relatedNames;
@property(nonatomic,retain) NSArray *localSocialProfiles;
@property(nonatomic,assign) BOOL isChecked;

@property(nonatomic,retain) UIImage *image;

+ (NSInteger)getCurrentPhoneId;

- (id)initWithPersonID:(NSInteger)personID
              fullName:(NSString *)name
            lastUpdate:(NSInteger)time
                 Phone:(NSMutableArray *)numbers;

- (PhoneDataModel *)mainPhone;

- (void)addToEngine:(OrlandoEngine *)engineInstance;

- (void)initNameToEngine:(OrlandoEngine *)engineInstance;

- (void)initNumberToEngine:(OrlandoEngine *)engineInstance;

- (void)removeToEngine:(OrlandoEngine *)engineInstance;

@end

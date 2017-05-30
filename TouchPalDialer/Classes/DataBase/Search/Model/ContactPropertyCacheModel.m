//
//  ContractCacheModel.m
//  TouchPalDialer
//
//  Created by Alice on 11-8-2.
//  Copyright 2011 CooTek. All rights reserved.
//

#import "ContactPropertyCacheModel.h"
#import <AddressBook/AddressBook.h>
#import "LabelDataModel.h"
#import "AttributeModel.h"
#import "PersonDBA.h"
#import "CootekNotifications.h"
#import "ContactCacheDataModel.h"

@interface ContactPropertyCacheModel ()

@property(nonatomic,retain) NSMutableDictionary *contactPopertyMapValueDict;

@end

@implementation ContactPropertyCacheModel

@synthesize contactPropertyValues;
@synthesize contactPopertyMapValueDict;

-(id)initWithPersonList:(NSArray *)person_list
          AttributeName:(NSInteger)attr
{
	self = [super init];
	if(self != nil){
		NSMutableArray  *tmpArray=[[NSMutableArray alloc] init];
		self.contactPropertyValues=tmpArray;
        
        NSMutableDictionary  *tmpDictionary=[[NSMutableDictionary alloc] init];
		self.contactPopertyMapValueDict= tmpDictionary;
        
		for (ContactCacheDataModel * person in person_list) {
			[self addCacheItem:person AttributeName:attr];			
		}		
	}
	return self;
}
-(void)editWithPerson:(NSInteger)personID
        AttributeName:(NSInteger)attr
             withType:(NSInteger)type
{
    if (personID > 0) {
        switch (type) {
            case ContactChangeTypeModify:{
                ContactCacheDataModel *person = [PersonDBA getConatctInfoByRecordID:personID];
                [self updateCacheItem:person AttributeName:attr];
                break;
            }
            case ContactChangeTypeDelete:
                [self deleteCacheItem:personID AttributeName:attr];
                break;    
            case ContactChangeTypeAdd:{
                ContactCacheDataModel *person = [PersonDBA getConatctInfoByRecordID:personID usingCNContact:NO];
                 [self addCacheItem:person AttributeName:attr];
                break; 
            }
            default:
                break;
        }        
    }
}

- (void)addCacheItem:(ContactCacheDataModel *)person
       AttributeName:(NSInteger)attr
{

	if (attr == kABPersonNicknameProperty && [person.nickName length] > 0) {
		AttributeModel *attr_item = [[AttributeModel alloc] init];
		attr_item.personID = person.personID;
		attr_item.attribute = [person nickName]; 
		[contactPropertyValues addObject:attr_item];
		
        NSString *key = [NSString stringWithFormat:@"%d_%d",person.personID,attr];
        [contactPopertyMapValueDict setObject:attr_item forKey:key];
		return;
	}
	if (attr == kABPersonOrganizationProperty && [person.company length] > 0) {
		AttributeModel *attr_item = [[AttributeModel alloc] init];
		attr_item.personID = person.personID;
		attr_item.attribute = [person company]; 
		[contactPropertyValues addObject:attr_item];
        NSString *key = [NSString stringWithFormat:@"%d_%d",person.personID,attr];
        [contactPopertyMapValueDict setObject:attr_item forKey:key];
		return;
	}
	if (attr == kABPersonJobTitleProperty && [person.jobTitle length] > 0) {
		AttributeModel *attr_item = [[AttributeModel alloc] init];
		attr_item.personID = person.personID;
		attr_item.attribute = [person jobTitle];
		[contactPropertyValues addObject:attr_item];
        NSString *key = [NSString stringWithFormat:@"%d_%d",person.personID,attr];
        [contactPopertyMapValueDict setObject:attr_item forKey:key];
		return;
	}
	if (attr==kABPersonDepartmentProperty && [person.department length] > 0) {
		AttributeModel *attr_item = [[AttributeModel alloc] init];
		attr_item.personID = person.personID;
		attr_item.attribute = [person department]; 
		[contactPropertyValues addObject:attr_item];
        
        NSString *key = [NSString stringWithFormat:@"%d_%d",person.personID,attr];
        [contactPopertyMapValueDict setObject:attr_item forKey:key];
		return;
	}
	if (attr==kABPersonBirthdayProperty && [[person birthday] length] > 0) {
		AttributeModel *attr_item=[[AttributeModel alloc] init];
		attr_item.personID=person.personID;
		attr_item.attribute=[person birthday]; 
		[contactPropertyValues addObject:attr_item];
        
        NSString *key = [NSString stringWithFormat:@"%d_%d",person.personID,attr];
        [contactPopertyMapValueDict setObject:attr_item forKey:key];
		return;
	}
    if (attr ==  kABPersonCreationDateProperty && [[person createDate] length] > 0) {
		AttributeModel *attr_item=[[AttributeModel alloc] init];
		attr_item.personID=person.personID;
		attr_item.attribute=[person createDate];
		[contactPropertyValues addObject:attr_item];
        
        NSString *key = [NSString stringWithFormat:@"%d_%d",person.personID,attr];
        [contactPopertyMapValueDict setObject:attr_item forKey:key];
		return;
	}
	if (attr == kABPersonNoteProperty && [[person note] length] > 0) {
		AttributeModel *attr_item=[[AttributeModel alloc] init];
		attr_item.personID=person.personID;
		attr_item.attribute=[person note];
		[contactPropertyValues addObject:attr_item];
        
        NSString *key = [NSString stringWithFormat:@"%d_%d",person.personID,attr];
        [contactPopertyMapValueDict setObject:attr_item forKey:key];
		return;
	}
	//多值
	if (attr == kABPersonEmailProperty && [person.emails count] > 0) {
		AttributeModel *attr_item=[[AttributeModel alloc] init];
		attr_item.personID=person.personID;
		attr_item.attribute=[person emails];
		[contactPropertyValues addObject:attr_item];
        
        NSString *key = [NSString stringWithFormat:@"%d_%d",person.personID,attr];
        [contactPopertyMapValueDict setObject:attr_item forKey:key];
		return;
	}

	if (attr == kABPersonAddressProperty && [[person address] count] > 0) {
		AttributeModel *attr_item=[[AttributeModel alloc] init];
		attr_item.personID=person.personID;
		attr_item.attribute=[person address]; 
		[contactPropertyValues addObject:attr_item];
        
        NSString *key = [NSString stringWithFormat:@"%d_%d",person.personID,attr];
        [contactPopertyMapValueDict setObject:attr_item forKey:key];
		return;
	}
	if (attr == kABPersonDateProperty && [[person dates] count] > 0) {
		AttributeModel *attr_item=[[AttributeModel alloc] init];
		attr_item.personID=person.personID;
		attr_item.attribute=[person dates]; 
		[contactPropertyValues addObject:attr_item];
        
        NSString *key = [NSString stringWithFormat:@"%d_%d",person.personID,attr];
        [contactPopertyMapValueDict setObject:attr_item forKey:key];
		return;
	}

	if (attr == kABPersonInstantMessageProperty && [[person IMs] count] > 0) {
		AttributeModel *attr_item = [[AttributeModel alloc] init];
		//查询账户 忽略账户类型 QQ:249572930
		attr_item.personID = person.personID;
		attr_item.attribute = [person IMs]; 
		[contactPropertyValues addObject:attr_item];	
        
        NSString *key = [NSString stringWithFormat:@"%d_%d",person.personID,attr];
        [contactPopertyMapValueDict setObject:attr_item forKey:key];
		return;
	}
	if (attr == kABPersonURLProperty && [[person URLs] count] > 0) {
		AttributeModel *attr_item = [[AttributeModel alloc] init];
		attr_item.personID = person.personID;
		attr_item.attribute = [person URLs]; 
		[contactPropertyValues addObject:attr_item];
        
        NSString *key = [NSString stringWithFormat:@"%d_%d",person.personID,attr];
        [contactPopertyMapValueDict setObject:attr_item forKey:key];
		return;
	}
}

- (void)updateCacheItem:(ContactCacheDataModel *)person
          AttributeName:(ABPropertyID)attr
{

    if (attr == kABPersonNicknameProperty) {
        NSString *key = [NSString stringWithFormat:@"%d_%d",person.personID,attr];
		AttributeModel *attr_item = [contactPopertyMapValueDict objectForKey:key];
        if (!attr_item) {
            attr_item = [[AttributeModel alloc] init];
            attr_item.personID = person.personID;
            attr_item.attribute = [person nickName];             
            [contactPropertyValues addObject:attr_item];
            [contactPopertyMapValueDict setObject:attr_item forKey:key];
        }else{
            attr_item.personID = person.personID;
            attr_item.attribute = [person nickName];
        }
		return;
	}
	if (attr == kABPersonOrganizationProperty) {
        NSString *key = [NSString stringWithFormat:@"%d_%d",person.personID,attr];
		AttributeModel *attr_item = [contactPopertyMapValueDict objectForKey:key];
        if (!attr_item) {
            attr_item = [[AttributeModel alloc] init];
            attr_item.personID = person.personID;
            attr_item.attribute = [person company];             
            [contactPropertyValues addObject:attr_item];
            [contactPopertyMapValueDict setObject:attr_item forKey:key];
        }else{
            attr_item.personID = person.personID;
            attr_item.attribute = [person company]; 
        }
		return;
	}
	if (attr == kABPersonJobTitleProperty) {
        NSString *key = [NSString stringWithFormat:@"%d_%d",person.personID,attr];
		AttributeModel *attr_item = [contactPopertyMapValueDict objectForKey:key];
        if (!attr_item) {
            attr_item = [[AttributeModel alloc] init];
            attr_item.personID = person.personID;
            attr_item.attribute = [person jobTitle];
            [contactPropertyValues addObject:attr_item];
            [contactPopertyMapValueDict setObject:attr_item forKey:key];
        }else{
            attr_item.personID = person.personID;
            attr_item.attribute = [person jobTitle];
        }
		return;
	}
	if (attr == kABPersonDepartmentProperty) {
        NSString *key = [NSString stringWithFormat:@"%d_%d",person.personID,attr];
		AttributeModel *attr_item = [contactPopertyMapValueDict objectForKey:key];
        if (!attr_item) {
            attr_item = [[AttributeModel alloc] init];
            attr_item.personID = person.personID;
            attr_item.attribute = [person department];             
            [contactPropertyValues addObject:attr_item];
            [contactPopertyMapValueDict setObject:attr_item forKey:key];
        }else{
            attr_item.personID = person.personID;
            attr_item.attribute = [person department]; 
        }
		return;
	}
	if (attr==kABPersonBirthdayProperty) {
        NSString *key = [NSString stringWithFormat:@"%d_%d",person.personID,attr];
		AttributeModel *attr_item= [contactPopertyMapValueDict objectForKey:key];
        if (!attr_item) {
            attr_item=[[AttributeModel alloc] init];
            attr_item.personID=person.personID;
            attr_item.attribute=[person birthday];             
            [contactPropertyValues addObject:attr_item];
            [contactPopertyMapValueDict setObject:attr_item forKey:key];
        }else{
            attr_item.personID=person.personID;
            attr_item.attribute=[person birthday];
        }

		return;
	}
    if (attr == kABPersonCreationDateProperty) {
        NSString *key = [NSString stringWithFormat:@"%d_%d",person.personID,attr];
		AttributeModel *attr_item = [contactPopertyMapValueDict objectForKey:key];
        if (!attr_item) {
            attr_item = [[AttributeModel alloc] init];
            attr_item.personID = person.personID;
            attr_item.attribute = [person createDate];
            [contactPropertyValues addObject:attr_item];
            [contactPopertyMapValueDict setObject:attr_item forKey:key];
        }else{
            attr_item.personID = person.personID;
            attr_item.attribute = [person createDate];
        }
		return;
	}
    
	if (attr == kABPersonNoteProperty) {
        NSString *key = [NSString stringWithFormat:@"%d_%d",person.personID,attr];
		AttributeModel *attr_item = [contactPopertyMapValueDict objectForKey:key];
        if (!attr_item) {
            attr_item = [[AttributeModel alloc] init];
            attr_item.personID = person.personID;
            attr_item.attribute = [person note];
            [contactPropertyValues addObject:attr_item];
            [contactPopertyMapValueDict setObject:attr_item forKey:key];
        }else{
            attr_item.personID = person.personID;
            attr_item.attribute = [person note];
        }
		return;
	}
	//多值
	if (attr == kABPersonEmailProperty) {
        NSString *key = [NSString stringWithFormat:@"%d_%d",person.personID,attr];
		AttributeModel *attr_item = [contactPopertyMapValueDict objectForKey:key];
        if (!attr_item) {
            attr_item = [[AttributeModel alloc] init];
            attr_item.personID = person.personID;
            attr_item.attribute = [person emails];
            [contactPropertyValues addObject:attr_item];
            [contactPopertyMapValueDict setObject:attr_item forKey:key];
        }else{
            attr_item.personID = person.personID;
            attr_item.attribute = [person emails];
        }
		return;
	}
	//
	if (attr==kABPersonAddressProperty) {
		//地址需要meger
        NSString *key = [NSString stringWithFormat:@"%d_%d",person.personID,attr];
		AttributeModel *attr_item = [contactPopertyMapValueDict objectForKey:key];
        if (!attr_item) {
            attr_item = [[AttributeModel alloc] init];
            attr_item.personID = person.personID;
            attr_item.attribute = [person address];             
            [contactPropertyValues addObject:attr_item];
            [contactPopertyMapValueDict setObject:attr_item forKey:key];
        }else{
            attr_item.personID=person.personID;
            attr_item.attribute=[person address]; 
        }
		return;
	}
	if (attr == kABPersonDateProperty) {
        NSString *key = [NSString stringWithFormat:@"%d_%d",person.personID,attr];
		AttributeModel *attr_item= [contactPopertyMapValueDict objectForKey:key];
        if (!attr_item) {
            attr_item=[[AttributeModel alloc] init];
            attr_item.personID=person.personID;
            attr_item.attribute=[person dates];             
            [contactPropertyValues addObject:attr_item];
            [contactPopertyMapValueDict setObject:attr_item forKey:key];
        }else{
            attr_item.personID=person.personID;
            attr_item.attribute=[person dates]; 
        }
		return;
	}
	//IM
	if (attr == kABPersonInstantMessageProperty) {
        NSString *key = [NSString stringWithFormat:@"%d_%d",person.personID,attr];
		AttributeModel *attr_item = [contactPopertyMapValueDict objectForKey:key];
        if (!attr_item) {
            attr_item = [[AttributeModel alloc] init];
            attr_item.personID = person.personID;
            attr_item.attribute = [person IMs];             
            [contactPropertyValues addObject:attr_item];
            [contactPopertyMapValueDict setObject:attr_item forKey:key];
        }else{
            //查询账户 忽略账户类型 QQ:249572930
            attr_item.personID = person.personID;
            attr_item.attribute = [person IMs]; 
        }
		return;
	}
	if (attr == kABPersonURLProperty) {
        NSString *key = [NSString stringWithFormat:@"%d_%d",person.personID,attr];
		AttributeModel *attr_item = [contactPopertyMapValueDict objectForKey:key];
        if (!attr_item) {
            attr_item = [[AttributeModel alloc] init];
            attr_item.personID = person.personID;
            attr_item.attribute = [person URLs];             
            [contactPropertyValues addObject:attr_item];
            [contactPopertyMapValueDict setObject:attr_item forKey:key];
        }else{
            attr_item.personID = person.personID;
            attr_item.attribute = [person URLs]; 
        }
		return;
	}
}
- (void)deleteCacheItem:(NSInteger)personID
          AttributeName:(NSInteger)attr
{
    NSString *key = [NSString stringWithFormat:@"%d_%d",personID,attr];
    AttributeModel *attr_item = [contactPopertyMapValueDict objectForKey:key];
    [contactPropertyValues removeObject:attr_item];
    [contactPopertyMapValueDict removeObjectForKey:key];
}
@end

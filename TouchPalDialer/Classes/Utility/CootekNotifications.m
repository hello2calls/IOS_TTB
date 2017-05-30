//
//  CootekNotifications.m
//  TouchPalDialer
//
//  Created by Sendor on 11-11-10.
//  Copyright 2011 Cootek. All rights reserved.
//
#import "CootekNotifications.h"

@implementation NotiPersonChangeData

@synthesize person_id;
@synthesize change_type;
@synthesize display_name;

- (id)initWithPersonId:(NSInteger)personId
            changeType:(ContactChangeType)changeType
{
    return [self initWithPersonId:personId
                       changeType:changeType
                      displayName:nil];

}

- (id)initWithPersonId:(NSInteger)personId
            changeType:(ContactChangeType)changeType
           displayName:(NSString*)displayName
{
    self = [super init];
    if (self) {
        person_id = personId;
        change_type = changeType;
        self.display_name = displayName;
    }
    return self;
}

@end


@implementation NotiGroupChangeData

@synthesize group_index;
@synthesize change_type;

- (id)initWithGroupIndex:(NSInteger)groupIndex
              changeType:(ContactChangeType)changeType
{
    self = [super init];
    if (self) {
        group_index = groupIndex;
        change_type = changeType;
    }
    return self;
}

@end


@implementation NotiPersonGroupChangeData

@synthesize groupID;
@synthesize personID;
@synthesize change_type;

- (id)initWithGroupContact:(NSInteger)m_groupID
              withPersonID:(NSInteger)m_personID
                changeType:(ContactGroupChangeType)m_changeType
{
    self = [super init];
    if (self) {
        groupID = m_groupID;
		personID = m_personID;
        change_type = m_changeType;
    }
    return self;
}

@end


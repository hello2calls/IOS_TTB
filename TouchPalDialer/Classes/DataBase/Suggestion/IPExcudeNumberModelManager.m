//
//  IPExcudeNumberModelManager.m
//  TouchPalDialer
//
//  Created by lingmei xie on 13-3-22.
//
//

#import "IPExcudeNumberModelManager.h"
#import "UserDefaultsManager.h"
#import "PhoneNumber.h"
#import "NSString+PhoneNumber.h"
#import "ContactCacheDataManager.h"

@interface IPExcudeNumberModelManager()
@property (nonatomic, retain) NSMutableArray *excludedMembers;
@end

@implementation IPExcudeNumberModelManager

static IPExcudeNumberModelManager  *sharedManager_ = nil;

@synthesize excludedMembers;

+ (IPExcudeNumberModelManager *)sharedManager
{
    if (sharedManager_) {
        return sharedManager_;
    }
    
    @synchronized(self){
        if (!sharedManager_) {
            sharedManager_ = [[super allocWithZone:NULL] init];
        }
    }
    return sharedManager_;
}

+(id)allocWithZone:(NSZone *)zone
{
    return [self sharedManager];
}

- (id) init
{
	self = [super init];
	if(self != nil){
        [self prepareExcludeList];
	}
	return self;
}

- (void)prepareExcludeList
{
    NSArray *originalArray = [UserDefaultsManager arrayForKey:EXCLUDED_MEMBERS_FOR_IP_RULES];
    if(originalArray){
        self.excludedMembers = [NSMutableArray arrayWithArray:originalArray];
        return;
    }
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    NSString *excludedMemberFilePath = [documentDirectory stringByAppendingPathComponent:@"excludedFromSmartDialList.plist"];
    NSDictionary *originalExcludedDic = [NSDictionary dictionaryWithContentsOfFile:excludedMemberFilePath];
    if(originalExcludedDic){
        NSArray *numbers = [originalExcludedDic allKeys];
        NSMutableArray *newNumbers = [[NSMutableArray alloc] initWithCapacity:numbers.count];
        for(NSString * number in numbers){
            [newNumbers addObject:[[PhoneNumber sharedInstance] getNormalizedNumber:[number digitNumber]]];
        }
        self.excludedMembers = newNumbers;
        [self persistExcludedMembers];
    }
}

#pragma mark functions related to Smart dial
- (void)addItemsToExcludedList:(NSArray *)numbers
{
    if(numbers.count <= 0){
        return;
    }
    if(self.excludedMembers == nil){
        self.excludedMembers = [NSMutableArray arrayWithCapacity:numbers.count];
    }
    for(NSString *number in numbers){
        [self.excludedMembers addObject:[[PhoneNumber sharedInstance] getNormalizedNumber:[number digitNumber]]];
    }
    [self persistExcludedMembers];
}

- (void)removeItemFromExcludedList:(NSString *)item
{
    NSString *normalizedItem = [[PhoneNumber sharedInstance] getNormalizedNumber:[item digitNumber]];
    [self.excludedMembers removeObject:normalizedItem];
    [self persistExcludedMembers];
}

- (NSArray *)getPersonListThatIsNotInExcludedList
{
    NSArray *allCachePersons = [ContactCacheDataManager instance].getAllCacheContact;
    NSMutableArray *personList = [[NSMutableArray alloc] initWithCapacity:allCachePersons.count];
    for(ContactCacheDataModel *person in allCachePersons){
        NSArray *numbers = [person phones];
        BOOL isIncluded = YES;
        for(PhoneDataModel *phone in numbers){
            if(![self.excludedMembers containsObject:[[PhoneNumber sharedInstance] getNormalizedNumber:[phone.number digitNumber]]]){
                isIncluded = NO;
                break;
            }
        }
        if(!isIncluded){
            [personList addObject:person];
        }
    }
    return personList;
}

- (void)persistExcludedMembers
{
    [UserDefaultsManager setObject:self.excludedMembers forKey:EXCLUDED_MEMBERS_FOR_IP_RULES];
}

- (BOOL)isThisNumberExcludedFromSmartDial:(NSString *)number
{
    NSString *normalizedItem = [[PhoneNumber sharedInstance] getNormalizedNumber:[number digitNumber]];
    return [self.excludedMembers containsObject:normalizedItem];
}

- (NSArray *)getExcludedFromSmartDialPersonList{
    return self.excludedMembers;
}

-(void) dealloc{
    self.excludedMembers = nil;
}
@end

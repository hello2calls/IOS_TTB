//
//  GestureSelectCell.m
//  TouchPalDialer
//
//  Created by ThomasYe on 13/8/18.
//
//

#import "GestureSelectCell.h"
#import "NSString+PhoneNumber.h"
#import "ContactCacheDataManager.h"
#import "ImageCacheModel.h"
#import "PersonDBA.h"
#import "TouchpalMembersManager.h"

@implementation GestureSelectCell

- (void)refreshDefault:(ContactCacheDataModel *)person  withIsCheck:(BOOL)is_check isShowNumber:(BOOL)is_show{
    
    self.personID=person.personID;
    self.m_main_number=person.number;
    self.attrName = [m_main_number formatPhoneNumber];
    
    ContactCacheDataModel *model = [[ContactCacheDataManager instance] contactCacheItem:personID];
    self.fullName = [model displayName];
    
    UIImage* defaultFacePhoto = [model image];
    if (!defaultFacePhoto) {
        defaultFacePhoto =  [PersonDBA getDefaultImageByPersonID: self.personID
                                                    isCootekUser: [TouchpalMembersManager isRegisteredByContactCachedModel:model]];
    }
    [self loadPersonData:defaultFacePhoto withNumberRange:NSMakeRange(0, 0) withNameRange:nil withShowNumber:is_show];
}


@end

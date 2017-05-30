//
//  PersonInfo.h
//  TouchPalDialer
//
//  Created by 袁超 on 15/5/26.
//
//

#import <Foundation/Foundation.h>
#define ALMARK @"person_almark"
#define MENG @"person_meng"
#define ADA @"person_ada"
#define LEMON @"person_lemon"
#define ALEX @"person_alex"
#define ALICE @"person_alice"

typedef enum {
    LOCAL_PHOTO,
    ALIYUN_PHOTO,
}PersonPhotoType;

typedef enum {
    MALE,
    FEMALE,
    UNKNOWN,
}PersonGender;

@interface PersonInfo : NSObject

@property (nonatomic, retain) NSString *photoUrl;
@property (nonatomic, assign) NSInteger photoType;
@property (nonatomic, assign) NSInteger gender;

@end

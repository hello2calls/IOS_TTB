//
//  ContactInfoModel.h
//  TouchPalDialer
//
//  Created by game3108 on 15/7/16.
//
//

#import <Foundation/Foundation.h>

typedef enum{
    noInfo,
    knownInfo,
    unknownInfo
}InfoType;

typedef enum{
    ContactHeaderNormal,
    ContactHeaderDelete,
    ContactHeaderNo
}ContactHeaderMode;

@interface ContactInfoModel : NSObject
@property (nonatomic,assign) InfoType infoType;
@property (nonatomic,assign) NSInteger personId;
@property (nonatomic,strong) NSString *phoneNumber;
@property (nonatomic,strong) UIImage *photoImage;
@property (nonatomic,strong) UIImage *bgImage;
@property (nonatomic,strong) NSString *firstStr;
@property (nonatomic,strong) NSString *secondStr;
@end

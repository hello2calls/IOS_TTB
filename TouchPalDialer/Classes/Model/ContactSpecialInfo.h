//
//  ContactSpecialInfo.h
//  TouchPalDialer
//
//  Created by game3108 on 15/4/21.
//
//

#import <Foundation/Foundation.h>

#define TOUCHPALER_NODE 1

typedef NS_ENUM(NSInteger, SpecialNodeType) {
    NODE_UNKOWN,
    NODE_MY_FAMILY,
    NODE_TOUCHPALER,
    NODE_CONTACT_SMART_GROUP,
    NODE_CONTACT_TRANSFER,
    NODE_CONTACT_INVITE
};

@interface ContactSpecialInfo : NSObject
@property (nonatomic,assign) NSInteger type;
@property (nonatomic,strong) NSString *imageName;
@property (nonatomic,strong) NSString *mainTitle;
@property (nonatomic,strong) NSString *subTitle;
@property (nonatomic,assign) NSInteger number;
@property (nonatomic) NSString *fontName; //without suffix
@property (nonatomic) NSString *text;
@property (nonatomic) NSString *textColorStyle; //
@property (nonatomic) NSString *bgColorStyle; //like `tp_color_light_blue_500`
@end

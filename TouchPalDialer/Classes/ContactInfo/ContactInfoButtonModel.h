//
//  ContactInfoButtonModel.h
//  TouchPalDialer
//
//  Created by game3108 on 15/7/20.
//
//

#import <Foundation/Foundation.h>
#import "ContactInfoModel.h"

typedef enum{
    knownCalllog = 0,
    knownGesture,
    knownShare,
    knownStore,
    unknownCallog,
    unknownCopy,
    unknownShare
}ButtonTag;

@interface ContactInfoButtonModel : NSObject
@property (nonatomic,strong) NSString* iconStr;
@property (nonatomic,strong) NSString* titleStr;
@property (nonatomic,assign) ButtonTag buttonTag;
@end

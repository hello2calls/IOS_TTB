//
//  TableItem.h
//  TouchPalDialer
//
//  Created by 袁超 on 15/6/9.
//
//

#import <Foundation/Foundation.h>

typedef enum {
    NORMAL_TYPE,
    INSERT_TYPE,
    DELETE_TYPE,
    UPDATE_TYPE,
}TableItemType;

@interface TableItem : NSObject

@property (nonatomic, assign)long long number;
@property (nonatomic, assign)NSInteger tag;
@property (nonatomic, retain)NSData *name;
@property (nonatomic, assign)NSInteger updateType;

@end

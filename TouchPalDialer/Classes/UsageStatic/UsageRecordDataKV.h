//
//  UsageRecordDataKV.h
//  TouchPalDialer
//
//  Created by 袁超 on 15/9/2.
//
//

#import <Foundation/Foundation.h>
@interface UsageRecordDataKV : NSObject 
@property (nonatomic) id recordValue;
@property (nonatomic) id recordKey;

- (id)initWithKey:(id)key withValue:(id)value;

@end

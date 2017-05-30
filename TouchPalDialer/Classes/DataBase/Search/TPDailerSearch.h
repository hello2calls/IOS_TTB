//
//  TPDailerSearch.h
//  TouchPalDialer
//
//  Created by lingmei xie on 12-12-4.
//
//

#import <Foundation/Foundation.h>
#import "TPSearch.h"
#import "PhonePadModel.h"

@interface TPDailerSearch : TPDefaultSearch

- (id)initWithKeyBoard:(DailerKeyBoardType)keyboradType
               calllog:(CalllogFilterType)calllogType;

- (void)setTPQueryCallog:(CalllogFilterType)type;

- (void)setKeyBoradType:(DailerKeyBoardType)type;

@end

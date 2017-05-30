//
//  DefaultHangupModelGenerator.h
//  TouchPalDialer
//
//  Created by Liangxiu on 15/7/29.
//
//

#import <Foundation/Foundation.h>
#import "HangupViewModelGenerator.h"

@interface BaseHangupModelGenerator : NSObject

@property (nonatomic, strong)HangupModel *hangupModel;

@property (nonatomic, weak)id<ModelChangeDelegate> changeDelegate;

- (id)initWithHangupModel:(HangupModel *)model;

- (HeaderViewModel *)getHeaderModel;

- (MiddleViewModel *)getMiddleModel;

- (MainActionViewModel *)getMainActionViewModel;

- (UIImage *)getBgImage;

- (NSString *)getErrorCode;
@end

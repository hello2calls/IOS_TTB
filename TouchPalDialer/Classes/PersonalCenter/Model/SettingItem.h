//
//  SettingModel.h
//  TouchPalDialer
//
//  Created by ALEX on 16/7/25.
//
//

#import <Foundation/Foundation.h>

typedef void(^HandleBlock)();

@interface SettingItem : NSObject

@property (nonatomic,copy)    NSString *title;
@property (nonatomic,copy)    NSString *subTitle;
@property (nonatomic,copy)    NSString *vcClass;
@property (nonatomic,copy)    HandleBlock handle;
@property (nonatomic,assign)  BOOL hiddenArrow;
@property (nonatomic,assign)  BOOL redDotHidden;


- (instancetype)initWithTitle:(NSString *)title subTitle:(NSString *)subtitle vcClass:(NSString *)vcClass handle:(HandleBlock)handle;
@end

//
//  AntiNormalItem.h
//  TouchPalDialer
//
//  Created by ALEX on 16/8/9.
//
//

#import <Foundation/Foundation.h>


typedef void(^HandleBlock)();

@interface AntiNormalItem : NSObject

@property (nonatomic,copy) NSString *title;
@property (nonatomic,copy) NSString *subtitle;
@property (nonatomic,copy) NSString *vcClass;
@property (nonatomic,copy) NSString *badge;
@property (nonatomic,copy) HandleBlock clickHandle;
@property (nonatomic,assign) CGFloat height;
@property (nonatomic,strong) NSAttributedString *attributedSubtitle;

+ (instancetype)itemWithTitle:(NSString *)title subtitle:(NSString *)subtitle vcClass:(NSString *)vcClass clickHandle:(HandleBlock)handle;

+ (instancetype)itemWithTitle:(NSString *)title attributedSubtitle:(NSAttributedString *)attributedSubtitle vcClass:(NSString *)vcClass clickHandle:(HandleBlock)handle;
@end

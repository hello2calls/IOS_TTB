//
//  FuwuhaoMessageView.h
//  TouchPalDialer
//
//  Created by Liangxiu on 15/8/5.
//
//

#import <Foundation/Foundation.h>
#import "PublicNumberMessage.h"
#import "YPUIView.h"
#import "VerticallyAlignedLabel.h"
#import "CTUrl.h"

@interface PublicNumberMessageView : YPUIView

-(id) initWithFrame:(CGRect)frame withPublicNumberMsg:(PublicNumberMessage*)model;
-(void) drawView:(PublicNumberMessage*)message;
+(int) getRowHeight:(PublicNumberMessage *)message;
+(CGSize) getSizeByText:(NSString* )text andUIFont:(UIFont *)font;
+(CGSize) getSizeByText:(NSString* )text andUIFont:(UIFont *)font andWidth:(CGFloat)width;

@property(nonatomic, strong)NSString* title;
@property(nonatomic, strong)NSDictionary* desc;
@property(nonatomic, strong)NSArray* keynotesAreas;
@property(nonatomic, strong)NSDictionary* remark;
@property(nonatomic, strong) PublicNumberMessage *message;
@property(nonatomic, strong) CTUrl* url;
@property(nonatomic, strong) VerticallyAlignedLabel* dateLabel;
@property(nonatomic, strong) NSDictionary* nativeUrl;
@end

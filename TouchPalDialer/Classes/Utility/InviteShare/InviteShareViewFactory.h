//
//  InviteShareViewFactory.h
//  TouchPalDialer
//
//  Created by game3108 on 16/3/8.
//
//

#import <Foundation/Foundation.h>
#import "InviteShareData.h"
#import "InviteShareView.h"
#import "AskLikeView.h"

@interface InviteShareViewFactory : NSObject

+ (InviteShareView *)showInviteShareView:(InviteShareData *)shareData inParent:(UIView *)container;
+ (AskLikeView *)showAskLikeView:(InviteShareData *)shareData inParent:(UIView *)container;

@end

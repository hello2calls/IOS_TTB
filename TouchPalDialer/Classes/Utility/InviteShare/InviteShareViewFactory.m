//
//  InviteShareViewFactory.m
//  TouchPalDialer
//
//  Created by game3108 on 16/3/8.
//
//

#import "InviteShareViewFactory.h"

@implementation InviteShareViewFactory

+ (InviteShareView *)showInviteShareView:(InviteShareData *)shareData inParent:(UIView *)container {
    InviteShareView *view = [[InviteShareView alloc]initWithFrame:container.bounds andInviteShareData:shareData];
    [container addSubview:view];
    return view;
}

+ (AskLikeView *)showAskLikeView:(InviteShareData *)shareData inParent:(UIView *)container{
    AskLikeView *view = [[AskLikeView alloc]initWithFrame:container.bounds andInviteShareData:shareData];
    [container addSubview:view];
    return view;
}

@end

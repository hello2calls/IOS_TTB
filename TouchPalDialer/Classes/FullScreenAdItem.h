//
//  FullScreenAdItem.h
//  TouchPalDialer
//
//  Created by Tengchuan Wang on 16/2/3.
//
//

#ifndef FullScreenAdItem_h
#define FullScreenAdItem_h

#import "CategoryItem.h"
#import "FullScreenAdItem.h"

@interface FullScreenAdItem: CategoryItem

@property(nonatomic, strong) NSDictionary *tabGuide;
@property(nonatomic, strong) NSString* adImage;

@end

#endif /* FullScreenAdItem_h */

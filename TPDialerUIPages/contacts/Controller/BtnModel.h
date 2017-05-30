//
//  BtnModel.h
//  iOS开发UINavigation系列
//
//  Created by 李校松 on 16/9/26.
//  Copyright © 2016年 李校松. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BtnModel : NSObject

@property (nonatomic , copy) NSString *ClassName;
@property (nonatomic , copy) NSString *image1 ;
@property (nonatomic , copy) NSString *image2 ;
@property (nonatomic , copy) NSString *title;
@property (nonatomic)        BOOL     isNew;
@property (nonatomic)        void (^blockItem)();


@end

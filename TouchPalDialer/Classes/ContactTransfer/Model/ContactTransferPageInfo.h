//
//  ContactTransferPageInfo.h
//  TouchPalDialer
//
//  Created by siyi on 16/3/15.
//
//

#ifndef ContactTransferPageInfo_h
#define ContactTransferPageInfo_h

#import <Foundation/Foundation.h>

@interface ContactTransferPageInfo : NSObject

@property (nonatomic) NSString *mainTitle;
@property (nonatomic) NSString *altTitle;
@property (nonatomic) NSString *imageName;
@property (nonatomic, assign) NSInteger pageIndex;
@property (nonatomic) NSString *buttonTittle;

@property (nonatomic, copy) void (^buttonAction)(void);
@end

#endif /* ContactTransferPageInfo_h */

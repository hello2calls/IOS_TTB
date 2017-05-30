//
//  LabelDataModel.h
//  AddressBook_DB
//
//  Created by Alice on 11-7-7.
//  Copyright 2011 CooTek. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface LabelDataModel : NSObject

@property(nonatomic,retain) NSString *labelKey;
@property(nonatomic,retain) id labelValue;
@property (nonatomic, retain) NSString *labelRawKey;
@property (nonatomic, retain) id extra;
@property(nonatomic,assign) BOOL ifVoip;

@end

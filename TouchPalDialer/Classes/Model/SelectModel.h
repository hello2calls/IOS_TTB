//
//  SelectModel.h
//  TouchPalDialer
//
//  Created by Alice on 11-8-23.
//  Copyright 2011 Cootek. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SelectModel : NSObject {
	NSInteger personID;
	BOOL isChecked;
    NSString *number;
}
@property(nonatomic,assign) NSInteger personID;
@property(nonatomic,assign) BOOL isChecked;
@property(nonatomic,retain) NSString *number;
@end

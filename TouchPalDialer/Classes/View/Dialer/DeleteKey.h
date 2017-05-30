//
//  DeleteKey.h
//  TouchPalDialer
//
//  Created by zhang Owen on 7/20/11.
//  Copyright 2011 Cootek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SuperKey.h"

@interface DeleteKey : SuperKey <SelfSkinChangeProtocol> 

@property(nonatomic,retain)UIImage *disableImage;
- (void)willDrawDeleteKey:(BOOL)isEnable;
@end

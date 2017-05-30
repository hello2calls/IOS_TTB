//
//  ClearView.h
//  TouchPalDialer
//
//  Created by zhang Owen on 11/24/11.
//  Copyright 2011 Cootek. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ClearView : UIView {
	NSString *key;
}

@property(nonatomic, retain) NSString *key;

- (void)setSectionKey:(NSString *)mkey;

@end

//
//  NumberKey.h
//  TouchPalDialer
//
//  Created by zhang Owen on 7/20/11.
//  Copyright 2011 Cootek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SuperKey.h"


@interface NumberKey : SuperKey<SelfSkinChangeProtocol>{
	NSString *letter;
	NSString *letter_minor;
	NSDictionary *m_info_dic;
    
    UIColor *textColor;
    UIColor *textColor_ht;

}

@property(nonatomic, retain) NSString *letter;
@property(nonatomic, retain) NSDictionary *m_info_dic;

@property(nonatomic,retain) UIColor *textColor;
@property(nonatomic,retain) UIColor *textColor_ht;
@property(nonatomic,retain) UIColor *minorTextColor;

- (id)initPhonePadKeyWithDictionary:(NSDictionary *)info_dic keyPadFrame:(CGRect)padFrame;
- (void)refresh;
@end

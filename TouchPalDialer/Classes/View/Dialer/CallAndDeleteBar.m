//
//  CallAndDeleteBar.m
//  TouchPalDialer
//
//  Created by zhang Owen on 10/10/11.
//  Copyright 2011 Cootek. All rights reserved.
//

#import "CallAndDeleteBar.h"
#import "CootekNotifications.h"
#import "consts.h"
#import "TPDialerResourceManager.h"
#import "SkinHandler.h"
#import "TPUIButton.h"

@implementation CallAndDeleteBar
@synthesize m_delegate;

- (id)initCallAndDeleteBarWithFrame:(CGRect)frame{
	if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
		backgroundImageView = [[UIImageView alloc] init];
        backgroundImageView.frame = CGRectMake(0, 0, TPScreenWidth(), TAB_BAR_HEIGHT);
        [self addSubview:backgroundImageView];
		[backgroundImageView setSkinStyleWithHost:self forStyle:@"dialerView_callAndDeleteBarBackImage_style"];
		CGRect frame_key_call = CGRectMake(self.frame.size.width/4, -1, self.frame.size.width/2, TAB_BAR_HEIGHT);
		key_call = [[CallKey alloc] initCallKeyWithFrame:frame_key_call];
        [key_call setSkinStyleWithHost:self forStyle:@"dialerView_callkey_style"];
		key_call.delegate = self;
		[self addSubview:key_call];
		CGRect frame_key_del = CGRectMake(self.frame.size.width*3/4, -1, TPScreenWidth()/4, TAB_BAR_HEIGHT);
		key_del = [[DeleteKey alloc] initWithFrame:frame_key_del];
        [key_del setSkinStyleWithHost:self forStyle:@"dialerView_deleteKey_style"];
		key_del.delegate = self;
		[self addSubview:key_del];
        CGRect frame_pad = CGRectMake(0, 0, self.frame.size.width/4, TAB_BAR_HEIGHT);
		key_pad = [[UIButton alloc] initWithFrame:frame_pad];
        [key_pad setSkinStyleWithHost:self forStyle:@"dialerView_showKeypad_style"];
//        [key_pad setTitle:NSLocalizedString(@"Unfold_", @"") forState:UIControlStateNormal];
//        [key_pad setTitle:NSLocalizedString(@"Fold_", @"") forState:UIControlStateSelected];
//        [key_pad.titleLabel setFont:[UIFont systemFontOfSize:12]];
//        [key_pad setTitleEdgeInsets:UIEdgeInsetsMake( 27.0,-key_pad.imageView.bounds.size.width, 0.0,0.0)];
//        [key_pad setImageEdgeInsets:UIEdgeInsetsMake(-20.0, 0.0,0.0, -key_pad.titleLabel.bounds.size.width)];
        [key_pad addTarget:self action:@selector(touchOnKeyPad) forControlEvents:UIControlEventTouchUpInside];
        key_pad.selected = [PhonePadModel getSharedPhonePadModel].phonepad_show;
		[self addSubview:key_pad];
	}
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doWhenInputEmpty) name:N_DIALER_INPUT_EMPTY object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doWhenInput) name:N_DIALER_INPUT_NOT_EMPTY object:nil];
	return self;
}

- (void)doWhenInputEmpty {
    if (self.hidden == NO) {
        self.hidden = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:N_LOCK_TAG_SECOND_TO_FORTH object:nil userInfo:nil];
    } 
}

- (void)doWhenInput {
	self.hidden = NO;
}


- (void)touchOnKeyPad {
    PhonePadModel *sharedModel = [PhonePadModel getSharedPhonePadModel];
    key_pad.selected = !sharedModel.phonepad_show;
    [sharedModel setPhonePadShowingState:!(sharedModel.phonepad_show)];
    [[NSNotificationCenter defaultCenter] postNotificationName:N_HINT_BUTTON_CLICK object:nil];
}


#pragma mark -
#pragma mark PhonePadKeyProtocol
- (void)deleteInputNumer {
	[m_delegate deleteInputNumer];
}

- (void)deleteAllInputNumber {
	[m_delegate deleteAllInputNumber];
}

- (void)dealloc {
    [SkinHandler removeRecursively:self];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark skinChange protocol
- (id)selfSkinChange:(NSString *)style{
    TPDialerResourceManager *manager = [TPDialerResourceManager sharedManager];
    NSDictionary *operDic = [manager getPropertyDicByStyle:style];
    if([operDic objectForKey:BACK_GROUND_IMAGE]){
        backgroundImageView.image = [manager getCachedImageByName:[operDic objectForKey:BACK_GROUND_IMAGE]];
    }
    NSNumber *toTop = [NSNumber numberWithBool:YES];
    return  toTop;
}
@end

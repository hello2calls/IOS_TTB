//
//  BlockUserView.m
//  TouchPalDialer
//
//  Created by Alice on 11-12-20.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BlockUserView.h"

@implementation BlockUserView

@synthesize m_alert;
@synthesize is_cancel_click;
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame {    
	return [self initWithMessage:frame withMessage:nil];
}
- (id)initWithMessage:(CGRect)frame withLongMessage:(NSString *)msg{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.        
		UIAlertView *alert= [[UIAlertView alloc] initWithTitle:msg
													   message:nil
													  delegate:nil 
											 cancelButtonTitle:NSLocalizedString(@"Cancel",@"" ) 
											 otherButtonTitles:nil];
		alert.delegate=self;
		[alert show];
		self.m_alert=alert;
		
		UIActivityIndicatorView *waitView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
		waitView.frame = CGRectMake(15,20, 12, 12);
		waitView.hidesWhenStopped = YES;
	    [waitView startAnimating];
	    [m_alert addSubview:waitView];
    }
    return self;
}     
- (id)initWithMessage:(CGRect)frame withMessage:(NSString *)msg
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
		if ([msg length]==0) {
			msg=NSLocalizedString(@"Uploading changes...",@"");
		}

		UIAlertView *alert= [[UIAlertView alloc] initWithTitle:msg
													   message:nil
													  delegate:nil 
											 cancelButtonTitle:NSLocalizedString(@"Cancel",@"" ) 
											 otherButtonTitles:nil];
		alert.delegate=self;
		[alert show];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(alertDismiss) name:UIApplicationDidEnterBackgroundNotification object:nil];
		self.m_alert=alert;
		
		UIActivityIndicatorView *waitView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
		waitView.frame = CGRectMake(15,18, 24, 24);
		waitView.hidesWhenStopped = YES;
	    [waitView startAnimating];
	    [m_alert addSubview:waitView];
    }
    return self;
}



- (void)alertDismiss{
    if(![NSThread mainThread]) {
        [self performSelectorOnMainThread:@selector(alertDismiss) withObject:nil waitUntilDone:YES];
        return;
    }
    [m_alert dismissWithClickedButtonIndex:0 animated:YES];
    [self removeFromSuperview];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	if (buttonIndex==0) {
		is_cancel_click = YES;
		[self alertDismiss];
		[delegate onCancelBlock];
	}
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/


@end

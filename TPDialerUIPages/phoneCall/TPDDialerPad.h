//
//  TPDDialerPad.h
//  TouchPalDialer
//
//  Created by weyl on 16/11/7.
//
//

#import <UIKit/UIKit.h>
#import <ReactiveCocoa.h>
@interface TPDDialerPad : UIView
@property (nonatomic) id delegate;
@property (nonatomic,strong) RACSubject* inputChangeSignal;
@property (nonatomic,strong) NSString* numStr;
@property (nonatomic,strong) UIView* numPad;

+(double)getHeight;
-(void)refreshAttrLabel;
-(void)foldPad:(BOOL)b;
-(void)showAllKeys:(BOOL)b;
-(void)showAddGestureBar:(BOOL)b;

-(void)research:(NSString*)numStr;
-(UIView*)generateGestureGuideMaskView;

-(void)pasteNum;
@end

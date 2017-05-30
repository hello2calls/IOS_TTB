//
//  TPDVoipCallPopUpViewController.h
//  TouchPalDialer
//
//  Created by H L on 2016/11/28.
//
//

#import <UIKit/UIKit.h>
#import "CallLogDataModel.h"
#import "VoipCallPopUpView.h"

@interface TPDVoipCallPopUpViewController : UIViewController<VoipCallPopUpViewDelegate>


@property (nonatomic, strong)       CallLogDataModel*  callLog;
@property (nonatomic, readwrite )   NSInteger          type; //(4 ,test mode)
@property (nonatomic, readwrite )   NSString*          callName; //(4 ,test mode)

-(void)callVoipDirectly;
- (void)onClickCancelButton;

@end

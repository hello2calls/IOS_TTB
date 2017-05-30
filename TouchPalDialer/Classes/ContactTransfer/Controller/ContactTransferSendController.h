//
//  ContactTransferSendController.h
//  TouchPalDialer
//
//  Created by siyi on 16/3/10.
//
//

#ifndef ContactTransferSendController_h
#define ContactTransferSendController_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SendContentView.h"
#import "QRContentView.h"
#import <AVFoundation/AVFoundation.h>

#define MAX_RECORDS_SENT_ONCE (200)
#define MAX_SEND_TRYIES (3)

@interface ContactTransferSendController : UIViewController <SendContentViewDelegate, QRContentViewDelegate>

@end




#endif /* ContactTransferSendController_h */

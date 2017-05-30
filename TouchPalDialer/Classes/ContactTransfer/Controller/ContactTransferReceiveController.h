//
//  ContactTransferReceiveController.h
//  TouchPalDialer
//
//  Created by siyi on 16/3/10.
//
//

#ifndef ContactTransferReceiveController_h
#define ContactTransferReceiveController_h

#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ReceiveContentView.h"

#define ENABLE_TRANSFER_DEBUG (0)

#define MAX_RECEIVE_TRIES (3)

#define RECEIVED_FILE_NAME @"contact_transfer_received.plist"

@interface ContactTransferReceiveController : UIViewController <AVCaptureMetadataOutputObjectsDelegate, ReceiveContentViewDelegate>

@end

#endif /* ContactTransferReceiveController_h */

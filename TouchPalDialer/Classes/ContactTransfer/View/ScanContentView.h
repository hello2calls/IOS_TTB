//
//  ScanContentView.h
//  TouchPalDialer
//
//  Created by siyi on 16/3/22.
//
//

#ifndef ScanContentView_h
#define ScanContentView_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface ScanContentView : UIView <AVCaptureMetadataOutputObjectsDelegate>
- (instancetype) initWithFrame:(CGRect)frame
                rectOfInterest:(CGRect)interestRect
              avOutputDelegate:(id<AVCaptureMetadataOutputObjectsDelegate>)avOutputDelegate;

- (instancetype) initWithFrame:(CGRect)frame avOutputDelegate:(id<AVCaptureMetadataOutputObjectsDelegate>)avOutputDelegate;

- (BOOL) startScanning;
- (void) stopScanning;
- (void) hide;
- (void) show;
- (void) destroy;

@property (nonatomic, readonly) id<AVCaptureMetadataOutputObjectsDelegate> avOutputDelegate;

@property (nonatomic, readonly) AVCaptureSession *captureSession;


@end

#endif /* ScanContentView_h */

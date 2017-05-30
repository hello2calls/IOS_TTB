//
//  ScanContentView.m
//  TouchPalDialer
//
//  Created by siyi on 16/3/22.
//
//

#import "ScanContentView.h"
#import "TPDialerResourceManager.h"
#import "ContactTransferConst.h"


@implementation ScanContentView {
    CGRect _interestRect;
    CGRect _qrWindowFrame;
    UIImageView *_scanLineView;
    NSTimer *_scanTimer;
}

- (void) baseInit {
    _interestRect = CGRectNull;
    _interestRect = CGRectNull;
    _qrWindowFrame = CGRectNull;
}

- (instancetype) initWithFrame:(CGRect)frame
                rectOfInterest:(CGRect)interestRect
              avOutputDelegate:(id<AVCaptureMetadataOutputObjectsDelegate>)avOutputDelegate {
    if (self = [super initWithFrame:frame]) {
        [self baseInit];
        
        if (CGRectIsNull(interestRect)) {
            _interestRect = [self getQRWindowFrame];
        } else {
            _interestRect = interestRect;
        }
        _avOutputDelegate = avOutputDelegate;
        
        [self setupQRScanner]; //add the scanning layer
        _scanLineView = [self getScanLineView];
        UIView *qrWindow = [self getQRWindowView];
        
        self.backgroundColor = [UIColor clearColor];
        
        [self addSubview:qrWindow];
        [self addSubview:_scanLineView];
    }
    return self;
}

- (instancetype) initWithFrame:(CGRect)frame
              avOutputDelegate:(id<AVCaptureMetadataOutputObjectsDelegate>)avOutputDelegate {
    return [self initWithFrame:frame rectOfInterest:CGRectNull avOutputDelegate:avOutputDelegate];
}

#pragma mark instance methods
- (BOOL) startScanning {
    if (_captureSession) {
        [_captureSession startRunning];
        if (!_scanTimer) {
            _scanTimer = [NSTimer scheduledTimerWithTimeInterval:(1.0/40) target:self
                                                        selector:@selector(moveScanningLine) userInfo:nil repeats:YES];
        }
        [_scanTimer fire];
        return YES;
    }
    return NO;
}

- (void) stopScanning {
    if (_captureSession && _captureSession.isRunning) {
        [_captureSession stopRunning];
    }
    [_scanTimer invalidate];
    _scanTimer = nil;
}

- (void) hide {
    self.hidden = YES;
    [self stopScanning];
}

- (void) show {
    self.hidden = NO;
    [self startScanning];
}
- (void) destroy {
    [self stopScanning];
    _captureSession = nil;
}

#pragma mark actions
- (void) moveScanningLine {
    // move the line view from up to down
    CGRect prevLineRect = _scanLineView.frame;
    CGFloat nextY = prevLineRect.origin.y;
    CGFloat step = 1.5;
    CGFloat maxY = _qrWindowFrame.origin.y + QR_WINDOW_WIDTH - step - _scanLineView.bounds.size.height;
    if (prevLineRect.origin.y <= maxY) {
        nextY = prevLineRect.origin.y + step;
    }else {
        nextY = _qrWindowFrame.origin.y;
    }
    CGRect nextLineRect = CGRectMake(prevLineRect.origin.x, nextY,
                                     prevLineRect.size.width, prevLineRect.size.height);
    _scanLineView.frame = nextLineRect;
}


#pragma mark get views
- (BOOL) setupQRScanner {
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    AVCaptureDeviceInput *captureDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    if (error) {
        // failed to open the device
        return NO;
    }
    //the order for adding input and output is important!
    _captureSession = [[AVCaptureSession alloc] init];
    [_captureSession addInput:captureDeviceInput];
    
    AVCaptureMetadataOutput *captureOutput = [[AVCaptureMetadataOutput alloc] init];
    [_captureSession addOutput:captureOutput];
    
    captureOutput.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
    [captureOutput setMetadataObjectsDelegate:_avOutputDelegate queue:dispatch_get_main_queue()];
    
    //prepare the capture layer
    AVCaptureVideoPreviewLayer *previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_captureSession];
    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    previewLayer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    previewLayer.backgroundColor = [UIColor clearColor].CGColor;
    [self.layer insertSublayer:previewLayer atIndex:0];
    
    //set rect of interest
    CGRect qrFrame = _interestRect;
    captureOutput.rectOfInterest = CGRectMake(qrFrame.origin.y / TPScreenHeight(),
                                              qrFrame.origin.x / TPScreenWidth(),
                                              qrFrame.size.height / TPScreenHeight(),
                                              qrFrame.size.width / TPScreenWidth());
    return YES;
}

- (UIImageView *) getQRWindowView {
    UIImageView *scanWindow = [[UIImageView alloc] initWithFrame:[self getQRWindowFrame]];
    UIImage *windowFrameImage = [[TPDialerResourceManager sharedManager] getImageInDefaultPackageByName:@"contact_transfer_qr_code_bg@2x.png"];
    scanWindow.image = windowFrameImage;
    scanWindow.contentMode = UIViewContentModeCenter;
    scanWindow.backgroundColor = [UIColor clearColor];
    return scanWindow;
}

- (CGRect) getQRWindowFrame {
    if (CGRectIsNull(_qrWindowFrame)) {
        CGFloat gX = (self.frame.size.width - QR_WINDOW_WIDTH) / 2;
        CGFloat gY = 110;
        _qrWindowFrame = CGRectMake(gX, gY, QR_WINDOW_WIDTH, QR_WINDOW_WIDTH);
    }
    return _qrWindowFrame;
}

- (UIImageView *) getScanLineView {
    // create the line view if necessary
    if (!_scanLineView) {
        UIImage *scanLineImage = [[TPDialerResourceManager sharedManager] getImageInDefaultPackageByName:@"contact_transfer_qr_code_scan@2x.png"];
        
        _scanLineView = [[UIImageView alloc] initWithImage:scanLineImage];
        _scanLineView.frame = CGRectMake(_qrWindowFrame.origin.x, _qrWindowFrame.origin.y,
                                         _qrWindowFrame.size.width, 16);
        _scanLineView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _scanLineView;
}

// deleagate for scanner
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects
       fromConnection:(AVCaptureConnection *)connection {
    if (!metadataObjects || metadataObjects.count == 0) {
        cootek_log(@"contact_transfer, metadataobjects is null");
        return;
    }
    AVMetadataMachineReadableCodeObject *metaData = [metadataObjects objectAtIndex:0];
    cootek_log(@"contact_transfer, scann result: %@", metaData.stringValue);
    return;
}

@end

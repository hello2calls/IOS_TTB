//
//  TPScanCardViewController.m
//
//
//  Created by H L on 2016/11/7.
//  Copyright © 2016年 G.Alesary. All rights reserved.
//

#import "TPScanCardViewController.h"


#import <UIKit/UIKit.h>
#import "UIView+Toast.h"
#import <ImageIO/ImageIO.h>
#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>
#import "UIColor+TPDExtension.h"
#import "TPABPersonActionController.h"
#import "SeattleFeatureExecutor.h"
#import "Reachability.h"
#import "DialerUsageRecord.h"

//Custom UI classes
//#import "CameraShutterButton.h"
//#import "CameraToggleButton.h"
//#import "CameraFlashButton.h"
//#import "CameraDismissButton.h"
//#import "CameraFocalReticule.h"
//#import "Constants.h"



#define kBlueColor          RGB2UIColor2(3  ,169,244)



@interface Model : NSObject

@property (nonatomic, strong)NSString    *name;
@property (nonatomic, strong)NSString    *tittle;

@end
@implementation Model
@end

@interface ContactModel : NSObject

@property (nonatomic, strong)NSString *name;
@property (nonatomic, strong)NSString *tittle;
@property (nonatomic, strong)NSString *URLString;
@property (nonatomic, strong)NSString *company;
@property (nonatomic, copy  )NSString *addressString;
@property (nonatomic, copy  )NSString *country;
@property (nonatomic, copy  )NSString *locality;

@property (nonatomic, strong)NSArray  *phoneArray;
@property (nonatomic, strong)NSArray  *emailArray;
@property (nonatomic, strong)NSArray  *faxArray;

@end
@implementation ContactModel



@end

@interface TPConstants : NSObject

///Type Definitions

typedef NS_ENUM(BOOL, CameraType) {
    FrontFacingCamera,
    RearFacingCamera,
};

typedef NS_ENUM(NSInteger, BarButtonTag) {
    ShutterButtonTag,
    ToggleButtonTag,
    FlashButtonTag,
    DismissButtonTag,
};

typedef struct {
    CGFloat ISO;
    CGFloat exposureDuration;
    CGFloat aperture;
    CGFloat lensPosition;
} CameraStatistics;

///Function Prototype declarations

CameraStatistics cameraStatisticsMake(float aperture, float exposureDuration, float ISO, float lensPostion);


//- (BOOL)checkTheCamera;

@end

@implementation TPConstants

CameraStatistics cameraStatisticsMake(float aperture, float exposureDuration, float ISO, float lensPostion) {
    CameraStatistics cameraStatistics;
    cameraStatistics.aperture = aperture;
    cameraStatistics.exposureDuration = exposureDuration;
    cameraStatistics.ISO = ISO;
    cameraStatistics.lensPosition = lensPostion;
    return cameraStatistics;
}


@end



#pragma mark - TPCameraSessionView
///Protocol Definition
@protocol TPCameraSessionDelegate <NSObject>

@optional - (void)didCaptureImage:(UIImage *)image;
@optional - (void)didCaptureImageWithData:(NSData *)imageData;

@end



///Protocol Definition
@protocol TPCameraManagerDelegate <NSObject>
@required - (void)cameraSessionManagerDidCaptureImage;
@required - (void)cameraSessionManagerFailedToCaptureImage;
@required - (void)cameraSessionManagerDidReportAvailability:(BOOL)deviceAvailability forCameraType:(CameraType)cameraType;
@required - (void)cameraSessionManagerDidReportDeviceStatistics:(CameraStatistics)deviceStatistics; //Report every .125 seconds

@end

@interface TPCameraManager : NSObject

//Weak pointers
@property (nonatomic, weak) id<TPCameraManagerDelegate>delegate;
@property (nonatomic, weak) AVCaptureDevice *activeCamera;

//Strong Pointers
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureStillImageOutput *stillImageOutput;
@property (nonatomic, strong) UIImage *stillImage;
@property (nonatomic, strong) NSData *stillImageData;
@property (readwrite        ) BOOL camerAccessable;
//Primative Variables
@property (nonatomic,assign,getter=isTorchEnabled) BOOL enableTorch;

//API Methods
- (void)addStillImageOutput;
- (void)captureStillImage;
- (void)addVideoPreviewLayer;
- (void)initiateCaptureSessionForCamera:(CameraType)cameraType;
- (void)stop;
- (BOOL)checkCameraAccessable;

@end




@implementation TPCameraManager

#pragma mark Capture Session Configuration

- (id)init {
    if ((self = [super init])) {
        [self setCaptureSession:[[AVCaptureSession alloc] init]];
        _captureSession.sessionPreset = AVCaptureSessionPresetHigh;
        _camerAccessable = NO;
    }
    return self;
}

- (void)addVideoPreviewLayer {
    [self setPreviewLayer:[[AVCaptureVideoPreviewLayer alloc] initWithSession:[self captureSession]]];
    [[self previewLayer] setVideoGravity:AVLayerVideoGravityResizeAspectFill];
}

- (void)initiateCaptureSessionForCamera:(CameraType)cameraType {
    
    //Iterate through devices and assign 'active camera' per parameter
    for (AVCaptureDevice *device in AVCaptureDevice.devices) {
        if ([device hasMediaType:AVMediaTypeVideo]) {
            if ([device.localizedName isEqualToString:@"Back Camera"] ||[device.localizedName isEqualToString:@"背面相机"] || device.position == 1)
                _activeCamera = device;
            
        }else {
            
            NSLog(@"camera not work %@",device);
        }
    }
    NSError *error          = nil;
    BOOL deviceAvailability = YES;
    
    AVCaptureDeviceInput *cameraDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:_activeCamera error:&error];
    if (!error && [[self captureSession] canAddInput:cameraDeviceInput]) [[self captureSession] addInput:cameraDeviceInput];
    else deviceAvailability = NO;
    
    //Report camera device availability
    if (self.delegate) [self.delegate cameraSessionManagerDidReportAvailability:deviceAvailability forCameraType:cameraType];
    
    //    [self initiateStatisticsReportWithInterval:.125];
}

-(BOOL)checkCameraAccessable {
    
    BOOL cameraAccessable = NO;
    //Iterate through devices and assign 'active camera' per parameter
    for (AVCaptureDevice *device in AVCaptureDevice.devices) {
        if ([device hasMediaType:AVMediaTypeVideo]) {
            if ([device.localizedName isEqualToString:@"Back Camera"] ||[device.localizedName isEqualToString:@"背面相机"]|| device.position == 1) {
                cameraAccessable = YES;
                break;
            }
        }else {
            
            NSLog(@"camera not work %@",device);
        }
    }
    NSError *error          = nil;
    BOOL deviceAvailability = YES;
    
    [AVCaptureDeviceInput deviceInputWithDevice:_activeCamera error:&error];
    if (error ) {
        deviceAvailability = NO;
    }
    if (cameraAccessable && deviceAvailability) {
        return YES;
    }else {
        return NO;
    }
    
    
}

-(void)initiateStatisticsReportWithInterval:(CGFloat)interval {
    
    __block id blockSafeSelf = self;
    
    [[NSOperationQueue new] addOperationWithBlock:^{
        do {
            [NSThread sleepForTimeInterval:interval];
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                if (self.delegate) [self.delegate cameraSessionManagerDidReportDeviceStatistics:cameraStatisticsMake(_activeCamera.lensAperture, CMTimeGetSeconds(_activeCamera.exposureDuration), _activeCamera.ISO, _activeCamera.lensPosition)];
            }];
        } while (blockSafeSelf);
    }];
}

- (void)addStillImageOutput
{
    [self setStillImageOutput:[[AVCaptureStillImageOutput alloc] init]];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey,nil];
    [[self stillImageOutput] setOutputSettings:outputSettings];
    
    [self getOrientationAdaptedCaptureConnection];
    
    [[self captureSession] addOutput:[self stillImageOutput]];
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus])
    {
        [device lockForConfiguration:nil];
        [device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
        [device unlockForConfiguration];
    }
}

- (void)captureStillImage
{
    AVCaptureConnection *videoConnection = [self getOrientationAdaptedCaptureConnection];
    
    if (videoConnection) {
        [[self stillImageOutput] captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:
         ^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
             CFDictionaryRef exifAttachments = CMGetAttachment(imageSampleBuffer, kCGImagePropertyExifDictionary, NULL);
             if (exifAttachments) {
                 //Attachements Found
             } else {
                 //No Attachments
             }
             NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
             UIImage *image = [[UIImage alloc] initWithData:imageData];
             [self setStillImage:image];
             [self setStillImageData:imageData];
             
             
             if (self.delegate)
                 [self.delegate cameraSessionManagerDidCaptureImage];
         }];
    }
    
//    Turn off the flash if on
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if ([device hasTorch])
        {
            [device lockForConfiguration:nil];
            [device setTorchMode:AVCaptureTorchModeOff];
            [device unlockForConfiguration];
        }
}

- (void)setEnableTorch:(BOOL)enableTorch
{
    _enableTorch = enableTorch;
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([device hasTorch] && [device hasFlash])
    {
        [device lockForConfiguration:nil];
        if (enableTorch) { [device setTorchMode:AVCaptureTorchModeOn]; }
        else { [device setTorchMode:AVCaptureTorchModeOff]; }
        [device unlockForConfiguration];
    }
}

#pragma mark - Helper Method(s)

- (void)assignVideoOrienationForVideoConnection:(AVCaptureConnection *)videoConnection
{
    AVCaptureVideoOrientation newOrientation;
    
    newOrientation = AVCaptureVideoOrientationPortrait;
    
    [videoConnection setVideoOrientation: newOrientation];
}

- (AVCaptureConnection *)getOrientationAdaptedCaptureConnection
{
    AVCaptureConnection *videoConnection = nil;
    
    for (AVCaptureConnection *connection in [[self stillImageOutput] connections]) {
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            if ([[port mediaType] isEqual:AVMediaTypeVideo] ) {
                videoConnection = connection;
                [self assignVideoOrienationForVideoConnection:videoConnection];
                break;
            }
        }
        if (videoConnection) {
            [self assignVideoOrienationForVideoConnection:videoConnection];
            break;
        }
    }
    
    return videoConnection;
}

#pragma mark - Cleanup Functions

// stop the camera, otherwise it will lead to memory crashes
- (void)stop
{
    [self.captureSession stopRunning];
    
    if(self.captureSession.inputs.count > 0) {
        AVCaptureInput* input = [self.captureSession.inputs objectAtIndex:0];
        [self.captureSession removeInput:input];
    }
    if(self.captureSession.outputs.count > 0) {
        AVCaptureVideoDataOutput* output = [self.captureSession.outputs objectAtIndex:0];
        [self.captureSession removeOutput:output];
    }
    
}


- (void)dealloc {
    [self stop];
}


@end

@interface TPCameraSessionView : UIView
@property (nonatomic, strong) TPCameraManager *captureManager;
//Delegate Property
@property (nonatomic, weak) id <TPCameraSessionDelegate> delegate;

//API Functions
- (void)setTopBarColor:(UIColor *)topBarColor;
- (void)hideFlashButton;
- (void)hideCameraToggleButton;
- (void)hideDismissButton;

@end


#pragma mark ***************
#pragma mark - TPCameraSessionView
@interface TPCameraSessionView () <TPCameraManagerDelegate>
{
    //Size of the UI elements variables
    CGSize shutterButtonSize;
    CGSize topBarSize;
    CGSize barButtonItemSize;
    
    //Variable vith the current camera being used (Rear/Front)
    CameraType cameraBeingUsed;
}

//Primative Properties
@property (readwrite) BOOL animationInProgress;

//Object References
@property (nonatomic, strong) UIButton *cameraShutter;
@property (nonatomic, strong) UIButton *cameraToggle;
@property (nonatomic, strong) UIButton *cameraFlash;
@property (nonatomic, strong) UIButton *cameraDismiss;
@property (nonatomic, strong) UIView *focalReticule;
@property (nonatomic, strong) UIView *bottomBarView;
@property (nonatomic, strong) UIView *fitterView;


@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *scanNetImageView;

//Temporary/Diagnostic properties
@property (nonatomic, strong) UILabel *ISOLabel, *apertureLabel, *shutterSpeedLabel;

@end

@implementation TPCameraSessionView

-(void)drawRect:(CGRect)rect {
    if (self) {
        _animationInProgress = NO;
        [self setupCaptureManager:RearFacingCamera];
        cameraBeingUsed = RearFacingCamera;
        [self composeInterface];
        
        [[_captureManager captureSession] startRunning];
    }
}

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    return self;
}

#pragma mark - Setup

-(void)setupCaptureManager:(CameraType)camera {
    
    // remove existing input
    AVCaptureInput* currentCameraInput = [self.captureManager.captureSession.inputs objectAtIndex:0];
    [self.captureManager.captureSession removeInput:currentCameraInput];
    
    _captureManager = nil;
    
    //Create and configure 'CaptureSessionManager' object
    _captureManager = [TPCameraManager new];
    
    // indicate that some changes will be made to the session
    [self.captureManager.captureSession beginConfiguration];
    
    if (_captureManager) {
        
        //Configure
        [_captureManager setDelegate:self];
        [_captureManager initiateCaptureSessionForCamera:camera];
        [_captureManager addStillImageOutput];
        [_captureManager addVideoPreviewLayer];
        [self.captureManager.captureSession commitConfiguration];
        
        //Preview Layer setup
        CGRect layerRect = self.layer.bounds;
        [_captureManager.previewLayer setBounds:layerRect];
        [_captureManager.previewLayer setPosition:CGPointMake(CGRectGetMidX(layerRect),CGRectGetMidY(layerRect))];
        
        //Apply animation effect to the camera's preview layer
        CATransition *applicationLoadViewIn =[CATransition animation];
        [applicationLoadViewIn setDuration:0.6];
        [applicationLoadViewIn setType:kCATransitionReveal];
        [applicationLoadViewIn setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
        [_captureManager.previewLayer addAnimation:applicationLoadViewIn forKey:kCATransitionReveal];
        
        //Add to self.view's layer
        [self.layer addSublayer:_captureManager.previewLayer];
    }
}
static  CGFloat kBorderW = 57;
static  CGFloat kMargin = 57;


-(void)composeInterface {
    
    //Adding notifier for orientation changes
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationChanged:)    name:UIDeviceOrientationDidChangeNotification  object:nil];
    
    
    //Define adaptable sizing variables for UI elements to the right device family (iPhone or iPad)
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    {
        //Declare the sizing of the UI elements for iPad
        shutterButtonSize = CGSizeMake(self.bounds.size.width * 0.9, self.bounds.size.width * 0.09);
        topBarSize        = CGSizeMake(self.frame.size.width, 106);
        barButtonItemSize = CGSizeMake([[UIScreen mainScreen] bounds].size.height * 0.04, [[UIScreen mainScreen] bounds].size.height * 0.04);
    } else
    {
        //Declare the sizing of the UI elements for iPhone
        shutterButtonSize = CGSizeMake(self.bounds.size.width * 0.20, self.bounds.size.width * 0.20);
        topBarSize        = CGSizeMake(self.frame.size.width, 106);
        barButtonItemSize = CGSizeMake(40,40);
    }
    
    
    
    
    
    //Create shutter button
    
    
    
    _imageView = [[UIImageView alloc]initWithFrame:self.bounds];
    [self addSubview:_imageView];
    //    _imageView.backgroundColor = [UIColor yellowColor];
    _imageView.hidden = NO;
    
    CGFloat kW = [UIScreen mainScreen].bounds.size.width - 2 *kMargin;
    CGFloat kH = [UIScreen mainScreen].bounds.size.height - 178 - kMargin;
    CGRect cropRect = CGRectMake(kMargin, kBorderW, kW, kH);

    //用来标识layer的绘图是否正确
    //    aView.layer.borderWidth = 1.0;
    [self drawview:_imageView];

    UIImageView *insideView = [[UIImageView alloc]initWithFrame:cropRect];
    [_imageView addSubview:insideView];
    
    
    
    _scanNetImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed: @"scan.png"]];
    [insideView addSubview:_scanNetImageView];
    [self resumeAnimation];
    
    _cameraShutter = [UIButton new];
    _cameraShutter.backgroundColor = [UIColor grayColor];
    //Create the top bar and add the buttons to it
    _bottomBarView = [UIView new];
    _bottomBarView.backgroundColor = [UIColor darkGrayColor];
    
    if (_bottomBarView) {
        //Setup visual attribution for bar
        _bottomBarView.frame  = (CGRect){0,[[UIScreen mainScreen] bounds].size.height - 106, topBarSize};
        _bottomBarView.backgroundColor = [UIColor blackColor];
        [self addSubview:_bottomBarView];
        
    }
    
    
    
    if (_captureManager) {
        
        //Button Visual attribution
        _cameraShutter.frame = (CGRect){0,0, 70,70};
        _cameraShutter.tag = ShutterButtonTag;
        _cameraShutter.backgroundColor = [UIColor clearColor];
        _cameraShutter.titleLabel.font = [UIFont fontWithName:@"iPhoneIcon4" size:34];
        [_cameraShutter setTitle:@"6" forState:UIControlStateNormal];

        [_cameraShutter setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        //Button target
        [_cameraShutter addTarget:self action:@selector(inputManager:) forControlEvents:UIControlEventTouchUpInside];
        
        
        UIView *cameraContainer = [UIView new];
        cameraContainer.frame = (CGRect){0,0, 70 ,70};
        cameraContainer.center = _bottomBarView.center;
        cameraContainer.backgroundColor = kBlueColor;
        cameraContainer.layer.cornerRadius = cameraContainer.frame.size.width / 2;
        
        [self addSubview:cameraContainer];
        
        UIView *cameraContainerBlack = [UIView new];
        cameraContainerBlack.frame = (CGRect){0,0, 63 ,63};
        cameraContainerBlack.center = CGPointMake(cameraContainer.bounds.size.width/2, cameraContainer.bounds.size.height/2);
        cameraContainerBlack.backgroundColor = [UIColor blackColor];
        cameraContainerBlack.layer.cornerRadius = cameraContainerBlack.frame.size.width / 2;
        [cameraContainer addSubview:cameraContainerBlack];
        
        UIView *cameraContainerBlue = [UIView new];
        cameraContainerBlue.frame = (CGRect){0,0, 60 ,60};
        cameraContainerBlue.center = CGPointMake(cameraContainer.bounds.size.width/2, cameraContainer.bounds.size.height/2);
        cameraContainerBlue.backgroundColor = kBlueColor;
        cameraContainerBlue.layer.cornerRadius = cameraContainerBlack.frame.size.width / 2;
        [cameraContainer addSubview:cameraContainerBlue];
        [cameraContainer addSubview:_cameraShutter];

    }
    
    
    
    
    //Add the flash button
    if (!_cameraFlash) {
        _cameraFlash = [UIButton new];
        _cameraFlash.frame = (CGRect){20,20, barButtonItemSize};
        _cameraFlash.center = CGPointMake(54, topBarSize.height/2);
        _cameraFlash.tag = FlashButtonTag;
        if ( UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad ) [_bottomBarView addSubview:_cameraFlash];
        [_cameraFlash setTitle:@"9" forState:UIControlStateNormal];
        _cameraFlash.titleLabel.font = [UIFont fontWithName:@"iPhoneIcon4" size:34];
        [_cameraFlash setTitleColor:kBlueColor forState:UIControlStateNormal];
        [_cameraFlash addTarget:self action:@selector(inputManager:) forControlEvents:UIControlEventTouchUpInside];

    }
    
    
    
    //Add the camera dismiss button
    if (!_cameraDismiss) {
        _cameraDismiss = [UIButton new];
        _cameraDismiss.frame = (CGRect){self.frame.size.width - 60,20, barButtonItemSize};
        _cameraDismiss.center = CGPointMake(_cameraDismiss.center.x, topBarSize.height/2);
        _cameraDismiss.tag = DismissButtonTag;
        [_bottomBarView addSubview:_cameraDismiss];
        [_cameraDismiss addTarget:self action:@selector(inputManager:) forControlEvents:UIControlEventTouchUpInside];
        [_cameraDismiss setTitle:@"G" forState:UIControlStateNormal];
        [_cameraDismiss setTitleColor:kBlueColor forState:UIControlStateNormal];
        _cameraDismiss.titleLabel.font = [UIFont fontWithName:@"iPhoneIcon4" size:34];
        

    }
    
    UILabel *mentionLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, _bottomBarView.tp_y - 35 - 20, self.tp_width, 20)];
    mentionLabel.text = @"把名片放入框内拍摄即可";
    mentionLabel.textColor = [[UIColor whiteColor]colorWithAlphaComponent:.6];
    mentionLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:mentionLabel];
    //    if (!_fitterView) {
//        
//        _fitterView = [UIView new];
//        _fitterView.frame = CGRectMake(0, 0, self.tp_width, self.tp_height - 106);
//        [self addSubview:_fitterView];
//        
//        CGFloat itemSize = 30;
//        CGFloat halfItemSize = itemSize/2.f;
//        for (int i = 0; i < 4 ; i ++) {
//            
//            UILabel *label = [UILabel new];
//            label.frame = CGRectMake(0, 0, itemSize, itemSize);
//            label.textColor  = [UIColor whiteColor];
//            switch (i) {
//                case 0:
//                    label.text = @"m";
//                    label.font = [UIFont fontWithName:@"iPhoneIcon5" size:34];
//                    label.center = CGPointMake(0, 57);
//                    label.textAlignment = NSTextAlignmentLeft;
//                    break;
//                case 1:
//                    label.text = @"n";
//                    label.font = [UIFont fontWithName:@"iPhoneIcon5" size:34];
//                    label.center = CGPointMake(insideView.tp_width  , halfItemSize);
//                    label.textAlignment = NSTextAlignmentRight;
//
//                    break;
//                case 2:
//                    label.text = @"k";
//                    label.font = [UIFont fontWithName:@"iPhoneIcon5" size:34];
//                    label.center = CGPointMake( halfItemSize, insideView.tp_height );
//                    label.textAlignment = NSTextAlignmentLeft;
//
//                    break;
//                case 3:
//                    label.text = @"l";
//                    label.font = [UIFont fontWithName:@"iPhoneIcon5" size:34];
//                    label.center = CGPointMake(insideView.tp_width  , insideView.tp_height );
//                    label.textAlignment = NSTextAlignmentRight;
//
//                    break;
//                    
//                default:
//                    break;
//            }
////            [insideView addSubview:label];
//            
//        }
//        
//        
//        
//    }
//    
    
    
 
}


- (void )drawview:(UIView *)containerView{
    
    CGFloat kW = [UIScreen mainScreen].bounds.size.width - 2 *kMargin;
    CGFloat kH = [UIScreen mainScreen].bounds.size.height - 178 - kMargin;
    
    CGRect cropRect = CGRectMake(kMargin, kBorderW, kW, kH);
    CGFloat radius = 7;
    CGFloat offSet = 10;
    
    
    for (int i = 0; i < 3; i++) {
        //create path
        UIBezierPath *path = [[UIBezierPath alloc] init];
        if (i == 2) {
            [path moveToPoint:CGPointMake(cropRect.origin.x , cropRect.origin.y + radius + offSet)];
        }
        
        [path addArcWithCenter:CGPointMake(cropRect.origin.x + radius, cropRect.origin.y + radius) radius:radius startAngle:M_PI endAngle:3 * M_PI / 2 clockwise:YES];
        if (i == 2) {
            [path addLineToPoint:CGPointMake(cropRect.origin.x + radius + offSet, cropRect.origin.y )];
            
            [path moveToPoint:CGPointMake(cropRect.origin.x + cropRect.size.width - radius - offSet, cropRect.origin.y )];
        }
        [path addArcWithCenter:CGPointMake(cropRect.origin.x + cropRect.size.width - radius, cropRect.origin.y + radius) radius:radius startAngle:3 * M_PI / 2 endAngle:2 * M_PI  clockwise:YES];
        if (i == 2) {
            [path addLineToPoint:CGPointMake(cropRect.origin.x + cropRect.size.width , cropRect.origin.y + radius + offSet)];
            
            [path moveToPoint:CGPointMake(cropRect.origin.x + cropRect.size.width , cropRect.origin.y + cropRect.size.height - radius - offSet)];
        }
        [path addArcWithCenter:CGPointMake(cropRect.origin.x + cropRect.size.width - radius , cropRect.origin.y + cropRect.size.height - radius) radius:radius startAngle:0 endAngle: M_PI / 2 clockwise:YES];
        if (i == 2) {
            [path addLineToPoint:CGPointMake(cropRect.origin.x + cropRect.size.width - radius - offSet , cropRect.origin.y + cropRect.size.height)];
            
            [path moveToPoint:CGPointMake(cropRect.origin.x + radius + offSet, cropRect.origin.y + cropRect.size.height)];
        }
        [path addArcWithCenter:CGPointMake(cropRect.origin.x + radius, cropRect.origin.y + cropRect.size.height -radius) radius:radius startAngle:M_PI/2 endAngle: M_PI  clockwise:YES];
        
        if (i == 2) {
            
            [path addLineToPoint:CGPointMake(cropRect.origin.x, cropRect.origin.y + cropRect.size.height - radius - offSet)];
            
            [path moveToPoint:CGPointMake(cropRect.origin.x, cropRect.origin.y + cropRect.size.height - radius - offSet)];
            [path closePath];
            
        }
        
        CGFloat Height = [UIScreen mainScreen].bounds.size.height;
        CGFloat Width  = [UIScreen mainScreen].bounds.size.width;
        
        
        //create shape layer
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        
        shapeLayer.lineWidth = 2;
        
        if (i == 0) {
            [path moveToPoint:CGPointMake(0, 0)];
            [path addLineToPoint:CGPointMake(0, Height)];
            [path addLineToPoint:CGPointMake(Width, Height)];
            [path addLineToPoint:CGPointMake(Width, 0)];
            [path addLineToPoint:CGPointMake(0, 0)];
            
            shapeLayer.strokeColor = [UIColor clearColor].CGColor;
            shapeLayer.fillColor = [[UIColor colorWithRed:0 green:0 blue:0 alpha:0.7] CGColor];
            shapeLayer.fillRule = kCAFillRuleNonZero;
        }
        
        
        
        if (i == 1) {
            [path addLineToPoint:CGPointMake(cropRect.origin.x , cropRect.origin.y + radius)];
            shapeLayer.strokeColor = [[UIColor whiteColor] colorWithAlphaComponent:.5].CGColor;
            shapeLayer.fillColor = [UIColor clearColor].CGColor;
            shapeLayer.fillRule = kCAFillRuleNonZero;
            shapeLayer.lineWidth = 1;
        }
        
        if ( i == 2) {
            shapeLayer.strokeColor = kBlueColor.CGColor;
            shapeLayer.fillColor = [UIColor clearColor].CGColor;
            //            shapeLayer.fillRule = kCAFillRuleNonZero;
            
        }
        
        shapeLayer.lineJoin = kCALineJoinBevel;
        shapeLayer.lineCap = kCALineCapRound;
        shapeLayer.path = path.CGPath;
        [containerView.layer addSublayer:shapeLayer];
        
    }
    

    
}



#define SCREEN_W  [UIScreen mainScreen].bounds.size.width
#define SCREEN_H  [UIScreen mainScreen].bounds.size.height

#pragma mark 恢复动画
- (void)resumeAnimation
{
    CAAnimation *anim = [_scanNetImageView.layer animationForKey:@"translationAnimation"];
    if(anim){
        // 1. 将动画的时间偏移量作为暂停时的时间点
        CFTimeInterval pauseTime = _scanNetImageView.layer.timeOffset;
        // 2. 根据媒体时间计算出准确的启动动画时间，对之前暂停动画的时间进行修正
        CFTimeInterval beginTime = CACurrentMediaTime() - pauseTime;
        
        // 3. 要把偏移时间清零
        [_scanNetImageView.layer setTimeOffset:0.0];
        // 4. 设置图层的开始动画时间
        [_scanNetImageView.layer setBeginTime:beginTime];
        
        [_scanNetImageView.layer setSpeed:1.0];
        
    }else{
        
        CGFloat scanWindowW = SCREEN_W - kMargin * 2;
        CGFloat scanNetImageViewW = _imageView.frame.size.width;
        
        _scanNetImageView.frame = CGRectMake(kMargin, kBorderW, scanWindowW, 2);
        _scanNetImageView.contentMode = 1;
        CABasicAnimation *scanNetAnimation = [CABasicAnimation animation];
        scanNetAnimation.keyPath = @"transform.translation.y";
        scanNetAnimation.byValue = @([UIScreen mainScreen].bounds.size.height - 178 - kMargin);
        scanNetAnimation.duration = 3.0;
        scanNetAnimation.repeatCount = MAXFLOAT;
        [_scanNetImageView.layer addAnimation:scanNetAnimation forKey:@"translationAnimation"];
        [_imageView addSubview:_scanNetImageView];
    }
    
    
    
}

- (void)stopAnimate {
    
    [_scanNetImageView.layer removeAllAnimations];
}
#pragma mark - Load View



#pragma mark - User Interaction

-(void)inputManager:(id)sender {
    
    switch ([(UIButton *)sender tag]) {
        case ShutterButtonTag:  [self onTapShutterButton];  return;
            break;
        case DismissButtonTag:
            if (_imageView.hidden == YES) {
                
            } else {
                [self onTapDismissButton];
                return;
            }
            break;
        case FlashButtonTag:    [self onTapFlashButton];    return;
            break;
        default:
            break;
    }
    [((UINavigationController *)self.delegate).navigationController popViewControllerAnimated:YES];
}

- (void)onTapShutterButton {
    
    
    if ([Reachability network] == network_none )
    {
        [self makeToast:@"无网络连接" duration:.5 position:CSToastPositionCenter title:nil image:nil];
        return ;

    }
    
    [DialerUsageRecord recordpath:PATH_SCANCARD
                              kvs:Pair(CONTACT_SCANCARD_CAMERA_CLICK, @(1)), nil];
    
    if ([_captureManager checkCameraAccessable]){
        [_captureManager captureStillImage];
        _imageView.image = _captureManager.stillImage;
        _imageView.hidden = NO;
        _cameraShutter.superview.hidden = YES;
        _fitterView.hidden = YES;
        [self stopAnimate];
        
        
    }else {
        
        UIAlertView *alertview = [[UIAlertView alloc]initWithTitle:@"提示" message:@"暂时无法获取拍照权限，是否进入设置中打开权限" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alertview show];
    }
    
    
    
}


- (void)onTapFlashButton {
    
    _cameraFlash.selected = !_cameraFlash.selected;
    [_cameraFlash setTitle:@"8" forState:UIControlStateSelected];
    _cameraFlash.titleLabel.font = [UIFont fontWithName:@"iPhoneIcon4" size:28];

    BOOL enable = !self.captureManager.isTorchEnabled;
    self.captureManager.enableTorch = enable;
}

- (void)onTapToggleButton {
    if (cameraBeingUsed == RearFacingCamera) {
        [self setupCaptureManager:FrontFacingCamera];
        cameraBeingUsed = FrontFacingCamera;
        [self composeInterface];
        [[_captureManager captureSession] startRunning];
        _cameraFlash.hidden = YES;
    }
}

- (void)onTapDismissButton {
    
//    if (_imageView.hidden == NO) {
////        _imageView.hidden = YES;
//        _cameraShutter.superview.hidden = NO;
//        _fitterView.hidden = NO;
//    }
    [((UINavigationController *)self.delegate).navigationController popViewControllerAnimated:YES];

}

- (void)focusGesture:(id)sender {
    
    if ([sender isKindOfClass:[UITapGestureRecognizer class]]) {
        UITapGestureRecognizer *tap = sender;
        if (tap.state == UIGestureRecognizerStateRecognized) {
            CGPoint location = [sender locationInView:self];
            
            [self focusAtPoint:location completionHandler:^{
                [self animateFocusReticuleToPoint:location];
            }];
        }
    }
}

#pragma mark - Animation

- (void)animateShutterRelease {
    
    _animationInProgress = YES; //Disables input manager
    
    [UIView animateWithDuration:.1 animations:^{
        _cameraShutter.transform = CGAffineTransformMakeScale(1.25, 1.25);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:.1 animations:^{
            _cameraShutter.transform = CGAffineTransformMakeScale(1, 1);
        } completion:^(BOOL finished) {
            
            _animationInProgress = NO; //Enables input manager
        }];
    }];
}

- (void)animateFocusReticuleToPoint:(CGPoint)targetPoint
{
    _animationInProgress = YES; //Disables input manager
    
    [self.focalReticule setCenter:targetPoint];
    self.focalReticule.alpha = 0.0;
    self.focalReticule.hidden = NO;
    
    [UIView animateWithDuration:0.4 animations:^{
        self.focalReticule.alpha = 1.0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.4 animations:^{
            self.focalReticule.alpha = 0.0;
        }completion:^(BOOL finished) {
            
            _animationInProgress = NO; //Enables input manager
        }];
    }];
}

- (void)orientationChanged:(NSNotification *)notification{
    
    //Animate top bar buttons on orientation changes
    switch ([[UIDevice currentDevice] orientation]) {
        case UIDeviceOrientationPortrait:
        {
            //Standard device orientation (Portrait)
            [UIView animateWithDuration:0.6 animations:^{
                CGAffineTransform transform = CGAffineTransformMakeRotation( 0 );
                
                _cameraFlash.transform = transform;
                //                _cameraFlash.center = CGPointMake(_topBarView.center.x * 0.80, _topBarView.center.y);
                
                _cameraToggle.transform = transform;
                //                _cameraToggle.center = CGPointMake(_topBarView.center.x * 1.20, _topBarView.center.y);
                
                //                _cameraDismiss.center = CGPointMake(20, _bottomBarView.center.y);
            }];
        }
            break;
        case UIDeviceOrientationLandscapeLeft:
        {
            //Device orientation changed to landscape left
            [UIView animateWithDuration:0.6 animations:^{
                CGAffineTransform transform = CGAffineTransformMakeRotation( M_PI_2 );
                
                _cameraFlash.transform = transform;
                //                _cameraFlash.center = CGPointMake(_topBarView.center.x * 1.25, _topBarView.center.y);
                
                _cameraToggle.transform = transform;
                //                _cameraToggle.center = CGPointMake(_topBarView.center.x * 1.60, _topBarView.center.y);
                
                //                _cameraDismiss.center = CGPointMake(_topBarView.center.x * 0.25, _topBarView.center.y);
            }];
        }
            break;
        case UIDeviceOrientationLandscapeRight:
        {
            //Device orientation changed to landscape right
            [UIView animateWithDuration:0.6 animations:^{
                CGAffineTransform transform = CGAffineTransformMakeRotation( - M_PI_2 );
                
                _cameraFlash.transform = transform;
                //                _cameraFlash.center = CGPointMake(_topBarView.center.x * 0.40, _topBarView.center.y);
                
                _cameraToggle.transform = transform;
                //                _cameraToggle.center = CGPointMake(_topBarView.center.x * 0.75, _topBarView.center.y);
                
                //                _cameraDismiss.center = CGPointMake(_topBarView.center.x * 1.75, _topBarView.center.y);
            }];
        }
            break;
        default:;
    }
}

#pragma mark - Camera Session Manager Delegate Methods

-(void)cameraSessionManagerDidCaptureImage
{
    
        if (self.delegate)
        {
            if ([self.delegate respondsToSelector:@selector(didCaptureImage:)])
                [self.delegate didCaptureImage:[[self captureManager] stillImage]];
    
            if ([self.delegate respondsToSelector:@selector(didCaptureImageWithData:)])
                [self.delegate didCaptureImageWithData:[[self captureManager] stillImageData]];
        }
    [self makeToastActivity];
    [self hideToastActivity];
    _scanNetImageView.hidden = YES;
    _imageView.image = _captureManager.stillImage;
    _imageView.hidden = NO;
    
}

-(void)cameraSessionManagerFailedToCaptureImage {
}

-(void)cameraSessionManagerDidReportAvailability:(BOOL)deviceAvailability forCameraType:(CameraType)cameraType {
}

-(void)cameraSessionManagerDidReportDeviceStatistics:(CameraStatistics)deviceStatistics {
}

#pragma mark - Helper Methods

- (void)focusAtPoint:(CGPoint)point completionHandler:(void(^)())completionHandler
{
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];;
    CGPoint pointOfInterest = CGPointZero;
    CGSize frameSize = self.bounds.size;
    pointOfInterest = CGPointMake(point.y / frameSize.height, 1.f - (point.x / frameSize.width));
    
    if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        
        //Lock camera for configuration if possible
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            
            if ([device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance]) {
                [device setWhiteBalanceMode:AVCaptureWhiteBalanceModeAutoWhiteBalance];
            }
            
            if ([device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
                [device setFocusMode:AVCaptureFocusModeAutoFocus];
                [device setFocusPointOfInterest:pointOfInterest];
            }
            
            if([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
                [device setExposurePointOfInterest:pointOfInterest];
                [device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
            }
            
            [device unlockForConfiguration];
            
            completionHandler();
        }
    }
    else { completionHandler(); }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(BOOL)shouldAutorotate
{
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

-(void)viewDidDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

#pragma mark - API Functions

- (void)setTopBarColor:(UIColor *)topBarColor
{
    _bottomBarView.backgroundColor = topBarColor;
}

- (void)hideFlashButton
{
    _cameraFlash.hidden = YES;
}

- (void)hideCameraToggleButton
{
    _cameraToggle.hidden = YES;
}

- (void)hideDismissButton
{
    _cameraDismiss.hidden = YES;
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (buttonIndex) {
        case 0:
            break;
        case 1:
            [self toSetting];
            break;
            
        default:
            break;
    }
    NSLog( @"%@",@(buttonIndex));
    
    
}

- (void)toSetting {
    NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    
    if([[UIApplication sharedApplication] canOpenURL:url]) {
        
        NSURL*url =[NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:url];
        
    }
    //    [((UIViewController *)self.delegate).navigationController popViewControllerAnimated:YES];
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

#pragma mark ***************
#pragma mark - TPScanCardViewController
@interface TPScanCardViewController ()<TPCameraSessionDelegate>
@property (nonatomic, strong) TPCameraSessionView *cameraView;
@property (readwrite        ) BOOL  isScanToPop;
@property (nonatomic, strong) ContactModel* tmp;
@end

@implementation TPScanCardViewController
- (void)viewWillAppear:(BOOL)animated {
    
    self.navigationController.navigationBarHidden = YES;
    if (_isScanToPop) {
        [self.navigationController popViewControllerAnimated:NO];
    }
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.view.backgroundColor  =[UIColor blackColor];
    [self launchCamera];
    _isScanToPop = NO;
    
 }
- (void)viewDidAppear:(BOOL)animated {

    if ([_cameraView.captureManager checkCameraAccessable] == NO) {
        UIAlertView *alertview = [[UIAlertView alloc]initWithTitle:@"提示" message:@"暂时无法获取拍照权限，是否进入设置中打开权限" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alertview.tag = 10;
        [alertview show];
        
        
    }

}
- (void)launchCamera {
    
    //Set white status bar
    [self setNeedsStatusBarAppearanceUpdate];
    
    //Instantiate the camera view & assign its frame
    _cameraView = [[TPCameraSessionView alloc] initWithFrame:self.view.frame];
    
   
    //Set the camera view's delegate and add it as a subview
    _cameraView.delegate = self;
    
    //Apply animation effect to present the camera view
    CATransition *applicationLoadViewIn =[CATransition animation];
    [applicationLoadViewIn setDuration:0.6];
    [applicationLoadViewIn setType:kCATransitionReveal];
    [applicationLoadViewIn setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    [[_cameraView layer]addAnimation:applicationLoadViewIn forKey:kCATransitionReveal];
    
    [self.view addSubview:_cameraView];
    
    //____________________________Example Customization____________________________
    //[_cameraView setTopBarColor:[UIColor colorWithRed:0.97 green:0.97 blue:0.97 alpha: 0.64]];
    //[_cameraView hideFlashButton]; //On iPad flash is not present, hence it wont appear.
    //[_cameraView hideCameraToggleButton];
    //[_cameraView hideDismissButton];
}




#pragma mark - cameraDelegate
-(void)didCaptureImage:(UIImage *)image {
//    NSLog(@"CAPTURED IMAGE");
//    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
//    [self.cameraView removeFromSuperview];
//    
//    
    [self.view makeToastActivity];
//star netrequest
    
    
    
}

-(void)didCaptureImageWithData:(NSData *)imageData {
    NSLog(@"CAPTURED IMAGE DATA");
    //UIImage *image = [[UIImage alloc] initWithData:imageData];
    //UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    //[self.cameraView removeFromSuperview];
    
//    [self sendRequest:imageData];
    [self checkEnable:imageData];
    //    [self addNewTestContacter:[self formatData:nil]];
}

- (void)addNewTestContacter : (ContactModel *)contactModel{

         CFErrorRef error = NULL;
        
        //创建一个通讯录操作对象
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
        
        //创建一条新的联系人纪录
        ABRecordRef newRecord = ABPersonCreate();
        
        //为新联系人记录添加属性值
    ABRecordSetValue(newRecord, kABPersonLastNameProperty, (__bridge CFTypeRef)contactModel.name, &error);
    ABRecordSetValue(newRecord, kABPersonOrganizationProperty, (__bridge CFTypeRef)contactModel.company, &error);
    ABRecordSetValue(newRecord, kABPersonJobTitleProperty, (__bridge CFTypeRef)contactModel.tittle, &error);
    
//    ABRecordSetValue(newRecord, kABPersonEmailProperty, (__bridge CFTypeRef)@"123123", &error);

        //创建一个多值属性
        ABMutableMultiValueRef multiPhone = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    
    
    
    for (Model *model in contactModel.phoneArray) {
        ABMultiValueAddValueAndLabel(multiPhone, (__bridge CFTypeRef)model.name, kABPersonPhoneIPhoneLabel, NULL);
        
    }
     //地址
    /*添加联系人的地址信息*/
    //实例化多值属性
    ABMultiValueRef addressMultiValue = ABMultiValueCreateMutable(kABMultiDictionaryPropertyType);
    
    //设置相关标志位
    ABMultiValueIdentifier AddressIdentifier;
    
    //初始化字典属性
    CFMutableDictionaryRef addressDictionaryRef = CFDictionaryCreateMutable(kCFAllocatorSystemDefault, 0, NULL, NULL);
    

    //进行添加
    CFDictionaryAddValue(addressDictionaryRef, kABPersonAddressCountryKey, (__bridge CFStringRef)contactModel.country);      //国家
    CFDictionaryAddValue(addressDictionaryRef, kABPersonAddressCityKey, (__bridge CFStringRef)contactModel.locality);       //城市
    CFDictionaryAddValue(addressDictionaryRef, kABPersonAddressStateKey, (__bridge CFStringRef)@"");    //省(区)
    CFDictionaryAddValue(addressDictionaryRef, kABPersonAddressStreetKey, (__bridge CFStringRef)(contactModel.addressString));      //街道
    CFDictionaryAddValue(addressDictionaryRef, kABPersonAddressZIPKey, (__bridge CFStringRef)@"");         //邮编
    CFDictionaryAddValue(addressDictionaryRef, kABPersonAddressCountryCodeKey, (__bridge CFStringRef)@"");    //ISO国家编码
    
    if (!([contactModel.country isEqualToString:@""] && [contactModel.locality isEqualToString:@""] && [contactModel.addressString isEqualToString:@""])) {
        //添加属性
        ABMultiValueAddValueAndLabel(addressMultiValue, addressDictionaryRef, (__bridge CFStringRef)@"工作", &AddressIdentifier);
        ABRecordSetValue(newRecord, kABPersonAddressProperty, addressMultiValue, &error);
    }
    //释放资源
    CFRelease(addressMultiValue);

    
    
        //将多值属性添加到记录
    ABRecordSetValue(newRecord, kABPersonPhoneProperty, multiPhone, &error);
  
    
    
    /*添加联系人的邮件信息*/
    //实例化多值属性
    ABMultiValueRef emailMultiValue = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    
    //设置相关标志位
    ABMultiValueIdentifier QQIdentifier;//QQ
    
    //进行赋值
    //设置自定义的标签以及值
    ABMultiValueAddValueAndLabel(emailMultiValue, (__bridge CFStringRef)((Model *)contactModel.emailArray[0]).name, (__bridge CFStringRef)@"工作", &QQIdentifier);
    
    //添加属性
    ABRecordSetValue(newRecord, kABPersonEmailProperty, emailMultiValue, &error);
    
    //释放资源
    CFRelease(emailMultiValue);
    
    
    
    /*添加联系人的邮件信息*/
    //实例化多值属性
    ABMultiValueRef urlMultiValue = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    
    //设置相关标志位
    ABMultiValueIdentifier urlIdentifier;//QQ
    
    //进行赋值
    //设置自定义的标签以及值
    ABMultiValueAddValueAndLabel(urlMultiValue, (__bridge CFStringRef)contactModel.URLString, kABPersonHomePageLabel, &urlIdentifier);
    
    if (![contactModel.URLString isEqualToString:@""]) {
        //添加属性
        ABRecordSetValue(newRecord, kABPersonURLProperty, urlMultiValue, &error);
    }
    
    //释放资源
    CFRelease(urlMultiValue);

    
    
    
    
    
    
    
    
        //添加记录到通讯录操作对象
        ABAddressBookAddRecord(addressBook, newRecord, &error);
    
    [[TPABPersonActionController controller] addPersonByRecord:newRecord presentedBy:self];

        
        CFRelease(newRecord);
        CFRelease(addressBook);




}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    //Show error alert if image could not be saved
    if (error) [[[UIAlertView alloc] initWithTitle:@"Error!" message:@"Image couldn't be saved" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
}



- (void)checkEnable:(NSData *)imageData{
    
    NSString *token = [SeattleFeatureExecutor getToken];
    
    NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"http://touchlife.cootekservice.com/yellowpage_v3/experiment_query?_token=%@&experiment_name=cards_scanning",token]];
    
    //post请求
    
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url cachePolicy:1 timeoutInterval:2.0f];
    request.HTTPMethod=@"GET";//设置请求方法是POST
    request.timeoutInterval=15;//设置请求超时
    
    
    //连接(NSURLSession)
    NSURLSession *session=[NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask=[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error != nil) {
            [error.userInfo[@"NSLocalizedDescription"] isEqualToString:@"请求超时。"];
            [self.cameraView hideToastActivity];

            [DialerUsageRecord recordpath:PATH_SCANCARD
                                      kvs:Pair(CONTACT_SCANCARD_TIMEOUT, @(1)), nil];
            
        }
        
        NSError *error2 ;
        if ( data == nil) {
            [self.cameraView hideToastActivity];

            return ;
        }
        id result=[NSJSONSerialization JSONObjectWithData:data options:0 error:&error2];
        NSLog(@"get==%@",result);
        if (result == nil) {
            return;
        }
        
        if ([result isKindOfClass:[NSDictionary class]]) {
            if ([result[@"result"] isKindOfClass:[NSDictionary class]]) {
                if ([result[@"result"][@"error_code"] longValue] == 2000) {
                    if ([result[@"result"][@"experiment_result"] isEqualToString:@"yes"]) {
                        
                        dispatch_async(dispatch_get_global_queue(0, 0), ^{
                       
                            [self sendRequest:imageData];
                            [DialerUsageRecord recordpath:PATH_SCANCARD
                                                      kvs:Pair(CONTACT_SCANCARD_ACCESS_SUCCESS, @(1)), nil];
                            });
                        
                    }else if([result[@"result"][@"experiment_result"] isEqualToString:@"no"]) {
                    
                        dispatch_async(dispatch_get_main_queue(), ^{

                        [DialerUsageRecord recordpath:PATH_SCANCARD
                                                  kvs:Pair(CONTACT_SCANCARD_ACCESS_FAIL, @(1)), nil];

                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"本服务限量开放。今日配额已全部用完，请明日再试。敬请谅解" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
                        [alert show];
                        });

                    }
                }
                
            }
            
            
        }
        
    }];
    [dataTask resume];
    
    
    
}


- (void)sendRequest:(NSData *)data {
    
    //    [CCMTHttpRequestManager postImage];
    
    //
    //url
    
    NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"https://bcr2.intsig.net/BCRService/BCR_VCF2?PIN=290BD181296&user=hui.huang@cootek.cn&pass=3XPFEBKB73BMYMN6&lang=15&size=%@&json=1",@(data.length)] ];
    
    //post请求
    NSMutableURLRequest *request=[self requestWithURL:url andFilenName:@"test.jpg" andLocalFilePath:data/*[[NSBundle mainBundle]pathForResource:@"test.jpg" ofType:@"image/jpg"]*/];
    request.timeoutInterval=15;//设置请求超时

    //连接(NSURLSession)
    NSURLSession *session=[NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask=[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSError *error2 ;
        if (error != nil) {
            [error.userInfo[@"NSLocalizedDescription"] isEqualToString:@"请求超时。"];
            [self.cameraView hideToastActivity];
            [DialerUsageRecord recordpath:PATH_SCANCARD
                                      kvs:Pair(CONTACT_SCANCARD_TIMEOUT, @(1)), nil];
            
        }

        if ( data == nil) {
            [self.cameraView hideToastActivity];
            return ;
        }
        id result=[NSJSONSerialization JSONObjectWithData:data options:0 error:&error2];
        NSLog(@"post==%@",result);
        if (result == nil) {
            [self.cameraView hideToastActivity];
         return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([result isKindOfClass:[NSDictionary class]]) {
                [DialerUsageRecord recordpath:PATH_SCANCARD
                                          kvs:Pair(CONTACT_SCANCARD_SUCCESS, @(1)), nil];
                self.tmp = [self formatData:result];
                [self addNewTestContacter:self.tmp];
                _isScanToPop = YES;

            }else {
                [DialerUsageRecord recordpath:PATH_SCANCARD
                                          kvs:Pair(CONTACT_SCANCARD_FAIL, @(1)), nil];
                self.tmp = [self formatData:result];
                [self addNewTestContacter:self.tmp];
                _isScanToPop = YES;

                
                

            
            }
        });

        
    }];
    [dataTask resume];
    
}
- (ContactModel *)formatData : (NSDictionary *)result {
/*
 @property (nonatomic, strong)NSString *name;
 @property (nonatomic, strong)NSString *tittle;
 @property (nonatomic, strong)NSString *address;
 @property (nonatomic, strong)NSArray  *phoneArray;
 @property (nonatomic, strong)NSArray  *emailArray;
 @property (nonatomic, strong)NSArray  *faxArray;

 */
    
    
    ContactModel *contact = [ContactModel new];
    
    contact.name = result[@"formatted_name"][0][@"item"];
    if (contact.name == nil) {
        contact.name = @"";
    }
    contact.tittle = result[@"title"][0][@"item"];
    if (contact.tittle == nil) {
        contact.tittle = @"";
    }
    contact.URLString = result[@"url"][0][@"item"];
    if (contact.URLString == nil) {
        contact.URLString = @"";
    }
    contact.addressString = [result[@"address"][0][@"item"][@"street"] copy];
    if (contact.addressString == nil) {
        contact.addressString = @"";
    }
    contact.locality = [result[@"address"][0][@"item"][@"locality"] copy];
    if (contact.locality == nil) {
        contact.locality = @"";
    }
    contact.country = [result[@"address"][0][@"item"][@"country"] copy];
    if (contact.country == nil) {
        contact.country = @"";
    }
    contact.company = result[@"organization"][0][@"item"][@"name"];
    if (contact.company == nil) {
        contact.company = result[@"organization"][0][@"item"][@"unit"];
    }
    if (contact.company == nil) {
        contact.company = @"";
    }

    
    
    if (((NSArray *) result[@"telephone"]).count > 0) {
        NSMutableArray *phone = [NSMutableArray new];
        for (int i = 0 ; i <((NSArray *) result[@"telephone"]).count ; i ++ ) {
            Model *new = [Model new];
            new.name = result[@"telephone"][i][@"item"][@"number"];
            if (new.name == nil) {
                new.name = @"";
            }
            [phone addObject:new];
        }
        contact.phoneArray = phone;

    }
    
    if (((NSArray *) result[@"email"]).count > 0) {
        NSMutableArray *phone = [NSMutableArray new];
        for (int i = 0 ; i <((NSArray *) result[@"email"]).count ; i ++ ) {
            Model *new = [Model new];
            new.name = result[@"email"][i][@"item"];
            if (new.name == nil) {
                new.name = @"";
            }
            [phone addObject:new];
        }
        contact.emailArray = phone;
        
    }

    if (((NSArray *) result[@"telephone"]).count == 0 && [contact.name isEqualToString:@""] ) {
        [DialerUsageRecord recordpath:PATH_SCANCARD
                                  kvs:Pair(CONTACT_SCANCARD_SUCCESS_WITH_NO_NAME_AND_NUMBER, @(1)), nil];

    }
 
    return  contact;
}


- (NSMutableURLRequest *)requestWithURL:(NSURL *)url andFilenName:(NSString *)fileName andLocalFilePath:(NSData *)data{
    
    //post请求
    
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url cachePolicy:1 timeoutInterval:15.0f];
    request.HTTPMethod=@"POST";//设置请求方法是POST
    request.timeoutInterval=15.0;//设置请求超时
    
    //拼接请求体数据(1-6步)
    request.HTTPBody = data;//[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"test" ofType:@"jpg"]];
    return request;
    
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 10) {
        
        switch (buttonIndex) {
            case 0:
                break;
            case 1:
                [self toSetting];
                break;
                
            default:
                break;
        }
        NSLog( @"%@",@(buttonIndex));
        
        
        
        
    }else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)toSetting {
    NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    
    if([[UIApplication sharedApplication] canOpenURL:url]) {
        
        NSURL*url =[NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:url];
        
    }
    //    [((UIViewController *)self.delegate).navigationController popViewControllerAnimated:YES];
}

@end
#pragma mark ***************

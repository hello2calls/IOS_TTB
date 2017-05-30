//
//  TPContactPhotoActionController.m
//  TouchPalDialer
//
//  Created by Chen Lu on 11/25/12.
//
//

#import "TPContactPhotoActionController.h"
#import <AddressBook/AddressBook.h>
#import "TPAddressBookWrapper.h"
#import "SyncContactInApp.h"
#import "PersonDBA.h"
#import "DefaultUIAlertViewHandler.h"
#import "AVFoundation/AVCaptureDevice.h"
#import "AVFoundation/AVMediaFormat.h"

@interface TPContactPhotoActionController (){
    UIImageView __strong *photoView_;
    UIButton __strong *pageSizeButton_;
    BOOL hasPhoto_;
}

@property (nonatomic, retain) UIViewController *presentingViewController;
@property (nonatomic, assign) NSInteger personId;

@end

static TPContactPhotoActionController *instance;

@implementation TPContactPhotoActionController

@synthesize presentingViewController = presentingViewController_;
@synthesize personId = personId_;

+(void)initialize{
    instance = [[TPContactPhotoActionController alloc]init];
}

+(TPContactPhotoActionController *)controller
{
    return instance;
}

-(void)doContactPhotoActionByPersonId:(NSInteger)personId presentedBy:(UIViewController *)aViewController
{
    if (personId <= 0) {
        return;
    }
    
    self.presentingViewController = aViewController;
    self.personId = personId;
    
    ABAddressBookRef addressBook = [TPAddressBookWrapper RetrieveAddressBookRefForCurrentThread];
    ABRecordRef personRecord = ABAddressBookGetPersonWithRecordID(addressBook,personId_);
    hasPhoto_ = ABPersonHasImageData(personRecord);
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Take photo", @"")];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Load from file", @"")];
    if (hasPhoto_) {
        [actionSheet addButtonWithTitle:NSLocalizedString(@"Original size", @"")];
    }
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", @"")];
    actionSheet.cancelButtonIndex = hasPhoto_ ? 3 : 2;
    
    actionSheet.delegate = self;
    
    [actionSheet showInView:self.presentingViewController.view];
}

-(BOOL)checkCameraAuthorization
{
    BOOL isAvalible = YES;
    //ios 7.0以上的系统新增加摄像头权限检测
    if ([[[UIDevice currentDevice]systemVersion]floatValue] >= 7.0) {
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        switch (authStatus) {
            case AVAuthorizationStatusRestricted:
            cootek_log(@"Restricted");
            break;
            case AVAuthorizationStatusDenied:
            cootek_log(@"Denied");
            isAvalible = NO;
            break;
            case AVAuthorizationStatusAuthorized:
            cootek_log(@"Authorized");
            break;
            case AVAuthorizationStatusNotDetermined:
            break;
            default:
            break;
        }
    }
    if (!isAvalible) {
        NSString *message = NSLocalizedString(@"您关闭了触宝电话的相机权限，无法进行拍照。可以在手机 > 设置 > 隐私 > 相机中开启权限。",@"");
        [DefaultUIAlertViewHandler showAlertViewWithTitle:message message:nil];
    }
    
    return isAvalible;
}

#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0: //camera
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                if([self checkCameraAuthorization]) {
                    [self getPhotoViaSourceType:UIImagePickerControllerSourceTypeCamera];
                }
            }
            break;
        case 1: //photo library
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
                [self getPhotoViaSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            }
            break;
        case 2:
            if (hasPhoto_) {
                [self showPhotoInOriginalSize];
            }
        default:
            break;
    }
    actionSheet.delegate = nil;
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    actionSheet.delegate = nil;
}

- (void)getPhotoViaSourceType:(UIImagePickerControllerSourceType)sourceType {
    UIImagePickerController * photoPicker = [[UIImagePickerController alloc] init];
    photoPicker.sourceType = sourceType;
    photoPicker.delegate = self;
    photoPicker.allowsEditing = YES;
    [self.presentingViewController presentViewController:photoPicker animated:YES completion:^(){}];
}

- (void) showPhotoInOriginalSize
{
    ABAddressBookRef addressBook = [TPAddressBookWrapper RetrieveAddressBookRefForCurrentThread];
    ABRecordRef personRecord = ABAddressBookGetPersonWithRecordID(addressBook,personId_);

    pageSizeButton_ = [UIButton buttonWithType:UIButtonTypeCustom];
    pageSizeButton_.frame = [self.presentingViewController.view bounds];
    [pageSizeButton_ addTarget:self action:@selector(hidePhoto) forControlEvents:UIControlEventTouchUpInside];
    [self.presentingViewController.view addSubview:pageSizeButton_];
    
    CFDataRef imageData = ABPersonCopyImageData(personRecord);
    UIImage *photo = [[UIImage alloc] initWithData:(__bridge NSData*)imageData];
    
    photoView_ = [[UIImageView alloc] initWithImage:photo];
    int y = (self.presentingViewController.view.frame.size.height - 320)/2;
    photoView_.frame = CGRectMake(20, y, TPScreenWidth() -40, 320);
    if (photo.size.width < photoView_.frame.size.width) {
        photoView_.frame = CGRectMake((TPScreenWidth() - photo.size.width)/2,y, photo.size.width, 320);
    }
    
    photoView_.contentMode = UIViewContentModeScaleAspectFit;
    photoView_.clipsToBounds = YES;
    [self.presentingViewController.view addSubview:photoView_];
    CFRelease(imageData);
    
    [UIView animateWithDuration:0.5f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         pageSizeButton_.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
                         photoView_.alpha = 0;
                         photoView_.alpha = 1;
                         pageSizeButton_.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
                     }
                     completion:nil];
}

- (void) hidePhoto
{
    [UIView animateWithDuration:0.5f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         pageSizeButton_.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
                         photoView_.alpha = 1;
                         photoView_.alpha = 0;
                         pageSizeButton_.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
                     }
                     completion:^(BOOL finished){
                         [photoView_ removeFromSuperview];
                         [pageSizeButton_ removeFromSuperview];
                     }];
}

#pragma mark UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    
    ABAddressBookRef addressBook = [TPAddressBookWrapper RetrieveAddressBookRefForCurrentThread];
    ABRecordRef personRecord = ABAddressBookGetPersonWithRecordID(addressBook,personId_);
    ABPersonSetImageData(personRecord,(__bridge CFDataRef)UIImagePNGRepresentation(image),NULL);
    
    BOOL isSuccess = ABAddressBookAddRecord(addressBook, personRecord, NULL);
    if (isSuccess) {
        isSuccess = ABAddressBookSave (addressBook, NULL);
    }
    if (isSuccess) {
        [SyncContactInApp editPerson:[PersonDBA contactCacheDataModelByRecord:personRecord]];
    }
    
    [picker dismissViewControllerAnimated:YES completion:^(){}];
    picker.delegate = nil;
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^(){}];
    picker.delegate = nil;
}

@end

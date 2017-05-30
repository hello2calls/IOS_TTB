//
//  TPContactPhotoActionController.h
//  TouchPalDialer
//
//  Created by Chen Lu on 11/25/12.
//
//

#import <Foundation/Foundation.h>

@interface TPContactPhotoActionController : NSObject<UIActionSheetDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate>

+(TPContactPhotoActionController *) controller;

-(void) doContactPhotoActionByPersonId:(NSInteger)personId
                           presentedBy:(UIViewController *)aViewController;

@end

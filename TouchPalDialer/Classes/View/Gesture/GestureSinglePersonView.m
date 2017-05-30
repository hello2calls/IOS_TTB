//
//  GestureSinglePersonView.m
//  TouchPalDialer
//
//  Created by Admin on 7/1/13.
//
//

#import "GestureSinglePersonView.h"
#import "GestureSettingsViewController.h"
#import "HeaderBar.h"
#import "CootekTableViewCell.h"
#import "GestureEditViewController.h"
#import "GesturePersonPickerViewController.h"
#import "GestureUtility.h"
#import "Person.h"
#import "PersonDBA.h"
#import "ContactCacheDataManager.h"
#import "TPDialerResourceManager.h"
#import "UIView+WithSkin.h"
#import "SkinHandler.h"
#import "UITableView+TP.h"
#import "NSString+PhoneNumber.h"
#import "UIButton+DoneButton.h"
#import "TouchableView.h"

#import "GestureScrollView.h"
#import <QuartzCore/QuartzCore.h>
#import "TouchPalDialerAppDelegate.h"
#import "FunctionUtility.h"
#define ADD_VIEW_TAG 100
#define DISABLE_VIEW_TAG 101
#define DESCRIPT_LABEL 102
#define BUTTON 103

@interface GestureSinglePersonView () <ViewTouchDelegate>{
    UIButton *_deleteButton;
    BOOL _isEditing;
}
@end

@implementation GestureSinglePersonView
@synthesize actionKey;
@synthesize gesture;
@synthesize isAdd;

-(id)initWithGesture:(Gesture *)ges Frame:(CGRect)frame andIndex:(int)index
{
    
    self = [super initWithFrame:frame];
    if (self) {
        self.gesture = ges;
        isAdd = NO;
        //gestureImage && photo
        float widthCandidate2 = frame.size.width;
        float paddingLeft = 11;
        float width = widthCandidate2 - 2*paddingLeft ;
        UIImageView *photoView = [[UIImageView alloc] initWithFrame:CGRectMake(paddingLeft, 0, width, width)];
        photoView.layer.cornerRadius =width/2;
        photoView.layer.masksToBounds = YES;
        UIImageView *gestureBackView = [[UIImageView alloc] initWithFrame:CGRectMake(width-30+paddingLeft, width - 30, 30, 30)];
        gestureBackView.layer.cornerRadius =15;
        gestureBackView.layer.masksToBounds = YES;
        gestureBackView.backgroundColor =[UIColor clearColor];
        UIImageView *gestureView = [[UIImageView alloc] initWithFrame:CGRectMake(width-30+paddingLeft, width - 30, 30, 30)];
        gestureView.layer.cornerRadius =15;
        gestureView.layer.masksToBounds = YES;
        UIImage *photo;
        if ([PersonDBA getImageByRecordID :[GestureUtility getPersonID:self.gesture.name withAction:actionKey]]) {
            photo = [PersonDBA getImageByRecordID :[GestureUtility getPersonID:self.gesture.name withAction:actionKey]];
        } else {
            photo =[PersonDBA getDefaultImageWithoutNameByPersonID:[GestureUtility getPersonID:self.gesture.name withAction:actionKey]];
        }

        UIImage *gestureBack = [[TPDialerResourceManager sharedManager]
                                getImageByName:@"shoushi-bg@2x.png"];
        UIImage *gestureImage = [self.gesture  convertToImage];
        
        photoView.image = photo;
        gestureBackView.image = gestureBack;
        gestureView.image = gestureImage;
        [self addSubview:photoView];
        [self addSubview:gestureBackView];
        [self addSubview:gestureView];
        
        // description
        UILabel* descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(paddingLeft, width + 10, width, 18)];
        descriptionLabel.textAlignment = NSTextAlignmentCenter;
        descriptionLabel.textColor =[[TPDialerResourceManager sharedManager] getResourceByStyle:@"GestureEditViewController_addGestureButtonText_color" needCache:NO];
        descriptionLabel.font = [UIFont systemFontOfSize:15];
        descriptionLabel.textAlignment = NSTextAlignmentCenter;
        descriptionLabel.text = [GestureUtility getName:self.gesture.name];
        descriptionLabel.backgroundColor = [UIColor clearColor];        
        [self addSubview:descriptionLabel];
        
        descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(paddingLeft, width + 28 + 2, width, 15)];
        descriptionLabel.textColor = [[TPDialerResourceManager sharedManager] getResourceByStyle:@"GestureEditViewController_gestureNameButtonText_color" needCache:NO];
        descriptionLabel.font = [UIFont systemFontOfSize:13];
        descriptionLabel.textAlignment = NSTextAlignmentCenter;
        descriptionLabel.backgroundColor = [UIColor clearColor];
        descriptionLabel.text = [GestureUtility getPhoneNumber:self.gesture.name];
        [self addSubview:descriptionLabel];
        // whole button
        TouchableView *wholeTouchView = [[TouchableView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        wholeTouchView.delegate = self;
        [self addSubview:wholeTouchView];
        
        //add delete button
        UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        deleteBtn.frame = CGRectMake(paddingLeft + width -25, -5, 29, 29);
        [deleteBtn setBackgroundImage:[[TPDialerResourceManager sharedManager]
                                       getImageByName:@"local_skin_item_delete@2x.png"]
                             forState:UIControlStateNormal];
        [deleteBtn addTarget:self action:@selector(deleteButtonPressed:)
            forControlEvents:UIControlEventTouchUpInside];
        deleteBtn.tag = index;
        [self addSubview:deleteBtn];
        deleteBtn.hidden = YES;
        _deleteButton = deleteBtn;

    }
    return self;
}

-(id)initWithAdd:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        isAdd = YES;
        float widthCandidate2 = frame.size.width;
        float paddingLeft = 11;
        float width =  widthCandidate2 - 2*paddingLeft ;
        UIImageView *photoView = [[UIImageView alloc] initWithFrame:CGRectMake(paddingLeft, 0, width, width)];
        photoView.contentMode = UIViewContentModeCenter;
        photoView.backgroundColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"GestureEditViewController_addcircle_normal_color"];
//        [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"GestureEditViewController_addcircle_normal_color"];
        photoView.layer.cornerRadius = width/2;
        photoView.layer.masksToBounds = YES;
        UIImage *photo = [[TPDialerResourceManager sharedManager] getImageByName:@"gesture_dial_add_normal@2x.png"];
        photoView.image = photo;
        photoView.tag =ADD_VIEW_TAG;
        [self addSubview:photoView];
        //add disable image
        UIImageView *disableView = [[UIImageView alloc] initWithFrame:
                                        photoView.frame];
        disableView.contentMode = UIViewContentModeCenter;
        disableView.layer.cornerRadius = width/2;
        disableView.layer.masksToBounds = YES;
        disableView.backgroundColor =\
        [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"GestureEditViewController_addcircle_disable_color"];
        UIImage *disableImage = [[TPDialerResourceManager sharedManager]
                                getImageByName:@"gesture_dial_add_disable@2x.png"];
        disableView.image = disableImage;
        [self addSubview:disableView];
        disableView.hidden = YES;
        disableView.tag = DISABLE_VIEW_TAG;
        
        UILabel* descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(paddingLeft, width + 10, width, 18)];
        descriptionLabel.textColor = [[TPDialerResourceManager sharedManager] getResourceByStyle:@"GestureEditViewController_addGestureButtonText_color" needCache:NO];
        descriptionLabel.font = [UIFont systemFontOfSize:15];
        descriptionLabel.textAlignment = NSTextAlignmentCenter;
        descriptionLabel.text = NSLocalizedString(@"Add a gesture",@"");
        descriptionLabel.adjustsFontSizeToFitWidth = YES;
        descriptionLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:descriptionLabel];
        descriptionLabel.tag = DESCRIPT_LABEL;
        
        UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        addBtn.frame = CGRectMake(paddingLeft, 0, width, width);
        addBtn.layer.cornerRadius = width/2;
        addBtn.layer.masksToBounds= YES;
        addBtn.tag = BUTTON;
        [addBtn addTarget:self action:@selector(addGesture) forControlEvents:UIControlEventTouchUpInside];
        UIImage *iameg =[FunctionUtility imageWithColor:[TPDialerResourceManager getColorForStyle:@"tp_color_black_transparency_100"] withFrame:photoView.bounds];
        [addBtn setBackgroundImage:iameg  forState:UIControlStateHighlighted];
        
        [self addSubview:addBtn];
    }
    return self;
}

- (void)onViewTouch {
    if (_isEditing) {
        return;
    }
    [self buttonPressed];

}


- (void)deleteButtonPressed:(UIButton *)button {
    [self.deleteDelegate onDeletePressed:button];
}

- (void)buttonPressed
{
    GestureEditViewController *editGestureController = [[GestureEditViewController alloc]
                                                        initWithGestureName:self.gesture.name];
    editGestureController.signedContact = YES;
    editGestureController.isEditGesture = YES;
    UINavigationController *navigation = [((TouchPalDialerAppDelegate *)[[UIApplication sharedApplication] delegate]) activeNavigationController];
    [navigation  pushViewController:editGestureController animated:YES];    
}


-(void)addGesture
{
    if (_isEditing) {
        return;
    }
    GestureEditViewController *editGestureController = [[GestureEditViewController alloc] init];
    
    [[TouchPalDialerAppDelegate naviController]  pushViewController:editGestureController animated:YES];
}



- (void)hideDeleteButton {
    _isEditing = NO;
    _deleteButton.hidden = YES;
    [self viewWithTag:ADD_VIEW_TAG].hidden = NO;
     [self viewWithTag:BUTTON].hidden = NO;
    [self viewWithTag:DISABLE_VIEW_TAG].hidden = YES;
    ((UILabel *)[self viewWithTag:DESCRIPT_LABEL]).textColor = \
        [[TPDialerResourceManager sharedManager] getResourceByStyle:@"GestureEditViewController_addGestureButtonText_color" needCache:NO];
}

- (void)showDeleteButton {
    _isEditing = YES;
    _deleteButton.hidden = NO;
     [self viewWithTag:BUTTON].hidden = YES;
    [self viewWithTag:DISABLE_VIEW_TAG].hidden = NO;
     [self viewWithTag:ADD_VIEW_TAG].hidden = YES;
    ((UILabel *)[self viewWithTag:DESCRIPT_LABEL]).textColor = \
        [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"GestureEditViewController_alpha_Text_color"];
}

@end

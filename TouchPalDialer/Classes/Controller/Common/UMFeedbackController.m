//
//  UMFeedbackController.m
//  TouchPalDialer
//
//  Created by 袁超 on 15/3/9.
//  re-feature done by siyi. Keep this class name unchanged for compatibility.
//
//

#import "UMFeedbackController.h"
#import <UIKit/UIKit.h>
#import "TPDialerResourceManager.h"
#import "UIView+WithSkin.h"
#import "HeaderBar.h"
#import "TPHeaderButton.h"
#import "UITableView+TP.h"
#import "CustomInputTextFiled.h"
#import "UserDefaultsManager.h"
#import "UMFeedbackFAQController.h"
#import "DefaultUIAlertViewHandler.h"
#import "AVFoundation/AVCaptureDevice.h"
#import "AVFoundation/AVMediaFormat.h"
#import "TouchPalDialerAppDelegate.h"
#import "FunctionUtility.h"
#import "CommonWebViewController.h"
#import "Reachability.h"
#import "CustomInputTextFiled.h"
#import "FunctionUtility.h"
#import "PersonalCenterController.h"
#import "DialerUsageRecord.h"
#import <Usage_iOS/UsageRecorder.h>
#import "UsageConst.h"
#import "TouchPalVersionInfo.h"
#import "NSString+TPHandleNil.h"


#define TOOLBAR_HEIGHT 45

@interface UMFeedbackController() {

    CGFloat keyboardHeight;
    CGFloat firstScrollY;
    BOOL isKeyboardShow;
    NSTimer *timer;
}

@property (nonatomic, retain)NSMutableDictionary *sizeList;
@property (nonatomic, retain)UIView *toolBottomBar;
@property (nonatomic, retain)UIButton *sendButton;
@property (nonatomic, retain)CustomInputTextFiled *textField;
@property (nonatomic, retain)UITableView *messageListView;


@end

@implementation UMFeedbackController {
    UITextField *_contactInputView;
    UITextView *_detailInputView;
    UIButton *_submitButton;
    BOOL _isDetailEdited;
    BOOL _isUpMoved;
    BOOL _shouldMovePageUp;
    UIView *_textViewContainer;
    UILabel *_detailPlaceholder;

    UIColor *_borderColorNormal;
    UIColor *_borderColorHighlighted;

    UIView *_pageContentContainer;
    UILabel *_detailErrorHintView;
    NSInteger _inputCharCount;
}

- (void) viewDidLoad {
    [super viewDidLoad];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    _borderColorNormal = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_200"];
    _borderColorHighlighted = [TPDialerResourceManager getColorForStyle:@"tp_color_light_blue_500"];

    _isDetailEdited = NO;
    _isUpMoved = NO;
    _shouldMovePageUp = NO;
    _inputCharCount = 0;

    CGFloat gY = 0;
    CGFloat pageHorizontalMargin = 20.0f;
    CGFloat pageContentWidth = TPScreenWidth() - pageHorizontalMargin * 2;

    UIFont *descFont = [UIFont systemFontOfSize:13];


    gY = 0;
    //--- header bar
    // header view: back button
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(0, TPHeaderBarHeightDiff(),50, 45)];
    cancelButton.backgroundColor = [UIColor clearColor];
    cancelButton.titleLabel.font = [UIFont fontWithName:@"iPhoneIcon1" size:22];
    [cancelButton setTitle:@"0" forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [cancelButton addTarget:self action:@selector(gotoBack) forControlEvents:UIControlEventTouchUpInside];

    // header view: title
    UILabel* headerTitle = [[UILabel alloc] initWithFrame:CGRectMake(
                    (TPScreenWidth()-198)/2, TPHeaderBarHeightDiff(), 198, 45)];
    headerTitle.backgroundColor = [UIColor clearColor];
    headerTitle.font = [UIFont systemFontOfSize:FONT_SIZE_2];
    headerTitle.textAlignment = NSTextAlignmentCenter;
    headerTitle.text = @"问题和反馈";
    headerTitle.textColor = [UIColor blackColor];

    HeaderBar *headerContainer = [[HeaderBar alloc] initHeaderBar];
    headerContainer.bgView.image = [[TPDialerResourceManager sharedManager] getImageInDefaultPackageByName:@"common_header_bg@2x.png"];

    [headerContainer addSubview:cancelButton];
    [headerContainer addSubview:headerTitle];
    // end of: headerContainer

    CGFloat detailY = 0;
    //--- detail, desc title;
    NSString *detailDesc = @"问题和建议";
    CGSize detailDescSize = [detailDesc sizeWithFont:descFont];
    UILabel *detailDescView = [[UILabel alloc]
        initWithFrame:CGRectMake(0, detailY, detailDescSize.width, detailDescSize.height)];
    detailDescView.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_800"];
    detailDescView.font = descFont;
    detailDescView.text = detailDesc;
    //end of: detail, desc title

    // for the error hint label
    NSString *detailErrorHint = @"(反馈内容不少于6个字符)";
    CGSize detailErrHintSize = [detailErrorHint sizeWithFont:descFont];
    _detailErrorHintView = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(detailDescView.frame), detailY,
        detailErrHintSize.width, detailErrHintSize.height)];
    _detailErrorHintView.text= detailErrorHint;
    _detailErrorHintView.font = descFont;
    _detailErrorHintView.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_red_400"];
    _detailErrorHintView.hidden = YES;

    detailY += detailDescView.frame.size.height;

    // detail, text field for inputting user comments
    CGFloat lineHeight = 22;
    CGSize detailInputSize = CGSizeMake(pageContentWidth - 15 * 2, lineHeight * 3);
    CGRect detailInputFrame = CGRectMake(15, 15, detailInputSize.width, detailInputSize.height);
    _detailInputView = [[UITextView alloc] initWithFrame:detailInputFrame];
    _detailInputView.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_800"];
    _detailInputView.font = [UIFont systemFontOfSize:16];
    _detailInputView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    _detailInputView.textAlignment = NSTextAlignmentLeft;
    //remove top padding
    if ([[UIDevice currentDevice].systemVersion floatValue] > 7) {
        _detailInputView.textContainerInset = UIEdgeInsetsZero;
        _detailInputView.textContainer.lineFragmentPadding = 0;
    } else {
        _detailInputView.contentInset = UIEdgeInsetsMake(-11,-8,0,0);
    }
    _detailInputView.delegate = self;


    NSString *detailHint = @"请详细描述您的问题和步骤\n(至少六个字符)";
    CGSize detailHintSize = CGSizeZero;
    if ([FunctionUtility systemVersionFloat] >= 7.0) {
        detailHintSize = [detailHint sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16]}];
    } else {
        detailHintSize = [detailHint sizeWithFont:[UIFont systemFontOfSize:16]];
        detailHintSize.height += 20;
    }
    _detailPlaceholder = [[UILabel alloc] initWithFrame:
        CGRectMake(15, 15, detailInputSize.width, detailHintSize.height)];
    _detailPlaceholder.text = @"请详细描述您的问题和步骤\n(至少六个字符)";
    _detailPlaceholder.numberOfLines = 0;
    _detailPlaceholder.lineBreakMode = NSLineBreakByCharWrapping;
    _detailPlaceholder.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_300"];
    _detailPlaceholder.font = [UIFont systemFontOfSize:16];

    detailY += 10;
    // textview container
    CGFloat textViewY = 0;
    textViewY += 15;
    _textViewContainer = [[UIView alloc] init];
    _textViewContainer.frame = CGRectMake(0, detailY, pageContentWidth, 96);
    _textViewContainer.layer.borderColor = _borderColorNormal.CGColor;
    _textViewContainer.layer.borderWidth = 1;
    _textViewContainer.layer.cornerRadius = 4;
    _textViewContainer.clipsToBounds = YES;

    [_textViewContainer addSubview:_detailInputView];
    [_textViewContainer addSubview:_detailPlaceholder];

    // -- end of: textview container
    detailY += _textViewContainer.frame.size.height;

    gY += 20;
    // detail container
    UIView *detailViewContainer = [[UIView alloc] init];
    detailViewContainer.frame = CGRectMake(pageHorizontalMargin, gY, pageContentWidth, detailY);

    [detailViewContainer addSubview:detailDescView];
    [detailViewContainer addSubview:_detailErrorHintView];
    [detailViewContainer addSubview:_textViewContainer];
    //end of: detail container
    gY += detailViewContainer.frame.size.height;

    //---- contact, desc title;
    CGFloat contactY = 0;
    NSString *contactDesc = @"联系方式（QQ/电话/微信号）";
    CGFloat contactDescHeight = [contactDesc sizeWithFont:descFont].height;
    UILabel *contactDescView = [[UILabel alloc]
        initWithFrame:CGRectMake(0, contactY, pageContentWidth, contactDescHeight)];
    contactDescView.font = descFont;
    contactDescView.text = contactDesc;
    contactY += contactDescView.frame.size.height;

    // contact, text field for input a number
    contactY += 10;
    CGSize contactInputSize = CGSizeMake(pageContentWidth, 46);
    CGRect contactInputFrame = CGRectMake(0, contactY, contactInputSize.width, contactInputSize.height);
    _contactInputView = [[UITextField alloc] initWithFrame:contactInputFrame];

    UIView *leftSpacer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 46)];
    UIView *rightSpacer = [[UIView alloc] initWithFrame:CGRectMake(pageContentWidth - 15, 0, 15, 46)];

    _contactInputView.leftView = leftSpacer;
    _contactInputView.leftViewMode = UITextFieldViewModeAlways;
    _contactInputView.rightView = rightSpacer;
    _contactInputView.rightViewMode = UITextFieldViewModeAlways;

    _contactInputView.placeholder = @"选填，方便和您取得联系";
    _contactInputView.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_300"];
    _contactInputView.font = [UIFont systemFontOfSize:16];

    _contactInputView.layer.borderColor = _borderColorNormal.CGColor;
    _contactInputView.layer.borderWidth = 1;

    _contactInputView.layer.cornerRadius = 4;
    _contactInputView.clipsToBounds = YES;
    _contactInputView.delegate = self;

    contactY += _contactInputView.frame.size.height;

    // contact container
    gY += 20;
    UIView *contactViewContainer = [[UIView alloc] init];
    CGSize contactContainerSize = CGSizeMake(pageContentWidth, contactY);
    contactViewContainer.frame = CGRectMake(pageHorizontalMargin, gY, contactContainerSize.width, contactContainerSize.height);
    [contactViewContainer addSubview:contactDescView];
    [contactViewContainer addSubview:_contactInputView];

    gY += contactViewContainer.frame.size.height;

    //--- submit button: view
    gY += 20;
    CGSize submitButtonSize = CGSizeMake(pageContentWidth, 46);

    _submitButton = [[UIButton alloc]
        initWithFrame:CGRectMake(pageHorizontalMargin, gY, submitButtonSize.width, submitButtonSize.height)];

    [_submitButton setBackgroundImage: [FunctionUtility imageWithColor:[TPDialerResourceManager
                                     getColorForStyle:@"tp_color_light_blue_500"]]
                            forState:UIControlStateNormal];
    [_submitButton setBackgroundImage: [FunctionUtility imageWithColor:[TPDialerResourceManager
                                    getColorForStyle:@"tp_color_light_blue_700"]]
                            forState:UIControlStateHighlighted];
    [_submitButton setBackgroundImage: [FunctionUtility imageWithColor:[TPDialerResourceManager
                            getColorForStyle:@"tp_color_black_transparency_100"]]
                            forState:UIControlStateDisabled];

    [_submitButton setTitleColor: [TPDialerResourceManager getColorForStyle:@"tp_color_white"]
                            forState:UIControlStateNormal];
    [_submitButton setTitleColor: [TPDialerResourceManager getColorForStyle:@"tp_color_white"]
                            forState:UIControlStateHighlighted];
    [_submitButton setTitleColor: [TPDialerResourceManager getColorForStyle:@"tp_color_white_transparency_800"]
                            forState:UIControlStateDisabled];

    NSString *submitButtonTitle = @"反馈给触宝电话产品组";
    [_submitButton setTitle:submitButtonTitle forState:UIControlStateNormal];
    [_submitButton setTitle:submitButtonTitle forState:UIControlStateHighlighted];
    [_submitButton setTitle:submitButtonTitle forState:UIControlStateDisabled];

    _submitButton.titleLabel.font = [UIFont systemFontOfSize:17];
    _submitButton.layer.cornerRadius = 4;
    _submitButton.clipsToBounds = YES;
    _submitButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    _submitButton.enabled = NO;
    gY += _submitButton.frame.size.height;

    // submit button: event
    [_submitButton addTarget:self
                      action:@selector(onSubmitDidClick) forControlEvents:UIControlEventTouchUpInside];

    // view tree setup
    self.view.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_white"];

    CGFloat headerHeight = headerContainer.frame.size.height;
    _pageContentContainer = [[UIView alloc] initWithFrame:CGRectMake(0, headerHeight,
                                TPScreenWidth(), TPScreenHeight() - headerHeight)];
    _pageContentContainer.backgroundColor = [UIColor whiteColor];

    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                        action:@selector(onTapOutSideOfTextInput)];
    [self.view addGestureRecognizer:gestureRecognizer];

    UISwipeGestureRecognizer *swapRecognizerToUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onTapOutSideOfTextInput)];
    [swapRecognizerToUp setDirection:UISwipeGestureRecognizerDirectionUp];
    [self.view addGestureRecognizer:swapRecognizerToUp];

    UISwipeGestureRecognizer * swapRecognizerToDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onTapOutSideOfTextInput)];
    [swapRecognizerToDown setDirection:UISwipeGestureRecognizerDirectionDown];
    [self.view addGestureRecognizer:swapRecognizerToDown];

    [_pageContentContainer addSubview:detailViewContainer];
    [_pageContentContainer addSubview:contactViewContainer];
    [_pageContentContainer addSubview:_submitButton];

    // view tree
    [self.view addSubview:_pageContentContainer];
    [self.view addSubview:headerContainer];

    // add observers
    [[NSNotificationCenter defaultCenter] addObserver:self
                                            selector:@selector(onKeyboardWillShow:)
                                            name:UIKeyboardWillShowNotification
                                            object:nil];
    NSString *referrer = [UserDefaultsManager stringForKey:FEEDBACK_REFERRER_URL];
    cootek_log(@"UMFeedbackController, referrer: %@", referrer);
}

- (void) onTapOutSideOfTextInput {
    [_detailInputView resignFirstResponder];
    [_contactInputView resignFirstResponder];
}

- (BOOL) textFieldShouldBeginEditing:(UITextView *)textView {
    _contactInputView.layer.borderColor = _borderColorHighlighted.CGColor;
    _contactInputView.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_800"];
    return YES;
}

- (void) textFieldDidEndEditing:(UITextField *)textField {
    _contactInputView.layer.borderColor = _borderColorNormal.CGColor;
    if (_isUpMoved) {
        [UIView animateWithDuration:0.3f animations:^{
            _pageContentContainer.center =
            CGPointMake(_pageContentContainer.center.x, _pageContentContainer.center.y + 100);
        }];
        _isUpMoved = NO;
        _shouldMovePageUp = NO;
    }
    if ([_contactInputView.text length]> 0) {
        _contactInputView.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_800"];
    } else {
        _contactInputView.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_300"];
    }
}

- (void) onSubmitDidClick {
    // sending the feedback
    NSInteger len = _detailInputView.text.length;
    if (len < MIN_ACCEPTABLE_CHAR_COUNT) {
        _detailErrorHintView.hidden = NO;
        return;
    }
    NSDictionary *fb = [self getFeedback];
    cootek_log(@"UMFeedbackController, feedback: %@", fb);
    NSData *jsonfb = [NSJSONSerialization dataWithJSONObject:fb options:kNilOptions  error:nil];
    cootek_log(@"UMFeedbackController, feddback, json: %@", [[NSString alloc] initWithData:jsonfb encoding:NSUTF8StringEncoding]);
    [DialerUsageRecord record:TYPE_FEEDBACK path:PATH_FEEDBACK values:[self getFeedback]];
    [UsageRecorder send];
    [self exit:YES];
}

- (void) gotoBack {
    [self checkUserInput];
}

- (void) checkUserInput {
    if ([[_detailInputView text] length] >= MIN_INPUT_CHARS) {
        // alert users to confirm the exit
        [DefaultUIAlertViewHandler showAlertViewWithTitle:@"您的反馈尚未提交，确认离开吗?"
                           message:nil
               okButtonActionBlock:^{
                   [self exit:NO];

               }
               cancelActionBlock:^{
                   //do nothing, just back to edit state.

               }
         ];
    } else {
        // do nothing and exit silently
        [self exit:NO];
    }
}


- (void) exit:(BOOL)feedbackSuccess {
    if (!feedbackSuccess) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    NSString *referrerUrlString = [UserDefaultsManager stringForKey:FEEDBACK_REFERRER_URL];
    cootek_log(@"UMFeedbackController, referrer: %@", referrerUrlString);
    if (referrerUrlString.length > 0) {
        UMFeedbackFAQController *faqController = nil;
        for(UIViewController *vc in self.navigationController.viewControllers) {
            if ([vc isKindOfClass:[UMFeedbackFAQController class]]) {
                faqController = (UMFeedbackFAQController *)vc;
                break;
            }
        }
        if (faqController) {
            // found, to use it
            [faqController reloadUrl:referrerUrlString];
            [self.navigationController popViewControllerAnimated:YES];

        } else {
            // not found the faq controller, to create one
            faqController = [[UMFeedbackFAQController alloc] init];
            faqController.url_string = referrerUrlString;
            faqController.title = @"hello world";
            [self.navigationController pushViewController:faqController animated:YES];
            [self removeFromParentViewController];
        }
        return;
    }

    //
    BOOL personalCenterFound = NO;
    UIViewController *personalCenterController = [[PersonalCenterController alloc] init];
    for(UIViewController *vc in self.navigationController.viewControllers) {
        if ([vc isKindOfClass:[PersonalCenterController class]]) {
            personalCenterController = vc;
            personalCenterFound = YES;
            break;
        }
    }
    if (personalCenterFound) {
        // romove the existed controller
        [self.navigationController popToViewController:personalCenterController animated:YES];
    } else {
        // push a new controller
        [self.navigationController pushViewController:personalCenterController animated:YES];
    }
}


- (BOOL) textViewShouldBeginEditing:(UITextView *)textView {
    _isDetailEdited = YES;
    _textViewContainer.layer.borderColor = _borderColorHighlighted.CGColor;
    if ([_detailInputView.text length] < 1) {
        _detailPlaceholder.hidden = NO;
    } else {
        _detailPlaceholder.hidden = YES;
    }
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    //change the border color and toggle the placeholder if necessary
    _textViewContainer.layer.borderColor = _borderColorNormal.CGColor;
    if ([_detailInputView.text length] >= 1 ) {
        _isDetailEdited = YES;
    } else {
         _isDetailEdited = NO;
    }

    // refresh the submit button color
    if ([[_detailInputView text] length] >= MIN_INPUT_CHARS) {
        _submitButton.userInteractionEnabled = YES;
        _submitButton.enabled = YES;
    } else {
        _submitButton.userInteractionEnabled = NO;
        _submitButton.enabled = NO;
    }
}

- (void) textViewDidChange:(UITextView *)textView {
    // refresh the submit button color
    if (_isDetailEdited) {
        _submitButton.userInteractionEnabled = YES;
        _submitButton.enabled = YES;
    } else {
        _submitButton.userInteractionEnabled = NO;
        _submitButton.enabled = NO;
    }

    if ([_detailInputView.text length] < 1 ) {
        _detailPlaceholder.hidden = NO;

        _submitButton.userInteractionEnabled = NO;
        _submitButton.enabled = NO;
    } else {
        _detailPlaceholder.hidden = YES;

        _submitButton.userInteractionEnabled = YES;
        _submitButton.enabled = YES;
    }

    [self checkToHideErrorHint];

    int len = [_detailInputView.text length];
    _inputCharCount = len < 0 ? 0 : len;
}

- (void) checkToHideErrorHint {
    int len = [_detailInputView.text length];
    if (_inputCharCount < MIN_ACCEPTABLE_CHAR_COUNT && len >= MIN_ACCEPTABLE_CHAR_COUNT) {
        // increase to overMIN_INPUT_CHARS, hide the error hint
        if (!_detailErrorHintView.hidden) {
            _detailErrorHintView.hidden = YES;
        }
    }
}

- (void)onKeyboardWillShow:(NSNotification *)aNotification {
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    CGFloat kbHeight = keyboardRect.size.height;
    CGFloat uiTotalHeight = _submitButton.frame.origin.y + _submitButton.frame.size.height + kbHeight;
    if (uiTotalHeight >= _pageContentContainer.frame.size.height) {
        _shouldMovePageUp = YES;
        cootek_log(@"isupmoved: %d, isfirstresponder: %d", _isUpMoved, _contactInputView.isFirstResponder);
        if (!_isUpMoved && _contactInputView.isFirstResponder) {
            [UIView animateWithDuration:0.3f animations:^{
                _pageContentContainer.center =
                CGPointMake(_pageContentContainer.center.x, _pageContentContainer.center.y - 100);
            }];
            _isUpMoved = YES;
        }
    } else {
        _shouldMovePageUp = NO;
    }
}

- (NSDictionary *) getFeedback {
    UIDevice *device = [UIDevice currentDevice];
    NSString *appString = @"[]";
    NSDictionary *fb = @{
        @"is_dual_sim": @(0),

        @"manufacturer": @"apple",
        @"os_version": [NSString nilToEmpty:device.systemVersion],
        @"device_info": [NSString nilToEmpty:[FunctionUtility deviceName]],
        @"channel_code": IPHONE_CHANNEL_CODE,

        @"current_version": CURRENT_TOUCHPAL_VERSION,
        @"first_version": [NSString nilToEmpty:[UserDefaultsManager stringForKey:FIRST_LAUNCH_VERSION]],
        @"last_version": [NSString nilToEmpty:[UserDefaultsManager stringForKey:LAST_LAUNCH_VERSION]],

        @"detail": [NSString nilToEmptyTrimmed:_detailInputView.text],
        @"contact_number": [NSString nilToEmptyTrimmed:_contactInputView.text],

        @"feedback_path": [NSString nilToEmpty:[UserDefaultsManager stringForKey:FEEDBACK_QUESTION_PATH]],
        @"feedback_type": [NSString nilToEmpty:[UserDefaultsManager stringForKey:FEEDBACK_QUESTION_CATEGORY]],

        @"rival_apps": appString,
    };

    return fb;
}

@end

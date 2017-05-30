//
//  ReceiveContentView.m
//  TouchPalDialer
//
//  Created by siyi on 16/3/21.
//
//

#import "ReceiveContentView.h"
#import "ContactTransferConst.h"
#import "TPDialerResourceManager.h"
#import "UILabel+TPHelper.h"
#import "UILabel+DynamicHeight.h"

@implementation ReceiveContentView {
    CGRect _frame;
    UIView *_bottomWarningLabel;
    UILabel *_sendStatusLabel;
    UIButton *_statusLabelContainer;
    CGRect _circleFrame;
    NSTimer *_timer;
    UIImageView *_sendingRingView;
    UIImageView *_finishedRingView;
    CGFloat _currentRotateAngle;
    BOOL _isRotating;
}

- (void) baseInit {
    _currentRotateAngle = 0;
    _status = 0;
    _isRotating = NO;
}

- (instancetype) initWithFrame:(CGRect)frame status:(NSInteger)currentStatus {
    self = [super initWithFrame:frame];
    if (self) {
        [self baseInit];
        
        _frame = frame;
        
        self.frame = _frame;
        // content view
        // bottom warnning label
        _bottomWarningLabel = [self getBottomWarningLabel];
        
        CGFloat gY = 90;
        _sendStatusLabel = [[UILabel alloc] initWithFrame:CGRectMake(
                                                                     (TPScreenWidth() -SEND_CIRCLE_DIAMETER)/2, gY, SEND_CIRCLE_DIAMETER, 21)];
        _sendStatusLabel.font = [UIFont systemFontOfSize:15];
        _sendStatusLabel.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_600"];
        _sendStatusLabel.textAlignment = NSTextAlignmentCenter;
        _sendStatusLabel.text = @"验证身份成功";
        [self addSubview:_sendStatusLabel];
        gY += 21;
        
        gY += 20;
        _circleFrame = CGRectMake((TPScreenWidth() - SEND_CIRCLE_DIAMETER)/2, gY,
                                  SEND_CIRCLE_DIAMETER, SEND_CIRCLE_DIAMETER);
        CGRect circleFrame = _circleFrame;
        
        _sendingRingView = [[UIImageView alloc] initWithFrame:circleFrame];
        UIImage *faddingRingImage = [[TPDialerResourceManager sharedManager] getImageInDefaultPackageByName:@"contact_transfer_border_sending@2x.png"];
        _sendingRingView.image = faddingRingImage;
        _sendingRingView.contentMode = UIViewContentModeCenter;
        
        _finishedRingView = [[UIImageView alloc] initWithFrame:circleFrame];
        UIImage *htRingImage = [[TPDialerResourceManager sharedManager] getImageInDefaultPackageByName:@"contact_transfer_border_success@2x.png"];
        _finishedRingView.image = htRingImage;
        _finishedRingView.contentMode = UIViewContentModeCenter;
        
        _finishedRingView.hidden = YES;
        _sendingRingView.hidden = NO;
        
        [self addSubview:_finishedRingView];
        [self addSubview:_sendingRingView];
        
        _statusLabelContainer = [self getStatusLabelContainerByStatus:currentStatus];
        [self setStatus:currentStatus];
        _statusLabelContainer.userInteractionEnabled = YES;
        [self addSubview:_statusLabelContainer];
        
    }
    return self;
}

- (instancetype) initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame status:STATUS_RECEIVE_CONNECTION];
}

- (void) onClickContainer {
    if (self.delegate) {
        [self.delegate onClickContainer];
    }
}

- (void) setStatus:(NSInteger)status {
    switch (status) {
        case STATUS_RECEIVE_CONNECTION: {
            // connecting
            _sendStatusLabel.text = @"验证身份成功";
            [self startRingAnimation];
            break;
        }
        case STATUS_RECEIVE_RECEIVING: {
            //sending
            _sendStatusLabel.text = @"连接建立成功";
            [self startRingAnimation];
            break;
        }
        case PRIVATE_STATUS_SELF_SUCCESS: {
            _sendStatusLabel.text = @"接收成功";
            break;
        }
        case PRIVATE_STATUS_INSERTING: {
            [self startRingAnimation];
            break;
        }
        case STATUS_INSERT_SUCCESS: {
            _sendStatusLabel.text = @"";
            _statusLabelContainer.userInteractionEnabled = NO;
            [self stopRingAnimation];
            break;
        }
        case STATUS_INSERT_FAILED_UNKNOWN:
        case STATUS_INSERT_FAILED_SECURITY:
        case STATUS_INSERT_FAILED_INTERRUPT:
        case STATUS_OPPOSITE_FINISHED:
        case STATUS_SELF_FINISHED:
        case STATUS_RECEIVE_INTERRUPT: {
            _sendStatusLabel.text = @"迁移失败";
            [self stopRingAnimation];
            break;
        }
        default: {
            break;
        }
    }
    [self updateStatusContainer:status];
    _status = status;
}

- (void) updateStatusContainer:(NSInteger)status {
    [_statusLabelContainer removeFromSuperview];
    _statusLabelContainer = [self getStatusLabelContainerByStatus:status];
    [self addSubview:_statusLabelContainer];
}

#pragma mark animations
- (void) startRingAnimation {
    if (_isRotating) {
        return;
    }
    _timer = [NSTimer scheduledTimerWithTimeInterval:(1.0/60) target:self selector:@selector(animateRing) userInfo:nil repeats:YES];
    [_timer fire];
    _isRotating = YES;
}

- (void) stopRingAnimation {
    if (!_isRotating) {
        return;
    }
    
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    _sendingRingView.hidden = YES;
    _finishedRingView.hidden = NO;
    _isRotating = NO;
}

- (void) animateRing {
    if (!_sendingRingView) {
        return;
    }
    UIImageView *ringView = _sendingRingView;
    [_sendingRingView removeFromSuperview];
    
    ringView.hidden = NO;
    _currentRotateAngle += 6;
    CGAffineTransform rotate = CGAffineTransformMakeRotation( _currentRotateAngle/ 360.0 * 3.14 );
    [ringView setTransform:rotate];
    
    _sendingRingView = ringView;
    [self addSubview:_sendingRingView];
}

#pragma mark get views
- (UIButton *) getStatusLabelContainerByStatus:(NSInteger)status {
    CGFloat currentStatusHeight = 25;
    CGFloat previousStatusHeight = 17;
    
    NSString *currentStatusText = nil;
    NSString *previousStatusText = nil;
    
    switch (status) {
        case STATUS_RECEIVE_CONNECTION: {
            // connecting
            currentStatusText = @"连接中...";
            previousStatusText = @"点击停止";
            break;
        }
        case STATUS_RECEIVE_RECEIVING: {
            // receiving
            currentStatusText = @"接收中...";
            previousStatusText = @"点击停止";
            break;
        }
        case STATUS_INSERT_SUCCESS: {
            currentStatusText = @"迁移成功";
            break;
        }
        case PRIVATE_STATUS_SELF_SUCCESS:
        case PRIVATE_STATUS_INSERTING: {
            currentStatusText = @"正在写入联系人...";
            previousStatusText = @"点击停止";
            break;
        }
        case STATUS_INSERT_FAILED_UNKNOWN:
        case STATUS_INSERT_FAILED_SECURITY:
        case STATUS_INSERT_FAILED_INTERRUPT:
        case STATUS_OPPOSITE_FINISHED:
        case STATUS_SELF_FINISHED:
        case STATUS_RECEIVE_INTERRUPT: {
            currentStatusText = @"点击重新接收";
            break;
        }
        default: {
            // failed
            break;
        }
    }
    cootek_log(@"contact_transfer, SendContentView, status: %@",[@(status) stringValue]);
    UILabel *currentLabel = nil;
    UILabel *prevLabel = nil;
    
    CGFloat totalHeight = 0;
    if (currentStatusText) {
        currentLabel = [self getLabelByText:currentStatusText fontSize:17 targetHeight:currentStatusHeight];
        currentLabel.textColor = [UIColor whiteColor];
        totalHeight += currentStatusHeight;
    }
    if (previousStatusText) {
        prevLabel = [self getLabelByText:previousStatusText fontSize:12 targetHeight:previousStatusHeight];
        prevLabel.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_white_transparency_600"];
        totalHeight += previousStatusHeight;
    }
    
    if (!currentLabel && !prevLabel) {
        return nil;
    }
    CGFloat inset = (SEND_CIRCLE_DIAMETER - SEND_STATUS_CIRCLE_DIAMETER) / 2;
    CGRect containerFrame = CGRectInset(_circleFrame, inset, inset);
    UIButton *container = [[UIButton alloc] initWithFrame:containerFrame];
    UIImage *normalCircleImage = [[TPDialerResourceManager sharedManager] getImageInDefaultPackageByName:@"contact_transfer_status_bg_normal@2x.png"];
    
    UIImage *htCircleImage = [[TPDialerResourceManager sharedManager] getImageInDefaultPackageByName:@"contact_transfer_status_bg_ht@2x.png"];
    [container setBackgroundImage:normalCircleImage forState:UIControlStateNormal];
    [container setBackgroundImage:htCircleImage     forState:UIControlStateHighlighted];
    
    CGFloat gX = 0;
    CGFloat gY = (containerFrame.size.height - totalHeight) / 2;
    
    if (currentLabel) {
        CGRect frame = currentLabel.frame;
        gY += frame.origin.y;
        gX = (containerFrame.size.width - frame.size.width) / 2;
        currentLabel.frame = CGRectMake(gX, gY, frame.size.width, frame.size.height);
        [container addSubview:currentLabel];
        gY += currentStatusHeight;
    }
    if (prevLabel) {
        CGRect frame = prevLabel.frame;
        gY += frame.origin.y;
        gX = (containerFrame.size.width - frame.size.width) / 2;
        prevLabel.frame = CGRectMake(gX, gY, frame.size.width, frame.size.height);
        [container addSubview:prevLabel];
    }
    container.backgroundColor = [UIColor clearColor];
    [container addTarget:self action:@selector(onClickContainer) forControlEvents:UIControlEventTouchUpInside];
    if (status == STATUS_INSERT_SUCCESS) {
        container.userInteractionEnabled = NO;
    }
    return container;
}

- (UILabel *) getLabelByText:(NSString *)text fontSize:(CGFloat)fontSize targetHeight:(CGFloat)targetHeight{
    if (!text) {
        return nil;
    }
    UILabel *label = [[UILabel alloc] initWithTitle:text fontSize:fontSize];
    CGFloat offset = 0;
    CGFloat labelHeight = label.frame.size.height;
    if (labelHeight < targetHeight) {
        offset = (targetHeight - labelHeight) / 2;
    }
    CGRect frame = label.frame;
    label.frame = CGRectMake(frame.origin.x, frame.origin.y + offset, frame.size.width, frame.size.height);
    return label;
}

- (UIView *) getBottomWarningContainer {
    return nil;
}

- (UILabel *) getBottomWarningLabel {
    return nil;
}

@end


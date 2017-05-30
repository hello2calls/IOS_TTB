//
//  ContactTransferSendController.m
//  TouchPalDialer
//
//  Created by siyi on 16/3/10.
//
//

#import "ContactTransferSendController.h"
#import "NetworkUtil.h"
#import "ContactTransferRecord.h"
#import "ContactTransferConst.h"
#import "ASIHTTPRequest.h"
#import "FunctionUtility.h"
#import "DateTimeUtil.h"
#import "SeattleFeatureExecutor.h"
#import "UserDefaultsManager.h"
#import "PersonDBA.h"
#import "ContactCacheDataModel.h"
#import "ContactCacheDataManager.h"
#import "ContactTransferUtil.h"
#import "TouchPalVersionInfo.h"
#import "UserDefaultKeys.h"
#import "TPDialerResourceManager.h"
#import "UILabel+TPHelper.h"
#import "UILabel+DynamicHeight.h"
#import "QRContentView.h"
#import "SendContentView.h"
#import "Reachability.h"
#import "DefaultUIAlertViewHandler.h"
#import "DialerUsageRecord.h"

@implementation ContactTransferSendController {
    NSInteger _senderStatus;
    NSInteger _receiverStatus;
    NSInteger _sendTriedCount;

    NSMutableArray *_recordGroups;
    NSMutableDictionary *_transferRecords;

    NSInteger _maxGroupMemberCount;
    ASIHTTPRequest *_senderRequest;

    NSInteger _systemContactCount;
    NSInteger _privateContactCount;

    NSString *_QRCodestring;
    UIView *_headerView;

    SendContentView *_sendContentView;
    QRContentView *_qrContentView;
    UIButton *_titleButton;
    BOOL _groupReady;
    ASIHTTPRequest *_persistRequest;
}

#pragma mark base init
- (void) baseInit {
    _senderStatus = STATUS_SEND_CONNECTION;
    _receiverStatus = STATUS_CONTENT_FORMAT_ERROR;
    _sendTriedCount = 0;
    _recordGroups = nil;
    _systemContactCount = 0;
    _privateContactCount = 0;
    _QRCodestring = nil;
    _groupReady = NO;
    _persistRequest = nil;
}

- (instancetype) init {
    if (self = [super init]) {
        _transferRecords = nil;
        _maxGroupMemberCount = MAX_RECORDS_SENT_ONCE;
    }
    return self;
}

#pragma mark view life cycle
- (void) viewDidLoad {
    [super viewDidLoad];

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    CGFloat gY = 0;
    UIColor *commonBgColor = [TPDialerResourceManager getColorForStyle:@"tp_color_light_blue_500"];

    _headerView = [self getHeaderView];
    _headerView.backgroundColor = commonBgColor;
    gY += _headerView.frame.size.height;

    self.view.frame = CGRectMake(0, 0, TPScreenWidth(), TPScreenHeight());
    self.view.backgroundColor = [UIColor whiteColor];

    CGRect contentFrame = CGRectMake(0, gY, TPScreenWidth(), TPScreenHeight() - gY);
    _sendContentView = [[SendContentView alloc] initWithFrame:contentFrame status:STATUS_SEND_CONNECTION];
    _sendContentView.hidden = YES;
    _sendContentView.delegate = self;

    _qrContentView = [[QRContentView alloc] initWithFrame:contentFrame status:STATUS_SEND_CONNECTION];
    _qrContentView.hidden = YES;
    _qrContentView.delegate = self;

    //set up self.view
    [self.view addSubview:_headerView];
    [self.view addSubview:_qrContentView];
    [self.view addSubview:_sendContentView];

    [self startSendTask];
}

- (void) startSendTask {
    [DialerUsageRecord recordpath:PATH_CONTACT_TRANSFER kvs:Pair(CONTACT_TRANSFER_SEND_CONNECTION, @(1)), nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNetworkChange:) name:N_REACHABILITY_NETWORK_CHANE object:nil];
    [self resetSendStaus];
    [self startSendTaskByLimit:_maxGroupMemberCount];
}

#pragma mark notifications
- (void) onNetworkChange:(NSNotification *)noti {
    id object = noti.object;
    if (!object) {
        return;
    }
    Reachability *networkInfo = (Reachability *)object;
    if (networkInfo.networkStatus == network_none) {
        // network becomes unavailable
        [self handReceiverStatus:nil];
    }
}


- (void) startSendTaskByLimit:(NSInteger)limit {
    BOOL hasError = [self hasPreSendError];
    if (!hasError) {
        _qrContentView.hidden = NO;
    }
    __weak ContactTransferSendController *weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSDictionary *emptyDict = [[NSDictionary alloc] init];
        [weakSelf sendJSONObject:emptyDict];
        BOOL justRearrange = _transferRecords && (limit != _maxGroupMemberCount);
        if (!justRearrange) {
            [weakSelf prepareRecords];
        }
        [weakSelf arrangeGroups:limit];
//        if (!hasError) {
//        }
    });
}

- (NSInteger) getPreSendStatus {
    // check network status
    ClientNetworkType networkStatus = [[Reachability shareReachability] networkStatus];
    cootek_log(@"contact_transfer, networkstatus: %d", networkStatus);
    if ( networkStatus == network_none) {
        return PRIVATE_STATUS_NO_NETWORK;
    }
    // check if contacts are empty
    NSArray *contactIDs = [[ContactCacheDataManager instance] getAllCacheContactID];
    if (!contactIDs || contactIDs.count == 0) {
        return STATUS_NO_CONTACTS_ERROR;
    }

    if ([_qrContentView isGeneratingError]) {
        return STATUS_GENERATE_QRCODE_FAILED;
    }
    return 0;
}

- (BOOL) hasPreSendError {
    NSInteger status = [self getPreSendStatus];
    if (status == 0) {
        return NO;
    }
    NSString *mainTitle = nil;
    switch (status) {
        case PRIVATE_STATUS_NO_NETWORK: {
            mainTitle = @"没有连接到网络，无法迁移联系人哦~";
            break;
        }
        case STATUS_NO_CONTACTS_ERROR: {
            mainTitle = @"您的通讯录中没有可迁移的联系人";
            break;
        }
        case STATUS_GENERATE_QRCODE_FAILED: {
            _qrContentView.hidden = NO;
            _senderStatus = STATUS_GENERATE_QRCODE_FAILED;
            [self onStatusChanged];
            break;
        }
        default:
            break;
    }
    if (mainTitle) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [DefaultUIAlertViewHandler showAlertViewWithTitle:@"触宝提示"
                                                      message:mainTitle
                                      onlyOkButtonActionBlock:^{
                                          [self.navigationController popViewControllerAnimated:YES];
                                      }];
        });
    }
    return YES;
}


#pragma mark delegates
//SendContentViewDelegate
- (void) onClickSendStatusCircle {
    if (_senderStatus == STATUS_SEND_SENDING
        || _senderStatus == STATUS_SEND_CONNECTION) {
        [DefaultUIAlertViewHandler showAlertViewWithTitle:@"触宝提示"
                                                  message:@"停止后将终止迁移，确定退出?"
                                      okButtonActionBlock:^{
                                          _senderStatus = STATUS_SEND_INTERRUPT;
                                          _receiverStatus = STATUS_CONTENT_FORMAT_ERROR;
                                          [self onStatusChanged];
                                      }
                                        cancelActionBlock:^{
                                            // do nothing
                                        }
         ];

    } else {
        _qrContentView.hidden = NO;
        _sendContentView.hidden = YES;
        [self resetSendStaus];
        [self startSendTask];
    }

}

//QRContentView
- (void) onClickQRImage {
    [_qrContentView refreshQRImage];
    [self startSendTask];
}

#pragma mark logics
- (void) deleteRequest {
    if (_senderRequest
        && (_senderRequest.isExecuting || !_senderRequest.isCancelled)) {
        [_senderRequest cancel];
        _senderRequest = nil;
    }
}

- (void) resetSendStaus {
    [self baseInit];
    [self updateContentViewToCurrentStatus:_senderStatus];
}

- (void) prepareRecords {
    NSArray *contactIDs = [[ContactCacheDataManager instance] getAllCacheContactID];
    _transferRecords = [[NSMutableDictionary alloc] initWithCapacity:1];
    _systemContactCount = 0;
    _privateContactCount = 0;

    for (id recordID in contactIDs) {
        if ([self isCanceled]) {
            _transferRecords = nil;
            _systemContactCount = 0;
            _privateContactCount = 0;
            break;
        }
        ContactTransferRecordType recordType = [ContactTransferUtil getRecordType:[recordID integerValue]];
        NSString *key = [ContactTransferUtil getRecordKeyByType:recordType recordID:recordID];
        ContactTransferRecord *transferRecord = [[ContactTransferRecord alloc] initWithRecordID:[recordID integerValue]];
        if (transferRecord) {
            switch (recordType) {
                case RECORD_TYPE_SYSTM: {
                    _systemContactCount++;
                    break;
                }
                case RECORD_TYPE_PRIVATE: {
                    _privateContactCount++;
                    break;
                }
                default: {
                    break;
                }
            }

            [_transferRecords setObject:transferRecord.items forKey:key];
        }
    }
}

- (void) arrangeGroups: (NSInteger) maxGroupMemeberCount {
    _maxGroupMemberCount = maxGroupMemeberCount;

    if (maxGroupMemeberCount <= 0  || !_transferRecords) {
        return;
    }
    NSInteger recordCount = _transferRecords.count;
    if (recordCount < 1) {
        return;
    }

    _recordGroups = [[NSMutableArray alloc] initWithCapacity:1];
    NSMutableDictionary *group = [[NSMutableDictionary alloc] initWithCapacity:maxGroupMemeberCount];
    NSInteger insertedCount = 0;

    for (NSString *key in _transferRecords.allKeys) {
        if ([self isCanceled]) {
            _recordGroups = nil;
            break;
        }
        id value = [_transferRecords objectForKey:key];
        if (!key || !value) {
            continue;
        }
        [group setObject:value forKey:key];
        insertedCount++;

        if (insertedCount >= maxGroupMemeberCount) {
            [_recordGroups addObject:group];
            insertedCount = 0;
            group = [[NSMutableDictionary alloc] initWithCapacity:maxGroupMemeberCount];
        }

    }
    // do not forget to add the `odd group`
    if (_recordGroups && group.count > 0) {
        [_recordGroups addObject:group];
    }
    _groupReady = YES;
    [self sendContactGroup];
}

- (void) sendData:(NSData *) data {
    if (_senderRequest && ![_senderRequest isCancelled]) {
        cootek_log(@"contact_transfer, transfer_request, reset send status, request: %@, status: %@", _senderRequest, [_senderRequest.responseHeaders objectForKey:HEADER_STATUS]);
        [_senderRequest cancel];
        _senderRequest = nil;
    }
    _senderRequest = [self getRequest];
    if (!_senderRequest) {
        return;
    }
    cootek_log(@"contact_transfer, transfer_request: %@", [_senderRequest.requestHeaders objectForKey:HEADER_STATUS]);
    if (data) {
        _senderRequest.postBody = [[NSMutableData alloc] initWithData:data];
    } else {
        _senderRequest.postBody = nil;
    }
    [_senderRequest startAsynchronous];
}

- (void) sendJSONObject:(id)object {
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:object
                                                   options:kNilOptions error:&error];
    if (error || !data) {
        cootek_log(@"contact_transfer, error: %@, data: %@", error, data);
        return;
    }
    [self sendData:data];
}

- (void) sendContactGroup {
    NSDictionary *group = _recordGroups.lastObject;
    if (!group || group.count == 0) {
        return;
    }
   [self sendJSONObject:group];
}

- (void) sendContactCount {
    NSDictionary *countItem = @{
        NAME_COUNT: @(_systemContactCount + _privateContactCount)
    };
    [self sendJSONObject:countItem];
}

- (BOOL) isCanceled {
    return (_senderStatus == STATUS_SEND_INTERRUPT)
        || (_senderStatus == STATUS_GENERATE_QRCODE_FAILED);
}

- (ASIHTTPRequest *) getRequest {
    [self deletePersistRequest];
    if (_senderStatus == PRIVATE_STATUS_SELF_SUCCESS) {
        return nil;
    }
    NSURL *url = [NSURL URLWithString:CONTACT_TRANSFER_URL];
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:url];
    request.requestMethod = HTTP_METHOD_POST; // post

    NSMutableDictionary *headers = _senderRequest.requestHeaders;
    if (!headers) {
        headers = [[NSMutableDictionary alloc] initWithCapacity:3];
        [headers setObject:@"" forKey:@"User-Agent"];
    }
    NSString *statusString = [@(_senderStatus) stringValue];
    if (statusString) {
        [headers setObject:statusString forKey:HEADER_STATUS];
    }
    if (!_QRCodestring) {
        _QRCodestring = [UserDefaultsManager stringForKey:CONTACT_TRANSFER_QR_CODE_STRING
                                             defaultValue:nil];
    }
    if (_QRCodestring) {
        [headers setObject:_QRCodestring forKey:HEADER_UUID];
    }
    request.requestHeaders = headers;

    __weak ASIHTTPRequest *weakRequest = request;
    __weak ContactTransferSendController *weakSelf = self;

    request.timeOutSeconds = CONNECTION_TIMEOUT_SEC;

    // the connection should use the persist connection
    if (_senderStatus == STATUS_SEND_INTERRUPT) {
        request.shouldAttemptPersistentConnection = NO;

    } else {
        request.shouldAttemptPersistentConnection = YES;
        request.persistentConnectionTimeoutSeconds = PERSIST_TIMEOUT_SEC;

        // should have completition block? except for the interupt, no need for response
        request.completionBlock = ^() {
            if (_senderStatus == STATUS_SELF_FINISHED
                || _senderStatus == STATUS_SEND_INTERRUPT) {
                // already finished, no need to hand receiver status
                return;
            }
            int responseCode = weakRequest.responseStatusCode;
            NSError *error = nil;
            NSDictionary *response = [NSJSONSerialization JSONObjectWithData:weakRequest.responseData options:kNilOptions error:&error];
            if (error || !response) {
                cootek_log(@"contact_transfer, error: %@, httpCode: %d, response: %@",\
                           error, responseCode, response);
                response = nil;
            }
            [weakSelf handReceiverStatus:response];
        };
    }

    // record the persist connection
    if (_senderStatus == STATUS_SEND_CONNECTION) {
        _persistRequest = request;
    }
    return request;
}


- (void) handReceiverStatus: (NSDictionary *) response {
    if (response) {
        // has response
        _receiverStatus = [[response objectForKey:HEADER_STATUS] integerValue];
        cootek_log(@"contact_transfer, transfer_response: %@", response);
        switch (_receiverStatus) {
            case STATUS_RECEIVE_CONNECTION:
            case STATUS_RECEIVE_RECEIVING: {
//                if (_persistRequest) {
//                    [self deletePersistRequest];
//                }

                if (_receiverStatus == STATUS_RECEIVE_CONNECTION) {
                    [DialerUsageRecord recordpath:PATH_CONTACT_TRANSFER kvs:Pair(CONTACT_TRANSFER_SEND_CONNECT_SUCCESS, @(1)), nil];
                }
                if (_senderStatus == STATUS_SEND_FINISHED) {
                    _senderStatus = PRIVATE_STATUS_SELF_SUCCESS;
                    [DialerUsageRecord recordpath:PATH_CONTACT_TRANSFER
                                              kvs:Pair(CONTACT_TRANSFER_SEND_SUCCESS, @(1)), nil];
                    if (_persistRequest && ![_senderRequest isCancelled]) {
                        [_senderRequest cancel];
                    }

                } else {
                    if (_groupReady) {
                        [_recordGroups removeLastObject];
                        if (_recordGroups.count == 0) {
                            // no more data to send
                            _senderStatus = STATUS_SEND_FINISHED;

                        } else {
                            _senderStatus = STATUS_SEND_SENDING; // continue to send
                        }
                    } else {
                        NSDictionary *emptyDict = [[NSDictionary alloc] init];
                        [self sendJSONObject:emptyDict];
                    }
                }
                break;
            }

            case STATUS_NO_RECEIVE_CONNECTION_ERROR:
            case STATUS_RECEIVE_INTERRUPT: {
                // receiver error: no receiver or the receiver is interrupted
                _senderStatus = STATUS_OPPOSITE_FINISHED;
                break;
            }

            case STATUS_CONTENT_FORMAT_ERROR: {
                _senderStatus = STATUS_SELF_FINISHED;
                break;
            }

            case STATUS_NO_UUID_ERROR:
            case STATUS_NO_STATUS_ERROR:
            case STATUS_NO_CONTENT_ERROR:
            default: {
                //when error, try again
                if (_sendTriedCount < MAX_SEND_TRYIES) {
                    _sendTriedCount++;
                    [self sendContactGroup];
                    return;

                } else {
                    _senderStatus = STATUS_SELF_FINISHED;
                }
                break;
            }
        }

    } else {
        // no response
        if (_senderStatus == STATUS_SEND_CONNECTION) {
            [DialerUsageRecord recordpath:PATH_CONTACT_TRANSFER
                    kvs:Pair(CONTACT_TRANSFER_SEND_CONNECT_FAILED, CONTACT_TRANSFER_TIMEOUT), nil];
        } else if (_senderStatus != STATUS_SEND_INTERRUPT) {
            [DialerUsageRecord recordpath:PATH_CONTACT_TRANSFER
                    kvs:Pair(CONTACT_TRANSFER_SEND_FAILED, CONTACT_TRANSFER_TIMEOUT), nil];
        }
        _senderStatus = STATUS_SELF_FINISHED;
        cootek_log(@"contact_transfer, response null");
    }
    cootek_log(@"contact_transfer,  _sender: %@, _receiver: %@", [@(_senderStatus) stringValue], [@(_receiverStatus) stringValue]);

   [self onStatusChanged];
}

- (void) onStatusChanged {
    if (_receiverStatus == STATUS_RECEIVE_CONNECTION) {
        // receive connection is established
        _sendContentView.hidden = NO;
        _qrContentView.hidden = YES;
        _sendContentView.status = STATUS_RECEIVE_CONNECTION; //

        switch (_senderStatus) {
            case STATUS_SEND_FINISHED: {
                [self sendContactCount];
                [self updateContentViewToCurrentStatus:PRIVATE_STATUS_SELF_SUCCESS];
                break;
            }
            case STATUS_SEND_SENDING: {
                [self updateContentViewToCurrentStatus:STATUS_SEND_SENDING];
                [self sendContactGroup];
                break;
            }
            case PRIVATE_STATUS_SELF_SUCCESS: {
                [self updateContentViewToCurrentStatus:_senderStatus];
                break;
            }
            default: {
                break;
            }
        }

    } else {
        //
        switch (_senderStatus) {
            case STATUS_SEND_FINISHED: {
                // finally send the count
                [self sendContactCount];
                [UserDefaultsManager removeObjectForKey:CONTACT_TRANSFER_QR_CODE_STRING];
                break;
            }
            case STATUS_SEND_SENDING: {
                [self updateContentViewToCurrentStatus:_senderStatus];
                [self sendContactGroup];
                break;
            }
            case STATUS_SEND_INTERRUPT: {
                [self updateContentViewToCurrentStatus:_senderStatus];
                [self sendData:nil];
                break;
            }
            case STATUS_GENERATE_QRCODE_FAILED:
            case STATUS_RECEIVE_INTERRUPT:
            case STATUS_SELF_FINISHED:
            case STATUS_OPPOSITE_FINISHED:
            case PRIVATE_STATUS_SELF_SUCCESS: {
                [self updateContentViewToCurrentStatus:_senderStatus];
                break;
            }
            default: {
                break;
            }
        }
    }
}

- (void) updateContentViewToCurrentStatus:(NSInteger)currentStatus {
    if (!_sendContentView.hidden) {
        _sendContentView.status = currentStatus;
    } else if (!_qrContentView.hidden) {
        _qrContentView.status = currentStatus;
    }
}

- (void) deletePersistRequest {
    if (!_persistRequest) {
        return;
    }
    if (![_persistRequest isCancelled]) {
        [_persistRequest cancel];
        _persistRequest = nil;
    }
}


#pragma mark actions
- (void) goToBack {
    if (_senderStatus == STATUS_SEND_SENDING
        || _receiverStatus == STATUS_RECEIVE_CONNECTION) {
        [DefaultUIAlertViewHandler showAlertViewWithTitle:@"触宝提示"
                                                  message:@"停止后将终止迁移，确定退出?"
                                      okButtonActionBlock:^{
                                          // force to quit
                                          _senderStatus = STATUS_SEND_INTERRUPT;
                                          _receiverStatus = STATUS_CONTENT_FORMAT_ERROR;
                                          [self finishByNotifyStaus:YES];
                                      }
                                        cancelActionBlock:^{
                                            // do nothing
                                        }
         ];
    } else {
        [self finishByNotifyStaus:NO];
    }
}

- (void) finishByNotifyStaus:(NSInteger)toNotify {
    if (_senderRequest && !(_senderRequest.isCancelled)) {
        [_senderRequest cancel];
        _senderRequest = nil;
    }
    [_sendContentView stopRingAnimation]; // dealloc the timer
    _recordGroups = nil;
    _transferRecords = nil;

    if (toNotify) {
        [self sendData:nil]; // just send the status, e.g. notify the server that the sender is interupted
    }

    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark get views
- (UIView *) getHeaderView {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, TPScreenWidth(), TPHeaderBarHeight())];
    headerView.backgroundColor = [UIColor clearColor];

    // back button
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(5, TPHeaderBarHeightDiff(),50, 45)];
    cancelButton.backgroundColor = [UIColor clearColor];
    cancelButton.titleLabel.font = [UIFont fontWithName:@"iPhoneIcon1" size:22];
    [cancelButton setTitle:@"0" forState:UIControlStateNormal];

    [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [cancelButton addTarget:self action:@selector(goToBack) forControlEvents:UIControlEventTouchUpInside];

    CGSize titleButtonSize = CGSizeMake(120, 45);
    CGRect titleFrame = CGRectMake((TPScreenWidth() - titleButtonSize.width)/2, TPHeaderBarHeightDiff(),
                                   titleButtonSize.width, titleButtonSize.height);
    _titleButton = [[UIButton alloc] initWithFrame:titleFrame];
    _titleButton.backgroundColor = [UIColor clearColor];
    _titleButton.titleLabel.font = [UIFont systemFontOfSize:18];
    [_titleButton setTitle:@"二维码" forState:UIControlStateNormal];

    [_titleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_titleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];

    //set up view tree
    [headerView addSubview:cancelButton];
    [headerView addSubview:_titleButton];

    return headerView;
}

#pragma mark dealloc
- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end

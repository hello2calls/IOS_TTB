//
//  ContactTransferReceiveController.m
//  TouchPalDialer
//
//  Created by siyi on 16/3/10.
//
//

#import "ContactTransferReceiveController.h"
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
#import "ASIHTTPRequest.h"
#import "UserDefaultKeys.h"
#import "TPDialerResourceManager.h"
#import "UILabel+TPHelper.h"
#import "UILabel+DynamicHeight.h"
#import "ScanContentView.h"
#import "ReceiveContentView.h"
#import "FileUtils.h"
#import "DefaultUIAlertViewHandler.h"
#import "DialerUsageRecord.h"
#import "UsageConst.h"
#import "UIView+Toast.h"
#import "DateTimeUtil.h"
#import "SyncContactWhenAppEnterForground.h"
#import "CootekNotifications.h"
#import "RegExCategories.h"
#import "TPAddressBookWrapper.h"
#import "Reachability.h"


@implementation ContactTransferReceiveController {
    ASIHTTPRequest *_receiveRequest;
    NSString *_QRCodestring;
    NSInteger _senderStatus;
    NSInteger _receiverStatus; //my status
    NSInteger _sendTriedCount;

    NSMutableArray *_receivedContacts; //
    NSMutableArray *_failedContacts; // contacts that failed to be inserted into db

    BOOL _isCheckingQRCode;
    BOOL _fileChecked;
    AVCaptureSession *_captureSession;

    UIView *_headerView;
    CGRect _contentFrame;

    ScanContentView *_scanContentView;
    ReceiveContentView *_receiveContentView;
    NSInteger _finishedCount;
    NSInteger _insertRetriedCount;
    BOOL _isTaskStarted;
}

- (void) baseInit {
    _receiverStatus = STATUS_RECEIVE_CONNECTION;
    _senderStatus = STATUS_CONTENT_FORMAT_ERROR;
    _sendTriedCount = 0;
    _isCheckingQRCode = NO;
    _finishedCount = 0;
    _insertRetriedCount = 0;

    _receivedContacts = nil;
    _failedContacts = nil;
}

- (instancetype) init {
    if (self = [super init]) {

        _scanContentView = nil;
        _receiveContentView = nil;
        _fileChecked = NO;
        _isTaskStarted = NO;
        [self baseInit];
    }
    return self;
}

#pragma mark ViewController life cycle
- (void) viewDidLoad {
    [super viewDidLoad];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

    UIColor *commonBgColor = [TPDialerResourceManager getColorForStyle:@"tp_color_light_blue_500"];

    _headerView = [self getHeaderView];
    _headerView.backgroundColor = commonBgColor;
    CGFloat gY = _headerView.frame.size.height;
    _contentFrame = CGRectMake(0, gY, TPScreenWidth(), TPScreenHeight() - gY);

    self.view.frame = CGRectMake(0, 0, TPScreenWidth(), TPScreenHeight());
    self.view.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_50"];

    // set up scanner
    _scanContentView = [[ScanContentView alloc] initWithFrame:_contentFrame avOutputDelegate:self];
    _scanContentView.backgroundColor = [UIColor clearColor];
    _scanContentView.hidden = YES;

    _receiveContentView = [[ReceiveContentView alloc] initWithFrame:_contentFrame];
    _receiveContentView.backgroundColor = [UIColor whiteColor];
    _receiveContentView.hidden = YES;
    _receiveContentView.delegate = self;

    // view tree
    [self.view addSubview:_headerView];
    [self.view addSubview:_scanContentView];
    [self.view addSubview:_receiveContentView];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNetworkChange:)
                                        name:N_REACHABILITY_NETWORK_CHANE object:nil];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!_isTaskStarted) {
        [self startReceiveTask];
        _isTaskStarted = YES;
    }
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark notifications
- (void) onContactViewReloaded {
    cootek_log(@"contact_sync, received postNoti, N_SYSTEM_CONTACT_DATA_CHANGED");
    if ([self hasFailed]) {
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:N_SYSTEM_CONTACT_DATA_CHANGED object:nil];
    } else {
        _receiverStatus = STATUS_INSERT_SUCCESS;
        [self onStatusChanged];
    }
}

- (void) onNetworkChange:(NSNotification *)noti {
    id object = noti.object;
    if (!object) {
        return;
    }
    Reachability *networkInfo = (Reachability *)object;
    if (networkInfo.networkStatus == network_none) {
        // network becomes unavailable
        _receiverStatus = STATUS_SELF_FINISHED;
        [self onStatusChanged];
        [self clearResource];
    }
}

#pragma mark initialize view
- (void) resetStatus {
    [self baseInit];
    [self updateContentViewToCurrentStatus:_receiverStatus];
}

- (void) startReceiveTask {
    if ([Reachability network] == network_none) {
        [DefaultUIAlertViewHandler showAlertViewWithTitle:@"触宝提示"
                                                  message:@"没有连接到网络，无法迁移联系人哦~"
                                      onlyOkButtonActionBlock:^{
                                          [self finish];
                                      }
         ];
    } else {
        [DialerUsageRecord recordpath:PATH_CONTACT_TRANSFER kvs:Pair(CONTACT_TRANSFER_RECEIVE_CONNECTION, @(1)), nil];
        [self resetStatus];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onContactViewReloaded) name:N_SYSTEM_CONTACT_DATA_CHANGED object:nil];
        if (_fileChecked) {
            [self checkCameraPermission];
        } else {
            // for the view shows for the first time, check for file.
            [self readFile];
        }
    }
}

- (void) beginScanQRCode {
    self.view.backgroundColor = [UIColor clearColor];
    _receiveContentView.hidden = YES;
    _scanContentView.hidden = NO;
    [_scanContentView startScanning];
}

- (void) checkCameraPermission {
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if (authStatus == AVAuthorizationStatusDenied
        || authStatus == AVAuthorizationStatusRestricted) {
        // show alert to finish or to settings
        [DefaultUIAlertViewHandler showAlertViewWithTitle:@"触宝提示"
                                                  message:@"您还未开启相机权限，无法扫描二维码迁移通讯录"
                                              cancelTitle:@"取消"
                                                  okTitle:@"启用"
                                      okButtonActionBlock:^{
                                          [self toPrivacySettings];
                                      }
                                        cancelActionBlock:^{
                                            [self finish];
                                        }];
    } else {
        [self beginScanQRCode];
    }
}

- (void) toPrivacySettings {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }else{
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=Privacy"]];
    }
}

- (void) receive {
    _receiveRequest = [self getRequest];
    if (_receiveRequest) {
        [_receiveRequest startAsynchronous];
    }
}


- (ASIHTTPRequest *) getRequest {
    [self deleteRequest];
    NSURL *url = [NSURL URLWithString:CONTACT_TRANSFER_URL];
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:url];
    request.requestMethod = HTTP_METHOD_GET; // get

    // set headers
    NSMutableDictionary *headers = request.requestHeaders;
    if (!headers) {
        headers = [[NSMutableDictionary alloc] initWithCapacity:3];
        [headers setObject:@"" forKey:@"User-Agent"];
    }
    NSString *statusString = [@(_receiverStatus) stringValue];
    if (statusString) {
        [headers setObject:statusString forKey:HEADER_STATUS];
    }
    if (!_QRCodestring) {
        _QRCodestring = [UserDefaultsManager stringForKey:CONTACT_TRANSFER_QR_CODE_STRING defaultValue:nil];
    }
    if (_QRCodestring) {
        [headers setObject:_QRCodestring forKey:HEADER_UUID];
    }
    request.requestHeaders = headers;

    __weak ASIHTTPRequest *weakRequest = request;
    __weak ContactTransferReceiveController *weakSelf = self;

    cootek_log(@"contact_transfer, request: %@", [request.requestHeaders objectForKey:HEADER_STATUS]);

    if (_receiverStatus != STATUS_RECEIVE_INTERRUPT) {
        request.completionBlock = ^() {
            int responseCode = weakRequest.responseStatusCode;
            NSError *error = nil;
            NSDictionary *response = [NSJSONSerialization JSONObjectWithData:weakRequest.responseData
                                                                     options:kNilOptions
                                                                       error:&error];
            if (error || !response) {
                response = nil;
                cootek_log(@"contact_transfer, completionBlock, error: %@, httpCode: %d, response: %@", \
                           error, responseCode, response);
            }
            if ([self hasFailed]) {
                response = nil;
            }
            [weakSelf handReceiverStatus:response];
        };
    }

    request.timeOutSeconds = CONNECTION_TIMEOUT_SEC;
    if (_receiverStatus == STATUS_RECEIVE_CONNECTION) {
        request.shouldAttemptPersistentConnection = YES;
        request.persistentConnectionTimeoutSeconds = PERSIST_TIMEOUT_SEC;
    } else {
        request.shouldAttemptPersistentConnection = NO;
    }
    return request;
}

- (void) deleteRequest {
    if (_receiveRequest && ![_receiveRequest isCancelled]) {
        [_receiveRequest cancel];
    }
}

- (void) handReceiverStatus: (NSDictionary *) response {
    if (response) {
        cootek_log(@"contact_transfer, response: %@", [response objectForKey:HEADER_STATUS]);
    } else {
        cootek_log(@"contact_transfer, response: null");
    }
    if (!response) {
        if (_receiverStatus == STATUS_RECEIVE_CONNECTION) {
            [DialerUsageRecord recordpath:PATH_CONTACT_TRANSFER
                    kvs:Pair(CONTACT_TRANSFER_RECEIVE_CONNECT_FAILED, CONTACT_TRANSFER_TIMEOUT), nil];
        } else if (_receiverStatus != STATUS_RECEIVE_INTERRUPT) {
            [DialerUsageRecord recordpath:PATH_CONTACT_TRANSFER
                    kvs:Pair(CONTACT_TRANSFER_RECEIVE_FAILED, CONTACT_TRANSFER_TIMEOUT), nil];
        }
        _receiverStatus = STATUS_SELF_FINISHED;
    } else {
        _senderStatus = [[response objectForKey:HEADER_STATUS] integerValue];

        switch (_senderStatus) {
            case STATUS_SEND_CONNECTION:
            case STATUS_SEND_SENDING: {
                if (_senderStatus == STATUS_SEND_CONNECTION) {
                    [DialerUsageRecord recordpath:PATH_CONTACT_TRANSFER
                                    kvs:Pair(CONTACT_TRANSFER_RECEIVE_CONNECT_SUCCESS, @(1)), nil];
                }
                _receiverStatus = STATUS_RECEIVE_RECEIVING;

                NSDictionary *content = [response objectForKey:NAME_CONTENT];
                NSArray *allKeys = [content allKeys];
                for(NSString *key in allKeys) {
                    id value = [content objectForKey:key];
                    if (value && key) {
                        NSMutableDictionary *item = [[NSMutableDictionary alloc] initWithCapacity:1];
                        [item setObject:value forKey:key];
                        if (!_receivedContacts) {
                            _receivedContacts = [[NSMutableArray alloc] initWithCapacity:1];
                        }
                        [_receivedContacts addObject:[item copy]];
                    }
                }
                break;
            }

            case STATUS_SEND_FINISHED: {
                NSDictionary *content = [response objectForKey:NAME_CONTENT];
                NSNumber *count = [content objectForKey:NAME_COUNT];
                cootek_log(@"contact_transfer, handReceiverStatus, count: %@",\
                           [count stringValue]);
                if (!count || ([count integerValue] != _receivedContacts.count)) {
                    // error: the count is not matched
                   _receiverStatus = STATUS_SELF_FINISHED;
                   [DialerUsageRecord recordpath:PATH_CONTACT_TRANSFER
                                kvs:Pair(CONTACT_TRANSFER_WRONG_CONTACT_COUNTS, @(1)), nil];
                    cootek_log(@"contact_transfer, handReceiverStatus, count erorr, \
                               expected count: %@, acutal count: %@",\
                               [count stringValue], [@(_receivedContacts.count) stringValue]);
                } else {
                    [DialerUsageRecord recordpath:PATH_CONTACT_TRANSFER
                            kvs:Pair(CONTACT_TRANSFER_RECEIVE_SUCCESS, @(1)), nil];
                    _receiverStatus = PRIVATE_STATUS_SELF_SUCCESS;
                    cootek_log(@"contact_sync, receive_finish");
                }
                break;
            }
            case STATUS_CONTENT_FORMAT_ERROR: {
                [DialerUsageRecord recordpath:PATH_CONTACT_TRANSFER
                        kvs:Pair(CONTACT_TRANSFER_RECEIVE_FAILED, CONTACT_TRANSFER_WRONG_CONTENT_FORMAT), nil];
            }
            case STATUS_SEND_INTERRUPT:
            case STATUS_NO_SEND_CONNECTION_ERROR: {
                // those errors can not be catched, so finish sending work.
                _receiverStatus = STATUS_OPPOSITE_FINISHED;
                break;
            }

            case STATUS_NO_UUID_ERROR:
            case STATUS_NO_STATUS_ERROR: {
                if (_sendTriedCount < MAX_RECEIVE_TRIES) {
                    _sendTriedCount++;
                    [self receive];

                } else {
                    _receiverStatus = STATUS_SELF_FINISHED;
                }
            }

            default: {
                break;
            }
        }
    }
    [self onStatusChanged];
    cootek_log(@"contact_transfer, handReceiverStatus, _senderstatus: %@, _receiverStatus: %@",\
               @(_senderStatus), @(_receiverStatus));
}

- (void) onStatusChanged {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateContentViewToCurrentStatus:_receiverStatus];
        switch (_receiverStatus) {
            case STATUS_RECEIVE_RECEIVING:
            case STATUS_RECEIVE_INTERRUPT: {
                [self receive]; // receive data or transit the interupt status
                break;
            }
            case PRIVATE_STATUS_SELF_SUCCESS: {
                // received successfully
                [self saveFile];
                break;
            }
            default: {
                break;
            }
        }
    });
}

- (void) updateContentViewToCurrentStatus:(NSInteger)currentStatus {
    if (!_receiveContentView.hidden) {
        _receiveContentView.status = currentStatus;
    } else if (!_scanContentView.hidden) {
//        _scanContentView.status = currentStatus;
    }
}

- (BOOL) hasFailed {
    return _receiverStatus == STATUS_RECEIVE_INTERRUPT
        || _receiverStatus == STATUS_SELF_FINISHED
        || _receiverStatus == STATUS_INSERT_FAILED_UNKNOWN
        || _receiverStatus == STATUS_INSERT_FAILED_SECURITY
        || _receiverStatus == STATUS_INSERT_FAILED_INTERRUPT
    ;
}

#pragma mark read or write files
- (void) readFile {
    BOOL fileSaved = [UserDefaultsManager boolValueForKey:CONTACT_TRANSFER_FILE_SAVED defaultValue:NO];
    NSString *path = [FileUtils getAbsoluteFilePath:RECEIVED_FILE_NAME];
    if (fileSaved && [FileUtils fileExistAtAbsolutePath:path]) {
        [DefaultUIAlertViewHandler showAlertViewWithTitle:@"触宝提示"
                                                  message:@"上次写入通讯录异常失败，是否重新写入？(已成功写入的联系人会有重复)"
                                      okButtonActionBlock:^{
                                          _receiverStatus = PRIVATE_STATUS_SELF_SUCCESS;
                                          _senderStatus = STATUS_SEND_FINISHED;
                                          _receiveContentView.hidden = NO;
                                          [self onFileSaved:YES finishedCount:0];
                                      }
                                        cancelActionBlock:^{
                                            // delete the saved file, we use sync deleting
                                            [self deleteFile];
                                            [self checkCameraPermission];
                                        }
         ];

    } else {
        // no saved file
        [self checkCameraPermission];
    }
    _fileChecked = YES;
}

- (void) asyncDeleteFile {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self deleteFile];
    });
}

- (void) deleteFile {
    // delete the key
    [UserDefaultsManager removeObjectForKey:CONTACT_TRANSFER_FILE_SAVED];
    // sync deleting
    NSString *path = [FileUtils getAbsoluteFilePath:RECEIVED_FILE_NAME];
    if ([FileUtils fileExistAtAbsolutePath:path]) {
        NSFileManager *fm = [NSFileManager defaultManager];
        NSError *error = nil;
        [fm removeItemAtPath:path error:&error];
        cootek_log(@"contact_transfer, delete file, error: %@", error);
    }
}

- (void) saveFile {
    if (!_receivedContacts || _receivedContacts.count == 0) {
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString *path = [FileUtils getAbsoluteFilePath:RECEIVED_FILE_NAME];
        if (!path) {
            //
            [self resetStatus];
            return;
        }
        BOOL savedSuccess = [_receivedContacts writeToFile:path atomically:YES];
        if (savedSuccess) {
            [UserDefaultsManager setBoolValue:YES forKey:CONTACT_TRANSFER_FILE_SAVED];
        }
        cootek_log(@"contact_transfer, savedSuccess: %d", savedSuccess);
        [self onFileSaved:savedSuccess finishedCount:0];
    });
}

- (void) onFileSaved:(BOOL)savedSuccess finishedCount:(NSInteger)finishedCount{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        // abnormal situation, error
        if (!savedSuccess) {
            _receiverStatus = STATUS_INSERT_FAILED_UNKNOWN;
            _senderStatus = STATUS_SEND_FINISHED;
            [self onStatusChanged];
            return;
        }

        // the file is saved
        if (!_receivedContacts) {
            // the `_receivedContacts` is nil? try to read from the saved file
            NSString *path = [FileUtils getAbsoluteFilePath:RECEIVED_FILE_NAME];
            _receivedContacts = [[NSMutableArray alloc] initWithContentsOfFile:path];
            if (!_receivedContacts || _receivedContacts.count == 0) {
                _receiverStatus = STATUS_INSERT_FAILED_UNKNOWN;
                _senderStatus = STATUS_SEND_FINISHED;
                [self onStatusChanged];
                return;
            }
         }

        // begin to insert
        dispatch_async(dispatch_get_main_queue(), ^{
            _receiverStatus = PRIVATE_STATUS_INSERTING;
            [self onStatusChanged];
        });

        // if the inserting takes more than one minute, show a toast
        __block BOOL insertFinished = NO;
        dispatch_time_t fireTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(30 * NSEC_PER_SEC));
        dispatch_after(fireTime, dispatch_get_main_queue(), ^{
            cootek_log(@"contact_transfer, toast, time: %@, receiver status: %d", [DateTimeUtil stringTimestampInMillis], _receiverStatus);
            if (_receiverStatus == PRIVATE_STATUS_INSERTING) {
                [self.view makeToast:@"正在写入中，时间可能有点长哦~请耐心等待一下吧~"];
            }
        });
        cootek_log(@"contact_transfer, toast, time: %@, receiver status: %d", [DateTimeUtil stringTimestampInMillis], _receiverStatus);

        NSInteger countToWrite = _receivedContacts.count;
        NSInteger index = finishedCount;
        long long insertStartTime = [DateTimeUtil currentTimestampInMillis];
        cootek_log(@"contact_sync, insert_abbook_start");
        NSInteger cursor = 0;
        cootek_log(@"contact_sync, inserting_cursor_%d", cursor);
        cursor++;

        NSMutableArray *transferRecords = [[NSMutableArray alloc] initWithCapacity:_receivedContacts.count];
        ABAddressBookRef iPhoneAddressBook = [TPAddressBookWrapper RetrieveAddressBookRefForCurrentThread];
        for (; index < _receivedContacts.count; index++) {
            @autoreleasepool {
                if (cursor % 100 == 0) {
                    cootek_log(@"contact_sync, inserting_cursor_%d", cursor);
                }
#if ENABLE_TRANSFER_DEBUG
                cootek_log(@"contact_transfer, countToWrite: %@, index: %@",\
                           [@(countToWrite) stringValue], [@(index) stringValue]);
#endif
                if ([self hasFailed]) {
                    break;
                }
                NSDictionary *contact = _receivedContacts[index];
                ContactTransferRecord *transferRecord = [[ContactTransferRecord alloc] initWithDictionary:contact];
                if (transferRecord) {
                    CFErrorRef error = NULL;
                    BOOL writeSuccess =  ABAddressBookAddRecord(iPhoneAddressBook, transferRecord.recordRef, &error);
                    [transferRecords addObject:transferRecord];
                    if (writeSuccess) {
                        _finishedCount += 1;
                    } else {
                        if (!_failedContacts) {
                            _failedContacts = [[NSMutableArray alloc] initWithCapacity:1];
                        }
                        [_failedContacts addObject:contact];
                    }
                }
                cursor++;
            } // autorelease pool
        }
        // save to ABAddressBook
        CFErrorRef saveError = NULL;
        ABAddressBookSave(iPhoneAddressBook, &saveError);
        cootek_log(@"contact_sync, insert_abbook_finish");

        // release all ABRecordRef
        cootek_log(@"contact_sync, remove_refs_start");
        for (ContactTransferRecord *record in transferRecords) {
            SAFE_CFRELEASE_NULL(record.recordRef);
        }
        cootek_log(@"contact_sync, remove_refs_finish");

        long long insertFinishTime = [DateTimeUtil currentTimestampInMillis];
        [DialerUsageRecord recordpath:PATH_CONTACT_TRANSFER
                                  kvs:Pair(CONTACT_TRANSFER_INSERT_TIME, @(insertFinishTime - insertStartTime)), nil];
        if (index == countToWrite) {
            insertFinished = YES;
            [self deleteFile];
        }
        cootek_log(@"contact_sync, insertFinished, finishedCount: %d", _finishedCount);
        if (_finishedCount > 0) {
            // some contacts have been inserted, so update our db
            [_receivedContacts removeAllObjects];
            cootek_log(@"contact_sync, startSync_start");
            [SyncContactWhenAppEnterForground startThreadToAsynContact];
             cootek_log(@"contact_sync, startSync_finish");
            [UserDefaultsManager setIntValue:index forKey:CONTACT_TRANSFER_INSERTED_COUNT];
            [[NSNotificationCenter defaultCenter] postNotificationName:N_CONTACT_TRANSFER_CONTACTS_RELOADING object:nil];
        }
        if (_finishedCount == countToWrite) {
            if (_insertRetriedCount > 0) {
                [DialerUsageRecord recordpath:PATH_CONTACT_TRANSFER
                    kvs:Pair(CONTACT_TRANSFER_RETRY_INSERT_SUCCESS, @(1)), nil];
            } else {
                [DialerUsageRecord recordpath:PATH_CONTACT_TRANSFER
                    kvs:Pair(CONTACT_TRANSFER_INSERT_SUCCESS, @(1)), nil];
            }

        } else {
            if (_insertRetriedCount > 0) {
                // failed again
                [DialerUsageRecord recordpath:PATH_CONTACT_TRANSFER kvs:Pair(CONTACT_TRANSFER_RETRY_INSERT_FAILED, CONTACT_TRANSFER_UNKNOWN_WRONG), nil];
            } else {
                // insert failed for the first time
                [DialerUsageRecord recordpath:PATH_CONTACT_TRANSFER kvs:Pair(CONTACT_TRANSFER_INSERT_FAILED, CONTACT_TRANSFER_UNKNOWN_WRONG), nil];
            }

            _receiverStatus = STATUS_INSERT_FAILED_UNKNOWN;
            _insertRetriedCount++;

            // some contacts failed to insert, alert the user
            NSInteger failedCount = 0;
            if (_failedContacts) {
                failedCount = _failedContacts.count;
            }
            if (failedCount > 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSString *msg = [NSString stringWithFormat:@"有%d个联系人写入失败，请手动写入", failedCount];
                    [DefaultUIAlertViewHandler showAlertViewWithTitle:@"触宝提示"
                                                              message:msg
                                              onlyOkButtonActionBlock:^{
                                              }
                     ]; // alert the failed info.
                });
            }

        }
        //
        [self onStatusChanged];

    });

}

#pragma mark actions
- (void) goToBack {
    if ([self isWoring] && _scanContentView.hidden) {
        NSString *message = nil;
        if (_receiverStatus == PRIVATE_STATUS_INSERTING) {
            message = @"停止后将终止迁移，已经写入成功的联系人将保存在您的通讯录中，确定退出?";
        } else {
            message = @"停止后将终止迁移，确定退出?";
        }
        if (!message) {
            return;
        }
        [DefaultUIAlertViewHandler showAlertViewWithTitle:@"触宝提示"
                                                  message:message
                                      okButtonActionBlock:^{
                                          // exit
                                          [self finish];
                                      }
                                        cancelActionBlock:^{
                                            // do nothing
                                        }];

    } else {
        [self finish];
    }
}

- (void) finish {
    [self clearResource];
    if (_receiverStatus == STATUS_RECEIVE_CONNECTION
        || _receiverStatus == STATUS_RECEIVE_RECEIVING) {
        _receiverStatus = STATUS_RECEIVE_INTERRUPT;
        [self receive];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) clearResource {
    if (!_scanContentView.hidden) {
        [_scanContentView stopScanning];
    }
    [_receivedContacts removeAllObjects];
    [_failedContacts removeAllObjects];
    [self deleteFile];
    if (_receiveRequest && ![_receiveRequest isCancelled]) {
        [_receiveRequest cancel];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:N_SYSTEM_CONTACT_DATA_CHANGED object:nil];
}

#pragma mark delegate AVCaptureMetadataOutputObjectsDelegate
// deleagate for scanner
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects
       fromConnection:(AVCaptureConnection *)connection {
    if (!metadataObjects || metadataObjects.count == 0) {
        cootek_log(@"contact_transfer, metadataobjects is null");
        return;
    }
    AVMetadataMachineReadableCodeObject *metaData = [metadataObjects objectAtIndex:0];
    if (!metaData) {
        return;
    }
    NSString *value = metaData.stringValue;
    [self checkQRCodeFormat:value];
    cootek_log(@"contact_transfer, scann result: %@", value);
}

- (void) checkQRCodeFormat:(NSString *)qrcode {
    // the legal format of QR code string is
    if (_isCheckingQRCode) {
        return;
   }
    //
    BOOL isValid = YES;
    if (!qrcode || qrcode.length == 0) {
        isValid = NO;
    }
    if ([qrcode hasPrefix:@"http"] ||
        [qrcode hasPrefix:@"https"]) {
        isValid = NO;
    }
    if ([qrcode rangeOfString:@"://"].location != NSNotFound) {
        isValid = NO;
    }

    if (![qrcode isMatch:[@"_\\d{13}$" toRxIgnoreCase:YES]]) {
        isValid = NO;
    }

    _isCheckingQRCode = YES;
    if (!isValid) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_scanContentView stopScanning];
            _scanContentView.hidden = YES;
            _receiveContentView.hidden = YES;
            self.view.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_50"];

            [DefaultUIAlertViewHandler showAlertViewWithTitle:@"触宝提示"
                                                      message:@"扫描的二维码格式不对，请重新扫描旧手机的二维码"
                                                      okTitle:@"好的" onlyOkButtonActionBlock:^{
                                                          [self finish];
                                                      }];
        });
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSRange range = [qrcode rangeOfString:@"_"];
            if (range.location != NSNotFound) {
                _receiveContentView.hidden = NO;

                [UserDefaultsManager setObject:qrcode forKey:CONTACT_TRANSFER_QR_CODE_STRING];
                [_scanContentView hide];

                cootek_log(@"contact_sync, receive_start");
                [self receive];
                _isCheckingQRCode = NO;
            }
        });
    }
}

#pragma mark delegate ReceiveContentViewDelegate
- (void) onClickContainer {

    NSString *title = @"触宝提示";
    NSString *message = nil;
    void (^confirmBlock)() = NULL;
    void (^cancelBlock)() = ^{};
    switch (_receiverStatus) {
        case STATUS_INSERT_SUCCESS: {
            return;
        }
        case PRIVATE_STATUS_SELF_SUCCESS: {
            //inserting
            message = @"停止后将终止迁移，确定退出?";
            confirmBlock = ^{
                // STATUS_INSERT_FAILED_INTERRUPT
                _receiverStatus = STATUS_SELF_FINISHED;
                [DialerUsageRecord recordpath:PATH_CONTACT_TRANSFER
                                          kvs:Pair(CONTACT_TRANSFER_SEND_FAILED, CONTACT_TRANSFER_ERROR_INTERRUPT), nil];
                [self onStatusChanged];
            };
            break;
        }
        case STATUS_RECEIVE_CONNECTION:
        case STATUS_RECEIVE_RECEIVING: {
            message = @"停止后将终止迁移，确定退出?";
            confirmBlock = ^{
                // receive interupted
                _receiverStatus = STATUS_RECEIVE_INTERRUPT;
                cootek_log(@"contact_transfer, interupt");
                [self receive];
                [self onStatusChanged];
            };
            break;
        }
        case PRIVATE_STATUS_INSERTING: {
            message = @"停止后将终止迁移，已经写入成功的联系人将保存在您的通讯录中，确定退出?";
            confirmBlock = ^{
                // writting interupted
                _receiverStatus = STATUS_INSERT_FAILED_INTERRUPT;
                [self onStatusChanged];
            };
            break;
        }
        case STATUS_SELF_FINISHED:
        case STATUS_OPPOSITE_FINISHED:
        case STATUS_INSERT_FAILED_INTERRUPT:
        case STATUS_INSERT_FAILED_SECURITY:
        case STATUS_RECEIVE_INTERRUPT:
        case STATUS_INSERT_FAILED_UNKNOWN: {
            [self clearResource];
            [self startReceiveTask];
            break;
        }
        default: {
            break;
        }

    }
    cootek_log(@"contact_transfer, onClickContainer, _receiverStatus: %d, message: %@", _receiverStatus, message);
    dispatch_async(dispatch_get_main_queue(), ^{
        if (confirmBlock) {
            [DefaultUIAlertViewHandler showAlertViewWithTitle:title message:message
                                          okButtonActionBlock:confirmBlock cancelActionBlock: cancelBlock];
        }
    });

}

- (BOOL) isWoring {
    return _receiverStatus == STATUS_RECEIVE_CONNECTION
        || _receiverStatus == STATUS_RECEIVE_RECEIVING
        || _receiverStatus == PRIVATE_STATUS_INSERTING
        || _receiverStatus == PRIVATE_STATUS_SELF_SUCCESS;
}

#pragma mark views
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
    UIButton *titleButton = [[UIButton alloc] initWithFrame:titleFrame];
    titleButton.backgroundColor = [UIColor clearColor];
    titleButton.titleLabel.font = [UIFont systemFontOfSize:18];
    [titleButton setTitle:@"接收通讯录" forState:UIControlStateNormal];

    [titleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [titleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];

    //set up view tree
    [headerView addSubview:cancelButton];
    [headerView addSubview:titleButton];

    return headerView;
}

@end

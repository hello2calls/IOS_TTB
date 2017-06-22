//
//  HangupHeaderView.m
//  TouchPalDialer
//
//  Created by Liangxiu on 15/6/9.
//
//

#import "HangupHeaderView.h"
#import "VoipConsts.h"
#import "TPDialerResourceManager.h"
#import "ContactCacheDataManager.h"
#import "ContactCacheDataModel.h"
#import "CallerIDModel.h"
#import "TPDialerResourceManager.h"
#import "FunctionUtility.h"
#import "CommonTipsWithBolckView.h"
#import "SeattleFeatureExecutor.h"
#import "PersonDBA.h"
#import "TPCallActionController.h"
#import "VoipCallPopUpView.h"
#define ActivityFamilyBindUrl @"http://search.cootekservice.com/page_v3/activity_family_bind?_token="
#import "TPDFamilyInfo.h"
#import <ReactiveCocoa.h>
#import "TPDLib.h"

@implementation HangupHeaderView {
    HeaderViewModel *_model;
    CallMode _callMode;
    NSString *_number;
    NSArray *_numberArr;
    UIButton *_familyButton;
    UIAlertView *_view;
}

@synthesize mainLabel;
@synthesize altLabel;

- (id)initWithModel:(HeaderViewModel *)model {
    self = [super initWithFrame:CGRectMake(0, 0, TPScreenWidth(), 60 + TPHeaderBarHeightDiff())];
    if (self) {
        _model = model;
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        CGFloat topGap = 10 + TPHeaderBarHeightDiff();
        mainLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, topGap, TPScreenWidth(), 25)];
        mainLabel.backgroundColor = [UIColor clearColor];
        if (_model.mainTextColor) {
            mainLabel.textColor = _model.mainTextColor;
        }
        mainLabel.textColor = [UIColor whiteColor];
        mainLabel.font = [UIFont systemFontOfSize:17];
        mainLabel.textAlignment = NSTextAlignmentCenter;
        
        if (_model.mainAttrString) {
            mainLabel.attributedText = _model.mainAttrString;
        } else if (_model.mainText) {
            mainLabel.text = _model.mainText;
        }
        [self addSubview:mainLabel];
        
        topGap += mainLabel.frame.size.height;
        altLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, topGap, TPScreenWidth(), 20)];
        altLabel.backgroundColor = [UIColor clearColor];

        altLabel.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_white_transparency_700"];
        
        if (_model.altText) {
            altLabel.text = _model.altText;
        }
        if (_model.altAttrString) {
            altLabel.attributedText = _model.altAttrString;
        }
        altLabel.font = [UIFont systemFontOfSize:14];
        altLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:altLabel];
        
        _familyButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
        NSString *familyString = @"加为亲情号";
        [_familyButton setTitle:familyString forState:(UIControlStateNormal)];
        UIFont *font = [UIFont systemFontOfSize:12];
        CGSize size = [familyString sizeWithFont:font];
        _familyButton.titleLabel.font = font;
        _familyButton.frame = CGRectMake(TPScreenWidth()-size.width-25, 0, size.width+10, size.height+10);
        _familyButton.center = CGPointMake(_familyButton.center.x, self.tp_height/2+10);
        _familyButton.titleLabel.textAlignment = NSTextAlignmentCenter;

        [_familyButton  setTitleColor:[TPDialerResourceManager getColorForStyle:@"#ff85a6"] forState:(UIControlStateNormal)];
        [_familyButton  setTitleColor:[TPDialerResourceManager getColorForStyle:@"#ff85a6"] forState:(UIControlStateHighlighted)];

        _familyButton.clipsToBounds = YES;
        _familyButton.hidden = YES;
        _familyButton.layer.cornerRadius = 12;
        _familyButton.layer.borderWidth = 1;
        _familyButton.layer.borderColor = ([TPDialerResourceManager getColorForStyle:@"#ff85a6"]).CGColor;
        [_familyButton setBackgroundImage:[TPDialerResourceManager getImageByColorName:@"#4dff4477" withFrame:_familyButton.bounds] forState:UIControlStateHighlighted];
        [self addSubview:_familyButton];
        WEAK(_familyButton)
        [[TPDFamilyInfo familyInfoSignal] subscribeNext:^(id x) {
            TPDFamilyInfo* f = x;
            NSInteger type = [[TPCallActionController controller] getCallNumberTypeCustion:[PhoneNumber getCNnormalNumber:_number]];
            if (_callMode == CallModeOutgoingCall && type!=VOIP_LANDLINE &&![f isFamilyNumber:_number]) {
                CGRect rect = mainLabel.frame;
                CGFloat width = TPScreenWidth() - _familyButton.tp_x;
                rect.origin.x = width + 5;
                rect.size.width = rect.size.width - width * 2 -10;
                mainLabel.frame = rect;
                //TTB修改
//                weak_familyButton.hidden = NO;
                weak_familyButton.hidden = YES;

            }else{
                weak_familyButton.hidden = YES;
            }
        }];
        
        [_familyButton tpd_withBlock:^(id sender) {
            [[TPDFamilyInfo familyInfoSignal] subscribeNext:^(id x) {
                TPDFamilyInfo* f = x;
                if (f == nil || f.bind_success_list.count >=5) {
                    _view= [[UIAlertView alloc] initWithTitle:nil message:@"您的亲情号名额已经用光了！" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确认", nil];
                    _view.tag = 100;
                    [_view show];
                }else{
                    _view= [[UIAlertView alloc] initWithTitle:nil message:@"已向对方发送绑定邀请" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确认", nil];
                    _view.tag = 101;
                    [self asyncSendBindUrl];
                    [_view show];
                    
                }
            }];

        }];

        



        altLabel.tp_width = 2*CGRectGetMinX(_familyButton.frame)-TPScreenWidth()-5;
        altLabel.center = CGPointMake(TPScreenWidth()/2, altLabel.center.y);
        
        
    }
    return self;
}

- (void)showAlertView {
    NSInteger count = [FunctionUtility getCountInBindSuccessListarray];
    if (count >= 5) {
        _view= [[UIAlertView alloc] initWithTitle:nil message:@"您的亲情号名额已经用光了！" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确认", nil];
        _view.tag = 100;
    } else {
        _view= [[UIAlertView alloc] initWithTitle:nil message:@"已向对方发送绑定邀请" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确认", nil];
        _view.tag = 101;
        [self asyncSendBindUrl];
        
    }
    [_view show];

}


- (void)asyncSendBindUrl {
        NSInteger personID = [NumberPersonMappingModel queryContactIDByNumber:_number];
        ContactCacheDataModel *model = [PersonDBA getConatctInfoByRecordID:personID];

        NSString *contacts_name = model.fullName;
        NSString *urlString = [[NSString stringWithFormat:@"%@%@&phone=%@&label=""&contacts_name=%@&is_binding_eachother=true",ActivityFamilyBindUrl,[SeattleFeatureExecutor getToken],_number,contacts_name]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
        [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
            cootek_log(@"=======%d",[[NSThread currentThread] isMainThread]);
        }];
}

- (instancetype)initWithNumberArr:(NSArray *)numberArr callMode:(CallMode)callMode {
    if (numberArr.count == 1) {
        return [self initWithNumber:numberArr[0] callMode:callMode];
    }else{
        _numberArr = numberArr;
        _callMode = callMode;
        
        HeaderViewModel *viewModel = [[HeaderViewModel alloc] init];
        NSString* mainStr = @"我";
        for (NSString* num in numberArr) {
            int personId = [NumberPersonMappingModel queryContactIDByNumber:num];
            
            
            if (personId > 0) {
                ContactCacheDataModel *contact = [[ContactCacheDataManager instance] contactCacheItem:personId];
                mainStr = [[mainStr stringByAppendingString:@"、"] stringByAppendingString: contact.displayName];
            }else{
                mainStr = [[mainStr stringByAppendingString:@"、"] stringByAppendingString: num];
            }
            
        }
        
        viewModel.mainText = @"正在呼叫";
        viewModel.altText = @"等待多人响应";
        
        viewModel.mainTextColor = [TPDialerResourceManager getColorForStyle:@"tp_color_white"];
        viewModel.altTextColor = [TPDialerResourceManager getColorForStyle:@"tp_color_white_transparency_700"];
        viewModel.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_black_transparency_500"];
        return [self initWithModel:viewModel];
    }
    
    
}


- (instancetype)initWithNumber:(NSString *)number callMode:(CallMode)callMode {
    _number = number;
    _callMode = callMode;
    
    int personId = [NumberPersonMappingModel queryContactIDByNumber:_number];
    
    HeaderViewModel *viewModel = [[HeaderViewModel alloc] init];
    if (personId > 0) {
        ContactCacheDataModel *contact = [[ContactCacheDataManager instance] contactCacheItem:personId];
        viewModel.mainText = contact.displayName;
        viewModel.altText = number;
        
    } else {
        viewModel.mainText = number;
        viewModel.altText = nil;
        [CallerIDModel queryCallerIDWithNumber:_number callBackBlock:^(CallerIDInfoModel * callerId){
            if ([callerId isCallerIdUseful]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.altLabel.text = [callerId getUsefulString];
                });
            }
        }];
    }
    viewModel.mainTextColor = [TPDialerResourceManager getColorForStyle:@"tp_color_white"];
    viewModel.altTextColor = [TPDialerResourceManager getColorForStyle:@"tp_color_white_transparency_700"];
    viewModel.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_black_transparency_500"];
    return [self initWithModel:viewModel];
}

@end


@implementation OnCallHeaderVeiw

@end

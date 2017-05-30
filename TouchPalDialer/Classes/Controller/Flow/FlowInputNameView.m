//
//  FlowInputNameView.m
//  TouchPalDialer
//
//  Created by game3108 on 15/3/3.
//
//

#import "FlowInputNameView.h"
#import "TPDialerResourceManager.h"
#import "SeattleFeatureExecutor.h"
#import "FlowInputResultView.h"
#import "CustomInputTextFiled.h"
#import "FlowInteractView.h"
#import "DialerUsageRecord.h"
#import "TPAnalyticConstants.h"
#import "TouchPalDialerAppDelegate.h"
#import "LoginController.h"
#import "CallFlowPacketLoginController.h"
#import "HandlerWebViewController.h"

@interface FlowInputNameView(){
    UITextField *_inputField;
    NSInteger _flowNum;
    UIButton *_exchangeButton;
    
    UIViewController *_sourceCon;
    FlowInteractView *boardView;
    
    CGRect _boardFrame;
}

@end


@implementation FlowInputNameView


-(instancetype)initWithFrame:(CGRect)frame andName:(NSString *)name andFlowNumber:(NSInteger)flowNum andSourceCon:(UIViewController *)sourceCon{
    self = [super initWithFrame:frame];
    
    if ( self ){
        
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
        _flowNum = flowNum;
        _sourceCon = sourceCon;
        
        boardView = [[FlowInteractView alloc]initWithFrame:CGRectMake(16, TPHeaderBarHeightDiff() + 117, 296, 240)];
        boardView.backgroundColor = [UIColor whiteColor];
        boardView.layer.masksToBounds = YES;
        boardView.layer.cornerRadius = 3.0f;
        [self addSubview:boardView];
        _boardFrame = boardView.frame;
        
        UIButton *cancelButton = [[UIButton alloc]initWithFrame:CGRectMake(boardView.frame.size.width - 40 , 0, 40, 40)];
        [cancelButton addTarget:self action:@selector(removeView) forControlEvents:UIControlEventTouchUpInside];
        [boardView addSubview:cancelButton];
        
        UIImageView *cancelImage = [[UIImageView alloc]initWithFrame:CGRectMake(12.5, 12.5, 15, 15)];
        cancelImage.image = [TPDialerResourceManager getImage:@"contact_search_close@2x.png"];
        [cancelButton addSubview:cancelImage];
        
        float globalY = 30;
        
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, globalY, boardView.frame.size.width - 40, FONT_SIZE_0_5)];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [TPDialerResourceManager getColorForStyle:@"flow_inputname_view_title_color"];
        titleLabel.font = [UIFont systemFontOfSize:FONT_SIZE_0_5];
        titleLabel.text = @"最后一步";
        [boardView addSubview:titleLabel];
        
        globalY += titleLabel.frame.size.height + 22;
        
        UILabel *inputLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, globalY, boardView.frame.size.width - 40, 20)];
        inputLabel.backgroundColor = [UIColor clearColor];
        inputLabel.textColor = [TPDialerResourceManager getColorForStyle:@"flow_inputname_view_inputlabel_color"];
        inputLabel.font = [UIFont systemFontOfSize:FONT_SIZE_3_5];
        inputLabel.text = @"请输入上方显示的完整账户名";
        [boardView addSubview:inputLabel];
        
        globalY += 10 + inputLabel.frame.size.height;
        _inputField = [[CustomInputTextFiled alloc] initWithFrame:CGRectMake(20, globalY, 180, 40) andPlaceHolder:name andID:nil];
        _inputField.layer.cornerRadius = 3.0f;
        _inputField.layer.masksToBounds = YES;
        [_inputField addTarget:self action:@selector(onTextFieldChange) forControlEvents:UIControlEventEditingChanged];
        [boardView addSubview:_inputField];
        
        CGRect oldFrame = _inputField.frame;
        
        _exchangeButton = [[UIButton alloc]initWithFrame:CGRectMake(oldFrame.origin.x+oldFrame.size.width+6, oldFrame.origin.y, 66, oldFrame.size.height)];
        _exchangeButton.layer.masksToBounds = YES;
        _exchangeButton.layer.cornerRadius = 3.0f;
        [_exchangeButton setTitle:@"提取" forState:UIControlStateNormal];
        _exchangeButton.titleLabel.font = [UIFont systemFontOfSize:FONT_SIZE_3_5];
        [_exchangeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_exchangeButton setBackgroundImage:[[TPDialerResourceManager sharedManager]getResourceByStyle:@"flow_inputname_view_button_normal_image"] forState:UIControlStateNormal];
        [_exchangeButton setBackgroundImage:[[TPDialerResourceManager sharedManager]getResourceByStyle:@"flow_inputname_view_button_hl_image"] forState:UIControlStateHighlighted];
        [_exchangeButton setBackgroundImage:[[TPDialerResourceManager sharedManager]getResourceByStyle:@"flow_inputname_view_button_disable_image"] forState:UIControlStateDisabled];
        [boardView addSubview:_exchangeButton];
        _exchangeButton.enabled = NO;
        [_exchangeButton addTarget:self action:@selector(exchangeFlow) forControlEvents:UIControlEventTouchUpInside];
        
        globalY += _inputField.frame.size.height + 20;
        
        NSString *excuseStr = @"*由于淘宝账户安全策略，触宝无法获取您的账号信息，需要您手工输入完整账户名，以完成流量提取。";
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:excuseStr];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        
        [paragraphStyle setLineSpacing:2];//调整行间距
        
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [excuseStr length])];
        
        UILabel *excuseLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, globalY, boardView.frame.size.width - 40, 50)];
        excuseLabel.font = [UIFont systemFontOfSize:FONT_SIZE_5_5];
        excuseLabel.textColor = [TPDialerResourceManager getColorForStyle:@"flow_inputname_view_excuselabel_color"];
        excuseLabel.attributedText = attributedString;
        excuseLabel.numberOfLines = 3;
        [boardView addSubview:excuseLabel];
        
        if ( TPScreenHeight() < 500 ){
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(keyboardWillBeShown:) name:UIKeyboardWillShowNotification object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(keyboardWillBeHidden:)
                                                         name:UIKeyboardWillHideNotification object:nil];
        }

    }
    
    return self;
}

- (void)drawRect:(CGRect)rect
{

    //设置背景颜色
    //[[UIColor clearColor]set];
    
    //UIRectFill([self bounds]);
    
    //拿到当前视图准备好的画板

    CGContextRef
    context = UIGraphicsGetCurrentContext();

    //利用path进行绘制三角形
    
    
    CGContextBeginPath(context);//标记
    
    
    CGContextMoveToPoint(context,40, 137);//设置起点
    
    
    CGContextAddLineToPoint(context,52, 125);
    
    
    CGContextAddLineToPoint(context,64, 137);
    
    
    CGContextClosePath(context);//路径结束标志，不写默认封闭
    
    
    [[UIColor whiteColor] setFill];
    //设置填充色
    
    
    [[UIColor whiteColor] setStroke];
    //设置边框颜色
    
    CGContextDrawPath(context, kCGPathFillStroke);//绘制路径path
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    if ([_inputField isFirstResponder]) {
        [_inputField resignFirstResponder];
    }
}

- (void)onTextFieldChange{
    if ( [_inputField.text length] > 0 ){
        _exchangeButton.enabled = YES;
    }else{
        _exchangeButton.enabled = NO;
    }
    
}

- (void)exchangeFlow{
    if ([_inputField isFirstResponder]) {
        [_inputField resignFirstResponder];
    }
    _exchangeButton.enabled = NO;
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(0, 0, _exchangeButton.frame.size.width/2, _exchangeButton.frame.size.width/2)];
    [indicator setCenter:CGPointMake(_exchangeButton.frame.size.width/2, _exchangeButton.frame.size.height/2)];
    [indicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    indicator.hidesWhenStopped = YES;
    [indicator startAnimating];
    [_exchangeButton addSubview:indicator];
    [DialerUsageRecord recordpath:EV_FLOW_INPUTNAME_VIEW_SUBMIT_PRESS kvs:Pair(@"count", @(1)), nil];
    dispatch_async([SeattleFeatureExecutor getQueue], ^{
        NSInteger resultCode = [SeattleFeatureExecutor exchangeTraffic:_inputField.text flow:_flowNum];
        dispatch_sync(dispatch_get_main_queue(), ^{
            if ( (resultCode == 2000 || resultCode == 4321) && _sourceCon != nil ){
                [DialerUsageRecord recordpath:EV_FLOW_INPUTNAME_VIEW_SUBMIT_SUCCESS kvs:Pair(@"count", @(1)), nil];

                if ( [_sourceCon isKindOfClass:[HandlerWebViewController class]] ){
                    HandlerWebViewController *tempt = (HandlerWebViewController*)_sourceCon;
                    [tempt reload];
                }
            }else{
                [DialerUsageRecord recordpath:EV_FLOW_INPUTNAME_VIEW_SUBMIT_FAIL kvs:Pair(@"count", @(1)), nil];

            }
            if ( resultCode == 4004 ){
                [DialerUsageRecord recordpath:EV_FLOW_RESULT_VIEW_CODE_4004 kvs:Pair(@"count", @(1)), nil];

                UINavigationController *navi = [((TouchPalDialerAppDelegate *)[[UIApplication sharedApplication] delegate]) activeNavigationController];
                [navi popToRootViewControllerAnimated:NO];
                [LoginController checkLoginWithDelegate:[CallFlowPacketLoginController withOrigin:@"noah_webview_alert"]];
            }else{
                FlowInputResultView *resultView = [[FlowInputResultView alloc]initWithFrame:CGRectMake(0, 0, TPScreenWidth(), TPScreenHeight()) andResultCode:resultCode];
                UIWindow *uiWindow = [[UIApplication sharedApplication].windows objectAtIndex:0];
                [uiWindow addSubview:resultView];
                [uiWindow bringSubviewToFront:resultView];
            }
            [self removeView];
        });
    });
}

- (void)removeView{
    if ( [_inputField.text length] > 0 ){
        [DialerUsageRecord recordpath:EV_FLOW_INPUTNAME_VIEW_BACK_HAS_INPUT kvs:Pair(@"count", @(1)), nil];
    }else{
        [DialerUsageRecord recordpath:EV_FLOW_INPUTNAME_VIEW_BACK_NO_INPUT kvs:Pair(@"count", @(1)), nil];
    }
    
    [self removeFromSuperview];
}

#pragma mark keyboardShownObserverSelecter


- (void) keyboardWillBeShown:(NSNotification *) notification
{
    if ([_inputField isFirstResponder]){
        NSDictionary *userInfo = [notification userInfo];
        NSNumber *animationDurationNumber = (NSNumber *)[userInfo objectForKey:@"UIKeyboardAnimationDurationUserInfoKey"];
        CGFloat animationDuration = 0.0f;
        animationDuration = [animationDurationNumber floatValue];
        [UIView animateWithDuration:animationDuration animations:^{
            boardView.frame = CGRectMake(_boardFrame.origin.x, _boardFrame.origin.y - 60, _boardFrame.size.width, _boardFrame.size.height);
        }];
        
    }
}

- (void) keyboardWillBeHidden:(NSNotification *) notification
{
    if ([_inputField isFirstResponder]){
        NSDictionary *userInfo = [notification userInfo];
        NSNumber *animationDurationNumber = (NSNumber *)[userInfo objectForKey:@"UIKeyboardAnimationDurationUserInfoKey"];
        CGFloat animationDuration = 0.0f;
        animationDuration = [animationDurationNumber floatValue];
        [UIView animateWithDuration:animationDuration animations:^{
            boardView.frame = CGRectMake(_boardFrame.origin.x, _boardFrame.origin.y, _boardFrame.size.width, _boardFrame.size.height);
        }];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end

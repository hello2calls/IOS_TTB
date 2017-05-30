//
//  FlowInputResultView.m
//  TouchPalDialer
//
//  Created by game3108 on 15/3/3.
//
//

#import "FlowInputResultView.h"
#import "TPDialerResourceManager.h"
#import "DialerUsageRecord.h"
#import "TPAnalyticConstants.h"

@interface FlowInputResultView(){
    NSInteger _resultCode;
}

@end

@implementation FlowInputResultView

- (instancetype)initWithFrame:(CGRect)frame andResultCode:(NSInteger)resultCode{
    self = [super initWithFrame:frame];
    
    if ( self ){
        
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
        _resultCode = resultCode;
        
        UIView *boardView = [[UIView alloc]initWithFrame:CGRectMake(16, TPHeaderBarHeightDiff() + 117, 296, 216)];
        boardView.backgroundColor = [UIColor whiteColor];
        boardView.layer.masksToBounds = YES;
        boardView.layer.cornerRadius = 3.0f;
        [self addSubview:boardView];
        
        UIButton *cancelButton = [[UIButton alloc]initWithFrame:CGRectMake(boardView.frame.size.width - 40 , 0, 40, 40)];
        [cancelButton addTarget:self action:@selector(removeView) forControlEvents:UIControlEventTouchUpInside];
        [boardView addSubview:cancelButton];
        
        UIImageView *cancelImage = [[UIImageView alloc]initWithFrame:CGRectMake(12.5, 12.5, 15, 15)];
        cancelImage.image = [TPDialerResourceManager getImage:@"contact_search_close@2x.png"];
        [cancelButton addSubview:cancelImage];
        
        float globalY = 30;
        
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, globalY, boardView.frame.size.width - 40, FONT_SIZE_0_5)];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [TPDialerResourceManager getColorForStyle:@"flow_inputresult_view_excuselabel_color"];
        titleLabel.font = [UIFont systemFontOfSize:FONT_SIZE_0_5];
        titleLabel.text = NSLocalizedString(@"taobao_exchange_success", "");
        [boardView addSubview:titleLabel];
        
        globalY += titleLabel.frame.size.height + 22;
        
        UILabel *inputLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, globalY, boardView.frame.size.width - 40, 40)];
        inputLabel.backgroundColor = [UIColor clearColor];
        inputLabel.numberOfLines = 2;
        inputLabel.font = [UIFont systemFontOfSize:FONT_SIZE_3_5];
        inputLabel.text = NSLocalizedString(@"taobao_exchange_success_2000", "");
        [boardView addSubview:inputLabel];
        
        globalY += inputLabel.frame.size.height + 22 ;
        
        UIButton *sureButton = [[UIButton alloc]initWithFrame:CGRectMake(20, globalY, boardView.frame.size.width - 40, VOIP_LINE_HEIGHT)];
        sureButton.layer.masksToBounds = YES;
        sureButton.layer.cornerRadius = 3.0f;
        [sureButton setTitle:NSLocalizedString(@"taobao_sure_button", "") forState:UIControlStateNormal];
        sureButton.titleLabel.font = [UIFont systemFontOfSize:FONT_SIZE_3_5];
        [sureButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [sureButton setBackgroundImage:[[TPDialerResourceManager sharedManager]getResourceByStyle:@"flow_inputname_view_button_normal_image"] forState:UIControlStateNormal];
        [sureButton setBackgroundImage:[[TPDialerResourceManager sharedManager]getResourceByStyle:@"flow_inputname_view_button_hl_image"] forState:UIControlStateHighlighted];
        [boardView addSubview:sureButton];
        [sureButton addTarget:self action:@selector(sureAction) forControlEvents:UIControlEventTouchUpInside];
        
        if ( resultCode == 4321 ){
            inputLabel.text = NSLocalizedString(@"taobao_exchange_success_4321", "");
            [DialerUsageRecord recordpath:EV_FLOW_RESULT_VIEW_CODE_4321 kvs:Pair(@"count", @(1)), nil];
        }else if ( resultCode != 2000 ){
            titleLabel.textColor = [TPDialerResourceManager getColorForStyle:@"flow_inputresult_view_excuselabel_error_color"];
            titleLabel.text = NSLocalizedString(@"taobao_exchange_fail", "");
            [sureButton setBackgroundImage:[[TPDialerResourceManager sharedManager]getResourceByStyle:@"flow_inputresult_view_errorbutton_normal_image"] forState:UIControlStateNormal];
            [sureButton setBackgroundImage:[[TPDialerResourceManager sharedManager]getResourceByStyle:@"flow_inputresult_view_errorbutton_normal_hl_image"] forState:UIControlStateHighlighted];
            if ( resultCode == 4322 ){
                inputLabel.text = NSLocalizedString(@"taobao_exchange_error_4322", "");
                [DialerUsageRecord recordpath:EV_FLOW_RESULT_VIEW_CODE_4322 kvs:Pair(@"count", @(1)), nil];
            }else if ( resultCode == 4324 ){
                inputLabel.text = NSLocalizedString(@"taobao_exchange_error_4324", "");
                [DialerUsageRecord recordpath:EV_FLOW_RESULT_VIEW_CODE_4324 kvs:Pair(@"count", @(1)), nil];
            }else if ( resultCode == 4325 ){
                inputLabel.text = NSLocalizedString(@"taobao_exchange_error_4325", "");
                [DialerUsageRecord recordpath:EV_FLOW_RESULT_VIEW_CODE_4325 kvs:Pair(@"count", @(1)), nil];
            }else if ( resultCode == 4328 ){
                inputLabel.text = NSLocalizedString(@"taobao_exchange_error_4328", "");
                [DialerUsageRecord recordpath:EV_FLOW_RESULT_VIEW_CODE_4328 kvs:Pair(@"count", @(1)), nil];
            }else if ( resultCode == 4329 ){
                inputLabel.text = NSLocalizedString(@"taobao_exchange_error_4329", "");
                [DialerUsageRecord recordpath:EV_FLOW_RESULT_VIEW_CODE_4329 kvs:Pair(@"count", @(1)), nil];
            }else if ( resultCode == 4326 ){
                inputLabel.text = NSLocalizedString(@"taobao_exchange_error_4326", "");
                [DialerUsageRecord recordpath:EV_FLOW_RESULT_VIEW_CODE_4326 kvs:Pair(@"count", @(1)), nil];
            }else if ( resultCode == 4327 ){
                inputLabel.text = NSLocalizedString(@"taobao_exchange_error_4327", "");
                [DialerUsageRecord recordpath:EV_FLOW_RESULT_VIEW_CODE_4327 kvs:Pair(@"count", @(1)), nil];
            }else if ( resultCode == 4330 ){
                inputLabel.text = NSLocalizedString(@"taobao_exchange_error_4330", "");
                [DialerUsageRecord recordpath:EV_FLOW_RESULT_VIEW_CODE_4330 kvs:Pair(@"count", @(1)), nil];
            }else if ( resultCode == 4004 ){
                inputLabel.text = NSLocalizedString(@"taobao_exchange_error_4004", "");
                [DialerUsageRecord recordpath:EV_FLOW_RESULT_VIEW_CODE_4004 kvs:Pair(@"count", @(1)), nil];
            }else{
                inputLabel.text = NSLocalizedString(@"taobao_exchange_error_else", "");
                [DialerUsageRecord recordpath:EV_FLOW_RESULT_VIEW_CODE_ELSE kvs:Pair(@"count", @(1)), nil];
            }
        }
    }else{
        [DialerUsageRecord recordpath:EV_FLOW_RESULT_VIEW_CODE_2000 kvs:Pair(@"count", @(1)), nil];
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
    
    
    CGContextMoveToPoint(context,40, 117+TPHeaderBarHeightDiff());//设置起点
    
    
    CGContextAddLineToPoint(context,52, 105+TPHeaderBarHeightDiff());
    
    
    CGContextAddLineToPoint(context,64, 117+TPHeaderBarHeightDiff());
    
    
    CGContextClosePath(context);//路径结束标志，不写默认封闭
    
    
    [[UIColor whiteColor] setFill];
    //设置填充色
    
    
    [[UIColor whiteColor] setStroke];
    //设置边框颜色
    
    
    CGContextDrawPath(context, kCGPathFillStroke);//绘制路径path
}

- (void)sureAction{
    if ( _resultCode == 2000 || _resultCode == 4321 ){
        [DialerUsageRecord recordpath:EV_FLOW_RESULT_VIEW_SUCCESS_SURE_BUTTON_PRESS kvs:Pair(@"count", @(1)), nil];
        if ( _resultCode == 2000 ){
            [DialerUsageRecord recordpath:EV_FLOW_RESULT_VIEW_SURE_BUTTON_CODE_2000 kvs:Pair(@"count", @(1)), nil];
        }else if ( _resultCode == 4321 ){
            [DialerUsageRecord recordpath:EV_FLOW_RESULT_VIEW_SURE_BUTTON_CODE_4321 kvs:Pair(@"count", @(1)), nil];
        }
    }else{
        [DialerUsageRecord recordpath:EV_FLOW_RESULT_VIEW_FAIL_SURE_BUTTON_PRESS kvs:Pair(@"count", @(1)), nil];
        if ( _resultCode == 4322 ){
            [DialerUsageRecord recordpath:EV_FLOW_RESULT_VIEW_SURE_BUTTON_CODE_4322 kvs:Pair(@"count", @(1)), nil];
        }else if ( _resultCode == 4324 ){
            [DialerUsageRecord recordpath:EV_FLOW_RESULT_VIEW_SURE_BUTTON_CODE_4324 kvs:Pair(@"count", @(1)), nil];

        }else if ( _resultCode == 4325 ){
            [DialerUsageRecord recordpath:EV_FLOW_RESULT_VIEW_SURE_BUTTON_CODE_4325 kvs:Pair(@"count", @(1)), nil];

        }else if ( _resultCode == 4328 ){
            [DialerUsageRecord recordpath:EV_FLOW_RESULT_VIEW_SURE_BUTTON_CODE_4328 kvs:Pair(@"count", @(1)), nil];

        }else if ( _resultCode == 4329 ){
            [DialerUsageRecord recordpath:EV_FLOW_RESULT_VIEW_SURE_BUTTON_CODE_4329 kvs:Pair(@"count", @(1)), nil];

        }else if ( _resultCode == 4326 ){
            [DialerUsageRecord recordpath:EV_FLOW_RESULT_VIEW_SURE_BUTTON_CODE_4326 kvs:Pair(@"count", @(1)), nil];

        }else if ( _resultCode == 4330 ){
            [DialerUsageRecord recordpath:EV_FLOW_RESULT_VIEW_SURE_BUTTON_CODE_4330 kvs:Pair(@"count", @(1)), nil];

        }else{
            [DialerUsageRecord recordpath:EV_FLOW_RESULT_VIEW_SURE_BUTTON_CODE_ELSE kvs:Pair(@"count", @(1)), nil];

        }
    }
    
    
    [self removeFromSuperview];
}

- (void)removeView{
    if ( _resultCode == 2000 || _resultCode == 4321 ){
        [DialerUsageRecord recordpath:EV_FLOW_RESULT_VIEW_SUCCESS_X_PRESS kvs:Pair(@"count", @(1)), nil];
        if ( _resultCode == 2000 ){
            [DialerUsageRecord recordpath:EV_FLOW_RESULT_VIEW_X_PRESS_CODE_2000 kvs:Pair(@"count", @(1)), nil];
        }else if ( _resultCode == 4321 ){
            [DialerUsageRecord recordpath:EV_FLOW_RESULT_VIEW_X_PRESS_CODE_4321 kvs:Pair(@"count", @(1)), nil];
        }
    }else{
        [DialerUsageRecord recordpath:EV_FLOW_RESULT_VIEW_FAIL_X_PRESS kvs:Pair(@"count", @(1)), nil];
        if ( _resultCode == 4322 ){
            [DialerUsageRecord recordpath:EV_FLOW_RESULT_VIEW_X_PRESS_CODE_4322 kvs:Pair(@"count", @(1)), nil];
        }else if ( _resultCode == 4324 ){
            [DialerUsageRecord recordpath:EV_FLOW_RESULT_VIEW_X_PRESS_CODE_4324 kvs:Pair(@"count", @(1)), nil];
        }else if ( _resultCode == 4325 ){
            [DialerUsageRecord recordpath:EV_FLOW_RESULT_VIEW_X_PRESS_CODE_4325 kvs:Pair(@"count", @(1)), nil];
        }else if ( _resultCode == 4328 ){
            [DialerUsageRecord recordpath:EV_FLOW_RESULT_VIEW_X_PRESS_CODE_4328 kvs:Pair(@"count", @(1)), nil];
        }else if ( _resultCode == 4329 ){
            [DialerUsageRecord recordpath:EV_FLOW_RESULT_VIEW_X_PRESS_CODE_4329 kvs:Pair(@"count", @(1)), nil];
        }else if ( _resultCode == 4326 ){
            [DialerUsageRecord recordpath:EV_FLOW_RESULT_VIEW_X_PRESS_CODE_4326 kvs:Pair(@"count", @(1)), nil];
        }else if ( _resultCode == 4330 ){
            [DialerUsageRecord recordpath:EV_FLOW_RESULT_VIEW_X_PRESS_CODE_4330 kvs:Pair(@"count", @(1)), nil];
        }else{
            [DialerUsageRecord recordpath:EV_FLOW_RESULT_VIEW_X_PRESS_CODE_ELSE kvs:Pair(@"count", @(1)), nil];
        }
    }
    [self removeFromSuperview];
}

@end

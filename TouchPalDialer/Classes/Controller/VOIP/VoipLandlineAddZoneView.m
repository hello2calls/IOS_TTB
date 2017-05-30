//
//  VoipLandlineAddZoneView.m
//  TouchPalDialer
//
//  Created by game3108 on 15/3/9.
//
//

#import "VoipLandlineAddZoneView.h"
#import "PhoneNumber.h"
#import "FlowInteractView.h"
#import "TPDialerResourceManager.h"
#import "VoipSystemInpuField.h"

@interface VoipLandlineAddZoneView(){
    FlowInteractView *boardView;
    VoipSystemInpuField *_numberFiled;
    
    NSString *_number;
    UIButton *sureButton;
}
@property (nonatomic,retain) NSString *number;
@end


@implementation VoipLandlineAddZoneView

- (instancetype)initWithFrame:(CGRect)frame andNumber:(NSString *)number{
    self = [super initWithFrame:frame];
    
    if ( self ){
        
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
        self.number = number;
        
        boardView = [[FlowInteractView alloc]initWithFrame:CGRectMake((TPScreenWidth()-300)/2, (TPScreenHeight()-170)/2, 300, 170)];
        boardView.backgroundColor = [TPDialerResourceManager getColorForStyle:@"voip_landline_addzoneView_bg_color"];
        boardView.layer.masksToBounds = YES;
        boardView.layer.cornerRadius = 7.0f;
        [self addSubview:boardView];
        
        float globalY = 20;
        
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, globalY, boardView.frame.size.width, FONT_SIZE_2_5)];
        titleLabel.text = @"提示";
        titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:FONT_SIZE_2_5];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [boardView addSubview:titleLabel];
        
        globalY += titleLabel.frame.size.height + 10;
        
        UILabel *callLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, globalY, boardView.frame.size.width, FONT_SIZE_4_5)];
        callLabel.text = @"用免费电话拨打固话，需加上区号";
        callLabel.font = [UIFont systemFontOfSize:FONT_SIZE_4_5];
        callLabel.backgroundColor = [UIColor clearColor];
        callLabel.textAlignment = NSTextAlignmentCenter;
        [boardView addSubview:callLabel];
        
        globalY += callLabel.frame.size.height + 20;
        
        _numberFiled = [[VoipSystemInpuField alloc]initWithFrame:CGRectMake(15, globalY, boardView.frame.size.width - 30, 30) andPlaceHolder:@"请输入区号"];
        _numberFiled.keyboardType = UIKeyboardTypeNumberPad;
        [_numberFiled becomeFirstResponder];
        [boardView addSubview:_numberFiled];
        [_numberFiled addTarget:self action:@selector(fieldChange) forControlEvents:UIControlEventEditingChanged];
        
        UILabel *numberLabel = [[UILabel alloc]initWithFrame:CGRectMake(_numberFiled.frame.size.width - 125 , 0, 120, 30)];
        numberLabel.text = number;
        numberLabel.font = [UIFont systemFontOfSize:FONT_SIZE_4_5];
        numberLabel.textAlignment = NSTextAlignmentRight;
        numberLabel.backgroundColor = [UIColor clearColor];
        numberLabel.textColor = [TPDialerResourceManager getColorForStyle:@"voip_landline_addzoneView_textField_placeholder_color"];
        [_numberFiled addSubview:numberLabel];
        
        globalY += _numberFiled.frame.size.height + 15;
        
        UIView *line1 = [[UIView alloc]initWithFrame:CGRectMake(0, globalY, boardView.frame.size.width, 0.5)];
        line1.backgroundColor = [TPDialerResourceManager getColorForStyle:@"voip_landline_addzoneView_button_border_color"];
        [boardView addSubview:line1];
        
        UIView *line2 = [[UIView alloc]initWithFrame:CGRectMake(boardView.frame.size.width/2-0.25, globalY, 0.5, 45)];
        line2.backgroundColor = [TPDialerResourceManager getColorForStyle:@"voip_landline_addzoneView_button_border_color"];
        [boardView addSubview:line2];
        
        UIButton *cancelButton = [[UIButton alloc]initWithFrame:CGRectMake(0, globalY, boardView.frame.size.width/2, 44)];
        cancelButton.titleLabel.font = [UIFont systemFontOfSize:FONT_SIZE_2_5];
        [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [cancelButton setTitleColor:[TPDialerResourceManager getColorForStyle:@"voip_landline_addzoneView_button_normal_color"] forState:UIControlStateNormal];
        [boardView addSubview:cancelButton];
        [cancelButton addTarget:self action:@selector(cancelButtonAction) forControlEvents:UIControlEventTouchUpInside];
        
        sureButton = [[UIButton alloc]initWithFrame:CGRectMake(boardView.frame.size.width/2, globalY, boardView.frame.size.width/2, 44)];
        sureButton.enabled = NO;
        sureButton.titleLabel.font = [UIFont systemFontOfSize:FONT_SIZE_2_5];
        [sureButton setTitle:@"确定" forState:UIControlStateNormal];
        [sureButton setTitleColor:[TPDialerResourceManager getColorForStyle:@"voip_landline_addzoneView_button_normal_color"] forState:UIControlStateNormal];
        [sureButton setTitleColor:[TPDialerResourceManager getColorForStyle:@"voip_landline_addzoneView_button_disable_color"] forState:UIControlStateDisabled];
        [boardView addSubview:sureButton];
        [sureButton addTarget:self action:@selector(sureButtonAction) forControlEvents:UIControlEventTouchUpInside];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillBeShown:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillBeHidden:)
                                                     name:UIKeyboardWillHideNotification object:nil];
    }
    
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    if ([_numberFiled isFirstResponder]) {
        [_numberFiled resignFirstResponder];
    }
}


- (void)fieldChange{
    NSString *number = [NSString stringWithFormat:@"%@%@",_numberFiled.text,_number];
    NSString *normalizePhone = [PhoneNumber getCNnormalNumber:number];
    if ( _numberFiled.text.length > 4 ){
        _numberFiled.text = [_numberFiled.text substringToIndex:4];
    }
    
    if ([normalizePhone hasPrefix:@"+86"]){
        if (normalizePhone.length >= 12 && normalizePhone.length <= 14){
            sureButton.enabled = YES;
        }else{
            sureButton.enabled = NO;
        }
    }else{
        sureButton.enabled = NO;
    }
}

- (void)cancelButtonAction{
    if ( [_numberFiled isFirstResponder] )
        [_numberFiled resignFirstResponder];
    [self removeFromSuperview];
    [_delegate cancelButtonAction];
}

- (void)sureButtonAction{
    if ( [_numberFiled isFirstResponder] )
        [_numberFiled resignFirstResponder];
    [self removeFromSuperview];
    [_delegate sureButtonAction:[NSString stringWithFormat:@"%@%@",_numberFiled.text,_number]];
}

#pragma mark keyboardShownObserverSelecter


- (void) keyboardWillBeShown:(NSNotification *) notification
{
    if ([_numberFiled isFirstResponder]){
        NSDictionary *userInfo = [notification userInfo];
        CGSize kbSize = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
        if (kbSize.height <= 0){
            return;
        }
        CGRect oldFrame = boardView.frame;
        float posY = (TPScreenHeight() - kbSize.height - oldFrame.size.height)/2;
        
        NSNumber *animationDurationNumber = (NSNumber *)[userInfo objectForKey:@"UIKeyboardAnimationDurationUserInfoKey"];
        CGFloat animationDuration = 0.0f;
        animationDuration = [animationDurationNumber floatValue];
        [UIView animateWithDuration:animationDuration animations:^{
            boardView.frame = CGRectMake(oldFrame.origin.x, posY, oldFrame.size.width, oldFrame.size.height);
        }];
    }
}

- (void) keyboardWillBeHidden:(NSNotification *) notification
{
    if ([_numberFiled isFirstResponder]){
        NSDictionary *userInfo = [notification userInfo];
        CGSize kbSize = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
        if (kbSize.height <= 0){
            return;
        }
        CGRect oldFrame = boardView.frame;
        NSNumber *animationDurationNumber = (NSNumber *)[userInfo objectForKey:@"UIKeyboardAnimationDurationUserInfoKey"];
        CGFloat animationDuration = 0.0f;
        animationDuration = [animationDurationNumber floatValue];
        [UIView animateWithDuration:animationDuration animations:^{
            boardView.frame = CGRectMake(oldFrame.origin.x, (TPScreenHeight()-170)/2, oldFrame.size.width, oldFrame.size.height);
        }];
    }
}


-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

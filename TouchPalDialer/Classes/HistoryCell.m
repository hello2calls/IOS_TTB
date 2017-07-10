//
//  HistoryCell.m
//  TouchPalDialer
//
//  Created by by.huang on 2017/7/9.
//
//

#import "UILabel+ContentSize.h"
#import "HistoryCell.h"

@interface HistoryCell ()

@property (strong, nonatomic) UILabel *phoneLabel;

@property (strong, nonatomic) UILabel *timeLabel;

@property (strong, nonatomic) UILabel *minuteLabel;

@property (strong, nonatomic) UILabel *priceLabel;

@property (strong, nonatomic) UILabel *statuLabel;

@end

@implementation HistoryCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if(self == [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        [self initView];
    }
    return self;
}

-(void)initView{
    self.backgroundColor = [UIColor whiteColor];
    self.frame = CGRectMake(0, 0, TPScreenWidth(), 100);
    
    _phoneLabel = [[UILabel alloc]init];
    _phoneLabel.textColor = [UIColor blackColor];
    _phoneLabel.font = [UIFont systemFontOfSize:14.0f];
    [self addSubview:_phoneLabel];
    
    _timeLabel = [[UILabel alloc]init];
    _timeLabel.textColor = [UIColor grayColor];
    _timeLabel.font = [UIFont systemFontOfSize:14.0f];
    [self addSubview:_timeLabel];
    
    _minuteLabel = [[UILabel alloc]init];
    _minuteLabel.textColor = [UIColor blackColor];
    _minuteLabel.font = [UIFont systemFontOfSize:16.0f];
    [self addSubview:_minuteLabel];
    
    _priceLabel = [[UILabel alloc]init];
    _priceLabel.textColor = [UIColor blackColor];
    _priceLabel.font = [UIFont systemFontOfSize:14.0f];
    [self addSubview:_priceLabel];
    
    _statuLabel = [[UILabel alloc]init];
    _statuLabel.textColor = [UIColor grayColor];
    _statuLabel.font = [UIFont systemFontOfSize:14.0f];
    [self addSubview:_statuLabel];
    
    
    UIView *view = [[UIView alloc]init];
    view.backgroundColor = [UIColor lightGrayColor];
    view.frame = CGRectMake(0, 79, TPScreenWidth(), 1);
    [self addSubview:view];

}

-(void)setData : (HistoryModel*)model
{
    _phoneLabel.text = model.phone;
    _phoneLabel.frame = CGRectMake(20, 20, _phoneLabel.contentSize.width, _phoneLabel.contentSize.height);
    
    _timeLabel.text = model.paid_at;
    _timeLabel.frame = CGRectMake(20, 40, _timeLabel.contentSize.width, _timeLabel.contentSize.height);

    _minuteLabel.text = [NSString stringWithFormat:@"充值 %@分钟",model.minutes];
    _minuteLabel.frame = CGRectMake(60+_phoneLabel.contentSize.width, 20, _minuteLabel.contentSize.width, _minuteLabel.contentSize.height);
    
    float fee = [model.fee floatValue];
    _priceLabel.text = [NSString stringWithFormat:@"¥ %.2f",fee];
    _priceLabel.frame = CGRectMake(TPScreenWidth() - _priceLabel.contentSize.width - 20, 20, _priceLabel.contentSize.width, _priceLabel.contentSize.height);
    
    int statu  =  [model.charged intValue];
    if(statu == 1){
        _statuLabel.text =@"充值成功";
    }else{
        _statuLabel.text =@"充值失败";
    }
    _statuLabel.frame = CGRectMake(TPScreenWidth() - _statuLabel.contentSize.width - 20, 40, _statuLabel.contentSize.width, _statuLabel.contentSize.height);

}



+(NSString *)identify{
    
    return @"HistoryCell";
}


@end

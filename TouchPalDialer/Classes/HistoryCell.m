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
    self.frame = CGRectMake(0, 0, TPScreenWidth(), 80);
    
    _phoneLabel = [[UILabel alloc]init];
    _phoneLabel.textColor = [UIColor blackColor];
    _phoneLabel.font = [UIFont systemFontOfSize:13.0f];
    [self addSubview:_phoneLabel];

}

-(void)setData : (HistoryModel*)model
{
    _phoneLabel.text = model.phone;
    _phoneLabel.frame = CGRectMake(20, 20, _phoneLabel.contentSize.width, _phoneLabel.contentSize.height);
    
}



+(NSString *)identify{
    
    return @"HistoryCell";
}


@end

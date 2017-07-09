//
//  HistoryCell.m
//  TouchPalDialer
//
//  Created by by.huang on 2017/7/9.
//
//

#import "HistoryCell.h"

@implementation HistoryCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if(self == [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        [self initView];
    }
    return self;
}

-(void)initView{

}


+(NSString *)identify{
    
    return @"HistoryCell";
}


@end

//
//  SelectSingleView.m
//  TouchPalDialer
//
//  Created by game3108 on 16/4/13.
//
//

#import "SelectSingleView.h"
#import "TPDialerResourceManager.h"

#define LABEL_TAG 2001

@interface SelectSingleView()<UITableViewDelegate,UITableViewDataSource>{
    NSInteger _rowNumber;
    NSArray *_selectArray;
}

@end

@implementation SelectSingleView

- (instancetype)initWithFrame:(CGRect)frame andSelectArray:(NSArray *)selectArray{
    self = [super initWithFrame:frame];
    if (self){
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
        
        _rowNumber = selectArray.count;
        _selectArray = selectArray;
        NSInteger selectRowNumber = _rowNumber;
        if (_rowNumber > 5){
            selectRowNumber = 5;
        }
        
        CGFloat tableHeight = 56*selectRowNumber + 78;
        UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(40, (frame.size.height-tableHeight)/2, frame.size.width - 80, tableHeight)];
        tableView.layer.cornerRadius = 4.0f;
        tableView.layer.masksToBounds = YES;
        tableView.rowHeight = 56;
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.backgroundColor = [UIColor whiteColor];
        [self addSubview:tableView];
        
    }
    return self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _rowNumber;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdentifier = @"select_single_view";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    NSInteger row = indexPath.row;
    
    if ( cell ){
        UILabel *label = [cell viewWithTag:LABEL_TAG];
        label.text = _selectArray[row][@"phone"];
    }else{
        cell = [[UITableViewCell alloc]initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 56)];
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 15, tableView.frame.size.width, 16)];
        label.tag = LABEL_TAG;
        label.backgroundColor = [UIColor whiteColor];
        label.text = _selectArray[row][@"phone"];
        label.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_800"];
        label.font = [UIFont systemFontOfSize:16];
        label.textAlignment = NSTextAlignmentCenter;
        [cell.contentView addSubview:label];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 78;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 78)];
    view.backgroundColor = [UIColor whiteColor];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 30, tableView.frame.size.width, 18)];
    label.backgroundColor = [UIColor whiteColor];
    label.text = _selectArray[0][@"name"];
    label.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_800"];
    label.font = [UIFont boldSystemFontOfSize:18];
    label.textAlignment = NSTextAlignmentCenter;
    [view addSubview:label];
    
    UIView *bottomLine = [[UIView alloc]initWithFrame:CGRectMake(0, 77, tableView.frame.size.width, 1)];
    bottomLine.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_150"];
    [view addSubview:bottomLine];
    
    return view;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [_delegate select:_selectArray[indexPath.row]];
    [self removeFromSuperview];
}

@end

//
//  TestViewController.m
//  TouchPalDialer
//
//  Created by weyl on 16/9/21.
//
//

#import "TestViewController.h"
#import "TPDLib.h"
#import <Masonry.h>

// 只在此页面用到的自定义控件，不要写到外面，就写在controller对应的.m文件底下
@interface CustomView : UIView
@property (nonatomic, strong) UILabel* subviewA;
@end

@implementation CustomView

-(instancetype)init{
    
}

@end


@interface TestViewController ()
// 外面不需要的属性，直接写在.m文件里。不要用花括号和下划线那种
@property (nonatomic, strong) CustomView* viewB;

// 如果vc中有tableView，一定要单独定义一个NSArray作为dataSource
@property (nonatomic, strong) UITableView* table;
@property (nonatomic, strong) NSArray* tableData;

// 所有的属性，除了需要copy的block，只有strong和非strong。 非strong的不要写weak
//@property (nonatomic, strong) UITableView* table;
//@property (nonatomic) NSArray* tableData;

@end

//以下反面教材
//@interface TestViewController (){
//    UITableView* _table;
//    NSArray* _tableData;
//}
//@end


@implementation TestViewController

// 标准的异步加载UI代码
-(void)reloadData{
    
    // no perform
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        // 处理耗时操作的代码块...
        
        self.tableData = @[];
        //通知主线程刷新
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.table reloadData];
            
        });
        
    });
}


-(void)viewDidLoad{
    [super viewDidLoad];

    // 第一部分，初始化
    UILabel* a = [[UILabel tpd_commonLabel] tpd_withText:@"c" color:[UIColor blackColor]];
    a.backgroundColor = [UIColor redColor];
    UILabel* b = [[UILabel tpd_commonLabel] tpd_withText:@"d" color:[UIColor blackColor]];
    UILabel* c = [[UILabel tpd_commonLabel] tpd_withText:@"e" color:[UIColor blackColor]];
    

    // 第二部分，addview
    [self.view addSubview:a];
    [self.view addSubview:b];
    [self.view addSubview:c];
    
    
    // 第三部分, 约束
    [a makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [b makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [c makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
}

#pragma mark UITableView代理方法

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

        NSObject* item = self.tableData[indexPath.row];
    
        UITableViewCell* cell = [[UITableViewCell tpd_tableViewCellStyleImageLabel2:@[@"", @"", @""] action:^(id sender) {
            
        } reuseId:@""] tpd_withSeperateLine].cast2UITableViewCell;
    
        [cell.tpd_label1 updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(cell.tpd_img1.left).offset(22);
            make.bottom.equalTo(cell.centerY);
        }];
        return cell;

    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tableData.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 66;
}



#pragma mark 帮助方法


@end

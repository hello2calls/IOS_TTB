//
//  TPDSuperSearchViewController.m
//  TouchPalDialer
//
//  Created by H L on 2016/12/19.
//
//
#import "SectionSearch.h"
#import "LocalStorage.h"
#import "SeattleFeatureExecutor.h"
#import "YellowPageWebViewController.h"
#import "AllServiceViewController.h"
#import "TPDSuperSearchViewController.h"
#import "TPDLib.h"
#import <Masonry.h>
#import <BlocksKit.h>
#define kBlue500Color [UIColor colorWithRed:3/255.f green:169/255.f blue:244/255.f alpha:1]
#define kBlueUColor   [UIColor colorWithRed:41/255.f green:182/255.f blue:246/255.f alpha:1]
#define kGray900Color [UIColor colorWithRed:26/255.f green:26/255.f blue:26/255.f alpha:1]
#define kGray600Color [UIColor colorWithRed:102/255.f green:102/255.f blue:102/255.f alpha:1]
#define kGray400Color [UIColor colorWithRed:153/255.f green:153/255.f blue:153/255.f alpha:1]
#define kGray100Color [UIColor colorWithRed:238/255.f green:238/255.f blue:238/255.f alpha:1]


@interface TPDSearch : UISearchBar<UITextFieldDelegate>

@end

@implementation TPDSearch

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.placeholder = NSLocalizedString(@"search", @"");
        
        // 通过init初始化的控件大多都没有尺寸
        self.backgroundImage = [self imageWithColor:[UIColor clearColor] size:self.bounds.size];
        self.backgroundColor = [UIColor clearColor];
        
        UITextField * searchField = [self valueForKey:@"_searchField"];
        searchField.delegate = self;
        searchField.clearButtonMode = UITextFieldViewModeWhileEditing;
        searchField.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:.9];
        searchField.layer.cornerRadius = 14;
        searchField.layer.masksToBounds = YES;
        
        //放大镜
        //        [self setImage:[UIImage imageNamed:@"icon@3x"]
        //            forSearchBarIcon:UISearchBarIconSearch
        //                        state:UIControlStateNormal];
    }
    return self;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    self.text = @"";
    return YES;

}
//取消searchbar背景色
- (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size
{
    CGRect rect = CGRectMake(0, 0,[UIScreen mainScreen].bounds.size.width, 44);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
+(instancetype)searchBar
{
    return [[self alloc] init];
}


@end



@interface TPDSuperSearchViewController ()<UISearchBarDelegate>

@property (nonatomic, strong) TPDSearch *searchBar;
@property (nonatomic, strong) UIScrollView *backScrollView;


@end

@implementation TPDSuperSearchViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.searchBar.text = @"";
    

}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    //head view
    UIView *headView = [UIView new];
    headView.backgroundColor = kBlue500Color;
    self.searchBar = [TPDSearch new];
    self.searchBar.backgroundColor = [UIColor clearColor];
    self.searchBar.delegate = self;
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cancelButton setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
    [cancelButton addBlockEventWithEvent:UIControlEventTouchUpInside withBlock:^{
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    
    self.backScrollView = [UIScrollView new];
    UITapGestureRecognizer *geture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(gesture)];
    [self.backScrollView addGestureRecognizer:geture];
    UILabel *tag = [UILabel new];
    tag.text = @"热门服务";
    tag.textColor = kGray400Color;
    tag.font = [UIFont systemFontOfSize:16.f];
    
    UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [moreButton setTitleColor:kGray400Color forState:UIControlStateNormal];
    [moreButton setTitle:@"更多>>" forState:UIControlStateNormal];
    moreButton.titleLabel.font = [UIFont systemFontOfSize:12.f];
    [moreButton addBlockEventWithEvent:UIControlEventTouchUpInside withBlock:^{
        [self.navigationController pushViewController:[AllServiceViewController new] animated:YES];
    }];
    
    UIView *separateView = [UIView new];
    separateView.backgroundColor = kGray100Color;
 
    UILabel *tag2 = [UILabel new];
    tag2.text = @"常用号码";
    tag2.textColor = kGray400Color;
    tag2.font = [UIFont systemFontOfSize:16.f];

    //add subview
    [self.view addSubview:headView];
    [headView addSubview:self.searchBar];
    [headView addSubview:cancelButton];
    [self.view addSubview:self.backScrollView];
    [self.backScrollView addSubview:tag];
    [self.backScrollView addSubview:moreButton];
    [self.backScrollView addSubview:separateView];
    [self.backScrollView addSubview:tag2];
   
    //layout
    [headView makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.width.equalTo(self.view);
        make.height.equalTo(64);
        
    }];
    [self.searchBar makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(headView).offset(20);
        make.right.equalTo(headView).offset(-54);
        make.left.equalTo(headView);
        make.height.equalTo(44);
    }];
    [cancelButton makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(headView);
        make.left.equalTo(self.searchBar.right);
        make.top.equalTo(headView).offset(20);
        make.height.equalTo(44);

    }];
    [self.backScrollView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(headView.bottom);
        make.width.equalTo(self.view);
        make.left.equalTo(self.view);
        make.height.equalTo(self.view).offset(-64);
    }];
    
    [tag makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.backScrollView).offset(30);
        make.left.equalTo(self.backScrollView).offset(20);
    }];
    [moreButton makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(headView).offset(-16);
        make.top.equalTo(self.backScrollView).offset(20);
        make.height.equalTo(40);
    }];
    [separateView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(tag.bottom).offset(125);
        make.left.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-16);
        make.height.equalTo(.7);
    }];
    [tag2 makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(separateView.bottom).offset(30);
        make.left.equalTo(self.view).offset(20);
    }];
    
    
    NSArray *iconArray = @[@"1",@"5",@"k",@"2",@"4"];
    NSArray *fontArray = @[@"iPhoneIcon5",@"iPhoneIcon5",@"iPhoneIcon6",@"iPhoneIcon5",@"iPhoneIcon5"];

    NSArray *textArray = @[@"查快递",@"话费流量",@"充Q币",@"违章代缴",@"水电煤"];
   
    //service button
    CGFloat buttonWidth = self.view.tp_width / textArray.count;
    for (int i = 0 ; i < textArray.count; i ++ ) {
        UIButton *serviceButton = [UIButton tpd_buttonStyleVerticalLabel2:@[iconArray[i],textArray[i]] withBlock:^(id sender) {
 
            [self JumpTopWebByCTU:i];
        }];
        serviceButton.backgroundColor = [UIColor whiteColor];
        serviceButton.tpd_text1.layer.borderColor = kBlueUColor.CGColor;
        serviceButton.tpd_text1.layer.borderWidth = 1.f;
        serviceButton.tpd_text1.layer.cornerRadius = 25;
        serviceButton.tpd_text1.layer.masksToBounds = YES;
        serviceButton.tpd_text1.text = iconArray[i];
        serviceButton.tpd_text1.textColor = kBlueUColor;
        serviceButton.tpd_text1.font = [UIFont fontWithName:fontArray[i] size:30.f];
        serviceButton.tpd_text2.textColor = kGray600Color;
        serviceButton.tpd_text2.text = textArray[i];
        
        [self.backScrollView addSubview:serviceButton];
        [serviceButton updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(i * buttonWidth);
            make.top.equalTo(tag.bottom).offset(20);
            make.width.equalTo(buttonWidth);
            make.height.equalTo(75);
        }];
        [serviceButton.tpd_text1 updateConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(50);
        }];
    }
    
    /*
     YellowPageWebViewController *controller = [[YellowPageWebViewController alloc] init];
     
     controller.url_string = @"http://dialer.cdn.cootekservice.com/web/internal/activities/family-num-bind/
     */
    
    NSArray *recommendArray = [self formatArray];

    buttonWidth = self.view.tp_width / ((NSArray *)recommendArray[0]).count;
    //recommend button
    for (int i = 0 ; i < recommendArray.count; i ++) {
        NSArray *contentArray = recommendArray[i];
        for (int j = 0 ; j < ((NSArray *)recommendArray[i]).count ; j ++) {
           
            UIButton *recommendButton = [UIButton buttonWithType:UIButtonTypeSystem];
            [recommendButton setTitle:contentArray[j][@"name"] forState:UIControlStateNormal];
            recommendButton.titleLabel.font = [UIFont systemFontOfSize:16.f];
            [recommendButton setTitleColor:kGray900Color forState:UIControlStateNormal];
            [recommendButton addBlockEventWithEvent:UIControlEventTouchUpInside withBlock:^{
                [self JumpTopWebByCT:i * 3 + j];

            }];
            [self.backScrollView addSubview:recommendButton];
            
            
            [recommendButton makeConstraints:^(MASConstraintMaker *make) {
                make.height.equalTo(40);
                make.width.equalTo(buttonWidth);
                make.top.equalTo(tag2.bottom).offset(i * 40 + 10);
                make.left.equalTo(self.backScrollView).offset(j * buttonWidth);
            }];
            if (j == ((NSArray *)recommendArray[i]).count - 1 && i == recommendArray.count - 1) {
                [self.backScrollView updateConstraints:^(MASConstraintMaker *make) {
                    make.bottom.equalTo(recommendButton);
                }];
            }
            
        }
    }

    [self.searchBar becomeFirstResponder];

  
}

- (NSArray *)formatArray {
    
    NSArray *nameArray = @[@"银行",@"理财",@"保险",@"打车",@"代驾",@"租车",@"外卖",@"机票",@"酒店",@"公共",@"报警救援",@"售后"];
     NSMutableArray *result = [NSMutableArray new];
    
    for (int i = 0 ; i < 4; i ++ ) {
        NSMutableArray *content = [NSMutableArray new];
        for (int j = 0;  j < 3 ; j ++) {
            NSDictionary *dic = @{@"name":nameArray[i * 3 + j]};
            [content addObject:dic];
        }
        [result addObject:content];
       
    }
    return result;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}
- (void)gesture {
    [self.view endEditing:YES];
}

#pragma mark - searchbar delegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {

    
//    searchBar.text = @"";
//    [self.view endEditing:YES];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {

    [LocalStorage setItemForKey:@"search_term" andValue:searchBar.text];
    SectionSearch* item2 = [SectionSearch new];
    item2.ctUrl = [CTUrl new];
    item2.ctUrl.needTitle = YES;
    item2.ctUrl.url = @"http://search.cootekservice.com/page/search.html";
    NSArray *array = @[@"_lat",@"_lng",@"_city",@"search_term"];
    item2.ctUrl.nativeParams = array;
    [item2.ctUrl startWebView];
    
}

#pragma mark - helper 


#define baseUrl @"https://search.cootekservice.com/page/navigate.html?classify=%@&city=%@&v=3&token=%@"

- (void)JumpTopWebByCT:(NSInteger)tag {
    
    CTUrl *ctUrl = [CTUrl new];
    
    NSArray *nameArray = @[@"classify=银行",@"classify=投资理财",@"classify=保险",@"classify=打车",@"classify=代驾",@"classify=租车",@"classify=精品外卖",@"classify=机票预订",@"classify=酒店",@"classify=公共服务",@"classify=报警救援",@"classify=售后服务"];

    NSArray *urlArray = @[@"http://search.cootekservice.com/page/navigate.html",
                          @"http://search.cootekservice.com/page/navigate.html",
                          @"http://search.cootekservice.com/page/navigate.html",
                          @"http://search.cootekservice.com/page/navigate.html",
                          @"http://search.cootekservice.com/page/navigate.html",
                          @"http://search.cootekservice.com/page/navigate.html",
                          @"http://search.cootekservice.com/page/delivery_new.html",
                          @"http://search.cootekservice.com/page/navigate.html",
                          @"http://search.cootekservice.com/page/navigate.html",
                          @"http://search.cootekservice.com/page/navigate.html",
                          @"http://search.cootekservice.com/page/navigate.html",
                          @"http://search.cootekservice.com/page/navigate.html"];

//    for (int i = 0 ; i < 12; i ++) {
        switch (tag) {
            case 0:
            {
                NSArray *temp  = @[@"_city"];
                ctUrl.params = nameArray[tag];
                ctUrl.serviceId = @"yinhang";
                ctUrl.url = urlArray[tag];
                ctUrl.nativeParams = temp;
            }
                break;

            case 1:
            {
                NSArray *temp  = @[@"_city"];
                ctUrl.params = nameArray[tag];
                ctUrl.serviceId = @"touzilicai";
                ctUrl.url = urlArray[tag];
                ctUrl.nativeParams = temp;
            }
                break;
                
            case 2:
            {
                NSArray *temp  = @[@"_city"];
                ctUrl.params = nameArray[tag];
                ctUrl.serviceId = @"baoxian";
                ctUrl.url = urlArray[tag];
                ctUrl.nativeParams = temp;
            }

                break;
                
            case 3:
            {
                NSArray *temp  = @[@"_city"];
                ctUrl.params = nameArray[tag];
                ctUrl.serviceId = @"chuzuche";
                ctUrl.url = urlArray[tag];
                ctUrl.nativeParams = temp;
            }
 
                break;
                
            case 4:
            {
                NSArray *temp  = @[@"_city"];
                ctUrl.params = nameArray[tag];
                ctUrl.serviceId = @"daijia";
                ctUrl.url = urlArray[tag];
                ctUrl.nativeParams = temp;
            }
                
                break;
                
              case 5:
            {
                NSArray *temp  = @[@"_city"];
                ctUrl.params = nameArray[tag];
                ctUrl.serviceId = @"zuche";
                ctUrl.url = urlArray[tag];
                ctUrl.nativeParams = temp;
            }

                break;
                
            case 6:
            {
                NSArray *temp  = @[@"_city",
                                   @"_lat",
                                   @"_lng"];
                ctUrl.params = nameArray[tag];
                ctUrl.serviceId = @"jingpinwaimai";
                ctUrl.url = urlArray[tag];
                ctUrl.nativeParams = temp;
            }
  
                break;
            case 7:
            {
                NSArray *temp  = @[@"_city"];
                ctUrl.params = nameArray[tag];
                ctUrl.serviceId = @"hangkonggongsi";
                ctUrl.url = urlArray[tag];
                ctUrl.nativeParams = temp;
            }
                

                break;

                
            case 8:
            {
                NSArray *temp  = @[@"_city"];
                ctUrl.params = nameArray[tag];
                ctUrl.serviceId = @"jiudian";
                ctUrl.url = urlArray[tag];
                ctUrl.nativeParams = temp;
            }
                break;
                
            case 9:
            {
                NSArray *temp  = @[@"_city"];
                ctUrl.params = nameArray[tag];
                ctUrl.serviceId = @"gonggongfuwu";
                ctUrl.url = urlArray[tag];
                ctUrl.nativeParams = temp;
            }

                break;
                
            case 10:
            {
                NSArray *temp  = @[@"_city"];
                ctUrl.params = nameArray[tag];
                ctUrl.serviceId = @"baojingjiuyuan";
                ctUrl.url = urlArray[tag];
                ctUrl.nativeParams = temp;
            }
  
                break;
                
            case 11:
            {
                NSArray *temp  = @[@"_city"];
                ctUrl.params = nameArray[tag];
                ctUrl.serviceId = @"pinpaishouhou";
                ctUrl.url = urlArray[tag];
                ctUrl.nativeParams = temp;
            }
 
                break;
                

            default:
                break;
        }
    ctUrl.needTitle = YES;
    ctUrl.needWrap = YES;
    [ctUrl startWebView];


}
- (void)JumpTopWebByCTU:(NSInteger)tag {
    

    CTUrl *ctUrl = [CTUrl new];
    
    NSArray *nameArray = @[@"self_source=index_native",@"",@"",@"",@""];
    
    NSArray *urlArray = @[@"http://search.cootekservice.com/page/express.html",
                          @"http://search.cootekservice.com/page/mobilerecharge.html",
                          @"http://chubao.m.7881.com",
                          @"http://search.cootekservice.com/page/violationList.html",
                          @"http://search.cootekservice.com/page_v3/life_recharge.html"];
    
    //    for (int i = 0 ; i < 12; i ++) {
    switch (tag) {
        case 0:
        {
            ctUrl.params = nameArray[tag];
            ctUrl.serviceId = @"express";
            ctUrl.url = urlArray[tag];
        }
            break;
            
        case 1:
        {
            ctUrl.params = nameArray[tag];
            ctUrl.serviceId = @"recharge";
            ctUrl.url = urlArray[tag];
        }
            break;
            
        case 2:
        {
            ctUrl.params = nameArray[tag];
            ctUrl.serviceId = @"chongqiubi";
            ctUrl.url = urlArray[tag];
        }
            
            break;
            
        case 3:
        {
            ctUrl.params = nameArray[tag];
            ctUrl.serviceId = @"violation";
            ctUrl.url = urlArray[tag];
        }
            
            break;
            
        case 4:
        {
            NSArray *temp  = @[@"_city"];
            ctUrl.params = nameArray[tag];
            ctUrl.serviceId = @"life_recharge_gd";
            ctUrl.url = urlArray[tag];
            ctUrl.nativeParams = temp;
        }
            
            break;
            
            
        default:
            break;
    }
    ctUrl.needTitle = YES;
    ctUrl.needWrap = YES;
    [ctUrl startWebView];

}

@end

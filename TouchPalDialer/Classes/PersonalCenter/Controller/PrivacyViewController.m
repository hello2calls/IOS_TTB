//
//  PrivacyViewController.m
//  TouchPalDialer
//
//  Created by by.huang on 2017/7/13.
//
//

#import "PrivacyViewController.h"
#import "HeaderBar.h"
#import "TPHeaderButton.h"
#import "UILabel+TPDExtension.h"
#import "TouchPalDialerAppDelegate.h"
#import "TPDialerResourceManager.h"
@interface PrivacyViewController ()

@end

@implementation PrivacyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[TPDialerResourceManager getColorForStyle:@"tp_color_grey_50"]];

    [self initHeader];
    [self initBody];
}

-(void)initHeader
{
    HeaderBar *headerBar = [[HeaderBar alloc] initHeaderBar];
    [headerBar setSkinStyleWithHost:self forStyle:@"defaultHeaderView_style"];
    [self.view addSubview:headerBar];
    
    TPHeaderButton *gobackBtn = [[TPHeaderButton alloc] initLeftBtnWithFrame:CGRectMake(0, 0, 50, 45)];
    [gobackBtn setSkinStyleWithHost:self forStyle:@"default_backButton_style"];
    [gobackBtn addTarget:self action:@selector(gobackBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:gobackBtn];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((TPScreenWidth()-200)/2, TPHeaderBarHeightDiff(), 200, 45)];
    [titleLabel setSkinStyleWithHost:self forStyle:@"defaultUILabel_style"];
    titleLabel.font = [UIFont systemFontOfSize:FONT_SIZE_2_5];
    titleLabel.text = NSLocalizedString(@"privacy_title", @"");
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [headerBar addSubview:titleLabel];
}

- (NSString *)getCurrentLanguage
{
    NSArray *languages = [NSLocale preferredLanguages];
    NSString *currentLanguage = [languages objectAtIndex:0];
    return currentLanguage;
}

-(void)initBody{

    NSString *languageStr = [self getCurrentLanguage];
    NSString *filePath;
    if([languageStr localizedStandardContainsString:@"en"]){
        filePath=[[NSBundle mainBundle] pathForResource:@"privacy_en"ofType:@"txt"];
    }else{
        filePath=[[NSBundle mainBundle] pathForResource:@"privacy"ofType:@"txt"];
    }
    NSError *error;
    NSString *content = [[NSString alloc]initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
    UIScrollView *scrollView = [[UIScrollView alloc]init];
    scrollView.frame = CGRectMake(0, 45 + TPHeaderBarHeightDiff(), TPScreenWidth(), TPScreenHeight()- (45 + TPHeaderBarHeightDiff()));
    [self.view addSubview:scrollView];
    
    
    UILabel *label = [[UILabel alloc]init];
    CGSize labelSize = {0, 0};
    labelSize = [content sizeWithFont:[UIFont systemFontOfSize:14]
                     constrainedToSize:CGSizeMake(TPScreenWidth()-20, 5000)
                         lineBreakMode:NSLineBreakByCharWrapping];
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByCharWrapping;
    label.font = [UIFont systemFontOfSize:14.0f];
    [label setTextColor:[UIColor blackColor]];
    [label setText:content];
    label.frame = CGRectMake(10, 10, TPScreenWidth()-20, labelSize.height + 20);

    [scrollView addSubview:label];
    
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    scrollView.contentSize = CGSizeMake(TPScreenWidth(), labelSize.height + 20);

}

-(void)gobackBtnPressed
{
    [TouchPalDialerAppDelegate popViewControllerWithAnimated : YES];
}

@end

//
//  ViewController.m
//  TPDialerAdvancedTest
//
//  Created by Elfe Xu on 12-10-9.
//  Copyright (c) 2012年 Elfe Xu. All rights reserved.
//

#import "ViewController.h"
#import "TPDialerAdvanced.h"
#import "Engine.h"

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    numberInput = [[[UITextField alloc] initWithFrame:CGRectMake(10, 10, 300, 30)] autorelease];
    numberInput.text = @"";
    numberInput.backgroundColor = [UIColor whiteColor];
    runButton = [[[UIButton alloc] initWithFrame:CGRectMake(10, 42, 300, 30)] autorelease];
    [runButton setTitle:@"Run" forState:UIControlStateNormal];
    runButton.backgroundColor = [UIColor blackColor];
    outputLabel1 = [[[UILabel alloc] initWithFrame:CGRectMake(10, 75, 300, 50)] autorelease];
    outputLabel1.backgroundColor = [UIColor whiteColor];
    outputLabel1.numberOfLines = 2;
    
    outputLabel2 = [[[UILabel alloc] initWithFrame:CGRectMake(10, 126, 300, 50)] autorelease];
    outputLabel2.backgroundColor = [UIColor whiteColor];
    outputLabel2.numberOfLines = 2;
    
    outputLabel3 = [[[UILabel alloc] initWithFrame:CGRectMake(10, 177, 300, 50)] autorelease];
    outputLabel3.backgroundColor = [UIColor whiteColor];
    outputLabel3.numberOfLines = 2;

    
    [self.view addSubview:numberInput];
    [self.view addSubview:runButton];
    [self.view addSubview:outputLabel1];
    [self.view addSubview:outputLabel2];
    [self.view addSubview:outputLabel3];
    
    [runButton addTarget:self action:@selector(query) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) query {
    Engine* engine = [[[Engine alloc] initWithNumber:numberInput.text] autorelease];
    [engine queryLocation];
    outputLabel1.text = engine.text1;
    outputLabel2.text = engine.text2;
    outputLabel3.text = engine.text3;
    [self performSelector:@selector(queryCallerId:) withObject:engine afterDelay:2];
}

- (void) queryCallerId:(Engine*) engine {
    [engine queryCallerId];
    outputLabel1.text = engine.text1;
    outputLabel2.text = engine.text2;
    outputLabel3.text = engine.text3;
}

@end

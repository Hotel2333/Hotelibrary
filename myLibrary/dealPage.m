//
//  dealPage.m
//  myLibrary
//
//  Created by 吕浩泰 on 2018/3/13.
//  Copyright © 2018年 吕浩泰. All rights reserved.
//

#import "dealPage.h"

@interface dealPage ()

@end

@implementation dealPage
- (void)viewWillAppear:(BOOL)animated{
    self.title = @"登记";
    (self.view).backgroundColor = [UIColor whiteColor];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    (self.navigationController.navigationBar).backgroundColor = [UIColor whiteColor];//白色
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;//且不透明
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    (self.navigationController.navigationBar).shadowImage = [UIImage new];
    
    
    UIImageView * logo = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"图标-登陆.png"]];
    logo.frame = CGRectMake(55, 125, 266, 66);
    [self.view addSubview:logo];
    
    CALayer * line = [CALayer layer];
    line.backgroundColor = [UIColor colorWithRed:0.592 green:0.592 blue:0.592 alpha:1].CGColor;
    line.frame = CGRectMake(50, 282, 270, 1);
    [self.view.layer addSublayer:line];
    
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(287, 249, 20, 25);
    [btn setBackgroundImage:[UIImage imageNamed:@"搜索2.png"] forState:UIControlStateNormal];
    [self.view addSubview:btn];
    
    UITextField * search = [[UITextField alloc]initWithFrame:CGRectMake(55, 248, 240, 28)];
    search.placeholder = @"输入内容以搜索";
    search.textAlignment = NSTextAlignmentLeft;
    search.font = [UIFont systemFontOfSize:20];
    [self.view addSubview:search];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

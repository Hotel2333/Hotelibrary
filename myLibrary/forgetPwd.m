//
//  forgetPwd.m
//  myLibrary
//
//  Created by 吕浩泰 on 2018/3/30.
//  Copyright © 2018年 吕浩泰. All rights reserved.
//

#import "forgetPwd.h"
#import "ViewController.h"
#import "User+CoreDataProperties.h"
#import <CoreData/CoreData.h>
@interface forgetPwd ()<UITextFieldDelegate>
@property(nonatomic, strong, readwrite)UIDatePicker * date;
@property(nonatomic, strong, readwrite)UITextField * birthdate;
@property(nonatomic, strong, readwrite)UITextField * name;
@property(nonatomic, strong, readwrite)UITextField * pwd;
@property(nonatomic, strong, readwrite)UITextField * pwdAgain;

@property(nonatomic, strong, readwrite)User * user;
@property(nonatomic, strong, readwrite)NSURL * modelURL;
@property(nonatomic, strong, readwrite)NSManagedObjectModel * mom;
@property(nonatomic, strong, readwrite)NSPersistentStoreCoordinator * psc;
@property(nonatomic, strong, readwrite)NSURL * path;
@property(nonatomic, strong, readwrite)NSManagedObjectContext * moc;
@end

@implementation forgetPwd
- (void)viewWillAppear:(BOOL)animated{
    self.view.backgroundColor = [UIColor whiteColor];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self managedObjectModel];
    [self documentDirectoryURL];
    [self persistentStoreCoordinator];
    [self context];
    
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(24, 30, 28 , 14);
    [btn setBackgroundImage:[UIImage imageNamed:@"取消.png"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(skip) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    UIImageView * logo = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"图标-登陆.png"]];
    logo.frame = CGRectMake(118, 85, 140, 35);
    [self.view addSubview:logo];
    
    
    //直线
    CALayer * lineOne = [CALayer layer];
    lineOne.backgroundColor = [UIColor colorWithRed:0.592 green:0.592 blue:0.592 alpha:1].CGColor;
    lineOne.frame = CGRectMake(40, 188, 300, 1);
    CALayer * lineTwo = [CALayer layer];
    lineTwo.backgroundColor = [UIColor colorWithRed:0.592 green:0.592 blue:0.592 alpha:1].CGColor;
    lineTwo.frame = CGRectMake(40, 240, 300, 1);
    CALayer * lineThree = [CALayer layer];
    lineThree.backgroundColor = [UIColor colorWithRed:0.592 green:0.592 blue:0.592 alpha:1].CGColor;
    lineThree.frame = CGRectMake(40, 292, 300, 1);
    CALayer * lineFour = [CALayer layer];
    lineFour.backgroundColor = [UIColor colorWithRed:0.592 green:0.592 blue:0.592 alpha:1].CGColor;
    lineFour.frame = CGRectMake(40, 292+52, 300, 1);
    [self.view.layer addSublayer:lineOne];
    [self.view.layer addSublayer:lineTwo];
    [self.view.layer addSublayer:lineThree];
    [self.view.layer addSublayer:lineFour];

    
    _name = [[UITextField alloc]initWithFrame:CGRectMake(40, 156, 200, 20)];
    _name.placeholder = @"请输入您的账号名";
    _name.borderStyle = UITextBorderStyleNone;
    _name.delegate = self;

    [self.view addSubview:_name];
    
    _pwd = [[UITextField alloc]initWithFrame:CGRectMake(40, 208, 200, 20)];
    _pwd.placeholder = @"请输入您的新密码";
    _pwd.borderStyle = UITextBorderStyleNone;
    _pwd.delegate = self;
    _pwd.secureTextEntry = YES;
    [self.view addSubview:_pwd];
    
    _pwdAgain = [[UITextField alloc]initWithFrame:CGRectMake(40, 260, 200, 20)];
    _pwdAgain.placeholder = @"请再次输入您的新密码";
    _pwdAgain.borderStyle = UITextBorderStyleNone;
    _pwdAgain.delegate = self;
    _pwdAgain.secureTextEntry = YES;
    [self.view addSubview:_pwdAgain];
    
    _birthdate = [[UITextField alloc]initWithFrame:CGRectMake(40, 260+52, 200, 20)];
    _birthdate.placeholder = @"请选择您的生日";
    _birthdate.borderStyle = UITextBorderStyleNone;
    _birthdate.delegate = self;
    [self.view addSubview:_birthdate];
    
    UIButton * btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn2.frame = CGRectMake(40, 545-52, 300, 40);
    [btn2 setBackgroundImage:[UIImage imageNamed:@"注册.png"] forState:UIControlStateNormal];
    [btn2 addTarget:self action:@selector(regis) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn2];
    
    [self showDataPicker];

}
- (void)skip{
    ViewController * view =[[ViewController alloc]init];
    [self presentViewController:view animated:YES completion:nil];
}

- (void)regis{
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"name LIKE %@",_name.text];
    request.predicate = predicate;
    NSArray * objs = [_moc executeFetchRequest:request error:nil];
    int objsNum = (int)objs.count;
    if(objsNum==0){
        UIAlertController * alertView = [UIAlertController alertControllerWithTitle:@"错误" message:@"没有找到该用户" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * action = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil];
        [alertView addAction:action];
        [self presentViewController:alertView animated:YES completion:nil];
    }else{
        User * obj = objs[0];//取得对象
        if([_birthdate.text isEqualToString:obj.birthday]){
            obj.password = _pwd.text;
            [_moc save:nil];
            UIAlertController * alertView = [UIAlertController alertControllerWithTitle:@"成功" message:@"密码修改成功" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction * action = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                ViewController * next = [[ViewController alloc]init];
                [self presentViewController:next animated:YES completion:nil];
            }];
            [alertView addAction:action];
            [self presentViewController:alertView animated:YES completion:nil];
        }else{
            UIAlertController * alertView = [UIAlertController alertControllerWithTitle:@"错误" message:@"生日信息输入错误" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction * action = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil];
            [alertView addAction:action];
            [self presentViewController:alertView animated:YES completion:nil];
        }
    }
}
- (void)showDataPicker{
    UIDatePicker * datePicker = [[UIDatePicker alloc]init];
    datePicker.locale = [NSLocale localeWithLocaleIdentifier:@"zh"];
    datePicker.datePickerMode = UIDatePickerModeDate;
    [datePicker setDate:[NSDate date] animated:YES];
    datePicker.maximumDate = [NSDate date];
    datePicker.backgroundColor = [UIColor colorWithRed:0.612 green:0.851 blue:0.365 alpha:0];
    datePicker.tintColor = [UIColor whiteColor];
    [datePicker addTarget:self action:@selector(datePick:) forControlEvents:UIControlEventValueChanged];
    
    self.date = datePicker;
    self.birthdate.inputView = datePicker;
}


- (void)datePick:(UIDatePicker *)datePicker{
    NSDateFormatter * forma = [[NSDateFormatter alloc]init];
    forma.dateFormat = @"yyyy年MM月dd日";
    NSString * dateStr = [forma stringFromDate:datePicker.date];//时间转字符串
    self.birthdate.text = dateStr;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    if([textField isEqual: self.pwdAgain]){
        if(![_pwd.text isEqualToString:_pwdAgain.text]){
            UIAlertController * alertView = [UIAlertController alertControllerWithTitle:@"密码错误" message:@"请重新输入密码" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction * action = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil];
            [alertView addAction:action];
            [self presentViewController:alertView animated:YES completion:nil];
        }
    }
}
- (NSManagedObjectModel *)managedObjectModel{
    if(!_mom){
        _modelURL = [[NSBundle mainBundle]URLForResource:@"myLibraryModel" withExtension:@"momd"];
        _mom = [[NSManagedObjectModel alloc]initWithContentsOfURL:_modelURL];
    }
    return _mom;
}
- (nullable NSURL *)documentDirectoryURL {
    return [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].firstObject;
}
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (!_psc) {
        // 创建 coordinator 需要传入 managedObjectModel
        _psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
        // 指定本地的 sqlite 数据库文件
        NSURL *sqliteURL = [[self documentDirectoryURL] URLByAppendingPathComponent:@"myLibrary.sqlite"];
        NSError *error;
        // 为 persistentStoreCoordinator 指定本地存储的类型，这里指定的是 SQLite
        [_psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:sqliteURL options:nil error:&error];
        if (error) {
            NSLog(@"falied to create persistentStoreCoordinator %@", error.localizedDescription);
        }
    }
    return _psc;
}
- (NSManagedObjectContext *)context {
    if (!_moc) {
        // 指定 context 的并发类型： NSMainQueueConcurrencyType 或 NSPrivateQueueConcurrencyType
        _moc = [[NSManagedObjectContext alloc ] initWithConcurrencyType:NSMainQueueConcurrencyType];
        _moc.persistentStoreCoordinator = self.persistentStoreCoordinator;
    }
    return _moc;
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

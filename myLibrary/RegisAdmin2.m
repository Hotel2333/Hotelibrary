//
//  RegisAdmin2.m
//  myLibrary
//
//  Created by 吕浩泰 on 2018/3/30.
//  Copyright © 2018年 吕浩泰. All rights reserved.
//

#import "RegisAdmin2.h"
#import "ViewController.h"
#import "Admin+CoreDataProperties.h"
#import <CoreData/CoreData.h>
@interface RegisAdmin2 ()<UITextFieldDelegate>
@property(nonatomic, strong, readwrite)UIDatePicker * date;
@property(nonatomic, strong, readwrite)UITextField * birthdate;
@property(nonatomic, strong, readwrite)UITextField * tid;
@property(nonatomic, strong, readwrite)UITextField * name;
@property(nonatomic, strong, readwrite)UITextField * age;
@property(nonatomic, strong, readwrite)UITextField * passwd;
@property(nonatomic, strong, readwrite)UITextField * passwdAgain;

@property(nonatomic, strong, readwrite)Admin * admin;
@property(nonatomic, strong, readwrite)NSURL * modelURL;
@property(nonatomic, strong, readwrite)NSManagedObjectModel * mom;
@property(nonatomic, strong, readwrite)NSPersistentStoreCoordinator * psc;
@property(nonatomic, strong, readwrite)NSURL * path;
@property(nonatomic, strong, readwrite)NSManagedObjectContext * moc;

@end

@implementation RegisAdmin2

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self managedObjectModel];
    [self documentDirectoryURL];
    [self persistentStoreCoordinator];
    [self context];
    
    /*
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(24, 30, 28 , 14);
    [btn setBackgroundImage:[UIImage imageNamed:@"取消.png"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(skip) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];*/
    
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
    lineFour.frame = CGRectMake(40, 344, 300, 1);
    CALayer * lineFive = [CALayer layer];
    lineFive.backgroundColor = [UIColor colorWithRed:0.592 green:0.592 blue:0.592 alpha:1].CGColor;
    lineFive.frame = CGRectMake(40, 396, 300, 1);
    [self.view.layer addSublayer:lineOne];
    [self.view.layer addSublayer:lineTwo];
    [self.view.layer addSublayer:lineThree];
    [self.view.layer addSublayer:lineFour];
    [self.view.layer addSublayer:lineFive];
    
    _tid = [[UITextField alloc]initWithFrame:CGRectMake(40, 156, 200, 20)];
    _tid.placeholder = @"请输入您的账号(纯数字)";
    _tid.borderStyle = UITextBorderStyleNone;
    _tid.delegate = self;
    //获取当前最大的id并加1
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"Admin"];
    NSArray * arr = [_moc executeFetchRequest:request error:nil];
    int large = 0;
    for(Admin * a in arr){
        int temp = [a.manager_id intValue];
        if(temp > large){
            large = temp;
        }
    }
    int lenght = (int)arr.count;
    if(lenght == 0){
        _tid.text = [NSString stringWithFormat:@"%d",1];
    }else{
        _tid.text = [NSString stringWithFormat:@"%d",large+1];
    }
    _tid.enabled = NO;
    [self.view addSubview:_tid];
    
    _name = [[UITextField alloc]initWithFrame:CGRectMake(40, 208, 200, 20)];
    _name.placeholder = @"请输入您的姓名";
    _name.borderStyle = UITextBorderStyleNone;
    _name.delegate = self;
    [self.view addSubview:_name];
    
    _birthdate = [[UITextField alloc]initWithFrame:CGRectMake(40, 312-52, 200, 20)];
    _birthdate.placeholder = @"请选择您的生日";
    _birthdate.borderStyle = UITextBorderStyleNone;
    _birthdate.delegate = self;
    [self.view addSubview:_birthdate];
    
    _passwd = [[UITextField alloc]initWithFrame:CGRectMake(40, 364-52, 200, 20)];
    _passwd.placeholder = @"请输入您的密码";
    _passwd.borderStyle = UITextBorderStyleNone;
    _passwd.delegate = self;
    _passwd.secureTextEntry = YES;
    [self.view addSubview:_passwd];
    
    _passwdAgain = [[UITextField alloc]initWithFrame:CGRectMake(40, 416-52, 200, 20)];
    _passwdAgain.placeholder = @"请再次输入您的密码";
    _passwdAgain.borderStyle = UITextBorderStyleNone;
    _passwdAgain.delegate = self;
    _passwdAgain.secureTextEntry = YES;
    [self.view addSubview:_passwdAgain];
    
    UIButton * btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn2.frame = CGRectMake(40, 545-52, 300, 40);
    [btn2 setBackgroundImage:[UIImage imageNamed:@"注册.png"] forState:UIControlStateNormal];
    [btn2 addTarget:self action:@selector(regis) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn2];
    
    [self showDataPicker];
    
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
- (void)regis{
    _admin= [NSEntityDescription insertNewObjectForEntityForName:@"Admin" inManagedObjectContext:_moc];
    _admin.manager_id= _tid.text;
    _admin.name = _name.text;
    _admin.password = _passwd.text;
    _admin.birthday = _birthdate.text;
    _admin.dept_name = [NSString stringWithFormat:@"部门待分配"];
    _admin.inBook = 0;
    _admin.inManager = 0;
    _admin.inUser = 0;
    _admin.isSenior = NO;
    
    NSDateFormatter * formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"yyyy年MM月dd日HH时mm分";
    NSString * dateTime = [formatter stringFromDate:[NSDate date]];
    _admin.reg_date = dateTime;
    
    NSFetchRequest * req = [NSFetchRequest fetchRequestWithEntityName:@"Admin"];
    NSPredicate * pre = [NSPredicate predicateWithFormat:@"name LIKE %@",_name.text];
    req.predicate = pre;
    NSArray * arr = [_moc executeFetchRequest:req error:nil];
    int arrNum = (int)arr.count;
    NSLog(@"名字为%@找到%d条记录",_name.text,arrNum);
    if(arrNum == 1){
        if([_moc save:nil]){
            UIAlertController * alertView = [UIAlertController alertControllerWithTitle:@"注册成功" message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction * action = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                //ViewController * view = [[ViewController alloc]init];
                //[self presentViewController:view animated:YES completion:nil];
                NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"Admin"];
                NSPredicate * predicate = [NSPredicate predicateWithFormat:@"manager_id LIKE %@",_adminID];
                request.predicate = predicate;
                NSArray * admins = [_moc executeFetchRequest:request error:nil];
                Admin * admin = admins[0];
                int inUser = admin.inUser;
                inUser++;
                admin.inUser = inUser;
                [_moc save:nil];
                NSLog(@"ID为%@的%@管理员注册成功",_tid.text,_name.text);
                [self.navigationController popViewControllerAnimated:YES];
                
            }];
            [alertView addAction:action];
            [self presentViewController:alertView animated:YES completion:nil];
        }
    }else{
        UIAlertController * warning = [UIAlertController alertControllerWithTitle:@"错误" message:@"该用户名已被占用" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * cancel = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleCancel handler:nil];
        [warning addAction:cancel];
        [self presentViewController:warning animated:YES completion:nil];
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

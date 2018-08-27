//
//  ViewController.m
//  myLibrary
//
//  Created by 吕浩泰 on 2018/3/13.
//  Copyright © 2018年 吕浩泰. All rights reserved.
//

#import "ViewController.h"
#import "bookPage2.h"
#import "borrow.h"
#import "minePage2.h"
#import "dealPage.h"
#import "minePage.h"
#import "userPage.h"
#import "bookPage.h"
#import "Regis.h"
#import "RegisAdmin.h"
#import "Admin+CoreDataProperties.h"
#import "User+CoreDataProperties.h"
#import "forgetPwd.h"
#import "forgetPwdAdmin.h"
#import "findPwd.h"
#import "findPwdAdmin.h"
#import <CoreData/CoreData.h>
//#import "User+CoreDataProperties.h"
#import "Admin+CoreDataProperties.m"
@interface ViewController ()<UITextFieldDelegate>{
    UITextField * UsrName;
    UITextField * passwd;
}
@property(nonatomic, strong, readwrite)Admin * admin;
@property(nonatomic, strong, readwrite)User * user;

@property(nonatomic, strong, readwrite)NSURL * modelURL;
@property(nonatomic, strong, readwrite)NSManagedObjectModel * mom;
@property(nonatomic, strong, readwrite)NSPersistentStoreCoordinator * psc;
@property(nonatomic, strong, readwrite)NSURL * path;
@property(nonatomic, strong, readwrite)NSManagedObjectContext * moc;
@property(nonatomic, strong, readwrite)NSFetchRequest * request;

@end



@implementation ViewController

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

- (void)viewWillAppear:(BOOL)animated{
    self.view.backgroundColor = [UIColor whiteColor];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UsrName = [[UITextField alloc]init];
    passwd = [[UITextField alloc]init];
    UsrName.delegate = self;
    passwd.delegate = self;
    // Do any additional setup after loading the view, typically from a nib.
    //logo
    UIImageView * logo = [[UIImageView alloc]initWithImage:
                          [UIImage imageNamed:@"图标-登陆.png"]];
    logo.frame = CGRectMake(55, 102, 266, 66);
    //登陆文本框
    UsrName.textColor = [UIColor blackColor];
    UsrName.textAlignment = NSTextAlignmentLeft;
    UsrName.font = [UIFont systemFontOfSize:16];
    UsrName.placeholder = @"请输入您的用户名";
    UsrName.borderStyle = UITextBorderStyleNone;
    UsrName.frame = CGRectMake(72, 250, 200, 22);
    UIImageView * usr = [[UIImageView alloc]initWithImage:
                         [UIImage imageNamed:@"用户名-登陆.png"]];
    usr.frame = CGRectMake(40, 251, 22, 22);
    //登陆文本框直线
    CALayer * lineOne = [CALayer layer];
    lineOne.backgroundColor = [UIColor colorWithRed:0.592 green:0.592 blue:0.592 alpha:1].CGColor;
    lineOne.frame = CGRectMake(38, 285, 300, 1);
    //密码文本框
    passwd.secureTextEntry = YES;
    passwd.textColor = [UIColor blackColor];
    passwd.textAlignment = NSTextAlignmentLeft;
    passwd.font = [UIFont systemFontOfSize:16];
    passwd.placeholder = @"请输入您的密码";
    passwd.borderStyle = UITextBorderStyleNone;
    passwd.frame = CGRectMake(72, 350, 200, 22);
    UIImageView * pas = [[UIImageView alloc]initWithImage:
                         [UIImage imageNamed:@"密码-登陆"]];
    pas.frame = CGRectMake(40, 351, 22, 22);
    //密码文本框直线
    CALayer * lineTwo = [CALayer layer];
    lineTwo.backgroundColor = [UIColor colorWithRed:0.592 green:0.592 blue:0.592 alpha:1].CGColor;
    lineTwo.frame = CGRectMake(38, 385, 300, 1);
    //登陆按钮
    UIButton * log = [UIButton buttonWithType:UIButtonTypeCustom];
    [log setBackgroundImage:[UIImage imageNamed:@"登陆-登陆"] forState:UIControlStateNormal];
    log.frame = CGRectMake(36, 460, 300, 40);
    [log addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
    //忘记密码按钮
    UIButton * fget = [UIButton buttonWithType:UIButtonTypeCustom];
    [fget setBackgroundImage:[UIImage imageNamed:@"忘记密码-登陆"] forState:UIControlStateNormal];
    fget.frame = CGRectMake(40, 552, 64, 14);
    [fget addTarget:self action:@selector(forget) forControlEvents:UIControlEventTouchUpInside];
    //立即注册按钮
    UIButton * regis = [UIButton buttonWithType:UIButtonTypeCustom];
    [regis setBackgroundImage:[UIImage imageNamed:@"立即注册-登陆"]
                     forState:UIControlStateNormal];
    regis.frame = CGRectMake(260, 550, 68, 20);
    [regis addTarget:self action:@selector(regist) forControlEvents:UIControlEventTouchUpInside];

    [self managedObjectModel];
    [self documentDirectoryURL];
    [self persistentStoreCoordinator];
    [self context];
    
    [self.view addSubview:logo];
    [self.view addSubview:UsrName];
    [self.view addSubview:passwd];
    [self.view addSubview:usr];
    [self.view addSubview:pas];
    [self.view.layer addSublayer:lineOne];
    [self.view.layer addSublayer:lineTwo];
    [self.view addSubview:log];
    [self.view addSubview:fget];
    [self.view addSubview:regis];
}

- (void)toRegis{
    UIAlertController * con = [UIAlertController alertControllerWithTitle:nil message:@"请选择注册类型" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction * admin = [UIAlertAction actionWithTitle:@"读者" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        Regis * regis = [[Regis alloc]init];
        [self presentViewController:regis animated:YES completion:nil];
    }];
    UIAlertAction * user = [UIAlertAction actionWithTitle:@"管理员" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        RegisAdmin * regisAdmin = [[RegisAdmin alloc]init];
        [self presentViewController:regisAdmin animated:YES completion:nil];
    }];
    UIAlertAction * cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:nil];
    [con addAction:admin];
    [con addAction:user];
    [con addAction:cancel];
    [self presentViewController:con animated:YES completion:nil];
}
- (void)login{
    if(UsrName.text.length == 0){
        UIAlertController * alertCon = [UIAlertController alertControllerWithTitle:@"输入错误" message:@"请输入用户名" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * action = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alertCon addAction:action];
        //转换视图控制器
        [self presentViewController:alertCon animated:YES completion:nil];
    }
    if(passwd.text.length == 0){
        UIAlertController * alertCon = [UIAlertController alertControllerWithTitle:@"输入错误" message:@"请输入密码" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * action = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alertCon addAction:action];
        //转换视图控制器
        [self presentViewController:alertCon animated:YES completion:nil];
        
    }
    UIAlertController * alertView = [UIAlertController alertControllerWithTitle:@"选择登陆类型" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction * loginAdmin = [UIAlertAction actionWithTitle:@"登陆管理员" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        _request = [NSFetchRequest fetchRequestWithEntityName:@"Admin"];
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"name LIKE %@",UsrName.text];
        _request.predicate = predicate;
        NSArray * ids = [_moc executeFetchRequest:_request error:nil];
        int lenght = (int)ids.count;
        if(lenght==0){
            UIAlertController * alertView = [UIAlertController alertControllerWithTitle:@"登陆失败" message:@"用户名不存在" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction * action = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil];
            [alertView addAction:action];
            [self presentViewController:alertView animated:YES completion:nil];
        }else{
            int rep = 0;
            rep = [self isRepeat];
            if(rep == 1){
                //_adminID = UsrName.text;
                _admin = ids[0];
                _adminID = _admin.manager_id;
                [self initNextView];
            }else{//发出警告
                UIAlertController * alertView = [UIAlertController alertControllerWithTitle:@"登陆失败" message:@"密码错误" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction * action = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil];
                [alertView addAction:action];
                [self presentViewController:alertView animated:YES completion:nil];
            }
        }
    }];
    UIAlertAction * loginReader = [UIAlertAction actionWithTitle:@"登陆读者" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        _request = [NSFetchRequest fetchRequestWithEntityName:@"User"];
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"name LIKE %@",UsrName.text];
        _request.predicate = predicate;
        NSArray * ids = [_moc executeFetchRequest:_request error:nil];
        int lenght = (int)ids.count;
        if(lenght==0){
            UIAlertController * alertView = [UIAlertController alertControllerWithTitle:@"登陆失败" message:@"用户名不存在" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction * action = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil];
            [alertView addAction:action];
            [self presentViewController:alertView animated:YES completion:nil];
        }else{
            int rep = 0;
            rep = [self isRepeat2];
            if(rep == 1){
                _user = ids[0];
                _readerID = _user.reader_id;
                [self initNextView2];
            }else{//发出警告
                UIAlertController * alertView = [UIAlertController alertControllerWithTitle:@"登陆失败" message:@"密码错误" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction * action = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil];
                [alertView addAction:action];
                [self presentViewController:alertView animated:YES completion:nil];
            }
        }
    }];
    UIAlertAction * cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alertView addAction:loginAdmin];
    [alertView addAction:loginReader];
    [alertView addAction:cancel];
    [self presentViewController:alertView animated:YES completion:nil];
    
}

- (void)initNextView{
    UITabBarController * tabBar = [[UITabBarController alloc]init];
    tabBar.tabBar.barTintColor = [UIColor whiteColor];
    tabBar.tabBar.tintColor = [UIColor colorWithRed:0.458 green:0.792 blue:0.094 alpha:0.5];
    
    //跳转到库存页
    bookPage * b = [[bookPage alloc]init];
    UINavigationController * book = [[UINavigationController alloc]initWithRootViewController:b];
    book.tabBarItem.title = [NSString stringWithFormat:@"库存"];
    book.tabBarItem.image = [UIImage imageNamed:@"库存-未点亮"];
    UIImage * image1 = [[UIImage imageNamed:@"库存-点亮"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    book.tabBarItem.selectedImage = image1;
    b.AdminID = _adminID;
    
    //跳转到用户页
    UINavigationController * user = [[UINavigationController alloc]initWithRootViewController:[[userPage alloc]init]];
    user.tabBarItem.title = [NSString stringWithFormat:@"用户"];
    user.tabBarItem.image = [UIImage imageNamed:@"用户-未点亮"];
    UIImage * image2 = [[UIImage imageNamed:@"用户-点亮"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    user.tabBarItem.selectedImage = image2;
    
    //跳转到我的页
    minePage * m = [[minePage alloc]init];
    UINavigationController * mine = [[UINavigationController alloc]initWithRootViewController:m];
    mine.tabBarItem.title = [NSString stringWithFormat:@"我的"];
    mine.tabBarItem.image = [UIImage imageNamed:@"我的-未点亮"];
    UIImage * image4 = [[UIImage imageNamed:@"我的-点亮"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    mine.tabBarItem.selectedImage = image4;
    m.adminID = _adminID;//跨view传值
    //NSLog(@"%@///%@",_adminID,m.adminID);
    
    
    NSMutableArray * arr =[[NSMutableArray alloc]init];
    [arr addObject:book];
    [arr addObject:user];
    //[arr addObject:deal];
    [arr addObject:mine];
    tabBar.viewControllers = arr;
    [self presentViewController:tabBar animated:YES completion:nil];

}
- (void)initNextView2{
    UITabBarController * tabBar = [[UITabBarController alloc]init];
    tabBar.tabBar.barTintColor = [UIColor whiteColor];
    tabBar.tabBar.tintColor = [UIColor colorWithRed:0.458 green:0.792 blue:0.094 alpha:0.5];
    
    //跳转到库存页
    bookPage2 * b = [[bookPage2 alloc]init];
    UINavigationController * book = [[UINavigationController alloc]initWithRootViewController:b];
    book.tabBarItem.title = [NSString stringWithFormat:@"库存"];
    book.tabBarItem.image = [UIImage imageNamed:@"库存-未点亮"];
    UIImage * image1 = [[UIImage imageNamed:@"库存-点亮"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    book.tabBarItem.selectedImage = image1;
    b.ReaderID = _readerID;
    
    //跳转到借阅页
    borrow * bo = [[borrow alloc]init];
    UINavigationController * borrow = [[UINavigationController alloc]initWithRootViewController:bo];
    borrow.tabBarItem.title = [NSString stringWithFormat:@"当前借阅"];
    borrow.tabBarItem.image = [UIImage imageNamed:@"登记-未点亮"];
    UIImage * image2 = [[UIImage imageNamed:@"登记-点亮"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    borrow.tabBarItem.selectedImage = image2;
    bo.ReaderID = _readerID;
    
    
    //跳转到我的页
    minePage2 * m = [[minePage2 alloc]init];
    UINavigationController * mine = [[UINavigationController alloc]initWithRootViewController:m];
    mine.tabBarItem.title = [NSString stringWithFormat:@"我的"];
    mine.tabBarItem.image = [UIImage imageNamed:@"我的-未点亮"];
    UIImage * image4 = [[UIImage imageNamed:@"我的-点亮"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    mine.tabBarItem.selectedImage = image4;
    m.ReaderID = _readerID;
    
    
    NSMutableArray * arr =[[NSMutableArray alloc]init];
    [arr addObject:book];
    [arr addObject:borrow];
    //[arr addObject:deal];
    [arr addObject:mine];
    tabBar.viewControllers = arr;
    [self presentViewController:tabBar animated:YES completion:nil];
    
}

- (int)isRepeat{//查询
    int rep = 0;
    NSString * searchContext = UsrName.text;
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"Admin"];//设置查询请求
    NSPredicate * pre = [NSPredicate predicateWithFormat:@"name LIKE %@",searchContext];//设置查询条件
    request.predicate = pre;
    NSArray * array = [_moc executeFetchRequest:request error:nil];
    for(Admin * t in array){
        if([passwd.text isEqualToString:t.password]){
            rep = 1;
        }
    }
    return rep;
}

- (int)isRepeat2{
    int rep = 0;
    NSString * searchContext = UsrName.text;
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"User"];//设置查询请求
    NSPredicate * pre = [NSPredicate predicateWithFormat:@"name LIKE %@",searchContext];//设置查询条件
    request.predicate = pre;
    NSArray * array = [_moc executeFetchRequest:request error:nil];
    for(User * u in array){
        if([passwd.text isEqualToString:u.password]){
            rep = 1;
        }
    }
    
    return rep;
}
- (void)forget{
    forgetPwd * reader1 = [[forgetPwd alloc]init];
    forgetPwdAdmin * admin1 = [[forgetPwdAdmin alloc]init];
    findPwd * reader2 = [[findPwd alloc]init];
    findPwdAdmin * admin2 = [[findPwdAdmin alloc]init];
    UIAlertController * alertView = [UIAlertController alertControllerWithTitle:@"请选择您的操作" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction * forgetPwd = [UIAlertAction actionWithTitle:@"忘记密码" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIAlertController * alertView2 = [UIAlertController alertControllerWithTitle:@"请选择您的用户类型" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction * s1 = [UIAlertAction actionWithTitle:@"读者" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self presentViewController:reader1 animated:YES completion:nil];
        }];
        UIAlertAction * s2 = [UIAlertAction actionWithTitle:@"管理员" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"正在执行管理员找回密码");
            //[self.navigationController pushViewController:admin1 animated:YES];
            [self presentViewController:admin1 animated:YES completion:nil];
        }];
        UIAlertAction * s3 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [alertView2 addAction:s1];
        [alertView2 addAction:s2];
        [alertView2 addAction:s3];
        [self presentViewController:alertView2 animated:YES completion:nil];
    }];
    UIAlertAction * findPwd = [UIAlertAction actionWithTitle:@"修改密码" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIAlertController * alertView2 = [UIAlertController alertControllerWithTitle:@"请选择您的用户类型" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction * s1 = [UIAlertAction actionWithTitle:@"读者" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self presentViewController:reader2 animated:YES completion:nil];
        }];
        UIAlertAction * s2 = [UIAlertAction actionWithTitle:@"管理员" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"正在执行管理员找回密码");
            //[self.navigationController pushViewController:admin1 animated:YES];
            [self presentViewController:admin2 animated:YES completion:nil];
        }];
        UIAlertAction * s3 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [alertView2 addAction:s1];
        [alertView2 addAction:s2];
        [alertView2 addAction:s3];
        [self presentViewController:alertView2 animated:YES completion:nil];
    }];
    UIAlertAction * cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alertView addAction:forgetPwd];
    [alertView addAction:findPwd];
    [alertView addAction:cancel];
    [self presentViewController:alertView animated:YES completion:nil];
}

- (void)regist{
    UIAlertController * con = [UIAlertController alertControllerWithTitle:nil message:@"请选择注册类型" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction * admin = [UIAlertAction actionWithTitle:@"注册读者" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        Regis * regis = [[Regis alloc]init];
        [self presentViewController:regis animated:YES completion:nil];
    }];
    UIAlertAction * user = [UIAlertAction actionWithTitle:@"注册管理员" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        RegisAdmin * regisAdmin = [[RegisAdmin alloc]init];
        [self presentViewController:regisAdmin animated:YES completion:nil];
    }];
    UIAlertAction * cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [con addAction:admin];
    [con addAction:user];
    [con addAction:cancel];
    [self presentViewController:con animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

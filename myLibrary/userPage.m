//
//  userPage.m
//  myLibrary
//
//  Created by 吕浩泰 on 2018/3/13.
//  Copyright © 2018年 吕浩泰. All rights reserved.
//

#import "userPage.h"
#import "admin.h"
#import "Reader.h"
#import <CoreData/CoreData.h>
#import "Admin+CoreDataProperties.h"
#import "User+CoreDataProperties.h"
#import "BMChineseSort.h"
#import "LrdOutputView.h"
#import "searchUser.h"
//#import "BMChineseSort.m"
@interface userPage ()<UITableViewDataSource,UITableViewDelegate,LrdOutputViewDelegate>
@property(nonatomic ,strong, readwrite)UITableView * list;
@property(nonatomic, strong, readwrite)UITableView * table;
@property(nonatomic, strong, readwrite)NSArray * addArray;

@property(nonatomic, strong, readwrite)NSURL * modelURL;
@property(nonatomic, strong, readwrite)NSManagedObjectModel * mom;//数据库实例模型
@property(nonatomic, strong, readwrite)NSPersistentStoreCoordinator * psc;//持续化存储控制器
@property(nonatomic, strong, readwrite)NSURL * path;//路径
@property(nonatomic, strong, readwrite)NSManagedObjectContext * moc;//请求上下文
@property(nonatomic, strong, readwrite)NSFetchRequest * request;//发送请求
@property(nonatomic, strong, readwrite)NSArray * array;
@property(nonatomic, strong, readwrite)NSArray * arrayAdmin;
@property(nonatomic, strong, readwrite)NSArray * arrayUser;
@property(nonatomic, strong, readwrite)NSArray * tmpArray;
@property(nonatomic, strong, readwrite)UIImageView * bookCon;

@property(nonatomic, strong, readwrite)Admin * admin;
@property(nonatomic, strong, readwrite)User * user;

@property(nonatomic, strong, readwrite)NSMutableArray * nameArray;
@property(nonatomic, strong, readwrite)NSMutableArray * indexArray;
@property(nonatomic, strong, readwrite)NSMutableArray * letterResultArr;

@property(nonatomic, strong, readwrite)NSArray * dataArray;
@property(nonatomic, strong, readwrite)LrdOutputView * outputView;
@end

@implementation userPage
- (void)viewWillAppear:(BOOL)animated{
    [self.list reloadData];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self managedObjectModel];
    [self documentDirectoryURL];
    [self persistentStoreCoordinator];
    [self context];
    
    [self goInit];
    
    self.indexArray = [BMChineseSort IndexWithArray:_array Key:@"name"];//设置关键数组
    self.letterResultArr = [BMChineseSort sortObjectArray:_array Key:@"name"];
    
    self.title = @"用户";
    (self.navigationController.navigationBar).backgroundColor = [UIColor whiteColor];//白色
    self.navigationController.navigationBar.translucent = NO;//且不透明
    //设置无底边
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    (self.navigationController.navigationBar).shadowImage = [UIImage new];
    
    
    _list = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.list.delegate = self;//设置协议对象
    self.list.dataSource = self;//设置数据源对象
    [self.view addSubview:_list];
    
    //加入更多按钮
    UIImage * image1 = [[UIImage imageNamed:@"more.png"]imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem * more = [[UIBarButtonItem alloc]initWithImage:image1 style:UIBarButtonItemStylePlain target:self action:@selector(showMore)];
    self.navigationItem.leftBarButtonItem = more;
    
    //加入搜索按钮
    UIImage * image2 = [[UIImage imageNamed:@"搜索.png"]imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem * search = [[UIBarButtonItem alloc]initWithImage:image2 style:UIBarButtonItemStylePlain target:self action:@selector(goSearch)];
    self.navigationItem.rightBarButtonItem = search;
    
    LrdCellModel *one = [[LrdCellModel alloc] initWithTitle:@"所有用户" imageName:@"所有"];
    LrdCellModel *two = [[LrdCellModel alloc] initWithTitle:@"管理人员" imageName:@"管理"];
    LrdCellModel *three = [[LrdCellModel alloc] initWithTitle:@"借阅用户" imageName:@"一般"];
    _dataArray = @[one, two, three];
}

- (void)goInit{
    //取得所有管理员数据
    _request = [NSFetchRequest fetchRequestWithEntityName:@"Admin"];
    NSSortDescriptor * nameSort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    _request.sortDescriptors = @[nameSort];
    _arrayAdmin = [_moc executeFetchRequest:_request error:nil];//取得管理员信息

    //取得所有用户数据
    _request = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    _request.sortDescriptors = @[nameSort];
    _arrayUser = [_moc executeFetchRequest:_request error:nil];//取得用户信息
    
    //合并以上两个数组
    NSMutableArray * arr = [NSMutableArray arrayWithArray:_arrayAdmin];
    [arr addObjectsFromArray:_arrayUser];
    _array = [arr copy];
    
    _tmpArray = _array;
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewRowAction * delete = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [self.list beginUpdates];
        [self.list deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        //删除model
        NSObject * obj = [[self.letterResultArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        if([obj isKindOfClass:[Admin class]]){
            Admin * a = [[self.letterResultArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
            [_moc deleteObject:a];
            [_moc save:nil];//记住保存
        }else{
            User * u = [[self.letterResultArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
            [_moc deleteObject:u];
            [_moc save:nil];//记住保存
        }
        [self goInit];
        [self.list reloadData];
        
        [self.list endUpdates];
    }];
    delete.backgroundColor = [UIColor colorWithRed:0.906 green:0.314 blue:0.345 alpha:1];
    return @[delete];
}
- (void)goSearch{
    searchUser * search = [[searchUser alloc]init];
    [self.navigationController pushViewController:search animated:YES];
}

- (void)showMore{
    CGFloat x = 10;
    CGFloat y = 75;
    _outputView = [[LrdOutputView alloc] initWithDataArray:_dataArray origin:CGPointMake(x, y) width:140 height:40 direction:kLrdOutputViewDirectionLeft];
    _outputView.delegate = self;
    _outputView.dismissOperation = ^(){
        //设置成nil，以防内存泄露
        _outputView = nil;
    };
    [_outputView pop];
}
- (void)didSelectedAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row == 0){
        [self showAll];
    }else if(indexPath.row == 1){
        [self showAdmin];
    }else if(indexPath.row == 2){
        [self showUser];
    }
}
- (void)showAll{//展示所有用户的触发方法
    _array = _tmpArray;
    self.indexArray = [BMChineseSort IndexWithArray:_array Key:@"name"];
    self.letterResultArr = [BMChineseSort sortObjectArray:_array Key:@"name"];
    self.title = @"所有用户";
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.list reloadData];
    });
}
- (void)showAdmin{//展示所有管理员的触发方法
    _array = _arrayAdmin;
    self.indexArray = [BMChineseSort IndexWithArray:_array Key:@"name"];
    self.letterResultArr = [BMChineseSort sortObjectArray:_array Key:@"name"];
    self.title = @"所有管理员";
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.list reloadData];
    });
    
}
- (void)showUser{//展示所有借阅者的触发方法
    _array = _arrayUser;
    self.indexArray = [BMChineseSort IndexWithArray:_array Key:@"name"];
    self.letterResultArr = [BMChineseSort sortObjectArray:_array Key:@"name"];
    self.title = @"所有借阅者";
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.list reloadData];
    });
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [self.indexArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[self.letterResultArr objectAtIndex:section]count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    /*if(section == 0) {
        return 0;
    }else{
    return 20;
    }//头视图高度  */
    return 20;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return [self.indexArray objectAtIndex:section];
}
- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    return self.indexArray;//显示每组标题索引（以显示右侧索引）
}
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index{
    return index;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CELL"];
        if (cell == nil){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CELL"];
        }
        //获得对应的Person对象
    NSObject * obj = [[self.letterResultArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if([obj isKindOfClass:[Admin class]]){//判断对象类型
        Admin * obj = [[self.letterResultArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        cell.textLabel.text = obj.name;
        //1.获取路径
        NSArray * path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString * conPath = [NSString stringWithFormat:@"ConForAdmin/%@.jpg",obj.manager_id];//存入用户头像
        NSString * docPath = [path objectAtIndex:0];
        NSFileManager * fileManager = [NSFileManager defaultManager];
        NSString * fullPath = [docPath stringByAppendingString:conPath];
        [fileManager createDirectoryAtPath:[fullPath stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:nil];
        //2.获取数据
        NSData * data = [NSData dataWithContentsOfFile:fullPath];
        UIImage * image = [UIImage imageWithData:data];
        if(image == nil&&data == nil){
            cell.imageView.image = [UIImage imageNamed:@"头像.png"];
            NSLog(@"数据库中没有存有本用户的头像");
            NSLog(@"我去这里找过了:%@",fullPath);
        }else{
            cell.imageView.image = image;
            NSLog(@"头像查询成功并已设置");
        }
        //调整cell.imageView大小
        CGSize itemSize = CGSizeMake(45, 45);//希望显示的大小
        UIGraphicsBeginImageContextWithOptions(itemSize, NO, UIScreen.mainScreen.scale);
        CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
        [cell.imageView.image drawInRect:imageRect];
        cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return cell;
    }else{
        User * obj = [[self.letterResultArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        cell.textLabel.text = obj.name;
        //1.获取路径
        NSArray * path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString * conPath = [NSString stringWithFormat:@"ConForUser/%@.jpg",obj.reader_id];//存入用户头像
        NSString * docPath = [path objectAtIndex:0];
        NSFileManager * fileManager = [NSFileManager defaultManager];
        NSString * fullPath = [docPath stringByAppendingString:conPath];
        [fileManager createDirectoryAtPath:[fullPath stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:nil];
        //2.获取数据
        NSData * data = [NSData dataWithContentsOfFile:fullPath];
        UIImage * image = [UIImage imageWithData:data];
        if(image == nil&&data == nil){
            cell.imageView.image = [UIImage imageNamed:@"头像.png"];
            NSLog(@"数据库中没有存有本用户的头像");
            NSLog(@"我去这里找过了:%@",fullPath);
        }else{
            cell.imageView.image = image;
            NSLog(@"头像查询成功并已设置");
        }
        //调整cell.imageView大小
        CGSize itemSize = CGSizeMake(45, 45);//希望显示的大小
        UIGraphicsBeginImageContextWithOptions(itemSize, NO, UIScreen.mainScreen.scale);
        CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
        [cell.imageView.image drawInRect:imageRect];
        cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSObject * obj = [[self.letterResultArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if([obj isKindOfClass:[Admin class]]){
        Admin * obj = [[self.letterResultArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        admin * next = [[admin alloc]init];
        next.AdminID = [NSString stringWithFormat:@"%@",obj.manager_id];
        [self.navigationController pushViewController:next animated:YES];
    }else{
        User * obj = [[self.letterResultArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        Reader * next = [[Reader alloc]init];
        next.ReaderID = obj.reader_id;
        [self.navigationController pushViewController:next animated:YES];
    }
}
/*
- (CGSize)preferredContentSize {
    if (self.presentingViewController && self.table != nil) {
        CGSize tempSize = self.presentingViewController.view.bounds.size;
        tempSize.width = 150;
        //返回一个完美适应tableView的大小的 size; sizeThatFits 返回的是最合适的尺寸, 但不会改变控件的大小
        CGSize size = [self.table sizeThatFits:tempSize];
        return size;
    }else{
        return [self preferredContentSize];
    }
}
*/
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

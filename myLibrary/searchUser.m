//
//  searchUser.m
//  myLibrary
//
//  Created by 吕浩泰 on 2018/3/28.
//  Copyright © 2018年 吕浩泰. All rights reserved.
//

#import "searchUser.h"
#import "admin.h"
#import "Reader.h"
#import <CoreData/CoreData.h>
#import "Admin+CoreDataProperties.h"
#import "User+CoreDataProperties.h"
#import "BMChineseSort.h"
#import "LrdOutputView.h"
@interface searchUser ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>
@property(nonatomic ,strong, readwrite)UITableView * list;
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


@property(nonatomic, strong, readwrite)UISearchBar * search;
@end

@implementation searchUser

- (void)viewDidLoad {
    [super viewDidLoad];
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
    self.list.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_list];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _search = [[UISearchBar alloc]initWithFrame:CGRectMake(0 , 0, 380, 28)];
    _search.backgroundImage = [[UIImage alloc]init];//去掉上下黑线
    _search.barTintColor = [UIColor grayColor];
    _search.tintColor = [UIColor grayColor];
    
    //定义图标
    [_search setImage:[UIImage imageNamed:@"搜索.png"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    _search.placeholder = @"搜索";
    _search.delegate = self;
    self.navigationItem.titleView = _search;
    
    [self managedObjectModel];
    [self documentDirectoryURL];
    [self persistentStoreCoordinator];
    [self context];
    
    [self goInit];
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self goInit];
    self.list.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _array = _tmpArray;
    self.indexArray = [BMChineseSort IndexWithArray:_array Key:@"name"];
    self.letterResultArr = [BMChineseSort sortObjectArray:_array Key:@"name"];
    self.title = @"所有用户";
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.list reloadData];
    });
}
- (void)goInit{
    //取得所有管理员数据
    _request = [NSFetchRequest fetchRequestWithEntityName:@"Admin"];
    NSSortDescriptor * nameSort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    _request.sortDescriptors = @[nameSort];
    NSPredicate * pre1 = [NSPredicate predicateWithFormat:@"name CONTAINS %@ || manager_id CONTAINS %@",_search.text,_search.text];
    _request.predicate = pre1;
    _arrayAdmin = [_moc executeFetchRequest:_request error:nil];//取得管理员信息
    NSLog(@"test:%@",_search.text);
    //取得所有用户数据
    _request = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    _request.sortDescriptors = @[nameSort];
    NSPredicate * pre2 = [NSPredicate predicateWithFormat:@"name CONTAINS %@ || reader_id CONTAINS %@",_search.text,_search.text];
    _request.predicate = pre2;
    _arrayUser = [_moc executeFetchRequest:_request error:nil];//取得用户信息
    
    //合并以上两个数组
    NSMutableArray * arr = [NSMutableArray arrayWithArray:_arrayAdmin];
    [arr addObjectsFromArray:_arrayUser];
    _array = [arr copy];
    
    _tmpArray = _array;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [self.indexArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSLog(@"Num:%d",(int)[[self.letterResultArr objectAtIndex:section]count]);
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

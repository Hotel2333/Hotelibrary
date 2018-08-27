//
//  bookPage2.m
//  myLibrary
//
//  Created by 吕浩泰 on 2018/3/29.
//  Copyright © 2018年 吕浩泰. All rights reserved.
//

#import "bookPage2.h"
#import "book.h"
#import "search2.h"
#import "upLoad.h"
#import "information2.h"
#import <CoreData/CoreData.h>
#import "User+CoreDataProperties.h"
#import "Book+CoreDataProperties.h"
#import "Borrow+CoreDataProperties.h"
#import "Return+CoreDataProperties.h"
#import "Punish+CoreDataClass.h"
@interface bookPage2 ()<UITableViewDataSource,UITableViewDelegate,NSFetchedResultsControllerDelegate>{
    NSFetchedResultsController * fecCon;
}
@property(nonatomic, strong, readwrite)UITableView * tableView;

@property(nonatomic, strong, readwrite)Book * book;
@property(nonatomic, strong, readwrite)NSURL * modelURL;
@property(nonatomic, strong, readwrite)NSManagedObjectModel * mom;//数据库实例模型
@property(nonatomic, strong, readwrite)NSPersistentStoreCoordinator * psc;//持续化存储控制器
@property(nonatomic, strong, readwrite)NSURL * path;//路径
@property(nonatomic, strong, readwrite)NSManagedObjectContext * moc;//请求上下文
@property(nonatomic, strong, readwrite)NSFetchRequest * request;//发送请求
@property(nonatomic, strong, readwrite)NSArray * array;
@end

@implementation bookPage2
- (void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    [_moc refreshAllObjects];
    [_tableView reloadData];
    [self goInit];
    NSLog(@"视图即将出现啦");
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"库存";
    self.view.backgroundColor = [UIColor whiteColor];
    (self.navigationController.navigationBar).backgroundColor = [UIColor whiteColor];//白色
    self.navigationController.navigationBar.translucent = NO;//且不透明
    
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    
    //设置无底边
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    (self.navigationController.navigationBar).shadowImage = [UIImage new];
    //self.navigationController.navigationBar.clipsToBounds = YES; 不好的写法
    
    //加入搜索按钮
    UIImage * image = [[UIImage imageNamed:@"搜索.png"] imageWithRenderingMode:   UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem * search = [[UIBarButtonItem alloc]initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(goSearch)];
    self.navigationItem.rightBarButtonItem = search;
    
    //加入tableView
    _tableView = [[UITableView alloc]initWithFrame:
                  CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.height-64)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.bounces = NO;
    [self.view addSubview:_tableView];
    
    [self managedObjectModel];
    [self documentDirectoryURL];
    [self persistentStoreCoordinator];
    [self context];
    
    [self goInit];
    
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    //借阅按钮
    UITableViewRowAction * read = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"借阅" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        UIAlertController * alertView = [UIAlertController alertControllerWithTitle:@"再次确认" message:@"是否确认借阅本书" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * next = [UIAlertAction actionWithTitle:@"是的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //存储入数据库
            Borrow * borrow = [NSEntityDescription insertNewObjectForEntityForName:@"Borrow" inManagedObjectContext:_moc];
            Book * obj = [fecCon objectAtIndexPath:indexPath];
            borrow.book_id = obj.book_id;
            borrow.manager_id = @"无管理员处理";
            /*
            //设置reader_id
            _request = [NSFetchRequest fetchRequestWithEntityName:@"User"];//设置请求的实体
            NSPredicate * predicate = [NSPredicate predicateWithFormat:@"name LIKE %@",_ReaderID];
            _request.predicate = predicate;//设置请求的条件
            NSError * error = nil;
            NSArray * arr = [_moc executeFetchRequest:_request error:&error];
            User * r = arr[0];
            borrow.reader_id = r.reader_id;*/
            borrow.reader_id = _ReaderID;
            NSLog(@"%@用户正在借阅%@图书",_ReaderID,obj.book_name);
            NSDateFormatter * formatter = [[NSDateFormatter alloc]init];
            formatter.dateFormat = @"yyyy年MM月dd日HH时mm分";
            NSString * dateTime = [formatter stringFromDate:[NSDate date]];
            borrow.borr_date = dateTime;
            //判断库存是否充足
            int num = obj.num;
            num--;
            if(num<0){
                UIAlertController * error = [UIAlertController alertControllerWithTitle:@"错误" message:@"本书已经没有库存了" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction * cancel2 = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDestructive handler:nil];
                [error addAction:cancel2];
                [self presentViewController:alertView animated:YES completion:nil];
            }else{
                obj.num = num;
                [_moc save:nil];
                //登记借阅
                NSError * error = nil;
                if([_moc save:&error]){
                    NSString * str = [NSString stringWithFormat:@"[%@]您已成功借阅编号为%@书名为《%@》的图书",dateTime,obj.book_id,obj.book_name];
                    UIAlertController * alertView2 = [UIAlertController alertControllerWithTitle:@"成功" message:str preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction * done = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil];
                    [alertView2 addAction:done];
                    [self presentViewController:alertView2 animated:YES completion:nil];
                }else{
                    UIAlertController * error = [UIAlertController alertControllerWithTitle:@"错误" message:@"存储失败" preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction * cancel2 = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDestructive handler:nil];
                    [error addAction:cancel2];
                    NSLog(@"错误信息:%@",error);
                    [self presentViewController:alertView animated:YES completion:nil];
                }
            }
        }];
        UIAlertAction * cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [alertView addAction:next];
        [alertView addAction:cancel];
        [self presentViewController:alertView animated:YES completion:nil];
    }];
        read.backgroundColor = [UIColor colorWithRed:0.620 green:0.851 blue:0.364 alpha:1];
        return @[read];
    }
            

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    id<NSFetchedResultsSectionInfo> info = [fecCon sections][section];
    NSLog(@"总共有%lu行",(unsigned long)[info numberOfObjects]);
    return [info numberOfObjects];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 110;//设置高度
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * ID = @"cell";
    book * cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if(!cell){
        cell = [[book alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        [cell setBookID:_bookID];
    }
    _book = [fecCon objectAtIndexPath:indexPath];
    _bookID = _book.book_id;
    [cell renderWithBookId:_bookID];//初始化cell的bookID
    cell.title.text = [NSString stringWithFormat:@"《%@》",_book.book_name];//在这里就设置文字
    cell.author.text = _book.author;
    cell.tips.text = _book.tips;
    return cell;
}
- (void)goSearch{
    search2 * searchPage = [[search2 alloc]init];
    [self.navigationController pushViewController:searchPage animated:YES];
}
- (void)goInit{
    _request = [NSFetchRequest fetchRequestWithEntityName:@"Book"];
    NSSortDescriptor * priceSort = [NSSortDescriptor sortDescriptorWithKey:@"price" ascending:YES];
    NSSortDescriptor * nameSort = [NSSortDescriptor sortDescriptorWithKey:@"book_name" ascending:YES];
    _request.sortDescriptors = @[priceSort,nameSort];
    fecCon = [[NSFetchedResultsController alloc]initWithFetchRequest:_request managedObjectContext:_moc sectionNameKeyPath:nil cacheName:nil];
    fecCon.delegate = self;
    NSError * error = nil;
    if(![fecCon performFetch:&error]){
        NSLog(@"ERROR:%@",error);
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    information2 * info = [[information2 alloc]init];
    Book * b = [fecCon objectAtIndexPath:indexPath];
    info.bookID = b.book_id;
    info.ReaderID = _ReaderID;
    [self.navigationController pushViewController:info animated:YES];
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

//
//  bookPage.m
//  myLibrary
//
//  Created by 吕浩泰 on 2018/3/13.
//  Copyright © 2018年 吕浩泰. All rights reserved.
//

#import "bookPage.h"
#import "book.h"
#import "search.h"
#import "upLoad.h"
#import "information.h"
#import <CoreData/CoreData.h>
#import "Admin+CoreDataProperties.h"
#import "Book+CoreDataProperties.h"
#import "Borrow+CoreDataProperties.h"
#import "Return+CoreDataProperties.h"
#import "Punish+CoreDataClass.h"
@interface bookPage ()<UITableViewDataSource,UITableViewDelegate,NSFetchedResultsControllerDelegate>{
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

@implementation bookPage
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
    //删除按钮
    UITableViewRowAction * delete = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        Book * obj = [fecCon objectAtIndexPath:indexPath];
        NSLog(@"正在删除编号为%@书名为%@的图书",obj.book_id,obj.book_name);
        [_moc deleteObject:obj];
        [_moc save:nil];//记住保存
        [self goInit];
        [_tableView reloadData];
        
        _request = [NSFetchRequest fetchRequestWithEntityName:@"Borrow"];
        NSPredicate * pre = [NSPredicate predicateWithFormat:@"book_id = %@",obj.book_id];
        _request.predicate = pre;
        NSArray * arr = [_moc executeFetchRequest:_request error:nil];
        for(Borrow * b in arr){
            [_moc deleteObject:b];
            [_moc save:nil];
        }
        
        [self.tableView endUpdates];
    }];
    delete.backgroundColor = [UIColor colorWithRed:0.906 green:0.314 blue:0.345 alpha:1];
    
    //更新按钮
    UITableViewRowAction * update = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"修改" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        upLoad * upload = [[upLoad alloc]init];
        upload.bookID = _bookID;
        [self.navigationController pushViewController:upload animated:YES];
    }];
    update.backgroundColor = [UIColor colorWithRed:0.620 green:0.851 blue:0.364 alpha:1];
    //借阅按钮
    UITableViewRowAction * read = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"借还" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        UIAlertController * selection = [UIAlertController alertControllerWithTitle:@"选择操作类型" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        //借书
        UIAlertAction * s1 = [UIAlertAction actionWithTitle:@"登记借阅" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            UIAlertController * alertView = [UIAlertController alertControllerWithTitle:@"登记借阅" message:@"请输入读者的id" preferredStyle:UIAlertControllerStyleAlert];
            [alertView addTextFieldWithConfigurationHandler:nil];
            UIAlertAction * done = [UIAlertAction actionWithTitle:@"下一步" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                //1.修改数据库
                Borrow * borrow = [NSEntityDescription insertNewObjectForEntityForName:@"Borrow" inManagedObjectContext:_moc];
                Book * obj = [fecCon objectAtIndexPath:indexPath];
                NSLog(@"正在借阅编号为%@书名为%@的图书",obj.book_id,obj.book_name);
                borrow.book_id = obj.book_id;
                /*
                //根据_AdminID找到manager_id
                _request = [NSFetchRequest fetchRequestWithEntityName:@"Admin"];
                NSPredicate * prediccate = [NSPredicate predicateWithFormat:@"name LIKE %@",_AdminID];
                _request.predicate = prediccate;
                NSArray * ar = [_moc executeFetchRequest:_request error:nil];
                Admin * a = ar[0];
                borrow.manager_id = a.manager_id;
                 */
                borrow.manager_id = _AdminID;
                //查询reader_id是否存在
                _request = [NSFetchRequest fetchRequestWithEntityName:@"User"];//设置查询请求
                NSPredicate * pre = [NSPredicate predicateWithFormat:@"reader_id LIKE %@",alertView.textFields.firstObject.text];//设置查询条件
                _request.predicate = pre;
                NSArray * array = [_moc executeFetchRequest:_request error:nil];
                int length = (int)array.count;//接收数组长度
                NSLog(@"在用户表中寻找到%d条记录",length);
                if(length==0){
                    UIAlertController * error = [UIAlertController alertControllerWithTitle:@"错误" message:@"找不到该id的用户" preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction * cancel2 = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDestructive handler:nil];
                    [error addAction:cancel2];
                    [self presentViewController:error animated:YES completion:nil];
                }else{
                    borrow.reader_id = alertView.textFields.firstObject.text;
                    int num = obj.num;
                    num--;
                    if(num<0){
                        UIAlertController * error = [UIAlertController alertControllerWithTitle:@"错误" message:@"本书已经没有库存了" preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction * cancel2 = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDestructive handler:nil];
                        [error addAction:cancel2];
                        [self presentViewController:error animated:YES completion:nil];
                    }else{
                        obj.num = num;
                        [_moc save:nil];
                        //录入时间
                        NSDateFormatter * formatter = [[NSDateFormatter alloc]init];
                        formatter.dateFormat = @"yyyy年MM月dd日HH时mm分";
                        NSString * dateTime = [formatter stringFromDate:[NSDate date]];
                        borrow.borr_date = dateTime;
                        [_moc save:nil];
                        //2.跳转下一步
                        NSString * info = [NSString stringWithFormat:@"[%@]编号为%@书名为%@的图书已成功借阅给用户%@",dateTime,obj.book_id,obj.book_name,alertView.textFields.firstObject.text];
                        UIAlertController * alertView2 = [UIAlertController alertControllerWithTitle:@"成功" message:info preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction * done2 = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil];
                        [alertView2 addAction:done2];
                        [self presentViewController:alertView2 animated:YES completion:nil];
                    }
                }
            }];
            UIAlertAction * cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:nil];
            [alertView addAction:done];
            [alertView addAction:cancel];
            [self presentViewController:alertView animated:YES completion:nil];
        }];
        //还书
        UIAlertAction * s2 = [UIAlertAction actionWithTitle:@"登记还书" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            UIAlertController * alertView = [UIAlertController alertControllerWithTitle:@"登记还书" message:@"请输入读者的id" preferredStyle:UIAlertControllerStyleAlert];
            [alertView addTextFieldWithConfigurationHandler:nil];
            UIAlertAction * done = [UIAlertAction actionWithTitle:@"下一步" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                //1.修改数据库
                Book * obj = [fecCon objectAtIndexPath:indexPath];
                NSLog(@"正在归还编号为%@书名为%@的图书",obj.book_id,obj.book_name);
                _request = [NSFetchRequest fetchRequestWithEntityName:@"Borrow"];
                NSPredicate * pre = [NSPredicate predicateWithFormat:@"reader_id LIKE %@",alertView.textFields.firstObject.text];
                _request.predicate = pre;
                NSError * error = nil;
                NSArray * array = [_moc executeFetchRequest:_request error:&error];
                //Borrow * borrow = array[0];
                //查询reader_id是否存在
                if(array.count==0){
                    NSLog(@"查找失败:%@",error);
                    UIAlertController * error = [UIAlertController alertControllerWithTitle:@"错误" message:@"借阅记录中找不到该id的用户" preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction * cancel2 = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDestructive handler:nil];
                    [error addAction:cancel2];
                    [self presentViewController:error animated:YES completion:nil];
                }else{
                    Borrow * borrow = array[0];
                    UIAlertController * alertView2 = [UIAlertController alertControllerWithTitle:@"注意" message:@"检查图书是否损坏" preferredStyle:UIAlertControllerStyleAlert];
                    //图书完好
                    UIAlertAction * good = [UIAlertAction actionWithTitle:@"完好" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        //1-1.计算归还逾期
                        NSDateFormatter * formatter = [[NSDateFormatter alloc]init];
                        formatter.dateFormat = @"yyyy年MM月dd日HH时mm分";
                        NSDate * nowDate = [NSDate date];//获得当前时间
                        NSString * dateTime = [formatter stringFromDate:[NSDate date]];
                        NSDate * borrowDate = [formatter dateFromString:borrow.borr_date];//获得借阅时间
                        NSTimeInterval start = [borrowDate timeIntervalSince1970]*1;
                        NSTimeInterval end = [nowDate timeIntervalSince1970]*1;
                        NSTimeInterval value = end - start;
                        int day = (int)value/(24*3600);//计算相差时间(日)
                        int free = 0;
                        //1-2.根据计算结果处理数据库
                        if(day<=90){
                            [_moc deleteObject:borrow];
                            [_moc save:nil];//存储删除borrow表的操作
                            int num = obj.num;
                            num++;
                            obj.num = num;
                            [_moc save:nil];//存储修改相应book库存的操作
                            Return * returnBook = [NSEntityDescription insertNewObjectForEntityForName:@"Return" inManagedObjectContext:_moc];
                            returnBook.book_id = obj.book_id;
                            //returnBook.manager_id = _AdminID;
                            /*//根据_AdminID找到manager_id
                            _request = [NSFetchRequest fetchRequestWithEntityName:@"Admin"];
                            NSPredicate * prediccate = [NSPredicate predicateWithFormat:@"name LIKE %@",_AdminID];
                            _request.predicate = prediccate;
                            NSArray * ar = [_moc executeFetchRequest:_request error:nil];
                            Admin * a = ar[0];
                            returnBook.manager_id = a.manager_id;
                            */
                            returnBook.manager_id = _AdminID;
                            returnBook.reader_id = alertView.textFields.firstObject.text;
                            returnBook.retu_date = dateTime;
                            [_moc save:nil];//存储插入return表的操作
                        }else{
                            [_moc deleteObject:borrow];
                            [_moc save:nil];//存储删除borrow表的操作
                            int num = obj.num;
                            num++;
                            obj.num = num;
                            [_moc save:nil];//存储修改相应book库存的操作
                            Return * returnBook = [NSEntityDescription insertNewObjectForEntityForName:@"Return" inManagedObjectContext:_moc];
                            returnBook.book_id = obj.book_id;
                            //returnBook.manager_id = _AdminID;
                            /*
                            //根据_AdminID找到manager_id
                            _request = [NSFetchRequest fetchRequestWithEntityName:@"Admin"];
                            NSPredicate * prediccate = [NSPredicate predicateWithFormat:@"name LIKE %@",_AdminID];
                            _request.predicate = prediccate;
                            NSArray * ar = [_moc executeFetchRequest:_request error:nil];
                            Admin * a = ar[0];
                            returnBook.manager_id = a.manager_id;
                             */
                            returnBook.manager_id = _AdminID;
                            returnBook.reader_id = alertView.textFields.firstObject.text;
                            returnBook.retu_date = dateTime;
                            [_moc save:nil];//存储插入return表的操作
                            Punish * punishReader = [NSEntityDescription insertNewObjectForEntityForName:@"Punish" inManagedObjectContext:_moc];
                            punishReader.book_id = obj.book_id;
                            punishReader.manager_id = _AdminID;
                            punishReader.reader_id = alertView.textFields.firstObject.text;
                            punishReader.punish_date = dateTime;
                            free = obj.price * 0.01 * (day - 90);//计算罚金
                            punishReader.punish_free = free;
                            punishReader.punish_tips = [NSString stringWithFormat:@"逾期还书%d天",day-90];
                            [_moc save:nil];//存储插入punish表的操作
                        }
                        NSString * info = [NSString stringWithFormat:@"编号为%@书名为%@且由ID为%@用户借阅的图书已归还，罚金为%d元",obj.book_id,obj.book_name,alertView.textFields.firstObject.text,free];
                        UIAlertController * alertView3 = [UIAlertController alertControllerWithTitle:@"成功" message:info preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction * leave = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil];
                        [alertView3 addAction:leave];
                        [self presentViewController:alertView3 animated:YES completion:nil];
                    }];
                    //图书损坏
                    UIAlertAction * bad = [UIAlertAction actionWithTitle:@"损坏" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                        NSDateFormatter * formatter = [[NSDateFormatter alloc]init];
                        formatter.dateFormat = @"yyyy年MM月dd日HH时mm分";
                        NSString * dateTime = [formatter stringFromDate:[NSDate date]];
                        int free = 0;
                        Borrow * borrow = array[0];
                        [_moc deleteObject:borrow];
                        [_moc save:nil];//存储删除borrow表的操作
                        int num = obj.broken_num;
                        num++;
                        obj.broken_num = num;
                        [_moc save:nil];//存储修改相应book库存的操作
                        Return * returnBook = [NSEntityDescription insertNewObjectForEntityForName:@"Return" inManagedObjectContext:_moc];
                        returnBook.book_id = obj.book_id;
                        //returnBook.manager_id = _AdminID;
                        /*
                        //根据_AdminID找到manager_id
                        _request = [NSFetchRequest fetchRequestWithEntityName:@"Admin"];
                        NSPredicate * prediccate = [NSPredicate predicateWithFormat:@"name LIKE %@",_AdminID];
                        _request.predicate = prediccate;
                        NSArray * ar = [_moc executeFetchRequest:_request error:nil];
                        Admin * a = ar[0];
                        returnBook.manager_id = a.manager_id;
                         */
                        returnBook.manager_id = _AdminID;
                        returnBook.reader_id = alertView.textFields.firstObject.text;
                        returnBook.retu_date = dateTime;
                        [_moc save:nil];//存储插入return表的操作
                        Punish * punishReader = [NSEntityDescription insertNewObjectForEntityForName:@"Punish" inManagedObjectContext:_moc];
                        punishReader.book_id = obj.book_id;
                        //punishReader.manager_id = _AdminID;
                        /*
                        //根据_AdminID找到manager_id
                        _request = [NSFetchRequest fetchRequestWithEntityName:@"Admin"];
                        NSPredicate * pree = [NSPredicate predicateWithFormat:@"name LIKE %@",_AdminID];
                        _request.predicate = pree;
                        NSArray * aar = [_moc executeFetchRequest:_request error:nil];
                        Admin * aa = aar[0];
                        punishReader.manager_id = aa.manager_id;
                         */
                        punishReader.manager_id = _AdminID;
                        punishReader.reader_id = alertView.textFields.firstObject.text;
                        punishReader.punish_date = dateTime;
                        free = obj.price * 0.8;//计算罚金
                        punishReader.punish_free = free;
                        punishReader.punish_tips = [NSString stringWithFormat:@"损坏图书"];
                        [_moc save:nil];//存储插入punish表的操作
                        
                        NSString * info = [NSString stringWithFormat:@"编号为%@书名为%@且由ID为%@用户借阅的图书已归还，罚金为%d元",obj.book_id,obj.book_name,alertView.textFields.firstObject.text,free];
                        UIAlertController * alertView3 = [UIAlertController alertControllerWithTitle:@"成功" message:info preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction * leave = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil];
                        [alertView3 addAction:leave];
                        [self presentViewController:alertView3 animated:YES completion:nil];
                    }];
                    [alertView2 addAction:good];
                    [alertView2 addAction:bad];
                    [self presentViewController:alertView2 animated:YES completion:nil];
                }
            }];
            UIAlertAction * cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:nil];
            [alertView addAction:done];
            [alertView addAction:cancel];
            [self presentViewController:alertView animated:YES completion:nil];
        }];
        //取消
        UIAlertAction * s3 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:nil];
        [selection addAction:s1];
        [selection addAction:s2];
        [selection addAction:s3];
        [self presentViewController:selection animated:YES completion:nil];
    }];
    read.backgroundColor = [UIColor colorWithRed:0.298 green:0.550 blue:0.722 alpha:1];
    return @[delete,update,read];
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
    search * searchPage = [[search alloc]init];
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
    information * info = [[information alloc]init];
    Book * b = [fecCon objectAtIndexPath:indexPath];
    info.bookID = b.book_id;
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

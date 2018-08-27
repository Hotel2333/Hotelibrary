//
//  search2.m
//  myLibrary
//
//  Created by 吕浩泰 on 2018/3/30.
//  Copyright © 2018年 吕浩泰. All rights reserved.
//

#import "search2.h"
#import "book.h"
#import "information2.h"
#import "Book+CoreDataProperties.h"
#import <CoreData/CoreData.h>
@interface search2 ()<UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource,NSFetchedResultsControllerDelegate>{
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
@property(nonatomic, strong, readwrite)UIImageView * bookCon;

@property(nonatomic, strong, readwrite)UISearchBar * search;
@end

@implementation search2
- (void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];//导航栏背景颜色
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
    
    //加入tableView
    _tableView = [[UITableView alloc]initWithFrame:
                  CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.height)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.bounces = NO;
    [self.view addSubview:_tableView];
    
    [self managedObjectModel];
    [self documentDirectoryURL];
    [self persistentStoreCoordinator];
    [self context];
    
}
- (void)goInit{
    _request = [NSFetchRequest fetchRequestWithEntityName:@"Book"];
    NSSortDescriptor * priceSort = [NSSortDescriptor sortDescriptorWithKey:@"price" ascending:YES];
    NSSortDescriptor * nameSort = [NSSortDescriptor sortDescriptorWithKey:@"book_name" ascending:YES];
    _request.sortDescriptors = @[priceSort,nameSort];
    NSPredicate * pre = [NSPredicate predicateWithFormat:@"book_id CONTAINS %@ || book_name CONTAINS %@ ||class_name CONTAINS %@ || author CONTAINS %@ || press_name CONTAINS %@",_search.text,_search.text,_search.text,_search.text,_search.text];
    _request.predicate = pre;
    /*
     fecCon = [[NSFetchedResultsController alloc]initWithFetchRequest:_request managedObjectContext:_moc sectionNameKeyPath:nil cacheName:nil];
     fecCon.delegate = self;
     NSError * error = nil;
     if(![fecCon performFetch:&error]){
     NSLog(@"ERROR:%@",error);
     }*/
    _array = [_moc executeFetchRequest:_request error:nil];
    
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self goInit];
    //[_moc refreshAllObjects];
    [_tableView reloadData];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    /*id<NSFetchedResultsSectionInfo> info = [fecCon sections][section];
     NSLog(@"总共有%lu行",(unsigned long)[info numberOfObjects]);
     return [info numberOfObjects];*/
    NSLog(@"总共有%d行",(int)_array.count);
    return (int)_array.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 110;//设置高度
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    information2 * info = [[information2 alloc]init];
    Book * b = _array[indexPath.row];
    info.bookID = b.book_id;
    [self.navigationController pushViewController:info animated:YES];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * ID = @"cell";
    book * cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if(!cell){
        cell = [[book alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        [cell setBookID:_bookID];
    }
    //_book = [fecCon objectAtIndexPath:indexPath];
    _book = _array[indexPath.row];
    _bookID = _book.book_id;
    [cell renderWithBookId:_bookID];//初始化cell的bookID
    //[cell setBookID:_bookID];
    cell.title.text = [NSString stringWithFormat:@"《%@》",_book.book_name];//在这里就设置文字
    cell.author.text = _book.author;
    cell.tips.text = _book.tips;
    return cell;
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

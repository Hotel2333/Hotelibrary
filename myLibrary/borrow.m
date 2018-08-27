//
//  borrow.m
//  myLibrary
//
//  Created by 吕浩泰 on 2018/3/29.
//  Copyright © 2018年 吕浩泰. All rights reserved.
//

#import "borrow.h"
#import "bookPage2.h"
#import "User+CoreDataProperties.h"
#import "Borrow+CoreDataProperties.h"
#import "Book+CoreDataProperties.h"
#import "Return+CoreDataProperties.h"
#import <CoreData/CoreData.h>
@interface borrow ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property(nonatomic, strong, readwrite)User * reader;
@property(nonatomic, strong, readwrite)NSURL * modelURL;
@property(nonatomic, strong, readwrite)NSManagedObjectModel * mom;//数据库实例模型
@property(nonatomic, strong, readwrite)NSPersistentStoreCoordinator * psc;//持续化存储控制器
@property(nonatomic, strong, readwrite)NSURL * path;//路径
@property(nonatomic, strong, readwrite)NSManagedObjectContext * moc;//请求上下文
@property(nonatomic, strong, readwrite)NSFetchRequest * request;//发送请求
@property(nonatomic, strong, readwrite)NSArray * array;

@property(nonatomic, strong, readwrite)UICollectionView * collectionView;
@property(nonatomic, strong, readwrite)UIScrollView * scrollView;

@end

@implementation borrow

- (void)viewWillAppear:(BOOL)animated{
    self.view.backgroundColor = [UIColor whiteColor];
    //设置无底边
    (self.navigationController.navigationBar).backgroundColor = [UIColor whiteColor];//白色
    self.navigationController.navigationBar.translucent = NO;//且不透明
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    (self.navigationController.navigationBar).shadowImage = [UIImage new];
    self.title = @"当前借阅";
    
    [_moc refreshAllObjects];
    _array = nil;
    [self goInit];
    int height = ((int)_array.count)/3*200;
    _scrollView.contentSize = CGSizeMake(self.view.frame.size.width, height);
    [self.collectionView reloadData];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc]init];
    layout.minimumLineSpacing = 60;
    layout.minimumInteritemSpacing = 15;
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.itemSize = CGSizeMake(82, 116);
    _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(28, 10, self.view.frame.size.width-54,self.view.frame.size.height) collectionViewLayout:layout];
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cellID"];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.backgroundColor = [UIColor whiteColor];
    //[self.view addSubview:collectionView];
    
    [self managedObjectModel];
    [self documentDirectoryURL];
    [self persistentStoreCoordinator];
    [self context];
    [self goInit];
    
    _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-60)];
    int height = ((int)_array.count)/3*200;
    _scrollView.contentSize = CGSizeMake(self.view.frame.size.width, height);
    [_scrollView addSubview:_collectionView];
    [self.view addSubview:_scrollView];
}
- (void)goInit{
    //找到读者id
    _request = [NSFetchRequest fetchRequestWithEntityName:@"User"];//设置请求的实体
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"reader_id LIKE %@",_ReaderID];
    
    _request.predicate = predicate;//设置请求的条件
    NSError * error = nil;
    _array = [_moc executeFetchRequest:_request error:&error];
    if(_array.count!=0){
        _reader = _array[0];
    }
    NSLog(@"错误:%@",error);
    
    
    //找到借阅记录
    _request = [NSFetchRequest fetchRequestWithEntityName:@"Borrow"];
    NSPredicate * pre = [NSPredicate predicateWithFormat:@"reader_id LIKE %@",_reader.reader_id];
    NSSortDescriptor * dateSort = [NSSortDescriptor sortDescriptorWithKey:@"borr_date" ascending:YES];
    _request.sortDescriptors = @[dateSort];
    _request.predicate = pre;
    _array = [_moc executeFetchRequest:_request error:nil];
    
    NSLog(@"找到(%@)用户%@的%d条借阅记录",_reader.reader_id,_ReaderID,(int)_array.count);
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    //return 10;
    int num = (int)_array.count;
    num++;
    return num;
}
- (void)next{
    bookPage2 * b = [[bookPage2 alloc]init];
    b.ReaderID = _ReaderID;
    [self.navigationController pushViewController:b animated:YES];
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellID" forIndexPath:indexPath];
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    int num = (int)_array.count;
    if(indexPath.section == 0 && indexPath.row == num){
        UIImageView * imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 82, 116)];
        imageView.image = [UIImage imageNamed:@"添加借阅.png"];
        UIButton * btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.frame = CGRectMake(0, 0, 82, 116);
        [btn addTarget:self action:@selector(next) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:imageView];
        [cell.contentView addSubview:btn];
        return cell;
    }else{
        Borrow * obj = _array[indexPath.row];
        UIImageView * imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 82, 116)];
        
        NSArray * path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString * conPath = [NSString stringWithFormat:@"/Book/%@.jpg",obj.book_id];
        NSString * docPath = [path objectAtIndex:0];
        NSFileManager * fileManager = [NSFileManager defaultManager];
        NSString * fullPath = [docPath stringByAppendingString:conPath];
        [fileManager createDirectoryAtPath:[fullPath stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:nil];
        NSData * data = [NSData dataWithContentsOfFile:fullPath];
        UIImage * image = [UIImage imageWithData:data];
        if(image == nil&&data == nil){
            [imageView setBackgroundColor:[UIColor blackColor]];
            NSLog(@"数据库中没有存有本图书的封面");
            NSLog(@"我去这里找过了:%@",fullPath);
        }else{
            [imageView setImage:image];
            NSLog(@"封面查询成功并已设置");
        }
        [cell.contentView addSubview:imageView];
        
        UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(0, 115, 95, 50)];
        label.font = [UIFont systemFontOfSize:14];
        //找到本书的书名
        _request = [NSFetchRequest fetchRequestWithEntityName:@"Book"];
        NSPredicate * pre = [NSPredicate predicateWithFormat:@"book_id LIKE %@",obj.book_id];
        _request.predicate = pre;
        NSArray * arr = [_moc executeFetchRequest:_request error:nil];
        Book * b = nil;
        if(arr.count!=0){
            b = arr[0];
        }
        label.text = b.book_name;
        label.numberOfLines = 2;
        [cell.contentView addSubview:label];
        return cell;
    }
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    Borrow * obj = _array[indexPath.row];
    UIAlertController * alertView = [UIAlertController alertControllerWithTitle:@"借阅信息" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertView addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.enabled = NO;
        textField.text = [NSString stringWithFormat:@"借阅时间:%@",obj.borr_date];
    }];
    [alertView addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.enabled = NO;
        textField.text = [NSString stringWithFormat:@"借阅时间:%@",obj.borr_date];
    }];
    [alertView addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.enabled = NO;
        textField.text = [NSString stringWithFormat:@"管理员: %@",obj.manager_id];
    }];
    UIAlertAction * s1 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction * s2 = [UIAlertAction actionWithTitle:@"归还" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        _request = [NSFetchRequest fetchRequestWithEntityName:@"Book"];
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"book_id LIKE %@",obj.book_id];
        _request.predicate = predicate;
        NSArray * books = [_moc executeFetchRequest:_request error:nil];
        int booksN = (int)books.count;
        if(booksN!=0){
            //修改Book库存信息
            Book * book = books[0];
            int num = book.num;
            num++;
            book.num = num;
            [_moc save:nil];
            //存储入return表
            Return * returnBook = [NSEntityDescription insertNewObjectForEntityForName:@"Return" inManagedObjectContext:_moc];
            returnBook.book_id = obj.book_id;
            returnBook.reader_id = obj.reader_id;
            returnBook.manager_id = obj.manager_id;
            NSDateFormatter * formatter = [[NSDateFormatter alloc]init];//计算当前时间
            formatter.dateFormat = @"yyyy年MM月dd日HH时mm分";
            NSString * dateTime = [formatter stringFromDate:[NSDate date]];
            returnBook.retu_date = dateTime;
            [_moc save:nil];
            //删除borrow表信息
            [_moc deleteObject:obj];
            [_moc save:nil];
            //刷新页面
            [_moc refreshAllObjects];
            [self goInit];
            [_collectionView reloadData];
            //弹窗提示成功
            NSString * info = [NSString stringWithFormat:@"您于%@成功归还图书%@",dateTime,book.book_name];
            UIAlertController * done = [UIAlertController alertControllerWithTitle:@"成功" message:info preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction * leave = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleCancel handler:nil];
            [done addAction:leave];
            [self presentViewController:done animated:YES completion:nil];
        }else{
            //弹窗提示失败
            UIAlertController * done = [UIAlertController alertControllerWithTitle:@"失败" message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction * leave = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleCancel handler:nil];
            [done addAction:leave];
            [self presentViewController:done animated:YES completion:nil];
        }
        
    }];
    [alertView addAction:s1];
    [alertView addAction:s2];
    [self presentViewController:alertView animated:YES completion:nil];
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

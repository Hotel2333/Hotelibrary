//
//  record2.m
//  myLibrary
//
//  Created by 吕浩泰 on 2018/3/29.
//  Copyright © 2018年 吕浩泰. All rights reserved.
//

#import "record2.h"
#import "Book+CoreDataProperties.h"
#import "User+CoreDataProperties.h"
#import "Borrow+CoreDataProperties.h"
#import "Return+CoreDataProperties.h"
#import "Punish+CoreDataClass.h"
#import <CoreData/CoreData.h>
@interface record2 ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic, strong, readwrite)NSURL * modelURL;
@property(nonatomic, strong, readwrite)NSManagedObjectModel * mom;//数据库实例模型
@property(nonatomic, strong, readwrite)NSPersistentStoreCoordinator * psc;//持续化存储控制器
@property(nonatomic, strong, readwrite)NSURL * path;//路径
@property(nonatomic, strong, readwrite)NSManagedObjectContext * moc;//请求上下文
@property(nonatomic, strong, readwrite)NSFetchRequest * request;//发送请求

@property(nonatomic, strong, readwrite)NSArray * borrowArray;
@property(nonatomic, strong, readwrite)NSArray * returnArray;
@property(nonatomic, strong, readwrite)NSArray * punishArray;
@property(nonatomic, strong, readwrite)NSArray * array;
@property(nonatomic, strong, readwrite)NSArray * tempArray;

@property(nonatomic, strong, readwrite)UITableView * tableView;
@end

@implementation record2

- (void)viewWillAppear:(BOOL)animated{
    //分页控制栏
    UISegmentedControl * segment = [[UISegmentedControl alloc]initWithItems:@[@"所有",@"未还",@"已还",@"处罚"]];
    segment.frame = CGRectMake(80, 5, 215, 30);
    self.navigationItem.titleView = segment;
    segment.selectedSegmentIndex = 0;//下标;
    segment.momentary = NO;
    [segment addTarget:self action:@selector(skip:) forControlEvents:UIControlEventValueChanged];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    
    [self managedObjectModel];
    [self documentDirectoryURL];
    [self persistentStoreCoordinator];
    [self context];
    
    [self goInit];
}
- (void)goInit{
    //获取借出列表
    _request = [NSFetchRequest fetchRequestWithEntityName:@"Borrow"];
    NSSortDescriptor * idSort = [NSSortDescriptor sortDescriptorWithKey:@"book_id" ascending:YES];
    _request.sortDescriptors = @[idSort];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"manager_id LIKE %@",_AdminID];
    _request.predicate = predicate;
    _borrowArray = [_moc executeFetchRequest:_request error:nil];
    //获取归还列表
    _request = [NSFetchRequest fetchRequestWithEntityName:@"Return"];
    _request.sortDescriptors = @[idSort];
    predicate = [NSPredicate predicateWithFormat:@"manager_id LIKE %@",_AdminID];
    _request.predicate = predicate;
    _returnArray = [_moc executeFetchRequest:_request error:nil];
    //获取处罚列表
    _request = [NSFetchRequest fetchRequestWithEntityName:@"Punish"];
    NSSortDescriptor * priceSort = [NSSortDescriptor sortDescriptorWithKey:@"punish_free" ascending:YES];
    _request.sortDescriptors = @[priceSort];
    predicate = [NSPredicate predicateWithFormat:@"manager_id LIKE %@",_AdminID];
    _request.predicate = predicate;
    _punishArray = [_moc executeFetchRequest:_request error:nil];
    //合并数组
    NSMutableArray * arr = [NSMutableArray arrayWithArray:_borrowArray];
    [arr addObjectsFromArray:_returnArray];
    [arr addObjectsFromArray:_punishArray];
    _array = [arr copy];
    
    NSLog(@"找到%d条记录",(int)_array.count);
    _tempArray = _array;
    
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    //删除按钮
    UITableViewRowAction * delete = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        NSObject * obj = _array[indexPath.row];
        if([obj isKindOfClass:[Borrow class]]){
            Borrow * b = _array[indexPath.row];
            [_moc deleteObject:b];
            [_moc save:nil];
        }else if([obj isKindOfClass:[Return class]]){
            Return * r = _array[indexPath.row];
            [_moc deleteObject:r];
            [_moc save:nil];
        }else{
            Punish * p = _array[indexPath.row];
            [_moc deleteObject:p];
            [_moc save:nil];
        }
        
        [self goInit];
        [_tableView reloadData];
        
        [self.tableView endUpdates];
    }];
    delete.backgroundColor = [UIColor colorWithRed:0.906 green:0.314 blue:0.345 alpha:1];
    return @[delete];
}
//分页控制栏的触发方法，切换dataSource再reload tableView
- (void)skip:(UISegmentedControl *) seg{
    NSInteger index = seg.selectedSegmentIndex;
    switch (index) {
        case 0:
            [self showAll];
            break;
        case 1:
            [self showBorrow];
            break;
        case 2:
            [self showReturn];
            break;
        case 3:
            [self showPunish];
            break;
        default:
            break;
    }
}
- (void)showAll{
    _array = _tempArray;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}
- (void)showBorrow{
    _array = _borrowArray;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}
- (void)showReturn{
    _array = _returnArray;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}
- (void)showPunish{
    _array = _punishArray;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return  1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(_array.count!=0){
        NSObject * obj = _array[indexPath.row];
        if([obj isKindOfClass:[Borrow class]]){
            UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cellID1"];
            if(cell == nil) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cellID1"];
            }
            Borrow * b = _array[indexPath.row];
            //根据id找到书名
            cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
            _request = [NSFetchRequest fetchRequestWithEntityName:@"Book"];
            NSPredicate * pre = [NSPredicate predicateWithFormat:@"book_id LIKE %@",b.book_id];
            _request.predicate = pre;
            NSArray * arr = [_moc executeFetchRequest:_request error:nil];
            if(arr.count!=0){
                Book * book = arr[0];
                cell.textLabel.text = book.book_name;
            }else{
                cell.textLabel.text = @"错误";
            }
            //根据id找到读者名字
            _request = [NSFetchRequest fetchRequestWithEntityName:@"User"];
            NSPredicate * pre2 = [NSPredicate predicateWithFormat:@"reader_id LIKE %@ ",b.reader_id];
            _request.predicate = pre2;
            arr = [_moc executeFetchRequest:_request error:nil];
            if(arr.count!=0){
                User * user = arr[0];
                cell.detailTextLabel.text = user.name;
            }else{
                cell.detailTextLabel.text = @"Not Found";
            }
            //放入当前时间
            NSDateFormatter * formatter = [[NSDateFormatter alloc]init];
            formatter.dateFormat = @"yyyy年MM月dd日HH时mm分";
            NSDate * date = [formatter dateFromString:b.borr_date];
            NSDateFormatter * form = [[NSDateFormatter alloc]init];
            form.dateFormat = @"yyyy/MM/dd/";
            NSString * dateStr = [form stringFromDate:date];
            UILabel * dateLabel = [[UILabel alloc]initWithFrame:CGRectMake(220, 20, 140, 16)];
            dateLabel.font = [UIFont systemFontOfSize:14];
            dateLabel.textColor = [UIColor colorWithRed:0.847 green:0.847 blue:0.847 alpha:1];
            dateLabel.text = dateStr;
            dateLabel.textAlignment = NSTextAlignmentRight;
            [cell.contentView addSubview:dateLabel];
            
            return cell;
        }else if([obj isKindOfClass:[Return class]]){
            UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cellID2"];
            if(cell == nil) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cellID2"];
            }
            Return * r = _array[indexPath.row];
            //根据id找到书名
            cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
            _request = [NSFetchRequest fetchRequestWithEntityName:@"Book"];
            NSPredicate * pre = [NSPredicate predicateWithFormat:@"book_id LIKE %@",r.book_id];
            _request.predicate = pre;
            NSArray * arr = [_moc executeFetchRequest:_request error:nil];
            if(arr.count!=0){
                Book * book = arr[0];
                cell.textLabel.text = book.book_name;
            }else{
                cell.textLabel.text = @"错误";
            }
            cell.textLabel.textColor = [UIColor colorWithRed:0.620 green:0.851 blue:0.364 alpha:1];
            //根据id找到读者名字
            _request = [NSFetchRequest fetchRequestWithEntityName:@"User"];
            pre = [NSPredicate predicateWithFormat:@"reader_id LIKE %@",r.reader_id];
            _request.predicate = pre;
            arr = [_moc executeFetchRequest:_request error:nil];
            if(arr.count!=0){
                User * user = arr[0];
                cell.detailTextLabel.text = user.name;
            }else{
                cell.detailTextLabel.text = @"Not Found";
            }
            cell.detailTextLabel.textColor = [UIColor colorWithRed:0.620 green:0.851 blue:0.364 alpha:1];
            //放入当前时间
            NSDateFormatter * formatter = [[NSDateFormatter alloc]init];
            formatter.dateFormat = @"yyyy年MM月dd日HH时mm分";
            NSDate * date = [formatter dateFromString:r.retu_date];
            NSDateFormatter * form = [[NSDateFormatter alloc]init];
            form.dateFormat = @"yyyy/MM/dd/";
            NSString * dateStr = [form stringFromDate:date];
            UILabel * dateLabel = [[UILabel alloc]initWithFrame:CGRectMake(220, 20, 140, 16)];
            dateLabel.font = [UIFont systemFontOfSize:14];
            dateLabel.textColor = [UIColor colorWithRed:0.847 green:0.847 blue:0.847 alpha:1];
            dateLabel.text = dateStr;
            dateLabel.textAlignment = NSTextAlignmentRight;
            dateLabel.textColor = [UIColor colorWithRed:0.620 green:0.851 blue:0.364 alpha:1];
            [cell.contentView addSubview:dateLabel];
            return cell;
        }else{
            UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cellID3"];
            if(cell == nil) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cellID3"];
            }
            Punish * p = _array[indexPath.row];
            //根据id找到书名
            cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
            _request = [NSFetchRequest fetchRequestWithEntityName:@"Book"];
            NSPredicate * pre = [NSPredicate predicateWithFormat:@"book_id LIKE %@",p.book_id];
            _request.predicate = pre;
            NSArray * arr = [_moc executeFetchRequest:_request error:nil];
            if(arr.count!=0){
                Book * book = arr[0];
                cell.textLabel.text = book.book_name;
            }else{
                cell.textLabel.text = @"错误";
            }
            cell.textLabel.textColor = [UIColor colorWithRed:0.906 green:0.314 blue:0.345 alpha:1];
            //根据id找到读者名字
            _request = [NSFetchRequest fetchRequestWithEntityName:@"User"];
            pre = [NSPredicate predicateWithFormat:@"reader_id LIKE %@",p.reader_id];
            _request.predicate = pre;
            arr = [_moc executeFetchRequest:_request error:nil];
            if(arr.count!=0){
                User * user = arr[0];
                cell.detailTextLabel.text = user.name;
            }else{
                cell.detailTextLabel.text = @"Not Found";
            }
            cell.detailTextLabel.textColor = [UIColor colorWithRed:0.906 green:0.314 blue:0.345 alpha:1];
            //放入当前时间
            NSDateFormatter * formatter = [[NSDateFormatter alloc]init];
            formatter.dateFormat = @"yyyy年MM月dd日HH时mm分";
            NSDate * date = [formatter dateFromString:p.punish_date];
            NSDateFormatter * form = [[NSDateFormatter alloc]init];
            form.dateFormat = @"yyyy/MM/dd/";
            NSString * dateStr = [form stringFromDate:date];
            UILabel * dateLabel = [[UILabel alloc]initWithFrame:CGRectMake(220, 20, 140, 16)];
            dateLabel.font = [UIFont systemFontOfSize:14];
            dateLabel.textColor = [UIColor colorWithRed:0.847 green:0.847 blue:0.847 alpha:1];
            dateLabel.text = dateStr;
            dateLabel.textAlignment = NSTextAlignmentRight;
            dateLabel.textColor = [UIColor colorWithRed:0.906 green:0.314 blue:0.345 alpha:1];
            [cell.contentView addSubview:dateLabel];
            return cell;
        }
    }else{
        return nil;
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

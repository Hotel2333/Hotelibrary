//
//  Reader.m
//  myLibrary
//
//  Created by 吕浩泰 on 2018/3/27.
//  Copyright © 2018年 吕浩泰. All rights reserved.
//

#import "Reader.h"
#import "record3.h"
#import "User+CoreDataProperties.h"
#import "Borrow+CoreDataProperties.h"
#import "Return+CoreDataProperties.h"
#import "Punish+CoreDataProperties.h"
@interface Reader ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic, strong, readwrite)UITableView * tableView;
@property(nonatomic, strong, readwrite)UIScrollView * scrollView;
@property(nonatomic, strong, readwrite)User * user;

@property(nonatomic, strong, readwrite)NSURL * modelURL;
@property(nonatomic, strong, readwrite)NSManagedObjectModel * mom;//数据库实例模型
@property(nonatomic, strong, readwrite)NSPersistentStoreCoordinator * psc;//持续化存储控制器
@property(nonatomic, strong, readwrite)NSURL * path;//路径
@property(nonatomic, strong, readwrite)NSManagedObjectContext * moc;//请求上下文
@property(nonatomic, strong, readwrite)NSFetchRequest * request;//发送请求
@property(nonatomic, strong, readwrite)NSArray * array;

@property(nonatomic, strong, readwrite)UIImageView * con;
@property(nonatomic, strong, readwrite)UILabel * name;
@property(nonatomic, strong, readwrite)UILabel * identity;
@end

@implementation Reader

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStyleGrouped];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    //[self.view addSubview:_tableView];
    
    self.view.backgroundColor = [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1];//设置底色
    _tableView.backgroundColor = [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1];
    
    _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [_scrollView addSubview:_tableView];
    
    
    UIButton * btn = [[UIButton alloc]initWithFrame:CGRectMake(40, 310, 300, 40)];
    //btn.backgroundColor = [UIColor greenColor];
    [btn setImage:[UIImage imageNamed:@"借阅记录.png"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(goRecord) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:btn];
    
    [self.view addSubview:_scrollView];
    
    [self managedObjectModel];
    [self documentDirectoryURL];
    [self persistentStoreCoordinator];
    [self context];
    [self goInit];
}
- (void)goInit{
    _request = [NSFetchRequest fetchRequestWithEntityName:@"User"];//设置请求的实体
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"reader_id LIKE %@",_ReaderID];
    _request.predicate = predicate;//设置请求的条件
    NSError * error = nil;
    _array = [_moc executeFetchRequest:_request error:&error];
    if(error){
        NSLog(@"传输错误:%@",error);
    }
    int num = (int)_array.count;
    if(num == 0){
        NSLog(@"查找失败");
        
    }else{
        _user = _array[0];
    }
    
}
- (void)goRecord{
    record3 * next = [[record3 alloc]init];
    next.ReaderID = _user.reader_id;
    [self.navigationController pushViewController:next animated:YES];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0){
        return 85;
    }else{
        return 42;
    }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == 0){
        return 1;
    }else{
        return 3;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0){
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
        if(!cell){
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cellID"];
        }
        //头像
        _con= [[UIImageView alloc]init];
        _con.frame = CGRectMake(14, 9, 65, 65);
        //1.获取路径
        NSArray * path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString * conPath = [NSString stringWithFormat:@"ConForUser/%@.jpg",_user.reader_id];//存入用户头像
        NSString * docPath = [path objectAtIndex:0];
        NSFileManager * fileManager = [NSFileManager defaultManager];
        NSString * fullPath = [docPath stringByAppendingString:conPath];
        [fileManager createDirectoryAtPath:[fullPath stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:nil];
        //2.获取数据
        NSData * data = [NSData dataWithContentsOfFile:fullPath];
        UIImage * image = [UIImage imageWithData:data];
        if(image == nil&&data == nil){
            [_con setImage:[UIImage imageNamed:@"头像.png"]];
            NSLog(@"数据库中没有存有本用户的头像");
            NSLog(@"我去这里找过了:%@",fullPath);
        }else{
            [_con setImage:image];
            NSLog(@"头像查询成功并已设置");
        }
        //姓名
        _name = [[UILabel alloc]initWithFrame:CGRectMake(92, 12, 200, 18)];
        _name.font = [UIFont boldSystemFontOfSize:16];
        _name.text = [NSString stringWithFormat:@"%@",_user.name];
        //编号
        _identity = [[UILabel alloc]initWithFrame:CGRectMake(92, 38, 200, 16)];
        _identity.font = [UIFont systemFontOfSize:14];
        _identity.text = [NSString stringWithFormat:@"%@",_user.reader_id];
        
        [cell.contentView addSubview:_con];
        [cell.contentView addSubview:_name];
        [cell.contentView addSubview:_identity];
        return cell;
    }else if(indexPath.section == 1 && indexPath.row == 0){
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
        if(!cell){
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cellID"];
        }
        UILabel * first = [[UILabel alloc]initWithFrame:CGRectMake(14, 10, 200, 16)];
        first.font = [UIFont systemFontOfSize:14];
        first.text = @"当前借阅";
        UILabel * second = [[UILabel alloc]initWithFrame:CGRectMake(92, 10, 200, 16)];
        second.font = [UIFont systemFontOfSize:14];
        //second.text = [NSString stringWithFormat:@"10本"];//待编写
        _request = [NSFetchRequest fetchRequestWithEntityName:@"Borrow"];
        NSPredicate * pre = [NSPredicate predicateWithFormat:@"reader_id LIKE %@",_ReaderID];
        _request.predicate = pre;
        NSArray * tmpArr = [_moc executeFetchRequest:_request error:nil];
        second.text = [NSString stringWithFormat:@"%d本",(int)tmpArr.count];
        
        [cell.contentView addSubview:first];
        [cell.contentView addSubview:second];
        return cell;
    }else if(indexPath.section == 1 && indexPath.row == 1){
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
        if(!cell){
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cellID"];
        }
        UILabel * first = [[UILabel alloc]initWithFrame:CGRectMake(14, 10, 200, 16)];
        first.font = [UIFont systemFontOfSize:14];
        first.text = @"违规记录";
        UILabel * second = [[UILabel alloc]initWithFrame:CGRectMake(92, 10, 200, 16)];
        second.font = [UIFont systemFontOfSize:14];
        //second.text = [NSString stringWithFormat:@"6条"];
        _request = [NSFetchRequest fetchRequestWithEntityName:@"Punish"];
        NSPredicate * pre = [NSPredicate predicateWithFormat:@"reader_id LIKE %@",_ReaderID];
        _request.predicate = pre;
        NSArray * tmpArr = [_moc executeFetchRequest:_request error:nil];
        second.text = [NSString stringWithFormat:@"%d条",(int)tmpArr.count];
        
        [cell.contentView addSubview:first];
        [cell.contentView addSubview:second];
        return cell;
    }else{
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
        if(!cell){
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cellID"];
        }
        UILabel * first = [[UILabel alloc]initWithFrame:CGRectMake(14, 10, 200, 16)];
        first.font = [UIFont systemFontOfSize:14];
        first.text = @"还书记录";
        UILabel * second = [[UILabel alloc]initWithFrame:CGRectMake(92, 10, 200, 16)];
        second.font = [UIFont systemFontOfSize:14];
        //second.text = [NSString stringWithFormat:@"27条"];
        _request = [NSFetchRequest fetchRequestWithEntityName:@"Return"];
        NSPredicate * pre = [NSPredicate predicateWithFormat:@"reader_id LIKE %@",_ReaderID];
        _request.predicate = pre;
        NSArray * tmpArr = [_moc executeFetchRequest:_request error:nil];
        second.text = [NSString stringWithFormat:@"%d条",(int)tmpArr.count];
        
        [cell.contentView addSubview:first];
        [cell.contentView addSubview:second];
        return cell;
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

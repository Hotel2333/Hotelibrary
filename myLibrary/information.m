//
//  information.m
//  myLibrary
//
//  Created by 吕浩泰 on 2018/3/14.
//  Copyright © 2018年 吕浩泰. All rights reserved.
//

#import "information.h"
#import "upLoad.h"
#import "Book+CoreDataProperties.h"
#import <CoreData/CoreData.h>
@interface information ()<UITableViewDelegate,UITableViewDataSource>
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
@end

@implementation information
- (void)viewWillAppear:(BOOL)animated{
    self.view.backgroundColor = [UIColor colorWithRed:0.612 green:0.851 blue:0.365 alpha:0];
    self.navigationController.navigationBar.translucent = NO;//且不透明
    
    //设置无底边
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    (self.navigationController.navigationBar).shadowImage = [UIImage new];//去掉小黑条
    (self.navigationController.navigationBar).tintColor = [UIColor whiteColor];//导航栏文字颜色
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.612 green:0.851 blue:0.365 alpha:0];//导航栏背景颜色
    
    [_moc refreshAllObjects];
    [self goInit];
    [self layoutHeaderView];
    [self.tableView reloadData];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    //加入tableView
    _tableView = [[UITableView alloc]initWithFrame:
                  CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.height)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    
    [self managedObjectModel];
    [self documentDirectoryURL];
    [self persistentStoreCoordinator];
    [self context];
    [self goInit];
    
    [self layoutHeaderView];
}
- (void)layoutHeaderView{
    //创建headView
    UIView * header = [[UIView alloc]initWithFrame: CGRectMake(0, 0, self.view.frame.size.width, 276)];
    
    //headerOne
    UIView * headerOne = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 200)];
    //_bookCon = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"封面.png"]];
    _bookCon = [[UIImageView alloc]init];
    _bookCon.frame = CGRectMake(33, 0, 82, 116);
    [self searchPic];
    [headerOne addSubview:_bookCon];
    //标题
    UILabel * title = [[UILabel alloc]initWithFrame:CGRectMake(125, 10 , 150 , 20)];
    title.font = [UIFont systemFontOfSize:18];
    title.textColor = [UIColor whiteColor];
    title.textAlignment = NSTextAlignmentLeft;
    //title.text = @"《计算机网络》";
    title.text = [NSString stringWithFormat:@"《%@》",_book.book_name];
    [headerOne addSubview:title];
    //作者
    UILabel * author = [[UILabel alloc]initWithFrame:CGRectMake(130, 45 , 150 , 15)];
    author.font = [UIFont systemFontOfSize:14];
    author.textColor = [UIColor whiteColor];
    author.textAlignment = NSTextAlignmentLeft;
    //author.text = @"谢希仁";
    author.text = _book.author;
    [headerOne addSubview:author];
    //内容
    UILabel * tips = [[UILabel alloc]initWithFrame:CGRectMake(33, 120, 310 , 80)];
    tips.font = [UIFont systemFontOfSize:12];
    tips.textColor = [UIColor whiteColor];
    tips.textAlignment = NSTextAlignmentLeft;
    tips.numberOfLines = 4;
    //tips.text = @"计算机网络也称计算机通信网。关于计算机网络的最简单定义是：一些相互连接的、以共享资源为目的的、自治的计算机的集合。若按此定义，则早期的面向终端的网络都不能算是计算机网络，而只能称为联机系统（因为那时的许多终端不能算是自治的计算机）。但随着硬件价格的下降，许多终端都具有一定的智能，因而“终端”和“自治的计算机”逐渐失去了严格的界限。若用微型计算机作为终端使用，按上述定义，则早期的那种面向终端的网络也可称为计算机网络。";
    tips.text = _book.tips;
    [headerOne addSubview:tips];
    
    headerOne.backgroundColor = [UIColor colorWithRed:0.612 green:0.851 blue:0.365 alpha:1];
    [header addSubview:headerOne];//添加headerOne入Header
    
    
    
    //headerTwo
    UIView * headerTwo = [[UIView alloc]initWithFrame:CGRectMake(0, 200, self.view.frame.size.width, 70)];
    UILabel * rest = [[UILabel alloc]initWithFrame:CGRectMake(50, 10, 40, 20)];
    rest.textAlignment = NSTextAlignmentCenter;
    rest.textColor = [UIColor colorWithRed:0.612 green:0.851 blue:0.365 alpha:1];
    rest.font = [UIFont systemFontOfSize:18];
    //rest.text = @"106";//库存数量
    rest.text = [NSString stringWithFormat:@"%d",_book.num];
    [headerTwo addSubview:rest];
    
    UILabel * restW = [[UILabel alloc]initWithFrame:CGRectMake(50, 42, 40, 20)];
    restW.textAlignment = NSTextAlignmentCenter;
    restW.textColor = [UIColor colorWithRed:0.612 green:0.851 blue:0.365 alpha:1];
    restW.font = [UIFont systemFontOfSize:12];
    restW.text = @"库存";
    [headerTwo addSubview:restW];
    
    UILabel * broken = [[UILabel alloc]initWithFrame:CGRectMake(170, 10, 40, 20)];
    broken.textAlignment = NSTextAlignmentCenter;
    broken.textColor = [UIColor colorWithRed:0.906 green:0.314 blue:0.345 alpha:1];
    broken.font = [UIFont systemFontOfSize:18];
    //broken.text = @"8";//损坏数量
    broken.text = [NSString stringWithFormat:@"%d",_book.broken_num];
    [headerTwo addSubview:broken];
    
    UILabel * brokenW = [[UILabel alloc]initWithFrame:CGRectMake(170, 42, 40, 20)];
    brokenW.textAlignment = NSTextAlignmentCenter;
    brokenW.textColor = [UIColor colorWithRed:0.906 green:0.314 blue:0.345 alpha:1];
    brokenW.font = [UIFont systemFontOfSize:12];
    brokenW.text = @"损坏";
    [headerTwo addSubview:brokenW];
    
    UIButton * edit = [UIButton buttonWithType:UIButtonTypeCustom];
    edit.frame = CGRectMake(302, 10, 21, 21);
    [edit setBackgroundImage:[UIImage imageNamed:@"编辑.png"] forState:UIControlStateNormal];
    [headerTwo addSubview:edit];
    [edit addTarget:self action:@selector(goEdit) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel * editW = [[UILabel alloc]initWithFrame:CGRectMake(292, 42, 40, 20)];
    editW.textAlignment = NSTextAlignmentCenter;
    editW.textColor = [UIColor colorWithRed:0.29 green:0.29 blue:0.29 alpha:1];
    editW.font = [UIFont systemFontOfSize:12];
    editW.text = @"编辑";
    [headerTwo addSubview:editW];
    
    headerTwo.backgroundColor = [UIColor whiteColor];
    [header addSubview:headerTwo];//添加hearderTwo进header
    
    //line
    UIView * line = [[UIView alloc]initWithFrame:CGRectMake(0, 270, self.view.frame.size.width, 6)];
    line.backgroundColor = [UIColor colorWithRed:0.847 green:0.847 blue:0.847 alpha:0.5];
    [header addSubview: line];
    
    self.tableView.tableHeaderView = header;
    [self.view addSubview:header];
}
- (void)goInit{
    _request = [NSFetchRequest fetchRequestWithEntityName:@"Book"];//设置请求的实体
    NSLog(@"_bookID:%@",_bookID);
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"book_id LIKE %@",_bookID];
    _request.predicate = predicate;//设置请求的条件
    NSError * error = nil;
    _array = [_moc executeFetchRequest:_request error:&error];
    NSLog(@"%@",error);
    _book = _array[0];
    
}
- (void)goEdit{
    upLoad * upload = [[upLoad alloc]init];
    upload.bookID = _bookID;
    [self.navigationController pushViewController:upload animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 8;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 8;
}
/* - (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if(section == 1){
        return 6;
    }else{
        return 0;
    }
    //另外设置》？？？
} */
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView * view = [[UIView alloc]initWithFrame:CGRectMake(0,0,375,8)];
    view.backgroundColor = [UIColor whiteColor];
    return view;
}
/*
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView * view = [[UIView alloc]initWithFrame:CGRectMake(0,0,375,8)];
    view.backgroundColor = [UIColor colorWithRed:0.847 green:0.847 blue:0.847 alpha:1];
    return view;
}*/
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row == 0){
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
        if(cell == nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cellID"];
        }
        UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(40, 10, 60, 20)];
        label.font = [UIFont systemFontOfSize:14];
        label.textColor = [UIColor colorWithRed:0.29 green:0.29 blue:0.29 alpha:1];
        label.textAlignment = NSTextAlignmentLeft;
        label.text = @"图书编号";
        [cell.contentView addSubview:label];
        
        UILabel * label2 = [[UILabel alloc]initWithFrame:CGRectMake(200, 10, 200, 20)];
        label2.font = [UIFont boldSystemFontOfSize:14];
        label2.textColor = [UIColor colorWithRed:0.29 green:0.29 blue:0.29 alpha:1];
        label2.textAlignment = NSTextAlignmentLeft;
        //label2.text = @"00006";
        label2.text = _book.book_id;
        [cell.contentView addSubview:label2];
        
        return cell;
    }else if(indexPath.row == 1){
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
        if(cell == nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cellID"];
        }
        UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(40, 10, 60, 20)];
        label.font = [UIFont systemFontOfSize:14];
        label.textColor = [UIColor colorWithRed:0.29 green:0.29 blue:0.29 alpha:1];
        label.textAlignment = NSTextAlignmentLeft;
        label.text = @"图书名称";
        [cell.contentView addSubview:label];
        
        UILabel * label2 = [[UILabel alloc]initWithFrame:CGRectMake(200, 10, 200, 20)];
        label2.font = [UIFont boldSystemFontOfSize:14];
        label2.textColor = [UIColor colorWithRed:0.29 green:0.29 blue:0.29 alpha:1];
        label2.textAlignment = NSTextAlignmentLeft;
        //label2.text = @"《计算机网络》";
        label2.text = [NSString stringWithFormat:@"《%@》",_book.book_name];
        [cell.contentView addSubview:label2];
        
        return cell;
    }else if(indexPath.row == 2){
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
        if(cell == nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cellID"];
        }
        UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(40, 10, 60, 20)];
        label.font = [UIFont systemFontOfSize:14];
        label.textColor = [UIColor colorWithRed:0.29 green:0.29 blue:0.29 alpha:1];
        label.textAlignment = NSTextAlignmentLeft;
        label.text = @"图书类别";
        [cell.contentView addSubview:label];
        
        UILabel * label2 = [[UILabel alloc]initWithFrame:CGRectMake(200, 10, 200, 20)];
        label2.font = [UIFont boldSystemFontOfSize:14];
        label2.textColor = [UIColor colorWithRed:0.29 green:0.29 blue:0.29 alpha:1];
        label2.textAlignment = NSTextAlignmentLeft;
        //label2.text = @"信息技术类";
        label2.text = _book.class_name;
        [cell.contentView addSubview:label2];
        return cell;
    }else if(indexPath.row == 3){
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
        if(cell == nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cellID"];
        }
        UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(40, 10, 60, 20)];
        label.font = [UIFont systemFontOfSize:14];
        label.textColor = [UIColor colorWithRed:0.29 green:0.29 blue:0.29 alpha:1];
        label.textAlignment = NSTextAlignmentLeft;
        label.text = @"作者";
        [cell.contentView addSubview:label];
        
        UILabel * label2 = [[UILabel alloc]initWithFrame:CGRectMake(200, 10, 200, 20)];
        label2.font = [UIFont boldSystemFontOfSize:14];
        label2.textColor = [UIColor colorWithRed:0.29 green:0.29 blue:0.29 alpha:1];
        label2.textAlignment = NSTextAlignmentLeft;
        //label2.text = @"谢希仁";
        label2.text = _book.author;
        [cell.contentView addSubview:label2];
        
        return cell;
    }else if(indexPath.row == 4){
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
        if(cell == nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cellID"];
        }
        UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(40, 10, 60, 20)];
        label.font = [UIFont systemFontOfSize:14];
        label.textColor = [UIColor colorWithRed:0.29 green:0.29 blue:0.29 alpha:1];
        label.textAlignment = NSTextAlignmentLeft;
        label.text = @"出版社";
        [cell.contentView addSubview:label];
        
        UILabel * label2 = [[UILabel alloc]initWithFrame:CGRectMake(200, 10, 200, 20)];
        label2.font = [UIFont boldSystemFontOfSize:14];
        label2.textColor = [UIColor colorWithRed:0.29 green:0.29 blue:0.29 alpha:1];
        label2.textAlignment = NSTextAlignmentLeft;
        //label2.text = @"电子工业出版社";
        label2.text = _book.press_name;
        [cell.contentView addSubview:label2];
        
        return cell;
    }else if(indexPath.row == 5){
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
        if(cell == nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cellID"];
        }
        UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(40, 10, 60, 20)];
        label.font = [UIFont systemFontOfSize:14];
        label.textColor = [UIColor colorWithRed:0.29 green:0.29 blue:0.29 alpha:1];
        label.textAlignment = NSTextAlignmentLeft;
        label.text = @"出版日期";
        [cell.contentView addSubview:label];
        
        UILabel * label2 = [[UILabel alloc]initWithFrame:CGRectMake(200, 10, 200, 20)];
        label2.font = [UIFont boldSystemFontOfSize:14];
        label2.textColor = [UIColor colorWithRed:0.29 green:0.29 blue:0.29 alpha:1];
        label2.textAlignment = NSTextAlignmentLeft;
        //label2.text = @"2015年01月01日";
        label2.text = _book.press_date;
        [cell.contentView addSubview:label2];
        
        return cell;
    }else if(indexPath.row == 6){
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
        if(cell == nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cellID"];
        }
        UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(40, 10, 60, 20)];
        label.font = [UIFont systemFontOfSize:14];
        label.textColor = [UIColor colorWithRed:0.29 green:0.29 blue:0.29 alpha:1];
        label.textAlignment = NSTextAlignmentLeft;
        label.text = @"登记日期";
        [cell.contentView addSubview:label];
        
        UILabel * label2 = [[UILabel alloc]initWithFrame:CGRectMake(200, 10, 200, 20)];
        label2.font = [UIFont boldSystemFontOfSize:14];
        label2.textColor = [UIColor colorWithRed:0.29 green:0.29 blue:0.29 alpha:1];
        label2.textAlignment = NSTextAlignmentLeft;
        //label2.text = @"2017年05月27日";
        label2.text = _book.reg_date;
        [cell.contentView addSubview:label2];
        
        return cell;
    }else{
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
        if(cell == nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cellID"];
        }
        UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(40, 10, 60, 20)];
        label.font = [UIFont systemFontOfSize:14];
        label.textColor = [UIColor colorWithRed:0.29 green:0.29 blue:0.29 alpha:1];
        label.textAlignment = NSTextAlignmentLeft;
        label.text = @"价格";
        [cell.contentView addSubview:label];
        
        UILabel * label2 = [[UILabel alloc]initWithFrame:CGRectMake(200, 10, 200, 20)];
        label2.font = [UIFont boldSystemFontOfSize:14];
        label2.textColor = [UIColor colorWithRed:0.29 green:0.29 blue:0.29 alpha:1];
        label2.textAlignment = NSTextAlignmentLeft;
        //label2.text = @"45.0元";
        label2.text = [NSString stringWithFormat:@"%f元",_book.price];
        [cell.contentView addSubview:label2];
        return cell;
    }
}
- (void)searchPic{
    NSArray * path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * conPath = [NSString stringWithFormat:@"/Book/%@.jpg",_bookID];
    NSString * docPath = [path objectAtIndex:0];
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSString * fullPath = [docPath stringByAppendingString:conPath];
    [fileManager createDirectoryAtPath:[fullPath stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:nil];
    NSData * data = [NSData dataWithContentsOfFile:fullPath];
    UIImage * image = [UIImage imageWithData:data];
    if(image == nil&&data == nil){
        [_bookCon setBackgroundColor:[UIColor blackColor]];
        NSLog(@"数据库中没有存有本图书的封面");
        NSLog(@"我去这里找过了:%@",fullPath);
    }else{
        [_bookCon setImage:image];
        NSLog(@"封面查询成功并已设置");
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

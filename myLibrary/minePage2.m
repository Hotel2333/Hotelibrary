//
//  minePage2.m
//  myLibrary
//
//  Created by 吕浩泰 on 2018/3/29.
//  Copyright © 2018年 吕浩泰. All rights reserved.
//

#import "minePage2.h"
#import "More2.h"
#import "record3.h"
#import "User+CoreDataProperties.h"
#import <CoreData/CoreData.h>
#import "ViewController.h"
#import "AppDelegate.h" //引入头文件
@interface minePage2 ()<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate>
@property(nonatomic, strong, readwrite)UITableView * mine;
@property(nonatomic, strong, readwrite)UIImageView * con;

@property(nonatomic, strong, readwrite)User * reader;
@property(nonatomic, strong, readwrite)NSURL * modelURL;
@property(nonatomic, strong, readwrite)NSManagedObjectModel * mom;//数据库实例模型
@property(nonatomic, strong, readwrite)NSPersistentStoreCoordinator * psc;//持续化存储控制器
@property(nonatomic, strong, readwrite)NSURL * path;//路径
@property(nonatomic, strong, readwrite)NSManagedObjectContext * moc;//请求上下文
@property(nonatomic, strong, readwrite)NSFetchRequest * request;//发送请求
@property(nonatomic, strong, readwrite)NSArray * array;
@end

@implementation minePage2
- (void)viewWillAppear:(BOOL)animated{
    self.view.backgroundColor = [UIColor whiteColor];
    [_moc refreshAllObjects];
    [self goInit];
    [self.mine reloadData];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"我的";
    self.view.backgroundColor = [UIColor whiteColor];
    (self.navigationController.navigationBar).backgroundColor = [UIColor whiteColor];//白色
    self.navigationController.navigationBar.translucent = NO;//且不透明
    //设置无底边
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    (self.navigationController.navigationBar).shadowImage = [UIImage new];
    
    [self managedObjectModel];
    [self documentDirectoryURL];
    [self persistentStoreCoordinator];
    [self context];
    
    //[self.view addSubview:_mine];
    
    [self goInit];
    
    self.title = _reader.name;
    
    
    _mine.delegate = self;
    _mine.dataSource = self;
    
    
    _mine = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.mine.delegate = self;
    self.mine.dataSource = self;
    self.mine.separatorStyle = UITableViewCellSeparatorStyleNone;//设置无底边
    
    [self.view addSubview:_mine];
    
    [self setupRefresh];
}
- (void)setupRefresh{
    UIRefreshControl * refresh = [[UIRefreshControl alloc]init];
    [refresh addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [_mine addSubview:refresh];
    [refresh beginRefreshing];
    [self refresh:refresh];
}
- (void)refresh:(UIRefreshControl *)refreshControl{
    [refreshControl endRefreshing];
    [_mine reloadData];
}
- (void)goInit{
    _request = [NSFetchRequest fetchRequestWithEntityName:@"User"];//设置请求的实体
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"reader_id LIKE %@",_ReaderID];
    _request.predicate = predicate;//设置请求的条件
    NSError * error = nil;
    _array = [_moc executeFetchRequest:_request error:&error];
    _reader = _array[0];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == 0){
        return 1;
    }else{
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0){
        return 175;
    }else {
        return 70;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(section == 0){
        return 0;
    }else{
        return 16;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 1 && indexPath.row == 0){
        record3 * record = [[record3 alloc]init];
        record.ReaderID = _ReaderID;
        [self.navigationController pushViewController:record animated:YES];
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(indexPath.section == 1){
            UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
            if(cell == nil) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cellID"];
            }else{
                for(UIView * subView in cell.contentView.subviews){
                    [subView removeFromSuperview];
                }
            }
            cell.textLabel.text = [NSString stringWithFormat:@"记录"];
            cell.textLabel.font = [UIFont systemFontOfSize:16];
            cell.imageView.image = [UIImage imageNamed:@"处理记录.png"];
            /*
            //通过name找到id
            _request = [NSFetchRequest fetchRequestWithEntityName:@"User"];
            NSPredicate * pre = [NSPredicate predicateWithFormat:@"name LIKE %@",_ReaderID];
            _request.predicate = pre;
            NSArray * arr = [_moc executeFetchRequest:_request error:nil];
            User * obj = arr[0];
            NSString * r_id = obj.reader_id;
            */
            //通过id找到记录个数
            _request = [NSFetchRequest fetchRequestWithEntityName:@"Return"];
            NSPredicate * pre =  [NSPredicate predicateWithFormat:@"reader_id LIKE %@",_ReaderID];
            _request.predicate = pre;
            NSArray * arr = [_moc executeFetchRequest:_request error:nil];
            
            
            UILabel * record = [[UILabel alloc]initWithFrame:CGRectMake(200, 10, 160, 20)];
            record.font = [UIFont systemFontOfSize:16];
            record.textColor = [UIColor grayColor];
            record.textAlignment = NSTextAlignmentRight;
            record.tag = 2;
            record.text = [NSString stringWithFormat:@"已阅读%d本",(int)arr.count];
            [cell.contentView addSubview:record];
            
            UILabel *  tips = [[UILabel alloc]initWithFrame:CGRectMake(200, 30, 160, 20)];
            tips.font = [UIFont systemFontOfSize:12];
            tips.textColor = [UIColor grayColor];
            tips.textAlignment = NSTextAlignmentRight;
            tips.tag = 3;
            tips.text = @"展示您的借阅记录";
            [cell.contentView addSubview:tips];
            
            return cell;
        }else{
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cellID4"];
        if(cell == nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cellID4"];
        }else{
            for(UIView * subView in cell.contentView.subviews){
                [subView removeFromSuperview];
            }
        }
        _con = [[UIImageView alloc]init];
        _con.frame = CGRectMake(148, 34, 80, 80);
        _con.layer.masksToBounds = YES;
        _con.layer.cornerRadius = 40;
        [cell.contentView addSubview:_con];
        
        UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(142, 134, 95, 16);
        btn.backgroundColor = [UIColor whiteColor];
        //btn.titleLabel.text = @"修改我的密码";
        [btn setTitle:@"编辑个人资料" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(chosePic) forControlEvents:UIControlEventTouchUpInside];
        btn.titleLabel.font = [UIFont systemFontOfSize:14];
        [cell.contentView addSubview: btn];
        
        UIButton * more = [UIButton buttonWithType:UIButtonTypeCustom];
        more.frame = CGRectMake(347, 70, 4.9, 9.3);
        [more setBackgroundImage:[UIImage imageNamed:@"更多.png"] forState:UIControlStateNormal];
        [more addTarget:self action:@selector(goUpdate) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:more];
        
        //1.获取路径
        NSArray * path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString * conPath = [NSString stringWithFormat:@"ConForUser/%@.jpg",_reader.reader_id];//存入用户头像
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
        
        return cell;
    }
}
- (void)goUpdate{
    More2 * more = [[More2 alloc]init];
    more.ReaderID = _ReaderID;
    [self.navigationController pushViewController:more animated:YES];
}

- (void)chosePic{
    UIActionSheet * sheet;
    if(![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        sheet = [[UIActionSheet alloc]initWithTitle:@"选择" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"取消" otherButtonTitles:@"拍照",@"从相册中选择", nil];
    }else{
        sheet = [[UIActionSheet alloc]
                 initWithTitle:@"选择"
                 delegate:self
                 cancelButtonTitle:nil
                 destructiveButtonTitle:@"取消"
                 otherButtonTitles:@"从相册选择", nil];
    }
    sheet.tag=255;
    [sheet showInView:self.view];
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(actionSheet.tag == 255){
        NSUInteger sourceType = 0;
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
            switch (buttonIndex) {
                case 0:
                    return;
                case 1:
                    sourceType = UIImagePickerControllerSourceTypeCamera;
                    break;
                case 2:
                    sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                default:
                    break;
            }
        }else{
            if(buttonIndex == 0){
                return;
            }else{
                sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            }
        }
        UIImagePickerController * pick = [[UIImagePickerController alloc]init];
        pick.delegate = self;
        pick.allowsEditing = YES;
        pick.sourceType = sourceType;
        [self presentViewController:pick animated:YES completion:nil];
    }
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    [picker dismissViewControllerAnimated:YES completion:nil];//返回到主界面
    //获取返回到照片
    UIImage * image = [info objectForKey:UIImagePickerControllerOriginalImage];
    //压缩图片
    NSData * imageData = UIImageJPEGRepresentation(image, 0.5);
    //沙盒准备保存图片到地址和图片名称
    /*NSString * conPath = [NSString stringWithFormat:@"%@.jpg",_admin.manager_id];
     NSString * fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Con"]stringByAppendingPathComponent:conPath];
     NSLog(@"存储成功:%@",fullPath);*/
    NSArray * path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * conPath = [NSString stringWithFormat:@"ConForUser/%@.jpg",_reader.reader_id];
    //NSString * fullPath = [[path objectAtIndex:0]stringByAppendingPathComponent:conPath];
    NSString * docPath = [path objectAtIndex:0];
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSString * fullPath = [docPath stringByAppendingString:conPath];
    [fileManager createDirectoryAtPath:[fullPath stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:nil];
    NSLog(@"存储成功:%@",fullPath);
    //图片写入文件中
    if(![imageData writeToFile: fullPath atomically:YES]){
        NSLog(@"存储其实失败了");
    }else{
        NSLog(@"存储其实成功了");
    }
    //通过路径获取图片，可以在主界面上的image进行预览
    UIImage * savedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    //_image.image = savedImage;
    dispatch_async(dispatch_get_main_queue(), ^{
        //_image.image = savedImage;//异步赋值
        _con.image = savedImage;
    });
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

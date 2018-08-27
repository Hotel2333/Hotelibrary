//
//  More.m
//  myLibrary
//
//  Created by 吕浩泰 on 2018/3/30.
//  Copyright © 2018年 吕浩泰. All rights reserved.
//

#import "More.h"
#import "ViewController.h"
#import "Admin+CoreDataProperties.h"
#import <CoreData/CoreData.h>
@interface More ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic, strong, readwrite)UITableView * mine;
@property(nonatomic, strong, readwrite)UIScrollView * scrollView;

@property(nonatomic, strong, readwrite)UIImageView * con;
@property(nonatomic, strong, readwrite)UILabel * nameLabel;

@property(nonatomic, strong, readwrite)Admin * admin;
@property(nonatomic, strong, readwrite)NSURL * modelURL;
@property(nonatomic, strong, readwrite)NSManagedObjectModel * mom;//数据库实例模型
@property(nonatomic, strong, readwrite)NSPersistentStoreCoordinator * psc;//持续化存储控制器
@property(nonatomic, strong, readwrite)NSURL * path;//路径
@property(nonatomic, strong, readwrite)NSManagedObjectContext * moc;//请求上下文
@property(nonatomic, strong, readwrite)NSFetchRequest * request;//发送请求
@property(nonatomic, strong, readwrite)NSArray * array;
@end

@implementation More

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
    
    self.title = _admin.name;
    
    
    _mine.delegate = self;
    _mine.dataSource = self;
    
    
    _mine = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.mine.delegate = self;
    self.mine.dataSource = self;
    self.mine.scrollEnabled = NO;
    self.mine.separatorStyle = UITableViewCellSeparatorStyleNone;//设置无底边
    
    UIButton * leave = [[UIButton alloc]initWithFrame:CGRectMake(36, 500, 300, 40)];
    [leave setBackgroundImage:[UIImage imageNamed:@"注销.png"] forState:UIControlStateNormal];
    [leave addTarget:self action:@selector(goLeave) forControlEvents:UIControlEventTouchUpInside];
    
    //[self.view addSubview:_mine];
    _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    _scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
    [self.scrollView addSubview:_mine];
    [self.scrollView addSubview:leave];
    [self.view addSubview:_scrollView];
    
}
- (void)goInit{
    _request = [NSFetchRequest fetchRequestWithEntityName:@"Admin"];//设置请求的实体
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"manager_id LIKE %@",_adminID];
    _request.predicate = predicate;//设置请求的条件
    NSError * error = nil;
    _array = [_moc executeFetchRequest:_request error:&error];
    _admin = _array[0];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == 0){
        return 1;
    }else{
        return 4;
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
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 1){
        if(indexPath.row == 0){
            UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
            if(cell == nil) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cellID"];
            }else{
                for(UIView * subView in cell.contentView.subviews){
                    [subView removeFromSuperview];
                }
            }
            cell.textLabel.text = [NSString stringWithFormat:@"用户名"];
            cell.textLabel.font = [UIFont systemFontOfSize:16];
            cell.imageView.image = [UIImage imageNamed:@"姓名.png"];
            
            _nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(200, 20, 160, 24)];
            _nameLabel.font = [UIFont systemFontOfSize:16];
            _nameLabel.textColor = [UIColor grayColor];
            _nameLabel.textAlignment = NSTextAlignmentRight;
            _nameLabel.text = _admin.name;
            [cell.contentView addSubview:_nameLabel];
          
            return cell;
        }else if(indexPath.row == 1){
            UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
            if(cell == nil) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cellID"];
            }else{
                for(UIView * subView in cell.contentView.subviews){
                    [subView removeFromSuperview];
                }
            }
            cell.textLabel.text = [NSString stringWithFormat:@"用户编号"];
            cell.textLabel.font = [UIFont systemFontOfSize:16];
            cell.imageView.image = [UIImage imageNamed:@"编号.png"];
            
            UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(200, 20, 160, 24)];
            label.font = [UIFont systemFontOfSize:16];
            label.textColor = [UIColor grayColor];
            label.textAlignment = NSTextAlignmentRight;
            label.text = _admin.manager_id;
            [cell.contentView addSubview:label];
            
            return cell;
        }else if(indexPath.row == 2){
            UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
            if(cell == nil) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cellID"];
            }else{
                for(UIView * subView in cell.contentView.subviews){
                    [subView removeFromSuperview];
                }
            }
            cell.textLabel.text = [NSString stringWithFormat:@"生日"];
            cell.textLabel.font = [UIFont systemFontOfSize:16];
            cell.imageView.image = [UIImage imageNamed:@"生日.png"];
            
            UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(200, 20, 160, 24)];
            label.font = [UIFont systemFontOfSize:16];
            label.textColor = [UIColor grayColor];
            label.textAlignment = NSTextAlignmentRight;
            label.text = _admin.birthday;
            [cell.contentView addSubview:label];
            
            return cell;
        }else{//if(indexPath.row == 3)
            UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
            if(cell == nil) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cellID"];
            }else{
                for(UIView * subView in cell.contentView.subviews){
                    [subView removeFromSuperview];
                }
            }
            cell.textLabel.text = [NSString stringWithFormat:@"注册时间"];
            cell.textLabel.font = [UIFont systemFontOfSize:16];
            cell.imageView.image = [UIImage imageNamed:@"注册时间.png"];
            
            UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(150, 20, 220, 24)];
            label.font = [UIFont systemFontOfSize:16];
            label.textColor = [UIColor grayColor];
            label.textAlignment = NSTextAlignmentRight;
            label.text = _admin.reg_date;
            [cell.contentView addSubview:label];
            
            return cell;
        }
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
        [btn setTitle:@"修改我的头像" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(chosePic) forControlEvents:UIControlEventTouchUpInside];
        btn.titleLabel.font = [UIFont systemFontOfSize:14];
        [cell.contentView addSubview: btn];
        /*
        UIButton * more = [UIButton buttonWithType:UIButtonTypeCustom];
        more.frame = CGRectMake(347, 70, 4.9, 9.3);
        [more setBackgroundImage:[UIImage imageNamed:@"更多.png"] forState:UIControlStateNormal];
        [cell.contentView addSubview:more];*/
        
        //1.获取路径
        NSArray * path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString * conPath = [NSString stringWithFormat:@"ConForAdmin/%@.jpg",_admin.manager_id];//存入用户头像
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
}- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 1 && indexPath.row == 0){
        UIAlertController * alertView = [UIAlertController alertControllerWithTitle:@"修改我的用户名" message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alertView addTextFieldWithConfigurationHandler:nil];
        UIAlertAction * yes = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            _request = [NSFetchRequest fetchRequestWithEntityName:@"Admin"];
            NSArray * names = [_moc executeFetchRequest:_request error:nil];
            int flag = 0;
            for(Admin * obj in names){
                if([alertView.textFields.firstObject.text isEqualToString:obj.name]){
                    flag = 1;
                }
            }
            if(flag == 0){
                _admin.name = alertView.textFields.firstObject.text;//修改用户名
                if([_moc save:nil]){
                    UIAlertController * alertView2 = [UIAlertController alertControllerWithTitle:@"成功" message:@"用户名修改成功" preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction * done = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleCancel handler:nil];
                    [alertView2 addAction:done];
                    //[_moc refreshAllObjects];
                    //[self goInit];
                    //[self.mine reloadData];
                    _nameLabel.text = alertView.textFields.firstObject.text;
                    [self presentViewController:alertView2 animated:YES completion:nil];
                }else{
                    UIAlertController * alertView2 = [UIAlertController alertControllerWithTitle:@"错误" message:@"存储失败" preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction * done = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleCancel handler:nil];
                    [alertView2 addAction:done];
                    [self presentViewController:alertView2 animated:YES completion:nil];
                }
            }else{
                UIAlertController * alertView2 = [UIAlertController alertControllerWithTitle:@"错误" message:@"该用户名已被使用" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction * done = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleCancel handler:nil];
                [alertView2 addAction:done];
                [self presentViewController:alertView2 animated:YES completion:nil];
            }
        }];
        UIAlertAction * no = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [alertView addAction:yes];
        [alertView addAction:no];
        [self presentViewController:alertView animated:YES completion:nil];
    }
}
- (void)goLeave{
    ViewController * view = [[ViewController alloc]init];
    [self presentViewController:view animated:YES completion:nil];
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
    NSString * conPath = [NSString stringWithFormat:@"ConForAdmin/%@.jpg",_admin.manager_id];
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

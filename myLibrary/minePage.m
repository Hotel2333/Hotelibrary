//
//  minePage.m
//  myLibrary
//
//  Created by 吕浩泰 on 2018/3/13.
//  Copyright © 2018年 吕浩泰. All rights reserved.
//

#import "minePage.h"
//#import "con.h"
#import "More.h"
#import "record.h"
#import "upLoadBook.h"
#import "Admin+CoreDataProperties.h"
#import "Department+CoreDataProperties.h"
#import "Classification+CoreDataProperties.h"
#import <CoreData/CoreData.h>
#import "ViewController.h"
#import "Regis2.h"
#import "RegisAdmin2.h"
#import "AppDelegate.h" //引入头文件
@interface minePage ()<UITableViewDataSource,UITableViewDelegate,NSFetchedResultsControllerDelegate,UIActionSheetDelegate>
@property(nonatomic, strong, readwrite)UITableView * mine;
@property(nonatomic, strong, readwrite)UIImageView * con;

@property(nonatomic, strong, readwrite)Admin * admin;
@property(nonatomic, strong, readwrite)NSURL * modelURL;
@property(nonatomic, strong, readwrite)NSManagedObjectModel * mom;//数据库实例模型
@property(nonatomic, strong, readwrite)NSPersistentStoreCoordinator * psc;//持续化存储控制器
@property(nonatomic, strong, readwrite)NSURL * path;//路径
@property(nonatomic, strong, readwrite)NSManagedObjectContext * moc;//请求上下文
@property(nonatomic, strong, readwrite)NSFetchRequest * request;//发送请求
@property(nonatomic, strong, readwrite)NSArray * array;

@property(nonatomic, strong, readwrite)UILabel * department;

@end

@implementation minePage

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
    
    self.title = _admin.name;
    
    
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
    _request = [NSFetchRequest fetchRequestWithEntityName:@"Admin"];//设置请求的实体
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"manager_id LIKE %@",_adminID];
    _request.predicate = predicate;//设置请求的条件
    NSError * error = nil;
    _array = [_moc executeFetchRequest:_request error:&error];
    _admin = _array[0];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == 0){
        return 1;
    }else if(section == 1){
        return 2;
    }else {
        return 3;
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
    if(indexPath.section == 1 && indexPath.row == 1){//点击处理记录
        record * rec = [[record alloc]init];
        [self.navigationController pushViewController:rec animated:YES];
    }else if(indexPath.section == 2 && indexPath.row == 0){//点击录入图书
        UIAlertController * alertView = [UIAlertController alertControllerWithTitle:nil message:@"请选择录入内容" preferredStyle:UIAlertControllerStyleActionSheet];//活动列表风格
        UIAlertAction * action1 = [UIAlertAction actionWithTitle:@"录入图书" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            upLoadBook * uploadbook = [[upLoadBook alloc]init];
            uploadbook.adminID = _adminID;
            [self.navigationController pushViewController:uploadbook animated:YES];
            //[self presentViewController:uploadbook animated:YES completion:nil];
        }];
        UIAlertAction * action2 = [UIAlertAction actionWithTitle:@"录入图书类型" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            UIAlertController * alertView2 = [UIAlertController alertControllerWithTitle:@"请输入分类名称" message:nil preferredStyle:UIAlertControllerStyleAlert];//风格必须为Alert,否则无法添加输入框
            Classification * class = [NSEntityDescription insertNewObjectForEntityForName:@"Classification" inManagedObjectContext:_moc];
            [alertView2 addTextFieldWithConfigurationHandler:nil];
            UIAlertAction * done = [UIAlertAction actionWithTitle:@"下一步" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                UIAlertController * alertView3 = [UIAlertController alertControllerWithTitle:@"请输入分类信息" message:nil preferredStyle:UIAlertControllerStyleAlert];
                [alertView3 addTextFieldWithConfigurationHandler:nil];
                UIAlertAction * done2 = [UIAlertAction actionWithTitle:@"完成" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    class.class_name = alertView2.textFields.firstObject.text;
                    class.tips = alertView3.textFields.firstObject.text;
                    NSError * error = nil;
                    if([_moc save:&error]){
                        NSString * info = [NSString stringWithFormat:@"%@分类(%@)已成功录入",class.class_name,class.tips];
                        UIAlertController * alertView4 = [UIAlertController alertControllerWithTitle:@"成功" message:info preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction * done3 = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil];
                        [alertView4 addAction:done3];
                        [self presentViewController:alertView4 animated:YES completion:nil];
                    }else{
                        NSString * info = [NSString stringWithFormat:@"%@分类(%@)录入失败且错误信息为:%@",class.class_name,class.tips,error];
                        UIAlertController * alertView4 = [UIAlertController alertControllerWithTitle:@"失败" message:info preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction * done3 = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDestructive handler:nil];
                        [alertView4 addAction:done3];
                        [self presentViewController:alertView4 animated:YES completion:nil];
                    }
                }];
                UIAlertAction * cancel2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:nil];
                [alertView3 addAction:cancel2];
                [alertView3 addAction:done2];
                [self presentViewController:alertView3 animated:YES completion:nil];
            }];
            UIAlertAction * cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:nil];
            [alertView2 addAction:cancel];
            [alertView2 addAction:done];
            [self presentViewController:alertView2 animated:YES completion:nil];
        }];
        UIAlertAction * action3 = [UIAlertAction actionWithTitle:@"展示现有图书类型" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            _request = [NSFetchRequest fetchRequestWithEntityName:@"Classification"];//设置请求的实体
            NSError * error = nil;
            _array = [_moc executeFetchRequest:_request error:&error];
            if(_array.count == 0){
                UIAlertController * alertView2 = [UIAlertController alertControllerWithTitle:@"警告" message:@"没有找到任何分类信息" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction * action = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleCancel handler:nil];
                [alertView2 addAction:action];
                [self presentViewController:alertView2 animated:YES completion:nil];
            }else{
                UIAlertController * alertView2 = [UIAlertController alertControllerWithTitle:@"图书分类" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
                for(Classification * obj in _array){
                    NSString * class_name = [NSString stringWithFormat:@"%@",obj.class_name];
                    NSString * tips = [NSString stringWithFormat:@"%@",obj.tips];
                    UIAlertAction * action = [UIAlertAction actionWithTitle:class_name style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        NSLog(@"%@分类:%@",class_name,tips);
                    }];
                    [alertView2 addAction:action];
                }
                UIAlertAction * cancel = [UIAlertAction actionWithTitle:@"返回" style:UIAlertActionStyleDestructive handler:nil];
                [alertView2 addAction:cancel];
                [self presentViewController:alertView2 animated:YES completion:nil];
            }
        }];
        UIAlertAction * action4 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        UIAlertAction * action5 = [UIAlertAction actionWithTitle:@"删除现有图书类型" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            UIAlertController * list = [UIAlertController alertControllerWithTitle:@"选择需要删除的类型" message:@"一旦删除无法还原，请慎重选择" preferredStyle:UIAlertControllerStyleActionSheet];
            _request = [NSFetchRequest fetchRequestWithEntityName:@"Classification"];
            NSArray * classList = [_moc executeFetchRequest:_request error:nil];
            int classNum = (int)classList.count;
            if(classNum == 0){
                UIAlertController * warning = [UIAlertController alertControllerWithTitle:@"错误" message:@"没有找到任何分类信息" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction * leave = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleCancel handler:nil];
                [warning addAction:leave];
                [self presentViewController:warning animated:YES completion:nil];
            }else{
                for(Classification * obj in classList){
                    UIAlertAction * action = [UIAlertAction actionWithTitle:obj.class_name style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        _request = [NSFetchRequest fetchRequestWithEntityName:@"Classification"];
                        NSPredicate * pre = [NSPredicate predicateWithFormat:@"class_name LIKE %@",obj.class_name];
                        _request.predicate = pre;
                        NSArray * class = [_moc executeFetchRequest:_request error:nil];
                        for(Classification * obj2 in class){
                            [_moc deleteObject:obj2];
                            [_moc save:nil];
                        }
                    }];
                    [list addAction:action];
                }
                UIAlertAction * cancelDelete = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
                [list addAction:cancelDelete];
                [self presentViewController:list animated:YES completion:nil];
            }
        }];
        [alertView addAction:action1];
        [alertView addAction:action2];
        [alertView addAction:action3];
        [alertView addAction:action5];
        [alertView addAction:action4];
        [self presentViewController:alertView animated:YES completion:nil];
    }else if(indexPath.section == 1 && indexPath.row == 0){
        UIAlertController * alertView = [UIAlertController alertControllerWithTitle:nil message:@"请选择您想进行的操作" preferredStyle:UIAlertControllerStyleActionSheet];//活动列表风格
        UIAlertAction * action1 = [UIAlertAction actionWithTitle:@"修改我的部门" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            _request = [NSFetchRequest fetchRequestWithEntityName:@"Department"];//设置请求的实体
            NSError * error = nil;
            NSArray * des = [_moc executeFetchRequest:_request error:&error];
            int desN = (int)des.count;
            if(desN == 0){
                UIAlertController * alertView2 = [UIAlertController alertControllerWithTitle:@"警告" message:@"没有找到任何部门信息" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction * action = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleCancel handler:nil];
                [alertView2 addAction:action];
                [self presentViewController:alertView2 animated:YES completion:nil];
            }else{
                UIAlertController * alertView2 = [UIAlertController alertControllerWithTitle:@"请选择你的部门" message:@"点击以展示部门详情" preferredStyle:UIAlertControllerStyleActionSheet];
                for(Department * obj in des){
                    NSString * dept_name = [NSString stringWithFormat:@"%@",obj.dept_name];
                    NSString * tips = [NSString stringWithFormat:@"%@",obj.tips];//尚未使用
                    UIAlertAction * action = [UIAlertAction actionWithTitle:dept_name style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        NSString * str = [NSString stringWithFormat:@"确认选择%@部门(%@)吗",dept_name,tips];
                        UIAlertController * alertView3 = [UIAlertController alertControllerWithTitle:@"再次确认" message:str preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction * yes = [UIAlertAction actionWithTitle:@"是的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                            NSLog(@"%@部门:%@",dept_name,tips);
                            _admin.dept_name = dept_name;
                            [_moc save:nil];
                            [_mine reloadData];
                        }];
                        UIAlertAction * no = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
                        [alertView3 addAction:yes];
                        [alertView3 addAction:no];
                        [self presentViewController:alertView3 animated:YES completion:nil];
                    }];
                    [alertView2 addAction:action];
                }
                UIAlertAction * cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
                [alertView2 addAction:cancel];
                [self presentViewController:alertView2 animated:YES completion:nil];
            }
        }];
        UIAlertAction * action2 = [UIAlertAction actionWithTitle:@"录入新的部门" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            UIAlertController * alertView2 = [UIAlertController alertControllerWithTitle:@"请输入部门名称" message:nil preferredStyle:UIAlertControllerStyleAlert];//风格必须为Alert,否则无法添加输入框
            Department * dept = [NSEntityDescription insertNewObjectForEntityForName:@"Department" inManagedObjectContext:_moc];
            [alertView2 addTextFieldWithConfigurationHandler:nil];
            UIAlertAction * done = [UIAlertAction actionWithTitle:@"下一步" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                UIAlertController * alertView3 = [UIAlertController alertControllerWithTitle:@"请输入部门信息" message:nil preferredStyle:UIAlertControllerStyleAlert];
                [alertView3 addTextFieldWithConfigurationHandler:nil];
                UIAlertAction * done2 = [UIAlertAction actionWithTitle:@"完成" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    dept.dept_name = alertView2.textFields.firstObject.text;
                    dept.tips = alertView3.textFields.firstObject.text;
                    NSError * error = nil;
                    if([_moc save:&error]){
                        NSString * info = [NSString stringWithFormat:@"%@部门(%@)已成功录入",dept.dept_name,dept.tips];
                        UIAlertController * alertView4 = [UIAlertController alertControllerWithTitle:@"成功" message:info preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction * done3 = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil];
                        [alertView4 addAction:done3];
                        [self presentViewController:alertView4 animated:YES completion:nil];
                    }else{
                        NSString * info = [NSString stringWithFormat:@"%@部门(%@)录入失败且错误信息为:%@",dept.dept_name,dept.tips,error];
                        UIAlertController * alertView4 = [UIAlertController alertControllerWithTitle:@"失败" message:info preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction * done3 = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDestructive handler:nil];
                        [alertView4 addAction:done3];
                        [self presentViewController:alertView4 animated:YES completion:nil];
                    }
                }];
                UIAlertAction * cancel2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:nil];
                [alertView3 addAction:cancel2];
                [alertView3 addAction:done2];
                [self presentViewController:alertView3 animated:YES completion:nil];
            }];
            UIAlertAction * cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:nil];
            [alertView2 addAction:cancel];
            [alertView2 addAction:done];
            [self presentViewController:alertView2 animated:YES completion:nil];
        }];
        UIAlertAction * action3 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        UIAlertAction * action4 = [UIAlertAction actionWithTitle:@"删除现有部门信息" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //提供选择
            _request = [NSFetchRequest fetchRequestWithEntityName:@"Department"];
            NSArray * depts = [_moc executeFetchRequest:_request error:nil];
            int deptNum = (int)depts.count;
            if(deptNum == 0){
                UIAlertController * warning = [UIAlertController alertControllerWithTitle:@"错误" message:@"没有找到任何部门信息" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction * leave = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleCancel handler:nil];
                [warning addAction:leave];
                [self presentViewController:warning animated:YES completion:nil];
            }else{
                UIAlertController * list = [UIAlertController alertControllerWithTitle:@"请选择删除的部门" message:@"一旦删除无法还原" preferredStyle:UIAlertControllerStyleActionSheet];
                
                for(Department * dept in depts){
                    UIAlertAction * section = [UIAlertAction actionWithTitle:dept.dept_name style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        [_moc deleteObject:dept];
                        [_moc save:nil];
                    }];
                    [list addAction:section];
                }
                UIAlertAction * cancelDelete = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
                [list addAction:cancelDelete];
                [self presentViewController:list animated:YES completion:nil];
            }
        }];
        [alertView addAction:action1];
        [alertView addAction:action2];
        [alertView addAction:action4];
        [alertView addAction:action3];
        [self presentViewController:alertView animated:YES completion:nil];
    }else if(indexPath.section == 2 && indexPath.row == 1){
        UIAlertController * alertView = [UIAlertController alertControllerWithTitle:nil message:@"请选择您想进行的操作" preferredStyle:UIAlertControllerStyleActionSheet];//活动列表风格
        UIAlertAction * action1 = [UIAlertAction actionWithTitle:@"录入新的用户" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            Regis2 * regis2 = [[Regis2 alloc]init];
            regis2.adminID = _adminID;
            [self.navigationController pushViewController:regis2 animated:YES];
        }];
        UIAlertAction * action2 = [UIAlertAction actionWithTitle:@"展示我录入的用户" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //等待开发
        }];
        UIAlertAction * action3 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alertView addAction:action1];
        [alertView addAction:action2];
        [alertView addAction:action3];
        [self presentViewController:alertView animated:YES completion:nil];
    }else if(indexPath.section == 2 && indexPath.row == 2){
        RegisAdmin2 * regisAdmin2 = [[RegisAdmin2 alloc]init];
        regisAdmin2.adminID = _adminID;
        [self.navigationController pushViewController:regisAdmin2 animated:YES];
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
            cell.textLabel.text = [NSString stringWithFormat:@"部门"];
            cell.textLabel.font = [UIFont systemFontOfSize:16];
            cell.imageView.image = [UIImage imageNamed:@"部门.png"];

            _department = [[UILabel alloc]initWithFrame:CGRectMake(200, 20, 160, 24)];
            _department.font = [UIFont systemFontOfSize:16];
            _department.textColor = [UIColor grayColor];
            _department.textAlignment = NSTextAlignmentRight;
            _department.tag = 1;
            //department.text = @"团学宣传部";
            _department.text = [NSString stringWithFormat:@"%@",_admin.dept_name];
            [cell.contentView addSubview:_department];
            
            return cell;
        }else {
            UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
            if(cell == nil) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cellID"];
            }else{
                for(UIView * subView in cell.contentView.subviews){
                    [subView removeFromSuperview];
                }
            }
            cell.textLabel.text = [NSString stringWithFormat:@"处理记录"];
            cell.textLabel.font = [UIFont systemFontOfSize:16];
            cell.imageView.image = [UIImage imageNamed:@"处理记录.png"];
            
            UILabel * record = [[UILabel alloc]initWithFrame:CGRectMake(200, 10, 160, 20)];
            record.font = [UIFont systemFontOfSize:16];
            record.textColor = [UIColor grayColor];
            record.textAlignment = NSTextAlignmentRight;
            record.tag = 2;
            //record.text = @"10条";
            //搜素当前所有的处理记录总数
            //获取借出列表
            _request = [NSFetchRequest fetchRequestWithEntityName:@"Borrow"];
            NSSortDescriptor * idSort = [NSSortDescriptor sortDescriptorWithKey:@"book_id" ascending:YES];
            _request.sortDescriptors = @[idSort];
            NSArray * borrowArray = [_moc executeFetchRequest:_request error:nil];
            //获取归还列表
            _request = [NSFetchRequest fetchRequestWithEntityName:@"Return"];
            _request.sortDescriptors = @[idSort];
            NSArray *  returnArray = [_moc executeFetchRequest:_request error:nil];
            //获取处罚列表
            _request = [NSFetchRequest fetchRequestWithEntityName:@"Punish"];
            NSSortDescriptor * priceSort = [NSSortDescriptor sortDescriptorWithKey:@"punish_free" ascending:YES];
            _request.sortDescriptors = @[priceSort];
            NSArray * punishArray = [_moc executeFetchRequest:_request error:nil];
            //合并数组
            NSMutableArray * arrForRecords = [NSMutableArray arrayWithArray:borrowArray];
            [arrForRecords addObjectsFromArray:returnArray];
            [arrForRecords addObjectsFromArray:punishArray];
            NSArray * records  = [arrForRecords copy];
            record.text = [NSString stringWithFormat:@"%d条",(int)records.count];
            [cell.contentView addSubview:record];
            
            UILabel *  tips = [[UILabel alloc]initWithFrame:CGRectMake(200, 30, 160, 20)];
            tips.font = [UIFont systemFontOfSize:12];
            tips.textColor = [UIColor grayColor];
            tips.textAlignment = NSTextAlignmentRight;
            tips.tag = 3;
            tips.text = @"展示全平台的处理的记录";
            [cell.contentView addSubview:tips];
            
            return cell;
        }
    }else if(indexPath.section == 2){
        if(indexPath.row == 0){
            UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cellID1"];
            if(cell == nil) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cellID1"];
            }else{
                for(UIView * subView in cell.contentView.subviews){
                    [subView removeFromSuperview];
                }
            }
            cell.textLabel.text = [NSString stringWithFormat:@"录入图书"];
            cell.textLabel.font = [UIFont systemFontOfSize:16];
            cell.imageView.image = [UIImage imageNamed:@"录入书本.png"];
            
            UILabel * record = [[UILabel alloc]initWithFrame:CGRectMake(200, 10, 160, 20)];
            record.font = [UIFont systemFontOfSize:16];
            record.textColor = [UIColor grayColor];
            record.textAlignment = NSTextAlignmentRight;
            record.tag = 4;
            //record.text = @"8本";
            record.text = [NSString stringWithFormat:@"%d本",_admin.inBook];
            NSLog(@"我一共存入了%d本书",_admin.inBook);
            [cell.contentView addSubview:record];
            
            UILabel *  tips = [[UILabel alloc]initWithFrame:CGRectMake(200, 30, 160, 20)];
            tips.font = [UIFont systemFontOfSize:12];
            tips.textColor = [UIColor grayColor];
            tips.textAlignment = NSTextAlignmentRight;
            tips.tag = 5;
            tips.text = @"展示已有的图书类型";
            [cell.contentView addSubview:tips];
            
            return cell;
        }else if(indexPath.row == 1){
            UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cellID2"];
            if(cell == nil) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cellID2"];
            }else{
                for(UIView * subView in cell.contentView.subviews){
                    [subView removeFromSuperview];
                }
            }
            cell.textLabel.text = [NSString stringWithFormat:@"录入用户"];
            cell.textLabel.font = [UIFont systemFontOfSize:16];
            cell.imageView.image = [UIImage imageNamed:@"录入用户.png"];
            
            UILabel * record = [[UILabel alloc]initWithFrame:CGRectMake(200, 10, 160, 20)];
            record.font = [UIFont systemFontOfSize:16];
            record.textColor = [UIColor grayColor];
            record.textAlignment = NSTextAlignmentRight;
            record.tag = 6;
            //record.text = @"共300人";
            //查询当前平台读者总人数
            _request = [NSFetchRequest fetchRequestWithEntityName:@"User"];
            NSArray * users = [_moc executeFetchRequest:_request error:nil];
            record.text = [NSString stringWithFormat:@"共%d人",(int)users.count];
            [cell.contentView addSubview:record];
            
            UILabel *  tips = [[UILabel alloc]initWithFrame:CGRectMake(200, 30, 160, 20)];
            tips.font = [UIFont systemFontOfSize:12];
            tips.textColor = [UIColor grayColor];
            tips.textAlignment = NSTextAlignmentRight;
            tips.tag = 7;
            //tips.text = @"你已录入了250人";
            tips.text = [NSString stringWithFormat:@"你已录入了%d人",_admin.inUser];
            [cell.contentView addSubview:tips];
            return cell;
        }else{
            UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cellID3"];
            if(cell == nil) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cellID3"];
            }else{
                for(UIView * subView in cell.contentView.subviews){
                    [subView removeFromSuperview];
                }
            }
            cell.textLabel.text = [NSString stringWithFormat:@"录入管理员"];
            cell.textLabel.font = [UIFont systemFontOfSize:16];
            cell.imageView.image = [UIImage imageNamed:@"录入管理员.png"];
            
            UILabel * record = [[UILabel alloc]initWithFrame:CGRectMake(200, 10, 160, 20)];
            record.font = [UIFont systemFontOfSize:16];
            record.textColor = [UIColor grayColor];
            record.textAlignment = NSTextAlignmentRight;
            record.tag = 8;
            //record.text = @"共12人";
            //查询当前平台管理员总个数
            _request = [NSFetchRequest fetchRequestWithEntityName:@"Admin"];
            NSArray * admins = [_moc executeFetchRequest:_request error:nil];
            record.text = [NSString stringWithFormat:@"共%d人",(int)admins.count];
            [cell.contentView addSubview:record];
            
            UILabel *  tips = [[UILabel alloc]initWithFrame:CGRectMake(200, 30, 160, 20)];
            tips.font = [UIFont systemFontOfSize:12];
            tips.textColor = [UIColor grayColor];
            tips.textAlignment = NSTextAlignmentRight;
            tips.tag = 9;
            tips.text = [NSString stringWithFormat:@"你已录入了%d人",_admin.inManager];
            [cell.contentView addSubview:tips];
            
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
        [btn setTitle:@"编辑个人资料" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(chosePic) forControlEvents:UIControlEventTouchUpInside];
        btn.titleLabel.font = [UIFont systemFontOfSize:14];
        [cell.contentView addSubview: btn];
        
        UIButton * more = [UIButton buttonWithType:UIButtonTypeCustom];
        more.frame = CGRectMake(347, 70, 4.9, 9.3);
        [more setBackgroundImage:[UIImage imageNamed:@"更多.png"] forState:UIControlStateNormal];
        [more addTarget:self action:@selector(updateInfo) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:more];
        
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
}
- (void)updateInfo{
    More * more = [[More alloc]init];
    more.adminID = _adminID;
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
    // Pas the selected object to the new view controller.
}
*/

             
        
@end

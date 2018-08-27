//
//  con.m
//  myLibrary
//
//  Created by 吕浩泰 on 2018/3/14.
//  Copyright © 2018年 吕浩泰. All rights reserved.
//

#import "con.h"
#import "Admin+CoreDataProperties.h"
#import <CoreData/CoreData.h>
@implementation con

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        _con = [[UIImageView alloc]init];
        _con.frame = CGRectMake(148, 34, 80, 80);
        _con.layer.masksToBounds = YES;
        _con.layer.cornerRadius = 40;
        [self addSubview:_con];
        
        _btn = [UIButton buttonWithType:UIButtonTypeCustom];
        _btn.frame = CGRectMake(142, 134, 95, 16);
        _btn.backgroundColor = [UIColor whiteColor];
        //btn.titleLabel.text = @"修改我的密码";
        [_btn setTitle:@"编辑个人资料" forState:UIControlStateNormal];
        [_btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_btn addTarget:self action:@selector(chosePic) forControlEvents:UIControlEventTouchUpInside];
        _btn.titleLabel.font = [UIFont systemFontOfSize:14];
        [self addSubview:_btn];
        
        UIButton * more = [UIButton buttonWithType:UIButtonTypeCustom];
        more.frame = CGRectMake(347, 70, 4.9, 9.3);
        [more setBackgroundImage:[UIImage imageNamed:@"更多.png"] forState:UIControlStateNormal];
        [self addSubview:more];
        
        [self goSearch];
        NSArray * path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString * conPath = [NSString stringWithFormat:@"Con/%@.jpg",_admin.manager_id];
        NSString * docPath = [path objectAtIndex:0];
        NSFileManager * fileManager = [NSFileManager defaultManager];
        NSString * cachesPath = [docPath stringByAppendingString:conPath];
        [fileManager createDirectoryAtPath:[cachesPath stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:nil];
        UIImage * image = [UIImage imageWithContentsOfFile:cachesPath];
        if(image == nil){
            [_con setImage:[UIImage imageNamed:@"头像.png"]];
            NSLog(@"数据库中没有存有本用户的头像");
        }else{
            [_con setImage:image];
            NSLog(@"头像查询成功并已设置");
        }
    }
    return self;
}
- (void)goSearch{
    _request = [NSFetchRequest fetchRequestWithEntityName:@"Admin"];//设置请求的实体
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"name LIKE %@",_adminID];
    _request.predicate = predicate;//设置请求的条件
    NSError * error = nil;
    _array = [_moc executeFetchRequest:_request error:&error];
    _admin = _array[0];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
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
@end

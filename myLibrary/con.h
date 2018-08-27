//
//  con.h
//  myLibrary
//
//  Created by 吕浩泰 on 2018/3/14.
//  Copyright © 2018年 吕浩泰. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Admin+CoreDataProperties.h"
#import <CoreData/CoreData.h>
@interface con : UITableViewCell
@property(nonatomic, copy)NSString * adminID;
@property(nonatomic, strong, readwrite)UIImageView * con;
@property(nonatomic, strong, readwrite)UIButton * btn;

@property(nonatomic, strong, readwrite)Admin * admin;
@property(nonatomic, strong, readwrite)NSURL * modelURL;
@property(nonatomic, strong, readwrite)NSManagedObjectModel * mom;//数据库实例模型
@property(nonatomic, strong, readwrite)NSPersistentStoreCoordinator * psc;//持续化存储控制器
@property(nonatomic, strong, readwrite)NSURL * path;//路径
@property(nonatomic, strong, readwrite)NSManagedObjectContext * moc;//请求上下文
@property(nonatomic, strong, readwrite)NSFetchRequest * request;//发送请求
@property(nonatomic, strong, readwrite)NSArray * array;
- (NSManagedObjectModel *)managedObjectModel;
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;
- (nullable NSURL *)doucumentDirectoryURL;
- (NSManagedObjectContext *)context;
@end

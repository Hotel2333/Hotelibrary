//
//  ViewController.h
//  myLibrary
//
//  Created by 吕浩泰 on 2018/3/13.
//  Copyright © 2018年 吕浩泰. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "User+CoreDataProperties.h"
@interface ViewController : UIViewController
@property(nonatomic, copy)NSString * adminID;
@property(nonatomic, copy)NSString * readerID;
//CoreData代码
- (NSManagedObjectModel *)managedObjectModel;
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;
- (nullable NSURL *)doucumentDirectoryURL;
- (NSManagedObjectContext *)context;

- (int)isRepeat;//判断重复
- (void)initNextView;//初始化下一个界面

@end


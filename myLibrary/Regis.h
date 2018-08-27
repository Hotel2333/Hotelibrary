//
//  Regis.h
//  myLibrary
//
//  Created by 吕浩泰 on 2018/3/14.
//  Copyright © 2018年 吕浩泰. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User+CoreDataProperties.h"
#import <sqlite3.h>
@interface Regis : UIViewController
//Sqlite3代码
//- (sqlite3 *)openDB;
//- (void)closeDB;
//- (void)insertWithUser:(User *)user;
//CoreData代码
- (NSManagedObjectModel *)managedObjectModel;
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;
- (nullable NSURL *)doucumentDirectoryURL;
- (NSManagedObjectContext *)context;
//其他
- (void)showDataPicker;
@end

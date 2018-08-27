//
//  upLoadBook.h
//  myLibrary
//
//  Created by 吕浩泰 on 2018/3/19.
//  Copyright © 2018年 吕浩泰. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Admin+CoreDataProperties.h"
@interface upLoadBook : UIViewController
@property(nonatomic, assign)NSString * adminID;
//CoreData代码（存数据准备）
- (NSManagedObjectModel *)managedObjectModel;
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;
- (nullable NSURL *)doucumentDirectoryURL;
- (NSManagedObjectContext *)context;
@end

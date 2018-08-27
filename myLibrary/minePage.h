//
//  minePage.h
//  myLibrary
//
//  Created by 吕浩泰 on 2018/3/13.
//  Copyright © 2018年 吕浩泰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface minePage : UIViewController
@property(nonatomic, copy)NSString * adminID;
//CoreData代码
- (NSManagedObjectModel *)managedObjectModel;
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;
- (nullable NSURL *)doucumentDirectoryURL;
- (NSManagedObjectContext *)context;

- (void)goInit;
@end

//
//  RegisAdmin2.h
//  myLibrary
//
//  Created by 吕浩泰 on 2018/3/30.
//  Copyright © 2018年 吕浩泰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegisAdmin2 : UIViewController
@property(nonatomic, copy)NSString * adminID;
//CoreData代码
- (NSManagedObjectModel *)managedObjectModel;
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;
- (nullable NSURL *)doucumentDirectoryURL;
- (NSManagedObjectContext *)context;
//其他
- (void)showDataPicker;
@end

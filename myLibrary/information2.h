//
//  information2.h
//  myLibrary
//
//  Created by 吕浩泰 on 2018/3/29.
//  Copyright © 2018年 吕浩泰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface information2 : UIViewController
@property(nonatomic, strong, readwrite)NSString * ReaderID;
@property(nonatomic, strong, readwrite)NSString * bookID;
//CoreData代码
- (NSManagedObjectModel *)managedObjectModel;
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;
- (nullable NSURL *)doucumentDirectoryURL;
- (NSManagedObjectContext *)context;
@end

//
//  User+CoreDataClass.h
//  myLibrary
//
//  Created by 吕浩泰 on 2018/3/18.
//  Copyright © 2018年 吕浩泰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Borrow, Punish, Return;

NS_ASSUME_NONNULL_BEGIN

@interface User : NSManagedObject

@end

NS_ASSUME_NONNULL_END

#import "User+CoreDataProperties.h"

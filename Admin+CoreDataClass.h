//
//  Admin+CoreDataClass.h
//  myLibrary
//
//  Created by 吕浩泰 on 2018/3/18.
//  Copyright © 2018年 吕浩泰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Borrow, Department, Punish, Return;

NS_ASSUME_NONNULL_BEGIN

@interface Admin : NSManagedObject

@end

NS_ASSUME_NONNULL_END

#import "Admin+CoreDataProperties.h"

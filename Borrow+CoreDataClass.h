//
//  Borrow+CoreDataClass.h
//  myLibrary
//
//  Created by 吕浩泰 on 2018/3/17.
//  Copyright © 2018年 吕浩泰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Book, Manager, Reader;

NS_ASSUME_NONNULL_BEGIN

@interface Borrow : NSManagedObject

@end

NS_ASSUME_NONNULL_END

#import "Borrow+CoreDataProperties.h"

//
//  Department+CoreDataProperties.h
//  myLibrary
//
//  Created by 吕浩泰 on 2018/3/18.
//  Copyright © 2018年 吕浩泰. All rights reserved.
//

#import "Department+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Department (CoreDataProperties)

+ (NSFetchRequest<Department *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *dept_name;
@property (nullable, nonatomic, copy) NSString *tips;
@property (nullable, nonatomic, retain) NSSet<Admin *> *manager;

@end

@interface Department (CoreDataGeneratedAccessors)

- (void)addManagerObject:(Admin *)value;
- (void)removeManagerObject:(Admin *)value;
- (void)addManager:(NSSet<Admin *> *)values;
- (void)removeManager:(NSSet<Admin *> *)values;

@end

NS_ASSUME_NONNULL_END

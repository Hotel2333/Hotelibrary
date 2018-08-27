//
//  Department+CoreDataProperties.m
//  myLibrary
//
//  Created by 吕浩泰 on 2018/3/18.
//  Copyright © 2018年 吕浩泰. All rights reserved.
//

#import "Department+CoreDataProperties.h"

@implementation Department (CoreDataProperties)

+ (NSFetchRequest<Department *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Department"];
}

@dynamic dept_name;
@dynamic tips;
@dynamic manager;

@end

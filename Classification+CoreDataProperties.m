//
//  Classification+CoreDataProperties.m
//  myLibrary
//
//  Created by 吕浩泰 on 2018/3/18.
//  Copyright © 2018年 吕浩泰. All rights reserved.
//

#import "Classification+CoreDataProperties.h"

@implementation Classification (CoreDataProperties)

+ (NSFetchRequest<Classification *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Classification"];
}

@dynamic class_name;
@dynamic tips;
@dynamic book;

@end

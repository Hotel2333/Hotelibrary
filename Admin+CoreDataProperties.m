//
//  Admin+CoreDataProperties.m
//  myLibrary
//
//  Created by 吕浩泰 on 2018/3/18.
//  Copyright © 2018年 吕浩泰. All rights reserved.
//

#import "Admin+CoreDataProperties.h"

@implementation Admin (CoreDataProperties)

+ (NSFetchRequest<Admin *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Admin"];
}

@dynamic birthday;
@dynamic dept_name;
@dynamic isSenior;
@dynamic manager_id;
@dynamic name;
@dynamic password;
@dynamic reg_date;
@dynamic department;
@dynamic manager_borrow;
@dynamic manager_punish;
@dynamic manager_return;

@end

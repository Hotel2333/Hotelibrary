//
//  User+CoreDataProperties.m
//  myLibrary
//
//  Created by 吕浩泰 on 2018/3/18.
//  Copyright © 2018年 吕浩泰. All rights reserved.
//

#import "User+CoreDataProperties.h"

@implementation User (CoreDataProperties)

+ (NSFetchRequest<User *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"User"];
}

@dynamic birthday;
@dynamic name;
@dynamic password;
@dynamic reader_id;
@dynamic reg_date;
@dynamic reader_borrow;
@dynamic reader_punish;
@dynamic reader_return;

@end

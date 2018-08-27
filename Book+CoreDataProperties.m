//
//  Book+CoreDataProperties.m
//  myLibrary
//
//  Created by 吕浩泰 on 2018/3/18.
//  Copyright © 2018年 吕浩泰. All rights reserved.
//

#import "Book+CoreDataProperties.h"

@implementation Book (CoreDataProperties)

+ (NSFetchRequest<Book *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Book"];
}

@dynamic author;
@dynamic book_id;
@dynamic book_name;
@dynamic broken_num;
@dynamic class_name;
@dynamic num;
@dynamic press_date;
@dynamic press_name;
@dynamic price;
@dynamic reg_date;
@dynamic tips;
@dynamic book_borrow;
@dynamic book_punish;
@dynamic book_return;
@dynamic classification;

@end

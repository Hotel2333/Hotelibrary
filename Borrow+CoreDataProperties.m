//
//  Borrow+CoreDataProperties.m
//  myLibrary
//
//  Created by 吕浩泰 on 2018/3/18.
//  Copyright © 2018年 吕浩泰. All rights reserved.
//

#import "Borrow+CoreDataProperties.h"

@implementation Borrow (CoreDataProperties)

+ (NSFetchRequest<Borrow *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Borrow"];
}

@dynamic book_id;
@dynamic borr_date;
@dynamic manager_id;
@dynamic reader_id;
@dynamic borrow_book;
@dynamic borrow_manager;
@dynamic borrow_reader;

@end

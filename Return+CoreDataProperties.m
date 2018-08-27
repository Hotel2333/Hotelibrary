//
//  Return+CoreDataProperties.m
//  myLibrary
//
//  Created by 吕浩泰 on 2018/3/18.
//  Copyright © 2018年 吕浩泰. All rights reserved.
//

#import "Return+CoreDataProperties.h"

@implementation Return (CoreDataProperties)

+ (NSFetchRequest<Return *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Return"];
}

@dynamic book_id;
@dynamic manager_id;
@dynamic reader_id;
@dynamic retu_date;
@dynamic return_book;
@dynamic return_manager;
@dynamic return_reader;

@end

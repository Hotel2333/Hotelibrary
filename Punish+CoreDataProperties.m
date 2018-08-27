//
//  Punish+CoreDataProperties.m
//  myLibrary
//
//  Created by 吕浩泰 on 2018/3/18.
//  Copyright © 2018年 吕浩泰. All rights reserved.
//

#import "Punish+CoreDataProperties.h"

@implementation Punish (CoreDataProperties)

+ (NSFetchRequest<Punish *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Punish"];
}

@dynamic book_id;
@dynamic manager_id;
@dynamic punish_date;
@dynamic punish_free;
@dynamic punish_tips;
@dynamic reader_id;
@dynamic punish_book;
@dynamic punish_manager;
@dynamic punish_reader;

@end

//
//  Borrow+CoreDataProperties.h
//  myLibrary
//
//  Created by 吕浩泰 on 2018/3/18.
//  Copyright © 2018年 吕浩泰. All rights reserved.
//

#import "Borrow+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Borrow (CoreDataProperties)

+ (NSFetchRequest<Borrow *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *book_id;
@property (nullable, nonatomic, copy) NSString *borr_date;
@property (nullable, nonatomic, copy) NSString *manager_id;
@property (nullable, nonatomic, copy) NSString *reader_id;
@property (nullable, nonatomic, retain) Book *borrow_book;
@property (nullable, nonatomic, retain) Admin *borrow_manager;
@property (nullable, nonatomic, retain) User *borrow_reader;

@end

NS_ASSUME_NONNULL_END

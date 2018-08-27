//
//  Return+CoreDataProperties.h
//  myLibrary
//
//  Created by 吕浩泰 on 2018/3/18.
//  Copyright © 2018年 吕浩泰. All rights reserved.
//

#import "Return+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Return (CoreDataProperties)

+ (NSFetchRequest<Return *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *book_id;
@property (nullable, nonatomic, copy) NSString *manager_id;
@property (nullable, nonatomic, copy) NSString *reader_id;
@property (nullable, nonatomic, copy) NSString *retu_date;
@property (nullable, nonatomic, retain) Book *return_book;
@property (nullable, nonatomic, retain) Admin *return_manager;
@property (nullable, nonatomic, retain) User *return_reader;

@end

NS_ASSUME_NONNULL_END

//
//  Punish+CoreDataProperties.h
//  myLibrary
//
//  Created by 吕浩泰 on 2018/3/18.
//  Copyright © 2018年 吕浩泰. All rights reserved.
//

#import "Punish+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Punish (CoreDataProperties)

+ (NSFetchRequest<Punish *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *book_id;
@property (nullable, nonatomic, copy) NSString *manager_id;
@property (nullable, nonatomic, copy) NSString *punish_date;
@property (nonatomic) float punish_free;
@property (nullable, nonatomic, copy) NSString *punish_tips;
@property (nullable, nonatomic, copy) NSString *reader_id;
@property (nullable, nonatomic, retain) Book *punish_book;
@property (nullable, nonatomic, retain) Admin *punish_manager;
@property (nullable, nonatomic, retain) User *punish_reader;

@end

NS_ASSUME_NONNULL_END

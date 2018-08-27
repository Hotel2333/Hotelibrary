//
//  Book+CoreDataProperties.h
//  myLibrary
//
//  Created by 吕浩泰 on 2018/3/18.
//  Copyright © 2018年 吕浩泰. All rights reserved.
//

#import "Book+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Book (CoreDataProperties)

+ (NSFetchRequest<Book *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *author;
@property (nullable, nonatomic, copy) NSString *book_id;
@property (nullable, nonatomic, copy) NSString *book_name;
@property (nonatomic) int16_t broken_num;
@property (nullable, nonatomic, copy) NSString *class_name;
@property (nonatomic) int16_t num;
@property (nullable, nonatomic, copy) NSString *press_date;
@property (nullable, nonatomic, copy) NSString *press_name;
@property (nonatomic) float price;
@property (nullable, nonatomic, copy) NSString *reg_date;
@property (nullable, nonatomic, copy) NSString *tips;
@property (nullable, nonatomic, retain) NSSet<Borrow *> *book_borrow;
@property (nullable, nonatomic, retain) NSSet<Punish *> *book_punish;
@property (nullable, nonatomic, retain) NSSet<Return *> *book_return;
@property (nullable, nonatomic, retain) Classification *classification;

@end

@interface Book (CoreDataGeneratedAccessors)

- (void)addBook_borrowObject:(Borrow *)value;
- (void)removeBook_borrowObject:(Borrow *)value;
- (void)addBook_borrow:(NSSet<Borrow *> *)values;
- (void)removeBook_borrow:(NSSet<Borrow *> *)values;

- (void)addBook_punishObject:(Punish *)value;
- (void)removeBook_punishObject:(Punish *)value;
- (void)addBook_punish:(NSSet<Punish *> *)values;
- (void)removeBook_punish:(NSSet<Punish *> *)values;

- (void)addBook_returnObject:(Return *)value;
- (void)removeBook_returnObject:(Return *)value;
- (void)addBook_return:(NSSet<Return *> *)values;
- (void)removeBook_return:(NSSet<Return *> *)values;

@end

NS_ASSUME_NONNULL_END

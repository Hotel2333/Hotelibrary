//
//  User+CoreDataProperties.h
//  myLibrary
//
//  Created by 吕浩泰 on 2018/3/18.
//  Copyright © 2018年 吕浩泰. All rights reserved.
//

#import "User+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface User (CoreDataProperties)

+ (NSFetchRequest<User *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *birthday;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSString *password;
@property (nullable, nonatomic, copy) NSString *reader_id;
@property (nullable, nonatomic, copy) NSString *reg_date;
@property (nullable, nonatomic, retain) NSSet<Borrow *> *reader_borrow;
@property (nullable, nonatomic, retain) NSSet<Punish *> *reader_punish;
@property (nullable, nonatomic, retain) NSSet<Return *> *reader_return;

@end

@interface User (CoreDataGeneratedAccessors)

- (void)addReader_borrowObject:(Borrow *)value;
- (void)removeReader_borrowObject:(Borrow *)value;
- (void)addReader_borrow:(NSSet<Borrow *> *)values;
- (void)removeReader_borrow:(NSSet<Borrow *> *)values;

- (void)addReader_punishObject:(Punish *)value;
- (void)removeReader_punishObject:(Punish *)value;
- (void)addReader_punish:(NSSet<Punish *> *)values;
- (void)removeReader_punish:(NSSet<Punish *> *)values;

- (void)addReader_returnObject:(Return *)value;
- (void)removeReader_returnObject:(Return *)value;
- (void)addReader_return:(NSSet<Return *> *)values;
- (void)removeReader_return:(NSSet<Return *> *)values;

@end

NS_ASSUME_NONNULL_END

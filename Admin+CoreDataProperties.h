//
//  Admin+CoreDataProperties.h
//  myLibrary
//
//  Created by 吕浩泰 on 2018/3/18.
//  Copyright © 2018年 吕浩泰. All rights reserved.
//

#import "Admin+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Admin (CoreDataProperties)

+ (NSFetchRequest<Admin *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *birthday;
@property (nullable, nonatomic, copy) NSString *dept_name;
@property (nonatomic) BOOL isSenior;
@property (nullable, nonatomic, copy) NSString *manager_id;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSString *password;
@property (nullable, nonatomic, copy) NSString *reg_date;
@property (nullable, nonatomic, retain) Department *department;
@property (nullable, nonatomic, retain) NSSet<Borrow *> *manager_borrow;
@property (nullable, nonatomic, retain) NSSet<Punish *> *manager_punish;
@property (nullable, nonatomic, retain) NSSet<Return *> *manager_return;

@end

@interface Admin (CoreDataGeneratedAccessors)

- (void)addManager_borrowObject:(Borrow *)value;
- (void)removeManager_borrowObject:(Borrow *)value;
- (void)addManager_borrow:(NSSet<Borrow *> *)values;
- (void)removeManager_borrow:(NSSet<Borrow *> *)values;

- (void)addManager_punishObject:(Punish *)value;
- (void)removeManager_punishObject:(Punish *)value;
- (void)addManager_punish:(NSSet<Punish *> *)values;
- (void)removeManager_punish:(NSSet<Punish *> *)values;

- (void)addManager_returnObject:(Return *)value;
- (void)removeManager_returnObject:(Return *)value;
- (void)addManager_return:(NSSet<Return *> *)values;
- (void)removeManager_return:(NSSet<Return *> *)values;

@end

NS_ASSUME_NONNULL_END

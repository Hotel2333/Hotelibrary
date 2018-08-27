//
//  Classification+CoreDataProperties.h
//  myLibrary
//
//  Created by 吕浩泰 on 2018/3/18.
//  Copyright © 2018年 吕浩泰. All rights reserved.
//

#import "Classification+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Classification (CoreDataProperties)

+ (NSFetchRequest<Classification *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *class_name;
@property (nullable, nonatomic, copy) NSString *tips;
@property (nullable, nonatomic, retain) NSSet<Book *> *book;

@end

@interface Classification (CoreDataGeneratedAccessors)

- (void)addBookObject:(Book *)value;
- (void)removeBookObject:(Book *)value;
- (void)addBook:(NSSet<Book *> *)values;
- (void)removeBook:(NSSet<Book *> *)values;

@end

NS_ASSUME_NONNULL_END

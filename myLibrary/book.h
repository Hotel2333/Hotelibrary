//
//  book.h
//  myLibrary
//
//  Created by 吕浩泰 on 2018/3/13.
//  Copyright © 2018年 吕浩泰. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Book+CoreDataProperties.h"
#import <CoreData/CoreData.h>
@interface book : UITableViewCell

@property(nonatomic, strong, readwrite)NSString * bookID;
@property(nonatomic, strong, readwrite)UIImageView * bookCon;
@property(nonatomic, strong, readwrite)UILabel * title;
@property(nonatomic, strong, readwrite)UILabel * author;
@property(nonatomic, strong, readwrite)UILabel * tips;
- (void)renderWithBookId:(NSString *)bookID;

@end

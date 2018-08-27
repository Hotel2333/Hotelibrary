//
//  bookPage2.h
//  myLibrary
//
//  Created by 吕浩泰 on 2018/3/29.
//  Copyright © 2018年 吕浩泰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface bookPage2 : UIViewController
@property(nonatomic, strong, readwrite)NSString * ReaderID;
@property(nonatomic, strong, readwrite)NSString * bookID;
@property(nonatomic, strong, readwrite)UIImageView * bookCon;
@property(nonatomic, strong, readwrite)UILabel * title;
@property(nonatomic, strong, readwrite)UILabel * author;
@property(nonatomic, strong, readwrite)UILabel * tips;
@end

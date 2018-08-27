//
//  book.m
//  myLibrary
//
//  Created by 吕浩泰 on 2018/3/13.
//  Copyright © 2018年 吕浩泰. All rights reserved.
//

#import "book.h"

@implementation book

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if(self=[super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        
        //封面
        _bookCon= [[UIImageView alloc]init];
        _bookCon.frame = CGRectMake(33, 11, 63, 89);
        //标题
        _title = [[UILabel alloc]initWithFrame:CGRectMake(116, 13 , 150 , 14)];
        _title.font = [UIFont boldSystemFontOfSize:14];
        //作者
        _author = [[UILabel alloc]initWithFrame:CGRectMake(118, 35 , 150 , 12)];
        _author.font = [UIFont systemFontOfSize:12];
        //内容
        _tips = [[UILabel alloc]initWithFrame:CGRectMake(118, 40 , 224 , 70)];
        _tips.numberOfLines = 2;
        _tips.font = [UIFont systemFontOfSize:12];
        
        [self addSubview:_bookCon];
        [self addSubview:_title];
        [self addSubview:_author];
        [self addSubview:_tips];
        
        
    }
    return self;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}
- (void)setBookID:(NSString *)bookID{
    _bookID = bookID;
}

- (void)renderWithBookId:(NSString *)bookID{
    _bookID = bookID;
    if(bookID.length > 0){
        [self searchPic];
        self.bookCon.hidden = NO;
    }else{
        self.bookCon.hidden = YES;
    }
    [self setNeedsLayout];
}
- (void)layoutSubviews{
    [super layoutSubviews];
    if(self.bookCon && !self.bookCon.hidden){
        self.bookCon.frame = CGRectMake(33, 11, 63, 89);
    }
}
- (void)searchPic{//搜索图片
    NSArray * path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * conPath = [NSString stringWithFormat:@"/Book/%@.jpg",_bookID];
    NSString * docPath = [path objectAtIndex:0];
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSString * fullPath = [docPath stringByAppendingString:conPath];
    [fileManager createDirectoryAtPath:[fullPath stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:nil];
    NSData * data = [NSData dataWithContentsOfFile:fullPath];
    UIImage * image = [UIImage imageWithData:data];
    if(image == nil&&data == nil){
        [_bookCon setBackgroundColor:[UIColor blackColor]];
        NSLog(@"数据库中没有存有本图书的封面");
        NSLog(@"我去这里找过了:%@",fullPath);
    }else{
        [_bookCon setImage:image];
        NSLog(@"封面查询成功并已设置");
    }
}
/*
- (void)goInit{
    NSLog(@"cell调用了goInit");
    _request = [NSFetchRequest fetchRequestWithEntityName:@"Book"];//设置请求的实体
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"book_id LIKE %@",_bookID];
    _request.predicate = predicate;//设置请求的条件
    NSError * error = nil;
    _array = [_moc executeFetchRequest:_request error:&error];
    if(error!=nil){
        NSLog(@"%@",error);
    }
}
- (void)searchPic{
    NSArray * path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * conPath = [NSString stringWithFormat:@"Book/%@.jpg",_book.book_id];
    NSString * docPath = [path objectAtIndex:0];
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSString * fullPath = [docPath stringByAppendingString:conPath];
    [fileManager createDirectoryAtPath:[fullPath stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:nil];
    NSData * data = [NSData dataWithContentsOfFile:fullPath];
    UIImage * image = [UIImage imageWithData:data];
    if(image == nil&&data == nil){
        //[_bookCon setImage:[UIImage imageNamed:@"头像.png"]];
        [_bookCon setBackgroundColor:[UIColor blackColor]];
        NSLog(@"数据库中没有存有本图书的封面");
        NSLog(@"我去这里找过了:%@",fullPath);
    }else{
        [_bookCon setImage:image];
        NSLog(@"头像查询成功并已设置");
    }

}
- (NSManagedObjectModel *)managedObjectModel{
    if(!_mom){
        _modelURL = [[NSBundle mainBundle]URLForResource:@"myLibraryModel" withExtension:@"momd"];
        _mom = [[NSManagedObjectModel alloc]initWithContentsOfURL:_modelURL];
    }
    return _mom;
}
- (nullable NSURL *)documentDirectoryURL {
    return [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].firstObject;
}
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (!_psc) {
        // 创建 coordinator 需要传入 managedObjectModel
        _psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
        // 指定本地的 sqlite 数据库文件
        NSURL *sqliteURL = [[self documentDirectoryURL] URLByAppendingPathComponent:@"myLibrary.sqlite"];
        NSError *error;
        // 为 persistentStoreCoordinator 指定本地存储的类型，这里指定的是 SQLite
        [_psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:sqliteURL options:nil error:&error];
        if (error) {
            NSLog(@"falied to create persistentStoreCoordinator %@", error.localizedDescription);
        }
    }
    return _psc;
}
- (NSManagedObjectContext *)context {
    if (!_moc) {
        // 指定 context 的并发类型： NSMainQueueConcurrencyType 或 NSPrivateQueueConcurrencyType
        _moc = [[NSManagedObjectContext alloc ] initWithConcurrencyType:NSMainQueueConcurrencyType];
        _moc.persistentStoreCoordinator = self.persistentStoreCoordinator;
    }
    return _moc;
}
*/

@end

//
//  upLoadBook.m
//  myLibrary
//
//  Created by 吕浩泰 on 2018/3/19.
//  Copyright © 2018年 吕浩泰. All rights reserved.
//

#import "upLoadBook.h"
#import "Book+CoreDataProperties.h"
#import "Classification+CoreDataProperties.h"
#import <CoreData/CoreData.h>
#import "upLoadBook.h"
#import "minePage.h"
@interface upLoadBook ()<UIScrollViewDelegate,UIActionSheetDelegate,UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
@property(nonatomic, strong, readwrite) UIScrollView * scrollView;
@property(nonatomic, strong, readwrite)UITableView * tableView;
@property(nonatomic, strong, readwrite) UIButton * addPic;
@property(nonatomic, strong, readwrite) UIImageView * bookCon;
@property(nonatomic, strong, readonly) UITextField * identifier;
@property(nonatomic, strong, readwrite) UITextField * name;
@property(nonatomic, strong, readwrite) UITextField * kind;
@property(nonatomic, strong, readwrite) UITextField * anthor;
@property(nonatomic, strong, readwrite) UITextField * press;
@property(nonatomic, strong, readwrite) UITextField * pressDate;
@property(nonatomic, strong, readwrite) UITextField * price;
@property(nonatomic, strong, readwrite) UITextView * tips;
@property(nonatomic, strong, readwrite) UITextField * broken_num;
@property(nonatomic, strong, readwrite) UITextField * num;
@property(nonatomic, strong, readwrite) UITextField * reg_date;
@property(nonatomic, strong, readwrite) UIDatePicker * date;

@property(nonatomic, strong, readwrite)Book * book;
@property(nonatomic, strong, readwrite)NSURL * modelURL;
@property(nonatomic, strong, readwrite)NSManagedObjectModel * mom;
@property(nonatomic, strong, readwrite)NSPersistentStoreCoordinator * psc;
@property(nonatomic, strong, readwrite)NSURL * path;
@property(nonatomic, strong, readwrite)NSManagedObjectContext * moc;
@property(nonatomic, strong, readwrite)NSFetchRequest * request;
@property(nonatomic, strong, readwrite)NSSaveChangesRequest * requestUpdate;
@property(nonatomic, strong, readwrite)NSArray * array;
@end

@implementation upLoadBook
- (void)viewWillAppear:(BOOL)animated{
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];//导航栏背景颜色
    //self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.612 green:0.851 blue:0.365 alpha:0];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.612 green:0.851 blue:0.365 alpha:0];
    //修改返回按钮文字
    UIBarButtonItem * back = [[UIBarButtonItem alloc]init];
    back.title = @"返回";
    self.navigationItem.backBarButtonItem = back;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 1100) style:UITableViewStyleGrouped];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.allowsSelection = NO;
    _tableView.scrollEnabled = NO;
    _tableView.backgroundColor = [UIColor colorWithRed:0.930 green:0.930 blue:0.930 alpha:1];

    
    [self managedObjectModel];
    [self documentDirectoryURL];
    [self persistentStoreCoordinator];
    [self context];
    //[self goInit];
    //[self searchPic];
    
    [self showDataPicker];
    
    UIScrollView * scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    scrollView.bounces = NO;
    scrollView.contentSize = CGSizeMake(self.view.frame.size.width, 1300);
    scrollView.backgroundColor = [UIColor colorWithRed:0.930 green:0.930 blue:0.930 alpha:1];
    //scrollView.backgroundColor = [UIColor whiteColor];
    [scrollView addSubview:_tableView];
    
    
    UIButton * btn = [[UIButton alloc]initWithFrame:CGRectMake(40, 1150, 300, 40)];
    //[btn setBackgroundColor:[UIColor colorWithRed:0.620 green:0.850 blue:0.365 alpha:1]];
    [btn setBackgroundImage:[UIImage imageNamed:@"完成"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(upLoad) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:btn];
    
    [self.view addSubview:scrollView];
}
- (void)showDataPicker{
    UIDatePicker * datePicker = [[UIDatePicker alloc]init];
    datePicker.locale = [NSLocale localeWithLocaleIdentifier:@"zh"];
    datePicker.datePickerMode = UIDatePickerModeDate;
    [datePicker setDate:[NSDate date] animated:YES];
    datePicker.maximumDate = [NSDate date];
    datePicker.backgroundColor = [UIColor colorWithRed:0.612 green:0.851 blue:0.365 alpha:0];
    datePicker.tintColor = [UIColor whiteColor];
    [datePicker addTarget:self action:@selector(datePick:) forControlEvents:UIControlEventValueChanged];
    
    self.date = datePicker;
    self.pressDate.inputView = datePicker;//设置文本框
}

- (void)datePick:(UIDatePicker *)datePicker{
    NSDateFormatter * forma = [[NSDateFormatter alloc]init];
    forma.dateFormat = @"yyyy年MM月dd日";
    NSString * dateStr = [forma stringFromDate:datePicker.date];//时间转字符串
    self.pressDate.text = dateStr;
}
- (void)popSelection{
    NSLog(@"editting");
    UIAlertController * alertView = [UIAlertController alertControllerWithTitle:@"选择分类信息" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    _request = [NSFetchRequest fetchRequestWithEntityName:@"Classification"];
    NSArray * class = [_moc executeFetchRequest:_request error:nil];
    for(Classification * obj in class){
        UIAlertAction * action = [UIAlertAction actionWithTitle:obj.class_name style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            _kind.text = obj.class_name;
        }];
        [alertView addAction:action];
    }
    UIAlertAction * cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alertView addAction:cancel];
    [self presentViewController:alertView animated:YES completion:nil];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 1 && indexPath.row == 2){
        NSLog(@"editting");
    }
}
- (void)upLoad{
    //_request = [NSFetchRequest fetchRequestWithEntityName:@"Book"];
    //NSPredicate * predicate = [NSPredicate predicateWithFormat:@"book_id LIKE %@",_bookID];//设置请求的条件
    //_request.predicate = predicate;
    //_array = [_moc executeFetchRequest:_request error:nil];
    //Book * obj = _array[0];
    Book * obj = [NSEntityDescription insertNewObjectForEntityForName:@"Book" inManagedObjectContext:_moc];
    //_book = [NSEntityDescription insertNewObjectForEntityForName:@"Book" inManagedObjectContext:_moc];
    obj.author = _anthor.text;
    obj.book_id = _identifier.text;
    obj.broken_num = [_broken_num.text intValue];
    obj.book_name = _name.text;
    obj.class_name = _kind.text;
    obj.num = [_num.text intValue];
    obj.press_date = _pressDate.text;
    obj.press_name = _press.text;
    obj.price = [_price.text floatValue];
    obj.tips = _tips.text;
    
    NSDateFormatter * formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"yyyy年MM月dd日HH时mm分";
    NSString * dateTime = [formatter stringFromDate:[NSDate date]];
    obj.reg_date = dateTime;
    
    NSError * error = nil;
    if([_moc save:&error]){
        UIAlertController * alertView = [UIAlertController alertControllerWithTitle:@"编辑成功" message:@"点击“好的”以返回" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * action = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.navigationController popViewControllerAnimated:YES];
        }];
        
        _request = [NSFetchRequest fetchRequestWithEntityName:@"Admin"];
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"manager_id LIKE %@",_adminID];
        NSLog(@"admin:%@",_adminID);
        _request.predicate = predicate;
        NSArray * arr = [_moc executeFetchRequest:_request error:nil];
        if(arr != nil){
            Admin * obj = arr[0];
            int books = obj.inBook;
            books++;
            obj.inBook = books;
            [_moc save:nil];
        }
        [alertView addAction:action];
        [self presentViewController:alertView animated:YES completion:nil];
    }else{
        NSLog(@"错误:%@",error);
    }
    
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == 0){
        return 1;
    }else if(section == 1){
        return 9;
    }else{
        return 1;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0){
        return 200;
    }else if(indexPath.section == 1){
        return 50;
    }else{
        return 290;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0){
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
        if(!cell){
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cellID"];
        }
        _addPic = [UIButton buttonWithType:UIButtonTypeCustom];
        _addPic.frame = CGRectMake(123, 10, 125, 177);
        //[_addPic setBackgroundImage:[UIImage imageNamed:@"上传图片.png"] forState:UIControlStateNormal];
        [_addPic addTarget:self action:@selector(chosePic) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:_addPic];
        
        //_bookCon = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"上传图片.png"]];
        _bookCon = [[UIImageView alloc]init];
        //[self searchPic];
        _bookCon.image = [UIImage imageNamed:@"上传图片.png"];
        _bookCon.frame = CGRectMake(123, 10, 125, 177);
        [cell.contentView addSubview:_bookCon];
        
        return cell;
    }else if(indexPath.section == 1 && indexPath.row == 0){
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
        if(!cell){
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cellID"];
        }
        UILabel * text = [[UILabel alloc]initWithFrame:CGRectMake(20, 15, 120, 18)];
        text.text = @"编号";
        text.font = [UIFont boldSystemFontOfSize:16];
        [cell.contentView addSubview:text];
        
        _identifier = [[UITextField alloc]initWithFrame:CGRectMake(160, 15, 200, 18)];
        _identifier.font = [UIFont systemFontOfSize:16];
        _identifier.enabled = NO;
        //_identifier.text = _book.book_id;
        //获取当前最大的id并加1
        _request = [NSFetchRequest fetchRequestWithEntityName:@"Book"];
        NSArray * arr = [_moc executeFetchRequest:_request error:nil];
        int large = 0;
        for(Book * b in arr){
            int temp = [b.book_id intValue];
            if(temp > large){
                large = temp;
            }
        }
        _identifier.text = [NSString stringWithFormat:@"%d",large+1];
        [cell.contentView addSubview:_identifier];
        
        return cell;
    }else if(indexPath.section == 1 && indexPath.row == 1){
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
        if(!cell){
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cellID"];
        }
        UILabel * text = [[UILabel alloc]initWithFrame:CGRectMake(20, 15, 120, 18)];
        text.text = @"书名";
        text.font = [UIFont boldSystemFontOfSize:16];
        [cell.contentView addSubview:text];
        
        _name = [[UITextField alloc]initWithFrame:CGRectMake(160, 15, 200, 18)];
        _name.font = [UIFont systemFontOfSize:16];
        //_name.text = _book.book_name;
        _name.placeholder = @"请输入图书的名字";
        [cell.contentView addSubview:_name];
        
        return cell;
    }else if(indexPath.section == 1 && indexPath.row == 2){
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
        if(!cell){
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cellID"];
        }
        UILabel * text = [[UILabel alloc]initWithFrame:CGRectMake(20, 15, 120, 18)];
        text.text = @"图书类型";
        text.font = [UIFont boldSystemFontOfSize:16];
        [cell.contentView addSubview:text];
        
        _kind = [[UITextField alloc]initWithFrame:CGRectMake(160, 15, 200, 18)];
        _kind.font = [UIFont systemFontOfSize:16];
        [_kind addTarget:self action:@selector(popSelection) forControlEvents:UIControlEventEditingDidBegin];
        //_kind.text = _book.class_name;
        _kind.placeholder = @"请选择图书的类型";
        //弹出选择框
        [cell.contentView addSubview:_kind];
        
        return cell;
    }else if(indexPath.section == 1 && indexPath.row == 3){
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
        if(!cell){
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cellID"];
        }
        UILabel * text = [[UILabel alloc]initWithFrame:CGRectMake(20, 15, 120, 18)];
        text.text = @"作者";
        text.font = [UIFont boldSystemFontOfSize:16];
        [cell.contentView addSubview:text];
        
        _anthor = [[UITextField alloc]initWithFrame:CGRectMake(160, 15, 200, 18)];
        _anthor.font = [UIFont systemFontOfSize:16];
        //_anthor.text = _book.author;
        _anthor.placeholder = @"请输入作者姓名";
        [cell.contentView addSubview:_anthor];
        
        return cell;
    }else if(indexPath.section == 1 && indexPath.row == 4){
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
        if(!cell){
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cellID"];
        }
        UILabel * text = [[UILabel alloc]initWithFrame:CGRectMake(20, 15, 120, 18)];
        text.text = @"出版社";
        text.font = [UIFont boldSystemFontOfSize:16];
        [cell.contentView addSubview:text];
        
        _press = [[UITextField alloc]initWithFrame:CGRectMake(160, 15, 200, 18)];
        _press.font = [UIFont systemFontOfSize:16];
        //_press.text = _book.press_name;
        _press.placeholder = @"请输入出版社名字";
        [cell.contentView addSubview:_press];
        
        return cell;
    }else if(indexPath.section == 1 && indexPath.row == 5){
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
        if(!cell){
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cellID"];
        }
        UILabel * text = [[UILabel alloc]initWithFrame:CGRectMake(20, 15, 120, 18)];
        text.text = @"出版时间";
        text.font = [UIFont boldSystemFontOfSize:16];
        [cell.contentView addSubview:text];
        
        _pressDate = [[UITextField alloc]initWithFrame:CGRectMake(160, 15, 200, 18)];
        _pressDate.font = [UIFont systemFontOfSize:16];
        //_pressDate.text = _book.press_date;
        _pressDate.placeholder = @"请选择出版时间";
        //弹出框选择时间
        [self showDataPicker];
        [cell.contentView addSubview:_pressDate];
        
        return cell;
    }else if(indexPath.section == 1 && indexPath.row == 6){
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
        if(!cell){
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cellID"];
        }
        UILabel * text = [[UILabel alloc]initWithFrame:CGRectMake(20, 15, 120, 18)];
        text.text = @"价格";
        text.font = [UIFont boldSystemFontOfSize:16];
        [cell.contentView addSubview:text];
        
        _price = [[UITextField alloc]initWithFrame:CGRectMake(160, 15, 200, 18)];
        _price.font = [UIFont systemFontOfSize:16];
        //_price.text = [NSString stringWithFormat:@"%lf元",_book.price];
        _price.placeholder = @"请输入价格(元)";
        [cell.contentView addSubview:_price];
        
        return cell;
    }else if(indexPath.section == 1 && indexPath.row == 7){
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
        if(!cell){
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cellID"];
        }
        UILabel * text = [[UILabel alloc]initWithFrame:CGRectMake(20, 15, 120, 18)];
        text.text = @"库存数量";
        text.font = [UIFont boldSystemFontOfSize:16];
        [cell.contentView addSubview:text];
        
        _num = [[UITextField alloc]initWithFrame:CGRectMake(160, 15, 200, 18)];
        _num.font = [UIFont systemFontOfSize:16];
        //_num.text = [NSString stringWithFormat:@"%d本",_book.num];
        _num.placeholder = @"请输入库存数量(本)";
        [cell.contentView addSubview:_num];
        
        return cell;
    }else if(indexPath.section == 1 && indexPath.row == 8){
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
        if(!cell){
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cellID"];
        }
        UILabel * text = [[UILabel alloc]initWithFrame:CGRectMake(20, 15, 120, 18)];
        text.text = @"损坏数量";
        text.font = [UIFont boldSystemFontOfSize:16];
        [cell.contentView addSubview:text];
        
        _broken_num = [[UITextField alloc]initWithFrame:CGRectMake(160, 15, 200, 18)];
        _broken_num.font = [UIFont systemFontOfSize:16];
        //_broken_num.text = [NSString stringWithFormat:@"%d本",_book.broken_num];
        _broken_num.placeholder = @"请输入损坏数量(本)";
        [cell.contentView addSubview:_broken_num];
        
        return cell;
    }else if(indexPath.section == 2){
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
        if(!cell){
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cellID"];
        }
        _tips = [[UITextView alloc]init];
        _tips.frame = CGRectMake(10, 10, 355, 270);
        _tips.font = [UIFont systemFontOfSize:16];
        //_tips.text = _book.tips;
        [cell.contentView addSubview:_tips];
        
        CAShapeLayer * shapeLayer = [CAShapeLayer layer];
        //[shapeLayer setStrokeColor:[UIColor blackColor].CGColor];//设置虚线颜色
        [shapeLayer setStrokeColor:[UIColor colorWithRed:0.930 green:0.930 blue:0.930 alpha:1].CGColor];
        [shapeLayer setFillColor:[UIColor clearColor].CGColor];//设置空白颜色
        [shapeLayer setLineWidth:2];//设置虚线宽度
        [shapeLayer setLineJoin:kCALineJoinRound];
        [shapeLayer setLineDashPattern:[NSArray arrayWithObjects:[NSNumber numberWithInt:5], [NSNumber numberWithInt:3], nil]];//设置线宽和间距
        CGMutablePathRef path = CGPathCreateMutable();//创建虚线路径
        CGPathMoveToPoint(path, NULL, 10, 10);//设置起点
        CGPathAddLineToPoint(path, NULL, 365, 10);
        CGPathAddLineToPoint(path, NULL, 365, 280);
        CGPathAddLineToPoint(path, NULL, 10, 280);
        CGPathAddLineToPoint(path, NULL, 10, 10);
        [shapeLayer setPath:path];
        CGPathRelease(path);
        [cell.layer addSublayer:shapeLayer];//添加虚线
        
        return cell;
    }else{
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
        if(!cell){
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cellID"];
        }
        return cell;
    }
}

/*
- (void)searchPic{
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
}*/
- (void)chosePic{
    UIActionSheet * sheet;
    if(![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        sheet = [[UIActionSheet alloc]initWithTitle:@"选择" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"取消" otherButtonTitles:@"拍照",@"从相册中选择", nil];
    }else{
        sheet = [[UIActionSheet alloc]
                 initWithTitle:@"选择"
                 delegate:self
                 cancelButtonTitle:nil
                 destructiveButtonTitle:@"取消"
                 otherButtonTitles:@"从相册选择", nil];
    }
    sheet.tag=255;
    [sheet showInView:self.view];
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(actionSheet.tag == 255){
        NSUInteger sourceType = 0;
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
            switch (buttonIndex) {
                case 0:
                    return;
                case 1:
                    sourceType = UIImagePickerControllerSourceTypeCamera;
                    break;
                case 2:
                    sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                default:
                    break;
            }
        }else{
            if(buttonIndex == 0){
                return;
            }else{
                sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            }
        }
        UIImagePickerController * pick = [[UIImagePickerController alloc]init];
        pick.allowsEditing = NO;
        pick.delegate = self;
        //pick.allowsEditing = YES;
        pick.sourceType = sourceType;
        [self presentViewController:pick animated:YES completion:nil];
    }
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    [picker dismissViewControllerAnimated:YES completion:nil];//返回到主界面
    //获取返回到照片
    UIImage * image = [info objectForKey:UIImagePickerControllerOriginalImage];
    //压缩图片
    NSData * imageData = UIImageJPEGRepresentation(image, 0.5);
    //沙盒准备保存图片到地址和图片名称
    //NSString * fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Books"]stringByAppendingPathComponent:@"x.jpg"];
    NSArray * path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * conPath = [NSString stringWithFormat:@"/Book/%@.jpg",_identifier.text];
    NSString * docPath = [path objectAtIndex:0];
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSString * fullPath = [docPath stringByAppendingString:conPath];
    [fileManager createDirectoryAtPath:[fullPath stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:nil];
    
    //图片写入文件中
    [imageData writeToFile: fullPath atomically:NO];
    //通过路径获取图片，可以在主界面上的image进行预览
    UIImage * savedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    _bookCon.image = savedImage;
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

//
//  ViewController.m
//  JJCoreDataMannger
//
//  Created by 罗文琦 on 2017/5/25.
//  Copyright © 2017年 罗文琦. All rights reserved.
//

#import "ViewController.h"
#import "Person+CoreDataClass.h"
#import "JJCoreDataManager.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSLog(@"%@",NSHomeDirectory());
    
}


-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{


   //1.创建对象
    
    Person* p = [NSEntityDescription insertNewObjectForEntityForName:@"Person" inManagedObjectContext:kJJCoreDataManager.managedObjectContext];
    
    p.name =@"hehda";
    p.age = 15;
    
    [kJJCoreDataManager save];
    //2.使用单例工具进行保存
    
}



#pragma mark -增加数据  使用工具类插入数据,ios10之后可以使用的更加快速的方法
- (void)insertButtonClick:(id)sender {
    //先获取耗时操作之前的时间
    NSDate *data1 = [NSDate date];
    
    //2.2  在多线程中保存数据库  block中context也是帮助我们创建一个新的基于多线程的上下文
    [kJJCoreDataManager.persistentContainer performBackgroundTask:^(NSManagedObjectContext * context) {
        NSLog(@"%@",[NSThread currentThread]);
        //因为 for循环本身也是一种耗时操作,如果一起放入子线程中  插入一百万行只需要0.013s
        for (NSInteger i = 0; i < 1000000; i++) {
            Person *p = [NSEntityDescription insertNewObjectForEntityForName:@"Person" inManagedObjectContext:context];
            p.name = @"坤哥";
            p.age = 18;
        }
        //保存到数据库的操作,在哪一个上下文中操作数据,就用哪一个上下文保存
        [context save:nil];
    }];
    //    //数据库的保存操作不要在循环内部,应该放到操作数据之后一起保存
    //    [kHMCoreDataManager save];
    
    //再获取耗时操作之后的时间
    NSDate *data2 = [NSDate date];
    
    //输出时间差
    NSLog(@"%f",[data2 timeIntervalSinceDate:data1]);
    //1.测试主线程中操作大量数据的性能
    //    //先获取耗时操作之前的时间
    //    NSDate *data1 = [NSDate date];
    //
    //    for (NSInteger i = 0; i < 1000000; i++) {
    //        Person *p = [NSEntityDescription insertNewObjectForEntityForName:@"Person" inManagedObjectContext:kHMCoreDataManager.managedObjectContext];
    //        p.name = @"坤哥";
    //        p.age = 18;
    //    }
    //   //数据库的保存操作不要在循环内部,应该放到操作数据之后一起保存
    //    [kHMCoreDataManager save];
    //
    //    //再获取耗时操作之后的时间
    //    NSDate *data2 = [NSDate date];
    //
    //    //输出时间差
    //    NSLog(@"%f",[data2 timeIntervalSinceDate:data1]);
    //2.测试NSPersitentContainer的多线程操作coreData耗时
}



#pragma mark -查询数据
- (IBAction)fetchButtonClick:(id)sender {
    
    //1.创建查询请求 参数是要查询的实体
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Person"];
    
    //设置查询请求的谓词(条件查询,相当于sqlit中的where语句)
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.name CONTAINS %@",@"犬次郎"];
    request.predicate = predicate;
    
    
    //2.执行查询请求.(默认情况下查询所有的数据)
    NSArray *requestArr= [kJJCoreDataManager.managedObjectContext executeFetchRequest:request error:nil];
    
    for (Person *p in requestArr) {
        NSLog(@"%@===%d",p.name,p.age);
    }
}

#pragma mark -删除数据
- (IBAction)deletBuutonClick:(id)sender {
    
    
    
    //删除数据的逻辑就是先将你想要的数据查询出来,然后再删除即可
    
    //1.创建查询请求 参数是要查询的实体
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Person"];
    
    //设置查询请求的谓词(条件查询,相当于sqlit中的where语句)
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.name CONTAINS %@",@"犬次郎"];
    request.predicate = predicate;
    
    
    //2.执行查询请求.(默认情况下查询所有的数据)
    NSArray <Person *>*requestArr= [kJJCoreDataManager.managedObjectContext executeFetchRequest:request error:nil];
    
    //3.删除对象
    [kJJCoreDataManager.managedObjectContext deleteObject:requestArr.firstObject];
    
    
    
    
    
    //4.保存到数据库
    [kJJCoreDataManager save];
}


#pragma mark -修改数据
- (IBAction)updateButtonClick:(id)sender {
    //修改数据的逻辑就是先将你想要的数据查询出来,然后再修改即可
    //1.创建查询请求 参数是要查询的实体
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Person"];
    //设置查询请求的谓词(条件查询,相当于sqlit中的where语句)
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.name CONTAINS %@",@"犬次郎"];
    request.predicate = predicate;
    //2.执行查询请求.(默认情况下查询所有的数据)
    NSArray <Person *>*requestArr= [kJJCoreDataManager.managedObjectContext executeFetchRequest:request error:nil];
    //3.直接修改查询出的对象(由于示例代码这里数组只有一个元素所以我直接取0下标修改,实际情况需要遍历获取想要的对象)
    requestArr.firstObject.age = 30;
    //4.保存到数据库
    [kJJCoreDataManager save];
}






@end

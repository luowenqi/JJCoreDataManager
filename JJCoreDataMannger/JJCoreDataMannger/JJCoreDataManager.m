//
//  JJCoreDataManager.m
//  JJCoreDataMannger
//
//  Created by 罗文琦 on 2017/5/25.
//  Copyright © 2017年 罗文琦. All rights reserved.
//

#import "JJCoreDataManager.h"
#import <UIKit/UIKit.h>


@interface JJCoreDataManager ()

//管理对象上下文
@property(nonatomic,strong)NSManagedObjectContext *managedObjectContext1;

//对象模型
@property(nonatomic,strong)NSManagedObjectModel *managedObjectModel;


//存储调度器
@property(nonatomic,strong)NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end


@implementation JJCoreDataManager

+(JJCoreDataManager *)manager
{
    static JJCoreDataManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[JJCoreDataManager alloc] init];
    });
    
    return manager;
}


#pragma mark -iOS10
//1.iOS10之后NSPersistentContainer大大简化了我们搭建CoreData Stack的操作
//2.NSPersistentContainer无法指定数据库的路径 一定是Library->APP Suppout
- (NSPersistentContainer *)persistentContainer
{
    if (_persistentContainer != nil) {
        return _persistentContainer;
    }
    
    
    //1.创建coredata stack 容器 参数:name 指的是数据库的文件名 managedObjectModel:指定模型文件
    _persistentContainer = [[NSPersistentContainer alloc] initWithName:[NSString stringWithFormat:@"%@",kFileName] managedObjectModel:[NSManagedObjectModel mergedModelFromBundles:nil]];
    
    //2.开始加载技术栈堆容器(此时会自动帮助我们生成管理对象上下文和存储调度器)
    [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *description, NSError *error) {
        if (error == nil) {
            NSLog(@"创建CoreData Stack成功%@",description);
            
        }
        else
        {
            NSLog(@"%@",error.description);
        }
    }];
    
    //3.返回
    return _persistentContainer;
}

#pragma mark -iOS9

//重写get方法实现懒加载
- (NSManagedObjectContext *)managedObjectContext1
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    //1.创建管理对象上下文 参数是指定上下文的线程环境  建议使用：NSMainQueueConcurrencyType主线操作（主线程操作没有延迟）   NSPrivateQueueConcurrencyType（子线程操作数据存储会有一定延迟）
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    //2.设置存储调度器（存储数据时 对象上下文负责给存储调度器发送指令）
    [_managedObjectContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    //3.返回
    return _managedObjectContext;
}


- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    
    //1.创建对象模型（参数：值得是模型文件  xcdatamodeld路径）
    //注意：模型文件的后缀不能使用xcdatamodeld，否则会崩溃。 只能用momd
    //    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:[[NSBundle mainBundle]URLForResource:@"HMiOS" withExtension:@"momd"]];
    
    //2.使用合并的方式创建对象模型（上面的操作创建模型此时只能保存一个固定的数据库xc文件，用该方法则可以同时管理多个模型xc文件）
    //参数是一个bundle路径的数组  如果设为nil，则会自动帮你寻找整个项目中所有的路径下的cx模型文件
    _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    //2.返回
    return _managedObjectModel;
}

- (NSURL*)getDocumentUrl
{
    return [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].firstObject;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    //1.创建存储调度器 参数：对象模型
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
    //2.给存储调度器添加存储器(存储调度器的作用是调度存储器)
    /**storeType
     NSSQLiteStoreType 数据库形式存储
     NSXMLStoreType XML形式存储
     NSBinaryStoreType 二进制存储
     NSInMemoryStoreType 内存形式存储
     */
    /**
     type:
     
     configuration:配置 一般为nil，默认设置
     URL:数据库文件保存的路径
     options:参数信息  一般为nil,默认设置
     error：报错
     */
    
    NSURL *fileURL = [[self getDocumentUrl] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.db",kFileName]];
    [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:fileURL options:nil error:nil];
    //3.返回
    return _persistentStoreCoordinator;
}

- (void)save
{
    NSError *error;
    [self.managedObjectContext save:&error];
    
    if (error == nil) {
        NSLog(@"保存到数据库成功");
    }
    else
    {
        NSLog(@"%@",error.description);
    }
}

- (NSManagedObjectContext *)managedObjectContext
{
    //如果是iOS10系统则返回NSPersitentContainer的viewContext,如果是iOS10之前的版本返回CoreData Stack中的上下文
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0) {
        return self.persistentContainer.viewContext;
    }
    else
    {
        return self.managedObjectContext1;
    }
}

- (void)deletAllEntities
{
    //如果是iOS10 则删除AppSupport文件夹下的数据库文件,如果是iOS9则删除沙盒中的数据库文件
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0) {
        
        NSString *filePath1 = [NSString stringWithFormat:@"%@/Library/Application Support/%@.sqlite",NSHomeDirectory(),kFileName];
        NSString *filePath2 = [NSString stringWithFormat:@"%@/Library/Application Support/%@.sqlite-shm",NSHomeDirectory(),kFileName];
        NSString *filePath3 = [NSString stringWithFormat:@"%@/Library/Application Support/%@.sqlite-wal",NSHomeDirectory(),kFileName];
        
        NSError *error;
        [[NSFileManager defaultManager] removeItemAtPath:filePath1 error:&error];
        [[NSFileManager defaultManager] removeItemAtPath:filePath2 error:&error];
        [[NSFileManager defaultManager] removeItemAtPath:filePath3 error:&error];
        
        if (error == nil) {
            NSLog(@"清除数据库成功");
        }
        else
        {
            NSLog(@"%@",error.description);
        }
        
        
    }
    else
    {
        //清空数据库快捷方式可以直接删除数据库文件
        
        NSString *filePath1 = [NSString stringWithFormat:@"%@/Documents/%@.db",NSHomeDirectory(),kFileName];
        NSString *filePath2 = [NSString stringWithFormat:@"%@/Documents/%@.db-shm",NSHomeDirectory(),kFileName];
        NSString *filePath3 = [NSString stringWithFormat:@"%@/Documents/%@.db-wal",NSHomeDirectory(),kFileName];
        
        NSError *error;
        [[NSFileManager defaultManager] removeItemAtPath:filePath1 error:&error];
        [[NSFileManager defaultManager] removeItemAtPath:filePath2 error:&error];
        [[NSFileManager defaultManager] removeItemAtPath:filePath3 error:&error];
        
        if (error == nil) {
            NSLog(@"清除数据库成功");
        }
        else
        {
            NSLog(@"%@",error.description);
        }
        
    }
}



@end

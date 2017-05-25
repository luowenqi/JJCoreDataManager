//
//  JJCoreDataManager.h
//  JJCoreDataMannger
//
//  Created by 罗文琦 on 2017/5/25.
//  Copyright © 2017年 罗文琦. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#define kFileName @"myCoreData"
#define kJJCoreDataManager [JJCoreDataManager manager]

@interface JJCoreDataManager : NSObject


/**
单例对象
 */
+(JJCoreDataManager *)manager;

#pragma mark CoreData Stack

//管理对象上下文
@property(nonatomic,strong)NSManagedObjectContext *managedObjectContext;


//core data Stack技术栈堆容器
@property(nonatomic,strong)NSPersistentContainer *persistentContainer;


#pragma mark -Funcation

//保存到数据库
- (void)save;

//清空数据库
- (void)deletAllEntities;


@end

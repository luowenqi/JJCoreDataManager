//
//  Person+CoreDataProperties.m
//  JJCoreDataMannger
//
//  Created by 罗文琦 on 2017/5/25.
//  Copyright © 2017年 罗文琦. All rights reserved.
//

#import "Person+CoreDataProperties.h"

@implementation Person (CoreDataProperties)

+ (NSFetchRequest<Person *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Person"];
}

@dynamic name;
@dynamic age;

@end

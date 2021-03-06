//
//  CoreDataManager.h
//  TTT
//
//  Created by Hans Yelek on 3/21/14.
//  Copyright (c) 2014 Hans Yelek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CoreDataManager : NSObject
{
    NSManagedObjectContext * _context;
}

@property (nonatomic, readonly, strong) NSString *entityName;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;


- (id)initWithEntity:(NSString *)entity;

- (void)setManagedObjectContext;

- (void)fetchAllObjects;
- (NSManagedObject *)insertNewObject;
- (void)deleteObject:(NSManagedObject *)object;
- (void)saveContext;

@end

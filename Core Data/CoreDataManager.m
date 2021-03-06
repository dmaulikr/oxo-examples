//
//  CoreDataManager.m
//  TTT
//
//  Created by Hans Yelek on 3/21/14.
//  Copyright (c) 2014 Hans Yelek. All rights reserved.
//

#import <CoreData/CoreData.h>

#import "CoreDataManager.h"

@implementation CoreDataManager

#pragma mark - Initialization

- (id)init
{
    if (self = [super init])
    {
        _entityName = @"TTTBoard";
    }
    
    return self;
}

- (id)initWithEntity:(NSString *)entity
{
    if (self = [super init])
        _entityName = entity;
    
    return self;
}

#pragma mark - Core Data

- (void)setManagedObjectContext
{
    NSManagedObjectModel *managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    
    NSString *filePath = [NSHomeDirectory() stringByAppendingString:@"/Documents/TTTBoard.sqlite"];
    NSPersistentStoreCoordinator *storeCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
    
    // connect to store
    NSError *error = nil;
    NSURL *url = [NSURL fileURLWithPath:filePath];
    if (![storeCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:url options:nil error:&error])
    {
        NSLog(@"Persistent Store Coordinator creation failed: %@", [error.userInfo objectForKey:@"reason"]);
        return;
    }
    
    // set up the context
    _context = [[NSManagedObjectContext alloc] init];
    _context.persistentStoreCoordinator = storeCoordinator;
}

- (void)fetchAllObjects
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:_entityName inManagedObjectContext:_context];
    
    // initialize fetch request
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = entity;
    request.fetchBatchSize = 1;
    
    // sort descriptor
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"section" ascending:YES];
    request.sortDescriptors = @[sortDescriptor];
    
    // perform fetch
    NSError *error = nil;
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:_context sectionNameKeyPath:@"section" cacheName:@"tttCache"];
    
    if (![_fetchedResultsController performFetch:&error])
        NSLog(@"Error fetching data: %@", error.localizedFailureReason);
}

- (NSManagedObject *)insertNewObject
{
    return [NSEntityDescription insertNewObjectForEntityForName:_entityName inManagedObjectContext:_context];
}

- (void)deleteObject:(NSManagedObject *)object
{
    [_context deleteObject:object];
}

- (void)saveContext
{
    NSError *error = nil;
    if (![_context save:&error])
        NSLog(@"Error saving context: %@", error.localizedFailureReason);
}

@end

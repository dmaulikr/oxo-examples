//
//  StatisticsManager.m
//  TTT
//
//  Created by Hans Yelek on 10/21/14.
//  Copyright (c) 2014 Hans Yelek. All rights reserved.
//

#import "StatisticsManager.h"

#import "TTTStatistics.h"

@implementation StatisticsManager

- (TTTStatistics *)statsModelForPlayerID:(NSString *)playerID opponentType:(NSString *)opponentType
{
    [self fetchAllObjects];
    
    // search through the existing models
    for (TTTStatistics * statsModel in self.fetchedResultsController.fetchedObjects)
    {
        if ( [statsModel.playerID isEqualToString:playerID] && [statsModel.opponentType isEqualToString:opponentType] )
        {
            return statsModel;
        }
    }
    
    // if not found, create a new stats model
    return [self createNewStatsModelWithPlayerID:playerID opponentType:opponentType];
}

- (TTTStatistics *)createNewStatsModelWithPlayerID:(NSString *)playerID opponentType:(NSString *)opponentType
{
    TTTStatistics * newStatsModel = (TTTStatistics *)[self insertNewObject];
    
    [newStatsModel setPlayerID:playerID];
    [newStatsModel setOpponentType:opponentType];
    [newStatsModel clearStats];
    
    [self saveContext];
    
    return newStatsModel;
}

@end

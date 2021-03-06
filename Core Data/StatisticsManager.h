//
//  StatisticsManager.h
//  TTT
//
//  Created by Hans Yelek on 10/21/14.
//  Copyright (c) 2014 Hans Yelek. All rights reserved.
//

#import "CoreDataManager.h"

@class TTTStatistics;

@interface StatisticsManager : CoreDataManager

- (TTTStatistics *)statsModelForPlayerID:(NSString *)playerID opponentType:(NSString *)opponentType;

@end

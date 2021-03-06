//
//  GameCenterManager.h
//  TTT
//
//  Created by Hans Yelek on 9/26/14.
//  Copyright (c) 2014 Hans Yelek. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol GameCenterManagerDelegate <NSObject>
@required

- (void)presentAuthenticationDialogueViewController:(UIViewController *)viewController;

@end


@interface GameCenterManager : NSObject

@property (nonatomic, weak) id <GameCenterManagerDelegate> delegate;

@property (nonatomic, strong, readonly) NSArray * leaderboards;

@property (nonatomic, strong, readonly) NSMutableDictionary * achievements;

@property (nonatomic, assign, readonly) BOOL gameCenterIsEnabled;

@property (nonatomic, strong, readonly) NSString * playerID;    // the playerID property of the GKLocalPlayer object representing the local player
@property (nonatomic, strong, readonly) NSString * playerDisplayName;


+ (GameCenterManager *)sharedGameCenterManager;

- (void)authenticateLocalPlayer;

- (void)incrementCompletionLeaderboardsAndAchievements;
- (void)incrementWinScoreAgainstOpponent:(NSString *)opponentType;

- (void)completeWinAchievementForOpponentType:(NSString *)opponentType;

- (void)completeTricksyAchievement;


/*
 * used only for development testing
 */
- (void)resetAchievements;

@end

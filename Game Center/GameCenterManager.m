//
//  GameCenterManager.m
//  TTT
//
//  Created by Hans Yelek on 9/26/14.
//  Copyright (c) 2014 Hans Yelek. All rights reserved.
//

#import <GameKit/GameKit.h>

#import "TTTTheme.h"

#import "GameCenterManager.h"

#import "UserDefaultsConstants.h"   // for opponent type strings
#import "GameCenterConstants.h"     // Leaderboard and Achivement Identifiers
#import "ThemeConstants.h"

#define COMPLETE 100.0f

@implementation GameCenterManager

+ (id)sharedGameCenterManager
{
    static GameCenterManager * sharedGameCenterManager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedGameCenterManager = [[self alloc] init];
    });
    
    return sharedGameCenterManager;
}

- (id)init
{
    self = [super init];
    if ( self )
    {
        _playerID = @"noLocalPlayer";
        
        //[self resetAchievements]; // used for testing purposes only
    }
    
    return self;
}

#pragma mark - Authentication

/*
 * See Listing 3-1 from the Game Center Programming Guide
 */
- (void)authenticateLocalPlayer
{
    GKLocalPlayer * localPlayer = [GKLocalPlayer localPlayer];
    localPlayer.authenticateHandler = ^(UIViewController * vc, NSError * error) {
        
        NSString * oldPlayerID = [NSString stringWithString:_playerID];
        
        if (error) { NSLog(@"%@ : %@", NSStringFromSelector(_cmd) ,error.localizedDescription); }
        
        BOOL gameCenterWasEnabled = _gameCenterIsEnabled;
        
        if (vc)
        {
            _gameCenterIsEnabled = NO;
            _playerID = @"noLocalPlayer";
            
            [self showAuthenticationDialogue:vc];
        }
        else if (localPlayer.isAuthenticated)
        {
            _gameCenterIsEnabled = YES;
            _playerID = localPlayer.playerID;
            _playerDisplayName = localPlayer.alias;
            
            [self loadAuthenticatedPlayerData:localPlayer];
        }
        else    // disable Game Center here
        {
            _gameCenterIsEnabled = NO;
            _playerID = @"noLocalPlayer";
        }
        
        if ( (gameCenterWasEnabled != _gameCenterIsEnabled) || (! [oldPlayerID isEqualToString:_playerID]) )
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:kGameCenterStatusDidChangeNotification
                                                                object:self];
        }
    };
}

- (void)showAuthenticationDialogue:(UIViewController *)authenticationDialogueViewController
{
    if (! self.delegate) {
        NSLog(@"WARNING: GameCenterManager's delegate property is not set!");
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(presentAuthenticationDialogueViewController:)])
    {
        [self.delegate presentAuthenticationDialogueViewController:authenticationDialogueViewController];
    }
}

- (void)loadAuthenticatedPlayerData:(GKLocalPlayer *)localPlayer
{
    [self loadLeaderBoards];
    [self loadAchievements];
    
    // after testing is complete, comment out this line and UNCOMMENT the two lines above
    //[self resetAchievements];
}

- (void)disableGameCenter
{
    //self.gameCenterAuthenticationVC = nil;
}

#pragma mark - Leaderboards

/*
 * See Listing 4-1 of Game Center Programming Guide
 */
- (void)loadLeaderBoards
{
    [GKLeaderboard loadLeaderboardsWithCompletionHandler:^(NSArray * leaderboards, NSError * error) {
        
        if (error) { NSLog(@"%@ : %@", NSStringFromSelector(_cmd), error.localizedDescription); }
        
        
        _leaderboards = leaderboards;
        
        if (_leaderboards) [self loadLeaderboardLocalPlayerScores];
    }];
}

- (void)loadLeaderboardLocalPlayerScores
{
    for (GKLeaderboard * leaderboard in self.leaderboards)
    {
        leaderboard.playerScope = GKLeaderboardPlayerScopeFriendsOnly;
        // really, only the local player's score is desired
        
        [leaderboard loadScoresWithCompletionHandler:^(NSArray * scores, NSError * error) {
            
            if (error) NSLog(@"%@ : %@", NSStringFromSelector(_cmd), error.localizedDescription);
            
            // Nothing else is done here. The loadScoresWithCompletionHandler: method is called only to validate
            // the localPlayerScore property of the leaderboard
        }];
        
        
    }
}

- (void)resetLeaderBoards
{
    
}

#pragma mark - Achievements

/*
 * See Listing 5-4 in Game Center Programming Guide
 */
- (void)loadAchievements
{
    _achievements = [NSMutableDictionary dictionary];
    
    [GKAchievement loadAchievementsWithCompletionHandler:^(NSArray * achievements, NSError * error) {
        
        if (error) NSLog(@"%@ : %@", NSStringFromSelector(_cmd), error.localizedDescription);
        
        
        for (GKAchievement * achievement in achievements)
        {
            achievement.showsCompletionBanner = YES;
            [_achievements  setObject:achievement forKey:achievement.identifier];
        }
        
    }];
}

/*
 * See listing 5-4 and notes that follow.
 */
- (GKAchievement *)getAchievementForIdentifier:(NSString *)identifier
{
    GKAchievement * achievement = (GKAchievement *)[_achievements objectForKey:identifier];
    
    if (! achievement)
    {
        achievement = [[GKAchievement alloc] initWithIdentifier:identifier];
        
        [_achievements setObject:achievement forKey:identifier];
    }
    
    achievement.showsCompletionBanner = YES;
    
    return achievement;
}

- (void)incrementCompletionAchievements
{
    NSArray * achievementIdentifiers = @[kAchievementComplete50, kAchievementComplete100, kAchievementComplete150, kAchievementComplete200, kAchievementComplete250, kAchievementComplete300, kAchievementComplete350, kAchievementComplete400, kAchievementComplete450, kAchievementComplete500];
    
    NSMutableArray * achievementsToReport = [NSMutableArray array];
    
    
    // increment percentComplete property of unfinished achievements
    for (NSString * achievementID in achievementIdentifiers)
    {
        GKAchievement * achievement = [self getAchievementForIdentifier:achievementID];
        
        if (achievement) {
            
            double incrementUnit = [self incrementUnitForAchievementID:achievementID];
            
            
            // add incomplete achievements to the array for later reporting to Game Center
            if (! achievement.completed)
            {
                double percentComplete = achievement.percentComplete + incrementUnit;
                achievement.percentComplete = percentComplete;
                
                [achievementsToReport addObject:achievement];
                
                if ( percentComplete >= 100.0f )
                {
                    // should make a processCompletedAchievement: method for this block...
                    //
                    
                    
                    
                    // post notification here for completed achievement
                    [[NSNotificationCenter defaultCenter] postNotificationName:kCompletionAchievementReachedNotification
                                                                        object:self
                                                                      userInfo:@{@"achievementID":achievement.identifier}];
                }
            }
        }
    }
    
    
    // report achievements to Game Center
    [GKAchievement reportAchievements:achievementsToReport withCompletionHandler:^(NSError * error) {
        
        if (error)  NSLog(@"%@\n%@", NSStringFromSelector(_cmd), error.localizedDescription);
        
    }];
}

- (void)completeWinAchievementForOpponentType:(NSString *)opponentType
{
    NSString * achievementID = [self achievementIdentifierForOpponentType:opponentType];
    
    GKAchievement * achievement = [self getAchievementForIdentifier:achievementID];
    
    if (achievement) {
        
        achievement.percentComplete = COMPLETE;
        
        [GKAchievement reportAchievements:@[achievement] withCompletionHandler:^(NSError * error) {
            
            if (error) NSLog(@"%@\n%@\n", NSStringFromSelector(_cmd), error.localizedDescription);
        }];
    }
}

- (void)completeTricksyAchievement
{
    GKAchievement * achievement = [self getAchievementForIdentifier:kAchievementCompleteTricksy];
    
    if ( achievement )
    {
        achievement.percentComplete = COMPLETE;
        
        [GKAchievement reportAchievements:@[achievement] withCompletionHandler:^(NSError * error){
            if ( error ) NSLog(@"%@\n%@\n", NSStringFromSelector(_cmd), error.localizedDescription);
        }];
    }
}

/*
 * Note: This method is being used for testing purposes only.
 */
- (void)resetAchievements
{
    [[NSUserDefaults standardUserDefaults] setObject:@NO forKey:kThemePackPreviewIsInProgressKey];
    [[NSUserDefaults standardUserDefaults] setObject:@0 forKey:kThemePackPreviewCountKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // clear achievements dictionary
    _achievements = [[NSMutableDictionary alloc] init];
    
    [GKAchievement resetAchievementsWithCompletionHandler:^(NSError * error) {
        
        NSLog(@"Achievements Reset!");
        if (error) { NSLog(@"\n%@\n\n%@\n\n", NSStringFromSelector(_cmd), error.localizedDescription); }
        
        [self loadLeaderBoards];
        [self loadAchievements];
    }];
}

#pragma mark - Score Updating

// PUBLIC
- (void)incrementCompletionLeaderboardsAndAchievements
{
    [self incrementLeaderboard_TotalGamesPlayed];
    [self incrementCompletionAchievements];
}


// PUBLIC
- (void)incrementWinScoreAgainstOpponent:(NSString *)opponentType
{
    // increment Leaderboards: total games
    // increment Achievements: completions
    
    [self incrementLeaderboard_TotalGamesPlayed];
    [self incrementCompletionAchievements];
    
    if ([opponentType isEqualToString:kOpponentAI_Naive]    ||
        [opponentType isEqualToString:kOpponentAI_Seasoned] ||
        [opponentType isEqualToString:kOpponentAI_Master])
    {
        [self incrementLeaderboardForOpponentType:opponentType];
    }
}

- (void)incrementLeaderboard_TotalGamesPlayed
{
    GKLeaderboard * totalGamesPlayedLeaderboard = [self getLeaderboard_TotalGamesPlayed];
    
    if (totalGamesPlayedLeaderboard) {
        
        GKScore * oldScore = totalGamesPlayedLeaderboard.localPlayerScore;
        GKScore * newScore = [[GKScore alloc] initWithLeaderboardIdentifier:totalGamesPlayedLeaderboard.identifier];
        
        
        newScore.value = oldScore.value + 1;
        
        [GKScore reportScores:@[newScore] withCompletionHandler:^(NSError * error){
            
            if (error) NSLog(@"%@ : %@", NSStringFromSelector(_cmd), error.description);
            
        }];
    }
}

- (void)incrementLeaderboardForOpponentType:(NSString *)opponentType
{
    GKLeaderboard * leaderboard = [self getLeaderboardForOpponentType:opponentType];
    
    if (leaderboard)
    {
        GKScore * oldscore = leaderboard.localPlayerScore;
        GKScore * newscore = [[GKScore alloc] initWithLeaderboardIdentifier:leaderboard.identifier];
        
        
        newscore.value = oldscore.value + 1;
        
        [GKScore reportScores:@[newscore] withCompletionHandler:^(NSError * error) {
            
            if (error) NSLog(@"%@ : %@", NSStringFromSelector(_cmd), error.localizedDescription);
            
        }];
    }
    else
    {
        NSLog(@"%@\nError: Leaderboard for opponent type (%@) not returned.", NSStringFromSelector(_cmd), opponentType);
    }
}

#pragma mark - Utility

- (GKLeaderboard *)getLeaderboard_TotalGamesPlayed
{
    GKLeaderboard * totalGamesLeaderboard = nil;
    
    for (GKLeaderboard * leaderboard in self.leaderboards)
    {
        if ([leaderboard.identifier isEqualToString:@"leaderboard.gamesPlayed"])
        {
            totalGamesLeaderboard = leaderboard;
            break;
        }
    }
    
    return totalGamesLeaderboard;
}

- (GKLeaderboard *)getLeaderboardForOpponentType:(NSString *)opponentType
{
    GKLeaderboard * leaderboard;
    NSString * leaderboardID = [self leaderboardIdentifierForOpponentType:opponentType];
    
    for (GKLeaderboard * lb in self.leaderboards)
    {
        if ([lb.identifier isEqualToString:leaderboardID])
        {
            leaderboard = lb;
            break;
        }
    }
    
    return leaderboard;
}

- (NSString *)leaderboardIdentifierForOpponentType:(NSString *)opponentType
{
    if      ([opponentType isEqualToString:kOpponentAI_Naive])      { return kLeaderboardWinsNaiveID; }
    else if ([opponentType isEqualToString:kOpponentAI_Seasoned])   { return kLeaderboardWinsSeasonedID; }
    else if ([opponentType isEqualToString:kOpponentAI_Master])     { return kLeaderboardWinsMasterID; }
    
    return nil;
}

- (NSString *)achievementIdentifierForOpponentType:(NSString *)opponentType
{
    if      ([opponentType isEqualToString:kOpponentAI_Naive])      { return kAchievementNaiveID; }
    else if ([opponentType isEqualToString:kOpponentAI_Seasoned])   { return kAchievementSeasonedID; }
    else if ([opponentType isEqualToString:kOpponentAI_Master])     { return kAchievementMasterID; }
    
    return nil;
}

- (double)incrementUnitForAchievementID:(NSString *)identifier
{
    if      ([identifier isEqualToString:kAchievementComplete50])   { return 2;       /* (1.0 / 50) * 100 */ }
    else if ([identifier isEqualToString:kAchievementComplete100])  { return 1;       /* (1.0 / 100) * 100 */ }
    else if ([identifier isEqualToString:kAchievementComplete150])  { return (1.0 / 150) * 100; }
    else if ([identifier isEqualToString:kAchievementComplete200])  { return 0.5f;    /* (1.0 / 200) * 100 */ }
    else if ([identifier isEqualToString:kAchievementComplete250])  { return 0.4f;    /* (1.0 / 250) * 100 */ }
    else if ([identifier isEqualToString:kAchievementComplete300])  { return (1.0 / 300) * 100; }
    else if ([identifier isEqualToString:kAchievementComplete350])  { return (1.0 / 350) * 100; }
    else if ([identifier isEqualToString:kAchievementComplete400])  { return 0.25;    /* (1.0 / 400) * 100 */ }
    else if ([identifier isEqualToString:kAchievementComplete450])  { return (1.0 / 450) * 100; }
    else if ([identifier isEqualToString:kAchievementComplete500])  { return 0.2f;    /* (1.0 / 500) * 100 */ }
    else { return 0; }
}

@end

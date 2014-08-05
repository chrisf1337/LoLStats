//
//  CFSummoner.h
//  LoLStats
//
//  Created by Christopher Fu on 7/25/14.
//  Copyright (c) 2014 Christopher Fu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CDFSummoner : NSObject

@property (nonatomic) NSString *name;
@property (nonatomic) NSNumber *level;
@property (nonatomic) NSNumber *idNumber;
@property (nonatomic) NSNumber *profileIconId;

@property (nonatomic) NSString *soloQueueLeagueTier;
@property (nonatomic) NSString *soloQueueLeagueDivision;

@property (nonatomic) int totalTrackedGames;
@property (nonatomic) int totalTrackedWins;

@property (nonatomic) int totalTrackedKills;
@property (nonatomic) int totalTrackedDeaths;
@property (nonatomic) int totalTrackedAssists;

@property (nonatomic) NSMutableArray *recentGames;

+ (instancetype)summonerWithName:(NSString *)name level:(NSNumber *)level idNumber:(NSNumber *)number;

- (instancetype)initWithName:(NSString *)name level:(NSNumber *)level idNumber:(NSNumber *)number;
- (NSString *)description;

@end

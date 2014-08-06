//
//  CFSummoner.m
//  LoLStats
//
//  Created by Christopher Fu on 7/25/14.
//  Copyright (c) 2014 Christopher Fu. All rights reserved.
//

#import "CDFSummoner.h"

@implementation CDFSummoner

+ (instancetype)summonerWithName:(NSString *)name level:(NSNumber *)level idNumber:(NSNumber *)idNumber
{
    return [[CDFSummoner alloc] initWithName:name level:level idNumber:idNumber];
}

+ (instancetype)summonerFromDictionary:(NSDictionary *)dict
{
    CDFSummoner *summoner = [[CDFSummoner alloc] initWithName:[dict objectForKey:@"name"]
                                                        level:[dict objectForKey:@"level"]
                                                     idNumber:[dict objectForKey:@"idNumber"]];
    summoner.profileIconId = [dict objectForKey:@"profileIconId"];
    summoner.soloQueueLeagueTier = [dict objectForKey:@"soloQueueLeagueTier"];
    summoner.soloQueueLeagueDivision = [dict objectForKey:@"soloQueueLeagueDivision"];
    summoner.totalTrackedGames = [(NSNumber *)[dict objectForKey:@"totalTrackedGames"] intValue];
    summoner.totalTrackedWins = [(NSNumber *)[dict objectForKey:@"totalTrackedWins"] intValue];
    summoner.totalTrackedKills = [(NSNumber *)[dict objectForKey:@"totalTrackedKills"] intValue];
    summoner.totalTrackedDeaths = [(NSNumber *)[dict objectForKey:@"totalTrackedDeaths"] intValue];
    summoner.totalTrackedAssists = [(NSNumber *)[dict objectForKey:@"totalTrackedAssists"] intValue];
    summoner.recentGames = [dict objectForKey:@"recentGames"];
    return summoner;
}

- (instancetype)initWithName:(NSString *)name level:(NSNumber *)level idNumber:(NSNumber *)idNumber
{
    self = [super init];
    if (self)
    {
        _name = name;
        _level = level;
        _idNumber = idNumber;
        _recentGames = [[NSMutableArray alloc] init];
        _totalTrackedGames = 0;
        _totalTrackedWins = 0;
        _totalTrackedKills = 0;
        _totalTrackedDeaths = 0;
        _totalTrackedAssists = 0;
        _soloQueueLeagueTier = @"Unranked";
        _soloQueueLeagueDivision = @"";
        _recentGames = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSDictionary *)toDictionary
{
    return @{@"name": self.name,
             @"level": self.level,
             @"idNumber": self.idNumber,
             @"profileIconId": self.profileIconId,
             @"soloQueueLeagueTier": self.soloQueueLeagueTier,
             @"soloQueueLeagueDivision": self.soloQueueLeagueDivision,
             @"totalTrackedGames": [NSNumber numberWithInt:self.totalTrackedGames],
             @"totalTrackedWins": [NSNumber numberWithInt:self.totalTrackedWins],
             @"totalTrackedKills": [NSNumber numberWithInt:self.totalTrackedKills],
             @"totalTrackedDeaths": [NSNumber numberWithInt:self.totalTrackedDeaths],
             @"totalTrackedAssists": [NSNumber numberWithInt:self.totalTrackedAssists],
             @"recentGames": self.recentGames};
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ (ID: %@, Tier: %@, level %@, KDA: %d/%d/%d)",
            self.name, self.idNumber, self.soloQueueLeagueTier, self.level, self.totalTrackedKills,
            self.totalTrackedDeaths, self.totalTrackedAssists];
}

@end

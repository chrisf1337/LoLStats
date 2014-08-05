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
        _totalTrackedKills = 0;
        _totalTrackedDeaths = 0;
        _totalTrackedAssists = 0;
        _soloQueueLeagueTier = @"Unranked";
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ (ID: %@, Tier: %@, level %@, KDA: %d/%d/%d)",
            self.name, self.idNumber, self.soloQueueLeagueTier, self.level, self.totalTrackedKills,
            self.totalTrackedDeaths, self.totalTrackedAssists];
}

@end

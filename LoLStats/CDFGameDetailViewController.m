//
//  CDFGameDetailViewController.m
//  LoLStats
//
//  Created by Christopher Fu on 7/30/14.
//  Copyright (c) 2014 Christopher Fu. All rights reserved.
//

#import "CDFGameDetailViewController.h"
#import "CDFSummonerDetailViewController.h"
#import "UIViewController+UIViewControllerAdditions.h"
#import "UIImage+UIImageAdditions.h"
#import "apikey.h"
#import "CDFSummoner.h"

@interface CDFGameDetailViewController ()

@property (nonatomic) NSArray *gameStatsArray;
@property (nonatomic) NSDictionary *gameSubtypeDict;
@property (nonatomic) NSNumber *gameTeamId;
@property (nonatomic) NSArray *gameFellowPlayers;
@property (nonatomic) NSMutableArray *gameTeammates;
@property (nonatomic) NSMutableArray *gameOpponents;

@property (nonatomic) NSMutableData *responseData;
@property (nonatomic) NSURLConnection *summonerInfoRequest;
@property (nonatomic) NSDictionary *requestedSummonerObjects;

@property (nonatomic) NSURLConnection *summonerStatsSummaryRequest;
@property (nonatomic) NSURLConnection *summonerLeagueEntriesRequest;

- (void)buildGameStatsArray;

@end

@implementation CDFGameDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Game Detail";
    self.responseData = [[NSMutableData alloc] init];
    self.gameTeammates = [[NSMutableArray alloc] init];
    self.gameOpponents = [[NSMutableArray alloc] init];
    self.gameSubtypeDict = @{@"NORMAL": @"Normal",
                             @"BOT": @"Bot",
                             @"BOT_3x3": @"Bot",
                             @"ARAM_UNRANKED_5x5": @"ARAM",
                             @"RANKED_SOLO_5x5": @"Ranked",
                             @"CAP_5x5": @"Dominion"};
    self.lblSummonerName.text = self.summoner.name;
    NSNumber *championId = [self.gameInfo objectForKey:@"championId"];
    int championLevel = [(NSNumber *)[[self.gameInfo objectForKey:@"stats"] objectForKey:@"level"] intValue];
    self.lblChampionName.text = [NSString stringWithFormat:@"%@ (Lv. %d)",
                                 [[self.championIds objectForKey:championId] objectForKey:@"name"],
                                 championLevel];
    NSString *championIconPath = [NSString stringWithFormat:@"%@.png",
                                  [[self.championIds objectForKey:championId] objectForKey:@"key"]];
    self.imgSummonerIcon.image = [UIImage imageNamed:championIconPath
                                        scaledToSize:CGSizeMake(self.imgSummonerIcon.bounds.size.width,
                                                                self.imgSummonerIcon.bounds.size.height)];
    int gameLength = [(NSNumber *)[[self.gameInfo objectForKey:@"stats"] objectForKey:@"timePlayed"] intValue];
    int gameLengthMin = gameLength / 60;
    int gameLengthSec = gameLength % 60;
    NSString *gameLengthString;
    if (gameLengthSec < 10)
    {
        gameLengthString = [NSString stringWithFormat:@"%d:0%d", gameLengthMin, gameLengthSec];
    }
    else
    {
        gameLengthString = [NSString stringWithFormat:@"%d:%d", gameLengthMin, gameLengthSec];
    }
    if ([[[self.gameInfo objectForKey:@"stats"] objectForKey:@"win"] boolValue])
    {
        self.lblWinLoss.text = [NSString stringWithFormat:@"WIN (%@)", gameLengthString];
        self.lblWinLoss.textColor = [UIColor colorWithRed:0 green:0.4 blue:0 alpha:1];
    }
    else
    {
        self.lblWinLoss.text = [NSString stringWithFormat:@"LOSS (%@)", gameLengthString];
        self.lblWinLoss.textColor = [UIColor redColor];
    }
    self.gameTeamId = [self.gameInfo objectForKey:@"teamId"];
    [self buildGameStatsArray];
    self.gameFellowPlayers = [self.gameInfo objectForKey:@"fellowPlayers"];
    for (NSDictionary *player in self.gameFellowPlayers)
    {
        if ([[player objectForKey:@"teamId"] isEqualToNumber:self.gameTeamId])
        {
            [self.gameTeammates addObject:player];
        }
        else
        {
            [self.gameOpponents addObject:player];
        }
    }
    NSMutableString *gameFellowPlayerIds = [[NSMutableString alloc] init];
    for (NSDictionary *player in self.gameFellowPlayers)
    {
        [gameFellowPlayerIds appendFormat:@"%@,", [player objectForKey:@"summonerId"]];
    }
    NSString *requestString = [NSString stringWithFormat:
                               @"https://na.api.pvp.net/api/lol/na/v1.4/summoner/%@?api_key=%@",
                               gameFellowPlayerIds, API_KEY];
    self.summonerInfoRequest = [self performRequestWithURLString:requestString];
}

- (void)viewDidAppear:(BOOL)animated
{
    for (int i = 0; i < self.gameStatsArray.count; i++)
    {
        UITableViewCell *cell = [self.tblGameStats cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        cell.userInteractionEnabled = NO;
    }
    [self.tblGameStats cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]].userInteractionEnabled = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)buildGameStatsArray
{
    NSDictionary *gameStats = [self.gameInfo objectForKey:@"stats"];
    NSArray *gameKDA = @[@"KDA:",
                         [NSString stringWithFormat:@"%d/%d/%d",
                          [(NSNumber *)[gameStats objectForKey:@"championsKilled"] intValue],
                          [(NSNumber *)[gameStats objectForKey:@"numDeaths"] intValue],
                          [(NSNumber *)[gameStats objectForKey:@"assists"] intValue]]];
    NSString *gameTypeString = [self.gameInfo objectForKey:@"gameType"];
    NSString *gameSubtypeString = [self.gameInfo objectForKey:@"subType"];
    NSArray *gameType;
    if ([gameTypeString isEqualToString:@"MATCHED_GAME"])
    {
        gameType = @[@"Game type:", [self.gameSubtypeDict objectForKey:gameSubtypeString]];
    }
    else
    {
        gameType = @[@"Game type:", @"Unknown"];
    }
    int cs = [[gameStats objectForKey:@"neutralMinionsKilled"] intValue] +
             [[gameStats objectForKey:@"minionsKilled"] intValue];
    NSArray *gameCs = @[@"CS:", [NSString stringWithFormat:@"%d", cs]];
    long goldEarned = [(NSNumber *)[gameStats objectForKey:@"goldEarned"] longValue];
    NSArray *gameGold = @[@"Gold earned:", [NSString stringWithFormat:@"%.1fk", goldEarned / 1000.0]];
    self.gameStatsArray = @[gameKDA, gameType, gameCs, gameGold];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    if (httpResponse.statusCode == 404)
    {
        //        [self showAlertWithTitle:@"Summoner not found!" message:@"The summoner name you have entered was not found."];
    }
    self.responseData.length = 0;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSLog(@"Received data!");
    [self.responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"Connection failed: %@", [error description]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"Received %d bytes of data", self.responseData.length);
    NSError *error;
    if (connection == self.summonerInfoRequest)
    {
        NSDictionary *summonerInfo = [NSJSONSerialization JSONObjectWithData:self.responseData
                                                                     options:kNilOptions
                                                                       error:&error];
        if (summonerInfo != nil)
        {
            self.requestedSummonerObjects = summonerInfo;
        }
        [self.tblTeammates reloadData];
        [self.tblOpponents reloadData];
    }
    else if (connection == self.summonerStatsSummaryRequest)
    {
        NSDictionary *summonerStatsSummary = [NSJSONSerialization JSONObjectWithData:self.responseData
                                                                             options:kNilOptions
                                                                               error:&error];
        if (summonerStatsSummary != nil)
        {
            self.nextSummoner.recentGames = [NSMutableArray arrayWithArray:
                                             [summonerStatsSummary objectForKey:@"games"]];
            self.nextSummoner.totalTrackedGames = self.nextSummoner.recentGames.count;
            for (NSDictionary *game in self.nextSummoner.recentGames)
            {
                NSDictionary *stats = [game objectForKey:@"stats"];
                self.nextSummoner.totalTrackedKills += [(NSNumber *)[stats objectForKey:@"championsKilled"] intValue];
                self.nextSummoner.totalTrackedDeaths += [(NSNumber *)[stats objectForKey:@"numDeaths"] intValue];
                self.nextSummoner.totalTrackedAssists += [(NSNumber *)[stats objectForKey:@"assists"] intValue];
                if ([[stats objectForKey:@"win"] boolValue])
                {
                    self.nextSummoner.totalTrackedWins++;
                }
            }
        }
        NSLog(@"%d/%d/%d (W: %d)", self.nextSummoner.totalTrackedKills, self.nextSummoner.totalTrackedDeaths,
              self.nextSummoner.totalTrackedAssists, self.nextSummoner.totalTrackedWins);
        NSString *requestString = [NSString stringWithFormat:
                                   @"https://na.api.pvp.net/api/lol/na/v2.4/league/by-summoner/%@/entry?api_key=%@",
                                   self.nextSummoner.idNumber, API_KEY];
        NSLog(@"%@", requestString);
        self.summonerLeagueEntriesRequest = [self performRequestWithURLString:requestString];
    }
    else if (connection == self.summonerLeagueEntriesRequest)
    {
        NSDictionary *summonerLeagueEntries = [NSJSONSerialization JSONObjectWithData:self.responseData
                                                                              options:kNilOptions
                                                                                error:&error];
        if (summonerLeagueEntries != nil)
        {
            summonerLeagueEntries = [summonerLeagueEntries objectForKey:
                                     [NSString stringWithFormat:@"%@", self.nextSummoner.idNumber]];
            for (NSDictionary *entry in summonerLeagueEntries)
            {
                if ([(NSString *)[entry objectForKey:@"queue"] isEqualToString:@"RANKED_SOLO_5x5"])
                {
                    NSString *tier = [entry objectForKey:@"tier"];
                    self.nextSummoner.soloQueueLeagueTier = [tier capitalizedString];
                    self.nextSummoner.soloQueueLeagueDivision = [[entry objectForKey:@"entries"][0] objectForKey:@"division"];
                }
            }
        }
        else
        {
            self.nextSummoner.soloQueueLeagueTier = @"Unranked";
            self.nextSummoner.soloQueueLeagueDivision = @"";
        }
        ((CDFSummonerDetailViewController *)[self backViewController]).summoner = self.nextSummoner;
        [self.navigationController popViewControllerAnimated:YES];
    }
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tblGameStats)
    {
        return self.gameStatsArray.count;
    }
    else if (tableView == self.tblTeammates)
    {
        return self.gameTeammates.count;
    }
    else
    {
        return self.gameOpponents.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tblGameStats)
    {
        UITableViewCell *cell = [self.tblGameStats dequeueReusableCellWithIdentifier:@"statCell"];
        UILabel *stat = (UILabel *)[cell viewWithTag:100];
        stat.text = self.gameStatsArray[indexPath.row][0];
        UILabel *value = (UILabel *)[cell viewWithTag:101];
        value.text = self.gameStatsArray[indexPath.row][1];
        return cell;
    }
    else if (tableView == self.tblTeammates)
    {
        UITableViewCell *cell = [self.tblTeammates dequeueReusableCellWithIdentifier:@"playerCell"];
        UIImageView *championIconView = (UIImageView *)[cell viewWithTag:200];
        UILabel *teammateNameLabel = (UILabel *)[cell viewWithTag:201];
        UILabel *kdaLabel = (UILabel *)[cell viewWithTag:202];
        NSDictionary *teammate = self.gameTeammates[indexPath.row];
        teammateNameLabel.text = [[self.requestedSummonerObjects objectForKey:
                                   [(NSNumber *)[teammate objectForKey:@"summonerId"] stringValue]] objectForKey:@"name"];

        NSNumber *championId = [teammate objectForKey:@"championId"];
//        NSString *championName = [(NSDictionary *)[self.championIds objectForKey:championId] objectForKey:@"name"];
        NSString *championKey = [(NSDictionary *)[self.championIds objectForKey:championId] objectForKey:@"key"];

        UIImage *championIcon = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png", championKey]
                                       scaledToSize:CGSizeMake(championIconView.bounds.size.width,
                                                               championIconView.bounds.size.height)];
        championIconView.image = championIcon;
        kdaLabel.text = @"";
        return cell;
    }
    else
    {
        UITableViewCell *cell = [self.tblOpponents dequeueReusableCellWithIdentifier:@"playerCell"];
        UIImageView *championIconView = (UIImageView *)[cell viewWithTag:300];
        UILabel *opponentNameLabel = (UILabel *)[cell viewWithTag:301];
        UILabel *kdaLabel = (UILabel *)[cell viewWithTag:302];
        NSDictionary *opponent = self.gameOpponents[indexPath.row];
        opponentNameLabel.text = [[self.requestedSummonerObjects objectForKey:
                                   [(NSNumber *)[opponent objectForKey:@"summonerId"] stringValue]] objectForKey:@"name"];

        NSNumber *championId = [opponent objectForKey:@"championId"];
        //        NSString *championName = [(NSDictionary *)[self.championIds objectForKey:championId] objectForKey:@"name"];
        NSString *championKey = [(NSDictionary *)[self.championIds objectForKey:championId] objectForKey:@"key"];

        UIImage *championIcon = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png", championKey]
                                       scaledToSize:CGSizeMake(championIconView.bounds.size.width,
                                                               championIconView.bounds.size.height)];
        championIconView.image = championIcon;
        kdaLabel.text = @"";

        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tblGameStats)
    {
        if (indexPath.row == 0)
        {
            UITableViewCell *cell = [self.tblGameStats cellForRowAtIndexPath:
                                     [NSIndexPath indexPathForRow:0 inSection:0]];
            UILabel *value = (UILabel *)[cell viewWithTag:101];
            if ([value.text rangeOfString:@"/"].location != NSNotFound)
            {
                if (self.summoner.totalTrackedDeaths == 0)
                {
                    value.text = @"Perfect:1";
                }
                else
                {
                    double kda = (double)(self.summoner.totalTrackedKills +
                                          self.summoner.totalTrackedAssists) / self.summoner.totalTrackedDeaths;
                    value.text = [NSString stringWithFormat:@"%.2f:1", kda];
                }
            }
            else
            {
                value.text = [NSString stringWithFormat:@"%.1f/%.1f/%.1f",
                              (double)self.summoner.totalTrackedKills / self.summoner.totalTrackedGames,
                              (double)self.summoner.totalTrackedDeaths / self.summoner.totalTrackedGames,
                              (double)self.summoner.totalTrackedAssists / self.summoner.totalTrackedGames];
            }
            [self.tblGameStats deselectRowAtIndexPath:indexPath animated:YES];
        }
    }
    else if (tableView == self.tblTeammates)
    {
        NSDictionary *teammate = self.gameTeammates[indexPath.row];
        NSDictionary *summonerObject = [self.requestedSummonerObjects objectForKey:
                                        [(NSNumber *)[teammate objectForKey:@"summonerId"] stringValue]];
        self.nextSummoner = [CDFSummoner
                            summonerWithName:[summonerObject objectForKey:@"name"]
                            level:(NSNumber *)[summonerObject objectForKey:@"summonerLevel"]
                            idNumber:(NSNumber *)[summonerObject objectForKey:@"id"]];
        self.nextSummoner.profileIconId = [summonerObject objectForKey:@"profileIconId"];

        // recent games
        NSString *requestString = [NSString stringWithFormat:
                                   @"https://na.api.pvp.net/api/lol/na/v1.3/game/by-summoner/%@/recent?api_key=%@",
                                   self.nextSummoner.idNumber, API_KEY];
        self.summonerStatsSummaryRequest = [self performRequestWithURLString:requestString];
        NSLog(@"%@", self.nextSummoner);
    }
    else
    {
        NSDictionary *opponent = self.gameOpponents[indexPath.row];
        NSDictionary *summonerObject = [self.requestedSummonerObjects objectForKey:
                                        [(NSNumber *)[opponent objectForKey:@"summonerId"] stringValue]];
        self.nextSummoner = [CDFSummoner
                             summonerWithName:[summonerObject objectForKey:@"name"]
                             level:(NSNumber *)[summonerObject objectForKey:@"summonerLevel"]
                             idNumber:(NSNumber *)[summonerObject objectForKey:@"id"]];
        self.nextSummoner.profileIconId = [summonerObject objectForKey:@"profileIconId"];

        // recent games
        NSString *requestString = [NSString stringWithFormat:
                                   @"https://na.api.pvp.net/api/lol/na/v1.3/game/by-summoner/%@/recent?api_key=%@",
                                   self.nextSummoner.idNumber, API_KEY];
        self.summonerStatsSummaryRequest = [self performRequestWithURLString:requestString];
        NSLog(@"%@", self.nextSummoner);
    }
}

@end

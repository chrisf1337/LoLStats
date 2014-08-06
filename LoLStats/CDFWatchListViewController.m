//
//  CDFWatchListViewController.m
//  LoLStats
//
//  Created by Christopher Fu on 8/4/14.
//  Copyright (c) 2014 Christopher Fu. All rights reserved.
//

#import "CDFWatchListViewController.h"
#import "UIImage+UIImageAdditions.h"
#import "UIViewController+UIViewControllerAdditions.h"
#import "CDFSummoner.h"
#import "CDFSummonerDetailViewController.h"
#import "CDFAdderViewController.h"
#import "apikey.h"

@interface CDFWatchListViewController ()

@property (nonatomic) NSMutableData *responseData;


@property (nonatomic) CDFSummoner *selectedSummoner;
@property (nonatomic) NSURLConnection *championIdRequest;
@property (nonatomic) NSURLConnection *summonerSpellInfoRequest;
@property (nonatomic) NSURLConnection *summonerStatsSummaryRequest;
@property (nonatomic) NSURLConnection *summonerLeagueEntriesRequest;

@end

@implementation CDFWatchListViewController

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
    self.title = @"Watch List";
    self.responseData = [[NSMutableData alloc] init];
    NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSError *error;
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"watchlist.json"];
    NSLog(@"%@", path);
    if (![[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        NSLog(@"File does not exist.");
        [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil];
        [@"[]" writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error];
        NSData *fileContents = [NSData dataWithContentsOfFile:path];
        NSArray *array = [NSJSONSerialization JSONObjectWithData:fileContents
                                                         options:kNilOptions
                                                           error:&error];
        self.watchList = [NSMutableArray arrayWithArray:array];
    }
    else
    {
        NSLog(@"File exists.");
        NSData *fileContents = [NSData dataWithContentsOfFile:path];
        NSArray *array = [NSJSONSerialization JSONObjectWithData:fileContents
                                                         options:kNilOptions
                                                           error:&error];
        if (array != nil)
        {
            self.watchList = [NSMutableArray arrayWithArray:array];
        }
    }
    NSString *requestString = [NSString stringWithFormat:
                               @"https://na.api.pvp.net/api/lol/static-data/na/v1.2/champion?api_key=%@",
                               API_KEY];
    self.championIdRequest = [self performRequestWithURLString:requestString];
    requestString = [NSString stringWithFormat:
                     @"https://na.api.pvp.net/api/lol/static-data/na/v1.2/summoner-spell?api_key=%@",
                     API_KEY];
    self.summonerSpellInfoRequest = [self performRequestWithURLString:requestString];
}

- (void)viewWillAppear:(BOOL)animated
{
    NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSError *error;
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"watchlist.json"];
    NSData *fileContents = [NSJSONSerialization dataWithJSONObject:self.watchList
                                                           options:kNilOptions
                                                             error:&error];
    [fileContents writeToFile:path atomically:YES];
    [self.tblWatchList reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSError *error;
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"watchlist.json"];
    NSData *fileContents = [NSJSONSerialization dataWithJSONObject:self.watchList
                                                           options:kNilOptions
                                                             error:&error];
    [fileContents writeToFile:path atomically:YES];
    [self.tblWatchList reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    if (connection == self.summonerStatsSummaryRequest)
    {
        NSDictionary *summonerStatsSummary = [NSJSONSerialization JSONObjectWithData:self.responseData
                                                                             options:kNilOptions
                                                                               error:&error];
        if (summonerStatsSummary != nil)
        {
            self.selectedSummoner.recentGames = [NSMutableArray arrayWithArray:
                                                 [summonerStatsSummary objectForKey:@"games"]];
            self.selectedSummoner.totalTrackedGames = self.selectedSummoner.recentGames.count;
            self.selectedSummoner.totalTrackedWins = 0;
            self.selectedSummoner.totalTrackedKills = 0;
            self.selectedSummoner.totalTrackedDeaths = 0;
            self.selectedSummoner.totalTrackedAssists = 0;
            for (NSDictionary *game in self.selectedSummoner.recentGames)
            {
                NSDictionary *stats = [game objectForKey:@"stats"];
                self.selectedSummoner.totalTrackedKills += [(NSNumber *)[stats objectForKey:@"championsKilled"] intValue];
                self.selectedSummoner.totalTrackedDeaths += [(NSNumber *)[stats objectForKey:@"numDeaths"] intValue];
                self.selectedSummoner.totalTrackedAssists += [(NSNumber *)[stats objectForKey:@"assists"] intValue];
                if ([[stats objectForKey:@"win"] boolValue])
                {
                    self.selectedSummoner.totalTrackedWins++;
                }
            }
        }
        NSLog(@"%d/%d/%d (W: %d)", self.selectedSummoner.totalTrackedKills, self.selectedSummoner.totalTrackedDeaths,
              self.selectedSummoner.totalTrackedAssists, self.selectedSummoner.totalTrackedWins);
        NSLog(@"%@", self.selectedSummoner);
        NSString *requestString = [NSString stringWithFormat:
                                   @"https://na.api.pvp.net/api/lol/na/v2.4/league/by-summoner/%@/entry?api_key=%@",
                                   self.selectedSummoner.idNumber, API_KEY];
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
                                     [NSString stringWithFormat:@"%@", self.selectedSummoner.idNumber]];
            for (NSDictionary *entry in summonerLeagueEntries)
            {
                if ([(NSString *)[entry objectForKey:@"queue"] isEqualToString:@"RANKED_SOLO_5x5"])
                {
                    NSString *tier = [entry objectForKey:@"tier"];
                    self.selectedSummoner.soloQueueLeagueTier = [tier capitalizedString];
                    self.selectedSummoner.soloQueueLeagueDivision = [[entry objectForKey:@"entries"][0] objectForKey:@"division"];
                }
            }
        }
        else
        {
            self.selectedSummoner.soloQueueLeagueTier = @"Unranked";
            self.selectedSummoner.soloQueueLeagueDivision = @"";
        }
        [self performSegueWithIdentifier:@"displaySummonerDetailFromWatch" sender:self];
    }
    else if (connection == self.championIdRequest)
    {
        NSDictionary *championIdsDict = [NSJSONSerialization JSONObjectWithData:self.responseData
                                                                        options:kNilOptions
                                                                          error:&error];
        if (championIdsDict != nil)
        {
            self.championIds = [NSMutableDictionary dictionaryWithDictionary:[championIdsDict objectForKey:@"data"]];
            NSArray *keys = [self.championIds allKeys];
            for (NSString *key in keys)
            {
                NSDictionary *info = [self.championIds objectForKey:key];
                [self.championIds removeObjectForKey:key];
                [self.championIds setObject:info forKey:[info objectForKey:@"id"]];
            }
        }
    }
    else if (connection == self.summonerSpellInfoRequest)
    {
        NSDictionary *summonerSpellsDict = [NSJSONSerialization JSONObjectWithData:self.responseData
                                                                           options:kNilOptions
                                                                             error:&error];
        if (summonerSpellsDict != nil)
        {
            self.summonerSpells = [NSMutableDictionary dictionaryWithDictionary:[summonerSpellsDict objectForKey:@"data"]];
            NSArray *keys = [self.summonerSpells allKeys];
            for (NSString *key in keys)
            {
                NSDictionary *info = [self.summonerSpells objectForKey:key];
                [self.summonerSpells removeObjectForKey:key];
                [self.summonerSpells setObject:info forKey:[info objectForKey:@"id"]];
            }
        }
    }

}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tblWatchList)
    {
        return self.watchList.count;
    }
    else
    {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tblWatchList dequeueReusableCellWithIdentifier:@"watchListCell"];
    UIImageView *summonerIconView = (UIImageView *)[cell viewWithTag:100];
    UILabel *summonerName = (UILabel *)[cell viewWithTag:101];
    summonerName.text = [self.watchList[indexPath.row] objectForKey:@"name"];
    NSString *summonerIconPath = [NSString stringWithFormat:@"%@.png", [(NSDictionary *)self.watchList[indexPath.row] objectForKey:@"profileIconId"]];
    UIImage *summonerIcon = [UIImage imageNamed:summonerIconPath
                                   scaledToSize:CGSizeMake(summonerIconView.bounds.size.height,
                                                           summonerIconView.bounds.size.width)];
    summonerIconView.image = summonerIcon;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *summonerDict = self.watchList[indexPath.row];
    self.selectedSummoner = [CDFSummoner summonerFromDictionary:summonerDict];
    NSString *requestString = [NSString stringWithFormat:
                               @"https://na.api.pvp.net/api/lol/na/v1.3/game/by-summoner/%@/recent?api_key=%@",
                               self.selectedSummoner.idNumber, API_KEY];
    NSLog(@"%@", self.selectedSummoner);
    self.summonerStatsSummaryRequest = [self performRequestWithURLString:requestString];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"displaySummonerDetailFromWatch"])
    {
        CDFSummonerDetailViewController *summonerDetailController = (CDFSummonerDetailViewController *)segue.destinationViewController;
        summonerDetailController.championIds = self.championIds;
        summonerDetailController.summoner = self.selectedSummoner;
        summonerDetailController.summonerSpells = self.summonerSpells;
    }
    else if ([segue.identifier isEqualToString:@"displayAdder"])
    {
        CDFAdderViewController *adderController = (CDFAdderViewController *)segue.destinationViewController;
        adderController.watchList = self.watchList;
    }
}

- (IBAction)editTapped:(id)sender
{
    if (self.isEditing)
    {
        [self.tblWatchList setEditing:NO animated:YES];
        self.btnEdit.title = @"Edit";
        self.isEditing = NO;
        self.btnAdd.enabled = YES;
    }
    else
    {
        [self.tblWatchList setEditing:YES animated:YES];
        self.btnEdit.title = @"Done";
        self.isEditing = YES;
        self.btnAdd.enabled = NO;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"commitEditingStyle!");
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [self.watchList removeObjectAtIndex:indexPath.row];
        [self.tblWatchList deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                 withRowAnimation:UITableViewRowAnimationFade];
    }
}

@end

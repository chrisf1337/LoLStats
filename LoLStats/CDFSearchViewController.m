//
//  CFViewController.m
//  LoLStats
//
//  Created by Christopher Fu on 7/23/14.
//  Copyright (c) 2014 Christopher Fu. All rights reserved.
//

#import "CDFSearchViewController.h"
#import "CDFSummonerDetailViewController.h"
#import "UIViewController+UIViewControllerAdditions.h"
#import "apikey.h"

@interface CDFSearchViewController ()

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message;

@property (nonatomic) NSMutableData *responseData;
@property (nonatomic) NSURLConnection *summonerInfoRequest;
@property (nonatomic) NSURLConnection *summonerStatsSummaryRequest;
@property (nonatomic) NSURLConnection *summonerLeagueEntriesRequest;

@property (nonatomic) NSURLConnection *championIdRequest;

@end

@implementation CDFSearchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.responseData = [[NSMutableData alloc] init];
//    self.scrollView.layer.borderColor = [UIColor blueColor].CGColor;
//    self.scrollView.layer.borderWidth = 1.0f;
//    self.summonerName = [[NSMutableString alloc] init];
    self.title = @"Search";
    NSString *requestString = [NSString stringWithFormat:
                               @"https://na.api.pvp.net/api/lol/static-data/na/v1.2/champion?api_key=%@",
                               API_KEY];
    self.championIdRequest = [self performRequestWithURLString:requestString];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)searchForSummoner:(NSString *)summonerName;
{
    NSString *requestString = [NSString stringWithFormat:
                               @"https://na.api.pvp.net/api/lol/na/v1.4/summoner/by-name/%@?api_key=%@",
                               summonerName, API_KEY];
    self.summonerInfoRequest = [self performRequestWithURLString:requestString];
}

- (IBAction)searchTapped:(id)sender
{
    [self.searchField resignFirstResponder];
    NSString *summonerName = [NSMutableString stringWithFormat:@"%@", self.searchField.text];
    self.searchField.text = @"";
    [self searchForSummoner:summonerName];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    if (httpResponse.statusCode == 404)
    {
        if (connection == self.summonerInfoRequest)
        {
            [self showAlertWithTitle:@"Summoner not found!"
                             message:@"The summoner name you have entered was not found."];
        }
        else if (connection == self.summonerLeagueEntriesRequest)
        {
            NSLog(@"summonerLeagueEntriesRequest 404'd");
        }
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
        self.summonerInfo = [NSJSONSerialization JSONObjectWithData:self.responseData options:kNilOptions error:&error];
        if (self.summonerInfo != nil)
        {
            self.summonerObject = [self.summonerInfo objectForKey:[self.summonerInfo allKeys][0]];
            self.summoner = [CDFSummoner
                             summonerWithName:[self.summonerObject objectForKey:@"name"]
                             level:(NSNumber *)[self.summonerObject objectForKey:@"summonerLevel"]
                             idNumber:(NSNumber *)[self.summonerObject objectForKey:@"id"]];
            self.summoner.profileIconId = [self.summonerObject objectForKey:@"profileIconId"];

            // recent games
            NSString *requestString = [NSString stringWithFormat:
                                       @"https://na.api.pvp.net/api/lol/na/v1.3/game/by-summoner/%@/recent?api_key=%@",
                                       self.summoner.idNumber, API_KEY];
            self.summonerStatsSummaryRequest = [self performRequestWithURLString:requestString];
        }
    }
    else if (connection == self.summonerStatsSummaryRequest)
    {
        NSDictionary *summonerStatsSummary = [NSJSONSerialization JSONObjectWithData:self.responseData
                                                                    options:kNilOptions
                                                                      error:&error];
        if (summonerStatsSummary != nil)
        {
            self.summoner.recentGames = [NSMutableArray arrayWithArray:[summonerStatsSummary objectForKey:@"games"]];
            self.summoner.totalTrackedGames = self.summoner.recentGames.count;
            for (NSDictionary *game in self.summoner.recentGames)
            {
                NSDictionary *stats = [game objectForKey:@"stats"];
                self.summoner.totalTrackedKills += [(NSNumber *)[stats objectForKey:@"championsKilled"] intValue];
                self.summoner.totalTrackedDeaths += [(NSNumber *)[stats objectForKey:@"numDeaths"] intValue];
                self.summoner.totalTrackedAssists += [(NSNumber *)[stats objectForKey:@"assists"] intValue];
                if ([[stats objectForKey:@"win"] boolValue])
                {
                    self.summoner.totalTrackedWins++;
                }
            }
        }
        NSLog(@"%d/%d/%d (W: %d)", self.summoner.totalTrackedKills, self.summoner.totalTrackedDeaths,
              self.summoner.totalTrackedAssists, self.summoner.totalTrackedWins);

        // league entries
        NSString *requestString = [NSString stringWithFormat:
                                   @"https://na.api.pvp.net/api/lol/na/v2.4/league/by-summoner/%@/entry?api_key=%@",
                                   self.summoner.idNumber, API_KEY];
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
                                     [NSString stringWithFormat:@"%@", self.summoner.idNumber]];
            for (NSDictionary *entry in summonerLeagueEntries)
            {
                if ([(NSString *)[entry objectForKey:@"queue"] isEqualToString:@"RANKED_SOLO_5x5"])
                {
                    NSString *tier = [entry objectForKey:@"tier"];
                    self.summoner.soloQueueLeagueTier = [tier capitalizedString];
                    self.summoner.soloQueueLeagueDivision = [[entry objectForKey:@"entries"][0] objectForKey:@"division"];
                }
            }
        }
        else
        {
            self.summoner.soloQueueLeagueTier = @"Unranked";
            self.summoner.soloQueueLeagueDivision = @"";
        }
        [self performSegueWithIdentifier:@"displaySummonerDetail" sender:self];
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
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    NSString *summonerName = [NSMutableString stringWithFormat:@"%@", self.searchField.text];
    textField.text = @"";
    [self searchForSummoner:summonerName];
    return YES;
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message
{
    [[[UIAlertView alloc] initWithTitle:title
                                message:message
                               delegate:self
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil]
     show];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"displaySummonerDetail"])
    {
        CDFSummonerDetailViewController *summonerDetail = (CDFSummonerDetailViewController *)segue.destinationViewController;
        summonerDetail.summonerObject = self.summonerObject;
        summonerDetail.summonerRecentGames = self.summoner.recentGames;
        summonerDetail.summoner = self.summoner;
        summonerDetail.championIds = self.championIds;
        NSLog(@"%@", self.summoner);
    }
}


@end

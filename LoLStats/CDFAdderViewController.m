//
//  CDFAdderViewController.m
//  LoLStats
//
//  Created by Christopher Fu on 8/5/14.
//  Copyright (c) 2014 Christopher Fu. All rights reserved.
//

#import "CDFAdderViewController.h"
#import "CDFSummoner.h"
#import "UIViewController+UIViewControllerAdditions.h"
#import "CDFWatchListViewController.h"
#import "apikey.h"

@interface CDFAdderViewController ()

@property (nonatomic) CDFSummoner *summoner;

@property (nonatomic) NSDictionary *summonerInfo;
@property (nonatomic) NSDictionary *summonerObject;

@property (nonatomic) NSMutableData *responseData;
@property (nonatomic) NSURLConnection *summonerInfoRequest;
@property (nonatomic) NSURLConnection *summonerStatsSummaryRequest;
@property (nonatomic) NSURLConnection *summonerLeagueEntriesRequest;

- (void)searchForSummoner:(NSString *)summonerName;
- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message;

- (BOOL)summonerInWatchList:(NSArray *)watchList withIdNumber:(NSNumber *)idNumber;

@end

@implementation CDFAdderViewController

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
    self.responseData = [[NSMutableData alloc] init];
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

- (void)searchForSummoner:(NSString *)summonerName;
{
    NSString *requestString = [NSString stringWithFormat:
                               @"https://na.api.pvp.net/api/lol/na/v1.4/summoner/by-name/%@?api_key=%@",
                               summonerName, API_KEY];
    self.summonerInfoRequest = [self performRequestWithURLString:requestString];
}

- (BOOL)summonerInWatchList:(NSArray *)watchList withIdNumber:(NSNumber *)idNumber
{
    for (NSDictionary *summoner in watchList)
    {
        if ([[summoner objectForKey:@"idNumber"] isEqualToNumber:idNumber])
        {
            return YES;
        }
    }
    return NO;
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
        self.summonerInfo = [NSJSONSerialization JSONObjectWithData:self.responseData
                                                            options:kNilOptions
                                                              error:&error];
        if (self.summonerInfo != nil)
        {
            self.summonerObject = [self.summonerInfo objectForKey:[self.summonerInfo allKeys][0]];
            self.summoner = [CDFSummoner
                             summonerWithName:[self.summonerObject objectForKey:@"name"]
                             level:(NSNumber *)[self.summonerObject objectForKey:@"summonerLevel"]
                             idNumber:(NSNumber *)[self.summonerObject objectForKey:@"id"]];
            self.summoner.profileIconId = [self.summonerObject objectForKey:@"profileIconId"];
            NSLog(@"%@", self.summoner);
            if (![self summonerInWatchList:self.watchList withIdNumber:self.summoner.idNumber])
            {
                [self.watchList addObject:[self.summoner toDictionary]];
                ((CDFWatchListViewController *)self.backViewController).watchList = self.watchList;
                [self.navigationController popViewControllerAnimated:YES];
            }
            else
            {
                [self showAlertWithTitle:@"Error"
                                 message:@"The summoner you have entered is already in your watch list!"];
            }
            // recent games
//            NSString *requestString = [NSString stringWithFormat:
//                                       @"https://na.api.pvp.net/api/lol/na/v1.3/game/by-summoner/%@/recent?api_key=%@",
//                                       self.summoner.idNumber, API_KEY];
//            self.summonerStatsSummaryRequest = [self performRequestWithURLString:requestString];
        }
    }
//    else if (connection == self.summonerStatsSummaryRequest)
//    {
//        NSDictionary *summonerStatsSummary = [NSJSONSerialization JSONObjectWithData:self.responseData
//                                                                             options:kNilOptions
//                                                                               error:&error];
//        if (summonerStatsSummary != nil)
//        {
//            self.summoner.recentGames = [NSMutableArray arrayWithArray:[summonerStatsSummary objectForKey:@"games"]];
//            self.summoner.totalTrackedGames = self.summoner.recentGames.count;
//            for (NSDictionary *game in self.summoner.recentGames)
//            {
//                NSDictionary *stats = [game objectForKey:@"stats"];
//                self.summoner.totalTrackedKills += [(NSNumber *)[stats objectForKey:@"championsKilled"] intValue];
//                self.summoner.totalTrackedDeaths += [(NSNumber *)[stats objectForKey:@"numDeaths"] intValue];
//                self.summoner.totalTrackedAssists += [(NSNumber *)[stats objectForKey:@"assists"] intValue];
//                if ([[stats objectForKey:@"win"] boolValue])
//                {
//                    self.summoner.totalTrackedWins++;
//                }
//            }
//        }
//        NSLog(@"%d/%d/%d (W: %d)", self.summoner.totalTrackedKills, self.summoner.totalTrackedDeaths,
//              self.summoner.totalTrackedAssists, self.summoner.totalTrackedWins);
//
//        // league entries
//        NSString *requestString = [NSString stringWithFormat:
//                                   @"https://na.api.pvp.net/api/lol/na/v2.4/league/by-summoner/%@/entry?api_key=%@",
//                                   self.summoner.idNumber, API_KEY];
//        NSLog(@"%@", requestString);
//        self.summonerLeagueEntriesRequest = [self performRequestWithURLString:requestString];
//    }
//    else if (connection == self.summonerLeagueEntriesRequest)
//    {
//        NSDictionary *summonerLeagueEntries = [NSJSONSerialization JSONObjectWithData:self.responseData
//                                                                              options:kNilOptions
//                                                                                error:&error];
//        if (summonerLeagueEntries != nil)
//        {
//            summonerLeagueEntries = [summonerLeagueEntries objectForKey:
//                                     [NSString stringWithFormat:@"%@", self.summoner.idNumber]];
//            for (NSDictionary *entry in summonerLeagueEntries)
//            {
//                if ([(NSString *)[entry objectForKey:@"queue"] isEqualToString:@"RANKED_SOLO_5x5"])
//                {
//                    NSString *tier = [entry objectForKey:@"tier"];
//                    self.summoner.soloQueueLeagueTier = [tier capitalizedString];
//                    self.summoner.soloQueueLeagueDivision = [[entry objectForKey:@"entries"][0] objectForKey:@"division"];
//                }
//            }
//        }
//        else
//        {
//            self.summoner.soloQueueLeagueTier = @"Unranked";
//            self.summoner.soloQueueLeagueDivision = @"";
//        }
//
//        NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
//        NSError *error;
//        NSString *path = [documentsDirectory stringByAppendingPathComponent:@"watchlist.json"];
//        NSData *fileContents = [NSData dataWithContentsOfFile:path];
//        NSArray *watchList = [NSJSONSerialization JSONObjectWithData:fileContents
//                                                             options:kNilOptions
//                                                               error:&error];
//        if (watchList != nil)
//        {
//            NSMutableArray *watchListSummoners = [NSMutableArray arrayWithArray:watchList];
//            if (![self summonerInWatchList:watchList withIdNumber:self.summoner.idNumber])
//            {
//                [watchListSummoners addObject:self.summoner.toDictionary];
//                NSData *data = [NSJSONSerialization dataWithJSONObject:watchListSummoners
//                                                               options:kNilOptions
//                                                                 error:&error];
//                [data writeToFile:path atomically:YES];
//            }
//            for (NSDictionary *summoner in watchListSummoners)
//            {
//                NSLog(@"%@", [summoner objectForKey:@"name"]);
//            }
//        }
//
//
//        [self performSegueWithIdentifier:@"displaySummonerDetailFromSearch" sender:self];
//    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    NSString *summonerName = [NSMutableString stringWithFormat:@"%@", self.searchField.text];
    textField.text = @"";
    [self searchForSummoner:summonerName];
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"Touched!");
    [self.view endEditing:YES];
}

@end

//
//  CFSummonerDetailViewController.m
//  LoLStats
//
//  Created by Christopher Fu on 7/24/14.
//  Copyright (c) 2014 Christopher Fu. All rights reserved.
//

#import "CDFSummonerDetailViewController.h"
#import "CDFGameDetailViewController.h"
#import "UIImage+UIImageAdditions.h"
#import "apikey.h"

@interface CDFSummonerDetailViewController ()

@property (nonatomic) NSMutableData *responseData;
@property (nonatomic) NSArray *summonerStatsArray;

@property (nonatomic) NSIndexPath *selectedGame;

- (void)buildSummonerStatsArray;

@end

@implementation CDFSummonerDetailViewController

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

//    self.tblSummonerStats.layer.borderColor = [UIColor redColor].CGColor;
//    self.tblSummonerStats.layer.borderWidth = 1.0f;
    self.title = @"Summoner Detail";
    
}

- (void)viewWillAppear:(BOOL)animated
{
    self.imgSummonerIcon.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png", self.summoner.profileIconId]
                                        scaledToSize:CGSizeMake(64, 64)];
    self.lblSummonerName.text = self.summoner.name;
    if ([self.summoner.soloQueueLeagueTier isEqualToString:@"Unranked"])
    {
        self.lblSummonerLeague.text = [NSString stringWithFormat:@"Level %@", self.summoner.level];
    }
    else
    {
        self.lblSummonerLeague.text = [NSString stringWithFormat:@"%@ %@", self.summoner.soloQueueLeagueTier,
                                       self.summoner.soloQueueLeagueDivision];
    }
    [self buildSummonerStatsArray];
    [self.tblSummonerRecentGames reloadData];
    [self.tblSummonerStats reloadData];
    [self.scrollView setContentOffset:CGPointZero animated:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    for (int i = 0; i < self.summonerStatsArray.count; i++)
    {
        UITableViewCell *cell = [self.tblSummonerStats cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        cell.userInteractionEnabled = NO;
    }
    [self.tblSummonerStats cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]].userInteractionEnabled = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)buildSummonerStatsArray
{
    NSArray *summonerKDA;
    if (self.summoner.totalTrackedGames == 0)
    {
        summonerKDA = @[@"Average KDA:", @"0/0/0"];
    }
    else
    {
        summonerKDA = @[@"Average KDA:",
                        [NSString stringWithFormat:@"%.1f/%.1f/%.1f",
                         (double)self.summoner.totalTrackedKills / self.summoner.totalTrackedGames,
                         (double)self.summoner.totalTrackedDeaths / self.summoner.totalTrackedGames,
                         (double)self.summoner.totalTrackedAssists / self.summoner.totalTrackedGames]];
    }

    NSArray *summonerTrackedGames = @[@"Total tracked games:",
                                      [NSString stringWithFormat:@"%d", self.summoner.totalTrackedGames]];
    self.summonerStatsArray = @[summonerKDA, summonerTrackedGames];
}

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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tblSummonerStats)
    {
        return self.summonerStatsArray.count;
    }
    else // tableView == self.tblSummonerRecentGames
    {
        return self.summoner.recentGames.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tblSummonerStats)
    {
        UITableViewCell *cell = [self.tblSummonerStats dequeueReusableCellWithIdentifier:@"statCell"];
        UILabel *stat = (UILabel *)[cell viewWithTag:100];
        stat.text = self.summonerStatsArray[indexPath.row][0];
        UILabel *value = (UILabel *)[cell viewWithTag:101];
        value.text = self.summonerStatsArray[indexPath.row][1];
        return cell;
    }
    else // tableView == self.tblSummonerRecentGames
    {
        UITableViewCell *cell = [self.tblSummonerRecentGames dequeueReusableCellWithIdentifier:@"recentGameCell"];
        UIImageView *championIconView = (UIImageView *)[cell viewWithTag:200];
        UILabel *championNameLabel = (UILabel *)[cell viewWithTag:201];
        UILabel *winLoseLabel = (UILabel *)[cell viewWithTag:202];

        NSDictionary *game = self.summoner.recentGames[indexPath.row];
        NSNumber *championId = [game objectForKey:@"championId"];
        NSString *championName = [(NSDictionary *)[self.championIds objectForKey:championId] objectForKey:@"name"];
        NSString *championKey = [(NSDictionary *)[self.championIds objectForKey:championId] objectForKey:@"key"];

        UIImage *championIcon = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png", championKey]
                                       scaledToSize:CGSizeMake(championIconView.bounds.size.width,
                                                               championIconView.bounds.size.height)];

        if ([[[game objectForKey:@"stats"] objectForKey:@"win"] boolValue])
        {
            winLoseLabel.text = @"Win";
            winLoseLabel.textColor = [UIColor colorWithRed:0 green:0.4 blue:0 alpha:1];
        }
        else
        {
            winLoseLabel.text = @"Loss";
            winLoseLabel.textColor = [UIColor redColor];
        }

        championIconView.image = championIcon;
        championNameLabel.text = [NSString stringWithFormat:@"%@", championName];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tblSummonerStats)
    {
        if (indexPath.row == 0)
        {
            UITableViewCell *cell = [self.tblSummonerStats cellForRowAtIndexPath:
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
                if (self.summoner.totalTrackedGames == 0)
                {
                    value.text = @"0/0/0";
                }
                else
                {
                    value.text = [NSString stringWithFormat:@"%.1f/%.1f/%.1f",
                                  (double)self.summoner.totalTrackedKills / self.summoner.totalTrackedGames,
                                  (double)self.summoner.totalTrackedDeaths / self.summoner.totalTrackedGames,
                                  (double)self.summoner.totalTrackedAssists / self.summoner.totalTrackedGames];
                }
            }
            [self.tblSummonerStats deselectRowAtIndexPath:indexPath animated:YES];
        }
    }
    else
    {
        self.selectedGame = indexPath;
        [self.tblSummonerRecentGames deselectRowAtIndexPath:indexPath animated:YES];
        [self performSegueWithIdentifier:@"displayGameDetail" sender:self];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"displayGameDetail"])
    {
        CDFGameDetailViewController *gameDetailController = (CDFGameDetailViewController *)segue.destinationViewController;
        gameDetailController.championIds = self.championIds;
        gameDetailController.summonerSpells = self.summonerSpells;
        gameDetailController.summoner = self.summoner;
        gameDetailController.gameInfo = self.summoner.recentGames[self.selectedGame.row];
    }
}

@end

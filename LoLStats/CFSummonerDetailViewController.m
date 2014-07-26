//
//  CFSummonerDetailViewController.m
//  LoLStats
//
//  Created by Christopher Fu on 7/24/14.
//  Copyright (c) 2014 Christopher Fu. All rights reserved.
//

#import "CFSummonerDetailViewController.h"
#import "UIImage+UIImageAdditions.h"
#import "apikey.h"

@interface CFSummonerDetailViewController ()

@property (nonatomic) NSMutableData *responseData;
@property (nonatomic) NSURLConnection *summonerStatsSummaryRequest;

@end

@implementation CFSummonerDetailViewController

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
    self.imgSummonerIcon.image = [UIImage imageNamed:@"20.png" scaledToSize:CGSizeMake(64, 64)];
    NSLog(@"%@", self.summonerObject);
    self.lblSummonerName.text = [self.summonerObject objectForKey:@"name"];
    if ([(NSNumber *)[self.summonerObject objectForKey:@"summonerLevel"] intValue] < 30)
    {
        self.lblSummonerLeague.text = [NSString stringWithFormat:@"Level %d",
                                       [(NSNumber *)[self.summonerObject objectForKey:@"summonerLevel"] intValue]];
    }
    NSLog(@"%d", [(NSNumber *)[self.summonerObject objectForKey:@"id"] intValue]);
    NSString *requestString = [NSString stringWithFormat:
                               @"https://na.api.pvp.net/api/lol/na/v1.3/game/by-summoner/%d/recent?api_key=%@",
                               [(NSNumber *)[self.summonerObject objectForKey:@"id"] intValue], API_KEY];
    NSLog(@"%@", requestString);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestString]];
    [request setValue:@"en-US" forHTTPHeaderField:@"Accept-Language"];
    [request setValue:@"ISO-8859-1,utf-8" forHTTPHeaderField:@"Accept-Charset"];
    self.summonerStatsSummaryRequest = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    NSError *error;
    self.summonerStatsSummary = [NSJSONSerialization JSONObjectWithData:self.responseData
                                                                options:kNilOptions
                                                                  error:&error];
    if (self.summonerStatsSummary != nil)
    {
        NSLog(@"%@", self.summonerStatsSummary);
    }
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
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tblSummonerStats dequeueReusableCellWithIdentifier:@"statCell"];
    NSArray *games = [self.summonerRecentGames objectForKey:@"games"];
    NSDictionary *stats = [(NSDictionary *)games[1] objectForKey:@"stats"];
    int kills = [(NSNumber *)[stats objectForKey:@"championsKilled"] intValue];
    cell.textLabel.text = [NSString stringWithFormat:@"Kills: %d", kills];
    return cell;
}

@end

//
//  CFViewController.m
//  LoLStats
//
//  Created by Christopher Fu on 7/23/14.
//  Copyright (c) 2014 Christopher Fu. All rights reserved.
//

#import "CFSearchViewController.h"
#import "CFSummonerDetailViewController.h"
#import "apikey.h"

@interface CFSearchViewController ()

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message;

@property (nonatomic) NSMutableData *responseData;

@end

@implementation CFSearchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.responseData = [[NSMutableData alloc] init];
    self.scrollView.layer.borderColor = [UIColor blueColor].CGColor;
    self.scrollView.layer.borderWidth = 1.0f;
    self.summonerName = [[NSMutableString alloc] init];
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
    NSLog(@"%@", requestString);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestString]];
    [request setValue:@"en-US" forHTTPHeaderField:@"Accept-Language"];
    [request setValue:@"ISO-8859-1,utf-8" forHTTPHeaderField:@"Accept-Charset"];
    (void)[[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (IBAction)searchTapped:(id)sender
{
    [self.searchField resignFirstResponder];
    self.summonerName = [NSMutableString stringWithFormat:@"%@", self.searchField.text];
    self.searchField.text = @"";
    [self searchForSummoner:self.summonerName];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    if (httpResponse.statusCode == 404)
    {
        [self showAlertWithTitle:@"Summoner not found!" message:@"The summoner name you have entered was not found."];
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
    self.summonerInfo = [NSJSONSerialization JSONObjectWithData:self.responseData options:kNilOptions error:&error];
    if (self.summonerInfo != nil)
    {
        self.summonerObject = [self.summonerInfo objectForKey:[self.summonerInfo allKeys][0]];
        NSLog(@"%@", self.summonerName);
        [self performSegueWithIdentifier:@"displaySummonerDetail" sender:self];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    self.summonerName = [NSMutableString stringWithFormat:@"%@", self.searchField.text];
    textField.text = @"";
    [self searchForSummoner:self.summonerName];
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
        CFSummonerDetailViewController *summonerDetail = (CFSummonerDetailViewController *)segue.destinationViewController;
        summonerDetail.summonerObject = self.summonerObject;
        summonerDetail.summonerName = self.summonerName;
    }
}


@end

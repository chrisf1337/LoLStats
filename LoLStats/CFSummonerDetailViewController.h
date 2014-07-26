//
//  CFSummonerDetailViewController.h
//  LoLStats
//
//  Created by Christopher Fu on 7/24/14.
//  Copyright (c) 2014 Christopher Fu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CFSummonerDetailViewController : UIViewController
<UITableViewDataSource,UITableViewDelegate, NSURLConnectionDataDelegate>

@property (weak, nonatomic) IBOutlet UILabel *lblSummonerName;
@property (weak, nonatomic) IBOutlet UIImageView *imgSummonerIcon;
@property (weak, nonatomic) IBOutlet UILabel *lblSummonerLeague;
@property (weak, nonatomic) IBOutlet UITableView *tblSummonerStats;

@property (nonatomic) NSMutableString *summonerName;
@property (nonatomic) NSDictionary *summonerObject;
@property (nonatomic) NSDictionary *summonerStatsSummary;
@property (nonatomic) NSDictionary *summonerRecentGames;

@end

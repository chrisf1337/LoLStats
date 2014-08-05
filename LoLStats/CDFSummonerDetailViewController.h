//
//  CFSummonerDetailViewController.h
//  LoLStats
//
//  Created by Christopher Fu on 7/24/14.
//  Copyright (c) 2014 Christopher Fu. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CDFSummoner.h"

@interface CDFSummonerDetailViewController : UIViewController
<UITableViewDataSource, UITableViewDelegate, NSURLConnectionDataDelegate>

@property (weak, nonatomic) IBOutlet UILabel *lblSummonerName;
@property (weak, nonatomic) IBOutlet UIImageView *imgSummonerIcon;
@property (weak, nonatomic) IBOutlet UILabel *lblSummonerLeague;
@property (weak, nonatomic) IBOutlet UITableView *tblSummonerStats;
@property (weak, nonatomic) IBOutlet UITableView *tblSummonerRecentGames;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (nonatomic) CDFSummoner *summoner;

@property (nonatomic) NSDictionary *summonerObject;
@property (nonatomic) NSDictionary *summonerStatsSummary;
@property (nonatomic) NSArray *summonerRecentGames;

@property (nonatomic) NSDictionary *championIds;

@end

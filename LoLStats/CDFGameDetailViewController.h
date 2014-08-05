//
//  CDFGameDetailViewController.h
//  LoLStats
//
//  Created by Christopher Fu on 7/30/14.
//  Copyright (c) 2014 Christopher Fu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CDFSummoner.h"

@interface CDFGameDetailViewController : UIViewController
<UITableViewDataSource, UITableViewDelegate, NSURLConnectionDataDelegate>

@property (weak, nonatomic) IBOutlet UILabel *lblSummonerName;
@property (weak, nonatomic) IBOutlet UIImageView *imgSummonerIcon;
@property (weak, nonatomic) IBOutlet UILabel *lblChampionName;
@property (weak, nonatomic) IBOutlet UILabel *lblWinLoss;
@property (weak, nonatomic) IBOutlet UITableView *tblGameStats;
@property (weak, nonatomic) IBOutlet UITableView *tblTeammates;
@property (weak, nonatomic) IBOutlet UITableView *tblOpponents;
@property (weak, nonatomic) IBOutlet UILabel *lblTeammates;
@property (weak, nonatomic) IBOutlet UILabel *lblOpponents;

@property (nonatomic) CDFSummoner *summoner;
@property (nonatomic) CDFSummoner *nextSummoner;


@property (nonatomic) NSDictionary *gameInfo;
@property (nonatomic) NSDictionary *championIds;

@end

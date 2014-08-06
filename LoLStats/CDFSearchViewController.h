//
//  CFViewController.h
//  LoLStats
//
//  Created by Christopher Fu on 7/23/14.
//  Copyright (c) 2014 Christopher Fu. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CDFSummoner.h"

@interface CDFSearchViewController : UIViewController <UITextFieldDelegate, NSURLConnectionDataDelegate>

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UITextField *searchField;
@property (nonatomic, weak) IBOutlet UIButton *btnSearch;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (nonatomic) CDFSummoner *summoner;

@property (nonatomic) NSDictionary *summonerInfo;
@property (nonatomic) NSDictionary *summonerObject;
@property (nonatomic) NSDictionary *summonerStatsSummary;
@property (nonatomic) NSArray *summonerRecentGames;

@property (nonatomic) NSMutableDictionary *championIds;

- (IBAction)searchTapped:(id)sender;

@end

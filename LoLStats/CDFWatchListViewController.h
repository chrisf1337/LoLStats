//
//  CDFWatchListViewController.h
//  LoLStats
//
//  Created by Christopher Fu on 8/4/14.
//  Copyright (c) 2014 Christopher Fu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CDFWatchListViewController : UITableViewController
<UITableViewDataSource, UITableViewDelegate, NSURLConnectionDataDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tblWatchList;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnEdit;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnAdd;
@property (nonatomic) NSMutableArray *watchList;
@property (nonatomic) NSMutableDictionary *championIds;

@property (nonatomic) BOOL isEditing;

- (IBAction)editTapped:(id)sender;

@end

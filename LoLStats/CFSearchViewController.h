//
//  CFViewController.h
//  LoLStats
//
//  Created by Christopher Fu on 7/23/14.
//  Copyright (c) 2014 Christopher Fu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CFSearchViewController : UIViewController <UITextFieldDelegate, NSURLConnectionDataDelegate>

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UITextField *searchField;
@property (nonatomic, weak) IBOutlet UIButton *btnSearch;

@property (nonatomic) NSMutableString *summonerName;

@property (nonatomic) NSDictionary *summonerInfo;
@property (nonatomic) NSDictionary *summonerObject;

- (IBAction)searchTapped:(id)sender;

@end

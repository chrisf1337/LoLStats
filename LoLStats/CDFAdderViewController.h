//
//  CDFAdderViewController.h
//  LoLStats
//
//  Created by Christopher Fu on 8/5/14.
//  Copyright (c) 2014 Christopher Fu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CDFAdderViewController : UIViewController <UITextFieldDelegate, NSURLConnectionDataDelegate>

@property (weak, nonatomic) IBOutlet UITextField *searchField;
@property (weak, nonatomic) IBOutlet UIButton *btnAdd;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

- (IBAction)searchTapped:(id)sender;

@property (nonatomic) NSMutableArray *watchList;

@end

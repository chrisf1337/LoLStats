//
//  UIViewController+UIViewControllerAdditions.h
//  LoLStats
//
//  Created by Christopher Fu on 7/30/14.
//  Copyright (c) 2014 Christopher Fu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (UIViewControllerAdditions)

- (NSURLConnection *)performRequestWithURLString:(NSString *)urlString;
- (UIViewController *)backViewController;

@end

//
//  UIViewController+UIViewControllerAdditions.m
//  LoLStats
//
//  Created by Christopher Fu on 7/30/14.
//  Copyright (c) 2014 Christopher Fu. All rights reserved.
//

#import "UIViewController+UIViewControllerAdditions.h"

@implementation UIViewController (UIViewControllerAdditions)

- (NSURLConnection *)performRequestWithURLString:(NSString *)urlString
{
    NSString *requestString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestString]];
    [request setValue:@"en-US" forHTTPHeaderField:@"Accept-Language"];
    [request setValue:@"ISO-8859-1,utf-8" forHTTPHeaderField:@"Accept-Charset"];
    return [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (UIViewController *)backViewController
{
    NSInteger numberOfViewControllers = self.navigationController.viewControllers.count;

    if (numberOfViewControllers < 2)
        return nil;
    else
        return [self.navigationController.viewControllers objectAtIndex:numberOfViewControllers - 2];
}

@end

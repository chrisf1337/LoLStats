//
//  UIImage+UIImageAdditions.m
//  Epicenters
//
//  Created by Christopher Fu on 7/21/14.
//  Copyright (c) 2014 Christopher Fu. All rights reserved.
//

#import "UIImage+UIImageAdditions.h"

@implementation UIImage (UIImageAdditions)

+ (UIImage *)imageNamed:(NSString *)name scaledToSize:(CGSize)newSize
{
    UIImage *image = [UIImage imageNamed:name];
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end

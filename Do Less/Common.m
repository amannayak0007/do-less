//
//  Utility.m
//  Do Less
//
//  Created by Roc on 13-8-6.
//  Copyright (c) 2013年 Roc. All rights reserved.
//

#import "Common.h"

@implementation Common

+ (void)alert:(NSString *)msg
{
    NSLog(@"%@", msg);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Eh...", "AlertView title")
                                                    message:msg
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"OK", @"Cancel button title for AlertView")
                                          otherButtonTitles:nil];
    [alert show];
}

+ (UIColor *)shadowColor
{
    return [UIColor colorWithRed:67/255.0 green:67/255.0 blue:67/255.0 alpha:0.75];
}

+ (CGSize)shadowOffset
{
    return CGSizeMake(1, 1);
}

+ (NSArray *)themeColors
{
    return @[
         [UIColor colorWithRed:255/255.0 green:128/255.0 blue:128/255.0 alpha:1],
         [UIColor colorWithRed:115/255.0 green:230/255.0 blue:115/255.0 alpha:1],
         [UIColor colorWithRed:102/255.0 green:204/255.0 blue:204/255.0 alpha:1],
    ];
}

@end

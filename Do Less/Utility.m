//
//  Utility.m
//  Do Less
//
//  Created by Roc on 13-8-6.
//  Copyright (c) 2013年 Roc. All rights reserved.
//

#import "Utility.h"

@implementation Utility

+ (void)alert:(NSString *)msg
{
    NSLog(@"%@", msg);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Eh..."
                                                    message:msg
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

+ (UIImageView*)appBackground
{
    return [[UIImageView alloc] initWithImage:
            [[UIImage imageNamed:@"WoodTextureBg-Portrait"]
             resizableImageWithCapInsets:UIEdgeInsetsZero]];
}

@end

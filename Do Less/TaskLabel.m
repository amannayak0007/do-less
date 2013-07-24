//
//  TaskLabel.m
//  Do Less
//
//  Created by Roc on 13-7-15.
//  Copyright (c) 2013年 Roc. All rights reserved.
//

#import "TaskLabel.h"

@implementation TaskLabel

- (void)drawTextInRect:(CGRect)rect
{
    [super drawTextInRect:rect];

    UIBezierPath *deletionLine = [[UIBezierPath alloc] init];
    [deletionLine moveToPoint:rect.origin];
    [deletionLine addLineToPoint:CGPointMake(160, 150)];
    [deletionLine addLineToPoint:CGPointMake(10, 150)];
    [[UIColor greenColor] setFill];
    [[UIColor redColor] setStroke];
    [deletionLine fill];
    [deletionLine stroke];
}

@end

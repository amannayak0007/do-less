//
//  ApplicationUnitTests.m
//  ApplicationUnitTests
//
//  Created by Roc on 13-7-24.
//  Copyright (c) 2013年 Roc. All rights reserved.
//

#import "ApplicationUnitTests.h"
#import "TodayViewController.h"

@implementation ApplicationUnitTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];

    [NSThread sleepForTimeInterval:1.0];
}

- (void)testExample
{
    UIWindow *window = [UIApplication sharedApplication].windows[0];

    STAssertTrue([window.rootViewController isKindOfClass:[TodayViewController class]], @"rootViewController is not TodayViewController.");
//    TodayViewController *todayVC = (TodayViewController *)window.rootViewController;
}

@end

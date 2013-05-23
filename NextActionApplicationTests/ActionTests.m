//
//  NextActionApplicationTests.m
//  NextActionApplicationTests
//
//  Created by Roc on 13-5-14.
//  Copyright (c) 2013年 Roc. All rights reserved.
//

#import "ActionTests.h"
#import "Action.h"

@interface ActionTests()
@property (strong, nonatomic) Action *model;
@end

@implementation ActionTests

- (void)setUp
{
    [super setUp];

    self.model = [Action sharedInstance];
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testActionGoal
{
    STAssertEquals(self.model.actionGoal, 10u, @"The default value of actionGoal doesn't equal 10.");
}

@end

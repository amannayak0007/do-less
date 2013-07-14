//
//  DoLessApplicationTests.m
//  DoLessApplicationTests
//
//  Created by Roc on 13-5-14.
//  Copyright (c) 2013年 Roc. All rights reserved.
//

#import "TaskTests.h"
#import "Task.h"

@interface TaskTests()
@property (strong, nonatomic) Task *model;
@end

@implementation TaskTests

- (void)setUp
{
    [super setUp];

    self.model = [Task sharedInstance];
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testTaskGoal
{
    STAssertEquals(self.model.taskGoal, 10u, @"The default value of taskGoal doesn't equal 10.");
}

@end

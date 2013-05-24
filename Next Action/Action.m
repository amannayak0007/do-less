//
//  Action.m
//  Next Action
//
//  Created by Roc on 13-4-30.
//  Copyright (c) 2013年 Roc. All rights reserved.
//

#import "Action.h"

@interface Action()
@end

@implementation Action
@synthesize currentAction = _currentAction;

+ (Action *)sharedInstance
{
    static Action *singleton;

    @synchronized(self)
    {
        if(!singleton)
        {
            singleton = [[Action alloc] init];
        }

        return singleton;
    }
}

- (EKEventStore *)eventStore
{
    if (!_eventStore) {
        _eventStore = [[EKEventStore alloc] init];
    }

    return _eventStore;
}

- (NSUInteger)actionGoal
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"ActionGoal"];
}

- (void)setActionGoal:(NSUInteger)actionGoal
{
    [[NSUserDefaults standardUserDefaults] setInteger:actionGoal forKey:@"ActionGoal"];
}

- (NSUInteger)actionCount
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"ActionCount"];
}

- (void)setActionCount:(NSUInteger)actionCount
{
    [[NSUserDefaults standardUserDefaults] setInteger:actionCount forKey:@"ActionCount"];
}

- (NSString *)award
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"Award"];
}

- (void)setAward:(NSString *)award
{
    [[NSUserDefaults standardUserDefaults] setObject:award forKey:@"Award"];
}

- (EKReminder *)currentAction
{
    if (!_currentAction) {
        NSString *reminderId = [[NSUserDefaults standardUserDefaults] stringForKey:@"CurrentActionId"];

        if (reminderId) {
            _currentAction = (EKReminder *)[self.eventStore calendarItemWithIdentifier:reminderId];
        }
    }

    return _currentAction;
}

- (void)setCurrentAction:(EKReminder *)currentAction
{
    _currentAction = currentAction;

    [[NSUserDefaults standardUserDefaults] setObject:currentAction.calendarItemIdentifier forKey:@"CurrentActionId"];
}

/*
- (EKReminder *)newReminder
{
    return [EKReminder reminderWithEventStore:self.eventStore];
}

- (BOOL)completeReminder:(EKReminder *)reminder error:(NSError **)error
{
    reminder.completed = YES;
    return [self.eventStore saveReminder:reminder commit:YES error:error];
}

- (BOOL)removeReminder:(EKReminder *)reminder error:(NSError *__autoreleasing *)error
{
    return [self.eventStore removeReminder:reminder commit:YES error:error];
}

- (BOOL)saveReminder:(EKReminder *)reminder error:(NSError *__autoreleasing *)error
{
    return [self.eventStore saveReminder:reminder commit:YES error:error];
}
 */
@end

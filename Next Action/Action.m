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
        EKEventStore *eventStore = [[EKEventStore alloc] init];

        dispatch_semaphore_t mutex = dispatch_semaphore_create(0);

        // Get user's reminders
        // TODO: Implement the logic when the access is denied or an error occured
        [eventStore requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError *error) {
            if (granted && !error) {
                _eventStore = eventStore;
            } else if (!granted) {
                NSLog(@"User did not grant the aceesss to reminders");
            } else {
                NSLog(@"%@", [error localizedDescription]);
            }
            dispatch_semaphore_signal(mutex);
        }];

        dispatch_semaphore_wait(mutex, DISPATCH_TIME_FOREVER);
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
    NSString *reminderId = [[NSUserDefaults standardUserDefaults] stringForKey:@"CurrentActionId"];

    return (EKReminder *)[self.eventStore calendarItemWithIdentifier:reminderId];
}

- (void)setCurrentAction:(EKReminder *)currentAction
{
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

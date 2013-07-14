//
//  Task.m
//  Do Less
//
//  Created by Roc on 13-4-30.
//  Copyright (c) 2013年 Roc. All rights reserved.
//

#import "Task.h"

@interface Task()
@end

@implementation Task
@synthesize todayTasks = _todayTasks;

+ (Task *)sharedInstance
{
    static Task *singleton;

    @synchronized(self)
    {
        if(!singleton)
        {
            singleton = [[Task alloc] init];
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

// TODO: Try to return mutable array here.
- (NSArray *)todayTasks
{
    if (!_todayTasks) {
        _todayTasks = @[
                        [self taskForKey:@"Task1"],
                        [self taskForKey:@"Task2"],
                        [self taskForKey:@"Task3"],
                        ];
    }

    return _todayTasks;
}

- (void)setTodayTasks:(NSArray *)todayTasks
{
    _todayTasks = todayTasks;
    [self setTask:_todayTasks[0] forKey:@"Task1"];
    [self setTask:_todayTasks[1] forKey:@"Task2"];
    [self setTask:_todayTasks[2] forKey:@"Task3"];
}

// Load task
// TODO: Only save & load tasks via UserDefaults when it is the right time, e.g. App exits
- (id)taskForKey:(NSString *)key
{
    NSString *reminderId = [[NSUserDefaults standardUserDefaults] stringForKey:key];

    if (reminderId) {
        return (EKReminder *)[self.eventStore calendarItemWithIdentifier:reminderId];
    } else {
        return [NSNull null];
    }
}

// Save task
- (void)setTask:(EKReminder *)task forKey:(NSString *)key
{
    if ((id)task == [NSNull null]) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:task.calendarItemIdentifier forKey:key];
    }

}

- (BOOL)canTaskBeChangedForIndex:(NSInteger)index
{
    EKReminder *task = self.todayTasks[index];
    if ((id)task == [NSNull null] || task.isCompleted == NO) {
        return YES;
    } else {
        return NO;
    }
}

//- (BOOL)areTodayTasksAllCompleted
//{
//    for (EKReminder *task in self.todayTasks) {
//        if ((id)task != [NSNull null] && task.isCompleted == NO) {
//            return NO;
//        }
//    }
//
//    return YES;
//}

// Mark task as completed
- (BOOL)markTask:(EKReminder *)task as:(BOOL)isCompleted error:(NSError **)error
{
    task.completed = isCompleted;
    return [self.eventStore saveReminder:task commit:YES error:error];
}

// Get task lists
- (NSArray *)lists
{
    return [self.eventStore calendarsForEntityType:EKEntityTypeReminder];
}

// Get all the tasks in the given list
- (NSArray *)tasksInList:(EKCalendar *)list
{
    __block NSArray *tasks;

    dispatch_semaphore_t mutex = dispatch_semaphore_create(0);

    NSPredicate *predicate = [self.eventStore predicateForIncompleteRemindersWithDueDateStarting:nil
                                                                                                ending:nil
                                                                                             calendars:@[list]];

    [self.eventStore fetchRemindersMatchingPredicate:predicate
                                                completion:^(NSArray *reminders) {
                                                    tasks = reminders;
                                                    dispatch_semaphore_signal(mutex);
                                                }];

    dispatch_semaphore_wait(mutex, DISPATCH_TIME_FOREVER);
    
    return tasks;
}

@end
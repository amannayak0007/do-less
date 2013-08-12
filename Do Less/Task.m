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

- (EKEventStore *)eventStore
{
    static EKEventStore *_eventStore;

    if (!_eventStore) {
        _eventStore = [[EKEventStore alloc] init];
    }

    return _eventStore;
}

- (NSArray *)lists
{
    return [self.eventStore calendarsForEntityType:EKEntityTypeReminder];
}

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

- (EKReminder *)taskWithIndexPath:(NSIndexPath *)indexPath
{
    NSArray *tasks = [self tasksWithSection:indexPath.section];
    return tasks[indexPath.row];
}

- (NSArray *)tasksWithSection:(NSInteger)section
{
    EKCalendar *list = self.lists[section];
    return [self tasksInList:list];
}

@end
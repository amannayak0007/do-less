//
//  Task.m
//  Do Less
//
//  Created by Roc on 13-4-30.
//  Copyright (c) 2013年 Roc. All rights reserved.
//

#import "Task.h"

@interface Task()

// The event store
@property (strong, nonatomic, readonly) EKEventStore *eventStore;

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

- (EKReminder *)loadTaskWithIdentifier:(NSString *)taskId
{
    return (EKReminder *)[self.eventStore calendarItemWithIdentifier:taskId];
}

- (BOOL)saveTask:(EKReminder *)task commit:(BOOL)commit error:(NSError *__autoreleasing *)error
{
    return [self.eventStore saveReminder:task commit:NO error:error];
}

- (BOOL)removeTask:(EKReminder *)task commit:(BOOL)commit error:(NSError *__autoreleasing *)error
{
    return [self.eventStore removeReminder:task commit:commit error:error];
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
    EKCalendar *list = self.lists[indexPath.section];
    NSArray *tasks = [self tasksInList:list];
    return tasks[indexPath.row];
}

- (void)addObserver:(id)notificationObserver selector:(SEL)notificationSelector
{
    [[NSNotificationCenter defaultCenter] addObserver:notificationObserver
                                             selector:notificationSelector
                                                 name:EKEventStoreChangedNotification
                                               object:self.eventStore];
}

- (void)requestAccessWithCompletion:(EKEventStoreRequestAccessCompletionHandler)completion
{
    [self.eventStore requestAccessToEntityType:EKEntityTypeReminder completion:completion];
}

- (BOOL)commit:(NSError *__autoreleasing *)error
{
    return [self.eventStore commit:error];
}

- (EKReminder *)newTask
{
    EKReminder *task = [EKReminder reminderWithEventStore:self.eventStore];
    return task;
}
@end
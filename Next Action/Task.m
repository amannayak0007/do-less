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

// TODO: Only save & load tasks via UserDefaults when it is the right time, e.g. App exits
- (id)loadTodayTaskWithKey:(NSString *)key
{
    NSString *reminderId = [[NSUserDefaults standardUserDefaults] stringForKey:key];
    EKReminder *task = (EKReminder *)[self.eventStore calendarItemWithIdentifier:reminderId];

    if (task) {
        return task;
    } else {
        return [NSNull null];
    }
}

- (void)saveTodayTask:(EKReminder *)task withKey:(NSString *)key
{
    if ((id)task == [NSNull null]) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:task.calendarItemIdentifier forKey:key];
    }

}

// TODO: Commit the change to the event store.
- (BOOL)saveTask:(EKReminder *)task error:(NSError **)error
{
    return [self.eventStore saveReminder:task commit:NO error:error];
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
@end
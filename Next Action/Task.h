//
//  Task.h
//  Do Less
//
//  Created by Roc on 13-4-30.
//  Copyright (c) 2013年 Roc. All rights reserved.
//
//  The data model for the app
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>

@interface Task : NSObject

// Task lists
@property (strong, nonatomic, readonly) NSArray *lists;

// Tasks for today
@property (strong, nonatomic) NSArray *todayTasks;

// Get singleton
+ (Task *)sharedInstance;

// Mark the reminder completed
- (BOOL)saveTask:(EKReminder *)task error:(NSError **)error;

- (NSArray *)tasksInList:(EKCalendar *)list;

// Completed task can not be changed until all the other tasks are completed
- (BOOL)canTaskBeChangedForIndex:(NSInteger)index;

// Register notification
- (void)addObserver:(id)notificationObserver selector:(SEL)notificationSelector;

- (void)requestAccessWithCompletion:(EKEventStoreRequestAccessCompletionHandler)completion;
@end

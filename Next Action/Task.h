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

// Commit all the changes
- (BOOL)commit:(NSError **)error;

// Save a task
- (BOOL)saveTask:(EKReminder *)task error:(NSError **)error;

// Load a task
- (EKReminder *)loadTaskWithIdentifier:(NSString *)taskId;

// Get all the tasks in the given list
- (NSArray *)tasksInList:(EKCalendar *)list;

// Register notification
- (void)addObserver:(id)notificationObserver selector:(SEL)notificationSelector;

// Request access to user's reminders
- (void)requestAccessWithCompletion:(EKEventStoreRequestAccessCompletionHandler)completion;

@end

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

// The event store
@property (strong, nonatomic) EKEventStore *eventStore;

// Task lists
@property (strong, nonatomic, readonly) NSArray *lists;

// Tasks for today
@property (strong, nonatomic) NSArray *todayTasks;

// Get singleton
+ (Task *)sharedInstance;

// Mark the reminder completed
- (BOOL)markTask:(EKReminder *)task as:(BOOL)isComplete error:(NSError **)error;

- (NSArray *)tasksInList:(EKCalendar *)list;

// Completed task can not be changed until all the other tasks are completed
- (BOOL)canTaskBeChangedForIndex:(NSInteger)index;
@end

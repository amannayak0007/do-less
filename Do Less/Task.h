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
@property (strong, nonatomic, readonly) EKEventStore *eventStore;

// Task lists
@property (strong, nonatomic, readonly) NSArray *lists;

// Get all the tasks in the given list
- (NSArray *)tasksInList:(EKCalendar *)list;

// Get task by index path
- (EKReminder *)taskWithIndexPath:(NSIndexPath *)indexPath;

// Get task by section
- (NSArray *)tasksWithSection:(NSInteger)section;

@end

//
//  Action.h
//  Next Action
//
//  Created by Roc on 13-4-30.
//  Copyright (c) 2013年 Roc. All rights reserved.
//
//  The data model for the app
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>

#define DEFAULT_ACTION_GOAL 10

@interface Action : NSObject

//The event store
@property (strong, nonatomic) EKEventStore *eventStore;

// Action need count
@property (nonatomic) NSUInteger actionGoal;

// Action accomplished count
@property (nonatomic) NSUInteger actionCount;

// Award for myself
@property (strong, nonatomic) NSString *award;

// Current action
@property (strong, nonatomic) EKReminder *currentAction;

// Get singleton
+ (Action *)sharedInstance;

/*
// Get a new reminder
- (EKReminder *)newReminder;

// Mark the reminder completed
- (BOOL)completeReminder:(EKReminder *)reminder error:(NSError **)error;

// Remove a reminder
- (BOOL)removeReminder:(EKReminder *)reminder error:(NSError **)error;

// Save a reminder
- (BOOL)saveReminder:(EKReminder *)reminder error:(NSError **)error;

 */
@end

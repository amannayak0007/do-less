//
//  TaskTableViewController.h
//  Do Less
//
//  Created by Roc on 13-5-16.
//  Copyright (c) 2013年 Roc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>

@interface TaskSelectionTableViewController : UITableViewController

// The task to be replaced
@property (strong, nonatomic) EKReminder *replacedTask;

// The selected task
@property (strong, nonatomic) EKReminder *selectedTask;

// The array of the tasks of today
@property (strong, nonatomic) NSArray *todayTasks;

@end

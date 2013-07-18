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

@property (strong, nonatomic) EKReminder *replacedTask;
@property (strong, nonatomic) EKReminder *selectedTask;
@property (strong, nonatomic) NSArray *todayTasks;

@end

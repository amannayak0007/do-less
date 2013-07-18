//
//  TaskTableViewController.m
//  Do Less
//
//  Created by Roc on 13-5-16.
//  Copyright (c) 2013年 Roc. All rights reserved.
//

#import "Task.h"
#import "TaskTableViewController.h"
#import "TodayViewController.h"

@interface TaskTableViewController ()

@property (strong, nonatomic, readonly) Task *model;

@end

@implementation TaskTableViewController

- (Task *)model
{
    return [Task sharedInstance];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.model requestAccessWithCompletion:^(BOOL granted, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (granted && !error) {
                [self.tableView reloadData];
            } else if (!granted) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Eh..."
                                                                message:@"Do Less needs to access your reminders to work properly"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            } else {
                NSLog(@"%@", [error localizedDescription]);
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Eh..."
                                                                message:[error localizedDescription]
                                                               delegate:nil
                                                      cancelButtonTitle:@"Fine"
                                                      otherButtonTitles:nil];
                [alert show];
            }
        });
    }];

    [self.model addObserver:self selector:@selector(eventStoreChanged:)];
}

- (void)eventStoreChanged:(NSNotification *)notification
{
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.model.lists count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    EKCalendar *list = self.model.lists[section];
    NSArray *tasks = [self.model tasksInList:list];
    return [tasks count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    EKCalendar *list = self.model.lists[section];
    NSArray *tasks = [self.model tasksInList:list];
    return [tasks count] == 0 ? nil : list.title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    static NSDateFormatter *dateFormatter;
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        [dateFormatter setDoesRelativeDateFormatting:YES];
    }

    EKCalendar *list = self.model.lists[indexPath.section];
    NSArray *tasks = [self.model tasksInList:list];
    EKReminder *task = tasks[indexPath.row];

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Task" forIndexPath:indexPath];

    cell.textLabel.text = task.title;

    // Dispaly task's due date if possible
    if (task.dueDateComponents) {
        NSCalendar *gregorian = [[NSCalendar alloc]
                                 initWithCalendarIdentifier:NSGregorianCalendar];
        NSDate *dueDate = [gregorian dateFromComponents:task.dueDateComponents];

        cell.detailTextLabel.text = [dateFormatter stringFromDate:dueDate];
    } else {
        cell.detailTextLabel.text = @"";
    }

    // Show the checkmark if the task has been selected
    if ([self.model.todayTasks indexOfObject:task] == NSNotFound) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    } else {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }

    if ([task isEqual:self.model.todayTasks[self.currentTaskTag]]) {
        cell.backgroundView = [[UIView alloc] initWithFrame:cell.frame];
        cell.backgroundView.backgroundColor = [UIColor redColor];
    }

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//    if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
//        [tableView deselectRowAtIndexPath:indexPath animated:YES];
//        return;
//    }
    
//    [tableView deselectRowAtIndexPath:indexPath animated:NO];

    EKCalendar *list = self.model.lists[indexPath.section];
    NSArray *tasks = [self.model tasksInList:list];
    EKReminder *selectedTask = tasks[indexPath.row];

    NSMutableArray *mutalbeTodayTasks = [self.model.todayTasks mutableCopy];

    NSUInteger index = [mutalbeTodayTasks indexOfObject:selectedTask];
    if (index != NSNotFound) {
        mutalbeTodayTasks[index] = mutalbeTodayTasks[self.currentTaskTag];
    }
    mutalbeTodayTasks[self.currentTaskTag] = selectedTask;

    self.model.todayTasks = mutalbeTodayTasks;

    [self performSegueWithIdentifier:@"BackToTasksToday" sender:self];
}

@end

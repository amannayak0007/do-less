//
//  TaskTableViewController.m
//  Do Less
//
//  Created by Roc on 13-5-16.
//  Copyright (c) 2013年 Roc. All rights reserved.
//

#import "Task.h"
#import "TaskTableViewController.h"

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

    [self.model.eventStore requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError *error) {
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

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(eventStoreChanged:)
                                                 name:EKEventStoreChangedNotification
                                               object:self.model.eventStore];
}

- (void)eventStoreChanged:(NSNotification *)notification
{
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

    // Show task title with colorful background
    cell.textLabel.text = task.title;
    cell.textLabel.textColor = [UIColor whiteColor];

    NSArray *colors = @[
                        [UIColor colorWithRed: 252/255.0 green:  47/255.0 blue: 106/255.0 alpha: 1], // Red
                        [UIColor colorWithRed: 254/255.0 green: 203/255.0 blue:  46/255.0 alpha: 1], // Yellow
                        [UIColor colorWithRed:  42/255.0 green: 174/255.0 blue: 245/255.0 alpha: 1], // Blue
                        [UIColor colorWithRed: 253/255.0 green: 148/255.0 blue:  38/255.0 alpha: 1], // Orange
                        [UIColor colorWithRed: 104/255.0 green: 216/255.0 blue:  68/255.0 alpha: 1], // Green
                        [UIColor colorWithRed: 206/255.0 green: 122/255.0 blue: 225/255.0 alpha: 1], // Purple
                        [UIColor colorWithRed: 161/255.0 green: 132/255.0 blue:  96/255.0 alpha: 1], // Brown
                        ];

    cell.backgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cell.backgroundView.backgroundColor = colors[indexPath.section % colors.count];

    // Dispaly task's due date if possible
    if (task.dueDateComponents) {
        NSCalendar *gregorian = [[NSCalendar alloc]
                                 initWithCalendarIdentifier:NSGregorianCalendar];
        NSDate *dueDate = [gregorian dateFromComponents:task.dueDateComponents];

        cell.detailTextLabel.text = [dateFormatter stringFromDate:dueDate];
    } else {
        cell.detailTextLabel.text = @"";
    }
    cell.detailTextLabel.textColor = [UIColor whiteColor];

    // Show the checkmark if the task has been selected
    if ([self.model.todayTasks indexOfObject:task] == NSNotFound) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    } else {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }

    [tableView deselectRowAtIndexPath:indexPath animated:NO];

    EKCalendar *list = self.model.lists[indexPath.section];
    NSArray *tasks = [self.model tasksInList:list];
    EKReminder *selectedTask = tasks[indexPath.row];

    NSMutableArray *mutalbeTodayTasks = [self.model.todayTasks mutableCopy];
    mutalbeTodayTasks[self.currentTaskTag] = selectedTask;
    self.model.todayTasks = mutalbeTodayTasks;

    [self performSegueWithIdentifier:@"BackToTasksToday" sender:self];
}

@end

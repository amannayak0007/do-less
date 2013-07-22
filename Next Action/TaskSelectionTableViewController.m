//
//  TaskTableViewController.m
//  Do Less
//
//  Created by Roc on 13-5-16.
//  Copyright (c) 2013年 Roc. All rights reserved.
//

#import "Task.h"
#import "TaskSelectionTableViewController.h"

@interface TaskSelectionTableViewController ()

@property (strong, nonatomic) Task *model;

@end

@implementation TaskSelectionTableViewController

#pragma mark - Getter & Setter

- (Task *)model
{
    if (!_model) {
        _model = [[Task alloc] init];
    }
    return _model;
}

#pragma mark - View Controller

- (void)viewDidLoad
{
    [super viewDidLoad];

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
    if ([self.todayTasks indexOfObject:task] == NSNotFound) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    } else {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }

    if ([task isEqual:self.replacedTask]) {
        cell.backgroundView = [[UIView alloc] initWithFrame:cell.frame];
        cell.backgroundView.backgroundColor = [UIColor redColor];
    } else {
        cell.backgroundView = nil;
    }

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    EKCalendar *list = self.model.lists[indexPath.section];
    NSArray *tasks = [self.model tasksInList:list];
    self.selectedTask = tasks[indexPath.row];

    [self performSegueWithIdentifier:@"BackToTasksToday" sender:self];
}

@end

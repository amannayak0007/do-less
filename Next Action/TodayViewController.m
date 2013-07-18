//
//  CurrentReminderController.m
//  Do Less
//
//  Created by Roc on 13-4-30.
//  Copyright (c) 2013年 Roc. All rights reserved.
//

#import "Task.h"
#import "TaskSelectionTableViewController.h"
#import "TodayViewController.h"
#import "TaskCell.h"

@interface TodayViewController ()

@property (strong, nonatomic) Task *model;

// Tasks for today
@property (strong, nonatomic) NSArray *todayTasks;

@end

@implementation TodayViewController
@synthesize todayTasks = _todayTasks;

- (Task *)model
{
    if (!_model) {
        _model = [[Task alloc] init];
    }
    return _model;
}

// TODO: Try to return mutable array here.
- (NSArray *)todayTasks
{
    if (!_todayTasks) {
        _todayTasks = @[
                        [self.model loadTodayTaskWithKey:@"Task1"],
                        [self.model loadTodayTaskWithKey:@"Task2"],
                        [self.model loadTodayTaskWithKey:@"Task3"],
                        ];
    }

    return _todayTasks;
}

- (void)setTodayTasks:(NSArray *)todayTasks
{
    _todayTasks = todayTasks;
    [self.model saveTodayTask:_todayTasks[0] withKey:@"Task1"];
    [self.model saveTodayTask:_todayTasks[1] withKey:@"Task2"];
    [self.model saveTodayTask:_todayTasks[2] withKey:@"Task3"];
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

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if (   self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft
        || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        self.tableView.scrollEnabled = YES;
    } else {
        self.tableView.scrollEnabled = NO;
    }
}

- (void)eventStoreChanged:(NSNotification *)notification
{
    [self.tableView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ToTaskTable"]) {
        TaskSelectionTableViewController *taskSelectionTVC = segue.destinationViewController;
        taskSelectionTVC.replacedTask = (EKReminder *)sender;
        taskSelectionTVC.todayTasks = self.todayTasks;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];

    EKReminder *task = self.todayTasks[indexPath.row];

    if ((id)task == [NSNull null] || task.isCompleted == NO) {
        [self performSegueWithIdentifier:@"ToTaskTable" sender:task];
    }
}

// Refresh tasks display after unwind from task selection
- (IBAction)didSelectNewTask:(UIStoryboardSegue *)segue {
    TaskSelectionTableViewController *taskSelectionTVC = segue.sourceViewController;

    if ([taskSelectionTVC.selectedTask isEqual:taskSelectionTVC.replacedTask]) {
        return;
    }

    NSUInteger replacedIndex = [self.todayTasks indexOfObject:taskSelectionTVC.replacedTask];
    NSMutableArray *mutalbeTodayTasks = [self.todayTasks mutableCopy];
    NSUInteger index = [mutalbeTodayTasks indexOfObject:taskSelectionTVC.selectedTask];

    if (index != NSNotFound) {
        mutalbeTodayTasks[index] = taskSelectionTVC.replacedTask;
    }

    mutalbeTodayTasks[replacedIndex] = taskSelectionTVC.selectedTask;

    self.todayTasks = mutalbeTodayTasks;

    [self.tableView reloadData];
}

- (IBAction)toggleCompleted:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        CGPoint swipeLocation = [sender locationInView:self.tableView];
        NSIndexPath *swipedIndexPath = [self.tableView indexPathForRowAtPoint:swipeLocation];
        TaskCell* swipedCell = (TaskCell *)[self.tableView cellForRowAtIndexPath:swipedIndexPath];
        EKReminder *task = self.todayTasks[swipedIndexPath.row];

        if ((id)task == [NSNull null]) {
            return;
        }

        swipedCell.completed = !swipedCell.isCompleted;
        task.completed = swipedCell.isCompleted;

        NSError *error;
        if (![self.model saveTask:task error:&error]) {
            NSLog(@"%@", [error localizedDescription]);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Eh..."
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Fine"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }
}

- (IBAction)swipeRecognized:(UISwipeGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateRecognized) {
        CGPoint swipeLocation = [sender locationInView:self.tableView];
        NSIndexPath *swipedIndexPath = [self.tableView indexPathForRowAtPoint:swipeLocation];
        TaskCell* swipedCell = (TaskCell *)[self.tableView cellForRowAtIndexPath:swipedIndexPath];
        EKReminder *task = self.todayTasks[swipedIndexPath.row];

        if ((id)task == [NSNull null]) {
            return;
        }

        if (sender.direction == UISwipeGestureRecognizerDirectionLeft) {
            swipedCell.completed = NO;
            task.completed = NO;
        } else if (sender.direction == UISwipeGestureRecognizerDirectionRight) {
            swipedCell.completed = YES;
            task.completed = YES;
        }

        NSError *error;
        if (![self.model saveTask:task error:&error]) {
            NSLog(@"%@", [error localizedDescription]);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Eh..."
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Fine"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (   self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft
        || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        return self.tableView.bounds.size.height;
    } else {
        return self.tableView.bounds.size.height/3;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    TaskCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    EKReminder *task = self.todayTasks[indexPath.row];

    // Configure the cell...
    if ((id)task == [NSNull null]) {
        cell.textLabel.text = @"";
        cell.completed = NO;
    } else {
        cell.textLabel.text = task.title;
        cell.completed = task.isCompleted;
    }

    return cell;
}

@end

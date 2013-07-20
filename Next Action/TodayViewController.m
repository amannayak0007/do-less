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
@property (strong, nonatomic) NSMutableArray *todayTasks;
@property NSUInteger replacedIndex;

@end

@implementation TodayViewController
@synthesize todayTasks = _todayTasks;

#pragma mark - Getter & Setter

- (Task *)model
{
    if (!_model) {
        _model = [[Task alloc] init];
    }
    return _model;
}

- (NSMutableArray *)todayTasks
{
    if (!_todayTasks) {
        _todayTasks = [@[
                        [self.model loadTodayTaskWithKey:@"Task1"],
                        [self.model loadTodayTaskWithKey:@"Task2"],
                        [self.model loadTodayTaskWithKey:@"Task3"],
                        ] mutableCopy];
    }

    return _todayTasks;
}

#pragma mark - View Controller

- (void)setTodayTasks:(NSMutableArray *)todayTasks
{
    _todayTasks = todayTasks;
    [self.model saveTodayTask:_todayTasks[0] withKey:@"Task1"];
    [self.model saveTodayTask:_todayTasks[1] withKey:@"Task2"];
    [self.model saveTodayTask:_todayTasks[2] withKey:@"Task3"];
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self becomeFirstResponder];
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

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    // User was shaking the device.
    if (motion == UIEventSubtypeMotionShake)
    {
        NSMutableArray *uncompletedTasks = [[NSMutableArray alloc] init];

        for (NSUInteger i=0; i<[self.todayTasks count]; i++) {
            EKReminder *task = self.todayTasks[i];
            if ((id)task != [NSNull null] && task.completed == NO) {
                [uncompletedTasks addObject:[NSNumber numberWithUnsignedInteger:i]];
            }
        }

        if ([uncompletedTasks count] == 0) {
            self.todayTasks = [@[[NSNull null], [NSNull null],[NSNull null]] mutableCopy];
        } else {
            for (NSNumber *j in uncompletedTasks) {
                self.todayTasks[[j unsignedIntegerValue]] = [NSNull null];
            }
        }

        [self.tableView reloadData];
    }
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

# pragma mark - Actions

// Refresh tasks display after unwind from task selection
- (IBAction)didSelectNewTask:(UIStoryboardSegue *)segue
{
    TaskSelectionTableViewController *taskSelectionTVC = segue.sourceViewController;

    if ([taskSelectionTVC.selectedTask isEqual:taskSelectionTVC.replacedTask]) {
        return;
    }

    NSUInteger index = [self.todayTasks indexOfObject:taskSelectionTVC.selectedTask];

    if (index != NSNotFound) {
        self.todayTasks[index] = taskSelectionTVC.replacedTask;
    }

    self.todayTasks[self.replacedIndex] = taskSelectionTVC.selectedTask;

    [self.tableView reloadData];
}

- (IBAction)toggleCompleted:(UILongPressGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan) {
        CGPoint swipeLocation = [sender locationInView:self.tableView];
        NSIndexPath *swipedIndexPath = [self.tableView indexPathForRowAtPoint:swipeLocation];
        TaskCell* swipedCell = (TaskCell *)[self.tableView cellForRowAtIndexPath:swipedIndexPath];
        EKReminder *task = self.todayTasks[swipedIndexPath.row];

        if ((id)task == [NSNull null]) {
            return;
        }

        task.completed = !task.isCompleted;
        [swipedCell setCompleted:task.completed animated:YES];

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

- (IBAction)swipeRecognized:(UISwipeGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateRecognized) {
        CGPoint swipeLocation = [sender locationInView:self.tableView];
        NSIndexPath *swipedIndexPath = [self.tableView indexPathForRowAtPoint:swipeLocation];
        TaskCell* swipedCell = (TaskCell *)[self.tableView cellForRowAtIndexPath:swipedIndexPath];
        EKReminder *task = self.todayTasks[swipedIndexPath.row];

        if ((id)task == [NSNull null]) {
            return;
        }

        if (sender.direction == UISwipeGestureRecognizerDirectionLeft) {
            task.completed = NO;
        } else if (sender.direction == UISwipeGestureRecognizerDirectionRight) {
            task.completed = YES;
        }
        [swipedCell setCompleted:task.completed animated:YES];

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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];

    EKReminder *task = self.todayTasks[indexPath.row];

    if ((id)task == [NSNull null] || task.isCompleted == NO) {
        self.replacedIndex = indexPath.row;
        [self performSegueWithIdentifier:@"ToTaskTable" sender:task];
    }
}

@end

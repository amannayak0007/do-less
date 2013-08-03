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

#define TODAY_TASK_NUMER 3

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
        _todayTasks = [[NSMutableArray alloc] initWithCapacity:TODAY_TASK_NUMER];

        for (NSUInteger i=0; i<TODAY_TASK_NUMER; i++) {
            NSString *taskId = [[NSUserDefaults standardUserDefaults] stringForKey:[@"Task" stringByAppendingFormat:@"%d", i]];
            EKReminder *task = (EKReminder *)[self.model loadTaskWithIdentifier:taskId];

            if (task) {
                _todayTasks[i] = task;
            } else {
                _todayTasks[i] = [NSNull null];
            }
        }
    }

    return _todayTasks;
}

#pragma mark - View Controller

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self resignFirstResponder];

    NSError *error;
    if (![self.model commit:&error]) {
        NSLog(@"%@", [error localizedDescription]);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Eh..."
                                                        message:[error localizedDescription]
                                                       delegate:nil
                                              cancelButtonTitle:@"Fine"
                                              otherButtonTitles:nil];
        [alert show];
    }

    [super viewWillAppear:animated];
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
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(save:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:[UIApplication sharedApplication]];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(commit:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:[UIApplication sharedApplication]];
}

// Save the task ids of today to user default
- (void)save:(NSNotification *)notification
{
    for (NSUInteger i=0; i<TODAY_TASK_NUMER; i++) {
        EKReminder *task = self.todayTasks[i];
        NSString *key = [@"Task" stringByAppendingFormat:@"%d", i];

        if ((id)task == [NSNull null]) {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
        } else {
            [[NSUserDefaults standardUserDefaults] setObject:task.calendarItemIdentifier forKey:key];
        }
    }
}

// Commit all the modifications
- (void)commit:(NSNotification *)notification
{
    NSError *error;
    if (![self.model commit:&error]) {
        NSLog(@"%@", [error localizedDescription]);
    }
}

- (void)eventStoreChanged:(NSNotification *)notification
{
    for (NSUInteger i=0; i<TODAY_TASK_NUMER; i++) {

        EKReminder *task = self.todayTasks[i];

        if ((id)task == [NSNull null]) {
            continue;
        } else if (![task refresh]) {
            self.todayTasks[i] = [NSNull null];
        }
    }

    [self.tableView reloadData];
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    // User was shaking the device.
    if (motion == UIEventSubtypeMotionShake && self.view.window)
    {
        NSMutableArray *uncompletedTasks = [[NSMutableArray alloc] init];

        for (NSUInteger i=0; i<[self.todayTasks count]; i++) {
            EKReminder *task = self.todayTasks[i];
            if ((id)task != [NSNull null] && task.completed == NO) {
                [uncompletedTasks addObject:[NSNumber numberWithUnsignedInteger:i]];
            }
        }

        if ([uncompletedTasks count] == 0) {
            for (NSUInteger i=0; i<[self.todayTasks count]; i++) {
                self.todayTasks[i] = [NSNull null];
            }
        } else {
            for (NSNumber *j in uncompletedTasks) {
                self.todayTasks[[j unsignedIntegerValue]] = [NSNull null];
            }
        }

        [self.tableView reloadData];
    }
}

- (void)configScrollView
{
    if (   self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft
        || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        self.tableView.scrollEnabled = YES;
    } else {
        self.tableView.scrollEnabled = NO;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ToTaskTable"]) {
        UINavigationController *nvc = segue.destinationViewController;
        TaskSelectionTableViewController *taskSelectionTVC = (TaskSelectionTableViewController*)nvc.topViewController;
        taskSelectionTVC.replacedTask = (EKReminder *)sender;
        taskSelectionTVC.todayTasks = self.todayTasks;
    }
}

# pragma mark - Actions

// Refresh tasks display after unwind from task selection
- (IBAction)didSelectNewTask:(UIStoryboardSegue *)segue
{
    TaskSelectionTableViewController *taskSelectionTVC = segue.sourceViewController;

    if (!taskSelectionTVC.selectedTask || [taskSelectionTVC.selectedTask isEqual:taskSelectionTVC.replacedTask]) {
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

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return TODAY_TASK_NUMER;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (   self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft
        || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        return self.tableView.bounds.size.height;
    } else {
        return self.tableView.bounds.size.height/TODAY_TASK_NUMER;
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

    cell.textLabel.backgroundColor = [UIColor clearColor];

    if (   self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft
        || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LandscapeCell.png"]];
        cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LandscapeCellSelected.png"]];
    } else {
        cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PortraitCell.png"]];
        cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PortraitCellSelected.png"]];
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

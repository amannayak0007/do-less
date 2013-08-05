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

        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"])
        {
            for (NSUInteger i=0; i<TODAY_TASK_NUMER; i++) {
                NSString *taskId = [[NSUserDefaults standardUserDefaults] stringForKey:[@"Task" stringByAppendingFormat:@"%d", i]];
                EKReminder *task = (EKReminder *)[self.model loadTaskWithIdentifier:taskId];

                if (task) {
                    _todayTasks[i] = task;
                } else {
                    _todayTasks[i] = [NSNull null];
                }
            }
        } else {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasLaunchedOnce"];
            [[NSUserDefaults standardUserDefaults] synchronize];

            EKReminder *tempTask = [self.model newTask];
            tempTask.title = @"Tap to select task";
            _todayTasks[0] = tempTask;

            tempTask = [self.model newTask];
            tempTask.title = @"Long press to toggle completion";
            _todayTasks[1] = tempTask;

            tempTask = [self.model newTask];
            tempTask.title = @"Shake to dismiss tasks";
            _todayTasks[2] = tempTask;
        }
    }

    return _todayTasks;
}

#pragma mark - View Controller

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    for (UITableViewCell *cell in self.tableView.visibleCells) {
        if (   toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft
            || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
            cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LandscapeCell.png"]];
            cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LandscapeCellSelected.png"]];
        } else {
            cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PortraitCell.png"]];
            cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PortraitCellSelected.png"]];
        }
    }
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

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [self resignFirstResponder];

    NSError *error;
    if (![self.model commit:&error]) {
        [self alert:[error localizedDescription]];
    }
}

- (void)alert:(NSString *)msg
{
    NSLog(@"%@", msg);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Eh..."
                                                    message:msg
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    switch ([EKEventStore authorizationStatusForEntityType:EKEntityTypeReminder]) {
        case EKAuthorizationStatusDenied:
        case EKAuthorizationStatusRestricted:
        {
            [self alert: @"To let Do Less work properly, please authorize it to access your reminders."];
            break;
        }
        case EKAuthorizationStatusNotDetermined:
        {
            [self.model requestAccessWithCompletion:^(BOOL granted, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (granted && !error) {
                        [self.tableView reloadData];
                    } else if (!granted) {
                        [self alert: @"To let Do Less work properly, please authorize it to access your reminders."];
                    } else {
                        [self alert:[error localizedDescription]];
                    }
                });
            }];
            break;
        }
        case EKAuthorizationStatusAuthorized:
        default:
        {
            [self.tableView reloadData];
            break;
        }
    }

    [self.model addObserver:self selector:@selector(eventStoreChanged:)];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:[UIApplication sharedApplication]];
}

- (void)didEnterBackground:(NSNotification *)notification
{
    // Save tasks of today
    for (NSUInteger i=0; i<TODAY_TASK_NUMER; i++) {
        EKReminder *task = self.todayTasks[i];
        NSString *key = [@"Task" stringByAppendingFormat:@"%d", i];

        if ((id)task == [NSNull null]) {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
        } else {
            [[NSUserDefaults standardUserDefaults] setObject:task.calendarItemIdentifier forKey:key];
        }
    }

    // Commit all the changes
    NSError *error;
    if (![self.model commit:&error]) {
        NSLog(@"%@", [error localizedDescription]);
    }

    // Dismiss task selection view
    [self dismissViewControllerAnimated:NO completion:^{}];
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
    // User was shaking the device and current is seeable
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ToTaskTable"]) {
        UINavigationController *nvc = segue.destinationViewController;
        TaskSelectionTableViewController *taskSelectionTVC = (TaskSelectionTableViewController*)nvc.topViewController;
        taskSelectionTVC.replacedTask = (EKReminder *)sender;
        taskSelectionTVC.todayTasks = self.todayTasks;
    }
}

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
        CGPoint pressedLocation = [sender locationInView:self.tableView];
        
        NSIndexPath *pressedIndexPath = [self.tableView indexPathForRowAtPoint:pressedLocation];
        if (!pressedIndexPath) {
            return;
        }

        TaskCell* pressedCell = (TaskCell *)[self.tableView cellForRowAtIndexPath:pressedIndexPath];
        EKReminder *task = self.todayTasks[pressedIndexPath.row];

        if ((id)task == [NSNull null]) {
            return;
        }

        task.completed = !task.isCompleted;
        [pressedCell setCompleted:task.completed animated:YES];

        NSError *error;
        // Teh calendar of presetted instrunctional task is nil, so don't save them.
        if (task.calendar && ![self.model saveTask:task commit:NO error:&error]) {
            [self alert:[error localizedDescription]];
        }
    }
}

- (void)configCellsBackground:(UITableViewCell *)cell
{
    if (   self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft
        || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LandscapeCell.png"]];
        cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LandscapeCellSelected.png"]];
    } else {
        cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PortraitCell.png"]];
        cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PortraitCellSelected.png"]];
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
    TaskCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TaskCell" forIndexPath:indexPath];
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

    [self configCellsBackground:cell];

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

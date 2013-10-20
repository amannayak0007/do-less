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
#import "Common.h"

#define TODAY_TASK_NUMER 3

@interface TodayViewController ()

@property (strong, nonatomic) Task *model;

// Tasks for today
@property (strong, nonatomic) NSMutableArray *todayTasks;
@property (strong, nonatomic) NSMutableArray *stampCoordinates;
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

- (void)loadTodayTasks
{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasLaunchedOnce"];
        [[NSUserDefaults standardUserDefaults] synchronize];

        EKCalendar *doLessList = [EKCalendar calendarForEntityType:EKEntityTypeReminder eventStore:self.model.eventStore];
        doLessList.title = @"Do Less";
        doLessList.source = self.model.eventStore.defaultCalendarForNewReminders.source;

        EKReminder *task1 = [EKReminder reminderWithEventStore:self.model.eventStore];
        task1.title = NSLocalizedString(@"Tap to select a task", @"User Instruction 1");
        task1.calendar = doLessList;
        
        EKReminder *task2 = [EKReminder reminderWithEventStore:self.model.eventStore];
        task2.title = NSLocalizedString(@"Long press to toggle completion", @"User Instruction 2");
        task2.calendar = doLessList;
        
        EKReminder *task3 = [EKReminder reminderWithEventStore:self.model.eventStore];
        task3.title = NSLocalizedString(@"Shake to dismiss tasks", @"User Instruction 3");
        task3.calendar = doLessList;
        
        EKReminder *task4 = [EKReminder reminderWithEventStore:self.model.eventStore];
        task4.title = NSLocalizedString(@"Use the Reminder app to manage your tasks", @"User instruction 4");
        task4.calendar = doLessList;
        
        NSError *error;
        if (![self.model.eventStore saveCalendar:doLessList commit:YES error:&error]) {
            NSLog(@"%@", [error localizedDescription]);
        }
        if (![self.model.eventStore saveReminder:task1 commit:NO error:&error]) {
            NSLog(@"%@", [error localizedDescription]);
        }
        if (![self.model.eventStore saveReminder:task2 commit:NO error:&error]) {
            NSLog(@"%@", [error localizedDescription]);
        }
        if (![self.model.eventStore saveReminder:task3 commit:NO error:&error]) {
            NSLog(@"%@", [error localizedDescription]);
        }
        if (![self.model.eventStore saveReminder:task4 commit:NO error:&error]) {
            NSLog(@"%@", [error localizedDescription]);
        }
        if (![self.model.eventStore commit:&error]) {
            NSLog(@"%@", [error localizedDescription]);
        }

        self.todayTasks = [@[task1, task2, task3] mutableCopy];
    }

    [self.tableView reloadData];
}

- (NSMutableArray *)todayTasks
{
    if (!_todayTasks) {
        _todayTasks = [[NSMutableArray alloc] initWithCapacity:TODAY_TASK_NUMER];
        
        for (NSUInteger i=0; i<TODAY_TASK_NUMER; i++) {
            NSString *taskId = [[NSUserDefaults standardUserDefaults] stringForKey:[@"Task" stringByAppendingFormat:@"%d", i]];
            EKReminder *task = (EKReminder *)[self.model.eventStore calendarItemWithIdentifier:taskId];
            
            if (task) {
                _todayTasks[i] = task;
            } else {
                _todayTasks[i] = [NSNull null];
            }
        }
    }

    return _todayTasks;
}

- (NSMutableArray *)stampCoordinates
{
    if (!_stampCoordinates) {
        _stampCoordinates = [[NSMutableArray alloc] initWithCapacity:TODAY_TASK_NUMER];
        for (NSUInteger i=0; i<TODAY_TASK_NUMER; i++) {
            _stampCoordinates[i] = [NSValue valueWithCGPoint:[TaskCell defaultStampCoordinate]];
        }
    }
    return _stampCoordinates;
}

#pragma mark - View Controller

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
    if (![self.model.eventStore commit:&error]) {
        [Common alert:[error localizedDescription]];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    switch ([EKEventStore authorizationStatusForEntityType:EKEntityTypeReminder]) {
        case EKAuthorizationStatusDenied:
        case EKAuthorizationStatusRestricted:
        {
            [Common alert: NSLocalizedString(@"To let Do Less work properly, please authorize it to access your reminders.", @"Ask user to grant the access to his/her reminders")];
            break;
        }
        case EKAuthorizationStatusNotDetermined:
        {
            [self.model.eventStore requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (granted && !error) {
                        [self loadTodayTasks];
                    } else if (!granted) {
                        [Common alert: NSLocalizedString(@"To let Do Less work properly, please authorize it to access your reminders.", @"Ask user to grant the access to his/her reminders")];
                    } else {
                        [Common alert:[error localizedDescription]];
                    }
                });
            }];
            break;
        }
        case EKAuthorizationStatusAuthorized:
        default:
        {
            [self loadTodayTasks];
            break;
        }
    }

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(eventStoreChanged:)
                                                 name:EKEventStoreChangedNotification
                                               object:self.model.eventStore];
    
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
    if (![self.model.eventStore commit:&error]) {
        NSLog(@"%@", [error localizedDescription]);
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
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
        NSMutableArray *completedTasks = [[NSMutableArray alloc] init];

        for (NSUInteger i=0; i<[self.todayTasks count]; i++) {
            EKReminder *task = self.todayTasks[i];
            if ((id)task != [NSNull null] && task.completed == YES) {
                [completedTasks addObject:[NSNumber numberWithUnsignedInteger:i]];
            }
        }

        // If there are completed tasks, dismiss only them; if no completed task, dismiss all tasks.
        if ([completedTasks count] == 0) {
            for (NSUInteger i=0; i<[self.todayTasks count]; i++) {
                self.todayTasks[i] = [NSNull null];
            }
        } else {
            for (NSNumber *j in completedTasks) {
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
        taskSelectionTVC.navBarColorIndex = self.replacedIndex;
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

        CGPoint pressedPoint = [sender locationInView:pressedCell];
        CGPoint relativePressedPoint = CGPointMake(pressedPoint.x/pressedCell.bounds.size.width, pressedPoint.y/pressedCell.bounds.size.height);
        self.stampCoordinates[pressedIndexPath.row] = [NSValue valueWithCGPoint:relativePressedPoint];

        [pressedCell setCompleted:task.completed atRelativePoint:relativePressedPoint animated:YES];

        NSError *error;
        if (![self.model.eventStore saveReminder:task commit:NO error:&error]) {
            [Common alert:[error localizedDescription]];
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
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
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
        [cell setCompleted:NO
           atRelativePoint:[self.stampCoordinates[indexPath.row] CGPointValue]
                  animated:NO];
    } else {
        cell.textLabel.text = task.title;
        [cell setCompleted:task.completed
           atRelativePoint:[self.stampCoordinates[indexPath.row] CGPointValue]
                  animated:NO];
    }

    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.textLabel.shadowColor = [Common shadowColor];
    cell.textLabel.shadowOffset = [Common shadowOffset];

    cell.backgroundColor = [Common themeColors][indexPath.row];

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

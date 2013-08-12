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
        EKCalendar *doLessList = [EKCalendar calendarForEntityType:EKEntityTypeReminder eventStore:self.model.eventStore];
        doLessList.title = @"Do Less";
        doLessList.source = self.model.eventStore.defaultCalendarForNewReminders.source;
        
        EKReminder *task1 = [EKReminder reminderWithEventStore:self.model.eventStore];
        task1.title = @"Tap to select task";
        task1.calendar = doLessList;
        
        EKReminder *task2 = [EKReminder reminderWithEventStore:self.model.eventStore];
        task2.title = @"Long press to toggle completion";
        task2.calendar = doLessList;
        
        EKReminder *task3 = [EKReminder reminderWithEventStore:self.model.eventStore];
        task3.title = @"Shake to dismiss tasks";
        task3.calendar = doLessList;
        
        EKReminder *task4 = [EKReminder reminderWithEventStore:self.model.eventStore];
        task4.title = @"Use the Reminder app to manage your tasks";
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

        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasLaunchedOnce"];
        [[NSUserDefaults standardUserDefaults] synchronize];
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

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    for (UITableViewCell *cell in self.tableView.visibleCells) {
        NSInteger idx = [self.tableView indexPathForCell:cell].row;
        [self configCellBackground:cell ByIndex:idx andOrientation:toInterfaceOrientation];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    for (UITableViewCell *cell in self.tableView.visibleCells) {
        NSInteger idx = [self.tableView indexPathForCell:cell].row;
        [self configCellBackground:cell ByIndex:idx andOrientation:self.interfaceOrientation];
    }
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
            [Common alert: @"To let Do Less work properly, please authorize it to access your reminders."];
            break;
        }
        case EKAuthorizationStatusNotDetermined:
        {
            [self.model.eventStore requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (granted && !error) {
                        [self loadTodayTasks];
                    } else if (!granted) {
                        [Common alert: @"To let Do Less work properly, please authorize it to access your reminders."];
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

    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"WoodTextureBg-Bottom"]];
    [self.tableView.backgroundView sizeToFit];
    self.tableView.backgroundView.center = self.tableView.center;
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

    // Dismiss task selection view
    [self dismissViewControllerAnimated:NO completion:^{}];
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
        taskSelectionTVC.navBarColorIndex = self.replacedIndex;
    
        [[UIBarButtonItem appearance] setBackgroundImage:[[UIImage imageNamed:@"Button-Default"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)]
                                   forState:UIControlStateNormal
                                 barMetrics:UIBarMetricsDefault];
        [[UIBarButtonItem appearance] setBackgroundImage:[[UIImage imageNamed:@"Button-Active"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)]
                                   forState:UIControlStateHighlighted
                                 barMetrics:UIBarMetricsDefault];

        [[UIBarButtonItem appearance] setBackgroundImage:[[UIImage imageNamed:@"Button-Landscape-Default"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)]
                                   forState:UIControlStateNormal
                                 barMetrics:UIBarMetricsLandscapePhone];
        [[UIBarButtonItem appearance] setBackgroundImage:[[UIImage imageNamed:@"Button-Landscape-Active"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)]
                                   forState:UIControlStateHighlighted
                                 barMetrics:UIBarMetricsLandscapePhone];

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

- (void)configCellBackground:(UITableViewCell *)cell ByIndex:(NSUInteger)idx andOrientation:(UIInterfaceOrientation)orientation
{
    NSMutableString *imageFileName = [@"IndexBg" mutableCopy];

    if (UIInterfaceOrientationIsLandscape(orientation)) {
        [imageFileName appendString:@"-Landscape"];
    } else {
        [imageFileName appendString:@"-Portrait"];
    }

    [imageFileName appendFormat:@"-%02d", idx + 1];


    if (IS_WIDESCREEN) {
        [imageFileName appendFormat:@"-568h"];
    }
    
    cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageFileName]];
    // TODO: Add the right selected bg image
    cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageFileName]];
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

    [self configCellBackground:cell ByIndex:indexPath.row andOrientation:self.interfaceOrientation];

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

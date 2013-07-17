//
//  CurrentReminderController.m
//  Do Less
//
//  Created by Roc on 13-4-30.
//  Copyright (c) 2013年 Roc. All rights reserved.
//

#import "Task.h"
#import "TaskTableViewController.h"
#import "TodayViewController.h"
#import "TaskCell.h"

@interface TodayViewController ()
@property (strong, nonatomic, readonly) Task *model;
@end

@implementation TodayViewController

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
        TaskTableViewController *tvc = segue.destinationViewController;
        tvc.currentTaskTag = ((NSIndexPath *)sender).row;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    [self performSegueWithIdentifier:@"ToTaskTable" sender:indexPath];
}

// Refresh tasks display after unwind from task selection
- (IBAction)didSelectNewTask:(UIStoryboardSegue *)segue {
    [self.tableView reloadData];
}


//TODO: write to the store
- (IBAction)swipeRecognized:(UISwipeGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateRecognized) {
        CGPoint swipeLocation = [sender locationInView:self.tableView];
        NSIndexPath *swipedIndexPath = [self.tableView indexPathForRowAtPoint:swipeLocation];
        TaskCell* swipedCell = (TaskCell *)[self.tableView cellForRowAtIndexPath:swipedIndexPath];
        EKReminder *task = self.model.todayTasks[swipedIndexPath.row];

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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    EKReminder *task = self.model.todayTasks[indexPath.row];

    // Configure the cell...
    if ((id)task == [NSNull null]) {
        cell.textLabel.text = @"";
    } else {
        cell.textLabel.text = task.title;
    }

    return cell;
}

@end

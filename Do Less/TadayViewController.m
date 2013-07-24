//
//  CurrentReminderController.m
//  Do Less
//
//  Created by Roc on 13-4-30.
//  Copyright (c) 2013年 Roc. All rights reserved.
//

#import "Task.h"
#import "TaskTableViewController.h"
#import "TadayViewController.h"

@interface TadayViewController ()

@property (strong, nonatomic, readonly) Task *model;
@property (weak, nonatomic) IBOutlet UITableViewCell *cell1;
@property (weak, nonatomic) IBOutlet UITableViewCell *cell2;
@property (weak, nonatomic) IBOutlet UITableViewCell *cell3;

@end

@implementation TadayViewController

- (Task *)model
{
    return [Task sharedInstance];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(eventStoreChanged:)
                                                 name:EKEventStoreChangedNotification
                                               object:self.model.eventStore];

    // Set background color and text color.
    self.cell1.backgroundView = [[UIView alloc] initWithFrame:self.cell1.frame];
    self.cell2.backgroundView = [[UIView alloc] initWithFrame:self.cell2.frame];
    self.cell3.backgroundView = [[UIView alloc] initWithFrame:self.cell3.frame];

    self.cell1.backgroundView.backgroundColor = [UIColor colorWithRed:252.0/255.0 green: 47.0/255.0 blue:106.0/255.0 alpha:1];
    self.cell2.backgroundView.backgroundColor = [UIColor colorWithRed:254.0/255.0 green:203.0/255.0 blue: 46.0/255.0 alpha:1];
    self.cell3.backgroundView.backgroundColor = [UIColor colorWithRed: 42.0/255.0 green:174.0/255.0 blue:245.0/255.0 alpha:1];

    self.cell1.textLabel.textColor = [UIColor whiteColor];
    self.cell2.textLabel.textColor = [UIColor whiteColor];
    self.cell3.textLabel.textColor = [UIColor whiteColor];

    [self refreshTasksToday];
}

- (void)refreshTasksToday
{
    self.cell1.textLabel.text = self.model.task1.isCompleted ? [self.model.task1.title stringByAppendingString:@"(✓)"] : self.model.task1.title;
    self.cell2.textLabel.text = self.model.task2.isCompleted ? [self.model.task2.title stringByAppendingString:@"(✓)"] : self.model.task2.title;
    self.cell3.textLabel.text = self.model.task3.isCompleted ? [self.model.task3.title stringByAppendingString:@"(✓)"] : self.model.task3.title;
}

- (void)eventStoreChanged:(NSNotification *)notification
{
    [self refreshTasksToday];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ToTaskTable"]) {
        TaskTableViewController *tvc = segue.destinationViewController;
        tvc.currentTaskId = ((UITableViewCell *)((UITapGestureRecognizer *)sender).view).reuseIdentifier;
    }
}

- (IBAction)selectTask:(UITapGestureRecognizer *)sender {
    [self performSegueWithIdentifier:@"ToTaskTable" sender:sender];
}

- (IBAction)markCompleted:(UISwipeGestureRecognizer *)sender {
    EKReminder *task;
    NSString *taskId = ((UITableViewCell *)sender.view).reuseIdentifier;

    if ([taskId isEqualToString:@"Task1"]) {
        task = self.model.task1;
    } else if ([taskId isEqualToString:@"Task2"]) {
        task = self.model.task2;
    } else if ([taskId isEqualToString:@"Task3"]) {
        task = self.model.task3;
    }

    if (!task || task.completed == YES) {
        return;
    }

    NSError *error;
    if (![self.model completeTask:task error:&error]) {
        NSLog(@"%@", [error localizedDescription]);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Eh..."
                                                        message:[error localizedDescription]
                                                       delegate:nil
                                              cancelButtonTitle:@"Fine"
                                              otherButtonTitles:nil];
        [alert show];
    }

    [self refreshTasksToday];
}

// Refresh tasks display after unwind from task selection
- (IBAction)setNewTaskForTaday:(UIStoryboardSegue *)segue {
    [self refreshTasksToday];
}

@end

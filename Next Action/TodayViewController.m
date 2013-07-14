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
#import <QuartzCore/QuartzCore.h>

@interface TodayViewController ()

@property (strong, nonatomic, readonly) Task *model;

@end

@implementation TodayViewController

+ (UIColor *)redColor
{
    return [UIColor colorWithRed: 252/255.0 green:  47/255.0 blue: 106/255.0 alpha: 1];
}

+ (UIColor *)yellowColor
{
    return [UIColor colorWithRed: 254/255.0 green: 203/255.0 blue:  46/255.0 alpha: 1];
}

+ (UIColor *)blueColor
{
    return [UIColor colorWithRed:  42/255.0 green: 174/255.0 blue: 245/255.0 alpha: 1];
}

+ (UIColor *)greenColor
{
    return [UIColor colorWithRed:104/255.0 green:216/255.0 blue:68/255.0 alpha:1];
}

+ (NSArray *)basicColors
{
    return @[[[self class] redColor], [[self class] yellowColor], [[self class] blueColor]];
}

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

    [self refreshTasksToday];
}

- (void)refreshTasksToday
{
    for (NSInteger i=0; i<3; i++) {

        UILabel *label = (UILabel*)[self.view viewWithTag:i];
        EKReminder *task = self.model.todayTasks[i];

        if ((id)task == [NSNull null]) {
            continue;
        }

        label.text = task.title;

        if (task.isCompleted) {
            label.backgroundColor = [[self class] greenColor]; // Green
        } else {
            label.backgroundColor = [[self class] basicColors][label.tag];
        }
    }
}

- (void)eventStoreChanged:(NSNotification *)notification
{
    [self refreshTasksToday];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ToTaskTable"]) {
        TaskTableViewController *tvc = segue.destinationViewController;
        tvc.currentTaskTag = ((UITapGestureRecognizer *)sender).view.tag;
    }
}

- (IBAction)selectTask:(UITapGestureRecognizer *)sender
{
    if ([self.model canTaskBeChangedForIndex:sender.view.tag]) {
        [self performSegueWithIdentifier:@"ToTaskTable" sender:sender];
    }
}

- (IBAction)markCompleted:(UISwipeGestureRecognizer *)sender
{
    UILabel *label = (UILabel *)sender.view;
    EKReminder *task = self.model.todayTasks[label.tag];

    if ((id)task == [NSNull null]) {
        return;
    }

    UIColor *originalColor, *finalColor;
    originalColor = label.backgroundColor;

    if (sender.direction == UISwipeGestureRecognizerDirectionRight && !task.isCompleted) {
        finalColor = [[self class] greenColor];
    } else if (sender.direction == UISwipeGestureRecognizerDirectionLeft && task.isCompleted) {
        finalColor = [[self class] basicColors][label.tag];
    } else {
        return;
    }

    CGColorRef currentCGColor = label.backgroundColor.CGColor;
    label.backgroundColor = nil;
    label.layer.backgroundColor = currentCGColor;
    [UIView animateWithDuration:0.5 animations:^{
        label.layer.backgroundColor = finalColor.CGColor;
    } completion:^(BOOL finished){
        if (finished) {
            label.backgroundColor = finalColor;
            
            //TODO: write to the store
            task.completed = !task.isCompleted;
            //    NSError *error;
            //    if (![self.model markTask:task as:isCompleted error:&error]) {
            //        NSLog(@"%@", [error localizedDescription]);
            //        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Eh..."
            //                                                        message:[error localizedDescription]
            //                                                       delegate:nil
            //                                              cancelButtonTitle:@"Fine"
            //                                              otherButtonTitles:nil];
            //        [alert show];
            //    }
        }
    }];
}

// Refresh tasks display after unwind from task selection
- (IBAction)setNewTaskForToday:(UIStoryboardSegue *)segue {
    [self refreshTasksToday];
}

- (IBAction)pan:(UIPanGestureRecognizer *)sender {
    UILabel *label = (UILabel *)sender.view;

    //Get the task
    EKReminder *task = self.model.todayTasks[label.tag];
    if ((id)task == [NSNull null]) {
        return;
    }

    CGFloat ratio = fabs([sender translationInView:label].x / 320);

    NSLog(@"%f", ratio);

    //Get the original color & the final color for the task background
    static UIColor *originalColor, *finalColor;

    if (sender.state == UIGestureRecognizerStateBegan) {
        originalColor = label.backgroundColor;

        if (task.isCompleted) {
            finalColor = [[self class] basicColors][label.tag];
        } else {
            finalColor = [[self class] greenColor];
        }
    }

    if (sender.state == UIGestureRecognizerStateBegan || sender.state == UIGestureRecognizerStateChanged) {
        if (   ( task.isCompleted && [sender translationInView:label].x > 0)
            || (!task.isCompleted && [sender translationInView:label].x < 0) ) {
            CGPoint newTranslation = {.x=0, .y=0};
            [sender setTranslation:newTranslation inView:label];
            return;
        }

        CGFloat originalRed, originalGreen, originalBlue, finalRed, finalGreen, finalBlue;

        [originalColor getRed:&originalRed green:&originalGreen blue:&originalBlue alpha:nil];
        [finalColor getRed:&finalRed green:&finalGreen blue:&finalBlue alpha:nil];

        label.backgroundColor = [UIColor colorWithRed:originalRed   + ratio * (finalRed   - originalRed  )
                                                green:originalGreen + ratio * (finalGreen - originalGreen)
                                                 blue:originalBlue  + ratio * (finalBlue  - originalBlue )
                                                alpha:1];
    } else if (sender.state == UIGestureRecognizerStateEnded) {

        CGColorRef currentCGColor = label.backgroundColor.CGColor;
        label.backgroundColor = nil;
        label.layer.backgroundColor = currentCGColor;

        if (ratio >= 0.5) {
            [UIView animateWithDuration:0.2 animations:^{
                label.layer.backgroundColor = finalColor.CGColor;
            } completion:^(BOOL finished){
                if (finished) {
                    //TODO: write to the store
                    task.completed = !task.isCompleted;
                    label.backgroundColor = finalColor;
                }
            }];
        } else {
            [UIView animateWithDuration:0.2 animations:^{
                label.layer.backgroundColor = originalColor.CGColor;
            } completion:^(BOOL finished){
                if (finished) {
                    label.backgroundColor = originalColor;
                }
            }];
        }
    }
}
@end

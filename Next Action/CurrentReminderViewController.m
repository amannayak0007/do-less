//
//  CurrentReminderController.m
//  Next Action
//
//  Created by Roc on 13-4-30.
//  Copyright (c) 2013年 Roc. All rights reserved.
//

#import "CurrentReminderViewController.h"

@interface CurrentReminderViewController ()
@property (weak, nonatomic) IBOutlet UILabel *mission;
@property (strong, nonatomic, readonly) Action *model;
//@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *rightSwipeRecognizer;
@end

@implementation CurrentReminderViewController

- (Action *)model
{
    return [Action sharedInstance];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.mission.text = self.model.currentAction.title;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(eventStoreChanged:)
                                                 name:EKEventStoreChangedNotification
                                               object:self.model.eventStore];

}

- (void)eventStoreChanged:(NSNotification *)notification
{
    self.model.currentAction = (EKReminder *)[self.model.eventStore calendarItemWithIdentifier:self.model.currentAction.calendarItemIdentifier];

    if (self.model.currentAction && self.model.currentAction.completed == NO) {
        self.mission.text = self.model.currentAction.title;
    } else {
        [self dismissViewControllerAnimated:YES completion:^{}];
    }
}

// TODO: Don't use modal segue to switch back and forth.
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"toAccomplished"]) {

    } else if ([segue.identifier isEqualToString:@"toCongratulation"]) {

    }
}

// TODO: Handle error;
- (IBAction)markReminderCompleted:(UISwipeGestureRecognizer *)sender {
    self.model.currentAction.completed = YES;

    NSError *error;
    if (![self.model.eventStore saveReminder:self.model.currentAction
                                      commit:YES
                                       error:&error]) {
       // Handle the error
    }

    if (++self.model.actionCount == self.model.actionGoal) {
        [self performSegueWithIdentifier:@"toCongratulation" sender:self];
    } else {
        [self performSegueWithIdentifier:@"toAccomplished" sender:self];
    }
}

@end

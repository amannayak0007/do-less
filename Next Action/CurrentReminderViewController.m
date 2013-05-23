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

    self.mission.text = self.currentReminder.title;
    //[self.mission addGestureRecognizer:self.rightSwipeRecognizer];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"toAccomplished"]) {

    } else if ([segue.identifier isEqualToString:@"toCongratulation"]) {

    }
}

// TODO: Handle error;
- (IBAction)markReminderCompleted:(UISwipeGestureRecognizer *)sender {
    self.currentReminder.completed = YES;

    NSError *error;
    if (![self.model.eventStore saveReminder:self.currentReminder
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

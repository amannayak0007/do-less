//
//  AwardSetViewController.m
//  Next Action
//
//  Created by Roc on 13-5-14.
//  Copyright (c) 2013年 Roc. All rights reserved.
//

#import "AwardSettingViewController.h"
#import "Action.h"

@interface AwardSettingViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *awardField;
@property (weak, nonatomic) IBOutlet UILabel *actionNeedLabel;
@property (strong, nonatomic, readonly) Action *model;
@property (weak, nonatomic) IBOutlet UIStepper *stepper;
@end

@implementation AwardSettingViewController

- (Action *)model
{
    return [Action sharedInstance];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.awardField.delegate = self;
    self.awardField.text = self.model.award;
    self.actionNeedLabel.text = [NSString stringWithFormat:@"%d", self.model.actionGoal];
    self.stepper.value = self.model.actionGoal;
}

- (IBAction)actionNeedChange:(UIStepper *)sender {
    NSNumber *actionNeed = [NSNumber numberWithDouble:sender.value];

    self.model.actionGoal = [actionNeed unsignedIntegerValue];
    self.actionNeedLabel.text = [NSString stringWithFormat:@"%d", self.model.actionGoal];
}

- (IBAction)awardChange:(UITextField *)sender {
    self.model.award = sender.text;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)unwindToSetNewGoal:(UIStoryboardSegue *)segue {
    self.model.actionCount = 0;
}
@end

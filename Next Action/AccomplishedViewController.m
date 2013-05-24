//
//  AccomplishedViewController.m
//  Next Action
//
//  Created by Roc on 13-5-17.
//  Copyright (c) 2013年 Roc. All rights reserved.
//

#import "AccomplishedViewController.h"
#import "Action.h"

@interface AccomplishedViewController () <UIAlertViewDelegate>
@property (strong, nonatomic, readonly) Action *model;
@property (weak, nonatomic) IBOutlet UILabel *accomplishedLabel;
@end

@implementation AccomplishedViewController

- (Action *)model
{
    return [Action sharedInstance];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSMutableAttributedString *statString = [[NSMutableAttributedString alloc]
         initWithString:[NSString stringWithFormat:@"%d", self.model.actionCount]
             attributes:@{
                  NSFontAttributeName : [UIFont fontWithName:@"Helvetica" size:30],
                  NSForegroundColorAttributeName: [UIColor redColor]
    }];

    NSAttributedString *need = [[NSAttributedString alloc]
         initWithString:[NSString stringWithFormat:@"/%d", self.model.actionGoal]
             attributes:@{
                  NSFontAttributeName : [UIFont fontWithName:@"Helvetica" size:30],
                  NSForegroundColorAttributeName: [UIColor whiteColor]
    }];

    [statString appendAttributedString:need];

    self.accomplishedLabel.attributedText = statString;
}

- (IBAction)changeGoal:(UIButton *)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"修改奖励"
                                                    message:@"修改奖励将清空现有进度，继续吗？"
                                                   delegate:self
                                          cancelButtonTitle:@"取消"
                                          otherButtonTitles:@"继续", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self performSegueWithIdentifier:@"SetNewGoal" sender:self];
    }
}

@end
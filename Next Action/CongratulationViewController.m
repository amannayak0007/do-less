//
//  CongratulationViewController.m
//  Next Action
//
//  Created by Roc on 13-5-17.
//  Copyright (c) 2013年 Roc. All rights reserved.
//

#import "CongratulationViewController.h"
#import "Action.h"

@interface CongratulationViewController ()
@property (weak, nonatomic) IBOutlet UILabel *awardLabel;
@property (strong, nonatomic, readonly) Action *model;
@end

@implementation CongratulationViewController

- (Action *)model
{
    return [Action sharedInstance];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    self.awardLabel.text = self.model.award;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

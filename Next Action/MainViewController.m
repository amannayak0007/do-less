//
//  MainViewController.m
//  Next Action
//
//  Created by Roc on 13-4-30.
//  Copyright (c) 2013年 Roc. All rights reserved.
//

#import "MainViewController.h"
#import <EventKit/EventKit.h>
#import <AudioToolbox/AudioServices.h>
#import <dispatch/dispatch.h>


// Micro seconds to self destruct
#define COUNTDOWN_FROM   500
#define COUNTDOWN_PERIOD 0.01

@interface MainViewController ()

@property (weak, nonatomic) IBOutlet UILabel *mission;
@property (weak, nonatomic) IBOutlet UILabel *note;
@property (weak, nonatomic) IBOutlet UILabel *due;
@property (weak, nonatomic) IBOutlet UILabel *countdown;

@property (weak, nonatomic) IBOutlet UILabel *nextActionPromopt;
@property (weak, nonatomic) IBOutlet UILabel *notePromopt;
@property (weak, nonatomic) IBOutlet UILabel *duePromopt;

@property (strong, nonatomic) EKEventStore *eventStore;
@property (strong, nonatomic) NSArray *reminders;
@property (strong, nonatomic) EKReminder *nextAction;
@property (strong, nonatomic, readonly) EKReminder *newAction;
@property (strong, nonatomic) NSTimer *timer;

@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Get user's reminders
    self.eventStore = [[EKEventStore alloc] init];
    [self.eventStore requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError *error) {
        if (granted && !error) {
            
            // Register the event store changed notification
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(eventStoreChanged:)
                                                         name:EKEventStoreChangedNotification
                                                       object:self.eventStore];
            
            [self refreshReminders];
        } else if (!granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.mission.text = @"Please grant access your reminders in the Setting App.";
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.mission.text = [error localizedDescription];
            });
        }
    }];
}

- (void)setReminders:(NSArray *)reminders
{
    _reminders = reminders;
    
    if (self.nextAction) {
        self.nextAction = (EKReminder *)[self.eventStore calendarItemWithIdentifier:self.nextAction.calendarItemIdentifier];
    }
    
    if (!self.nextAction) {
        self.nextAction = self.newAction;
    }
}

- (EKReminder *)newAction
{
    return [self.reminders objectAtIndex: arc4random() % [self.reminders count] ];
}

- (void)setNextAction:(EKReminder *)nextAction
{
    _nextAction = nextAction;
    
    self.mission.text = _nextAction.title;
    
    self.note.text = _nextAction.notes;
    
    if (_nextAction.dueDateComponents) {
        self.due.text = [NSString stringWithFormat:@"%04d-%02d-%02d %02d:%02d:%02d",
                         _nextAction.dueDateComponents.year,
                         _nextAction.dueDateComponents.month,
                         _nextAction.dueDateComponents.day,
                         _nextAction.dueDateComponents.hour,
                         _nextAction.dueDateComponents.minute,
                         _nextAction.dueDateComponents.second];
    } else {
        self.due.text = @"";
    }
}

#pragma mark - Flipside View

- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showAlternate"]) {
        [[segue destinationViewController] setDelegate:self];
    }
}

/*
[self.timer invalidate];
self.timer = [NSTimer scheduledTimerWithTimeInterval:COUNTDOWN_PERIOD
                                              target:self
                                            selector:@selector(countdownWithTimer:)
                                            userInfo:nil
                                             repeats:YES];
 */
- (void)countdownWithTimer:(NSTimer *)timer
{
    static NSInteger count = COUNTDOWN_FROM;
    
    self.countdown.text = [NSString stringWithFormat:@"%02d:%02d", count/100, count%100];
    
    if (count-- == 0) {
        [timer invalidate];
        count = COUNTDOWN_FROM;
        
        // Make the device viberate
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
}

#pragma mark - Shake motion

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [self becomeFirstResponder];
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (motion == UIEventSubtypeMotionShake)
    {
        self.nextAction = self.newAction;
    }
}

#pragma mark -

- (void)eventStoreChanged:(NSNotification *)notification
{
    if (self.eventStore) {
        [self refreshReminders];
    }
}

- (void)refreshReminders
{
    NSPredicate *predicate = [self.eventStore predicateForIncompleteRemindersWithDueDateStarting:nil ending:nil calendars:nil];
    
    [self.eventStore fetchRemindersMatchingPredicate:predicate completion:^(NSArray *reminders) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.reminders = reminders;
        });
    }];
}

@end

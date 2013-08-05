//
//  TaskCell.m
//  tasklabel
//
//  Created by Roc on 13-7-17.
//  Copyright (c) 2013年 Roc. All rights reserved.
//

#import "TaskCell.h"
#include <AudioToolbox/AudioToolbox.h>

#define ANIMATION_TIME 0.3

@interface TaskCell()

@property (strong, nonatomic) UIImageView *stamp;
@property (nonatomic)  SystemSoundID stampingSound;

@end

@implementation TaskCell

- (UIImageView *)stamp
{
    if (!_stamp) {
        _stamp = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Stamp.png"]];
        _stamp.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin
                                 |UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
        [self addSubview:_stamp];
    }
    return _stamp;
}

- (SystemSoundID)stampingSound
{
    if (!_stampingSound) {
        // Get the main bundle for the app
        CFBundleRef mainBundle = CFBundleGetMainBundle();

        // Get the URL to the sound file to play.
        CFURLRef soundFileURLRef  = CFBundleCopyResourceURL(mainBundle, CFSTR("Stamp"), CFSTR("wav"), NULL);

        // Create a system sound object representing the sound file
        AudioServicesCreateSystemSoundID(soundFileURLRef, &_stampingSound);
    }

    return _stampingSound;
}

- (void)setCompleted:(BOOL)completed animated:(BOOL)animated
{
    if (!animated) {
        self.completed = completed;
        return;
    }

    if (completed) {
        [UIView animateWithDuration:ANIMATION_TIME
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.stamp.alpha = 1.0;
                             self.stamp.transform = CGAffineTransformIdentity;
                             self.stamp.center = CGPointMake(self.bounds.size.width/3, self.bounds.size.height/2);
                         }
                         completion:^(BOOL finish){}
         ];

        AudioServicesPlaySystemSound(self.stampingSound);
    } else {
        [UIView animateWithDuration:ANIMATION_TIME
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.stamp.alpha = 0.0;
                             self.stamp.transform = CGAffineTransformMakeScale(1.5, 1.5);
                         }
                         completion:^(BOOL finish){}
         ];
    }

    _completed = completed;
}

- (void)setCompleted:(BOOL)completed
{
    if (completed) {
        self.stamp.alpha = 1.0;
        self.stamp.transform = CGAffineTransformIdentity;
        self.stamp.center = CGPointMake(self.bounds.size.width/3, self.bounds.size.height/2);
    } else {
        self.stamp.alpha = 0.0;
        self.stamp.transform = CGAffineTransformMakeScale(1.5, 1.5);
    }

    _completed = completed;
}
@end

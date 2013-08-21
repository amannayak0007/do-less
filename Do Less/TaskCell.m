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

+ (CGPoint)defaultStampCoordinate
{
    return CGPointMake(0.333, 0.333);
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];

    if (self) {
        [self.contentView addSubview:self.stamp];
    }

    return self;
}

- (UIImageView *)stamp
{
    if (!_stamp) {
        _stamp = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Stamp.png"]];
        [_stamp setTranslatesAutoresizingMaskIntoConstraints:NO];
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

        CFRelease(soundFileURLRef);
    }

    return _stampingSound;
}

- (void)updateStampConstrainsWithCGPoint:(CGPoint)point
{
    [self.contentView removeConstraints:self.contentView.constraints];
    [self.contentView addConstraints:@[
        [NSLayoutConstraint constraintWithItem:self.stamp
                                     attribute:NSLayoutAttributeCenterX
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.contentView
                                     attribute:NSLayoutAttributeCenterX
                                    multiplier:2*point.x
                                      constant:0],
        [NSLayoutConstraint constraintWithItem:self.stamp
                                     attribute:NSLayoutAttributeCenterY
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.contentView
                                     attribute:NSLayoutAttributeCenterY
                                    multiplier:2*point.y
                                      constant:0]
     ]];
}

- (void)setCompleted:(BOOL)completed atRelativePoint:(CGPoint)point animated:(BOOL)animated;
{
    _completed = completed;
    [self.contentView bringSubviewToFront:self.stamp];

    if (_completed) {
        [self updateStampConstrainsWithCGPoint:point];
    }

    if (_completed && animated) {
        AudioServicesPlaySystemSound(self.stampingSound);
    }

    if (animated) {
        [UIView animateWithDuration:ANIMATION_TIME
                              delay:0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.stamp.alpha = _completed ? 1 : 0;
                             self.stamp.transform = _completed ? CGAffineTransformIdentity : CGAffineTransformMakeScale(1.5, 1.5);
                         }
                         completion:^(BOOL finish){}
         ];
    } else {
        self.stamp.alpha = _completed ? 1.0 : 0.0;
        self.stamp.transform = _completed ? CGAffineTransformIdentity : CGAffineTransformMakeScale(1.5, 1.5);
    }
}

- (void)setCompleted:(BOOL)completed animated:(BOOL)animated
{
    [self setCompleted:completed
       atRelativePoint:[[self class] defaultStampCoordinate]
              animated:animated];
}

- (void)setCompleted:(BOOL)completed
{
    [self setCompleted:completed
              animated:NO];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}
@end

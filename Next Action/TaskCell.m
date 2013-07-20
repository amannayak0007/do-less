//
//  TaskCell.m
//  tasklabel
//
//  Created by Roc on 13-7-17.
//  Copyright (c) 2013年 Roc. All rights reserved.
//

#import "TaskCell.h"

#define DELETING_LINE_WIDTH 2

@interface TaskCell()
@property (strong, nonatomic) UIImageView *stamp;
@end

@implementation TaskCell

- (UIImageView *)stamp
{
    if (!_stamp) {
        _stamp = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Stamp.png"]];
        _stamp.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        [self addSubview:_stamp];
    }
    return _stamp;
}

- (void)setCompleted:(BOOL)completed animated:(BOOL)animated
{
    if (!animated) {
        self.completed = completed;
        return;
    }

    if (completed) {
        [UIView animateWithDuration:0.5 animations:^{
            // TODO: Be responsive
            self.stamp.alpha = 1.0;
            self.stamp.transform = CGAffineTransformIdentity;
            self.stamp.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
        }];
    } else {
        [UIView animateWithDuration:0.5 animations:^{
            self.stamp.alpha = 0.0;
            self.stamp.transform = CGAffineTransformMakeScale(1.5, 1.5);
        }];
    }

    _completed = completed;
}

- (void)setCompleted:(BOOL)completed
{
    if (completed) {
        self.stamp.alpha = 1.0;
        self.stamp.transform = CGAffineTransformIdentity;
        self.stamp.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    } else {
        self.stamp.alpha = 0.0;
        self.stamp.transform = CGAffineTransformMakeScale(1.5, 1.5);
    }

    _completed = completed;
}
@end

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
@property (strong, nonatomic) CALayer *delettingLayer;
@end

@implementation TaskCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(CALayer *)delettingLayer
{
    if (!_delettingLayer) {
        _delettingLayer = [[CALayer alloc] init];

        _delettingLayer.anchorPoint = (CGPoint){0, 0.5};
        _delettingLayer.backgroundColor = self.textLabel.textColor.CGColor;

        [self.textLabel.layer addSublayer:_delettingLayer];
    }

    return _delettingLayer;
}

- (void)setCompleted:(BOOL)completed
{
    CABasicAnimation *deletingAnimation = [CABasicAnimation animationWithKeyPath:@"bounds"];
    deletingAnimation.duration = 0.5;
    deletingAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];

    CGRect empty = {
        .origin = self.textLabel.layer.bounds.origin,
        .size = (CGSize) {
            .width = 0,
            .height = DELETING_LINE_WIDTH,
        }
    };
    CGRect full = {
        .origin = self.textLabel.layer.bounds.origin,
        .size = (CGSize) {
            .width = self.textLabel.layer.bounds.size.width,
            .height = DELETING_LINE_WIDTH,
        }
    };

    if (completed) {
        deletingAnimation.fromValue = [NSValue valueWithCGRect:empty];
        deletingAnimation.toValue = [NSValue valueWithCGRect:full];

        self.delettingLayer.bounds = full;
    } else {
        deletingAnimation.fromValue = [NSValue valueWithCGRect:full];
        deletingAnimation.toValue = [NSValue valueWithCGRect:empty];

        self.delettingLayer.bounds = empty;
    }

    self.delettingLayer.position = (CGPoint){0, self.textLabel.layer.bounds.size.height/2};
    [self.delettingLayer addAnimation:deletingAnimation forKey:nil];

//    [UIView animateWithDuration:0.5
//                          delay:0
//                        options:UIViewAnimationOptionCurveEaseInOut
//                     animations:^{
//                         if (completed) {
//                             self.contentView.backgroundColor = [UIColor greenColor];
//                         } else {
//                             self.contentView.backgroundColor = [UIColor redColor];
//                         }
//                     }
//                     completion:^(BOOL finished){
//                     }
//     ];

    _completed = completed;
}
@end

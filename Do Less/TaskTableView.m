//
//  TaskTableView.m
//  Do Less
//
//  Created by Roc on 13-8-10.
//  Copyright (c) 2013年 Roc. All rights reserved.
//

#import "TaskTableView.h"
#import "Common.h"

@interface TaskTableView ()
@property (strong, nonatomic) UILabel *outerHeaderView;
@end

@implementation TaskTableView

- (UILabel*)outerHeaderView
{
    if (!_outerHeaderView) {
        _outerHeaderView = [[UILabel alloc] init];
        _outerHeaderView.textColor = [UIColor grayColor];
        _outerHeaderView.textAlignment = NSTextAlignmentCenter;
    }
    return _outerHeaderView;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];

    if (self) {
        [self addSubview: self.outerHeaderView];
    }

    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    if (self.bounds.size.width > self.bounds.size.height) {
        self.outerHeaderView.text = NSLocalizedString(@"You don't find time for important things, you make it.", @"Quote 1");
    } else {
        self.outerHeaderView.text = NSLocalizedString(@"Do the ugliest thing first.", @"Quote 2");
    }

    self.outerHeaderView.bounds = CGRectMake(0, 0, self.bounds.size.width, 20);
    self.outerHeaderView.center = CGPointMake(self.bounds.size.width/2, -20);
}
@end

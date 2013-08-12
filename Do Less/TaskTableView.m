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
@property (strong, nonatomic) UIImageView *outerHeaderView;
@end

@implementation TaskTableView

- (UIImageView*)outerHeaderView
{
    if (!_outerHeaderView) {
        _outerHeaderView = [[UIImageView alloc] init];
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

    NSMutableString *imageFileName = [@"WoodTextureBg-Top" mutableCopy];

    if (self.bounds.size.width > self.bounds.size.height) {
        [imageFileName appendString:@"-Landscape"];
    } else {
        [imageFileName appendString:@"-Portrait"];
    }

    self.outerHeaderView.image = [UIImage imageNamed:imageFileName];
    [self.outerHeaderView sizeToFit];
    self.outerHeaderView.center = CGPointMake(self.bounds.size.width/2, -self.outerHeaderView.image.size.height/2);
}
@end

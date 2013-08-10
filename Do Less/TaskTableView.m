//
//  TaskTableView.m
//  Do Less
//
//  Created by Roc on 13-8-10.
//  Copyright (c) 2013年 Roc. All rights reserved.
//

#import "TaskTableView.h"
#import "Utility.h"

@interface TaskTableView ()
@property (strong, nonatomic) UIImageView *outerHeaderView;
@property (strong, nonatomic) UIImageView *outerFooterView;
@property (strong, nonatomic) UIImageView *paddingView;
@end

@implementation TaskTableView

- (UIImageView*)outerHeaderView
{
    if (!_outerHeaderView) {
        _outerHeaderView = [[UIImageView alloc] init];
    }
    return _outerHeaderView;
}

- (UIImageView *)outerFooterView
{
    if (!_outerFooterView) {
        _outerFooterView = [[UIImageView alloc] init];
    }
    return _outerFooterView;
}

- (UIImageView *)paddingView
{
    if (!_paddingView) {
        _paddingView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"ListPageBg"]resizableImageWithCapInsets:UIEdgeInsetsZero]];
    }
    return _paddingView;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];

    self.tableHeaderView = [[UIView alloc] init];
    self.tableFooterView = [[UIView alloc] init];

    [self.tableHeaderView addSubview: self.outerHeaderView];
    [self.tableFooterView addSubview: self.paddingView];
    [self.tableFooterView addSubview: self.outerFooterView];

    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    NSMutableString *imageFileName = [@"WoodTextureBg" mutableCopy];
    NSString *topImageFilename;
    NSString *bottomImageFilename;

    if (self.bounds.size.width > self.bounds.size.height) {
        [imageFileName appendFormat:@"-Landscape"];
    } else {
        [imageFileName appendFormat:@"-Portrait"];
    }

    topImageFilename = [imageFileName stringByAppendingString:@"-Top"];
    bottomImageFilename = [imageFileName stringByAppendingString:@"-Bottom"];

    if (IS_WIDESCREEN && self.bounds.size.width > self.bounds.size.height) {
        topImageFilename = [topImageFilename stringByAppendingString:@"-568h"];
        bottomImageFilename = [bottomImageFilename stringByAppendingString:@"-568h"];
    }

    self.outerHeaderView.image = [UIImage imageNamed:topImageFilename];
    self.outerHeaderView.frame = CGRectMake(0, -self.outerHeaderView.image.size.height, self.outerHeaderView.image.size.width, self.outerHeaderView.image.size.height);

    CGFloat padding = self.contentSize.height >= self.bounds.size.height ? 0 : self.bounds.size.height-self.contentSize.height;
    self.paddingView.frame = CGRectMake(0, 0, self.bounds.size.width, padding);

    self.outerFooterView.image = [UIImage imageNamed:bottomImageFilename];
    self.outerFooterView.frame = CGRectMake(0, padding, self.outerFooterView.image.size.width, self.outerFooterView.image.size.height);
}
@end

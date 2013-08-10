//
//  Utility.h
//  Do Less
//
//  Created by Roc on 13-8-6.
//  Copyright (c) 2013年 Roc. All rights reserved.
//

#import <Foundation/Foundation.h>

#define IS_WIDESCREEN (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone && [UIScreen mainScreen].bounds.size.height==568)

@interface Utility : NSObject
+ (void)alert:(NSString *)msg;
@end

//
//  BaseViewController.m
//  TestSocialNetwork
//
//  Created by Roman on 6/2/15.
//  Copyright (c) 2015 Roman. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end


@implementation BaseTableViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
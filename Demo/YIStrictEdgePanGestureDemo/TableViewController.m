//
//  TableViewController.m
//  YIStrictEdgePanGestureDemo
//
//  Created by Yasuhiro Inami on 2014/03/15.
//  Copyright (c) 2014年 Yasuhiro Inami. All rights reserved.
//

#import "TableViewController.h"

@interface TableViewController ()

@property (strong, nonatomic) IBOutlet UIView *tutorialView;

@end

@implementation TableViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.navigationController.viewControllers.count > 1) {
        self.tutorialView.hidden = NO;
    }
    else {
        self.tutorialView.hidden = YES;
    }
}

@end

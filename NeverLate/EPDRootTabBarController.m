//
//  EPDRootTabBarController.m
//  NeverLate
//
//  Created by Endika Gutiérrez Salas on 4/14/12.
//  Copyright (c) 2012 EPD. All rights reserved.
//

#import "EPDRootTabBarController.h"

#import "EPDMenuViewController.h"
#import "ECSlidingViewController.h"

@interface EPDRootTabBarController ()

@end

@implementation EPDRootTabBarController


- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // shadowPath, shadowOffset, and rotation is handled by ECSlidingViewController.
    // You just need to set the opacity, radius, and color.
    self.view.layer.shadowOpacity = 0.75f;
    self.view.layer.shadowRadius = 10.0f;
    self.view.layer.shadowColor = [UIColor blackColor].CGColor;
    
    self.slidingViewController.anchorRightRevealAmount = 70.0f;
    self.slidingViewController.underRightWidthLayout = ECFullWidth;

    [self.view addGestureRecognizer:self.slidingViewController.panGesture];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end

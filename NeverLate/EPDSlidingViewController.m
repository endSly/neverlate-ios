//
//  EPDInitialViewController.m
//  NeverLate
//
//  Created by Endika Gutiérrez Salas on 4/14/12.
//  Copyright (c) 2012 EPD. All rights reserved.
//

#import "EPDSlidingViewController.h"

#import "EPDMenuViewController.h"

@interface EPDSlidingViewController ()

@end

@implementation EPDSlidingViewController

@synthesize objectManager;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (EPDMenuViewController *)menuController
{
    if ([self.underLeftViewController isKindOfClass:[EPDMenuViewController class]]) {
        return (EPDMenuViewController *) self.underLeftViewController;
    }
    return nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end

//
//  EPDMenuViewController.m
//  NeverLate
//
//  Created by Endika Gutiérrez Salas on 4/14/12.
//  Copyright (c) 2012 EPD. All rights reserved.
//

#import "EPDMenuViewController.h"

#import "ECSlidingViewController.h"

@interface EPDMenuViewController ()

@end

@implementation EPDMenuViewController

@synthesize navigationBar = _navigationBar;
@synthesize tableView = _tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    [self.navigationBar setBackgroundImage:[UIImage imageNamed:@"MenuNavBar.png"] forBarMetrics:UIBarMetricsDefault];
    
    self.tableView.backgroundColor = [UIColor colorWithRed:0xc0/255.0 green:0xc0/255.0 blue:0xc0/255.0 alpha:1];
    
    self.slidingViewController.anchorRightRevealAmount = 72.0f;
    self.slidingViewController.underRightWidthLayout = ECFullWidth;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        
        cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cell-bg"]];
        
    }
    
    return cell;
}

@end

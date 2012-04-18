//
//  EPDMenuViewController.m
//  NeverLate
//
//  Created by Endika Gutiérrez Salas on 4/14/12.
//  Copyright (c) 2012 EPD. All rights reserved.
//

#import "EPDMenuViewController.h"
#import "EPDRootTabBarController.h"
#import "EPDObjectManager.h"
#import "EPDSlidingViewController.h"
#import "ECSlidingViewController.h"

@interface EPDMenuViewController ()

@end

@implementation EPDMenuViewController

@synthesize selectedIndex = _selectedIndex;
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
    
    self.view.backgroundColor = [UIColor colorWithRed:0xc0/255.0 green:0xc0/255.0 blue:0xc0/255.0 alpha:1];
    self.tableView.backgroundColor = [UIColor clearColor];
    
    self.slidingViewController.anchorRightRevealAmount = 224.0f;
    self.slidingViewController.underRightWidthLayout = ECFullWidth;
    
    self.navigationBar.layer.shadowRadius = 4.0;
    self.navigationBar.layer.shadowColor = [[UIColor darkGrayColor] CGColor];
    self.navigationBar.layer.masksToBounds = NO;
    self.navigationBar.layer.shouldRasterize = YES;
    self.navigationBar.layer.shadowOpacity = 0.5;
    self.navigationBar.layer.shadowOffset = CGSizeMake(0,4);
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
    return 70.0f;
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
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.8];
        cell.textLabel.shadowColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.7];
        cell.textLabel.shadowOffset = CGSizeMake(0, -1.0);
    }
    
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"Metro Bilbao";
            cell.imageView.image = [UIImage imageNamed:(_selectedIndex == 0 ? @"MetroBilbaoSelected" : @"MetroBilbao")];
            break;
            
        case 1:
            cell.textLabel.text = @"Tranvía Bilbao";
            cell.imageView.image = [UIImage imageNamed:(_selectedIndex == 1 ? @"TranviaBilbaoSelected" : @"TranviaBilbao")];
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (_selectedIndex == indexPath.row) {
        [self.slidingViewController resetTopView];
        return;
    }
    
    _selectedIndex = indexPath.row;
    
    EPDRootTabBarController *rootTabBarController = [self.storyboard instantiateViewControllerWithIdentifier:@"RootTabBar"];
    
    EPDObjectManager *objectManager = [[self class] objectManagerForIndex:indexPath.row];
    
    ((EPDSlidingViewController *) self.slidingViewController).objectManager = objectManager;
    
    [self.slidingViewController anchorTopViewOffScreenTo:ECRight animations:nil onComplete:^{
        [self.tableView reloadData];
        
        CGRect frame = self.slidingViewController.topViewController.view.frame;
        self.slidingViewController.topViewController = rootTabBarController;
        self.slidingViewController.topViewController.view.frame = frame;
        [self.slidingViewController resetTopView];
    }];
}

+ (EPDObjectManager *)objectManagerForIndex:(int)index
{
    EPDObjectManager *objectManager;
    
    switch (index) {
        case 0:
            objectManager = [[EPDObjectManager alloc] initWithDatabasePath:
                             [[NSBundle mainBundle] pathForResource:@"metro-times" 
                                                             ofType:@"sqlite3"]];
            
            objectManager.color = [UIColor redColor];
            objectManager.name = @"Metro Bilbao";
            break;
            
        case 1:
            objectManager = [[EPDObjectManager alloc] initWithDatabasePath:
                             [[NSBundle mainBundle] pathForResource:@"tranvia-times" 
                                                             ofType:@"sqlite3"]];
            objectManager.color = [UIColor colorWithCGColor:[UIColor colorWithRed:102/255.0 green:152/255.0 blue:51/255.0 alpha:1].CGColor];
            objectManager.name = @"Tranvía Bilbao";
            break;
    }
    
    return objectManager;
}

@end

//
//  EPDTimesViewController.m
//  NeverLate
//
//  Created by Endika Gutiérrez Salas on 4/5/12.
//  Copyright (c) 2012 EPD. All rights reserved.
//

#import "EPDTimesViewController.h"

#import "EPDSlidingViewController.h"
#import "EPDStation.h"
#import "EPDTime.h"
#import "CustomNavigationBar.h"

@interface EPDTimesViewController ()

@end

@implementation EPDTimesViewController

@synthesize originStation = _originStation;
@synthesize destinationStation = _destinationStation;
@synthesize date = _date;

- (void)viewDidLoad
{
    [super viewDidLoad];

    [_originStation timeToStation:_destinationStation time:&_travelTime direction:&_direction];

    NSArray *times = [((EPDSlidingViewController *) self.slidingViewController).objectManager timesForStation:_originStation date:_date];
    
    UIButton* backButton = [((CustomNavigationBar *)self.navigationController.navigationBar) backButtonWith:[UIImage imageNamed:@"BarBackButton.png"] highlight:nil leftCapWidth:14.0];
    backButton.titleLabel.textColor = [UIColor colorWithRed:254.0/255.0 green:239.0/255.0 blue:218.0/225.0 alpha:1];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    NSMutableArray *selectedTimes = [NSMutableArray arrayWithCapacity:times.count / 2];
    for (EPDTime *time in times) {
        int t, d;
        [self.originStation timeToStation:time.directionStation time:&t direction:&d];
        if (d == _direction)
            [selectedTimes addObject:time];
    }
    
    _times = selectedTimes;
    
    
    
    self.title = [NSString stringWithFormat:@"%@ - %@", _originStation.name, _destinationStation.name];
    
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _times.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    EPDTime *time = ((EPDTime *) [_times objectAtIndex:indexPath.row]);
    int minutes = time.timeInt;
    int arrivalTime = (minutes + _travelTime) % (24 * 60);
    
    static UIFont *font = nil;
    if (!font)
        font = [UIFont fontWithName:@"AtRotisSemiSans" size:18.0f];
    
    cell.textLabel.text = time.directionStation.name;
    cell.textLabel.font = font;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%i:%02i Llegada: %i:%02i", minutes / 60, minutes % 60, arrivalTime / 60, arrivalTime % 60];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [NSString stringWithFormat:@"%@ a %@ en %i minutos", _originStation.name, _destinationStation.name, _travelTime];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end

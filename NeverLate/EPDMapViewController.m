//
//  EPDSecondViewController.m
//  NeverLate
//
//  Created by Endika Gutiérrez Salas on 3/29/12.
//  Copyright (c) 2012 EPD. All rights reserved.
//

#import "EPDMapViewController.h"

#import <CoreLocation/CoreLocation.h>

#import "EPDStation.h"
#import "EPDStationLocation.h"
#import "EPDStationDetailViewController.h"

@interface EPDStationAnnotation : NSObject <MKAnnotation>

@property (nonatomic, retain) EPDStationLocation *location;

@end

@implementation EPDMapViewController

@synthesize mapView = _mapView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.translucent = YES;
    
    self.mapView.region = (MKCoordinateRegion) {
        .center = {
            .latitude = 43.256944,
            .longitude = -2.923611
        },
        .span = {
            .latitudeDelta = .10f,
            .longitudeDelta = .10f
        }
    };
    
    [EPDStationLocation findAll:^(NSArray *locations) {
        for (EPDStationLocation *location in locations) {
            EPDStationAnnotation *annotation = [[EPDStationAnnotation alloc] init];
            annotation.location = location;
            [self.mapView addAnnotation:annotation];
        }
    }];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


- (void)stationSelected:(UIButton *)sender
{
    NSNumber *stationId = [NSNumber numberWithInt:sender.tag];
    
    _selectedStation = [EPDStation findById:stationId];
    
    [self performSegueWithIdentifier:@"StationDetailSegue" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    EPDStationDetailViewController *detailController = (EPDStationDetailViewController *) segue.destinationViewController;
    detailController.station = _selectedStation;
}

#pragma mark - Map Delegate

- (MKAnnotationView *) mapView:(MKMapView *)map viewForAnnotation:(id <MKAnnotation>)annotation
{
    static NSString *annotationIdentifier = @"MetroIdentifier";
    
    MKAnnotationView *annotationView = [map dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
    if (!annotationView) {
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationIdentifier];
    
        annotationView.image = [UIImage imageNamed:@"metro-annotation"];
        
        annotationView.enabled = YES;
        annotationView.canShowCallout = YES;
    }
    
    UIButton *stationDetailButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    stationDetailButton.tag = ((EPDStationAnnotation *) annotation).location.station_id.intValue;
    [stationDetailButton addTarget:self action:@selector(stationSelected:) forControlEvents:UIControlEventTouchDown];
    annotationView.rightCalloutAccessoryView = stationDetailButton;
    
    return annotationView;
}

@end

@implementation EPDStationAnnotation

@synthesize location = _location;

- (CLLocationCoordinate2D)coordinate
{
    return (CLLocationCoordinate2D) {
        .latitude = _location.lat.floatValue,
        .longitude = _location.lng.floatValue
    };
}

- (NSString *)title
{
    return _location.station.name;
}

- (NSString *)subtitle
{
    return _location.station.joints;
}

@end

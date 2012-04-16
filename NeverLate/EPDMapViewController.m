//
//  EPDSecondViewController.m
//  NeverLate
//
//  Created by Endika Gutiérrez Salas on 3/29/12.
//  Copyright (c) 2012 EPD. All rights reserved.
//

#import "EPDMapViewController.h"

#import <CoreLocation/CoreLocation.h>

#import "EPDSlidingViewController.h"
#import "EPDStation.h"
#import "EPDStationLocation.h"
#import "EPDStationDetailViewController.h"

@interface EPDStationAnnotation : NSObject <MKAnnotation>

@property (nonatomic, retain) EPDStationLocation *location;

@end

@implementation EPDMapViewController

@synthesize mapView = _mapView;
@synthesize stationToShow = _stationToShow;

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationController.navigationBar.tintColor = ((EPDSlidingViewController *) self.slidingViewController).objectManager.color;
    
    CLLocationManager *locationManager = [[CLLocationManager alloc] init];
    
    float minLat = locationManager.location.coordinate.latitude, 
        minLng = locationManager.location.coordinate.longitude, 
        maxLat = minLat, 
        maxLng = minLng;
    
    NSArray *stations;
    
    if (_stationToShow) {
        stations = [NSArray arrayWithObject:_stationToShow];
    } else {
        stations = [((EPDSlidingViewController *) self.slidingViewController).objectManager allStations];
    }
    
    for (EPDStation *station in stations) {
        for (EPDStationLocation *location in station.stationLocations) {
            minLat = MIN(minLat, location.lat.floatValue);
            minLng = MIN(minLng, location.lng.floatValue);
            maxLat = MAX(maxLat, location.lat.floatValue);
            maxLng = MAX(maxLng, location.lng.floatValue);
            
            EPDStationAnnotation *annotation = [[EPDStationAnnotation alloc] init];
            annotation.location = location;
            [self.mapView addAnnotation:annotation];
        }
    }
    
    self.mapView.region = (MKCoordinateRegion) {
        .center = {
            .latitude = (minLat + maxLat) / 2,
            .longitude = (minLng + maxLng) / 2
        },
        .span = {
            .latitudeDelta = maxLat - minLat,
            .longitudeDelta = maxLng - minLng + 0.08f
        }
    };
}

- (void)viewDidAppear:(BOOL)animated
{
    self.navigationController.navigationBar.translucent = YES;
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
    
    _selectedStation = [((EPDSlidingViewController *) self.slidingViewController).objectManager stationWithId:stationId];
    
    [self performSegueWithIdentifier:@"StationDetailSegue" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    EPDStationDetailViewController *detailController = (EPDStationDetailViewController *) segue.destinationViewController;
    detailController.station = _selectedStation;
}

- (IBAction)showUserHeadding:(id)sender
{
    self.mapView.showsUserLocation = YES;
    
    if (!_navigate) {
        [self.mapView setUserTrackingMode:MKUserTrackingModeFollowWithHeading animated:YES];
    } else {
        self.mapView.userTrackingMode = MKUserTrackingModeNone;
    }
    _navigate = !_navigate;
}

#pragma mark - Map Delegate

- (MKAnnotationView *) mapView:(MKMapView *)map viewForAnnotation:(id <MKAnnotation>)annotation
{
    static NSString *annotationIdentifier = @"MetroIdentifier";

    if ([annotation isKindOfClass:[EPDStationAnnotation class]]) {
        MKAnnotationView *annotationView = [map dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
        if (!annotationView) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationIdentifier];
            
            annotationView.image = [UIImage imageNamed:@"metro-annotation"];
            
            annotationView.enabled = YES;
            annotationView.canShowCallout = YES;
        }
        if (!self.stationToShow && [annotation isKindOfClass:[EPDStationAnnotation class]]) {
            UIButton *stationDetailButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            stationDetailButton.tag = ((EPDStationAnnotation *) annotation).location.station_id.intValue;
            [stationDetailButton addTarget:self action:@selector(stationSelected:) forControlEvents:UIControlEventTouchDown];
            annotationView.rightCalloutAccessoryView = stationDetailButton;
        }
        
        return annotationView;

    }
    
    return nil;
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
    return _location.location_name;
}

@end

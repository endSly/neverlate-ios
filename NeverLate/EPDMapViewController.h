//
//  EPDSecondViewController.h
//  NeverLate
//
//  Created by Endika Gutiérrez Salas on 3/29/12.
//  Copyright (c) 2012 EPD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class EPDStation;

@interface EPDMapViewController : UIViewController <MKMapViewDelegate> {
    
    EPDStation *_selectedStation;
}

@property (nonatomic, assign) IBOutlet MKMapView *mapView;

@end

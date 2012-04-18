//
//  EPDBannerController.m
//  NeverLate
//
//  Created by Endika Gutiérrez Salas on 4/18/12.
//  Copyright (c) 2012 EPD. All rights reserved.
//

#import "EPDBannerController.h"

@implementation EPDBannerController

@synthesize bannerView = _bannerView;

+ (EPDBannerController *)sharedBanner
{
    static EPDBannerController *bannerController = nil;
    if (!bannerController)
        bannerController = [[EPDBannerController alloc] init];
    
    return bannerController;
}

- (id)init 
{
    self = [super init];
    if (self) {
        _bannerView = [[GADBannerView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
        _bannerView.adUnitID = @"a14f75833f65366";
        [_bannerView loadRequest:[GADRequest request]];
    }
    return self;
}

@end

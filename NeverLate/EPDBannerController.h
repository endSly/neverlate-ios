//
//  EPDBannerController.h
//  NeverLate
//
//  Created by Endika Gutiérrez Salas on 4/18/12.
//  Copyright (c) 2012 EPD. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GADBannerView.h"

@interface EPDBannerController : NSObject

@property (nonatomic, readonly) GADBannerView * bannerView;

+ (EPDBannerController *)sharedBanner;

@end

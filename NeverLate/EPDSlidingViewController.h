//
//  EPDInitialViewController.h
//  NeverLate
//
//  Created by Endika Gutiérrez Salas on 4/14/12.
//  Copyright (c) 2012 EPD. All rights reserved.
//

#import "ECSlidingViewController.h"

@class EPDObjectManager;
@class EPDMenuViewController;

@interface EPDSlidingViewController : ECSlidingViewController

@property (nonatomic, retain) EPDObjectManager * objectManager;
@property (nonatomic, readonly) EPDMenuViewController * menuController;

@end

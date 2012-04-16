//
//  EPDMenuViewController.h
//  NeverLate
//
//  Created by Endika Gutiérrez Salas on 4/14/12.
//  Copyright (c) 2012 EPD. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EPDObjectManager;

@interface EPDMenuViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) int selectedIndex;

@property (nonatomic, assign) IBOutlet UINavigationBar *navigationBar;
@property (nonatomic, assign) IBOutlet UITableView *tableView;

+ (EPDObjectManager *)objectManagerForIndex:(int)index;

@end

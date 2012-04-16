//
//  EPDMenuViewController.h
//  NeverLate
//
//  Created by Endika Gutiérrez Salas on 4/14/12.
//  Copyright (c) 2012 EPD. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EPDMenuViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    int _selectedIndex;
}

@property (nonatomic, assign) IBOutlet UINavigationBar *navigationBar;
@property (nonatomic, assign) IBOutlet UITableView *tableView;

@end

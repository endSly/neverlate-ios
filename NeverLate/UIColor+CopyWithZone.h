//
//  UIColor+CopyWithZone.h
//  NeverLate
//
//  Created by Endika Gutiérrez Salas on 4/16/12.
//  Copyright (c) 2012 EPD. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (CopyWithZone)

- (id)copyWithZone:(NSZone *)zone;

@end

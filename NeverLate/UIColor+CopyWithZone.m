//
//  UIColor+CopyWithZone.m
//  NeverLate
//
//  Created by Endika Gutiérrez Salas on 4/16/12.
//  Copyright (c) 2012 EPD. All rights reserved.
//

#import "UIColor+CopyWithZone.h"

@implementation UIColor (CopyWithZone)

- (id)copyWithZone:(NSZone *)zone
{
    CGColorRef cgCopy = CGColorCreateCopy(self.CGColor);
    return [[UIColor allocWithZone:zone] initWithCGColor:cgCopy];
}

@end

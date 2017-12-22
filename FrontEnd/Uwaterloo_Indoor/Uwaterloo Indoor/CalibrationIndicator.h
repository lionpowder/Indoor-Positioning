//
//  Header.h
//  Uwaterloo Indoor
//
//  Created by Owner on 2017-10-25.
//  Copyright © 2017 Owner. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <IndoorAtlas/IALocationManager.h>

@class UINavigationItem;

@interface CalibrationIndicator : NSObject
- (id)initWithNavigationItem:(UINavigationItem *)navigationItem andCalibration:(enum ia_calibration)calibration;
- (void)setCalibration:(enum ia_calibration)calibration;
@end

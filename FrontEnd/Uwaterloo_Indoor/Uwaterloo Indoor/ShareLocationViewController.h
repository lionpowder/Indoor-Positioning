//
//  ShareLocationViewController.h
//  Uwaterloo Indoor
//
//  Created by Owner on 2017-10-25.
//  Copyright © 2017 Owner. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "IndoorAtlas/IndoorAtlas.h"
#import <MapKit/MapKit.h>

@interface AppleMapsOverlayViewController : UIViewController
@property (nonatomic, strong) IALocationManager *locationManager;
@property (strong) MKMapView *map;
@end

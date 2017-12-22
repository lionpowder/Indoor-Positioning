//
//  ImageViewController.h
//  Uwaterloo Indoor
//
//  Created by Owner on 2017-10-25.
//  Copyright © 2017 Owner. All rights reserved.
//
//#import <UIKit/UIKit.h>
//
//@interface ImageViewController : UIViewController
//
//@end

#import <UIKit/UIKit.h>
#import "IndoorAtlas/IndoorAtlas.h"
#import <MapKit/MapKit.h>

@interface ImageViewController : UIViewController
@property (nonatomic, strong) IALocationManager *locationManager;
@property (strong) MKMapView *map;
@property (strong, nonatomic) NSString *savedCoords;
@property (strong, nonatomic) NSString *userName;
@property bool login;
@end

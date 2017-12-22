#import <IndoorAtlas/IALocationManager.h>
#import <IndoorAtlas/IAResourceManager.h>
#import "ImageViewController.h"
#import "FavoritesViewController.h"
#import "FavoritesNaviController.h"
#import "CalibrationIndicator.h"
#import "ApiKey.h"
#import <UIKit/UIKit.h>


#import <MapKit/MapKit.h>


#define degreesToRadians(x) (M_PI * x / 180.0)

@interface ContactServer : NSObject
@end

@implementation ContactServer
+ (void) serverRequest:(NSDictionary *)sendDict function:(NSString*) operationName completion:(void (^)(id responseObject, NSError *error))completion
{
    
    NSURL *url = [NSURL URLWithString:[@"http://18.216.78.130/UserInfo.svc/" stringByAppendingString:operationName]];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    
    // 2
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"POST";
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-type"];
    
    //  NSData *dataIn = [@"12" dataUsingEncoding:NSUTF8StringEncoding];
    //   request.HTTPBody = dataIn;
    
    //[request setHTTPBody:dataIn];
    
    
    // 3
    //  NSDictionary *dictionary = @{@"username": @"chenyu",@"password": @"1234567890"};
    NSLog (@"%@", sendDict);
    
    
    
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:sendDict options:kNilOptions error:&error];
    //NSData *data = [@"12" dataUsingEncoding:NSUTF8StringEncoding];
    NSData *dataIn = [NSJSONSerialization dataWithJSONObject:sendDict options:NSJSONWritingPrettyPrinted error:nil];
    // NSData *dataIn = [@"hgghhh" dataUsingEncoding:NSUTF8StringEncoding];
    //  NSString *string = @"123";
    //  NSData *dataIn = [NSJSONSerialization dataWithJSONObject:string options:0 error:nil];
    
    request.HTTPBody = dataIn;
    
    if (!error) {
        // 4
        NSURLSessionUploadTask *uploadTask = [session uploadTaskWithRequest:request
                                                                   fromData:data completionHandler:^(NSData *data,NSURLResponse *response,NSError *error) {
                                                                       
                                                                       if (!data) {
                                                                           if (completion) {
                                                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                                                   completion(nil, error);
                                                                               });
                                                                           }
                                                                           return;
                                                                       }
                                                                       
                                                                       // report any errors parsing the JSON
                                                                       
                                                                       NSError *parseError = nil;
                                                                       NSData *returnedData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                                                                       
                                                                       if (!returnedData) {
                                                                           if (completion) {
                                                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                                                   completion(nil, parseError);
                                                                               });
                                                                           }
                                                                           return;
                                                                       }
                                                                       
                                                                       // if everything is ok, then just return the JSON object
                                                                       
                                                                       if (completion) {
                                                                           dispatch_async(dispatch_get_main_queue(), ^{
                                                                               completion(returnedData, nil);
                                                                           });
                                                                       }
                                                                   }];
        
        [uploadTask resume];
    }
}


@end
@interface MapOverlay : NSObject <MKOverlay>
- (id)initWithFloorPlan:(IAFloorPlan *)floorPlan andRotatedRect:(CGRect)rotated;
- (MKMapRect)boundingMapRect;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property CLLocationCoordinate2D center;
@property MKMapRect rect;


@end

@implementation MapOverlay

- (id)initWithFloorPlan:(IAFloorPlan *)floorPlan andRotatedRect:(CGRect)rotated
{
    self = [super init];
    if (self != nil) {
        
        _center = floorPlan.center;
        MKMapPoint topLeft = MKMapPointForCoordinate(floorPlan.topLeft);
        _rect = MKMapRectMake(topLeft.x + rotated.origin.x, topLeft.y + rotated.origin.y,
                              rotated.size.width, rotated.size.height);
    }
    return self;
}

- (CLLocationCoordinate2D)coordinate
{
    return self.center;
}

- (MKMapRect)boundingMapRect {
    return _rect;
}

@end

@interface MapOverlayRenderer : MKOverlayRenderer
@property (nonatomic, strong, readwrite) IAFloorPlan *floorPlan;
@property (strong, readwrite) UIImage *image;
@property CGRect rotated;
@end

@implementation MapOverlayRenderer

- (void)drawMapRect:(MKMapRect)mapRect
          zoomScale:(MKZoomScale)zoomScale
          inContext:(CGContextRef)ctx
{
    double mapPointsPerMeter = MKMapPointsPerMeterAtLatitude(self.floorPlan.center.latitude);
    CGRect rect = CGRectMake(0, 0, self.floorPlan.widthMeters * mapPointsPerMeter, self.floorPlan.heightMeters * mapPointsPerMeter);
    
    CGContextTranslateCTM(ctx, -_rotated.origin.x, -_rotated.origin.y);
    // Rotate around top left corner
    CGContextRotateCTM(ctx, degreesToRadians(self.floorPlan.bearing));
    
    UIGraphicsPushContext(ctx);
    [_image drawInRect:rect blendMode:kCGBlendModeNormal alpha:1.0];
    UIGraphicsPopContext();
}

@end

@interface ImageViewController () <MKMapViewDelegate, IALocationManagerDelegate,UISearchBarDelegate,UITextFieldDelegate> {
    MapOverlay *mapOverlay;
    MapOverlayRenderer *mapOverlayRenderer;
    id<IAFetchTask> floorPlanFetch;
    id<IAFetchTask> imageFetch;
    
    UIImage *fpImage;
    NSData *image;
    MKMapCamera *camera;
    Boolean updateCamera;
    __weak IBOutlet UIBarButtonItem *loginButton;
    
}
@property (strong) MKCircle *circle;
@property (strong) IAFloorPlan *floorPlan;
@property (nonatomic, strong) IAResourceManager *resourceManager;
@property CGRect rotated;
@property (nonatomic, strong) CalibrationIndicator *calibrationIndicator;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UISearchBar *searchBar;

@property NSUserDefaults *userDefaults;

@property(copy,nonatomic)NSArray *name;
@property(copy,nonatomic)NSArray *latitude;
@property(copy,nonatomic)NSArray *longitude;
@end

@implementation ImageViewController
@synthesize map;

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    if (overlay == self.circle) {
        MKCircleRenderer *circleRenderer = [[MKCircleRenderer alloc] initWithCircle:overlay];
        circleRenderer.fillColor = [UIColor colorWithRed:0 green:0.647 blue:0.961 alpha:1.0];
        circleRenderer.alpha = 1.f;
        return circleRenderer;
    } else if (overlay == mapOverlay) {
        mapOverlay = overlay;
        mapOverlayRenderer = [[MapOverlayRenderer alloc] initWithOverlay:mapOverlay];
        mapOverlayRenderer.rotated = self.rotated;
        mapOverlayRenderer.floorPlan = self.floorPlan;
        mapOverlayRenderer.image = fpImage;
        return mapOverlayRenderer;
    } else {
        MKCircleRenderer *circleRenderer = [[MKCircleRenderer alloc] initWithCircle:(MKCircle *)overlay];
        circleRenderer.fillColor =  [UIColor colorWithRed:1 green:0 blue:0 alpha:1.0];
        return circleRenderer;
    }
    
}

- (void)indoorLocationManager:(IALocationManager*)manager didUpdateLocations:(NSArray*)locations
{
    (void)manager;
    
    CLLocation *l = [(IALocation*)locations.lastObject location];
    NSLog(@"position changed to coordinate (lat,lon): %f, %f", l.coordinate.latitude, l.coordinate.longitude);
    
    if (self.circle != nil) {
        [map removeOverlay:self.circle];
    }
    
    self.circle = [MKCircle circleWithCenterCoordinate:l.coordinate radius:1];
    [map addOverlay:self.circle];
    if (updateCamera) {
        updateCamera = false;
        if (camera == nil) {
            // Ask Map Kit for a camera that looks at the location from an altitude of 300 meters above the eye coordinates.
            camera = [MKMapCamera cameraLookingAtCenterCoordinate:l.coordinate fromEyeCoordinate:l.coordinate eyeAltitude:300];
            
            // Assign the camera to your map view.
            map.camera = camera;
        } else {
            camera.centerCoordinate = l.coordinate;
        }
    }
    
    [self updateLabel];
}

- (void)changeMapOverlay
{
    if (mapOverlay != nil)
        [map removeOverlay:mapOverlay];
    
    double mapPointsPerMeter = MKMapPointsPerMeterAtLatitude(self.floorPlan.center.latitude);
    double widthMapPoints = self.floorPlan.widthMeters * mapPointsPerMeter;
    double heightMapPoints = self.floorPlan.heightMeters * mapPointsPerMeter;
    CGRect cgRect = CGRectMake(0, 0, widthMapPoints, heightMapPoints);
    double a = degreesToRadians(self.floorPlan.bearing);
    self.rotated = CGRectApplyAffineTransform(cgRect, CGAffineTransformMakeRotation(a));
    
    mapOverlay = [[MapOverlay alloc] initWithFloorPlan:self.floorPlan andRotatedRect:self.rotated];
    [map addOverlay:mapOverlay];
    
    // Enable to show red circles on floorplan corners
#if 0
    MKCircle *topLeft = [MKCircle circleWithCenterCoordinate:_floorPlan.topLeft radius:5];
    [map addOverlay:topLeft];
    
    MKCircle *topRight = [MKCircle circleWithCenterCoordinate:_floorPlan.topRight radius:5];
    [map addOverlay:topRight];
    
    MKCircle *bottomLeft = [MKCircle circleWithCenterCoordinate:_floorPlan.bottomLeft radius:5];
    [map addOverlay:bottomLeft];
#endif
}

- (NSString*)cacheFile {
    //get the caches directory path
    NSArray *paths = NSSearchPathForDirectoriesInDomains
    (NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDirectory = [paths objectAtIndex:0];
    BOOL isDir = NO;
    NSError *error;
    // create caches directory if it does not exist
    if (! [[NSFileManager defaultManager] fileExistsAtPath:cachesDirectory isDirectory:&isDir] && isDir == NO) {
        [[NSFileManager defaultManager] createDirectoryAtPath:cachesDirectory withIntermediateDirectories:NO attributes:nil error:&error];
    }
    NSString *plistName = [cachesDirectory stringByAppendingPathComponent:@"fpcache.plist"];
    return plistName;
}

// Stores floor plan meta data to NSCachesDirectory
- (void)saveFloorPlan:(IAFloorPlan *)object key:(NSString *)key {
    NSString *cFile = [self cacheFile];
    NSMutableDictionary *cache;
    if ([[NSFileManager defaultManager] fileExistsAtPath:cFile]) {
        cache = [NSMutableDictionary dictionaryWithContentsOfFile:cFile];
    } else {
        cache = [NSMutableDictionary new];
    }
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:object];
    [cache setObject:data forKey:key];
    [cache writeToFile:cFile atomically:YES];
}

// Loads floor plan meta data from NSCachesDirectory
// Remember that if you edit the floor plan position
// from www.indooratlas.com then you must fetch the IAFloorPlan again from server
- (IAFloorPlan *)loadFloorPlanWithId:(NSString *)key {
    NSDictionary *cache = [NSMutableDictionary dictionaryWithContentsOfFile:[self cacheFile]];
    NSData *data = [cache objectForKey:key];
    IAFloorPlan *object = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    return object;
}

// Image is fetched again each time. It can be cached on device.
- (void)fetchImage:(IAFloorPlan*)floorPlan
{
    if (imageFetch != nil) {
        [imageFetch cancel];
        imageFetch = nil;
    }
    __weak typeof(self) weakSelf = self;
    imageFetch = [self.resourceManager fetchFloorPlanImageWithUrl:floorPlan.imageUrl andCompletion:^(NSData *imageData, NSError *error){
        if (!error) {
            fpImage = [[UIImage alloc] initWithData:imageData];
            [weakSelf changeMapOverlay];
        }
    }];
}

- (void)indoorLocationManager:(IALocationManager*)manager didEnterRegion:(IARegion*)region
{
    (void) manager;
    if (region.type != kIARegionTypeFloorPlan)
        return;
    
    NSLog(@"Floor plan changed to %@", region.identifier);
    updateCamera = true;
    if (floorPlanFetch != nil) {
        [floorPlanFetch cancel];
        floorPlanFetch = nil;
    }
    
    IAFloorPlan *fp = [self loadFloorPlanWithId:region.identifier];
    if (fp != nil) {
        // use stored floor plan meta data
        self.floorPlan = fp;
        [self fetchImage:fp];
    } else {
        __weak typeof(self) weakSelf = self;
        floorPlanFetch = [self.resourceManager fetchFloorPlanWithId:region.identifier andCompletion:^(IAFloorPlan *floorPlan, NSError *error) {
            if (!error) {
                self.floorPlan = floorPlan;
                [weakSelf saveFloorPlan:floorPlan key:region.identifier];
                [weakSelf fetchImage:floorPlan];
            } else {
                NSLog(@"There was error during floorplan fetch: %@", error);
            }
        }];
    }
}

- (void)indoorLocationManager:(IALocationManager *)manager calibrationQualityChanged:(enum ia_calibration)quality
{
    [self.calibrationIndicator setCalibration:quality];
}

/**
 * Request location updates
 */
- (void)requestLocation
{
    self.locationManager = [IALocationManager sharedInstance];
    
    // Optionally set initial location
    if (kFloorplanId.length) {
        IALocation *location = [IALocation locationWithFloorPlanId:kFloorplanId];
        self.locationManager.location = location;
    }
    
    // set delegate to receive location updates
    self.locationManager.delegate = self;
    
    // Create floor plan manager
    self.resourceManager = [IAResourceManager resourceManagerWithLocationManager:self.locationManager];
    
    self.calibrationIndicator = [[CalibrationIndicator alloc] initWithNavigationItem:self.navigationItem andCalibration:self.locationManager.calibration];
    
    [self.calibrationIndicator setCalibration:self.locationManager.calibration];
    
    // Request location updates
    [self.locationManager startUpdatingLocation];
}

- (void)updateLabel
{
    self.label.text = [NSString stringWithFormat:@"Trace ID: %@", [self.locationManager.extraInfo objectForKey:kIATraceId]];
}

- (void)authenticateAndRequestLocation
{
    // Create IALocationManager and point delegate to receiver
    self.locationManager = [IALocationManager sharedInstance];
    self.locationManager.delegate = self;

    // Set IndoorAtlas ApiKey and secret
    [self.locationManager setApiKey:kAPIKey andSecret:kAPISecret];

    // Request location updates
    [self.locationManager startUpdatingLocation];
}
//- (void) serverRequest:(NSDictionary *)sendDict function:(NSString*) operationName completion:(void (^)(id responseObject, NSError *error))completion
//{
//    
//    NSURL *url = [NSURL URLWithString:[@"http://18.216.78.130/UserInfo.svc/" stringByAppendingString:operationName]];
//    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
//    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
//    
//    // 2
//    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
//    request.HTTPMethod = @"POST";
//    [request addValue:@"application/json" forHTTPHeaderField:@"Content-type"];
//    
//    //  NSData *dataIn = [@"12" dataUsingEncoding:NSUTF8StringEncoding];
//    //   request.HTTPBody = dataIn;
//    
//    //[request setHTTPBody:dataIn];
//    
//    
//    // 3
//    //  NSDictionary *dictionary = @{@"username": @"chenyu",@"password": @"1234567890"};
//    NSLog (@"%@", sendDict);
//    
//    
//    
//    NSError *error = nil;
//    NSData *data = [NSJSONSerialization dataWithJSONObject:sendDict options:kNilOptions error:&error];
//    //NSData *data = [@"12" dataUsingEncoding:NSUTF8StringEncoding];
//    NSData *dataIn = [NSJSONSerialization dataWithJSONObject:sendDict options:NSJSONWritingPrettyPrinted error:nil];
//    // NSData *dataIn = [@"hgghhh" dataUsingEncoding:NSUTF8StringEncoding];
//    //  NSString *string = @"123";
//    //  NSData *dataIn = [NSJSONSerialization dataWithJSONObject:string options:0 error:nil];
//    
//    request.HTTPBody = dataIn;
//    
//    if (!error) {
//        // 4
//        NSURLSessionUploadTask *uploadTask = [session uploadTaskWithRequest:request
//                                                                   fromData:data completionHandler:^(NSData *data,NSURLResponse *response,NSError *error) {
//                                                                       
//                                                                       if (!data) {
//                                                                           if (completion) {
//                                                                               dispatch_async(dispatch_get_main_queue(), ^{
//                                                                                   completion(nil, error);
//                                                                               });
//                                                                           }
//                                                                           return;
//                                                                       }
//                                                                       
//                                                                       // report any errors parsing the JSON
//                                                                       
//                                                                       NSError *parseError = nil;
//                                                                       NSData *returnedData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
//                                                                       
//                                                                       if (!returnedData) {
//                                                                           if (completion) {
//                                                                               dispatch_async(dispatch_get_main_queue(), ^{
//                                                                                   completion(nil, parseError);
//                                                                               });
//                                                                           }
//                                                                           return;
//                                                                       }
//                                                                       
//                                                                       // if everything is ok, then just return the JSON object
//                                                                       
//                                                                       if (completion) {
//                                                                           dispatch_async(dispatch_get_main_queue(), ^{
//                                                                               completion(returnedData, nil);
//                                                                           });
//                                                                       }
//                                                                   }];
//        
//        [uploadTask resume];
//    }
//}
//-(NSString*) getCoordfromServer:(NSString*)ID{
//    //  NSDictionary *payloadDict = [NSDictionary dictionaryWithObjectsAndKeys:@"88",@"sessionID", nil];
//    NSString *operationName = ID;
//    
//    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] init];
//    urlRequest.URL = [NSURL URLWithString:[@"http://18.216.78.130/UserInfo.svc/GetCoord/" stringByAppendingString:operationName]];
//    [urlRequest setHTTPMethod:@"GET"];
//    [urlRequest addValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-type"];
//    NSError *error = nil;
//    // NSData *jsonData = [NSJSONSerialization dataWithJSONObject:payloadDict options:0 error:NULL];
//    NSData *jsonData = [NSData dataWithContentsOfURL:urlRequest.URL options:NSDataReadingUncached error:&error];
//    [urlRequest setHTTPBody:jsonData];
//    
//    //NSString* newStr = [NSString stringWithUTF8String:[jsonData bytes]];
//    
//    //return newStr;
//    NSDictionary *results;
//    if(NSClassFromString(@"NSJSONSerialization"))
//    {
//        NSError *error = nil;
//        id object = [NSJSONSerialization
//                     JSONObjectWithData:jsonData
//                     options:0
//                     error:&error];
//        
//        if(error) { /* JSON was malformed, act appropriately here */ }
//        
//        // the originating poster wants to deal with dictionaries;
//        // assuming you do too then something like this is the first
//        // validation step:
//        if([object isKindOfClass:[NSDictionary class]])
//        {
//            results = object;
//            
//            NSLog(@"%@",results[@"GetCoordResult"]);
//            /* proceed with results as you like; the assignment to
//             an explicit NSDictionary * is artificial step to get
//             compile-time checking from here on down (and better autocompletion
//             when editing). You could have just made object an NSDictionary *
//             in the first place but stylistically you might prefer to keep
//             the question of type open until it's confirmed */
//        }
//        else
//        {
//            /* there's no guarantee that the outermost object in a JSON
//             packet will be a dictionary; if we get here then it wasn't,
//             so 'object' shouldn't be treated as an NSDictionary; probably
//             you need to report a suitable error condition */
//        }
//    }
//    else
//    {
//        // the user is using iOS 4; we'll need to use a third-party solution.
//        // If you don't intend to support iOS 4 then get rid of this entire
//        // conditional and just jump straight to
//        // NSError *error = nil;
//        // [NSJSONSerialization JSONObjectWithData:...
//    }
//    // 1
//    NSURL *url = [NSURL URLWithString:@"http://18.216.78.130/UserInfo.svc/GetCoord"];
//    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
//    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
//    
//    // 2
//    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
//    request.HTTPMethod = @"POST";
//    [request addValue:@"application/json" forHTTPHeaderField:@"Content-type"];
//    
//    //  NSData *dataIn = [@"12" dataUsingEncoding:NSUTF8StringEncoding];
//    //   request.HTTPBody = dataIn;
//    
//    //[request setHTTPBody:dataIn];
//    
//    
//    // 3
//    //  NSDictionary *dictionary = @{@"username": @"chenyu",@"password": @"1234567890"};
//    NSDictionary *dictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//                                @"001", @"id",
//                                nil];
//    NSLog (@"%@", dictionary);
//    
//    
//    NSError *error = nil;
//    NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary options:kNilOptions error:&error];
//    //NSData *data = [@"12" dataUsingEncoding:NSUTF8StringEncoding];
//    NSData *dataIn = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
//    // NSData *dataIn = [@"hgghhh" dataUsingEncoding:NSUTF8StringEncoding];
//    //  NSString *string = @"123";
//    //  NSData *dataIn = [NSJSONSerialization dataWithJSONObject:string options:0 error:nil];
//    
//    request.HTTPBody = dataIn;
//    _Block NSDictionary* result;
//    if (!error) {
//        // 4
//        NSURLSessionUploadTask *uploadTask = [session uploadTaskWithRequest:request
//                                                                   fromData:data completionHandler:^(NSData *data,NSURLResponse *response,NSError *error) {
//                                                                       // Handle response here
//                                                                       NSLog(@"Resopnse == %@",response);
//                                                                       //  NSString* newStr = [NSString stringWithUTF8String:[data bytes]];
//                                                                       NSString *newStr = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
//                                                                       NSLog(@"%@",data);
//                                                                       NSLog(@"%@",newStr);
//                                                                       
//                                                                       NSDictionary* result2 = [NSJSONSerialization
//                                                                                 JSONObjectWithData:data
//                                                                                 options:0
//                                                                                 error:&error];
//                                                                       result = result2
//                                                                   }];
//        
//        // 5
//        [uploadTask resume];
//    }
//    return result[@"GetCoordResult"];
//}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self.view endEditing:YES];
    NSDictionary *dictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                searchBar.text, @"id",
                                nil];
    [ContactServer serverRequest:dictionary function:@"GetCoord" completion:^(id responseObject, NSError *error) {
        if (responseObject) {
            // do what you want with the response object here
            NSLog(@"get %@",responseObject);
//            NSDictionary* result2 = responseObject;
//            NSLog(@"%@",result2 [@"GetCoordResult"]);
            NSString *result =responseObject;
            if(![result isEqual: @"not found"]){
                searchBar.text = @"";
                
                NSArray *coord = [result componentsSeparatedByString:@","];
                
                [self.map removeAnnotations:self.map.annotations];
                CLLocationCoordinate2D c2D = CLLocationCoordinate2DMake([coord[0] floatValue], [coord[1] floatValue]);
                NSLog(@"%f,%f", [coord[0] floatValue], [coord[1] floatValue]);
                MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
                [annotation setCoordinate:c2D];
                [annotation setTitle:@"Title"]; //You can set the subtitle too
                [self.map addAnnotation:annotation];
                
            }
            else{
                searchBar.text = @"";
                UIAlertController * alert = [UIAlertController
                                             alertControllerWithTitle:@"No Result"
                                             message:@"Can not find the reslut, please try again"
                                             preferredStyle:UIAlertControllerStyleAlert];
                
                //Add Buttons
                
                UIAlertAction* yesButton = [UIAlertAction
                                            actionWithTitle:@"Ok"
                                            style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * action) {
                                                //Handle your yes please button action here
                                            }];
                
                
                //Add your buttons to alert controller
                
                [alert addAction:yesButton];
                [self presentViewController:alert animated:YES completion:nil];
            }
            
        } else {
            NSLog(@"%s: serverRequest error: %@", __FUNCTION__, error);
               [self messageAlert:@"Search Failed" message:@"No response from server, please try agin later"];
        }
    }];
    
  //  NSString *reslut = [self getCoordfromServer:searchBar.text];
 //   NSLog(@"XXXXXXXXX%@", reslut);

    
    
}
- (IBAction)longPressed:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
        NSLog(@"Long press Ended");

    } else if (sender.state == UIGestureRecognizerStateBegan) {
        NSLog(@"Long press detected.");
        [self.map removeAnnotations:self.map.annotations];
        CGPoint touchPoint = [sender locationInView:self.map];
        CLLocationCoordinate2D touchMapCoordinate =
        [self.map convertPoint:touchPoint toCoordinateFromView:self.map];
        
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
        annotation.coordinate = touchMapCoordinate;
        
        [self.map addAnnotation:annotation];
        
        NSLog(@"This position is located at %f,%f", touchMapCoordinate.latitude,touchMapCoordinate.longitude);
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *cancelAction = [UIAlertAction
                                       actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
                                       style:UIAlertActionStyleCancel
                                       handler:^(UIAlertAction *action)
                                       {
                                           NSLog(@"Cancel action");
                                       }];
        
        UIAlertAction *addAction = [UIAlertAction
                                        actionWithTitle:NSLocalizedString(@"Add to Favorites", @"Add to Favorites")
                                        style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction *action)
                                        {
                                            if(_login == true){
                                                NSLog(@"Add to Favorites");
                                            NSString *str1 = [NSString stringWithFormat:@"%f", touchMapCoordinate.latitude];
                                            NSString *str2 = [NSString stringWithFormat:@"%f", touchMapCoordinate.longitude];
                                                [self addtoFavoritesLat:str1 andLong:str2];
                                            }
                                            else{
                                                [self loginRequestMessagAlert];
                                            }
                                            
                                        }];
        
        
        UIAlertAction *removeAction = [UIAlertAction
                                    actionWithTitle:NSLocalizedString(@"Remove Marker", @"Remove Marker")
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction *action)
                                    {
                                        
                                        NSLog(@"Remove Marker");
                                        [self.map removeAnnotations:self.map.annotations];

                                        
                                    }];
        
        [alertController addAction:cancelAction]; // 1th row from bottom
        [alertController addAction:removeAction]; // 2nd row from bottom
        [alertController addAction:addAction]; // 3rd row from bottom
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

-(void) addtoFavoritesLat:(NSString*)latValue andLong:(NSString*)longValue{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Add new Location to Favorites" message:@"Please enter location name" preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField){
        textField.placeholder = @"Location";
        //textField.keyboardType = UIKeyboardTypeNumberPad;
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:@"OK"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action) {
                                   
                                   UITextField *login = alertController.textFields.firstObject;
                                   NSString *locationName = login.text;
                                   
                                   NSString *coord = [NSString stringWithFormat:@"%@,%@", latValue, longValue];
                                   NSArray *array = [NSArray arrayWithObjects: [NSArray arrayWithObjects: locationName, coord, nil], nil];
                                       NSDictionary *dictionary = @{@"username": _userName,@"idList":array, @"isAdd": [NSNumber numberWithInt:1]};
                                       [ContactServer serverRequest:dictionary function:@"SetFavorite" completion:^(id responseObject, NSError *error) {
                                           if (responseObject) {
                                               // do what you want with the response object here
                                              // NSLog(@"get %@",responseObject);
                                               NSInteger result = [responseObject integerValue];
                                               //int result = (unsigned int)responseObject;
                                               NSLog(@"%tu",result);
                                               
                                               if(result != 1){
                                                   [self messageAlert:@"Add Failed" message:@"Location name exists"];
                                               }
                                           } else {
                                               NSLog(@"%s: serverRequest error: %@", __FUNCTION__, error);
                                                  [self messageAlert:@"Add Favorites Failed" message:@"No response from server, please try agin later"];
                                           }
                                       }];
//                                   NSMutableArray *nameList = [[NSMutableArray alloc] initWithArray: [_userDefaults objectForKey:@"Name"]];
//                                   [nameList addObject:string];
//                                    [_userDefaults setObject:nameList forKey:@"Name"];
//                                   
//                                   NSMutableArray *latList = [[NSMutableArray alloc] initWithArray: [_userDefaults objectForKey:@"Latitude"]];
//                                   [latList addObject:latValue];
//                                    [_userDefaults setObject:latList forKey:@"Latitude"];
//                                   
//                                   NSMutableArray *longList = [[NSMutableArray alloc] initWithArray: [_userDefaults objectForKey:@"Longitude"]];
//                                   [longList addObject:longValue];
//                                    [_userDefaults setObject:longList forKey:@"Longitude"];
//                                   
//                                       [_userDefaults synchronize];
//                                    NSLog(@"%@", [[NSUserDefaults standardUserDefaults] dictionaryRepresentation]);
                                   
                                   
                               }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}



#pragma mark MapsOverlayView boilerplate
- (void) Init{
//    self.name = @[@"Apple",@"IBM",@"Facebook"];
//    self.latitude = @[@"43.470434", @"43.470448", @"43.470442"];
//    self.longitude = @[@"-80.543444", @"-80.543364",@"-80.543298"];
//    
//     _userDefaults = [NSUserDefaults standardUserDefaults];
//    if(!([[[_userDefaults dictionaryRepresentation] allKeys] containsObject:@"Name"])){
//        [_userDefaults setObject:_name forKey:@"Name"];
//        [_userDefaults synchronize];
//    }
//    if(!([[[_userDefaults dictionaryRepresentation] allKeys] containsObject:@"Latitude"])){
//        [_userDefaults setObject:_latitude forKey:@"Latitude"];
//        [_userDefaults synchronize];
//    }
//    if(!([[[_userDefaults dictionaryRepresentation] allKeys] containsObject:@"Longitude"])){
//        [_userDefaults setObject:_longitude forKey:@"Longitude"];
//        [_userDefaults synchronize];
//    }
    
    
    
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self Init];
    
    [self authenticateAndRequestLocation];
    
    updateCamera = true;
    
    map = [MKMapView new];
    [self.view addSubview:map];
    map.frame = self.view.bounds;
    map.delegate = self;
    
    self.label = [UILabel new];
    self.label.textAlignment = NSTextAlignmentCenter;
    self.label.numberOfLines = 0;
    self.label.font = [UIFont fontWithName:@"Trebuchet MS" size:14.0f];
    CGRect frame = self.view.bounds;
    frame.size.height = 24 * 2;
    self.label.frame = frame;
    [self.view addSubview:self.label];
    
    [self requestLocation];
    
//    CLLocationCoordinate2D c2D = CLLocationCoordinate2DMake(43.470612, -80.543175);
//    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
//    [annotation setCoordinate:c2D];
//    [annotation setTitle:@"Title"]; //You can set the subtitle too
//    [self.map addAnnotation:annotation];
    
    
    self.searchBar = [UISearchBar new];
    CGRect searchBarFrame = self.view.bounds;
    searchBarFrame.origin.y = 74;
    searchBarFrame.origin.x = 30;
    searchBarFrame.size.height = 40;
    searchBarFrame.size.width = 300;
    self.searchBar.frame = searchBarFrame;
    [self.view addSubview:self.searchBar];
    self.searchBar.delegate = self;
    
    
    if(_savedCoords!= nil){
        
        //NSLog(@"ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ%@",_savedCoords);
        NSArray *components = [_savedCoords componentsSeparatedByString:@","];
        
        CLLocationCoordinate2D c2D = CLLocationCoordinate2DMake([components[0] floatValue], [components[1] floatValue]);
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
        [annotation setCoordinate:c2D];
        [annotation setTitle:@"Title"]; //You can set the subtitle too
        [self.map addAnnotation:annotation];
        
        _savedCoords = nil;
        
    }
    
    if(_login == true){
        loginButton.title = @"Logout";
        loginButton.image = [UIImage imageNamed:@"icons8-export-filled-25.png"];
    }

}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.locationManager stopUpdatingLocation];
    self.locationManager.delegate = nil;
    self.locationManager = nil;
    self.resourceManager = nil;
    mapOverlayRenderer.image = nil;
    fpImage = nil;
    mapOverlayRenderer = nil;
    
    map.delegate = nil;
    [map removeFromSuperview];
    map = nil;
    
    [self.label removeFromSuperview];
    self.label = nil;
    
}

- (IBAction)tapBackground:(id)sender {
    [self.view endEditing:YES];
}

-(void) signupAction{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Sign Up" message:@"Please enter your user name and password" preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField1){
        textField1.placeholder = @"Enter Your User Name";
        textField1.delegate = self;
        //textField.keyboardType = UIKeyboardTypeNumberPad;
    }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField2){
        textField2.placeholder = @"Enter Your Password";
        textField2.secureTextEntry = true;
        textField2.delegate = self;
        //textField.keyboardType = UIKeyboardTypeNumberPad;
    }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField3){
        textField3.placeholder = @"Repeat Your Password";
        textField3.secureTextEntry = true;
        textField3.delegate = self;
        //textField.keyboardType = UIKeyboardTypeNumberPad;
    }];
    
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:@"OK"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action) {
                                   
                                   UITextField *userName = alertController.textFields.firstObject;
                                   NSString *string1 = userName.text;
                                   UITextField *password1 = alertController.textFields[1];
                                   NSString *string2 = password1.text;
                                   UITextField *password2 = alertController.textFields.lastObject;
                                   NSString *string3 = password2.text;
                                   
                                   if (([string1 length]>=4)&&([string2 length]>=6)&&([string3 length]>=6)){
                                       if([string2 isEqualToString:string3]){
                                           NSDictionary *dictionary = @{@"username": string1,@"password": string2,@"issignup": [NSNumber numberWithInt:1]};
                                           
                                           [ContactServer serverRequest:dictionary function:@"login" completion:^(id responseObject, NSError *error) {
                                               if (responseObject) {
                                                   NSInteger result = [responseObject integerValue];
                                                   //int result = (unsigned int)responseObject;
                                                   NSLog(@"%tu",result);
                                                   
                                                   if(result == 1){
                                                       [self messageAlert:@"Signup Sccessful" message:@""];
                                                   }
                                                   else{
                                                       [self messageAlert:@"Signup Failed" message:@"Username exists"];
                                                    
                                                   }
                                                   // do what you want with the response object here
                                                   NSLog(@"get %@",responseObject);
                                                   //  NSDictionary* result2 = responseObject;
                                                   // NSLog(@"%@",result2 [@"GetCoordResult"]);
                                               } else {
                                                   NSLog(@"%s: serverRequest error: %@", __FUNCTION__, error);
                                                   [self messageAlert:@"Signup Failed" message:@"No response from server, please try agin later"];
                                               }
                                           }];
                                           
                                       }
                                       else {
                                           [self messageAlert:@"Signup Failed" message:@"Two password does not match"];
                                       }
                                   
                                   }
                                   else{
                                   [self messageAlert:@"Signup Failed" message:@"Please enter username more than 4 characters and password more than 6 characters"];}
                                   
                               }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    

    [alertController addAction:okAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
    
}
- (IBAction)loginAction:(id)sender {
    if(_login == true) {
        _login = false;
        loginButton.title = @"Login";
         loginButton.image = [UIImage imageNamed:@"icons8-import-25.png"];
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@"Logout Sucessful"
                                     message:@""
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        //Add Buttons
        
        UIAlertAction* yesButton = [UIAlertAction
                                    actionWithTitle:@"Ok"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {
                                        //Handle your yes please button action here
                                    }];
        
        
        //Add your buttons to alert controller
        
        [alert addAction:yesButton];
        [self presentViewController:alert animated:YES completion:nil];

        
    }
    else{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Login" message:@"Please enter your user name and password" preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField1){
            textField1.placeholder = @"User Name";
            textField1.delegate = self;
            //textField.keyboardType = UIKeyboardTypeNumberPad;
        }];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField2){
            textField2.placeholder = @"Password";
            textField2.secureTextEntry = true;
            textField2.delegate = self;
            //textField.keyboardType = UIKeyboardTypeNumberPad;
        }];
        
        
        UIAlertAction *okAction = [UIAlertAction
                                   actionWithTitle:@"OK"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action) {
                                       
                                       UITextField *username = alertController.textFields.firstObject;
                                       NSString *string1 = username.text;
                                       UITextField *password = alertController.textFields.lastObject;
                                       NSString *string2 = password.text;
                                       
                                       NSDictionary *dictionary = @{@"username": string1,@"password": string2,@"issignup": [NSNumber numberWithInt:0]};
                                       
                                       [ContactServer serverRequest:dictionary function:@"login" completion:^(id responseObject, NSError *error) {
                                           if (responseObject) {
                                               NSInteger result = [responseObject integerValue];
                                              //int result = (unsigned int)responseObject;
                                               NSLog(@"%tu",result);
                                               
                                               if(result == 1){
                                                   _login = true;
                                                   loginButton.title = @"Logout";
                                                   _userName = username.text;
                                                   loginButton.image = [UIImage imageNamed:@"icons8-export-filled-25.png"];
                                                   NSLog(@"%@",_userName);
                                               }
                                               else{
                                                   [self messageAlert:@"Login Failed" message:@"Username or password is wrong"];
                                               }
                                               // do what you want with the response object here
                                               NSLog(@"get %@",responseObject);
                                               //  NSDictionary* result2 = responseObject;
                                               // NSLog(@"%@",result2 [@"GetCoordResult"]);
                                           } else {
                                               NSLog(@"%s: serverRequest error: %@", __FUNCTION__, error);
                                               [self messageAlert:@"Login Failed" message:@"No response from server, please try agin later"];
                                           }
                                       }];
                                       
                                       
                                       
                                       
                                   }];
        
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        
        UIAlertAction *signUplAction = [UIAlertAction
                                        actionWithTitle:@"Sign Up"
                                        style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction *action) {
                                            
                                        [self signupAction];
                                        }];
         [alertController addAction:okAction];
        [alertController addAction:cancelAction];
       [alertController addAction:signUplAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    
}
- (IBAction)favorButtonAction:(UIBarButtonItem *)sender {
    if(_login == true)
    {[self performSegueWithIdentifier:@"toFavor" sender:self];}
    else{
//        UIAlertController * alert = [UIAlertController
//                                     alertControllerWithTitle:@"Please Login"
//                                     message:@"Please login and then try again"
//                                     preferredStyle:UIAlertControllerStyleAlert];
//        
//        //Add Buttons
//        
//        UIAlertAction* yesButton = [UIAlertAction
//                                    actionWithTitle:@"Ok"
//                                    style:UIAlertActionStyleDefault
//                                    handler:^(UIAlertAction * action) {
//                                        //Handle your yes please button action here
//                                    }];
//        
//        
//        //Add your buttons to alert controller
//        
//        [alert addAction:yesButton];
//        [self presentViewController:alert animated:YES completion:nil];
        [self loginRequestMessagAlert];

    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"toFavor"]) {
        // segue.destinationViewController：获取连线时所指的界面（VC）
        FavoritesNaviController* nav = segue.destinationViewController;
        FavoritesViewController *receive = (FavoritesViewController *)nav.topViewController;
        receive.userName = _userName;

        
    }
}

-(void) loginRequestMessagAlert{
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@"Please Login"
                                 message:@"Please login and then try again"
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    //Add Buttons
    
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"Ok"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
                                    //Handle your yes please button action here
                                }];
    
    
    //Add your buttons to alert controller
    
    [alert addAction:yesButton];
    [self presentViewController:alert animated:YES completion:nil];

}

-(void) messageAlert:(NSString*) title message:(NSString*) message{
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:title
                                 message:message
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    //Add Buttons
    
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"Ok"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
                                    //Handle your yes please button action here
                                }];
    
    
    //Add your buttons to alert controller
    
    [alert addAction:yesButton];
    [self presentViewController:alert animated:YES completion:nil];
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    // Prevent crashing undo bug – see note below.
    if(range.length + range.location > textField.text.length)
    {
        return NO;
    }
    
    NSCharacterSet *myCharSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"];
    for (int i = 0; i < [string length]; i++)
    {
        unichar c = [string characterAtIndex:i];
        if (![myCharSet characterIsMember:c])
        {
            return NO;
        }
    }
    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return newLength <= 10;
    
    
}

@end

@interface SearchLocation : ImageViewController
@end

@implementation SearchLocation
+(void) passSearchInformation:(NSDictionary*) dictionary returnTo:(Class *) class{
    [ContactServer serverRequest:dictionary function:@"GetCoord" completion:^(id responseObject, NSError *error) {
        if (responseObject) {
            // do what you want with the response object here
            NSLog(@"get %@",responseObject);
            //            NSDictionary* result2 = responseObject;
            //            NSLog(@"%@",result2 [@"GetCoordResult"]);
            NSString *result =responseObject;
            if(![result isEqual: @"not found"]){
           //     searchBar.text = @"";
                
                NSArray *coord = [result componentsSeparatedByString:@","];
                
          //      [self.map removeAnnotations:self.map.annotations];
                CLLocationCoordinate2D c2D = CLLocationCoordinate2DMake([coord[0] floatValue], [coord[1] floatValue]);
                NSLog(@"%f,%f", [coord[0] floatValue], [coord[1] floatValue]);
                MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
                [annotation setCoordinate:c2D];
                [annotation setTitle:@"Title"];
            //    [self.map addAnnotation:annotation];
                
            }
            else{
           //     searchBar.text = @"";
                UIAlertController * alert = [UIAlertController
                                             alertControllerWithTitle:@"No Result"
                                             message:@"Can not find the reslut, please try again"
                                             preferredStyle:UIAlertControllerStyleAlert];
                
                //Add Buttons
                
                UIAlertAction* yesButton = [UIAlertAction
                                            actionWithTitle:@"Ok"
                                            style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * action) {
                                                //Handle your yes please button action here
                                            }];
                
                
                //Add your buttons to alert controller
                
                [alert addAction:yesButton];
            //    [self presentViewController:alert animated:YES completion:nil];
            }
            
        } else {
            NSLog(@"%s: serverRequest error: %@", __FUNCTION__, error);
       //     [self messageAlert:@"Search Failed" message:@"No response from server, please try agin later"];
        }
    }];

    
}
@end





//
//  Header.h
//  Uwaterloo Indoor
//
//  Created by Owner on 2017-10-25.
//  Copyright © 2017 Owner. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SDKDemoAppDelegate : UIResponder <
UIApplicationDelegate,
UISplitViewControllerDelegate>

@property(strong, nonatomic) UIWindow *window;
@property(strong, nonatomic) UINavigationController *navigationController;

@end

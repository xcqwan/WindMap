//
//  AppDelegate.h
//  WindMap
//
//  Created by Zombie on 9/25/14.
//  Copyright (c) 2014 Xcqwan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BMapKit.h"
#import "Constant.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, BMKGeneralDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) BMKMapManager *mapManager;

@end

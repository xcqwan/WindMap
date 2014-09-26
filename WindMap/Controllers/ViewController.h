//
//  ViewController.h
//  WindMap
//
//  Created by Zombie on 9/25/14.
//  Copyright (c) 2014 Xcqwan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BMapKit.h"
#import "Constant.h"
#import <AFNetworking/AFHTTPRequestOperationManager.h>

@interface ViewController : UIViewController<BMKMapViewDelegate,BMKLocationServiceDelegate>

@property BMKLocationService *locService;
@property BMKMapView *mapView;

@end

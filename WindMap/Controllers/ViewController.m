//
//  ViewController.m
//  WindMap
//
//  Created by Zombie on 9/25/14.
//  Copyright (c) 2014 Xcqwan. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property NSString *myPID;

@property CLLocationCoordinate2D lastUploadLocation;
@property NSUserDefaults *userDefaults;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    
    self.mapView = [[BMKMapView alloc] initWithFrame:self.view.frame];
    self.view = self.mapView;
    
    self.locService = [[BMKLocationService alloc] init];
    [self.locService startUserLocationService];
    
    self.mapView.showsUserLocation = NO;
    self.mapView.userTrackingMode = BMKUserTrackingModeFollow;
    self.mapView.showsUserLocation = true;
    self.mapView.zoomLevel = 16;
}

- (void)initUD
{
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    self.myPID = [self.userDefaults valueForKey:UD_POI_ID];
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = [[self.userDefaults valueForKey:UD_LAST_LATITUDE] doubleValue];
    coordinate.longitude = [[self.userDefaults valueForKey:UD_LAST_LONGITUDE] doubleValue];
    self.lastUploadLocation = coordinate;
    [self search:self.lastUploadLocation];
}

- (void)saveUD
{
    [self.userDefaults setObject:self.myPID forKey:UD_POI_ID];
    [self.userDefaults setObject:[NSNumber numberWithDouble:self.lastUploadLocation.longitude] forKey:UD_LAST_LONGITUDE];
    [self.userDefaults setObject:[NSNumber numberWithDouble:self.lastUploadLocation.latitude] forKey:UD_LAST_LATITUDE];
}


- (void)create:(CLLocationCoordinate2D)coordinate
{
    double latitude = coordinate.latitude;
    double longitude = coordinate.longitude;
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:POI_SERVICE_TOKEN forKey:@"ak"];
    [params setObject:POI_TB_ID forKey:@"geotable_id"];
    [params setObject:@3 forKey:@"coord_type"];
    [params setObject:[NSNumber numberWithDouble:longitude] forKey:@"longitude"];
    [params setObject:[NSNumber numberWithDouble:latitude] forKey:@"latitude"];
    [params setObject:@"谢谢" forKey:@"title"];
    
    AFHTTPRequestOperationManager * manager = [[AFHTTPRequestOperationManager alloc]init];
    
    [manager POST:URL_POI_CREATE parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Success: %@", responseObject);
        self.myPID = [responseObject valueForKey:@"id"];
        self.lastUploadLocation = coordinate;
        
        [self saveUD];
        [self search:coordinate];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", operation.response);
        self.myPID = nil;
    }];
}

- (void)search:(CLLocationCoordinate2D)coordinate
{
    double latitude = coordinate.latitude;
    double longitude = coordinate.longitude;
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:POI_SERVICE_TOKEN forKey:@"ak"];
    [params setObject:POI_TB_ID forKey:@"geotable_id"];
    [params setObject:@3 forKey:@"coord_type"];
    [params setObject:@"" forKey:@"q"];
    [params setObject:[NSString stringWithFormat:@"%f,%f", longitude, latitude] forKey:@"location"];
    
    AFHTTPRequestOperationManager * manager = [[AFHTTPRequestOperationManager alloc]init];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    [manager GET:URL_POI_nearby parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        for (NSDictionary *user in [responseObject valueForKey:@"contents"]) {
            NSArray *location = [user valueForKey:@"location"];
            
            BMKPointAnnotation *annotation = [[BMKPointAnnotation alloc] init];
            CLLocationCoordinate2D coor;
            coor.longitude = [location[0] doubleValue];
            coor.latitude = [location[1] doubleValue];
            annotation.coordinate = coor;
            annotation.title = [user valueForKey:@"title"];
            annotation.subtitle = [user valueForKey:@"tags"];
            [self.mapView addAnnotation:annotation];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", operation.response);
    }];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.mapView viewWillAppear];
    self.mapView.delegate = self;
    self.locService.delegate = self;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self.mapView viewWillDisappear];
    self.mapView.delegate = nil;
    self.locService.delegate = nil;
}

#pragma mark - BMKMapViewDelegate,BMKLocationServiceDelegate
/**
 *用户方向更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
-(void)didUpdateUserHeading:(BMKUserLocation *)userLocation
{
    [self.mapView updateLocationData:userLocation];
    NSLog(@"Heading is %@", userLocation.heading);
}

/**
 *用户位置更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
-(void)didUpdateUserLocation:(BMKUserLocation *)userLocation
{
    [self.mapView updateLocationData:userLocation];
    if (self.myPID == nil) {
        //注册本设备, 并上传位置
        [self create:userLocation.location.coordinate];
        self.myPID = @"";
    } else {
        if (self.lastUploadLocation.latitude == 0) {
            //更新本设备位置
        } else {
            //判断现处位置与最后一次上传的位置的距离, 超过一定范围则上传
        }
//        [self search:userLocation.location.coordinate];
    }
}

/**
 *在地图View停止定位后，会调用此函数
 *@param mapView 地图View
 */
- (void)mapViewDidStopLocatingUser:(BMKMapView *)mapView
{
    NSLog(@"stop locate");
}

/**
 *定位失败后，会调用此函数
 *@param mapView 地图View
 *@param error 错误号，参考CLError.h中定义的错误号
 */
- (void)mapView:(BMKMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
    NSLog(@"location error");
}

@end

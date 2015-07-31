//
//  ViewController.m
//  XMLocationManagerDemo
//
//  Created by shscce on 15/7/31.
//  Copyright (c) 2015年 xmfraker. All rights reserved.
//

#import "ViewController.h"
#import "XMLocationManager.h"

@interface ViewController ()<MKMapViewDelegate>

@property (strong, nonatomic) MKMapView *mapView;
@property (weak, nonatomic) UILabel *distanceLabel;/**< 显示距离 */
@property (weak, nonatomic) UILabel *addressLabel;/**< 显示地理位置 */
@property (weak, nonatomic) UILabel *locationLabel;/**< 显示经纬度 */

@property (assign, nonatomic) CLLocationCoordinate2D userLocationCoordinate2D;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self.view addSubview:self.mapView];
    UILabel *locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 400, 320, 50)];
    locationLabel.numberOfLines = 2;
    locationLabel.text = @"location";
    [self.view addSubview:self.locationLabel = locationLabel];
    
    UILabel *addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 460, 320, 20)];
    addressLabel.text = @"address";
    [self.view addSubview:self.addressLabel = addressLabel];
    
    UILabel *distanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 490, 320, 50)];
    distanceLabel.text = @"distance";
    distanceLabel.numberOfLines = 2;
    [self.view addSubview:self.distanceLabel = distanceLabel];
    
    [[XMLocationManager shareManager] requestAuthorization];
    [[XMLocationManager shareManager] startLocation];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    self.userLocationCoordinate2D = userLocation.coordinate;
}

#pragma mark - Private Methods

- (void)handleTap:(UITapGestureRecognizer *)tap{
    CGPoint touchPoint = [tap locationInView:tap.view];
    CLLocationCoordinate2D coordinate = [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
    
    self.locationLabel.text = [NSString stringWithFormat:@"经度:%f\n纬度:%f",coordinate.latitude,coordinate.longitude];
    
    [[XMLocationManager shareManager] reverseGeocodeWithCoordinate2D:coordinate success:^(CLPlacemark *placemark) {
        if (placemark) {
            self.addressLabel.text = [NSString stringWithFormat:@"%@",placemark.name];
        }
    } failure:^{
        
    }];
    
    
    self.distanceLabel.text = [NSString stringWithFormat:@"系统距离:%f\n自定义方法距离:%f",[[XMLocationManager shareManager] systemDistanceWithEndCoordinate2D:self.userLocationCoordinate2D fromStartCoordinate2D:coordinate],[[XMLocationManager shareManager] customDistanceWithEndCoordinate2D:self.userLocationCoordinate2D fromStartCoordinate2D:coordinate]];
    
}

#pragma mark - Getters

- (MKMapView *)mapView{
    if (!_mapView) {
        _mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
        _mapView.delegate = self;
        [_mapView showsUserLocation];
        _mapView.userTrackingMode = MKUserTrackingModeFollow;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        [_mapView addGestureRecognizer:tap];
    }
    return _mapView;
}

@end

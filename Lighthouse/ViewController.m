//
//  ViewController.m
//  Lighthouse
//
//  Created by Jun Lin on 12/13/13.
//  Copyright (c) 2013 Sumi Interactive. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

#import "ViewController.h"

@interface ViewController ()


@property (weak, nonatomic) IBOutlet UILabel *beaconLabel;
@property (weak, nonatomic) IBOutlet UILabel *proximityLabel;
@property (weak, nonatomic) IBOutlet UILabel *majorLabel;
@property (weak, nonatomic) IBOutlet UILabel *minorLabel;
@property (weak, nonatomic) IBOutlet UILabel *accuracyLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *rssiLabel;

@property (strong, nonatomic) CLBeaconRegion *beaconRegion;
@property (strong, nonatomic) CLLocationManager *locationManager;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self initRegion];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initRegion {
    NSUUID *proximityUUID = [[NSUUID alloc] initWithUUIDString:@"D57092AC-DFAA-446C-8EF3-C81AA22815B5"];
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:proximityUUID identifier:@"com.sumiapp.Lighthouse"];
    [self.locationManager startMonitoringForRegion:self.beaconRegion];
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
    [self.beaconLabel setText:@"Found"];
    [self notifyWithMessage:@"Enter Region"];
}

-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    [self.locationManager stopRangingBeaconsInRegion:self.beaconRegion];
    [self.beaconLabel setText:@"Exited"];
    [self notifyWithMessage:@"Exit Region"];
}

- (void) locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    [self.locationManager requestStateForRegion:self.beaconRegion];
}

- (void) locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    if ([region.identifier isEqual:@"com.sumiapp.Lighthouse"]) {
        CLBeacon *beacon = [[CLBeacon alloc] init];
        beacon = [beacons lastObject];

        [self.beaconLabel setText:@"YES"];
        [self.proximityLabel setText:beacon.proximityUUID.UUIDString];
        [self.majorLabel setText:[NSString stringWithFormat:@"%@", beacon.major] ];
        [self.minorLabel setText:[NSString stringWithFormat:@"%@", beacon.minor]];
        [self.accuracyLabel setText:[NSString stringWithFormat:@"%f", beacon.accuracy]];
        if (beacon.proximity == CLProximityUnknown) {
            [self.distanceLabel setText:@"Unknown Proximity"];
        } else if (beacon.proximity == CLProximityImmediate) {
            [self.distanceLabel setText:@"Immediate"];
        } else if (beacon.proximity == CLProximityNear) {
            [self.distanceLabel setText:@"Near"];
        } else if (beacon.proximity == CLProximityFar) {
            [self.distanceLabel setText:@"Far"];
        }
        [self.rssiLabel setText:[NSString stringWithFormat:@"%li", (long)beacon.rssi]];
    }
}

- (void) notifyWithMessage:(NSString *)message
{
    UILocalNotification *notification = [[UILocalNotification alloc] init];

    if (notification != nil) {
        notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:2];
        notification.timeZone = [NSTimeZone defaultTimeZone];
        notification.repeatInterval = kCFCalendarUnitDay;
        notification.soundName = UILocalNotificationDefaultSoundName;
        notification.alertBody = message;
        notification.applicationIconBadgeNumber += 1;
        NSDictionary *info = [NSDictionary dictionaryWithObject:@"name" forKey:@"key"];
        notification.userInfo = info;
        UIApplication *app = [UIApplication sharedApplication];
        [app scheduleLocalNotification:notification];
    }
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification*)notification
{
    application.applicationIconBadgeNumber -= 1;
}

@end

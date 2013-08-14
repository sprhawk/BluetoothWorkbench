//
//  BluetoothCentralManager.m
//  BluetoothWorkbench
//
//  Created by YANG HONGBO on 2013-8-14.
//  Copyright (c) 2013年 YANG HONGBO. All rights reserved.
//

#import "BluetoothCentralManager.h"
#import <CoreBluetooth/CoreBluetooth.h>

NSString * BluetoothCentralManagerReadyToUseNotification = @"BluetoothCentralManagerReadyToUseNotification";
NSString * BluetoothCentralManagerUnavailableNotification = @"BluetoothCentralManagerUnavailableNotification";
NSString * BluetoothCentralManagerDidDiscoverPeripheralNotification = @"BluetoothCentralManagerDidDiscoverPeripheralNotification";
NSString * BluetoothCentralManagerDidConnectPeripheralNotification = @"BluetoothCentralManagerDidConnectPeripheralNotification";
NSString * BluetoothCentralManagerDidFailToConnectPeripheralNotification = @"BluetoothCentralManagerDidFailToConnectPeripheralNotification";
NSString * BluetoothCentralManagerDidDisconnectPeripheralNotification = @"BluetoothCentralManagerDidDisconnectPeripheralNotification";

NSString * PeripheralAdvertisementDataKey = @"PeripheralAdvertisementDataKey";
NSString * PeripheralRSSIKey = @"PeripheralRSSIValueKey";
NSString * PeripheralErrorKey = @"PeripheralErrorKey";
NSString * BluetoothCentralStateKey = @"BluetoothCentralStateKey";

@interface BluetoothCentralManager () <CBCentralManagerDelegate>
{
    CBCentralManager * _central;
    NSMutableSet * _discoveredPeripherals;
}
@end

@implementation BluetoothCentralManager

+ (BluetoothCentralManager *)defaultManager
{
    static BluetoothCentralManager * defaultManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultManager = [[BluetoothCentralManager alloc] init];
    });
    return defaultManager;
}

- (id)init
{
    self = [super init];
    if (self) {
        _central = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        _discoveredPeripherals = [[NSMutableSet alloc] initWithCapacity:10];
    }
    return self;
}

#pragma - mark Actions
- (void)scan
{
    [self scanForServices:nil];
}

- (void)scanForServices:(NSArray *)services
{
    [_central scanForPeripheralsWithServices:services options:nil];
    self.scanning = YES;
}

- (void)stopScan
{
    [_central stopScan];
    self.scanning = NO;
}

- (void)connectPeripheral:(CBPeripheral *)peripheral
{
    [_central connectPeripheral:peripheral options:nil];
}

- (void)cancelConnectionToPeripheral:(CBPeripheral *)peripheral
{
    [_central cancelPeripheralConnection:peripheral];
}

- (CBCentralManagerState)state
{
    return _central.state;
}

#pragma - mark Delegates

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    NSNotification * n = nil;
    switch (central.state) {
        case CBCentralManagerStatePoweredOn:
        {
            n = [NSNotification notificationWithName:BluetoothCentralManagerReadyToUseNotification
                                              object:self];
        }
            break;
        case CBCentralManagerStatePoweredOff:
        case CBCentralManagerStateResetting:
        case CBCentralManagerStateUnauthorized:
        case CBCentralManagerStateUnknown:
        case CBCentralManagerStateUnsupported:
        default:
        {
            n = [NSNotification notificationWithName:BluetoothCentralManagerUnavailableNotification
                                              object:self
                                            userInfo:@{BluetoothCentralStateKey: [NSNumber numberWithUnsignedInteger:central.state]}];
        }
            break;
    }
    if (n) {
        NSNotificationCenter * center = [NSNotificationCenter defaultCenter];
        [center postNotification:n];
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    [_discoveredPeripherals addObject:peripheral];
    NSLog(@"discovered number:%d", [_discoveredPeripherals count]);
    NSNotification * n ;
    n = [NSNotification notificationWithName:BluetoothCentralManagerDidDiscoverPeripheralNotification
                                      object:peripheral
                                    userInfo:@{PeripheralAdvertisementDataKey: advertisementData, PeripheralRSSIKey:RSSI}];
    [[NSNotificationCenter defaultCenter] postNotification:n];
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSNotification * n ;
    n = [NSNotification notificationWithName:BluetoothCentralManagerDidConnectPeripheralNotification
                                      object:peripheral
                                    userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotification:n];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSNotification * n ;
    n = [NSNotification notificationWithName:BluetoothCentralManagerDidFailToConnectPeripheralNotification
                                      object:peripheral
                                    userInfo:@{PeripheralErrorKey: error}];
    [[NSNotificationCenter defaultCenter] postNotification:n];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    
    NSNotification * n ;
    n = [NSNotification notificationWithName:BluetoothCentralManagerDidDisconnectPeripheralNotification
                                      object:peripheral
                                    userInfo:@{PeripheralErrorKey: error}];
    [[NSNotificationCenter defaultCenter] postNotification:n];
}

- (void)centralManager:(CBCentralManager *)central didRetrievePeripherals:(NSArray *)peripherals
{
    
}

- (void)centralManager:(CBCentralManager *)central didRetrieveConnectedPeripherals:(NSArray *)peripherals
{
    
}


@end

@implementation CBPeripheral (UUIDString)

- (NSString *)UUIDString
{
    if (self.UUID) {
        CFStringRef s = CFUUIDCreateString(NULL, self.UUID);
        return CFBridgingRelease(s);
    }
    return nil;
}

@end


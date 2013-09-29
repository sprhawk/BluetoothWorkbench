//
//  BluetoothCentralManager.m
//  BluetoothWorkbench
//
//  Created by YANG HONGBO on 2013-8-14.
//  Copyright (c) 2013年 YANG HONGBO. All rights reserved.
//

#import "BluetoothCentralManager.h"
#import <CoreBluetooth/CoreBluetooth.h>

NSString * const BluetoothCentralManagerReadyToUseNotification = @"BluetoothCentralManagerReadyToUseNotification";
NSString * const BluetoothCentralManagerUnavailableNotification = @"BluetoothCentralManagerUnavailableNotification";
NSString * const BluetoothCentralManagerDidDiscoverPeripheralNotification = @"BluetoothCentralManagerDidDiscoverPeripheralNotification";
NSString * const BluetoothCentralManagerDidConnectPeripheralNotification = @"BluetoothCentralManagerDidConnectPeripheralNotification";
NSString * const BluetoothCentralManagerDidFailToConnectPeripheralNotification = @"BluetoothCentralManagerDidFailToConnectPeripheralNotification";
NSString * const BluetoothCentralManagerDidDisconnectPeripheralNotification = @"BluetoothCentralManagerDidDisconnectPeripheralNotification";

NSString * const PeripheralAdvertisementDataKey = @"PeripheralAdvertisementDataKey";
NSString * const PeripheralRSSIKey = @"PeripheralRSSIValueKey";
NSString * const PeripheralErrorKey = @"PeripheralErrorKey";
NSString * const BluetoothCentralStateKey = @"BluetoothCentralStateKey";

NSString * const BluetoothServiceDeviceInfomationKey = @"Device Infomation";
NSString * const BluetoothServiceDeviceInfomationServiceKey = @"Service";
NSString * const BluetoothServiceDeviceInfomationSystemIdKey = @"System Id";
NSString * const BluetoothServiceDeviceInfomationManufacturerNameKey = @"Manufacturer Name";
NSString * const BluetoothServiceDeviceInfomationModelNumberKey = @"Model Number";
NSString * const BluetoothServiceDeviceInfomationSerialNumberKey = @"Serial Number";
NSString * const BluetoothServiceDeviceInfomationHardwareRevisionKey = @"Hardware Revision";
NSString * const BluetoothServiceDeviceInfomationFirmwareRevisionKey = @"Firmware Revision";
NSString * const BluetoothServiceDeviceInfomationSoftwareRevisionKey = @"Software Revision";
NSString * const BluetoothServiceDeviceInfomationRegulatoryCertificationDataListKey = @"Regulatory Certification Data List";
NSString * const BluetoothServiceDeviceInfomationPnPIDKey = @"PnP id";

@interface BluetoothCentralManager () <CBCentralManagerDelegate>
{
    CBCentralManager * _central;
    NSMutableSet * _discoveredPeripherals;
}
@property (nonatomic, strong, readwrite) NSDictionary * services;
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
        self.services = @{BluetoothServiceDeviceInfomationKey:
                              @{BluetoothServiceDeviceInfomationServiceKey:[CBUUID UUIDWithString:@"180A"],
                                BluetoothServiceDeviceInfomationSystemIdKey:[CBUUID UUIDWithString:@"2A23"], //Manufacturer Identifier(40)/Organizationally Unique Identifier(24)
                                BluetoothServiceDeviceInfomationModelNumberKey: [CBUUID UUIDWithString:@"2A24"], //utf8
                                BluetoothServiceDeviceInfomationSerialNumberKey: [CBUUID UUIDWithString:@"2A25"], //utf8
                                BluetoothServiceDeviceInfomationFirmwareRevisionKey: [CBUUID UUIDWithString:@"2A26"],
                                BluetoothServiceDeviceInfomationHardwareRevisionKey: [CBUUID UUIDWithString:@"2A27"],
                                BluetoothServiceDeviceInfomationSoftwareRevisionKey: [CBUUID UUIDWithString:@"2A28"],
                                BluetoothServiceDeviceInfomationManufacturerNameKey:[CBUUID UUIDWithString:@"2A29"], //utf8
                                BluetoothServiceDeviceInfomationManufacturerNameKey:[CBUUID UUIDWithString:@"2A29"],
                                BluetoothServiceDeviceInfomationRegulatoryCertificationDataListKey: [CBUUID UUIDWithString:@"2A2A"],
                                BluetoothServiceDeviceInfomationPnPIDKey: [CBUUID UUIDWithString:@"2A50"],
                                },
                          };

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
    if (![_discoveredPeripherals containsObject:peripheral]) { //为什么会有重复的，因为不同事的data么？
        [_discoveredPeripherals addObject:peripheral];
        NSLog(@"discovered number:%d", [_discoveredPeripherals count]);
        NSNotification * n ;
        n = [NSNotification notificationWithName:BluetoothCentralManagerDidDiscoverPeripheralNotification
                                          object:peripheral
                                        userInfo:@{PeripheralAdvertisementDataKey: advertisementData, PeripheralRSSIKey:RSSI}];
        [[NSNotificationCenter defaultCenter] postNotification:n];
    }
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
    NSDictionary * userInfo = nil;
    if (error) {
        userInfo = @{PeripheralErrorKey: error};
        
    }
    NSLog(@"failed To Connect %@", error);
    n = [NSNotification notificationWithName:BluetoothCentralManagerDidFailToConnectPeripheralNotification
                                      object:peripheral
                                    userInfo:userInfo];
    [[NSNotificationCenter defaultCenter] postNotification:n];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    
    NSNotification * n ;
    NSDictionary * userInfo = nil;
    if (error) {
        userInfo = @{PeripheralErrorKey: error};
    }
    NSLog(@"Disconnected:%@", error);
    n = [NSNotification notificationWithName:BluetoothCentralManagerDidDisconnectPeripheralNotification
                                      object:peripheral
                                    userInfo:userInfo];
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

@implementation CBService (UUIDString)

- (NSString *)UUIDString
{
    return self.UUID.UUIDString;
}

@end

@implementation CBCharacteristic (UUIDString)

- (NSString *)UUIDString
{
    return self.UUID.UUIDString;
}

@end

@implementation CBUUID (UUIDString)

- (NSString *)UUIDString
{
    NSMutableString * s = [NSMutableString stringWithCapacity:self.data.length * 2 + 4];
    unsigned char * b = (unsigned char *)self.data.bytes;
    for (NSUInteger i = 0; i < self.data.length; i ++) {
        [s appendFormat:@"%02X", *(b + i)];
        switch (i) {
            case 3:
            case 5:
            case 7:
            case 9:
                [s appendString:@"-"];
                break;
            default:
                break;
        }
    }
    return [s copy];
}

@end
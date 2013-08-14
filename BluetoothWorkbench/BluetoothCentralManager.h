//
//  BluetoothCentralManager.h
//  BluetoothWorkbench
//
//  Created by YANG HONGBO on 2013-8-14.
//  Copyright (c) 2013年 YANG HONGBO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

extern NSString * BluetoothCentralManagerReadyToUseNotification;
extern NSString * BluetoothCentralManagerUnavailableNotification;
extern NSString * BluetoothCentralManagerDidDiscoverPeripheralNotification;
extern NSString * BluetoothCentralManagerDidConnectPeripheralNotification;
extern NSString * BluetoothCentralManagerDidFailToConnectPeripheralNotification;
extern NSString * BluetoothCentralManagerDidDisconnectPeripheralNotification;
extern NSString * BluetoothCentralStateKey;
extern NSString * PeripheralAdvertisementDataKey;
extern NSString * PeripheralRSSIKey;
extern NSString * PeripheralErrorKey;

@interface BluetoothCentralManager : NSObject
@property (nonatomic, assign, readwrite, getter = isScanning) BOOL scanning;
+ (BluetoothCentralManager *)defaultManager;
- (void)scan;
- (void)scanForServices:(NSArray *)services;
- (void)stopScan;
- (void)connectPeripheral:(CBPeripheral *)peripheral;
- (void)cancelConnectionToPeripheral:(CBPeripheral *)peripheral;
- (CBCentralManagerState)state;
@end

@interface CBPeripheral (UUIDString)
- (NSString *)UUIDString;
@end

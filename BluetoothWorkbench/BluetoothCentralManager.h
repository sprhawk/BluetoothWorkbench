//
//  BluetoothCentralManager.h
//  BluetoothWorkbench
//
//  Created by YANG HONGBO on 2013-8-14.
//  Copyright (c) 2013年 YANG HONGBO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

extern NSString * const BluetoothCentralManagerReadyToUseNotification;
extern NSString * const BluetoothCentralManagerUnavailableNotification;
extern NSString * const BluetoothCentralManagerDidDiscoverPeripheralNotification;
extern NSString * const BluetoothCentralManagerDidConnectPeripheralNotification;
extern NSString * const BluetoothCentralManagerDidFailToConnectPeripheralNotification;
extern NSString * const BluetoothCentralManagerDidDisconnectPeripheralNotification;
extern NSString * const BluetoothCentralStateKey;
extern NSString * const PeripheralAdvertisementDataKey;
extern NSString * const PeripheralRSSIKey;
extern NSString * const PeripheralErrorKey;

extern NSString * const BluetoothServiceDeviceInfomationKey;
extern NSString * const BluetoothServiceDeviceInfomationServiceKey;
extern NSString * const BluetoothServiceDeviceInfomationSystemIdKey;
extern NSString * const BluetoothServiceDeviceInfomationManufacturerNameKey;
extern NSString * const BluetoothServiceDeviceInfomationModelNumberKey;
extern NSString * const BluetoothServiceDeviceInfomationSerialNumberKey;
extern NSString * const BluetoothServiceDeviceInfomationHardwareRevisionKey;
extern NSString * const BluetoothServiceDeviceInfomationFirmwareRevisionKey;
extern NSString * const BluetoothServiceDeviceInfomationSoftwareRevisionKey;
extern NSString * const BluetoothServiceDeviceInfomationRegulatoryCertificationDataListKey;
extern NSString * const BluetoothServiceDeviceInfomationPnPIDKey;

@interface BluetoothCentralManager : NSObject
@property (nonatomic, assign, readwrite, getter = isScanning) BOOL scanning;
@property (nonatomic, strong, readonly) NSDictionary * services;
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

@interface CBService (UUIDString)
- (NSString *)UUIDString;
@end

@interface CBCharacteristic (UUIDString)
- (NSString *)UUIDString;
@end

@interface CBUUID (UUIDString)
- (NSString *)UUIDString;
@end
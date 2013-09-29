//
//  PeripheralViewController.h
//  BluetoothWorkbench
//
//  Created by YANG HONGBO on 2013-9-27.
//  Copyright (c) 2013年 YANG HONGBO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface PeripheralViewController : UITableViewController
@property (nonatomic, retain, readwrite) CBPeripheral* peripheral;

@end

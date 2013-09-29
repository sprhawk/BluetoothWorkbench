//
//  PeripheralViewController.m
//  BluetoothWorkbench
//
//  Created by YANG HONGBO on 2013-9-27.
//  Copyright (c) 2013年 YANG HONGBO. All rights reserved.
//

#import "PeripheralViewController.h"
#import "BluetoothCentralManager.h"

@interface PeripheralViewController () <CBPeripheralDelegate>
{
    NSMutableSet * _observers;
    NSMutableArray * _servicesUUIDs;
    NSMutableDictionary * _services;
    NSMutableDictionary * _characteristics; //Service[]
}
@end

@implementation PeripheralViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    for (id o in _observers) {
        [[NSNotificationCenter defaultCenter] removeObserver:o];
    }
    [_observers removeAllObjects];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    if (!_servicesUUIDs) {
        _servicesUUIDs = [NSMutableArray arrayWithCapacity:3];
    }
    if (!_services) {
        _services = [NSMutableDictionary dictionaryWithCapacity:3];
    }
    if (!_characteristics) {
        _characteristics = [NSMutableDictionary dictionaryWithCapacity:3];
    }
    
    [self setupPeripheralNotifications];

    self.peripheral.delegate = self;
    if (!self.peripheral.isConnected) {
        [[BluetoothCentralManager defaultManager] connectPeripheral:self.peripheral];
    }
    
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.peripheral.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    self.peripheral.delegate = nil;
    [[BluetoothCentralManager defaultManager] cancelConnectionToPeripheral:self.peripheral];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return self.peripheral.services.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    CBService * s = self.peripheral.services[section];
    return s.UUIDString;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    CBService * s = self.peripheral.services[section];
    return s.characteristics.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    CBService * s = self.peripheral.services[indexPath.section];
    CBCharacteristic * c = s.characteristics[indexPath.row];
    cell.textLabel.text = c.UUIDString;
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

#pragma mark - 
- (void)setupPeripheralNotifications
{
    if (!_observers) {
        _observers = [NSMutableSet setWithCapacity:3];
        
        NSNotificationCenter * c = [NSNotificationCenter defaultCenter];
        id o;
        o = [c addObserverForName:BluetoothCentralManagerDidConnectPeripheralNotification
                           object:nil
                            queue:nil
                       usingBlock:^(NSNotification *note) {
//                           CBUUID * uuid = [BluetoothCentralManager defaultManager].services[BluetoothServiceDeviceInfomationServiceKey];
                           [self.peripheral discoverServices:nil];
                       }];
        [_observers addObject:o];
        
        o = [c addObserverForName:BluetoothCentralManagerDidFailToConnectPeripheralNotification
                           object:nil
                            queue:nil
                       usingBlock:^(NSNotification *note) {
                           
                       }];
        [_observers addObject:o];
        
        o = [c addObserverForName:BluetoothCentralManagerDidDisconnectPeripheralNotification
                           object:nil
                            queue:nil
                       usingBlock:^(NSNotification *note) {
                           [self.tableView reloadData];
                       }];
        [_observers addObject:o];
    }
}

- (void)clearPeripheralNotifications
{
    
}

#pragma mark - peripheral delgate

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    [self.tableView insertSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, peripheral.services.count)]
                  withRowAnimation:UITableViewRowAnimationAutomatic];
    for (int i = 0; i < peripheral.services.count; i ++) {
        CBService * s = peripheral.services[i];
        [peripheral discoverCharacteristics:nil forService:s];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:[peripheral.services indexOfObject:service]]
                  withRowAnimation:UITableViewRowAnimationAutomatic];
    
    CBUUID * uuid = [BluetoothCentralManager defaultManager].services[BluetoothServiceDeviceInfomationKey][BluetoothServiceDeviceInfomationServiceKey];
    if ([service.UUID isEqual:uuid]) {
        uuid = [BluetoothCentralManager defaultManager].services[BluetoothServiceDeviceInfomationKey][BluetoothServiceDeviceInfomationSystemIdKey];
        for (CBCharacteristic *c in service.characteristics) {
            if([c.UUID isEqual:uuid]) {
                [self.peripheral readValueForCharacteristic:c];
            }
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverIncludedServicesForService:(CBService *)service error:(NSError *)error
{
    
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    CBUUID *uuid = [BluetoothCentralManager defaultManager].services[BluetoothServiceDeviceInfomationKey][BluetoothServiceDeviceInfomationSystemIdKey];
    if ([uuid isEqual:characteristic.UUID]) {
        NSData * data = characteristic.value;
        if (8 == data.length) {
            int64_t * littleSysId = (int64_t *)data.bytes;
            int64_t sysid = CFSwapInt64LittleToHost(*littleSysId);
            NSLog(@"sysid:%llX", sysid);
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error
{
    
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error
{
    
}

- (void)peripheralDidUpdateName:(CBPeripheral *)peripheral
{
    
}

- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error
{
    
}

@end

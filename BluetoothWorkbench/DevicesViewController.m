//
//  DevicesViewController.m
//  BluetoothWorkbench
//
//  Created by YANG HONGBO on 2013-8-14.
//  Copyright (c) 2013年 YANG HONGBO. All rights reserved.
//

#import "DevicesViewController.h"
#import "BluetoothCentralManager.h"

@interface DevicesViewController () <CBPeripheralDelegate>
{
    NSMutableSet * _observers;
}
@end

@implementation DevicesViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        [self setupNotifications];
        
    }
    return self;
}

- (void)awakeFromNib
{
    [self setupNotifications];
}

- (void)dealloc
{
    [self cleanupNotifications];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    BluetoothCentralManager * _central = [BluetoothCentralManager defaultManager];
    if (CBCentralManagerStatePoweredOn == [_central state]) {
        self.scanBarButtonItem.enabled = YES;
    }
    else {
        self.scanBarButtonItem.enabled = NO;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
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

#pragma mark - Setup Notifications
- (void)setupNotifications
{
    if (nil == _observers) {
        _observers = [NSMutableSet setWithCapacity:10];
        
        NSNotificationCenter * c = [NSNotificationCenter defaultCenter];
        __weak BluetoothCentralManager * _central = [BluetoothCentralManager defaultManager];
        __weak DevicesViewController * controller = self;
        id observer = nil;
        observer =
        [c addObserverForName:BluetoothCentralManagerReadyToUseNotification
                       object:nil
                        queue:nil
                   usingBlock:^(NSNotification *note) {
                       controller.scanBarButtonItem.enabled = YES;
                   }];
        [_observers addObject:observer];
        
        observer =
        [c addObserverForName:BluetoothCentralManagerUnavailableNotification
                       object:nil
                        queue:nil
                   usingBlock:^(NSNotification *note) {
                       controller.scanBarButtonItem.enabled = NO;
                   }];
        
        [_observers addObject:observer];
        
        observer =
        [c addObserverForName:BluetoothCentralManagerDidDiscoverPeripheralNotification
                       object:nil
                        queue:nil
                   usingBlock:^(NSNotification *note) {
                       CBPeripheral * p = note.object;
                       if (p) {
                           NSLog(@"Discovered:%@ RSSI:%.3f", p.name, [note.userInfo[PeripheralRSSIKey] floatValue]);
                           if(!p.isConnected) {
                               [_central connectPeripheral:p];
                           }
                       }
                   }];
        
        [_observers addObject:observer];
        
        observer =
        [c addObserverForName:BluetoothCentralManagerDidConnectPeripheralNotification
                       object:nil
                        queue:nil
                   usingBlock:^(NSNotification *note) {
                       CBPeripheral * p = note.object;
                       p.delegate = self;
                       NSLog(@"Connected:%@", p.name);
                       [p readRSSI];
                       [p discoverServices:nil];
                   }];
        
        [_observers addObject:observer];
        
        observer =
        [c addObserverForName:BluetoothCentralManagerDidFailToConnectPeripheralNotification
                       object:nil
                        queue:nil
                   usingBlock:^(NSNotification *note) {
                       
                   }];
        
        [_observers addObject:observer];
        
        observer =
        [c addObserverForName:BluetoothCentralManagerDidDisconnectPeripheralNotification
                       object:nil
                        queue:nil
                   usingBlock:^(NSNotification *note) {
                       
                   }];
        [_observers addObject:observer];
    }
    
}

- (void)cleanupNotifications
{
    NSNotificationCenter * c = [NSNotificationCenter defaultCenter];
    for (id o in _observers) {
        [c removeObserver:o];
    }
    [_observers removeAllObjects];
    
}
- (IBAction)scan:(id)sender {
    BluetoothCentralManager * mgr = [BluetoothCentralManager defaultManager];
    if (!mgr.isScanning) {
        [mgr scan];
        self.scanBarButtonItem.title = @"stop";
    }
    else {
        [mgr stopScan];
        self.scanBarButtonItem.title = @"scan";
    }
}

- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"update RSSI:%.2f", [peripheral.RSSI floatValue]);
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    NSLog(@"available services:%d", peripheral.services.count);
    for (CBService * s in peripheral.services) {
        [peripheral discoverCharacteristics:nil forService:s];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    NSArray * cs = service.characteristics;
    NSLog(@"available characteristics:%d", [cs count]);
    for (CBCharacteristic * c in cs) {
        
    }
}
@end

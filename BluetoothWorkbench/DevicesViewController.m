//
//  DevicesViewController.m
//  BluetoothWorkbench
//
//  Created by YANG HONGBO on 2013-8-14.
//  Copyright (c) 2013年 YANG HONGBO. All rights reserved.
//

#import "DevicesViewController.h"
#import "BluetoothCentralManager.h"
#import "PeripheralViewController.h"

 static NSString *CellIdentifier = @"Cell";

@interface DevicesViewController () <CBPeripheralDelegate>
{
    NSMutableSet * _observers;
    NSMutableArray * _peripherals;
}
@end

@implementation DevicesViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        [self setup];
        
    }
    return self;
}

- (void)awakeFromNib
{
    [self setup];
}

- (void)dealloc
{
    [self cleanup];
}

- (void)setup
{
    if (!_peripherals) {
        _peripherals = [NSMutableArray arrayWithCapacity:5];
    }
    [self setupNotifications];
}

- (void)cleanup
{
    _peripherals = nil;
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
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _peripherals.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    CBPeripheral * p = _peripherals[indexPath.row];
    cell.textLabel.text = p.name;
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


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UITableViewCell * c = (UITableViewCell *)sender;
    NSIndexPath * indexPath = [self.tableView indexPathForCell:c];
    CBPeripheral * p = _peripherals[indexPath.row];
    PeripheralViewController * v = (PeripheralViewController *)segue.destinationViewController;
    v.peripheral = p;
}

#pragma mark - Setup Notifications
- (void)setupNotifications
{
    if (nil == _observers) {
        _observers = [NSMutableSet setWithCapacity:10];
        
        NSNotificationCenter * c = [NSNotificationCenter defaultCenter];
//        __weak BluetoothCentralManager * _central = [BluetoothCentralManager defaultManager];
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
                           NSData * d = note.userInfo[PeripheralAdvertisementDataKey];
                           if (d) {
                               NSLog(@"data:%@", d);
                           }
                           [self.tableView beginUpdates];
                           [_peripherals addObject:p];
                           [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_peripherals.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
                           [self.tableView endUpdates];

                       }
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
//    NSLog(@"available services:%d", peripheral.services.count);
//    for (CBService * s in peripheral.services) {
//        [peripheral discoverCharacteristics:nil forService:s];
//    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
//    NSArray * cs = service.characteristics;
//    NSLog(@"available characteristics:%d", [cs count]);
//    for (CBCharacteristic * c in cs) {
//        
//    }
}


@end

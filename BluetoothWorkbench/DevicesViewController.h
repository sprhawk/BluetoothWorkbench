//
//  DevicesViewController.h
//  BluetoothWorkbench
//
//  Created by YANG HONGBO on 2013-8-14.
//  Copyright (c) 2013年 YANG HONGBO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DevicesViewController : UITableViewController
@property (weak, nonatomic) IBOutlet UIBarButtonItem *scanBarButtonItem;
- (IBAction)scan:(id)sender;

@end

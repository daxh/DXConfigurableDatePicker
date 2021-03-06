//
//  ViewController.h
//  DXConfigurableDatePickerExample
//
//  Created by Denis Suprun on 12/03/15.
//  Copyright (c) 2015 daxh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DXConfigurableDatePicker.h"

@interface ViewController : UIViewController
<DXConfigurableDatePickerDelegate>
@property (nonatomic, strong) IBOutlet DXConfigurableDatePicker * confDatePicker;
@property (nonatomic, strong) IBOutlet UISegmentedControl * segment;
@property (nonatomic, strong) IBOutlet UISwitch * switcher;
@property (nonatomic, strong) IBOutlet UILabel * label;

@end


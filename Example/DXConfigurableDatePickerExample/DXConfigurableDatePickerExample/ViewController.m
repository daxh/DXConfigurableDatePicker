//
//  ViewController.m
//  DXConfigurableDatePickerExample
//
//  Created by Denis Suprun on 12/03/15.
//  Copyright (c) 2015 daxh. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

-(void)configurableDatePickerWillChangeDate:(DXConfigurableDatePicker *)picker{
}

-(void)configurableDatePickerDidChangeDate:(DXConfigurableDatePicker *)picker{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    if (picker.dateFormat == DXConfigurableDatePickerFormatNoDay) {
        [formatter setDateFormat:@"MMMM YYYY"];
    } else if (picker.dateFormat == DXConfigurableDatePickerFormatNormal) {
        [formatter setDateFormat:@"d MMMM YYYY"];
    } else if (picker.dateFormat == DXConfigurableDatePickerFormatYearOnly) {
        [formatter setDateFormat:@"YYYY"];
    }

    self.label.text = [formatter stringFromDate:picker.date];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self.segment addTarget:self
                     action:@selector(segmentValueChanged:)
           forControlEvents:UIControlEventValueChanged];
    
    [self.switcher addTarget:self
                      action:@selector(switcherValueChanged:)
            forControlEvents:UIControlEventValueChanged];
    
    self.confDatePicker.configurableDatePickerDelegate = self;
    [self configurableDatePickerDidChangeDate:self.confDatePicker];
}

-(void)segmentValueChanged:(id)sender{
    switch (((UISegmentedControl *)sender).selectedSegmentIndex) {
        case 0:
            [self.confDatePicker setDateFormat:DXConfigurableDatePickerFormatNormal];
            break;
        case 1:
            [self.confDatePicker setDateFormat:DXConfigurableDatePickerFormatNoDay];
            break;
        case 2:
            [self.confDatePicker setDateFormat:DXConfigurableDatePickerFormatYearOnly];
            break;
        default:
            [self.confDatePicker setDateFormat:DXConfigurableDatePickerFormatNormal];
            break;
    }
}

-(void)switcherValueChanged:(id)sender{
    [self.confDatePicker setKeepHiddenComponentsWidth:((UISwitch *)sender).isOn];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

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
//    self.label.text = picker.date.description;
}

-(void)configurableDatePickerDidChangeDate:(DXConfigurableDatePicker *)picker{
    NSCalendar * cal = [NSCalendar currentCalendar];
    NSDateComponents * dc = [cal components:NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear fromDate:picker.date];
    self.label.text = [NSString stringWithFormat:@"%@ \n %ld:%ld:%ld", picker.date.description, (long)dc.month, (long)dc.day, (long)dc.year];
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

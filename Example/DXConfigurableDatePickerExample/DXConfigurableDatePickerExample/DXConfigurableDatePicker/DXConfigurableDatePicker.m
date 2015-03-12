//
//  DXConfigurableDatePicker.m
//  DXConfigurableDatePickerExample
//
//  Created by Denis Suprun on 12/03/15.
//  Copyright (c) 2015 daxh. All rights reserved.
//

#import "DXConfigurableDatePicker.h"

@interface DXConfigurableDatePicker()

@property (nonatomic, readonly) NSArray* monthStrings;

@end

@implementation DXConfigurableDatePicker

@synthesize date = _date;
@synthesize monthStrings = _monthStrings;
@synthesize enableColourRow = _enableColourRow;
@synthesize configurableDatePickerDelegate = _configurableDatePickerDelegate;

-(id)initWithDate:(NSDate *)date{
    self = [super init];
    if (self) {
        [self initialize];
        [self setDate:date];
        self.showsSelectionIndicator = YES;
    }
    
    return self;
}

-(id)init{
    self = [self initWithDate:[NSDate date]];
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
        [self initialize];
        if (!_date)
            [self setDate:[NSDate date]];
    }
    
    return self;
}

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        [self initialize];
        if (!_date)
            [self setDate:[NSDate date]];
    }
    
    return self;
}

-(void) initialize{
    self.dataSource = self;
    self.delegate = self;
    
    _enableColourRow = YES;
    _wrapMonths = YES;
}

-(id<UIPickerViewDelegate>)delegate
{
    return self;
}

-(void)setDelegate:(id<UIPickerViewDelegate>)delegate
{
    if ([delegate isEqual:self])
        [super setDelegate:delegate];
}

-(id<UIPickerViewDataSource>)dataSource
{
    return self;
}

-(void)setDataSource:(id<UIPickerViewDataSource>)dataSource
{
    if ([dataSource isEqual:self])
        [super setDataSource:dataSource];
}

-(int)monthComponent
{
    return self.yearComponent ^ 1;
}

-(int)yearComponent
{
    return !self.yearFirst;
}

-(NSArray *)monthStrings
{
    return [[NSDateFormatter alloc] init].monthSymbols;
}


#pragma mark - UIPickerViewDataSource

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 3;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return 50;
}

-(CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{
    return 50.0f;
}

-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel *lbl;
    if (view == nil) {
        lbl = [[UILabel alloc] init];
        NSLog(@"Label allocated for row#%ld & component#%ld", row, component);
    } else {
        lbl = (UILabel *)view;
        NSLog(@"Label reused for row#%ld & component#%ld", row, component);
    }
    
    lbl.text = [NSString stringWithFormat:@"%ld", (long)row];
    
    return lbl;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

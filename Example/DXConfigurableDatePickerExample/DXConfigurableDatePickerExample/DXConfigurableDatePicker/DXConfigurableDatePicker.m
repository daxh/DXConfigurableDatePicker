//
//  DXConfigurableDatePicker.m
//  DXConfigurableDatePickerExample
//
//  Created by Denis Suprun on 12/03/15.
//  Copyright (c) 2015 daxh. All rights reserved.
//

#import "DXConfigurableDatePicker.h"

#define MONTH_ROW_MULTIPLIER 340
#define DEFAULT_MINIMUM_YEAR 1
#define DEFAULT_MAXIMUM_YEAR 99999
#define DATE_COMPONENT_FLAGS NSCalendarUnitDay | NSCalendarUnitYear | NSCalendarUnitMonth

@interface DXConfigurableDatePicker()

@property (nonatomic) int componentDay;
@property (nonatomic) int componentMonth;
@property (nonatomic) int componentYear;
@property (nonatomic, readonly) NSArray* monthStrings;

-(int)yearFromRow:(NSUInteger)row;
-(NSUInteger)rowFromYear:(int)year;

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

-(int)componentDay
{
    return 1;
}

-(int)componentMonth
{
    return 0;
}

-(int)componentYear
{
    return 2;
}

-(NSArray *)monthStrings
{
    return [[NSDateFormatter alloc] init].monthSymbols;
}

//-(void)setYearFirst:(BOOL)yearFirst
//{
//    _yearFirst = yearFirst;
//    NSDate* date = self.date;
//    [self reloadAllComponents];
//    [self setNeedsLayout];
//    [self setDate:date];
//}

-(void)setMinimumYear:(NSNumber *)minimumYear
{
    NSDate* currentDate = self.date;
    NSDateComponents* components = [[NSCalendar currentCalendar] components:DATE_COMPONENT_FLAGS fromDate:currentDate];
    components.timeZone = [NSTimeZone defaultTimeZone];
    
    if (minimumYear && components.year < minimumYear.integerValue)
        components.year = minimumYear.integerValue;
    
    _minimumYear = minimumYear;
    [self reloadAllComponents];
    [self setDate:[[NSCalendar currentCalendar] dateFromComponents:components]];
}

-(void)setMaximumYear:(NSNumber *)maximumYear
{
    NSDate* currentDate = self.date;
    NSDateComponents* components = [[NSCalendar currentCalendar] components:DATE_COMPONENT_FLAGS fromDate:currentDate];
    components.timeZone = [NSTimeZone defaultTimeZone];
    
    if (maximumYear && components.year > maximumYear.integerValue)
        components.year = maximumYear.integerValue;
    
    _maximumYear = maximumYear;
    [self reloadAllComponents];
    [self setDate:[[NSCalendar currentCalendar] dateFromComponents:components]];
}

-(void)setWrapMonths:(BOOL)wrapMonths
{
    _wrapMonths = wrapMonths;
    [self reloadAllComponents];
}

-(int)yearFromRow:(NSUInteger)row
{
    int minYear = DEFAULT_MINIMUM_YEAR;
    
    if (self.minimumYear)
        minYear = self.minimumYear.intValue;
    
    return (int)row + minYear;
}

-(NSUInteger)rowFromYear:(int)year
{
    int minYear = DEFAULT_MINIMUM_YEAR;
    
    if (self.minimumYear)
        minYear = self.minimumYear.intValue;
    
    return year - minYear;
}

-(void)setDate:(NSDate *)date
{
    NSDateComponents* components = [[NSCalendar currentCalendar] components:DATE_COMPONENT_FLAGS fromDate:date];
    components.timeZone = [NSTimeZone defaultTimeZone];
    
    if (self.minimumYear && components.year < self.minimumYear.integerValue)
        components.year = self.minimumYear.integerValue;
    else if (self.maximumYear && components.year > self.maximumYear.integerValue)
        components.year = self.maximumYear.integerValue;
    
    if(self.wrapMonths){
        NSInteger monthMidpoint = self.monthStrings.count * (MONTH_ROW_MULTIPLIER / 2);
        
        [self selectRow:(components.month - 1 + monthMidpoint) inComponent:self.componentMonth animated:NO];
    }
    else {
        [self selectRow:(components.month - 1) inComponent:self.componentMonth animated:NO];
    }
    [self selectRow:[self rowFromYear:(int)components.year] inComponent:self.componentYear animated:NO];
    
    _date = [[NSCalendar currentCalendar] dateFromComponents:components];
}

#pragma mark - UIPickerViewDataSource

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSDateComponents* components = [[NSDateComponents alloc] init];
    components.month = 1 + ([self selectedRowInComponent:self.componentMonth] % self.monthStrings.count);
    components.year = [self yearFromRow:[self selectedRowInComponent:self.componentYear]];
    
    [self willChangeValueForKey:@"date"];
    if ([self.configurableDatePickerDelegate respondsToSelector:@selector(configurableDatePickerWillChangeDate:)])
        [self.configurableDatePickerDelegate configurableDatePickerWillChangeDate:self];
    
    _date = [[NSCalendar currentCalendar] dateFromComponents:components];
    
    if ([self.configurableDatePickerDelegate respondsToSelector:@selector(configurableDatePickerDidChangeDate:)])
        [self.configurableDatePickerDelegate configurableDatePickerDidChangeDate:self];
    [self didChangeValueForKey:@"date"];
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 3;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component == self.componentMonth && !self.wrapMonths)
        return self.monthStrings.count;
    else if(component == self.componentMonth)
        return MONTH_ROW_MULTIPLIER * self.monthStrings.count;
    
    int maxYear = DEFAULT_MAXIMUM_YEAR;
    if (self.maximumYear)
        maxYear = self.maximumYear.intValue;
    
    return [self rowFromYear:maxYear] + 1;
}

-(CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    if (component == self.componentMonth)
        return 132.0f;
    else
        return 76.0f;
}

-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 32.0f;
}

-(UIView *)pickerView:(UIPickerView *)pickerView
           viewForRow:(NSInteger)row
         forComponent:(NSInteger)component
          reusingView:(UIView *)view{
    CGFloat width = [self pickerView:self widthForComponent:component];
    CGRect frame = CGRectMake(0.0f, 0.0f, width, 45.0f);
    
    if (component == self.componentMonth)
    {
        const CGFloat padding = 37.0f;
        if (component) {
            frame.origin.x += padding;
            frame.size.width -= padding;
        }
        
        frame.size.width -= padding;
    }
    
    UILabel * label = (UILabel *)view;
    if (label == nil) {
        // Trying ti reuse view if possible
        label = [[UILabel alloc] initWithFrame:frame];
        //    if (_enableColourRow && [[formatter stringFromDate:[NSDate date]] isEqualToString:label.text])
        //        label.textColor = [UIColor colorWithRed:0.0f green:0.35f blue:0.91f alpha:1.0f];
        label.font = [UIFont systemFontOfSize:24.0f];
        label.backgroundColor = [UIColor clearColor];
        label.shadowOffset = CGSizeMake(0.0f, 0.1f);
        label.shadowColor = [UIColor whiteColor];
    }
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    if (component == self.componentDay) {
        label.text = [NSString stringWithFormat:@"%ld", row];
        label.textAlignment = NSTextAlignmentCenter;
        formatter.dateFormat = @"d";
    } else if (component == self.componentMonth) {
        label.text = [self.monthStrings objectAtIndex:(row % self.monthStrings.count)];
        formatter.dateFormat = @"MMMM";
        label.textAlignment = NSTextAlignmentLeft;
    } else {
        label.text = [NSString stringWithFormat:@"%d", [self yearFromRow:row]];
        label.textAlignment = NSTextAlignmentLeft;
        formatter.dateFormat = @"y";
    }
    
    return label;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

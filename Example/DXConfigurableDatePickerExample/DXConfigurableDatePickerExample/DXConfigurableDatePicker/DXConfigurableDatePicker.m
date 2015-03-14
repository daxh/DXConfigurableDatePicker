/*
 Copyright (C) 2014-2015 Denis Suprun
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

#import "DXConfigurableDatePicker.h"

#define DATE_COMPONENT_FLAGS NSCalendarUnitDay | NSCalendarUnitYear | NSCalendarUnitMonth
#define MONTH_ROW_MULTIPLIER 340
#define DEFAULT_MAX_NUM_OF_DAYS 31
#define DAY_ROW_MULTIPLIER 340
#define DEFAULT_MINIMUM_YEAR 1
#define DEFAULT_MAXIMUM_YEAR 99999

@interface DXConfigurableDatePicker()

@property (nonatomic, strong) NSCalendar * calendar;

@property (nonatomic) int componentDay;
@property (nonatomic) int componentMonth;
@property (nonatomic) int componentYear;
@property (nonatomic, readonly) NSArray* monthStrings;

-(int)yearFromRow:(NSUInteger)row;
-(NSUInteger)rowFromYear:(int)year;

@end

@implementation DXConfigurableDatePicker

@synthesize calendar = _calendar;
@synthesize date = _date;
@synthesize monthStrings = _monthStrings;
@synthesize enableColourRow = _enableColourRow;
@synthesize configurableDatePickerDelegate = _configurableDatePickerDelegate;

#pragma mark - SET UP

-(id)initWithDate:(NSDate *)date {
    self = [super init];
    if (self) {
        [self initialize];
        [self setDate:date];
        self.showsSelectionIndicator = YES;
    }
    
    return self;
}

-(id)init {
    self = [self initWithDate:[NSDate date]];
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
        [self initialize];
        if (!_date)
            [self setDate:[NSDate date]];
    }
    
    return self;
}

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self)
    {
        [self initialize];
        if (!_date)
            [self setDate:[NSDate date]];
    }
    
    return self;
}

-(void) initialize {
    self.dataSource = self;
    self.delegate = self;
    
    self.calendar = [NSCalendar currentCalendar];
    _enableColourRow = YES;
    _wrapMonths = YES;
    _wrapDays = YES;
}

-(id<UIPickerViewDelegate>)delegate {
    return self;
}

-(void)setDelegate:(id<UIPickerViewDelegate>)delegate {
    if ([delegate isEqual:self])
        [super setDelegate:delegate];
}

-(id<UIPickerViewDataSource>)dataSource {
    return self;
}

-(void)setDataSource:(id<UIPickerViewDataSource>)dataSource {
    if ([dataSource isEqual:self])
        [super setDataSource:dataSource];
}

-(int)componentDay {
    return 1;
}

-(int)componentMonth {
    return 0;
}

-(int)componentYear {
    return 2;
}

-(void)setDate:(NSDate *)date {
    NSDateComponents* components = [[NSCalendar currentCalendar] components:DATE_COMPONENT_FLAGS fromDate:date];
    components.timeZone = [NSTimeZone defaultTimeZone];
    
    // setting months
    if(self.wrapMonths){
        NSInteger monthMidpoint = self.monthStrings.count * (MONTH_ROW_MULTIPLIER / 2);
        [self selectRow:(components.month - 1 + monthMidpoint) inComponent:self.componentMonth animated:NO];
    }
    else {
        [self selectRow:(components.month - 1) inComponent:self.componentMonth animated:NO];
    }

    // setting days
    if (self.wrapDays) {
        // TODO complete this part
        NSInteger dayMidpoint = DEFAULT_MAX_NUM_OF_DAYS * (MONTH_ROW_MULTIPLIER / 2);
        [self selectRow:[self rowFromDay:(components.day + dayMidpoint)] inComponent:self.componentDay animated:NO];
    } else {
        [self selectRow:[self rowFromDay:components.day] inComponent:self.componentDay animated:NO];
    }

    // setting years
    if (self.minimumYear && components.year < self.minimumYear.integerValue)
        components.year = self.minimumYear.integerValue;
    else if (self.maximumYear && components.year > self.maximumYear.integerValue)
        components.year = self.maximumYear.integerValue;
    [self selectRow:[self rowFromYear:(int)components.year] inComponent:self.componentYear animated:NO];
    
    _date = [[NSCalendar currentCalendar] dateFromComponents:components];
}

#pragma mark - YEARS

//-(void)setYearFirst:(BOOL)yearFirst
//{
//    _yearFirst = yearFirst;
//    NSDate* date = self.date;
//    [self reloadAllComponents];
//    [self setNeedsLayout];
//    [self setDate:date];
//}

-(void)setMinimumYear:(NSNumber *)minimumYear {
    NSDate* currentDate = self.date;
    NSDateComponents* components = [[NSCalendar currentCalendar] components:DATE_COMPONENT_FLAGS fromDate:currentDate];
    components.timeZone = [NSTimeZone defaultTimeZone];
    
    if (minimumYear && components.year < minimumYear.integerValue)
        components.year = minimumYear.integerValue;
    
    _minimumYear = minimumYear;
    [self reloadAllComponents];
    [self setDate:[[NSCalendar currentCalendar] dateFromComponents:components]];
}

-(void)setMaximumYear:(NSNumber *)maximumYear {
    NSDate* currentDate = self.date;
    NSDateComponents* components = [[NSCalendar currentCalendar] components:DATE_COMPONENT_FLAGS fromDate:currentDate];
    components.timeZone = [NSTimeZone defaultTimeZone];
    
    if (maximumYear && components.year > maximumYear.integerValue)
        components.year = maximumYear.integerValue;
    
    _maximumYear = maximumYear;
    [self reloadAllComponents];
    [self setDate:[[NSCalendar currentCalendar] dateFromComponents:components]];
}

-(int)yearFromRow:(NSUInteger)row {
    int minYear = DEFAULT_MINIMUM_YEAR;
    
    if (self.minimumYear)
        minYear = self.minimumYear.intValue;
    
    return (int)row + minYear;
}

-(NSUInteger)rowFromYear:(int)year {
    int minYear = DEFAULT_MINIMUM_YEAR;
    
    if (self.minimumYear)
        minYear = self.minimumYear.intValue;
    
    return year - minYear;
}

#pragma mark - MONTHS

-(NSArray *)monthStrings {
    return [[NSDateFormatter alloc] init].monthSymbols;
}

-(void)setWrapMonths:(BOOL)wrapMonths {
    _wrapMonths = wrapMonths;
    [self reloadAllComponents];
}

-(NSUInteger) monthFromRow:(NSUInteger) row {
    return row % self.monthStrings.count + 1;
}

-(NSString *) monthStringFromRow:(NSUInteger) row {
    return self.monthStrings[[self monthFromRow:row] - 1];
}

#pragma mark - DAYS

-(void)setWrapDays:(BOOL)wrapDays {
    _wrapDays = wrapDays;
    [self reloadAllComponents];
}

-(NSUInteger) findDayAdjustment:(NSUInteger) day {
    NSDateComponents* components = [self.calendar components:DATE_COMPONENT_FLAGS fromDate:[NSDate date]];
    components.timeZone = [NSTimeZone defaultTimeZone];
    components.year = [self yearFromRow:[self selectedRowInComponent:self.componentYear]];
    components.month = [self monthFromRow:[self selectedRowInComponent:self.componentMonth]];
    NSDate * date = [self.calendar dateFromComponents:components];
    NSRange rng = [self.calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date];
    return (day >= rng.location && day <=rng.length) ? 0 : day - rng.length;
}

-(NSUInteger) dayFromRow:(NSUInteger) row {
    return row % DEFAULT_MAX_NUM_OF_DAYS + 1;
}

-(NSUInteger) rowFromDay:(NSUInteger) day {
    if (self.wrapDays) {
        // select row determined by day but nearest to curently selected row
        NSUInteger row = [self selectedRowInComponent:self.componentDay];
        NSUInteger wrap_padding = row / DEFAULT_MAX_NUM_OF_DAYS;
        return wrap_padding * DEFAULT_MAX_NUM_OF_DAYS + day - 1;
    }

    return day - 1;
}

#pragma mark - UIPickerViewDataSource

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSUInteger day = [self dayFromRow:[self selectedRowInComponent:self.componentDay]];
    NSUInteger dayAdjustment = [self findDayAdjustment:day];
    if (dayAdjustment > 0) {
        day -= dayAdjustment;
        [self selectRow:[self rowFromDay:day] inComponent:self.componentDay animated:YES];
    }
    
    NSDateComponents* components = [[NSDateComponents alloc] init];
    components.day = day;
    components.month = [self monthFromRow:[self selectedRowInComponent:self.componentMonth]];
    components.year = [self yearFromRow:[self selectedRowInComponent:self.componentYear]];
    
    [self willChangeValueForKey:@"date"];
    if ([self.configurableDatePickerDelegate respondsToSelector:@selector(configurableDatePickerWillChangeDate:)])
        [self.configurableDatePickerDelegate configurableDatePickerWillChangeDate:self];
    
    _date = [[NSCalendar currentCalendar] dateFromComponents:components];
    
    if ([self.configurableDatePickerDelegate respondsToSelector:@selector(configurableDatePickerDidChangeDate:)])
        [self.configurableDatePickerDelegate configurableDatePickerDidChangeDate:self];
    [self didChangeValueForKey:@"date"];
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 3;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    NSInteger numberOfRows = 0;
    if (component == self.componentDay){
        //TODO complete this stuff
        numberOfRows = !self.wrapDays ? DEFAULT_MAX_NUM_OF_DAYS :
                    DAY_ROW_MULTIPLIER * DEFAULT_MAX_NUM_OF_DAYS;
    } else if (component == self.componentMonth)
        numberOfRows = !self.wrapMonths ? self.monthStrings.count :
                   MONTH_ROW_MULTIPLIER * self.monthStrings.count ;
    else if (component == self.componentYear){
        int maxYear = DEFAULT_MAXIMUM_YEAR;
        if (self.maximumYear)
            maxYear = self.maximumYear.intValue;
        numberOfRows = [self rowFromYear:maxYear] + 1;
    }
    
    NSLog(@"comp %ld no_rows %ld", component, numberOfRows);
    return numberOfRows;
}

-(CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    if (component == self.componentMonth)
        return 119.0f;
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
    
    if (component == self.componentMonth) {
        const CGFloat padding = 20.0f;
        frame.origin.x += padding;
        frame.size.width -= padding;
    } else if (component == self.componentYear) {
        const CGFloat padding = 10.0f;
        frame.origin.x += padding;
        frame.size.width -= padding;
    }
    
    UILabel * label = (UILabel *)view;
    // Trying ti reuse view if possible
    if (label == nil) {
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
        label.text = [NSString stringWithFormat:@"%ld", [self dayFromRow:row]];
        label.textAlignment = NSTextAlignmentCenter;
        formatter.dateFormat = @"d";
    } else if (component == self.componentMonth) {
        label.text = [self monthStringFromRow:row];
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

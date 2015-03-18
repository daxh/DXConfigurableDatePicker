
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

static const int dateComponentFlags = NSCalendarUnitDay | NSCalendarUnitYear | NSCalendarUnitMonth;
static const int rowMultiplierMonths = 340;
static const int rowMultiplierDays = 340;
static const int maxNumOfDays = 31;
static const int minValOfYear = 1;
static const int maxValOfYear = 99999;

static const CGFloat baseTotalComponentsWidth = 300.0f;
static const CGFloat componentWidthDayCoef = 0.285f;
static const CGFloat componentWidthMonthCoef = 0.44f;
static const CGFloat componentWidthYearCoef = 0.3f;
static const CGFloat componentWidthMonthPaddingCoef = 0.09f;

@interface DXConfigurableDatePicker()

@property (nonatomic, strong) NSCalendar * calendar;

@property (nonatomic) CGFloat totalComponentsWidthScale;
@property (nonatomic) CGFloat totalComponentsWidth;
@property (nonatomic) CGFloat componentWidthDay;
@property (nonatomic) CGFloat componentWidthMonth;
@property (nonatomic) CGFloat componentWidthYear;

@property (nonatomic) int componentDay;
@property (nonatomic) int componentMonth;
@property (nonatomic) int componentYear;
@property (nonatomic) int componentsNumber;


@property (nonatomic, readonly) NSArray* monthStrings;

@end

@implementation DXConfigurableDatePicker

@synthesize calendar = _calendar;
@synthesize date = _date;
@synthesize dateFormat = _dateFormat;
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
    _keepHiddenComponentsWidth = YES;
    
    self.totalComponentsWidth = self.frame.size.width/2;
    self.totalComponentsWidthScale = baseTotalComponentsWidth / self.totalComponentsWidth;
    self.componentWidthDay = componentWidthDayCoef * self.totalComponentsWidth * self.totalComponentsWidthScale;
    self.componentWidthMonth = componentWidthMonthCoef * self.totalComponentsWidth * self.totalComponentsWidthScale;
    self.componentWidthYear = componentWidthYearCoef * self.totalComponentsWidth * self.totalComponentsWidthScale;
    
    [self setDateFormat:DXConfigurableDatePickerFormatNormal];
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

-(void)setDate:(NSDate *)date {
    if (date == nil) {
        date = [NSDate date];
    }
    
    NSDateComponents* components = [[NSCalendar currentCalendar] components:dateComponentFlags fromDate:date];
    components.timeZone = [NSTimeZone defaultTimeZone];

    // setting years
    if (self.minimumYear && components.year < self.minimumYear.integerValue)
        components.year = self.minimumYear.integerValue;
    else if (self.maximumYear && components.year > self.maximumYear.integerValue)
        components.year = self.maximumYear.integerValue;
    [self selectRow:[self rowFromYear:(int)components.year] inComponent:self.componentYear animated:NO];
    
    // setting months
    if (self.componentMonth != -1){
        if(self.wrapMonths){
            NSInteger monthMidpoint = self.monthStrings.count * (rowMultiplierMonths / 2);
            [self selectRow:(components.month - 1 + monthMidpoint) inComponent:self.componentMonth animated:NO];
        }
        else {
            [self selectRow:(components.month - 1) inComponent:self.componentMonth animated:NO];
        }
    }

    // setting days
    if (self.componentDay != -1) {
        if (self.wrapDays) {
            NSInteger dayMidpoint = maxNumOfDays * (rowMultiplierDays / 2);
            [self selectRow:[self rowFromDay:(components.day + dayMidpoint)] inComponent:self.componentDay animated:NO];
        } else {
            [self selectRow:[self rowFromDay:components.day] inComponent:self.componentDay animated:NO];
        }
    }
    
    _date = [[NSCalendar currentCalendar] dateFromComponents:components];
}

-(void)setDateFormat:(DXConfigurableDatePickerFormat)dateFormat{
    _dateFormat = dateFormat;
    NSDate* date = self.date;
    [self updateComponentNumbers];
    [self reloadAllComponents];
    [self setNeedsLayout];
    [self setDate:date];
}

-(void)setKeepHiddenComponentsWidth:(BOOL)keepHiddenComponentsWidth{
    _keepHiddenComponentsWidth = keepHiddenComponentsWidth;
    NSDate* date = self.date;
    [self updateComponentNumbers];
    [self reloadAllComponents];
    [self setNeedsLayout];
    [self setDate:date];
}

-(void)updateComponentNumbers{
    if (self.keepHiddenComponentsWidth ||
        self.dateFormat == DXConfigurableDatePickerFormatNormal) {
        self.componentMonth = 0;
        self.componentDay = 1;
        self.componentYear = 2;
        self.componentsNumber = 3;
    } else if (self.dateFormat == DXConfigurableDatePickerFormatNoDay){
        self.componentMonth = 0;
        self.componentYear = 1;
        self.componentsNumber = 2;
        self.componentDay = -1;
    } else if (self.dateFormat == DXConfigurableDatePickerFormatYearOnly){
        self.componentYear = 0;
        self.componentsNumber = 1;
        self.componentDay = -1;
        self.componentMonth = -1;
    }
}

#pragma mark - YEARS

-(void)setMinimumYear:(NSNumber *)minimumYear {
    NSDate* currentDate = self.date;
    NSDateComponents* components = [[NSCalendar currentCalendar] components:dateComponentFlags fromDate:currentDate];
    components.timeZone = [NSTimeZone defaultTimeZone];
    
    if (minimumYear && components.year < minimumYear.integerValue)
        components.year = minimumYear.integerValue;
    
    _minimumYear = minimumYear;
    [self reloadAllComponents];
    [self setDate:[[NSCalendar currentCalendar] dateFromComponents:components]];
}

-(void)setMaximumYear:(NSNumber *)maximumYear {
    NSDate* currentDate = self.date;
    NSDateComponents* components = [[NSCalendar currentCalendar] components:dateComponentFlags fromDate:currentDate];
    components.timeZone = [NSTimeZone defaultTimeZone];
    
    if (maximumYear && components.year > maximumYear.integerValue)
        components.year = maximumYear.integerValue;
    
    _maximumYear = maximumYear;
    [self reloadAllComponents];
    [self setDate:[[NSCalendar currentCalendar] dateFromComponents:components]];
}

-(int)yearFromRow:(NSUInteger)row {
    int minYear = minValOfYear;
    
    if (self.minimumYear)
        minYear = self.minimumYear.intValue;
    
    return (int)row + minYear;
}

-(NSUInteger)rowFromYear:(int)year {
    int minYear = minValOfYear;
    
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
    NSDateComponents* components = [self.calendar components:dateComponentFlags fromDate:[NSDate date]];
    components.timeZone = [NSTimeZone defaultTimeZone];
    components.year = [self yearFromRow:[self selectedRowInComponent:self.componentYear]];
    components.month = [self monthFromRow:[self selectedRowInComponent:self.componentMonth]];
    NSDate * date = [self.calendar dateFromComponents:components];
    NSRange rng = [self.calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date];
    return (day >= rng.location && day <=rng.length) ? 0 : day - rng.length;
}

-(NSUInteger) dayFromRow:(NSUInteger) row {
    return row % maxNumOfDays + 1;
}

-(NSUInteger) rowFromDay:(NSUInteger) day {
    if (self.wrapDays) {
        // select row determined by day but nearest to curently selected row
        NSUInteger row = [self selectedRowInComponent:self.componentDay];
        NSUInteger wrap_padding = row / maxNumOfDays;
        return wrap_padding * maxNumOfDays + day - 1;
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
    return self.componentsNumber;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    NSInteger numberOfRows = 0;
    if (component == self.componentDay){
        numberOfRows = !self.wrapDays ? maxNumOfDays :
                    rowMultiplierDays * maxNumOfDays;
    } else if (component == self.componentMonth)
        numberOfRows = !self.wrapMonths ? self.monthStrings.count :
                   rowMultiplierMonths * self.monthStrings.count ;
    else if (component == self.componentYear){
        int maxYear = maxValOfYear;
        if (self.maximumYear)
            maxYear = self.maximumYear.intValue;
        numberOfRows = [self rowFromYear:maxYear] + 1;
    }
    
    return numberOfRows;
}

-(CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    if (self.dateFormat == DXConfigurableDatePickerFormatNormal || self.keepHiddenComponentsWidth) {
        if (component == self.componentMonth)
            return self.componentWidthMonth;
        if (component == self.componentDay)
            return self.componentWidthDay;
        else
            return self.componentWidthYear;
    }
    
    if (self.dateFormat == DXConfigurableDatePickerFormatNoDay) {
        return [self hideRowForComponent:component] ? 0 : self.totalComponentsWidth / 2;
    }
    
    if (self.dateFormat == DXConfigurableDatePickerFormatYearOnly) {
        return [self hideRowForComponent:component] ? 0 : self.totalComponentsWidth;
    }
    
    return 0;
}

-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 33.0f;
}

-(UIView *)pickerView:(UIPickerView *)pickerView
           viewForRow:(NSInteger)row
         forComponent:(NSInteger)component
          reusingView:(UIView *)view{
    // Trying to reuse view if possible
    if (view == nil) {
        CGFloat width = [self pickerView:self widthForComponent:component];
        CGFloat height = [self pickerView:self rowHeightForComponent:component];
        CGRect frame = CGRectMake(0.0f, 0.0f, width, height);
        view = [[UIView alloc] initWithFrame:frame];

        UILabel * label = [[UILabel alloc] initWithFrame:frame];
        label.font = [UIFont systemFontOfSize:23.0f];
        label.backgroundColor = [UIColor clearColor];
        label.shadowOffset = CGSizeMake(0.0f, 0.1f);
        label.shadowColor = [UIColor whiteColor];
        [view addSubview:label];
        //    if (_enableColourRow && [[formatter stringFromDate:[NSDate date]] isEqualToString:label.text])
        //        label.textColor = [UIColor colorWithRed:0.0f green:0.35f blue:0.91f alpha:1.0f];
        
        if (component == self.componentMonth) {
            CGRect lblFrame = ((UILabel *)view.subviews[0]).frame;
            CGFloat padding = componentWidthMonthPaddingCoef * self.totalComponentsWidth * self.totalComponentsWidthScale;
            if (!self.keepHiddenComponentsWidth &&
                self.dateFormat != DXConfigurableDatePickerFormatNormal) {
                padding = 0.0f;
            }
            lblFrame.origin.x = padding;
            [((UILabel *)view.subviews[0]) setFrame:lblFrame];
        }
    }
    
    NSTextAlignment textAlignment = NSTextAlignmentLeft;
    if (!self.keepHiddenComponentsWidth &&
        self.dateFormat != DXConfigurableDatePickerFormatNormal) {
        textAlignment = NSTextAlignmentCenter;
    }
    UILabel * label = view.subviews[0];
    if (component == self.componentMonth) {
        label.text = [self monthStringFromRow:row];
        label.textAlignment = textAlignment;
    } else if (component == self.componentDay) {
        label.text = [NSString stringWithFormat:@"%ld", [self dayFromRow:row]];
        label.textAlignment = NSTextAlignmentCenter;
    } else {
        label.text = [NSString stringWithFormat:@"%d", [self yearFromRow:row]];
        label.textAlignment = textAlignment;
    }
    
    view.hidden = [self hideRowForComponent:component];
    return view;
}

-(BOOL)hideRowForComponent:(NSInteger)component{
    if (!self.keepHiddenComponentsWidth) {
        return NO;
    }
    
    switch (self.dateFormat) {
        case DXConfigurableDatePickerFormatNoDay:
            if (component == self.componentDay) {
                return YES;
            }
            return NO;
        case DXConfigurableDatePickerFormatYearOnly:
            if (component == self.componentYear) {
                return NO;
            }
            return YES;
        default:
            return NO;
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

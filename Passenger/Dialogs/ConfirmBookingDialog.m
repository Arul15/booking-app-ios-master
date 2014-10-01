/******************************************************************************
 *
 * Copyright (C) 2013 T Dispatch Ltd
 *
 * Licensed under the GPL License, Version 3.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.gnu.org/licenses/gpl-3.0.html
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 ******************************************************************************
 *
 * @author Marcin Orlowski <marcin.orlowski@webnet.pl>
 *
 ****/

#import "ConfirmBookingDialog.h"
#import "DatePickerDialog.h"
#import "VehicleSelectionDialog.h"
#import "NSDate+CabOfficeSettings.h"
#import "CreditCard.h"
#import "CreditCardsManager.h"
#import "CardSelectionDialog.h"

@interface ConfirmBookingDialog()

@property (weak, nonatomic) IBOutlet UIButton *header;
@property (weak, nonatomic) IBOutlet FlatButton *bookButton;
@property (weak, nonatomic) IBOutlet FlatButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIImageView *dropoffImageView;
@property (weak, nonatomic) IBOutlet UILabel *pickupLabel;
@property (weak, nonatomic) IBOutlet UILabel *dropoffLabel;
@property (weak, nonatomic) IBOutlet FlatButton *timeButton;
@property (weak, nonatomic) IBOutlet FlatButton *dateButton;
@property (weak, nonatomic) IBOutlet UIView *timeView;
@property (weak, nonatomic) IBOutlet UIView *dateView;
@property (weak, nonatomic) IBOutlet UIView *pickupView;
@property (weak, nonatomic) IBOutlet UIView *dropoffView;
@property (weak, nonatomic) IBOutlet UIView *vehicleView;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet FlatButton *vehicleButton;
@property (weak, nonatomic) MapAnnotation* pickup;
@property (weak, nonatomic) MapAnnotation* dropoff;
@property (weak, nonatomic) VehiclesManager* vehiclesManager;
@property (weak, nonatomic) Vehicle* selectedVehicle;
@property (weak, nonatomic) IBOutlet UIView *activityView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityViewIndicator;
@property (weak, nonatomic) IBOutlet UIView *cardView;
@property (weak, nonatomic) IBOutlet FlatButton *cardButton;

@property (weak, nonatomic) CreditCard* selectedCard;

@property (strong, nonatomic) NSDate *selectedTime;
@property (strong, nonatomic) NSDate *selectedDate;

- (IBAction)bookButtonPressed:(id)sender;
- (IBAction)cancelButtonPressed:(id)sender;
- (IBAction)timeButtonPressed:(id)sender;
- (IBAction)dateButtonPressed:(id)sender;
- (IBAction)vehicleButtonPressed:(id)sender;
- (IBAction)cardButtonPressed:(id)sender;

@property (nonatomic, copy) DialogConfirmationBlock confirmationBlock;

@end

@implementation ConfirmBookingDialog

- (id)init
{
    self = [super initWithNibName:@"ConfirmBookingDialog"];
    if (self) {
    }
    return self;
}

+ (ConfirmBookingDialog*) showDialog:(MapAnnotation *)pickup
                             dropoff:(MapAnnotation *)dropoff
                 withVehiclesManager:(VehiclesManager *)vehiclesManager
                   confirmationBlock:(DialogConfirmationBlock)confirmationBlock

{
    ConfirmBookingDialog* dialog = [[ConfirmBookingDialog alloc] init];
    dialog.pickupLabel.text = pickup.title;
    
    dialog.vehiclesManager = vehiclesManager;
    dialog.pickup = pickup;
    dialog.dropoff = dropoff;
    
    if (dropoff)
    {
        dialog.dropoffView.hidden = NO;
        dialog.dropoffLabel.text = dropoff.title;
    }
    else
    {
        dialog.dropoffView.hidden = YES;
    }
    if (confirmationBlock)
        dialog.confirmationBlock = confirmationBlock;
    [dialog show];
    return dialog;
}

- (void)show
{
    UIFont *font = [UIFont semiboldOpenSansOfSize:17];
    
    self.contentView.backgroundColor = [UIColor dialogDefaultBackgroundColor];

    _activityView.hidden = YES;
    _activityViewIndicator.center = _activityView.center;
    
    _priceLabel.backgroundColor = [UIColor lightGrayColor];
    _priceLabel.textColor = [UIColor blackColor];
    _priceLabel.font = [UIFont lightOpenSansOfSize:17];
    _priceLabel.text = @"";
    
    _pickupLabel.font = font;
    _pickupLabel.textColor = [UIColor pickupTextColor];
    
    _dropoffLabel.font = font;
    _dropoffLabel.textColor = [UIColor dropoffTextColor];
    
    [_header setTitle:NSLocalizedString(@"new_booking_dialog_title", @"") forState:UIControlStateNormal];
    [_header.titleLabel setFont:[UIFont lightOpenSansOfSize:19]];
    [_header setTitleColor:[UIColor buttonTextColor] forState:UIControlStateNormal];
    [_header setBackgroundColor:[UIColor buttonColor]];

    [_cancelButton setTitleFont:[UIFont lightOpenSansOfSize:19]];
    [_cancelButton setTitle:NSLocalizedString(@"new_booking_dialog_button_cancel", @"") forState:UIControlStateNormal];
    
    [_bookButton setTitleFont:[UIFont lightOpenSansOfSize:19]];
    [_bookButton setTitle:NSLocalizedString(@"new_booking_dialog_button_ok", @"") forState:UIControlStateNormal];
    
    [_timeButton setTitleFont:[UIFont semiboldOpenSansOfSize:16]];
    [_timeButton setTitleColor:[UIColor pickupTextColor] forState:UIControlStateNormal];
    [_timeButton setTitle:NSLocalizedString(@"new_booking_dialog_pickup_time_now", @"") forState:UIControlStateNormal];

    [_dateButton setTitleFont:[UIFont semiboldOpenSansOfSize:16]];
    [_dateButton setTitleColor:[UIColor pickupTextColor] forState:UIControlStateNormal];
    [_dateButton setTitle:NSLocalizedString(@"new_booking_dialog_pickup_date_now", @"") forState:UIControlStateNormal];

    _dateView.hidden = YES;
    
#ifndef ENABLE_CREDIT_CARD_PAYMENTS
    _cardView.hidden = YES;
    _selectedCard = nil;
#else
    [_cardButton setTitleFont:[UIFont lightOpenSansOfSize:19]];
    [_cardButton setTitleColor:[UIColor buttonTextColor] forState:UIControlStateNormal];
    _selectedCard = [CreditCardsManager getInstance].defaultCard;
    [_cardButton setTitle:_selectedCard.maskedNumber forState:UIControlStateNormal];
#endif
    
    _selectedVehicle = _vehiclesManager.defaultVehicle;
    if (_selectedVehicle) {
        [_vehicleButton setTitleFont:[UIFont lightOpenSansOfSize:19]];
        [_vehicleButton setTitleColor:[UIColor buttonTextColor] forState:UIControlStateNormal];
        [_vehicleButton setTitle:_selectedVehicle.name forState:UIControlStateNormal];
    } else {
        _vehicleView.hidden = YES;
    }

    [self updateLayout];
    
    NSDate *date = [[NSDate date] dateByAddingMinimumAllowedPickupTimeOffsetInMinutes];
    self.selectedDate = date;
    self.selectedTime = date;

    [self setButtonsTitles:_selectedTime day:_selectedDate];
    
    if ([CabOfficeSettings minimumAllowedPickupTimeOffsetInMinutes]) {
        [self enableDateButton];
    }

    [super show];
    
    [self calculateFare];
    
}

- (void)updateRect:(UIView *)v y:(CGFloat)y {
    CGRect r = v.frame;
    r.origin.y = y;
    v.frame = r;
}

- (void)updateLayout
{
    CGRect frame = self.contentView.frame;
    
    CGFloat y = _cardView.frame.origin.y;
    
    if (!_cardView.hidden) {
        y += _cardView.frame.size.height;
    } else {
        frame.size.height -= _cardView.frame.size.height;
    }
    
    [self updateRect:_timeView y:y];
    y += _timeView.frame.size.height;

    if (!_dateView.hidden) {
        [self updateRect:_dateView y:y];
        y += _dateView.frame.size.height;
    } else {
        frame.size.height -= _dateView.frame.size.height;
    }

    if (!_vehicleView.hidden) {
        [self updateRect:_vehicleView y:y];
        y += _vehicleView.frame.size.height;
    } else {
        frame.size.height -= _vehicleView.frame.size.height;
    }

    [self updateRect:_pickupView y:y];
    y += _pickupView.frame.size.height;
    
    if (!_dropoffView.hidden) {
        [self updateRect:_dropoffView y:y];
        y += _dropoffView.frame.size.height;
        [self updateRect:_priceLabel y:y];
        y += _priceLabel.frame.size.height;
    } else {
        frame.size.height -= (_dropoffView.frame.size.height + _priceLabel.frame.size.height);
        _priceLabel.hidden = YES;
    }

    y += _bookButton.frame.size.height;
    frame.size.height = y;
    
    self.contentView.frame = frame;
}

- (void)enableDateButton
{
    _dateView.hidden = NO;
    [self updateLayout];
}

- (NSDate *)pickupDate
{
    NSDate *date = nil;
    
    if (_selectedTime || _selectedDate)
    {
        NSDateComponents* sdc;
        if (_selectedDate)
            sdc = [[NSCalendar currentCalendar] components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:_selectedDate];
        else
            sdc = [[NSCalendar currentCalendar] components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:[NSDate date]];
        
        NSDateComponents* stc;
        if (_selectedTime)
            stc = [[NSCalendar currentCalendar] components:(NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:_selectedTime];
        else
            stc = [[NSCalendar currentCalendar] components:(NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:[NSDate date]];
        
        date = [[NSCalendar currentCalendar] dateFromComponents:sdc];
        date = [[NSCalendar currentCalendar] dateByAddingComponents:stc toDate:date options:NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit];
    }
    return date;
}

- (IBAction)bookButtonPressed:(id)sender
{
    [self dismiss];
    
    if (_confirmationBlock) {
        _confirmationBlock([self pickupDate], _selectedVehicle, _selectedCard);
    }
}

- (IBAction)cancelButtonPressed:(id)sender
{
    [self dismiss];
}

- (void)setButtonsTitles:(NSDate *)time day:(NSDate *)day
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    NSString* t = [dateFormatter stringFromDate:time];
    [_timeButton setTitle:t forState:UIControlStateNormal];
    
    [dateFormatter setDateFormat:@"EEEE, LLLL dd yyyy"];
    NSString* str = [dateFormatter stringFromDate:day];
    [_dateButton setTitle:str forState:UIControlStateNormal];
}

- (BOOL)isDateToday:(NSDate *)date
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:[NSDate date]];
    NSDate *today = [cal dateFromComponents:components];
    components = [cal components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:date];
    NSDate *otherDate = [cal dateFromComponents:components];
    
    if([today isEqualToDate:otherDate]) {
        return YES;
    }
    return NO;
}

- (IBAction)timeButtonPressed:(id)sender {

    NSDate* minimumDate = nil;

    if (_selectedDate)
    {
        if ([self isDateToday:_selectedDate])
        {
            minimumDate = [[NSDate date] dateByAddingMinimumAllowedPickupTimeOffsetInMinutes];
        }
    }
    else
    {
        minimumDate = [[NSDate date] dateByAddingMinimumAllowedPickupTimeOffsetInMinutes];
    }
    
    [DatePickerDialog showTimePicker:^(NSDate *date){
        
        [self enableDateButton];
        
        self.selectedTime = date;
        if (!_selectedDate)
        {
            self.selectedDate = [NSDate date];
        }
        [self setButtonsTitles:date day:_selectedDate];
        [self calculateFare];
    } withMinimumDate:minimumDate];
}

- (IBAction)dateButtonPressed:(id)sender {
    [DatePickerDialog showDatePicker:^(NSDate *date){
        self.selectedDate = date;
        if (!_selectedTime || [self isDateToday:_selectedDate])
        {
            self.selectedTime = [NSDate date];
        }
        [self setButtonsTitles:_selectedTime day:date];
        [self calculateFare];
    }];
}

- (IBAction)vehicleButtonPressed:(id)sender {
    [VehicleSelectionDialog selectVehicleFromList:_vehiclesManager.vehicles
                               preselectedVehicle:_selectedVehicle
                                  completionBlock:^(Vehicle* vehicle) {
                                      _selectedVehicle = vehicle;
                                      [_vehicleButton setTitle:vehicle.name forState:UIControlStateNormal];
                                      [self calculateFare];
    }];
}

- (IBAction)cardButtonPressed:(id)sender {
    [CardSelectionDialog selectCardFromList:[CreditCardsManager getInstance].cards
                            preselectedCard:_selectedCard
                            completionBlock:^(CreditCard* card) {
                                _selectedCard = card;
                                [_cardButton setTitle:card.maskedNumber forState:UIControlStateNormal];
                            }];
}

- (void)calculateFare {
    if (_pickup && _dropoff) {
        _activityView.hidden = NO;
        [_activityViewIndicator startAnimating];
        
        [[NetworkEngine getInstance] getTravelFare:_pickup.position
                                                to:_dropoff.position
                                          usingCar:_selectedVehicle.pk
                                    withPickupTime:[self pickupDate]
                                   completionBlock:^(NSObject *o) {
                                       _activityView.hidden = YES;
                                       [_activityViewIndicator stopAnimating];
                                       NSDictionary* d = (NSDictionary*)o;
                                       _priceLabel.text = d[@"fare"][@"formatted_total_cost"];
                                   }
                                      failureBlock:^(NSError *e) {
                                            _activityView.hidden = YES;
                                            [_activityViewIndicator stopAnimating];
                                            _priceLabel.text = @"";
                                      }];
    }
}

@end

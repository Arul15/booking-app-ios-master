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

#import "VehicleSelectionDialog.h"

@interface VehicleSelectionDialog() <UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet FlatButton *selectButton;
@property (weak, nonatomic) IBOutlet FlatButton *cancelButton;

@property (weak, nonatomic) NSArray* vehicles;

- (IBAction)selectButtonPresed:(id)sender;
- (IBAction)cancelButtonPressed:(id)sender;

@property (nonatomic, copy) VehicleSelectionCompletionBlock completionBlock;

@end

@implementation VehicleSelectionDialog

- (id)init
{
    self = [super initWithNibName:@"VehicleSelectionDialog"];
    if (self) {
        
        [_selectButton setTitle:NSLocalizedString(@"new_booking_dialog_picker_button_select", @"") forState:UIControlStateNormal];
        [_cancelButton setTitle:NSLocalizedString(@"new_booking_dialog_picker_button_cancel", @"") forState:UIControlStateNormal];
        // Initialization code
    }
    return self;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return _vehicles.count;
}

- (UIView *)pickerView:(UIPickerView *)thePickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{

    Vehicle *v = _vehicles[row];

    UILabel* car = [[UILabel alloc] initWithFrame:CGRectMake(0,0,thePickerView.frame.size.width, 60)];
    car.text = v.name;
    car.textAlignment = NSTextAlignmentCenter;
    car.backgroundColor = [UIColor clearColor];
    car.font = [UIFont lightOpenSansOfSize:16];
    car.textColor = [UIColor blackColor];
    return car;
}

+ (void)selectVehicleFromList:(NSArray*)vehicles
           preselectedVehicle:(Vehicle*)vehicle
              completionBlock:(VehicleSelectionCompletionBlock)completionBlock
{
    VehicleSelectionDialog* d = [[VehicleSelectionDialog alloc] init];
    d.vehicles = vehicles;
    d.completionBlock = completionBlock;
    NSInteger idx = [vehicles indexOfObject:vehicle];
    [d.pickerView selectRow:idx inComponent:0 animated:NO];
    [d show];
}

- (IBAction)selectButtonPresed:(id)sender {
    if (_completionBlock) {
        Vehicle *v = _vehicles[[_pickerView selectedRowInComponent:0]];
        NSLog(@"Selected vehicle: %@", v);
        _completionBlock(v);
    }
    [self dismiss];
}

- (IBAction)cancelButtonPressed:(id)sender {
    [self dismiss];
}

@end

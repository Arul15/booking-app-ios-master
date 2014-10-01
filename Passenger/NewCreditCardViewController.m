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

#import "NewCreditCardViewController.h"
#import "FlatTextField.h"

@interface NewCreditCardViewController () <UIGestureRecognizerDelegate, UITextFieldDelegate>
{
    UITextField* _activeField;
}

@property (weak, nonatomic) IBOutlet UILabel*header;
@property (weak, nonatomic) IBOutlet FlatButton *addButton;
@property (weak, nonatomic) IBOutlet FlatButton *cancelButton;
@property (weak, nonatomic) IBOutlet UILabel *cardHolderTitle;
@property (weak, nonatomic) IBOutlet FlatTextField *cardHolderTextField;
@property (weak, nonatomic) IBOutlet UILabel *cardNumberTitle;
@property (weak, nonatomic) IBOutlet FlatTextField *cardNumberTextField;
@property (weak, nonatomic) IBOutlet UILabel *securityCodeTitle;
@property (weak, nonatomic) IBOutlet UILabel *expirationDateTitle;
@property (weak, nonatomic) IBOutlet FlatTextField *securityCodeTextField;
@property (weak, nonatomic) IBOutlet FlatTextField *expirationDateMonthTextField;
@property (weak, nonatomic) IBOutlet FlatTextField *expirationDateYearTextField;

- (IBAction)addButtonPressed:(id)sender;
- (IBAction)cancelButtonPressed:(id)sender;

@end

@implementation NewCreditCardViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    
    [_header setText:NSLocalizedString(@"new_card_title", @"")];
    [_header setFont:[UIFont lightOpenSansOfSize:19]];
    [_header setTextColor:[UIColor blackColor]];
    [_header setBackgroundColor:[UIColor dialogDefaultBackgroundColor]];
    
    [_cancelButton setTitleFont:[UIFont lightOpenSansOfSize:19]];
    [_cancelButton setTitle:NSLocalizedString(@"new_card_button_cancel", @"") forState:UIControlStateNormal];
    
    _securityCodeTextField.placeholder = NSLocalizedString(@"new_card_cvv_hint", @"");
    _securityCodeTextField.font = [UIFont lightOpenSansOfSize:16];
    _securityCodeTextField.delegate = self;
    
    _expirationDateMonthTextField.placeholder = NSLocalizedString(@"new_card_expiration_mm_hint", @"");
    _expirationDateMonthTextField.font = [UIFont lightOpenSansOfSize:16];
    _expirationDateMonthTextField.delegate = self;
    
    _expirationDateYearTextField.placeholder = NSLocalizedString(@"new_card_expiration_yy_hint", @"");
    _expirationDateYearTextField.font = [UIFont lightOpenSansOfSize:16];
    _expirationDateYearTextField.delegate = self;
    
    _cardHolderTextField.font = [UIFont lightOpenSansOfSize:16];
    _cardHolderTextField.delegate = self;
    
    _cardNumberTextField.font = [UIFont lightOpenSansOfSize:16];
    _cardNumberTextField.delegate = self;
    
    _cardHolderTitle.font = [UIFont lightOpenSansOfSize:15];
    _cardHolderTitle.textColor = [UIColor grayColor];
    _cardHolderTitle.text = NSLocalizedString(@"new_card_holder_name_label", @"");
    
    _cardNumberTitle.font = [UIFont lightOpenSansOfSize:15];
    _cardNumberTitle.textColor = [UIColor grayColor];
    _cardNumberTitle.text = NSLocalizedString(@"new_card_number_label", @"");
    
    _securityCodeTitle.font = [UIFont lightOpenSansOfSize:15];
    _securityCodeTitle.textColor = [UIColor grayColor];
    _securityCodeTitle.text = NSLocalizedString(@"new_card_cvv_label", @"");
    
    _expirationDateTitle.font = [UIFont lightOpenSansOfSize:15];
    _expirationDateTitle.textColor = [UIColor grayColor];
    _expirationDateTitle.text = NSLocalizedString(@"new_card_expiration_label", @"");
    
    [_addButton setTitleFont:[UIFont lightOpenSansOfSize:19]];
    [_addButton setTitle:NSLocalizedString(@"new_card_button_ok", @"") forState:UIControlStateNormal];
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] init];
    [tap addTarget:self action:@selector(tapGesture:)];
    tap.delegate = self;
    tap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tap];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    
    if ([touch.view isKindOfClass:[UIButton class]]) {
        return NO;
    }
    return YES;
}

- (void)tapGesture:(UITapGestureRecognizer*)gesture
{
    [_activeField resignFirstResponder];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    _activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    _activeField = nil;
}

- (BOOL) isAllDigits:(NSString *)string
{
    NSCharacterSet* nonNumbers = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    NSRange r = [string rangeOfCharacterFromSet: nonNumbers];
    return r.location == NSNotFound;
}


- (IBAction)addButtonPressed:(id)sender
{
    if (!_cardHolderTextField.text.length) {
        [MessageDialog showError:NSLocalizedString(@"new_card_error_invalid_holder_name", @"")
                       withTitle:NSLocalizedString(@"dialog_error_title", @"")];
        return;
    }
    
    if (!_cardNumberTextField.text.length) {
        [MessageDialog showError:NSLocalizedString(@"new_card_error_invalid_card_number", @"")
                       withTitle:NSLocalizedString(@"dialog_error_title", @"")];
        return;
    }
    
    if (!_expirationDateMonthTextField.text.length || !_expirationDateYearTextField.text.length) {
        [MessageDialog showError:NSLocalizedString(@"new_card_error_invalid_expiration_date", @"")
                       withTitle:NSLocalizedString(@"dialog_error_title", @"")];
        return;
    }
    
    NSString* cvv = _securityCodeTextField.text;
    if (cvv.length) {
        if( ![self isAllDigits:cvv] ) {
            [MessageDialog showError:NSLocalizedString(@"new_card_error_invalid_cvv_number", @"")
                           withTitle:NSLocalizedString(@"dialog_error_title", @"")];
            return;
        }
    }
}

- (IBAction)cancelButtonPressed:(id)sender
{
    if (IS_IPAD) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

@end

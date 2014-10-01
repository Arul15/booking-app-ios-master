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

#import "MenuViewController.h"
#import "MyAccountViewController.h"
#import "CabOfficeViewController.h"
#import "UserSettings.h"

@interface MenuViewController ()

@property (weak, nonatomic) IBOutlet FlatButton *myAccountButton;
@property (weak, nonatomic) IBOutlet FlatButton *cabOfficeButton;
@property (weak, nonatomic) IBOutlet FlatButton *tourButton;
@property (weak, nonatomic) IBOutlet FlatButton *logoutButton;
@property (weak, nonatomic) IBOutlet FlatButton *cardsButton;
@property (weak, nonatomic) IBOutlet UILabel *appVersionLabel;
@property (weak, nonatomic) IBOutlet UIView *menuView;
@property (weak, nonatomic) IBOutlet UILabel *poweredByLabel;

- (IBAction)logoutButtonPressed:(id)sender;

@property (nonatomic, strong) NSDictionary* officeData;

@end

@implementation MenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#define SPACE 10

- (CGFloat)setupMenuButton:(FlatButton*)button atPosition:(CGFloat)y withTitle:(NSString *)title {
    [button setTitleFont:[UIFont lightOpenSansOfSize:31]];
    [button setButtonBackgroundColor:[UIColor clearColor]];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTextAlignment:UITextAlignmentLeft];

    CGRect r = button.frame;
    r.origin.y = y;
    button.frame = r;
    
    y += r.size.height;
    y += SPACE;
    
    return y;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];

    CGFloat y = 0;
    
    [_appVersionLabel setFont:[UIFont lightOpenSansOfSize:15]];
    [_appVersionLabel setText:[NSString stringWithFormat:@"v%@",version]];
    [_appVersionLabel setTextColor:[UIColor colorWithHexString:@"#aaaaaa"]];
    [_appVersionLabel setTextAlignment:NSTextAlignmentRight];
    
    [_poweredByLabel setFont:[UIFont lightOpenSansOfSize:15]];
    [_poweredByLabel setText:@"Powered by T Dispatch"];
    [_poweredByLabel setTextColor:[UIColor colorWithHexString:@"#aaaaaa"]];
    [_poweredByLabel setTextAlignment:NSTextAlignmentLeft];
    
    y = [self setupMenuButton:_myAccountButton atPosition:y withTitle:NSLocalizedString(@"menu_button_account", @"")];

#ifdef ENABLE_CREDIT_CARD_PAYMENTS
    y = [self setupMenuButton:_cardsButton atPosition:y withTitle:NSLocalizedString(@"menu_button_cards", @"")];
#else
    _cardsButton.hidden = YES;
#endif
    y = [self setupMenuButton:_cabOfficeButton atPosition:y withTitle:NSLocalizedString(@"menu_button_cab_office", @"")];

    y = [self setupMenuButton:_tourButton atPosition:y withTitle:NSLocalizedString(@"menu_button_tour", @"")];

    y = [self setupMenuButton:_logoutButton atPosition:y withTitle:NSLocalizedString(@"menu_button_logout", @"")];

    CGRect r = _menuView.frame;
    r.size.height = y - SPACE;
    _menuView.frame = r;
    
    [[NetworkEngine getInstance] getFleetData:^(NSObject *o) {
                                                self.officeData = (NSDictionary *)o;
                                            }
                                          failureBlock:^(NSError * error) {
                                          }];

	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _menuView.center = self.view.center;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setMyAccountButton:nil];
    [self setCabOfficeButton:nil];
    [self setTourButton:nil];
    [self setLogoutButton:nil];
    [self setAppVersionLabel:nil];
    [super viewDidUnload];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showMyAccountViewController"])
    {
        MyAccountViewController* vc = segue.destinationViewController;
        vc.accountPreferences = [NetworkEngine getInstance].accountPreferences;
    }
    else if ([segue.identifier isEqualToString:@"showCabOfficeViewController"])
    {
        CabOfficeViewController* vc = segue.destinationViewController;
        vc.officeData = _officeData;
    }
}

- (IBAction)logoutButtonPressed:(id)sender {
    [UserSettings setRefreshToken:nil];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end

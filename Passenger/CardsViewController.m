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


#import "CardsViewController.h"
#import "CreditCardsManager.h"
#import "NewCreditCardViewController.h"

@interface CardsViewController () <UITableViewDataSource, UITableViewDelegate>
{
    NSArray* _cards;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet FlatButton *closeButton;
@property (weak, nonatomic) IBOutlet FlatButton *addCardButton;
@property (weak, nonatomic) IBOutlet UILabel *emptyListLabel;

- (IBAction)closeButtonPressed:(id)sender;
- (IBAction)addButtonPressed:(id)sender;

@end

@implementation CardsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
 
    [_closeButton setTitle:NSLocalizedString(@"card_list_button_done", @"") forState:UIControlStateNormal];
    [_closeButton setTitleColor:[UIColor buttonTextColor] forState:UIControlStateNormal];
    
    [_addCardButton setTitle:NSLocalizedString(@"card_list_button_add", @"") forState:UIControlStateNormal];
    [_addCardButton setTitleColor:[UIColor buttonTextColor] forState:UIControlStateNormal];

    _emptyListLabel.text = NSLocalizedString(@"card_list_no_cards", @"");
    _emptyListLabel.font = [UIFont lightOpenSansOfSize:20];
    
    _tableView.backgroundColor = [UIColor clearColor];

    _cards = [CreditCardsManager getInstance].cards;
    [_tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _emptyListLabel.center = _tableView.center;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark table view source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (void)showEmptyListIfNeeded
{
    if (_cards.count) {
        _emptyListLabel.hidden = YES;
        _tableView.hidden = NO;
    } else {
        _emptyListLabel.hidden = NO;
        _tableView.hidden = YES;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    [self showEmptyListIfNeeded];
    return _cards.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cardsTableViewCellIdentifier";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    CreditCard* card = _cards[indexPath.row];
    
    cell.textLabel.font = [UIFont lightOpenSansOfSize:16];
    cell.textLabel.textColor = [UIColor grayColor];
    cell.textLabel.text = card.cardholderName.length ? card.cardholderName : NSLocalizedString(@"card_list_row_no_label", @"");

    cell.detailTextLabel.font = [UIFont lightOpenSansOfSize:13];
    cell.detailTextLabel.textColor = [UIColor grayColor];
    cell.detailTextLabel.text = card.maskedNumber;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {

        __block WaitDialog* w = [[WaitDialog alloc] init];
        [w show];
        [[CreditCardsManager getInstance] removeCard:_cards[indexPath.row]
                                        updateBlock:^(NSArray *cards, NSError* e) {
                                            [w dismiss];
                                            if (e) {
                                                [MessageDialog showError:[NSString stringWithFormat:NSLocalizedString(@"card_error_failed_to_delete_card", @""), e.localizedDescription]
                                                               withTitle:NSLocalizedString(@"dialog_error_title", @"")];
                                            } else {
                                                _cards = cards;
                                                [_tableView reloadData];
                                            }
                                        }];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return YES;
}

- (IBAction)closeButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)addCard:(CreditCard *)card {
    [[CreditCardsManager getInstance] addCard:card
                                  updateBlock:^(NSArray *cards, NSError* error) {
                                      _cards = cards;
                                      [_tableView reloadData];
                                  }];
}

- (IBAction)addButtonPressed:(id)sender {
    
    NSInteger cardLimit = [CabOfficeSettings cardLimit];
    if (!cardLimit || _cards.count < cardLimit) {
        [self performSegueWithIdentifier:@"NewCreditCardSegue" sender:nil];
    } else {
        [MessageDialog showError:NSLocalizedString(@"card_error_cannot_add_new_card", @"")
                       withTitle:NSLocalizedString(@"dialog_error_title", @"")];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"NewCreditCardSegue"]) {
        NewCreditCardViewController *ncc = segue.destinationViewController;
        ncc.completionBlock = ^(CreditCard *card) {
            [self addCard:card];
        };
    }
}

@end

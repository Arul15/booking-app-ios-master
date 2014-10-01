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


#import "SearchViewController.h"
#import "LocationSelectorViewController.h"
#import "LocationSelectionListViewController.h"
#import "StationsManager.h"

#import "DAPagesContainer.h"

@interface SearchViewController ()

@property (nonatomic, strong) DAPagesContainer* pagesContainer;

@end

@implementation SearchViewController

- (CGSize)contentSizeForViewInPopover
{
    return CGSizeMake(320, 320);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.pagesContainer = [[DAPagesContainer alloc] init];
    [self.pagesContainer willMoveToParentViewController:self];
    self.pagesContainer.view.frame = self.view.bounds;
    self.pagesContainer.searchContext = self.searchContext;
    self.pagesContainer.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.pagesContainer.view];
    [self.pagesContainer didMoveToParentViewController:self];

    LocationSelectorViewController* loc;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:DEVICE_STORYBOARD
                                                         bundle:nil];
    loc = [storyboard instantiateViewControllerWithIdentifier:@"locationSelectorViewController"];
    loc.title = NSLocalizedString(@"address_search_page_search", @"");
    
    if ([CabOfficeSettings enableLocationSearchModules])
    {
        LocationSelectionListViewController* loc1;
        loc1 = [storyboard instantiateViewControllerWithIdentifier:@"locationSelectionListViewController"];
        loc1.title = NSLocalizedString(@"address_search_page_stations", @"");
        loc1.stationType = StationTypeTrain;
        
        loc1.places = [StationsManager getInstance].stations;

        _pagesContainer.viewControllers = @[loc, loc1];
    }
    else
    {
        _pagesContainer.viewControllers =  @[loc];
    }

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _pagesContainer.completionBlock = self.completionBlock;
    
    for (LocationSelectionBaseViewController *v in _pagesContainer.viewControllers)
    {
        v.completionBlock = self.completionBlock;
        v.locationType = self.locationType;
        v.searchContext = self.searchContext;
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

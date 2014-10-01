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

#import "VehiclesManager.h"

@interface VehiclesManager()
{
    NSMutableArray* _vehicles;
}
@end

@implementation VehiclesManager

- (void)getVehicles
{
    [[NetworkEngine getInstance] getVehicles:^(NSObject* response) {
        _vehicles = [[NSMutableArray alloc] initWithCapacity:5];
        NSArray* v = (NSArray *)response;
        for (NSDictionary *d in v) {
            Vehicle* vehicle = [[Vehicle alloc] initWithDictionary:d];
            [_vehicles addObject:vehicle];
        }
    }
                                failureBlock:^(NSError *error) {
                                    NSLog(@"getVehicles: %@", error);
                                }];
}

- (Vehicle *)defaultVehicle {
    NSInteger idx = [_vehicles indexOfObjectPassingTest:^BOOL(Vehicle * v, NSUInteger idx, BOOL *stop) {
        
        if ([v.name isEqualToString:@"saloon"] || [v.name isEqualToString:@"Saloon"]) {
            *stop = YES;
            return YES;
        }
        
        return NO;
    }];
    
    if (idx != NSNotFound) {
        return _vehicles[idx];
    } else if (_vehicles.count) {
        return _vehicles[0];
    }
    return nil;
}

@end

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

#import "StationsManager.h"
#import "MapAnnotation.h"

@interface StationsManager()
{
    NSMutableArray* _stations;
}
@end

@implementation StationsManager

+ (StationsManager *)getInstance
{
    static StationsManager *smInstance;
    
    @synchronized(self)
    {
        if (!smInstance)
        {
            smInstance = [[StationsManager alloc] init];
        }
        return smInstance;
    }
}

- (void)addStation:(CLLocationCoordinate2D)location
             title:(NSString *)title
           zipCode:(NSString *)zipCode
{
    
    MapAnnotation *a = [[MapAnnotation alloc] initWithCoordinate:location
                                                       withTitle:title
                                                   withImageName:nil
                                                     withZipCode:zipCode];
    [_stations addObject:a];

}

- (id)init
{
    self = [super init];
    if (self)
    {
        _stations = [[NSMutableArray alloc] init];
        
        [self addStation:CLLocationCoordinate2DMake(52.253708, 0.712454)
                   title:@"Bury St Edmonds Station"
                 zipCode:@"IP32 6AQ"];
        
        [self addStation:CLLocationCoordinate2DMake(51.736465, 0.468708)
                   title:@"Chelmsford Station"
                 zipCode:@"CM1 1HT"];
        
        [self addStation:CLLocationCoordinate2DMake(51.901230, 0.893736)
                   title:@"Colchester Station"
                 zipCode:@"CO4 5EY"];
        
        [self addStation:CLLocationCoordinate2DMake(52.391209, 0.265048)
                   title:@"Ely Station"
                 zipCode:@"CB7 4DJ"];

        [self addStation:CLLocationCoordinate2DMake(52.627151, 1.306835)
                   title:@"Norwich Station"
                 zipCode:@"NR1 1EH"];

        [self addStation:CLLocationCoordinate2DMake(51.666916, 0.383777)
                   title:@"Ingatestone Station"
                 zipCode:@"CM4 0BW"];
        
//        [self addStation:CLLocationCoordinate2DMake(52.050720, 1.144216)
//                   title:@"Ipswich Station"
//                 zipCode:@"IP2 8AL"];
    }
    return self;
}

- (double)toRadians:(double)angle
{
    return (angle *  M_PI / 180.0);
}

- (CGFloat)distanceFromLocation:(CLLocationCoordinate2D)start
                     toLocation:(CLLocationCoordinate2D)end {

    double earthRadius = 6371;
    double lat1 = start.latitude;
    double lat2 = end.latitude;
    double lon1 = start.longitude;
    double lon2 = end.longitude;
    double dLat = [self toRadians:(lat2-lat1)];
    double dLon = [self toRadians:(lon2-lon1)];
    double a = (sin(dLat/2) * sin(dLat/2))
    + (cos([self toRadians:(lat1)])
       * cos([self toRadians:(lat2)])
       * sin(dLon/2) * sin(dLon/2));
    return (2 * asin(sqrt(a))) * earthRadius;
}

- (BOOL)isStation:(CLLocationCoordinate2D)location
{
    BOOL result = NO;
    for (MapAnnotation *s in _stations) {
        if( [self distanceFromLocation:location toLocation:s.position] < 0.5 ) {
            result = YES;
            break;
        }
    }
    return result;
}

@end

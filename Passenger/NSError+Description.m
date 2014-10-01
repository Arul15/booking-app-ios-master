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

#import "NSError+Description.h"

@implementation NSError (Description)

+ (NSError*)errorWithDescription:(NSString*)description
{
    NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
    [errorDetail setValue:description forKey:NSLocalizedDescriptionKey];
    NSError* error = [NSError errorWithDomain:@"Passenger" code:1 userInfo:errorDetail];
    return error;
}

+ (NSError *)errorFromAPIResponse:(NSDictionary *)response andError:(NSError *)error
{
    id message = response[@"message"];
    if (message) {
        if ([message isKindOfClass:[NSString class]]) {
            return [NSError errorWithDescription:message];
        } else {
            NSDictionary *msg = message;
            NSString *text = msg[@"text"];
            if (text) {
                return [NSError errorWithDescription:text];
            }
        }
    }
    return error;
}

@end

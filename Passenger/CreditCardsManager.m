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

#import "CreditCardsManager.h"

@interface CreditCardsManager()
{
    NSMutableArray* _cards;
}

@end

@implementation CreditCardsManager

+ (CreditCardsManager *)getInstance
{
    static CreditCardsManager *smInstance;
    
    @synchronized(self)
    {
        if (!smInstance)
        {
            smInstance = [[CreditCardsManager alloc] init];
        }
        return smInstance;
    }
}

- (id)init
{
    self = [super init];
    if (self) {
        _cards = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)getCards:(CardManagerUpdateBlock)updateBlock {
    updateBlock(_cards, nil);
}

- (void)addCard:(CreditCard*)card updateBlock:(CardManagerUpdateBlock)updateBlock {
    [_cards addObject:card];
    if (updateBlock) {
        updateBlock(_cards, nil);
    }
}

- (void)removeCard:(CreditCard*)card updateBlock:(CardManagerUpdateBlock)updateBlock {
}

- (CreditCard *)defaultCard
{
    NSInteger idx = [_cards indexOfObjectPassingTest:^BOOL(CreditCard * c, NSUInteger idx, BOOL *stop) {

        if ([c.defaultCard boolValue]) {
            *stop = YES;
            return YES;
        }
        
        return NO;
    }];
    
    if (idx != NSNotFound) {
        return _cards[idx];
    } else if (_cards.count) {
        return _cards[0];
    }
    return nil;
}

- (NSArray*)cards {
    return _cards;
}

@end

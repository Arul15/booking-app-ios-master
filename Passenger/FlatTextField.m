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


#import "FlatTextField.h"

@interface FlatTextField ()

@property (nonatomic, strong) UIImageView* img;

@end

@implementation FlatTextField

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self setBackgroundImage:NO];
        _img = [[UIImageView alloc] initWithFrame:self.bounds];
        [self addSubview:_img];
    }
    return self;
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectMake(bounds.origin.x + 10, bounds.origin.y,
                      bounds.size.width - 20, bounds.size.height);
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    return [self textRectForBounds:bounds];
}

- (void)setBackgroundImage:(BOOL)selected
{
    UIImage *b;
#define CAP_INSETS UIEdgeInsetsMake(0, 10, 10, 10)
    if (selected)
    {
        b = [[UIImage imageNamed:@"textfield_back_normal.png"] resizableImageWithCapInsets:CAP_INSETS];
    }
    else
    {
        b = [[UIImage imageNamed:@"textfield_back_selected.png"] resizableImageWithCapInsets:CAP_INSETS];
    }
    
//    _img.image = b;
    
    [self setBackground:b];
    [self setNeedsDisplay];

}

- (BOOL)becomeFirstResponder
{
    BOOL outcome = [super becomeFirstResponder];
    [self setBackgroundImage:YES];
    return outcome;
}

- (BOOL)resignFirstResponder
{
    BOOL outcome = [super resignFirstResponder];
    [self setBackgroundImage:NO];
    return outcome;
}

-(void) drawPlaceholderInRect:(CGRect)rect {
    [[UIColor lightGrayColor] setFill];
    [[self placeholder] drawInRect:rect withFont:self.font];
}

@end

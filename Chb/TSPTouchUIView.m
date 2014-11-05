//
//  TSPTouchUIView.m
//  Chb
//
//  Created by Massimo on 4/13/14.
//  Copyright (c) 2014 Massimo Zanini. All rights reserved.
//

#import "TSPTouchUIView.h"
#import "FindUIViewController.h"
#import "TSPViewController.h"

@interface TSPTouchUIView ()
@end

@implementation TSPTouchUIView
@synthesize delegate;

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"-touchesBegan");
    
    //Cambia Immagine
    for (id subview in self.subviews) {
        if ([subview isKindOfClass:[UIImageView class]] &&
            [subview tag] == self.tag + 10) {
            UIImageView *theView = (UIImageView*)subview;
            UIImage *image = [UIImage imageNamed:[self imageName:self.tag perEvento:@"off"]];
            [theView setImage:image];
        }
    }
    
    [super touchesBegan:touches withEvent:event];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"-touchesEnded");
    
    //Ripristina Immagine
    for (id subview in self.subviews) {
        if ([subview isKindOfClass:[UIImageView class]] &&
            [subview tag] == self.tag + 10) {
            UIImageView *theView = (UIImageView*)subview;
            
            UIImage *image = [UIImage imageNamed:[self imageName:self.tag perEvento:@"on"]];
            
            [theView setImage:image];
        }
    }
    
    //Call doBtnPressed
    TSPViewController * myController = (TSPViewController *)[self firstAvailableUIViewController];
    [myController doBtnPressed:self.tag];
    
    [super touchesEnded:touches withEvent:event];
}

- (NSString*) imageName:(NSInteger)tag perEvento:(NSString*)event {
    switch (tag) {
        case 100:
            if([event isEqualToString:@"on"])
                return @"f1.png";
            else
                return @"f1_off.png";
            break;
        case 200:
            if([event isEqualToString:@"on"])
                return @"f2.png";
            else
                return @"f2_off.png";
            break;
        case 300:
            if([event isEqualToString:@"on"])
                return @"f3.png";
            else
                return @"f3_off.png";
            break;
        case 400:
            if([event isEqualToString:@"on"])
                return @"f4.png";
            else
                return @"f4_off.png";
            break;
        case 500:
            if([event isEqualToString:@"on"])
                return @"f5.png";
            else
                return @"f5_off.png";
            break;
        case 600:
            if([event isEqualToString:@"on"])
                return @"f6.png";
            else
                return @"f6_off.png";
            break;
        default:
            return @"";
            break;
    }
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

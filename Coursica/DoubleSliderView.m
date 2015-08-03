//
//  DoubleSliderView.m
//  
//
//  Created by Regan Bell on 5/11/15.
//
//

#import "DoubleSliderView.h"
#import "NMRangeSlider.h"

#define CoursicaBlue [UIColor colorWithRed:31/255.0 green:148/255.0 blue:255/255.0 alpha:1.0]

@implementation DoubleSliderView

- (UILabel*)titleLabelWithTitle:(NSString*)title {
    
    UILabel *scoreLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    scoreLabel.font = self.font;
    scoreLabel.text = title;
    scoreLabel.textColor = self.textColor;
    scoreLabel.translatesAutoresizingMaskIntoConstraints = NO;
    scoreLabel.textAlignment = NSTextAlignmentCenter;
    
    [self pinHeight:20.0 view:scoreLabel];

    return scoreLabel;
}

- (void)pinHeight:(CGFloat)height view:(UIView*)view {
    
    [view addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:height]];
}

- (void)pinWidth:(CGFloat)height view:(UIView*)view {
    
    [view addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:height]];
}

- (id)initWithTitle:(NSString *)title font:(UIFont*)font textColor:(UIColor*)color {
    
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.font = font;
        self.textColor = color;
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        UILabel *titleLabel = [self titleLabelWithTitle:title];
        UILabel *rightScoreLabel = [self titleLabelWithTitle:@"1.0"];
        UILabel *leftScoreLabel = [self titleLabelWithTitle:@"1.0"];
        
        self.titleLabel = titleLabel;
        self.rightScoreLabel = rightScoreLabel;
        self.leftScoreLabel = leftScoreLabel;
        
        NMRangeSlider *overallSlider = [[NMRangeSlider alloc] initWithFrame:CGRectMake(16, 6, 300, 34)];
        UIImage *handleImage = [UIImage imageNamed:@"SliderTab"];
        overallSlider.lowerHandleImageNormal = handleImage;
        overallSlider.upperHandleImageNormal = handleImage;
        overallSlider.lowerHandleImageHighlighted = handleImage;
        overallSlider.upperHandleImageHighlighted = handleImage;
        overallSlider.minimumValue = 1;
        overallSlider.maximumValue = 5;
        overallSlider.lowerValue = 2;
        overallSlider.upperValue = 5;
        overallSlider.tintColor = CoursicaBlue;
        overallSlider.translatesAutoresizingMaskIntoConstraints = NO;
        [overallSlider addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
        self.slider = overallSlider;
        
        [self addSubview:overallSlider];
        [self addSubview:titleLabel];
        [self addSubview:leftScoreLabel];
        [self addSubview:rightScoreLabel];
        
        // 25 spacing
        
        [self pinWidth:120.0 view:titleLabel];
        [self pinWidth:51.0 view:leftScoreLabel];
        [self pinWidth:53.0 view:rightScoreLabel];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:leftScoreLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:overallSlider attribute:NSLayoutAttributeLeft multiplier:1.0 constant:10.0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:leftScoreLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:titleLabel attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:2.0]];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:rightScoreLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:overallSlider attribute:NSLayoutAttributeRight multiplier:1.0 constant:-10.0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:rightScoreLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:titleLabel attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:2.0]];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:titleLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:titleLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];

        //    // Add programatic constraints to the slider
        [self pinHeight:40.0 view:overallSlider];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:overallSlider attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:overallSlider attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:overallSlider attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:titleLabel attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
        
        [self valueChanged:overallSlider];
    }
    return self;
}

- (void)valueChanged:(NMRangeSlider*)slider {
    
    if (self.shouldFormatForFloatValue) {
        self.leftScoreLabel.text = [NSString stringWithFormat:@"%.1f", slider.lowerValue];
        self.rightScoreLabel.text = [NSString stringWithFormat:@"%.1f", slider.upperValue];
    } else {
        self.leftScoreLabel.text = [NSString stringWithFormat:@"%d", (int)slider.lowerValue];
        int upperIntValue = (int)slider.upperValue;
        if (upperIntValue == 250) {
            self.rightScoreLabel.text = [NSString stringWithFormat:@"250+"];
        } else {
            self.rightScoreLabel.text = [NSString stringWithFormat:@"%d", upperIntValue];
        }
    }
    
}

@end

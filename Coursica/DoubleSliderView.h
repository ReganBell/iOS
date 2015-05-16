//
//  DoubleSliderView.h
//  
//
//  Created by Regan Bell on 5/11/15.
//
//

#import <UIKit/UIKit.h>

@class NMRangeSlider;

@interface DoubleSliderView : UIView

@property (strong, nonatomic) UIFont *font;
@property (strong, nonatomic) UIColor *textColor;
@property (weak, nonatomic) NMRangeSlider *slider;

- (id)initWithTitle:(NSString *)title font:(UIFont*)font textColor:(UIColor*)color;

@end

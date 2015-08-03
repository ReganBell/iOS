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
@property (weak, nonatomic) UILabel *leftScoreLabel;
@property (weak, nonatomic) UILabel *rightScoreLabel;
@property (weak, nonatomic) UILabel *titleLabel;
@property BOOL shouldFormatForFloatValue;

- (id)initWithTitle:(NSString *)title font:(UIFont*)font textColor:(UIColor*)color;
- (void)valueChanged:(NMRangeSlider*)slider;

@end

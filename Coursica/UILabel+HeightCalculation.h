//
//  UILabel+HeightCalculation.h
//  BRANDiD
//
//  Created by Regan Bell on 5/15/14.
//  Copyright (c) 2014 BRANDiD. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (HeightCalculation)

- (CGFloat)heightForContent;
+ (CGFloat)heightForString:(NSString*)string width:(CGFloat)width font:(UIFont*)font;
- (void)updateHeightForContent;

+ (CGFloat)widthForString:(NSString*)string height:(CGFloat)height font:(UIFont*)font;
- (CGFloat)widthForContent;
- (void)updateWidthForContent;

@end

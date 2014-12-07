//
//  UILabel+HeightCalculation.m
//  BRANDiD
//
//  Created by Regan Bell on 5/15/14.
//  Copyright (c) 2014 BRANDiD. All rights reserved.
//

#import "UILabel+HeightCalculation.h"

@implementation UILabel (HeightCalculation)

+ (CGFloat)heightForString:(NSString*)string width:(CGFloat)width font:(UIFont*)font {
    
    NSDictionary *stringAttributes = [NSDictionary dictionaryWithObject:font forKey: NSFontAttributeName];
    
    CGSize sizeForContent = [string boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                                    options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                                 attributes:stringAttributes context:nil].size;
    
    return ceilf(sizeForContent.height);
}

- (CGFloat)heightForContent {
    
    return [self.class heightForString:self.text width:self.width font:self.font];
}

- (void)updateHeightForContent {
    self.height = self.heightForContent;
}

+ (CGFloat)widthForString:(NSString*)string height:(CGFloat)height font:(UIFont*)font {
    
    NSDictionary *stringAttributes = [NSDictionary dictionaryWithObject:font forKey: NSFontAttributeName];
    
    CGSize sizeForContent = [string boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, height)
                                                 options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                              attributes:stringAttributes context:nil].size;
    
    return ceilf(sizeForContent.width);
}

- (CGFloat)widthForContent {
    
    return [self.class widthForString:self.text height:self.height font:self.font];
}

- (void)updateWidthForContent {
    self.width = self.widthForContent;
}

@end

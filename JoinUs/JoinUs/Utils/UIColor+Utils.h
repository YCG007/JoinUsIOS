//
//  UIColor+Utils.h
//  JoinUs
//
//  Created by Liang Qian on 19/3/2016.
//  Copyright © 2016 North Gate Code. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Utils)

@property (nonatomic, readonly) CGFloat red;
@property (nonatomic, readonly) CGFloat green;
@property (nonatomic, readonly) CGFloat blue;
@property (nonatomic, readonly) CGFloat alpha;

+ (instancetype)colorForButtonParimary;
+ (instancetype)colorForButtonSecondary;

+ (instancetype)colorWithRGBValue:(uint32_t)rgb;
+ (instancetype)colorWithRGBAValue:(uint32_t)rgba;
- (instancetype)initWithRGBValue:(uint32_t)rgb;
- (instancetype)initWithRGBAValue:(uint32_t)rgba;

- (uint32_t)RGBValue;
- (uint32_t)RGBAValue;

- (BOOL)isMonochromeOrRGB;
- (BOOL)isEquivalent:(id)object;
- (BOOL)isEquivalentToColor:(UIColor *)color;

- (instancetype)colorWithBrightness:(CGFloat)brightness;
- (instancetype)colorBlendedWithColor:(UIColor *)color factor:(CGFloat)factor;

@end

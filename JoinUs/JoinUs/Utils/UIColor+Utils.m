//
//  UIColor+Utils.m
//  JoinUs
//
//  Created by Liang Qian on 19/3/2016.
//  Copyright © 2016 North Gate Code. All rights reserved.
//

#import "UIColor+Utils.h"

@implementation UIColor (Utils)

+ (instancetype)colorForButtonParimary {
    return [[self alloc] initWithRGBValue:0x88c43f];
}

+ (instancetype)colorForButtonSecondary {
    return [[self alloc] initWithRGBValue:0x009687];
}

- (void)getRGBAComponents:(CGFloat[4])rgba
{
    CGColorSpaceModel model = CGColorSpaceGetModel(CGColorGetColorSpace(self.CGColor));
    const CGFloat *components = CGColorGetComponents(self.CGColor);
    switch (model)
    {
        case kCGColorSpaceModelMonochrome:
        {
            rgba[0] = components[0];
            rgba[1] = components[0];
            rgba[2] = components[0];
            rgba[3] = components[1];
            break;
        }
        case kCGColorSpaceModelRGB:
        {
            rgba[0] = components[0];
            rgba[1] = components[1];
            rgba[2] = components[2];
            rgba[3] = components[3];
            break;
        }
        case kCGColorSpaceModelCMYK:
        case kCGColorSpaceModelDeviceN:
        case kCGColorSpaceModelIndexed:
        case kCGColorSpaceModelLab:
        case kCGColorSpaceModelPattern:
        case kCGColorSpaceModelUnknown:
        {
            
#ifdef DEBUG
            
            //unsupported format
            NSLog(@"Unsupported color model: %i", model);
#endif
            rgba[0] = 0.0f;
            rgba[1] = 0.0f;
            rgba[2] = 0.0f;
            rgba[3] = 1.0f;
            break;
        }
    }
}

+ (instancetype)colorWithRGBValue:(uint32_t)rgb
{
    return [[self alloc] initWithRGBValue:rgb];
}

+ (instancetype)colorWithRGBAValue:(uint32_t)rgba
{
    return [[self alloc] initWithRGBAValue:rgba];
}

- (instancetype)initWithRGBValue:(uint32_t)rgb
{
    CGFloat red = ((rgb & 0xFF0000) >> 16) / 255.0f;
    CGFloat green = ((rgb & 0x00FF00) >> 8) / 255.0f;
    CGFloat blue = (rgb & 0x0000FF) / 255.0f;
    return [self initWithRed:red green:green blue:blue alpha:1.0f];
}

- (instancetype)initWithRGBAValue:(uint32_t)rgba
{
    CGFloat red = ((rgba & 0xFF000000) >> 24) / 255.0f;
    CGFloat green = ((rgba & 0x00FF0000) >> 16) / 255.0f;
    CGFloat blue = ((rgba & 0x0000FF00) >> 8) / 255.0f;
    CGFloat alpha = (rgba & 0x000000FF) / 255.0f;
    return [self initWithRed:red green:green blue:blue alpha:alpha];
}

- (uint32_t)RGBValue
{
    CGFloat rgba[4];
    [self getRGBAComponents:rgba];
    uint32_t red = rgba[0]*255;
    uint32_t green = rgba[1]*255;
    uint32_t blue = rgba[2]*255;
    return (red << 16) + (green << 8) + blue;
}

- (uint32_t)RGBAValue
{
    CGFloat rgba[4];
    [self getRGBAComponents:rgba];
    uint8_t red = rgba[0]*255;
    uint8_t green = rgba[1]*255;
    uint8_t blue = rgba[2]*255;
    uint8_t alpha = rgba[3]*255;
    return (red << 24) + (green << 16) + (blue << 8) + alpha;
}

- (CGFloat)red
{
    CGFloat rgba[4];
    [self getRGBAComponents:rgba];
    return rgba[0];
}

- (CGFloat)green
{
    CGFloat rgba[4];
    [self getRGBAComponents:rgba];
    return rgba[1];
}

- (CGFloat)blue
{
    CGFloat rgba[4];
    [self getRGBAComponents:rgba];
    return rgba[2];
}

- (CGFloat)alpha
{
    return CGColorGetAlpha(self.CGColor);
}

- (BOOL)isMonochromeOrRGB
{
    CGColorSpaceModel model = CGColorSpaceGetModel(CGColorGetColorSpace(self.CGColor));
    return model == kCGColorSpaceModelMonochrome || model == kCGColorSpaceModelRGB;
}

- (BOOL)isEquivalent:(id)object
{
    if ([object isKindOfClass:[self class]])
    {
        return [self isEquivalentToColor:object];
    }
    return NO;
}

- (BOOL)isEquivalentToColor:(UIColor *)color
{
    if ([self isMonochromeOrRGB] && [color isMonochromeOrRGB])
    {
        return self.RGBAValue == color.RGBAValue;
    }
    return [self isEqual:color];
}

- (instancetype)colorWithBrightness:(CGFloat)brightness
{
    brightness = MAX(brightness, 0.0f);
    
    CGFloat rgba[4];
    [self getRGBAComponents:rgba];
    
    return [[self class] colorWithRed:rgba[0] * brightness
                                green:rgba[1] * brightness
                                 blue:rgba[2] * brightness
                                alpha:rgba[3]];
}

- (instancetype)colorBlendedWithColor:(UIColor *)color factor:(CGFloat)factor
{
    factor = MIN(MAX(factor, 0.0f), 1.0f);
    
    CGFloat fromRGBA[4], toRGBA[4];
    [self getRGBAComponents:fromRGBA];
    [color getRGBAComponents:toRGBA];
    
    return [[self class] colorWithRed:fromRGBA[0] + (toRGBA[0] - fromRGBA[0]) * factor
                                green:fromRGBA[1] + (toRGBA[1] - fromRGBA[1]) * factor
                                 blue:fromRGBA[2] + (toRGBA[2] - fromRGBA[2]) * factor
                                alpha:fromRGBA[3] + (toRGBA[3] - fromRGBA[3]) * factor];
}
@end

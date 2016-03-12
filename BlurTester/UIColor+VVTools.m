//
//  UIColor+VVTools.m
//  BlurTester
//
//  Created by Vlas Voloshin on 12/03/2016.
//  Copyright © 2016 Vlas Voloshin. All rights reserved.
//

#import "UIColor+VVTools.h"

@implementation UIColor (VVTools)

- (CGColorSpaceModel)vv_colorSpaceModel
{
    return CGColorSpaceGetModel(CGColorGetColorSpace(self.CGColor));
}

- (NSString *)vv_hexStringValueRGBA
{
    NSString *rgbHexString = [self vv_hexStringValueRGB];
    if (rgbHexString == nil) {
        return nil;
    }
    
    CGFloat alpha = CGColorGetAlpha(self.CGColor);
    
    return [rgbHexString stringByAppendingFormat:@"%02X", (int)round(alpha * 0xFF)];
}

- (NSString *)vv_hexStringValueRGB
{
    CGFloat red, green, blue;
    if (self.vv_colorSpaceModel == kCGColorSpaceModelMonochrome) {
        BOOL successful = [self getWhite:&red alpha:NULL];
        if (!successful) {
            NSAssert(NO, @"Failed to get color white value. Did you specify an incompatible color?");
            return nil;
        }
        
        blue = green = red;
    } else {
        BOOL successful = [self getRed:&red green:&green blue:&blue alpha:NULL];
        if (!successful) {
            NSAssert(NO, @"Failed to get color RGBA values. Did you specify an incompatible color?");
            return nil;
        }
    }
    
    return [NSString stringWithFormat:@"#%02X%02X%02X", (int)round(red * 0xFF), (int)round(green * 0xFF), (int)round(blue * 0xFF)];
}

@end

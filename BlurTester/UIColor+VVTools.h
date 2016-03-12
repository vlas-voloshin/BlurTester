//
//  UIColor+VVTools.h
//  BlurTester
//
//  Created by Vlas Voloshin on 12/03/2016.
//  Copyright © 2016 Vlas Voloshin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (VVTools)

- (CGColorSpaceModel)vv_colorSpaceModel;
- (NSString *)vv_hexStringValueRGBA;
- (NSString *)vv_hexStringValueRGB;

@end

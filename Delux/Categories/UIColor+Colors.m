//
//  UIColor+Colors.m
//
//  Created by Darktt on 12/10/17.
//  Copyright (c) 2012 Darktt Personal Company. All rights reserved.
//

#import "UIColor+Colors.h"

static NSDictionary *colorLookup = nil;

@implementation UIColor (Colors)

#pragma mark - Random color

+ (UIColor *)randomColor
{
	CGFloat red =  (CGFloat)(arc4random()%255+1)/255.0f;
	CGFloat blue = (CGFloat)(arc4random()%255+1)/255.0f;
	CGFloat green = (CGFloat)(arc4random()%255+1)/255.0f;
    
//    NSLog(@"R:%.3f,G:%.3f,B:%.3f", red, green, blue);
    
	return [UIColor colorWithRed:red green:green blue:blue];
}

#pragma mark Custom Colors

+ (UIColor *)lightBrownColor
{
    return rgb(232, 230, 224);
}

+ (UIColor *)baseWhiteColor
{
    return rgb(232, 232, 232);
}

+ (UIColor *)facebookColor
{
    return rgb(59, 89, 182);
}

+ (UIColor *)newFacebookColor
{
    return rgb(66, 96, 153);
}

+ (UIColor *)twitterColor
{
    return rgb(144,209,237);
}

+ (UIColor *)googleRedColor
{
    return rgb(214, 36, 8);
}

+ (UIColor *)googleGreenColor
{
    return rgb(0, 215, 8);
}

+ (UIColor *)googleBlueColor
{
    return rgb(22, 69, 174);
}

+ (UIColor *)googleYellowColor
{
    return rgb(239, 186, 0);
}

+ (UIColor *)yahooRedColor
{
    return rgb(255, 0, 51);
}

+ (UIColor *)netEaseRedColor
{
    return rgb(198, 50, 53);
}

+ (UIColor *)windows8BlueColor
{
    return rgb(0, 173, 239);
}

+ (UIColor *)togoBoxGrayColor
{
    return rgb(76, 76, 76);
}

+ (UIColor *)togoBoxGreenColor
{
    return rgb(171, 248, 7);
}

+ (UIColor *)togoBoxPurpleColor
{
    return rgb(147, 33, 121);
}

+ (UIColor *)iOS7WhiteColor
{
    return rgb(247, 247, 247);
}

+ (UIColor *)iOS7BlueColor
{
    return rgb(0, 122, 255);
}

#pragma mark Falt Colors

// Red
+ (UIColor *)flatRedColor
{
    return rgb(231, 76, 60);
}

+ (UIColor *)flatDarkRedColor
{
    return rgb(192, 57, 43);
}

// Green
+ (UIColor *)flatGreenColor
{
    return rgb(46, 204, 113);
}

+ (UIColor *)flatDarkGreenColor
{
    return rgb(39, 174, 96);
}

// Blue
+ (UIColor *)flatBlueColor
{
    return rgb(52, 152, 219);
}

+ (UIColor *)flatDarkBlueColor
{
    return rgb(41, 128, 185);
}

// Teal
+ (UIColor *)flatTealColor
{
    return rgb(26, 188, 156);
}

+ (UIColor *)flatDarkTealColor
{
    return rgb(22, 160, 133);
}

// Purple
+ (UIColor *)flatPurpleColor
{
    return rgb(155, 89, 182);
}

+ (UIColor *)flatDarkPurpleColor
{
    return rgb(142, 68, 173);
}

// Black
+ (UIColor *)flatBlackColor
{
    return rgb(52, 73, 94);
}

+ (UIColor *)flatDarkBlackColor
{
    return rgb(44, 62, 80);
}

// Yellow
+ (UIColor *)flatYellowColor
{
    return rgb(241, 196, 15);
}

+ (UIColor *)flatDarkYellowColor
{
    return rgb(243, 156, 18);
}

// Orange
+ (UIColor *)flatOrangeColor
{
    return rgb(230, 126, 34);
}

+ (UIColor *)flatDarkOrangeColor
{
    return rgb(211, 84, 0);
}

// White
+ (UIColor *)flatWhiteColor
{
    return rgb(236, 240, 241);
}

+ (UIColor *)flatDarkWhiteColor
{
    return rgb(189, 195, 199);
}

// Gray
+ (UIColor *)flatGrayColor
{
    return rgb(149, 165, 166);
}

+ (UIColor *)flatDarkGrayColor
{
    return rgb(127, 140, 141);
}

#pragma mark - Fork from KXKiOS7Colors

+ (UIColor *)iOS7LightGreenColor
{
    return rgb(135, 252, 112);
}

+ (UIColor *)iOS7MidGreenColor
{
    return rgb(99, 218, 56);
}

+ (UIColor *)iOS7DarkGreenColor
{
    return rgb(12, 211, 24);
}

+ (UIColor *)iOS7LightGreyColor
{
    return rgb(220, 221, 222);
}

+ (UIColor *)iOS7DarkGreyColor
{
    return rgb(136, 139, 144);
}

+ (UIColor *)iOS7LightBlueColor
{
    return rgb(25, 214, 253);
}

+ (UIColor *)iOS7MidBlueColor
{
    return rgb(86, 183, 241);
}

+ (UIColor *)iOS7DarkBlueColor
{
    return rgb(29, 98, 240);
}

+ (UIColor *)iOS7LightPinkColor
{
    return rgb(255, 41, 141);
}

+ (UIColor *)iOS7DarkPinkColor
{
    return rgb(255, 41, 105);
}

+ (UIColor *)iOS7RedColor
{
    return rgb(255, 59, 48);
}

+ (UIColor *)iOS7LightOrangeColor
{
    return rgb(255, 149, 0);
}

+ (UIColor *)iOS7DarkOrangeColor
{
    return rgb(255, 94, 58);
}

+ (UIColor *)iOS7LightTealColor
{
    return rgb(81, 237, 198);
}

+ (UIColor *)iOS7LightPurpleColor
{
    return rgb(239, 77, 182);
}

+ (UIColor *)iOS7DarkPurpleColor
{
    return rgb(199, 67, 252);
}

+ (UIColor *)iOS7BrownColor
{
    return rgb(162, 132, 94);
}

+ (UIColor *)iOS7YellowColor
{
    return rgb(234, 187, 0);
}

#pragma mark - Set Color With Hexadecimal

+ (UIColor *)colorWithHex:(UInt32)hex
{
	int r = (hex >> 16) & 0xFF;
	int g = (hex >> 8) & 0xFF;
	int b = (hex) & 0xFF;
    
	return rgb(r,g,b);
}

+ (UIColor *)colorWithHexString:(NSString *)hex
{
    if ([hex length] != 6 && [hex length] != 3) return nil;
    
    NSUInteger digits = [hex length]/3;
    
    int red, green, blue;
    sscanf([[hex substringWithRange:NSMakeRange(0, digits)] UTF8String], "%x", &red);
    sscanf([[hex substringWithRange:NSMakeRange(digits, digits)] UTF8String], "%x", &green);
    sscanf([[hex substringWithRange:NSMakeRange(2 * digits, digits)] UTF8String], "%x", &blue);
    
    CGFloat maxValue = (digits == 1) ? 15.0 : 255.0;
    return [UIColor colorWithRed:red / maxValue green:green / maxValue blue:blue / maxValue alpha:1.0];
}

#pragma mark - Get Color Web Safe Color

+ (UIColor *)colorWithColorName:(NSString *)name
{
	if (colorLookup == nil)
	{
		colorLookup = [[NSDictionary alloc] initWithObjectsAndKeys:
                       @"F0F8FF",@"aliceblue",
                       @"FAEBD7",@"antiquewhite",
                       @"00FFFF",@"aqua",
                       @"7FFFD4",@"aquamarine",
                       @"F0FFFF",@"azure",
                       @"F5F5DC",@"beige",
                       @"FFE4C4",@"bisque",
                       @"000000",@"black",
                       @"FFEBCD",@"blanchedalmond",
                       @"0000FF",@"blue",
                       @"8A2BE2",@"blueviolet",
                       @"A52A2A",@"brown",
                       @"DEB887",@"burlywood",
                       @"5F9EA0",@"cadetblue",
                       @"7FFF00",@"chartreuse",
                       @"D2691E",@"chocolate",
                       @"FF7F50",@"coral",
                       @"6495ED",@"cornflowerblue",
                       @"FFF8DC",@"cornsilk",
                       @"DC143C",@"crimson",
                       @"00FFFF",@"cyan",
                       @"00008B",@"darkblue",
                       @"008B8B",@"darkcyan",
                       @"B8860B",@"darkgoldenrod",
                       @"A9A9A9",@"darkgray",
                       @"A9A9A9",@"darkgrey",
                       @"006400",@"darkgreen",
                       @"BDB76B",@"darkkhaki",
                       @"8B008B",@"darkmagenta",
                       @"556B2F",@"darkolivegreen",
                       @"FF8C00",@"darkorange",
                       @"9932CC",@"darkorchid",
                       @"8B0000",@"darkred",
                       @"E9967A",@"darksalmon",
                       @"8FBC8F",@"darkseagreen",
                       @"483D8B",@"darkslateblue",
                       @"2F4F4F",@"darkslategray",
                       @"2F4F4F",@"darkslategrey",
                       @"00CED1",@"darkturquoise",
                       @"9400D3",@"darkviolet",
                       @"FF1493",@"deeppink",
                       @"00BFFF",@"deepskyblue",
                       @"696969",@"dimgray",
                       @"696969",@"dimgrey",
                       @"1E90FF",@"dodgerblue",
                       @"B22222",@"firebrick",
                       @"FFFAF0",@"floralwhite",
                       @"228B22",@"forestgreen",
                       @"FF00FF",@"fuchsia",
                       @"DCDCDC",@"gainsboro",
                       @"F8F8FF",@"ghostwhite",
                       @"FFD700",@"gold",
                       @"DAA520",@"goldenrod",
                       @"808080",@"gray",
                       @"808080",@"grey",
                       @"008000",@"green",
                       @"ADFF2F",@"greenyellow",
                       @"F0FFF0",@"honeydew",
                       @"FF69B4",@"hotpink",
                       @"CD5C5C",@"indianred",
                       @"4B0082",@"indigo",
                       @"FFFFF0",@"ivory",
                       @"F0E68C",@"khaki",
                       @"E6E6FA",@"lavender",
                       @"FFF0F5",@"lavenderblush",
                       @"7CFC00",@"lawngreen",
                       @"FFFACD",@"lemonchiffon",
                       @"ADD8E6",@"lightblue",
                       @"F08080",@"lightcoral",
                       @"E0FFFF",@"lightcyan",
                       @"FAFAD2",@"lightgoldenrodyellow",
                       @"D3D3D3",@"lightgray",
                       @"D3D3D3",@"lightgrey",
                       @"90EE90",@"lightgreen",
                       @"FFB6C1",@"lightpink",
                       @"FFA07A",@"lightsalmon",
                       @"20B2AA",@"lightseagreen",
                       @"87CEFA",@"lightskyblue",
                       @"778899",@"lightslategray",
                       @"778899",@"lightslategrey",
                       @"B0C4DE",@"lightsteelblue",
                       @"FFFFE0",@"lightyellow",
                       @"00FF00",@"lime",
                       @"32CD32",@"limegreen",
                       @"FAF0E6",@"linen",
                       @"FF00FF",@"magenta",
                       @"800000",@"maroon",
                       @"66CDAA",@"mediumaquamarine",
                       @"0000CD",@"mediumblue",
                       @"BA55D3",@"mediumorchid",
                       @"9370D8",@"mediumpurple",
                       @"3CB371",@"mediumseagreen",
                       @"7B68EE",@"mediumslateblue",
                       @"00FA9A",@"mediumspringgreen",
                       @"48D1CC",@"mediumturquoise",
                       @"C71585",@"mediumvioletred",
                       @"191970",@"midnightblue",
                       @"F5FFFA",@"mintcream",
                       @"FFE4E1",@"mistyrose",
                       @"FFE4B5",@"moccasin",
                       @"FFDEAD",@"navajowhite",
                       @"000080",@"navy",
                       @"FDF5E6",@"oldlace",
                       @"808000",@"olive",
                       @"6B8E23",@"olivedrab",
                       @"FFA500",@"orange",
                       @"FF4500",@"orangered",
                       @"DA70D6",@"orchid",
                       @"EEE8AA",@"palegoldenrod",
                       @"98FB98",@"palegreen",
                       @"AFEEEE",@"paleturquoise",
                       @"D87093",@"palevioletred",
                       @"FFEFD5",@"papayawhip",
                       @"FFDAB9",@"peachpuff",
                       @"CD853F",@"peru",
                       @"FFC0CB",@"pink",
                       @"DDA0DD",@"plum",
                       @"B0E0E6",@"powderblue",
                       @"800080",@"purple",
                       @"FF0000",@"red",
                       @"BC8F8F",@"rosybrown",
                       @"4169E1",@"royalblue",
                       @"8B4513",@"saddlebrown",
                       @"FA8072",@"salmon",
                       @"F4A460",@"sandybrown",
                       @"2E8B57",@"seagreen",
                       @"FFF5EE",@"seashell",
                       @"A0522D",@"sienna",
                       @"C0C0C0",@"silver",
                       @"87CEEB",@"skyblue",
                       @"6A5ACD",@"slateblue",
                       @"708090",@"slategray",
                       @"708090",@"slategrey",
                       @"FFFAFA",@"snow",
                       @"00FF7F",@"springgreen",
                       @"4682B4",@"steelblue",
                       @"D2B48C",@"tan",
                       @"008080",@"teal",
                       @"D8BFD8",@"thistle",
                       @"FF6347",@"tomato",
                       @"40E0D0",@"turquoise",
                       @"EE82EE",@"violet",
                       @"F5DEB3",@"wheat",
                       @"FFFFFF",@"white",
                       @"F5F5F5",@"whitesmoke",
                       @"FFFF00",@"yellow",
                       @"9ACD32",@"yellowgreen", nil];
	}
    
	NSString *hexString = [colorLookup objectForKey:[name lowercaseString]];
    
	return [UIColor colorWithHexString:hexString];
}

#pragma mark - Set Color With RGB

+ (UIColor *)colorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue
{
    return [UIColor colorWithRed:red green:green blue:blue alpha:1.0f];
}

#pragma mark - Output Color Components

+ (NSArray *)colorComponentsFromColor:(UIColor *)color
{
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    NSString *colorAsString = [NSString stringWithFormat:@"Red : %.0f, Green : %.0f, Blue : %.0f, Alpha : %.0f", components[0]*255.0, components[1]*255.0, components[2]*255.0, components[3]*100];
    NSArray *componentsArr = [colorAsString componentsSeparatedByString:@","];
    
    return componentsArr;
}

- (NSArray *)colorComponents
{
    return [UIColor colorComponentsFromColor:self];
}

@end

//
//  TIToken.m
//  Mailer
//
//  Created by wuli on 14-5-12.
//  Copyright (c) 2014年 Knotable. All rights reserved.
//

#import "TIToken.h"
#import "TITokenField.h"
#import "TITokenConfig.h"
@interface UIColor (Private)
- (BOOL)ti_getRed:(CGFloat *)red green:(CGFloat *)green blue:(CGFloat *)blue alpha:(CGFloat *)alpha;
@end

CGFloat const hTextPadding = 14;
CGFloat const vTextPadding = 8;
CGFloat const kDisclosureThickness = 2.5;
#if IOS7_API
NSLineBreakMode const kLineBreakMode = NSLineBreakByTruncatingTail;
#else
UILineBreakMode const kLineBreakMode = UILineBreakModeTailTruncation;
#endif

@interface TIToken (Private)
CGPathRef CGPathCreateTokenPath(CGFloat width, CGFloat arcValue, BOOL innerPath);
CGPathRef CGPathCreateDisclosureIndicatorPath(CGPoint arrowPointFront, CGFloat height, CGFloat thickness, CGFloat * width);
@end

@implementation TIToken
- (id)initWithTitle:(NSString *)aTitle {
	return [self initWithTitle:aTitle representedObject:nil];
}

- (id)initWithTitle:(NSString *)aTitle representedObject:(id)object {
	return [self initWithTitle:aTitle representedObject:object font:[UIFont systemFontOfSize:14]];
}

- (id)initWithTitle:(NSString *)aTitle representedObject:(id)object font:(UIFont *)aFont {
	
	if ((self = [super init])){
		self.font = aFont;
        self.representedObject = object;
		self.accessoryType = TITokenAccessoryTypeNone;
		
        self.title = aTitle;

		self.tintColor = [UIColor colorWithRed:0.216 green:0.373 blue:0.965 alpha:1];
		self.maxWidth = 200;
		[self sizeToFit];
		
		[self setBackgroundColor:[UIColor clearColor]];
	}
	
	return self;
}

- (void)sizeToFit {
	
	CGFloat accessoryWidth = 0;
	
	if (self.accessoryType == TITokenAccessoryTypeDisclosureIndicator){
		CGPathRelease(CGPathCreateDisclosureIndicatorPath(CGPointZero, self.font.pointSize, kDisclosureThickness, &accessoryWidth));
		accessoryWidth += floorf(hTextPadding / 2);
	}
	
#if IOS7_API
//    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:self.title
//                                                                         attributes:@{ NSFontAttributeName: self.font }];
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = kLineBreakMode;
    paragraphStyle.alignment = NSTextAlignmentLeft;
    CGRect titleRect = [self.title boundingRectWithSize:CGSizeMake(self.maxWidth - hTextPadding - accessoryWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.font,NSParagraphStyleAttributeName:paragraphStyle} context:nil];
    CGSize titleSize = titleRect.size;
#else
    CGSize titleSize = [self.title sizeWithFont:self.font forWidth:(self.maxWidth - hTextPadding - accessoryWidth) lineBreakMode:kLineBreakMode];
#endif
    
	[self setFrame:((CGRect){self.frame.origin, {floorf(titleSize.width + hTextPadding + accessoryWidth), floorf(titleSize.height + vTextPadding)}})];
	[self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGFloat arcValue = ((self.bounds.size.height - (vTextPadding / 2)) / 2) + 1;
	BOOL drawHighlighted = (self.selected || self.highlighted);
	
	CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
	CGPoint endPoint = CGPointMake(0, self.bounds.size.height);
	
	// Draw the outline.
	CGContextSaveGState(context);
	
	CGPathRef outlinePath = CGPathCreateTokenPath(self.bounds.size.width, arcValue, NO);
	CGContextAddPath(context, outlinePath);
	CGPathRelease(outlinePath);
	
	CGFloat red = 1;
	CGFloat green = 1;
	CGFloat blue = 1;
	CGFloat alpha = 1;
	[self.tintColor ti_getRed:&red green:&green blue:&blue alpha:&alpha];
	
	if (drawHighlighted){
		CGContextSetFillColor(context, (CGFloat[4]){red, green, blue, 1});
		CGContextFillPath(context);
	}
	else
	{
		CGContextClip(context);
		CGFloat locations[2] = {0, 0.95};
		CGFloat components[8] = {red + 0.2, green + 0.2, blue + 0.2, alpha, red, green, blue, alpha};
		CGGradientRef gradient = CGGradientCreateWithColorComponents(colorspace, components, locations, 2);
		CGContextDrawLinearGradient(context, gradient, CGPointZero, endPoint, 0);
		CGGradientRelease(gradient);
	}
	
	CGContextRestoreGState(context);
	
	CGPathRef innerPath = CGPathCreateTokenPath(self.bounds.size.width, arcValue, YES);
    
    // Draw a white background so we can use alpha to lighten the inner gradient
    CGContextSaveGState(context);
	CGContextAddPath(context, innerPath);
    CGContextSetFillColor(context, (CGFloat[4]){1, 1, 1, 1});
    CGContextFillPath(context);
    CGContextRestoreGState(context);
	
	// Draw the inner gradient.
	CGContextSaveGState(context);
	CGContextAddPath(context, innerPath);
	CGPathRelease(innerPath);
	CGContextClip(context);
	
	CGFloat locations[2] = {0, (drawHighlighted ? 0.9 : 0.6)};
    CGFloat highlightedComp[8] = {red, green, blue, 0.7, red, green, blue, 1};
    CGFloat nonHighlightedComp[8] = {red, green, blue, 0.15, red, green, blue, 0.3};
	
	CGGradientRef gradient = CGGradientCreateWithColorComponents(colorspace, (drawHighlighted ? highlightedComp : nonHighlightedComp), locations, 2);
	CGContextDrawLinearGradient(context, gradient, CGPointZero, endPoint, 0);
	CGGradientRelease(gradient);
	CGContextRestoreGState(context);
	
	CGFloat accessoryWidth = 0;
	
	if (_accessoryType == TITokenAccessoryTypeDisclosureIndicator){
		CGPoint arrowPoint = CGPointMake(self.bounds.size.width - floorf(hTextPadding / 2), (self.bounds.size.height / 2) - 1);
		CGPathRef disclosurePath = CGPathCreateDisclosureIndicatorPath(arrowPoint, _font.pointSize, kDisclosureThickness, &accessoryWidth);
		accessoryWidth += floorf(hTextPadding / 2);
		
		CGContextAddPath(context, disclosurePath);
		CGContextSetFillColor(context, (CGFloat[4]){1, 1, 1, 1});
		
		if (drawHighlighted){
			CGContextFillPath(context);
		}
		else
		{
			CGContextSaveGState(context);
			CGContextSetShadowWithColor(context, CGSizeMake(0, 1), 1, [[[UIColor whiteColor] colorWithAlphaComponent:0.6] CGColor]);
			CGContextFillPath(context);
			CGContextRestoreGState(context);
			
			CGContextSaveGState(context);
			CGContextAddPath(context, disclosurePath);
			CGContextClip(context);
			
			CGGradientRef disclosureGradient = CGGradientCreateWithColorComponents(colorspace, highlightedComp, NULL, 2);
			CGContextDrawLinearGradient(context, disclosureGradient, CGPointZero, endPoint, 0);
			CGGradientRelease(disclosureGradient);
			
			arrowPoint.y += 0.5;
			CGPathRef innerShadowPath = CGPathCreateDisclosureIndicatorPath(arrowPoint, _font.pointSize, kDisclosureThickness, NULL);
			CGContextAddPath(context, innerShadowPath);
			CGContextSetStrokeColor(context, (CGFloat[4]){0, 0, 0, 0.3});
			CGContextStrokePath(context);
			CGContextRestoreGState(context);
		}
		
		CGPathRelease(disclosurePath);
	}
	
	CGColorSpaceRelease(colorspace);
#if IOS7_API    
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = kLineBreakMode;
    paragraphStyle.alignment = NSTextAlignmentLeft;
    NSDictionary *attributes = @{NSFontAttributeName:self.font,NSParagraphStyleAttributeName:paragraphStyle};
    
    CGRect titleRect = [self.title boundingRectWithSize:CGSizeMake(self.maxWidth - hTextPadding - accessoryWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes  context:nil];
    CGSize titleSize = titleRect.size;
    
	CGFloat vPadding = floor((self.bounds.size.height - titleSize.height) / 2);
	CGFloat titleWidth = ceilf(self.bounds.size.width - hTextPadding - accessoryWidth);
	CGRect textBounds = CGRectMake(floorf(hTextPadding / 2), vPadding - 1, titleWidth, floorf(self.bounds.size.height - (vPadding * 2)));
	
	CGContextSetFillColor(context, (drawHighlighted ? (CGFloat[4]){1, 1, 1, 1} : (CGFloat[4]){0, 0, 0, 1}));

    
    [_title drawAtPoint:textBounds.origin withAttributes:attributes];
#else
	CGSize titleSize = [_title sizeWithFont:_font forWidth:(_maxWidth - hTextPadding - accessoryWidth) lineBreakMode:kLineBreakMode];
	CGFloat vPadding = floor((self.bounds.size.height - titleSize.height) / 2);
	CGFloat titleWidth = ceilf(self.bounds.size.width - hTextPadding - accessoryWidth);
	CGRect textBounds = CGRectMake(floorf(hTextPadding / 2), vPadding - 1, titleWidth, floorf(self.bounds.size.height - (vPadding * 2)));
	
	CGContextSetFillColor(context, (drawHighlighted ? (CGFloat[4]){1, 1, 1, 1} : (CGFloat[4]){0, 0, 0, 1}));
	[_title drawInRect:textBounds withFont:_font lineBreakMode:kLineBreakMode];
#endif
}

CGPathRef CGPathCreateTokenPath(CGFloat width, CGFloat arcValue, BOOL innerPath) {
	
	CGMutablePathRef path = CGPathCreateMutable();
	CGFloat radius = arcValue - (innerPath ? 0.5 : 0);
	CGPathAddArc(path, NULL, arcValue, arcValue, radius, (M_PI / 2), (M_PI * 3 / 2), NO);
	CGPathAddArc(path, NULL, width - arcValue, arcValue, radius, (M_PI  * 3 / 2), (M_PI / 2), NO);
	
	return path;
}

CGPathRef CGPathCreateDisclosureIndicatorPath(CGPoint arrowPointFront, CGFloat height, CGFloat thickness, CGFloat * width) {
	
	thickness /= cosf(M_PI / 4);
	
	CGMutablePathRef path = CGPathCreateMutable();
	CGPathMoveToPoint(path, NULL, arrowPointFront.x, arrowPointFront.y);
	
	CGPoint bottomPointFront = CGPointMake(arrowPointFront.x - (height / (2 * tanf(M_PI / 4))), arrowPointFront.y - height / 2);
	CGPathAddLineToPoint(path, NULL, bottomPointFront.x, bottomPointFront.y);
	
	CGPoint bottomPointBack = CGPointMake(bottomPointFront.x - thickness * cosf(M_PI / 4),  bottomPointFront.y + thickness * sinf(M_PI / 4));
	CGPathAddLineToPoint(path, NULL, bottomPointBack.x, bottomPointBack.y);
	
	CGPoint arrowPointBack = CGPointMake(arrowPointFront.x - thickness / cosf(M_PI / 4), arrowPointFront.y);
	CGPathAddLineToPoint(path, NULL, arrowPointBack.x, arrowPointBack.y);
	
	CGPoint topPointFront = CGPointMake(bottomPointFront.x, arrowPointFront.y + height / 2);
	CGPoint topPointBack = CGPointMake(bottomPointBack.x, topPointFront.y - thickness * sinf(M_PI / 4));
	
	CGPathAddLineToPoint(path, NULL, topPointBack.x, topPointBack.y);
	CGPathAddLineToPoint(path, NULL, topPointFront.x, topPointFront.y);
	CGPathAddLineToPoint(path, NULL, arrowPointFront.x, arrowPointFront.y);
	
	if (width) *width = (arrowPointFront.x - topPointBack.x);
	return path;
}

- (void)setHighlighted:(BOOL)flag {
	
	if (self.highlighted != flag){
		[super setHighlighted:flag];
		[self setNeedsDisplay];
	}
}

- (void)setSelected:(BOOL)flag {
	
	if (self.selected != flag){
		[super setSelected:flag];
		[self setNeedsDisplay];
	}
}
-(void)setTitle:(NSString *)title
{
    _title = title;
    [self sizeToFit];
}
-(void)setFont:(UIFont *)font
{
    if (!font) {
        _font = [UIFont systemFontOfSize:14];
    } else {
        _font = font;
    }
	[self sizeToFit];

}
-(void)setTintColor:(UIColor *)tintColor
{
    if (!tintColor) {
        tintColor =  [UIColor colorWithRed:0.867 green:0.906 blue:0.973 alpha:1];
    }
    _tintColor = tintColor;
    [self setNeedsDisplay];
}
-(void)setMaxWidth:(CGFloat)maxWidth
{
    if (_maxWidth != maxWidth) {
        _maxWidth = maxWidth;
		[self sizeToFit];
    }
}
-(void)setAccessoryType:(TITokenAccessoryType)accessoryType
{
    if (_accessoryType != accessoryType) {
        _accessoryType = accessoryType;
        [self sizeToFit];
    }
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<TIToken %p; title = \"%@\">", self, self.title];
}

- (void)dealloc {
}
@end

//==========================================================
#pragma mark - Private Additions -
//==========================================================
@implementation UIColor (Private)

- (BOOL)ti_getRed:(CGFloat *)red green:(CGFloat *)green blue:(CGFloat *)blue alpha:(CGFloat *)alpha {
	
	CGColorSpaceModel colorSpaceModel = CGColorSpaceGetModel(CGColorGetColorSpace(self.CGColor));
	const CGFloat * components = CGColorGetComponents(self.CGColor);
	
	if (colorSpaceModel == kCGColorSpaceModelMonochrome){
		
		if (red) *red = components[0];
		if (green) *green = components[0];
		if (blue) *blue = components[0];
		if (alpha) *alpha = components[1];
		return YES;
	}
	
	if (colorSpaceModel == kCGColorSpaceModelRGB){
		
		if (red) *red = components[0];
		if (green) *green = components[1];
		if (blue) *blue = components[2];
		if (alpha) *alpha = components[3];
		return YES;
	}
	
	return NO;
}

@end
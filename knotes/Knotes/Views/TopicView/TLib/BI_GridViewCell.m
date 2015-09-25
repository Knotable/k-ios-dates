//
//  BI_GridViewCell.m
//  BaiduIMLib
//
//  Created by backup on 11-10-9.
//  Copyright 2011年 backup. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "BI_GridViewCell.h"

///////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////

#ifdef TEXT_RENDERING_USING_SHOWGLYPHS

CG_EXTERN void CGFontGetGlyphsForUnichars(CGFontRef font, void* chars, CGGlyph* glyphs, int len)
CG_AVAILABLE_STARTING(__MAC_10_2, __IPHONE_2_0);

static CGFontRef sCGFontChinese = nil;
static CGFontRef sCGFontEnglish = nil;

enum
{
    GridCellTextTypeMixed,
    GridCellTextTypeChinese,
    GridCellTextTypeEnglish,
};

#endif

///////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////

@implementation BI_GridViewCell

@synthesize tag				= tag_;
@synthesize selected        = selected_;
@synthesize frameInfo       = frameInfo_;
@synthesize highlighted     = highlighted_;
@synthesize reuseIdentifier = reuseIdentifier_;

- (id)initWithReuseIdentifier:(NSString *)identifier 
{
    self = [super init];
    if (self) 
    {
        self.backgroundColor = [UIColor clearColor];
        reuseIdentifier_     = [identifier copy];
    }
    return self;
}

- (void)dealloc
{
    [frameInfo_       release];
    [reuseIdentifier_ release];
    [super            dealloc];
}

- (void)setHighlighted:(BOOL)value
{
	[self setHighlighted:value animated:NO];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{	
    if (highlighted_ != highlighted)
    {
        highlighted_ = highlighted;
        [self setNeedsDisplay];
    }
}

- (void)twinkle
{
    if (NO == highlighted_)
    {
        [self setHighlighted:YES animated:NO];
        if (redrawNow_)
        {
            [self.layer display];
            if ([[UIView class] respondsToSelector:@selector(flush)]) 
            {
                [[UIView class] performSelector:@selector(flush)];
            }
        }
    }
}

- (void)reset
{
    [frameInfo_ release];
    frameInfo_   = nil;
    selected_    = NO;
    highlighted_ = NO;
}

- (void)setSelected:(BOOL)value
{
	[self setSelected:value animated:NO];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    if (selected_ != selected)
    {
        selected_ = selected;
        [self setHighlighted:selected animated:animated];
        [self setNeedsDisplay];
    }
}


#ifdef TEXT_RENDERING_USING_SHOWGLYPHS

#pragma mark -
#pragma mark Text Drawing

+ (void)initialize
{
    if (self == [BI_GridViewCell class])
    {
        NSString *fontName = nil;
        if (nil == sCGFontChinese)
        {
            NSString *fontName = @"STHeitiSC-Light";
            sCGFontChinese = CGFontCreateWithFontName((CFStringRef)fontName);
        }
        
        if (nil == sCGFontEnglish) 
        {
            fontName = @"Helvetica Neue";
            sCGFontEnglish = CGFontCreateWithFontName((CFStringRef)fontName);
            
            if (nil == sCGFontEnglish)
            {
                fontName = @"Helvetica";
                sCGFontEnglish = CGFontCreateWithFontName((CFStringRef)fontName);
            }
        }
    }
}

+ (NSInteger)textTypeOfUnichars:(unichar *)unichars count:(NSInteger)count
{
    NSInteger num = 0;
    for (NSInteger i = 0; i < count; i++)
    {
        if (unichars[i] < 256)
        {
            num++;
        }
    }
    
    NSInteger type = GridCellTextTypeMixed;
    if (0 == num)
    {
        type = GridCellTextTypeChinese;
    }
    else if (num == count)
    {
        type = GridCellTextTypeEnglish;
    }
    return type;
}

+ (void)drawText:(NSString *)text inRect:(CGRect)rect withFont:(UIFont *)font inContext:(CGContextRef)context
{
    if (nil == sCGFontChinese) 
    {
        rect.origin.y += roundf((rect.size.height - font.pointSize) / 2);
        [text drawAtPoint:rect.origin withFont:font];
    }
    else
    {
        const size_t count = text.length;
        
        CGGlyph glyphs[count];
        unichar chars[count];
        [text getCharacters:chars range:NSMakeRange(0, count)];
        
        NSInteger type = [BI_GridViewCell textTypeOfUnichars:chars count:count];
        switch (type) 
        {
            case GridCellTextTypeChinese:
            case GridCellTextTypeEnglish:
            {
                rect.origin.y += rect.size.height - roundf((rect.size.height - font.pointSize) / 2) - 2;
                
                CGFontRef fontRef = GridCellTextTypeChinese == type ? sCGFontChinese : sCGFontEnglish;
                CGFontGetGlyphsForUnichars(fontRef, chars, glyphs, count);
                
                CGContextSetFont(context, fontRef);
                CGContextSetFontSize(context, font.pointSize);
                CGContextSetTextDrawingMode(context, kCGTextFill);
                CGContextSetTextMatrix(context, CGAffineTransformMake(1.0, 0.0, 0.0, -1.0, 0.0, 0.0));
                CGContextSetTextPosition(context, rect.origin.x, rect.origin.y);
                CGContextShowGlyphs(context, glyphs, count);
                break;
            }
                
            default:
            {
                rect.origin.y += roundf((rect.size.height - font.pointSize) / 2);
                [text drawAtPoint:rect.origin withFont:font];
                break;
            }
        }
    }
}
#endif
@end

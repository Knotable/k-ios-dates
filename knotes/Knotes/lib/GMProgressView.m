//
//  GMProgressView.m
//  RevealControllerProject
//
//  Created by backup on 13-11-11.
//
//

#import "GMProgressView.h"
#import "CUtil.h"

@interface GMProgressView ()

@property (nonatomic) NSTimer *timer;

@property (assign, nonatomic) CGFloat angle;//angle between two lines

@end
@implementation GMProgressView


- (id)initWithFrame:(CGRect)frame
          backColor:(UIColor *)backColor
      progressColor:(UIColor *)progressColor
          lineWidth:(CGFloat)lineWidth{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:30.0/255 green:40.0/255 blue:50.0/255 alpha:1];
        _backColor = backColor;
        _progressColor = progressColor;
        _lineWidth = lineWidth;
        _type = GMProgressCircle;//defalut is circle
    }
    [self setTitleText:@""];
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}
- (void)setTitleText:(NSString *)text
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 22)];
        _titleLabel.backgroundColor = kCustomColorBlue;
        _titleLabel.autoresizingMask =  UIViewAutoresizingFlexibleWidth;
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = kCustomBoldFont(10);
        [self addSubview:_titleLabel];
    }
    _titleLabel.text = text;
}
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    if (_titleLabel) {
        rect.size.height-=_titleLabel.frame.size.height;
        rect.origin.y+=_titleLabel.frame.size.height;
    }
    
    if (_showProgress) {
        if (!_progressLabel) {
            _progressLabel = [[UILabel alloc] init];
            _progressLabel.backgroundColor = [UIColor clearColor];
            _progressLabel.textColor = [UIColor whiteColor];
            _progressLabel.textAlignment = NSTextAlignmentCenter;
            _progressLabel.font = kCustomBoldFont(8);
            [self addSubview:_progressLabel];
        }
        _progressLabel.text = [NSString stringWithFormat:@"%d%%",(int)(self.progress*100)];
    }
    if (_type == GMProgressCircle) {
        if (_progressLabel) {
            [_progressLabel setFrame:rect];
        }
        CGPoint center = CGPointMake(rect.size.width/2, rect.origin.y+(rect.size.height)/2);

        CGFloat rediu = (MIN(CGRectGetHeight(rect), CGRectGetWidth(rect)) - self.lineWidth)/2-6;
        if (self.rediu) {
            rediu = self.rediu;
        }
        //draw background circle
        UIBezierPath *backCircle = [UIBezierPath bezierPathWithArcCenter:center
                                                                  radius:rediu
                                                              startAngle:(CGFloat) - M_PI_2
                                                                endAngle:(CGFloat)(1.5 * M_PI)
                                                               clockwise:YES];
        [self.backColor setStroke];
        backCircle.lineWidth = self.lineWidth;
        [backCircle stroke];
        if (self.progress) {
            //draw progress circle
            UIBezierPath *progressCircle = [UIBezierPath bezierPathWithArcCenter:center
                                                                          radius:rediu
                                                                      startAngle:(CGFloat) - M_PI_2
                                                                        endAngle:(CGFloat)(- M_PI_2 + self.progress * 2 * M_PI)
                                                                       clockwise:YES];
            [self.progressColor setStroke];
            progressCircle.lineWidth = self.lineWidth;
            [progressCircle stroke];
        }
    } else {
        if (_progressLabel) {
            [_progressLabel setFrame:CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, 20)];
            rect.origin.y+=20;
            rect.size.height-=20;
        }
        CGContextRef context = UIGraphicsGetCurrentContext() ;
        // save the context
        CGContextSaveGState(context) ;
        // allow antialiasing
        CGContextSetAllowsAntialiasing(context, TRUE) ;
        // we first draw the outter rounded rectangle
        rect = CGRectInset(rect, 1.0f, 1.0f) ;
        rect.size.height = 20;
        CGFloat radius = 0.5f * rect.size.height ;
        [self.backColor setStroke] ;
        CGContextSetLineWidth(context, 2.0f) ;
        CGContextBeginPath(context) ;
        CGContextMoveToPoint(context, CGRectGetMinX(rect), CGRectGetMidY(rect)) ;
        CGContextAddArcToPoint(context, CGRectGetMinX(rect), CGRectGetMinY(rect), CGRectGetMidX(rect), CGRectGetMinY(rect), radius) ;
        CGContextAddArcToPoint(context, CGRectGetMaxX(rect), CGRectGetMinY(rect), CGRectGetMaxX(rect), CGRectGetMidY(rect), radius) ;
        CGContextAddArcToPoint(context, CGRectGetMaxX(rect), CGRectGetMaxY(rect), CGRectGetMidX(rect), CGRectGetMaxY(rect), radius) ;
        CGContextAddArcToPoint(context, CGRectGetMinX(rect), CGRectGetMaxY(rect), CGRectGetMinX(rect), CGRectGetMidY(rect), radius) ;
        CGContextClosePath(context) ;
        CGContextDrawPath(context, kCGPathStroke) ;
        // draw the empty rounded rectangle (shown for the "unfilled" portions of the progress
        rect = CGRectInset(rect, 3.0f, 3.0f) ;
        radius = 0.5f * rect.size.height ;
        [self.progressColor setFill] ;
        CGContextBeginPath(context) ;
        CGContextMoveToPoint(context, CGRectGetMinX(rect), CGRectGetMidY(rect)) ;
        CGContextAddArcToPoint(context, CGRectGetMinX(rect), CGRectGetMinY(rect), CGRectGetMidX(rect), CGRectGetMinY(rect), radius) ;
        CGContextAddArcToPoint(context, CGRectGetMaxX(rect), CGRectGetMinY(rect), CGRectGetMaxX(rect), CGRectGetMidY(rect), radius) ;
        CGContextAddArcToPoint(context, CGRectGetMaxX(rect), CGRectGetMaxY(rect), CGRectGetMidX(rect), CGRectGetMaxY(rect), radius) ;
        CGContextAddArcToPoint(context, CGRectGetMinX(rect), CGRectGetMaxY(rect), CGRectGetMinX(rect), CGRectGetMidY(rect), radius) ;
        CGContextClosePath(context) ;
        CGContextFillPath(context) ;
        // draw the inside moving filled rounded rectangle
        radius = 0.5f * rect.size.height ;
        // make sure the filled rounded rectangle is not smaller than 2 times the radius
        rect.size.width *= self.progress ;
        if (rect.size.width < 2 * radius)
            rect.size.width = 2 * radius ;
        [[UIColor redColor] setFill] ;
        CGContextBeginPath(context) ;
        CGContextMoveToPoint(context, CGRectGetMinX(rect), CGRectGetMidY(rect)) ;
        CGContextAddArcToPoint(context, CGRectGetMinX(rect), CGRectGetMinY(rect), CGRectGetMidX(rect), CGRectGetMinY(rect), radius) ;
        CGContextAddArcToPoint(context, CGRectGetMaxX(rect), CGRectGetMinY(rect), CGRectGetMaxX(rect), CGRectGetMidY(rect), radius) ;
        CGContextAddArcToPoint(context, CGRectGetMaxX(rect), CGRectGetMaxY(rect), CGRectGetMidX(rect), CGRectGetMaxY(rect), radius) ;
        CGContextAddArcToPoint(context, CGRectGetMinX(rect), CGRectGetMaxY(rect), CGRectGetMinX(rect), CGRectGetMidY(rect), radius) ;
        CGContextClosePath(context) ;
        CGContextFillPath(context) ;
        
        // restore the context
        CGContextRestoreGState(context) ;
    }
}

- (void)updateProgressCircle{
    //update progress value
    self.progress = 0.4;//(float) (self.player.currentTime / self.player.duration);
    //redraw back & progress circles
    [self setNeedsDisplay];
}



//calculate angle between start to point
- (CGFloat)angleFromStartToPoint:(CGPoint)point{
    CGFloat angle = [self angleBetweenLinesWithLine1Start:CGPointMake(CGRectGetWidth(self.bounds) / 2,CGRectGetHeight(self.bounds) / 2) Line1End:CGPointMake(CGRectGetWidth(self.bounds) / 2,CGRectGetHeight(self.bounds) / 2 - 1) Line2Start:CGPointMake(CGRectGetWidth(self.bounds) / 2,CGRectGetHeight(self.bounds) / 2) Line2End:point];
    if (CGRectContainsPoint(CGRectMake(0, 0, CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame)), point)) {
        angle = 2 * M_PI - angle;
    }
    return angle;
}


//calculate angle between 2 lines
- (CGFloat)angleBetweenLinesWithLine1Start:(CGPoint)line1Start
                                  Line1End:(CGPoint)line1End
                                Line2Start:(CGPoint)line2Start
                                  Line2End:(CGPoint)line2End{
    CGFloat a = line1End.x - line1Start.x;
    CGFloat b = line1End.y - line1Start.y;
    CGFloat c = line2End.x - line2Start.x;
    CGFloat d = line2End.y - line2Start.y;
    return acos(((a*c) + (b*d)) / ((sqrt(a*a + b*b)) * (sqrt(c*c + d*d))));
}

@end

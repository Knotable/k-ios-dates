#import "UILabel+dynamicSizeMe.h"

@implementation UILabel (dynamicSizeMe)

-(float)resizeToFit{
    float height = [self expectedHeight];
    CGRect newFrame = [self frame];
    newFrame.size.height = height;
    [self setFrame:newFrame];
    return newFrame.origin.y + newFrame.size.height;
}

-(float)expectedHeight{
    [self setNumberOfLines:0];
    [self setLineBreakMode:NSLineBreakByTruncatingTail];

    CGSize maximumLabelSize = CGSizeMake(self.frame.size.width,CGFLOAT_MAX);
    
    CGRect expectedLabelSizeRect = [[self text] boundingRectWithSize:maximumLabelSize
                                                         options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                                      attributes:@{NSFontAttributeName:self.font}
                                                         context:nil];
                                
    return expectedLabelSizeRect.size.height;
}
-(float)expectedWidth{
    [self setNumberOfLines:0];
    [self setLineBreakMode:NSLineBreakByTruncatingTail];
    
    CGSize maximumLabelSize = CGSizeMake(self.frame.size.width,CGFLOAT_MAX);
    
    CGRect expectedLabelSizeRect = [[self text] boundingRectWithSize:maximumLabelSize
                                                             options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                                          attributes:@{NSFontAttributeName:self.font}
                                                             context:nil];
    return expectedLabelSizeRect.size.width;
}

@end

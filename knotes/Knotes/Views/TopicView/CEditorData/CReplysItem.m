//
//  CReplysItem.m
//  Knotable
//
//  Created by backup on 14-7-18.
//
//

#import "CReplysItem.h"
#import "DesignManager.h"
#import "HybridDocument.h"
#import "TextUtil.h"
@implementation CReplysItem
-(id)init
{
    self = [super init];
    if (self) {
        self.type = C_REPlYS;
        self.notShowUnderLine = YES;
    }
    return self;
}

-(int)getCellHeight
{
    CGFloat max_width = 298.00;

    CGSize boundingSize = [[TextUtil sharedInstance] getTextViewSize:self.attributedString withWidth:max_width];

    return boundingSize.height+10+5;
}

-(void)setContent:(NSDictionary *)content
{
    if (![_content isEqual:content]) {
        _content = content;
        if (!self.content) {
            _attributedString = [[NSAttributedString alloc] initWithString:@""];
            return;
        }
        
        NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        NSDictionary *attributedTextProperties = @{
                                                   NSFontAttributeName:[DesignManager knoteBodyFont],
                                                   NSForegroundColorAttributeName:[DesignManager knoteBodyTextColor],
                                                   NSBackgroundColorAttributeName:[UIColor clearColor],
                                                   NSParagraphStyleAttributeName:[paragraphStyle copy]
                                                   };
        
        NSString *text = content[@"body"] ;
        if (text && [text isKindOfClass:[NSString class]] && (text.length > 3)) {
            HybridDocument *document = [[HybridDocument alloc] initWithHTML:text];
            text = document.text;
            if(!text){
                text = @"";
            }
        }
        NSMutableAttributedString *mutAttStr = [[[NSAttributedString alloc] initWithString:text attributes:attributedTextProperties] mutableCopy];
        //    [mutAttStr insertAttributedString:usernameAtt atIndex:0];
        
        _attributedString = [mutAttStr copy];
    }
}
@end

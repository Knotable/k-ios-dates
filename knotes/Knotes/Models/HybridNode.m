//
// Created by Martin Ceperley on 5/8/14.
//

#import "HybridNode.h"
#import "ParsingManager.h"
#import "RegexKitLite.h"

@interface HybridNode ()

@property (nonatomic, assign) BOOL atEdge;

@end
@implementation HybridNode {

}

-(id)initWithText:(NSString *)text
{
    if(self = [super init]){
        self.text = text;
        self.isHTML = NO;
    }
    return self;
}

-(id)initWithHTML:(NSString *)html atEdge:(BOOL)atEdge
{
    if(self = [super init]){
        self.html = html;
        self.atEdge = atEdge;
        self.isHTML = YES;
        [self parseHTML];
    }
    return self;
}

-(id)initWithEscapeSequence:(NSString *)sequence
{
    if(self = [super init]){
        self.html = sequence;
        self.atEdge = NO;
        self.isHTML = YES;
        [self parseEscapeSequence];
    }
    return self;
}


-(void)parseEscapeSequence
{
    NSRange codeRange = [_html rangeOfRegex:@"\\&#?(.+);" capture:1];
    NSString *code = [_html substringWithRange:codeRange];
    NSInteger intValue = [code integerValue];
    if (intValue != 0) {
        self.text = [NSString stringWithFormat:@"%C", (unichar)intValue];
    } else {
        NSString *replacement = [[ParsingManager sharedInstance] htmlEscapeEntities][code];
        self.text = replacement;
    }
}

-(void)parseHTML
{

    NSString* foundTag = [_html lowercaseString];
    NSString* replacement = nil;
    if (_atEdge) {
        replacement = nil;
    } else if ([foundTag hasPrefix:@"</p"]) {
        replacement = @"\n";
    } else if ([foundTag hasPrefix:@"<br"]) {
        replacement = @"\n";
    } else if ([foundTag hasPrefix:@"<div"]) {
        replacement = @"\n";
    } else if ([foundTag hasPrefix:@"<tr"]) {
        replacement = @"\n";
    }

    self.text = replacement;

}

-(NSString *)description {
    return [NSString stringWithFormat:@"%@ node text: %@ html: %@", _isHTML ? @"HTML" : @"Text", _text, _html];
}


@end

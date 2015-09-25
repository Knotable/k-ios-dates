//
//  HybridDocument.m
//  Knotable
//
//  Created by Martin Ceperley on 5/8/14.
//
//

#import "HybridDocument.h"

#import "RegexKitLite.h"
#import "HybridNode.h"
#import "NSString+Knotes.h"

@interface  HybridDocument ()

@property (nonatomic, strong) NSMutableArray *nodes;

@end

@implementation HybridDocument

static NSString *HDDocumentHTML = @"HDDocumentHTML";

- (void)commonInit
{
}
- (id)initWithHTML:(NSString *)documentHTML
{
    self = [super init];
    if (self){
        //NSLog(@":\n%@", documentHTML);
        [self commonInit];

        NSLog(@". %@", self);
        self.documentHTML = documentHTML;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        [self commonInit];

        NSLog(@". %@", self);
        self.documentHTML = [coder decodeObjectForKey:HDDocumentHTML];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.documentHTML forKey:HDDocumentHTML];
}

- (void)setDocumentHTML:(NSString *)documentHTML {
    _documentHTML = documentHTML;
    NSLog(@".");
    [self processHTML];
    _documentHash = [_documentHTML md5];
}

-(void) processHTML
{
    if (_documentHTML == nil || ![_documentHTML isKindOfClass:[NSString class]]) {
        return;
    }

    NSRange r;
    self.nodes = [[NSMutableArray alloc] init];

    NSUInteger searchStart = 0;
    NSUInteger htmlLength = _documentHTML.length;
    
    HybridNode *hiddenEndNode = nil;

    NSRange replyStartRange = [_documentHTML rangeOfRegex:@"On .* wrote:"];
    if (replyStartRange.location != NSNotFound) {
        
        NSRange restOfDocRange = NSMakeRange(replyStartRange.location, htmlLength - replyStartRange.location);
        
        htmlLength = replyStartRange.location;
        
        NSString *html = [_documentHTML substringWithRange:restOfDocRange];
        hiddenEndNode = [[HybridNode alloc] initWithText:nil];
        hiddenEndNode.html = html;
        hiddenEndNode.isHTML = YES;
    }

    while ((r = [_documentHTML rangeOfRegex:@"<[^>]+>" inRange:NSMakeRange(searchStart, htmlLength-searchStart)]).location != NSNotFound)
    {
        if(r.location > searchStart){
            //Text node before it
            NSRange textRange = NSMakeRange(searchStart, r.location - searchStart);
            [self insertTextNodeFromRange:textRange];
        }

        NSString *html = [_documentHTML substringWithRange:r];
        NSString *foundTag = [html lowercaseString];

        //For XML and CSS, need to find end tag and count as all one tag
        BOOL specialTag = NO;
        for(NSArray *specialStartAndEndTags in @[@[@"<xml",@"</xml>"], @[@"<style",@"</style>"]]){
            NSString *startPrefix = specialStartAndEndTags[0];
            if ([foundTag hasPrefix:startPrefix] ) {
                NSString *endTag = specialStartAndEndTags[1];
                NSUInteger startSearchIndex = r.location + r.length;
                NSRange endTagRange = [_documentHTML rangeOfString:endTag options:0 range:NSMakeRange(startSearchIndex, htmlLength - startSearchIndex)];
                if(endTagRange.location != NSNotFound){
                    r.length = (endTagRange.location + endTagRange.length) - r.location;
                    html = [_documentHTML substringWithRange:r];
                    specialTag = YES;
                }
                break;
            }
        }
        
        //Look for gmail quote tag to hide
        if (!specialTag) {
            if ([foundTag rangeOfString:@"gmail_quote"].location != NSNotFound || [foundTag rangeOfString:@"gmail_extra"].location != NSNotFound) {
                //hide the rest of the document for now. it should find the end div, but that's hard.
                r.length = _documentHTML.length - r.location;
                html = [_documentHTML substringWithRange:r];
                specialTag = YES;
            }
            
        }

        BOOL atEdge = r.location == 0 || r.location + r.length == htmlLength;
        HybridNode *htmlNode = [[HybridNode alloc] initWithHTML:html atEdge:atEdge];
        [_nodes addObject:htmlNode];

        searchStart = r.location + r.length;
        if(searchStart >= htmlLength){
            break;
        }
    }

    //Last text node
    if(searchStart < htmlLength-1){
        [self insertTextNodeFromRange:NSMakeRange(searchStart, htmlLength - searchStart)];
    }
    
    //Hidden html node
    if (hiddenEndNode) {
        [_nodes addObject:hiddenEndNode];
    }

    //Done making list of nodes

    NSLog(@".");

    [self postProcessNodeText];
    [self updateText];

}


-(void)insertTextNodeFromRange:(NSRange)range
{
    NSString *text = [_documentHTML substringWithRange:range];
    
    NSMutableArray *textNodes = [[NSMutableArray alloc] init];
    //search for escape characters
    
    
    NSUInteger textLength = text.length;

    NSRange searchRange = NSMakeRange(0, textLength);
    NSRange foundRange;
    while((foundRange = [text rangeOfRegex:@"\\&#?[0-9a-zA-Z]+;" inRange:searchRange]).location != NSNotFound)
    {
        //Make text node before it
        if (foundRange.location > searchRange.location) {
            NSRange beforeTextRange = NSMakeRange(searchRange.location, foundRange.location-searchRange.location);
            NSString *beforeText = [text substringWithRange:beforeTextRange];
            [_nodes addObject:[[HybridNode alloc] initWithText:beforeText]];
        }
        
        NSString *escapedEntity = [text substringWithRange:foundRange];
        //NSLog(@"Found entity :%@", escapedEntity);
        
        [_nodes addObject:[[HybridNode alloc] initWithEscapeSequence:escapedEntity]];
        
        searchRange.location = foundRange.location + foundRange.length;
        searchRange.length = textLength - searchRange.location;
        
    }
    
    //Last or only text node
    if (searchRange.length > 0) {
        HybridNode *textNode = [[HybridNode alloc] initWithText:[text substringWithRange:searchRange]];
        [textNodes addObject:textNode];
    }
    
    [_nodes addObjectsFromArray:textNodes];
}

-(void)updateText
{
    NSMutableString *text = [[NSMutableString alloc] init];
    for (HybridNode *node in _nodes){
        NSString *nodeText = node.text;
        if(nodeText != nil){
            [text appendString:nodeText];
        }
    }
    _text = [text copy];
    //NSLog(@"updated text:\n%@\nend of text", _text);
}

-(void)updateHTML
{
    NSMutableString *html = [[NSMutableString alloc] init];
    for (HybridNode *node in _nodes){
        NSString *nodeHtml = node.html != nil ? node.html : node.text;
        if(nodeHtml != nil){
            [html appendString:nodeHtml];
        }
    }
    _documentHTML = [html copy];
    //NSLog(@"updated text:\n%@\nend of text", _text);
}

//Returns the node that contains the character at index, and sets textIndex to represent it's location
//For results at the end of the node's string, it will return an index equal to the length, as an insertion point

-(HybridNode *)nodeForTextIndex:(NSUInteger)textIndex
{
    
    NSUInteger searchedIndex = 0;
    for (HybridNode *node in _nodes){

        NSString *nodeText = node.text;
        if(nodeText != nil){
            NSUInteger nodeTextLength = nodeText.length;

            if(textIndex <= nodeTextLength + searchedIndex){
                NSUInteger localIndex = textIndex - searchedIndex;
                node.textIndex = localIndex;
                return node;
            }
            
            searchedIndex += nodeTextLength;
        }
    }
    return nil;
}

-(void)removeLeadingWhitespace
{
    //Need to remove leading whitespace from document
    for (HybridNode *node in _nodes){
        NSString *nodeText = node.text;
        if(nodeText != nil){
            NSRange leadingWhitespaceRange = [nodeText rangeOfRegex:@"^\\s+"];
            if(leadingWhitespaceRange.location != NSNotFound){
                NSUInteger newStartIndex = leadingWhitespaceRange.location + leadingWhitespaceRange.length;
                NSUInteger newLength = nodeText.length - newStartIndex;
                if(newLength > 0){
                    NSRange remainingRange = NSMakeRange(newStartIndex, newLength);
                    nodeText = [nodeText substringWithRange:remainingRange];
                } else {
                    nodeText = nil;
                }
                node.text = nodeText;
                if(nodeText != nil && nodeText.length > 0){
                    return;
                }
            } else if(nodeText.length > 0){
                return;
            }
        }
    }
}

-(void)removeTrailingWhitespace
{
    //Need to remove trailing whitespace from document
    for (HybridNode *node in [_nodes reverseObjectEnumerator]){
        NSString *nodeText = node.text;
        if(nodeText != nil){
            NSRange trailingWhitespaceRange = [nodeText rangeOfRegex:@"\\s+$"];
            if(trailingWhitespaceRange.location != NSNotFound){
                NSUInteger newLength = nodeText.length - trailingWhitespaceRange.length;
                if(newLength > 0){
                    NSRange remainingRange = NSMakeRange(0, newLength);
                    nodeText = [nodeText substringWithRange:remainingRange];
                } else {
                    nodeText = nil;
                }
                node.text = nodeText;
                if(nodeText != nil && nodeText.length > 0){
                    return;
                }
            } else if(nodeText.length > 0){
                return;
            }
        }
    }
}

-(void)simplerRemoveExcessiveNewlines
{
    //This should be a simpler approach to the below algorithm
    
    NSRange newlinesFoundRange;
    while ((newlinesFoundRange = [_text rangeOfRegex:@"(\n[ \t]*){3,}"]).location != NSNotFound) {
        
        
        //delete each character, starting from back
        for(int i = newlinesFoundRange.location + newlinesFoundRange.length - 1; i >= newlinesFoundRange.location; i--){
            [self deleteTextInRange:NSMakeRange(i, 1) deleteEmptyTags:NO];
        }
        
        //add two newlines
        [self changeTextInRange:NSMakeRange(newlinesFoundRange.location, 0) replacementText:@"\n\n" deleteEmptyTags:NO];
    }
}
-(void)removeExcessiveNewlines
{
    //Here we remove more than 3 consecutive newlines. this is tricky if they are overlapping node borders
    //To accomplish it, we have to search a node combined with the previous text, and then only replace the portion in the node

    NSLog(@". STARTING NEWLINE SEARCH");

    HybridNode *previousNode = nil;
    NSUInteger offset = 0;
    NSMutableString *combinedText = [[NSMutableString alloc] init];


    for (HybridNode *node in _nodes){
        if (node.text == nil) {
            continue;
        }
        NSLog(@"original node.text: \"%@\"", node.text);

        offset = combinedText.length;
        [combinedText appendString:node.text];
        previousNode = node;
        
        NSRange newlinesSearchRange = NSMakeRange(0, combinedText.length);
        NSRange newlinesFoundRange;
        NSMutableString *newNodeText = [node.text mutableCopy];
        NSRange replacementRange;
        NSString *replacement;
        
        //NSLog(@"searching combined text first time: \"%@\"", combinedText);
        
        BOOL changed = NO;

        while ((newlinesFoundRange = [combinedText rangeOfRegex:@"(\n[ \t]*){3,}" inRange:newlinesSearchRange]).location != NSNotFound) {
            changed = YES;
            NSLog(@"found newlines in range %@ search range %@ offset: %d", NSStringFromRange(newlinesFoundRange), NSStringFromRange(newlinesSearchRange), offset);

            if (newlinesFoundRange.location >= offset) {
                //all located in node
                NSLog(@"all located in node");
                replacement = @"\n\n";
                replacementRange = NSMakeRange(newlinesFoundRange.location - offset, newlinesFoundRange.length);
            } else {
                //overlapping previous node
                
                int lengthInPreviousNode = offset - newlinesFoundRange.location;
                
                replacementRange = NSMakeRange(0, newlinesFoundRange.length - lengthInPreviousNode);
                
                if (lengthInPreviousNode >= 2) {
                    replacement = @"";
                } else if (lengthInPreviousNode == 1) {
                    replacement = @"\n";
                }
            }
            NSLog(@"newNodeText length %d replacing range %@ with string length %d", newNodeText.length, NSStringFromRange(replacementRange), replacement.length);
            
            [newNodeText replaceCharactersInRange:replacementRange withString:replacement];
            NSLog(@"node after replacement at range: %@ : \"%@\"", NSStringFromRange(replacementRange), newNodeText);

            NSRange combinedTextReplacementRange = NSMakeRange(replacementRange.location + offset, replacementRange.length);
            NSLog(@"combinedText length %d replacing range %@ with string length %d", combinedText.length, NSStringFromRange(combinedTextReplacementRange), replacement.length);

            [combinedText replaceCharactersInRange:combinedTextReplacementRange withString:replacement];

            if (newNodeText.length == 0) {
                break;
            }
            
            newlinesSearchRange.location = (newlinesFoundRange.location + newlinesFoundRange.length) - (newlinesFoundRange.length - replacement.length);
            if (newlinesSearchRange.location >= combinedText.length - 1) {
                break;
            }
            newlinesSearchRange.length = combinedText.length - newlinesSearchRange.location;
    
            //NSLog(@"searching combined text again: \"%@\" search range: %@", combinedText, NSStringFromRange(newlinesSearchRange));

        }
        
        if (changed) {
            if (newNodeText.length == 0) {
                node.text = nil;
            } else {
                node.text = [newNodeText copy];
            }
            //NSLog(@"new node.text: \"%@\"", node.text);
        }
    }
}

-(void)postProcessNodeText
{
    NSLog(@".");
    [self removeLeadingWhitespace];
    [self removeTrailingWhitespace];
    
    [self updateText];
    [self simplerRemoveExcessiveNewlines];
}
- (void)deleteTextInRange:(NSRange)range deleteEmptyTags:(BOOL)deleteEmptyTags
{
    if (range.length == 0) return;
    
    NSRange rangeToDelete = range;
    
    NSMutableArray *nodesToDelete = [[NSMutableArray alloc] init];
    
    BOOL continuingDelete = NO;
    
    NSUInteger searchedIndex = 0;
    for (HybridNode *node in _nodes){
        NSString *nodeText = node.text;
        if(nodeText != nil){
            NSUInteger nodeTextLength = nodeText.length;
            if (rangeToDelete.location >= searchedIndex && rangeToDelete.location < searchedIndex + nodeTextLength) {
                //delete range starts in this node
                NSUInteger localStart = rangeToDelete.location - searchedIndex;
                NSUInteger localLength;
                if (range.location + range.length >= searchedIndex + nodeTextLength) {
                    //delete range goes past this node
                    localLength = nodeTextLength - localStart;
                    continuingDelete = YES;
                } else {
                    //contained within this node
                    localLength = rangeToDelete.length;
                }
                
                if (localLength == nodeTextLength) {
                    //Empty text node, delete it
                    if (deleteEmptyTags) {
                        [nodesToDelete addObject:node];
                    } else {
                        node.text = nil;
                    }
                } else {
                    node.text = [nodeText stringByReplacingCharactersInRange:NSMakeRange(localStart, localLength) withString:@""];
                }
                
                if (!continuingDelete) {
                    break;
                }
                
                rangeToDelete.length -= localLength;
                rangeToDelete.location += localLength;

            }
            
            searchedIndex += nodeTextLength;
        } else if(continuingDelete && deleteEmptyTags) {
            //Delete this HTML node
            [nodesToDelete addObject:node];
        }
    }
    
    [_nodes removeObjectsInArray:nodesToDelete];
    [self updateText];
    [self updateHTML];
}

- (void)changeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    [self changeTextInRange:range replacementText:text deleteEmptyTags:YES];
}

- (void)changeTextInRange:(NSRange)range replacementText:(NSString *)text deleteEmptyTags:(BOOL)deleteEmptyTags
{
    if (range.length > 0) {
        //deleting
        [self deleteTextInRange:range deleteEmptyTags:deleteEmptyTags];
    }
    if (text.length > 0) {
        //inserting
        HybridNode * node = [self nodeForTextIndex:range.location - range.length];
        NSUInteger localIndex = node.textIndex;
        if (localIndex == node.text.length) {
            node.text = [node.text stringByAppendingString:text];
        } else {
            node.text = [node.text stringByReplacingCharactersInRange:NSMakeRange(localIndex, 0) withString:text];
        }
        
    }
    
    [self updateText];
    [self updateHTML];
}

@end

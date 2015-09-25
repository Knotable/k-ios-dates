//
//  RKRichTextView.m
//  ACL Workpapers
//
//  Created by ren6 on 2/1/13.
//  Copyright (c) 2013 ACL Services Ltd. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "RKRichTextView.h"
#define RK_IS_IPAD ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
#define RK_IS_IPHONE ([UIDevice currentDevice].userInterfaceIdiom != UIUserInterfaceIdiomPad)

@interface RKRichTextView()<UIGestureRecognizerDelegate>
-(void) willChangeHeight:(int)newHeight;
-(void) willDidLoad;
-(void) onFocus;
-(void) onFocusOut;
-(void) touchMoved;
-(void) touchEnded;
-(void) onMetion:(NSString *)str;
-(void) onInsert:(NSString *)str;
@end
@implementation RKRichTextView{
    CGRect keyboardFrame;
    RKRichTextViewListener *listener;
    CGAffineTransform rotate;
    BOOL isHiding; BOOL isShowing;
    float screenHeight;
}
@synthesize isActiveResponder;
-(void) dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(void) richTextViewTapped{
    [self becomeFirstResponder];
}
-(void) awakeFromNib{
    [super awakeFromNib];
    [self setup];
}
-(id)init{
    self = [super init];
    if (self){
        [self setup];
    }
    return self;
}
-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        [self setup];
    }
    return self;
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return nil; // if disable zooming then content offset will remain still
}

-(void) setup
{
    self.opaque = NO;
    
    self.backgroundColor = [UIColor clearColor];
    
    self.scrollView.delegate = self;
    
    listener = [[RKRichTextViewListener alloc] init];
    listener.richTextView = self;
    
    screenHeight = [[UIScreen mainScreen] bounds].size.height;
    
    self.delegate = listener;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

    [self setText:@""];
}
//todo
//- (UIView *)inputAccessoryView{
//    return nil;
//}
- (void) keyboardWillHide:(NSNotification *)notif
{
}
- (void) keyboardWillShow:(NSNotification *)notif {
    [self performSelector:@selector(removeBar) withObject:nil afterDelay:0.0f];
}

-(void) onFocusOut{
    if ([((NSObject*)[self aDelegate]) respondsToSelector:@selector(richTextViewWillLooseFocus:)])
        [[self aDelegate] richTextViewWillLooseFocus:self];
    [self firstResponder:NO];
}
-(void) onFocus{
    if ([((NSObject*)[self aDelegate]) respondsToSelector:@selector(richTextViewWillReceiveFocus:)])
        [[self aDelegate] richTextViewWillReceiveFocus:self];
    [self firstResponder:YES];
}
-(void) touchEnded{
    isActiveResponder = YES;
}
-(void) onMetion:(NSString *)str
{
    if (self.aDelegate && [self.aDelegate respondsToSelector:@selector(onMention:withText:)]) {
        [self.aDelegate onMention:self withText:str];
    }
    NSLog(@"onMetion");
}
-(void) onInsert:(NSString *)str
{
    if (self.aDelegate && [self.aDelegate respondsToSelector:@selector(onMention:withText:)])
    {
        [self.aDelegate onInsert:self withText:str];
    }
    
    NSLog(@"onInsert:%@", str);
}

-(void) touchMoved
{
    
}

-(void) firstResponder:(BOOL) f
{
    isActiveResponder = f;
    
    if (isActiveResponder)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"richTextViewWillBecomeFirstResponder" object:nil];
    }
}

-(BOOL) becomeFirstResponder
{
    if ([self respondsToSelector:@selector(setKeyboardDisplayRequiresUserAction:)])
        self.keyboardDisplayRequiresUserAction = NO;
    
    [self firstResponder:YES];
    
    [self stringByEvaluatingJavaScriptFromString:@"document.getElementById('zss_editor_content').onfocus();"];
//    return [super becomeFirstResponder];
    return YES;
}
-(BOOL)resignFirstResponder{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"richTextViewWillResignFirstResponder" object:nil];
//    UITextField *t = [[UITextField alloc] initWithFrame:self.toolbarView.frame];
//    [self.toolbarView.superview addSubview:t];
//    [t becomeFirstResponder];
//    [t resignFirstResponder];
//    [t removeFromSuperview];

    [self stringByEvaluatingJavaScriptFromString:@"document.activeElement.blur()"];
    [self firstResponder:NO];
    
    return [super resignFirstResponder];
}
//-(void) setInputAccessoryView:(UIView *)inputAccessoryView{
//   
//}


-(void)didChangeSegmentControl:(UISegmentedControl*)sender{
    if ([((NSObject*)[self aDelegate]) respondsToSelector:@selector(prevNextControlTouched:)]){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"richTextViewWillBecomeFirstResponder" object:nil];
        [[self aDelegate] prevNextControlTouched:sender];
    }
}
-(void) willDidLoad{
    if ([((NSObject*)[self aDelegate]) respondsToSelector:@selector(richTextViewDidLoad:)])
        [[self aDelegate] richTextViewDidLoad:self];
}
-(void) willChangeHeight:(int)newHeight{
    self.scalesPageToFit = YES;
    self.scrollView.scrollEnabled = NO;
    if ([((NSObject*)[self aDelegate]) respondsToSelector:@selector(richTextViewDidChange:)])
        [[self aDelegate] richTextViewDidChange:self];
}
-(int)contentSizeHeight{
    return [[self stringByEvaluatingJavaScriptFromString:@"getHeight()"] intValue];
}
-(NSString*) text{
    NSString* t = [self stringByEvaluatingJavaScriptFromString:@"document.getElementById('zss_editor_content').innerHTML"];
    
    /*NSArray *stringsToRemove = [NSArray arrayWithObjects:
                                @"&nbsp;",
                                @" ",
                                @"<div>",
                                @"</div>",
                                @"<br>",
                                nil];*/
    NSArray *stringsToRemove = [NSArray arrayWithObjects:
                                @"&nbsp;",
                                nil];
    NSString *t2 = t;
    for (NSString *s in stringsToRemove)
        t2 = [t2 stringByReplacingOccurrencesOfString:s withString:@""];
    if ([t2 length] == 0 ){
        return @"";
    }
    //return t;
    return t2;
}
-(void)setText:(NSString *)richText{
    NSBundle *bundle = [NSBundle mainBundle];
    NSURL *indexFileURL = [bundle URLForResource:@"RKRichTextView" withExtension:@"html"];
	NSString *text = [NSString stringWithContentsOfURL:indexFileURL encoding:NSUTF8StringEncoding error:nil];
	text = [text stringByReplacingOccurrencesOfString:@"{%content}" withString:richText];
    
    NSString *source = [[NSBundle mainBundle] pathForResource:@"ZSSRichTextEditor" ofType:@"js"];
    NSString *jsString = [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:source] encoding:NSUTF8StringEncoding];
    text = [text stringByReplacingOccurrencesOfString:@"<!--editor-->" withString:jsString];
    
    NSString *source1 = [[NSBundle mainBundle] pathForResource:@"rangy-core" ofType:@"js"];
    NSString *jsString1 = [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:source1] encoding:NSUTF8StringEncoding];
    text = [text stringByReplacingOccurrencesOfString:@"<!--editor1-->" withString:jsString1];

    
    NSString *source2 = [[NSBundle mainBundle] pathForResource:@"rangy-cssclassapplier" ofType:@"js"];
    NSString *jsString2 = [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:source2] encoding:NSUTF8StringEncoding];
    text = [text stringByReplacingOccurrencesOfString:@"<!--editor2-->" withString:jsString2];

    
    NSString *source3 = [[NSBundle mainBundle] pathForResource:@"rangy-serializer" ofType:@"js"];
    NSString *jsString3 = [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:source3] encoding:NSUTF8StringEncoding];
    text = [text stringByReplacingOccurrencesOfString:@"<!--editor3-->" withString:jsString3];

	[self loadHTMLString:text baseURL:nil];
    self.scalesPageToFit = YES;
    self.scrollView.scrollEnabled = NO;
    for(UIView *wview in [[[self subviews] objectAtIndex:0] subviews]) {
        if([wview isKindOfClass:[UIImageView class]]) { wview.hidden = YES; }
    }
}
- (IBAction)boldAction:(id)sender {
    [self stringByEvaluatingJavaScriptFromString:@"document.execCommand(\"Bold\")"];
}

- (IBAction)italicAction:(id)sender {
    [self stringByEvaluatingJavaScriptFromString:@"document.execCommand(\"Italic\")"];
}

- (IBAction)underlineAction:(id)sender {
    [self stringByEvaluatingJavaScriptFromString:@"document.execCommand(\"underline\")"];
}
- (IBAction)strikeAction:(id)sender {
    [self stringByEvaluatingJavaScriptFromString:@"document.execCommand(\"strikeThrough\")"];
}

- (IBAction)orderedAction:(id)sender {
    [self stringByEvaluatingJavaScriptFromString:@"document.execCommand(\"insertOrderedList\")"];
    if ([((NSObject*)[self aDelegate]) respondsToSelector:@selector(richTextViewDidChange:)])
        [[self aDelegate] richTextViewDidChange:self];
}
- (IBAction)unorderedAction:(id)sender {
    [self stringByEvaluatingJavaScriptFromString:@"document.execCommand(\"insertUnorderedList\")"];
    if ([((NSObject*)[self aDelegate]) respondsToSelector:@selector(richTextViewDidChange:)])
        [[self aDelegate] richTextViewDidChange:self];
}

-(UIWindow*) keyWindow{
    for (UIWindow *testWindow in [[UIApplication sharedApplication] windows]) {
        if (![[testWindow class] isEqual:[UIWindow class]]) {
            return testWindow;
        }
    }
    return nil;
}
- (void)removeBar
{
    return;
    // Locate non-UIWindow.
    UIWindow *keyboardWindow = nil;
    for (UIWindow *testWindow in [[UIApplication sharedApplication] windows]) {
        if (![[testWindow class] isEqual:[UIWindow class]]) {
            keyboardWindow = testWindow;
            break;
        }
    }
    // Locate UIWebFormView.
    for (UIView *formView in [keyboardWindow subviews]) {
        // iOS 5 sticks the UIWebFormView inside a UIPeripheralHostView.
        if ([[formView description] rangeOfString:@"UIPeripheralHostView"].location != NSNotFound) {
            for (UIView *subView in [formView subviews]) {
                if ([[subView description] rangeOfString:@"UIWebFormAccessory"].location != NSNotFound) {
                    // remove the input accessory view
                    [subView setHidden:YES];
                    [subView removeFromSuperview];
                }
                else if([[subView description] rangeOfString:@"UIImageView"].location != NSNotFound){
                    // remove the line above the input accessory view (changing the frame)
                    [subView setHidden:YES];
                    [subView setFrame:CGRectZero];
                }
            }
        }
    }
}

@end

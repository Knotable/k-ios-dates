//
//  Debug.m
//  Market
//
//  Created by backup on 13-7-30.
//  Copyright (c) 2013年 liwu. All rights reserved.
//


#import "Debug.h"
#import <unistd.h>
#import <sys/sysctl.h>
@implementation Debug
+ (instancetype)defaultDebug
{
    static Debug *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[Debug alloc] init];
        sharedInstance.enableLog = YES;
    });
    return sharedInstance;
}
#ifdef __DEBUG__
void bd_show_view_hierarchy(UIView *view, NSInteger level)
{
    NSMutableString *indent = [NSMutableString string];
    for (NSInteger i = 0; i < level; i++)
    {
        [indent appendString:@"    "];
    }
//    printf("%s,%s\n",[[indent description] cStringUsingEncoding:NSUTF8StringEncoding],
//           [[view description] cStringUsingEncoding:NSUTF8StringEncoding]);
    NSLog(@"%@%@", indent, [view description]);
    
    for (UIView *item in view.subviews)
    {
        bd_show_view_hierarchy(item, level + 1);
    }
}

// From: http://developer.apple.com/mac/library/qa/qa2004/qa1361.html
int NIIsInDebugger(void) {
    int                 mib[4];
    struct kinfo_proc   info;
    size_t              size;
    
    // Initialize the flags so that, if sysctl fails for some bizarre
    // reason, we get a predictable result.
    
    info.kp_proc.p_flag = 0;
    
    // Initialize mib, which tells sysctl the info we want, in this case
    // we're looking for information about a specific process ID.
    
    mib[0] = CTL_KERN;
    mib[1] = KERN_PROC;
    mib[2] = KERN_PROC_PID;
    mib[3] = getpid();
    
    // Call sysctl.
    
    size = sizeof(info);
    sysctl(mib, sizeof(mib) / sizeof(*mib), &info, &size, NULL, 0);
    
    // We're being debugged if the P_TRACED flag is set.
    
    return (info.kp_proc.p_flag & P_TRACED) != 0;
}

#endif //__DEBUG__

#if 0
@interface UIView(Border)
@end

@implementation UIView(Border)

- (id)swizzled_initWithFrame:(CGRect)frame
{
    //    NSLog(@"===> ChangeFrame");
    // This is the confusing part (article explains this line).
    id result = [self swizzled_initWithFrame:frame];
    Class cls = NSClassFromString(@"BI_PanelViewSDK");
    // Safe guard: do we have an UIView (or something that has a layer)?
    if ([result respondsToSelector:@selector(layer)] && [self isKindOfClass:NSClassFromString(@"UIPeripheralHostView")])
        //if ([result respondsToSelector:@selector(layer)])
    {
        // Get layer for this view.
        CALayer *layer = [result layer];
        // Set border on layer.
        layer.borderWidth = 1;
        layer.borderColor = [[UIColor redColor] CGColor];
    }
    
    // Return the modified view.
    return result;
}

- (id)swizzled_initWithCoder:(NSCoder *)aDecoder
{
    // This is the confusing part (article explains this line).
    id result = [self swizzled_initWithCoder:aDecoder];
    Class cls = NSClassFromString(@"BI_PanelViewSDK");
    // Safe guard: do we have an UIView (or something that has a layer)?
    //if ([result respondsToSelector:@selector(layer)] && [self isKindOfClass:cls])
    if ([result respondsToSelector:@selector(layer)] && [self isKindOfClass:NSClassFromString(@"UIPeripheralHostView")])
        //if ([result respondsToSelector:@selector(layer)])
    {
        // Get layer for this view.
        CALayer *layer = [result layer];
        // Set border on layer.
        layer.borderWidth = 1;
        layer.borderColor = [[UIColor redColor] CGColor];
    }
    
    // Return the modified view.
    return result;
}

- (UIViewController *)swizzled_viewDelegate
{
    UIViewController *controller = [self swizzled_viewDelegate];
    //NSLog(@"swizzled_viewDelegate--%@-%@", controller, [NSThread callStackSymbols]);
    
    return controller;
}

- (void)swizzled_setTransform:(CGAffineTransform)transform
{
    [self swizzled_setTransform:transform];
    
#if 0
    if ([self isKindOfClass:NSClassFromString(@"UITextEffectsWindow")])
    {
        NSLog(@"-----transform is error here: %@", [NSThread callStackSymbols]);
    }
#endif
}

+ (void)load
{
    // The "+ load" method is called once, very early in the application life-cycle.
    // It's called even before the "main" function is called. Beware: there's no
    // autorelease pool at this point, so avoid Objective-C calls.
    Method original, swizzle;
    
    // Get the "- (id)initWithFrame:" method.
    original = class_getInstanceMethod(self, @selector(initWithFrame:));
    // Get the "- (id)swizzled_initWithFrame:" method.
    swizzle = class_getInstanceMethod(self, @selector(swizzled_initWithFrame:));
    // Swap their implementations.
    method_exchangeImplementations(original, swizzle);
    
    // Get the "- (id)initWithCoder:" method.
    original = class_getInstanceMethod(self, @selector(initWithCoder:));
    // Get the "- (id)swizzled_initWithCoder:" method.
    swizzle = class_getInstanceMethod(self, @selector(swizzled_initWithCoder:));
    // Swap their implementations.
    method_exchangeImplementations(original, swizzle);
    
    //viewDelegate
    //original = class_getInstanceMethod(self, @selector(_viewDelegate));
    //NSLog(@"---++++++++++-----original: %@", original);
    //swizzle = class_getInstanceMethod(self, @selector(swizzled_viewDelegate));
    //method_exchangeImplementations(original, swizzle);
    
    original = class_getInstanceMethod(self, @selector(setTransform:));
    swizzle = class_getInstanceMethod(self, @selector(swizzled_setTransform:));
    NSLog(@"+++++++++++++++++++++++++++------------------$$$$$$$$$$$$");
    method_exchangeImplementations(original, swizzle);
    
    //objc_msgSend();
    
    
    
    
}

#endif
#if 0
BOOL NIIsArrayWithObjects(id object) {
    return [object isKindOfClass:[NSArray class]] && [(NSArray*)object count] > 0;
}
BOOL NIIsPad(void) {
    static NSInteger isPad = -1;
    if (isPad < 0) {
        isPad = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) ? 1 : 0;
    }
    return isPad > 0;
}
BOOL NIIsStringWithAnyText(id object) {
    return [object isKindOfClass:[NSString class]] && [(NSString*)object length] > 0;
}
#endif
@end

//  KnotableRichTextController.m
//  Knotable
//  Created by @Malik-Hassan 7/13/15.

#import "KnotesRichTextController.h"

@interface KnotableRichTextController ()

@end

@implementation KnotableRichTextController

- (void)viewDidLoad {
    [super viewDidLoad];
    //Do any additional setup after loading the view.
    
    //<hr style='margin-top:5px;'/>
    
//    NSString *html = @"<u> &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp </u> <p>Example showing just a few toolbar buttons.</p>";
    
    NSString *html = @"";    
    
    // Choose which toolbar items to show
    self.enabledToolbarItems = @[ZSSRichTextEditorToolbarBold, ZSSRichTextEditorToolbarH1, ZSSRichTextEditorToolbarParagraph];
    
    // Set the HTML contents of the editor
    [self setHTML:html];
    
    //self.view.backgroundColor = [UIColor greenColor];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

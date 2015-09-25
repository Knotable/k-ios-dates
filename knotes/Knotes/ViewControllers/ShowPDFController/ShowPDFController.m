//
//  ShowPDFController.m
//  Knotable
//
//  Created by Martin Ceperley on 3/12/14.
//
//

#import "ShowPDFController.h"
#import "FileEntity.h"

@interface ShowPDFController ()

@property (nonatomic, strong) FileEntity *file;

@end

@implementation ShowPDFController

- (id)initWithFile:(FileEntity *)file
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.file = file;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];


    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectZero];
    webView.delegate = self;
    [self.view addSubview:webView];

    [webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(@0);
    }];

    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeButton setTitle:@"Close" forState:UIControlStateNormal];
    [closeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(closePressed) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:closeButton];

    [closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@20.0);
        make.right.equalTo(@-20.0);
    }];

    NSString *path = [self.file filePath];
    NSURL *targetURL = [NSURL fileURLWithPath:path];
    NSURLRequest *request = [NSURLRequest requestWithURL:targetURL];
    [webView loadRequest:request];

    NSLog(@"Webview loading URL: %@", targetURL);


}

- (void)closePressed
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(dismissPDFViewer)]){
        [self.delegate performSelector:@selector(dismissPDFViewer)];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"webViewDidFinishLoad");

}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"didFailLoadWithError: %@", error);
}


@end

//
//  ConnectGoogleController.m
//  Knotable
//
//  Created by Martin Ceperley on 2/19/14.
//
//

#import "ConnectGoogleController.h"
#import "ServerConfig.h"
#import "ObjCMongoDB.h"
#import "AccountEntity.h"
#include <stdlib.h>
#import "DataManager.h"

@interface ConnectGoogleController ()

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, copy) NSString *redirectURL;
@property (nonatomic, copy) NSString *credentialToken;

@property (nonatomic, copy) NSString *google_id;
@property (nonatomic, copy) NSString *google_user_id;

@end

@implementation ConnectGoogleController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        

    }
    return self;
}

- (NSString*)stringByEscapingForURLArgument:(NSString *)arg
{
    // Encode all the reserved characters, per RFC 3986
    // (<http://www.ietf.org/rfc/rfc3986.txt>)
    CFStringRef escaped =
            CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                    (__bridge CFStringRef)arg,
                    NULL,
                    (__bridge CFStringRef)@"!*'();:@&=+$,/?%#[]",
                    kCFStringEncodingUTF8);
    return (__bridge NSString *) escaped;
}

- (NSString *)randomID
{
    NSString *UNMISTAKABLE_CHARS = @"23456789ABCDEFGHJKLMNPQRSTWXYZabcdefghijkmnopqrstuvwxyz";
    int unmistakable_length = (int)UNMISTAKABLE_CHARS.length;
    NSUInteger output_length = 17;

    NSMutableString *output = [[NSMutableString alloc] initWithCapacity:output_length];

    for(int i=0;i<output_length;i++){
        NSUInteger charIndex = arc4random() % unmistakable_length;
        NSString *charString = [UNMISTAKABLE_CHARS substringWithRange:NSMakeRange(charIndex, 1)];
        [output appendString:charString];
    }
    return [output copy];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"Connect Gmail";
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
    cancelButton.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = cancelButton;


    _webView = [[UIWebView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:_webView];
    [_webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    _webView.delegate = self;

    [self startOAuth];
}
- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlackTranslucent];
}

- (void)startOAuth
{

    /*
    var loginUrl =
            'https://accounts.google.com/o/oauth2/auth' +
                    '?response_type=code' +
                    '&client_id=' + config.clientId +
                    '&scope=' + flatScope +
                    '&redirect_uri=' + Meteor.absoluteUrl('_oauth/google?close') +
                    '&state=' + credentialToken +
                    '&access_type=' + accessType +
                    '&approval_prompt=' + approvalPrompt;
     */
    
    NSString *client_id = [AppDelegate sharedDelegate].server.google_client_id;

    NSArray *requestPermissionList =  @[
            @"https://mail.google.com/", // imap
            @"https://www.googleapis.com/auth/userinfo.profile", // profile
            @"https://www.googleapis.com/auth/userinfo.email", // email
            @"https://www.google.com/m8/feeds/",
            @"https://www.google.com/reader/api/0/subscription"
    ];

    NSMutableArray *escaped_permissions = [[NSMutableArray alloc] init];
    
    for(NSString *permission in requestPermissionList)
    {
        [escaped_permissions addObject:[self stringByEscapingForURLArgument:permission]];
    }
    
    NSString *joined_escaped_permissions = [escaped_permissions componentsJoinedByString:@"+"];

    NSLog(@"joined_escaped_permissions: %@", joined_escaped_permissions);

    self.credentialToken = [self randomID];

    _redirectURL = [AppDelegate sharedDelegate].server.google_redirectURI;
    
//    self.redirectURL =//[NSString stringWithFormat:@"http://%@/_oauth/google?close", app.server.application_host];
    
    NSLog(@"redirectURL: %@", _redirectURL);

    NSString *url = [NSString stringWithFormat:@"https://accounts.google.com/o/oauth2/auth?response_type=code&client_id=%@&scope=%@&redirect_uri=%@&state=%@&access_type=%@&approval_prompt=%@",
                                               client_id,
                                               joined_escaped_permissions,
                                               [self stringByEscapingForURLArgument:_redirectURL],
                                               _credentialToken,
                                               @"offline",
                                               @"force"];

    NSLog(@"GOOGLE OAUTH URL: %@", url);

    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}

- (NSString *)encodeBodyData:(NSDictionary *)dict
{
    NSMutableArray *paramStrings = [[NSMutableArray alloc] init];
    [dict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [paramStrings addObject:[@[key,obj] componentsJoinedByString:@"="]];
    }];
    return [paramStrings componentsJoinedByString:@"&"];
}

- (void)requestToken:(NSString *)code
{
    NSString *client_id = [AppDelegate sharedDelegate].server.google_client_id;
    NSString *client_secret = [AppDelegate sharedDelegate].server.google_client_secret;

    NSDictionary *tokenParams = @{
            @"code":code,
            @"client_id":client_id,
            @"client_secret":client_secret,
            @"redirect_uri":@"http://localhost",//_redirectURL,
            @"grant_type":@"authorization_code"
    };

    NSString *bodyData = [self encodeBodyData:tokenParams];

    NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://accounts.google.com/o/oauth2/token"]];

    [postRequest setHTTPMethod:@"POST"];
    [postRequest setHTTPBody:[NSData dataWithBytes:[bodyData UTF8String] length:strlen([bodyData UTF8String])]];
    [postRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];

    [NSURLConnection sendAsynchronousRequest:postRequest
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
    {
        if(connectionError != nil)
        {
            NSLog(@"Error posting token: %@", connectionError);
        }
        else
        {
            //NSString *textData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

            NSError *jsonError = nil;
            NSDictionary *output = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];

            if(jsonError)
            {
                NSLog(@"Error decoding json: %@", jsonError);
            }
            else
            {
                NSString *access_token = output[@"access_token"];
                NSNumber *expires_in = output[@"expires_in"];
                NSString *id_token = output[@"id_token"];
                NSString *refresh_token = output[@"refresh_token"];


                NSString *identityURL = [NSString stringWithFormat:@"https://www.googleapis.com/oauth2/v1/userinfo?access_token=%@", access_token];

                NSLog(@"identityURL: %@", identityURL);

                NSURLRequest *identityRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:identityURL]];
                
                [NSURLConnection sendAsynchronousRequest:identityRequest
                                                   queue:[NSOperationQueue mainQueue]
                                       completionHandler:^(NSURLResponse *identityResponse, NSData *identityData, NSError *identityError)
                {
                    if(identityError)
                    {
                        NSLog(@"Error getting identity: %@", identityError);
                    }
                    else
                    {
                        NSError *identityJsonError = nil;
                        NSDictionary *identity = [NSJSONSerialization JSONObjectWithData:identityData options:0 error:&identityJsonError];

                        NSString *email = identity[@"email"];
                        NSString *google_id = identity[@"id"];
                        self.google_id = google_id;

                        NSString *family_name = identity[@"family_name"];
                        NSString *given_name = identity[@"given_name"];
                        NSString *locale = identity[@"locale"];
                        NSString *name = identity[@"name"];
                        NSString *picture = identity[@"picture"];
                        NSString *verified_email = identity[@"verified_email"];

                        //From google_server.js in meteor
                        NSArray *whitelisted_fields = @[@"id", @"email", @"verified_email", @"name", @"given_name",
                                @"family_name", @"picture", @"locale", @"timezone", @"gender"];

                        NSMutableDictionary *serviceData = [[NSMutableDictionary alloc] init];
                        serviceData[@"accessToken"] = access_token;
                        serviceData[@"expiresAt"] = @(1000.0 * ([[NSDate date] timeIntervalSince1970] + expires_in.doubleValue));
                        
                        //NSLog(@"expires_in value: %@ now: %f expiresAt: %@", expires_in, [[NSDate date] timeIntervalSince1970] , serviceData[@"expiresAt"]);

                        for(NSString *field in whitelisted_fields)
                        {
                            id value = identity[field];
                            
                            if(value)
                            {
                                serviceData[field] = value;
                            }
                        }
                        
                        if(refresh_token)
                        {
                            serviceData[@"refreshToken"] = refresh_token;
                        }

                        NSLog(@"saving to mongo with serviceData: %@", serviceData);

                        [[AppDelegate sharedDelegate] sendRequestSaveGoogle:serviceData
                                                    accountID:[DataManager sharedInstance].currentAccount.account_id withCompleteBlock:^(WM_NetworkStatus success, NSError *error, id userData)
                        {
                            if(success == NetworkSucc && userData != nil)
                            {
                                NSString *google_user_id = userData;
                                
                                self.google_user_id = google_user_id;

                                [self success];

                            }
                            else
                            {
                                NSLog(@"Error saving google user account");
                            }
                        }];

                    }
                }];
            }
        }
    }];



}

- (NSDictionary *)paramsFromRequest:(NSURLRequest *)request
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];

    NSArray *urlParts = [request.URL.absoluteString componentsSeparatedByString:@"?"];
    if(urlParts.count >= 2){

        NSString *parameterString = urlParts[1];
        NSArray *parameterPairs = [parameterString componentsSeparatedByString:@"&"];
        for(NSString *pairString in parameterPairs){
            NSArray *pair = [pairString componentsSeparatedByString:@"="];
            if(pair.count == 2){
                params[pair[0]] = pair[1];
            }
        }
    }

    return [params copy];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSRange range =  [request.URL.absoluteString rangeOfString:_redirectURL];

    if(_redirectURL && range.location == 0 && range.length > 0){
        NSLog(@"OAuth going back to meteor server");

        NSDictionary *params = [self paramsFromRequest:request];

        NSLog(@"params: %@", params);

        NSString *code = params[@"code"];
        NSLog(@"code: %@", code);

        if(code)
        {
            [self requestToken:code];
        }

        return NO;
    }

    return YES;
}

- (void)success
{
    self.navigationController.navigationBar.translucent = NO;
    
    if(self.delegate)
    {
        [self.delegate successConnectingGoogle:self.google_id user_id:self.google_user_id];
    }
}

- (void)cancel
{
    self.navigationController.navigationBar.translucent = NO;
    
    if(self.delegate)
    {
        [self.delegate cancelConnectGoogle];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

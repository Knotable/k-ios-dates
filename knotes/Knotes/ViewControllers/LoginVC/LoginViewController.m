//
//  ViewController.m
//  Knote
//
//  Created by JYN on 9/19/13.
//  Copyright (c) 2013 jackiejin. All rights reserved.
//


#import "LoginViewController.h"

#import "UserEntity.h"
#import "AccountEntity.h"

#import "DataManager.h"
#import "DesignManager.h"
#import "AnalyticsManager.h"

#import "ServerConfig.h"
#import "ObjCMongoDB.h"
#import "SVProgressHUD.h"

#import "UIImage+Retina4.h"
#import "NSString+Knotes.h"

#import <ObjectiveDDP/MeteorClient.h>
#import <Masonry/View+MASAdditions.h>
#import <Lookback/Lookback.h>

#define ktDefaultLoginTimeInterval 60.0


#define verticalGap 8.0

static CGFloat logoLowerPos = 118.0;
static CGFloat logoUpperPos = 100.0;

static CGFloat textFieldsLowerPos = 237.0;
static CGFloat textFieldsUpperPos = 190.0;


typedef enum
{
    LoginStateLoggingIn,
    LoginStateSigningUp,
    LoginStateTerms,
    LoginStateForgotPassword,
    LoginStateGetLink
} LoginState;

@interface LoginViewController (){
    @private
    BOOL preFilledUsername;
    UIResponder *currentResponder;
    LoginState loginState;
}

@property (strong, nonatomic) UILabel       *knotableLabel;
@property (strong, nonatomic) UIView        *loginGroup;
@property (strong, nonatomic) UIImageView   *background;
@property (strong, nonatomic) UIImageView   *logo;
@property (strong, nonatomic) UIImageView   *verticalDivider;
@property (strong, nonatomic) UITextField   *emailTextField;
@property (strong, nonatomic) UITextField   *usernameTextField;
@property (strong, nonatomic) UITextField   *passwordTextField;
@property (strong, nonatomic) UITextView    *termsTextView;
@property (strong, nonatomic) UIButton      *submitButton;
@property (strong, nonatomic) UIButton      *forgotPasswordButton;
@property (strong, nonatomic) UIButton      *fPasswordBackButton;
@property (strong, nonatomic) UIButton      *HelpButton;
@property (strong, nonatomic) UIButton      *bottomRightButton;
@property (strong, nonatomic) UIButton      *bottomgetLinkButton;
@property (strong, nonatomic) UIButton      *bottomLeftButton;
@property (strong, nonatomic) UIButton      *chooseServerButton;
@property (assign , nonatomic)  BOOL        isGetLinkActivated;
@property (assign , nonatomic)  BOOL        loggingIn;
@property (nonatomic, strong)   NSTimer     *checkTimer;
@property (strong , nonatomic)  NSString    *inputUsername;
@property (strong , nonatomic)  NSString    *inputPassword;
@property (strong , nonatomic)  NSString    *inputEmail;
@property (strong , nonatomic)  NSString    *inputFullname;

@property (assign, nonatomic) BOOL pressedButtonToLogin;


@property (strong, nonatomic)   NSMutableAttributedString   *chooseServerTitle;
@property (nonatomic, strong)   UIInterpolatingMotionEffect *horMotionEffect;
@property (nonatomic, strong)   UIInterpolatingMotionEffect *vertMotionEffect;
@property (strong, nonatomic)   UIActivityIndicatorView     *loginIndicator;

@property (strong, nonatomic)   MASConstraint *loginGroupTopConstraint;
@property (strong, nonatomic)   MASConstraint *passwordFieldTopConstraint;
@property (strong, nonatomic)   MASConstraint *bottomLeftButtonRightConstraint;

-(IBAction)enterSignup:(id)sender;
-(IBAction)enterForgotPassword:(id)sender;

@end

@implementation LoginViewController

enum  {
    INPUT_NAME = 0,
    INPUT_NAME_EXISTS,
    INPUT_PASSWORD,
    INPUT_PASSWORD_TOO_SHORT,
    INPUT_EMAIL,
    INPUT_EMAIL_INVALID,
    INPUT_EMAIL_EXISTS,
    INPUT_CONNECTION_PROBLEM,
    INPUT_LINK_SENT,
    INPUT_OK
};

- (id)init
{
    self = [super init];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    loginState = LoginStateLoggingIn;
    
    self.pressedButtonToLogin = NO;
    
    [self setupViews];
    
    [self reset];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTap:)];
    [self.view addGestureRecognizer:tap];

}

#pragma mark View Setup

- (void)setupViews
{
    self.background = [[UIImageView alloc] initWithImage:[UIImage retina4ImageNamed:@"background.png"]];
    
    [self.view addSubview:self.background];
    [self.view sendSubviewToBack:self.background];
    
    self.horMotionEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x"
                                                type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    self.vertMotionEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y"
                                                type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];

    CGFloat amplitude = 50.0;
    
    self.horMotionEffect.minimumRelativeValue = @(amplitude);
    self.horMotionEffect.maximumRelativeValue = @(-amplitude);
    self.vertMotionEffect.minimumRelativeValue = @(amplitude);
    self.vertMotionEffect.maximumRelativeValue = @(-amplitude);
    
    CGFloat sizeFactor = 1.2;
    
    CGSize backgroundSize = CGSizeMake(self.view.bounds.size.width * sizeFactor, self.view.bounds.size.height * sizeFactor);


    [self.background mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(@0);
        make.width.equalTo(@(backgroundSize.width));
        make.height.equalTo(@(backgroundSize.height));
        //make.edges.equalTo(@0);
    }];
    
    self.logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"knotes_rounded_icon"]];
    
    [self.view addSubview:self.logo];
    
    [self.logo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@(logoLowerPos));
        make.centerX.equalTo(@0);
    }];
    
    [self initializeTextFields];
    
    self.bottomRightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.bottomRightButton setTitle:@" Sign Up" forState:UIControlStateNormal];
    [self.bottomRightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.bottomRightButton addTarget:self action:@selector(enterSignup:) forControlEvents:UIControlEventTouchUpInside];
    self.bottomRightButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.bottomRightButton.titleLabel.textAlignment = NSTextAlignmentLeft;
    self.bottomRightButton.titleLabel.font = [DesignManager knoteLoginButtonFonts];
    [self.view addSubview:self.bottomRightButton];
    
    self.bottomLeftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.bottomLeftButton setTitle:@"Dont have an account?" forState:UIControlStateNormal];
    [self.bottomLeftButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.bottomLeftButton addTarget:self action:@selector(enterSignup:) forControlEvents:UIControlEventTouchUpInside];
    self.bottomLeftButton.titleLabel.font = [DesignManager knoteLoginFieldsFont];
    self.bottomLeftButton.hidden = YES;
    self.bottomRightButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.bottomRightButton.titleLabel.textAlignment = NSTextAlignmentRight;
    
    [self.view addSubview:self.bottomLeftButton];
    
    [self.bottomLeftButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.submitButton.mas_bottom).offset(10);
        make.left.equalTo(self.submitButton.mas_left).offset(13);
    }];
    
    [self.bottomRightButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bottomLeftButton.mas_right);
        make.centerY.equalTo(self.bottomLeftButton);
    }];
    
    
    self.bottomgetLinkButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.bottomgetLinkButton setTitle:@"Get a signing link by email!" forState:UIControlStateNormal];
    [self.bottomgetLinkButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.bottomgetLinkButton addTarget:self action:@selector(enterGetLinkState) forControlEvents:UIControlEventTouchUpInside];
    self.bottomgetLinkButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.bottomgetLinkButton.titleLabel.textAlignment = NSTextAlignmentLeft;
    self.bottomgetLinkButton.titleLabel.font = [DesignManager knoteLoginButtonFonts];
    [self.view addSubview:self.bottomgetLinkButton];
    [self.bottomgetLinkButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bottomLeftButton.mas_bottom);
        make.centerX.equalTo(self.submitButton);
    }];
    self.bottomgetLinkButton.hidden=YES;
    self.HelpButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.HelpButton setTitle:@"Contact us" forState:UIControlStateNormal];
    self.HelpButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0]/*[UIFont fontWithName:@"Roboto-Regular" size:13.0]*/;
    [self.HelpButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.HelpButton addTarget:self action:@selector(openComposer) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.HelpButton];
    [self.HelpButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(@(-5));
        make.height.equalTo(@(25));
        make.right.equalTo(@(-10));
    }];
    
    
}

- (void)updateServerName
{
    NSString *name = [[AppDelegate sharedDelegate].server.name uppercaseString];
    
    [self.chooseServerTitle replaceCharactersInRange:NSMakeRange(0, self.chooseServerTitle.length)
                                          withString:name];
    
    [self.chooseServerButton setAttributedTitle:[self.chooseServerTitle copy]
                                       forState:UIControlStateNormal];
}

- (void)backgroundTap:(UITapGestureRecognizer *)backgroundTap
{
    if(currentResponder)
    {
        [currentResponder resignFirstResponder];
    }
}

- (void) initializeTextFields {

    self.usernameTextField = [self loginTextFieldForIcon:@"login-username" placeholder:@"Enter username or e-mail"];
    self.usernameTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.usernameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.usernameTextField.spellCheckingType = UITextSpellCheckingTypeNo;
    self.usernameTextField.borderStyle = UIControlStateNormal;

    self.emailTextField = [self loginTextFieldForIcon:@"login-email" placeholder:@"Enter e-mail"];
    self.emailTextField.keyboardType = UIKeyboardTypeEmailAddress;
    self.emailTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.emailTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.emailTextField.spellCheckingType = UITextSpellCheckingTypeNo;
    

    self.passwordTextField = [self loginTextFieldForIcon:@"login-password" placeholder:@"Enter password"];
    self.passwordTextField.secureTextEntry = YES;
    self.passwordTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.passwordTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.passwordTextField.spellCheckingType = UITextSpellCheckingTypeNo;

    self.submitButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.submitButton setBackgroundImage:[UIImage imageNamed:@"btn_sign_in"] forState:UIControlStateNormal];

    [self.submitButton setTitle:@"SIGN IN" forState:UIControlStateNormal];
    [self.submitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.submitButton.titleLabel setFont:[DesignManager knoteLoginButtonFonts]];
    [self.submitButton addTarget:self action:@selector(onLogin:) forControlEvents:UIControlEventTouchUpInside];
    
    self.forgotPasswordButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.forgotPasswordButton setImage:[UIImage imageNamed:@"btn_forgot_password"] forState:UIControlStateNormal];
    [self.forgotPasswordButton addTarget:self action:@selector(enterForgotPassword:) forControlEvents:UIControlEventTouchUpInside];
    
    self.fPasswordBackButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.fPasswordBackButton setTitle:@"BACK" forState:UIControlStateNormal];
    [self.fPasswordBackButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.fPasswordBackButton.titleLabel setFont:[DesignManager knoteLoginFieldsFont]];
    [self.fPasswordBackButton addTarget:self action:@selector(exitForgotPassword:) forControlEvents:UIControlEventTouchUpInside];
    [self.fPasswordBackButton setAlpha:0.0];
    [self.view addSubview:self.fPasswordBackButton];
    
    self.loginIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.loginIndicator.hidesWhenStopped = YES;

    self.loginGroup = [UIView new];

    [self.loginGroup addSubview:self.usernameTextField];
    [self.loginGroup addSubview:self.emailTextField];
    [self.loginGroup addSubview:self.passwordTextField];
    [self.loginGroup addSubview:self.submitButton];
    [self.loginGroup addSubview:self.forgotPasswordButton];
    
    [self.loginGroup addSubview:self.loginIndicator];

    [self.view addSubview:self.loginGroup];


    [self.usernameTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@42.0);
        make.width.equalTo(@260.0);
        make.top.equalTo(@0);
        make.left.equalTo(@0);
        make.right.equalTo(@0);
    }];


    [self.passwordTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(self.usernameTextField);
        make.left.equalTo(self.usernameTextField);
        self.passwordFieldTopConstraint = make.top.equalTo(self.usernameTextField.mas_bottom).with.offset(verticalGap);
    }];
    
    //Start out logging in with the email address behind password
    [self.emailTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(self.usernameTextField);
        make.left.equalTo(self.usernameTextField);
        make.top.equalTo(self.usernameTextField.mas_bottom).with.offset(verticalGap);
    }];
    
    self.emailTextField.hidden = YES;


    [self.submitButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(self.usernameTextField);
        make.left.equalTo(self.usernameTextField);
        make.top.equalTo(self.passwordTextField.mas_bottom).with.offset(15.0);
        make.bottom.equalTo(@0);
    }];
    
//    [self.fPasswordBackButton setCenter:self.submitButton.center];
    [self.fPasswordBackButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(@0);
        make.top.equalTo(self.loginGroup.mas_bottom).offset(60);
    }];
    
    [self.forgotPasswordButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.passwordTextField.mas_top).offset(9);
        make.right.equalTo(self.passwordTextField.mas_right).offset(-7);
    }];
    
    [self.loginIndicator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.submitButton);
    }];


    [self.loginGroup mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(@0);
        self.loginGroupTopConstraint = make.top.equalTo(@(textFieldsLowerPos));
    }];


}

- (UITextField *)loginTextFieldForIcon:(NSString *)filename placeholder:(NSString *)placeholder {

    //Finally make the textField
    UITextField *textField = [[UITextField alloc] init];
    textField.font = [DesignManager knoteLoginFieldsFont];
    textField.textColor = [UIColor whiteColor];
    [textField setBackground:[UIImage imageNamed:@"txt_field_bg"]];
    textField.backgroundColor = [UIColor clearColor];
    textField.leftViewMode = UITextFieldViewModeAlways;
    textField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    
    if ([textField respondsToSelector:@selector(setAttributedPlaceholder:)])
    {
        UIColor *color = [UIColor whiteColor];
        
        textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeholder
                                                                          attributes:@{NSForegroundColorAttributeName: color}];
    }
    else
    {
        NSLog(@"Cannot set placeholder text's color, because deployment target is earlier than iOS 6.0");
        // TODO: Add fall-back code to set placeholder color.
    }
    
    textField.placeholder = placeholder;
    textField.delegate = self;

    return textField;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    self.navigationController.navigationBarHidden = YES;
    [[Lookback_Weak lookback] enteredView:@"Login View"];
     
    [self.background addMotionEffect:self.horMotionEffect];
    [self.background addMotionEffect:self.vertMotionEffect];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear: animated];
    glbAppdel.hasLogin = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardShowing:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardHiding:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    [self.background removeMotionEffect:self.horMotionEffect];
    [self.background removeMotionEffect:self.vertMotionEffect];
    
    [super viewWillDisappear: animated];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark Keyboard Methods

- (void)keyboardShowing:(NSNotification *)note
{
    NSNumber *duration = note.userInfo[UIKeyboardAnimationDurationUserInfoKey];
    self.loginGroupTopConstraint.with.offset(60.0);


    [UIView animateWithDuration:duration.floatValue animations:^{
        self.logo.alpha = 0.0;
        self.knotableLabel.alpha = 0.0;
        [self.view layoutIfNeeded];
    }];
}

- (void)keyboardHiding:(NSNotification *)note
{
    NSNumber *duration = note.userInfo[UIKeyboardAnimationDurationUserInfoKey];

    self.loginGroupTopConstraint.with.offset(loginState ==
                                             LoginStateLoggingIn ? textFieldsLowerPos : textFieldsUpperPos);

    [UIView animateWithDuration:duration.floatValue animations:^{
        self.logo.alpha = 1.0;
        self.knotableLabel.alpha = 1.0;
        [self.view layoutIfNeeded];
    }];

}

#pragma mark Memory Management

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark * Private method

- (void)onTimer:(NSTimer*)timer
{
    [self.checkTimer invalidate];
    
    self.checkTimer = nil;
    
    NSLog(@"Check Point !!!\n---App would hide spinner and login process here---");
    
    AppDelegate *app = [AppDelegate sharedDelegate];
    
    if (app.meteor && !app.meteor.connected)
    {
        [self showAlertMessage:INPUT_CONNECTION_PROBLEM];
    }
    
    [self hideLoadingProcess];

    if ([self.navigationController.viewControllers.lastObject isKindOfClass: [LoginProcessViewController class]])
        [self.loginProcess dismiss];
}

-(IBAction)onLogin:(id)sender
{
    NSUserDefaults* userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault removeObjectForKey: @"lastTopicID"];
    [userDefault synchronize];
    
    AppDelegate *app = [AppDelegate sharedDelegate];
    
    if ([DataManager sharedInstance].currentAccount)
    {
        [[DataManager sharedInstance].currentAccount MR_deleteEntity];
        [DataManager sharedInstance].currentAccount = nil;
        
        [app restoreAppData];
    }
    
    if (currentResponder)
    {
        [currentResponder resignFirstResponder];
    }
    
    int nInput = [self getInputType];

    if (nInput != INPUT_OK)
    {
        [self showAlertMessage:nInput];
    }
    else
    {
        self.checkTimer = [NSTimer scheduledTimerWithTimeInterval:ktDefaultLoginTimeInterval
                                                       target:self
                                                     selector:@selector(onTimer:)
                                                     userInfo:nil
                                                      repeats:NO];
        
        if (!self.loginProcess)
        {
            UIStoryboard* storyboard = [UIStoryboard storyboardWithName: @"Main" bundle: nil];
            self.loginProcess = [storyboard instantiateViewControllerWithIdentifier: @"LoginProgress"];
//            self.loginProcess = [[LoginProcessViewController alloc] init];
        }
        
        if (!self.loginProcess.parentViewController)
        {
            [glbAppdel.navController pushViewController:self.loginProcess
                                               animated:YES];
        }
        if (app.meteor.connected)
        {
            [app meteorLoginWithUsername:self.inputUsername password:self.inputPassword];
        }
        else
        {
            self.pressedButtonToLogin = YES;
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(meteorClientConnectionReady:)
                                                         name:MeteorClientConnectionReadyNotification
                                                       object:nil];
        }
        NSLog(@"logging in with meteor username: %@", self.inputUsername);
        
        self.loggingIn = YES;
    }
    
    [DataManager sharedInstance].userLogin = YES;
}

#pragma mark <NSKeyValueObserving>

- (void)meteorClientConnectionReady:(NSNotification *)note
{
    AppDelegate *app = [AppDelegate sharedDelegate];
    
    if (app.meteor.websocketReady && app.meteor.connected)
    {
        if ( self.pressedButtonToLogin )
        {
            [app meteorLoginWithUsername:self.inputUsername password:self.inputPassword];
        }
    }
}

-(void)startLoginSpinner
{
    [self.submitButton setTitle:@"" forState:UIControlStateDisabled];
    self.submitButton.enabled = NO;
    [self.loginIndicator startAnimating];
}
-(void)stopLoginSpinner
{
    self.submitButton.enabled = YES;
    [self.loginIndicator stopAnimating];
}

#pragma mark Login

-(void)setPlaceholder:(NSString*)placeholder forTextFiled:(UITextField*)text_field
{
    if ([text_field respondsToSelector:@selector(setAttributedPlaceholder:)])
    {
        UIColor *color = [UIColor whiteColor];
        text_field.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeholder attributes:@{NSForegroundColorAttributeName: color}];
    }
    else
    {
        NSLog(@"Cannot set placeholder text's color, because deployment target is earlier than iOS 6.0");
        // TODO: Add fall-back code to set placeholder color.
    }

}


- (void)prepareForEnteringLoginState {
    loginState = LoginStateLoggingIn;

    [self.passwordFieldTopConstraint uninstall];
    [self.passwordTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        self.passwordFieldTopConstraint = make.top.equalTo(self.usernameTextField.mas_bottom).with.offset(verticalGap);
    }];

    [self.logo mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@(logoLowerPos));
    }];

    [self.loginGroup mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@(textFieldsLowerPos));
    }];
}


- (void)configureLoginState {
    loginState = LoginStateLoggingIn;

    [self reset];

    //Without these there is an unwanted fade animation
    [UIView setAnimationsEnabled:NO];
    [self setPlaceholder:@"Enter username or e-mail" forTextFiled:self.usernameTextField];
//    [self loginTextFieldForIcon:@"login-username" placeholder:@"Enter username or e-mail"];
//    [self.bottomLeftButton setTitle:@"Dont have an account?" forState:UIControlStateNormal];
    [self.bottomRightButton setTitle:@" Sign Up" forState:UIControlStateNormal];
    [self.submitButton setTitle:@"SIGN IN" forState:UIControlStateNormal];
    [self.forgotPasswordButton setHidden:NO];
    [UIView setAnimationsEnabled:YES];

    self.emailTextField.hidden = YES;
    if (_isGetLinkActivated)
    {
//        self.bottomgetLinkButton.hidden=NO;
    }
//    [self.bottomLeftButton addTarget:self action:@selector(enterSignup:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomRightButton addTarget:self action:@selector(enterSignup:) forControlEvents:UIControlEventTouchUpInside];
//    [self.bottomRightButton addTarget:self action:@selector(enterForgotPassword:) forControlEvents:UIControlEventTouchUpInside];
    [self.submitButton addTarget:self action:@selector(onLogin:) forControlEvents:UIControlEventTouchUpInside];
    
    self.bottomLeftButton.hidden = YES;
}

- (void)leaveLoginState {
    [self.forgotPasswordButton setHidden:YES];
    self.bottomgetLinkButton.hidden=YES;
    [self.bottomLeftButton removeTarget:self action:@selector(enterSignup:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomRightButton removeTarget:self action:@selector(enterForgotPassword:) forControlEvents:UIControlEventTouchUpInside];
    [self.submitButton removeTarget:self action:@selector(onLogin:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark New User Signup

- (IBAction)enterSignup:(id)sender{
    loginState = LoginStateSigningUp;
    self.emailTextField.hidden = NO;
    [self.passwordFieldTopConstraint uninstall];
    [self.passwordTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        self.passwordFieldTopConstraint = make.top.equalTo(self.emailTextField.mas_bottom).with.offset(verticalGap);
    }];

    [self.logo mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@(logoUpperPos));
    }];

    [self.loginGroup mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@(textFieldsUpperPos));
    }];

    [self leaveLoginState];

    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self reset];
        [self configureSignUpState];

    }];
}
-(void)enterGetLinkState
{
    [self leaveLoginState];
    
    loginState = LoginStateGetLink;
    [self setPlaceholder:@"Enter username or e-mail" forTextFiled:self.emailTextField];
    self.emailTextField.hidden = NO;
    
    [self.logo mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@(logoUpperPos));
    }];
    
    self.loginGroupTopConstraint.offset(textFieldsUpperPos);
    
    [UIView animateWithDuration:0.3 animations:^{
        self.usernameTextField.alpha = 0;
        self.passwordTextField.alpha = 0;
        self.verticalDivider.alpha = 0;
        self.bottomRightButton.alpha = 0;
        self.bottomLeftButton.alpha = 0;
        self.fPasswordBackButton.alpha=1.0;
        [self.view layoutIfNeeded];
        [self.view layoutIfNeeded];
        
    } completion:^(BOOL finished) {
        
        [UIView setAnimationsEnabled:NO];
        [self.submitButton setTitle:@"GET LINK" forState:UIControlStateNormal];
        
        [UIView setAnimationsEnabled:YES];
        [self.submitButton addTarget:self action:@selector(GetLinkServiceHERE) forControlEvents:UIControlEventTouchUpInside];
        
    }];

}
-(void)GetLinkServiceHERE
{
    NSLog(@"get link");
    if (currentResponder) {
        [currentResponder resignFirstResponder];
    }
    int nInput = [self getInputType];
    
    if (nInput != INPUT_OK)
    {
        [self showAlertMessage:nInput];
    }
    else
    {
        // checkUsernameExist
        
        AppDelegate *app = [AppDelegate sharedDelegate];
        
        if(app.meteor)
        {
            MeteorClient *meteor = app.meteor;
            
            NSLog(@"have meteor, connected ? %d ", meteor.connected);
            
            [meteor callMethodName:@"updateLoginAttempts"
                        parameters:@[self.emailTextField.text]
                  responseCallback:^(NSDictionary *response, NSError *error)
             {
                 if(error)
                 {
                     NSLog(@"called checkUsernameExist got error %@", error);
                     
                     if( [MeteorClientTransportErrorDomain isEqualToString:error.domain]
                        && error.code == 0)
                     {
                         [self showAlertMessage:INPUT_CONNECTION_PROBLEM];
                     }
                     
                     return;
                 }
                 else
                 {
                     [self showAlertMessage:INPUT_LINK_SENT];
                 [self exitForgotPassword:nil];
                 }
                 /*BOOL usernameExists = ((NSNumber *)response[@"result"]).boolValue;
                 
                 NSLog(@"usernameExists? %d", usernameExists);
                 
                 [self usernameExistsResponse:usernameExists];*/
             }];
        }
    }
}
- (void)configureSignUpState {

    //Without these there is an unwanted fade animation
    [UIView setAnimationsEnabled:NO];
    [self setPlaceholder:@"Username" forTextFiled:self.usernameTextField];
    [self setPlaceholder:@"Email" forTextFiled:self.emailTextField];

    [self.bottomLeftButton setTitle:@"Already have an account?" forState:UIControlStateNormal];
    self.bottomLeftButton.hidden = YES;
    [self.bottomRightButton setTitle:@"Log In" forState:UIControlStateNormal];
    [self.submitButton setTitle:@"SIGN UP" forState:UIControlStateNormal];
    [UIView setAnimationsEnabled:YES];

    [self.bottomLeftButton addTarget:self action:@selector(goBackToLogin:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomRightButton addTarget:self action:@selector(goBackToLogin:) forControlEvents:UIControlEventTouchUpInside];
    [self.submitButton addTarget:self action:@selector(submitSignUp:) forControlEvents:UIControlEventTouchUpInside];
}


- (void)submitSignUp:(id)sender {
    if (currentResponder) {
        [currentResponder resignFirstResponder];
    }
    int nInput = [self getInputType];

    if (nInput != INPUT_OK)
    {
        [self showAlertMessage:nInput];
    }
    else
    {
        // checkUsernameExist

        AppDelegate *app = [AppDelegate sharedDelegate];
        
        if(app.meteor)
        {
            MeteorClient *meteor = app.meteor;
            
            NSLog(@"have meteor, connected ? %d ", meteor.connected);

            [meteor callMethodName:@"checkUsernameExist"
                        parameters:@[self.inputUsername]
                  responseCallback:^(NSDictionary *response, NSError *error)
            {
                if(error)
                {
                    NSLog(@"called checkUsernameExist got error %@", error);
                    
                    if( [MeteorClientTransportErrorDomain isEqualToString:error.domain]
                       && error.code == 0)
                    {
                        [self showAlertMessage:INPUT_CONNECTION_PROBLEM];
                    }
                    
                    return;
                }

                BOOL usernameExists = ((NSNumber *)response[@"result"]).boolValue;
                
                NSLog(@"usernameExists? %d", usernameExists);

                [self usernameExistsResponse:usernameExists];
            }];
        }
    }
}

- (void)usernameExistsResponse:(BOOL)exists
{
    if(exists)
    {
        [self showAlertMessage:INPUT_NAME_EXISTS];
        
        return;
    }

    NSLog(@"Actually signup");

    //createAccount
    NSDictionary *registrationInfo = @{
            @"username":self.inputUsername,
            @"fullname":self.inputFullname,
            @"email":self.inputEmail,
            @"password":self.inputPassword,
            @"is_register":@(YES)
    };

    AppDelegate *app = [AppDelegate sharedDelegate];

    [app.meteor callMethodName:@"createAccount"
                    parameters:@[registrationInfo]
              responseCallback:^(NSDictionary *response, NSError *error) {
        if(error)
        {
            NSLog(@"error: %@", error);
            
            id info = error.userInfo[NSLocalizedDescriptionKey];
            
            NSString *reason = nil;
            
            if(info && [info isKindOfClass:[NSDictionary class]])
            {
                reason = info[@"reason"];
                
                if(error.code == 403 || [reason isEqualToString:@"Email already exist."])
                {
                    NSLog(@"email already exists");
                    
                    [self showAlertMessage:INPUT_EMAIL_EXISTS];
                }
            }
            else if(info &&  [info isKindOfClass:[NSString class]])
            {
                reason = info;
                
                NSLog(@"STRING SIGNUP PROBLEM: %@", reason);
            }
            
            if(!reason)
            {
                NSLog(@"UNKNOWN SIGNUP PROBLEM");
            }
            
            NSLog(@"Error Code: %d Reason: \"%@\"", (int)error.code, reason);
            
            return;
        }
        
        if(response)
        {
            NSDictionary *result = response[@"result"];
            NSString *email = result[@"email"];
            NSString *userId = result[@"userId"];
            NSString *username = result[@"username"];
           // NSString *hashedToken = result[@"hashedToken"];
            NSUserDefaults *userDefaults = [[NSUserDefaults alloc]initWithSuiteName:@"group.knotable.knotedev.share"];
            NSMutableDictionary *userInfo = [[userDefaults objectForKey:@"userInfo"] mutableCopy];
            
            if (userInfo == nil) {
                userInfo = [[NSMutableDictionary alloc] init];
            }
            
            [userInfo setObject:email forKey:@"email"];
            [userInfo setObject:username forKey:@"name"];
            
            NSUserDefaults *extensionUserDefaults = [[NSUserDefaults alloc]initWithSuiteName:@"group.knotable.knotedev.share"];
            [extensionUserDefaults setObject:userInfo forKey:@"userInfo"];
            [extensionUserDefaults synchronize];


            __block  UserEntity *user = [UserEntity MR_createEntity];
            user.email = email;
            user.user_id = userId;
            user.name = username;
            
            NSDictionary *parameters = @{ @"userId": userId };
            
            [[AnalyticsManager sharedInstance] notifyAccountWasCreatedWithParameters:parameters];
            
            AppDelegate *app = [AppDelegate sharedDelegate];
            
            if (app.meteor && app.meteor.userId)
            {
                [app.meteor addSubscription:METEORCOLLECTION_USERPRIVATEDATA
                             withParameters:@[[AppDelegate sharedDelegate].meteor.userId]];
            }
          //Dhruv: Commented code couse issue in successfull registration
/*NSString *account_id = [[AppDelegate sharedDelegate] getAccountID:userId];
            
            if (account_id)
            {
                AccountEntity *account = [AccountEntity MR_createEntity];
                account.user = user;
                account.lastLoggedIn = [NSDate date];
                account.loggedIn = @(YES);
                account.account_id = account_id;
                
                [DataManager sharedInstance].currentAccount = account;*/
                
                [app saveContextAndWait];
                
                user.password = self.inputPassword;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self goBackToLogin:nil];
                    NSString *confirmText = @"Please check for an email from us, and follow the link to confirm your email address.";
                    UIAlertView *confirmEmailAlert = [[UIAlertView alloc] initWithTitle:@"Confirm Email"
                                                                                message:confirmText
                                                                               delegate:nil
                                                                      cancelButtonTitle:@"OK"
                                                                      otherButtonTitles:nil];
                    //[confirmEmailAlert show];
                    self.inputUsername = username;
                    [self onLogin:nil];
                    
                    /*
                    AppDelegate *app = [AppDelegate sharedDelegate];
                    if (app.meteor.connected)
                    {
                        [app meteorLoginWithUsername:username password:self.inputPassword];
                    }
                     */
                    
                    
                });
            /*} else {
                NSString *confirmText = @"Please Try again";
                UIAlertView *confirmEmailAlert = [[UIAlertView alloc] initWithTitle:@"Network Error."
                                                                            message:confirmText
                                                                           delegate:nil
                                                                  cancelButtonTitle:@"OK"
                                                                  otherButtonTitles:nil];
                [confirmEmailAlert show];
            }*/

            // Lin : Removed code cause there was return command.
        }
    }];
}

- (void)leaveSignUpState {
    [self.bottomLeftButton removeTarget:self action:@selector(goBackToLogin:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomRightButton removeTarget:self action:@selector(openTerms:) forControlEvents:UIControlEventTouchUpInside];
    [self.submitButton removeTarget:self action:@selector(submitSignUp:) forControlEvents:UIControlEventTouchUpInside];

}
-(void)openComposer
{
    if ([MFMailComposeViewController canSendMail]) {
        
        MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        mailViewController.mailComposeDelegate = self;
        //[mailViewController setSubject:@"Subject Goes Here."];
        
        //[mailViewController setMessageBody:@"Your message goes here." isHTML:NO];
        [mailViewController setToRecipients:@[@"help@knote.com"]];
        [self presentViewController:mailViewController animated:YES completion:nil];
        
        
    }
    
    else {
        
        NSLog(@"Device is unable to send email in its current state.");
        
    }
}
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    UIAlertView *alert;
    switch (result)
    {
        case MFMailComposeResultCancelled:
            break;
        case MFMailComposeResultSaved:
            alert = [[UIAlertView alloc] initWithTitle:@"Draft Saved" message:@"Composed Mail is saved in draft." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
            break;
        case MFMailComposeResultSent:
            alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"You have successfully sent mail." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
            break;
        case MFMailComposeResultFailed:
            alert = [[UIAlertView alloc] initWithTitle:@"Failed" message:@"Sorry! Failed to send." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [controller dismissViewControllerAnimated:YES completion:nil];
}
- (void)goBackToLogin:(id)sender {
    [self prepareForEnteringLoginState];
    [self leaveSignUpState];

    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self configureLoginState];

    }];

}

#pragma mark Terms & Conditions

- (void)openTerms:(id)sender {
    [self leaveSignUpState];


    self.termsTextView = [[UITextView alloc] initWithFrame:CGRectZero textContainer:nil];
    self.termsTextView.editable = NO;
    self.termsTextView.layer.cornerRadius = 5.0;

    NSString *titleText = @"Terms and Conditions of Use\n";
    NSString *bodyText = @"\n1. Terms\n\nBy accessing this web site, you are agreeing to be bound the web site Terms and Conditions of Use, all applicable laws and regulations...";

    NSDictionary *titleAttrs = @{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Light" size:16.0]};
    NSDictionary *bodyAttrs = @{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Light" size:11.0]/*[UIFont fontWithName:@"HelveticaNeue" size:11.0]*/};

    NSMutableAttributedString *termsText = [[NSMutableAttributedString alloc] initWithString:titleText attributes:titleAttrs];
    NSAttributedString *bodyAttString = [[NSAttributedString alloc] initWithString:bodyText attributes:bodyAttrs];

    [termsText appendAttributedString:bodyAttString];

    self.termsTextView.attributedText = termsText;



    [self.view addSubview:self.termsTextView];


    [self.termsTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@256.0);
        make.height.equalTo(@218.0);
        make.centerX.equalTo(@400.0);
        make.top.equalTo(@190.0);
    }];

    [self.view layoutIfNeeded];

    [self.termsTextView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(@0.0);
    }];

    [self.loginGroup mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(@-400.0);
    }];

    [UIView animateWithDuration:0.3 animations:^{
        //self.loginGroup.alpha = 0;
        [self.view layoutIfNeeded];

    } completion:^(BOOL finished) {

        //Without these there is an unwanted fade animation
        [UIView setAnimationsEnabled:NO];
        [self.bottomLeftButton setTitle:@"BACK" forState:UIControlStateNormal];
        [self.bottomRightButton setTitle:@"LOG IN" forState:UIControlStateNormal];
        [UIView setAnimationsEnabled:YES];

        [self.bottomLeftButton addTarget:self action:@selector(exitTerms:) forControlEvents:UIControlEventTouchUpInside];
        [self.bottomRightButton addTarget:self action:@selector(exitTerms:) forControlEvents:UIControlEventTouchUpInside];
    }];
}

- (void)exitTerms:(id)sender {
    BOOL goingToSignUp = sender == self.bottomLeftButton;

    [self.bottomLeftButton removeTarget:self action:@selector(exitTerms:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomRightButton removeTarget:self action:@selector(exitTerms:) forControlEvents:UIControlEventTouchUpInside];

    [self.termsTextView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(@400.0);
    }];

    [self.loginGroup mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(@0);
    }];

    if(!goingToSignUp){
        [self prepareForEnteringLoginState];
    }

    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];

    } completion:^(BOOL finished) {

        //Without these there is an unwanted fade animation
        [UIView setAnimationsEnabled:NO];
        if(goingToSignUp){
            [self configureSignUpState];
        } else {
            [self configureLoginState];
        }
        [UIView setAnimationsEnabled:YES];
    }];
}

#pragma mark Forgot / Rest Password

- (void)enterForgotPassword:(id)sender {
    [self leaveLoginState];

    loginState = LoginStateForgotPassword;
    [self setPlaceholder:@"Enter e-mail" forTextFiled:self.emailTextField];
    self.emailTextField.hidden = NO;

    [self.logo mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@(logoUpperPos));
    }];

    self.loginGroupTopConstraint.offset(textFieldsUpperPos);

    [UIView animateWithDuration:0.3 animations:^{
        self.usernameTextField.alpha = 0;
        self.passwordTextField.alpha = 0;
        self.verticalDivider.alpha = 0;
        self.bottomRightButton.alpha = 0;
        self.bottomLeftButton.alpha = 0;
        self.fPasswordBackButton.alpha=1.0;
        [self.view layoutIfNeeded];
        [self.view layoutIfNeeded];

    } completion:^(BOOL finished) {

        [UIView setAnimationsEnabled:NO];
        [self.submitButton setTitle:@"RESET PASSWORD" forState:UIControlStateNormal];

        [UIView setAnimationsEnabled:YES];
        [self.submitButton addTarget:self action:@selector(resetPassword) forControlEvents:UIControlEventTouchUpInside];

    }];


}

- (void)resetPassword {
    if (currentResponder) {
        [currentResponder resignFirstResponder];
    }
    int nInput = [self getInputType];

    if (nInput != INPUT_OK) {
        [self showAlertMessage:nInput];
    } else {
        AppDelegate *app = [AppDelegate sharedDelegate];
        if(app.meteor){
            MeteorClient *meteor = app.meteor;
            [meteor callMethodName:@"forgotPassword"
                        parameters:@[@{@"email":self.inputEmail}]
                  responseCallback:^(NSDictionary *response, NSError *error)
            {
                if(error)
                {
                    NSLog(@"forgotPassword error: %@", response);
                    
                    NSString *reason = error.userInfo[NSLocalizedDescriptionKey];
                    
                    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:reason
                                                                    message:nil
                                                                   delegate:self
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                    
                    [alert show];
                    
                }
                else
                {
                    NSLog(@"forgotPassword response: %@", response);
                    
                    NSString *message = @"Email sent. Please check your email.";
                    
                    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:message
                                                                    message:nil
                                                                   delegate:self
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                    
                    [alert show];
                    
                    [self exitForgotPassword:nil];
                }
            }];
        }

    }
}

- (void)exitForgotPassword:(id)sender {
    [self.bottomLeftButton removeTarget:self action:@selector(exitForgotPassword:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomRightButton removeTarget:self action:@selector(exitForgotPassword:) forControlEvents:UIControlEventTouchUpInside];
    [self.submitButton removeTarget:self action:@selector(resetPassword) forControlEvents:UIControlEventTouchUpInside];


    [self.logo mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@(logoLowerPos));
    }];
    
    self.loginGroupTopConstraint.offset(textFieldsLowerPos);

    [UIView animateWithDuration:0.3 animations:^{
        self.usernameTextField.alpha = 1.0;
        self.passwordTextField.alpha = 1.0;
        self.verticalDivider.alpha = 1.0;
        self.bottomRightButton.alpha = 1.0;
        self.bottomLeftButton.alpha = 1.0;
        self.fPasswordBackButton.alpha = 0.0;
        [self.view layoutIfNeeded];

    } completion:^(BOOL finished) {

        [self configureLoginState];

    }];

}

#pragma mark Meteor Connection Methods


- (void)loginNetworkResult:(id)obj withCode:(NSInteger)code
{
    [self.checkTimer invalidate];
    
    self.checkTimer = nil;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self performSelector:@selector(stopLoginSpinner) withObject:nil afterDelay:1];
    });
    
    if (code == NetworkSucc) {
        
    } else {
        NSString *reason = @"Invalid credentials or network error, please try again.";
        
        if (obj && [obj isKindOfClass:[NSString class]]) {
            reason = obj;
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            BOOL wrongPassword = ([reason rangeOfString:@"Incorrect password"].location != NSNotFound);
            if (wrongPassword) {
                [self enterForgotPassword:nil];
            } else {
                [[AppDelegate sharedDelegate] ShowAlert:Nil messageContent:reason];
            }
        });
    }
    
    self.pressedButtonToLogin = NO;
}

#pragma mark Input Validation

- (void) updateAndCleanInput {
    self.inputUsername = [[self.usernameTextField.text trimmed] lowercaseStringWithLocale:[NSLocale currentLocale]];
    self.usernameTextField.text = self.inputUsername;

    self.inputEmail = [[self.emailTextField.text trimmed] lowercaseStringWithLocale:[NSLocale currentLocale]];
    self.emailTextField.text = self.inputEmail;

    NSArray *emailComponents = [self.inputEmail componentsSeparatedByString:@"@"];
    self.inputFullname = emailComponents.count > 0 ? emailComponents.firstObject : self.inputEmail;

    self.inputPassword = self.passwordTextField.text;
}

- (int) getInputType {
    int nRet;

    [self updateAndCleanInput];

    switch (loginState) {
        case LoginStateForgotPassword:
            nRet = [self validateForgotPassword];
            break;
        case LoginStateSigningUp:
            nRet = [self validateSigningUp];
            break;
        case LoginStateGetLink:
            nRet = [self validateGETLINK];
            break;
        default:
            //LoginStateLoggingIn
            nRet = [self validateLoggingIn];
            break;
    }
    return nRet;
}


- (int) validateForgotPassword {
    if (self.inputEmail.length == 0) {
        return INPUT_EMAIL;
    }
    else if (![self.inputEmail isValidEmail]) {
        return INPUT_EMAIL_INVALID;
    }
    return INPUT_OK;
}
- (int) validateGETLINK {
    if (self.inputEmail.length == 0) {
        return INPUT_EMAIL;
    }
    return INPUT_OK;
}

- (int)validateLoggingIn {
    int nRet;
    if (self.inputUsername.length == 0) {
        nRet = INPUT_NAME;
    } else if (self.inputPassword.length == 0) {
        nRet = INPUT_PASSWORD;
    } else {
        nRet = INPUT_OK;
    }
    return nRet;
}

- (int)validateSigningUp {
    int nRet;
    if (self.inputUsername.length == 0) {
        nRet = INPUT_NAME;
    }
    else if (self.inputEmail.length == 0) {
        nRet = INPUT_EMAIL;
    }
    else if (![self.inputEmail isValidEmail]) {
        nRet = INPUT_EMAIL_INVALID;
    }
    else if (self.inputPassword.length == 0) {
        nRet = INPUT_PASSWORD;
    }
    else if (self.inputPassword.length < 6) {
        nRet = INPUT_PASSWORD_TOO_SHORT;
    }
    else {
        nRet = INPUT_OK;
    }
    return nRet;
}

- (void) showAlertMessage:(int) type
{
    NSString* strTitle;
    
    switch (type)
    {
        case INPUT_CONNECTION_PROBLEM:
            strTitle = @"We're sorry, there is a network issue. Please try again later";
            break;
            
        case INPUT_NAME:
            strTitle = loginState == LoginStateLoggingIn ? @"Please enter your username" : @"Please enter a username";
            break;
            
        case INPUT_NAME_EXISTS:
            strTitle = @"That username is taken, please choose another";
            break;
            
        case INPUT_PASSWORD:
            strTitle = loginState == LoginStateLoggingIn ? @"Please enter your password" : @"Please enter a password";
            break;
            
        case INPUT_PASSWORD_TOO_SHORT:
            strTitle = @"That password is too short, it must be at least 6 characters";
            break;
            
        case INPUT_EMAIL:
            strTitle = @"Please enter your email address";
            break;
            
        case INPUT_EMAIL_INVALID:
            strTitle = @"That email address is not valid";
            break;
            
        case INPUT_EMAIL_EXISTS:
            strTitle = @"That email is already being used, please log in";
            break;
        case INPUT_LINK_SENT:
            strTitle = @"If you have an account already, check your mail for a magic login link.";
            break;
        default:
            strTitle = @"";
            break;
    }
    
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:strTitle
                                                    message:nil
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
     
    [alert show];
}

#pragma mark -
#pragma mark UITextFieldDelegate Methods

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [textField setBackground:[UIImage imageNamed:@"selected_txt_field_bg.png"]];
    currentResponder = textField;
    if (textField == self.usernameTextField && preFilledUsername) {
        preFilledUsername = NO;
        textField.text = @"";
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    currentResponder = nil;
    [textField setBackground:[UIImage imageNamed:@"txt_field_bg.png"]];
}


- (void) reset
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if([DataManager sharedInstance].currentAccount
           && loginState == LoginStateLoggingIn)
        {
            self.usernameTextField.text = [DataManager sharedInstance].currentAccount.user.name;
            
            preFilledUsername = YES;
            
        }
        else
        {
            preFilledUsername = NO;
        }
        
        self.emailTextField.text = @"";
            });
}
-(void)getLinkActivate
{
    _isGetLinkActivated=YES;
//    self.bottomgetLinkButton.hidden=NO;

}
#pragma mark - Segue management

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
}

#pragma mark -
#pragma mark - Action after login

- (void) hideLoadingProcess
{
    [self stopLoginSpinner];
    
    [self.loginProcess stopAnimation];    
}

- (void) showPermissionScreens
{
    [self performSegueWithIdentifier: @"showPrompt" sender: nil];
}

@end

#import "ListViewController.h"
#import "MeteorClient.h"

@interface ListViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableview;
#if PRE_DDP_FEATURE
@property (strong, nonatomic) M13MutableOrderedDictionary *lists;
#endif

@end

@implementation ListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
               meteor:(MeteorClient *)meteor {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.meteor = meteor;
#if PRE_DDP_FEATURE
        self.lists = self.meteor.collections[@"lists"];
#endif
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationItem.title = @"My Lists";
    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.hidesBackButton = YES;
    
    UIBarButtonItem *logoutButton = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStylePlain target:self action:@selector(logout)];
    self.navigationItem.rightBarButtonItem = logoutButton;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveUpdate:)
                                                 name:@"added"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveUpdate:)
                                                 name:@"removed"
                                               object:nil];
}

- (void)didReceiveUpdate:(NSNotification *)notification {
    [self.tableview reloadData];
}

- (void)logout {
    [self.meteor logout];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark <UITableViewDataSource>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#if PRE_DDP_FEATURE
    return [self.lists count];
#else
    return 0;
#endif
}

static NSDictionary *selectedList;

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"list";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:cellIdentifier];
    }
#if PRE_DDP_FEATURE

    NSDictionary *list = self.lists[indexPath.row];
#else
    NSDictionary *list = nil;
#endif
    selectedList = list;
    cell.textLabel.text = list[@"name"];

    UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];

    shareButton.frame = CGRectMake(255.0f, 5.0f, 55.0f, 34.0f);
    shareButton.backgroundColor = [UIColor greenColor];
    [shareButton setTitle:@"Share" forState:UIControlStateNormal];
    [shareButton addTarget:self action:@selector(didClickShareButton:forEvent:) forControlEvents:UIControlEventTouchUpInside];

    // XXX: shareButton needs to be able to link to its list
    // shareButton

    [cell addSubview:shareButton];

    return cell;
}

static UITextField *shareWithTF;

- (void)didClickShareButton:(id)sender forEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView:self.view];

    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0, location.y, 320.0, 100.0)];
    view.backgroundColor = [UIColor whiteColor];
    UITextField *shareWithTextField = [[UITextField alloc] initWithFrame:CGRectMake(10.0, 50.0, 240.0, 44.0)];
    shareWithTF = shareWithTextField;
    shareWithTextField.borderStyle = UITextBorderStyleLine;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(255.0, 50.0, 60.0, 44.0);
    button.backgroundColor = [UIColor greenColor];
    [button setTitle:@"Send" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(didClickShareWithButton:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:shareWithTextField];
    [view addSubview:button];

    UIView *modalBackground = [[UIView alloc] initWithFrame:self.view.frame];
    modalBackground.backgroundColor = [UIColor blackColor];
    modalBackground.alpha = 0.7;

    [self.view addSubview:modalBackground];
    [self.view addSubview:view];
}

- (void)didClickShareWithButton:(id)sender {
    NSArray *parameters = @[@{@"_id": selectedList[@"_id"]}, @{@"$set":@{@"share_with": shareWithTF.text}}];
    [self.meteor callMethodName:@"/lists/update" parameters:parameters responseCallback:nil];
    [[[self.view subviews] lastObject] removeFromSuperview];
    [[[self.view subviews] lastObject] removeFromSuperview];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
                                            forRowAtIndexPath:(NSIndexPath *)indexPath {
#if PRE_DDP_FEATURE
    NSDictionary *list = self.lists[indexPath.row];
#else
    NSDictionary *list = nil;
#endif
    [self.meteor callMethodName:@"/lists/remove" parameters:@[@{@"_id": list[@"_id"]}] responseCallback:nil];
}

#pragma mark <UITableViewDelegate>

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

}

@end

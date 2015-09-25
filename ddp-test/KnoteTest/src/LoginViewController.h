#import <UIKit/UIKit.h>
#import "KnotesViewController.h"

@class MeteorClient;

@interface LoginViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *email;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UILabel *connectionStatusText;
@property (weak, nonatomic) IBOutlet UILabel *loginStatusText;
@property (weak, nonatomic) IBOutlet UIImageView *connectionStatusLight;
@property (atomic,strong) MeteorClient *meteor;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

- (IBAction)didTapLoginButton:(id)sender;

@end

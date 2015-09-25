//
//  CustomABPeoplePickerNavigationController.m
//  Knotable
//
//  Created by Emiliano Barcia Lizarazu on 12/1/15.
//
//

#import "CustomABPeoplePickerNavigationController.h"

@interface CustomABPeoplePickerNavigationController ()

@end

@implementation CustomABPeoplePickerNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion
{
    if(self.shouldDismiss){
        [super dismissViewControllerAnimated:flag completion:completion];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

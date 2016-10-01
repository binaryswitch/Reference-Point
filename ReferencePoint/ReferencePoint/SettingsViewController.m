//
//  SettingsViewController.m
//  ReferencePoint
//
//  Created by Justin White on 24/09/16.
//  Copyright © 2016 binaryswitch. All rights reserved.
//

#import "SettingsViewController.h"
#import "LoginViewController.h"
#import "User.h"
#import <Firebase/Firebase.h>

@interface SettingsViewController ()
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;
@property (weak, nonatomic) IBOutlet UILabel *userIdLabel;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.logoutButton addTarget:self action:@selector(didTapLogoutButton) forControlEvents:UIControlEventTouchUpInside];
    // Do any additional setup after loading the view.
    
    self.userIdLabel.text = [FIRAuth auth].currentUser.uid;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) didTapLogoutButton{
    //transition here
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    [[RLMRealm defaultRealm] beginWriteTransaction];
    [[RLMRealm defaultRealm] deleteAllObjects];
    [[RLMRealm defaultRealm] commitWriteTransaction];

    LoginViewController * nextScreen = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    [self presentViewController:nextScreen animated:YES completion:nil];

}

@end

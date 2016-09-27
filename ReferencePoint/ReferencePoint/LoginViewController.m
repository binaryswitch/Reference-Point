//
//  ViewController.m
//  ReferencePoint
//
//  Created by Justin White on 21/09/16.
//  Copyright © 2016 binaryswitch. All rights reserved.
//

#import "LoginViewController.h"
#import "MapViewController.h"

@import Firebase;

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UIButton * goButton;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField0;
@property (weak, nonatomic) IBOutlet UIButton *loginSelectorButton;
@property (weak, nonatomic) IBOutlet UIButton *registerSelectorButton;

@property BOOL loginModeSelected;

@property (weak, nonatomic) IBOutlet UITextField *passwordField1;
//@property (strong, nonatomic) MapViewController * mapViewController;


@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
   // self.mapViewController = [[MapViewController alloc] init];
    [self.goButton addTarget:self action:@selector(didTapGoButton) forControlEvents:UIControlEventTouchUpInside];
    [self.loginSelectorButton addTarget:self action:@selector(didTapLoginSelectorButton) forControlEvents:UIControlEventTouchUpInside];
    [self.registerSelectorButton addTarget:self action:@selector(didTapRegisterSelectorButton) forControlEvents:UIControlEventTouchUpInside];


    self.passwordField0.secureTextEntry = true;
    self.passwordField1.secureTextEntry = true;
    
    [self didTapLoginSelectorButton];
    
    self.currentUser = [[User allObjects] firstObject];
    
    [[FIRAuth auth] addAuthStateDidChangeListener:^(FIRAuth *_Nonnull auth,
                                                    FIRUser *_Nullable user) {
        if (user != nil) {
            
            NSLog(@"%@ current user %@",self.currentUser, [[[FIRAuth auth] currentUser] uid] );
            
            if (self.currentUser != nil){
                

                [self attemptLoginWithToken];
            }
        
        } else {
            NSLog(@"%@ no  current user");
        }
    }];


    // Do any additional setup after loading the view, typically from a nib.
}

- (void) didTapLoginSelectorButton
{
    self.loginModeSelected = YES;
    self.passwordField1.hidden = YES;
}

- (void) didTapRegisterSelectorButton
{
    self.loginModeSelected = NO;
    self.passwordField1.hidden = NO;
}

- (void) didTapGoButton{
    
    if (self.emailField.text == nil || [self.emailField.text isEqualToString:@""])
    {
        return;
    }
    else if (self.passwordField0.text == nil || [self.passwordField0.text isEqualToString:@""])
    {
        return;
    }
    
    if (self.loginModeSelected)
    {
        

        [self attemptLogin];
    }
    else{
        
        if (self.passwordField1.text == nil || [self.passwordField1.text isEqualToString:@""])
        {
            return;
        }
        
        [self attemptRegister];
    }
}

- (void) saveOrUpdateRealmUser: (NSString *) email{
    
    User * newOrOldUser = [User objectForPrimaryKey:email];
    
    if (newOrOldUser == nil){
        newOrOldUser = [[User alloc] init];
        newOrOldUser.email = email;
    }
    
    [[RLMRealm defaultRealm] beginWriteTransaction];
    [[RLMRealm defaultRealm] addOrUpdateObject:newOrOldUser];
    [[RLMRealm defaultRealm] commitWriteTransaction];
    self.currentUser = newOrOldUser;


}

- (void) attemptLogin
{
    NSString *email = self.emailField.text;
    NSString *password = self.passwordField0.text;
    [[FIRAuth auth] signInWithEmail:email
                           password:password
                         completion:^(FIRUser * _Nullable user, NSError * _Nullable error)
    {
                                 if (error)
                                 {
                                     NSLog(@"%@", error.localizedDescription);
                                     return;
                                 }
                             
                                 NSLog(@"uid %@ %@", user.uid, user.refreshToken);

                                 //transition here
                                 UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main"
                                                                                      bundle:nil];
                                 MapViewController * nextScreen = [storyboard instantiateViewControllerWithIdentifier:@"MapViewController"];
        
                                [self saveOrUpdateRealmUser: email];
        
                                 [self presentViewController:nextScreen animated:YES completion:nil];

                             }];

}

- (void) attemptLoginWithToken
{
    
    //transition here
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main"
                                                         bundle:nil];
    MapViewController * nextScreen = [storyboard instantiateViewControllerWithIdentifier:@"MapViewController"];
    
    
    
    [self presentViewController:nextScreen animated:YES completion:nil];
    
    
}

- (void) attemptRegister
{
    NSString *email = self.emailField.text;
    NSString *password = self.passwordField0.text;
    [[FIRAuth auth] createUserWithEmail:email
                               password:password
                             completion:^(FIRUser * _Nullable user, NSError * _Nullable error)
    {
                                 if (error) {
                                     NSLog(@"%@", error.localizedDescription);
                                     return;
                                 }
                                 
                                 //transition here
                                 UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main"
                                                                                      bundle:nil];
                                 MapViewController * nextScreen = [storyboard instantiateViewControllerWithIdentifier:@"MapViewController"];
                                 
                                 [self presentViewController:nextScreen animated:YES completion:nil];
                                 
                             }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

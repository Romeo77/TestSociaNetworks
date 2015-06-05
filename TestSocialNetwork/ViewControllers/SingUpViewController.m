//
//  SingUpViewController.m
//  TestSocialNetwork
//
//  Created by Roman on 6/4/15.
//  Copyright (c) 2015 Roman. All rights reserved.
//

#import "SingUpViewController.h"

@interface SingUpViewController ()
@property (weak, nonatomic) IBOutlet UITextField *tfFirstName;
@property (weak, nonatomic) IBOutlet UITextField *tfSecondName;
@property (weak, nonatomic) IBOutlet UITextField *tfBirthDay;
@property (weak, nonatomic) IBOutlet UITextField *tfEmail;
@property (weak, nonatomic) IBOutlet UITextField *tfUserName;
@property (weak, nonatomic) IBOutlet UITextField *tfPassword;
@end

@implementation SingUpViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

#pragma mark - Action Buttons

- (IBAction)btnSingupTapped:(id)sender
{
    [PFCloud callFunctionInBackground:@"signUpUser"
                       withParameters:@{@"email": _tfEmail.text, @"username": _tfUserName.text, @"password": _tfPassword.text , @"firstname": _tfFirstName.text, @"secondname": _tfSecondName.text, @"birthday": _tfBirthDay.text}
                                block:^(NSString *result, NSError *error) {
                                    UIErrReturn (@"Failed to sign up")
                                    HUDSHOW
                                    [PFUser logInWithUsernameInBackground:_tfUserName.text password:_tfPassword.text
                                                                    block:^(PFUser *user, NSError *error) {
                                                                        HUDHIDE
                                                                        
                                                                        UIErrReturn(@"Cannot login");
                                                                        
                                                                        [[NSNotificationCenter defaultCenter]postNotificationName:notificationLogin object:nil];
                                                                    }];
                                    
                                }];
}



@end

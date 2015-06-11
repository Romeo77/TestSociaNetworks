//
//  LoginViewController.m
//  TestSocialNetwork
//
//  Created by Roman on 6/2/15.
//  Copyright (c) 2015 Roman. All rights reserved.
//

static NSString *const ALL_USER_FIELDS = @"first_name,last_name,photo_200_orig";

#import "LoginViewController.h"
#import "GoogleSingUp.h"
#import "TwitterSingUp.h"
#import "FacebookSingUp.h"

@interface LoginViewController ()<VKSdkDelegate>
@property (weak, nonatomic) IBOutlet UITextField *tfUserName;
@property (weak, nonatomic) IBOutlet UITextField *tfPassword;
@end

@implementation LoginViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

#pragma mark - Action Buttons

- (IBAction) btnLoginTapped:(id)sender
{
    HUDSHOW
    [PFUser logInWithUsernameInBackground:self.tfUserName.text password:self.tfPassword.text
                                    block:^(PFUser *user, NSError *error) {
                                        HUDHIDE
                                        UIErrReturn(@"Cannot login");
                                        [[NSNotificationCenter defaultCenter]postNotificationName:notificationLogin object:nil];
                                    }];
}

- (IBAction) btnFacebookTapped:(id)sender
{
    [[FacebookSingUp manager] initFacebookSingUp];
}

- (IBAction) btnGoogleTapped:(id)sender
{
    [[GoogleSingUp manager] initGoogleSingUp];
}

- (IBAction) btnTwitterTapped:(id)sender
{
    [[TwitterSingUp manager] initTwitterSingUp];
}

- (IBAction) btnVkTapped:(id)sender
{
    [VKSdk initializeWithDelegate:self andAppId:@"4941554"];
    if (![VKSdk wakeUpSession])
    {
        [VKSdk authorize:@[VK_PER_NOHTTPS, VK_PER_OFFLINE, VK_PER_PHOTOS, VK_PER_WALL, VK_PER_EMAIL]];
    }
    else
    {
        [self logInVK];
    }
}

- (IBAction)btnForgotPasswordTapped:(id)sender
{
    UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"Password reset" message:@"Please enter your email" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"Send", nil];
    av.alertViewStyle = UIAlertViewStylePlainTextInput;
    [av show];
    
    av.tapBlock = ^(UIAlertView *av, NSInteger buttonIndex)
    {
        if(buttonIndex == av.cancelButtonIndex)return ;
        HUDSHOW
        [PFUser requestPasswordResetForEmailInBackground:[av textFieldAtIndex:0].text block:^(BOOL succeeded,NSError *error){
            HUDHIDE
            UIErrReturn (@"Failed to request password reset")
            UIMsg(@"Reguest instructions sent to your email")
        }];
    };
}

- (void) saveUserInfoFromVkWithFirstName :(NSString*)firstName andSecondName :(NSString*)secondName andUrl :(NSString*)urlImage
{
    PFUser *user = [PFUser user];
    user.username = secondName;
    user.password = @"12345";
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            [[PFUser currentUser] setObject:firstName forKey:@"firstname"];
            [[PFUser currentUser] setObject:[self wrapImageToPFfile:urlImage] forKey:@"image"];
            [[PFUser currentUser] setObject:secondName forKey:@"secondname"];
            [[PFUser currentUser] saveInBackground];
        }
    }];
}

- (PFFile *) wrapImageToPFfile :(NSString*) userImageURL
{
    NSURL *url = [NSURL URLWithString:userImageURL];
    NSData *data = [NSData dataWithContentsOfURL:url];
    UIImage *img = [[UIImage alloc] initWithData:data];
    NSData *imageData = UIImagePNGRepresentation(img);
    PFFile *imageFile = [PFFile fileWithName:@"image.png" data:imageData];
    return imageFile;
}

#pragma mark - VK helper methods

- (void) logInVK
{
    VKRequest * request = [[VKApi users] get:@{ VK_API_FIELDS : ALL_USER_FIELDS }];
    [request executeWithResultBlock:^(VKResponse * response)
     {
         [PFUser logInWithUsernameInBackground:[[response.json firstObject] objectForKey:@"last_name"] password:@"12345"
                                         block:^(PFUser *user, NSError *error) {
                                             HUDHIDE
                                             
                                             UIErrReturn(@"Cannot login");
                                             
                                             [[NSNotificationCenter defaultCenter]postNotificationName:notificationLogin object:nil];
                                         }];
         
     } errorBlock:^(NSError * error) {
         if (error.code != VK_API_ERROR) {
             [error.vkError.request repeat];
         }
         else {
             NSLog(@"VK error: %@", error);
         }
     }];
    
    
}

- (void) vkSdkNeedCaptchaEnter:(VKError *)captchaError
{
    VKCaptchaViewController *vc = [VKCaptchaViewController captchaControllerWithError:captchaError];
    [vc presentIn:self.navigationController.topViewController];
}

- (void) startWorking
{
    VKRequest * request = [[VKApi users] get:@{ VK_API_FIELDS : ALL_USER_FIELDS }];
    [request executeWithResultBlock:^(VKResponse * response)
     {
         [self saveUserInfoFromVkWithFirstName:[[response.json firstObject] objectForKey:@"first_name"] andSecondName :[[response.json firstObject] objectForKey:@"last_name"] andUrl:[[response.json firstObject] objectForKey:@"photo_200_orig"]];
     } errorBlock:^(NSError * error) {
         if (error.code != VK_API_ERROR) {
             [error.vkError.request repeat];
         }
         else {
             NSLog(@"VK error: %@", error);
         }
     }];
    [[NSNotificationCenter defaultCenter]postNotificationName:notificationLogin object:nil];
}

#pragma mark - VK Delegate

- (void)vkSdkTokenHasExpired:(VKAccessToken *)expiredToken
{
    // [self authorize:nil];
}

- (void)vkSdkReceivedNewToken:(VKAccessToken *)newToken
{
    [self startWorking];
}

- (void)vkSdkShouldPresentViewController:(UIViewController *)controller
{
    [self.navigationController.topViewController presentViewController:controller animated:YES completion:nil];
}

- (void)vkSdkAcceptedUserToken:(VKAccessToken *)token
{
    [self startWorking];
}

- (void)vkSdkUserDeniedAccess:(VKError *)authorizationError
{
    UIMsg(@"Access denied")
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end

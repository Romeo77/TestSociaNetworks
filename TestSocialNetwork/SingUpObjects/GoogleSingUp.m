//
//  GoogleSingUp.m
//  TestSocialNetwork
//
//  Created by Roman on 6/4/15.
//  Copyright (c) 2015 Roman. All rights reserved.
//
static NSString * const kClientID =
@"306038420167-5od117iusimv57aqb3duo5cm1uil27vp.apps.googleusercontent.com";

#import "GoogleSingUp.h"
#import <GTLPlusConstants.h>
#import <GPPSignInButton.h>
#import "GTLServicePlus.h"
#import <GooglePlus/GooglePlus.h>
#import "GTLQueryPlus.h"
#import "GTLPlusActivity.h"
#import "GTLPlusActivityFeed.h"
#import "GTLPlusComment.h"
#import "GTLPlusCommentFeed.h"
#import "GTLPlusMoment.h"
#import "GTLPlusMomentsFeed.h"
#import "GTLPlus.h"
#import "GTLPlusItemScope.h"
#import "GTLPlusPeopleFeed.h"
#import "GTLPlusPerson.h"

@interface GoogleSingUp () <GPPSignInDelegate>
@property (nonatomic) GPPSignIn *singIn;
@property (assign, nonatomic) BOOL flag;
@end

@implementation GoogleSingUp

+ (instancetype) manager
{
    static GoogleSingUp *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[GoogleSingUp alloc] init];
    });
    
    return  manager;
}

- (id) init// or use coredata not to save a google user in the parse again, need more terms....
{
    self = [super init];
    if ( self )
    {
        _flag = YES;
    }
    return self;
}

- (void) initGoogleSingUp
{
    HUDSHOW
    _singIn = [GPPSignIn sharedInstance];
    // _singIn.clientID = kClientID;                 //IOS 8 works badly
    _singIn.scopes = @[kGTLAuthScopePlusLogin];
    _singIn.shouldFetchGoogleUserEmail = YES;
    _singIn.delegate = self;
    [_singIn authenticate];
    [_singIn trySilentAuthentication];
    if (!_flag)
    {
        [self logIn];
    }
}

- (void)finishedWithAuth: (GTMOAuth2Authentication *)auth  error: (NSError *) error
{
    if(_flag){
        GTLServicePlus* plusService = [[GTLServicePlus alloc] init] ;
        plusService.retryEnabled = YES;
        [plusService setAuthorizer:auth];
        GTLQueryPlus *query = [GTLQueryPlus queryForPeopleGetWithUserId:@"me"];
        [plusService executeQuery:query
                completionHandler:^(GTLServiceTicket *ticket,
                                    GTLPlusPerson *person,
                                    NSError *error) {
                    if (error)
                    {
                        UIErrReturn (@"Failed to request user info")
                    }
                    else
                    {
                        [self saveUserInfoFromGoogleWithFirstName :person.name.givenName andSecond :person.name.familyName andUrl :person.image.url andBirthDay :person.birthday];
                    }
                }];
        _flag = NO;
        HUDHIDE
    }
}

- (void) saveUserInfoFromGoogleWithFirstName :(NSString*)firstName andSecond :(NSString*)secondName andUrl :(NSString*)  urlImage andBirthDay :(NSString*)birthday
{
    PFUser *user = [PFUser user];
    user.username = _singIn.userEmail;
    user.password = @"12345";
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            [[PFUser currentUser] setObject:firstName forKey:@"firstname"];
            [[PFUser currentUser] setObject:[self wrapImageToPFfile:urlImage] forKey:@"image"];
            [[PFUser currentUser] setObject:secondName forKey:@"secondname"];
            [[PFUser currentUser] setObject:_singIn.userEmail forKey:@"email"];
            [[PFUser currentUser] saveInBackground];
        }
    }];
    [[NSNotificationCenter defaultCenter]postNotificationName:notificationLogin object:nil];
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

- (void) logIn
{
    [PFUser logInWithUsernameInBackground:_singIn.userEmail password:@"12345"
                                    block:^(PFUser *user, NSError *error) {
                                        HUDHIDE
                                        
                                        UIErrReturn(@"Cannot login");
                                        
                                        [[NSNotificationCenter defaultCenter]postNotificationName:notificationLogin object:nil];
                                    }];
}

@end

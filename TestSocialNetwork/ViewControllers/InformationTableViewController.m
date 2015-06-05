//
//  InformationTableViewController.m
//  TestSocialNetwork
//
//  Created by Roman on 6/4/15.
//  Copyright (c) 2015 Roman. All rights reserved.
//
static NSString *const ALL_USER_FIELDS = @"nickname";

#import "InformationTableViewController.h"

@interface InformationTableViewController ()
@property (strong, nonatomic) NSArray *arrayWithFriends;
@end

@implementation InformationTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

#pragma mark - Action Buttons

- (IBAction)btnFriendsTapped:(id)sender
{
    //for facebook
    //    FBRequest* friendsRequest = [FBRequest requestForMyFriends];
    //    [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,
    //                                                  NSDictionary* result,
    //                                                  NSError *error)
    //     {
    //         _arrayWithFriends = [result objectForKey:@"data"];
    //
    //         [[self tableView] reloadData];
    //     }];
    VKRequest * request = [[VKApi friends] get:@{ VK_API_FIELDS : ALL_USER_FIELDS }];
    [request executeWithResultBlock:^(VKResponse * response) {
        _arrayWithFriends = [response.json objectForKey:@"items"];
        [self.tableView reloadData];
    } errorBlock:^(NSError * error) {
        if (error.code != VK_API_ERROR) {
            [error.vkError.request repeat];
        }
        else {
            NSLog(@"VK error: %@", error);
        }
    }];
}

- (IBAction)btnLogoutTapped:(id)sender
{
    [[NSNotificationCenter defaultCenter]postNotificationName:notificationLogout object:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _arrayWithFriends.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.text = [_arrayWithFriends[indexPath.row]objectForKey:@"first_name"];
    return cell;
}

@end

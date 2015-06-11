//
//  InformationTableViewController.m
//  TestSocialNetwork
//
//  Created by Roman on 6/4/15.
//  Copyright (c) 2015 Roman. All rights reserved.
//
static NSString *const ALL_USER_FIELDS = @"nickname";


#import "InformationTableViewController.h"
#import "AddPostViewController.h"
#import "PostTableViewCell.h"
#import <MediaPlayer/MediaPlayer.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>

@interface InformationTableViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (strong, nonatomic) NSArray *arrayWithFriends;
@property (strong, nonatomic) NSArray *arrayWithObjects;
//===
@property (strong,nonatomic) NSString *urlVideo;
@property (strong,nonatomic) UIImage *chosenImage;

@end

@implementation InformationTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadData];
}

-(void)loadData
{
    [PFQuery clearAllCachedResults];
    PFQuery *query = [PFQuery queryWithClassName:@"PicsVideos"];
    if(query.hasCachedResult)
        query.cachePolicy = kPFCachePolicyCacheElseNetwork;
    HUDSHOW
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         HUDHIDE
         SHOW_ERROR_RETURN
         self.arrayWithObjects  = objects;
         [self.tableView reloadData];
     }];
}

#pragma mark - Action Buttons

- (IBAction)btnAddPostTapped:(id)sender
{
    [self compactCode:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (IBAction)btnLogoutTapped:(id)sender
{
    [PFUser logOut];
    [[NSNotificationCenter defaultCenter]postNotificationName:notificationLogout object:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _arrayWithObjects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PostTableViewCell *cell = (PostTableViewCell *)[tableView
                                                    dequeueReusableCellWithIdentifier:@"cell"];
    PFObject *object = self.arrayWithObjects[indexPath.row];
    PFUser *a = object[@"owner"];
    PFQuery * query = [PFUser query];
    [query getObjectInBackgroundWithId:a.objectId
                                 block:^(PFObject *user, NSError *error) {
                                     cell.lbUserName.text = user[@"firstname"];
                                     
                                     if (object[@"url"]) {
                                         UIButton *newBtn=[UIButton buttonWithType:UIButtonTypeSystem];
                                         [newBtn setFrame:CGRectMake(25,25,55,55)];
                                         [ newBtn setTitle:@"Play" forState:UIControlStateNormal];
                                         newBtn.backgroundColor = [UIColor blackColor];
                                         newBtn.tag = indexPath.row;
                                         [newBtn addTarget:self action:@selector(btnPlayTapped:) forControlEvents:UIControlEventTouchUpInside];
                                         
                                         [cell addSubview:newBtn];
                                     }
                                     
                                     cell.lbNamePic.text = object[@"name"];
                                     cell.lbLocation.text = object[@"location"];
                                     cell.imgView.image = nil;
                                     PFFile *imgFile = object[@"pictures"];
                                     [cell.indicator startAnimating];
                                     
                                     [imgFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                                         [cell.indicator stopAnimating];
                                         if (error) return;
                                         
                                         cell.imgView.image = [UIImage imageWithData:data];
                                     }];
                                 }];
    return cell;
}

-(void) btnPlayTapped :(id)sender
{
    PFObject *object = self.arrayWithObjects[[sender tag]];
    NSURL *url = [NSURL URLWithString:object[@"url"]];
    MPMoviePlayerViewController *player =[[MPMoviePlayerViewController alloc] initWithContentURL: url];
    [self presentMoviePlayerViewControllerAnimated:player];
    [player.moviePlayer play];
}

-(void)compactCode :(UIImagePickerControllerSourceType)type
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    picker.mediaTypes = [UIImagePickerController
                         availableMediaTypesForSourceType:picker.sourceType];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = type;
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if ([info[@"UIImagePickerControllerMediaType"] isEqualToString: @"public.image"])
    {
        _chosenImage = info[UIImagePickerControllerEditedImage];
        _urlVideo = nil;
    }
    else
    {
        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[info objectForKey:UIImagePickerControllerMediaURL] options:nil];
        AVAssetImageGenerator *generateImg = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        NSError *error = NULL;
        CMTime time = CMTimeMake(1, 65);
        CGImageRef refImg = [generateImg copyCGImageAtTime:time actualTime:NULL error:&error];
        SHOW_ERROR_RETURN
        _chosenImage = [[UIImage alloc] initWithCGImage:refImg];
        _urlVideo = [[info objectForKey:UIImagePickerControllerReferenceURL] absoluteString];
    }
    
    if (_chosenImage.size.width >200 || _chosenImage.size.height >200)
        _chosenImage = [self changeImageSizeWithImage:_chosenImage];
    [self performSegueWithIdentifier: @"post" sender:nil];
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (UIImage *)changeImageSizeWithImage:(UIImage *)image
{
    UIGraphicsBeginImageContext(CGSizeMake(200, 200));
    [image drawInRect:CGRectMake(0, 0, 200, 200)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark prepareForSegue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    AddPostViewController *vc = [AddPostViewController new];
    if ([[segue identifier] isEqualToString:@"post"]) {
        vc = [segue destinationViewController];
        vc.imagePost = _chosenImage;
        vc.urlVideo = _urlVideo;
    }
}

/*- (IBAction)btnFriendsTapped:(id)sender//there was a button to get the list friends from vk and facebook
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
 }*/

@end

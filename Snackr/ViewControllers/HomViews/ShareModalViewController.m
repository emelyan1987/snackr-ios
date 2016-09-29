//
//  ShareModalViewController.m
//  Snackr
//
//  Created by Snackr on 8/19/15.
//  Copyright (c) 2015 Snackr. All rights reserved.
//

#import "ShareModalViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <TwitterKit/TwitterKit.h>

//#import <Social/Social.h>
#import <PinterestSDK.h>
#import "AlertManager.h"


@interface ShareModalViewController ()
@property (nonatomic, retain) UIDocumentInteractionController *documentController;
@end

@implementation ShareModalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.bgView.layer.cornerRadius = 10.0f;
    self.bgView.clipsToBounds = YES;
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onDone:(id)sender {
    [self.delegate onShareDone];
}
- (IBAction)onShareFacebook:(id)sender {
    UIImage *image = self.photo;
    
    FBSDKSharePhoto *photo = [[FBSDKSharePhoto alloc] init];
    photo.image = image;
    photo.userGenerated = YES;
    FBSDKSharePhotoContent *content = [[FBSDKSharePhotoContent alloc] init];
    content.photos = @[photo];
    
    [FBSDKShareDialog showFromViewController:self
                                 withContent:content
                                    delegate:nil];
    
    [self.delegate onShareDone];
    /*if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        
        [controller setInitialText:@"First post from my iPhone app"];
        [self presentViewController:controller animated:YES completion:Nil];
    }*/
}
- (IBAction)onSharePinterest:(id)sender {
    
    UIImage *image = self.photo;
    
    [[PDKClient sharedInstance] authenticateWithPermissions:@[PDKClientReadPublicPermissions,
                                                              PDKClientWritePublicPermissions,
                                                              PDKClientReadPrivatePermissions,
                                                              PDKClientWritePrivatePermissions,
                                                              PDKClientReadRelationshipsPermissions,
                                                              PDKClientWriteRelationshipsPermissions] withSuccess:^(PDKResponseObject *responseObject) {
                                                                  [[PDKClient sharedInstance] createBoard:@"asdf" boardDescription:@"asdfasdf" withSuccess:^(PDKResponseObject *responseObject) {
                                                                      PDKBoard *board = responseObject.board;
                                                                      
                                                                      [[PDKClient sharedInstance] createPinWithImage:image link:nil onBoard:nil description:@"asdfasdf" progress:^(CGFloat percentComplete) {
                                                                          int i=0;
                                                                          i++;
                                                                      } withSuccess:^(PDKResponseObject *responseObject) {
                                                                          int i=0;
                                                                          i++;
                                                                      } andFailure:^(NSError *error) {
                                                                          NSLog(@"Pinterest Create Image Error: %@", error);
                                                                      }];
                                                                  } andFailure:^(NSError *error) {
                                                                      NSLog(@"Pinterest Create board Error: %@", error);
                                                                  }];
                                                              } andFailure:^(NSError *error) {
                                                                  NSLog(@"Pinterest Authenticate Error: %@", error);
                                                              }];
    
    [self.delegate onShareDone];
    
}
- (IBAction)onShareTwitter:(id)sender {
    TWTRComposer *composer = [[TWTRComposer alloc] init];
    
    //[composer setText:@"just setting up my Fabric"];
    [composer setImage:self.photo];
    
    // Called from a UIViewController
    [composer showFromViewController:self completion:^(TWTRComposerResult result) {
        if (result == TWTRComposerResultCancelled) {
            NSLog(@"Sharing is cancelled");
            [AlertManager showErrorMessage:@"Tweet composition cancelled"];
        }
        else {
            NSLog(@"Sending Tweet!");
            [AlertManager showInfoMessage:@"Sharing success!"];
        }
    }];
    
    [self.delegate onShareDone];

}
- (IBAction)onShareInstagram:(id)sender {
    UIImage *image = self.photo;
    NSURL *instagramURL = [NSURL URLWithString:@"instagram://app"];
    if([[UIApplication sharedApplication] canOpenURL:instagramURL])
    {
        NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
        
        NSString *writePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"instagram.igo"];
        if (![imageData writeToFile:writePath atomically:YES]) {
            // failure
            NSLog(@"image save failed to path %@", writePath);
            return;
        } else {
            // success.
        }
        
        // send it to instagram.
        NSURL *fileURL = [NSURL fileURLWithPath:writePath];
        
        
        self.documentController = [UIDocumentInteractionController interactionControllerWithURL:fileURL];
        self.documentController.delegate = self;
        [self.documentController setUTI:@"com.instagram.photo"];
        [self.documentController setAnnotation:@{@"InstagramCaption" : @"We are making fun"}];
        [self.documentController presentOpenInMenuFromRect:CGRectMake(0, 0, 320, 480) inView:self.view animated:YES];
    }
    else
    {
        NSLog (@"Instagram not found");
        [AlertManager showErrorMessage:@"Instagram app is not installed on your iPhone"];
    }
    
    [self.delegate onShareDone];
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

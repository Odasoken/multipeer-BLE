//
//  ViewController.m
//  mutitPeerBLE
//
//  Created by juliano on 15/11/6.
//  Copyright © 2015年 WT. All rights reserved.
//

#import "ViewController.h"
#import <MultipeerConnectivity/MultipeerConnectivity.h>

static NSString * const XXServiceType = @"xx-service";

@interface ViewController ()<MCBrowserViewControllerDelegate,MCSessionDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property(nonatomic,strong) NSMutableArray *connectedPeers;

@property(nonatomic,strong) MCSession *session;
@property(nonatomic,strong)  MCAdvertiserAssistant *advertiserAssistant;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.connectedPeers = [NSMutableArray array];
    MCPeerID *localPeerID = [[MCPeerID alloc] initWithDisplayName:[[UIDevice currentDevice] name]];
    self.session = [[MCSession alloc] initWithPeer:localPeerID];
    self.session.delegate = self;
    MCAdvertiserAssistant *advertiserAssistant = [[MCAdvertiserAssistant alloc] initWithServiceType:XXServiceType discoveryInfo:nil session:self.session];
    self.advertiserAssistant = advertiserAssistant;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    [self.session disconnect];
}
- (IBAction)pair:(id)sender {
    
    [self.advertiserAssistant start];
    MCBrowserViewController *blvc = [[MCBrowserViewController alloc] initWithServiceType:XXServiceType session:self.session];
    blvc.delegate = self;
    [self presentViewController:blvc animated:YES completion:nil];
}

- (IBAction)sendData:(id)sender {
    if (self.connectedPeers.count) {
         NSData *data = UIImagePNGRepresentation(self.imageView.image);
        NSError *error = nil;
        [self.session sendData:data toPeers:@[self.connectedPeers.firstObject] withMode:MCSessionSendDataReliable error:&error];
        if (error) {
            NSLog(@"error:%@",error);
        }
    }
}
- (IBAction)selectImage:(id)sender {
    UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
    ipc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    ipc.delegate = self;
    [self presentViewController:ipc animated:YES completion:nil];
}

#pragma mark -MCBrowserViewControllerDelegate
-(void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController
{
    [browserViewController dismissViewControllerAnimated:YES completion:nil];
}

-(void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController
{
   [browserViewController dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)browserViewController:(MCBrowserViewController *)browserViewController
      shouldPresentNearbyPeer:(MCPeerID *)peerID
            withDiscoveryInfo:(nullable NSDictionary<NSString *, NSString *> *)info
{
    //YES才可以展示搜索到的peer
    return YES;
}
#pragma  mark -UIImagePickerControllerDelegate
//-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
//{
//    NSLog(@"%@",info);
//}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    self.imageView.image = image;
}
//#pragma mark -MCNearbyServiceAdvertiserDelegate
//-(void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void (^)(BOOL, MCSession * _Nonnull))invitationHandler
//{
//    if ([self.mutableBlockedPeers containsObject:peerID]) {
//        invitationHandler(NO, nil);
//        return;
//    }
////    
////    [[UIActionSheet actionSheetWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Received Invitation from %@", @"Received Invitation from {Peer}"), peerID.displayName]
////                       cancelButtonTitle:NSLocalizedString(@"Reject", nil)
////                  destructiveButtonTitle:NSLocalizedString(@"Block", nil)
////                       otherButtonTitles:@[NSLocalizedString(@"Accept", nil)]
////                                   block:^(UIActionSheet *actionSheet, NSInteger buttonIndex)
////      {
////          BOOL acceptedInvitation = (buttonIndex == [actionSheet firstOtherButtonIndex]);
////          
////          if (buttonIndex == [actionSheet destructiveButtonIndex]) {
////              [self.mutableBlockedPeers addObject:peerID];
////          }
////          
////          MCSession *session = [[MCSession alloc] initWithPeer:localPeerID
////                                              securityIdentity:nil
////                                          encryptionPreference:MCEncryptionNone];
////          session.delegate = self;
////          
////          invitationHandler(acceptedInvitation, (acceptedInvitation ? session : nil));
////      }] showInView:self.view];
//}

#pragma mark - MCSessionDelegate
-(void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
    if (state == MCSessionStateConnected)
    {
        if (![self.connectedPeers containsObject:peerID]) {
            [self.connectedPeers addObject:peerID];
        }
    }else
    {
        if ([self.connectedPeers containsObject:peerID]) {
            [self.connectedPeers removeObject:peerID];
        }
    }
}

-(void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
    UIImage *image = [UIImage imageWithData:data];
    dispatch_async(dispatch_get_main_queue(), ^{
      self.imageView.image = image;
    });
    
}

-(void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID
{
    
}

-(void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress
{
    
}

-(void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error
{
    
}

@end

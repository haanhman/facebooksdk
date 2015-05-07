//
//  MainScene.m
//  PROJECTNAME
//
//  Created by Viktor on 10/10/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "MainScene.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>

@implementation MainScene {
    CCButton *loginBtn, *logoutBtn;
    NSDictionary *meInfo;
    CCLabelTTF *lblName;
    NSArray *listFriend;
    FBSDKGameRequestDialog *dialog;
}

-(void)didLoadFromCCB {
    logoutBtn.visible = NO;
    loginBtn.visible = NO;
}

-(void)onEnterTransitionDidFinish {
    [super onEnterTransitionDidFinish];
    [self scheduleOnce:@selector(initLoginButton) delay:1.0f];
}

-(void)initLoginButton {
    if ([FBSDKAccessToken currentAccessToken]) {
        logoutBtn.visible = YES;
        loginBtn.visible= NO;
        [self getMeInfo];
    } else {
        loginBtn.visible = YES;
        logoutBtn.visible = NO;
        lblName.string = @"NULL";
    }
}

-(void)LogoutAction {
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [login logOut];
    loginBtn.visible = YES;
    logoutBtn.visible = NO;
    lblName.string = @"NULL";
}

-(void)LoginAction {
    if ([FBSDKAccessToken currentAccessToken]) {
        [self getMeInfo];
    } else {
        FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
        [login logInWithReadPermissions:@[@"public_profile", @"email", @"user_friends"] handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
            if (error) {
                // Process error
            } else if (result.isCancelled) {
                // Handle cancellations
            } else {
                // If you ask for multiple permissions at once, you
                // should check if specific permissions missing
                //dang nhap thanh cong
                [self getMeInfo];
            }
        }];
    }
}

-(void)InviteAction {
    if ([FBSDKAccessToken currentAccessToken]) {
        if(listFriend.count > 0) {
            [self sendRequest];
            return;
        }
        
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me/invitable_friends" parameters:@{@"limit":@"5000", @"offset":@"5000"}]
         
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
             if (!error) {
                 listFriend = [result valueForKey:@"data"];
                 [self sendRequest];
             } else {
                 NSLog(@"error: %@", error);
             }
         }];
    } else {
        NSLog(@"Ban chua login");
    }
}


-(void)sendRequest {
    NSMutableArray *friends = [NSMutableArray array];
    for (NSDictionary *dict in listFriend) {
        [friends addObject:[dict valueForKey:@"id"]];
//        NSString *name = [dict valueForKey:@"name"];
//        if([name isEqualToString:@"Nguyễn Mùi"] || [name isEqualToString:@"Anh Man"] || [name isEqualToString:@"Đào Xuân Hoàng"]) {
//            [nguoinhan addObject:[dict valueForKey:@"id"]];
//        }
        
        //By default, the sender is presented with a multi-friend selector allowing them to select a maximum of 50 recipients.
        if(friends.count == 10) {
            break;
        }
    }    
    FBSDKGameRequestContent *gameRequestContent = [[FBSDKGameRequestContent alloc] init];
    gameRequestContent.message = @"Choi thu nhe, hay lam day";
    gameRequestContent.title = @"Monkey Junior";
    gameRequestContent.to = friends;
    dialog = [FBSDKGameRequestDialog showWithContent:gameRequestContent delegate:(id)self];
    
}

- (void)gameRequestDialogDidCancel:(FBSDKGameRequestDialog *)gameRequestDialog {
    NSLog(@"==> Cancel");
    UIAlertView *alertview=[[UIAlertView alloc] initWithTitle:@"Facebook" message:@"Cancel share" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
    [alertview show];
}

- (void)gameRequestDialog:(FBSDKGameRequestDialog *)gameRequestDialog didCompleteWithResults:(NSDictionary *)results {
    NSLog(@"Share thanh cong\nresults: %@", results);
}
- (void)gameRequestDialog:(FBSDKGameRequestDialog *)gameRequestDialog didFailWithError:(NSError *)error {
    NSLog(@"Share loi\nerror: %@", error);
}


-(void)UseAction {
    
    
    if ([FBSDKAccessToken currentAccessToken]) {
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me/friends" parameters:nil]
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
             if (!error) {
                 
                 NSLog(@"Danh sach ban be da dung app: %@", result);
             } else {
                 NSLog(@"error: %@", error);
             }
         }];
    }
    
}

-(void)postAction {
    if ([[FBSDKAccessToken currentAccessToken] hasGranted:@"publish_actions"]) {
        [[[FBSDKGraphRequest alloc]
          initWithGraphPath:@"me/feed"
          parameters: @{
                        @"message" : @"Monkey Junior - Early Start",
                        @"name":@"Monkey Junior App",
                        @"description":@"click vao day de down app ve cho con ban hoc nhe",
                        @"link":@"https://itunes.apple.com/us/app/monkey-junior-teach-your-child/id930331514?mt=8"
                        }
          HTTPMethod:@"POST"]
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
             if (!error) {
                 NSLog(@"Post id:%@", result[@"id"]);
             }
         }];
    } else {
        NSLog(@"Ban chua dang nhap");
    }
}

-(void)getMeInfo {
    if ([FBSDKAccessToken currentAccessToken]) {
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil]
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
             if (error) {
                 loginBtn.visible = YES;
                 logoutBtn.visible = NO;
                 lblName.string = @"NULL";
                 NSLog(@"Mat ket noi den server");
             } else {
                 meInfo = result;
                 lblName.string = [meInfo valueForKey:@"name"];
                 
                 loginBtn.visible = NO;
                 logoutBtn.visible = YES;
             }
         }];
    }
}

-(void)SwtichMode {
    NSLog(@"==> SwtichMode");
//    AppController *appController = (AppController *)[[UIApplication sharedApplication] delegate];
//    UIViewController *c = [[UIViewController alloc]init];
//    //the above code won't work for iOS so you must also include this for iOS
//    [c.view setBackgroundColor:[UIColor blackColor]];
//    [appController.navController presentViewController:c animated:NO completion:^{
//        dispatch_after(0, dispatch_get_main_queue(), ^{
//            [appController.navController dismissViewControllerAnimated:NO completion:nil];
//        });
//    }];
    
//    [[UIDevice currentDevice] setValue:
//     [NSNumber numberWithInteger: UIInterfaceOrientationPortrait]
//                                forKey:@"orientation"];
    
//    [[UIApplication sharedApplication] setStatusBarOrientation:UIDeviceOrientationPortrait | UIDeviceOrientationPortraitUpsideDown];
    
    [[UIDevice currentDevice] setValue:
     [NSNumber numberWithInteger: UIInterfaceOrientationPortrait]
                                forKey:@"orientation"];
}


-(NSUInteger)supportedInterfaceOrientations
{
    NSLog(@"vao day roi");
    return UIInterfaceOrientationPortrait;
}

@end

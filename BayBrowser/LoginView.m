//
//  LoginView.m
//  BayBrowser
//
//  Created by Ethan Arbuckle on 5/15/13.
//
//

#import "LoginView.h"
#import "AFNetworking.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"
#import "SideViewViewController.h"

@interface LoginView ()

@end

@implementation LoginView

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)login:(id)sender {
    [self.view endEditing:YES];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Logging in...";
    [self.view addSubview:hud];
    AppDelegate *appd = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://thepiratebay.sx/login.php?username=%@&password=%@&act=login&submit=Login", _username.text, _pass.text]];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *response = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        if ([response rangeOfString:@"You have no active torrents."].location != NSNotFound) {
            appd.authenticated = YES;
            [[NSUserDefaults standardUserDefaults] setValue:_username.text forKey:@"username"];
            [[NSUserDefaults standardUserDefaults] setValue:_pass.text forKey:@"password"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            appd.username = [NSMutableString stringWithFormat:@"%@", _username.text];
            SideViewViewController *side = [[SideViewViewController alloc] init];
            [side refreshTable];
            [self dismissModalViewControllerAnimated:YES];
            [appd.deckController toggleLeftView];
        } else {
            appd.authenticated = NO;
        }
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        UIAlertView *noLogin = [[UIAlertView alloc] initWithTitle:@"Login Failed" message:@"Failed to login using the creditionals you provided" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [noLogin show];
    }];
    [operation start];
}

- (IBAction)cancel:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

@end

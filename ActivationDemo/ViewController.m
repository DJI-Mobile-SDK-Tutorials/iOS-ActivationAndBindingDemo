//
//  ViewController.h
//  ActivationDemo
//
//  Created by DJI on 28/4/2016.
//  Copyright © 2016 DJI. All rights reserved.
//

#import "ViewController.h"
#import <DJISDK/DJISDK.h>
#import "DJIAppActivationManager_InternalTesting.h"

#define WeakRef(__obj) __weak typeof(self) __obj = self
#define WeakReturn(__obj) if(__obj ==nil)return;

void ShowResult(NSString *format, ...)
{
    va_list argumentList;
    va_start(argumentList, format);
    
    NSString* message = [[NSString alloc] initWithFormat:format arguments:argumentList];
    va_end(argumentList);
    NSString * newMessage = [message hasSuffix:@":(null)"] ? [message stringByReplacingOccurrencesOfString:@":(null)" withString:@" successful!"] : message;
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController* alertViewController = [UIAlertController alertControllerWithTitle:nil message:newMessage preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertViewController addAction:okAction];
        UIViewController* viewController = (UIViewController*)[[UIApplication sharedApplication] keyWindow].rootViewController;
        [viewController presentViewController:alertViewController animated:YES completion:nil];
    });
}

@interface ViewController ()<DJIAppActivationManagerDelegate, DJISDKManagerDelegate>
@property (nonatomic) DJIAppActivationState activationState;
@property (nonatomic) DJIAppActivationAircraftBindingState aircraftBindingState;

@property (weak, nonatomic) IBOutlet UILabel *bindingStateLabel;
@property (weak, nonatomic) IBOutlet UILabel *appActivationLabel;
- (IBAction)onLoginClick:(id)sender;
- (IBAction)onLogoutClick:(id)sender;

@end

@implementation ViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self registerApp];
    [self updateUI];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [DJISDKManager appActivationManager].delegate = self;
    self.activationState = [DJISDKManager appActivationManager].appActivationState;
    self.aircraftBindingState = [DJISDKManager appActivationManager].aircraftBindingState;
}

- (void)registerApp
{
    [DJISDKManager registerAppWithDelegate:self];
}

-(void)updateUI {
    switch (self.aircraftBindingState) {
        case DJIAppActivationAircraftBindingStateUnboundButCannotSync:
            self.bindingStateLabel.text = @"Unbound. Please connect Internet to update state. ";
            break;
        case DJIAppActivationAircraftBindingStateUnbound:
            self.bindingStateLabel.text = @"Unbound. Use DJI GO to bind the aircraft. ";
            break;
        case DJIAppActivationAircraftBindingStateUnknown:
            self.bindingStateLabel.text = @"Unknown";
            break;
        case DJIAppActivationAircraftBindingStateBound:
            self.bindingStateLabel.text = @"Bound";
            break;
        case DJIAppActivationAircraftBindingStateInitial:
            self.bindingStateLabel.text = @"Initial";
            break;
        case DJIAppActivationAircraftBindingStateNotRequired:
            self.bindingStateLabel.text = @"Binding is not required. ";
            break;
        case DJIAppActivationAircraftBindingStateNotSupported:
            self.bindingStateLabel.text = @"App Activation is not supported. ";
            break;
    }
    
    switch (self.activationState) {
        case DJIAppActivationStateLoginRequired:
            self.appActivationLabel.text = @"Login is required to activate.";
            break;
        case DJIAppActivationStateUnknown:
            self.appActivationLabel.text = @"Unknown";
            break;
        case DJIAppActivationStateActivated:
            self.appActivationLabel.text = @"Activated";
            break;
        case DJIAppActivationStateNotSupported:
            self.appActivationLabel.text = @"App Activation is not supported.";
            break;
    }
}

- (IBAction)onLoginClick:(id)sender {
    [[DJISDKManager userAccountManager] logIntoDJIUserAccountWithAuthorizationRequired:NO withCompletion:^(DJIUserAccountState state, NSError * _Nullable error) {
        if (error) {
            ShowResult(@"Login error: %@", error.description);
        }else{
            ShowResult(@"Login Success");
        }
    }];
}

- (IBAction)onLogoutClick:(id)sender {
    [[DJISDKManager userAccountManager] logOutOfDJIUserAccountWithCompletion:^(NSError * _Nullable error) {
        if (error) {
            ShowResult(@"Logout error: %@", error.description);
        }else{
            ShowResult(@"Logout Success");
        }
    }];
}

#pragma mark DJISDKManager Delegate Method
- (void)appRegisteredWithError:(NSError *)error
{
    NSString* message = @"Register App Successed!";
    if (error) {
        message = @"Register App Failed! Please enter your App Key in the plist file and check the network.";
    }else
    {
        NSLog(@"registerAppSuccess");
    }
    
    ShowResult(@"%@", message);
}

#pragma mark DJIAppActivationManagerDelegate Methods
-(void)manager:(DJIAppActivationManager *)manager didUpdateAppActivationState:(DJIAppActivationState)appActivationState {
    self.activationState = appActivationState;
    [self updateUI];
}

-(void)manager:(DJIAppActivationManager *)manager didUpdateAircraftBindingState:(DJIAppActivationAircraftBindingState)aircraftBindingState {
    self.aircraftBindingState = aircraftBindingState;
    [self updateUI];
}

@end

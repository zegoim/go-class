//
//  ZegoEnvSettingViewController.m
//  ZegoWhiteboardVideoDemo
//
//  Created by MartinNie on 2020/11/10.
//  Copyright © 2020 zego. All rights reserved.
//

#import "ZegoEnvSettingViewController.h"
#import "ZegoClassEnvManager.h"
@interface ZegoEnvSettingViewController ()
@property (weak, nonatomic) IBOutlet UISwitch *businessEnvSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *roomSeviceEnvSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *docsSeviceEnvSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *pptModeSwitch;

@end

@implementation ZegoEnvSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.businessEnvSwitch setOn:[ZegoClassEnvManager shareManager].businessTestEnv];
    [self.roomSeviceEnvSwitch setOn:[ZegoClassEnvManager shareManager].roomSeviceTestEnv];
    [self.docsSeviceEnvSwitch setOn:[ZegoClassEnvManager shareManager].docsSeviceTestEnv];
    [self.pptModeSwitch setOn:[ZegoClassEnvManager shareManager].pptStepDefaultMode];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)didClickBusinessEnv:(UISwitch *)sender {
    [ZegoClassEnvManager shareManager].businessTestEnv = sender.isOn;
}
- (IBAction)didClickRoomSeviceEnv:(UISwitch *)sender {
    [ZegoClassEnvManager shareManager].roomSeviceTestEnv = sender.isOn;
}
- (IBAction)didClickDocsSeviceEnv:(UISwitch *)sender {
    [ZegoClassEnvManager shareManager].docsSeviceTestEnv = sender.isOn;
}
- (IBAction)didClickPPTModeSwitch:(UISwitch *)sender {
    [ZegoClassEnvManager shareManager].pptStepDefaultMode = sender.isOn;
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

//
//  ViewController.m
//  NXAristotle-learn
//
//  Created by linyibin on 2017/2/27.
//  Copyright © 2017年 NXAristotle. All rights reserved.
//

#import "ViewController.h"
#import <LocalAuthentication/LocalAuthentication.h>
#import "NXTestTouchIDAboutViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

//  进行touchID验证
- (IBAction)enterAboutBtn:(UIButton *)sender {
    LAContext *content = [[LAContext alloc] init];
    content.localizedCancelTitle = @"要取消";   /**< 弹出的两个取消按钮的文案 */
    content.localizedFallbackTitle = @"使用锁屏密码进入";  /**< 如果允许使用锁屏密码进入的话 */
    
    /*
     LAPolicyDeviceOwnerAuthenticationWithBiometrics : 该模式下，连续超过5次错误，系统会自动上锁（返回’Biometry is locked out.‘的提示），并且不会自动转到密码输入框，需要锁屏，用密码解锁一次才能再次使用
     LAPolicyDeviceOwnerAuthentication : 该模式下，允许连续输入6次错误，然后自动切换到密码输入解锁模式
     */
    NSError *error = nil;
    if ([content canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
        NSLog(@"该设备支持指纹识别");
        [content evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:@"指纹解锁进入" reply:^(BOOL success, NSError * _Nullable error) {
            if (success) {
                NSLog(@"验证成功");
                //  当前线程非主线程，跳转vc属于刷新UI，必须在主线程上执行，否则可能导致crash，故此处用GCD回到主线程进行跳转处理
                dispatch_async(dispatch_get_main_queue(), ^{
                    NXTestTouchIDAboutViewController *VC = [[NXTestTouchIDAboutViewController alloc] init];
                    [self.navigationController pushViewController:VC animated:YES];
                });
                
                
            }else{
                NSLog(@"error:%@",error.localizedDescription);
                switch (error.code) {
                    case LAErrorSystemCancel:
                    {
                        NSLog(@"系统取消授权，如其他APP切入");
                        break;
                    }
                    case LAErrorUserCancel:
                    {
                        NSLog(@"用户取消验证Touch ID");
                        break;
                    }
                    case LAErrorAuthenticationFailed:
                    {
                        NSLog(@"授权失败");
                        break;
                    }
                    case LAErrorPasscodeNotSet:
                    {
                        NSLog(@"系统未设置密码");
                        break;
                    }
                    case LAErrorTouchIDNotAvailable:
                    {
                        NSLog(@"设备Touch ID不可用，例如未打开");
                        break;
                    }
                    case LAErrorTouchIDNotEnrolled:
                    {
                        NSLog(@"设备Touch ID不可用，用户未录入");
                        break;
                    }
                    case LAErrorUserFallback:
                    {
                        //                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        //                            NSLog(@"用户选择输入密码，切换主线程处理");
                        //                        }];
                        break;
                    }
                    default:
                    {
                        //                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        //                            NSLog(@"其他情况，切换主线程处理");
                        //                        }];
                        break;
                    }
                }
            }
        }];
        
    }else{
        NSLog(@"不支持指纹识别");
        switch (error.code) {
            case LAErrorTouchIDNotEnrolled:
            {
                NSLog(@"TouchID is not enrolled");
                break;
            }
            case LAErrorPasscodeNotSet:
            {
                NSLog(@"A passcode has not been set");
                break;
            }
            default:
            {
                NSLog(@"TouchID not available");
                break;
            }
        }
        
        NSLog(@"%@",error.localizedDescription);
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

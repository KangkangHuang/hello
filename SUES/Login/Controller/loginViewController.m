//
//  loginViewController.m
//  Login
//
//  Created by menuz on 14-2-23.
//  Copyright (c) 2014年 menuz's lab. All rights reserved.
//

#import "loginViewController.h"
#import "AppDelegate.h"
#import <AFNetworking.h>
#import "MBProgressHUD.h"
#import "Networking.h"
#import "MyUtil.h"
#import "AnalyzeGradeData.h"
#import "AnalyzeCourseData.h"

@interface loginViewController ()<UIGestureRecognizerDelegate>
@property (nonatomic,strong) AppDelegate *app;
@property (nonatomic,strong) NSString *userId;
@property (nonatomic,strong) NSString *userPassWord;
@property (nonatomic,strong) MBProgressHUD *hud;
@property (nonatomic,strong)Networking *networking;
///网络请求工具
@end

@implementation loginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
//    [self createBackButton];
    
    //点击隐藏键盘
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    tap.delegate = self;
    
    //设置密码显示格式
    self.passwordTF.secureTextEntry = YES;
}

-(AppDelegate *)app
{
    
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

//如果是添加账号，则需要返回按钮
-(void)createBackButton
{
    if (self.app.user) {
        UIButton *btn = [MyUtil createBtnFrame:CGRectMake(0, 8, 30, 28) type:UIButtonTypeCustom bgImageName:@"myForum" title:nil target:self action:@selector(back)];
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:btn];
        self.navigationItem.leftBarButtonItem = item;
    }
}

-(void)back
{
    [self.app changeRootCtroller:YES];
}

-(Networking *)networking
{
    if (!_networking) {
        _networking = [[Networking alloc] init];
    }
    return _networking;
}

//隐藏键盘
-(void)dismissKeyboard {
    [self.view endEditing:YES];
    [self.passwordTF resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)Login:(id)sender {
    NSString *username = self.usernameTF.text;
    NSString *password = self.passwordTF.text;
    
//    NSString *username = @"023113102";
//    NSString *password = @"19940429";
    
    self.userId = username;
    self.userPassWord = password;
    
    //网络请求
    [self networkingRequest];
}


//HUD提示框
- (void)networkingRequest {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    self.hud = hud;
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        __weak loginViewController *weakSelf = self;
        
        //验证登陆的回调方法
        self.networking.requestFinish = ^(NSString *requestString,NSString *error){
            
            if (!error) {               //登录成功
                [weakSelf requestUserData];
            }else {                     //登录失败
                [weakSelf.hud hideAnimated:YES];
                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:weakSelf.navigationController.view animated:YES];
                hud.mode = MBProgressHUDModeText;
                hud.label.text = NSLocalizedString(error, @"HUD message title");
                hud.offset = CGPointMake(0.f, MBProgressMaxOffset);
                [hud hideAnimated:YES afterDelay:1.f];
            }
        };
        
        //验证登录是否成功
        [self.networking loginRequestWithUserName:self.userId password:self.userPassWord];
    });
}

//向服务器请求用户数据
-(void)requestUserData
{
    self.app.user = nil;//原来的user置为nil
    __weak loginViewController *weakSelf = self;
    self.networking.requestHtmlData = ^(NSData *gradeData,NSData *coursesData){
        AnalyzeGradeData *analyzeGrade = [[AnalyzeGradeData alloc] init];
        AnalyzeCourseData *analyzeCourses = [[AnalyzeCourseData alloc] init];
        [analyzeGrade analyzeGradeHtmlData:gradeData userId:weakSelf.userId userPassword:weakSelf.userPassWord];
        [analyzeCourses analyzeCoursesHtmlData:coursesData];
        
        //在主线程修改UI操作
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.hud hideAnimated:YES];
            [weakSelf.app changeRootCtroller:YES];
            
            //请求考试安排（耗时操作），后台处理
            [weakSelf.app requestSemesterIDAndStudentID:weakSelf.app.user];
        });
        
    };
    [self.networking requestUserDataWithType:RequestALlData];//请求所有的数据
}

@end

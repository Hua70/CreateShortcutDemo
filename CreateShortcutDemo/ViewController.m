//
//  ViewController.m
//  CreateShortcutDemo
//
//  Created by YWH on 15/6/10.
//  Copyright (c) 2015年 YWH. All rights reserved.
//http://www.open-open.com/code/view/1421907845515

#import "ViewController.h"
#import "HTTPServer.h"
@interface ViewController ()
{
    HTTPServer *_httpServer;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self initHttpServer];
//    [self createLinkWithDict];
    
    UIButton *createcutBtn = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    createcutBtn.backgroundColor = [UIColor orangeColor];
    [createcutBtn setTitle:@"创建快捷方式" forState:UIControlStateNormal];
    [createcutBtn addTarget:self action:@selector(createLinkWithDict) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:createcutBtn];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)initHttpServer
{
  
        
        //启动本地httpSever和服务器首页页面
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsPath = paths[0];
        self.webRootDir = [documentsPath stringByAppendingPathComponent:@"web"];
        BOOL isDirectory = YES;
        BOOL exsit = [[NSFileManager defaultManager] fileExistsAtPath:_webRootDir isDirectory:&isDirectory];
        if(!exsit){
            [[NSFileManager defaultManager] createDirectoryAtPath:_webRootDir withIntermediateDirectories:YES attributes:nil error:nil];
        }
        self.mainPage    = [NSString stringWithFormat:@"%@/web/index.html",documentsPath];
        
        
//        [DDLog addLogger:[DDTTYLogger sharedInstance]];
        
        _httpServer = [[HTTPServer alloc] init];
        [_httpServer setType:@"_http._tcp."];
        
        [_httpServer setDocumentRoot:_webRootDir];
        
        NSError *error;
        if([_httpServer start:&error])
        {
            NSLog(@"Started HTTP Server on port %hu", [_httpServer listeningPort]);
        }
        else
        {
            NSLog(@"Error starting HTTP Server: %@", error);
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];

}
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    if([[UIDevice currentDevice].systemVersion integerValue] >= 6.0){
        sleep(1);
    }else {
        sleep(2);
    }
    [_httpServer stop];
}
- (void)applicationWillEnterForeground:(UIApplication *)application
{
    NSError *error;
    if(![_httpServer isRunning]){
        if([_httpServer start:&error])
        {
            NSLog(@"Started HTTP Server on port %hu", [_httpServer listeningPort]);
        }
        else
        {
            NSLog(@"Error starting HTTP Server: %@", error);
        }
    }
    
}
- (void)createLinkWithDict
{
    NSString *filePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/yeweihua.mobileconfig"];
    
    NSString *savePath = [self.webRootDir stringByAppendingString:@"/yeweihua.mobileconfig"];
    NSMutableDictionary *profilesConfig = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
    [profilesConfig writeToFile:savePath atomically:YES];
    
    
    NSString *_serverHostName = [NSString stringWithFormat:@"%@:%hu",@"http://127.0.0.1",[_httpServer listeningPort]];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSError* errorLocal = nil;
        NSMutableURLRequest *requestLocal = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:_serverHostName]
                                                                         cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0f];
        [NSURLConnection sendSynchronousRequest:requestLocal returningResponse:nil error:&errorLocal];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (errorLocal == nil) {
                NSURL *pathUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",_serverHostName,@"/yeweihua.mobileconfig"]];
                if ([[UIApplication sharedApplication] canOpenURL:pathUrl]) {
                    [[UIApplication sharedApplication] openURL:pathUrl];
                }
            }else {
            }
        });
        
    });

}
@end

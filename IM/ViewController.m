//
//  ViewController.m
//  IM
//
//  Created by guozw on 14/11/24.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "ViewController.h"
#import "LoginProcedures.h"
#import "session.h"

@interface ViewController () <LoginProceduresDelegate> {
    LoginProcedures *m_lp;
    Session         *m_sess;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    m_lp = [[LoginProcedures alloc]init];
    m_lp.delegate = self;
    m_sess = [[Session alloc]init];
    [m_lp loginWithSession:m_sess UserId:@"gzw" pwd:@"8" timeout:30];


}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)loginProceduresWaitingSvrTime:(LoginProcedures *)proc {
    
}

- (void)loginProcedures:(LoginProcedures *)proc login:(BOOL)suc {
    
}

- (void)loginProcedures:(LoginProcedures *)proc recvPush:(BOOL)suc {
    
}

- (void)loginProceduresConnectFail:(LoginProcedures *)proc timeout:(BOOL)timeout error:(NSError *)error {
    
}

@end

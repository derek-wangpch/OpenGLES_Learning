//
//  BaseRenderViewController.m
//  OpenGLES_Learning
//
//  Created by Derek Wang on 17/6/2017.
//  Copyright © 2017 Derek Wang. All rights reserved.
//

#import "TriangleRenderViewController.h"
#import "OpenGLESView.h"
#import "TriangleRender.h"

@interface TriangleRenderViewController ()

@end

@implementation TriangleRenderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    TriangleRender *render = [TriangleRender new];
    OpenGLESView *glView = [[OpenGLESView alloc] initWithFrame:self.view.bounds render:render];
    self.view = glView;
    [glView startAnimating];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

//
//  NewTeapotViewController.m
//  OpenGLES_Learning
//
//  Created by Derek Wang on 19/6/2017.
//  Copyright © 2017 Derek Wang. All rights reserved.
//

#import "TeapotPhongViewController.h"
#import "TeapotRender.h"
#import "OpenGLESView.h"

@interface TeapotPhongViewController ()

@property (nonatomic) TeapotRender *teapotRender;
@property (nonatomic) OpenGLESView *glView;

@end

@implementation TeapotPhongViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.teapotRender = [TeapotRender new];
    self.glView = [[OpenGLESView alloc] initWithFrame:self.view.bounds render:self.teapotRender];
    self.view = _glView;

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapView:)];
    [self.view addGestureRecognizer:tap];
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

- (void)onTapView:(UITapGestureRecognizer *)tap {
    if (_glView.isAnimating) {
        [_glView stopAnimating];
    } else {
        [_glView startAnimating];
    }
}

- (void)dealloc {
    [self.glView stopAnimating];
}

@end

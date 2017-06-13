//
//  BaseViewController.m
//  OpenGLES_Learning
//
//  Created by Derek Wang on 11/6/2017.
//  Copyright © 2017 Derek Wang. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@property (nonatomic) EAGLContext *glContext;

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupGLContext];
    [self setupGLView];
    glEnable(GL_DEPTH_TEST);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Setup GLContext
- (void)setupGLContext {
    EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    if (context == nil) {
        context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    }
    if (context == nil) {
        NSLog(@"Error when setting up EAGLContext");
    }
    [EAGLContext setCurrentContext:context];
    self.glContext = context;
}

#pragma mark - Setup GLContext
- (void)setupGLView {
    GLKView *glv = (GLKView *)self.view;
    glv.context = self.glContext;
    glv.drawableDepthFormat = GLKViewDrawableDepthFormat16;
    // Multisampling is a form of antialiasing that smooths jagged edges, improving image quality in most 3D apps at the cost of using more memory and fragment processing time
    glv.drawableMultisample = GLKViewDrawableMultisample4X;
    glv.delegate = self;
}

@end

//
//  TriangleViewController.m
//  OpenGLES_Learning
//
//  Created by Derek Wang on 11/6/2017.
//  Copyright © 2017 Derek Wang. All rights reserved.
//

#import "TriangleViewController.h"

@interface TriangleViewController () {
    GLuint vao, vbo;
}

@property (nonatomic) GLKBaseEffect *effect;

@end

@implementation TriangleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.effect = [GLKBaseEffect new];

    [self makeTriangle];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)makeTriangle {
    Vertex attrArr[] =
    {
        {{-1, -1, 0}, {1, 0, 0}, {0, 0}},  //左上
        {{1, -1, 0}, {0, 1, 0}, {0, 0}},    //顶点
        {{0, 1, 0}, {0, 0, 1}, {0, 0}}    //左下
    };

    glGenVertexArraysOES(1, &vao);
    glBindVertexArrayOES(vao);

    // Generate buffer
    glGenBuffers(1, &vbo);
    // Bind buffer
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    // Copy Data from memory to GPU
    glBufferData(GL_ARRAY_BUFFER, sizeof(attrArr), attrArr, GL_STATIC_DRAW);

    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), (const GLvoid *) offsetof(Vertex, Position));

    glEnableVertexAttribArray(GLKVertexAttribColor);
    glVertexAttribPointer(GLKVertexAttribColor, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), (const GLvoid *) offsetof(Vertex, Color));

    glBindVertexArrayOES(0);
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
     [self drawTriangle];
}

#pragma mark - Draw the triangle
- (void)drawTriangle {
    // Clear the framebuffer
    glClearColor(0.0f, 0.0f, 0.1f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    float aspect = fabsf(self.view.bounds.size.width / self.view.bounds.size.height);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, 1.0f, 10.0f);
    self.effect.transform.projectionMatrix = projectionMatrix;

    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -6.0f);
    self.effect.transform.modelviewMatrix = modelViewMatrix;

    glBindVertexArrayOES(vao);
    [self.effect prepareToDraw];
    glDrawArrays(GL_TRIANGLES, 0, 3);
}

- (void)dealloc {
    glDeleteBuffers(1, &vbo);
    glDeleteVertexArraysOES(1, &vao);
}

@end

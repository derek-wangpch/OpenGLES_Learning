//
//  TeapotViewController.m
//  OpenGLES_Learning
//
//  Created by Derek Wang on 11/6/2017.
//  Copyright © 2017 Derek Wang. All rights reserved.
//

#import "TeapotViewController.h"
#import "teapot.h"

#define kTeapotScale		3.0

@interface TeapotViewController () {
    GLuint vao, vbo, vboN;
}

@property (nonatomic) GLKBaseEffect *effect;

@end

@implementation TeapotViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self makeTeapot];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)makeTeapot
{
    GLKBaseEffect *effect = [[GLKBaseEffect alloc] init];
    // material
    effect.material.ambientColor = GLKVector4Make(0.4, 0.8, 0.4, 1.0);
    effect.material.diffuseColor = GLKVector4Make(1.0, 1.0, 1.0, 1.0);
    effect.material.specularColor = GLKVector4Make(1.0, 1.0, 1.0, 1.0);
    effect.material.shininess = 100.0;
    // light0
    effect.light0.enabled = GL_TRUE;
    effect.light0.ambientColor = GLKVector4Make(0.2, 0.2, 0.2, 1.0);
    effect.light0.diffuseColor = GLKVector4Make(0.2, 0.7, 0.2, 1.0);
    effect.light0.position = GLKVector4Make(0.0, 0.0, 1.0, 0.0);

    GLuint vertexArray, vertexBuffer, normalBuffer;

    glGenVertexArraysOES(1, &vertexArray);
    glBindVertexArrayOES(vertexArray);

    // position
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(teapot_vertices), teapot_vertices, GL_STATIC_DRAW);

    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 0, BUFFER_OFFSET(0));

    // normal
    glGenBuffers(1, &normalBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, normalBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(teapot_normals), teapot_normals, GL_STATIC_DRAW);

    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 0, BUFFER_OFFSET(0));

    glBindVertexArrayOES(0);

    self.effect = effect;
    vao = vertexArray;
    vbo = vertexBuffer;
    vboN = normalBuffer;
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    [self drawTeapot];
}

- (void)drawTeapot {
    // Clear the framebuffer
    glClearColor(0.0f, 0.0f, 0.1f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    int	start = 0, i = 0;

    GLKMatrix4 modelView = GLKMatrix4MakeTranslation(0, 0, -4.0f);
    modelView = GLKMatrix4Scale(modelView, kTeapotScale, kTeapotScale, kTeapotScale);

    modelView = GLKMatrix4Rotate(modelView, GLKMathDegreesToRadians(30.0f), 1, 0, 0);

    float aspect = fabsf(self.view.bounds.size.width / self.view.bounds.size.height);

    GLKMatrix4 projectionMatrix = GLKMatrix4MakeOrtho(-1.0f, 1.0f, -1.0f/aspect, 1.0f/aspect, 0.0f, 10.0f);
    // rotate the camara for a better view
    //projectionMatrix = GLKMatrix4Rotate(projectionMatrix, DegreesToRadians(-30.0f), 0.0f, 1.0f, 0.0f);
    self.effect.transform.projectionMatrix = projectionMatrix;
    self.effect.transform.modelviewMatrix = modelView;

    // draw the teapot
    glBindVertexArrayOES(vao);
    [self.effect prepareToDraw];

    while(i < num_teapot_indices) {
        if(teapot_indices[i] == -1) {
            glDrawElements(GL_TRIANGLE_STRIP, i - start, GL_UNSIGNED_SHORT, &teapot_indices[start]);
            start = i + 1;
        }
        i++;
    }
    if(start < num_teapot_indices)
        glDrawElements(GL_TRIANGLE_STRIP, i - start - 1, GL_UNSIGNED_SHORT, &teapot_indices[start]);
}

- (void)dealloc {
    glDeleteBuffers(1, &vbo);
    glDeleteBuffers(1, &vboN);
    glDeleteVertexArraysOES(1, &vao);
}

@end

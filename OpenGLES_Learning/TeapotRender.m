//
//  TeapotRender.m
//  OpenGLES_Learning
//
//  Created by Derek Wang on 18/6/2017.
//  Copyright © 2017 Derek Wang. All rights reserved.
//

#import "TeapotRender.h"
#import "ShaderUtil.h"
#import "teapot.h"
#import "BaseStructs.h"

#define kTeapotScale		4.0

@interface  TeapotRender() {
    GLuint          _program;
    GLuint          vao, vbo, normalBuffer, indexBuffer;
    GLuint          uProjectionMatrix, uModelViewMatrix, uNormalMatrix;
    GLuint          vao2, vbo2;
    GLfloat         rotate;
}

@end

@implementation TeapotRender

- (void)setup {
    [super setup];
    rotate = 30.0f;
    [self loadShaders];
    [self setupVertexData];
}

- (void)loadShaders {
    const char *vshFile = [[[NSBundle mainBundle] pathForResource:@"PhongShader" ofType:@"vsh"] cStringUsingEncoding:NSASCIIStringEncoding];
    const char *fshFile = [[[NSBundle mainBundle] pathForResource:@"PhongShader" ofType:@"fsh"] cStringUsingEncoding:NSASCIIStringEncoding];
    _program = loadShaders(vshFile, fshFile);
    glUseProgram(_program);

    uProjectionMatrix = glGetUniformLocation(_program, "uProjectionMatrix");
    uModelViewMatrix = glGetUniformLocation(_program, "uModelViewMatrix");
    uNormalMatrix = glGetUniformLocation(_program, "uNormalMatrix");

    // Setup eye position, which is at origin
    GLfloat eyePos[3] = {0,0,0};
    GLuint uEyePos = glGetUniformLocation(_program, "uEyePos");
    glUniform3fv(uEyePos, 1, eyePos);
}

- (void)setupVertexData {
    glGenVertexArraysOES(1, &vao);
    glBindVertexArrayOES(vao);

    // position
    glGenBuffers(1, &vbo);
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    glBufferData(GL_ARRAY_BUFFER, sizeof(teapot_vertices), teapot_vertices, GL_STATIC_DRAW);

    GLuint posSlot = glGetAttribLocation(_program, "aPosition");

    glVertexAttribPointer(posSlot, 3, GL_FLOAT, GL_FALSE, 0, BUFFER_OFFSET(0));
    glEnableVertexAttribArray(posSlot);

    // normal
    glGenBuffers(1, &normalBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, normalBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(teapot_normals), teapot_normals, GL_STATIC_DRAW);

    GLuint normalSlot = glGetAttribLocation(_program, "aNormal");
    glVertexAttribPointer(normalSlot, 3, GL_FLOAT, GL_FALSE, 0, BUFFER_OFFSET(0));
    glEnableVertexAttribArray(normalSlot);

    glBindVertexArrayOES(0);
}

- (void)renderContent {
    glClearColor(0.0f, 0.0f, 0.1f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glViewport(0, 0, self.renderWidth, self.renderHeight);

    glUseProgram(_program);
    glBindVertexArrayOES(vao);

    GLKMatrix4 modelView = GLKMatrix4MakeTranslation(0, 0, -2.0f);
    modelView = GLKMatrix4Scale(modelView, kTeapotScale, kTeapotScale, kTeapotScale);
    rotate += 1.0f;
    modelView = GLKMatrix4Rotate(modelView, GLKMathDegreesToRadians(rotate), 1, 0, 0);
    float aspect = fabsf((GLfloat)self.renderWidth / self.renderHeight);

    GLKMatrix4 projectionMatrix = GLKMatrix4MakeOrtho(-1.0f, 1.0f, -1.0f/aspect, 1.0f/aspect, 0.0f, 10.0f);

    glUniformMatrix4fv(uProjectionMatrix, 1, GL_FALSE, projectionMatrix.m);
    glUniformMatrix4fv(uModelViewMatrix, 1, GL_FALSE, modelView.m);

    bool invertible = true;
    GLKMatrix4 normalMatrix = GLKMatrix4InvertAndTranspose(modelView, &invertible);
    if (invertible) {
        glUniformMatrix4fv(uNormalMatrix, 1, GL_FALSE, normalMatrix.m);
    }

    int	start = 0, i = 0;
    while(i < num_teapot_indices) {
        if(teapot_indices[i] == -1) {
            GLvoid *indices = &teapot_indices[start];
            glDrawElements(GL_TRIANGLE_STRIP, i - start, GL_UNSIGNED_SHORT, indices);
            start = i + 1;
        }
        i++;
    }
    if(start < num_teapot_indices)
        glDrawElements(GL_TRIANGLE_STRIP, i - start - 1, GL_UNSIGNED_SHORT, &teapot_indices[start]);
}


- (void)dealloc {
    glDeleteProgram(_program);
    [self destroyVAO:vao];
}

@end

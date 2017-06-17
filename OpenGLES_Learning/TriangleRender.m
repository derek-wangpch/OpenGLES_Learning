//
//  TriangleRender.m
//  OpenGLES_Learning
//
//  Created by Derek Wang on 17/6/2017.
//  Copyright © 2017 Derek Wang. All rights reserved.
//

#import "TriangleRender.h"
#import "ShaderUtil.h"
#import "BaseStructs.h"
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import <GLKit/GLKit.h>

@interface  TriangleRender() {
    GLuint          _program;
    GLuint          vao, vbo;
    GLfloat         rotationZ;
}

@end

@implementation TriangleRender

- (void)setup {
    [self loadShaders];
    [self makeTriangle];
}

- (void)loadShaders {
    const char *vshFile = [[[NSBundle mainBundle] pathForResource:@"shader" ofType:@"vsh"] cStringUsingEncoding:NSASCIIStringEncoding];
    const char *fshFile = [[[NSBundle mainBundle] pathForResource:@"shader" ofType:@"fsh"] cStringUsingEncoding:NSASCIIStringEncoding];
    _program = loadShaders(vshFile, fshFile);
    glUseProgram(_program);
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

    GLuint posSlot = glGetAttribLocation(_program, "position");
    glVertexAttribPointer(posSlot, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), (const GLvoid *) offsetof(Vertex, Position));
    glEnableVertexAttribArray(posSlot);

    GLuint colorSlot = glGetAttribLocation(_program, "color");
    glVertexAttribPointer(colorSlot, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), (const GLvoid *) offsetof(Vertex, Color));
    glEnableVertexAttribArray(colorSlot);

    glBindVertexArrayOES(0);
}


- (void)render {
    glClearColor(0.0f, 0.0f, 0.1f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    glViewport(0, 0, self.renderWidth, self.renderHeight);

    rotationZ += 1.0f;

    float aspect = fabsf((GLfloat)self.renderWidth / self.renderHeight);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, 1.0f, 10.0f);

    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -6.0f);

    modelViewMatrix = GLKMatrix4RotateZ(modelViewMatrix, GLKMathDegreesToRadians(rotationZ));

    GLuint projectionSlot = glGetUniformLocation(_program, "projectionMatrix");
    GLuint modelViewSlot = glGetUniformLocation(_program, "modelViewMatrix");
    glUniformMatrix4fv(projectionSlot, 1, GL_FALSE,projectionMatrix.m);
    glUniformMatrix4fv(modelViewSlot, 1, GL_FALSE, modelViewMatrix.m);

    glBindVertexArrayOES(vao);
    //[self setupVertexData];
    glDrawArrays(GL_TRIANGLES, 0, 3);
}

- (void)dealloc {
    glDeleteBuffers(1, &vbo);
    glDeleteVertexArraysOES(1, &vao);
    glDeleteProgram(_program);
}

@end

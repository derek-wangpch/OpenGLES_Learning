//
//  ShaderUtil.c
//  OpenGLES_Learning
//
//  Created by Derek Wang on 14/6/2017.
//  Copyright © 2017 Derek Wang. All rights reserved.
//

#include "ShaderUtil.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct ShaderSourceStruct{
    GLchar *string;

    GLsizei byteSize;

    GLenum  shaderType;
} ShaderSource;

GLuint compileShader(ShaderSource *source);

ShaderSource *loadShaderSource(const char *fileName) {
    ShaderSource *source = (ShaderSource *)calloc(sizeof(ShaderSource), 1);

    const char *suffixBegin = fileName + strlen(fileName) - 4;

    if (0 == strncmp(suffixBegin, ".fsh", 4)) {
        source->shaderType = GL_FRAGMENT_SHADER;
    } else if (0 == strncmp(suffixBegin, ".vsh", 4)) {
        source->shaderType = GL_VERTEX_SHADER;
    } else {
        source->shaderType = 0;
    }

    FILE* curFile = fopen(fileName, "r");

    // Get the size of the source
    fseek(curFile, 0, SEEK_END);
    long fileSize = ftell (curFile);

    // Add 1 to the file size to include the null terminator for the string
    source->byteSize =  (GLsizei)fileSize + 1;

    // Alloc memory for the string
    source->string = malloc(source->byteSize);

    // Read entire file into the string from beginning of the file
    fseek(curFile, 0, SEEK_SET);
    fread(source->string, 1, fileSize, curFile);

    fclose(curFile);

    // Insert null terminator
    source->string[fileSize] = 0;

    return source;
}

void destroySource(ShaderSource *source) {
    free(source->string);
    free(source);
}

GLuint loadShaders(const char *vertexShader, const char *fragShader) {
    GLuint prgName = glCreateProgram();

    ShaderSource *vertexSource = loadShaderSource(vertexShader);
    GLuint vsh = compileShader(vertexSource);
    if (vsh == 0) {
        destroySource(vertexSource);
        return 0;
    }

    ShaderSource *fragSource = loadShaderSource(fragShader);
    GLuint fsh = compileShader(fragSource);
    if (fsh == 0) {
        destroySource(fragSource);
        return 0;
    }

    // Attach the fragment shader to our program
    glAttachShader(prgName, vsh);
    glAttachShader(prgName, fsh);

    // Delete the fragment shader since it is now attached
    // to the program, which will retain a reference to it
    glDeleteShader(vsh);
    glDeleteShader(fsh);

    //////////////////////
    // Link the program //
    //////////////////////

    GLint logLength, status;
    glLinkProgram(prgName);
    glGetProgramiv(prgName, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar*)malloc(logLength);
        glGetProgramInfoLog(prgName, logLength, &logLength, log);
        printf("Program link log:\n%s\n", log);
        free(log);
    }

    glGetProgramiv(prgName, GL_LINK_STATUS, &status);
    if (status == 0)
    {
        printf("Failed to link program");
        return 0;
    }

    glValidateProgram(prgName);

    glGetProgramiv(prgName, GL_VALIDATE_STATUS, &status);
    if (status == 0)
    {
        // 'status' set to 0 here does NOT indicate the program itself is invalid,
        //   but rather the state OpenGL was set to when glValidateProgram was called was
        //   not valid for this program to run (i.e. Given the CURRENT openGL state,
        //   draw call with this program will fail).  You may still be able to use this
        //   program if certain OpenGL state is set before a draw is made.  For instance,
        //   'status' could be 0 because no VAO was bound and so long as one is bound
        //   before drawing with this program, it will not be an issue.
        printf("Program cannot run with current OpenGL State");
    }

    glGetProgramiv(prgName, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar*)malloc(logLength);
        glGetProgramInfoLog(prgName, logLength, &logLength, log);
        printf("Program validate log:\n%s\n", log);
        free(log);
    }


    return prgName;
}

// Compile shader source
GLuint compileShader(ShaderSource *source) {
    GLuint shader = glCreateShader(source->shaderType);

    const GLchar *sourceString = source->string;

    glShaderSource(shader, 1, (const GLchar **)(&sourceString), NULL);
    glCompileShader(shader);

    GLint logLength, status;

    glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &logLength);

    if (logLength > 0)
    {
        GLchar *log = (GLchar*) malloc(logLength);
        glGetShaderInfoLog(shader, logLength, &logLength, log);
        printf("Vtx Shader compile log:%s\n", log);
        free(log);
    }

    glGetShaderiv(shader, GL_COMPILE_STATUS, &status);
    if (status == 0)
    {
        printf("Failed to compile vtx shader:\n%s\n", sourceString);
        return 0;
    }

    return shader;
}

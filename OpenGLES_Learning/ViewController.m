//
//  ViewController.m
//  OpenGLES_Learning
//
//  Created by Derek Wang on 10/6/2017.
//  Copyright © 2017 Derek Wang. All rights reserved.
//

#import "ViewController.h"
#import "teapot.h"

#define kTeapotScale		3.0
#define	DegreesToRadians(x) ((x) * M_PI / 180.0)
#define kCircleSegments     36
#define kInnerCircleRadius	1.0

typedef struct
{
     __unsafe_unretained GLKBaseEffect *effect;
    GLuint vertexArray;
    GLuint vertexBuffer;
    GLuint normalBuffer;

} BaseEffect;

const Vertex Vertices[] = {
    {{1, -1, 0}, {1, 0, 0, 1}},
    {{1, 1, 0}, {0, 1, 0, 1}},
    {{-1, 1, 0}, {0, 0, 1, 1}},
    {{-1, -1, 0}, {0, 0, 0, 1}}
};

const GLubyte Indices[] = {
    0, 1, 2,
    2, 3, 0
};


@interface TestViewController () {
    BaseEffect teapot;

    // teapot
    GLfloat rot;

    // Circle
    BaseEffect circleObj;

    GLuint _vertexArray;
    GLuint _vertexBuffer;
    GLuint _indexBuffer;
    float _rotation;
}

@property (nonatomic) EAGLContext *glContext;
@property (nonatomic) GLuint shaderProgram;

@property (nonatomic) GLuint triangleVAO;
@property (nonatomic) GLKBaseEffect * teapotEffect;
@property (nonatomic) GLKBaseEffect *circleEffect;

@property (nonatomic) GLKBaseEffect *triangleEffect;

@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //[self setupShaders];

    [self makeTeapot];
    [self makeCircle:&circleObj withNumOfSegments:kCircleSegments radius:kInnerCircleRadius];

    self.triangleEffect = [[GLKBaseEffect alloc] init];
    [self makeTriangle];
    [self makeCube];
}

- (void)makeCube {
    glGenVertexArraysOES(1, &_vertexArray);
    glBindVertexArrayOES(_vertexArray);

    glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(Vertices), Vertices, GL_STATIC_DRAW);

    glGenBuffers(1, &_indexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(Indices), Indices, GL_STATIC_DRAW);

    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), (const GLvoid *) offsetof(Vertex, Position));
    glEnableVertexAttribArray(GLKVertexAttribColor);
    glVertexAttribPointer(GLKVertexAttribColor, 4, GL_FLOAT, GL_FALSE, sizeof(Vertex), (const GLvoid *) offsetof(Vertex, Color));

    glEnableVertexAttribArray(0);
}

- (void)setupShaders {
    NSString* vertFile = [[NSBundle mainBundle] pathForResource:@"shader" ofType:@"vsh"];
    NSString* fragFile = [[NSBundle mainBundle] pathForResource:@"shader" ofType:@"fsh"];
    self.shaderProgram = [self loadShaders:vertFile frag:fragFile];

    glLinkProgram(self.shaderProgram);
    GLint linkResult;
    glGetProgramiv(self.shaderProgram, GL_LINK_STATUS, &linkResult);

    if (linkResult == GL_FALSE) {
        GLchar messages[256];
        glGetProgramInfoLog(self.shaderProgram, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"error%@", messageString);
        return;
    }
    glUseProgram(self.shaderProgram);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (GLuint)loadShaders:(NSString *)vert frag:(NSString *)frag {
    GLuint verShader, fragShader;
    GLuint program = glCreateProgram();

    [self compileShader:&verShader type:GL_VERTEX_SHADER file:vert];
    [self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:frag];

    glDeleteShader(verShader);
    glDeleteShader(fragShader);

    return program;
}


- (void)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file {
    NSString *content = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil];
    const GLchar *souce = (GLchar *)[content UTF8String];
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &souce, NULL);
    glCompileShader(*shader);
}

#pragma mark - Make a triangle
- (void)makeTriangle {
    Vertex attrArr[] =
    {
        {{-1, -1, 0}, {1, 0, 0, 1}},  //左上
        {{1, -1, 0}, {0, 1, 0, 1}},    //顶点
        {{0, 1, 0}, {0, 0, 1, 1}}    //左下
    };

    GLuint vao;

    glGenVertexArraysOES(1, &vao);
    glBindVertexArrayOES(vao);

    // 生成buffer
    GLuint vbo;
    glGenBuffers(1, &vbo);
    // bind为当前buffer
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    // 将数据copy到GPU
    glBufferData(GL_ARRAY_BUFFER, sizeof(attrArr), attrArr, GL_STATIC_DRAW);

    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), (const GLvoid *) offsetof(Vertex, Position));

    glEnableVertexAttribArray(GLKVertexAttribColor);
    glVertexAttribPointer(GLKVertexAttribColor, 4, GL_FLOAT, GL_FALSE, sizeof(Vertex), (const GLvoid *) offsetof(Vertex, Color));

    glBindVertexArrayOES(0);

    self.triangleVAO = vao;
}

#pragma mark - Draw the cube
- (void)drawCube {
    glClearColor(0.0f, 0.0f, 0.1f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    float aspect = fabsf(self.view.bounds.size.width / self.view.bounds.size.height);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, 4.0f, 10.0f);
    self.triangleEffect.transform.projectionMatrix = projectionMatrix;

    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -6.0f);
    modelViewMatrix = GLKMatrix4RotateY(modelViewMatrix, GLKMathDegreesToRadians(45));

    self.triangleEffect.transform.modelviewMatrix = modelViewMatrix;

    glBindVertexArrayOES(_vertexArray);
    [self.triangleEffect prepareToDraw];
    glDrawElements(GL_TRIANGLES, sizeof(Indices)/sizeof(Indices[0]), GL_UNSIGNED_BYTE, 0);
}

#pragma mark - Draw the triangle
- (void)drawTriangle {
    // Clear the framebuffer
    glClearColor(0.0f, 0.0f, 0.1f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    float aspect = fabsf(self.view.bounds.size.width / self.view.bounds.size.height);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, 1.0f, 10.0f);
    self.triangleEffect.transform.projectionMatrix = projectionMatrix;

    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -6.0f);
//    modelViewMatrix = GLKMatrix4RotateZ(modelViewMatrix, GLKMathDegreesToRadians(45));
    self.triangleEffect.transform.modelviewMatrix = modelViewMatrix;

    glBindVertexArrayOES(_triangleVAO);
    [self.triangleEffect prepareToDraw];
    glDrawArrays(GL_TRIANGLES, 0, 3);
}

#pragma mark - GLKViewDelegate
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    if (false) {
        [self drawCube];
    } else {
        [self drawTriangle];
        [self drawTeapot];
    }
}

- (void)testDraw {
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClearDepthf(1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    // set the projection matrix
    //_teapotEffect.transform.projectionMatrix = projectionMatrix;
    [self drawTeapot];
}

- (void)testDrawCircle {
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClearDepthf(1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    glBindVertexArrayOES(circleObj.vertexArray);
    [circleObj.effect prepareToDraw];
    glDrawArrays (GL_LINE_LOOP, 0, kCircleSegments);
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

    self.teapotEffect = effect;
    teapot.effect = effect;
    teapot.vertexArray = vertexArray;
    teapot.vertexBuffer = vertexBuffer;
    teapot.normalBuffer = normalBuffer;
}

- (void)makeCircle:(BaseEffect *)circle withNumOfSegments:(GLint)segments radius:(GLfloat)radius
{
    GLfloat vertices[kCircleSegments*3];
    GLint count = 0;
    for (GLfloat i = 0; i < 360.0f; i += 360.0f/segments)
    {
        vertices[count++] = (sin(DegreesToRadians(i))*radius);									//x
        vertices[count++] = (cos(DegreesToRadians(i))*radius);	//y
        vertices[count++] = 0;	//z
    }

    GLKBaseEffect *effect = [[GLKBaseEffect alloc] init];
    effect.useConstantColor = GL_TRUE;
    effect.constantColor = GLKVector4Make(0.2f, 0.7f, 0.2f, 1.0f);

    GLuint vertexArray, vertexBuffer;

    glGenVertexArraysOES(1, &vertexArray);
    glBindVertexArrayOES(vertexArray);

    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);

    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 0, BUFFER_OFFSET(0));

    glBindVertexArrayOES(0);

    self.circleEffect = effect;
    circle->effect = effect;
    circle->vertexArray = vertexArray;
    circle->vertexBuffer = vertexBuffer;
    circle->normalBuffer = 0;
}

- (void)drawTeapot {
    int	start = 0, i = 0;

    // move clockwise along the circle
    GLKMatrix4 modelView = GLKMatrix4MakeTranslation(0, 0, -4.0f);
    modelView = GLKMatrix4Scale(modelView, kTeapotScale, kTeapotScale, kTeapotScale);

    //GLKMatrix4 modelView = GLKMatrix4MakeTranslation(0, 0, -4.0f);

    //modelView = GLKMatrix4Rotate(modelView, -M_PI_2, 0, 0, 1); //we want to display in landscape mode
    modelView = GLKMatrix4Rotate(modelView, DegreesToRadians(60.0f), 1, -1, 0);
    //modelView = GLKMatrix4Rotate(modelView, DegreesToRadians(60.0f), 1, 0, 0);

    float aspect = fabsf(self.view.bounds.size.width / self.view.bounds.size.height);
//    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, 4.0f, 10.0f);
//    _teapotEffect.transform.projectionMatrix = projectionMatrix;

    GLKMatrix4 projectionMatrix = GLKMatrix4MakeOrtho(-1.0f, 1.0f, -1.0f/aspect, 1.0f/aspect, 0.0f, 10.0f);
    // rotate the camara for a better view
    //projectionMatrix = GLKMatrix4Rotate(projectionMatrix, DegreesToRadians(-30.0f), 0.0f, 1.0f, 0.0f);
    _teapotEffect.transform.projectionMatrix = projectionMatrix;

    _teapotEffect.transform.modelviewMatrix = modelView;

    // draw the teapot
    glBindVertexArrayOES(teapot.vertexArray);
    [_teapotEffect prepareToDraw];

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
    if ([EAGLContext currentContext] == _glContext) {
        [EAGLContext setCurrentContext:nil];
    }
    glDeleteBuffers(1, &_vertexBuffer);
    glDeleteBuffers(1, &_indexBuffer);
}

/*
- (void)update {
    float aspect = fabsf(self.view.bounds.size.width / self.view.bounds.size.height);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, 4.0f, 10.0f);
    circleObj.effect.transform.projectionMatrix = projectionMatrix;

    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -6.0f);
    _rotation += 90 * self.timeSinceLastUpdate;
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, GLKMathDegreesToRadians(25), 1, 0, 0);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, GLKMathDegreesToRadians(0), 0, 1, 0);
    circleObj.effect.transform.modelviewMatrix = modelViewMatrix;

    //_teapotEffect.transform.modelviewMatrix = modelViewMatrix;
}
*/

@end

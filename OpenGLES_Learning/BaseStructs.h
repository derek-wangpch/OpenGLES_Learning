//
//  BaseStructs.h
//  OpenGLES_Learning
//
//  Created by Derek Wang on 12/6/2017.
//  Copyright © 2017 Derek Wang. All rights reserved.
//

#ifndef BaseStructs_h
#define BaseStructs_h

#define BUFFER_OFFSET(i) ((float *)NULL + (i))

typedef struct {
    float Position[3];
    float Color[3];
    float TexCoord[2];
} Vertex;



#endif /* BaseStructs_h */

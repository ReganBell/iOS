//
//  FastTokenizer.m
//  Coursica
//
//  Created by Regan Bell on 7/14/15.
//  Copyright (c) 2015 Prestige Worldwide. All rights reserved.
//

#import "FastTokenizer.h"

@implementation FastTokenizer

+ (NSArray*)tokensFromString:(NSString*)field {
    
    NSMutableArray *fastFieldTerms = [NSMutableArray array];
    NSMutableString *currentString = [NSMutableString string];
    const char *primitiveField = field.UTF8String;
    char primitiveBuffer[field.length];
    char *primitiveString = &primitiveBuffer;
    int tokenIndex = 0;
    for (int i = 0; i < field.length; i++) {
        char character = tolower(primitiveField[i]);
        
        if (character == ':' || character == ',' || character == '"' || character == '?' || character == '&' || character == '(' || character == ')'
            || character == '!' || character == '\'') {
            continue;
        }
        
        if (character == '.' || character == ' ') {
            if (i + 1 < field.length) {
                char next = primitiveField[i+1];
                if (next == ' ') {
                    if (currentString.length) {
                        [fastFieldTerms addObject:currentString];
                    }
                    currentString = [NSMutableString string];
                    i++;
                    continue;
                }
                if (next == '.') {
                    continue;
                }
            }
        }
        
        if (character == ' ' || character == '/' || character == '-') {
            int length = tokenIndex;
            char *token = calloc(length, 1);
            strncpy(token, primitiveString, length);
            NSString *tokenString = [NSString stringWithUTF8String:token];
            if (tokenString.length) {
                [fastFieldTerms addObject:tokenString];
            }
            free(token);
            tokenIndex = 0;
            continue;
        }
        primitiveString[tokenIndex] = character;
        tokenIndex++;
        
        if (i == field.length - 1) {
            int length = tokenIndex;
            char *token = calloc(length, 1);
            strncpy(token, primitiveString, length);
            NSString *tokenString = [NSString stringWithUTF8String:token];
            if (tokenString.length) {
                [fastFieldTerms addObject:tokenString];
            }
            free(token);
            tokenIndex = 0;
        }
    }
    int length = tokenIndex;
    if (length) {
        char *token = calloc(length, 1);
        strncpy(token, primitiveString, length);
        [fastFieldTerms addObject:[NSString stringWithUTF8String:token]];
    }
    return [NSArray arrayWithArray:fastFieldTerms];
}

@end

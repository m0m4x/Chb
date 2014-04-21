//
//  GetData.h
//  Chb
//
//  Created by Massimo on 4/20/14.
//  Copyright (c) 2014 Massimo Zanini. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GetData : NSObject

@property UIView *loading;
@property UIActivityIndicatorView *indicator;

-(void) loadResources:(NSArray*)resources completion:(void (^)(void))completionBlock;

-(NSString*) getPathFor:(NSString*)file fileType:(NSString*)file_type initRes:(bool)onlineUpdate;

@end

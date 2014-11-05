//
//  FileDownloadInfo.m
//  BGTransferDemo
//
//  Created by Gabriel Theodoropoulos on 25/3/14.
//  Copyright (c) 2014 Appcoda. All rights reserved.
//

#import "FileDownloadInfo.h"

@implementation FileDownloadInfo

-(id)initWithFileTitle:(NSString *)title
     andDownloadSource:(NSString *)source
               atLocal:(NSString *)local
          withPartFile:(NSString *)part {
    
    if (self == [super init]) {
        self.fileTitle = title;
        self.fileName = [source lastPathComponent];
        
        //source
        self.localSource = local;
        self.downloadSource = source;
        
        //status
        self.isAvailable = NO;
        self.isPaused = NO;
        self.isDownloading = NO;
        
        //progress data
        self.taskProgress = 0.0;
        
        //resume data
        if(part!=nil){
            self.isPaused = YES;
            self.taskResumeData = [NSData dataWithContentsOfFile:part];
            //dati info
            NSDictionary *info = [NSDictionary dictionaryWithContentsOfFile:
                                  [[part stringByDeletingPathExtension] stringByAppendingPathExtension:@"info"] ];
            self.taskProgress = [[info valueForKey:@"taskProgress"] doubleValue];
        }
        
        //available
        if (local != nil){
            self.isAvailable = YES;
        }
    }
    
    return self;
}

-(id)initFromLocal:(NSString *)source{
    if (self == [super init]) {
        self.fileTitle = [[source lastPathComponent] stringByDeletingPathExtension];
        
        self.localSource = source;
        self.isAvailable = YES;
        
        //se online
        self.downloadSource = nil;
        self.taskProgress = 0.0;
        self.isDownloading = NO;
    }
    
    return self;
}

@end

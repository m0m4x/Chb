//
//  FileDownloadInfo.h
//  BGTransferDemo
//
//  Created by Gabriel Theodoropoulos on 25/3/14.
//  Copyright (c) 2014 Appcoda. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileDownloadInfo : NSObject

@property (nonatomic, strong) NSString *fileTitle;
@property (nonatomic, strong) NSString *fileName;

@property (nonatomic, strong) NSString *localSource;

@property (nonatomic, strong) NSString *downloadSource;

@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;

@property (nonatomic, strong) NSData *taskResumeData;

@property (nonatomic) double taskProgress;

@property (nonatomic) BOOL isAvailable;
@property (nonatomic) BOOL isDownloading;
@property (nonatomic) BOOL isPaused;


-(id)initWithFileTitle:(NSString *)title
     andDownloadSource:(NSString *)source
               atLocal:(NSString *)local
          withPartFile:(NSString *)part;
-(id)initFromLocal:(NSString *)LocalPath;
@end

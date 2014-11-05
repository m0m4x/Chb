//
//  TSPURLSessionDelegate.m
//  Chb
//
//  Created by max on 05/11/14.
//  Copyright (c) 2014 Massimo Zanini. All rights reserved.
//

#import "URLSessionDelegate.h"

#import "TSPBilViewController.h"

@interface URLSessionDelegate ()

@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) TSPBilViewController *parent;
@end



@implementation URLSessionDelegate

/*-(void)setNewDelegate:(id *)BilVC {
    self.BilViewController = (TSPBilViewController*) BilVC;
}*/

#pragma mark - NSURLSession Delegate method implementation

- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error
{
    NSLog(@"> didBecomeInvalidWithError (t.%@) %@", [NSThread currentThread], [error description]);
    
    /*
    if (error)
    {
        
        
    }
    
    if ([session isEqual:_session])
    {
        //self.session = nil;
    }*/
}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location{
    NSLog(@"> didFinishDownloadingToURL (t.%@)", [NSThread currentThread]);
    /*
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *destinationFilename = downloadTask.originalRequest.URL.lastPathComponent;
    NSURL *destinationURL = [self.docDirectoryURL URLByAppendingPathComponent:destinationFilename];
    
    if ([fileManager fileExistsAtPath:[destinationURL path]]) {
        [fileManager removeItemAtURL:destinationURL error:nil];
    }
    
    BOOL success = [fileManager copyItemAtURL:location
                                        toURL:destinationURL
                                        error:&error];
    
    if (success) {
        // Change the flag values of the respective FileDownloadInfo object.
        int index = [self getFileDownloadInfoIndexWithTaskIdentifier:downloadTask.taskIdentifier];
        int index2 = [self getFileDownloadInfoIndexWithURL:[downloadTask.currentRequest.URL absoluteString]];
        FileDownloadInfo *fdi = [self.arrFileDownloadData objectAtIndex:index2];
        
        fdi.isPaused = NO;
        fdi.isDownloading = NO;
        fdi.isAvailable = YES;
        
        // Set the initial value to the taskIdentifier property of the fdi object,
        // so when the start button gets tapped again to start over the file download.
        //fdi.taskIdentifier = -1;
        
        // In case there is any resume data stored in the fdi object, just make it nil.
        fdi.taskResumeData = nil;
        
        // Rimuovi file di resume
        //[self removeDownloadPartData:fdi];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            // Reload the respective table view row using the main thread.
            [self.tblFiles reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index2 inSection:0]]
                                 withRowAnimation:UITableViewRowAnimationNone];
            
        }];
        
    }
    else{
        NSLog(@"Unable to copy temp file. Error: %@", [error localizedDescription]);
    }*/
    
}


-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    NSLog(@"> didCompleteWithError (t.%@) ",  [NSThread currentThread]);
    /*
    if (error != nil) {
        NSDictionary *info = [error userInfo];
        NSLog(@"Download completed with error: %@", [error localizedDescription]);
        
        / *if(![[error localizedDescription] isEqualToString:@"cancelled"]){
         [[NSOperationQueue mainQueue] addOperationWithBlock:^{
         //RESTART Download using the main thread.
         int index = [self getFileDownloadInfoIndexWithTaskIdentifier:task.taskIdentifier];
         FileDownloadInfo *fdi = [self.arrFileDownloadData objectAtIndex:index];
         
         if (!fdi.isDownloading){
         // providing the appropriate URL as the download source.
         fdi.downloadTask = [self.session downloadTaskWithURL:[NSURL URLWithString:fdi.downloadSource]];
         
         // Keep the new task identifier.
         fdi.taskIdentifier = fdi.downloadTask.taskIdentifier;
         
         // Change the isDownloading property value.
         fdi.isDownloading = YES;
         
         // Start the task.
         [fdi.downloadTask resume];
         }
         }];
         } * /
    }
    else{
        NSLog(@"Download finished successfully.");
    }*/
}


-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    NSLog(@"> updateProgress task:%lu (t.%@) [%@]", downloadTask.taskIdentifier, [NSThread currentThread], self.id);
    
    [self.delegate updateProgress];
    
    /*
    //self.session.delegateQueue
    
    if (totalBytesExpectedToWrite == NSURLSessionTransferSizeUnknown) {
        NSLog(@"Unknown transfer size");
    }
    else{
        
        //dispatch_async(dispatch_get_main_queue(), ^{
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            // Locate the FileDownloadInfo object among all based on the taskIdentifier property of the task.
            int index = [self getFileDownloadInfoIndexWithTaskIdentifier:downloadTask.taskIdentifier];
            int index2 = [self getFileDownloadInfoIndexWithURL:[downloadTask.currentRequest.URL absoluteString]];
            
            //fdi.isDownloading =YES;
            NSLog(@"index: %i - %i",index,index2);
            
            //
            FileDownloadInfo *fdi = [self.arrFileDownloadData objectAtIndex:index2];
            
            //fdi.isDownloading =YES;
            NSLog(@"Task Identifier of seed line: %lu ",(unsigned long)fdi.downloadTask.taskIdentifier);
            
            
            // Calculate the progress.
            fdi.taskProgress = (double)totalBytesWritten / (double)totalBytesExpectedToWrite;
            NSIndexPath *CellIndexPath = [NSIndexPath indexPathForRow:index2 inSection:0];
            
            // Get the progress view of the appropriate cell and update its progress.
            UITableViewCell *cell = [self.tblFiles cellForRowAtIndexPath:CellIndexPath];
            UIProgressView *progressView = (UIProgressView *)[cell viewWithTag:CellProgressBarTagValue];
            progressView.progress = fdi.taskProgress;
            
            NSLog([NSString stringWithFormat:@"%f (%ld %ld)",fdi.taskProgress,(long)CellIndexPath.section,(long)CellIndexPath.row ]);
            
            // Reload the table view.
            //[self.tblFiles reloadData];
            [self.tblFiles reloadRowsAtIndexPaths:@[CellIndexPath] withRowAnimation:UITableViewRowAnimationNone];
            
        }];
        //});
    }*/
}


-(void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session{
    NSLog(@"> URLSessionDidFinishEventsForBackgroundURLSession (t.%@) %@", [NSThread currentThread], self.id);
    /*
    TSPAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    TSPAppDelegate *appaDelegate = self.session.delegate;
    
    // Check if all download tasks have been finished.
    [self.session getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        
        if ([downloadTasks count] == 0) {
            if (appDelegate.backgroundTransferCompletionHandler != nil) {
                // Copy locally the completion handler.
                void(^completionHandler)() = appDelegate.backgroundTransferCompletionHandler;
                
                // Make nil the backgroundTransferCompletionHandler.
                appDelegate.backgroundTransferCompletionHandler = nil;
                
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    // Call the completion handler to tell the system that there are no other background transfers.
                    completionHandler();
                    
                    // Show a local notification when all downloads are over.
                    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
                    localNotification.alertBody = @"All files have been downloaded!";
                    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
                }];
            }
        }
    }];*/
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes {
    
    NSLog(@"> didResumeAtOffset (t.%@) %@", [NSThread currentThread], self.id);
    
}


@end

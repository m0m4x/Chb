//
//  TSPBilViewController.m
//  Chb
//
//  Created by max on 31/10/14.
//  Copyright (c) 2014 Massimo Zanini. All rights reserved.
//

#import "TSPBilViewController.h"
#import "FileDownloadInfo.h"
#import "TSPAppDelegate.h"
#import "GetData.h"

#import "TSPPageViewController.h"
#import "PageViewController.h"

#import "FindUIViewController.h"

#import "URLSessionDelegate.h" 

// Define some constants regarding the tag values of the prototype cell's subviews.
#define CellLabelTagValue               10
#define CellStartPauseButtonTagValue    20
#define CellStopButtonTagValue          30
#define CellProgressBarTagValue         40
#define CellLabelReadyTagValue          50

@interface TSPBilViewController ()

@property GetData *dataObj;

@property (nonatomic, strong) NSString *id;

@property (nonatomic, strong) NSURLSession *session;

@property (nonatomic, strong) NSMutableArray *arrFileDownloadData;
@property (nonatomic, strong) NSURL *docDirectoryURL;
@property  NSArray *bilanci;

-(void)initializeFileDownloadDataArray;
-(int)getFileDownloadInfoIndexWithTaskIdentifier:(unsigned long)taskIdentifier;

-(void)saveDownloadPartData;

@end

@implementation TSPBilViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Oggetti
    self.dataObj = [GetData alloc];
    self.dataObj.loading = (UIView*) [self.view viewWithTag:50];
    self.dataObj.indicator = (UIActivityIndicatorView*) [self.view viewWithTag:60];
    
    UIImageView *bg = (UIImageView*) [self.view viewWithTag:3];
    UILabel *label_title = (UILabel *)[self.view viewWithTag:30];
    UIButton *button_back = (UIButton *)[self.view viewWithTag:5];

    
    //Title
    self.title= @"bilancio";
    label_title.text = @"bilancio";
    [bg setImage:[UIImage imageNamed:@"bg_bilancio.png"]];
    
    //Back Button
    [button_back setImage:[UIImage imageNamed:@"icon-back.png"] forState:UIControlStateNormal];

    
    // Do any additional setup after loading the view.
    NSArray *URLs = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    self.docDirectoryURL = [URLs objectAtIndex:0];
    
    // Make self the delegate and datasource of the table view.
    self.tblFiles.delegate = self;
    self.tblFiles.dataSource = self;
    
    // Enable scrolling in table view.
    self.tblFiles.scrollEnabled = YES;
    
    //Sessione per Download
    self.id = [self randomStringWithLength];
    NSLog(@"ID: %@",self.id);
    self.session = [self backgroundSession];

    
    //Caricamento Risorse (lista Bilanci)
    [self.dataObj loadResources:^{
        
        //Donwload bilanci.txt
        NSString *file = [self.dataObj getPathFor:@"bilanci" fileType:@"txt" checkOnline:YES];
        [self initializeFileDownloadDataArray:file];
        
        //Get downloadData
        //Get Current Tasks
        [self.session getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
            NSUInteger count = [dataTasks count] + [uploadTasks count] + [downloadTasks count];
            
            NSLog(@"NSURLSession restored: %lu",(unsigned long)count);
            
            /*for (NSURLSessionDownloadTask *task in downloadTasks) {
                
                double taskProgress = (double)task.countOfBytesReceived / (double)task.countOfBytesExpectedToReceive;
                
                int index = [self getFileDownloadInfoIndexWithURL:[task.originalRequest.URL absoluteString]];
                FileDownloadInfo *fdi = [self.arrFileDownloadData objectAtIndex:index];
                
                NSLog(@"task %lu: %ld %.0f/%.0f - %.2f%%", (unsigned long)task.taskIdentifier,[fdi.downloadTask state], (double)task.countOfBytesReceived, (double)task.countOfBytesExpectedToReceive, taskProgress*100);
                NSLog(@"mem task %lu: %.2f%%", (unsigned long)fdi.taskIdentifier , fdi.taskProgress*100);
                
                fdi.isDownloading = YES;
                fdi.downloadTask = task;
                fdi.taskProgress = taskProgress;
                // Keep the new task identifier.
                fdi.taskIdentifier = fdi.downloadTask.taskIdentifier;
                // Start the task.
                [fdi.downloadTask state ];
                
            }*/
        }];
        
        
        // Reload the table view.
        [self.tblFiles reloadData];
        
    }];
    
}

- (NSURLSession *)backgroundSession {
    NSLog(@"> backgroundSession(t.%@)", [NSThread currentThread]);
    
    NSURLSession *session = nil;
    /*static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{*/
        // Session Configuration
        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"it.chb.downloads"];
        sessionConfiguration.HTTPMaximumConnectionsPerHost = 5;
        
        // Initialize Session
        session = [NSURLSession
                   sessionWithConfiguration:sessionConfiguration
                   //delegate:URLSessionDel
                   delegate:self
                   delegateQueue:nil];
         
        NSLog(@"> setted %@ as delegate", self.id);

    //});
    
    return session;
}

-(NSString *) randomStringWithLength {
    NSLog(@"> randomStringWithLength(t.%@)", [NSThread currentThread]);
    
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity: 10];
    for (int i=0; i<10; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform([letters length])]];
    }
    return randomString;
}

- (void)didReceiveMemoryWarning {
    NSLog(@"> didReceiveMemoryWarning(t.%@)", [NSThread currentThread]);
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    NSLog(@"> viewWillDisappear(t.%@)", [NSThread currentThread]);
    
    [super viewWillDisappear:animated];

    if([self isMovingToParentViewController]){
    
        NSLog(@"moving to parent");
        
    }
    
    if([self isBeingDismissed]){
        
        NSLog(@"being dismissed");
        
    }
    
    //Pause all Download
    /*NSMutableArray *arrResumeData;
    for (int i=0; i<[self.arrFileDownloadData count]; i++) {
        FileDownloadInfo *fdi = [self.arrFileDownloadData objectAtIndex:i];
        // Pause the task by canceling it and storing the resume data.
        if (fdi.isDownloading){
            //Pausa i download attivi
            [fdi.downloadTask cancelByProducingResumeData:^(NSData *resumeData) {
                if (resumeData != nil) {
                    fdi.taskResumeData = [[NSData alloc] initWithData:resumeData];
                    [self saveDownloadPartData:fdi];
                }
            }];
        } else if(fdi.taskResumeData != nil){
            //Salva i dati dei download in pausa
            [self saveDownloadPartData:fdi];
        }
    }*/
    
    //[self.session finishTasksAndInvalidate];
    
}

/*
- (void)saveDownloadPartData:(FileDownloadInfo*)fdi{
    
    //Crea file .info per i dati di resume
    NSDictionary *info = @{@"taskProgress":
                               [NSNumber numberWithDouble:fdi.taskProgress]
                           };
    NSURL *infoURL = [[self.docDirectoryURL URLByAppendingPathComponent:fdi.fileName] URLByAppendingPathExtension:@"info"];
    [info writeToFile:[infoURL path] atomically:YES];
    
    //Crea file .part per il resume
    NSURL *partURL = [[self.docDirectoryURL URLByAppendingPathComponent:fdi.fileName] URLByAppendingPathExtension:@"part"];
    [fdi.taskResumeData writeToFile:[partURL path] atomically:YES];
}

- (void)removeDownloadPartData:(FileDownloadInfo*)fdi{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    //Elimina file .info per i dati di resume
    NSURL *infoURL = [[self.docDirectoryURL URLByAppendingPathComponent:fdi.fileName] URLByAppendingPathExtension:@"info"];
    if ([fileManager fileExistsAtPath:[infoURL path]]) {
        [fileManager removeItemAtURL:[NSURL URLWithString:[infoURL path]] error:nil];
    }

    //Elimina file .part per il resume
    NSURL *partURL = [[self.docDirectoryURL URLByAppendingPathComponent:fdi.fileName] URLByAppendingPathExtension:@"part"];
    if ([fileManager fileExistsAtPath:[partURL path]]) {
        [fileManager removeItemAtURL:[NSURL URLWithString:[partURL path]] error:nil];
    }
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Private method implementation


-(void)initializeFileDownloadDataArray:(NSString*)bilanci_path{
    NSLog(@"> initializeFileDownloadDataArray(t.%@)", [NSThread currentThread]);
    
    self.arrFileDownloadData = [[NSMutableArray alloc] init];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    //(Online) Leggi da File (bilanci.txt)
    NSString* fileContents = [NSString stringWithContentsOfFile:bilanci_path encoding:NSUTF8StringEncoding error:nil];
    self.bilanci = [fileContents componentsSeparatedByCharactersInSet: [NSCharacterSet newlineCharacterSet]];
    for (NSString *fil in self.bilanci){
        NSArray* dati = [fil componentsSeparatedByString:@"," ];
        //0 titolo, 1 percorso
        if ([dati count] >= 2 ){
            NSString *fileName = [[dati objectAtIndex:1] lastPathComponent];
            
            //controlla se esiste (già scaricato)
            NSString *localFile = nil;
            NSURL *fileDestinationURL = [self.docDirectoryURL  URLByAppendingPathComponent:fileName];
            if ([fileManager fileExistsAtPath:[fileDestinationURL path]]) {
                localFile = [fileDestinationURL absoluteString];
            }
            //controlla se esistono dati di resume (file part/info)
            NSString *localPart = nil;
            NSURL *filePartURL = [fileDestinationURL URLByAppendingPathExtension:@"part"];
            if([fileManager fileExistsAtPath:[filePartURL path]]){
                localPart = [filePartURL path];
            }
            
            //aggiungi
            [self.arrFileDownloadData addObject:[[FileDownloadInfo alloc]
                                                 initWithFileTitle:[dati objectAtIndex:0]
                                                 andDownloadSource:[dati objectAtIndex:1]
                                                 atLocal: localFile
                                                 withPartFile:localPart
            ]];
        }
    }
    
    //(Altri file in cartella download)
    //Vedi solo i file che sono stati scaricati e non piu disponibili online
    //Controlla se un documento con stesso nome file è già presente:
    //    se si non visualizzare.
    //    se non presente aggiungilo.
    NSArray *allFiles = [fileManager contentsOfDirectoryAtURL:self.docDirectoryURL
                                   includingPropertiesForKeys:nil
                                                      options:NSDirectoryEnumerationSkipsHiddenFiles
                                                        error:nil];
    for (int i=0; i<[allFiles count]; i++) {
        
        NSString* localFile = [allFiles objectAtIndex:i];
        
        if([[localFile pathExtension] isEqualToString:@"pdf"]){
        
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"fileName MATCHES %@",[localFile lastPathComponent]];
            NSArray* filteredArray = [self.arrFileDownloadData filteredArrayUsingPredicate:predicate];
        
            if ([filteredArray count]==0) {
                [self.arrFileDownloadData addObject:[[FileDownloadInfo alloc]
                                                 initFromLocal: [allFiles objectAtIndex:i]
                                                 ]];
            }
        }
    }
    
    //Demo
    /*[self.arrFileDownloadData addObject:[[FileDownloadInfo alloc] initWithFileTitle:@"Human Interface Guidelines"
        andDownloadSource:@"https://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/MobileHIG/MobileHIG.pdf"]
        atLocal: @""
        ];
    [self.arrFileDownloadData addObject:[[FileDownloadInfo alloc] initWithFileTitle:@"Networking Overview" andDownloadSource:@"https://developer.apple.com/library/ios/documentation/NetworkingInternetWeb/Conceptual/NetworkingOverview/NetworkingOverview.pdf"]];
    [self.arrFileDownloadData addObject:[[FileDownloadInfo alloc] initWithFileTitle:@"AV Foundation" andDownloadSource:@"https://developer.apple.com/library/ios/documentation/AudioVideo/Conceptual/AVFoundationPG/AVFoundationPG.pdf"]];
    [self.arrFileDownloadData addObject:[[FileDownloadInfo alloc] initWithFileTitle:@"iPhone User Guide" andDownloadSource:@"http://manuals.info.apple.com/MANUALS/1000/MA1565/en_US/iphone_user_guide.pdf"]];
    */
}

-(int)getFileDownloadInfoIndexWithTaskIdentifier:(unsigned long)taskIdentifier{
    NSLog(@"> getFileDownloadInfoIndexWithTaskIdentifier(t.%@)", [NSThread currentThread]);
    
    int index = -1;
    for (int i=0; i<[self.arrFileDownloadData count]; i++) {
        FileDownloadInfo *fdi = [self.arrFileDownloadData objectAtIndex:i];
        if (fdi.downloadTask.taskIdentifier == taskIdentifier) {
            index = i;
            break;
        }
    }
    
    return index;
}
-(int)getFileDownloadInfoIndexWithURL:(NSString*)url{
    NSLog(@"> getFileDownloadInfoIndexWithURL(t.%@)", [NSThread currentThread]);
    
    int index = -1;
    for (int i=0; i<[self.arrFileDownloadData count]; i++) {
        FileDownloadInfo *fdi = [self.arrFileDownloadData objectAtIndex:i];
        if ([fdi.downloadSource isEqualToString:url]) {
            index = i;
            break;
        }
    }
    
    return index;
}



#pragma mark - UITableView Delegate and Datasource method implementation

- (IBAction)handleBackBtn:(id)sender {
    [self.navigationController popViewControllerAnimated:true];
    //[self dismissModalViewControllerAnimated:YES];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.arrFileDownloadData.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"> tableView updateCell (t.%@) cell: %li", [NSThread currentThread] , (long)indexPath.row    );
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"idCell"];
    cell.backgroundColor = [UIColor clearColor];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"idCell"];
    }
    
    // Get the respective FileDownloadInfo object from the arrFileDownloadData array.
    FileDownloadInfo *fdi = [self.arrFileDownloadData objectAtIndex:indexPath.row];
    
    // Get all cell's subviews.
    UILabel *displayedTitle = (UILabel *)[cell viewWithTag:10];
    UIButton *startPauseButton = (UIButton *)[cell viewWithTag:CellStartPauseButtonTagValue];
    //UIButton *stopButton = (UIButton *)[cell viewWithTag:CellStopButtonTagValue];
    UIProgressView *progressView = (UIProgressView *)[cell viewWithTag:CellProgressBarTagValue];
    UILabel *readyLabel = (UILabel *)[cell viewWithTag:CellLabelReadyTagValue];
    
    NSString *startPauseButtonImageName;
    
    // Set the file title.
    displayedTitle.text = fdi.fileTitle;
    
    // Depending on whether the current file is being downloaded or not, specify the status
    // of the progress bar and the couple of buttons on the cell.
    if (fdi.isAvailable) {
        //AVAILABLE
        startPauseButtonImageName = @"down-30"; //not used
        startPauseButton.hidden = !NO;
        
        readyLabel.hidden = !YES;
        
        progressView.hidden = !NO;
        progressView.progress = fdi.taskProgress;
    }
    else if (fdi.isDownloading){
        //IN PROGRESS
        startPauseButtonImageName = @"pause-25";
        
        // Show the progress view and update its progress, change the image of the start button so it shows
        // a pause icon, and enable the stop button.
        startPauseButton.hidden = !YES;
        readyLabel.hidden = !NO;
        
        progressView.hidden = !YES;
        progressView.progress = fdi.taskProgress;
    }
    else{
        startPauseButtonImageName = @"down-30";
        
        //Controlla se presenti dati di resume
        if(fdi.taskResumeData != nil){
            //PAUSED
            startPauseButton.hidden = !YES;
            readyLabel.hidden = !NO;
            
            progressView.hidden = !YES;
            progressView.progress = fdi.taskProgress;
            
        }else{
            //NOT INITIALIZED
            //Non in Download e nessun dato di resume
            // Hide the progress view and disable the stop button.
            startPauseButton.hidden = !YES;
            readyLabel.hidden = !NO;
            
            progressView.hidden = !NO;
            progressView.progress = fdi.taskProgress;
            
        }
        
    }
    
    // Set the appropriate image to the start button.
    [startPauseButton setImage:[UIImage imageNamed:startPauseButtonImageName] forState:UIControlStateNormal];
    
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0;
}


#pragma mark - IBAction method implementation

- (IBAction)OpenFile:(id)sender {
    NSLog(@"> OpenFile (t.%@)", [NSThread currentThread]);
    
    // Check if the parent view of the sender button is a table view cell.
    if ([[[sender superview] superview] isKindOfClass:[UITableViewCell class]]) {
        // Get the container cell.
        UITableViewCell *containerCell = (UITableViewCell *)[[sender superview] superview];
        
        // Get the row (index) of the cell. We'll keep the index path as well, we'll need it later.
        NSIndexPath *cellIndexPath = [self.tblFiles indexPathForCell:containerCell];
        int cellIndex = cellIndexPath.row;
        
        // Get the FileDownloadInfo object being at the cellIndex position of the array.
        FileDownloadInfo *fdi = [self.arrFileDownloadData objectAtIndex:cellIndex];
        
        //Start Viewer
        
        //Inizializza Page Controller
        NSURL *fileURL = [self.docDirectoryURL URLByAppendingPathComponent:fdi.fileName];
        
        TSPPageViewController *page =
        [[TSPPageViewController alloc] initWithPDFAtPath:[fileURL path]];
        
        [self.navigationController pushViewController:page animated:YES];
        
        //[self presentViewController:page animated:YES completion:NULL];
        
        
    }
}

- (IBAction)startOrPauseDownloadingSingleFile:(id)sender {
    NSLog(@"> startOrPauseDownloadingSingleFile (t.%@)", [NSThread currentThread]);
    
    // Check if the parent view of the sender button is a table view cell.
    if ([[[sender superview] superview] isKindOfClass:[UITableViewCell class]]) {
        // Get the container cell.
        UITableViewCell *containerCell = (UITableViewCell *)[[sender superview] superview];
        
        // Get the row (index) of the cell. We'll keep the index path as well, we'll need it later.
        //NSIndexPath *cellIndexPath = [self.tblFiles indexPathForCell:containerCell];
        NSIndexPath *cellIndexPath = [self.tblFiles indexPathForRowAtPoint:containerCell.center];
        int cellIndex = cellIndexPath.row;
        
        // Get the FileDownloadInfo object being at the cellIndex position of the array.
        FileDownloadInfo *fdi = [self.arrFileDownloadData objectAtIndex:cellIndex];
        
        // The isDownloading property of the fdi object defines whether a downloading should be started
        // or be stopped.
        if (!fdi.isDownloading) {
            // START
            // This is the case where a download task should be started.
            
            // Create a new task, but check whether it should be created using a URL or resume data.
            if (fdi.isPaused) {
                
                // Create a new download task, which will use the stored resume data.
                fdi.downloadTask = [self.session downloadTaskWithResumeData:fdi.taskResumeData  ];
                
                // Start the task.
                [fdi.downloadTask resume];
                fdi.isDownloading = YES;
                fdi.isPaused = NO;
                
                // Reload the table view.
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                //dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tblFiles reloadRowsAtIndexPaths:@[cellIndexPath] withRowAnimation:UITableViewRowAnimationNone];
                //});
                   }];
                
                NSLog(@" New Download REstart: %lul ",(unsigned long)fdi.downloadTask.taskIdentifier);
                
            }else{
                
                //Check Task existence
                [self.session getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
                    
                    NSURLSessionDownloadTask *Task = nil;
                    
                    for (NSURLSessionDownloadTask *tsk in downloadTasks) {
                        if([fdi.downloadSource isEqualToString:[tsk.currentRequest.URL absoluteString ]] ){
                            Task = tsk;
                        }
                    }
                    if(Task == nil){
                        Task = [self.session downloadTaskWithURL:[NSURL URLWithString:fdi.downloadSource] ];
                    }
                    fdi.downloadTask = Task;
                    
                    // Start the task.
                    [fdi.downloadTask resume ];
                    fdi.isDownloading = YES;
                    fdi.isPaused = NO;
                    
                    NSLog(@" New Download start: %lul ",(unsigned long)fdi.downloadTask.taskIdentifier);
                    
                    // Reload the table view.
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    //dispatch_async(dispatch_get_main_queue(), ^{
                        [self.tblFiles reloadRowsAtIndexPaths:@[cellIndexPath] withRowAnimation:UITableViewRowAnimationNone];
                    //});
                    }];
                }];
            }
            
        }else{
            // PAUSE the task by canceling it and storing the resume data.
            [fdi.downloadTask cancelByProducingResumeData:^(NSData *resumeData) {
                if (resumeData != nil) {
                    NSLog(@"rsdl: %lu",(unsigned long)[resumeData length]);
                    fdi.taskResumeData = [[NSData alloc] initWithData:resumeData];
                    fdi.isPaused = YES;
                    //[self saveDownloadPartData:fdi];
                    
                    // Reload the table view.
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.tblFiles reloadRowsAtIndexPaths:@[cellIndexPath] withRowAnimation:UITableViewRowAnimationNone];
                    });
                }
            }];
            //foo value while producing resume data
            //fdi.taskResumeData = [NSData alloc] ; //to update ui
            fdi.isDownloading = NO;
        }
        


    }
}

/*
-(void)startNew:(FileDownloadInfo*)fdi{
    
    
    // Create a new task, but check whether it should be created using a URL or resume data.
    if (fdi.isPaused) {
        
        // Create a new download task, which will use the stored resume data.
        fdi.downloadTask = [self.session downloadTaskWithResumeData:fdi.taskResumeData  ];
        
        // Start the task.
        [fdi.downloadTask resume];
        fdi.isDownloading = YES;
        fdi.isPaused = NO;
        
        NSLog(@" New Download REstart: %lul ",(unsigned long)fdi.downloadTask.taskIdentifier);
        
    }else{
        
        //Check Task existence
        [self.session getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
            
            NSURLSessionDownloadTask *Task = nil;
            
            for (NSURLSessionDownloadTask *tsk in downloadTasks) {
                if([fdi.downloadSource isEqualToString:[tsk.currentRequest.URL absoluteString ]] ){
                    Task = tsk;
                }
            }
            if(Task == nil){
                Task = [self.session downloadTaskWithURL:[NSURL URLWithString:fdi.downloadSource] ];
            }
            fdi.downloadTask = Task;
            
            // Start the task.
            [fdi.downloadTask resume ];
            fdi.isDownloading = YES;
            fdi.isPaused = NO;
            
            NSLog(@" New Download start: %lul ",(unsigned long)fdi.downloadTask.taskIdentifier);
            
            // Reload the table view.
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tblFiles reloadRowsAtIndexPaths:@[cellIndexPath] withRowAnimation:UITableViewRowAnimationNone];
            });
            
        }];
        
    }

    
}
*/

/*
- (IBAction)stopDownloading:(id)sender {
    if ([[[[sender superview] superview] superview] isKindOfClass:[UITableViewCell class]]) {
        // Get the container cell.
        UITableViewCell *containerCell = (UITableViewCell *)[[[sender superview] superview] superview];
        
        // Get the row (index) of the cell. We'll keep the index path as well, we'll need it later.
        NSIndexPath *cellIndexPath = [self.tblFiles indexPathForCell:containerCell];
        int cellIndex = cellIndexPath.row;
        
        // Get the FileDownloadInfo object being at the cellIndex position of the array.
        FileDownloadInfo *fdi = [self.arrFileDownloadData objectAtIndex:cellIndex];
        
        // Cancel the task.
        [fdi.downloadTask cancel];
        
        // Change all related properties.
        fdi.isDownloading = NO;
        fdi.taskIdentifier = -1;
        fdi.taskProgress = 0.0;
        
        // Reload the table view.
        [self.tblFiles reloadRowsAtIndexPaths:@[cellIndexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
}
*/

/*
- (IBAction)startAllDownloads:(id)sender {
    // Access all FileDownloadInfo objects using a loop.
    for (int i=0; i<[self.arrFileDownloadData count]; i++) {
        FileDownloadInfo *fdi = [self.arrFileDownloadData objectAtIndex:i];
        
        // Check if a file is already being downloaded or not.
        if (!fdi.isDownloading) {
            // Check if should create a new download task using a URL, or using resume data.
            if (fdi.taskIdentifier == -1) {
                fdi.downloadTask = [self.session downloadTaskWithURL:[NSURL URLWithString:fdi.downloadSource]];
            }
            else{
                fdi.downloadTask = [self.session downloadTaskWithResumeData:fdi.taskResumeData];
            }
            
            // Keep the new taskIdentifier.
            fdi.taskIdentifier = fdi.downloadTask.taskIdentifier;
            
            // Start the download.
            [fdi.downloadTask resume];
            
            // Indicate for each file that is being downloaded.
            fdi.isDownloading = YES;
        }
    }
    
    // Reload the table view.
    [self.tblFiles reloadData];
}


- (IBAction)stopAllDownloads:(id)sender {
    // Access all FileDownloadInfo objects using a loop.
    for (int i=0; i<[self.arrFileDownloadData count]; i++) {
        FileDownloadInfo *fdi = [self.arrFileDownloadData objectAtIndex:i];
        
        // Check if a file is being currently downloading.
        if (fdi.isDownloading) {
            // Cancel the task.
            [fdi.downloadTask cancel];
            
            // Change all related properties.
            fdi.isDownloading = NO;
            fdi.taskIdentifier = -1;
            fdi.downloadProgress = 0.0;
            fdi.downloadTask = nil;
        }
    }
    
    // Reload the table view.
    [self.tblFiles reloadData];
}

- (IBAction)resetAll:(id)sender {
    // Access all FileDownloadInfo objects using a loop and give all properties their initial values.
    for (int i=0; i<[self.arrFileDownloadData count]; i++) {
        FileDownloadInfo *fdi = [self.arrFileDownloadData objectAtIndex:i];
        
        if (fdi.isDownloading) {
            [fdi.downloadTask cancel];
        }
        
        fdi.isDownloading = NO;
        fdi.isAvailable = NO;
        fdi.taskIdentifier = -1;
        fdi.downloadProgress = 0.0;
        fdi.downloadTask = nil;
    }
    
    // Reload the table view.
    [self.tblFiles reloadData];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // Get all files in documents directory.
    NSArray *allFiles = [fileManager contentsOfDirectoryAtURL:self.docDirectoryURL
                                   includingPropertiesForKeys:nil
                                                      options:NSDirectoryEnumerationSkipsHiddenFiles
                                                        error:nil];
    for (int i=0; i<[allFiles count]; i++) {
        [fileManager removeItemAtURL:[allFiles objectAtIndex:i] error:nil];
    }
}
 
 
 - (IBAction)initializeAll {
 
 // Access all FileDownloadInfo objects using a loop and give all properties their initial values.
 for (int i=0; i<[self.arrFileDownloadData count]; i++) {
 FileDownloadInfo *fdi = [self.arrFileDownloadData objectAtIndex:i];
 
 if (fdi.isDownloading) {
 [fdi.downloadTask cancel];
 }
 
 fdi.isDownloading = NO;
 fdi.isAvailable = NO;
 fdi.taskIdentifier = -1;
 fdi.downloadProgress = 0.0;
 fdi.downloadTask = nil;
 }
 
 // Reload the table view.
 [self.tblFiles reloadData];
 
 NSFileManager *fileManager = [NSFileManager defaultManager];
 
 [self.tblFiles reloadData];
 
 // Get all files in documents directory.
 NSArray *allFiles = [fileManager contentsOfDirectoryAtURL:self.docDirectoryURL
 includingPropertiesForKeys:nil
 options:NSDirectoryEnumerationSkipsHiddenFiles
 error:nil];
 for (int i=0; i<[allFiles count]; i++) {
 [fileManager removeItemAtURL:[allFiles objectAtIndex:i] error:nil];
 }
 }
 
*/

#pragma mark - NSURLSession Delegate method implementation

- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error
{
    NSLog(@"> didBecomeInvalidWithError (s.%@) %@", self.id , [error description]);
    
    /*
     Non invalidare mai la sessione
     if (error)
    {
        
        
    }
    
    if ([session isEqual:_session])
    {
        //self.session = nil;
    }*/
}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location{
    NSLog(@"> didFinishDownloadingToURL (s.%@)", self.id);
    
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
            
            NSLog(@"UI state: %ld",[[UIApplication sharedApplication] applicationState]);
            if (([[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground) ||
                (self.view.window == nil)) {
                // viewController is not visible
                // Show a local notification when all downloads are over.
                UILocalNotification *localNotification = [[UILocalNotification alloc] init];
                localNotification.alertBody = [ [[NSString alloc] init] stringByAppendingFormat:@"%@ scaricato!",fdi.fileTitle] ;
                [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
            }
            
        }];
        
    }
    else{
        NSLog(@"Unable to copy temp file. Error: %@", [error localizedDescription]);
    }
    
}


-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    NSLog(@"> didCompleteWithError (s.%@)", self.id);
    
    if (error != nil) {
        NSDictionary *info = [error userInfo];
        NSLog(@"Download completed with error: %@", [error localizedDescription]);
        
        /*if(![[error localizedDescription] isEqualToString:@"cancelled"]){
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
        }*/
    }
    else{
        NSLog(@"Download finished successfully.");
    }
}


/*
 TODO
 updateProtocol from ProtocolDelegate
 */

-(void)updateProgress {
    NSLog(@"> updateProgress from Delegate (s.%@) ", self.id);
}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    NSLog(@"> updateProgress task:%lu (s.%@)",downloadTask.taskIdentifier, self.id);
    
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
    }
}


-(void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session{
    NSLog(@"> URLSessionDidFinishEventsForBackgroundURLSession (s.%@)", self.id);
    
    TSPAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    //TSPAppDelegate *appaDelegate = self.session.session.delegate;
    
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
    }];
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes {
    
    NSLog(@"> didResumeAtOffset (s.%@) ", self.id);
    
}

@end

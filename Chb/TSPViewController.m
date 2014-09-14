//
//  TSPViewController.m
//  Chb
//
//  Created by Massimo on 4/13/14.
//  Copyright (c) 2014 Massimo Zanini. All rights reserved.
//

#import "TSPViewController.h"
#import "TSPWebViewController.h"

@interface TSPViewController ()

@property NSInteger btn_type;

@property UIView *loading;
@property UIActivityIndicatorView *indicator;

- (void) closeThings;

@end

@implementation TSPViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    //Caricamento
    self.loading = (UIView*) [self.view viewWithTag:50];
    self.indicator = (UIActivityIndicatorView*) [self.view viewWithTag:60];
    [self loadThings];
    
    // Ios 6
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets  = NO;
    
    //Immagine Barra
    /*UIImage *image = [UIImage imageNamed: @"logo_chb_s.png"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage: image];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.frame = CGRectMake(0, 0, self.navigationController.navigationBar.frame.size.width-20, self.navigationController.navigationBar.frame.size.height-20 );
    self.navigationItem.titleView = imageView;
    */
    
    //Disabilita Barra superiore
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    
    //BackGround
    UIImage *bg = [UIImage imageNamed:@"terraViBil"];
    self.view.backgroundColor = [UIColor colorWithPatternImage:bg];
    
    //Testo Indietro
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    //Metti testo a label
    UILabel *label1 = (UILabel*) [self.view viewWithTag:110];
    UILabel *label2 = (UILabel*) [self.view viewWithTag:210];
    UILabel *label3 = (UILabel*) [self.view viewWithTag:310];
    UILabel *label4 = (UILabel*) [self.view viewWithTag:410];
    UILabel *label5 = (UILabel*) [self.view viewWithTag:510];
    UILabel *label6 = (UILabel*) [self.view viewWithTag:610];
    label1.numberOfLines = 2;
    label2.numberOfLines = 2;
    label3.numberOfLines = 2;
    label4.numberOfLines = 2;
    label5.numberOfLines = 2;
    label6.numberOfLines = 2;
    label1.text = @"ChiantiBanca\n in Breve";
    label2.text = @"Il Bilancio\n ";
    label3.text = @"Le Filiali\n ";
    label4.text = @"Iniziative\nSociali";
    label5.text = @"Governance\n ";
    label6.text = @"Notizie\n ";
    
    
    [self prepareFavBtn];
    
    //Trash
    /*
     CGRect screenRect = [[UIScreen mainScreen] bounds];
     CGFloat screenWidth = screenRect.size.width;
     CGFloat screenHeight = screenRect.size.height;
     */
    //[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[imageView]-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:NSDictionaryOfVariableBindings(imageView)]];
    

}


// View Caricamento
- (void) loadThings
{
    //Espandi e Avvia indicatore
    //TODO
    [self.indicator startAnimating];
    
    //Nuovo Thread
    [NSThread detachNewThreadSelector:@selector(inNewThread:) toTarget:self withObject:nil];
}
- (void) inNewThread:(id)data {
    
    //...lots of computation...
    /*NSString *stringURL = @"http://www.somewhere.com/thefile.png";
    NSURL  *url = [NSURL URLWithString:stringURL];
    NSData *urlData = [NSData dataWithContentsOfURL:url];
    if ( urlData )
    {
        NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"banner.png"];

        NSError *writeError = nil;
        
        [urlData writeToFile:filePath options:NSDataWritingAtomic error:&writeError];
        
        if (writeError) {
            NSLog(@"Error writing file: %@", writeError);
        }
 
    }*/
    
    //Chiudi
    //[self performSelector:@selector(closeThings) withObject:nil afterDelay:2];
    [self closeThings];
    
}
- (void) closeThings {
    [self.indicator stopAnimating];
    [self.loading removeFromSuperview];
}


//Tasto principale premuto
- (void)doBtnPressed:(NSInteger) type
{
    NSLog(@"-doBtnPressed");
    
    self.btn_type = type;
    switch (type) {
        case 100:
        case 200:
        case 400:
        case 500:
        case 600:
            //webview
            [self performSegueWithIdentifier: @"btn_web" sender: self];
            break;
        case 300:
            //mappa
            [self performSegueWithIdentifier: @"btn_map" sender: self];
            break;
        case 900:
            //favorito
            [self performSegueWithIdentifier: @"btn_web" sender: self];
            break;
        default:
            break;
    }
    
}
//Tasto Favoriti premuto
- (void)gotoFav{
    
    [self doBtnPressed:900];
    
}

//Prepare Segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    NSLog(@"-prepareForSegue");
    if([segue.identifier isEqualToString:@"btn_web"]){
        TSPWebViewController *controller = (TSPWebViewController *)segue.destinationViewController;
        if(self.btn_type == 900){
            //Favorito (Filiale)
            controller.type= 1;
            controller.info_title= [[[[NSUserDefaults standardUserDefaults] objectForKey:@"fav_title"]componentsSeparatedByString:@"." ] objectAtIndex:0];
            controller.info_file= [[NSUserDefaults standardUserDefaults] objectForKey:@"fav_file"];
        }else{
            //Bottone
            controller.type= 0;
            controller.info= self.btn_type;
        }

    }
}

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"-viewWillAppear");
    [super viewWillAppear:animated];
    [self prepareFavBtn]; // to refresh
}

- (void) prepareFavBtn{
    
    //Favorite Btn (solo con type 1)
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"fav_title"] != nil){
        
        UIImage* image3 = [UIImage imageNamed:@"star_full"];
        CGRect frameimg = CGRectMake(0, 0, 20, 20);
        UIButton *someButton = [[UIButton alloc] initWithFrame:frameimg];
        someButton.frame = frameimg;
        [someButton setBackgroundImage:image3 forState:UIControlStateNormal];
        [someButton addTarget:self action:@selector(gotoFav)
             forControlEvents:UIControlEventTouchUpInside];
        [someButton setShowsTouchWhenHighlighted:YES];
        UIBarButtonItem *mailbutton =[[UIBarButtonItem alloc] initWithCustomView:someButton];
        self.navigationItem.rightBarButtonItem=mailbutton;
        
    } else if (self.navigationItem.rightBarButtonItem != nil){
        
        self.navigationItem.rightBarButtonItem=nil;
        
    }
    
}




//Altro
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

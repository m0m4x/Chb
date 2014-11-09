//
//  TSPMapViewController.m
//  Chb
//
//  Created by Massimo on 4/13/14.
//  Copyright (c) 2014 Massimo Zanini. All rights reserved.
//

#import "TSPMapViewController.h"
#import "TSPWebViewController.h"
#import "GetData.h"

#import "MapKit/MapKit.h"
#import "CoreLocation/CoreLocation.h"


@interface TSPMapViewController ()

@property GetData *dataObj;

@property  NSArray *filiali;
@property  NSString *selected;
@property (nonatomic,weak) IBOutlet MKMapView *mapView;

-(void)aggiungiFilialeCoords:(double)lati long:(double)longi descrizione:(NSString*)descr;
-(void)aggiungiFiliale:(NSString*)address descrizione:(NSString*)descr;

@end

#define IDIOM    UI_USER_INTERFACE_IDIOM()
#define IPAD     UIUserInterfaceIdiomPad

@implementation TSPMapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //Oggetti
    self.dataObj = [GetData alloc];
    self.dataObj.loading = (UIView*) [self.view viewWithTag:50];
    self.dataObj.indicator = (UIActivityIndicatorView*) [self.view viewWithTag:60];
    
    //self.mapView = (MKMapView*) [self.view viewWithTag:800];
    
    UIImageView *bg = (UIImageView*) [self.view viewWithTag:3];
    UILabel *label_title = (UILabel *)[self.view viewWithTag:30];
    UIButton *button_back = (UIButton *)[self.view viewWithTag:5];

    //Imposta Titolo
    self.title = @"filiali";
    label_title.text = @"filiali";
    
    //Imposta bg
    [bg setImage:[UIImage imageNamed:@"bg_vuoto.png"]];
    
    //Imposta Mappa
    self.mapView.mapType = MKMapTypeStandard;
    
    //Tasto Indietro
    [button_back setImage:[UIImage imageNamed:@"icon-back.png"] forState:UIControlStateNormal];
    
    //Caricamento Risorse (lista Filiali)
    [self.dataObj loadResources:^{
        
        NSString *file = [self.dataObj getPathFor:@"filiali" fileType:@"txt" checkOnline:YES];
        [self loadFiliali:file];
        
    }];
    //Poi il percorso delle risorse si otterrà con:
    //[self.dataObj getPathFor:@"filiali" fileType:@"txt" checkOnline:NO];

}

- (IBAction)handleBackBtn:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:true];
}


-(void)loadFiliali:(NSString*)filiali_path{
    
    NSLog(@"-loadFiliali");
    
    //Imposta Mappa 2
    self.mapView.showsUserLocation = YES;
    
    //Leggi da File (filiali.txt)
    //NSString* filePath = [self.dataObj getPathFor:@"filiali" fileType:@"txt" initRes:NO];
    NSString* fileContents = [NSString stringWithContentsOfFile:filiali_path encoding:NSUTF8StringEncoding error:nil];
    self.filiali = [fileContents componentsSeparatedByCharactersInSet: [NSCharacterSet newlineCharacterSet]];
    for (NSString *fil in self.filiali){
        NSArray* dati = [fil componentsSeparatedByString:@"," ];
        //0 Nome
        //1 lat
        //2 long
        //3 file
        if ([dati count] >= 3 ){
            [self aggiungiFilialeCoords:[[dati objectAtIndex:1] doubleValue]
                                   long:[[dati objectAtIndex:2] doubleValue]
                            descrizione:[dati objectAtIndex:0]];
        }
        
    }
    
    //Centra
    /* fisso
     CLLocationCoordinate2D center = CLLocationCoordinate2DMake(43.610075,11.189575);
     MKCoordinateSpan span = MKCoordinateSpanMake(1, 1);
     MKCoordinateRegion regionToDisplay = MKCoordinateRegionMake(center, span);
     [self.mapView setRegion:regionToDisplay];
     
     //MKMapView *mapView = (MKMapView*)[self.view viewWithTag:800];
     //MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(43.7254976, 11.0468912), 2000, 2000);
     //MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(37.323, -122.031), 0.2, 0.2);
     */
    
    //Zoom Rect
    MKMapRect zoomRect = MKMapRectNull;
    for (id <MKAnnotation> annotation in self.mapView.annotations)
    {
        MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1);
        zoomRect = MKMapRectUnion(zoomRect, pointRect);
    }
    
    //Padding borders
    NSInteger padding;
    if ( IDIOM == IPAD ) {
        padding = 50;
    } else {
        padding = 20;
    }
    
    [self.mapView
     setVisibleMapRect:[self.mapView mapRectThatFits:zoomRect edgePadding:(UIEdgeInsetsMake(padding, padding, padding, padding))]
     animated:YES];
    
    
}



- (void)aggiungiFiliale:(NSString*)address descrizione:(NSString*)descr
{
    NSLog(@"-aggiungiFiliale");
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:address
                 completionHandler:^(NSArray* placemarks, NSError* error){
                     // Check for returned placemarks
                     if (placemarks && placemarks.count > 0) {
                         CLPlacemark *topResult = [placemarks objectAtIndex:0];
                         // Create a MLPlacemark and add it to the map view
                         MKPlacemark *placemark = [[MKPlacemark alloc] initWithPlacemark:topResult];
                         //[self.mapView addAnnotation:placemark];
                         
                         MKPointAnnotation *pa = [[MKPointAnnotation alloc] init];
                         pa.coordinate = placemark.location.coordinate;
                         pa.title = descr;
                         [self.mapView addAnnotation:pa];
                     }
                 }];
}

- (void)aggiungiFilialeCoords:(double)lati long:(double)longi descrizione:(NSString*)descr
{
    NSLog(@"-aggiungiFilialeCoords");
    // Create a MLPlacemark and add it to the map view
    MKPointAnnotation *pa = [[MKPointAnnotation alloc] init];
    pa.coordinate = CLLocationCoordinate2DMake(lati,longi);
    pa.title = descr;
    [self.mapView addAnnotation:pa];
}


- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>) annotation
{
    NSLog(@"-mapView");
    
    MKAnnotationView *annView = [[MKAnnotationView alloc ] initWithAnnotation:annotation reuseIdentifier:nil];
    
    if ([[annotation title] isEqualToString:@"Current Location"]) {
        NSLog(@"- CURRENT LOC!");
        return nil;
    }else if ([[[annotation title] lowercaseString] hasPrefix:@"atm intelligente"] |
        [[[annotation title] lowercaseString] hasPrefix:@"atm avanzato"] |
        [[[annotation title] lowercaseString] hasPrefix:@"bancomat intelligente"] |
        [[[annotation title] lowercaseString] hasPrefix:@"bancomat avanzato"]){
        annView.image = [ UIImage imageNamed:@"pin_green"];
    }else if ([[[annotation title] lowercaseString] hasPrefix:@"atm"] |
              [[[annotation title] lowercaseString] hasPrefix:@"bancomat"]){
        annView.image = [ UIImage imageNamed:@"pin_yellow"];
    }else if([[[annotation title] lowercaseString] hasPrefix:@"videosportello"] |
             [[[annotation title] lowercaseString] hasPrefix:@"postazione di video"]){
        annView.image = [ UIImage imageNamed:@"pin_pink"];
    } else {
        annView.image = [ UIImage imageNamed:@"pin_red"];
        
        //se info
        if([self addInfo:[annotation title]]){
            UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            annView.rightCalloutAccessoryView = infoButton;
        }
    }
    
    //Marker Dimensions
    if ( IDIOM == IPAD ) {
        annView.frame = CGRectMake(0, 0, 25, 38);
    } else {
        annView.frame = CGRectMake(0, 0, 15, 26);
    }
    
    annView.canShowCallout = YES;
    annView.contentMode = UIViewContentModeScaleAspectFit;
    
    return annView;
}
-(bool)addInfo:(NSString*)title {
    NSLog(@"-addInfo");
    for (NSString *fil in self.filiali){
        NSArray* dati = [fil componentsSeparatedByString:@"," ];
        //0 Nome
        //1 lat
        //2 long
        //3 file
        if ([dati count] > 3 ){
            if([[dati objectAtIndex:0] isEqualToString:title]){
                return true;
            }
        }
    }
    return false;
}


//Info Filiale
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view
calloutAccessoryControlTapped:(UIControl *)control
{
    NSLog(@"accessory button tapped for annotation %@", view.annotation);
    self.selected = view.annotation.title;
    [self performSegueWithIdentifier: @"info" sender: self];
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    NSLog(@"-prepareForSegue");

    TSPWebViewController *controller = (TSPWebViewController *)segue.destinationViewController;
    controller.type= 1; //fil

    //Prendi Nome File
    for (NSString *fil in self.filiali){
        NSArray* dati = [fil componentsSeparatedByString:@"," ];
        //0 Nome
        //1 lat
        //2 long
        //3 file
        if ([dati count] > 3 ){
            if([[dati objectAtIndex:0] isEqualToString:self.selected]){
                controller.info_title = self.selected;
                controller.info_file = [dati objectAtIndex:3];
            }
        }
        
    }
    
    
}









- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

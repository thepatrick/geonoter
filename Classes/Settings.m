//
//  Settings.m
//  Geonoter
//
//  Created by Patrick Quinn-Graham on 15/02/09.
//  Copyright 2009-2010 Patrick-Quinn-Graham. All rights reserved.
//

#import "Settings.h"
#import "GeoNoterAppDelegate.h"
#import "SettingsChooseFromArray.h"
#import "SettingsAbout.h"


@implementation Settings

@synthesize tableView;

+(void)registerDefaultsInDictionary:(NSMutableDictionary*)defaults {
	[defaults setObject:[NSNumber numberWithBool:YES] forKey:GNLocationsDefaultsUseGeocoder];
	[defaults setObject:GNLocationsDefaultNameMostSpecific forKey:GNLocationsDefaultsDefaultName];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	arrayOfDefaultNameOptions = [[NSArray arrayWithObjects:GNLocationsDefaultNameMostSpecific, GNLocationsDefaultNameCoordinates, GNLocationsDefaultNameDateTime, nil] retain];
	arrayOfDefaultNameValues = [[NSArray arrayWithObjects:@"Most specific", @"Coordinates", @"Date and Time", nil] retain];
	settingsGroups = [[NSArray arrayWithObjects:@"About", @"Locations", @"Debug", nil] retain];
	settingsOptions = [[NSArray arrayWithObjects:[NSNumber numberWithInteger:1], [NSNumber numberWithInteger:2], [NSNumber numberWithInteger:1], nil] retain];
	self.title = @"Settings";
	[super viewDidLoad];
}

- (void)viewDidUnload {
	[arrayOfDefaultNameOptions release];
	arrayOfDefaultNameOptions = nil;
	[arrayOfDefaultNameValues release];
	arrayOfDefaultNameValues = nil;
	[super viewDidUnload];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
	[settingsGroups release];
	[settingsOptions release];
    [super dealloc];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView { 
	return [settingsGroups count];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return [settingsGroups objectAtIndex:section];
}

-(UITableViewCell*)tableView:(UITableView*)tv cellForRowAtIndexPath:(NSIndexPath*)indexPath {
	UITableViewCell *cell = nil;
	switch(indexPath.section) {
		case 0:
			cell = [self prepareAboutCellAtRow:indexPath.row];
			break;
		case 1:
			cell = [self prepareLocationsCellAtRow:indexPath.row];
			break;
		case 2:
			cell = [self prepareDebugCellAtRow:indexPath.row];
			break;
	}
	return cell;
}

-(NSInteger)tableView:(UITableView*)tv numberOfRowsInSection:(NSInteger)section
{
	return [(NSNumber*)[settingsOptions objectAtIndex:section] integerValue];
}

-(UITableViewCell*)dequeOrCreateCellStyle:(UITableViewCellStyle)style withIdentifier:(NSString*)identifier {
	UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
	if(!cell) {
		cell = [[[UITableViewCell alloc] initWithStyle:style reuseIdentifier:identifier] autorelease];
	}
	return cell;
}

-(void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	switch(indexPath.section) {
		case 0:
            [self didSelectAboutRow];
			break;
		case 1:
			[self didSelectLocationsRow:indexPath.row];
			break;
		case 2:
			[self didSelectDebugRow:indexPath.row];
			break;
	}
	[tv deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -
#pragma mark About section

-(UITableViewCell*)prepareAboutCellAtRow:(NSInteger)row {
	UITableViewCell *cell = [self dequeOrCreateCellStyle:UITableViewCellStyleValue1 withIdentifier:@"aboutInfo"];
	switch(row) {
		case 0:
			cell.textLabel.text = @"Version 1.0";
            cell.detailTextLabel.text = @"Credits";
            cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
			break;	}
	return cell;
}

-(void)didSelectAboutRow {
    // do stuff  
    SettingsAbout *sb = [SettingsAbout aboutWithPage:[[NSBundle mainBundle] pathForResource:@"Credits" ofType:@"html"]];
    [self.navigationController pushViewController:sb animated:YES];
}  

#pragma mark -
#pragma mark Locations section

-(UITableViewCell*)prepareLocationsCellAtRow:(NSInteger)row {
	UITableViewCell *cell = [self dequeOrCreateCellStyle:UITableViewCellStyleValue1 withIdentifier:@"aboutLocations"];
	switch(row) {
		case 0:
			cell.textLabel.text = @"Use Geocoder";
			cell.accessoryType = UITableViewCellAccessoryNone;
			cell.accessoryView = [[[UISwitch alloc] initWithFrame:CGRectZero] autorelease];
			DLog(@"LocationsUseGeocoder: %@", [[NSUserDefaults standardUserDefaults] boolForKey:GNLocationsDefaultsUseGeocoder] ? @"YES" : @"NO");
			[(UISwitch*)cell.accessoryView setOn:[[NSUserDefaults standardUserDefaults] boolForKey:GNLocationsDefaultsUseGeocoder] animated:NO];
			[(UISwitch*)cell.accessoryView addTarget:self action:@selector(locationsUseGeocoderChange:) forControlEvents:UIControlEventValueChanged];
			cell.detailTextLabel.text = @"";
			break;
		case 1:
			cell.textLabel.text = @"Default name";
			NSInteger idx = [arrayOfDefaultNameOptions indexOfObject:[[NSUserDefaults standardUserDefaults] stringForKey:GNLocationsDefaultsDefaultName]];
			cell.detailTextLabel.text = [arrayOfDefaultNameValues objectAtIndex:idx];
			cell.accessoryView = nil;
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			break;
	}
	return cell;
}

-(void)locationsUseGeocoderChange:(UISwitch*)sender {
	DLog(@"locationsUseGeocoderChange! %@", sender.on ? @"YES" : @"NO");
	[[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:GNLocationsDefaultsUseGeocoder];
}

-(void)didSelectLocationsRow:(NSInteger)row {
	DLog(@"didSelectLocationsRow %d", row);
	switch(row) {
		case 0:
			break;
		case 1:
			DLog(@"didSelectLocationsRow 1!");
			NSInteger idx = [arrayOfDefaultNameOptions indexOfObject:[[NSUserDefaults standardUserDefaults] stringForKey:GNLocationsDefaultsDefaultName]];
			SettingsChooseFromArray *scfa = [SettingsChooseFromArray chooserWithArrayOfOptions:arrayOfDefaultNameValues andPickedIndex:idx];
			[scfa setUserPickedItem:^(NSInteger picked, id object){
				[[NSUserDefaults standardUserDefaults] setObject:[arrayOfDefaultNameOptions objectAtIndex:picked] forKey:GNLocationsDefaultsDefaultName];
				[scfa.navigationController popViewControllerAnimated:YES];
				[self.tableView reloadData];
			}];
			scfa.title = @"Default name";
			[self.navigationController pushViewController:scfa animated:YES];
			DLog(@"Just asked navigation controller to push %@", scfa);
			break;
	}	
}

#pragma mark -
#pragma mark Debug section

-(UITableViewCell*)prepareDebugCellAtRow:(NSInteger)row {
	UITableViewCell *cell = [self dequeOrCreateCellStyle:UITableViewCellStyleDefault withIdentifier:@"aboutInfo"];
	switch(row) {
		case 0:
			cell.textLabel.text = @"Send database by e-mail";
			break;
	}
	return cell;
}

-(void)didSelectDebugRow:(NSInteger)row {
	GeoNoterAppDelegate* app = (GeoNoterAppDelegate*)[[UIApplication sharedApplication] delegate];
	switch(row) {
		case 0:
			if(![MFMailComposeViewController canSendMail]) {
				[app launchMailAppOnDevice];
				return;
			}
			
			MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
			picker.mailComposeDelegate = self;
			[picker setSubject:@"Geonoter Database"];
			NSData *myData = [NSData dataWithContentsOfFile:[app getDocumentPath:@"geonoter.db"]];
			[picker addAttachmentData:myData mimeType:@"application/x-sqlite3" fileName:[NSString stringWithFormat:@"geonoter-%@.db", [[UIDevice currentDevice] uniqueIdentifier]]];
			[self presentModalViewController:picker animated:YES];
			[picker release];
	}	
}

#pragma mark -
#pragma mark Email stuff

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error  {   
	[self dismissModalViewControllerAnimated:YES];
}

@end

//
//  Settings.m
//  GeoNoter
//
//  Created by Patrick Quinn-Graham on 15/02/09.
//  Copyright 2009-2010 Patrick-Quinn-Graham. All rights reserved.
//

#import "Settings.h"
#import "GeoNoterAppDelegate.h"


@implementation Settings

@synthesize tableView;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	settingsGroups = [[NSArray arrayWithObjects:@"About", @"Debug", nil] retain];
	settingsOptions = [[NSArray arrayWithObjects:[NSNumber numberWithInteger:1], [NSNumber numberWithInteger:1], nil] retain];
    [super viewDidLoad];
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

-(UITableViewCell*)tableView:(UITableView*)tv cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
	
	UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:@"aboutInfo"];
	if(!cell) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"aboutInfo"] autorelease];
	}
	//cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	switch(indexPath.section) {
		case 0:
			cell.textLabel.text = @"Version 1.0";
			break;
		case 1:
			[self prepareDebugCell:cell atRow:indexPath.row];
			break;
	}
	
	return cell;
}

-(NSInteger)tableView:(UITableView*)tv numberOfRowsInSection:(NSInteger)section
{
	return [(NSNumber*)[settingsOptions objectAtIndex:section] integerValue];
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	switch(indexPath.section) {
		case 0:
			break;
		case 1:
			[self didSelectDebugRow:indexPath.row];
			break;
	}
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark -
#pragma mark Debug section

-(void)prepareDebugCell:(UITableViewCell*)cell atRow:(NSInteger)row {
	switch(row) {
		case 0:
			cell.textLabel.text = @"Send database by e-mail";
			break;
	}
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

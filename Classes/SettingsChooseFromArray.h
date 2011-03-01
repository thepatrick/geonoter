//
//  SettingsChooseFromArray.h
//  Geonoter
//
//  Created by Patrick Quinn-Graham on 10-05-22.
//  Copyright 2009-2010 Patrick Quinn-Graham. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SettingsChooseFromArray : UITableViewController {

	
	void (^userPickedItem)(NSInteger,id);
	NSArray *userOptions;
	NSInteger userPicked;
	
}

@property (nonatomic, retain) NSArray *userOptions;
@property (nonatomic, assign) NSInteger userPicked;

+chooserWithArrayOfOptions:(NSArray*)array andPickedIndex:(NSInteger)picked;

-(void)setUserPickedItem:(void (^)(NSInteger,id))block;

@end

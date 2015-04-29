//
//  RMAppDataWindowController.m
//  Connecter
//
//  Created by Markus on 28.02.14.
//  Copyright (c) 2014 Realmac Software. All rights reserved.
//

// Controller
#import "RMAddLocaleWindowController.h"
#import "RMOutlineViewController.h"

// Views
#import "RMScreenshotsGroupView.h"
#import "RMOutlineView.h"

// Model
#import "RMAppDataDocument.h"
#import "RMAppScreenshot.h"
#import "RMAppMetaData.h"
#import "RMAppVersion.h"
#import "RMAppLocale.h"

#import "RMAppDataWindowController.h"

NSString *const RMAppDataArrangedObjectsKVOPath = @"arrangedObjects";

@interface RMAppDataWindowController () <RMScreenshotsGroupViewDelegate, NSTabViewDelegate, NSOutlineViewDelegate>

@property (nonatomic, strong) RMOutlineViewController *outlineController;
@property (nonatomic, strong) RMAddLocaleWindowController *addLocaleWindowController;

@property (nonatomic, strong) IBOutlet NSArrayController *versionsController;
@property (nonatomic, strong) IBOutlet NSArrayController *localesController;
@property (nonatomic, strong) IBOutlet NSArrayController *screenshotsController;
@property (nonatomic, weak)   IBOutlet RMScreenshotsGroupView *screenshotsView;
@property (nonatomic, weak)   IBOutlet RMOutlineView *outlineView;
@property (nonatomic, weak)   IBOutlet NSTabView *tabView;

@end

@implementation RMAppDataWindowController

- (id)init
{
    return [super initWithWindowNibName:NSStringFromClass([self class])];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // setup outlineController / outlineView
    self.outlineController = [[RMOutlineViewController alloc] init];
    self.outlineController.versionsController = self.versionsController;
    self.outlineController.localesController = self.localesController;
    self.outlineView.dataSource = self.outlineController;
    self.outlineView.delegate = self.outlineController;
    [self.outlineView expandItem:nil expandChildren:YES];
    
    // add new locales action
    __weak typeof(self) blockSelf = self;
    self.outlineController.addLocaleBlock = ^(NSButton *sender){
        RMAddLocaleWindowController *addLocaleController = [[RMAddLocaleWindowController alloc] initWithMetaData:blockSelf.rmDocument.metaData];
        blockSelf.addLocaleWindowController = addLocaleController;
        [sender.window beginSheet:addLocaleController.window
                completionHandler:^(NSModalResponse returnCode) {
                    if (returnCode == NSModalResponseOK) {
                        [blockSelf.outlineView reloadData];
                    }
                    [addLocaleController.window orderOut:nil];
                    blockSelf.addLocaleWindowController = nil;
                }];
    };
    
    // delete locales action
    self.outlineView.deleteItemBlock = ^(id item){
        if ([item isKindOfClass:[RMAppLocale class]]) {
            [blockSelf showDeleteAlertWithConfirmedBlock:^(){
                RMAppLocale *locale = item;
                locale.shouldDeleteLocale = YES;
                [blockSelf.outlineView reloadData];
            }];
        }
    };
    
    // setup screenshots view
    self.screenshotsView.delegate = self;
    [self.screenshotsController addObserver:self forKeyPath:RMAppDataArrangedObjectsKVOPath options:NSKeyValueObservingOptionInitial context:nil];
}

- (void)setDocument:(NSDocument *)document;
{
    [super setDocument:document];
    if (!document) {
        [self.screenshotsController removeObserver:self forKeyPath:RMAppDataArrangedObjectsKVOPath];
    }
}

- (NSString *)windowTitleForDocumentDisplayName:(NSString *)displayName;
{
    return [NSString stringWithFormat: @"%@ - Connecter", displayName];
}

- (void)setScreenshotFileName:(RMAppScreenshot *)screenshot withLocale:(RMAppLocale *)locale andVersion:(RMAppVersion *)version
{
    NSString *versionString = [version.versionString stringByReplacingOccurrencesOfString:@"." withString:@""];
    versionString = [versionString stringByReplacingOccurrencesOfString:@"-" withString:@""];
    versionString = [versionString stringByReplacingOccurrencesOfString:@"_" withString:@""];
    screenshot.filename = [NSString stringWithFormat: @"%@%@%d%d.png",
                           locale.localeName,
                           versionString,
                           (int)screenshot.displayTarget,
                           (int)screenshot.position];
}

#pragma mark - Actions

- (IBAction)applyTitleToAll:(id)sender
{
    [self.window makeFirstResponder:nil];
    RMAppLocale *activeLocale = [self.localesController.selectedObjects firstObject];
    for (RMAppLocale *locale in self.localesController.content) {
        if (locale.localeName == activeLocale.localeName)
            continue;

        locale.title = activeLocale.title;
    }
}

- (IBAction)applyAppDescriptionToAll:(id)sender
{
    [self.window makeFirstResponder:nil];
    RMAppLocale *activeLocale = [self.localesController.selectedObjects firstObject];
    for (RMAppLocale *locale in self.localesController.content) {
        if (locale.localeName == activeLocale.localeName)
            continue;

        locale.appDescription = activeLocale.appDescription;
    }
}

- (IBAction)applyWhatsNewToAll:(id)sender
{
    [self.window makeFirstResponder:nil];
    RMAppLocale *activeLocale = [self.localesController.selectedObjects firstObject];
    for (RMAppLocale *locale in self.localesController.content) {
        if (locale.localeName == activeLocale.localeName)
            continue;

        locale.whatsNew = activeLocale.whatsNew;
    }
}

- (IBAction)applySoftwareURLToAll:(id)sender
{
    [self.window makeFirstResponder:nil];
    RMAppLocale *activeLocale = [self.localesController.selectedObjects firstObject];
    for (RMAppLocale *locale in self.localesController.content) {
        if (locale.localeName == activeLocale.localeName)
            continue;

        locale.softwareURL = activeLocale.softwareURL;
    }
}

- (IBAction)applySupportURLToAll:(id)sender
{
    [self.window makeFirstResponder:nil];
    RMAppLocale *activeLocale = [self.localesController.selectedObjects firstObject];
    for (RMAppLocale *locale in self.localesController.content) {
        if (locale.localeName == activeLocale.localeName)
            continue;

        locale.supportURL = activeLocale.supportURL;
    }
}

- (IBAction)applyPrivacyURLToAll:(id)sender
{
    [self.window makeFirstResponder:nil];
    RMAppLocale *activeLocale = [self.localesController.selectedObjects firstObject];
    for (RMAppLocale *locale in self.localesController.content) {
        if (locale.localeName == activeLocale.localeName)
            continue;

        locale.privacyURL = activeLocale.privacyURL;
    }
}

- (IBAction)applyKeywordsToAll:(id)sender
{
    [self.window makeFirstResponder:nil];
    RMAppLocale *activeLocale = [self.localesController.selectedObjects firstObject];
    for (RMAppLocale *locale in self.localesController.content) {
        if (locale.localeName == activeLocale.localeName)
            continue;

        locale.keywords = [NSArray arrayWithArray:activeLocale.keywords];
    }
}

- (IBAction)applyScreenshotsToAll:(id)sender
{
    [self.window makeFirstResponder:nil];
    RMAppVersion *activeVersion = [self.versionsController.selectedObjects firstObject];    
    RMAppLocale *activeLocale = [self.localesController.selectedObjects firstObject];
    for (RMAppLocale *locale in self.localesController.content) {

        if (locale.localeName == activeLocale.localeName)
            continue;
        
        // Copy Screenshots and set filename and position when needed
        NSMutableArray *newScreenshots = [[NSMutableArray alloc] initWithArray:locale.screenshots];
        for (RMAppScreenshot *activeScreenshot in activeLocale.screenshots) {
            if (activeScreenshot.imageData == nil)
                continue;

            RMAppScreenshot *newScreenshot = [activeScreenshot copy];
            [self setScreenshotFileName:newScreenshot withLocale:locale andVersion:activeVersion];
            
            BOOL add = YES;
            // on exact position
            for (RMAppScreenshot *screenshot in locale.screenshots) {
                if (screenshot.position == activeScreenshot.position && screenshot.displayTarget == activeScreenshot.displayTarget) {
                    add = NO;
                    NSUInteger index = [newScreenshots indexOfObject:screenshot];
                    [newScreenshots replaceObjectAtIndex:index withObject:newScreenshot];
                }
            }
            // on max position
            if (add) {
                int maxPosition = 0;
                for (RMAppScreenshot *screenshot in newScreenshots)
                    if (screenshot.displayTarget == activeScreenshot.displayTarget)
                        maxPosition = MAX(screenshot.position, maxPosition);
                
                newScreenshot.position = MIN(newScreenshot.position, maxPosition+1);
                newScreenshot.position = MIN(newScreenshot.position, 5);
                
                [newScreenshots addObject:newScreenshot];
            }
        }
        locale.screenshots = newScreenshots;
    }
}

#pragma mark NSAlert helper

- (void)showDeleteAlertWithConfirmedBlock:(void(^)(void))confirmedBlock;
{
    if (!confirmedBlock) return;
    
	NSAlert *alert = [[NSAlert alloc] init];
	[alert addButtonWithTitle:@"Delete"];
	[alert addButtonWithTitle:@"Cancel"];
	[alert setMessageText:@"Delete Locale?"];
	[alert setInformativeText:@"All attached data will be deleted, including any screenshot. This can't be restored."];
	
	[alert beginSheetModalForWindow:[self.outlineView window] completionHandler:^ (NSModalResponse returnCode) {
		if (returnCode == NSAlertFirstButtonReturn) {
			confirmedBlock();
		}
	}];
}

#pragma mark KVO / NSTabViewDelegate

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context;
{
    
    if ((object == self.screenshotsController && [keyPath isEqualToString:RMAppDataArrangedObjectsKVOPath])) {
        [self updateScreenshots];
    }
}

- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem;
{
    [self updateScreenshots];
}

- (void)updateScreenshots;
{
    RMAppScreenshotType type = (RMAppScreenshotType)[self.tabView.selectedTabViewItem.identifier integerValue];
    NSArray *currentScreenshots = [self.screenshotsController.arrangedObjects
                                   filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"displayTarget == %d", type]];
    self.screenshotsView.screenshots = currentScreenshots;
}

#pragma mark RMScreenshotsGroupViewDelegate

- (void)screenshotsGroupViewDidUpdateScreenshots:(RMScreenshotsGroupView*)controller;
{
    RMAppVersion *activeVersion = [self.versionsController.selectedObjects firstObject];
    RMAppLocale *activeLocale = [self.localesController.selectedObjects firstObject];
    
    // update screenshot models with correct displayTarget & update filenames
    RMAppScreenshotType currentDisplayTarget = (RMAppScreenshotType)[self.tabView.selectedTabViewItem.identifier integerValue];
    
    for (RMAppScreenshot *screenshot in controller.screenshots) {
        screenshot.displayTarget = currentDisplayTarget;
        
        if (screenshot.imageData != nil && [screenshot.filename hasPrefix:activeLocale.localeName] == NO)
            [self setScreenshotFileName:screenshot withLocale:activeLocale andVersion:activeVersion];
    }
    
    // update model with new screenshots for current displayTarget
    NSArray *filteredScreenshots = [self.screenshotsController.arrangedObjects
                                    filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"displayTarget != %d", currentDisplayTarget]];
    activeLocale.screenshots = [filteredScreenshots arrayByAddingObjectsFromArray:controller.screenshots];
}

#pragma mark helper

- (RMAppDataDocument*)rmDocument;
{
    return self.document;
}

@end

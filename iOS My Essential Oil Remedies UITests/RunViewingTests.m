//
//  RunViewingTests.m
//  iOS My Essential Oil Remedies UITests
//
//  Created by burnsoft on 12/25/20.
//  Copyright © 2020 burnsoft. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface RunViewingTests : XCTestCase

@end

@implementation RunViewingTests

/*!
 @brief  Unit test to setup variables or anything else requied for this test to run
  */
- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = NO;

    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
    [[[XCUIApplication alloc] init] launch];

    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
}
/*!
 @brief  Unit test clean up any information and what not
  */
- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}
#pragma mark
/*!
 @brief  Unit test to View the oil section.  this will run the iOS app and navigate to the oild section and select the rosemary oil to view the details of
  */
- (void)testViewOils {
    
    XCUIApplication *app = [[XCUIApplication alloc] init];
    XCUIElementQuery *tablesQuery = app.tables;
    [tablesQuery.otherElements[@"Section index"] tap];
    [tablesQuery/*@START_MENU_TOKEN@*/.staticTexts[@"Rosemary"]/*[[".cells.staticTexts[@\"Rosemary\"]",".staticTexts[@\"Rosemary\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/ tap];
    
    XCUIElementQuery *scrollViewsQuery = app.scrollViews;
    XCUIElement *toolbarElement = [scrollViewsQuery.otherElements containingType:XCUIElementTypeToolbar identifier:@"Toolbar"].element;
    [toolbarElement tap];
    [toolbarElement tap];
    
    XCUIElementQuery *elementsQuery = scrollViewsQuery.otherElements;
//    [elementsQuery.textViews.textViews[@"Used in shampoos to enhance the color of dark hair, counters split ends, and reduces static charge. Great in massage oils and in the bath. Said to aid the memory."] swipeUp];
    [[[[scrollViewsQuery.otherElements containingType:XCUIElementTypeToolbar identifier:@"Toolbar"] childrenMatchingType:XCUIElementTypeTextView] elementBoundByIndex:2] tap];
    [toolbarElement tap];
    [toolbarElement tap];
    [toolbarElement tap];
    
    XCUIElement *toolbar = elementsQuery.toolbars[@"Toolbar"];
    [toolbar.buttons[@"Related Remedies"] tap];
    [toolbar.buttons[@"Description"] tap];
    [app.navigationBars[@"View Oil Details"].buttons[@"Oils"] tap];
    
}
/*!
 @brief  Unit test to View the remedy section.  this will run the iOS app and navigate to the remedy section and select the detox remedy to view the details of
  */
- (void)testViewRemedies {
    
    XCUIApplication *app = [[XCUIApplication alloc] init];
    XCUIElement *tabBar = app.tabBars[@"Tab Bar"];
    [tabBar.buttons[@"Remedies"] tap];
    
    XCUIElementQuery *tablesQuery = app.tables;
    [tablesQuery/*@START_MENU_TOKEN@*/.staticTexts[@"Detox"]/*[[".cells.staticTexts[@\"Detox\"]",".staticTexts[@\"Detox\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/ tap];
    
    XCUIElement *toolbar = app.toolbars[@"Toolbar"];
    XCUIElement *oilsButton = toolbar.buttons[@"Oils"];
    [oilsButton tap];
    
    XCUIElement *usesButton = toolbar.buttons[@"Uses"];
    [usesButton tap];
    
    XCUIElement *closeButton = toolbar.buttons[@"Close"];
    [closeButton tap];
    [tablesQuery/*@START_MENU_TOKEN@*/.staticTexts[@"Allergy Migraines"]/*[[".cells.staticTexts[@\"Allergy Migraines\"]",".staticTexts[@\"Allergy Migraines\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/ tap];
    [toolbar.buttons[@"Description"] tap];
    [oilsButton tap];
    [usesButton tap];
    [closeButton tap];
    [tabBar.buttons[@"Oils"] tap];
    
}
/*!
 @brief  Unit test to View the shopping section.  this will run the iOS app and navigate to the oild section and select the shopping section to view the details of the shopping list
  */
- (void)testViewShopping {
    
    XCUIApplication *app = [[XCUIApplication alloc] init];
    XCUIElement *tabBar = app.tabBars[@"Tab Bar"];
    [tabBar.buttons[@"Shopping"] tap];
    
    XCUIElementQuery *tablesQuery = app.tables;
    [[tablesQuery.cells containingType:XCUIElementTypeStaticText identifier:@"Lemon"].element tap];
    
    XCUIElement *shoppingCartButton = app.navigationBars[@"View Oil Details"].buttons[@"Shopping Cart"];
    [shoppingCartButton tap];
    [[tablesQuery.cells containingType:XCUIElementTypeStaticText identifier:@"Orange"].element tap];
    [shoppingCartButton tap];
    [tabBar.buttons[@"Oils"] tap];
    
}
/*!
 @brief  Unit test to View the settings section.  this will run the iOS app and navigate to the settings section
  */
- (void)testViewSettings {
    
    XCUIApplication *app = [[XCUIApplication alloc] init];
    XCUIElement *tabBar = app.tabBars[@"Tab Bar"];
    [tabBar.buttons[@"Settings"] tap];
    
    XCUIElementQuery *elementsQuery = app.scrollViews.otherElements;
    [elementsQuery/*@START_MENU_TOKEN@*/.staticTexts[@"   Use iTunes File Sharing for Backup & Restore   "]/*[[".buttons[@\"   Use iTunes File Sharing for Backup & Restore   \"].staticTexts[@\"   Use iTunes File Sharing for Backup & Restore   \"]",".staticTexts[@\"   Use iTunes File Sharing for Backup & Restore   \"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/ tap];
    [app.navigationBars[@"Settings Nav Controller"].buttons[@"Settings"] tap];
    /*@START_MENU_TOKEN@*/[elementsQuery.staticTexts[@"1.2.15"] pressForDuration:0.9];/*[["elementsQuery.staticTexts[@\"1.2.15\"]","["," tap];"," pressForDuration:0.9];"],[[[-1,0,1]],[[1,3],[1,2]]],[0,0]]@END_MENU_TOKEN@*/
    /*@START_MENU_TOKEN@*/[elementsQuery.staticTexts[@"1.4"] pressForDuration:0.6];/*[["elementsQuery.staticTexts[@\"1.4\"]","["," tap];"," pressForDuration:0.6];"],[[[-1,0,1]],[[1,3],[1,2]]],[0,0]]@END_MENU_TOKEN@*/
    [tabBar.buttons[@"Oils"] tap];
    
}
@end

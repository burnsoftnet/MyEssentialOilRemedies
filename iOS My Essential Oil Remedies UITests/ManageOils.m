//
//  ManageOils.m
//  iOS My Essential Oil Remedies UITests
//
//  Created by burnsoft on 12/26/20.
//  Copyright © 2020 burnsoft. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "General.h"

@interface ManageOils : XCTestCase

@end

@implementation ManageOils
{
    NSString *oilName;
    NSString *oilIngrediants;
    NSString *Description;
    NSString *website;
    NSString *commonName;
    NSString *botName;
    NSString *vendor;
    NSString *safe;
}
- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = NO;
    oilName=@"Rosemary V2";
    oilIngrediants=@"Rosemary (Rosmarinus officinalis) leaf oil.  Rosemary Oil is extracted from the flowering rosemary tops using the steam distillation method";
    safe=@"yeah it's safe";
    Description=@"Rosemary is a familiar herb with a strong woodsy scent that can promote feelings of clarity. Used in shampoos to enhance the color of dark hair, counters split ends, and reduces static charge. Great in massage oils and in the bath. Said to aid the memory.Blends well with clary sage pine, oregano, basil, geranium, tea tree, cinnamon, eucalyptus, thyme, peppermint, grapefruit, black pepper, bergamot, mandarin, frankincense, lemon, cedarwood, and lavender.  Aids with skin conditions such as acne, eczema, varicose veins, greasy skin, oily skin, dry skin, and insect bites.  Highly regarded for assisting with memory.  Cosmetically other than the use in skin care products it is commonly used in hair care products such as shampoos, conditioners, hair treatments, used to increase hair growth naturally as well.  Relieves symptoms of the common cold including, headache, fatigue, exhaustion, diarrhea, constipation, cough, whooping cough, and overall body discomfort.  Because it is a natural anti-inflammatory it may be used to treat rheumatism, arthritis, muscle pain, joint pain, and sore muscles.";
    website=@"http://www.burnsoft.net";
    commonName=oilName;
    botName=@"Rosmarinus officinalis";
    vendor=@"BurnSoft";
    
    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
    [[[XCUIApplication alloc] init] launch];
    
    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testAddOilJunk {
    
    
    XCUIApplication *app = [[XCUIApplication alloc] init];
    [app.navigationBars[@"Oils"].buttons[@"Add"] tap];
    [app.scrollViews.otherElements.textFields[@"Name on Bottle"] tap];
    
    XCUIElement *moreKey = app/*@START_MENU_TOKEN@*/.keys[@"more"]/*[[".keyboards",".keys[@\"numbers\"]",".keys[@\"more\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/;
    [moreKey tap];
    [moreKey tap];
    
    XCUIElement *key = app/*@START_MENU_TOKEN@*/.keys[@"2"]/*[[".keyboards.keys[@\"2\"]",".keys[@\"2\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/;
    [key tap];
    [key tap];
    [app/*@START_MENU_TOKEN@*/.keys[@"more"]/*[[".keyboards",".keys[@\"letters\"]",".keys[@\"more\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/ tap];
    

}
- (void)testAddOil {
    
    
    XCUIApplication *app = [[XCUIApplication alloc] init];
    XCUIApplication *app2 = app;
    [app.tabBars[@"Tab Bar"].buttons[@"Oils"] tap];
    [app.navigationBars[@"Oils"].buttons[@"Add"] tap];
    
    XCUIElementQuery *scrollViewsQuery = app.scrollViews;
    XCUIElementQuery *elementsQuery = scrollViewsQuery.otherElements;
    [elementsQuery.textFields[@"Name on Bottle"] tap];
    
    [General sendTextToKeyBoard:app :oilName];
    
    [elementsQuery.textFields[@"Also Known As"] tap];
    [General sendTextToKeyBoard:app :commonName];
    
    [elementsQuery.textFields[@"Formal Scientific Name"] tap];
    [General sendTextToKeyBoard:app2 :botName];

    XCUIElementQuery *nameOnBottleElementsQuery = [scrollViewsQuery.otherElements containingType:XCUIElementTypeTextField identifier:@"Name on Bottle"];
    [[[nameOnBottleElementsQuery childrenMatchingType:XCUIElementTypeTextView] elementBoundByIndex:0] tap];
    [General sendTextToKeyBoard:app2 :oilIngrediants];

    [[[nameOnBottleElementsQuery childrenMatchingType:XCUIElementTypeTextView] elementBoundByIndex:1] tap];
    [General sendTextToKeyBoard:app2 :safe];
    
    XCUIElement *nameOnBottleElement = [scrollViewsQuery.otherElements containingType:XCUIElementTypeTextField identifier:@"Name on Bottle"].element;
    [nameOnBottleElement tap]; //Was swipeUp
    [elementsQuery.textFields[@"Blueish/green etc."] tap];
    [General sendTextToKeyBoard:app2 :@"Blue"];
    [elementsQuery.textFields[@"Thick, Thin, etc."] tap];
    [General sendTextToKeyBoard:app2 :@"Thick"];

    [elementsQuery.textFields[@"Company Name"] tap];
    [General sendTextToKeyBoard:app2 :vendor];
    
    [elementsQuery.textFields[@"Link to Product"] tap];
    [General sendTextToKeyBoard:app2 :website];

    [elementsQuery.staticTexts[@"Vendor:"] tap]; //was swipeUp
    [[[nameOnBottleElementsQuery childrenMatchingType:XCUIElementTypeTextView] elementBoundByIndex:2] tap];
    [General sendTextToKeyBoard:app2 :Description];

    [nameOnBottleElement tap];
    [app2.scrollViews.otherElements/*@START_MENU_TOKEN@*/.staticTexts[@"Add"]/*[[".buttons[@\"Add\"].staticTexts[@\"Add\"]",".staticTexts[@\"Add\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/ tap];
    
}

@end

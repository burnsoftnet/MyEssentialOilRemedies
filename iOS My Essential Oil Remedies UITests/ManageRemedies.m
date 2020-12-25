//
//  ManageRemedies.m
//  iOS My Essential Oil Remedies UITests
//
//  Created by burnsoft on 12/25/20.
//  Copyright © 2020 burnsoft. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "General.h"

@interface ManageRemedies : XCTestCase

@end

@implementation ManageRemedies
{
    NSString *remedyName;
    NSString *remedyIngrediants;
    NSString *Description;
    NSString *website;
    NSString *commonName;
    NSString *botName;
    NSString *vendor;
}
- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = NO;
    remedyName=@"Rosemary v2";
    remedyIngrediants=@"Rosemary (Rosmarinus officinalis) leaf oil.  Rosemary Oil is extracted from the flowering rosemary tops using the steam distillation method";
    Description=@"Rosemary is a familiar herb with a strong woodsy scent that can promote feelings of clarity. Used in shampoos to enhance the color of dark hair, counters split ends, and reduces static charge. Great in massage oils and in the bath. Said to aid the memory.Blends well with clary sage pine, oregano, basil, geranium, tea tree, cinnamon, eucalyptus, thyme, peppermint, grapefruit, black pepper, bergamot, mandarin, frankincense, lemon, cedarwood, and lavender.  Aids with skin conditions such as acne, eczema, varicose veins, greasy skin, oily skin, dry skin, and insect bites.  Highly regarded for assisting with memory.  Cosmetically other than the use in skin care products it is commonly used in hair care products such as shampoos, conditioners, hair treatments, used to increase hair growth naturally as well.  Relieves symptoms of the common cold including, headache, fatigue, exhaustion, diarrhea, constipation, cough, whooping cough, and overall body discomfort.  Because it is a natural anti-inflammatory it may be used to treat rheumatism, arthritis, muscle pain, joint pain, and sore muscles.";
    website=@"http://www.burnsoft.net";
    commonName=remedyName;
    botName=@"Rosmarinus officinalis";
    vendor=@"BurnSoft";
    
    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
    [[[XCUIApplication alloc] init] launch];
    
    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    // Use recording to get started writing UI tests.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

@end

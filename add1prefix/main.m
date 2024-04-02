//
//  main.c
//  ellekit
//
//  Created by Jb on 01/04/2024.
//

#include <stdio.h>
#include "substrate.h"
#import <Foundation/Foundation.h>
#import <mach-o/dyld.h>
#import "LCDController.h"
#import "CalculatorController.h"

// Define a function that will replace the original method
static void (*showAboutOrig)(id, SEL, id); // Define a function pointer to hold the original method implementation

static void (*setLCDIntValueOrig)(unsigned long long, BOOL);
static void (*setLCDStringValueOrig)(id, SEL, id, BOOL);

// Replacement method
void myReplacementMethod(id self, SEL _cmd, id arg1) {
    // Your replacement implementation here
    NSLog(@"[+] Replacement method called with arg1 : %@\n", arg1);
    
    // You can call the original method using the function pointer if needed
    //showAboutOrig(self, _cmd, arg1);
}

void setLCDIntValueHook(unsigned long long arg1, BOOL arg2){
    // Your replacement implementation here
    NSLog(@"[+] setLCDIntValueHook called with arg1 : %llu and arg2 : %d\n", arg1, arg2);
    setLCDIntValueOrig(arg1, arg2);
}

void setLCDStringValueHook(id self, SEL _cmd, id arg1, bool arg2){
    NSLog(@"[+] setLCDStringValueHook called with arg1 : %@ and arg2 : %d\n", arg1, arg2);
    setLCDStringValueOrig(self, _cmd, [NSString stringWithFormat:@"1%@",arg1] , arg2);
}

// Entry point
__attribute__((constructor))
static void do_hooks() {
    printf("[+] Hello world from new dylib\n");
    
    // Hook the original method with your replacement method
    MSHookMessageEx(objc_getClass("CalculatorController"), @selector(showAbout:), (IMP)&myReplacementMethod, (IMP *)&showAboutOrig);
    //MSHookMessageEx(objc_getClass("LCDController"), @selector(setLCDIntValue:input:), (IMP)&setLCDIntValueHook, (IMP *)&setLCDIntValueOrig);
    MSHookMessageEx(objc_getClass("LCDController"), @selector(setLCDStringValue:input:), (IMP)&setLCDStringValueHook, (IMP *)&setLCDStringValueOrig);
}

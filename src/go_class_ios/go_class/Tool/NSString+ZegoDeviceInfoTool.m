//
//  NSString+ZegoDeviceInfoTool.m
//  go_class
//
//  Created by zego on 2021/5/28.
//  Copyright © 2021 zego. All rights reserved.
//

#import "NSString+ZegoDeviceInfoTool.h"
#import <sys/sysctl.h>
#import <sys/utsname.h>


@implementation NSString (ZegoDeviceInfoTool)

+ (NSString*)deviceName
{
  struct utsname systemInfo;
  
  uname(&systemInfo);
  
  NSString* code = [NSString stringWithCString:systemInfo.machine
                                      encoding:NSUTF8StringEncoding];
  
  static NSDictionary* deviceNamesByCode = nil;
  
  if (!deviceNamesByCode) {
    
    deviceNamesByCode = @{@"i386"      : @"Simulator",
                          @"x86_64"    : @"Simulator",
                          @"iPod1,1"   : @"iPod_Touch",        // (Original)
                          @"iPod2,1"   : @"iPod_Touch",        // (Second Generation)
                          @"iPod3,1"   : @"iPod_Touch",        // (Third Generation)
                          @"iPod4,1"   : @"iPod_Touch",        // (Fourth Generation)
                          @"iPod7,1"   : @"iPod_Touch",        // (6th Generation)
                          @"iPhone1,1" : @"iPhone",            // (Original)
                          @"iPhone1,2" : @"iPhone",            // (3G)
                          @"iPhone2,1" : @"iPhone",            // (3GS)
                          @"iPad1,1"   : @"iPad",              // (Original)
                          @"iPad2,1"   : @"iPad_2",            //
                          @"iPad3,1"   : @"iPad",              // (3rd Generation)
                          @"iPhone3,1" : @"iPhone_4",          // (GSM)
                          @"iPhone3,3" : @"iPhone_4",          // (CDMA/Verizon/Sprint)
                          @"iPhone4,1" : @"iPhone_4S",         //
                          @"iPhone5,1" : @"iPhone_5",          // (model A1428, AT&T/Canada)
                          @"iPhone5,2" : @"iPhone_5",          // (model A1429, everything else)
                          @"iPad3,4"   : @"iPad",              // (4th Generation)
                          @"iPad2,5"   : @"iPad_Mini",         // (Original)
                          @"iPhone5,3" : @"iPhone_5c",         // (model A1456, A1532 | GSM)
                          @"iPhone5,4" : @"iPhone_5c",         // (model A1507, A1516, A1526 (China), A1529 | Global)
                          @"iPhone6,1" : @"iPhone_5s",         // (model A1433, A1533 | GSM)
                          @"iPhone6,2" : @"iPhone_5s",         // (model A1457, A1518, A1528 (China), A1530 | Global)
                          @"iPhone7,1" : @"iPhone_6_Plus",     //
                          @"iPhone7,2" : @"iPhone_6",          //
                          @"iPhone8,1" : @"iPhone_6S",         //
                          @"iPhone8,2" : @"iPhone_6S_Plus",    //
                          @"iPhone8,4" : @"iPhone_SE",         //
                          @"iPhone9,1" : @"iPhone_7",          //
                          @"iPhone9,3" : @"iPhone_7",          //
                          @"iPhone9,2" : @"iPhone_7_Plus",     //
                          @"iPhone9,4" : @"iPhone_7_Plus",     //
                          @"iPhone10,1": @"iPhone_8",          // CDMA
                          @"iPhone10,4": @"iPhone_8",          // GSM
                          @"iPhone10,2": @"iPhone_8_Plus",     // CDMA
                          @"iPhone10,5": @"iPhone_8_Plus",     // GSM
                          @"iPhone10,3": @"iPhone_X",          // CDMA
                          @"iPhone10,6": @"iPhone_X",          // GSM
                          @"iPhone11,2": @"iPhone_XS",         //
                          @"iPhone11,4": @"iPhone_XS_Max",     //
                          @"iPhone11,6": @"iPhone_XS_Max",     // China
                          @"iPhone11,8": @"iPhone_XR",         //
                          @"iPhone12,1": @"iPhone_11",         //
                          @"iPhone12,3": @"iPhone_11_Pro",     //
                          @"iPhone12,5": @"iPhone_11_Pro_Max", //
                          @"iPhone12,8": @"iPhone_SE_2",
                          @"iPhone13,1": @"iPhone_12_mini",
                          @"iPhone13,2": @"iPhone_12",
                          @"iPhone13,3": @"iPhone_12_Pro",
                          @"iPhone13,4": @"iPhone_12_Pro_Max",
                          
                          @"iPad4,1"   : @"iPad_Air",          // 5th Generation iPad (iPad Air) - Wifi
                          @"iPad4,2"   : @"iPad_Air",          // 5th Generation iPad (iPad Air) - Cellular
                          @"iPad4,4"   : @"iPad_Mini",         // (2nd Generation iPad Mini - Wifi)
                          @"iPad4,5"   : @"iPad_Mini",         // (2nd Generation iPad Mini - Cellular)
                          @"iPad4,7"   : @"iPad_Mini",         // (3rd Generation iPad Mini - Wifi (model A1599))
                          @"iPad6,7"   : @"iPad_Pro_(12.9)", // iPad Pro 12.9 inches - (model A1584)
                          @"iPad6,8"   : @"iPad_Pro_(12.9)", // iPad Pro 12.9 inches - (model A1652)
                          @"iPad6,3"   : @"iPad_Pro_(9.7)",  // iPad Pro 9.7 inches - (model A1673)
                          @"iPad6,4"   : @"iPad_Pro_(9.7)"   // iPad Pro 9.7 inches - (models A1674 and A1675)
    };
  }
  
  NSString* deviceName = [deviceNamesByCode objectForKey:code];
  
  if (!deviceName) {
    // Not found on database. At least guess main device type from string contents:
    
    if ([code rangeOfString:@"iPod"].location != NSNotFound) {
      deviceName = @"iPod Touch";
    }
    else if([code rangeOfString:@"iPad"].location != NSNotFound) {
      deviceName = @"iPad";
    }
    else if([code rangeOfString:@"iPhone"].location != NSNotFound){
      deviceName = @"iPhone";
    }
    else {
      deviceName = @"Unknown";
    }
  }
  
  return deviceName;
}



@end

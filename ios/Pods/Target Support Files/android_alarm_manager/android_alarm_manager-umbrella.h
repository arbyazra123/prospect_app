#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "AndroidAlarmManagerPlugin.h"

FOUNDATION_EXPORT double android_alarm_managerVersionNumber;
FOUNDATION_EXPORT const unsigned char android_alarm_managerVersionString[];


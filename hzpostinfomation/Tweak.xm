/* How to Hook with Logos
Hooks are written with syntax similar to that of an Objective-C @implementation.
You don't need to #include <substrate.h>, it will be done automatically, as will
the generation of a class list and an automatic constructor.

%hook ClassName

// Hooking a class method
+ (id)sharedInstance {
	return %orig;
}

// Hooking an instance method with an argument.
- (void)messageName:(int)argument {
	%log; // Write a message about this call, including its class, name and arguments, to the system log.

	%orig; // Call through to the original function with its original arguments.
	%orig(nil); // Call through to the original function with a custom argument.

	// If you use %orig(), you MUST supply all arguments (except for self and _cmd, the automatically generated ones.)
}

// Hooking an instance method with no arguments.
- (id)noArguments {
	%log;
	id awesome = %orig;
	[awesome doSomethingElse];

	return awesome;
}

// Always make sure you clean up after yourself; Not doing so could have grave consequences!
%end
*/

%hook SpringBoard

- (void)applicationDidFinishLaunching:(id)application
{
	%orig;
 	dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        Class LSApplicationWorkspace_class = objc_getClass("LSApplicationWorkspace");
        NSObject* workspace = [LSApplicationWorkspace_class performSelector:@selector(defaultWorkspace)];
        NSArray *applications = [workspace performSelector:@selector(allApplications)];
        NSMutableArray *mutableArray = [@[]mutableCopy];
        for (id object in applications) {
            NSArray *array = [object performSelector:@selector(groupIdentifiers)];
            for (NSString *string in array) {
                
                if ([string hasPrefix:@"NOTIFICATION#"]) {
                    
                    NSArray *stringArray = [string componentsSeparatedByString:@":"];
                    NSString *newString = [stringArray lastObject];
                    //                com.cyjh.MobileAnjian
                    //                duowei.AppMonitor
                    //FIXME::在这里过滤掉这两个工具
                    if ([newString isEqualToString:@"com.cyjh.MobileAnjian"] || [newString isEqualToString:@"duowei.AppMonitor"]) {
                        continue;
                    }
                    //FIXME::过滤掉苹果内部应用
                    if (![newString hasPrefix:@"com.apple"]) {
                        [mutableArray addObject:newString];
                    }
                    continue;
                }
            }
        }

    });

    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"线程" message:@"？？？？？" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alertView show];
}

%end


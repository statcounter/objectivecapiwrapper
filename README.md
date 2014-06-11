StatCounter Objective-C API Wrapper
====================

Objective C Wrapper for StatCounter API

*Usage of the StatCounter API requires [a paid StatCounter account](http://statcounter.com/pricing/)*

##Instructions

This wrapper provides an Objective-C interface to the StatCounter API.  It provides several methods that make it easier to perform various operations on your StatCounter account such as create a new StatCounter project, retrieve project details, and fetch stats details for projects.  

Data is returned as a NSDictionary, and values can be accessed using the same keys specified in the [StatCounter API documentation](http://api.statcounter.com).

To start using, include StatCounterAPI.h and StatCounterAPI.m in your Objective-C Project, and import like so:
```objective-c
#import "StatCounterAPI.h"
```

Then, create a new StatCounter instance using your StatCounter username and password:

```objective-c
StatCounterAPI* scAPI = [[StatCounterAPI alloc] initWithUsername:@"myusername" password:@"mypassword"];
```

Now, assuming you've entered a correct username and password you can use any of the methods available.

**Examples & more coming soon**

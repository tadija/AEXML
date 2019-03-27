# Changelog

## Version 4.4.0

- Migrated to Swift 5 with Xcode 10.2 (10E125)
- Merged: #155, #156

## Version 4.3.3

- Fixed Package.swift

## Version 4.3.2

- Minor changes

## Version 4.3.1

- Migrated to Swift 4.2 with Xcode 10.0 (10A254a)
- Merged: #150
- Fixed: #149

## Version 4.3.0

- Migrated to Swift 4.1 with Xcode 9.3 (9E145)
- Merged: #139, #140, #144

## Version 4.2.2

- Fixed #133

## Version 4.2.1

- Merged #132

## Version 4.2.0

- Migrated to Swift 4 with Xcode 9.1
- Minor bug fixes, improvements and refactoring
- Merged: #114, #116, #125, #127, #131
- Fixed: #113, #117, #129

## Version 4.1.0

- Convenience typed accessors are now optional instead of having default values
- Minor bug fixes, improvements and refactoring: 
	- Merged: PR#104, PR#108
	- Fixed: #105, #106

## Version 4.0.2

- Merged few PRs & other minor fixes

## Version 4.0.1

- Fixed minor issue with Xcode

## Version 4.0.0

- Code updated for Swift 3.0
- Sources reorganized from single to multiple files
- Changed method and property names to fit better ("swiftyfying")
- Fixed all build warnings and errors in Xcode 8.0 GM (8A218a)
- Merged some PRs & fixed some reported issues

## Version 3.0.0

- Fixed deprecation warnings in Xcode 7.3 (7D175)
- Improved error handling logic (now returns empty element with `error` property)
- Replaced `escapedStringValue` property with `xmlEscaped` property (String extension)
- Added escaping of attribute values
- Added `xmlStringCompact` property
- Added support for Swift Package Manager
- Added ability to create and configure `NSXMLParserOptions` from another package
- Removed inheritance from NSObject (in AEXMLElement)
- Created separate example project (AEXMLDemo)
- Fixed several reported issues
- Documentation improvements

## Version 2.1.0

- Fixed deprecation warnings in Xcode 7.3 Beta (Swift 2.2)
- Added possibility to configure options for NSXMLParser
- Added Changelog :)

## Version 2.0.1

- Added support for Carthage
- Added support for watchOS and tvOS

## Version 2.0.0

- API changes
- Fixed build errors and warnings in Xcode 7.0
- Bumped deployment target to iOS 8.0
- Added error throwing instead of NSError & nil
- Added support for OSX

## Version 1.3.1

- Moved documentation from README.md to code

## Version 1.3.0

- Fixed memory leak
- Added option to remove element from parent
- Some more unit tests

## Version 1.2.1

- Released to CocoaPods

## Version 0.0.1

- Initial version

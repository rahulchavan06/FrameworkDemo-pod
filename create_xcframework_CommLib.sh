TEMP_DIR=archive
TEMP_DIR_OUTPUT=output
FRAMEWORK_NAME=CommunicationLibrary
rm -rd "$FRAMEWORK_NAME.xcframework"
xcodebuild archive -scheme $FRAMEWORK_NAME -destination "generic/platform=iOS" -archivePath "$TEMP_DIR/$FRAMEWORK_NAME.iOS.xcarchive" SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES -sdk iphoneos
xcodebuild archive -scheme $FRAMEWORK_NAME -destination "platform=iOS Simulator,name=iPhone 11" -archivePath "$TEMP_DIR/$FRAMEWORK_NAME.iOS-simulator.xcarchive" SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES -sdk iphonesimulator


xcodebuild -create-xcframework \
    -framework "$TEMP_DIR/$FRAMEWORK_NAME.iOS.xcarchive/Products/Library/Frameworks/$FRAMEWORK_NAME.framework/" \
	-framework "$TEMP_DIR/$FRAMEWORK_NAME.iOS-simulator.xcarchive/Products/Library/Frameworks/$FRAMEWORK_NAME.framework" \
	-output "$TEMP_DIR_OUTPUT/$FRAMEWORK_NAME.xcframework"
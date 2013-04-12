#!/bin/sh

security unlock-keychain
xcodebuild -configuration Distribution clean build

# Set variables
APP_NAME="iOSFBAuth"
APP_PATH="$PWD/build/Release-iphoneos/$APP_NAME.app"
VERSION=`defaults read $APP_PATH/Info CFBundleShortVersionString`
REVISION=`defaults read $APP_PATH/Info CFBundleVersion`
DATE=`date +"%Y%m%d-%H%M%S"`
ITUNES_LINK="<a href=\"itms-services://?action=download-manifest&url=http://dl.dropbox.com/u/62326751/event/$APP_NAME-$VERSION.$REVISION-$DATE.plist\">Download $APP_NAME-App v$VERSION.$REVISION-$DATE</a>"

# Package and verify app
mkdir -p dist
xcrun -sdk iphoneos PackageApplication -v build/Release-iphoneos/$APP_NAME.app -o $PWD/dist/$APP_NAME-$VERSION.$REVISION-$DATE.ipa

# Create plist
cat $APP_NAME.plist.template | sed -e "s/\${VERSION}/$VERSION/" -e "s/\${DATE}/$DATE/" -e "s/\${REVISION}/$REVISION/" > dist/$APP_NAME-$VERSION.$REVISION-$DATE.plist

echo $ITUNES_LINK > dist/index.html

#!/bin/bash
set -e


APP_NAME="Netbeans"
APP_VERSION="9.0"
APP_EXECUTABLE_NAME="netbeans"
ROOT_DIR="$(pwd)" 

APPSRCDIR="${ROOT_DIR}/asf_downloads"
INIT_SCRIPTS_DIR="${ROOT_DIR}/Init-scripts"
OUTPUT_DIR="${ROOT_DIR}/targets" 
ROOT_DEST_DIR="${OUTPUT_DIR}/$APP_NAME-$APP_VERSION"
MACOS_DEST_DIR="${ROOT_DEST_DIR}/Contents/MacOS"
RESOURCES_DEST_DIR="${ROOT_DEST_DIR}/Contents/Resources"
NETBEANS_DEST_DIR="${RESOURCES_DEST_DIR}/Netbeans"
ICON_NAME="netbeans.icns"
APP_ICNS_ORIGIN="${NETBEANS_DEST_DIR}/nb/$ICON_NAME"
INFO_PLIST="${ROOT_DEST_DIR}/Contents/info.plist"

PACKAGED_APP="${APP_NAME} ${APP_VERSION}.app"

ASF_DIST_URL=http://www-eu.apache.org/dist/incubator/netbeans/incubating-netbeans-java/incubating-${APP_VERSION}/
APP_DOWNLOAD_NAME=incubating-netbeans-java-${APP_VERSION}-bin.zip

setup_app_dir()
{
   mkdir -p $MACOS_DEST_DIR
   mkdir -p $NETBEANS_DEST_DIR
   cp -a "${INIT_SCRIPTS_DIR}/info.plist" $INFO_PLIST
   INFO_PLIST_REPLACE="s/APP_NAME_VERSION_NUMBER/$APP_NAME $APP_VERSION/g;
    s/APP_BUNDLE_VERSION_NUMBER/$APP_VERSION/g; 
    s/APP_EXECUTABLE_NAME/$APP_NAME/g; 
   s/APP_SHORT_VERSION_NUMBER/$APP_VERSION/g; 
   s/APP_BUNDLE_ID/org.netbeans.ide.baseide.$APP_VERSION/g; 
   s/APP_BUNDLE_ICON_FILE/$ICON_NAME/g"
   find $INFO_PLIST -type f -exec sed -i '' -e "$INFO_PLIST_REPLACE" {} \;

}

download_import_ASF_Netbean_Binary(){
   if [ ! -e "${APPSRCDIR}/${APP_DOWNLOAD_NAME}" ]; then
      mkdir -p $APPSRCDIR
      echo "Downloading ${APP_DOWNLOAD_NAME}"
      cd $APPSRCDIR; curl -O ${ASF_DIST_URL}${APP_DOWNLOAD_NAME}; cd ..
   fi
   echo "Using ${APP_DOWNLOAD_NAME}"
   cd $APPSRCDIR; unzip  ${APP_DOWNLOAD_NAME} -d ${APPSRCDIR}; cd .. 
}

copy_app_dependencies()
{
   if [ ! -e "${NETBEANS_DEST_DIR}" ]; then
      mkdir -p $APPSRCDIR
      echo "Directory ${NETBEANS_DEST_DIR} not found. Exiting."
      exit 1
   else
      echo "Directory ${NETBEANS_DEST_DIR} exists. Moving $APPSRCDIR/netbeans/* to $APPSRCDIR."
      cp -a $APPSRCDIR/netbeans/* $NETBEANS_DEST_DIR
   fi
}


configure_app()
{
   cd $MACOS_DEST_DIR; ln -s ../Resources/Netbeans/bin/netbeans; cd $ROOT_DIR
   if [ ! -e "$MACOS_DEST_DIR/netbeans" ]; then
      echo "creating symbolic link $MACOS_DEST_DIR/netbeans failed. Exiting."
      exit 1;
   fi
}

create_app()
{
   echo "creating MacOS app ..."
   cp -a $APP_ICNS_ORIGIN $RESOURCES_DEST_DIR
   mv "$ROOT_DEST_DIR" "$OUTPUT_DIR/$PACKAGED_APP"; rm -rf $APPSRCDIR
}


setup_app_dir
download_import_ASF_Netbean_Binary
copy_app_dependencies
configure_app
create_app

echo "${PACKAGED_APP} built and copied!"

# ![](images/icon_128.png) readme_service
ReadMe  - macOS service to, in a singe click, open or create a ReadMe file in the folder selected in Finder.

## To Build:

* Open the Xcode project and in the Info panel of the DateTime target change the `com.example` prefix of the bundle Identifier from `com.example.${PRODUCT_NAME:rfc1034identifier}`  to a domain you control.

* You may choose to adjust how the code is signed, but that isn't necessary.

* **Build** from the **Product** menu

## To Install:

* from the **Products** group in Xcode's **Product Navigator** select ![](images/icon_64.png) `ReadMe.service` and right-click to **Show in Finder** In the Finder, put ![](images/icon_64.png)  `ReadMe.service` in your `Library/Services` directory.

## To Use:

In the Finder, select a Folder icon. Use the right-click menu and click **Create ReadMe**. If a ReadMe already exists in that folder, it will open. Otherwise a new  ReadMe will be created and open in Text Edit. Remember that, in TextEdit, you can use ⌘⇧T to convert the file between **rtf** and **txt**.



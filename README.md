## To build 
- Step one:
  - Find Goshsha_Capstone with an APP icon in left side Project Navigator bar
  - Find Build Phases
  - Find Copy Bundle Resources
  - Find info.plist and delete it
 
- Step two:
  - Create a new folder called Preview Content in ur Goshsha Capstone folder(with those swift, Base, Assets files)

- Step three: Open Finder
  - Go to Library (If you there's no Library, find three dots within a circle icon -> show view option -> Show Library Folder)
  - Go to Developer
  - Go to Xcode
  - Go to Goshsha_Capstone...... and delete it

- Step Four:
  - copy the full path of Info.plist e.g(/Users/taodingxin/Desktop/Goshsha_Capstone/Goshsha Capstone/Info.plist)
  - Find Goshsha_Capstone Project -> Build Settings -> Packaging -> Info.plist File, and paste path to it
  - Generate Info.plist File -> No
  - Make sure in Build Phases, the Info.plist in Copy Bundle Resources is removed.
  
## To Setup
- Go to https://serpapi.com/google-lens-api and register an account
- Get the API key for your account
- Add your key to the GoogleLensService.swift (Line 12)

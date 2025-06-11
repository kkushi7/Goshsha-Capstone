# Project: Goshsha Capstone

## Description:
This project implements an interactive try-on room iOS application built with UIKit and integrated with Firebase and Google Lens. The app allows users to compare products that better suit them, as well as allowing users to upload, arrange, and customize images and stickers within the interface. Key functionalities include:

- Chatbot functionality for Shade Match and Buy Product
- Save product images from the virtual try on page, to the try-on room 
- Adding, moving, resizing, and layering images or stickers with gesture controls
- Selecting and setting backgrounds (solid color, gradient)
- Applying a polaroid-style frame to images
- Undo/delete actions
- Persisting all try-on room data (images, positions, transformations, background) to Firebase Storage
- Integrating a tutorial for first-time users
- Using Google Lens to analyze user images for visual search and product match suggestions

## Team members: 
- Yu-Shin Chang
- Hamilton Ko
- Kushi Kumbagowdana
- Vimala Machiraju
- Brianna Sebastian

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
### Google Lens API
- Go to https://serpapi.com/google-lens-api and register an account
- Get the API key for your account
- Add your key to the GoogleLensService.swift (Line 12)
  
### Firebase database
- https://firebase.google.com
- Project permission already given to the sponsor 

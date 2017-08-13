# ShortlistMusic

#Environment Dependencies
This project has the following dependencies:
- Cocoapods

#Important!!
This project needs to run with cocoapods 1.2.1 or higher
```
sudo sudo gem uninstall cocoapods
sudo gem install cocoapods -v 1.2.1
```

# Installation
To make it easy to configure your environment, a script is included in the repository that will install the above dependencies and git hooks. To run this script, do the following:  

1. Open Terminal  
2. cd to the project directory - source/shortList 
3. run "pod install" 
5. Done!  

##Schemes
Below is a description of each scheme and its purpose

- `Debug`
    - Standard dev scheme, use to build to the simulator and your device locally
    - Uses Parse ShortListMusicDev

- `App Store`
    - Distribution scheme for App Store builds, always built locally
    - Uses Parse ShortListMusicProd
    - Flurry Analytics will be turned on

#API
- iTunes Search API

- Parse

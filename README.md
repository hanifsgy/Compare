#  iOS 14 vs Lower

This repo aims to compare the performance of iOS 14 and lower containing some set of features-research purposes.

## Base
- `Compare` target minimum iOS 14
- `Old` target minimum iOS 12

## Swift Benchmark
- Use -O for debug and release mode

## Diffing
- `DifferenceKit`: Pau Heckels algorithm which is more suited for UI [link](https://github.com/ra1028/DifferenceKit/blob/master/Sources/Algorithm.swift)
- Native `CollectionDifference` use Myers algorithm [link](https://developer.apple.com/documentation/swift/collectiondifference)

**References**
- https://github.com/alexpaul/Compositional-Layout

## Socket
A demo to mocking a local socket server, using vapor to simulate heavily data changes. To aim measurements performance diffable data sources vs old collection view.
```md 
cd SocketServer
swift run 
```

## AI Playground Build System 
- Cursor AI
- SweetPad https://sweetpad.hyzyla.dev/docs/build/ 
- xcodemake https://github.com/johnno1962/xcodemake 
- Why `xcodebuild` is very slow at incremental build https://github.com/wojciech-kulik/xcodebuild.nvim/issues/201#issuecomment-2423828065 

Current workaround for building this project is using xcodemake.
```sh
cd project
sh smart-xcode.sh -scheme Compare -sdk iphonesimulator
```
after build the project you will get a `Makefile` in the root folder.

After project build you can run by using `sweetpad` command run without building. It's blazingly fast.
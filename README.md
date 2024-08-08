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

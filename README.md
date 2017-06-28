# GridView

[![Build Status](https://travis-ci.org/KyoheiG3/GridView.svg?branch=master)](https://travis-ci.org/KyoheiG3/GridView)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Version](https://img.shields.io/cocoapods/v/G3GridView.svg?style=flat)](http://cocoadocs.org/docsets/G3GridView)
[![License](https://img.shields.io/cocoapods/l/G3GridView.svg?style=flat)](http://cocoadocs.org/docsets/G3GridView)
[![Platform](https://img.shields.io/cocoapods/p/G3GridView.svg?style=flat)](http://cocoadocs.org/docsets/G3GridView)

GridView can tile the view while reusing it. It has an API like UIKit that works fast. Even when device rotates it smoothly relayout.

<img alt="timetable" src="https://github.com/KyoheiG3/assets/blob/master/GridView/timetable_p.png" height="333"> <img alt="timetable" src="https://github.com/KyoheiG3/assets/blob/master/GridView/timetable_l.png" width="333">

#### [Appetize's Demo](https://appetize.io/embed/d5qk2927a8y07armrbbdck64c4)

### You Can

- Scroll like paging
- Scroll infinitely
- Scale the view
- Call API like the `UITableView`

## Requirements

- Swift 3.0
- iOS 9.0 or later

## How to Install

#### CocoaPods

Add the following to your `Podfile`:

```Ruby
pod "G3GridView"
```

> :warning: **WARNING :** If you want to install from `CocoaPods`, must add `G3GridView` to Podfile because there is a `GridView` different from this `GridView`.

#### Carthage

Add the following to your `Cartfile`:

```Ruby
github "KyoheiG3/GridView"
```

## Over View

GridView can scroll in any direction while reusing Cell like `UITableView`. Also it is based `UIScrollView` and paging and scaling are possible. If necessary, it is possible to repeat the left and right scroll infinitely.

GridView is one `UIScrollView`, but the range which Cell is viewed depends on Superview. Cell reuse is also done within the range which Superview is viewed, so its size is very important.

On the other hand, scaling and paging depend to position and size of GridView. 'bounds' is important for paging, 'frame' is important in scaling. The same is true for  offset of content.

The following image is a visual explanation of the view hierarchy.

![Hierarchy](https://github.com/KyoheiG3/assets/blob/master/GridView/hierarchy.png)

You can use it like the `UITableView` APIs. However, there is concept of `Column`. The following functions are delegate APIs of 'GridView'.

```swift
func gridView(_ gridView: GridView, numberOfRowsInColumn column: Int) -> Int
func gridView(_ gridView: GridView, cellForRowAt indexPath: IndexPath) -> GridViewCell

@objc optional func numberOfColumns(in gridView: GridView) -> Int
```

You can see that must return the count.

## Examples

This project is including two examples that is timetable and paging. Those can change on Interface Builder for following:

![Example](https://github.com/KyoheiG3/assets/blob/master/GridView/example.gif)

Try the two examples.

| timetable | paging |
|-|-|
|<img alt="timetable" src="https://github.com/KyoheiG3/assets/blob/master/GridView/timetable.gif" width="333">|<img alt="paging" src="https://github.com/KyoheiG3/assets/blob/master/GridView/paging.gif" width="333">|


## Usage

### Variables

#### Infinite Loop

A horizontal loop is possible.

```swift
open var isInfinitable: Bool
```

- Default is `true`.
- Set `false` if you don't need to loop of view.

<img alt="loop" src="https://github.com/KyoheiG3/assets/blob/master/GridView/loop.gif" height="333">

```swift
gridView.isInfinitable = true
```

#### Scaling

Content is done relayout rather than scaling like 'UIScrollView'.

```swift
open var minimumScale: Scale
open var maximumScale: Scale
```

- Default for x and y are 1.
- Set the vertical and horizontal scales.

```swift
public var currentScale: Scale { get }
```

- Get current vertical and horizontal scales.

<img alt="scaling" src="https://github.com/KyoheiG3/assets/blob/master/GridView/scaling.gif" height="333">

```swift
gridView.minimumScale = Scale(x: 0.5, y: 0.5)
gridView.maximumScale = Scale(x: 1.5, y: 1.5)
```

#### Fill for Cell

It is possible to decide the placement of Cell at relayout.

```swift
open var layoutWithoutFillForCell: Bool
```

- Default is `false`.
- Set `true` if need to improved view layout performance.

| false | true |
|-|-|
|<img alt="false" src="https://github.com/KyoheiG3/assets/blob/master/GridView/false.gif" width="333">|<img alt="true" src="https://github.com/KyoheiG3/assets/blob/master/GridView/true.gif" width="333">|

```swift
gridView.layoutWithoutFillForCell = true
```

#### Content Offset

If `isInfinitable` is true, `contentOffset` depends on the content size including size to loop. It is possible to take content offset that actually visible.

```swift
open var actualContentOffset: CGPoint { get }
```

#### Delegate

Set the delegate destination. This delegate property is `UIScrollViewDelegate` but, actually set the `GridViewDelegate`.

```
weak open var dataSource: GridViewDataSource?
open var delegate: UIScrollViewDelegate?
```

### Functions

#### State

Get the view state.

```swift
public func visibleCells<T>() -> [T]
public func cellForRow(at indexPath: IndexPath) -> GridViewCell?
public func rectForRow(at indexPath: IndexPath) -> CGRect
public func indexPathsForSelectedRows() -> [IndexPath]
public func indexPathForRow(at position: CGPoint) -> IndexPath
```

#### Operation

Operate the view.

```swift
public func contentScale(_ scale: CGFloat)
public func reloadData()
public func invalidateContentSize()
public func invalidateLayout(horizontally: Bool = default)
public func deselectRow(at indexPath: IndexPath)
override open func setContentOffset(_ contentOffset: CGPoint, animated: Bool)
public func scrollToRow(at indexPath: IndexPath, at scrollPosition: GridViewScrollPosition = default, animated: Bool = default)
```

## LICENSE

Under the MIT license. See LICENSE file for details.

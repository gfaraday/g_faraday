# 0.7.2

* migrate to flutter 2.5.0
* fix typo
  
## 0.7.1

* fix refresh error when save file

## 0.7.0

* migrate to flutter 2.0

## 0.6.0-nullsafety.33

* fix typo

## 0.6.0-nullsafety.32

* add top navigator accessor
* add top context accessor
* compatible with objc

## 0.5.1-nullsafety.31

* add navigator observer
  
## 0.5.1-nullsafety.30

* refactor logger
* improve widget dispose logic after native container dealloc

## 0.5.1-nullsafety.29

* [android] fix status bar style

## 0.5.1-nullsafety.28

* [ios] reset additionalSafeAreaInsets
* [android] refactor `initEngine` to `startEngine`
  
## 0.5.1-nullsafety.27

* [ios] post status bar notification

## 0.5.1-nullsafety.26

* [android] downgrade minSdkVersion to 16
  
## 0.5.1-nullsafety.25

* [ios] fix ios notification issue

## 0.5.1-nullsafety.24

* [ios] refine swipe pop gesture
* refine example project

## 0.5.1-nullsafety.23

* remove useless asset

## 0.5.1-nullsafety.22

* [ios] resize channel buffer
  
## 0.5.1-nullsafety.21

* remove navigator anchor
* [android] refine `onNewIntent`

## 0.5.1-nullsafety.20

* add anchor native api
* [android] fix splash reuse issue

## 0.5.1-nullsafety.19

* fix page dealloc logic
  
## 0.5.1-nullsafety.18

* add popToAnchor native api

## 0.5.1-nullsafety.17

* compatible xcode 11.5

## 0.5.1-nullsafety.16

* support pop to any flutter route

## 0.5.1-nullsafety.15

* refine options default value

## 0.5.1-nullsafety.14

* refine options api

## 0.5.1-nullsafety.13

* downgrade flutter version to 1.24.0-10.2.pre

## 0.5.1-nullsafety.12

* revert FaradayBrdige of api

## 0.5.1-nullsafety.11

* refine notification api

## 0.5.1-nullsafety.10

* [android] fix splash issue

## 0.5.1-nullsafety.9

* [android] make route&params public
* add more examples

## 0.5.1-nullsafety.8

* [ios] refine callback api
* migrate to `Flutter 1.25.0-8.1.pre`

## 0.5.0-nullsafety.7

* [ios] refine push api
* refine nullsafety

## 0.5.0-nullsafety.6

* [ios] fix pop gesture logic

## 0.5.0-nullsafety.5

* upgrade json package to 4.0.0.nullsafety.2

## 0.5.0-nullsafety.4

* upgrade json package to 4.0.0.nullsafety.1

## 0.5.0-nullsafety.3

* [ios] fix callback issue
* add invokeMapMethod&invokeListMethod for common channel

## 0.5.0-nullsafety.2

* fix navigator onGenerateInitialRouteIssue

## 0.5.0-nullsafety.1

* [ios] make flutter engine public

## 0.5.0-nullsafety.0

* support null safety basically

## 0.4.3-pre.3

* refine android activity lifecycle

## 0.4.3-pre.2

* detach activity before destroy

## 0.4.3-pre.1

* test publish by github action

## 0.4.3-pre.0

* refactor activity builder api

## 0.4.2

* add examples

## 0.4.2-pre.2

* fix Activity animation issue
* fix ViewController swipe back gesture

## 0.4.2-pre.1

* Support custom splash screen with pure color

## 0.4.2-pre.0

* Support activity all launch modes
* Support custom transition animation
* Support transparent background

## 0.4.1-pre.1

* Support Activity animation
* Support Fragment

## 0.4.1-pre.0

* Remove Page.Hidden event
* Custom FlutterActivity

## 0.4.0

* Support hybrid route stack.
* Automatically handle ios navigation bar hidden/show.
* Support `WillPopScope` widget.
* Send/Receive global notification.
* Complete documentation.

# 集成Flutter

> 需要一个 文件服务器 支持https 支持上传下载

## ios

1. 创建私有的 pod spec
[Private Pods](https://guides.cocoapods.org/making/private-cocoapods.html)

git@git.yuxiaor.com:yuxiaor-mobile/faraday_spec.git

2. 将Flutter framework 上传至私有仓库

```
flutter build ios-framework --no-profile --cocoapods

pod repo push faraday Flutter.podspec
```
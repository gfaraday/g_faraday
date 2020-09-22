package com.yuxiaor.flutter.g_faraday_example.faraday

import android.app.Activity
import com.yuxiaor.flutter.g_faraday.FaradayActivity

//
//  Route.kt
//  Faraday
//
//  Created by faraday_cli on 2020/9/22.
//

//
//    ___                   _
//   / __\_ _ _ __ __ _  __| | __ _ _   _
//  / _\/ _` | '__/ _` |/ _` |/ _` | | | |
// / / | (_| | | | (_| | (_| | (_| | |_| |
// \/   \__,_|_|  \__,_|\__,_|\__,_|\__, |
//                                  |___/
//
// GENERATED CODE BY FARADAY CLI - DO NOT MODIFY BY HAND

sealed class FlutterRoute(val routeName: String, val routeArguments: HashMap<String, Any>?) {
// ---> sealed
// ---> sealed cli_demo/demo.dart|DemoApp
    object DemoHome: FlutterRoute("demo_home", null)
    data class DemoHome1(val id: String): FlutterRoute("demo_home1", hashMapOf("id" to id))
    data class DemoHome2(val name: String): FlutterRoute("demo_home2", hashMapOf("name" to name))
    /// comments open demo home
    object DemoHome3: FlutterRoute("demo_home3", null)
// <--- sealed cli_demo/demo.dart|DemoApp
}

/**
 * Navigate to flutter
 * @param route flutter router
 *
 * override [Activity.onActivityResult] in your Activity to got the result
 */
fun Activity.openFlutter(route: FlutterRoute, requestCode: Int) {
    startActivityForResult(FaradayActivity.build(this, route.routeName, route.routeArguments), requestCode)
}
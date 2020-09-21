// ---> protocol
  // ---> protocol demo.dart|Bridge

  ///
  /// This is test message
  ///
  ///
  ///
  func test(_ id: Array<Double>, _ named: Array<Int>?) -> Any?
  // <--- protocol demo.dart|Bridge


// ---> impl
  // ---> impl demo.dart|Bridge
    if (name == "demo.dart|Bridge#test") {
      guard let id = args?["id"] as? Array<Double> else {
        fatalError("argument: id not valid")
      }
      
      let named = args?["named"] as? Array<Int> 
      // invoke test
      completions(test(id, named))
      return true
    }
        
  // <--- impl demo.dart|Bridge


// ---> enum
  // ---> enum demo.dart|Bridge

  ///
  ///
  ///
  ///
  case openDetail(_ id: Int, _ name: Any?)
  // <--- enum demo.dart|Bridge
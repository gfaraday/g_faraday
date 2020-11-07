# Net

`g_faraday`默认现有的`ios`&`android`已经存在大量的网络基础设施(包括但不限于登录验证，加解密等等)

> 如果没有没有你可以跳过此部分内容


## Flutter

`flutter`侧我们提供了`FaradayNet`用来进行网络请求

``` dart

final response = await FaradayNet.request('get', '/user', parameters: {'id': 1}, headers: {'ua': 'g_faraday'});

```

## Native

native侧需要实现`flutter`侧的方法，在ios和android中定义如下

### ios

``` swift

// 接口定义
public protocol FaradayHttpProvider: AnyObject {
    
    func request(method: String, url: String, parameters: [String: Any]?, headers: [String: String]?, completion: @escaping (_ result: Any?) -> Void) -> Void
}

// implementation example
extension AppDelegate: FaradayHttpProvider {

    func request(method: String, url: String, parameters: [String : Any]?, headers: [String : String]?, completion: @escaping (Any?) -> Void) {
        let afHeaders = headers.map { HTTPHeaders($0) }
        // 假设使用 Alamofire实现网络请求
        let dataRequest = AF.request(url, method: HTTPMethod(rawValue: method.uppercased()), parameters: parameters, headers: afHeaders)
        dataRequest.responseJSON { response in
            switch response.result {
                case .success(let data):
                    completion(["data": data, "errorCode": 0])
                case .failure(let error):
                    completion(["message": error.localizedDescription, "errorCode": error.responseCode ?? 1])
            }
        }
    }

}

// 使用
Faraday.default.startFlutterEngine(navigatorDelegate: self, httpProvider: self, commonHandler: self.handle(_:_:_:), automaticallyRegisterPlugins: true)

```

### android

``` kotlin

// 定义
interface NetHandler {

    /**
     * @param method GET POST PUT DELETE ...
     * @param url
     * @param params request params
     * @param headers request headers
     * @param onComplete callback the request response
     */
    fun request(method: String, url: String, params: HashMap<String, Any>?, headers: HashMap<String, String>?, onComplete: (result: Any?) -> Unit)

}

//
class FaradayNet : NetHandler {
    private val api = Net.create<FaradayFutureApi>()

    interface FaradayFutureApi {

        @GET
        fun get(@Url url: String, @QueryMap params: HashMap<String, Any>?): Call<JsonElement>

        @POST
        fun post(@Url url: String, @Body body: HashMap<String, Any>?): Call<JsonElement>

        @PUT
        fun put(@Url url: String, @Body body: HashMap<String, Any>?): Call<JsonElement>

        @DELETE
        fun delete(@Url url: String, @QueryMap map: HashMap<String, Any>?): Call<JsonElement>
    }

    override fun request(method: String, url: String, params: HashMap<String, Any>?, headers: HashMap<String, String>?, onComplete: (result: Any?) -> Unit) {
        val args = params ?: hashMapOf()
        val netCall = when (method.toUpperCase(Locale.getDefault())) {
            "GET" -> api.get(url, args)
            "POST" -> api.post(url, args)
            "PUT" -> api.put(url, args)
            "DELETE" -> api.delete(url, args)
            else -> throw RuntimeException("Unsupported method $method")
        }

        MainScope().launch(NetErrorHandler) {
            val response = netCall.call()
            if (response.code() !in 200..300) {
                throw HttpException(response)
            }
            onComplete.invoke(succeed(response.body()))
        }.onError { code, message ->
            onComplete.invoke(failed(code, message))
        }
    }

    private suspend fun <T> Call<T>.call() = suspendCoroutine<Response<T>> { continuation ->
        GlobalScope.launch(Dispatchers.IO) {
            try {
                val response = execute()
                continuation.resume(response)
            } catch (t: Throwable) {
                continuation.resumeWithException(t)
            }
        }
    }

    private fun succeed(json: JsonElement?): Map<String, Any?> {
        return mapOf("code" to 200, "data" to json?.toString(), "fromAndroid" to true)
    }

    private fun failed(code: String, message: String): Map<String, Any?> {
        return mapOf("code" to code, "msg" to message)
    }
}

//
Faraday.setNetHandler(FaradayNet())

```
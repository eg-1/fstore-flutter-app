import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'package:screen/screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:badges/badges.dart';

var _itemsInCart = 0;

class Product {
  final int id;
  final String name;
  final String details;
  final String img;
  final String price;
  final List images;

  Product(
      {this.id, this.name, this.details, this.img, this.images, this.price});

  factory Product.fromJson(Map<String, dynamic> json) {
    return new Product(
      id: json['id'] * 1,
      name: json['name'],
      details: json['details'],
      price: json['price'],
      images: json['images'],
      img: json['img'],
    );
  }
}


  Future addCartItem(item_id, item_name, item_price,item_img, item_quantity) async {
    var cart = "";
    var theitem = new Map();
    theitem['id'] = item_id.toString();
    theitem['name'] = item_name.toString();
    theitem['price'] = item_price.toString();
    theitem['img'] = item_img;
    theitem['quantity'] = item_quantity.toString();
    var jsonCart;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //prefs.setString('cart', '{}');

    cart = prefs.getString('cart') ?? '{}';

    jsonCart = json.decode(cart);

    jsonCart[item_id.toString()] = theitem;

    prefs.setString("cart", json.encode(jsonCart));
    _itemsInCart = jsonCart.values.length ?? 0;
  }
//Future keepScreenOn() async {
//  Screen.keepOn(true);
//}
int _itemCount = 0;

void main() async {
  
  SharedPreferences prefs = await SharedPreferences.getInstance();

  String cart = prefs.getString('cart') ?? "{}";

  await prefs.clear();

  prefs.setString("cart", cart);

  _itemsInCart = jsonDecode(cart).values.length;

  return runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'المتجر',
      locale: Locale('ar', ''),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('ar', ''), // Arabic
      ],
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      initialRoute: '/',
      routes: {
        // When navigating to the "/" route, build the FirstScreen widget.
        '/': (context) => MyHomePage(title: 'المتجر'),
      },
    );
  }
}
_MyHomePageState homeState;
class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() {
    homeState =_MyHomePageState() ;
    return homeState;
  }

}

class _MyHomePageState extends State<MyHomePage> {
  bool _isLoading = false,
      _isHome = true,
      _isLoadingWebView = true,
      _isKeptOn = false;
  double _brightness = 1.0;
  int _selectedIndex = 0;

  String _selectedCate = "0";
  Widget catesList, _store, _storeCatesList;

  var _allCates = false, _allCatesProducts = false;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  WebViewController _webViewControllerOne, _webViewControllerTow;
  TextEditingController __ext_controller;

  void _onItemTapped(int index) {
    //_isLoading = true;
    if (index == 1) {
      _webViewControllerOne.loadUrl("https://fstore.eg-1.com/app/orders?m=1");
    } else if (index == 2) {
      _webViewControllerTow.loadUrl("https://fstore.eg-1.com/settings?m=1");
    }

    _goTo(index);
  }

  @override
  initState() {
    super.initState();
    Screen.keepOn(true);
    __ext_controller = new TextEditingController(text: "1");
  }

  _getWidget() {
    return Container(
      child: Stack(
        children: <Widget>[
          Visibility(
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              //maintainInteractivity: true,
              //maintainSemantics: true,
              visible: _selectedIndex == 0 && !_isLoading && _isHome,
              child: catesList),
          Visibility(
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              //maintainInteractivity: true,
              //maintainSemantics: true,
              visible: _selectedIndex == 0 && _isLoading,
              child: Center(child: CircularProgressIndicator())),
          //Visibility(
          //    maintainSize: true,
          //    maintainAnimation: true,
          //    maintainState: true,
          //    //maintainInteractivity: true,
          //    //maintainSemantics: true,
          //    visible: _selectedIndex == 1 &&_isLoadingWebView,
          //    child: Center(child: CircularProgressIndicator())),
          Visibility(
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              //maintainInteractivity: true,
              //maintainSemantics: true,
              visible: _selectedIndex == 0 && !_isLoading && !_isHome,
              child: _store),
          Visibility(
            maintainSize: true,
            maintainAnimation: true,
            maintainState: true,
            //maintainInteractivity: true,
            //maintainSemantics: true,
            visible: _selectedIndex == 1 && !_isLoadingWebView,
            child: WebView(
              initialUrl: 'https://fstore.eg-1.com/app/orders?m=1',
              javascriptMode: JavascriptMode.unrestricted,
              onWebViewCreated: (WebViewController webViewController) {
                setState(() {
                  _webViewControllerOne = webViewController;
                  //_isLoading = true;
                  _isLoadingWebView = true;
                });
              },
              onPageFinished: (c_url) {
                setState(() {
                  _isLoadingWebView = false;

                  if (c_url.contains('/settings') && _selectedIndex == 1){
                    _selectedIndex = 2;
                  }
                  if (c_url.contains('/cart') && _selectedIndex == 2){
                    _selectedIndex = 1;
                  }
                  //_isLoading = false;
                });
              },
            ),
          ),
          Visibility(
            maintainSize: true,
            maintainAnimation: true,
            maintainState: true,
            //maintainInteractivity: true,
            //maintainSemantics: true,
            visible: _selectedIndex == 2 && !_isLoadingWebView,
            child: WebView(
              initialUrl: 'https://fstore.eg-1.com/app/settings?m=1',
              
                            
                            javascriptChannels: Set.from([
                              JavascriptChannel(
                                  name: 'Success',
                                  onMessageReceived:(JavascriptMessage message) async {

                setState(() {
_selectedIndex = 0;                });                                  })
                            ]),
              javascriptMode: JavascriptMode.unrestricted,
              onWebViewCreated: (WebViewController webViewController) {
                setState(() {
                  _webViewControllerTow = webViewController;
                  //_isLoading = true;
                  _isLoadingWebView = true;
                });
              },
              onPageFinished: (c_url) {
                setState(() {
                  _isLoadingWebView = false;


                  if (c_url.contains('/settings') && _selectedIndex == 1){
                    _selectedIndex = 2;
                  }
                  if (c_url.contains('/cart') && _selectedIndex == 2){
                    _selectedIndex = 1;
                  }
                  //_isLoading = false;
                });
              },
            ),
          ),
          Visibility(
            visible: _selectedIndex == 3,
            child: Container(
              padding: EdgeInsets.all(20.0),
              child: Column(
                children: <Widget>[
                  Center(
                      child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      "عن المتجر",
                      style: TextStyle(fontSize: 30.0),
                    ),
                  )),
                  Text(
                      "هذا التطبيق هو تطبيق مرتبط بالموقعنا الإلكتروني ويتمثل عمله في تقديم خدمات الشراء عبر الإنترنت في انحاء من السعودية.")
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    catesList = FutureBuilder(
        future: allCatesData() ?? _noData(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return Text('!!!');
            case ConnectionState.waiting:
              return Center(child: CircularProgressIndicator());
            case ConnectionState.active:
              return Text('');
            case ConnectionState.done:
              if (snapshot.hasError) {
                return Text(
                  'خطأ غير متوقع',
                  style: TextStyle(color: Colors.red),
                );
              }
          }
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasError) {
            return Text(
              'خطأ غير متوقع',
              style: TextStyle(color: Colors.red),
            );
          }
          return Stack(
            children: [
              snapshot.connectionState == ConnectionState.done
                  ? AnimatedOpacity(
                      opacity: snapshot.connectionState == ConnectionState.done
                          ? 1.0
                          : 0.0,
                      duration: Duration(milliseconds: 500),
                      child: GridView.builder(
                        itemCount: json.decode(snapshot.data).length,
                        gridDelegate:
                            new SliverGridDelegateWithFixedCrossAxisCount(
                                childAspectRatio: 5 / 7,
                                crossAxisCount:
                                    (MediaQuery.of(context).size.width >
                                            MediaQuery.of(context).size.height
                                        ? 5
                                        : 3)),
                        itemBuilder: (BuildContext context, int index) {
                          return Column(
                            children: <Widget>[
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedIndex = 0;
                                    _isHome = false;
                                    _selectedCate = json
                                        .decode(snapshot.data)[index]['id']
                                        .toString();
                                    //_getProductsByCateID(json.decode(snapshot.data)[index]['id'].toString());
                                  });
                                },
                                child: Container(
                                  margin: const EdgeInsets.all(15.0),
                                  padding: const EdgeInsets.all(3.0),
                                  decoration: new BoxDecoration(
                                    borderRadius: new BorderRadius.all(
                                        Radius.circular(4.0)),
                                    border: new Border.all(
                                        color: Colors.green, width: 2.0),
                                  ),
                                  child: Image.network(
                                    'https://images1-focus-opensocial.googleusercontent.com/gadgets/proxy?container=focus&resize_h=200&url=https://fstore.eg-1.com/uploads/images/' +
                                        json.decode(snapshot.data)[index]
                                            ['img'],
                                    fit: BoxFit.cover,
                                    height: 80,
                                    width: 80,
                                  ),
                                ),
                              ),
                              Text(json.decode(snapshot.data)[index]['name']),
                            ],
                          );
                        },
                      ),
                    )
                  : Text("")
            ],
          );
        });
    _storeCatesList = FutureBuilder(
        future: allCatesData() ?? _noData(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return Text('!!!');
            case ConnectionState.waiting:
              return Center(child: CircularProgressIndicator());
            case ConnectionState.active:
              return Text('');
            case ConnectionState.done:
              if (snapshot.hasError) {
                return Text(
                  'خطأ غير متوقع',
                  style: TextStyle(color: Colors.red),
                );
              }
          }
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasError) {
            return Text(
              'خطأ غير متوقع',
              style: TextStyle(color: Colors.red),
            );
          }
          return Stack(
            children: [
              snapshot.connectionState == ConnectionState.done
                  ? AnimatedOpacity(
                      opacity: snapshot.connectionState == ConnectionState.done
                          ? 1.0
                          : 0.0,
                      duration: Duration(milliseconds: 500),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: json.decode(snapshot.data).length,
                        itemBuilder: (BuildContext context, int index) {
                          return Column(
                            children: <Widget>[
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedCate = json
                                        .decode(snapshot.data)[index]['id']
                                        .toString();
                                    //_getProductsByCateID(json.decode(snapshot.data)[index]['id'].toString());
                                  });
                                },
                                child: Container(
                                  margin: const EdgeInsets.all(10.0),
                                  padding: const EdgeInsets.all(3.0),
                                  decoration: new BoxDecoration(
                                    borderRadius: new BorderRadius.all(
                                        Radius.circular(4.0)),
                                    border: new Border.all(
                                        color: Colors.green, width: 2.0),
                                  ),
                                  child: Image.network(
                                    'https://images1-focus-opensocial.googleusercontent.com/gadgets/proxy?container=focus&resize_h=40&url=https://fstore.eg-1.com/uploads/images/' +
                                        json.decode(snapshot.data)[index]
                                            ['img'],
                                    fit: BoxFit.cover,
                                    height: 40,
                                    width: 40,
                                  ),
                                ),
                              ),
                              Text(
                                json.decode(snapshot.data)[index]['name'],
                                style: TextStyle(fontSize: 11.0),
                              ),
                            ],
                          );
                        },
                      ),
                    )
                  : Text("")
            ],
          );
        });
    _store = FutureBuilder(
        initialData: "[]",
        future: allCatesProducts(_selectedCate) ?? _noData(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return Text('!!!');
            case ConnectionState.waiting:
              return Center(child: CircularProgressIndicator());
            case ConnectionState.active:
              return Text('');
            case ConnectionState.done:
              if (snapshot.hasError) {
                return Text(
                  'خطأ غير متوقع',
                  style: TextStyle(color: Colors.red),
                );
              }
          }
          if (json.decode(snapshot.data).length == 0) {
            return Stack(
              children: <Widget>[
                _storeCatesList,
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.sentiment_very_dissatisfied, size: 45.0),
                      Text(
                        "لا توجد بيانات",
                        style: TextStyle(color: Colors.black, fontSize: 18.0),
                      ),
                      Text(
                        "لمزيد من المعلومات يرجى مراسلة الإدارة",
                        style: TextStyle(color: Colors.black54, fontSize: 14.0),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasError) {
            return Text(
              'خطأ غير متوقع',
              style: TextStyle(color: Colors.red),
            );
          }
          return Stack(
            children: [
              _storeCatesList,
              Container(
                padding: EdgeInsets.only(top: 100.0),
                child: snapshot.connectionState == ConnectionState.done
                    ? AnimatedOpacity(
                        opacity:
                            snapshot.connectionState == ConnectionState.done
                                ? 1.0
                                : 1.0,
                        duration: Duration(milliseconds: 500),
                        child: GridView.builder(
                          itemCount: json.decode(snapshot.data).length,
                          gridDelegate:
                              new SliverGridDelegateWithFixedCrossAxisCount(
                                  childAspectRatio: 9 / 15,
                                  crossAxisCount:
                                      (MediaQuery.of(context).size.width >
                                              MediaQuery.of(context).size.height
                                          ? 4
                                          : 2)),
                          itemBuilder: (BuildContext context, int index) {
                            return InkWell(
                              onTap: () async {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ProductPage(
                                              product: Product(
                                            id: json.decode(
                                                        snapshot.data)[index]
                                                    ["id"] *
                                                1,
                                            name: json
                                                .decode(snapshot.data)[index]
                                                    ["name"]
                                                .toString(),
                                            details: json
                                                .decode(snapshot.data)[index]
                                                    ["details"]
                                                .toString(),
                                            img: json
                                                .decode(snapshot.data)[index]
                                                    ["img"]
                                                .toString(),
                                            images: json
                                                .decode(snapshot.data)[index]
                                                    ["images"]
                                                .toList(),
                                            price: json
                                                .decode(snapshot.data)[index]
                                                    ["price"]
                                                .toString(),
                                          ))),
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.all(0.0),
                                padding: const EdgeInsets.all(0.0),
                                child: Container(
                                  padding: const EdgeInsets.only(
                                      top: 20.0,
                                      left: 20.0,
                                      right: 20.0,
                                      bottom: 0.0),
                                  child: Column(
                                    children: <Widget>[
                                      Image.network(
                                        'https://images1-focus-opensocial.googleusercontent.com/gadgets/proxy?container=focus&resize_h=200&url=https://fstore.eg-1.com/uploads/images/' +
                                            json.decode(snapshot.data)[index]
                                                ['img'],
                                        fit: BoxFit.contain,
                                        height:
                                            (MediaQuery.of(context).size.width >
                                                    MediaQuery.of(context)
                                                        .size
                                                        .height
                                                ? 160
                                                : 160),
                                        width: 150,
                                      ),
                                      RichText(
                                        text: TextSpan(children: <TextSpan>[
                                          TextSpan(
                                              text: json.decode(
                                                  snapshot.data)[index]['name'],
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold)),
                                        ]),
                                        //child: Text(json.decode(snapshot.data)[index]['name'])),
                                      ),
                                      Text(json
                                              .decode(snapshot.data)[index]
                                                  ['price']
                                              .toString() +
                                          " ريال"),
                                      Center(
                                        child: RaisedButton(
                                          shape: new RoundedRectangleBorder(
                                              borderRadius:
                                                  new BorderRadius.circular(
                                                      30.0)),
                                          color: Colors.green,
                                          textColor: Colors.white,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              Icon(Icons.add_shopping_cart),
                                            ],
                                          ),
                                          onPressed: () async {

                                                  addCartItem(json.decode(
                                                        snapshot.data)[index]
                                                    ["id"] *1, json
                                                .decode(snapshot.data)[index]
                                                    ["name"]
                                                .toString(),
                      json
                                                .decode(snapshot.data)[index]
                                                    ["price"]
                                                .toString(),json
                                                .decode(snapshot.data)[index]
                                                    ["img"]
                                                .toString(), 1.toString());
                                                setState(() {
                                                  _itemsInCart = 10;
                                                });


                  Scaffold.of(context).showSnackBar(SnackBar(
                    content: Text('تمت إضافته للسلة'),
                    duration: Duration(seconds: 3),
                  ));

                                          },
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    : Text(""),
              )
            ],
          );
        });
    return WillPopScope(
      onWillPop: (){
         Future(() => false);
      },
      child: OfflineBuilder(
        connectivityBuilder: (
          BuildContext context,
          ConnectivityResult connectivity,
          Widget child,
        ) {
          final bool connected = connectivity != ConnectivityResult.none;
          return new Stack(
            fit: StackFit.expand,
            children: [
              Scaffold(
                appBar: AppBar(
                  backgroundColor: connected ? Colors.green : Colors.red,
                  title: Row(
                    children: <Widget>[
                      Image.network(
                        'https://images1-focus-opensocial.googleusercontent.com/gadgets/proxy?container=focus&resize_h=200&url=https://download.blender.org/branding/blender_logo_socket.png',
                        fit: BoxFit.contain,
                        height: 50,
                      ),
                      Text("${connected ? '' : ' - بدون إنترنت'}"),
                    ],
                  ),
                  actions: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Badge(
                          badgeContent: Text(
                            _itemsInCart.toString(),
                            style: TextStyle(color: Colors.white),
                          ),
                          child: IconButton(
                            icon: Icon(Icons.shopping_basket),
                            onPressed: () async {
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              //prefs.setString('cart', '{}');

                              var cart = prefs.getString('cart') ?? '{}';

                              var jsonCart = json.decode(cart);
                              //for (var item in json.decode(cart).values) {
                              //  _webViewController.evaluateJavascript(
                              //      'window.order({"id":' +
                              //          item["id"].toString() +
                              //          ',"name":"' +
                              //          item["name"] +
                              //          '","price":' +
                              //          item["price"] +
                              //          ',"quantity":' +
                              //          item["quantity"] +
                              //          '});');
                              //}

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => CartPage(
                                        alldata:
                                            json.decode(cart).values.toList())),
                              );

                              //_webViewController.evaluateJavascript(
                              //    'window.order({"id":16,"name":"المنتج 16","price":140,"cate_id":4,"img":"IMAGE1562014516.jpg","details":"منتج ذو جودة عالية","created_at":"2019-07-17 13:01:28","updated_at":"2019-07-17 13:01:28","quantity":1});');

                              //_webViewController
                              //    .loadUrl("https://fstore.eg-1.com/app/cart");
                              //_webViewController.evaluateJavascript("document.body.remove();");
                              //_goTo(2);
                            },
                          )),
                    )
                  ],
                ),
                body: connected
                    ? Stack(
                        children: <Widget>[
                          _getWidget(),
                          //!_isLoading
                          //    ? Center(child: new CircularProgressIndicator())
                          //    : _getWidget(),
                          //AnimatedOpacity(
                          //  opacity:
                          //      _isLoading ? 0.0 : 1.0,
                          //  duration: Duration(milliseconds: 500),
                          //  child: _getWidget(),
                          //)
                        ],
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Icon(Icons.signal_wifi_off, size: 45.0),
                            Text(
                              "الوصول إلى الإنترنت ضروري",
                              style:
                                  TextStyle(color: Colors.black, fontSize: 18.0),
                            ),
                            Text(
                              "يرجى توصيل الإنترنت",
                              style: TextStyle(
                                  color: Colors.black54, fontSize: 14.0),
                            ),
                          ],
                        ),
                      ),
                bottomNavigationBar: connected
                    ? BottomNavigationBar(
                        currentIndex: _selectedIndex,
                        items: const <BottomNavigationBarItem>[
                          BottomNavigationBarItem(
                            icon: Icon(Icons.store),
                            title: Text('تسوق'),
                          ),
                          BottomNavigationBarItem(
                            icon: Icon(Icons.shopping_cart),
                            title: Text('الطلبات'),
                          ),
                          BottomNavigationBarItem(
                            icon: Icon(Icons.person),
                            title: Text('الحساب'),
                          ),
                          BottomNavigationBarItem(
                            icon: Icon(Icons.info),
                            title: Text('من نحن'),
                          ),
                        ],
                        selectedItemColor: Colors.green,
                        unselectedItemColor: Colors.black,
                        showUnselectedLabels: true,
                        onTap: _onItemTapped,
                      )
                    : Text(""),
              ),
            ],
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Text(
              'There are no bottons to push :)',
            ),
            new Text(
              'Just turn off your internet.',
            ),
          ],
        ),
      ),
    );
  }

  Future _goTo(index) async {
    setState(() {
      _selectedIndex = index;
      //_isLoading = true;
      if (index == 1 || index == 2) {
        _isLoadingWebView = true;
      }
    });
  }

  Future _noData() async {
    return "[]";
  }

  Future allCatesData() async {
    var allCates = "";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    allCates = prefs.getString('cates') ?? "";
    if (allCates == "") {
      try {
        return await http
            .post("https://fstore.eg-1.com/api/v1/cates")
            .then((response) {
          if (response.statusCode != 200 || response.body.toString().contains("html")) {
            return "[]";
          }
          prefs.setString('cates', response.body.toString() ?? "[]");
          return response.body ?? "[]";
        })
        .then((body) => body)
        .catchError((response) => "[]");
      } catch (e) {
        return "[]";
      }
    }
    return allCates ??
        "[]"; //'[{"id":9,"name":"\u0627\u0633\u064a\u0627 \u062a\u0634 \u0628\u0645","img":"IMAGE1563496710.jpeg","created_at":"2019-07-19 00:38:30","updated_at":"2019-07-19 00:38:30"},{"id":5,"name":"\u0641\u0626\u0629","img":"IMAGE1563368795.jpeg","created_at":"2019-07-17 13:06:35","updated_at":"2019-07-17 13:06:35"},{"id":14,"name":"\u0645\u0646\u062a\u062c\u0627\u062a \u0623\u0646\u062f\u0648\u0646\u0633\u064a\u0629","img":"IMAGE1564169979.png","created_at":"2019-07-26 19:39:39","updated_at":"2019-07-26 19:39:39"},{"id":12,"name":"\u0645\u0646\u062a\u062c\u0627\u062a \u0635\u064a\u0646\u064a\u0629","img":"IMAGE1564169799.png","created_at":"2019-07-26 19:36:39","updated_at":"2019-07-26 19:36:39"},{"id":13,"name":"\u0645\u0646\u062a\u062c\u0627\u062a \u0641\u0644\u0628\u064a\u0646\u064a\u0629","img":"IMAGE1564169812.png","created_at":"2019-07-26 19:36:52","updated_at":"2019-07-26 19:36:52"},{"id":11,"name":"\u0645\u0646\u062a\u062c\u0627\u062a \u0643\u0648\u0631\u064a\u0629","img":"IMAGE1564169608.png","created_at":"2019-07-26 19:33:28","updated_at":"2019-07-26 19:33:28"},{"id":15,"name":"\u0645\u0646\u062a\u062c\u0627\u062a \u0645\u0627\u0644\u064a\u0632\u064a\u0629","img":"IMAGE1564170181.png","created_at":"2019-07-26 19:43:01","updated_at":"2019-07-26 19:43:01"}]';
  }

  Future allCatesProducts(cate_id) async {
    var allProducts = "";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    allProducts = prefs.getString('prodcts_$cate_id') ?? "";
    if (allProducts == "") {
      try {
        return http
            .post("https://fstore.eg-1.com/api/v1/$cate_id/products")
            .then((response) {
          if (response.statusCode != 200 || response.body.toString().contains("html")) {
            return "[]";
          }
          prefs.setString('prodcts_$cate_id', response.body.toString() ?? "[]");
          return response.body ?? "[]";
        }).catchError((response) => "[]");
      } catch (e) {
        return "[]";
      }
    }
    return allProducts ??
        "[]"; //'[{"id":9,"name":"\u0627\u0633\u064a\u0627 \u062a\u0634 \u0628\u0645","img":"IMAGE1563496710.jpeg","created_at":"2019-07-19 00:38:30","updated_at":"2019-07-19 00:38:30"},{"id":5,"name":"\u0641\u0626\u0629","img":"IMAGE1563368795.jpeg","created_at":"2019-07-17 13:06:35","updated_at":"2019-07-17 13:06:35"},{"id":14,"name":"\u0645\u0646\u062a\u062c\u0627\u062a \u0623\u0646\u062f\u0648\u0646\u0633\u064a\u0629","img":"IMAGE1564169979.png","created_at":"2019-07-26 19:39:39","updated_at":"2019-07-26 19:39:39"},{"id":12,"name":"\u0645\u0646\u062a\u062c\u0627\u062a \u0635\u064a\u0646\u064a\u0629","img":"IMAGE1564169799.png","created_at":"2019-07-26 19:36:39","updated_at":"2019-07-26 19:36:39"},{"id":13,"name":"\u0645\u0646\u062a\u062c\u0627\u062a \u0641\u0644\u0628\u064a\u0646\u064a\u0629","img":"IMAGE1564169812.png","created_at":"2019-07-26 19:36:52","updated_at":"2019-07-26 19:36:52"},{"id":11,"name":"\u0645\u0646\u062a\u062c\u0627\u062a \u0643\u0648\u0631\u064a\u0629","img":"IMAGE1564169608.png","created_at":"2019-07-26 19:33:28","updated_at":"2019-07-26 19:33:28"},{"id":15,"name":"\u0645\u0646\u062a\u062c\u0627\u062a \u0645\u0627\u0644\u064a\u0632\u064a\u0629","img":"IMAGE1564170181.png","created_at":"2019-07-26 19:43:01","updated_at":"2019-07-26 19:43:01"}]';
  }

  Future _ackAlert(BuildContext context, snapshot, index) {
    _itemCount = 1;
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(json.decode(snapshot.data)[index]["name"].toString()),
          content: Column(
            children: <Widget>[
              Text(json.decode(snapshot.data)[index]["details"].toString()),
              Text("السعر: " +
                  json.decode(snapshot.data)[index]["price"].toString() +
                  "ريال"),
              new Row(
                children: <Widget>[
                  new IconButton(
                      icon: new Icon(Icons.remove),
                      onPressed: () => setState(() => {_itemCount--})),
                  Text(_itemCount.toString()),
                  new IconButton(
                      icon: new Icon(Icons.add),
                      onPressed: () => setState(() => {_itemCount++}))
                ],
              ),
            ],
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('إلغاء'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('إضافة للسلة'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class ProductPage extends StatefulWidget {
  final Product product;

  ProductPage({Key key, @required this.product}) : super(key: key);
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  var _itemCount = 1;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Image.network(
          'https://images1-focus-opensocial.googleusercontent.com/gadgets/proxy?container=focus&resize_h=50&url=https://download.blender.org/branding/blender_logo_socket.png',
          fit: BoxFit.contain,
          height: 50,
        ),
        //Row(
        //  //mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //  children: <Widget>[
        //    Text(widget.product.name),
        //    //Text(widget.product.price.toString() + " ريال")
        //  ],
        //),
        actions: <Widget>[],
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: (widget.product.images.length ?? 0) + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: SizedBox(
                        width: 300,
                        height: 280,
                        child: Image.network(
                          'https://images1-focus-opensocial.googleusercontent.com/gadgets/proxy?container=focus&resize_h=400&url=https://fstore.eg-1.com/uploads/images/' +
                              widget.product.img,
                          fit: BoxFit.contain,
                          height: 280,
                          width: 300,
                        ),
                      ),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: SizedBox(
                      width: 300,
                      height: 280,
                      child: Image.network(
                        'https://images1-focus-opensocial.googleusercontent.com/gadgets/proxy?container=focus&resize_h=400&url=https://fstore.eg-1.com/uploads/images/' +
                            widget.product.images[index - 1]["img"],
                        fit: BoxFit.contain,
                        height: 280,
                        width: 300,
                      ),
                    ),
                  );
                },
              ),
            ),
            //ListView(
            //  scrollDirection: Axis.horizontal,
            //  children: <Widget>[
            //    Image.network(
            //      'https://images1-focus-opensocial.googleusercontent.com/gadgets/proxy?container=focus&resize_h=400&url=https://fstore.eg-1.com/uploads/images/' +
            //          widget.product.img,
            //      fit: BoxFit.contain,
            //      height: 220,
            //    ),
            //  ],
            //),
            Container(
                padding: EdgeInsets.all(20.0),
                child: Text(widget.product.details != "null"
                    ? widget.product.details
                    : "لا يوجد وصف لهذا المنتج.")),
            Center(
                child: Text(
                    (int.parse(widget.product.price) * _itemCount).toString() +
                        " ريال",
                    style: TextStyle(fontSize: 18))),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _itemCount > 1
                    ? new IconButton(
                        icon: new Icon(Icons.remove),
                        onPressed: () {
                          setState(() {
                            _itemCount--;
                            
                          });
                        })
                    : Container(),
                Center(child: Text(_itemCount.toString())),
                new IconButton(
                    icon: new Icon(Icons.add),
                    onPressed: () {
                      setState(() {
                        _itemCount++;
                      });
                    }),
              ],
            ),
            Container(
              padding: EdgeInsets.all(20.0),
              child: RaisedButton(
                onPressed: () {
                  addCartItem(widget.product.id, widget.product.name,
                      widget.product.price,widget.product.img, _itemCount.toString());


                  _scaffoldKey.currentState.showSnackBar(SnackBar(
                    content: Text('تمت إضافته للسلة'),
                    duration: Duration(seconds: 3),
                  ));
                  //_MyHomePageState()._webViewController.evaluateJavascript('window.order({"id":${widget.product.id},"name":"${widget.product.name}","price":${widget.product.price},"quantity":'+_itemCount.toString()+'});');
                },
                color: Colors.white,
                child: Text("أضفه للسلة"),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class CartPage extends StatefulWidget {
  final alldata;

  CartPage({Key key, this.alldata}) : super(key: key);
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  var isloading = false;
  WebViewController wvc;

  Future removeCartItem(item_id) async {
    var cart = "";
    var jsonCart;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //prefs.setString('cart', '{}');

    cart = prefs.getString('cart') ?? '{}';

    jsonCart = json.decode(cart);

    jsonCart.remove(item_id.toString());

    prefs.setString("cart", json.encode(jsonCart));
    _itemsInCart = jsonCart.values.length;
  }

  @override
  Widget build(BuildContext context) {
    return OfflineBuilder(
      child: Text("data"),
      connectivityBuilder: (
        BuildContext context,
        ConnectivityResult connectivity,
        Widget child,
      ) {
        final bool connected = connectivity != ConnectivityResult.none;
        return new Stack(
          fit: StackFit.expand,
          children: [
            Scaffold(
              appBar: AppBar(
                backgroundColor: connected ? Colors.green : Colors.red,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("السلة"),
                    //Text(" ريال")
                  ],
                ),
                //actions: <Widget>[
                //  IconButton(
                //    icon: Icon(Icons.add_alarm),
                //    onPressed: (){
                //      wvc.evaluateJavascript('window.clearCart();');
                //    },
                //  )
                //],
              ),
              body: connected
                  ? Stack(
                      children: <Widget>[
                        Visibility(
                          maintainSize: true,
                          maintainAnimation: true,
                          maintainState: true,
                          visible: !isloading,
                          child: WebView(
                            initialUrl: 'https://fstore.eg-1.com/app/cart?m=1',
                            javascriptMode: JavascriptMode.unrestricted,

                            onWebViewCreated: (WebViewController _wvc) {
                              setState(() {
                                isloading = true;
                                wvc = _wvc;
                              });
                            },
                            onPageFinished: (url) async {
                              setState(() {
                                isloading = false;
                              });

                              if (!url.contains('login') &&
                                  !url.contains('register') &&
                                  !url.contains('verify') &&
                                  !url.contains('app/cart')) {
                                wvc.loadUrl(
                                    "https://fstore.eg-1.com/app/cart?m=1");
                              }

                              if (url.contains('app/cart')) {
                                wvc.evaluateJavascript('window.clearCart();');

                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                //prefs.setString('cart', '{}');

                                var cart = prefs.getString('cart') ?? '{}';

                                for (var item in json.decode(cart).values) {
                                  wvc.evaluateJavascript('window.order({"id":' +
                                      item["id"].toString() +',"name":"' +item["name"] +
                                      '","price":' +
                                      item["price"] +
                                      ',"quantity":' +
                                      item["quantity"] +
                                      ',img:'+jsonEncode(item["img"])+'});');
                                }
                              }
                            },
                            
                            javascriptChannels: Set.from([
                              JavascriptChannel(
                                  name: 'Print',
                                  onMessageReceived:
                                      (JavascriptMessage message) async {
                                    if (message.message.contains('delete_')) {
                                      removeCartItem(message.message
                                          .replaceAll("delete_", ""));
                                    } else if (message.message == "ok") {
                                      SharedPreferences prefs =
                                          await SharedPreferences.getInstance();
                                      prefs.setString('cart', '{}');

                                      setState(() {
                                        _itemsInCart = 0;
                                      });

                                    }
                                  })
                            ]),
                          ),
                        ),
                        Visibility(
                          visible: isloading,
                          child: Center(child: CircularProgressIndicator()),
                        )
                      ],
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.signal_wifi_off, size: 45.0),
                          Text(
                            "الوصول إلى الإنترنت ضروري",
                            style:
                                TextStyle(color: Colors.black, fontSize: 18.0),
                          ),
                          Text(
                            "يرجى توصيل الإنترنت",
                            style: TextStyle(
                                color: Colors.black54, fontSize: 14.0),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        );
      },
    );
    //ListView.builder(
    //  itemCount: widget.alldata.length,
    //  itemBuilder: (BuildContext ctxt, int index) {
    //    return Container(
    //      padding: EdgeInsets.all(20.0),
    //      child: Row(
    //              mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //              children: <Widget>[
    //                Column(
    //                  crossAxisAlignment: CrossAxisAlignment.start,
    //                  children: <Widget>[
    //                    Text(
    //                      widget.alldata[index]["name"],
    //                      style: TextStyle(fontWeight: FontWeight.bold),
    //                    ),
    //                    Opacity(
    //                        opacity: 0.5,
    //                        child: Text(
    //                            "سعر الوحدة: ${widget.alldata[index]["price"]} ريال")),
    //                  ],
    //                ),
    //                Center(
    //                  child: Row(
    //                    children: <Widget>[
    //                      Text(
    //                          "الكمية: ${widget.alldata[index]["quantity"]}"),
    //                      IconButton(
    //                        icon: Icon(Icons.delete),
    //                        onPressed: () {
    //                          removeCartItem(widget.alldata[index]["id"]);
//
    //                          setState(() {
    //                            widget.alldata.removeWhere((item) =>
    //                                item["id"] ==
    //                                widget.alldata[index]["id"]);
    //                          });
    //                        },
    //                      )
    //                    ],
    //                  ),
    //                )
    //              ],
    //            )
    //    );
    //  }),
  }
}

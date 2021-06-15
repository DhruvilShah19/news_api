import 'package:flutter/material.dart';
import 'package:news_api/login/UI/login.dart';
import 'package:news_api/view/article_view.dart';
import 'package:news_api/view/category_news.dart';
import 'package:news_api/models/data.dart';
import 'package:news_api/models/news.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter_mobx/flutter_mobx.dart';

// ignore: must_be_immutable
class MyApp extends StatefulWidget {
  String value;
  MyApp({this.value});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String savedValue;
  SharedPreferences sharedPreferences;
  // ignore: deprecated_member_use
  List<CategoryModel> categories = new List<CategoryModel>();
  // ignore: deprecated_member_use
  List<ArticleModel> articles = new List<ArticleModel>();
  bool _loading = true;
  var password;

  @override
  void initState() {
    super.initState();
    categories = getCategories();
    getNews();
    checkLoginStatus();
  }

  checkLoginStatus() async {
    sharedPreferences = await SharedPreferences.getInstance();
    savedValue = sharedPreferences.getString('email');
    if (sharedPreferences.getString("token") == null) {
      Navigator.of(this.context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (BuildContext context) => Login()),
          (Route<dynamic> route) => false);
    }
  }

  getNews() async {
    News newsClass = News();
    await newsClass.getNews();
    articles = newsClass.news;
    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        endDrawer: Drawer(
          child: ListView(
            children: [
              DrawerHeader(
                  child: Text(
                    savedValue != null ? savedValue : 'User not logged In',
                    style: TextStyle(color: Colors.white),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.deepPurpleAccent,
                  )),
              Divider(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                // ignore: deprecated_member_use
                child: RaisedButton(
                  color: Colors.deepPurpleAccent,
                  onPressed: () {
                    sharedPreferences.clear();
                    // ignore: deprecated_member_use
                    sharedPreferences.commit();
                    Navigator.of(this.context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (BuildContext context) => Login()),
                        (Route<dynamic> route) => false);
                  },
                  child: Text(
                    "Logout",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              // Padding(
              //   padding: const EdgeInsets.all(8.0),
              //   // ignore: deprecated_member_use
              //   child: RaisedButton(
              //     color: Colors.deepPurpleAccent,
              //     onPressed: () {},
              //     child: Observer(
              //       builder: (_) => Text(
              //         "Theme change",
              //         style: TextStyle(color: Colors.white),
              //       ),
              //     ),
              //   ),
              // )
            ],
          ),
        ),
        appBar: AppBar(
          centerTitle: true,
          iconTheme: new IconThemeData(color: Colors.black),
          backgroundColor: Colors.white,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "Latest",
                style: TextStyle(
                    color: Colors.purple,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0),
              ),
              Text(
                "News",
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                    letterSpacing: 2.0),
              )
            ],
          ),
        ),
        body: _loading
            ? Container(
                child: Center(child: CircularProgressIndicator()),
              )
            : RefreshIndicator(
                onRefresh: () async {
                  await new Future.delayed(Duration(seconds: 2));
                  return null;
                },
                child: SingleChildScrollView(
                  child: Container(
                    child: Column(children: <Widget>[
                      Container(
                          padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
                          child: TextField(
                            showCursor: false,
                            readOnly: false,
                            autocorrect: true,
                            decoration: InputDecoration(
                              hintText: 'Search all treanding news here ...',
                              prefixIcon: Icon(
                                Icons.search,
                                size: 30,
                              ),
                              hintStyle: TextStyle(color: Colors.grey),
                              filled: true,
                              fillColor: Colors.white70,
                              enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12.0)),
                                borderSide:
                                    BorderSide(color: Colors.black, width: 1.5),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0)),
                                borderSide:
                                    BorderSide(color: Colors.green, width: 2),
                              ),
                            ),
                          )),
                      Container(
                        height: 160,
                        child: ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemCount: categories.length,
                            itemBuilder: (context, index) {
                              return Category(
                                image: categories[index].imageUrl,
                                categoryName: categories[index].categoryName,
                              );
                            }),
                      ),
                      ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          physics: ClampingScrollPhysics(),
                          itemCount: articles.length,
                          itemBuilder: (context, index) {
                            return BlogCategory(
                              title: articles[index].title,
                              description: articles[index].description,
                              imageUrl: articles[index].urlToImage,
                              url: articles[index].url,
                            );
                          }),
                    ]),
                  ),
                ),
              ),
      ),
    );
  }
}

class Category extends StatelessWidget {
  final image;
  final String categoryName;

  const Category({this.image, this.categoryName});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Categorynews(
                          category: categoryName.toLowerCase(),
                        )),
              );
            },
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.asset(
                    image,
                    width: 200,
                    height: 160,
                    fit: BoxFit.cover,
                  ),
                ),
                Container(
                  width: 200,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: Colors.black45),
                  child: Text(
                    categoryName,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BlogCategory extends StatelessWidget {
  final title;
  final description;
  final imageUrl;
  final url;

  const BlogCategory({this.title, this.description, this.imageUrl, this.url});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ArticleView(
                    blogurl: url,
                  )),
        );
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(imageUrl)),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                child: Text(
                  title,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0),
                ),
              ),
              Text(
                description,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 1.0),
              )
            ],
          ),
        ),
      ),
    );
  }
}

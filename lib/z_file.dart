
import 'dart:convert';
import 'package:meta/meta.dart';

void main() {
  // String jsonString = 
  // '''
  // {"author": "Singh Saab", "title": "Oye Bale bale", "likes": null} 
  // ''';
  // Article a = Article.fromJsonString(jsonString);
  // print(a.toString());
}

void encodingExample() {
  Map<dynamic, dynamic> mp = Map();
  mp['phone'] = '9816547008';
  mp['email'] = 'gouravkandoria1500@gmail.com';
  // mp['function'] = () {
  //   return 1;
  // };
  // mp[1] = 54;
  mp['1'] = true;
  String jsonString = jsonEncode(mp);
  print('mp: $mp');
  print('jsonString: $jsonString');
}

void decodingExample() {
  String jsonString = 
  '''
    {"phone":"9816547008","email":"gouravkandoria1500@gmail.com","1":true}
  ''';
  var ls = jsonDecode(jsonString);
  print('jsonString: $jsonString');
  print('ls: ${ls.toString()}');
}

void func() {
	print('Hello World');
  var a = const MyClass(10);
  var b = const MyClass(10);
	if(identical(a,b)) {
		print('they are identical');
	}
	else {
		print('not identical');
	}
  print('a.n: ${a.n}');
  print('b.n: ${b.n}');
  if(identical(a,b)) {
		print('they are identical');
	}
	else {
		print('not identical');
	}
}

int getValues() {
  return 2;
}

class MyClass {
  final n;
  const MyClass(this.n);
}

class Article {
  final String author;
  final String title;
  final int likes;
  const Article({@required this.author, @required this.title, @required this.likes});

  factory Article.fromJsonString(String jsonString) {
    Map<String, dynamic> mp = jsonDecode(jsonString);
    return Article(author: mp['author'], title : mp['title'], likes: mp['likes']);
  }

  factory Article.fromJsonMap(Map mp) {
    return Article(author: mp['author'], title : mp['title'], likes: mp['likes']);
  }

  @override
  String toString() {
    return toJsonString();
  }

  String toJsonString() {

    String tempString = 
'''
{
  "author": "$author",
  "title": "$title",
  "likes: ${likes!=null ? likes : null},
}
'''
   ;
  return tempString;
  }
}
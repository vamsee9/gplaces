
import 'package:flutter/material.dart';
import 'place_service.dart';
import 'package:uuid/uuid.dart';
import 'address_search.dart';

void main() async {
  // String request =
  //     'https://maps.googleapis.com/maps/api/place/autocomplete/json?'
  //     'input=hyd' // input type
  //     '&types=address' // get address of particular area
  //     '&language=en' // current location language
  //     '&components=country:in' // search location 'India' exclusive
  //     '&key=AIzaSyDPFVBgZDnp7Ee-6y8K5vPK_8kTOGfYAZ4' // Google places API Key
  //     '&sessiontoken=';
  // final client = Client();
  // final response = await client.get(Uri.parse(request));

  // Map<dynamic, dynamic> res = json.decode(response.body);

  // String request2 =
  //     "https://maps.googleapis.com/maps/api/place/details/json?place_id=${res['predictions'][0]['place_id']}&key=AIzaSyDPFVBgZDnp7Ee-6y8K5vPK_8kTOGfYAZ4";

  // final response2 = await client.get(Uri.parse(request2));
  // Map<dynamic, dynamic> res2 = json.decode(response2.body);
  // double lat = res2['result']['geometry']['location']['lat'];
  // double long = res2['result']['geometry']['location']['lng'];
  // String request3 =
  //     'https://maps.googleapis.com/maps/api/place/nearbysearch/json?'
  //     'location=$lat,$long'
  //     '&radius=1500'
  //     '&type=restaurant'
  //     '&key=AIzaSyDPFVBgZDnp7Ee-6y8K5vPK_8kTOGfYAZ4';
  // final response3 = await client.get(Uri.parse(request3));
  // Map<dynamic, dynamic> res3 = json.decode(response3.body);
  // print(res3);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google Places Demo',
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Places Autocomplete Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  var query;
  Suggestion result;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        margin: EdgeInsets.only(left: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              controller: _controller,
              readOnly: true,
              onTap: () async {
                // generate a new token here
                final sessionToken = Uuid().v4();
                result = await showSearch(
                  context: context,
                  delegate: AddressSearch(sessionToken),
                );
                setState(() {});
              },
              decoration: InputDecoration(
                icon: Container(
                  width: 10,
                  height: 10,
                  child: Icon(
                    Icons.place_outlined,
                  ),
                ),
                hintText: "Enter location",
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(left: 8.0, top: 16.0),
              ),
            ),
            if (result != null)
              FutureBuilder(
                  future:
                      PlaceApiProvider(Uuid().v4()).fetchNearby(result.placeId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done &&
                        snapshot.hasData)
                      return Container(
                        height: 500,
                        child: ListView.builder(
                          itemBuilder: (context, index) => ListTile(
                            title: Text(
                              (snapshot.data[index]['name']),
                            ),
                            leading: snapshot.data[index]['photos'] != null
                                ? Image.network(
                                    "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photo_reference=${snapshot.data[index]['photos'][0]['photo_reference']}&key=AIzaSyDPFVBgZDnp7Ee-6y8K5vPK_8kTOGfYAZ4",
                                  )
                                : SizedBox(),
                          ),
                          itemCount: snapshot.data.length,
                        ),
                      );
                    return Text('Loading...');
                  }),
          ],
        ),
      ),
    );
  }
}


import 'package:cabs/bottom_navbar.dart';
import 'package:cabs/checkout.dart';
import 'package:cabs/get_cart_items_list.dart';
import 'package:cabs/reusable_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class cart_item extends StatefulWidget {
  const cart_item({Key? key}) : super(key: key);
  static const route = "/cart_item";

  @override
  State<cart_item> createState() => _cart_itemState();
}

var fire_storedb = FirebaseFirestore.instance.collection("Cart").snapshots();
var user_email = "";
int cart_value=0;
var data_value ="0";

class _cart_itemState extends State<cart_item> {
  @override
  void initState() {
    getsharedpreferences();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Image.asset(
              "assets/images/app_logo.png",
              width: 70,
              height: 70,
            ),
          ),
          title: Text("Your Cart", style: TextStyle(color: Colors.black)),
          centerTitle: true,
          backgroundColor: Colors.white),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            child: listview(),
            height: MediaQuery.of(context).size.height / 1.3,
          ),
          Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                alignment: Alignment.bottomCenter,
                child: ElevatedButton(
                    onPressed: () async {
                      int cart_value2 = 0;
                      SharedPreferences sharedPreferences =
                          await SharedPreferences.getInstance();
                      var email = sharedPreferences.getString("email").toString();
                      FirebaseFirestore.instance
                          .collection("Cart").get().then((value) {
                        value.docs.forEach((element) {
                          FirebaseFirestore.instance
                              .collection("Cart").doc(element.id).get()
                              .then((value2) => {
                                    if (value2.data()!['email'] == email)
                                      {
                                        cart_value2 = cart_value2 +
                                            (value2.data()!['quantity']) as int,
                                        sharedPreferences.setInt(
                                            "value", cart_value2),
                                        print(sharedPreferences.getInt("value"))
                                      }
                                  });
                        });
                      });
                      Navigator.pushNamed(context, checkout.route);
                    },
                    child: Text("Proceed to Checkout")),
              ))
        ],
      ),
      bottomNavigationBar: bottom_navbar(),
    );
  }


  Widget listview() {
    return Container(
      alignment: Alignment.center,
      child: Card(
        child: StreamBuilder(
          stream: fire_storedb,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const CircularProgressIndicator();
            return (ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                if (snapshot.data!.docs[index]['email'].toString() == user_email) {
                  return (get_cart_items_list(snapshot, index));
                }
                else {
                  return (Container());
                }
              },
            ));
          },
        ),
      ),
    );
  }
  void getsharedpreferences() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var email = sharedPreferences.getString("email").toString();
    //var value = sharedPreferences.getInt("value").toString();
    setState(() {
      /*print(value);
      data_value=value;*/
      user_email = email;
    });
  }
}
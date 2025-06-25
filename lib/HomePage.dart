import 'package:flutter/material.dart';
import 'AddUserPage.dart';
import 'DatabaseHelper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text(
            "SQF LITE",
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
          ),
          centerTitle: true,
        ),
        body: FutureBuilder<bool>(
          builder: (context, snapshot1) {
            if (snapshot1.hasData) {
              return FutureBuilder<List<Map<String, Object?>>>(
                builder: (context, snapshot) {
                  if (snapshot != null && snapshot.hasData) {
                    return ListView.builder(
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            Navigator.of(context)
                                .push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    AddUser(snapshot.data![index]),
                              ),
                            )
                                .then(
                                  (value) {
                                if (value == true) {
                                  setState(() {});
                                }
                              },
                            );
                          },
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          (snapshot.data![index]['UserName'])
                                              .toString(),
                                        ),
                                        SizedBox(
                                          width: 4,
                                        ),
                                        Text(
                                          (snapshot.data![index]['CityName'])
                                              .toString(),
                                        ),
                                        SizedBox(
                                          height: 4,
                                        ),
                                        Text(
                                          (snapshot.data![index]['Dob'])
                                              .toString(),
                                        ),
                                      ],
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Navigator.of(context)
                                          .push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              AddUser(snapshot.data![index]),
                                        ),
                                      )
                                          .then(
                                            (value) {
                                          if (value == true) {
                                            setState(() {});
                                          }
                                        },
                                      );
                                    },
                                    child: Icon(
                                      Icons.edit,
                                      color: Colors.green,
                                      size: 24,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      deleteUser(
                                          snapshot.data![index]["UserID"]).then(
                                            (value) {
                                          setState(() {});
                                        },
                                      );
                                    },
                                    child: Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                      size: 24,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      itemCount: snapshot.data!.length,
                    );
                  } else {
                    return Center(
                        child: CircularProgressIndicator(
                          color: Colors.black,
                        ));
                  }
                },
                future: MyDatabase().getUserListFromTable(),
              );
            } else {
              return CircularProgressIndicator();
            }
          },
          future: MyDatabase().copyPasteAssetFileToRoot(),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context)
                .push(
              MaterialPageRoute(
                builder: (context) => AddUser(null),
              ),
            )
                .then(
                  (value) {
                if (value == true) {
                  setState(() {});
                }
              },
            );
          },
          backgroundColor: Colors.black,
          child: Container(
            child: Icon(
              Icons.add,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Future<int> deleteUser(id)  async {
    int userID = await MyDatabase().deleteUserDetails(id);
    return userID;
  }
}
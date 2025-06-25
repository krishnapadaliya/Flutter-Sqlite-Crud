import 'package:flutter/material.dart';
import 'DatabaseHelper.dart';

class AddUser extends StatefulWidget {
  AddUser(this.map, {super.key});
  Map<String, Object?>? map;

  @override
  State<AddUser> createState() => _AddUserState();
}

class _AddUserState extends State<AddUser> {
  TextEditingController firstNameController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  CityModel? _ddSelectedValue;
  List<CityModel> _cities = [];

  @override
  void initState() {
    super.initState();
    firstNameController.text =
    widget.map == null ? "" : widget.map!['UserName'].toString();
    dateController.text =
    widget.map == null ? "" : widget.map!['Dob'].toString();

    loadCities(); // Load city list
  }

  Future<void> loadCities() async {
    List<CityModel> cities = await MyDatabase().getCityList();
    setState(() {
      _cities = cities;
      if (cities.isNotEmpty) {
        _ddSelectedValue = cities.first;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          centerTitle: true,
          title: Text(
            "Add User",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  TextFormField(
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Enter First Name';
                      }
                      return null;
                    },
                    controller: firstNameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Enter First Name",
                      labelStyle: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Enter Date';
                      }
                      return null;
                    },
                    controller: dateController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Enter DOB",
                      labelStyle: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Select City",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      (_cities.isEmpty)
                          ? CircularProgressIndicator()
                          : DropdownButton<CityModel>(
                        value: _ddSelectedValue,
                        items: _cities.map((CityModel e) {
                          return DropdownMenuItem(
                            value: e,
                            child: Text(e.Name.toString()),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _ddSelectedValue = value!;
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.black,
                    ),
                    child: TextButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate() &&
                            _ddSelectedValue != null) {
                          if (widget.map == null) {
                            await insertUser();
                          } else {
                            await updateUser(widget.map!['UserID']);
                          }
                          Navigator.of(context).pop(true);
                        }
                      },
                      child: Text(
                        "Submit",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<int> insertUser() async {
    Map<String, dynamic> map = {
      "Name": firstNameController.text,
      "Dob": dateController.text,
      "CityID": _ddSelectedValue!.CityID!,
    };
    return await MyDatabase().insertUserDetails(map);
  }

  Future<int> updateUser(id) async {
    Map<String, dynamic> map = {
      "Name": firstNameController.text,
      "Dob": dateController.text,
      "CityID": _ddSelectedValue!.CityID!,
    };
    return await MyDatabase().updateUserDetails(map, id);
  }
}

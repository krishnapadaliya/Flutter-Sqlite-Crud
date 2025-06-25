import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class MyDatabase {
  Future<Database> initDatabase() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String databasePath = join(appDocDir.path, 'api_db.db');
    return await openDatabase(databasePath);
  }

  Future<bool> copyPasteAssetFileToRoot() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "api_db.db");

    if (FileSystemEntity.typeSync(path) == FileSystemEntityType.notFound) {
      ByteData data =
      await rootBundle.load(join('assets/database', 'api_db.db'));
      List<int> bytes =
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(path).writeAsBytes(bytes);
      return true;
    }
    return false;
  }

  Future<List<Map<String, Object?>>> getUserListFromTable() async {
    Database db = await initDatabase();
    List<Map<String, Object?>> data = await db.rawQuery(
        "SELECT Tbl_User.Name as UserName,Tbl_City.Name as CityName,UserID,Dob FROM Tbl_User INNER JOIN Tbl_City ON Tbl_User.CityId = Tbl_City.CityId");
    return data;
  }

  Future<List<CityModel>> getCityList() async {
    Database db = await initDatabase();
    List<Map<String, Object?>> data =
    await db.rawQuery("Select * From Tbl_City");
    List<CityModel> cityList = [];
    for (int i = 0; i < data.length; i++) {
      CityModel model = CityModel();
      model.CityID = int.parse(data[i]['CityID'].toString());
      model.Name = data[i]['Name'].toString();
      cityList.add(model);
    }
    return cityList;
  }

  Future<int> insertUserDetails(map) async {
    Database db = await initDatabase();
    int userID = await db.insert("Tbl_User", map);
    return userID;
  }

  Future<int> updateUserDetails(map,id) async {
    Database db = await initDatabase();
    int userID =
    await db.update("Tbl_User", map, where: "UserID=?", whereArgs: [id]);
    return userID;
  }

  Future<int> deleteUserDetails(id) async {
    Database db = await initDatabase();
    int userID = await db.delete("Tbl_User",where: "UserID = ?",whereArgs: [id]);
    return userID;
  }
}

class CityModel{
  int? _CityID;
  String? _Name;

  int? get CityID => _CityID;

  set CityID(int? value) {
    _CityID = value;
  }


  String? get Name => _Name;

  set Name(String? value) {
    _Name = value;
  }

}
// // ignore_for_file: prefer_const_constructors, unnecessary_null_comparison, must_be_immutable, unused_field, unnecessary_cast, no_leading_underscores_for_local_identifiers, body_might_complete_normally_nullable, unused_local_variable, prefer_const_literals_to_create_immutables, use_build_context_synchronously
// import 'dart:convert';
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'db_contact.dart';
// import 'package:image_picker/image_picker.dart';

// class ObservationListScreen extends StatefulWidget {
//   final int hikeId;
//   final List<Map<String, dynamic>> allData;
//   ObservationListScreen({required this.hikeId, required this.allData});

//   @override
//   _ObservationListScreenState createState() => _ObservationListScreenState();
// }

// class _ObservationListScreenState extends State<ObservationListScreen> {
//   Uint8List? _image;

//   final _bottomSheetFormKey = GlobalKey<FormState>();

//   bool _isLoading = true;
//   late final List<Map<String, dynamic>> allData;
//   TextEditingController _observationController = TextEditingController();
//   TextEditingController _timeController = TextEditingController();
//   TextEditingController _commentController = TextEditingController();
//   TextEditingController _imageController = TextEditingController();

//   void _refreshData() async {
//     final data = await SQLHelper.getAllDataWithObservations();
//     print("Data: $data");
//     setState(() {
//       allData = data;
//       _isLoading = false;
//     });
//   }

//   @override
//   void initState() {
//     super.initState();
//     _refreshData();
//   }

//   late TimeOfDay _selectedTime;
//   Future<void> _selectTime(BuildContext context) async {
//     final TimeOfDay? picked = await showTimePicker(
//       context: context,
//       initialTime: _selectedTime,
//     );
//     if (picked != null && picked != _selectedTime) {
//       setState(() {
//         _selectedTime = picked;
//         _timeController.text = picked.format(context);
//       });
//     }
//   }

//   Future<void> _addDataObservation(int dataInfoId) async {
//     try {
//       await SQLHelper.createDataObservation(
//         _observationController.text,
//         _timeController.text,
//         _commentController.text,
//         Uint8List.fromList(base64.decode(_imageController.text)),
//         dataInfoId,
//       );
//       _refreshData();
//       setState(() {});
//     } catch (e) {
//       print("Error adding data observation: $e");
//     }
//   }

//   Future<void> _updateDataObservation(int id) async {
//     await SQLHelper.updateDataObservation(id, _observationController.text,
//         _timeController.text, _commentController.text, _imageController.text);
//     _refreshData();
//   }

//   Future<void> _deleteDataObservation(int id) async {
//     await SQLHelper.deleteDataObservation(id);
//     ScaffoldMessenger.of(context as BuildContext).showSnackBar(const SnackBar(
//       backgroundColor: Colors.redAccent,
//       content: Text("Your Data Deleted"),
//     ));
//   }

//   Future<void> _showDeleteConfirmationDialog(BuildContext context, id) async {
//     return showDialog<void>(
//       context: context,
//       barrierDismissible:
//           false, // Không cho phép người dùng bấm ra ngoài để đóng hộp thoại
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Confirm Delete'),
//           content: Text('Are you sure you want to delete this data?'),
//           actions: <Widget>[
//             TextButton(
//               child: Text('Cancel'),
//               onPressed: () {
//                 Navigator.of(context).pop(); // Đóng hộp thoại
//               },
//             ),
//             TextButton(
//               child: Text('Delete'),
//               onPressed: () {
//                 // Gọi hàm xóa dữ liệu ở đây
//                 _deleteDataObservation(id);
//                 _refreshData();
//                 Navigator.of(context).pop(); // Đóng hộp thoại
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void selectImageLibrary() async {
//     Uint8List? img = await pickerImage(ImageSource.gallery);
//     if (img != null) {
//       String? base64Image = await convertImageToBase64(img);
//       setState(() {
//         _image = img;
//         _imageController.text = base64Image!; // Update the image controller
//       });
//     }
//   }

//   void selectImageCamera() async {
//     Uint8List? img = await pickerImage(ImageSource.camera);
//     if (img != null) {
//       String? base64Image = await convertImageToBase64(img);
//       setState(() {
//         _image = img;
//         _imageController.text = base64Image!; // Update the image controller
//       });
//     }
//   }

//   Future<Uint8List?> pickerImage(ImageSource source) async {
//     final ImagePicker _imagePicker = ImagePicker();
//     XFile? _file = await _imagePicker.pickImage(source: source);
//     if (_file != null) {
//       return await _file.readAsBytes();
//     }
//     print('No Image Selected');
//   }

//   Future<String?> convertImageToBase64(Uint8List? imageBytes) async {
//     if (imageBytes != null) {
//       String base64String = base64Encode(imageBytes);
//       return base64String;
//     }
//     return null; // Return null if no image bytes are provided
//   }

//   int? dataInfoId;
//   void showAddObservationForm(int? id) async {
//     //  int hikeId
//     dataInfoId = id;
//     if (id != null) {
//       final existingData = allData.firstWhere((element) => element['id'] == id);
//       _observationController.text = existingData['observation'];
//       _timeController.text = existingData['time'] ??= "";
//       _commentController.text = existingData['comment'] ??= "";
//       // dataInfoId = existingData['data_info_id'];
//       _imageController.text = existingData['image'] ??= "";
//     }
//     final _formKey = GlobalKey<FormState>();
//     bool _isFormValid = false; // Biến để theo dõi tính hợp lệ của Form
//     showModalBottomSheet(
//       context: context,
//       elevation: 5,
//       isScrollControlled: true,
//       builder: (_) => Container(
//         padding: EdgeInsets.only(
//           top: 20,
//           left: 15,
//           right: 15,
//           bottom: MediaQuery.of(context).viewInsets.bottom + 50,
//         ),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             mainAxisAlignment: MainAxisAlignment.end,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   _image != null
//                       ? CircleAvatar(
//                           radius: 80,
//                           backgroundImage: MemoryImage(_image!),
//                         )
//                       : _imageController.text.isNotEmpty
//                           ? CircleAvatar(
//                               radius: 64,
//                               backgroundImage: MemoryImage(
//                                   base64.decode(_imageController.text)))
//                           : CircleAvatar(
//                               radius: 64,
//                               child: Image.asset(
//                                 "images/avatar.jpg",
//                               ),
//                             ),
//                   SizedBox(width: 30), // Khoảng cách giữa hai biểu tượng
//                   ElevatedButton(
//                     onPressed: () => selectImageLibrary(),
//                     child: Icon(
//                       Icons.image,
//                       size: 20,
//                     ),
//                   ),
//                   SizedBox(
//                     width: 30,
//                   ),
//                   ElevatedButton(
//                     onPressed: () => selectImageCamera(),
//                     child: Icon(
//                       Icons.add_a_photo,
//                       size: 20,
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(
//                 height: 5,
//               ),
//               TextField(
//                 controller: _observationController,
//                 decoration:
//                     InputDecoration(labelText: 'Name', hintText: 'Name'),
//               ),
//               SizedBox(
//                 height: 5,
//               ),
//               TextField(
//                 controller: _timeController,
//                 decoration:
//                     InputDecoration(labelText: 'Time', hintText: 'Time'),
//               ),
//               SizedBox(
//                 height: 5,
//               ),
//               TextField(
//                 controller: _commentController,
//                 decoration:
//                     InputDecoration(labelText: 'Comment', hintText: 'comments'),
//               ),
//               SizedBox(
//                 height: 10,
//               ),
//               Center(
//                 child:
//                     ElevatedButton(
//                       onPressed: () async {
//                         if (_formKey.currentState!.validate()) {
//                           if (id == null) {
//                             await _addDataObservation(dataInfoId!);
//                           }
//                           if (id != null) {
//                             await _updateDataObservation(id);
//                           }
//                           _observationController.text = '';
//                           _timeController.text = '';
//                           _commentController.text = '';
//                           _imageController.text = '';
//                           // Hide bottom sheet
//                           Navigator.of(context).pop();
//                           print("Data added");
//                         }
//                       },
//                       child: Text(
//                         id == null ? 'Add' : 'Update',
//                         style: TextStyle(
//                           fontSize: 18,
//                           color: Colors.white,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ),

//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color.fromARGB(255, 235, 223, 164),
//       appBar: AppBar(
//         title: Text("List of observations"),
//       ),
//       body: _isLoading
//           ? Center(
//               child: CircularProgressIndicator(),
//             )
//           : ListView.builder(
//               itemCount: allData.length,
//               itemBuilder: (context, index) => Card(
//                 margin: EdgeInsets.all(15),
//                 child: ListTile(
//                   leading: CircleAvatar(
//                     radius: 30,
//                     backgroundImage: allData[index]['image'].isNotEmpty
//                         ? MemoryImage(base64.decode(allData[index]['image']))
//                             as ImageProvider
//                         : NetworkImage(
//                                 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcReiyHYtDJQ0t5jCs4j_PiD5ESMvPwnvHVa3w&usqp=CAU')
//                             as ImageProvider,
//                   ),
//                   title: Padding(
//                     padding: EdgeInsets.symmetric(vertical: 5),
//                     child: Text(
//                       allData[index]['observation'],
//                       style: TextStyle(
//                         fontSize: 20,
//                       ),
//                     ),
//                   ),
//                   subtitle: Text(allData[index]['time']),
//                   trailing: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       IconButton(
//                         onPressed: () {
//                           showAddObservationForm(allData[index]['id']);
//                         },
//                         icon: Icon(
//                           Icons.edit,
//                           color: Colors.indigo,
//                         ),
//                       ),
//                       IconButton(
//                         icon: Icon(Icons.delete),
//                         color: Colors.red,
//                         onPressed: () {
//                           _showDeleteConfirmationDialog(
//                               context, allData[index]['id']);
//                         },
//                       )
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () => showAddObservationForm(dataInfoId),
//         child: Icon(
//           Icons.add,
//           color: Colors.blue,
//           size: 50,
//         ),
//       ),
//     );
//   }
// }

// ignore_for_file: depend_on_referenced_packages, prefer_const_constructors, unnecessary_cast, prefer_final_fields

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'db_contact.dart';
import 'package:image_picker/image_picker.dart';

class ObservationListScreen extends StatefulWidget {
  final int hikeId;
  final List<Map<String, dynamic>> allData;
  ObservationListScreen({required this.hikeId, required this.allData});

  @override
  _ObservationListScreenState createState() => _ObservationListScreenState();
}
//test commmit
class _ObservationListScreenState extends State<ObservationListScreen> {
  Uint8List? _image;

  bool _isLoading = true;
  late final List<Map<String, dynamic>> allData;
  TextEditingController _observationController = TextEditingController();
  TextEditingController _timeController = TextEditingController();
  TextEditingController _commentController = TextEditingController();
  TextEditingController _imageController = TextEditingController();

  void _refreshData() async {
    final data = await SQLHelper.getAllDataWithObservations();
    print("Data: $data");
    setState(() {
      allData = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  TimeOfDay? _selectedTime = TimeOfDay.now();
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        _timeController.text = picked.format(context);
      });
    }
  }

  Future<void> _addDataObservation(int dataInfoId) async {
    try {
      await SQLHelper.createDataObservation(
        dataInfoId,
        _observationController.text,
        _timeController.text,
        _commentController.text,
        Uint8List.fromList(base64.decode(_imageController.text)),
      );
      _refreshData();
      setState(() {});
    } catch (e) {
      print("Error adding data observation: $e");
    }
  }

  Future<void> _updateDataObservation(int id) async {
    await SQLHelper.updateDataObservation(id, _observationController.text,
        _timeController.text, _commentController.text, _imageController.text);
    _refreshData();
  }

  Future<void> _deleteDataObservation(int id) async {
    await SQLHelper.deleteDataObservation(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      backgroundColor: Colors.redAccent,
      content: Text("Your Data Deleted"),
    ));
  }

  Future<void> _showDeleteConfirmationDialog(BuildContext context, id) async {
    return showDialog<void>(
      context: context,
      barrierDismissible:
          false, // Không cho phép người dùng bấm ra ngoài để đóng hộp thoại
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this data?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Đóng hộp thoại
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                // Gọi hàm xóa dữ liệu ở đây
                _deleteDataObservation(id);
                _refreshData();
                Navigator.of(context).pop(); // Đóng hộp thoại
              },
            ),
          ],
        );
      },
    );
  }

  void selectImageLibrary() async {
    Uint8List? img = await pickerImage(ImageSource.gallery);
    if (img != null) {
      String? base64Image = await convertImageToBase64(img);
      setState(() {
        _image = img;
        _imageController.text = base64Image!; // Update the image controller
      });
    }
  }

  void selectImageCamera() async {
    Uint8List? img = await pickerImage(ImageSource.camera);
    if (img != null) {
      String? base64Image = await convertImageToBase64(img);
      setState(() {
        _image = img;
        _imageController.text = base64Image!; // Update the image controller
      });
    }
  }

  Future<Uint8List?> pickerImage(ImageSource source) async {
    final ImagePicker _imagePicker = ImagePicker();
    XFile? _file = await _imagePicker.pickImage(source: source);
    if (_file != null) {
      return await _file.readAsBytes();
    }
    print('No Image Selected');
  }

  Future<String?> convertImageToBase64(Uint8List? imageBytes) async {
    if (imageBytes != null) {
      String base64String = base64Encode(imageBytes);
      return base64String;
    }
    return null; // Return null if no image bytes are provided
  }

  int? dataInfoId;
  void showAddObservationForm(int? id) async {
    dataInfoId = id;
    if (id != null) {
      final existingData =
          allData.firstWhere((element) => element['dataInfoId'] == id);
      _observationController.text = existingData['observation'];
      _timeController.text = existingData['time'] ??= "";
      _commentController.text = existingData['comment'] ??= "";
      _imageController.text = existingData['image'] ??= "";
    }
    final _formKey = GlobalKey<FormState>();
    showModalBottomSheet(
      context: context,
      elevation: 5,
      isScrollControlled: true,
      builder: (_) => Container(
        padding: EdgeInsets.only(
          top: 20,
          left: 15,
          right: 15,
          bottom: MediaQuery.of(context).viewInsets.bottom + 50,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _image != null
                      ? CircleAvatar(
                          radius: 80,
                          backgroundImage: MemoryImage(_image!),
                        )
                      : _imageController.text.isNotEmpty
                          ? CircleAvatar(
                              radius: 64,
                              backgroundImage: MemoryImage(
                                  base64.decode(_imageController.text)))
                          : CircleAvatar(
                              radius: 64,
                              child: Image.asset("images/avatar.jpg"),
                            ),
                  SizedBox(width: 30), // Khoảng cách giữa hai biểu tượng
                  ElevatedButton(
                    onPressed: () => selectImageLibrary(),
                    child: Icon(
                      Icons.image,
                      size: 20,
                    ),
                  ),
                  SizedBox(
                    width: 30,
                  ),
                  ElevatedButton(
                    onPressed: () => selectImageCamera(),
                    child: Icon(
                      Icons.add_a_photo,
                      size: 20,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              TextFormField(
                controller: _observationController,
                decoration: InputDecoration(
                    labelText: 'Observation', hintText: 'Observation'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter an observation';
                  }
                  return null;
                },
              ),
              SizedBox(
                height: 5,
              ),
              TextFormField(
                controller: _timeController,
                decoration: InputDecoration(
                  labelText: 'Time',
                  hintText: 'Time',
                ),
                onTap: () {
                  // Mở hộp thoại chọn giờ
                  _selectTime(context);
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a time';
                  }
                  return null;
                },
              ),
              SizedBox(
                height: 5,
              ),
              TextFormField(
                controller: _commentController,
                decoration:
                    InputDecoration(labelText: 'Comment', hintText: 'Comment'),
              ),
              SizedBox(
                height: 10,
              ),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      if (id == null) {
                        await _addDataObservation(dataInfoId!);
                      }
                      if (id != null) {
                        await _updateDataObservation(id);
                      }
                      _observationController.text = '';
                      _timeController.text = '';
                      _commentController.text = '';
                      _imageController.text = '';
                      // Hide bottom sheet
                      Navigator.of(context).pop();
                      print("Data added");
                    }
                  },
                  child: Text(
                    id == null ? 'Add Observation' : 'Update Observation',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 235, 223, 164),
      appBar: AppBar(
        title: Text("List of observations"),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: allData.length,
              itemBuilder: (context, index) => Card(
                margin: EdgeInsets.all(15),
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundImage: allData[index]['image'].isNotEmpty
                        ? MemoryImage(base64.decode(allData[index]['image']))
                            as ImageProvider
                        : NetworkImage(
                                'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcReiyHYtDJQ0t5jCs4j_PiD5ESMvPwnvHVa3w&usqp=CAU')
                            as ImageProvider,
                  ),
                  title: Padding(
                    padding: EdgeInsets.symmetric(vertical: 5),
                    child: Text(
                      allData[index]['observation'],
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                  subtitle: Text(allData[index]['time']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          showAddObservationForm(allData[index]['dataInfoId']);
                        },
                        icon: Icon(
                          Icons.edit,
                          color: Colors.indigo,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        color: Colors.red,
                        onPressed: () {
                          _showDeleteConfirmationDialog(
                              context, allData[index]['id']);
                        },
                      )
                    ],
                  ),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddObservationForm(dataInfoId),
        child: Icon(
          Icons.add,
          color: Colors.blue,
          size: 50,
        ),
      ),
    );
  }
}

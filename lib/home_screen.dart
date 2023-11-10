// ignore_for_file: prefer_const_constructors, no_leading_underscores_for_local_identifiers, unused_local_variable, unused_field, unused_element

import 'package:corev3/ObservationListScreen.dart';
import 'package:flutter/material.dart';
import 'db_contact.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _allData = [];
  List<Map<String, dynamic>> _visibleData = []; // for searching
  int _visibleItemCount = 6; // Số dữ liệu hiển thị ban đầu
  int _currentPage = 1; // Trang hiện tại
  bool _isLoading = true;
  bool _showLess = false;
  bool _showMore = true;
  bool _showMoreButtonVisible = true;
  bool _addingObservation = false;
  bool get hasMoreData => _visibleItemCount < _allData.length;
  final ScrollController _scrollController = ScrollController();

  void _refreshData() async {
    final data = await SQLHelper.getAllData();
    setState(() {
      _allData = data;
      _isLoading = false;
    });
  }

  void _loadMoreData() {
    if (_visibleItemCount + 6 <= _allData.length) {
      setState(() {
        _visibleItemCount += 6;
        _currentPage++;
        _showLess = true;
        _showMoreButtonVisible = false;
      });
    } else {
      setState(() {
        _visibleItemCount = _allData.length;
        _showMore = false;
        _showLess = true;
        _showMoreButtonVisible = false;
      });
    }
  }

  void _showLessData() {
    setState(() {
      _visibleItemCount = 6;
      _currentPage = 1;
      _showMore = true; // Đặt _showMore thành true khi ấn "Show Less"
      _showLess = false;
      _showMoreButtonVisible = true;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadDataFromDatabase();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (_showMore) {
          _loadMoreData();
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadDataFromDatabase() async {
    final data = await SQLHelper.getDataFromDatabase();
    print("Data loaded: $data");
    setState(() {
      _allData = data;
      _visibleData = data;
      _isLoading = false;
    });
    _refreshData();
  }

  Future<void> _deleteData(int id) async {
    await SQLHelper.deleteDataInfo(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      backgroundColor: Colors.redAccent,
      content: Text("Your Data Deleted"),
    ));
    _refreshData();
  }

  Future<void> _showDeleteConfirmationDialog(BuildContext context, id) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this data?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                _deleteData(id);
                _refreshData();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  final _bottomSheetFormKey = GlobalKey<FormState>();
  final _informationFormKey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _locationController = TextEditingController();
  TextEditingController _dateController = TextEditingController();
  TextEditingController _parkingController = TextEditingController();
  TextEditingController _lengthController = TextEditingController();
  TextEditingController _difficultyController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _searchController = TextEditingController();
 

  Future<void> _addDataInfo() async {
    await SQLHelper.createHikeInfo(
      _nameController.text,
      _locationController.text,
      _dateController.text,
      _parkingController.text,
      _lengthController.text,
      _difficultyController.text,
      _descriptionController.text,
    );
    _refreshData();
  }

 
  Future<void> _updateDataInfo(int id) async {
    await SQLHelper.updateHikeInfo(
      id,
      _nameController.text,
      _locationController.text,
      _dateController.text,
      _parkingController.text,
      _lengthController.text,
      _difficultyController.text,
      _descriptionController.text,
    );
  }

 

  Future<void> _deleteDataInfo(int id) async {
    await SQLHelper.deleteDataInfo(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      backgroundColor: Colors.redAccent,
      content: Text("Your Data Deleted"),
    ));
    _refreshData();
  }


  void _searchByName(String name) {
    setState(() {
      if (name.isEmpty) {
        _visibleData = _allData.sublist(0, _visibleItemCount);
      } else {
        _visibleData = _allData
            .where((dataInfo) =>
                dataInfo['name'].toLowerCase().contains(name.toLowerCase()))
            .toList();
      }
    });
  }



  void showBottomSheet(int? id) async {
    if (id != null) {
      bool _isFormValid = false; // Biến để theo dõi tính hợp lệ của Form
      bool _packingAvailableController = false;
      final existingData =
          _allData.firstWhere((element) => element['id'] == id);
      _nameController.text = existingData['name'] ??= "";
      _locationController.text = existingData['location'] ??= "";
      _dateController.text = existingData['date'] ?? "";
      _parkingController.text = existingData['parkingAvailable'] ?? "";
      _lengthController.text = existingData['length'] ?? "";
      _difficultyController.text = existingData['difficulty'] ?? "";
      _descriptionController.text = existingData['description'] ?? "";
    }
    showModalBottomSheet(
        context: context,
        elevation: 5,
        isScrollControlled: true,
        builder: (_) => Container(
              padding: EdgeInsets.only(
                top: 40,
                left: 15,
                right: 15,
                bottom: MediaQuery.of(context).viewInsets.bottom + 50,
              ),
              child: Form(
                key: _bottomSheetFormKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(labelText: 'Name of Hike *'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a name';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _nameController = value! as TextEditingController;
                      },
                    ),
                    TextFormField(
                      controller: _locationController,
                      decoration: InputDecoration(labelText: 'Location *'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a location';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _locationController = value! as TextEditingController;
                      },
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      controller: _dateController,
                      decoration: InputDecoration(
                        labelText: 'Date Hiking',
                        hintText: 'Date',
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a date';
                        }
                        return null;
                      },
                      onTap: () async {
                        DateTime? selectedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (selectedDate != null) {
                          _dateController.text =
                              selectedDate.toLocal().toString().split(' ')[0];
                        }
                      },
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      controller: _lengthController,
                      decoration:
                          InputDecoration(labelText: 'Length of Hike (Km) *'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter hike length';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _lengthController =
                            double.parse(value!) as TextEditingController;
                      },
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Text('Parking Available: '),
                        Row(
                          children: [
                            Radio(
                              value: true,
                              groupValue: _parkingController.text,
                              onChanged: (value) {
                                setState(() {
                                  _parkingController =
                                      value as TextEditingController;
                                });
                              },
                            ),
                            Text('Yes'),
                            Radio(
                              value: false,
                              groupValue: _parkingController.text,
                              onChanged: (value) {
                                setState(() {
                                  _parkingController.text = value as String;
                                });
                              },
                            ),
                            Text('No'),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text('Difficulty Level: '),
                        Radio(
                          value: 'Low',
                          groupValue: _difficultyController.text,
                          onChanged: (value) {
                            setState(() {
                              _difficultyController.text = 'Low';
                            });
                          },
                        ),
                        Text('Low'),
                        Radio(
                          value: 'Medium',
                          groupValue: _difficultyController.text,
                          onChanged: (value) {
                            setState(() {
                              _difficultyController.text = 'Medium';
                            });
                          },
                        ),
                        Text('Medium'),
                        Radio(
                          value: 'High',
                          groupValue: _difficultyController.text,
                          onChanged: (value) {
                            setState(() {
                              _difficultyController.text = 'High';
                            });
                          },
                        ),
                        Text('High'),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(labelText: 'Description'),
                      onSaved: (value) {
                        _descriptionController =
                            value! as TextEditingController;
                      },
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_bottomSheetFormKey.currentState!.validate()) {
                            showDataConfirmationDialog(context, id: id);
                          }
                        },
                        child: Text(
                          id == null ? 'Add Information' : 'Update',
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
            ));
  }

 
  Future<void> showDataConfirmationDialog(BuildContext context,
      {int? id}) async {
    bool isEditing = id != null;
    final confirmationResult = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isEditing
              ? 'Confirm Hike information'
              : 'Confirm Hike Information'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Name: ${_nameController.text}'),
              Text('Location: ${_locationController.text}'),
              Text('Date Hiking: ${_dateController.text}'),
              Text('Length: ${_lengthController.text} Km'),
              Text(
                  'Parking Available: ${_parkingController.text == 'true' ? 'Yes' : 'No'}'),
              Text('Difficulty Level: ${_difficultyController.text}'),
              Text('Description: ${_descriptionController.text}'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false); // Không thêm/cập nhật dữ liệu
              },
            ),
            TextButton(
              child: Text(isEditing ? 'Update' : 'Add'),
              onPressed: () {
                Navigator.of(context)
                    .pop(true); // Đánh dấu xác nhận để thêm/cập nhật dữ liệu
              },
            ),
          ],
        );
      },
    );

    if (confirmationResult == true) {
      if (isEditing) {
        await _updateDataInfo(id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Update successful'),
            backgroundColor: Colors.green, // Màu nền của thông báo
          ),
        );
      } else {
        await _addDataInfo();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Add successful'),
            backgroundColor: Colors.green, // Màu nền của thông báo
          ),
        );
      }
      _nameController.clear();
      _locationController.clear();
      _dateController.clear();
      _lengthController.clear();
      _parkingController.clear();
      _difficultyController.clear();
      _descriptionController.clear();
      _refreshData();
      print("Data added/updated");
      Navigator.of(context).pop(); // Quay lại HomeScreen
    }
  }

  @override
  Widget build(BuildContext context) {
    final visibleData = _allData.sublist(0, _visibleItemCount);
    return Scaffold(
        appBar: AppBar(
          title: Text('Hike Page'),
          automaticallyImplyLeading: false,
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: 250, // Điều chỉnh kích thước TextField
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by name',
                    icon: Icon(Icons.search),
                  ),
                  onChanged: (text) {
                    _searchByName(_searchController.text);
                  },
                ),
              ),
            ),
          ],
        ),
        body: _isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: visibleData.length,
                      itemBuilder: (context, index) => GestureDetector(
                        onTap: () {
                          final hikeId = _allData[index]['id'];
                          if (hikeId != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ObservationListScreen(
                                    hikeId: hikeId, allData: _allData),
                              ),
                            );
                          } else {
                            // Xử lý trường hợp `_allData[index]['hikeId']` là `null` ở đây
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text('Error'),
                                  content:
                                      Text('Hike ID is missing for this item.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('OK'),
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        },
                        child: Card(
                            margin: EdgeInsets.all(15),
                            child: ListTile(
                              title: Padding(
                                padding: EdgeInsets.symmetric(vertical: 5),
                                child: Text(
                                  visibleData[index]['name'],
                                  style: TextStyle(
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                          'Location: ${_allData[index]['location']}'),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                          'Date: ${_allData[index]['date']} | '),
                                      Text(
                                          'Length: ${_allData[index]['length']}'),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(width: 3),
                                  IconButton(
                                    onPressed: () {
                                      showBottomSheet(_allData[index]['id']);
                                    },
                                    icon: Icon(
                                      Icons.edit,
                                      color: Colors.indigo,
                                    ),
                                  ),
                                  SizedBox(width: 3),
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    color: Colors.red,
                                    onPressed: () {
                                      _showDeleteConfirmationDialog(
                                          context, _allData[index]['id']);
                                    },
                                  )
                                ],
                              ),
                            )),
                      ),
                    ),
                  ),
                  if (_showMoreButtonVisible)
                    ElevatedButton(
                      onPressed: _loadMoreData,
                      child: Text('Show More'),
                    )
                  else if (_showLess)
                    ElevatedButton(
                      onPressed: _showLessData,
                      child: Text('Show Less'),
                    ),
                ],
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => showBottomSheet(null),
          child: Icon(
            Icons.add,
            color: Colors.blue,
            size: 50,
          ),
        ));
  }
}

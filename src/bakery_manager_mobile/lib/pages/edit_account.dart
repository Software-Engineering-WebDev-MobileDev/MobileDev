import 'package:bakery_manager_mobile/services/api_service.dart';
import 'package:flutter/material.dart';

class EditAccountPage extends StatefulWidget {
  const EditAccountPage({super.key});

  @override
  State<EditAccountPage> createState() => _EditAccountPageState();
}

class _EditAccountPageState extends State<EditAccountPage> {
  final _formKey = GlobalKey<FormState>();

  List<Map<String, dynamic>> _emails = [];
  List<Map<String, dynamic>> _phones = [];
  List<String> emailsToDelete = [];
  List<String> originalEmails = [];
  List<String> phonesToDelete = [];
  List<String> originalPhones = [];
  List<TextEditingController> _emailControllers = [];
  List<TextEditingController> _phoneControllers = [];

  final List<String> emailTypes = ["personal", "work", "other", "primary"];
  final List<String> phoneTypes = ["mobile", "home", "work", "fax", "primary"];

  @override
  void initState() {
    super.initState();

    // Set up controllers with default values (or empty)

    // Fetch user data when the page loads
    _fetchUserData();
  }

  @override
  void dispose() {
    for (var controller in _emailControllers) {
      controller.dispose();
    }
    for (var controller in _phoneControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  String _capitalizeFirstLetter(String input) {
    if (input.isEmpty) return input;
    return input[0].toUpperCase() + input.substring(1);
  }

  // Email validation function
  String? _validateEmail(String email) {
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (email.isEmpty) {
      return 'Email is required';
    } else if (!emailRegex.hasMatch(email)) {
      return 'Invalid email format.';
    }
    return null;
  }

  // Phone number validation function
  String? _validatePhone(String phone) {
    final phoneRegex = RegExp(r'^\d{10}$'); // Expecting 10 digits
    if (phone.isEmpty) {
      return 'Phone number is required';
    } else if (!phoneRegex.hasMatch(phone)) {
      return 'Phone number must be 10 digits long.';
    }
    return null;
  }

// Remove email field and handle primary email reassignment
void _removeEmailField(int index) {
  bool wasPrimary = _emails[index]['primary'];
  setState(() {
    emailsToDelete.add(_emails[index]['address']);
    _emails.removeAt(index);
    _emailControllers.removeAt(index).dispose();

    // If the removed email was primary and others remain, assign a new primary
    if (wasPrimary && _emails.isNotEmpty) {
      _emails[0]['primary'] = true;
      _emails[0]['type'] = 'primary'; // Set the first remaining one as primary
    }
  });
}

// Remove phone field and handle primary phone reassignment
void _removePhoneField(int index) {
  bool wasPrimary = _phones[index]['primary'];
  setState(() {
    phonesToDelete.add(_phones[index]['number']);
    _phones.removeAt(index);
    _phoneControllers.removeAt(index).dispose();

    // If the removed phone was primary and others remain, assign a new primary
    if (wasPrimary && _phones.isNotEmpty) {
      _phones[0]['primary'] = true;
      _phones[0]['type'] = 'primary'; // Set the first remaining one as primary
    }
  });
}

  Future<void> _saveAccountChanges() async {
    if (_formKey.currentState!.validate()) {
      // Prepare to delete old emails
      List<Map<String, dynamic>> emailsToAdd = [];

      for (var email in originalEmails) {
        await ApiService.deleteUserEmail(emailAddress: email);
      }
      // Delete old phone numbers
      for (var phone in originalPhones) {
        await ApiService.deleteUserPhone(phoneNumber: phone);
      }

 // Check for new emails to add
      for (var i = 0; i < _emailControllers.length; i++) {
        String emailAddress = _emailControllers[i].text;
        if (emailAddress.isNotEmpty) {
          emailsToAdd.add({
            'address': emailAddress,
            'type': _emails[i]['type'],
            'isPrimary': _emails[i]['primary'],
          });
        }
      }

      // Delete old emails
      for (var email in emailsToDelete) {
        await ApiService.deleteUserEmail(emailAddress: email);
      }

      // Add new emails
      for (var emailData in emailsToAdd) {
        await ApiService.addUserEmail(
          emailAddress: emailData['address'],
          type: emailData['type'],
        );
      }

      List<Map<String, dynamic>> phonesToAdd = [];

      // Check for new phone numbers to add
      for (var i = 0; i < _phoneControllers.length; i++) {
        String phoneNumber = _phoneControllers[i].text;
        if (phoneNumber.isNotEmpty) {
          phonesToAdd.add({
            'number': phoneNumber,
            'type': _phones[i]['type'],
            'isPrimary': _phones[i]['primary'],
          });
        }
      }

      // Delete old phone numbers
      for (var phone in phonesToDelete) {
        await ApiService.deleteUserPhone(phoneNumber: phone);
      }

      // Add new phone numbers
      for (var phoneData in phonesToAdd) {
        await ApiService.addUserPhone(
          phoneNumber: phoneData['number'],
          type: phoneData['type'],
        );
      }

      Map<String, dynamic> response =
          await Future.delayed(const Duration(seconds: 0), () {
        return {'status': 'success'};
      });

      bool accountUpdated = response['status'] == 'success';

      if (accountUpdated) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account updated successfully!')),
        );
        Navigator.pop(context); // Go back after success
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Account update failed: ${response['reason']}'),
          ),
        );
      }
    }
  }

// Build emails field with fixed primary dropdown handling and value reset
Column _buildEmailsField() {
  return Column(
    children: _emails.asMap().entries.map((entry) {
      int idx = entry.key;
      var email = entry.value;
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Row(
          children: [
          // Email Text Field
          Expanded(
            child: TextFormField(
              controller: _emailControllers[idx],
              // maxLength removed
              decoration: InputDecoration(
                hintText: 'Email ${idx + 1}',
                border: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(
                    color: _validateEmail(_emailControllers[idx].text) == null
                        ? Colors.grey
                        : Colors.red,
                  ),
                ),
              ),
              onChanged: (value) {
                // Enforce max length of 50 characters
                if (value.length > 50) {
                  _emailControllers[idx].text = value.substring(0, 50);
                  _emailControllers[idx].selection = TextSelection.fromPosition(
                    TextPosition(offset: 50),
                  );
                }
                setState(() {});
              },
              validator: (value) => _validateEmail(value!),
            ),
          ),
            const SizedBox(width: 8),

            // Primary Radio Button
            Radio<bool>(
              value: true,
              groupValue: email['primary'],
              onChanged: (value) {
                setState(() {
                  // Clear all other primary flags
                  for (var em in _emails) {
                    em['primary'] = false;
                    if (em['type'] == 'primary') {
                      em['type'] = emailTypes[0]; // Reset to default type
                    }
                  }
                  email['primary'] = true;
                  email['type'] = 'primary'; // Set type to primary
                });
              },
            ),
            const Text('Primary'),
            const SizedBox(width: 8),

            // Email Type Dropdown
            DropdownButton<String>(
              value: email['type'],
              onChanged: email['primary']
                  ? null // Disable dropdown when primary radio is selected
                  : (newValue) {
                      setState(() {
                        email['type'] = newValue!;
                      });
                    },
              items: email['primary']
                  ? [
                      const DropdownMenuItem(
                        value: 'primary',
                        child: Text('Primary'),
                      ),
                    ]
                  : emailTypes
                      .where((type) => type != 'primary')
                      .map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(_capitalizeFirstLetter(type)),
                        );
                      }).toList(),
            ),
            const SizedBox(width: 8),

            // Subtract/Remove Button
            if (_emails.length > 1)
              IconButton(
                icon: const Icon(Icons.remove_circle, color: Colors.red),
                onPressed: () => _removeEmailField(idx),
              ),
          ],
        ),
      );
    }).toList(),
  );
}

// Build phones field with fixed primary dropdown handling and value reset
Column _buildPhonesField() {
  return Column(
    children: _phones.asMap().entries.map((entry) {
      int idx = entry.key;
      var phone = entry.value;
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Row(
          children: [
            // Phone Number Field
            Expanded(
              child: TextFormField(
                controller: _phoneControllers[idx],
                maxLength: 10, // Limit phone number to 10 digits
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Phone ${idx + 1}',
                  border: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(
                      color:
                          _validatePhone(_phoneControllers[idx].text) == null
                              ? Colors.grey
                              : Colors.red,
                    ),
                  ),
                ),
                onChanged: (value) {
                  setState(() {});
                },
                validator: (value) => _validatePhone(value!),
              ),
            ),
            const SizedBox(width: 8),

            // Primary Radio Button
            Radio<bool>(
              value: true,
              groupValue: phone['primary'],
              onChanged: (value) {
                setState(() {
                  // Clear all other primary flags
                  for (var ph in _phones) {
                    ph['primary'] = false;
                    if (ph['type'] == 'primary') {
                      ph['type'] = phoneTypes[0]; // Reset to default type
                    }
                  }
                  phone['primary'] = true;
                  phone['type'] = 'primary'; // Set type to primary
                });
              },
            ),
            const Text('Primary'),
            const SizedBox(width: 8),

            // Phone Type Dropdown
            DropdownButton<String>(
              value: phone['type'],
              onChanged: phone['primary']
                  ? null // Disable dropdown when primary radio is selected
                  : (newValue) {
                      setState(() {
                        phone['type'] = newValue!;
                      });
                    },
              items: phone['primary']
                  ? [
                      const DropdownMenuItem(
                        value: 'primary',
                        child: Text('Primary'),
                      ),
                    ]
                  : phoneTypes
                      .where((type) => type != 'primary')
                      .map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(_capitalizeFirstLetter(type)),
                        );
                      }).toList(),
            ),
            const SizedBox(width: 8),

            // Subtract/Remove Button
            if (_phones.length > 1)
              IconButton(
                icon: const Icon(Icons.remove_circle, color: Colors.red),
                onPressed: () => _removePhoneField(idx),
              ),
          ],
        ),
      );
    }).toList(),
  );
}


  void _fetchUserData() async {
    Map<String, dynamic> result = await ApiService.getUserInfo();

    if (result['status'] == 'success') {
      Map<String, dynamic> userInfo = result['content'];

      setState(() {
        // Populate emails
        _emails = (userInfo['Emails'] as List<dynamic>)
            .map<Map<String, dynamic>>((email) {
          return {
            'address': email['EmailAddress'],
            'type': email['EmailTypeID'],
            'primary': email['EmailTypeID'] == 'primary', // Set primary flag
          };
        }).toList();

        // Set the first email as primary if none is marked as primary
        bool hasPrimaryEmail = _emails.any((email) => email['primary']);
        if (!hasPrimaryEmail && _emails.isNotEmpty) {
          _emails[0]['primary'] = true;
          _emails[0]['type'] = 'primary'; // Force the first to be primary
        }

        originalEmails = _emails.map((emailMap) => emailMap['address'] as String).toList();

        // Populate phones
        _phones = (userInfo['PhoneNumbers'] as List<dynamic>)
            .map<Map<String, dynamic>>((phone) {
          return {
            'number': phone['PhoneNumber'],
            'type': phone['PhoneTypeID'],
            'primary': phone['PhoneTypeID'] == 'primary', // Set primary flag
          };
        }).toList();

        // Set the first phone as primary if none is marked as primary
        bool hasPrimaryPhone = _phones.any((phone) => phone['primary']);
        if (!hasPrimaryPhone && _phones.isNotEmpty) {
          _phones[0]['primary'] = true;
          _phones[0]['type'] = 'primary'; // Force the first to be primary
        }

        originalPhones = _phones.map((phoneMap) => phoneMap['number'] as String).toList();

        // Create controllers for each email/phone
        _emailControllers = _emails
            .map((email) => TextEditingController(text: email['address']))
            .toList();
        _phoneControllers = _phones
            .map((phone) => TextEditingController(text: phone['number']))
            .toList();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error fetching user data: ${result['reason']}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 209, 125, 51),
        shape: const RoundedRectangleBorder(),
        title: const Stack(
          children: <Widget>[
            Text(
              'Edit Account',
              style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home, color: Colors.white),
            onPressed: () {
              Navigator.popUntil(context, ModalRoute.withName('/'));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),

                // Emails Field
                const Text(
                  'Emails:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildEmailsField(),
                  // Add Email Button
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _emails.add({'address': '', 'type': 'work', 'primary': false});
                        _emailControllers.add(TextEditingController(text: ''));
                      });
                    },
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text(
                      'Add Email',
                      style: TextStyle(color: Colors.white), // Set text color to white
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16), // Skinnier button
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),

                // Phone Numbers Field
                const Text(
                  'Phone Numbers:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildPhonesField(),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _phones.add({'number': '', 'type': 'mobile', 'primary': false});
                      _phoneControllers.add(TextEditingController(text: ''));
                    });
                  },
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    'Add Phone',
                    style: TextStyle(color: Colors.white), // Set text color to white
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16), // Skinnier button
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 209, 125, 51), // Orange color
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16), // Skinnier button
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _saveAccountChanges, // Call the save function
                  icon: const Icon(Icons.update, color: Colors.white), // Icon for update
                  label: const Text(
                    'Update Contact Info',
                    style: TextStyle(color: Colors.white), // Set text color to white
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

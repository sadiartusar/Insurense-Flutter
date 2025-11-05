import 'dart:io';
import 'package:date_field/date_field.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:general_insurance_management_system/page/login.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:radio_group_v2/radio_group_v2.dart';
import 'package:radio_group_v2/radio_group_v2.dart' as v2;

class Registration extends StatefulWidget {
  const Registration({super.key});

  @override
  State<Registration> createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {

  final TextEditingController name=TextEditingController();
  final TextEditingController email=TextEditingController();
  final TextEditingController password=TextEditingController();
  final TextEditingController confirmPassword=TextEditingController();
  final TextEditingController cell=TextEditingController();
  final TextEditingController addrerss=TextEditingController();

  final RadioGroupController genderController= RadioGroupController();

  final DateTimeFieldPickerPlatform dob=DateTimeFieldPickerPlatform.material;

  String? selectedGender;

  DateTime? selectedDob;

  XFile? selectedImage;

  Uint8List? webImage;
  final ImagePicker _picker=ImagePicker();

  final _formKey=GlobalKey<FormState>();



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: name,
                  decoration: InputDecoration(
                      labelText: "Full Name",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person)
                  ),

                ),

                SizedBox(
                  height: 20.0,
                ),

                TextField(
                  controller: email,
                  decoration: InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email)
                  ),

                ),

                SizedBox(
                  height: 20.0,
                ),

                TextField(
                  controller: password,
                  decoration: InputDecoration(
                      labelText: "Password",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock)
                  ),

                  obscureText: true,

                ),

                SizedBox(
                  height: 20.0,
                ),

                TextField(
                  controller: confirmPassword,
                  decoration: InputDecoration(
                      labelText: "Confirm Password",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock)
                  ),

                  obscureText: true,

                ),

                SizedBox(
                  height: 20.0,
                ),

                TextField(
                  controller: cell,
                  decoration: InputDecoration(
                      labelText: "Cell number",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone)
                  ),

                ),

                SizedBox(
                  height: 20.0,
                ),

                TextField(
                  controller: addrerss,
                  decoration: InputDecoration(
                      labelText: "Address",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.maps_home_work_outlined)
                  ),

                ),

                SizedBox(
                  height: 20.0,
                ),

                DateTimeFormField(
                  decoration: InputDecoration(
                      labelText: "Date of Birth"
                  ),

                  mode: DateTimeFieldPickerMode.date,
                  pickerPlatform: dob,

                  onChanged: (DateTime?value){
                    setState(() {
                      selectedDob=value;
                    });
                  },
                ),

                SizedBox(
                  height: 20.0,
                ),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Gender:",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      v2.RadioGroup(
                        controller: genderController,
                        values: const["Male","Female","Other"],
                        indexOfDefault: 0,
                        orientation: RadioGroupOrientation.horizontal,
                        onChanged: (newValue){
                          setState(() {
                            selectedGender=newValue.toString();
                          });
                        },
                      )
                    ],
                  ),
                ),

                SizedBox(
                  height: 20.0,
                ),

                TextButton.icon(
                    icon: Icon(Icons.image),
                    label: Text("Upload Image"),
                    onPressed: pickImage


                ),
                if(kIsWeb && webImage !=null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.memory(
                      webImage!,
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  if(!kIsWeb && selectedImage !=null)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.file(
                        File(selectedImage!.path),
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                      ),
                    ),

                SizedBox(
                  height: 20.0,
                ),

                ElevatedButton(onPressed:(){

                },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white
                  ),
                  child: Text(
                    "Registration",
                    style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.w800,
                        fontFamily: GoogleFonts.lato().fontFamily
                    ),
                  ),
                ),

                SizedBox(
                  height: 20.0,
                ),

                TextButton(
                  onPressed: (){
                    Navigator.push(
                      context, MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                  child: Text(
                    "Login",
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),

                  ),
                ),

              ],
            ),
          ),
        ),
      ),


    );
  }

  Future<void> pickImage() async{
    if(kIsWeb){
      var pickedImage = await ImagePickerWeb.getImageAsBytes();
      if(pickedImage !=null){
        setState(() {
          webImage=pickedImage;
        });
      }
    }
    else{
      final XFile? pickedImage =await _picker.pickImage(source: ImageSource.gallery);
      if(pickedImage != null){
        setState(() {
          selectedImage=pickedImage;
        });
      }
    }
  }
}

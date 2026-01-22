import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AdminJobScreen extends StatefulWidget {
  const AdminJobScreen({super.key});

  @override
  State<AdminJobScreen> createState() => _AdminJobScreenState();
}

class _AdminJobScreenState extends State<AdminJobScreen> {
  // Controllers to capture input
  final TextEditingController _roleController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _salaryController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();
  final TextEditingController _descController =
      TextEditingController(); // Description

  bool isPosting = false;

  // 🔥 Job Post Karne ka Logic
  Future<void> _postJob() async {
    if (_roleController.text.isEmpty || _linkController.text.isEmpty) {
      Fluttertoast.showToast(msg: "Role and Link are required!");
      return;
    }

    setState(() => isPosting = true);

    try {
      // Firestore mein 'jobs' collection mein data add karna
      await FirebaseFirestore.instance.collection('jobs').add({
        'role': _roleController.text,
        'company': _companyController.text,
        'salary': _salaryController.text, // e.g., "15 LPA"
        'applyLink': _linkController.text,
        'description': _descController.text,
        'postedAt': FieldValue.serverTimestamp(),
        'isActive': true,
      });

      Fluttertoast.showToast(
        msg: "✅ Job Posted Successfully!",
        backgroundColor: Colors.green,
      );

      // Fields clear kar do taaki agli job daal sako
      _clearFields();
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e", backgroundColor: Colors.red);
    } finally {
      setState(() => isPosting = false);
    }
  }

  void _clearFields() {
    _roleController.clear();
    _companyController.clear();
    _salaryController.clear();
    _linkController.clear();
    _descController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Post New Job",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.indigo,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Create Job Opportunity",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            const Text("Details will be visible to all students immediately."),
            const SizedBox(height: 25),

            // 1. Role (e.g., SDE-1)
            _buildTextField(_roleController, "Job Role", Icons.work),
            const SizedBox(height: 15),

            // 2. Company (e.g., Google)
            _buildTextField(_companyController, "Company Name", Icons.business),
            const SizedBox(height: 15),

            // 3. Salary (e.g., 25 LPA)
            _buildTextField(
              _salaryController,
              "Package (LPA)",
              Icons.attach_money,
            ),
            const SizedBox(height: 15),

            // 4. Description (Short Details)
            _buildTextField(
              _descController,
              "Short Description/Requirements",
              Icons.description,
              maxLines: 3,
            ),
            const SizedBox(height: 15),

            // 5. Apply Link (Google Form / Career Page)
            _buildTextField(_linkController, "Application Link", Icons.link),
            const SizedBox(height: 30),

            // POST BUTTON
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: isPosting ? null : _postJob,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: isPosting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.cloud_upload),
                label: Text(isPosting ? "Posting..." : "PUBLISH JOB"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.indigo),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }
}

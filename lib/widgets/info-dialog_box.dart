import 'package:flutter/material.dart';

class InfoDialog extends StatefulWidget {
  InfoDialog({super.key, this.title, this.description,});

  String? title, description;

  @override
  State<InfoDialog> createState() => _InfoDialogState();
}

class _InfoDialogState extends State<InfoDialog>
{
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12)
      ),
      backgroundColor: Colors.grey,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 12,),

                 Text(
                  widget.title.toString(),
                  style: const TextStyle(
                     fontSize: 22,
                    color: Colors.white60,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 27,),

                 Text(
                  widget.description.toString(),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32,),

                SizedBox(
                  width: 202,
                  child: ElevatedButton(
                    onPressed: (){
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Ok"
                    ),
                  ),
                ),
                const SizedBox(height: 12,),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

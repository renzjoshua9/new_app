import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:new_app/appInfo/app_info.dart';
import 'package:new_app/global/global_var.dart';
import 'package:new_app/methods/common_methods.dart';
import 'package:new_app/models/address_model.dart';
import 'package:new_app/models/prediction_model.dart';
import 'package:new_app/widgets/loading_dialog.dart';

class PredictionPlaceUI extends StatefulWidget {

  PredictionModel? predictedPlaceData;

  PredictionPlaceUI({super.key, this.predictedPlaceData,});

  @override
  State<PredictionPlaceUI> createState() => _PredictionPlaceUIState();
}

class _PredictionPlaceUIState extends State<PredictionPlaceUI> {

  ///Place details that include long and lat
  fetchClickedPlaceDetails(String placeID) async {

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context)  => LoadingDialog(messageText: "Getting Details"),
    );

    String urlPlaceDetailsAPI = "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeID&key=$googleMapKey";

    var responseFromDetailsPlaceAPI = await CommonMethods.sendRequestToAPI(urlPlaceDetailsAPI);

    Navigator.pop(context);

    if(responseFromDetailsPlaceAPI == "error"){
      return;
    }

    if(responseFromDetailsPlaceAPI["status"] == "OK"){
      AddressModel dropOffLocation = AddressModel();

      dropOffLocation.placeName = responseFromDetailsPlaceAPI["result"]["name"];
      dropOffLocation.latitudePosition= responseFromDetailsPlaceAPI["result"]["geometry"]["location"]["lat"];
      dropOffLocation.longitudePosition= responseFromDetailsPlaceAPI["result"]["geometry"]["location"]["lng"];
      dropOffLocation.placeID= placeID;

      Provider.of<AppInfo>(context, listen: false).updateDropOffLocation(dropOffLocation);

      Navigator.pop(context, "placeSelected");

    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: (){
          fetchClickedPlaceDetails(widget.predictedPlaceData!.place_id.toString());
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
        ),
        child: Container(
          child: Column(
            children: [
              const SizedBox(height: 10,),
              Row(
                children: [
                  const Icon(
                    Icons.share_location,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 13,),

                  Expanded(child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      //main text
                      Text(
                          widget.predictedPlaceData!.main_text.toString(),
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                      ),

                      const SizedBox(height: 3,),
                      //secondary text
                      Text(
                        widget.predictedPlaceData!.secondary_text.toString(),
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  ),
                ],
              ),

              const SizedBox(height: 10,),


            ],
          ),
        )
    );
  }
}

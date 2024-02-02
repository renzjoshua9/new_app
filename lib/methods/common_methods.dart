import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../appInfo/app_info.dart';
import '../global/global_var.dart';
import 'package:http/http.dart' as http;

import '../models/address_model.dart';
import '../models/direction_details.dart';

class CommonMethods{
  checkConnectivity(BuildContext context) async {
      var connectionResult = await Connectivity().checkConnectivity();

      if(connectionResult != ConnectivityResult.mobile && connectionResult != ConnectivityResult.wifi){
        if(!context.mounted) return;
        displaySnackbar("You are not connected to the Internet.", context);
      }
  }

  displaySnackbar(String messageText, BuildContext context){
    var snackBar = SnackBar(content: Text(messageText));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static sendRequestToAPI(String apiUrl) async {
    http.Response responseFromAPI = await http.get(Uri.parse(apiUrl));

    try{
      if(responseFromAPI.statusCode == 200){
        String dataFromAPI = responseFromAPI.body;
        var dataDecoded = jsonDecode(dataFromAPI);
        return dataDecoded;
      }
      else{
        return "error";
      }
    }
    catch(errorMsg){
      return "error";
    }
  }

  static Future<String> convertGeographicCoordinatesIntoHumanReadableAddress(Position position, BuildContext context) async {
    String apiGeoCodingUrl = "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$googleMapKey";
    String humanReadableAddress = "";
    var responseFromApi = await sendRequestToAPI(apiGeoCodingUrl);

    if(responseFromApi != "error"){
      humanReadableAddress = responseFromApi["results"][0]["formatted_address"];

      AddressModel model = AddressModel();
      model.humanReadableAddress = humanReadableAddress;
      model.placeName = humanReadableAddress;
      model.longitudePosition = position.longitude;
      model.latitudePosition = position.latitude;

      Provider.of<AppInfo>(context, listen: false).updatePickUpLocation(model);
    }

    return humanReadableAddress;
  }

  static Future<DirectionDetails?> getDirectionDetailsFromAPI(LatLng source, LatLng destination) async {
    String urlDirectionAPI = "https://maps.googleapis.com/maps/api/directions/json?destination=${destination.latitude},${destination.longitude}&origin=${source.latitude},${source.longitude}&mode=driving&key=$googleMapKey";

    var responseFromDirectionAPI = await sendRequestToAPI(urlDirectionAPI);

    if(responseFromDirectionAPI == "error"){
      return null ;
    }

    DirectionDetails detailsModel = DirectionDetails();
    detailsModel.distanceTextString = responseFromDirectionAPI["routes"][0]["legs"][0]["distance"]["text"];
    detailsModel.distanceValueDigits = responseFromDirectionAPI["routes"][0]["legs"][0]["distance"]["value"];

    detailsModel.durationTextString = responseFromDirectionAPI["routes"][0]["legs"][0]["duration"]["text"];
    detailsModel.durationValueDigits = responseFromDirectionAPI["routes"][0]["legs"][0]["duration"]["value"];

    detailsModel.encodedPoints = responseFromDirectionAPI["routes"][0]["overview_polyline"]["points"];

    return detailsModel;
  }

}
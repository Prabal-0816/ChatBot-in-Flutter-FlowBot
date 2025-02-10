import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:http_parser/http_parser.dart';

const String apiKey = '';
const String storeName = '';
const String apiVersion = '';
const String accessToken = '';

const String baseUrl = 'https://$storeName.myshopify.com/admin/api/$apiVersion';

final Map<String , String> headers = {
  "X-Shopify-Access-Token": accessToken,
  "Content-Type": "application/json",
};

Future<dynamic> uploadMediaToServer(File mediaFile , String mimeType) async {
  try {
    // Shopify GraphQL URL for uploading media
    final String uploadUrl = "$baseUrl/graphql.json";

    // Create multipart request
    var request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
    request.headers.addAll(headers);

    // Add file to the multipart request
    request.files.add(
        await http.MultipartFile.fromPath(
            'file',
            mediaFile.path,
            contentType: MediaType(
                mimeType.split('/')[0],
                mimeType.split('/')[1]
            )   // Mime Type example : "image/jpeg"
        )
    );

    // Send request
    var response = await request.send();

    if(response.statusCode == 200) {
      var responseData = await http.Response.fromStream(response);
      var jsonResponse = json.decode(responseData.body);

      // Parse the uploaded URL from the response
      // Assuming shopify response contains the uploaded URL in a specific path
      String uploadedUrl = jsonResponse['data']['fileCreate']['file']['url'];
      print('File uploaded successfully. URL: $uploadedUrl');
      return uploadedUrl;
    }
    else {
      print('Failed to upload file: ${response.statusCode}');
      return null;
    }
  }
  catch(e) {
    print('Error uploading file : $e');
    return null;
  }
}

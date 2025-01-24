import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:googleapis/sheets/v4.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'store_page.dart';

class LoginPage extends StatelessWidget {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      // Step 1: Sign in with Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Step 2: Sign in to Firebase
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;
      final String userId = user!.uid;

      // Step 3: Create a Google Sheet for the user
      final String? spreadsheetId = await _createGoogleSheet(userId);

      // Step 4: Store Google Sheet ID in Firestore
      await _firestore.collection('users').doc(userId).set({
        'googleSheetId': spreadsheetId,
        'storeUrl': 'https://yourwebsite.com/store/$userId', // Unique URL
      });

      // Step 5: Navigate to the store page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StorePage(spreadsheetId: spreadsheetId!),
        ),
      );
    } catch (e) {
      print('Error: $e');
    }
  }

  // Helper function to create a Google Sheet
  Future<String?> _createGoogleSheet(String userId) async {
    final credentials = ServiceAccountCredentials.fromJson({
      "type": "service_account",
      "project_id": "cool-reach-448809-m0",
      "private_key_id": "94d97a5eff5e8a79bddc85c59afbaa547cc9ad0e",
      "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQCIGc8isW/Ua4iS\nT/RX8Cafg1jxXqOhieN56/GlXBnFHzTQC5WA9nhPacyswP1dS1AcGb49nilYaRaS\nSC4Ec56vfN3dk5mkIqXeoSGGg5R1/SjfUplsW3FPm7w+50cw6RzuqNEwKWcYzlIf\n0YR9gUinQLgRB46lwfEJ8kwAN7gDgZpI/5Qh27VxvgE0h8Fb8SIdC5m4RS7/aWwz\nTSqXnvncepy/qF+NooL7gyR1f37INyBaCe5MVaziO5QZt9ncQEjhZVvdlWiTIib1\ncSxuly4w0wVPn1vVLgE7PPcTH18+7IVJcjeWWkO19hYuBrXNhs5Bw+Aro7UUWPvn\nXJjDcCoxAgMBAAECggEAC+n+ePIBcR3suaooIJ6UMviDi7WWK2jvsdeWsrwKQXhG\n3kN1VfG9fG4tjZ3jUAxsudkDD0/OHMAuSqXo6VjZtlD+9wuZsoWZ8ZA3aBgSofWE\nY3BOn+6tT6O5aeRDFiQB9V5v2YB2VvSQudpUd8weeQ2wT0VTFm2Q1ScRwh8ei6fn\nEJmdlJkaiTb9dWRdiSQFUhUvGKeUwR9BB8NogM3CQ99irh9oZdQtVXHkObkhNf3R\n/d8C++mJ1h+tzT/B8Mf76ANFLUMsEhCQ/BdVB8o2Azc57ffdaGHS4Iyo+1sKPWl9\nUV33t30K8WtkkowagwxcvBVYMYuIrI5IaTVhKM8xcQKBgQDAdD40jpkIomSdmEpj\n2GJzunYFJE2cXCcfF4qUzTmnrykBtmpS5A1wT0TrLqlBdG1nNPkjtJvT0wjtfAYi\ngHRzjvt4OnWesIH85Du7nape24kg7HazFaZCUeJa/OqeNJK4o19uvAyuclxmcaMZ\nYsehGr1A50I78kDbhunHPzSOpQKBgQC1CiNmtJAiSYCggM39jXu9mMc8xJNVBvIQ\nG8j/txtsQMoyJnddxpsiZZhrt6vwtHBvIS7rCWauukIMiYtgf7iGkCnY520D+S0f\n/29PkRqZ/XXtnZQ6QGPbiuiTQDHqkF1WLpsaW6FSCrEGQwevjaW03+TUmJiHGJdv\nsaBcmMnDnQKBgH6RtHtiMNkR2/QdPQdPPuh3f7i/+F7V6FC1bcmQ8tMKCoD61BAx\ntXjgWSYG6P+IL49JsnQ+CqGTz/JHt80nB+8b4NxgLgywbry/6VzpQyvhW90QRrxe\nh5pkOea3ISHs13Wg1FmCSSDNS2GAaNCAO2QDruWpcdD08JyvrL4CHnGVAoGAFztX\n06Q0ItI/2VjuFi2DxY7HcnrfVTfw9DQ8lOQQdtHRoKHjC3ujCMT0zE3jmJ3vF7Ow\na6TnMmDgfO9hnV6GdW4mkJkSGkJtkf+bbyB1w3ENIxLnpJoCtnea5NqGDU29TIPq\nj3VWvEp28RDE+bg5nX5lxQpX+G4lcMXgiEFrEtkCgYBYHYrHH2Uo9JMbPW5WVE6O\nnKYNUcrv4lgHx21O6Y3K3ZGBkYyJ/RR77ykYOOS7K9LGZbcoctMjDmnmSeVblfTx\nTiAem7SWk3KRaszRsRPOdNvqfcVWM57kcrfjX3yrdWgSYYkXIMEA9HK7AXOKp948\nnCNb/SWMm6vHdlLpuS27gw==\n-----END PRIVATE KEY-----\n",
      "client_email": "storelink-service-account@cool-reach-448809-m0.iam.gserviceaccount.com",
      "client_id": "117226454439743650358",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/storelink-service-account%40cool-reach-448809-m0.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
      // "type": "service_account",
      // "project_id": "your-project-id",
      // "private_key_id": "your-private-key-id",
      // "private_key": "-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n",
      // "client_email": "your-client-email",
      // "client_id": "your-client-id",
      // "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      // "token_uri": "https://oauth2.googleapis.com/token",
      // "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
      // "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/your-client-email"
    });

    final authClient = await clientViaServiceAccount(credentials, SheetsApi.spreadsheetsScope as List<String>);
    final sheetsApi = SheetsApi(authClient);

    // Create a new Google Sheet
    final spreadsheet = Spreadsheet()
      ..properties = SpreadsheetProperties()
      ..properties?.title = 'Store - $userId';

    final createdSheet = await sheetsApi.spreadsheets.create(spreadsheet);
    authClient.close();

    return createdSheet.spreadsheetId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _signInWithGoogle(context),
          child: Text('Sign in with Google'),
        ),
      ),
    );
  }
}
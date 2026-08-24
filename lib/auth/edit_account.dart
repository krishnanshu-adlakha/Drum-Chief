import 'package:drum_chief/auth/auth_services.dart';
import 'package:flutter/material.dart';

Future<Map> getUserDetails() async {
  Map userDetails = await authService.value.getUserDetails();
  return userDetails;
}

class EditAccountScreen extends StatefulWidget {
  const EditAccountScreen({super.key});

  @override
  State<EditAccountScreen> createState() => _EditAccountScreenState();
}

class _EditAccountScreenState extends State<EditAccountScreen> {
  late Future<Map> userDetails;

  @override
  void initState() {
    super.initState();
    userDetails = getUserDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          "MANAGE ACCOUNT",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: ValueListenableBuilder(
          valueListenable: authService,
          builder: (context, authService, snapshot) {
            return StreamBuilder(
              stream: authService.userChanges,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator.adaptive();
                } else if (snapshot.hasError) {
                  return Text("Error has occured ${snapshot.error}");
                } else if (snapshot.hasData) {
                  final userData = snapshot.data!;
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Text(
                            userData.displayName ?? "No username found",
                            style: TextStyle(fontSize: 30, color: Colors.white),
                          ),
                          Text(
                            userData.email ?? "No email address found",
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                          SizedBox(height: 20),
                          ListView(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            children: [
                              ListTile(
                                title: Text(
                                  "Change username",
                                  style: TextStyle(fontSize: 20),
                                ),
                                trailing: Icon(Icons.chevron_right),
                                onTap: () {
                                  Navigator.of(
                                    context,
                                  ).pushNamed("/change-username");
                                },
                              ),
                              ListTile(
                                title: Text(
                                  "Change password",
                                  style: TextStyle(fontSize: 20),
                                ),
                                trailing: Icon(Icons.chevron_right),
                                onTap: () {
                                  Navigator.of(
                                    context,
                                  ).pushNamed("/change-password");
                                },
                              ),
                              ListTile(
                                title: Text(
                                  "About this app",
                                  style: TextStyle(fontSize: 20),
                                ),
                                trailing: Icon(Icons.chevron_right),
                                onTap: () {
                                  Navigator.of(context).pushNamed("/about");
                                },
                              ),
                              ListTile(
                                title: Text(
                                  "Delete my account",
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.red,
                                  ),
                                ),
                                trailing: Icon(Icons.chevron_right, color: Colors.red),
                                onTap: () {
                                  Navigator.of(
                                    context,
                                  ).pushNamed("/delete-account");
                                },
                              ),
                              ListTile(
                                title: Text(
                                  "Sign out",
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 20,
                                  ),
                                ),
                                trailing: Icon(
                                  Icons.chevron_right,
                                  color: Colors.red,
                                ),
                                onTap: () async {
                                  try {
                                    await authService.signOut();
                                    if (context.mounted) {
                                      Navigator.of(
                                        context,
                                      ).pushNamedAndRemoveUntil(
                                        "/login",
                                        (Route<dynamic> route) => false,
                                      );
                                    }
                                  } catch (e) {
                                    SnackBar snackBar = SnackBar(
                                      content: Text(e.toString()),
                                    );
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(snackBar);
                                    }
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  return Text("No account available.");
                }
              },
            );
          },
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ss_universal/api/api_service.dart';
import 'package:ss_universal/model/client_model.dart';
import 'package:ss_universal/screens/activities/activities_form_screen.dart';
import 'package:ss_universal/utils/app_colors.dart';
import 'package:ss_universal/utils/common_drawer.dart';
import 'package:ss_universal/utils/media_query.dart';

class ClientsListScreen extends StatefulWidget {
  const ClientsListScreen({super.key});

  @override
  State<ClientsListScreen> createState() => _ClientsListScreenState();
}

class _ClientsListScreenState extends State<ClientsListScreen> {
  late Future<List<ClientModel>> _clientFuture;

  @override
  void initState() {
    super.initState();
    _clientFuture = ApiService.getClientList();
  }

  @override
  Widget build(BuildContext context) {
    final w = MQ.width(context);
    final h = MQ.height(context);

    return Scaffold(
      backgroundColor: AppColor.background,
      drawer: CommonDrawer(onClose: () => Navigator.pop(context)),

      body: SafeArea(
        child: Column(
          children: [
            /// APP BAR
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: w * 0.04,
                vertical: h * 0.015,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.arrow_back),
                  ),
                  const Spacer(),
                  Image.asset("assets/images/logo.jpg", height: 60.h),
                  const Spacer(),
                ],
              ),
            ),

            SizedBox(height: h * 0.02),

            /// TITLE
            Text(
              "Clients Name",
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.w600,
                color: AppColor.textPrimary,
              ),
            ),

            SizedBox(height: h * 0.02),

            /// CLIENT LIST
            Expanded(
              child: FutureBuilder<List<ClientModel>>(
                future: _clientFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("No clients found"));
                  }

                  final clients = snapshot.data!;

                  return ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: w * 0.06),
                    itemCount: clients.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final client = clients[index];

                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ActivityFormScreen(
                                clientSrNo: client.clientSrNo,
                                clientName: client.clientName,
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          child: Text(
                            client.clientName,
                            style: TextStyle(
                              fontSize: 15.sp,
                              color: AppColor.textPrimary,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

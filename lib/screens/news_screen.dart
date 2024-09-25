import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:news/appcolors.dart';
import 'package:news/providers/news_provider.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

class NewsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final newsProvider = Provider.of<NewsProvider>(context, listen: false);
    String timeAgoFromNow(String isoDateString) {
      // Parse the ISO 8601 date string into a DateTime object
      DateTime timestamp = DateTime.parse(isoDateString).toLocal();

      // Get the current date and time
      DateTime now = DateTime.now();

      // Calculate the difference between now and the timestamp
      Duration difference = now.difference(timestamp);

      // Logic to show time in minutes, hours, or days ago
      if (difference.inMinutes < 1) {
        return "Just now";
      } else if (difference.inMinutes < 60) {
        return "${difference.inMinutes} minutes ago";
      } else if (difference.inHours < 24) {
        return "${difference.inHours} hours ago";
      } else {
        int daysAgo = difference.inDays;
        return daysAgo == 1 ? "1 day ago" : "$daysAgo days ago";
      }
    }

    return Scaffold(
      backgroundColor: AppColors.whiteshade,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
          actions: [
            Transform.rotate(
              angle: math.pi / 6,
              child: Icon(
                Icons.navigation_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            SizedBox(
              width: 3.w,
            ),
            Padding(
              padding: EdgeInsets.only(right: 15.w),
              child: Text(
                newsProvider.countryCode.toUpperCase(),
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins'),
              ),
            )
          ],
          backgroundColor: AppColors.blue,
          title: Text(
            'MyNews',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: "Poppins",
                color: Colors.white,
                fontSize: 18.sp),
          )),
      body: FutureBuilder(
        future: newsProvider.fetchNews(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || newsProvider.errorMessage != null) {
            return Center(
                child:
                    Text(newsProvider.errorMessage ?? 'Error fetching news'));
          } else {
            return Consumer<NewsProvider>(
              builder: (context, newsProvider, child) {
                return ListView(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 20.w, top: 12.h),
                          child: Text('Top Headlines',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "Poppins",
                                  color: Colors.black,
                                  fontSize: 16.sp)),
                        ),
                        SizedBox(
                          height: 20.h,
                        ),
                        ListView.builder(
                          itemCount: newsProvider.news.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            final article = newsProvider.news[index];
                            return Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: 20.w, right: 20.w, bottom: 15.h),
                                  child: Container(
                                    width: double.infinity, // Full screen width
                                    height: 150.h, // Height of 150px
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15),
                                    ),

                                    child: Row(
                                      children: [
                                        // Left Column (60% width)
                                        Expanded(
                                          flex: 6, // 60% of the row's width
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                                left: 12.w,
                                                right: 2.w,
                                                top: 2.h,
                                                bottom: 2.h),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  article['source']['name'],
                                                  style: TextStyle(
                                                      fontSize: 16.sp,
                                                      fontFamily: 'Poppins',
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black),
                                                ),
                                                Text(
                                                  article['title'] ??
                                                      'No Title',
                                                  maxLines: 3,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      fontSize: 15.sp,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontFamily: 'Poppins',
                                                      color: Colors.black),
                                                ),
                                                Text(
                                                  timeAgoFromNow(article[
                                                          'publishedAt']) ??
                                                      'No Title',
                                                  style: TextStyle(
                                                      fontSize: 14.sp,
                                                      fontFamily: 'Poppins',
                                                      color: AppColors.grey),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        // Right Column (40% width)
                                        Expanded(
                                          flex: 4, // 40% of the row's width
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                                left: 8.w,
                                                right: 8.w,
                                                top: 12.h,
                                                bottom: 12.h),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                image: DecorationImage(
                                                  image: NetworkImage(
                                                    article['urlToImage'] ??
                                                        'https://via.placeholder.com/150',
                                                  ),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                );
              },
            );
          }
        },
      ),
    );
  }
}

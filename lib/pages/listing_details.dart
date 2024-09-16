import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fyp_project/models/owner.dart';
import 'package:fyp_project/models/property.dart';

import '../models/property_listing.dart';

class Listingdetails extends StatefulWidget {

  final PropertyListing propertyListing;
  Listingdetails({super.key, required this.propertyListing});

  @override
  ListingdetailsState createState() => ListingdetailsState();
}

final Property property = Property(
    property_id: "1",
    property_title: "PLACEHOLDER",
    owner: Owner(
        username: "name",
        contact_no: "contact_no",
        profile_pic: "profile_pic",
        id: "1"),
    address: "ADDRESS ADDRESS ADDRESS ADDRESS ADDRESS ADDRESS",
    imageUrl: "https://via.placeholder.com/150");

  class ListingdetailsState extends State<Listingdetails> {
  int _currentIndex = 0;
  List<Widget> body = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: _getBody(),
      bottomNavigationBar: bottomNavigationBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
        },
        child: Icon(Icons.chat,
          color: Colors.white,),
        backgroundColor: Colors.black,
      ),
    );
  }
  //https://youtu.be/VfUUOI6BUtE?si=yAhaupWJhH8CTQeU
  Widget _getBody() {
    switch (_currentIndex) {
      case 0:
        return ListView(
          padding: EdgeInsets.all(16),
          children: [
            ImageCarousel(),
            SizedBox(height:16),
            Text(widget.propertyListing.listing_title,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
            SizedBox(height:16),
            Row(
              children: [
                Icon(
                  Icons.star,
                  color: Colors.yellow,
                  size: 30,
                ),
                SizedBox(width: 8,),
                Text(
                  "${widget.propertyListing.rating}/5",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16,),
            Row(
              children: [Text("Price: RM${widget.propertyListing.price}"),
                SizedBox(width: 16,),
                Text("Deposit: RM${widget.propertyListing.deposit}"),],
            ),
            SizedBox(height: 16,),
            Text(
              "Room Type: ${widget.propertyListing.room_type}",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
            SizedBox(height: 16,),
            Text(
              "Description",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
            SizedBox(height: 8,),
            Text('${widget.propertyListing.description}\n\n${property.address}'),
            SizedBox(height: 16),
            Text(
              "Preference",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 8,),
            Row(
              children: [
                Text("Sex: ${widget.propertyListing.sex_preference}"),
                SizedBox(width: 16,),
                Text("Nationality: ${widget.propertyListing.nationality_preference}"),
              ],
            ),
            SizedBox(height: 16,),
            Text(
              "Ammenities",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 8,),
            Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: widget.propertyListing.amenities.map((amenity) {
                  return Chip(
                    label: Text(amenity),
                    backgroundColor: Colors.grey[200],
                  );
                }).toList()),
            SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(property.owner.profile_pic), // Load the image
                ),
                SizedBox(width: 16),
                Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Owner Details",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Owner Name: ${property.owner.username}",
                          style: TextStyle(fontSize: 14),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Contact Details: ${property.owner.contact_no}",
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ))
              ],
            )
          ],
        );
      case 1:
        return Column(
          children: [
            Container(
              padding: EdgeInsets.only(left: 20),
              child: Align(
                child: Text("Review", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,)),
                alignment: Alignment.centerLeft,
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: widget.propertyListing.reviews.length,
                scrollDirection: Axis.vertical,
                padding: EdgeInsets.only(left: 20, right: 20),
                separatorBuilder: (context, index) {
                  return SizedBox(height: 30);
                },
                itemBuilder: (context, index) {
                  return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Color(0xffE5E4E2),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.star, color: Colors.yellow,),
                              Text("${widget.propertyListing.reviews[index].rating}/5")
                            ],
                          ),
                          Container(
                            padding: EdgeInsets.all(8),
                            child: Text(
                              "${widget.propertyListing.reviews[index].comment}/5",
                              style: TextStyle(
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ],
                      )
                  );
                },
              ),
            )
          ],
        );
      case 2:
        return ListView(
          children: [
            Center(
              child: Icon(Icons.account_tree_outlined),
            ),
            Center(
              child: Text("MAP PART"),
            )
          ],
        );
      default:
        return ListView(
          children: [
            Center(
              child: Icon(Icons.account_tree_outlined),
            ),
            Center(
              child: Text("SOMETHING IS WRONG LOL"),
            )
          ],
        );
    }
  }

  CarouselSlider ImageCarousel() {
    return CarouselSlider(
          options: CarouselOptions(height: 200),
          items: widget.propertyListing.image_url.map((imageUrl) {
            return Builder(
              builder: (BuildContext context) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.symmetric(horizontal: 5.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                  ),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                  ),
                );
              },
            );
          }).toList(),
        );
  }

  BottomNavigationBar bottomNavigationBar() {
    return BottomNavigationBar(
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Details",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: "Review",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: "Map",
          ),
        ],
      onTap: (int newIndex) {
          setState(() {
            _currentIndex = newIndex;
          });
      },
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.grey,
    );
  }

  AppBar appBar() {
    return AppBar(
      // App bar title
      title: const Text("Listing Details",
        style: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      elevation: 0,

      // action is right side of the app bar
      actions: [IconButton(
        // placeholder icon fix later
        icon: const Icon(Icons.view_list),
        // same thing here
        onPressed: () => {},
      )],
    );
  } // end of appBar method
}

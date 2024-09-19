const { createClient } = require('@supabase/supabase-js');

const express = require("express");
const multer = require('multer');
const path = require('path');
const cors = require('cors');
const mime = require('mime-types'); 

require('dotenv').config();

const app = express();
app.use(cors());
app.use(express.json());

const supabase = createClient(process.env.SUPABASE_URL, process.env.API_KEY);

const storage = multer.memoryStorage();
const upload = multer({ storage });

app.get('/api/data', async (req, res) => {
  try {
    const { data, error } = await supabase.from("profiles").select("*");
    if (error) return res.status(500).json({ error: error.message });
    res.json(data);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post("/api/add-property", async (req, res) => {
  const { property_title, address, owner_id, property_image } = req.body;

  try {
    const { data, error } = await supabase
      .from('Property') 
      .insert([{ property_title, address, owner_id, property_image }])
      .select("property_id") 
      .single();

    if (error) {
      console.error('Insert Error:', error.message);
      return res.status(500).json({ error: error.message });
    }
    res.status(200).json({ message: "Property Added Successfully", data });
  } catch (e) {
    console.error('Catch Error:', e.message);
    res.status(500).json({ message: e.message });
  }
});


app.post("/api/upload-property-image", upload.single("image"), async (req, res) => {
  const { originalname, buffer } = req.file;
  const mimeType = mime.lookup(originalname);

  if (!mimeType) {
    return res.status(400).json({ error: "Unsupported file type" });
  }

  const { data, error } = await supabase.storage
    .from("property-images")
    .upload(`images/${Date.now()}_${originalname}`, buffer, {
      contentType: mimeType
    }); 

  if (error) {
    return res.status(500).json({ error: error.message });
  }

  console.log(data.path);

  const { data: publicData, error: publicUrlError } = supabase.storage
    .from('property-images')
    .getPublicUrl(data.path);

  if (publicUrlError) {
    return res.status(500).json({ error: publicUrlError.message });
  }
  const publicURL = publicData.publicUrl;
  console.log(publicURL);

  res.status(200).json({ message: 'Image uploaded successfully', imageUrl: publicURL });
});

app.get("/api/get-all-owner-properties", async (req, res) => {
  try {

    const { owner_id } = req.query;

    const { data, error } = await supabase
      .from("Property")
      .select("*")
      .eq("owner_id", owner_id);

    if (error) return res.status(500).json({ error: error.message });

    res.json(data);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get("/api/get-owner-with-id/:user_id", async (req, res) => {
  try {

    const { user_id } = req.params;

    const { data, error } = await supabase
      .from("Owners")
      .select("*")
      .eq("user_id", user_id)
      .single();

    if (error) return res.status(500).json({ error: error.message });
    
    res.json(data);

  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.put("/api/update-property/:property_id", async (req, res) => {
  try{
    const { property_id } = req.params;
    const { property_title, address, property_image, owner_id } = req.body;

    const { data, error } = await supabase
      .from("Property")
      .update({
        property_title: property_title,
        address: address,
        property_image: property_image,
        owner_id: owner_id
      })
      .eq("property_id", property_id);

    if (error) {
      return res.status(500).json({ error: error.message });
    }

    res.status(200).json({ message: "Property updated successfully", data: data });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.delete("/api/delete-property/:property_id", async (req, res) => {
  const { property_id } = req.params;

  try {
    const { data, error } = await supabase
      .from("Property")
      .delete()
      .eq("property_id", property_id);

    if (error) {
      console.error('Error deleting property:', error);
      return res.status(500).json({ message: 'Internal server error' });
    }

    res.status(200).json({ message: 'Property deleted successfully' });
  } catch (error) {
    console.error('Unexpected error:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
});

app.post("/api/add-listing-images", async (req, res) => {
  const { listing_id, image_url } = req.body;

  try {
    const { data, error } = await supabase
      .from("Listing_images") 
      .insert([{ listing_id, image_url }])
      .select("id") 
      .single();

    if (error) {
      console.error('Insert Error:', error.message);
      return res.status(500).json({ error: error.message });
    }
    res.status(200).json({ message: "Listing Image Added Successfully", data });
  } catch (e) {
    console.error('Catch Error:', e.message);
    res.status(500).json({ message: e.message });
  }
});

app.delete("/api/delete-listing-image", async (req, res) => {
  const { listing_id, image_url } = req.body;

  try {
    const { data, error } = await supabase
      .from("Listing_images") 
      .delete()
      .match({ listing_id, image_url }) 
      .select("id");

    if (error) {
      console.error('Insert Error:', error.message);
      return res.status(500).json({ error: error.message });
    }
    res.status(200).json({ message: "Listing Image Added Successfully", data });
  } catch (e) {
    console.error('Catch Error:', e.message);
    res.status(500).json({ message: e.message });
  }
});

app.post("/api/add-listing-ammenities", async (req, res) => {
  const { listing_id, isMasterRoom, isSingleRoom, isSharedRoom, isSuite, isWifiAccess, isAirCon, isNearMarket,
    isCarPark, isNearMRT, isNearLRT, isPrivateBathroom, isGymnasium, isCookingAllowed, isWashingMachine, isNearBusStop
   } = req.body;

  try {
    const { data, error } = await supabase
      .from("Amenities") 
      .insert([{ listing_id, isMasterRoom, isSingleRoom, isSharedRoom, isSuite, isWifiAccess, isAirCon, isNearMarket,
        isCarPark, isNearMRT, isNearLRT, isPrivateBathroom, isGymnasium, isCookingAllowed, isWashingMachine, isNearBusStop }])
      .select("listing_id") 
      .single();

    if (error) {
      console.error('Insert Error:', error.message);
      return res.status(500).json({ error: error.message });
    }
    res.status(200).json({ message: "Listing Amenities Added Successfully", data });
  } catch (e) {
    console.error('Catch Error:', e.message);
    res.status(500).json({ message: e.message });
  }
});

app.post("/api/add-listing", async (req, res) => {
  const { listing_title, tenant, price, deposit, property_id, description, isPublished, isVerified, rating, nationality_preference, sex_preference } = req.body;

  try {
    const { data, error } = await supabase
      .from("Listing") 
      .insert([{ listing_title, tenant, price, deposit, property_id, rating, isPublished, isVerified, description, nationality_preference, sex_preference }])
      .select("listing_id") 
      .single();

    if (error) {
      console.error('Insert Error:', error.message);
      return res.status(500).json({ error: error.message });
    }
    res.status(200).json({ message: "Listing Added Successfully", data });
  } catch (e) {
    console.error('Catch Error:', e.message);
    res.status(500).json({ message: e.message });
  }
});

app.get("/api/get-listing-images/:listing_id", async (req, res) => {
  try {
    const { listing_id } = req.params;

    const { data, error } = await supabase
      .from("Listing_images")
      .select("image_url")
      .eq("listing_id", listing_id);

    if (error) {
      return res.status(500).json({ error: error.message });
    }

    if (!data || data.length === 0) {
      return res.status(404).json({ error: "No images found for the listing" });
    }

    return res.status(200).json(data);
  } catch (err) {
    return res.status(500).json({ error: err.message });
  }
});


app.get("/api/get-all-listing/:property_id", async (req, res) => {
  const { property_id } = req.params;

  try {
    const { data, error } = await supabase
      .from("Listing")
      .select("*")
      .eq("property_id", property_id);

    if (error) {
      console.error("Error fetching listings:", error.message);
      return res.status(500).json({ error: error.message });
    }

    if (data.length === 0) {
      return res.status(404).json({ message: "No listings found for this property." });
    }

    res.status(200).json({ message: "Listings fetched successfully", data });
  } catch (e) {
    console.error("Catch Error:", e.message);
    res.status(500).json({ message: e.message });
  }
});

app.get("/api/get-all-reviews/:listing_id", async (req, res) => {
  const { listing_id } = req.params;

  try {
    const { data, error } = await supabase
      .from("Reviews")
      .select("*")
      .eq("listing_id", listing_id);

    if (error) {
      console.error("Error fetching reviews:", error.message);
      return res.status(500).json({ error: error.message });
    }

    if (data.length === 0) {
      return res.status(404).json({ message: "No reviews found for this listing." });
    }

    res.status(200).json({ message: "Reviews fetched successfully", data });
  } catch (e) {
    console.error("Catch Error:", e.message);
    res.status(500).json({ message: e.message });
  }
});

app.get("/api/get-all-amenities/:listing_id", async (req, res) => {
  const { listing_id } = req.params;

  try {
    const { data, error } = await supabase
      .from("Amenities")
      .select("*")
      .eq("listing_id", listing_id);

    if (error) {
      console.error("Error fetching amenities:", error.message);
      return res.status(500).json({ error: error.message });
    }

    if (data.length === 0) {
      return res.status(404).json({ message: "No amenities found for this listing." });
    }

    res.status(200).json({ message: "amenities fetched successfully", data });
  } catch (e) {
    console.error("Catch Error:", e.message);
    res.status(500).json({ message: e.message });
  }
});

app.get("/api/get-renter-with-id/:user_id", async (req, res) => {
  const { user_id } = req.params;

  try {
    const { data, error } = await supabase
      .from("Renters")
      .select("*")
      .eq("user_id", user_id)
      .single();

    if (error) {
      console.error("Error fetching renter information:", error.message);
      return res.status(500).json({ error: error.message });
    }

    if (data.length === 0) {
      return res.status(404).json({ message: "No renter found" });
    }

    res.status(200).json({ message: "renter information fetched successfully", data });
  } catch (e) {
    console.error("Catch Error:", e.message);
    res.status(500).json({ message: e.message });
  }
});

app.delete("/api/delete-listing-images/:listing_id", async (req, res) => {
  const { listing_id } = req.params;
  try {
    const { data, error } = await supabase
      .from("Listing_images")
      .delete()
      .eq("listing_id", listing_id)
      .select("image_url");

    if (error) {
      console.error('Error deleting listing images:', error);
      return res.status(500).json({ message: 'Internal server error' });
    }

    res.status(200).json({ 
      message: 'Listing images deleted successfully',
      data: data
    });
  } catch (error) {
    console.error('Unexpected error:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
});

app.delete("/api/delete-listing-amenities/:listing_id", async (req, res) => {
  const { listing_id } = req.params;

  try {
    const { data, error } = await supabase
      .from("Amenities")
      .delete()
      .eq("listing_id", listing_id);

    if (error) {
      console.error('Error deleting listing amenities:', error);
      return res.status(500).json({ message: 'Internal server error' });
    }

    res.status(200).json({ message: 'listing amenities deleted successfully' });
  } catch (error) {
    console.error('Unexpected error:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
});

app.delete("/api/delete-listing/:listing_id", async (req, res) => {
  const { listing_id } = req.params;
  try {
    const { data, error } = await supabase
      .from("Listing")
      .delete()
      .eq("listing_id", listing_id);

    if (error) {
      console.error('Error deleting listing:', error);
      return res.status(500).json({ message: 'Internal server error' });
    }

    res.status(200).json({ message: 'listing deleted successfully' });
  } catch (error) {
    console.error('Unexpected error:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
});

app.put("/api/update-listing/:listing_id", async (req, res) => {
  try{
    const { listing_id } = req.params;
    const { listing_title, price, deposit, rating, description, sex_preference, nationality_preference } = req.body;

    const { data, error } = await supabase
      .from("Listing")
      .upsert({
        listing_id: listing_id,
        listing_title: listing_title,
        price: price,
        deposit: deposit,
        rating: rating,
        description: description, 
        sex_preference: sex_preference, 
        nationality_preference: nationality_preference,
      });

    if (error) {
      return res.status(500).json({ error: error.message });
    }

    res.status(200).json({ message: "Listing updated successfully", data: data });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.delete("/api/delete-image", async (req, res) => {
  const { listing_id, image_url } = req.body;

  try {
    const { data, error } = await supabase
      .from("Listing_images") 
      .delete()
      .eq("listing_id", listing_id)
      .eq("image_url", image_url);

    if (error) {
      console.error('Insert Error:', error.message);
      return res.status(500).json({ error: error.message });
    }

    res.status(200).json({ message: "Listing Image Added Successfully", data });
  } catch (e) {
    console.error('Catch Error:', e.message);
    res.status(500).json({ message: e.message });
  }
});

app.put("/api/edit-listing-ammenities", async (req, res) => {
  const { listing_id, isMasterRoom, isSingleRoom, isSharedRoom, isSuite, isWifiAccess, isAirCon, isNearMarket,
    isCarPark, isNearMRT, isNearLRT, isPrivateBathroom, isGymnasium, isCookingAllowed, isWashingMachine, isNearBusStop
   } = req.body;

  try {
    const { data, error } = await supabase
      .from("Amenities") 
      .upsert([{ listing_id, isMasterRoom, isSingleRoom, isSharedRoom, isSuite, isWifiAccess, isAirCon, isNearMarket,
        isCarPark, isNearMRT, isNearLRT, isPrivateBathroom, isGymnasium, isCookingAllowed, isWashingMachine, isNearBusStop }])
      .select("listing_id") 
      .single();

    if (error) {
      console.error('update Error:', error.message);
      return res.status(500).json({ error: error.message });
    }
    res.status(200).json({ message: "Listing Amenities Updated Successfully", data });
  } catch (e) {
    console.error('Catch Error:', e.message);
    res.status(500).json({ message: e.message });
  }
});

app.listen(2000, () => {
  console.log("connected at server port 2000");
});

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

app.listen(2000, () => {
  console.log("connected at server port 2000");
});

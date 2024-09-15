const { createClient } = require('@supabase/supabase-js');

const express = require("express");
require('dotenv').config();
const app = express();

const supabase = createClient(process.env.SUPABASE_URL, process.env.API_KEY);

app.use(express.json());


app.get('/api/data', async (req, res) => {
  try {
    const { data, error } = await supabase.from("profiles").select("*");
    if (error) return res.status(500).json({ error: error.message });
    res.json(data);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.listen(2000, () => {
    console.log("connected at server port 2000");
})



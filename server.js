const express = require('express');
const bodyParser = require('body-parser');



// app_configuration
const app = express();
const PORT = process.env.PORT || 3001;
// Middleware
app.use(express.json());
// item_list
let itemList = [
    { id: 1, name: 'name' },
    { id: 2, name: 'Item 2' },
    { id: 3, name: 'Item 3' }
];


// Crud operations
app.get('/api/data', (req, res) => {
   return res.json(itemList); });
app.post('/api/data', (req, res) =>{
    let newTask ={
        id: itemList.length + 1,
        name: req.body.name
    };
    itemList.push(newTask);
    // return res.json(itemList); for testing
    return res.status(201).json(newTask); //new open for


});
app.put('/api/data/:id', (req, res) => {
    let itemId = parseInt(req.params.id);
    let Updated_Item = req.body;
    let index=itemList.findIndex(item=> item.id === itemId);   
    if (index !== -1) {
        itemList[index].name = req.body.name;

        return res.json(itemList[index]);
    } else {
        return res.status(404).json({ error: 'Item not found' });
    }
});
app.delete('/api/data/:id', (req, res) => {
    let itemId = parseInt(req.params.id);
    let deleted_Item = req.body;
    let index=itemList.findIndex(item=> item.id === itemId);   
    if (index !== -1) {
        let deleted_Item = itemList.splice(index, 1)[0];
        return res.json(deleted_Item);
    } else {
        return res.status(404).json({ error: 'Item not found' });
    }
});

// Root route — placed before app.listen
app.get('/', (req, res) => {
  res.send('✅ Backend is running. Use /api/data for API calls.');
});

// listen on PORT
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});

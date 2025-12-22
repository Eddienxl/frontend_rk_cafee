const express = require('express');
const path = require('path');
const app = express();

// Serve static files dari folder build/web
app.use(express.static(path.join(__dirname, 'build/web')));

// Handle Flutter routing (SPA - Single Page Application)
// Semua route akan diarahkan ke index.html
app.get('*', (req, res) => {
    res.sendFile(path.join(__dirname, 'build/web', 'index.html'));
});

const PORT = process.env.PORT || 8080;
app.listen(PORT, () => {
    console.log(`Frontend RK Cafe running on port ${PORT}`);
});

//******************************************************************************
//*** set up an HTTP server off port 3000
//******************************************************************************
const express = require('express');
const app = express();
const PORT = 3000; 

// Requires the exported pool object from the local 'mysql.js' file
const pool = require('./mysql');

//******************************************************************************
//*** This routing table handles all the GET requests from the browser
//******************************************************************************

// All GET handlers now use async/await by calling the async readAndServe utility


//******************************************************************************
//*** this handles a specific GET requests from the browser (/)
//******************************************************************************
app.get("/", async (req, res) => {
    // extract the string received from the browser
    const category = req.query.category;
    const author = req.query.author;
    // return format of html table or json object
    const format = req.query.format; 

    // SECURITY FIX: Use prepared statements (the '?' placeholder)
    let sql_query;
    let input;

    if (category) {
        sql_query = "SELECT * FROM books WHERE category = ?";
        input = category;
    } else if (author) {
        sql_query = "SELECT * FROM books WHERE author = ?";
        input = author;
    } else {
        return res.status(404).send("Please provide category or author");
    }

    try {
        const [rows] = await pool.execute(sql_query, [input]);

        if (format == "text") {
            let html_body = "<HTML><STYLE>body{font-family:arial}</STYLE><BODY><TABLE BORDER=1>";
            html_body += "<TR><TH>TITLE</TH><TH>AUTHOR</TH><TH>CATEGORY</TH><TH>PRICE</TH></TR>";
            for (let i = 0; i < rows.length; i++) {
                    html_body += `<TR><TD>${rows[i].title}</TD><TD>${rows[i].author}</TD><TD>${rows[i].category}</TD><TD>${rows[i].price}</TD></TR>`;
                }
                html_body += "</TABLE></BODY></HTML>";
                res.send(html_body);
        } else {
            res.json(rows);
        }
    } catch (err) {
        console.error("SQL Error in / GET:", err);
        res.status(500).send("<html><body><h1>Database Query Error</h1><p>An error occurred while fetching data: " + err.message + "</p></body></html>");
    }
});

// --- Global Error Handler Middleware ---
// Kept as a fallback for non-route-specific errors or errors passed by next()
app.use((err, req, res, next) => {
    // Log the error stack for debugging purposes
    console.error(err.stack);
    res.status(500).json({ error: 'An unexpected server error occurred.', details: err.message });
});


//*** set up an HTTP server off port 3000
app.listen(PORT, function () {
    console.log("NodeJS app listening on port " + PORT);
});

// server.js

const express = require("express");
const mysql = require("mysql");
const cors = require("cors");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");

const app = express();
app.use(express.json());
app.use(cors());

//pdf gerniration 
const bodyParser = require('body-parser');
const PDFDocument = require('pdfkit');
const fs = require('fs');
const path = require('path');
const port = 3000;

app.use(bodyParser.json());

app.post('/generate-pdf', (req, res) => {
  const { description, date, cout } = req.body;

  const fileName = `reparation_${Date.now()}.pdf`;
  const filePath = path.join(__dirname, fileName);

  const doc = new PDFDocument();
  const writeStream = fs.createWriteStream(filePath);
  doc.pipe(writeStream);

  doc.fontSize(20).text('Demande de Réparation', { align: 'center' });
  doc.moveDown();

  doc.fontSize(14).text(`Description : ${description}`);
  doc.text(`Date souhaitée : ${date}`);
  doc.text(`Coût estimé : ${cout} DHS`);

  doc.end();

  writeStream.on('finish', () => {
    res.download(filePath, fileName, () => {
      fs.unlinkSync(filePath); // حذف الملف بعد التنزيل
    });
  });
});

app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
});


// Connexion à MySQL
const db = mysql.createConnection({
  host: "localhost",
  user: "root",
  password: "",
  database: "myapp",
});

db.connect(err => {
  if (err) console.error("Erreur de connexion à MySQL :", err);
  else console.log("Connexion réussie à MySQL !");
});

// Middleware d'authentification
const authenticateToken = (req, res, next) => {
  const authHeader = req.header("Authorization");
  const token = authHeader?.startsWith("Bearer ")
    ? authHeader.split(" ")[1]
    : authHeader;
  if (!token) return res.status(401).json({ error: "Accès refusé" });
  jwt.verify(token, "secret", (err, user) => {
    if (err) return res.status(403).json({ error: "Token invalide" });
    req.user = user;
    next();
  });
};

// Middleware admin
const isAdmin = (req, res, next) => {
  db.query(
    "SELECT role FROM users WHERE id = ?",
    [req.user.userId],
    (err, result) => {
      if (err) return res.status(500).json({ error: "Erreur serveur" });
      if (!result.length || result[0].role !== "admin")
        return res.status(403).json({ error: "Accès interdit" });
      next();
    }
  );
};

// --- Auth (signup / login) ---

app.post("/signup", (req, res) => {
  const { username, email, password, role } = req.body;
  if (!username || !email || !password)
    return res.status(400).json({ error: "Tous les champs sont obligatoires" });

  bcrypt.hash(password, 10, (err, hash) => {
    if (err) return res.status(500).json({ error: "Erreur de hashage" });
    const sql =
      "INSERT INTO users (username, email, password, role) VALUES (?, ?, ?, ?)";
    db.query(sql, [username, email, hash, role === "admin" ? "admin" : "user"], err => {
      if (err) return res.status(500).json({ error: "Erreur lors de l'inscription" });
      res.json({ message: "Utilisateur inscrit avec succès" });
    });
  });
});

app.post("/login", (req, res) => {
  const { email, password } = req.body;
  if (!email || !password)
    return res.status(400).json({ error: "Email et mot de passe requis" });

  db.query("SELECT * FROM users WHERE email = ?", [email], (err, results) => {
    if (err) return res.status(500).json({ error: "Erreur serveur" });
    if (!results.length) return res.status(401).json({ error: "Utilisateur non trouvé" });

    bcrypt.compare(password, results[0].password, (err, match) => {
      if (err) return res.status(500).json({ error: "Erreur serveur" });
      if (!match) return res.status(401).json({ error: "Mot de passe incorrect" });

      const token = jwt.sign({ userId: results[0].id }, "secret", { expiresIn: "1h" });
      res.json({ message: "Connexion réussie", token, role: results[0].role });
    });
  });
});

// --- Gestion utilisateurs (admin only) ---

app.get("/users", authenticateToken, isAdmin, (req, res) => {
  db.query("SELECT id, username, email, role FROM users", (err, rows) => {
    if (err) return res.status(500).json({ error: "Erreur serveur" });
    res.json(rows);
  });
});

app.delete("/users/:id", authenticateToken, isAdmin, (req, res) => {
  db.query("DELETE FROM users WHERE id = ?", [req.params.id], (err, result) => {
    if (err) return res.status(500).json({ error: "Erreur serveur" });
    if (!result.affectedRows) return res.status(404).json({ error: "Utilisateur non trouvé" });
    res.json({ message: "Utilisateur supprimé avec succès" });
  });
});

// --- Messages ---

app.post("/sendMessage", (req, res) => {
  const { id, message } = req.body;
  if (!id || !message)
    return res.status(400).json({ error: "ID et message requis" });
  db.query(
    "INSERT INTO messages (user_id, message) VALUES (?, ?)",
    [id, message],
    err => {
      if (err) return res.status(500).json({ error: "Erreur serveur" });
      res.json({ message: "Message envoyé avec succès" });
    }
  );
});

app.get("/messages", authenticateToken, (req, res) => {
  db.query(
    "SELECT message, sent_at FROM messages WHERE user_id = ? ORDER BY sent_at DESC",
    [req.user.userId],
    (err, rows) => {
      if (err) return res.status(500).json({ error: "Erreur serveur" });
      res.json(rows);
    }
  );
});

// --- Livres CRUD ---

// CREATE
app.post("/addBook", authenticateToken, isAdmin, (req, res) => {
  const { titre, image, description, disponibilite } = req.body;
  if (!titre) return res.status(400).json({ error: "Titre requis" });

  const sql =
    "INSERT INTO livres (titre, image, description, disponibilite) VALUES (?, ?, ?, ?)";
  db.query(sql, [titre, image || "", description || "", disponibilite || "indisponible"], err => {
    if (err) return res.status(500).json({ error: "Erreur lors de l'ajout du livre" });
    res.json({ message: "Livre ajouté avec succès" });
  });
});

// READ ALL
app.get("/livres", (req, res) => {
  db.query(
    "SELECT id, titre, image, date_ajout, disponibilite FROM livres ORDER BY date_ajout DESC",
    (err, rows) => {
      if (err) return res.status(500).json({ error: "Erreur serveur" });
      res.json(rows);
    }
  );
});

// READ ONE
app.get("/livres/:id", (req, res) => {
  db.query(
    "SELECT id, titre, image, description, date_ajout, disponibilite FROM livres WHERE id = ?",
    [req.params.id],
    (err, rows) => {
      if (err) return res.status(500).json({ error: "Erreur serveur" });
      if (!rows.length) return res.status(404).json({ error: "Livre non trouvé" });
      res.json(rows[0]);
    }
  );
});

// UPDATE
app.put("/livres/:id", authenticateToken, isAdmin, (req, res) => {
  const { titre, image, description, disponibilite } = req.body;
  if (!titre) return res.status(400).json({ error: "Titre requis" });

  db.query(
    "UPDATE livres SET titre = ?, image = ?, description = ?, disponibilite = ? WHERE id = ?",
    [titre, image || "", description || "", disponibilite || "indisponible", req.params.id],
    (err, result) => {
      if (err) return res.status(500).json({ error: "Erreur serveur" });
      if (!result.affectedRows) return res.status(404).json({ error: "Livre non trouvé" });
      res.json({ message: "Livre modifié avec succès" });
    }
  );
});

// DELETE
app.delete("/livres/:id", authenticateToken, isAdmin, (req, res) => {
  db.query("DELETE FROM livres WHERE id = ?", [req.params.id], (err, result) => {
    if (err) return res.status(500).json({ error: "Erreur serveur" });
    if (!result.affectedRows) return res.status(404).json({ error: "Livre non trouvé" });
    res.json({ message: "Livre supprimé avec succès" });
  });
});

// --- Recommandations ---

app.post('/recommandations', authenticateToken, (req, res) => {
  const { titre, description } = req.body;
  const userId = req.user.userId;
  db.query(
    "INSERT INTO recommandations (user_id, titre, description) VALUES (?, ?, ?)",
    [userId, titre, description],
    err => {
      if (err) return res.status(500).json({ error: "Erreur serveur" });
      res.json({ message: "Recommandation enregistrée." });
    }
  );
});

app.get('/recommandations', authenticateToken, isAdmin, (req, res) => {
  const sql = `
    SELECT r.id, r.titre, r.description, r.user_id, r.date_creation
    FROM recommandations r
    JOIN users u ON r.user_id = u.id
    ORDER BY r.date_creation DESC
  `;
  db.query(sql, (err, rows) => {
    if (err) return res.status(500).json({ error: "Erreur serveur" });
    res.json(rows);
  });
});

// --- Liste personnelle ---

app.post("/addToPersonalList", authenticateToken, (req, res) => {
  const userId = req.user.userId;
  const { livreId } = req.body;
  if (!livreId) return res.status(400).json({ error: "ID du livre manquant" });

  db.query(
    "INSERT INTO liste_personnelle (user_id, livre_id) VALUES (?, ?)",
    [userId, livreId],
    err => {
      if (err) return res.status(500).json({ error: "Erreur serveur" });
      res.json({ message: "Livre ajouté à votre liste personnelle" });
    }
  );
});

app.get('/listePersonnelle', authenticateToken, (req, res) => {
  const userId = req.user.userId;
  const sql = `
    SELECT l.id, l.titre, lp.date_ajout
    FROM liste_personnelle lp
    JOIN livres l ON lp.livre_id = l.id
    WHERE lp.user_id = ?
    ORDER BY lp.date_ajout DESC
  `;
  db.query(sql, [userId], (err, results) => {
    if (err) return res.status(500).json({ error: "Erreur serveur" });
    res.json(results);
  });
});

// --- Emprunts (achats) ---
// 📌 Route POST - Ajouter une demande d'emprunt
app.post("/emprunter", authenticateToken, (req, res) => {
  const { livreId, date } = req.body;
  const userId = req.user.userId;

  if (!livreId || !date) {
    return res.status(400).json({ error: "Tous les champs sont requis" });
  }

  const checkSql = `
    SELECT * FROM emprunts
    WHERE user_id = ? AND livre_id = ? AND admin_status = 'en attente'
  `;

  db.query(checkSql, [userId, livreId], (err, result) => {
    if (err) return res.status(500).json({ error: "Erreur serveur" });
    if (result.length > 0) {
      return res.status(400).json({ message: "Demande déjà en attente" });
    }

    const insertSql = `
      INSERT INTO emprunts (user_id, livre_id, dateEmprunt, admin_status)
      VALUES (?, ?, ?, 'en attente')
    `;

    db.query(insertSql, [userId, livreId, date], (err2) => {
      if (err2) return res.status(500).json({ error: "Erreur serveur" });
      res.status(200).json({ message: "Demande envoyée avec succès" });
    });
  });
});

// 📌 Route GET - Liste des demandes en attente (admin)
app.get("/admin/emprunts-en-attente", authenticateToken, isAdmin, (req, res) => {
  const sql = `
    SELECT e.id, e.user_id, u.username, l.titre,
           e.dateEmprunt, e.admin_status
    FROM emprunts e
    JOIN users u ON e.user_id = u.id
    JOIN livres l ON e.livre_id = l.id
    WHERE e.admin_status = 'en attente'
    ORDER BY e.dateEmprunt DESC
  `;
  db.query(sql, (err, rows) => {
    if (err) return res.status(500).json({ error: "Erreur serveur" });
    res.json(rows);
  });
});

// 📌 Route PUT - Traitement d'une demande (admin)
app.put("/admin/traiter-emprunt", authenticateToken, isAdmin, (req, res) => {
  const { id, status } = req.body;
  if (!["accepté", "refusé"].includes(status))
    return res.status(400).json({ error: "Statut invalide" });

  db.query(
    "UPDATE emprunts SET admin_status = ? WHERE id = ?",
    [status, id],
    (err, result) => {
      if (err) return res.status(500).json({ error: "Erreur serveur" });
      if (!result.affectedRows)
        return res.status(404).json({ error: "Demande non trouvée" });
      res.json({ message: `Demande ${status}e avec succès.` });
    }
  );
});


// 📌 Route GET - Historique des emprunts acceptés (admin)
app.get("/historique-ventes", authenticateToken, isAdmin, (req, res) => {
  const sql = `
    SELECT e.id, e.user_id, u.username, l.titre,
           e.dateEmprunt
    FROM emprunts e
    JOIN users u ON e.user_id = u.id
    JOIN livres l ON e.livre_id = l.id
    WHERE e.admin_status = 'accepté'
    ORDER BY e.dateEmprunt DESC
  `;
  db.query(sql, (err, rows) => {
    if (err) return res.status(500).json({ error: "Erreur serveur" });
    res.json(rows);
  });
});

// 📌 Route GET - Livres acceptés pour un utilisateur
app.get('/livres-acceptees', authenticateToken, (req, res) => {
  const userId = req.user.userId;
  const sql = `
    SELECT l.id, l.titre, e.dateEmprunt
    FROM emprunts e
    JOIN livres l ON e.livre_id = l.id
    WHERE e.user_id = ? AND e.admin_status = 'accepté'
    ORDER BY e.dateEmprunt DESC
  `;
  db.query(sql, [userId], (err, results) => {
    if (err) return res.status(500).json({ error: "Erreur serveur" });
    res.json(results);
  });
});

// Démarrage du serveur
app.listen(3000, "0.0.0.0", () =>
  console.log("Serveur en ligne sur le port 3000")
);

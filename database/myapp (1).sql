-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1:3306
-- Generation Time: Jun 02, 2025 at 07:37 PM
-- Server version: 8.3.0
-- PHP Version: 8.2.18

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `myapp`
--

-- --------------------------------------------------------

--
-- Table structure for table `addcar`
--

DROP TABLE IF EXISTS `addcar`;
CREATE TABLE IF NOT EXISTS `addcar` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `livre_id` int NOT NULL,
  `dateEmprunt` datetime DEFAULT CURRENT_TIMESTAMP,
  `statut` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT 'en cours',
  `admin_status` enum('en attente','accepté','refusé') CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT 'en attente',
  `disponibilite` varchar(50) COLLATE utf8mb4_general_ci DEFAULT 'disponible',
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `livre_id` (`livre_id`)
) ENGINE=InnoDB AUTO_INCREMENT=36 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `addcar`
--

INSERT INTO `addcar` (`id`, `user_id`, `livre_id`, `dateEmprunt`, `statut`, `admin_status`, `disponibilite`) VALUES
(32, 26, 57, '2025-05-26 00:00:00', 'en cours', 'accepté', 'disponible'),
(33, 26, 54, '2025-05-21 00:00:00', 'en cours', 'accepté', 'disponible'),
(34, 30, 57, '2025-05-29 00:00:00', 'en cours', 'accepté', 'disponible'),
(35, 30, 56, '2025-05-30 00:00:00', 'en cours', 'accepté', 'disponible');

-- --------------------------------------------------------

--
-- Table structure for table `cars`
--

DROP TABLE IF EXISTS `cars`;
CREATE TABLE IF NOT EXISTS `cars` (
  `id` int NOT NULL AUTO_INCREMENT,
  `titre` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `description` text COLLATE utf8mb4_general_ci,
  `image` varchar(500) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `date_ajout` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `disponibilite` varchar(50) COLLATE utf8mb4_general_ci NOT NULL DEFAULT 'disponible' COMMENT 'Disponibilité du livre',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=64 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `cars`
--

INSERT INTO `cars` (`id`, `titre`, `description`, `image`, `date_ajout`, `disponibilite`) VALUES
(45, 'Dacia duster', 'Le Dacia Duster 2025 est un SUV robuste offrant des motorisations hybrides, une transmission intégrale en option, un design modernisé et un intérieur spacieux, le tout à un prix abordable', 'https://image.elite-auto.fr/visuel/DACIA/dacia_23dusterjourneysu2fb_angularfront.png', '2025-04-23 20:56:40', 'disponible'),
(47, 'Hyundai Accent', 'La Hyundai Accent est une berline élégante offrant des équipements modernes, un intérieur confortable et une performance économique.', 'https://www.hyundai.com/content/dam/hyundai/ma/fr/data/vehicle-thumbnail/product/the-all-new-accent/default/668x362.png', '2025-04-23 21:38:30', 'indisponible'),
(48, 'Hyundai New Grand I10  \r', 'La Hyundai New Grand i10 est une citadine compacte au design moderne, dotée de technologies intelligentes et d’une performance économique.', 'https://www.hyundai.com/content/dam/hyundai/ma/fr/data/vehicle-thumbnail/product/grand-i10-/default/SLD-2_668X362.png', '2025-04-23 21:38:55', 'disponible'),
(53, 'Volkswagen caddy', 'Le Volkswagen Caddy est un utilitaire compact polyvalent, offrant un grand espace de chargement et une performance fiable.', 'https://kifalstorage.s3.amazonaws.com/new/img/volkswagen/caddy/principal.png', '2025-05-12 22:26:50', 'disponible'),
(54, 'RENAULT AUSTRAL', 'Le Renault Austral est un SUV moderne alliant design élégant, technologie avancée et moteurs efficaces.', 'https://image.elite-auto.fr/visuel/RENAULT/renault_24australhteknoesprtalpnsu1bfr_angularfront.png', '2025-05-12 22:29:09', 'disponible'),
(55, 'PEUGEOT 3008', 'Le Peugeot 3008 est un SUV dynamique alliant style audacieux, technologie avancée et performance efficace.', 'https://image.elite-auto.fr/visuel/modeles/600x400/peugeot_3008_2024.png', '2025-05-12 22:37:15', 'disponible'),
(56, 'RENAULT ESPACE VI', 'Le Renault Espace VI est un SUV haut de gamme offrant confort spacieux, design élégant et technologies modernes.', 'https://image.elite-auto.fr/visuel/RENAULT/renault_24espaceheviconic7p4wdsu6b_angularfront.png', '2025-05-12 22:42:27', 'disponible'),
(57, 'TOYOTA C-HR', 'Le Toyota C-HR est un SUV hybride au design audacieux, alliant efficacité et sécurité avancée', 'https://image.elite-auto.fr/visuel/TOYOTA/toyota_24chrhevpremieresu2b_angularrear.png', '2025-05-12 22:43:26', 'disponible'),
(62, 'hyundai', '.....', 'https://www.hyundai.com/content/dam/hyundai/ma/fr/data/vehicle-thumbnail/product/grand-i10-/default/SLD-2_668X362.png', '2025-05-29 20:44:48', 'disponible'),
(63, 'golf', '....', 'https://kifalstorage.s3.amazonaws.com/new/img/volkswagen/golf/principal.png', '2025-05-30 08:05:21', 'indisponible');

-- --------------------------------------------------------

--
-- Table structure for table `maliste`
--

DROP TABLE IF EXISTS `maliste`;
CREATE TABLE IF NOT EXISTS `maliste` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL,
  `livre_id` int DEFAULT NULL,
  `date_ajout` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `livre_id` (`livre_id`)
) ENGINE=InnoDB AUTO_INCREMENT=35 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `maliste`
--

INSERT INTO `maliste` (`id`, `user_id`, `livre_id`, `date_ajout`) VALUES
(30, 26, 57, '2025-05-25 00:08:00'),
(31, 26, 56, '2025-05-25 00:08:02'),
(32, 26, 56, '2025-05-25 00:08:03'),
(33, 26, 53, '2025-05-25 00:08:06'),
(34, 30, 57, '2025-05-29 20:19:24');

-- --------------------------------------------------------

--
-- Table structure for table `messages`
--

DROP TABLE IF EXISTS `messages`;
CREATE TABLE IF NOT EXISTS `messages` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` varchar(255) NOT NULL,
  `sujet` varchar(255) NOT NULL,
  `message` text NOT NULL,
  `type` enum('Urgent','Information','Autre') NOT NULL,
  `date` datetime NOT NULL,
  `sent_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `messages`
--

INSERT INTO `messages` (`id`, `user_id`, `sujet`, `message`, `type`, `date`, `sent_at`) VALUES
(7, '26', '', 'Continuez à avancer ! Vos efforts font une réelle différence.', 'Urgent', '0000-00-00 00:00:00', '2025-05-21 18:48:31'),
(6, '26', '', 'Bonjour,\nJuste un petit mot pour dire que tout va bien. Merci pour votre engagement et vos efforts constants. Continuez votre excellent travail !', 'Urgent', '0000-00-00 00:00:00', '2025-05-21 18:47:46'),
(8, '30', '', '...', 'Urgent', '0000-00-00 00:00:00', '2025-05-29 20:21:13'),
(9, '30', '', '.....', 'Urgent', '0000-00-00 00:00:00', '2025-05-29 20:35:47');

-- --------------------------------------------------------

--
-- Table structure for table `recommandations`
--

DROP TABLE IF EXISTS `recommandations`;
CREATE TABLE IF NOT EXISTS `recommandations` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `titre` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `description` text COLLATE utf8mb4_general_ci NOT NULL,
  `date_creation` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `recommandations`
--

INSERT INTO `recommandations` (`id`, `user_id`, `titre`, `description`, `date_creation`) VALUES
(17, 26, '', '', '2025-05-21 19:08:12'),
(18, 26, 'Dacia duster', 'Merci de faire réparer le véhicule dès que possible et de nous informer une fois terminé.', '2025-05-21 19:18:25'),
(19, 30, 'Tayota', '.....', '2025-05-29 20:19:54');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
CREATE TABLE IF NOT EXISTS `users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `email` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `password` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `role` enum('user','admin') COLLATE utf8mb4_general_ci DEFAULT 'user',
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `username`, `email`, `password`, `role`) VALUES
(25, 'aziz', 'aziz@gmail.com', '$2b$10$8PuSJr5yqo1M6htAWte0muKSU5ZDnDTcAVxnKFSvnvRV4AMBT3yVO', 'admin'),
(26, 'sara', 'sara@gmail.com', '$2b$10$w2P7z3RyS2aYrCoyHlcxOe1GmZIyfjw3alEkJR7e2k0Ls3dDYUaH.', 'user'),
(30, 'taha', 'taha@gmail.com', '$2b$10$Wz9Zc6SMOHoZWnCtkf7HSOTNtNggeLT92ZMi.n9UTr1LMrqi5eM8y', 'user');

--
-- Constraints for dumped tables
--

--
-- Constraints for table `addcar`
--
ALTER TABLE `addcar`
  ADD CONSTRAINT `addcar_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `addcar_ibfk_2` FOREIGN KEY (`livre_id`) REFERENCES `cars` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `maliste`
--
ALTER TABLE `maliste`
  ADD CONSTRAINT `maliste_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `maliste_ibfk_2` FOREIGN KEY (`livre_id`) REFERENCES `cars` (`id`);

--
-- Constraints for table `recommandations`
--
ALTER TABLE `recommandations`
  ADD CONSTRAINT `recommandations_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

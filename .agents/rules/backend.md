---
trigger: always_on
---

This is the actual structure of the database supporting ANSEP3's development:

-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: localhost:8889
-- Tiempo de generación: 02-03-2026 a las 19:57:37
-- Versión del servidor: 8.0.40
-- Versión de PHP: 8.3.14

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `ANSEP3`
--

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `models`
--

CREATE TABLE `models` (
  `Id` int NOT NULL,
  `model_name` varchar(255) NOT NULL,
  `model_author` varchar(255) DEFAULT NULL,
  `model_path` varchar(500) NOT NULL,
  `model_filename` varchar(255) NOT NULL,
  `model_description` text,
  `model_publication` varchar(500) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `models`
--

INSERT INTO `models` (`Id`, `model_name`, `model_author`, `model_path`, `model_filename`, `model_description`, `model_publication`) VALUES
(1, 'Astrocyte Canonical 2025 (Angarita et al 2025)', 'Andrea Angarita-Rodríguez, Nicolas Mendoza-Mejía, Janneth Gonzalez ,Jason Papin, Andres Felipe Aristizabal, Andrés Pinzón', 'models', 'astrocyte_2025.xml', 'This is the canonical model from Angarita et al. 2025 fully described in the paper \"Improvement in the prediction power of an astrocyte genome-scale metabolic model using multi-omic data\".\r\nIn this study it was applied a principal component analysis (PCA)-based approach to integrate transcriptome and proteome data. This method facilitates the reconstruction of context-specific models grounded in multi-omics data, enhancing their biological relevance and predictive capacity. This way we successfully reconstructed an astrocyte GEM with improved prediction capabilities compared to state-of-the-art models available in the literature.\r\nThis model corresponds to the healthy state of Astrocyte using transcriptomics and proteomics data.', 'https://doi.org/10.3389/fsysb.2024.1500710'),
(2, 'Astrocyte Healthy 2020 (Osorio et al. 2020)', 'Daniel Osorio, Andrés Pinzón, Cynthia Martín-Jiménez, George E Barreto, Janneth González', 'models', 'astrocyte_healthy_2020.xml', 'This model is part of the genome-scale metabolic reconstruction of astrocytes that was used to study astrocytic response during an inflammatory insult by palmitate through Flux Balance Analysis methods and data mining. In this study the metabolic fluxes of human astrocytes under three different scenarios were assessed: healthy (normal conditions), induced inflammation by palmitate, and tibolone treatment under palmitate inflammation. \r\nThis model corresponds to the healthy state in this study.', 'https://doi.org/10.3389/fnins.2019.01410'),
(3, 'Test model', 'COBRA community', 'models', 'ecoli_core_model.xml', 'This model is JUST FOR TESTING, it is not part of our production and corresponds to  a generic E. coli core model, widely used in education by the metabolic reconstruction community.\r\n', 'NA'),
(4, 'Astrocyte Martin-Jimenez 2017 (Martin-Jimenez et al. 2017)', 'Cynthia A Martin-Jimenez, Diego Salazar-Barreto, George E Barreto, Janneth Gonzalez', 'models', 'astrocite_2017.xml', 'This was the first global high-quality, manually curated metabolic reconstruction network of a human astrocyte created by our group in normal and ischemic conditions. It includes 5,007 metabolites and 5,659 reactions distributed among 8 cell compartments, (extracellular, cytoplasm, mitochondria, endoplasmic reticle, Golgi apparatus, lysosome, peroxisome and nucleus).', 'https://doi.org/10.3389/fnagi.2017.00023'),
(5, 'Dopaminergic Neuron 2016 ( Gaitan et. al)', 'Diana Gaitan, Daniel Osorio y Andrés Pinzón. ', 'models', 'dopaminergic_Gaitan_2016.xml', 'This is our first version of a dopaminergic neuron cell in the context of Parkinson\'s Disease and neuroprotection with Caffeine. Its reconstruction was based on post mortem brain data. This work was published only as a master thesis work on Bioinformatics. \r\nAlthough not formally published in a journal this model\'s predictions are highly accurate and deserves a place in this platform as a tool for dopaminergic neuron cells metabolism.', 'https://repositorio.unal.edu.co/handle/unal/59029'),
(101, 'Broken Model', NULL, 'models/broken_file.xml', 'broken_file.xml', NULL, NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `simulations`
--

CREATE TABLE `simulations` (
  `id` int NOT NULL,
  `user_id` int NOT NULL,
  `analysis_id` varchar(100) NOT NULL,
  `analysis_name` varchar(255) NOT NULL,
  `analysis_type` varchar(50) DEFAULT 'FBA',
  `model_id` int DEFAULT NULL,
  `model_filename` varchar(255) DEFAULT NULL,
  `objective_value` double DEFAULT NULL,
  `status` varchar(50) DEFAULT NULL,
  `execution_status` varchar(50) DEFAULT 'processing',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `simulations`
--

INSERT INTO `simulations` (`id`, `user_id`, `analysis_id`, `analysis_name`, `analysis_type`, `model_id`, `model_filename`, `objective_value`, `status`, `execution_status`, `created_at`) VALUES
(92, 1, 'fba_result_20260228_174606', 'First FBA', 'FBA', 3, 'ecoli_core_model.xml', 0.873922, 'optimal', 'success', '2026-02-28 17:46:06'),
(93, 1, 'fva_result_20260228_174650', 'First FVA', 'FVA', 3, 'ecoli_core_model.xml', 0.873922, 'Optimal', 'success', '2026-02-28 17:46:50'),
(94, 1, 'robustness_result_20260228_174742', 'First Robustness', 'ROBUSTNESS', 3, 'ecoli_core_model.xml', NULL, 'Optimal', 'success', '2026-02-28 17:47:42'),
(95, 1, 'fba_result_20260228_220052', 'hola', 'FBA', 3, 'ecoli_core_model.xml', 0.873922, 'optimal', 'success', '2026-02-28 22:00:52'),
(96, 1, 'fva_result_20260228_220110', 'hola2', 'FVA', 3, 'ecoli_core_model.xml', 0.873922, 'Optimal', 'success', '2026-02-28 22:01:10'),
(97, 1, 'robustness_result_20260228_220430', 'robuts', 'ROBUSTNESS', 3, 'ecoli_core_model.xml', NULL, NULL, 'error', '2026-02-28 22:04:30'),
(98, 1, 'robustness_result_20260228_220509', 'rere', 'ROBUSTNESS', 3, 'ecoli_core_model.xml', NULL, NULL, 'error', '2026-02-28 22:05:09'),
(99, 1, 'robustness_result_20260228_220623', 'dfdfdf', 'ROBUSTNESS', 3, 'ecoli_core_model.xml', NULL, 'Optimal', 'success', '2026-02-28 22:06:23'),
(100, 1, 'expression_result_20260301_190420', 'Expression Analysis 2026-03-01 19:04', 'EXPRESSION', 3, 'ecoli_core_model.xml', NULL, NULL, 'processing', '2026-03-01 19:04:20'),
(101, 1, 'fba_result_20260302_192900', 'test neuron', 'FBA', 3, 'ecoli_core_model.xml', 0.873922, 'optimal', 'success', '2026-03-02 19:29:00'),
(102, 1, 'fva_result_20260302_192922', 'test neuron', 'FVA', 3, 'ecoli_core_model.xml', 0.873922, 'Optimal', 'success', '2026-03-02 19:29:22'),
(103, 1, 'robustness_result_20260302_193003', 'test neuron', 'ROBUSTNESS', 3, 'ecoli_core_model.xml', NULL, 'Optimal', 'success', '2026-03-02 19:30:03');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `users`
--

CREATE TABLE `users` (
  `id` int NOT NULL,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `users`
--

INSERT INTO `users` (`id`, `name`, `email`, `password`, `created_at`) VALUES
(1, 'Andres Pinzon', 'andrespinzon@gmail.com', '$2y$10$65VPlzLyemyFNjFqV6di7O2cysgKbLANsVUGUsUctpu1mxYHar3F.', '2026-02-25 16:39:23'),
(4, 'Janneth Gonzalez', 'janneth.gonzalez@javeriana.edu.co', '$2y$10$3wz966ZXxd9d3NE5OYvVv.9l.QwDIMO7tZPGYMBxnDyDFERYhwnGW', '2026-02-25 16:57:05');

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `models`
--
ALTER TABLE `models`
  ADD PRIMARY KEY (`Id`);

--
-- Indices de la tabla `simulations`
--
ALTER TABLE `simulations`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `analysis_id` (`analysis_id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `model_id` (`model_id`);

--
-- Indices de la tabla `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `models`
--
ALTER TABLE `models`
  MODIFY `Id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=102;

--
-- AUTO_INCREMENT de la tabla `simulations`
--
ALTER TABLE `simulations`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=104;

--
-- AUTO_INCREMENT de la tabla `users`
--
ALTER TABLE `users`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `simulations`
--
ALTER TABLE `simulations`
  ADD CONSTRAINT `simulations_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `simulations_ibfk_2` FOREIGN KEY (`model_id`) REFERENCES `models` (`Id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

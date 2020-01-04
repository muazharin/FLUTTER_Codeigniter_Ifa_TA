-- phpMyAdmin SQL Dump
-- version 4.8.4
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jan 04, 2020 at 07:26 AM
-- Server version: 10.1.37-MariaDB
-- PHP Version: 7.3.0

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `db_ifa`
--

-- --------------------------------------------------------

--
-- Table structure for table `tb_delete`
--

CREATE TABLE `tb_delete` (
  `id_delete` int(11) NOT NULL,
  `id_send` int(11) NOT NULL,
  `ket_pengirim` varchar(100) NOT NULL,
  `ket_penerima` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `tb_recent`
--

CREATE TABLE `tb_recent` (
  `id_recent` int(11) NOT NULL,
  `id_send` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `tb_send`
--

CREATE TABLE `tb_send` (
  `id_send` int(11) NOT NULL,
  `pengirim` varchar(100) NOT NULL,
  `penerima` varchar(100) NOT NULL,
  `kunci` varchar(200) NOT NULL,
  `tipe` varchar(4) NOT NULL,
  `str` longtext NOT NULL,
  `pesan` text NOT NULL,
  `ket` varchar(15) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `tb_user`
--

CREATE TABLE `tb_user` (
  `id_user` int(11) NOT NULL,
  `username` varchar(100) NOT NULL,
  `password` varchar(32) NOT NULL,
  `email` varchar(100) NOT NULL,
  `hp` varchar(12) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `tb_user`
--

INSERT INTO `tb_user` (`id_user`, `username`, `password`, `email`, `hp`) VALUES
(1, 'ifa', 'e10adc3949ba59abbe56e057f20f883e', 'ifa@gmail.com', '082188061718'),
(5, 'muaz', '200820e3227815ed1756a6b531e7e0d2', 'alfanmuazharin@gmail.com', '082243309590'),
(12, 'mamta', 'e10adc3949ba59abbe56e057f20f883e', 'mamta@gmail.com', '085231469764');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `tb_delete`
--
ALTER TABLE `tb_delete`
  ADD PRIMARY KEY (`id_delete`);

--
-- Indexes for table `tb_recent`
--
ALTER TABLE `tb_recent`
  ADD PRIMARY KEY (`id_recent`);

--
-- Indexes for table `tb_send`
--
ALTER TABLE `tb_send`
  ADD PRIMARY KEY (`id_send`);

--
-- Indexes for table `tb_user`
--
ALTER TABLE `tb_user`
  ADD PRIMARY KEY (`id_user`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `tb_delete`
--
ALTER TABLE `tb_delete`
  MODIFY `id_delete` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=39;

--
-- AUTO_INCREMENT for table `tb_recent`
--
ALTER TABLE `tb_recent`
  MODIFY `id_recent` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=41;

--
-- AUTO_INCREMENT for table `tb_send`
--
ALTER TABLE `tb_send`
  MODIFY `id_send` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=41;

--
-- AUTO_INCREMENT for table `tb_user`
--
ALTER TABLE `tb_user`
  MODIFY `id_user` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

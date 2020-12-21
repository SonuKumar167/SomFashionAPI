-- phpMyAdmin SQL Dump
-- version 5.0.2
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: May 31, 2020 at 05:04 PM
-- Server version: 10.4.11-MariaDB
-- PHP Version: 7.4.5

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `ecommerce`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_GetProduct` ()  NO SQL
BEGIN
CREATE TEMPORARY TABLE GetProduct(
 product_id int(20) not null,
 product_title varchar(255) not null,
 gender varchar(255) not null,
 product_desc varchar(255) not null,
 product_image_front varchar(255) not null,
 product_image_back varchar(255) not null,
 product_image_side varchar(255) not null,
 product_keywords varchar(255) not null,
 cat_title varchar(255) not null,
 cat_id int(20) not null,
 brand_id int(20) not null,
 brand_title varchar(255) not null,
 size_s varchar(5),
 size_m varchar(5),
 size_l varchar(5),
 size_xl varchar(5),
 size_xxl varchar(5),
 qty_s int(20),
 qty_m int(20),
 qty_l int(20),
 qty_xl int(20),
 qty_xxl int(20),
 price_s int(20),
 price_m int(20),
 price_l int(20),
 price_xl int(20),
 price_xxl int(20)
);

INSERT into GetProduct(`product_id`,`product_title`,`gender`,`product_desc`,`product_image_front`,`product_image_back`,`product_image_side`,`product_keywords`,`cat_title`,`cat_id`,`brand_id`,`brand_title`) SELECT p.product_id, p.product_title,p.gender, p.product_desc,p.product_image_front,p.product_image_back,p.product_image_side, p.product_keywords, c.cat_title, c.cat_id, b.brand_id, b.brand_title FROM products p JOIN categories c ON c.cat_id = p.product_cat JOIN brands b ON b.brand_id = p.product_brand order by p.product_id desc;

UPDATE GetProduct P INNER JOIN product_size as S ON P.product_id=S.product_id SET P.size_s=S.product_size,P.qty_s=S.product_qty,P.price_s=S.product_price where S.product_size='S';

UPDATE GetProduct P INNER JOIN product_size as S ON P.product_id=S.product_id SET P.size_m=S.product_size,P.qty_m=S.product_qty,P.price_m=S.product_price where S.product_size='M';

UPDATE GetProduct P INNER JOIN product_size as S ON P.product_id=S.product_id SET P.size_l=S.product_size,P.qty_l=S.product_qty,P.price_l=S.product_price where S.product_size='L';

UPDATE GetProduct P INNER JOIN product_size as S ON P.product_id=S.product_id SET P.size_xl=S.product_size,P.qty_xl=S.product_qty,P.price_xl=S.product_price where S.product_size='XL';

UPDATE GetProduct P INNER JOIN product_size as S ON P.product_id=S.product_id SET P.size_xxl=S.product_size,P.qty_xxl=S.product_qty,P.price_xxl=S.product_price where S.product_size='XXL';
SELECT * FROM GetProduct order by product_id desc;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_MenCategory` ()  NO SQL
BEGIN

SELECT C.cat_id,C.brand_id,C.cat_title,C.gender,C.wear,P.Count from ( SELECT * from categories where gender='Men') C LEFT JOIN
( select count(*) as Count,product_cat from products GROUP by product_cat) P ON C.cat_id = P.product_cat;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_OrderStatus` ()  NO SQL
BEGIN
CREATE TEMPORARY TABLE OrderCount(
  activeCount int(20) not null,
  pendingCount int(20),
  deliveredCount int(20)
);

insert into OrderCount(activeCount) SELECT count(order_id) FROM orders where order_status='Confirmed' || order_status='Dispatched' || order_status='Out for Delivery';

Update OrderCount SET pendingCount=0,deliveredCount=( SELECT count(order_id) from orders where order_status='Delivered');

Update OrderCount SET pendingCount=( SELECT count(id) from cart);

SELECT activeCount,deliveredCount,pendingCount FROM OrderCount ;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_ProductFilter` (IN `cat_id` VARCHAR(255), IN `gender` VARCHAR(255), IN `Offset1` INT(20), IN `brand_id` VARCHAR(255), IN `min1` INT(20), IN `max1` INT(20), IN `size` VARCHAR(255), IN `typehead` VARCHAR(255))  NO SQL
BEGIN

IF cat_id>0 and brand_id>0 and min1>0 and max1>0 and Offset1>0 THEN
SELECT distinct p.product_code,p.product_id, p.product_title, p.product_price,p.product_size,p.product_qty, p.product_desc, p.product_image_front,p.product_image_back,p.product_image_side, p.product_keywords, c.cat_title, c.cat_id, b.brand_id, b.brand_title FROM products p JOIN categories c ON c.cat_id = p.product_cat JOIN brands b ON b.brand_id = p.product_brand where find_in_set(p.product_cat,cat_id) and find_in_set(p.product_brand,brand_id) and p.product_price >= min1 and p.product_price <= max1 order by p.product_id desc limit Offset1,48;

ELSEIF cat_id>0 and brand_id>0 and min1>0 and max1>0 THEN
SELECT distinct p.product_code,p.product_id, p.product_title, p.product_price,p.product_size,p.product_qty, p.product_desc, p.product_image_front,p.product_image_back,p.product_image_side, p.product_keywords, c.cat_title, c.cat_id, b.brand_id, b.brand_title FROM products p JOIN categories c ON c.cat_id = p.product_cat JOIN brands b ON b.brand_id = p.product_brand where find_in_set(p.product_cat,cat_id) and find_in_set(p.product_brand,brand_id) and p.product_price >= min1 and p.product_price <= max1 order by p.product_id desc limit 0,48;

ELSEIF cat_id>0 and brand_id>0 and Offset1>0 THEN
SELECT distinct p.product_code,p.product_id, p.product_title, p.product_price,p.product_size,p.product_qty, p.product_desc, p.product_image_front,p.product_image_back,p.product_image_side, p.product_keywords, c.cat_title, c.cat_id, b.brand_id, b.brand_title FROM products p JOIN categories c ON c.cat_id = p.product_cat JOIN brands b ON b.brand_id = p.product_brand where p.product_cat = cat_id and p.product_brand=brand_id order by p.product_id desc limit Offset1,48;

ELSEIF cat_id>0 and brand_id>0 THEN
SELECT distinct p.product_code,p.product_id, p.product_title, p.product_price,p.product_size,p.product_qty, p.product_desc, p.product_image_front,p.product_image_back,p.product_image_side, p.product_keywords, c.cat_title, c.cat_id, b.brand_id, b.brand_title FROM products p JOIN categories c ON c.cat_id = p.product_cat JOIN brands b ON b.brand_id = p.product_brand where p.product_cat = cat_id and p.product_brand=brand_id order by p.product_id desc limit 0,48;

ELSEIF size!="" AND cat_id>0 and min1>0 AND max1>0 AND Offset1>0 THEN
SELECT distinct p.product_code,p.product_id, p.product_title, p.product_price,p.product_size,p.product_qty, p.product_desc, p.product_image_front,p.product_image_back,p.product_image_side, p.product_keywords, c.cat_title, c.cat_id, b.brand_id, b.brand_title FROM products p JOIN categories c ON c.cat_id = p.product_cat JOIN brands b ON b.brand_id = p.product_brand where p.product_id IN (SELECT DISTINCT `product_id` FROM `product_size` WHERE p.product_price>=min1 AND p.product_price<=max1 and find_in_set(`product_size`,size) order by product_id desc) and find_in_set(p.product_cat,cat_id) order by p.product_id desc limit Offset1,48;

ELSEIF size!="" AND cat_id>0 and min1>0 AND max1>0 THEN
SELECT distinct p.product_code,p.product_id, p.product_title, p.product_price,p.product_size,p.product_qty, p.product_desc, p.product_image_front,p.product_image_back,p.product_image_side, p.product_keywords, c.cat_title, c.cat_id, b.brand_id, b.brand_title FROM products p JOIN categories c ON c.cat_id = p.product_cat JOIN brands b ON b.brand_id = p.product_brand where p.product_id IN (SELECT DISTINCT `product_id` FROM `product_size` WHERE p.product_price>=min1 AND p.product_price<=max1 and find_in_set(`product_size`,size) order by product_id desc) and find_in_set(p.product_cat,cat_id) order by p.product_id desc limit 0,48;

ELSEIF cat_id>0 and min1>0 and max1>0 and Offset1>0 THEN
SELECT distinct p.product_code,p.product_id, p.product_title, p.product_price,p.product_size,p.product_qty, p.product_desc, p.product_image_front,p.product_image_back,p.product_image_side, p.product_keywords, c.cat_title, c.cat_id, b.brand_id, b.brand_title FROM products p JOIN categories c ON c.cat_id = p.product_cat JOIN brands b ON b.brand_id = p.product_brand where find_in_set(p.product_cat,cat_id) and p.product_price>=min1 and p.product_price<=max1 order by p.product_id desc limit Offset1,48;

ELSEIF cat_id>0 and min1>0 and max1>0 THEN
SELECT distinct p.product_code,p.product_id, p.product_title, p.product_price,p.product_size,p.product_qty, p.product_desc, p.product_image_front,p.product_image_back,p.product_image_side, p.product_keywords, c.cat_title, c.cat_id, b.brand_id, b.brand_title FROM products p JOIN categories c ON c.cat_id = p.product_cat JOIN brands b ON b.brand_id = p.product_brand where find_in_set(p.product_cat,cat_id) and p.product_price>=min1 and p.product_price<=max1 order by p.product_id desc limit 0,48;

ELSEIF cat_id>0 and Offset1>0 THEN
SELECT distinct p.product_code,p.product_id, p.product_title, p.product_price,p.product_size,p.product_qty, p.product_desc, p.product_image_front,p.product_image_back,p.product_image_side, p.product_keywords, c.cat_title, c.cat_id, b.brand_id, b.brand_title FROM products p JOIN categories c ON c.cat_id = p.product_cat JOIN brands b ON b.brand_id = p.product_brand where find_in_set(p.product_cat,cat_id) order by p.product_id desc limit Offset1,48;

ELSEIF cat_id>0 THEN
SELECT distinct p.product_code,p.product_id, p.product_title, p.product_price,p.product_size,p.product_qty, p.product_desc, p.product_image_front,p.product_image_back,p.product_image_side, p.product_keywords, c.cat_title, c.cat_id, b.brand_id, b.brand_title FROM products p JOIN categories c ON c.cat_id = p.product_cat JOIN brands b ON b.brand_id = p.product_brand where find_in_set(p.product_cat,cat_id) order by p.product_id desc limit 0,48;

ELSEIF brand_id>0 and min1>0 and max1>0 and Offset1>0 THEN
SELECT distinct p.product_code,p.product_id, p.product_title, p.product_price,p.product_size,p.product_qty, p.product_desc, p.product_image_front,p.product_image_back,p.product_image_side, p.product_keywords, c.cat_title, c.cat_id, b.brand_id, b.brand_title FROM products p JOIN categories c ON c.cat_id = p.product_cat JOIN brands b ON b.brand_id = p.product_brand where find_in_set(p.product_brand,brand_id) and p.product_price>=min1 and p.product_price<=max1 order by p.product_id desc limit Offset1,48;

ELSEIF brand_id>0 and min1>0 and max1>0 THEN
SELECT distinct p.product_code,p.product_id, p.product_title, p.product_price,p.product_size,p.product_qty, p.product_desc, p.product_image_front,p.product_image_back,p.product_image_side, p.product_keywords, c.cat_title, c.cat_id, b.brand_id, b.brand_title FROM products p JOIN categories c ON c.cat_id = p.product_cat JOIN brands b ON b.brand_id = p.product_brand where find_in_set(p.product_brand,brand_id) and p.product_price>=min1 and p.product_price<=max1 order by p.product_id desc limit 0,48;

ELSEIF brand_id>0 and Offset1>0 THEN
SELECT distinct p.product_code,p.product_id, p.product_title, p.product_price,p.product_size,p.product_qty, p.product_desc, p.product_image_front,p.product_image_back,p.product_image_side, p.product_keywords, c.cat_title, c.cat_id, b.brand_id, b.brand_title FROM products p JOIN categories c ON c.cat_id = p.product_cat JOIN brands b ON b.brand_id = p.product_brand where find_in_set(p.product_brand,brand_id) order by p.product_id desc limit Offset1,48;

ELSEIF brand_id>0 THEN
SELECT distinct p.product_code,p.product_id, p.product_title, p.product_price,p.product_size,p.product_qty, p.product_desc, p.product_image_front,p.product_image_back,p.product_image_side, p.product_keywords, c.cat_title, c.cat_id, b.brand_id, b.brand_title FROM products p JOIN categories c ON c.cat_id = p.product_cat JOIN brands b ON b.brand_id = p.product_brand where find_in_set(p.product_brand,brand_id) order by p.product_id desc limit 0,48;

ELSEIF size!="" AND min1>0 AND max1>0 AND Offset1>0 THEN
SELECT distinct p.product_code,p.product_id, p.product_title, p.product_price,p.product_size,p.product_qty, p.product_desc, p.product_image_front,p.product_image_back,p.product_image_side, p.product_keywords, c.cat_title, c.cat_id, b.brand_id, b.brand_title FROM products p JOIN categories c ON c.cat_id = p.product_cat JOIN brands b ON b.brand_id = p.product_brand where p.product_id IN (SELECT DISTINCT `product_id` FROM `product_size` WHERE p.product_price>=min1 AND p.product_price<=max1 and find_in_set(`product_size`,size) order by product_id desc) order by p.product_id desc limit Offset1,48;

ELSEIF size!="" AND min1>0 AND max1>0 THEN
SELECT distinct p.product_code,p.product_id, p.product_title, p.product_price,p.product_size,p.product_qty, p.product_desc, p.product_image_front,p.product_image_back,p.product_image_side, p.product_keywords, c.cat_title, c.cat_id, b.brand_id, b.brand_title FROM products p JOIN categories c ON c.cat_id = p.product_cat JOIN brands b ON b.brand_id = p.product_brand where p.product_id IN (SELECT DISTINCT `product_id` FROM `product_size` WHERE p.product_price>=min1 AND p.product_price<=max1 and find_in_set(`product_size`,size) order by product_id desc) order by p.product_id desc limit 0,48;

ELSEIF gender!="" AND gender!=0 and Offset1>0 and min1>0 and max1>0 THEN
SELECT distinct p.product_code,p.product_id, p.product_title, p.product_price,p.product_size,p.product_qty, p.product_desc, p.product_image_front,p.product_image_back,p.product_image_side, p.product_keywords, c.cat_title, c.cat_id, b.brand_id, b.brand_title FROM products p JOIN categories c ON c.cat_id = p.product_cat JOIN brands b ON b.brand_id = p.product_brand where p.gender=gender and p.product_price>=min1 AND p.product_price<=max1 order by p.product_id desc limit Offset1,48;

ELSEIF min1>0 and max1>0 and Offset1>0 THEN
SELECT distinct p.product_code,p.product_id, p.product_title, p.product_price,p.product_size,p.product_qty, p.product_desc, p.product_image_front,p.product_image_back,p.product_image_side, p.product_keywords, c.cat_title, c.cat_id, b.brand_id, b.brand_title FROM products p JOIN categories c ON c.cat_id = p.product_cat JOIN brands b ON b.brand_id = p.product_brand where p.product_price>=min1 AND p.product_price<=max1 order by p.product_id desc limit Offset1,48;

ELSEIF min1>0 and max1>0 THEN
SELECT distinct p.product_code,p.product_id, p.product_title, p.product_price,p.product_size,p.product_qty, p.product_desc, p.product_image_front,p.product_image_back,p.product_image_side, p.product_keywords, c.cat_title, c.cat_id, b.brand_id, b.brand_title FROM products p JOIN categories c ON c.cat_id = p.product_cat JOIN brands b ON b.brand_id = p.product_brand where p.product_price>=min1 AND p.product_price<=max1 order by p.product_id desc limit 0,48;

ELSEIF typehead!="" AND Offset1 > 0 THEN
SELECT distinct p.product_code,p.product_id, p.product_title, p.product_price,p.product_size,p.product_qty, p.product_desc, p.product_image_front,p.product_image_back,p.product_image_side, p.product_keywords, c.cat_title, c.cat_id, b.brand_id, b.brand_title FROM products p JOIN categories c ON c.cat_id = p.product_cat JOIN brands b ON b.brand_id = p.product_brand where find_in_set(c.cat_title,typehead) order by p.product_id desc limit 0,Offset1;

ELSEIF typehead!="" THEN
SELECT distinct p.product_code,p.product_id, p.product_title, p.product_price,p.product_size,p.product_qty, p.product_desc, p.product_image_front,p.product_image_back,p.product_image_side, p.product_keywords, c.cat_title, c.cat_id, b.brand_id, b.brand_title FROM products p JOIN categories c ON c.cat_id = p.product_cat JOIN brands b ON b.brand_id = p.product_brand where find_in_set(c.cat_title,typehead) order by p.product_id desc limit 0,48;

ELSEIF gender!="" and Offset1>0 THEN
SELECT distinct p.product_code,p.product_id, p.product_title, p.product_price,p.product_size,p.product_qty, p.product_desc, p.product_image_front,p.product_image_back,p.product_image_side, p.product_keywords, c.cat_title, c.cat_id, b.brand_id, b.brand_title FROM products p JOIN categories c ON c.cat_id = p.product_cat JOIN brands b ON b.brand_id = p.product_brand where p.gender=gender order by p.product_id desc limit Offset1,48;

ELSEIF Offset1>0 THEN
SELECT distinct p.product_code,p.product_id, p.product_title, p.product_price,p.product_size,p.product_qty, p.product_desc, p.product_image_front,p.product_image_back,p.product_image_side, p.product_keywords, c.cat_title, c.cat_id, b.brand_id, b.brand_title FROM products p JOIN categories c ON c.cat_id = p.product_cat JOIN brands b ON b.brand_id = p.product_brand order by p.product_id desc limit Offset1,48;

ELSEIF gender!="" THEN
SELECT distinct p.product_code,p.product_id, p.product_title, p.product_price,p.product_size,p.product_qty, p.product_desc, p.product_image_front,p.product_image_back,p.product_image_side, p.product_keywords, c.cat_title, c.cat_id, b.brand_id, b.brand_title FROM products p JOIN categories c ON c.cat_id = p.product_cat JOIN brands b ON b.brand_id = p.product_brand where p.gender=gender order by p.product_id desc limit 0,48;

ELSEIF size!="" AND Offset1>0 THEN
SELECT distinct p.product_code,p.product_id, p.product_title, p.product_price,p.product_size,p.product_qty, p.product_desc, p.product_image_front,p.product_image_back,p.product_image_side, p.product_keywords, c.cat_title, c.cat_id, b.brand_id, b.brand_title FROM products p JOIN categories c ON c.cat_id = p.product_cat JOIN brands b ON b.brand_id = p.product_brand where p.product_id IN (SELECT DISTINCT `product_id` FROM `product_size` WHERE find_in_set(`product_size`,size) order by product_id desc) order by p.product_id desc limit Offset1,48;

ELSEIF size!="" THEN
SELECT distinct p.product_code,p.product_id, p.product_title, p.product_price,p.product_size,p.product_qty, p.product_desc, p.product_image_front,p.product_image_back,p.product_image_side, p.product_keywords, c.cat_title, c.cat_id, b.brand_id, b.brand_title FROM products p JOIN categories c ON c.cat_id = p.product_cat JOIN brands b ON b.brand_id = p.product_brand where p.product_id IN (SELECT DISTINCT `product_id` FROM `product_size` WHERE find_in_set(`product_size`,size) order by product_id desc) order by p.product_id desc limit 0,48;

ELSE
SELECT distinct p.product_code,p.product_id, p.product_title, p.product_price,p.product_size,p.product_qty, p.product_desc, p.product_image_front,p.product_image_back,p.product_image_side, p.product_keywords, c.cat_title, c.cat_id, b.brand_id, b.brand_title FROM products p JOIN categories c ON c.cat_id = p.product_cat JOIN brands b ON b.brand_id = p.product_brand order by p.product_id desc limit 0,48;

END IF;


END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_WomenCategory` ()  NO SQL
BEGIN

SELECT C.cat_id,C.brand_id,C.cat_title,C.gender,C.wear,P.Count from ( SELECT * from categories where gender='women') C,
( select count(*) as Count,product_cat from products GROUP by product_cat) P where C.cat_id = P.product_cat;

END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `admin`
--

CREATE TABLE `admin` (
  `id` int(11) NOT NULL,
  `name` varchar(50) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `is_active` enum('0','1') NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `admin`
--

INSERT INTO `admin` (`id`, `name`, `email`, `password`, `is_active`) VALUES
(8, 'Sonu', 'sonuprakash167@gmail.com', 'a52a21d431f999e49d4211f983c5be51', '0');

-- --------------------------------------------------------

--
-- Table structure for table `banner`
--

CREATE TABLE `banner` (
  `id` int(10) NOT NULL,
  `name` varchar(255) NOT NULL,
  `content` varchar(255) NOT NULL,
  `path` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `banner`
--

INSERT INTO `banner` (`id`, `name`, `content`, `path`) VALUES
(3, 'image2', 'Cushion', '../img/banner/bg.jpg'),
(4, 'image3', 'Cushion', '../img/banner/bg-2.jpg');

-- --------------------------------------------------------

--
-- Table structure for table `brands`
--

CREATE TABLE `brands` (
  `brand_id` int(100) NOT NULL,
  `brand_title` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `brands`
--

INSERT INTO `brands` (`brand_id`, `brand_title`) VALUES
(8, 'Trendy'),
(9, 'Lycra'),
(12, 'Levis'),
(13, 'Spykar');

-- --------------------------------------------------------

--
-- Table structure for table `cart`
--

CREATE TABLE `cart` (
  `id` int(10) NOT NULL,
  `p_id` int(10) NOT NULL,
  `price` int(20) NOT NULL,
  `user_id` int(10) DEFAULT NULL,
  `qty` int(10) NOT NULL,
  `size` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `cart`
--

INSERT INTO `cart` (`id`, `p_id`, `price`, `user_id`, `qty`, `size`) VALUES
(6, 158, 400, 4, 1, 'M'),
(1444, 157, 400, 4, 1, 'M');

-- --------------------------------------------------------

--
-- Table structure for table `categories`
--

CREATE TABLE `categories` (
  `cat_id` int(100) NOT NULL,
  `brand_id` int(10) NOT NULL,
  `cat_title` text NOT NULL,
  `gender` varchar(255) NOT NULL,
  `wear` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `categories`
--

INSERT INTO `categories` (`cat_id`, `brand_id`, `cat_title`, `gender`, `wear`) VALUES
(14, 8, 'Palazzo', 'Women', 'bottom'),
(15, 9, 'Pants', 'Women', 'bottom'),
(16, 8, 'Top', 'Women', 'top'),
(17, 8, 'Kurti', 'Women', 'top'),
(19, 10, 'Jeans', 'Men', 'bottom'),
(20, 12, 'Casual Shirt', 'Men', 'top'),
(21, 12, 'T-Shirt', 'Men', 'top'),
(22, 12, 'Casual Trousers', 'Men', 'bottom'),
(23, 12, 'Formal Trousers', 'Men', 'bottom'),
(24, 12, 'Formal Shirt', 'Men', 'top');

-- --------------------------------------------------------

--
-- Table structure for table `coupons`
--

CREATE TABLE `coupons` (
  `id` int(20) NOT NULL,
  `code` varchar(6) NOT NULL,
  `price` int(11) NOT NULL,
  `status` int(5) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `customers_order_details`
--

CREATE TABLE `customers_order_details` (
  `id` int(20) NOT NULL,
  `user_id` int(20) NOT NULL,
  `order_id` int(20) NOT NULL,
  `product_id` int(20) NOT NULL,
  `customer_name` varchar(255) NOT NULL,
  `address` varchar(255) NOT NULL,
  `city` varchar(255) NOT NULL,
  `pin` varchar(255) NOT NULL,
  `mobile` varchar(10) NOT NULL,
  `datetime` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `customers_order_details`
--

INSERT INTO `customers_order_details` (`id`, `user_id`, `order_id`, `product_id`, `customer_name`, `address`, `city`, `pin`, `mobile`, `datetime`) VALUES
(3, 4, 8, 73, 'Sonu', 'Pandav Nagar', 'Delhi', '110020', '7239907130', '0000-00-00 00:00:00'),
(5, 4, 10, 158, 'SONU KUMAR', 'DURGA MANDIR ROAD', 'Sasaram', '821115', '7239907130', '2020-04-29 16:51:03'),
(6, 4, 11, 158, 'Sonu', 'Nooranganj', 'Sasaram', '821115', '7239907130', '2020-04-30 19:54:18');

-- --------------------------------------------------------

--
-- Table structure for table `orders`
--

CREATE TABLE `orders` (
  `order_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `SID` int(20) NOT NULL,
  `product_id` int(11) NOT NULL,
  `qty` int(11) NOT NULL,
  `size` varchar(255) NOT NULL,
  `price` int(20) NOT NULL,
  `tax` double NOT NULL,
  `delivery` int(20) NOT NULL,
  `order_status` varchar(255) NOT NULL DEFAULT 'Confirmed',
  `ReturnReason` varchar(255) NOT NULL,
  `p_mode` varchar(255) NOT NULL,
  `p_status` varchar(20) NOT NULL,
  `order_time` datetime NOT NULL DEFAULT current_timestamp(),
  `last_update` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `orders`
--

INSERT INTO `orders` (`order_id`, `user_id`, `SID`, `product_id`, `qty`, `size`, `price`, `tax`, `delivery`, `order_status`, `ReturnReason`, `p_mode`, `p_status`, `order_time`, `last_update`) VALUES
(8, 4, 8, 73, 3, 'S', 645, 0, 0, 'Cancelled', '', 'Cash On Delivery', 'pending', '2020-01-11 16:25:43', '2020-04-30 16:37:42'),
(10, 4, 8, 158, 2, 'M', 800, 0, 0, 'Dispatched', '', 'Cash On Delivery', 'pending', '2020-04-29 16:51:03', '2020-04-30 16:36:07'),
(11, 4, 8, 158, 1, 'M', 400, 20, 50, 'Return Initiated', '1', 'Google Pay', 'pending', '2020-04-30 19:54:18', '2020-05-18 14:56:31');

-- --------------------------------------------------------

--
-- Table structure for table `products`
--

CREATE TABLE `products` (
  `product_id` int(100) NOT NULL,
  `product_code` int(10) NOT NULL,
  `product_cat` int(11) NOT NULL,
  `product_brand` int(100) NOT NULL,
  `product_title` varchar(255) NOT NULL,
  `gender` varchar(255) NOT NULL,
  `product_size` varchar(255) NOT NULL,
  `product_price` int(100) NOT NULL,
  `product_qty` int(11) NOT NULL,
  `product_desc` text NOT NULL,
  `product_image_front` text NOT NULL,
  `product_image_back` text NOT NULL,
  `product_image_side` text NOT NULL,
  `product_keywords` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `products`
--

INSERT INTO `products` (`product_id`, `product_code`, `product_cat`, `product_brand`, `product_title`, `gender`, `product_size`, `product_price`, `product_qty`, `product_desc`, `product_image_front`, `product_image_back`, `product_image_side`, `product_keywords`) VALUES
(12, 19, 17, 8, 'White Red Cotton Kurti', 'Women', 'S,M,L,XL,XXL', 310, 50, 'Cotton Kurti', '1569653669_JKT019CREMCMRIC_1.JPG', '1569653669_JKT019CREMCMRIC_2.JPG', '1569653669_JKT019CREMCMRIC_5.JPG', 'Kurti'),
(13, 18, 17, 8, 'White Blue Cotton Kurti', 'Women', 'S,M,L,X,XXL', 310, 50, 'white blue cotton kurti', '1569653821_JKT019GREENCAMRIC_2.JPG', '1569653821_JKT019GREENCAMRIC_4.JPG', '1569653821_JKT019GREENCAMRIC_5.JPG', 'Cotton Kurti'),
(14, 10, 17, 8, 'Sky Blue Cotton Slab Top', 'Women', 'S,M,L,XL,XXL', 285, 50, 'Cotton Slab Top', '1569657109_JKT010CSLUBCUTSLIVBLUE_1.JPG', '1569657109_JKT010CSLUBCUTSLIVBLUE_3.JPG', '1569657109_JKT010CSLUBCUTSLIVBLUE_5.JPG', 'Kurti'),
(15, 11, 17, 8, 'Yellow Cotton Slab Kurti', 'Women', 'S,M,L,XL,XXL', 285, 50, 'Slab Cotton Kurti', '1569657226_JKT010CSLUBCUTSLIVORANGE_1.JPG', '1569657226_JKT010CSLUBCUTSLIVORANGE_3.JPG', '1569657226_JKT010CSLUBCUTSLIVORANGE_5.JPG', 'Kurti'),
(16, 12, 17, 8, 'Light Yellow Cotton Kurti', 'Women', 'S,M,L,XL,XXL', 285, 50, 'Cotton Slab Kurti', '1569657333_JKT010CSLUBCUTSLIVYELOW_1.JPG', '1569657333_JKT010CSLUBCUTSLIVYELOW_2.JPG', '1569657333_JKT010CSLUBCUTSLIVYELOW_5.JPG', 'Kurti'),
(17, 13, 17, 8, 'Pink Cotton Slab Kurti', 'Women', 'S,M,L,XL,XXL', 285, 50, 'Slab Cotton Kurti', '1569657468_JKT011CSLUBMASTERD_1.JPG', '1569657468_JKT011CSLUBMASTERD_4.JPG', '1569657468_JKT011CSLUBMASTERD_5.JPG', 'Kurti'),
(18, 14, 17, 8, 'White Navy Blue Kurti', 'Women', 'S,M,L,XL,XXL', 195, 50, 'Navy Blue Kurti', '1569657677_JKT001NEVYBLUE_2.JPG', '1569657677_JKT001NEVYBLUE_3.JPG', '1569657677_JKT001NEVYBLUE_4.JPG', 'Kurti'),
(19, 15, 17, 8, 'Red White Kurti', 'Women', 'S,M,L,XL,XXL', 195, 50, 'Kurti', '1569657786_JKT001WHITE_1a.JPG', '1569657786_JKT001WHITE_3a.JPG', '1569657786_JKT001WHITE_4a.JPG', 'Kurti'),
(20, 16, 17, 8, 'Multi Color Kurti', 'Women', 'S,M,L,XL,XXL', 195, 50, 'Multi Color Kurti', '1569657884_JKT002REDZIGJAG_1.JPG', '1569657884_JKT002REDZIGJAG_2.JPG', '1569657884_JKT002REDZIGJAG_5.JPG', 'kurti'),
(21, 17, 17, 8, 'Blue Linen Kurti', 'Women', 'S,M,L,XL,XXL', 315, 50, 'Linen Kurti', '1569658087_JKT017RAYONBLUE_1.JPG', '1569658087_JKT017RAYONBLUE_2.JPG', '1569658087_JKT017RAYONBLUE_3.JPG', 'Kurti'),
(22, 18, 17, 8, 'Pink Linen Kurti', 'Women', 'S,M,L,XL,XXL', 315, 50, 'Linen Kurti', '1569658199_JKT017RAYONPINK_1.JPG', '1569658199_JKT017RAYONPINK_2.JPG', '1569658199_JKT017RAYONPINK_6.JPG', 'kurti'),
(23, 19, 17, 8, 'Blue Reyon Kurti', 'Women', 'S,M,L,XL,XXL', 260, 50, 'Reyon Kurti', '1569658974_JKT014RAYONSOLIDNEVY_2.JPG', '1569658974_JKT014RAYONSOLIDNEVY_3.JPG', '1569658974_JKT014RAYONSOLIDNEVY_5.JPG', 'Kurti'),
(24, 20, 17, 8, 'Red Reyon Kurti', 'Women', 'S,M,L,XL,XXL', 260, 50, 'Reyon Kurti', '1569659083_JKT014RAYONSOLIDPINK_6 - Copy.JPG', '1569659083_JKT014RAYONSOLIDPINK_2.JPG', '1569659083_JKT014RAYONSOLIDPINK_4.JPG', 'Kurti'),
(25, 21, 17, 8, 'Dark Blue Reyon Kurti', 'Women', 'S,M,L,XL,XXL', 260, 50, 'Reyon Kurti', '1569659205_JKT014RAYONSOLIDROYALBLUE_1.JPG', '1569659205_JKT014RAYONSOLIDROYALBLUE_6.JPG', '1569659205_JKT014RAYONSOLIDROYALBLUE_5.JPG', 'Kurti'),
(26, 22, 17, 8, 'Striped Reyon Kurti', 'Women', 'S,M,L,XL,XXL', 290, 50, 'Reyon Kurti', '1569660640_JKT013RAYONPRINT_1.JPG', '1569660640_JKT013RAYONPRINT_2.JPG', '1569660640_JKT013RAYONPRINT_4.JPG', 'Kurti'),
(27, 23, 17, 8, 'Plain Blue Reyon Kurti', 'Women', 'S,M,L,XL,XXL', 260, 50, 'Reyon Kurti', '1569660746_JKT014RAYONSOLIDGREY_2.JPG', '1569660746_JKT014RAYONSOLIDGREY_3.JPG', '1569660746_JKT014RAYONSOLIDGREY_5.JPG', 'Kurti'),
(28, 24, 17, 8, 'Black Reyon Kurti', 'Women', 'S,X,L,XL,XXL', 290, 50, 'Reyon Kurti', '1569660843_JKT015RAYONNEVYRASGUL_1.JPG', '1569660843_JKT015RAYONNEVYRASGUL_3.JPG', '1569660843_JKT015RAYONNEVYRASGUL_5.JPG', 'Kurti'),
(29, 25, 17, 8, 'Yellow Reyon Kurti', 'Women', 'S,M,L,XL,XXL', 375, 50, 'Reyon Kurti', '1569661016_JKT016RAYONYELOW_3.JPG', '1569661016_JKT016RAYONYELOW_4.JPG', '1569661016_JKT016RAYONYELOW_6.JPG', 'Kurti'),
(30, 26, 17, 8, 'Black white Circle Kurti', 'Women', 'S,M,L,XL,XXL', 585, 50, 'Kurti', '1569661167_JKT018BLKROULDGOLDPRINTSET_2.JPG', '1569661167_JKT018BLKROULDGOLDPRINTSET_4.JPG', '1569661167_JKT018BLKROULDGOLDPRINTSET_5.JPG', 'Kurti'),
(31, 27, 16, 8, 'White Top', 'Women', 'S,M,L,XL,XXL', 90, 50, 'Top', '1569663749_BMT-01 (1).JPG', '1569663749_BMT-01 (2).JPG', '1569663749_BMT-01 (4).JPG', 'Top'),
(32, 28, 16, 8, 'White Top', 'Women', 'S,M,L,XL,XXL', 90, 50, 'Top', '1569663872_BMT-02 (3).JPG', '1569663872_BMT-01.JPG', '1569663872_BMT-02 (5).JPG', 'Top'),
(33, 29, 16, 8, 'Blue Striped Top', 'Women', 'S,M,L,XL,XXL', 90, 50, 'Stripped Top', '1569664008_BMT-04 (3).JPG', '1569664008_BMT-04 (6).JPG', '1569664008_BMT-04 (1).JPG', 'Top'),
(34, 30, 16, 8, 'Black Firozi Top', 'Women', 'S,M,L,XL,XXL', 90, 50, 'Top', '1569664315_BMT-05 (3).JPG', '1569664315_BMT-05 (5).JPG', '1569664315_BMT-05 (6).JPG', 'Top'),
(35, 31, 16, 8, 'White Blue Top', 'Women', 'S,M,L,XL,XXL', 90, 50, 'Top', '1569664402_BMT-06 (3).JPG', '1569664402_BMT-06 (5).JPG', '1569664402_BMT-06 (1).JPG', 'Top'),
(36, 32, 16, 8, 'Multi Color Top', 'Women', 'S,M,L,XL,XXL', 90, 50, 'Top', '1569664493_BMT-07 (4).JPG', '1569664493_BMT-07 (5).JPG', '1569664493_BMT-07 (2).JPG', 'Top'),
(37, 33, 16, 8, 'Flower Black Top', 'Women', 'S,M,L,XL,XXL', 90, 50, 'Top', '1569664579_BMT-08 (1).JPG', '1569664579_BMT-08 (3).JPG', '1569664579_BMT-08 (4).JPG', 'Top'),
(38, 34, 16, 8, 'White Blue Striped Top', 'Women', 'S,M,L,XL,XXL', 90, 50, 'Striped Top', '1569664661_KTOPTP01Blue1 - Copy.JPG', '1569664661_KTOPTP01Blue3.JPG', '1569664661_KTOPTP01Blue4.JPG', 'Top'),
(39, 35, 16, 8, 'Red White Striped Top', 'Women', 'S,M,L,XL,XXL', 90, 50, 'Striped Top', '1569664746_KTOPTP02red1.JPG', '1569664746_KTOPTP02red3.JPG', '1569664746_KTOPTP02red4.JPG', 'Top'),
(40, 36, 16, 8, 'Multi Color Striped Top', 'Women', 'S,M,L,XL,XXL', 90, 50, 'Striped Top', '1569664853_KTOPTP03multi1.jpg', '1569664853_KTOPTP03multi2.jpg', '1569664853_KTOPTP03multi4.jpg', 'Top'),
(41, 37, 16, 8, 'Plain Elephant Top', 'Women', 'S,M,L,XL,XXL', 130, 50, 'Top', '1569666047_JFT034plainelephanttop_1a.jpg', '1569666047_JFT034plainelephanttop_3a.jpg', '1569666047_JFT034plainelephanttop_4a.jpg', 'Top'),
(42, 38, 16, 8, 'Hand Free Blue Top', 'Women', 'S,M,L,XL,XXL', 130, 50, 'Hand Free Top', '1569666147_JFT039-01handfrilblue_1.JPG', '1569666147_JFT039-01handfrilblue_5.JPG', '1569666147_JFT039-01handfrilblue_2.JPG', 'Hand Free Top'),
(43, 39, 16, 8, 'Hand Free Red Top', 'Women', 'S,M,L,XL,XXL', 130, 50, 'Hand Free Top', '1569666340_JFT039-02handfrilRe_1.JPG', '1569666340_JFT039-02handfrilRe_2.JPG', '1569666340_JFT039-02handfrilRe_5.JPG', 'Hand Free Top'),
(44, 40, 16, 8, 'Red Rose Hand Free ', 'Women', 'S,M,L,XL,XXL', 130, 50, 'Hand Free', '1569666440_JFT039-03handfrilredros_1.JPG', '1569666440_JFT039-03handfrilredros_4.JPG', '1569666440_JFT039-03handfrilredros_2.JPG', 'Hand Free'),
(45, 41, 16, 8, 'White Black Hand Free', 'Women', 'S,M,L,XL,XXL', 130, 50, 'Hand Free', '1569666529_JFT039-04handfrilwhit_1.JPG', '1569666529_JFT039-04handfrilwhit_3.JPG', '1569666529_JFT039-04handfrilwhit_4.JPG', 'Hand Free'),
(46, 42, 16, 8, 'Multi Color Hand Free', 'Women', 'S,M,L,XL,XXL', 130, 50, 'Hand Free', '1569666602_TNT010-Mulit (1).jpg', '1569666602_TNT010-Mulit (2).jpg', '1569666602_TNT010-Mulit (5).jpg', 'Hand Free'),
(47, 43, 16, 8, 'Light Green Round Top', 'Women', 'S,M,L,XL,XXL', 150, 50, 'Top', '1569681098_JFT041LIGHTGREENROUNDFRIL_1.JPG', '1569681098_JFT041LIGHTGREENROUNDFRIL_4.JPG', '1569681098_JFT041LIGHTGREENROUNDFRIL_4.JPG', 'Top'),
(48, 44, 16, 8, 'Pink Round Top', 'Women', 'S,M,L,XL,XXL', 150, 50, 'Top', '1569681195_JFT041PEACHROUNDFRIL_1.JPG', '1569681195_JFT041PEACHROUNDFRIL_2.JPG', '1569681195_JFT041PEACHROUNDFRIL_4.JPG', 'Top'),
(49, 45, 16, 8, 'Black Tip Top', 'Women', 'S,M,L,XL,XXL', 155, 50, 'Tip Top', '1569681592_Ktiptopblack-1.jpg', '1569681592_Ktiptopblack-3.jpg', '1569681592_Ktiptopblack-4.jpg', 'Top'),
(50, 46, 16, 8, 'Blue Tip Top', 'Women', 'S,M,L,XL,XXL', 155, 50, 'Tip Top', '1569681707_Ktiptopoblue-1 - Copy.jpg', '1569681707_Ktiptopoblue-4 - Copy.jpg', '1569681707_Ktiptopoblue-2.jpg', 'Top'),
(51, 47, 16, 8, 'Orange Tip Top', 'Women', 'S,M,L,XL,XXL', 155, 50, 'Tip Top', '1569681804_Ktiptoporg-1 - Copy.jpg', '1569681804_Ktiptoporg-3.jpg', '1569681804_Ktiptoporg-4 - Copy.jpg', 'Top'),
(52, 48, 16, 8, 'White Tip Top', 'Women', 'S,M,L,XL,XXL', 155, 50, 'Tip Top', '1569681875_Ktiptopowht-1 - Copy.jpg', '1569681875_Ktiptopowht-2.jpg', '1569681875_Ktiptopowht-4 - Copy.jpg', 'Top'),
(53, 49, 16, 8, 'Red Tip Top', 'Women', 'S,M,L,XL,XXL', 155, 50, 'Tip Top', '1569681973_KtiptopRed-1.jpeg', '1569681973_KtiptopRed-3.jpg', '1569681973_KtiptopRed-1.jpeg', 'Top'),
(54, 50, 16, 8, 'Cut Sleeve Black Top', 'Women', 'S,M,L,XL,XXL', 165, 50, 'Cut Sleeve Top', '1569682137_JFT-04BLACKCUTSLIV_1.JPG', '1569682137_JFT-04BLACKCUTSLIV_3.JPG', '1569682137_JFT-04BLACKCUTSLIV_4.JPG', 'Top'),
(55, 51, 16, 8, 'Cut Sleeve Blue Top', 'Women', 'S,M,L,XL,XXL', 165, 50, 'Top', '1569682205_JFT-04BLUECUTSLIV-1 - Copy.JPG', '1569682205_JFT-04BLUECUTSLIV-2.JPG', '1569682205_JFT-04BLUECUTSLIV-4.JPG', 'Cut Sleeve'),
(56, 52, 16, 8, 'Cut Sleeve Yellow Top', 'Women', 'S,M,L,XL,XXL', 165, 50, 'Cut Sleeve', '1569682332_JFT-04YELOWCUTSLIV_1 - Copy.JPG', '1569682332_JFT-04YELOWCUTSLIV_2.JPG', '1569682332_JFT-04YELOWCUTSLIV_4.JPG', 'Top'),
(57, 53, 16, 8, 'Flower Black Yellow Top', 'Women', 'S,M,L,XL,XXL', 165, 50, 'Flower Top', '1569682429_JFT-025BLACK_1.JPG', '1569682429_JFT-025BLACK_2.JPG', '1569682429_JFT-025BLACK_4.JPG', 'Top'),
(58, 54, 16, 8, 'Hand Cut Yellow Top', 'Women', 'S,M,L,XL,XXL', 165, 50, 'Hand Cut Top', '1569682551_JFT-025handcut_1.JPG', '1569682551_JFT-025handcut_2.JPG', '1569682551_JFT-025handcut_4 - Copy.JPG', 'Top'),
(59, 55, 16, 8, 'Half Sleeve Yellow Top', 'Women', 'S,M,L,XL,XXL', 165, 50, 'Half Sleeve Top', '1569682642_JFT-027YELOW_1.JPG', '1569682642_JFT-027YELOW_3.JPG', '1569682642_JFT-027YELOW_4.JPG', 'Half Sleeve'),
(60, 56, 16, 8, 'Full Sleeve Red Rose Top', 'Women', 'S,M,L,XL,XXL', 165, 50, 'Fell Sleeve Top', '1569682730_JFT040Redros1.JPG', '1569682730_JFT040Redros2.JPG', '1569682730_JFT040Redros4.JPG', 'Full Sleeve'),
(61, 57, 16, 8, 'Blue Print Flower Top', 'Women', 'S,M,L,XL,XXL', 165, 50, 'Flower Top', '1569682827_JFT-045BLUEPRINT_1.JPG', '1569682827_JFT-045BLUEPRINT_3.JPG', '1569682827_JFT-045BLUEPRINT_2.JPG', 'Flower Top'),
(62, 58, 16, 8, 'Cut Sleeve Maroon Top', 'Women', 'S,M,L,XL,XXL', 165, 50, 'Cut Sleeve Top', '1569682920_JFT-045MAROONPRINT_1.JPG', '1569682920_JFT-045MAROONPRINT_2.JPG', '1569682920_JFT-045MAROONPRINT_4.JPG', 'Cut Sleeve'),
(63, 59, 16, 8, 'Cut Sleeve Orange Printed Top', 'Women', 'S,M,L,XL,XXL', 165, 50, 'Cut Sleeve Printed Top', '1569683036_JFT-045ORANGEPRINT_1.JPG', '1569683036_JFT-045ORANGEPRINT_3.JPG', '1569683036_JFT-045ORANGEPRINT_2.JPG', 'Printed Top'),
(64, 60, 16, 8, 'Stripped Blue Top', 'Women', 'S,M,L,XL,XXL', 165, 50, 'Stripped Top', '1569683129_TRF019-Blue (1).jpg', '1569683129_TRF019-Blue (4).jpg', '1569683129_TRF019-Blue (6).jpg', 'Stripped Top'),
(65, 61, 16, 8, 'Black Top', 'Women', 'S,M,L,XL,XXL', 175, 50, 'Top', '1569684024_3aastinblack_1.jpg', '1569684024_3aastinblack_2.jpg', '1569684024_3aastinblack_4.jpg', 'Top'),
(66, 62, 16, 8, 'Orange Top', 'Women', 'S,M,L,XL,XXL', 175, 50, 'Top', '1569684113_3aastinpeach_1.jpg', '1569684113_3aastinpeach_2.jpg', '1569684113_3aastinpeach_4.jpg', 'Top'),
(67, 63, 16, 8, 'White Top', 'Women', 'S,M,L,XL,XXL', 175, 50, 'Top', '1569684177_3aastinwhite_1.jpg', '1569684177_3aastinwhite_2.jpg', '1569684177_3aastinwhite_4.jpg', 'Top'),
(68, 64, 16, 8, 'Crop Black Top', 'Women', 'S,M,L,XL,XXL', 175, 50, 'Crop Top, Cotton', '1569684364_ccroptopblack_1.JPG', '1569684364_ccroptopblack_4.JPG', '1569684364_ccroptopblack_2.JPG', 'Crop Top'),
(69, 65, 16, 8, 'Crop Blue Cotton Top', 'Women', 'S,M,L,XL,XXL', 175, 50, 'Crop Top, Cotton', '1569684454_ccroptopblue_1.JPG', '1569684454_ccroptopblue_5.JPG', '1569684454_ccroptopblue_2.JPG', 'Crop Top'),
(70, 66, 16, 8, 'Crop Pink Cotton Top', 'Women', 'S,M,L,XL,XXL', 175, 50, 'Crop Top,Cotton', '1569684570_ccroptoppeach_1.JPG', '1569684570_ccroptoppeach_4.JPG', '1569684570_ccroptoppeach_2.JPG', 'Crop Top'),
(71, 67, 16, 8, 'Crop White Cotton Top ', 'Women', 'S,M,L,XL,XXL', 175, 50, 'Crop Top', '1569684667_ccroptopwhite_1.JPG', '1569684667_ccroptopwhite_3.JPG', '1569684667_ccroptopwhite_2 - Copy.JPG', 'Crop Top'),
(72, 68, 16, 8, 'Cut Sleeve, Half Blue Top', 'Women', 'S,M,L,XL,XXL', 175, 50, 'Cut Sleeve Top', '1569684820_KA07BLUE_1.jpeg', '1569684820_KA07BLUE_2.jpeg', '1569684820_KA07BLUE_3 - Copy.jpeg', 'Cut Sleeve'),
(73, 69, 16, 8, 'Cut Sleeve , Half Red Top', 'Women', 'S,M,L,XL,XXL', 175, 50, 'Cut Sleeve Top', '1569684896_KA07RED_1.jpg', '1569684896_KA07RED_2.jpg', '1569684896_KA07RED_7.jpg', 'Cut Sleeve'),
(74, 70, 16, 8, 'Half Sleeve, Royal Blue Top', 'Women', 'S,M,L,XL,XXL', 195, 50, 'Half Sleeve Top', '1569685006_JFT-02ROYALBLUE_1.JPG', '1569685006_JFT-02ROYALBLUE_3.JPG', '1569685006_JFT-02ROYALBLUE_4.JPG', 'Half Sleeve'),
(75, 71, 16, 8, 'Half Sleeve, Royal Yellow Top', 'Women', 'S,M,L,XL,XXL', 195, 50, 'Half Sleeve Top', '1569685098_JTOP02MASTER_1.JPG', '1569685098_JTOP02MASTER_3.JPG', '1569685098_JTOP02MASTER_4.JPG', 'Half Sleeve'),
(76, 72, 16, 8, 'Half Sleeve, Flower Top', 'Women', 'S,M,L,XL,XXL', 199, 50, 'Half Sleeve Top', '1569685221_TNT012 (2).jpg', '1569685221_TNT012 (3).jpg', '1569685221_TNT012 (5).jpg', 'Half Sleeve'),
(78, 73, 16, 8, 'Hand Free, Grey Top', 'Women', 'S,M,L,XL,XXL', 215, 50, 'Hand Free', '1569685441_TNT09Grey (1).jpg', '1569685441_TNT09Grey (2).jpg', '1569685441_TNT09Grey (5).jpg', 'Hand Free'),
(79, 74, 14, 8, 'Crepe Black White Palazzo', 'Women', 'M,XL,XXL', 165, 50, 'Palazzo', '1569778425_pz001black-1.jpg', '1569778425_pz001black-3.jpg', '1569778425_pz001black-4.jpg', 'Palazzo'),
(80, 75, 14, 8, 'Crepe Red White Stripped Palazzo', 'Women', 'M,XL,XXL', 165, 50, 'Stripped Palazzo', '1569778570_PZ002RED-1.jpg', '1569778570_PZ002RED-3.jpg', '1569778570_PZ002RED-1.jpg', 'Stripped Palazzo'),
(81, 76, 14, 8, 'Crepe Blue Palazzo', 'Women', 'M,XL,XXL', 165, 50, 'Palazzo', '1569778640_PZ003WHTBLU-1.jpg', '1569778640_PZ003WHTBLU-3.jpg', '1569778640_PZ003WHTBLU-4.jpg', 'Palazzo'),
(82, 77, 14, 8, 'Crepe White Palazzo', 'Women', 'M,XL,XXL', 165, 50, 'Palazzo', '1569778733_PZ005WHT-1 - Copy.jpg', '1569778733_PZ005WHT-2.jpg', '1569778733_PZ005WHT-3.jpg', 'Palazzo'),
(83, 78, 14, 8, 'Crepe white Dot Palazzo', 'Women', 'M,XL,XXL', 165, 50, 'Dot Palazzo', '1569778804_PZ006WHTDOT-1.jpg', '1569778804_PZ006WHTDOT-2.JPG', '1569778804_PZ006WHTDOT-3.JPG', 'Dot Plazzo'),
(84, 79, 14, 8, 'Crepe Blue White Dotted Palazzo', 'Women', 'M,XL,XXL', 165, 50, 'Dotted Palazzo', '1569835594_PZ007BLU-2.jpg', '1569835594_PZ007BLU-3 - Copy.jpg', '1569835594_PZ007BLU-4.jpg', 'Dotted Palazzo'),
(85, 80, 14, 8, 'Crepe Orange Palazzo', 'Women', 'M,XL,XXL', 165, 50, 'Crepe Palazzo', '1569835907_PZ008ORG-1.jpg', '1569835907_PZ008ORG-3.jpg', '1569835907_PZ008ORG-4.jpg', 'Crepe Palazzo'),
(86, 81, 14, 8, 'Crepe Black White Palazzo', 'Women', 'M,XL,XXL', 165, 50, 'Palazzo', '1569836371_PZ009BLKWHT-1.JPG', '1569836371_PZ009BLKWHT-2.JPG', '1569836371_PZ009BLKWHT-6.JPG', 'Palazzo'),
(87, 82, 14, 8, 'Crepe Ice Blue Palazzo', 'Women', 'M,XL,XXL', 165, 50, 'Palazzo', '1569836579_PZ010ICEBLU-1.jpg', '1569836579_PZ010ICEBLU-2.jpg', '1569836579_PZ010ICEBLU-3.jpg', 'Palazzo'),
(88, 83, 14, 8, 'Crepe Multi Color Palazzo', 'Women', 'M,XL,XXL', 165, 50, 'Crepe Palazzo', '1569836716_PZ0011multicol-1.jpg', '1569836716_PZ0011multicol-4.jpg', '1569836716_PZ0011multicol-6.jpg', 'Crepe Palazzo'),
(89, 84, 15, 9, 'Cotton Black Pant', 'Women', 'M,XL,XXL', 275, 50, 'Cotton Pant', '1569999864_cpant101black_1.JPG', '1569999864_cpant101black_2.JPG', '1569999864_cpant101black_3.JPG', 'Cotton Pant'),
(90, 85, 15, 9, 'Cotton Grey Pant', 'Women', 'M,XL,XXL', 275, 50, 'Cotton Pant', '1569999977_cpant102grey_2.JPG', '1569999977_cpant102grey_3.JPG', '1569999977_cpant102grey_4.JPG', 'Cotton Pant'),
(91, 86, 15, 9, 'Cotton Red Pant', 'Women', 'M,XL,XXL', 275, 50, 'Cotton Pant', '1570000098_cpant104gajri_1.JPG', '1570000098_cpant104gajri_3.JPG', '1570000098_cpant104gajri_4.JPG', 'Cotton Pant'),
(92, 87, 15, 9, 'Sky Blue Cotton Pant', 'Women', 'M,XL,XXL', 275, 50, 'Cotton Pant', '1570000166_cpant105skyblue_1.JPG', '1570000166_cpant105skyblue_3.JPG', '1570000166_cpant105skyblue_4.JPG', 'Cotton Pant'),
(93, 88, 15, 9, 'White Cotton Pant', 'Women', 'M,XL,XXL', 275, 50, 'Cotton Pant', '1570000249_cpant103white_1a.JPG', '1570000249_cpant103white_3a.JPG', '1570000249_cpant103white_4a.JPG', 'Cotton Pant'),
(94, 89, 14, 8, 'White Stripped Crepe Palazzo', 'Women', 'M,XL,XXL', 165, 50, 'Stripped Palazzo', '1570000584_PZ012white_1.jpg', '1570000584_PZ012white_2.jpg', '1570000584_PZ012white_3.jpg', 'Crepe Palazzo'),
(96, 90, 14, 8, 'Black Crepe Palazzo', 'Women', 'M,XL,XXL', 165, 50, 'Crepe Palazzo', '1570000673_pz013blac1 - Copy.JPG', '1570000673_pz013blac3.JPG', '1570000673_pz013blac4.JPG', 'Crepe Palazzo'),
(97, 91, 15, 9, 'Maroon Crepe Palazzo', 'Women', 'M,XL,XXL', 165, 50, 'Crepe Palazzo', '1570000784_pz014maroon1.JPG', '1570000784_pz014maroon5.JPG', '1570000784_pz014maroon6.JPG', 'Crepe Palazzo'),
(98, 92, 14, 8, 'Multi Color Crepe Palazzo', 'Women', 'M,XL,XXL', 165, 50, 'Crepe Palazzo', '1570000873_PZ059crepmultibox1.jpg', '1570000873_PZ059crepmultibox3.jpg', '1570000873_PZ059crepmultibox4.jpg', 'Crepe Palazzo'),
(99, 93, 14, 8, 'White Blue Dot Crepe Palazzo', 'Women', 'M,XL,XXL', 165, 50, 'Crepe Dot Plazzo', '1570001068_PZ060crepwhitestar1.jpg', '1570001068_PZ060crepwhitestar2.jpg', '1570001068_PZ060crepwhitestar4.jpg', 'Crepe Palazzo'),
(100, 93, 14, 8, 'Multi Color Burfi Crepe Palazzo', 'Women', 'M,XL,XXL', 165, 50, 'Multi Color Palazzo', '1570001230_PZ061crepmultiburfi1 - Copy.jpg', '1570001230_PZ061crepmultiburfi1.jpg', '1570001230_PZ061crepmultiburfi2 - Copy.jpg', 'Multi Color Palazzo'),
(101, 94, 14, 8, 'Multi Print Crepe Palazzo', 'Women', 'M,XL,XXL', 165, 50, 'Multi Print Palazzo', '1570001403_PZ063MULTIPRINT1 - Copy.JPG', '1570001403_PZ063MULTIPRINT2.JPG', '1570001403_PZ063MULTIPRINT4.JPG', 'Multi Color Print'),
(102, 95, 14, 8, 'Multi Color Palazzo ', 'Women', 'M,X,XXL', 165, 50, 'Multi Color', '1570001866_PZ064MULTI1 - Copy.JPG', '1570001866_PZ064MULTI3.JPG', '1570001866_PZ064MULTI4.JPG', 'Multi Color'),
(103, 96, 14, 8, 'Black Multi Color Crepe Palazzo', 'Women', 'M,XL,XXL', 165, 50, 'Multi Color', '1570001986_PZ065BLACKMULTI1 - Copy.JPG', '1570001986_PZ065BLACKMULTI3.JPG', '1570001986_PZ065BLACKMULTI4.jpg', 'Multi Color'),
(104, 97, 14, 8, 'Multi Color Crepe ', 'Women', 'M,XL,XXL', 165, 50, 'Multi Color Palazzo', '1570002095_PZ066MULTI1.JPG', '1570002095_PZ066MULTI2.JPG', '1570002095_PZ066MULTI3.JPG', 'Multi Color'),
(105, 98, 14, 8, 'Multi Color Leaf Palazzo', 'Women', 'M,XL,XXL', 165, 50, 'Multi Color', '1570002272_PZ067_2.JPG', '1570002272_PZ067_3.JPG', '1570002272_PZ067_4.JPG', 'Multi Color Palazzo'),
(106, 99, 14, 8, 'Black White Flower Crepe Palazzo', 'Women', 'M,XL,XXL', 165, 50, 'Flower crepe Palazzo', '1570002951_PZ068BLACK_1.jpg', '1570002951_PZ068BLACK_2.jpg', '1570002951_PZ068BLACK_3.jpg', 'Flower Palazzo'),
(107, 100, 14, 8, 'Blue Stripped Crepe Palazzo', 'Women', 'M,XL,XXL', 165, 50, 'Stripped Palazzo', '1570003196_PZ070BLUESTRIP_1 - Copy.jpg', '1570003196_PZ070BLUESTRIP_2.jpg', '1570003196_PZ070BLUESTRIP_3.jpg', 'Stripped Palazzo'),
(108, 101, 14, 8, 'Blue Flower Crepe Palazzo', 'Women', 'M,XL,XXL', 165, 50, 'Flower Palazzo', '1570003292_PZ071BLUEFLOWER_1.jpg', '1570003292_PZ071BLUEFLOWER_2.jpg', '1570003292_PZ071BLUEFLOWER_3 - Copy.jpg', 'Flower Palazzo'),
(109, 102, 14, 8, 'Elephant Print Crepe palazzo', 'Women', 'M,XL,XXL', 165, 50, 'Elephant Print palazzo', '1570003523_PZ072ELEPHANT_1.jpg', '1570003523_PZ072ELEPHANT_2.jpg', '1570003523_PZ072ELEPHANT_3.jpg', 'Elephant Print Palazzo'),
(110, 103, 14, 8, 'Orange Yellow Flower Print Palazzo', 'Women', 'M,XL,XXL', 165, 50, 'Flower Print Palazzo', '1570003650_PZ073YELOW_1 - Copy.jpg', '1570003650_PZ073YELOW_1.jpg', '1570003650_PZ073YELOW_3 - Copy.jpg', 'Flower Print Palazzo'),
(111, 104, 14, 8, 'Black Flower Crepe Palazzo', 'Women', 'M,XL,XXL', 165, 50, 'Flower Print palazzo', '1570004191_PZ074BLACKFLOWER_1.jpg', '1570004191_PZ074BLACKFLOWER_2.jpg', '1570004191_PZ074BLACKFLOWER_3.jpg', 'Flower Print'),
(112, 105, 14, 8, 'Multi Color Crepe palazzo ', 'Women', 'M,XL,XXL', 165, 50, 'Multi Color palazzo', '1570004295_PZJ021MULTICOLOR_1.jpg', '1570004295_PZJ021MULTICOLOR_2.jpg', '1570004295_PZJ021MULTICOLOR_4.jpg', 'Multi Color palazzo'),
(113, 106, 14, 8, 'Multi Zig Zag Crepe Palazzo', 'Women', 'M,XL,XXL', 165, 50, 'Zig Zag Crepe Palazzo', '1570004431_PZJ022MULTIZIGZAG_1.jpg', '1570004431_PZJ022MULTIZIGZAG_2.jpg', '1570004431_PZJ022MULTIZIGZAG_3.jpg', 'Zig Zag Palazzo'),
(114, 107, 14, 8, 'Raffar Crepe Black Palazzo', 'Women', 'M,XL,XXL', 265, 50, 'Raffar Crepe Palazzo', '1570004562_PZR1021BLACK-1.jpg', '1570004562_PZR1021BLACK-2.jpg', '1570004562_PZR1021BLACK-3.jpg', 'Raffar Crepe Palazzo'),
(115, 108, 14, 8, 'Raffar Crepe Yellow Palazzo', 'Women', 'M,XL,XXL', 265, 50, 'Raffar Crepe Palazzo', '1570004666_PZR1022YELOW-1.jpg', '1570004666_PZR1022YELOW-2.jpg', '1570004666_PZR1022YELOW-3.jpg', 'Raffar Crepe Palazzo'),
(116, 109, 14, 8, 'Raffar Crepe Royal Blue Palazzo', 'Women', 'M,XL,XXL', 265, 50, 'Raffar Crepe Blue Palazzo', '1570004740_PZR1023ROYALBLE-1.jpg', '1570004740_PZR1023ROYALBLE-3.jpg', '1570004740_PZR1023ROYALBLE-4.jpg', 'Raffar Crepe Blue Palazzo'),
(118, 110, 14, 8, 'Raffar Crepe MaroonPalazzo', 'Women', 'M,XL,XXL', 265, 50, 'Raffar Crepe MaroonPalazzo', '1570004813_PZR1024MAROON-1.jpg', '1570004813_PZR1024MAROON-2.jpg', '1570004813_PZR1024MAROON-4.jpg', 'Raffar Crepe Palazzo'),
(119, 111, 14, 8, 'Raffar Crepe GreyPalazzo', 'Women', 'M,XL,XXL', 265, 50, 'Raffar Crepe Palazzo', '1570004871_PZR1025GREY_1.jpg', '1570004871_PZR1025GREY_2.jpg', '1570004871_PZR1025GREY_3.jpg', 'Raffar Crepe Palazzo'),
(120, 112, 14, 8, 'Reyon Plain Navy Blue Palazzo', 'Women', 'M,XL,XXL', 175, 50, 'Reyon Plain Navy Blue Palazzo', '1570005013_PZ033SRAYONPLAINNEVYBLUE1.JPG', '1570005013_PZ033SRAYONPLAINNEVYBLUE3.jpg', '1570005013_PZ033SRAYONPLAINNEVYBLUE4.JPG', 'Reyon Palazzo'),
(121, 113, 14, 8, 'Reyon Plain Maroon Palazzo', 'Women', 'M,XL,XXL', 175, 50, 'Reyon Plain Maroon Palazzo', '1570005076_PZ034SRAYONPLAINMAROON1.jpg', '1570005076_PZ034SRAYONPLAINMAROON2.JPG', '1570005076_PZ034SRAYONPLAINMAROON4.JPG', 'Reyon Plain Maroon Palazzo'),
(122, 114, 14, 8, 'Reyon Plain Royal Blue Palazzo', 'Women', 'M,XL,XXL', 175, 50, 'Reyon Plain Navy Royal Blue Palazzo', '1570005170_PZ035SRAYONPLAINROYALBLUE1.JPG', '1570005170_PZ035SRAYONPLAINROYALBLUE3.JPG', '1570005170_PZ035SRAYONPLAINROYALBLUE4.JPG', 'Reyon Palazzo'),
(123, 115, 14, 8, 'Reyon Plain Pink Palazzo', 'Women', 'M,XL,XXL', 175, 50, 'Reyon Plain Pink Palazzo', '1570005223_PZ036SRAYONPLAINPINK1.JPG', '1570005223_PZ036SRAYONPLAINPINK3.jpg', '1570005223_PZ036SRAYONPLAINPINK4.JPG', 'Reyon Palazzo'),
(124, 116, 14, 8, 'Reyon Plain White Palazzo', 'Women', 'M,XL,XXL', 175, 50, 'Reyon Plain White Palazzo', '1570005279_PZ037SRAYONPLAINWHITE3.jpg', '1570005279_PZ037SRAYONPLAINWHITE4.JPG', '1570005279_PZ037SRAYONPLAINWHITE3.jpg', 'Reyon Palazzo'),
(125, 117, 14, 8, 'Reyon Red Palazzo', 'Women', 'M,XL,XXL', 175, 50, 'Reyon Palazzo', '1570034148_PZ038B7SRAYONPLAINORG4.JPG', '1570034148_PZ038BRAYONPLAINORG1.JPG', '1570034148_PZ038BRAYONPLAINORG2.JPG', 'Reyon Palazzo'),
(126, 118, 14, 8, 'Reyon Dark Pink Plain Palazzo', 'Women', 'M,XL,XXL', 175, 50, 'Reyon Dark Palazzo', '1570035182_PZ039BRAYONPLAINDARKPINK1.JPG', '1570035182_PZ039BRAYONPLAINDARKPINK3.JPG', '1570035182_PZ039BRAYONPLAINDARKPINK4.JPG', 'Reyon Palazzo'),
(127, 119, 14, 8, 'Reyon Navy Blue Palazzo', 'Women', 'M,XL,XXL', 175, 50, 'Reyon Palazzo', '1570035460_PZ040BRAYONPLAINNEVYBLUE1.JPG', '1570035460_PZ040BRAYONPLAINNEVYBLUE3.JPG', '1570035460_PZ040BRAYONPLAINNEVYBLUE4.JPG', 'Reyon Palazzo'),
(128, 120, 14, 8, 'Reyon Black Palazzo', 'Women', 'M,XL,XXL', 175, 50, 'Reyon Palazzo', '1570035863_PZ041BRAYONPLAINBLACK1.jpg', '1570035863_PZ041BRAYONPLAINBLACK2.jpg', '1570035863_PZ041BRAYONPLAINBLACK4.JPG', 'Reyon Palazzo'),
(129, 121, 14, 8, 'Reyon Plain Palazzo', 'Women', 'M,XL,XXL', 175, 50, 'Reyon Palazzo', '1570036240_PZ042BRAYONPLAINMASTERD1.jpg', '1570036240_PZ042BRAYONPLAINMASTERD3.JPG', '1570036240_PZ042BRAYONPLAINMASTERD4.JPG', 'Reyon Palazzo'),
(130, 122, 14, 8, 'Reyon Plain Greenish Brown Palazzo', 'Women', 'M,XL,XXL', 175, 50, 'Reyon Palazzo', '1570036405_PZ043COTTONHAFFCHEKENMASTERD1.JPG', '1570036405_PZ043COTTONHAFFCHEKENMASTERD2.JPG', '1570036405_PZ043COTTONHAFFCHEKENMASTERD4.JPG', 'Reyon Palazzo'),
(131, 123, 14, 8, 'Reyon Plain Red Palazzo', 'Women', 'M,XL,XXL', 124, 50, 'Reyon Palazzo', '1570036496_PZ045COTTONHAFFCHEKENRED1.JPG', '1570036496_PZ045COTTONHAFFCHEKENRED3.jpg', '1570036496_PZ045COTTONHAFFCHEKENRED4.JPG', 'Reyon Palazzo'),
(132, 124, 14, 8, 'Reyon Plain Blue Palazzo', 'Women', 'M,XL,XXL', 175, 50, 'Reyon Palazzo', '1570036572_PZ044COTTONHAFFCHEKENROYALBLUE1.JPG', '1570036572_PZ044COTTONHAFFCHEKENROYALBLUE3.jpg', '1570036572_PZ044COTTONHAFFCHEKENROYALBLUE4.JPG', 'Reyon Palazzo'),
(133, 125, 14, 8, 'Reyon Plain Black Palazzo', 'Women', 'M,XL,XXL', 175, 50, 'Reyon Palazzo', '1570036648_PZ046COTTONHAFFCHEKENBLACK2.JPG', '1570036648_PZ046COTTONHAFFCHEKENBLACK3.jpg', '1570036648_PZ046COTTONHAFFCHEKENBLACK4.JPG', 'Reyon Palazzo'),
(134, 126, 16, 8, 'White Black Dotted Crepe Palazzo', 'Women', 'S,M,L,XL,XXL', 90, 50, 'Crepe Palazzo', '1570372581_198 (1).jpg', '1570372581_198 (2).jpg', '1570372581_198 (3).jpg', 'Crepe Palazzo'),
(135, 127, 16, 8, 'Pink Flower Crepe Top', 'Women', 'S,M,L,XL,XXL', 90, 50, 'Crepe Top', '1570372691_199 (1).jpg', '1570372691_199 (2).jpg', '1570372691_199 (3).jpg', 'Crepe Top'),
(136, 128, 16, 8, 'Orange Flower Crepe Top', 'Women', 'S,M,L,XL,XXL', 90, 50, 'Crepe Top', '1570372857_200 (1).jpg', '1570372857_200 (2).jpg', '1570372857_200 (3).jpg', 'Crepe Top'),
(137, 129, 16, 8, 'Blue White Line Crepe Top', 'Women', 'S,M,L,XL,XXL', 90, 50, 'Crepe Top', '1570373006_201 (1).jpg', '1570373006_201 (2).jpg', '1570373006_201 (3).jpg', 'Crepe Top'),
(138, 130, 16, 8, 'Red White Flower Crepe Top', 'Women', 'S,M,L,XL,XXL', 90, 50, 'Crepe Top', '1570373143_202 (1).jpg', '1570373143_202 (2).jpg', '1570373143_202 (3).jpg', 'Crepe Top'),
(139, 131, 16, 8, 'Blue Flower Crepe Top', 'Women', 'S,M,L,XL,XXL', 90, 50, 'Crepe Top', '1570373225_207 (1).jpg', '1570373225_207 (2).jpg', '1570373225_207 (3).jpg', 'Crepe Top'),
(140, 132, 16, 8, 'Orange Crepe Top', 'Women', 'S,M,L,XL,XXL', 90, 50, 'Crepe', '1570373350_208 (1).jpg', '1570373350_208 (2).jpg', '1570373350_208 (3).jpg', 'Crepe'),
(142, 133, 16, 8, 'Blue White Flower Crepe Top', 'Women', 'S,M,L,XL,XXL', 90, 50, 'Crepe Top', '1570373448_215 (1).jpg', '1570373448_215 (2).jpg', '1570373448_215 (3).jpg', 'Crepe Top'),
(143, 134, 16, 8, 'Multi Color Stripped Crepe Top', 'Women', 'S,M,L,XL,XXL', 90, 50, 'Crepe Top', '1570373560_216 (1).jpg', '1570373560_216 (2).jpg', '1570373560_216 (3).jpg', 'Crepe Top'),
(144, 135, 16, 8, 'Blue Flower Crepe Top', 'Women', 'S,M,L,XL,XXL', 90, 50, 'Crepe Top', '1570373662_218 (1).jpg', '1570373662_218 (2).jpg', '1570373662_218 (3).jpg', 'Crepe Top'),
(145, 136, 16, 8, 'Blue Flower Printed Crepe Top', 'Women', 'S,M,L,XL,XXL', 90, 50, 'Crepe Top', '1570373756_217 (1).jpg', '1570373756_217 (2).jpg', '1570373756_217 (3).jpg', 'Crepe Top'),
(146, 137, 16, 8, 'Black Crepe Top', 'Women', 'S,M,L,XL,XXL', 90, 50, 'Crepe', '1570373843_219 (1).jpg', '1570373843_219 (2).jpg', '1570373843_219 (3).jpg', 'Crepe Top'),
(147, 138, 16, 8, 'Multi Color Stripped Crepe Top', 'Women', 'S,M,L,XL,XXL', 90, 50, 'Crepe Top', '1570373951_220 (1).jpg', '1570373951_220 (2).jpg', '1570373951_220 (3).jpg', 'Crepe Top'),
(148, 139, 16, 8, 'Maroon Color Crepe Top', 'Women', 'S,M,L,XL,XXL', 90, 50, 'Crepe Top', '1570374030_221 (1).jpg', '1570374030_221 (2).jpg', '1570374030_221 (3).jpg', 'Crepe Top'),
(149, 140, 16, 8, 'White Pink Flower Crepe Top', 'Women', 'S,M,L,XL,XXL', 130, 50, 'Crepe Top', '1570374274_203 (1).jpg', '1570374274_203 (2).jpg', '1570374274_203 (3).jpg', 'Crepe Top'),
(150, 141, 16, 8, 'Flower Printed Crepe Top', 'Women', 'S,M,L,XL,XXL', 130, 50, 'Crepe Top', '1570374381_204 (2).jpg', '1570374381_204 (1).jpg', '1570374381_204 (3).jpg', 'Crepe Top'),
(151, 142, 16, 8, 'Multi Color Flower Printed Crepe Top', 'Women', 'S,M,L,XL,XXL', 130, 50, 'Crepe Top', '1570374738_205 (1).jpg', '1570374738_205 (2).jpg', '1570374738_205 (3).jpg', 'Crepe Top'),
(152, 143, 16, 8, 'Blue White Flower Crepe Top', 'Women', 'S,M,L,XL,XXL', 130, 50, 'Crepe Top', '1570374872_206 (1).jpg', '1570374872_206 (2).jpg', '1570374872_206 (3).jpg', 'Crepe Top'),
(153, 144, 16, 8, 'Black White Crepe Top', 'Women', 'S,M,L,XL,XXL', 130, 50, 'Crepe Top', '1570374960_209 (1).jpg', '1570374960_209 (2).jpg', '1570374960_209 (3).jpg', 'Crepe Top'),
(154, 145, 16, 8, 'Black Red Line Crepe Top', 'Women', 'S,M,L,XL,XXL', 130, 50, 'Crepe Top', '1570375044_210 (1).jpg', '1570375044_210 (2).jpg', '1570375044_210 (3).jpg', 'Crepe Top'),
(155, 146, 16, 8, 'Butterfly Printed Crepe Top', 'Women', 'S,M,L,XL,XXL', 130, 50, 'Crepe Top', '1570375182_211 (1).jpg', '1570375182_211 (2).jpg', '1570375182_211 (3).jpg', 'Crepe Top'),
(156, 147, 16, 8, 'white Flower Printed Crepe Top', 'Women', 'S,M,L,XL,XXL', 130, 50, 'Crepe top', '1570375268_212 (1).jpg', '1570375268_212 (2).jpg', '1570375268_212 (3).jpg', 'Crepe Top'),
(157, 148, 16, 8, 'Black White Dotted Crepe Top', 'Women', 'S,M,L,XL,XXL', 400, 50, 'Crepe Top', '1570375342_213 (1).jpg', '1570375342_213 (2).jpg', '1570375342_213 (3).jpg', 'Crepe Top'),
(158, 149, 16, 8, 'White Flower Printed Crepe Top', 'Women', 'S,M,L,XL,XXL', 400, 50, 'Crepe Top', '1570375446_214 (1).jpg', '1570375446_214 (2).jpg', '1570375446_214 (3).jpg', 'Crepe Top'),
(163, 0, 21, 12, 'Tshirt', 'Women', '', 65, 0, 'Shirt', '1586726653_ab.jpg', '1586726653_ab1.jpg', '1586726653_co.jpg', 'Tshirt');

-- --------------------------------------------------------

--
-- Table structure for table `product_qty`
--

CREATE TABLE `product_qty` (
  `qty_id` int(20) NOT NULL,
  `product_id` int(20) NOT NULL,
  `size` varchar(255) NOT NULL,
  `qty` int(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `product_size`
--

CREATE TABLE `product_size` (
  `size_id` int(10) NOT NULL,
  `product_id` int(20) NOT NULL,
  `product_size` varchar(255) NOT NULL,
  `product_price` int(20) NOT NULL,
  `product_qty` int(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `product_size`
--

INSERT INTO `product_size` (`size_id`, `product_id`, `product_size`, `product_price`, `product_qty`) VALUES
(11, 157, 'S', 500, 18),
(12, 157, 'M', 400, 30),
(13, 157, 'L', 300, 40),
(14, 157, 'XL', 200, 50),
(15, 157, 'XXL', 100, 60),
(16, 158, 'S', 500, 10),
(17, 158, 'M', 400, 50),
(18, 158, 'L', 300, 30),
(19, 158, 'XL', 200, 40),
(20, 158, 'XXL', 100, 50);

-- --------------------------------------------------------

--
-- Table structure for table `returnreason`
--

CREATE TABLE `returnreason` (
  `id` int(20) NOT NULL,
  `reason` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `returnreason`
--

INSERT INTO `returnreason` (`id`, `reason`) VALUES
(1, 'Color Different'),
(2, 'Not Expected Product');

-- --------------------------------------------------------

--
-- Table structure for table `shipping_address`
--

CREATE TABLE `shipping_address` (
  `SID` int(20) NOT NULL,
  `name` varchar(255) NOT NULL,
  `address` varchar(255) NOT NULL,
  `city` varchar(255) NOT NULL,
  `pin` int(5) NOT NULL,
  `mobile` varchar(10) NOT NULL,
  `defaultAdd` int(20) NOT NULL,
  `user_id` int(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `shipping_address`
--

INSERT INTO `shipping_address` (`SID`, `name`, `address`, `city`, `pin`, `mobile`, `defaultAdd`, `user_id`) VALUES
(7, 'Sonu', 'Nooranganj', 'Sasaram', 821115, '7239907130', 1, 4),
(8, 'Somdat', 'Rohtas', 'Sasaram', 821115, '7239907130', 0, 4),
(9, 'Nitish', 'Sector 75', 'Noida', 120307, '7239907130', 0, 4);

-- --------------------------------------------------------

--
-- Table structure for table `user_info`
--

CREATE TABLE `user_info` (
  `user_id` int(10) NOT NULL,
  `first_name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `address` varchar(255) NOT NULL,
  `city` varchar(255) NOT NULL,
  `pin` int(6) DEFAULT NULL,
  `password` varchar(255) NOT NULL,
  `mobile` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `user_info`
--

INSERT INTO `user_info` (`user_id`, `first_name`, `email`, `address`, `city`, `pin`, `password`, `mobile`) VALUES
(4, 'Sonu', 'sonuprakash167@gmail.com', 'Nooranganj', 'Sasaram', 821115, '78e66a042127f97cd157e66e457b1034', '7239907130');

-- --------------------------------------------------------

--
-- Table structure for table `wishlist`
--

CREATE TABLE `wishlist` (
  `wishId` int(20) NOT NULL,
  `product_id` int(20) NOT NULL,
  `user_id` int(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `wishlist`
--

INSERT INTO `wishlist` (`wishId`, `product_id`, `user_id`) VALUES
(1, 148, 4),
(2, 147, 4);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `admin`
--
ALTER TABLE `admin`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indexes for table `banner`
--
ALTER TABLE `banner`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `brands`
--
ALTER TABLE `brands`
  ADD PRIMARY KEY (`brand_id`);

--
-- Indexes for table `cart`
--
ALTER TABLE `cart`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `categories`
--
ALTER TABLE `categories`
  ADD PRIMARY KEY (`cat_id`);

--
-- Indexes for table `coupons`
--
ALTER TABLE `coupons`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `customers_order_details`
--
ALTER TABLE `customers_order_details`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `orders`
--
ALTER TABLE `orders`
  ADD PRIMARY KEY (`order_id`);

--
-- Indexes for table `products`
--
ALTER TABLE `products`
  ADD PRIMARY KEY (`product_id`),
  ADD KEY `fk_product_cat` (`product_cat`),
  ADD KEY `fk_product_brand` (`product_brand`);

--
-- Indexes for table `product_qty`
--
ALTER TABLE `product_qty`
  ADD PRIMARY KEY (`qty_id`);

--
-- Indexes for table `product_size`
--
ALTER TABLE `product_size`
  ADD PRIMARY KEY (`size_id`);

--
-- Indexes for table `returnreason`
--
ALTER TABLE `returnreason`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `shipping_address`
--
ALTER TABLE `shipping_address`
  ADD PRIMARY KEY (`SID`);

--
-- Indexes for table `user_info`
--
ALTER TABLE `user_info`
  ADD PRIMARY KEY (`user_id`);

--
-- Indexes for table `wishlist`
--
ALTER TABLE `wishlist`
  ADD PRIMARY KEY (`wishId`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `admin`
--
ALTER TABLE `admin`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `banner`
--
ALTER TABLE `banner`
  MODIFY `id` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `brands`
--
ALTER TABLE `brands`
  MODIFY `brand_id` int(100) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT for table `cart`
--
ALTER TABLE `cart`
  MODIFY `id` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1445;

--
-- AUTO_INCREMENT for table `categories`
--
ALTER TABLE `categories`
  MODIFY `cat_id` int(100) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=25;

--
-- AUTO_INCREMENT for table `coupons`
--
ALTER TABLE `coupons`
  MODIFY `id` int(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `customers_order_details`
--
ALTER TABLE `customers_order_details`
  MODIFY `id` int(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `orders`
--
ALTER TABLE `orders`
  MODIFY `order_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `products`
--
ALTER TABLE `products`
  MODIFY `product_id` int(100) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=164;

--
-- AUTO_INCREMENT for table `product_qty`
--
ALTER TABLE `product_qty`
  MODIFY `qty_id` int(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `product_size`
--
ALTER TABLE `product_size`
  MODIFY `size_id` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT for table `returnreason`
--
ALTER TABLE `returnreason`
  MODIFY `id` int(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `shipping_address`
--
ALTER TABLE `shipping_address`
  MODIFY `SID` int(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `user_info`
--
ALTER TABLE `user_info`
  MODIFY `user_id` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `wishlist`
--
ALTER TABLE `wishlist`
  MODIFY `wishId` int(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `products`
--
ALTER TABLE `products`
  ADD CONSTRAINT `fk_product_brand` FOREIGN KEY (`product_brand`) REFERENCES `brands` (`brand_id`),
  ADD CONSTRAINT `fk_product_cat` FOREIGN KEY (`product_cat`) REFERENCES `categories` (`cat_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

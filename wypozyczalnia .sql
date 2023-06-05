-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Cze 05, 2023 at 03:39 PM
-- Wersja serwera: 10.4.28-MariaDB
-- Wersja PHP: 8.2.4

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `wypozyczalnia`
--

DELIMITER $$
--
-- Procedury
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `policzWszystkiePunkty` ()   begin
	drop view if exists wszystkiePunkty;
	create view wszystkiePunkty AS
    	select kl.imie, kl.nazwisko, y.punkty from
			(select x.id_klienta, sum(x.points) as punkty
            from 
                (select z.id_klienta, c.points from zamowienia z
                inner join karta_stalego_klienta k using(id_klienta)
                inner join config c using(typ_karty)
                where c.dolne_ograniczenie <= z.wypozyczone_dni and c.gorne_ograniczenie >= z.wypozyczone_dni and z.id_pracownika_odbierajacego > 0
                order by z.id_klienta) x
            group by x.id_klienta ) y
        inner join klienci kl using(id_klienta);
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `updateKlienciSubskrybujacy` ()   begin
     	drop view if exists kliencisubskrybujacy;
      	create view klienciSubskrybujacy AS
        SELECT imie, nazwisko, nr_telefonu, email
        FROM klienci
        WHERE subskrybcja = 1;
     END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `zakonczZamowienie` (`pracownik` INT, `zamowienie` INT)   begin
	declare test int default if((select id_pracownika_odbierajacego from zamowienia where id_zamowienia = zamowienie)>0, 0, 1);
    
	update zamowienia 
    set id_pracownika_odbierajacego = if(test=1, pracownik, null)
    where id_zamowienia = zamowienie;
    
    update karta_stalego_klienta k
    inner join
        (select z.id_klienta, c.points from zamowienia z
        inner join karta_stalego_klienta k using(id_klienta)
        inner join config c using(typ_karty)
        where c.dolne_ograniczenie <= z.wypozyczone_dni and c.gorne_ograniczenie >= z.wypozyczone_dni and z.id_zamowienia = zamowienie) x
    set ilosc_punktow = if(test=1, ilosc_punktow + x.points, ilosc_punktow)
    where k.id_klienta = x.id_klienta;
    
end$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `config`
--

CREATE TABLE `config` (
  `id_config` int(11) NOT NULL,
  `typ_karty` char(1) NOT NULL,
  `dolne_ograniczenie` int(11) NOT NULL,
  `gorne_ograniczenie` int(11) NOT NULL,
  `points` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `config`
--

INSERT INTO `config` (`id_config`, `typ_karty`, `dolne_ograniczenie`, `gorne_ograniczenie`, `points`) VALUES
(1, 'B', 1, 10, 1),
(2, 'B', 11, 50, 2),
(3, 'B', 50, 200, 3),
(4, 'B', 200, 9999999, 4),
(5, 'S', 1, 10, 1),
(6, 'S', 11, 50, 3),
(7, 'S', 50, 200, 6),
(8, 'S', 200, 9999999, 10),
(9, 'G', 1, 10, 2),
(10, 'G', 11, 50, 4),
(11, 'G', 50, 200, 8),
(12, 'G', 200, 9999999, 15),
(13, 'P', 1, 10, 3),
(14, 'P', 11, 50, 6),
(15, 'P', 50, 200, 10),
(16, 'P', 200, 9999999, 20);

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `karta_stalego_klienta`
--

CREATE TABLE `karta_stalego_klienta` (
  `id_karty` int(11) NOT NULL,
  `id_klienta` int(11) NOT NULL,
  `ilosc_punktow` int(11) NOT NULL,
  `typ_karty` char(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `karta_stalego_klienta`
--

INSERT INTO `karta_stalego_klienta` (`id_karty`, `id_klienta`, `ilosc_punktow`, `typ_karty`) VALUES
(1, 50, 0, 'S'),
(2, 49, 3, 'S'),
(3, 48, 0, 'G'),
(4, 47, 0, 'S'),
(5, 46, 0, 'G'),
(6, 45, 0, 'S'),
(7, 44, 0, 'P'),
(8, 43, 6, 'G'),
(9, 42, 2, 'B'),
(10, 41, 1, 'S'),
(11, 40, 0, 'P'),
(12, 39, 2, 'B'),
(13, 38, 0, 'G'),
(14, 37, 0, 'S'),
(15, 36, 2, 'G'),
(16, 35, 0, 'S'),
(17, 34, 2, 'B'),
(18, 33, 3, 'P'),
(19, 32, 8, 'G'),
(20, 31, 0, 'P'),
(21, 30, 1, 'B'),
(22, 29, 3, 'S'),
(23, 28, 0, 'G'),
(24, 27, 0, 'P'),
(25, 26, 0, 'S'),
(26, 25, 0, 'B'),
(27, 24, 3, 'S'),
(28, 23, 16, 'G'),
(29, 22, 0, 'S'),
(30, 21, 0, 'S'),
(31, 20, 0, 'G'),
(32, 19, 0, 'G'),
(33, 18, 0, 'B'),
(34, 17, 1, 'S'),
(35, 16, 0, 'B'),
(36, 15, 0, 'G'),
(37, 14, 0, 'S'),
(38, 13, 4, 'G'),
(39, 12, 0, 'B'),
(40, 11, 2, 'G'),
(41, 10, 0, 'G'),
(42, 9, 0, 'B'),
(43, 8, 0, 'S'),
(44, 7, 0, 'G'),
(45, 6, 0, 'B'),
(46, 5, 0, 'G'),
(47, 4, 0, 'G'),
(48, 3, 0, 'S'),
(49, 2, 0, 'G'),
(50, 1, 8, 'B');

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `klienci`
--

CREATE TABLE `klienci` (
  `ID_klienta` int(11) NOT NULL,
  `imie` text NOT NULL,
  `nazwisko` text NOT NULL,
  `pesel` varchar(11) NOT NULL,
  `data_urodzenia` date NOT NULL,
  `adres` text NOT NULL,
  `plec` text NOT NULL,
  `email` text NOT NULL,
  `nr_telefonu` varchar(9) NOT NULL,
  `subskrybcja` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `klienci`
--

INSERT INTO `klienci` (`ID_klienta`, `imie`, `nazwisko`, `pesel`, `data_urodzenia`, `adres`, `plec`, `email`, `nr_telefonu`, `subskrybcja`) VALUES
(1, 'Adam', 'Nowak', '85050134567', '1985-05-01', 'Warszawa, ul. S?oneczna 1', 'Mezczyzna', 'adam.nowak@example.com', '412594280', 0),
(2, 'Michal', 'Kowalski', '90071287654', '1990-07-12', 'Gdansk, ul. Kwiatowa 2', 'Mezczyzna', 'michal.kowalski@example.com', '373077153', 0),
(3, 'Jan', 'Wisniewski', '81081398765', '1981-08-13', 'Krakow, ul. Lipowa 3', 'Mezczyzna', 'jan.wisniewski@example.com', '445997992', 1),
(4, 'Kamila', 'Dabrowska', '93090423456', '1993-09-04', 'Wroclaw, ul. Wiosenna 4', 'Kobieta', 'kamilad23@example.com', '788273253', 0),
(5, 'Piotr', 'Kaczmarek', '87080534567', '1987-08-05', 'Poznan, ul. Ko?ciuszki 5', 'Mezczyzna', 'piotr123@example.com', '577949779', 0),
(6, 'Rafal', 'Lewandowski', '92090678965', '1992-09-06', 'Katowice, ul. Mickiewicza 6', 'Mezczyzna', 'rafal.lewandowski@example.com', '522812400', 1),
(7, 'Damian', 'Jankowski', '84090787654', '1984-09-07', 'Lodz, ul. Ogrodowa 7', 'Mezczyzna', 'damian.jankowski@example.com', '134928291', 0),
(8, 'Rafal', 'Krawczyk', '95010898765', '1995-01-08', 'Gdynia, ul. Polna 8', 'Mezczyzna', 'rafal.krawczyk@example.com', '996574418', 0),
(9, 'Krzysztof', 'Grabowski', '88020965432', '1988-02-09', 'Szczecin, ul. Wiosenna 9', 'Mezczyzna', 'krzysztof.grabowski@example.com', '521985433', 0),
(10, 'Kamil', 'Nowakowski', '91031078965', '1991-03-10', 'Lublin, ul. Le?na 10', 'Mezczyzna', 'kamil.nowakowski@example.com', '314915655', 1),
(11, 'Tomasz', 'Sikorski', '86041134567', '1986-04-11', 'Bydgoszcz, ul. Kwiatkowa 11', 'Mezczyzna', 'tomasz.sikorski@example.com', '660295327', 0),
(12, 'Robert', 'Kowalczyk', '95051287654', '1995-05-12', 'Bialystok, ul. S?oneczna 12', 'Mezczyzna', 'kowalr@example.com', '887378101', 0),
(13, 'Patryk', 'Jasinski', '89061398765', '1989-06-13', 'Rzeszow, ul. Lipowa 13', 'Mezczyzna', 'patrykjas@example.com', '256463657', 0),
(14, 'Kamil', 'Gorski', '80071423456', '1980-07-14', 'Kielce, ul. Wiosenna 14', 'Mezczyzna', 'kamilgg@example.com', '518835066', 1),
(15, 'Pawel', 'Nowakowski', '94081534567', '1994-08-15', 'Olsztyn, ul. Warszawska 15', 'Mezczyzna', 'pawel.nowakowska@example.com', '171463115', 0),
(16, 'Tomasz', 'Kowalski', '87091678965', '1987-09-16', 'Opole, ul. Le?na 16', 'Mezczyzna', 'tomasz.kowalski@example.com', '680678112', 0),
(17, 'Lena', 'Wisniewska', '92001787654', '1992-10-17', 'Gorzow Wielkopolski, ul. Ogrodzi?ska 17', 'Kobieta', 'lenawi63@example.com', '276962391', 0),
(18, 'Damian', 'Kaczmarek', '86011898765', '1986-11-18', 'Tychy, ul. S?oneczna 18', 'Mezczyzna', 'damian.kaczmarek@example.com', '632400458', 0),
(19, 'Rafal', 'Lewandowski', '95021965432', '1995-12-19', 'Zielona Gora, ul. Lipowa 19', 'Mezczyzna', 'rafal.lewandowski@example.com', '813755701', 0),
(20, 'Krzysztof', 'Jankowski', '89032078965', '1989-03-20', 'Gliwice, ul. Kwiatowa 20', 'Mezczyzna', 'krzysztof.jankowski@example.com', '924977697', 1),
(21, 'Piotr', 'Krawczyk', '93042134567', '1993-04-21', 'Radom, ul. Polna 21', 'Mezczyzna', 'piotr.krawczyk@example.com', '539352847', 0),
(22, 'Robert', 'Grabowski', '84052287654', '1984-05-22', 'Czestochowa, ul. Ogrodowa 22', 'Mezczyzna', 'robert.grabowski@example.com', '593808428', 0),
(23, 'Kamil', 'Nowakowski', '92062398765', '1992-06-23', 'Sosnowiec, ul. Polna 23', 'Mezczyzna', 'kamil.nowakowski@example.com', '477206532', 0),
(24, 'Pawel', 'Sikorski', '86072423456', '1986-07-24', 'Ruda Slaska, ul. Wiosenna 24', 'Mezczyzna', 'pawel.sikorski@example.com', '787394118', 0),
(25, 'Piotr', 'Kowalczyk', '95082534567', '1995-08-25', 'Walbrzych, ul. Warszawska 25', 'Mezczyzna', 'piotr.kowalczyk@example.com', '321442608', 1),
(26, 'Damian', 'Jasinski', '89092678965', '1989-09-26', 'Wloclawek, ul. Le?na 26', 'Mezczyzna', 'damian.jasinski@example.com', '542064945', 0),
(27, 'Elzbieta', 'Nowakowska', '80002787654', '1980-10-27', 'Zabrze, ul. Lipowa 27', 'Kobieta', 'nowaela@example.com', '339221632', 0),
(28, 'Robert', 'Nowakowska', '86012898765', '1986-11-28', 'Ostrow Wielkopolski, ul. Kwiatowa 28', 'Mezczyzna', 'robert.nowakowska@example.com', '568426981', 0),
(29, 'Damian', 'Wisniewski', '96022965432', '1996-02-29', 'Plock, ul. S?oneczna 29', 'Mezczyzna', 'damian.wisniewski@example.com', '943422368', 0),
(30, 'Gra?yna', 'Kaczmarek', '90033078965', '1990-03-30', 'Elblag, ul. Ko?ciuszki 30', 'Kobieta', 'grazka21@example.com', '830276738', 1),
(31, 'Adam', 'Nowak', '88050134567', '1988-05-01', 'Warszawa, ul. S?oneczna 1', 'Mezczyzna', 'adam.nowak@example.com', '576792435', 0),
(32, 'Michal', 'Kowalski', '91071287654', '1991-07-12', 'Gdansk, ul. Kwiatowa 2', 'Mezczyzna', 'michal.kowalski@example.com', '146017701', 0),
(33, 'Jan', 'Wisniewski', '84081398765', '1984-08-13', 'Krakow, ul. Lipowa 3', 'Mezczyzna', 'jan.wisniewski@example.com', '184176617', 0),
(34, 'Kamil', 'Dabrowski', '96090423456', '1996-09-04', 'Wroclaw, ul. Wiosenna 4', 'Mezczyzna', 'kamil.dabrowski@example.com', '137983079', 1),
(35, 'Piotr', 'Kaczmarek', '86080534567', '1986-08-05', 'Poznal, ul. Ko?ciuszki 5', 'Mezczyzna', 'piotr.kaczmarek@example.com', '706699065', 0),
(36, 'Rafal', 'Lewandowski', '91090678965', '1991-09-06', 'Katowice, ul. Mickiewicza 6', 'Mezczyzna', 'rafal.lewandowski@example.com', '418402668', 0),
(37, 'Damian', 'Jankowski', '85090787654', '1985-09-07', 'Lodz, ul. Ogrodowa 7', 'Mezczyzna', 'damian.jankowski@example.com', '120655870', 0),
(38, 'Rafal', 'Krawczyk', '97010898765', '1997-01-08', 'Gdynia, ul. Polna 8', 'Mezczyzna', 'rafal.krawczyk@example.com', '123313050', 0),
(39, 'Krzysztof', 'Grabowski', '89020965432', '1989-02-09', 'Szczecin, ul. Wiosenna 9', 'Mezczyzna', 'krzysztof.grabowski@example.com', '339511049', 0),
(40, 'Kamil', 'Nowakowski', '92031078965', '1992-03-10', 'Lublin, ul. Le?na 10', 'Mezczyzna', 'kamil.nowakowski@example.com', '114128287', 0),
(41, 'Tomasz', 'Sikorski', '87041134567', '1987-04-11', 'Bydgoszcz, ul. Kwiatkowa 11', 'Mezczyzna', 'tomasz.sikorski@example.com', '154397348', 0),
(42, 'Robert', 'Kowalczyk', '97051287654', '1997-05-12', 'Bialystok, ul. S?oneczna 12', 'Mezczyzna', 'robert.kowalczyk@example.com', '248686620', 0),
(43, 'Patryk', 'Jasinski', '87061398765', '1987-06-13', 'Rzeszow, ul. Lipowa 13', 'Mezczyzna', 'patryk.jasinski@example.com', '720619225', 1),
(44, 'Kamil', 'Gorski', '81071423456', '1981-07-14', 'Kielce, ul. Wiosenna 14', 'Mezczyzna', 'kamil.gorski@example.com', '239452228', 0),
(45, 'Pawel', 'Nowakowska', '95081534567', '1995-08-15', 'Olsztyn, ul. Warszawska 15', 'Mezczyzna', 'pawel.nowakowska@example.com', '454968341', 0),
(46, 'Tomasz', 'Kowalski', '88091678965', '1988-09-16', 'Opole, ul. Le?na 16', 'Mezczyzna', 'tomasz.kowalski@example.com', '303809813', 1),
(47, 'Michal', 'Wisniewski', '93001787654', '1993-10-17', 'Gorzow Wielkopolski, ul. Ogrodzi?ska 17', 'Mezczyzna', 'michal.wisniewski@example.com', '631965861', 0),
(48, 'Damian', 'Kaczmarek', '86011898765', '1986-11-18', 'Tychy, ul. S?oneczna 18', 'Mezczyzna', 'damian.kaczmarek@example.com', '491607603', 0),
(49, 'Michalina', 'Nowak', '97021965432', '1997-12-19', 'Zielona Gora, ul. Lipowa 19', 'Kobieta', 'michalinan2@example.com', '441769360', 0),
(50, 'Krzysztof', 'Jankowski', '90032078965', '1990-03-20', 'Gliwice, ul. Kwiatowa 20', 'Mezczyzna', 'krzysztof.jankowski@example.com', '366756508', 0);

-- --------------------------------------------------------

--
-- Zastąpiona struktura widoku `kliencisubskrybujacy`
-- (See below for the actual view)
--
CREATE TABLE `kliencisubskrybujacy` (
`imie` text
,`nazwisko` text
,`nr_telefonu` varchar(9)
,`email` text
);

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `motocykle`
--

CREATE TABLE `motocykle` (
  `id_motocykla` int(11) NOT NULL,
  `typ_motocykla` text NOT NULL,
  `typ_silnika` text NOT NULL,
  `pojemnosc` float NOT NULL,
  `marka` text NOT NULL,
  `model` text NOT NULL,
  `przebieg` bigint(20) NOT NULL,
  `kolor` text NOT NULL,
  `koszt_na_dzien` float NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `motocykle`
--

INSERT INTO `motocykle` (`id_motocykla`, `typ_motocykla`, `typ_silnika`, `pojemnosc`, `marka`, `model`, `przebieg`, `kolor`, `koszt_na_dzien`) VALUES
(1, 'Sportowy', 'rzedowy', 1000, 'Yamaha', 'R1', 5000, 'Czarny', 400),
(2, 'Skuter', 'single', 125, 'Honda', 'PCX', 2000, 'Biały', 200),
(3, 'Chopper', 'typ v', 1800, 'Harley-Davidson', 'Softail', 8000, 'Czerwony', 600),
(4, 'Naked', 'rzedowy', 750, 'Kawasaki', 'Z750', 4000, 'Zielony', 250),
(5, 'Enduro', 'rzedowy', 450, 'KTM', 'EXC', 3000, 'Pomarańczowy', 500),
(6, 'Cruiser', 'typ v', 1600, 'Suzuki', 'Boulevard', 6000, 'Czarny', 550),
(7, 'Sportowy', 'rzedowy', 600, 'Honda', 'CBR600', 3500, 'Czerwony', 350),
(8, 'Skuter', 'single', 50, 'Vespa', 'Primavera', 1500, 'Niebieski', 250),
(9, 'Touring', 'boxer', 1200, 'BMW', 'R1200RT', 9000, 'Srebrny', 650),
(10, 'Supermoto', 'rzedowy', 450, 'Husqvarna', '701', 2500, 'żóty', 550),
(11, 'Sportowy', 'rzedowy', 1000, 'Zero', 'SR', 500, 'Czarny', 400),
(12, 'Naked', 'typ v', 800, 'Triumph', 'Street Triple', 4000, 'Czarny', 350),
(13, 'Chopper', 'typ v', 1300, 'Indian', 'Chief', 6000, 'Biały', 600),
(14, 'Sportowy', 'rzedowy', 1000, 'Suzuki', 'GSXR', 3000, 'Niebieski', 380),
(15, 'Enduro', 'single', 250, 'Honda', 'CRF250L', 2000, 'Czerwony', 280),
(16, 'Skuter', 'single', 125, 'NIU', 'NQI GTS', 1000, 'Szary', 200),
(17, 'Naked', 'rzedowy', 600, 'Yamaha', 'MT-07', 3500, 'Czarny', 280),
(18, 'Cruiser', 'typ v', 900, 'Kawasaki', 'Vulcan', 5000, 'Srebrny', 500),
(19, 'Touring', 'typ v', 1600, 'Harley-Davidson', 'Road King', 8000, 'Czarny', 600),
(20, 'Supermoto', 'rzedowy', 690, 'KTM', 'SMC-R', 3000, 'Pomarańczowy', 550),
(21, 'Sportowy', 'rzedowy', 1000, 'Lightning', 'LS-218', 500, 'Czarny', 400),
(22, 'Naked', 'typ v', 1000, 'Kawasaki', 'Z1000', 4000, 'Zielony', 370),
(23, 'Chopper', 'typ v', 1800, 'Honda', 'Fury', 6000, 'Czerwony', 600),
(24, 'Sportowy', 'rzedowy', 600, 'Suzuki', 'GSX-R600', 3500, 'Czerwony', 390),
(25, 'Enduro', 'rzedowy', 450, 'Yamaha', 'WR450F', 2500, 'Biały', 500),
(26, 'Cruiser', 'typ v', 1500, 'Victory', 'Vegas', 6000, 'Czarny', 550),
(27, 'Skuter', 'single', 50, 'Xiaomi', 'Mi M365', 1500, 'Czerwony', 250),
(28, 'Sportowy', 'rzedowy', 1000, 'Ducati', 'Panigale', 3000, 'Czarny', 380),
(29, 'Touring', 'typ v', 1200, 'Yamaha', 'FJR1300', 9000, 'Srebrny', 580),
(30, 'Supermoto', 'rzedowy', 450, 'Suzuki', 'DRZ400', 2500, 'żóty', 550);

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `pracownicy`
--

CREATE TABLE `pracownicy` (
  `id_pracownika` int(11) NOT NULL,
  `imie` text NOT NULL,
  `nazwisko` text NOT NULL,
  `pesel` varchar(11) NOT NULL,
  `nr_telefonu` varchar(9) NOT NULL,
  `email` text NOT NULL,
  `stanowisko` text NOT NULL,
  `status_studenta` tinyint(1) NOT NULL,
  `dzial` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `pracownicy`
--

INSERT INTO `pracownicy` (`id_pracownika`, `imie`, `nazwisko`, `pesel`, `nr_telefonu`, `email`, `stanowisko`, `status_studenta`, `dzial`) VALUES
(1, 'Ryszard', 'Nowak', '95050134567', '635781989', 'Ryszard.Nowak@example.com', 'Kierownik', 0, 'Zarzadzanie'),
(2, 'Zbigniew', 'Nowak', '80071287654', '607613730', 'Zbigniew.Nowak@example.com', 'Kierownik', 0, 'Zarzadzanie'),
(3, 'Aleksander', 'Kowalski', '91081398765', '739509051', 'Aleksander.Kowalski@example.com', 'Sprzedawca', 0, 'Obsluga Klienta'),
(4, 'Krzysztof', 'Marczak', '83090423456', '864044792', 'Krzysztof.Marczak@example.com', 'Sprzedawca', 0, 'Obsluga Klienta'),
(5, 'Adam', 'Mickiewicz', '97080534567', '901234660', 'Adam.Mickiewicz@example.com', 'Sprzedawca', 0, 'Obsluga Klienta'),
(6, 'Mateusz', 'Bartoszewski', '82090678965', '434648687', 'Mateusz.Bartoszewski@example.com', 'Sprzedawca', 0, 'Obsluga Klienta'),
(7, 'Jakub', 'Pazura', '94090787654', '378986233', 'Jakub.Pazura@example.com', 'Mechanik', 0, 'Obsluga Techniczna'),
(8, 'Grazyna', 'Wojtowicz', '85010898765', '112279096', 'Grazyna.Wojtowicz@example.com', 'Mechanik', 0, 'Obsluga Techniczna'),
(9, 'Justyna', 'Wozniak', '98020965432', '360946331', 'Justyna.Wozniak@example.com', 'Konserwator', 0, 'Obsluga Techniczna'),
(10, 'Pawel', 'Kukiewicz', '81031078965', '948191165', 'Pawel.Kukiewicz@example.com', 'Konserwator', 0, 'Obsluga Techniczna'),
(11, 'Maciej', 'Wisniwski', '71031078965', '621051049', 'Maciej.Wisniwski@example.com', 'Konserwator', 0, 'Obsluga Techniczna');

-- --------------------------------------------------------

--
-- Zastąpiona struktura widoku `wszystkiepunkty`
-- (See below for the actual view)
--
CREATE TABLE `wszystkiepunkty` (
`imie` text
,`nazwisko` text
,`punkty` decimal(32,0)
);

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `zamowienia`
--

CREATE TABLE `zamowienia` (
  `id_zamowienia` int(11) NOT NULL,
  `id_motocykla` int(11) NOT NULL,
  `id_pracownika_wydajacego` int(11) NOT NULL,
  `id_klienta` int(11) NOT NULL,
  `id_pracownika_odbierajacego` int(11) DEFAULT NULL,
  `data_wypozyczenia` date NOT NULL,
  `wypozyczone_dni` int(11) NOT NULL,
  `czy_faktura` tinyint(1) NOT NULL,
  `platnosc` text NOT NULL,
  `dostawa` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `zamowienia`
--

INSERT INTO `zamowienia` (`id_zamowienia`, `id_motocykla`, `id_pracownika_wydajacego`, `id_klienta`, `id_pracownika_odbierajacego`, `data_wypozyczenia`, `wypozyczone_dni`, `czy_faktura`, `platnosc`, `dostawa`) VALUES
(1, 6, 3, 34, 3, '2023-01-31', 21, 1, 'karta', 0),
(2, 0, 3, 43, 4, '2023-02-14', 16, 1, 'karta', 1),
(3, 10, 4, 32, 6, '2023-03-01', 17, 0, 'karta', 0),
(4, 4, 6, 11, 5, '2023-05-05', 5, 0, 'karta', 0),
(5, 16, 5, 42, 4, '2023-04-04', 22, 0, 'gotowka', 0),
(6, 12, 5, 17, 4, '2023-02-25', 8, 0, 'gotowka', 0),
(7, 2, 4, 24, 6, '2023-03-06', 11, 1, 'karta', 0),
(8, 11, 4, 13, 6, '2023-03-17', 18, 1, 'karta', 1),
(9, 7, 4, 30, 3, '2023-04-28', 6, 0, 'karta', 1),
(10, 8, 6, 23, 4, '2023-02-09', 14, 1, 'gotowka', 0),
(11, 19, 4, 33, 6, '2023-03-01', 1, 0, 'karta', 1),
(12, 5, 5, 43, 4, '2023-02-06', 3, 0, 'karta', 0),
(13, 3, 6, 29, 5, '2023-03-17', 24, 1, 'karta', 1),
(14, 18, 6, 41, 3, '2023-02-13', 9, 0, 'karta', 0),
(15, 4, 4, 36, 6, '2023-03-14', 2, 0, 'karta', 0),
(16, 15, 3, 49, 4, '2023-02-15', 14, 0, 'gotowka', 0),
(17, 13, 4, 23, 5, '2023-04-16', 24, 0, 'karta', 1),
(18, 9, 3, 39, 5, '2023-02-17', 20, 0, 'gotowka', 0),
(19, 17, 6, 23, 6, '2023-02-18', 17, 0, 'karta', 0),
(20, 14, 5, 23, 5, '2023-03-30', 28, 0, 'gotowka', 1),
(21, 22, 4, 32, 3, '2023-02-20', 11, 0, 'gotowka', 1),
(22, 1, 4, 1, NULL, '2023-06-04', 4, 0, 'karta', 0),
(23, 2, 4, 1, 4, '2023-06-01', 10, 1, 'karta', 0),
(24, 3, 4, 1, 4, '2023-06-01', 11, 1, 'karta', 0),
(25, 4, 4, 1, 4, '2023-06-01', 15, 1, 'karta', 0),
(26, 5, 4, 1, 4, '2023-06-01', 30, 1, 'karta', 0),
(27, 10, 5, 1, NULL, '2023-06-04', 3, 1, 'gotowka', 1);

-- --------------------------------------------------------

--
-- Struktura widoku `kliencisubskrybujacy`
--
DROP TABLE IF EXISTS `kliencisubskrybujacy`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `kliencisubskrybujacy`  AS SELECT `klienci`.`imie` AS `imie`, `klienci`.`nazwisko` AS `nazwisko`, `klienci`.`nr_telefonu` AS `nr_telefonu`, `klienci`.`email` AS `email` FROM `klienci` WHERE `klienci`.`subskrybcja` = 1 ;

-- --------------------------------------------------------

--
-- Struktura widoku `wszystkiepunkty`
--
DROP TABLE IF EXISTS `wszystkiepunkty`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `wszystkiepunkty`  AS SELECT `kl`.`imie` AS `imie`, `kl`.`nazwisko` AS `nazwisko`, `y`.`punkty` AS `punkty` FROM ((select `x`.`id_klienta` AS `id_klienta`,sum(`x`.`points`) AS `punkty` from (select `z`.`id_klienta` AS `id_klienta`,`c`.`points` AS `points` from ((`zamowienia` `z` join `karta_stalego_klienta` `k` on(`z`.`id_klienta` = `k`.`id_klienta`)) join `config` `c` on(`k`.`typ_karty` = `c`.`typ_karty`)) where `c`.`dolne_ograniczenie` <= `z`.`wypozyczone_dni` and `c`.`gorne_ograniczenie` >= `z`.`wypozyczone_dni` and `z`.`id_pracownika_odbierajacego` > 0 order by `z`.`id_klienta`) `x` group by `x`.`id_klienta`) `y` join `klienci` `kl` on(`y`.`id_klienta` = `kl`.`ID_klienta`)) ;

--
-- Indeksy dla zrzutów tabel
--

--
-- Indeksy dla tabeli `karta_stalego_klienta`
--
ALTER TABLE `karta_stalego_klienta`
  ADD PRIMARY KEY (`id_karty`);

--
-- Indeksy dla tabeli `klienci`
--
ALTER TABLE `klienci`
  ADD PRIMARY KEY (`ID_klienta`);

--
-- Indeksy dla tabeli `motocykle`
--
ALTER TABLE `motocykle`
  ADD PRIMARY KEY (`id_motocykla`);

--
-- Indeksy dla tabeli `pracownicy`
--
ALTER TABLE `pracownicy`
  ADD PRIMARY KEY (`id_pracownika`);

--
-- Indeksy dla tabeli `zamowienia`
--
ALTER TABLE `zamowienia`
  ADD PRIMARY KEY (`id_zamowienia`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `karta_stalego_klienta`
--
ALTER TABLE `karta_stalego_klienta`
  MODIFY `id_karty` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=51;

--
-- AUTO_INCREMENT for table `klienci`
--
ALTER TABLE `klienci`
  MODIFY `ID_klienta` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=51;

--
-- AUTO_INCREMENT for table `motocykle`
--
ALTER TABLE `motocykle`
  MODIFY `id_motocykla` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=31;

--
-- AUTO_INCREMENT for table `pracownicy`
--
ALTER TABLE `pracownicy`
  MODIFY `id_pracownika` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `zamowienia`
--
ALTER TABLE `zamowienia`
  MODIFY `id_zamowienia` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=28;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

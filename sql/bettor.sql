--
-- PostgreSQL database cluster dump
--

-- Started on 2023-02-09 04:13:25

SET default_transaction_read_only = off;

SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;

--
-- Drop databases (except postgres and template1)
--





--
-- Drop roles
--

DROP ROLE postgres;


--
-- Roles
--

CREATE ROLE postgres;
ALTER ROLE postgres WITH SUPERUSER INHERIT CREATEROLE CREATEDB LOGIN REPLICATION BYPASSRLS PASSWORD 'md516fb43374fed0b588e74ff0d01f88f72';

--
-- User Configurations
--






--
-- Databases
--

--
-- Database "template1" dump
--

--
-- PostgreSQL database dump
--

-- Dumped from database version 13.9 (Debian 13.9-0+deb11u1)
-- Dumped by pg_dump version 15.1

-- Started on 2023-02-09 04:13:25

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

UPDATE pg_catalog.pg_database SET datistemplate = false WHERE datname = 'template1';
DROP DATABASE template1;
--
-- TOC entry 2982 (class 1262 OID 1)
-- Name: template1; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE template1 WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'en_GB.UTF-8';


ALTER DATABASE template1 OWNER TO postgres;

\connect template1

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 2983 (class 0 OID 0)
-- Dependencies: 2982
-- Name: DATABASE template1; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON DATABASE template1 IS 'default template for new databases';


--
-- TOC entry 2985 (class 0 OID 0)
-- Name: template1; Type: DATABASE PROPERTIES; Schema: -; Owner: postgres
--

ALTER DATABASE template1 IS_TEMPLATE = true;


\connect template1

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 4 (class 2615 OID 2200)
-- Name: public; Type: SCHEMA; Schema: -; Owner: postgres
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO postgres;

--
-- TOC entry 2984 (class 0 OID 0)
-- Dependencies: 2982
-- Name: DATABASE template1; Type: ACL; Schema: -; Owner: postgres
--

REVOKE CONNECT,TEMPORARY ON DATABASE template1 FROM PUBLIC;
GRANT CONNECT ON DATABASE template1 TO PUBLIC;


--
-- TOC entry 2986 (class 0 OID 0)
-- Dependencies: 4
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;
GRANT ALL ON SCHEMA public TO PUBLIC;


-- Completed on 2023-02-09 04:13:25

--
-- PostgreSQL database dump complete
--

--
-- Database "postgres" dump
--

--
-- PostgreSQL database dump
--

-- Dumped from database version 13.9 (Debian 13.9-0+deb11u1)
-- Dumped by pg_dump version 15.1

-- Started on 2023-02-09 04:13:25

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

DROP DATABASE postgres;
--
-- TOC entry 3015 (class 1262 OID 13445)
-- Name: postgres; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE postgres WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'en_GB.UTF-8';


ALTER DATABASE postgres OWNER TO postgres;

\connect postgres

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 3016 (class 0 OID 0)
-- Dependencies: 3015
-- Name: DATABASE postgres; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON DATABASE postgres IS 'default administrative connection database';


--
-- TOC entry 5 (class 2615 OID 2200)
-- Name: public; Type: SCHEMA; Schema: -; Owner: postgres
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO postgres;

--
-- TOC entry 635 (class 1247 OID 24746)
-- Name: MatchTime; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public."MatchTime" AS ENUM (
    'Full Time',
    '1st Half',
    '2nd Half'
);


ALTER TYPE public."MatchTime" OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 200 (class 1259 OID 24718)
-- Name: Match; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Match" (
    id bigint NOT NULL,
    home_team character varying NOT NULL,
    guest_team character varying NOT NULL,
    date_time timestamp with time zone NOT NULL
);


ALTER TABLE public."Match" OWNER TO postgres;

--
-- TOC entry 201 (class 1259 OID 24724)
-- Name: Match_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Match_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."Match_id_seq" OWNER TO postgres;

--
-- TOC entry 3019 (class 0 OID 0)
-- Dependencies: 201
-- Name: Match_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Match_id_seq" OWNED BY public."Match".id;


--
-- TOC entry 202 (class 1259 OID 24726)
-- Name: OverUnder; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."OverUnder" (
    id bigint NOT NULL,
    value numeric NOT NULL,
    over numeric,
    under numeric,
    match_id bigint NOT NULL,
    half public."MatchTime" NOT NULL,
    payout character varying
);


ALTER TABLE public."OverUnder" OWNER TO postgres;

--
-- TOC entry 203 (class 1259 OID 24729)
-- Name: OverUnder_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."OverUnder_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."OverUnder_id_seq" OWNER TO postgres;

--
-- TOC entry 3021 (class 0 OID 0)
-- Dependencies: 203
-- Name: OverUnder_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."OverUnder_id_seq" OWNED BY public."OverUnder".id;


--
-- TOC entry 2865 (class 2604 OID 24731)
-- Name: Match id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Match" ALTER COLUMN id SET DEFAULT nextval('public."Match_id_seq"'::regclass);


--
-- TOC entry 2866 (class 2604 OID 24732)
-- Name: OverUnder id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."OverUnder" ALTER COLUMN id SET DEFAULT nextval('public."OverUnder_id_seq"'::regclass);


--
-- TOC entry 3006 (class 0 OID 24718)
-- Dependencies: 200
-- Data for Name: Match; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."Match" VALUES (2, 'Giannina', 'Ionikos', '2023-02-11 18:00:00+00');
INSERT INTO public."Match" VALUES (54, 'Volos', 'Atromitos', '2023-02-12 14:00:00+00');
INSERT INTO public."Match" VALUES (57, 'Aris', 'Panathinaikos', '2023-02-12 18:00:00+00');
INSERT INTO public."Match" VALUES (67, 'Lamia', 'OFI Crete', '2023-02-13 15:00:00+00');
INSERT INTO public."Match" VALUES (70, 'Asteras Tripolis', 'PAOK', '2023-02-13 16:00:00+00');
INSERT INTO public."Match" VALUES (73, 'AEK Athens FC', 'Levadiakos', '2023-02-13 16:30:00+00');
INSERT INTO public."Match" VALUES (76, 'Olympiacos Piraeus', 'Panetolikos', '2023-02-13 19:00:00+00');
INSERT INTO public."Match" VALUES (79, 'Panathinaikos', 'Volos', '2023-02-18 15:00:00+00');
INSERT INTO public."Match" VALUES (82, 'OFI Crete', 'Aris', '2023-02-18 17:30:00+00');
INSERT INTO public."Match" VALUES (85, 'Asteras Tripolis', 'Giannina', '2023-02-18 18:00:00+00');
INSERT INTO public."Match" VALUES (88, 'Lamia', 'Olympiacos Piraeus', '2023-02-19 14:00:00+00');
INSERT INTO public."Match" VALUES (91, 'Panetolikos', 'Ionikos', '2023-02-19 17:30:00+00');
INSERT INTO public."Match" VALUES (94, 'PAOK', 'AEK Athens FC', '2023-02-19 18:30:00+00');
INSERT INTO public."Match" VALUES (97, 'Atromitos', 'Levadiakos', '2023-02-20 16:00:00+00');


--
-- TOC entry 3008 (class 0 OID 24726)
-- Dependencies: 202
-- Data for Name: OverUnder; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."OverUnder" VALUES (21, 0.5, 1.08, 9.0, 2, 'Full Time', '96.4%');
INSERT INTO public."OverUnder" VALUES (22, 0.75, 1.06, 7.2, 2, 'Full Time', '92.4%');
INSERT INTO public."OverUnder" VALUES (23, 1.0, 1.08, 6.15, 2, 'Full Time', '91.9%');
INSERT INTO public."OverUnder" VALUES (24, 1.25, 1.26, 3.9, 2, 'Full Time', '95.2%');
INSERT INTO public."OverUnder" VALUES (25, 1.5, 1.44, 2.9, 2, 'Full Time', '96.2%');
INSERT INTO public."OverUnder" VALUES (26, 1.75, 1.52, 2.55, 2, 'Full Time', '95.2%');
INSERT INTO public."OverUnder" VALUES (27, 2.0, 1.6800000000000002, 2.1799999999999997, 2, 'Full Time', '94.9%');
INSERT INTO public."OverUnder" VALUES (28, 2.25, 2.02, 1.8399999999999999, 2, 'Full Time', '96.3%');
INSERT INTO public."OverUnder" VALUES (76, 1.25, 2.01, 1.75, 2, '2nd Half', '93.6%');
INSERT INTO public."OverUnder" VALUES (77, 1.5, 2.5, 1.53, 2, '2nd Half', '94.9%');
INSERT INTO public."OverUnder" VALUES (78, 1.75, 2.99, 1.3599999999999999, 2, '2nd Half', '93.5%');
INSERT INTO public."OverUnder" VALUES (79, 2.0, 4.5, 1.19, 2, '2nd Half', '94.1%');
INSERT INTO public."OverUnder" VALUES (80, 2.25, 5.05, 1.1400000000000001, 2, '2nd Half', '93.0%');
INSERT INTO public."OverUnder" VALUES (81, 2.5, 6.0, 1.13, 2, '2nd Half', '95.1%');
INSERT INTO public."OverUnder" VALUES (82, 3.0, 10.0, 1.03, 2, '2nd Half', '93.4%');
INSERT INTO public."OverUnder" VALUES (83, 3.5, 17.0, 1.03, 2, '2nd Half', '97.1%');
INSERT INTO public."OverUnder" VALUES (342, 0.5, 1.07, 11.0, 54, 'Full Time', '97.5%');
INSERT INTO public."OverUnder" VALUES (29, 2.5, 2.3, 1.65, 2, 'Full Time', '96.1%');
INSERT INTO public."OverUnder" VALUES (61, 0.5, 1.5, 2.6399999999999997, 2, '1st Half', '95.7%');
INSERT INTO public."OverUnder" VALUES (62, 0.75, 1.73, 2.17, 2, '1st Half', '96.3%');
INSERT INTO public."OverUnder" VALUES (63, 1.0, 2.1799999999999997, 1.67, 2, '1st Half', '94.6%');
INSERT INTO public."OverUnder" VALUES (64, 1.25, 2.8, 1.43, 2, '1st Half', '94.7%');
INSERT INTO public."OverUnder" VALUES (65, 1.5, 3.4, 1.3599999999999999, 2, '1st Half', '97.1%');
INSERT INTO public."OverUnder" VALUES (66, 1.75, 4.32, 1.19, 2, '1st Half', '93.3%');
INSERT INTO public."OverUnder" VALUES (67, 2.0, 7.3, 1.07, 2, '1st Half', '93.3%');
INSERT INTO public."OverUnder" VALUES (68, 2.25, 8.0, 1.06, 2, '1st Half', '93.6%');
INSERT INTO public."OverUnder" VALUES (69, 2.5, 10.0, 1.07, 2, '1st Half', '96.7%');
INSERT INTO public."OverUnder" VALUES (70, 3.0, 14.0, 1.01, 2, '1st Half', '94.2%');
INSERT INTO public."OverUnder" VALUES (71, 3.5, 34.0, 1.01, 2, '1st Half', '98.1%');
INSERT INTO public."OverUnder" VALUES (72, 4.5, 61.0, NULL, 2, '1st Half', '98.4%');
INSERT INTO public."OverUnder" VALUES (73, 0.5, 1.3599999999999999, 3.4, 2, '2nd Half', '97.1%');
INSERT INTO public."OverUnder" VALUES (343, 0.75, 1.05, 8.1, 54, 'Full Time', '93.0%');
INSERT INTO public."OverUnder" VALUES (346, 1.5, 1.3599999999999999, 3.3, 54, 'Full Time', '96.3%');
INSERT INTO public."OverUnder" VALUES (347, 1.75, 1.43, 2.8600000000000003, 54, 'Full Time', '95.3%');
INSERT INTO public."OverUnder" VALUES (348, 2.0, 1.55, 2.46, 54, 'Full Time', '95.1%');
INSERT INTO public."OverUnder" VALUES (349, 2.25, 1.85, 2.01, 54, 'Full Time', '96.3%');
INSERT INTO public."OverUnder" VALUES (350, 2.5, 2.1, 1.77, 54, 'Full Time', '96.0%');
INSERT INTO public."OverUnder" VALUES (351, 2.75, 2.3600000000000003, 1.5899999999999999, 54, 'Full Time', '95.0%');
INSERT INTO public."OverUnder" VALUES (352, 3.0, 2.95, 1.4, 54, 'Full Time', '94.9%');
INSERT INTO public."OverUnder" VALUES (353, 3.25, 3.3, 1.33, 54, 'Full Time', '94.8%');
INSERT INTO public."OverUnder" VALUES (354, 3.5, 3.75, 1.28, 54, 'Full Time', '95.4%');
INSERT INTO public."OverUnder" VALUES (355, 3.75, 4.5, 1.17, 54, 'Full Time', '92.9%');
INSERT INTO public."OverUnder" VALUES (356, 4.0, 6.2, 1.07, 54, 'Full Time', '91.3%');
INSERT INTO public."OverUnder" VALUES (30, 2.75, 2.65, 1.48, 2, 'Full Time', '95.0%');
INSERT INTO public."OverUnder" VALUES (31, 3.0, 3.4, 1.32, 2, 'Full Time', '95.1%');
INSERT INTO public."OverUnder" VALUES (32, 3.25, 3.8, 1.27, 2, 'Full Time', '95.2%');
INSERT INTO public."OverUnder" VALUES (33, 3.5, 4.35, 1.23, 2, 'Full Time', '95.9%');
INSERT INTO public."OverUnder" VALUES (34, 3.75, 5.1, 1.13, 2, 'Full Time', '92.5%');
INSERT INTO public."OverUnder" VALUES (35, 4.0, 7.1, 1.05, 2, 'Full Time', '91.5%');
INSERT INTO public."OverUnder" VALUES (36, 4.25, 8.0, 1.05, 2, 'Full Time', '92.8%');
INSERT INTO public."OverUnder" VALUES (37, 4.5, 10.0, 1.07, 2, 'Full Time', '96.7%');
INSERT INTO public."OverUnder" VALUES (38, 5.0, 12.5, 1.01, 2, 'Full Time', '93.4%');
INSERT INTO public."OverUnder" VALUES (39, 5.5, 21.0, 1.02, 2, 'Full Time', '97.3%');
INSERT INTO public."OverUnder" VALUES (40, 6.5, 51.0, NULL, 2, 'Full Time', '98.1%');
INSERT INTO public."OverUnder" VALUES (74, 0.75, 1.41, 2.7800000000000002, 2, '2nd Half', '93.6%');
INSERT INTO public."OverUnder" VALUES (75, 1.0, 1.6099999999999999, 2.23, 2, '2nd Half', '93.5%');
INSERT INTO public."OverUnder" VALUES (344, 1.0, 1.06, 6.9, 54, 'Full Time', '91.9%');
INSERT INTO public."OverUnder" VALUES (345, 1.25, 1.2, 4.04, 54, 'Full Time', '92.5%');
INSERT INTO public."OverUnder" VALUES (357, 4.25, 6.85, 1.07, 54, 'Full Time', '92.5%');
INSERT INTO public."OverUnder" VALUES (358, 4.5, 8.0, 1.08, 54, 'Full Time', '95.2%');
INSERT INTO public."OverUnder" VALUES (359, 5.0, 12.0, 1.02, 54, 'Full Time', '94.0%');
INSERT INTO public."OverUnder" VALUES (360, 5.5, 17.0, 1.02, 54, 'Full Time', '96.2%');
INSERT INTO public."OverUnder" VALUES (361, 6.5, 34.0, 1.01, 54, 'Full Time', '98.1%');
INSERT INTO public."OverUnder" VALUES (362, 0.5, 1.44, 2.8200000000000003, 54, '1st Half', '95.3%');
INSERT INTO public."OverUnder" VALUES (363, 0.75, 1.6099999999999999, 2.3200000000000003, 54, '1st Half', '95.0%');
INSERT INTO public."OverUnder" VALUES (364, 1.0, 2.05, 1.81, 54, '1st Half', '96.1%');
INSERT INTO public."OverUnder" VALUES (365, 1.25, 2.5700000000000003, 1.5, 54, '1st Half', '94.7%');
INSERT INTO public."OverUnder" VALUES (366, 1.5, 3.25, 1.4, 54, '1st Half', '97.8%');
INSERT INTO public."OverUnder" VALUES (367, 1.75, 3.96, 1.22, 54, '1st Half', '93.3%');
INSERT INTO public."OverUnder" VALUES (368, 2.0, 6.6, 1.09, 54, '1st Half', '93.6%');
INSERT INTO public."OverUnder" VALUES (369, 2.25, 7.2, 1.07, 54, '1st Half', '93.2%');
INSERT INTO public."OverUnder" VALUES (370, 2.5, 9.0, 1.08, 54, '1st Half', '96.4%');
INSERT INTO public."OverUnder" VALUES (371, 3.5, 26.0, 1.02, 54, '1st Half', '98.1%');
INSERT INTO public."OverUnder" VALUES (372, 4.5, 61.0, NULL, 54, '1st Half', '98.4%');
INSERT INTO public."OverUnder" VALUES (373, 0.5, 1.3, 3.75, 54, '2nd Half', '96.5%');
INSERT INTO public."OverUnder" VALUES (374, 0.75, 1.3599999999999999, 2.99, 54, '2nd Half', '93.5%');
INSERT INTO public."OverUnder" VALUES (375, 1.0, 1.53, 2.44, 54, '2nd Half', '94.0%');
INSERT INTO public."OverUnder" VALUES (376, 1.25, 1.9, 1.8399999999999999, 54, '2nd Half', '93.5%');
INSERT INTO public."OverUnder" VALUES (377, 1.5, 2.35, 1.62, 54, '2nd Half', '95.9%');
INSERT INTO public."OverUnder" VALUES (378, 1.75, 2.7800000000000002, 1.41, 54, '2nd Half', '93.6%');
INSERT INTO public."OverUnder" VALUES (379, 2.0, 4.0, 1.23, 54, '2nd Half', '94.1%');
INSERT INTO public."OverUnder" VALUES (380, 2.25, 4.6, 1.18, 54, '2nd Half', '93.9%');
INSERT INTO public."OverUnder" VALUES (381, 2.5, 5.25, 1.17, 54, '2nd Half', '95.7%');
INSERT INTO public."OverUnder" VALUES (382, 3.0, 8.7, 1.04, 54, '2nd Half', '92.9%');
INSERT INTO public."OverUnder" VALUES (383, 3.5, 13.0, 1.04, 54, '2nd Half', '96.3%');
INSERT INTO public."OverUnder" VALUES (384, 0.5, 1.16, 6.5, 57, 'Full Time', '98.4%');
INSERT INTO public."OverUnder" VALUES (385, 0.75, 1.1400000000000001, 4.859999999999999, 57, 'Full Time', '92.3%');
INSERT INTO public."OverUnder" VALUES (386, 1.0, 1.19, 4.2, 57, 'Full Time', '92.7%');
INSERT INTO public."OverUnder" VALUES (387, 1.25, 1.46, 2.85, 57, 'Full Time', '96.5%');
INSERT INTO public."OverUnder" VALUES (388, 1.5, 1.6800000000000002, 2.3, 57, 'Full Time', '97.1%');
INSERT INTO public."OverUnder" VALUES (389, 1.75, 1.8900000000000001, 2.0, 57, 'Full Time', '97.2%');
INSERT INTO public."OverUnder" VALUES (390, 2.0, 2.2800000000000002, 1.6800000000000002, 57, 'Full Time', '96.7%');
INSERT INTO public."OverUnder" VALUES (391, 2.25, 2.7, 1.51, 57, 'Full Time', '96.8%');
INSERT INTO public."OverUnder" VALUES (392, 2.5, 3.15, 1.4, 57, 'Full Time', '96.9%');
INSERT INTO public."OverUnder" VALUES (393, 2.75, 3.8, 1.27, 57, 'Full Time', '95.2%');
INSERT INTO public."OverUnder" VALUES (394, 3.0, 5.05, 1.12, 57, 'Full Time', '91.7%');
INSERT INTO public."OverUnder" VALUES (395, 3.25, 5.6, 1.11, 57, 'Full Time', '92.6%');
INSERT INTO public."OverUnder" VALUES (396, 3.5, 6.75, 1.12, 57, 'Full Time', '96.1%');
INSERT INTO public."OverUnder" VALUES (397, 3.75, 8.1, 1.04, 57, 'Full Time', '92.2%');
INSERT INTO public."OverUnder" VALUES (398, 4.0, 10.0, 1.03, 57, 'Full Time', '93.4%');
INSERT INTO public."OverUnder" VALUES (399, 4.5, 17.0, 1.03, 57, 'Full Time', '97.1%');
INSERT INTO public."OverUnder" VALUES (400, 5.5, 34.0, 1.01, 57, 'Full Time', '98.1%');
INSERT INTO public."OverUnder" VALUES (401, 6.5, 56.0, NULL, 57, 'Full Time', '98.2%');
INSERT INTO public."OverUnder" VALUES (505, 0.5, 1.67, 2.3, 57, '1st Half', '96.8%');
INSERT INTO public."OverUnder" VALUES (506, 0.75, 2.0, 1.81, 57, '1st Half', '95.0%');
INSERT INTO public."OverUnder" VALUES (507, 1.0, 2.9, 1.41, 57, '1st Half', '94.9%');
INSERT INTO public."OverUnder" VALUES (508, 1.25, 3.69, 1.28, 57, '1st Half', '95.0%');
INSERT INTO public."OverUnder" VALUES (509, 1.5, 4.4, 1.29, 57, '1st Half', '99.8%');
INSERT INTO public."OverUnder" VALUES (510, 1.75, 5.8, 1.12, 57, '1st Half', '93.9%');
INSERT INTO public."OverUnder" VALUES (511, 2.0, 10.75, 1.03, 57, '1st Half', '94.0%');
INSERT INTO public."OverUnder" VALUES (512, 2.25, NULL, NULL, 57, '1st Half', '-');
INSERT INTO public."OverUnder" VALUES (513, 2.5, 15.0, 1.04, 57, '1st Half', '97.3%');
INSERT INTO public."OverUnder" VALUES (514, 3.5, 41.0, 1.01, 57, '1st Half', '98.6%');
INSERT INTO public."OverUnder" VALUES (515, 4.5, 91.0, NULL, 57, '1st Half', '98.9%');
INSERT INTO public."OverUnder" VALUES (516, 0.5, 1.44, 2.75, 57, '2nd Half', '94.5%');
INSERT INTO public."OverUnder" VALUES (517, 0.75, 1.62, 2.2199999999999998, 57, '2nd Half', '93.7%');
INSERT INTO public."OverUnder" VALUES (518, 1.0, 2.0, 1.76, 57, '2nd Half', '93.6%');
INSERT INTO public."OverUnder" VALUES (519, 1.25, 2.51, 1.49, 57, '2nd Half', '93.5%');
INSERT INTO public."OverUnder" VALUES (520, 1.5, 3.1, 1.4, 57, '2nd Half', '96.4%');
INSERT INTO public."OverUnder" VALUES (521, 1.75, 4.0, 1.22, 57, '2nd Half', '93.5%');
INSERT INTO public."OverUnder" VALUES (522, 2.0, 6.65, 1.1, 57, '2nd Half', '94.4%');
INSERT INTO public."OverUnder" VALUES (523, 2.25, 7.3, 1.07, 57, '2nd Half', '93.3%');
INSERT INTO public."OverUnder" VALUES (524, 2.5, 8.0, 1.08, 57, '2nd Half', '95.2%');
INSERT INTO public."OverUnder" VALUES (525, 3.5, 23.0, 1.02, 57, '2nd Half', '97.7%');
INSERT INTO public."OverUnder" VALUES (526, 0.5, 1.11, 8.0, 67, 'Full Time', '97.5%');
INSERT INTO public."OverUnder" VALUES (527, 0.75, 1.09, 6.0, 67, 'Full Time', '92.2%');
INSERT INTO public."OverUnder" VALUES (528, 1.0, 1.11, 5.2, 67, 'Full Time', '91.5%');
INSERT INTO public."OverUnder" VALUES (529, 1.25, 1.32, 3.4, 67, 'Full Time', '95.1%');
INSERT INTO public."OverUnder" VALUES (530, 1.5, 1.5, 2.65, 67, 'Full Time', '95.8%');
INSERT INTO public."OverUnder" VALUES (531, 1.75, 1.63, 2.31, 67, 'Full Time', '95.6%');
INSERT INTO public."OverUnder" VALUES (532, 2.0, 1.8599999999999999, 2.02, 67, 'Full Time', '96.8%');
INSERT INTO public."OverUnder" VALUES (533, 2.25, 2.21, 1.7, 67, 'Full Time', '96.1%');
INSERT INTO public."OverUnder" VALUES (534, 2.5, 2.5300000000000002, 1.54, 67, 'Full Time', '95.7%');
INSERT INTO public."OverUnder" VALUES (535, 2.75, 3.0, 1.3900000000000001, 67, 'Full Time', '95.0%');
INSERT INTO public."OverUnder" VALUES (536, 3.0, 3.92, 1.21, 67, 'Full Time', '92.5%');
INSERT INTO public."OverUnder" VALUES (537, 3.25, 4.359999999999999, 1.17, 67, 'Full Time', '92.2%');
INSERT INTO public."OverUnder" VALUES (538, 3.5, 5.1, 1.18, 67, 'Full Time', '95.8%');
INSERT INTO public."OverUnder" VALUES (539, 3.75, 6.2, 1.09, 67, 'Full Time', '92.7%');
INSERT INTO public."OverUnder" VALUES (540, 4.0, 8.7, 1.02, 67, 'Full Time', '91.3%');
INSERT INTO public."OverUnder" VALUES (541, 4.5, 11.5, 1.05, 67, 'Full Time', '96.2%');
INSERT INTO public."OverUnder" VALUES (542, 5.5, 23.0, 1.02, 67, 'Full Time', '97.7%');
INSERT INTO public."OverUnder" VALUES (543, 6.5, 51.0, NULL, 67, 'Full Time', '98.1%');
INSERT INTO public."OverUnder" VALUES (544, 0.5, 1.55, 2.5, 67, '1st Half', '95.7%');
INSERT INTO public."OverUnder" VALUES (545, 0.75, 1.81, 2.01, 67, '1st Half', '95.2%');
INSERT INTO public."OverUnder" VALUES (546, 1.0, 2.4299999999999997, 1.55, 67, '1st Half', '94.6%');
INSERT INTO public."OverUnder" VALUES (547, 1.25, 3.11, 1.3599999999999999, 67, '1st Half', '94.6%');
INSERT INTO public."OverUnder" VALUES (548, 1.5, 3.75, 1.3, 67, '1st Half', '96.5%');
INSERT INTO public."OverUnder" VALUES (549, 1.75, 4.9, 1.16, 67, '1st Half', '93.8%');
INSERT INTO public."OverUnder" VALUES (550, 2.0, 8.6, 1.05, 67, '1st Half', '93.6%');
INSERT INTO public."OverUnder" VALUES (551, 2.25, 9.3, 1.04, 67, '1st Half', '93.5%');
INSERT INTO public."OverUnder" VALUES (552, 2.5, 11.0, 1.05, 67, '1st Half', '95.9%');
INSERT INTO public."OverUnder" VALUES (553, 3.5, 34.0, 1.01, 67, '1st Half', '98.1%');
INSERT INTO public."OverUnder" VALUES (554, 4.5, 71.0, NULL, 67, '1st Half', '98.6%');
INSERT INTO public."OverUnder" VALUES (555, 0.5, 1.3599999999999999, 3.25, 67, '2nd Half', '95.9%');
INSERT INTO public."OverUnder" VALUES (556, 0.75, 1.49, 2.51, 67, '2nd Half', '93.5%');
INSERT INTO public."OverUnder" VALUES (557, 1.0, 1.76, 2.01, 67, '2nd Half', '93.8%');
INSERT INTO public."OverUnder" VALUES (558, 1.25, 2.21, 1.62, 67, '2nd Half', '93.5%');
INSERT INTO public."OverUnder" VALUES (559, 1.5, 2.7, 1.5, 67, '2nd Half', '96.4%');
INSERT INTO public."OverUnder" VALUES (560, 1.75, 3.4, 1.29, 67, '2nd Half', '93.5%');
INSERT INTO public."OverUnder" VALUES (561, 2.0, 5.3, 1.15, 67, '2nd Half', '94.5%');
INSERT INTO public."OverUnder" VALUES (562, 2.25, 5.9, 1.11, 67, '2nd Half', '93.4%');
INSERT INTO public."OverUnder" VALUES (563, 2.5, 6.5, 1.11, 67, '2nd Half', '94.8%');
INSERT INTO public."OverUnder" VALUES (564, 3.5, 19.0, 1.02, 67, '2nd Half', '96.8%');
INSERT INTO public."OverUnder" VALUES (565, 0.5, 1.11, 8.5, 70, 'Full Time', '98.2%');
INSERT INTO public."OverUnder" VALUES (566, 0.75, 1.08, 6.45, 70, 'Full Time', '92.5%');
INSERT INTO public."OverUnder" VALUES (567, 1.0, 1.1, 5.55, 70, 'Full Time', '91.8%');
INSERT INTO public."OverUnder" VALUES (568, 1.25, 1.31, 3.45, 70, 'Full Time', '94.9%');
INSERT INTO public."OverUnder" VALUES (569, 1.5, 1.5, 2.75, 70, 'Full Time', '97.1%');
INSERT INTO public."OverUnder" VALUES (570, 1.75, 1.63, 2.3200000000000003, 70, 'Full Time', '95.7%');
INSERT INTO public."OverUnder" VALUES (571, 2.0, 1.85, 2.0, 70, 'Full Time', '96.1%');
INSERT INTO public."OverUnder" VALUES (572, 2.25, 2.15, 1.73, 70, 'Full Time', '95.9%');
INSERT INTO public."OverUnder" VALUES (573, 2.5, 2.48, 1.5699999999999998, 70, 'Full Time', '96.1%');
INSERT INTO public."OverUnder" VALUES (574, 2.75, 2.95, 1.4, 70, 'Full Time', '94.9%');
INSERT INTO public."OverUnder" VALUES (575, 3.0, 3.64, 1.24, 70, 'Full Time', '92.5%');
INSERT INTO public."OverUnder" VALUES (576, 3.25, 4.0600000000000005, 1.2, 70, 'Full Time', '92.6%');
INSERT INTO public."OverUnder" VALUES (577, 3.5, 5.0, 1.2, 70, 'Full Time', '96.8%');
INSERT INTO public."OverUnder" VALUES (578, 3.75, 5.7, 1.1, 70, 'Full Time', '92.2%');
INSERT INTO public."OverUnder" VALUES (579, 4.0, 8.0, 1.03, 70, 'Full Time', '91.3%');
INSERT INTO public."OverUnder" VALUES (580, 4.25, NULL, NULL, 70, 'Full Time', '-');
INSERT INTO public."OverUnder" VALUES (581, 4.5, 11.0, 1.06, 70, 'Full Time', '96.7%');
INSERT INTO public."OverUnder" VALUES (582, 5.0, NULL, NULL, 70, 'Full Time', '-');
INSERT INTO public."OverUnder" VALUES (583, 5.5, 23.0, 1.02, 70, 'Full Time', '97.7%');
INSERT INTO public."OverUnder" VALUES (584, 6.5, 51.0, NULL, 70, 'Full Time', '98.1%');
INSERT INTO public."OverUnder" VALUES (585, 0.5, 1.53, 2.55, 70, '1st Half', '95.6%');
INSERT INTO public."OverUnder" VALUES (586, 0.75, 1.8, 2.06, 70, '1st Half', '96.1%');
INSERT INTO public."OverUnder" VALUES (587, 1.0, 2.34, 1.6, 70, '1st Half', '95.0%');
INSERT INTO public."OverUnder" VALUES (588, 1.25, 3.0, 1.3900000000000001, 70, '1st Half', '95.0%');
INSERT INTO public."OverUnder" VALUES (589, 1.5, 3.5, 1.33, 70, '1st Half', '96.4%');
INSERT INTO public."OverUnder" VALUES (590, 1.75, 4.640000000000001, 1.17, 70, '1st Half', '93.4%');
INSERT INTO public."OverUnder" VALUES (591, 2.0, 8.1, 1.06, 70, '1st Half', '93.7%');
INSERT INTO public."OverUnder" VALUES (592, 2.25, 8.7, 1.05, 70, '1st Half', '93.7%');
INSERT INTO public."OverUnder" VALUES (593, 2.5, 11.0, 1.06, 70, '1st Half', '96.7%');
INSERT INTO public."OverUnder" VALUES (594, 3.5, 34.0, 1.01, 70, '1st Half', '98.1%');
INSERT INTO public."OverUnder" VALUES (595, 4.5, 67.0, NULL, 70, '1st Half', '98.5%');
INSERT INTO public."OverUnder" VALUES (596, 0.5, 1.3599999999999999, 3.25, 70, '2nd Half', '95.9%');
INSERT INTO public."OverUnder" VALUES (597, 0.75, 1.46, 2.6, 70, '2nd Half', '93.5%');
INSERT INTO public."OverUnder" VALUES (598, 1.0, 1.72, 2.08, 70, '2nd Half', '94.1%');
INSERT INTO public."OverUnder" VALUES (599, 1.25, 2.13, 1.67, 70, '2nd Half', '93.6%');
INSERT INTO public."OverUnder" VALUES (600, 1.5, 2.65, 1.5, 70, '2nd Half', '95.8%');
INSERT INTO public."OverUnder" VALUES (601, 1.75, 3.2, 1.32, 70, '2nd Half', '93.5%');
INSERT INTO public."OverUnder" VALUES (602, 2.0, 4.95, 1.15, 70, '2nd Half', '93.3%');
INSERT INTO public."OverUnder" VALUES (603, 2.25, 5.55, 1.13, 70, '2nd Half', '93.9%');
INSERT INTO public."OverUnder" VALUES (604, 2.5, 6.5, 1.11, 70, '2nd Half', '94.8%');
INSERT INTO public."OverUnder" VALUES (605, 3.0, NULL, NULL, 70, '2nd Half', '-');
INSERT INTO public."OverUnder" VALUES (606, 3.5, 19.0, 1.02, 70, '2nd Half', '96.8%');
INSERT INTO public."OverUnder" VALUES (607, 0.5, 1.03, 18.0, 73, 'Full Time', '97.4%');
INSERT INTO public."OverUnder" VALUES (608, 1.0, 1.01, 13.0, 73, 'Full Time', '93.7%');
INSERT INTO public."OverUnder" VALUES (609, 1.25, 1.08, 6.45, 73, 'Full Time', '92.5%');
INSERT INTO public."OverUnder" VALUES (610, 1.5, 1.18, 5.1, 73, 'Full Time', '95.8%');
INSERT INTO public."OverUnder" VALUES (611, 1.75, 1.19, 4.16, 73, 'Full Time', '92.5%');
INSERT INTO public."OverUnder" VALUES (612, 2.0, 1.26, 3.9, 73, 'Full Time', '95.2%');
INSERT INTO public."OverUnder" VALUES (613, 2.25, 1.43, 2.83, 73, 'Full Time', '95.0%');
INSERT INTO public."OverUnder" VALUES (614, 2.5, 1.5899999999999999, 2.4, 73, 'Full Time', '95.6%');
INSERT INTO public."OverUnder" VALUES (615, 2.75, 1.73, 2.1100000000000003, 73, 'Full Time', '95.1%');
INSERT INTO public."OverUnder" VALUES (616, 3.0, 1.98, 1.88, 73, 'Full Time', '96.4%');
INSERT INTO public."OverUnder" VALUES (617, 3.25, 2.2, 1.67, 73, 'Full Time', '94.9%');
INSERT INTO public."OverUnder" VALUES (618, 3.5, 2.5, 1.55, 73, 'Full Time', '95.7%');
INSERT INTO public."OverUnder" VALUES (619, 3.75, 2.87, 1.42, 73, 'Full Time', '95.0%');
INSERT INTO public."OverUnder" VALUES (620, 4.0, 3.72, 1.28, 73, 'Full Time', '95.2%');
INSERT INTO public."OverUnder" VALUES (621, 4.25, 3.68, 1.23, 73, 'Full Time', '92.2%');
INSERT INTO public."OverUnder" VALUES (622, 4.5, 4.35, 1.22, 73, 'Full Time', '95.3%');
INSERT INTO public."OverUnder" VALUES (623, 4.75, 4.98, 1.1400000000000001, 73, 'Full Time', '92.8%');
INSERT INTO public."OverUnder" VALUES (624, 5.0, 6.65, 1.06, 73, 'Full Time', '91.4%');
INSERT INTO public."OverUnder" VALUES (625, 5.5, 9.0, 1.08, 73, 'Full Time', '96.4%');
INSERT INTO public."OverUnder" VALUES (626, 6.5, 19.0, 1.02, 73, 'Full Time', '96.8%');
INSERT INTO public."OverUnder" VALUES (627, 7.5, 34.0, 1.01, 73, 'Full Time', '98.1%');
INSERT INTO public."OverUnder" VALUES (628, 0.5, 1.3, 3.75, 73, '1st Half', '96.5%');
INSERT INTO public."OverUnder" VALUES (629, 0.75, 1.38, 3.0, 73, '1st Half', '94.5%');
INSERT INTO public."OverUnder" VALUES (630, 1.0, 1.56, 2.38, 73, '1st Half', '94.2%');
INSERT INTO public."OverUnder" VALUES (631, 1.25, 1.99, 1.83, 73, '1st Half', '95.3%');
INSERT INTO public."OverUnder" VALUES (632, 1.5, 2.4, 1.6, 73, '1st Half', '96.0%');
INSERT INTO public."OverUnder" VALUES (633, 1.75, 3.02, 1.3900000000000001, 73, '1st Half', '95.2%');
INSERT INTO public."OverUnder" VALUES (634, 2.0, 4.15, 1.21, 73, '1st Half', '93.7%');
INSERT INTO public."OverUnder" VALUES (635, 2.25, 4.68, 1.17, 73, '1st Half', '93.6%');
INSERT INTO public."OverUnder" VALUES (636, 2.5, 5.5, 1.17, 73, '1st Half', '96.5%');
INSERT INTO public."OverUnder" VALUES (637, 3.0, NULL, NULL, 73, '1st Half', '-');
INSERT INTO public."OverUnder" VALUES (638, 3.5, 15.0, 1.03, 73, '1st Half', '96.4%');
INSERT INTO public."OverUnder" VALUES (639, 4.5, 67.0, 1.01, 73, '1st Half', '99.5%');
INSERT INTO public."OverUnder" VALUES (640, 0.5, 1.2, 5.0, 73, '2nd Half', '96.8%');
INSERT INTO public."OverUnder" VALUES (641, 0.75, 1.2, 4.24, 73, '2nd Half', '93.5%');
INSERT INTO public."OverUnder" VALUES (642, 1.0, 1.27, 3.54, 73, '2nd Half', '93.5%');
INSERT INTO public."OverUnder" VALUES (643, 1.25, 1.53, 2.41, 73, '2nd Half', '93.6%');
INSERT INTO public."OverUnder" VALUES (644, 1.5, 1.85, 1.96, 73, '2nd Half', '95.2%');
INSERT INTO public."OverUnder" VALUES (645, 1.75, 2.05, 1.72, 73, '2nd Half', '93.5%');
INSERT INTO public."OverUnder" VALUES (646, 2.0, 2.5700000000000003, 1.47, 73, '2nd Half', '93.5%');
INSERT INTO public."OverUnder" VALUES (647, 2.25, 2.99, 1.3599999999999999, 73, '2nd Half', '93.5%');
INSERT INTO public."OverUnder" VALUES (648, 2.5, 3.75, 1.29, 73, '2nd Half', '96.0%');
INSERT INTO public."OverUnder" VALUES (649, 3.0, 6.0, 1.1, 73, '2nd Half', '93.0%');
INSERT INTO public."OverUnder" VALUES (650, 3.5, 9.0, 1.08, 73, '2nd Half', '96.4%');
INSERT INTO public."OverUnder" VALUES (651, 4.5, 21.0, 1.02, 73, '2nd Half', '97.3%');
INSERT INTO public."OverUnder" VALUES (652, 0.5, 1.04, 16.0, 76, 'Full Time', '97.7%');
INSERT INTO public."OverUnder" VALUES (653, 1.0, 1.01, 12.0, 76, 'Full Time', '93.2%');
INSERT INTO public."OverUnder" VALUES (654, 1.25, 1.09, 6.1, 76, 'Full Time', '92.5%');
INSERT INTO public."OverUnder" VALUES (655, 1.5, 1.2, 4.7, 76, 'Full Time', '95.6%');
INSERT INTO public."OverUnder" VALUES (656, 1.75, 1.22, 3.86, 76, 'Full Time', '92.7%');
INSERT INTO public."OverUnder" VALUES (657, 2.0, 1.28, 3.72, 76, 'Full Time', '95.2%');
INSERT INTO public."OverUnder" VALUES (658, 2.25, 1.46, 2.7199999999999998, 76, 'Full Time', '95.0%');
INSERT INTO public."OverUnder" VALUES (659, 2.5, 1.67, 2.31, 76, 'Full Time', '96.9%');
INSERT INTO public."OverUnder" VALUES (660, 2.75, 1.8, 2.0700000000000003, 76, 'Full Time', '96.3%');
INSERT INTO public."OverUnder" VALUES (661, 3.0, 2.05, 1.8199999999999998, 76, 'Full Time', '96.4%');
INSERT INTO public."OverUnder" VALUES (662, 3.25, 2.35, 1.6400000000000001, 76, 'Full Time', '96.6%');
INSERT INTO public."OverUnder" VALUES (663, 3.5, 2.63, 1.53, 76, 'Full Time', '96.7%');
INSERT INTO public."OverUnder" VALUES (664, 3.75, 3.05, 1.38, 76, 'Full Time', '95.0%');
INSERT INTO public."OverUnder" VALUES (665, 4.0, 3.9, 1.26, 76, 'Full Time', '95.2%');
INSERT INTO public."OverUnder" VALUES (666, 4.25, 3.98, 1.21, 76, 'Full Time', '92.8%');
INSERT INTO public."OverUnder" VALUES (667, 4.5, 4.8, 1.2, 76, 'Full Time', '96.0%');
INSERT INTO public."OverUnder" VALUES (668, 4.75, 5.35, 1.12, 76, 'Full Time', '92.6%');
INSERT INTO public."OverUnder" VALUES (669, 5.0, 7.2, 1.05, 76, 'Full Time', '91.6%');
INSERT INTO public."OverUnder" VALUES (670, 5.5, 10.0, 1.07, 76, 'Full Time', '96.7%');
INSERT INTO public."OverUnder" VALUES (671, 6.5, 19.0, 1.02, 76, 'Full Time', '96.8%');
INSERT INTO public."OverUnder" VALUES (672, 7.5, 41.0, NULL, 76, 'Full Time', '97.6%');
INSERT INTO public."OverUnder" VALUES (673, 0.5, 1.33, 3.7, 76, '1st Half', '97.8%');
INSERT INTO public."OverUnder" VALUES (674, 0.75, 1.43, 2.8600000000000003, 76, '1st Half', '95.3%');
INSERT INTO public."OverUnder" VALUES (675, 1.0, 1.65, 2.29, 76, '1st Half', '95.9%');
INSERT INTO public."OverUnder" VALUES (676, 1.25, 2.1100000000000003, 1.77, 76, '1st Half', '96.3%');
INSERT INTO public."OverUnder" VALUES (677, 1.5, 2.55, 1.6, 76, '1st Half', '98.3%');
INSERT INTO public."OverUnder" VALUES (678, 1.75, 3.25, 1.37, 76, '1st Half', '96.4%');
INSERT INTO public."OverUnder" VALUES (679, 2.0, 4.35, 1.19, 76, '1st Half', '93.4%');
INSERT INTO public."OverUnder" VALUES (680, 2.25, 4.9399999999999995, 1.15, 76, '1st Half', '93.3%');
INSERT INTO public."OverUnder" VALUES (681, 2.5, 5.6, 1.15, 76, '1st Half', '95.4%');
INSERT INTO public."OverUnder" VALUES (682, 3.0, NULL, NULL, 76, '1st Half', '-');
INSERT INTO public."OverUnder" VALUES (683, 3.5, 17.0, 1.03, 76, '1st Half', '97.1%');
INSERT INTO public."OverUnder" VALUES (684, 4.5, 67.0, 1.01, 76, '1st Half', '99.5%');
INSERT INTO public."OverUnder" VALUES (685, 0.5, 1.22, 5.0, 76, '2nd Half', '98.1%');
INSERT INTO public."OverUnder" VALUES (686, 0.75, 1.22, 4.0, 76, '2nd Half', '93.5%');
INSERT INTO public."OverUnder" VALUES (687, 1.0, 1.29, 3.47, 76, '2nd Half', '94.0%');
INSERT INTO public."OverUnder" VALUES (688, 1.25, 1.5699999999999998, 2.31, 76, '2nd Half', '93.5%');
INSERT INTO public."OverUnder" VALUES (689, 1.5, 1.9100000000000001, 1.9300000000000002, 76, '2nd Half', '96.0%');
INSERT INTO public."OverUnder" VALUES (690, 1.75, 2.13, 1.67, 76, '2nd Half', '93.6%');
INSERT INTO public."OverUnder" VALUES (691, 2.0, 2.7, 1.46, 76, '2nd Half', '94.8%');
INSERT INTO public."OverUnder" VALUES (692, 2.25, 3.15, 1.33, 76, '2nd Half', '93.5%');
INSERT INTO public."OverUnder" VALUES (693, 2.5, 4.0, 1.28, 76, '2nd Half', '97.0%');
INSERT INTO public."OverUnder" VALUES (694, 3.0, 6.0, 1.1, 76, '2nd Half', '93.0%');
INSERT INTO public."OverUnder" VALUES (695, 3.5, 9.0, 1.08, 76, '2nd Half', '96.4%');
INSERT INTO public."OverUnder" VALUES (696, 4.5, 21.0, 1.02, 76, '2nd Half', '97.3%');
INSERT INTO public."OverUnder" VALUES (697, 0.5, 1.06, 9.5, 79, 'Full Time', '95.4%');
INSERT INTO public."OverUnder" VALUES (698, 1.5, 1.33, 3.45, 79, 'Full Time', '96.0%');
INSERT INTO public."OverUnder" VALUES (699, 1.75, 1.38, 3.05, 79, 'Full Time', '95.0%');
INSERT INTO public."OverUnder" VALUES (700, 2.0, 1.48, 2.65, 79, 'Full Time', '95.0%');
INSERT INTO public."OverUnder" VALUES (701, 2.25, 1.72, 2.12, 79, 'Full Time', '95.0%');
INSERT INTO public."OverUnder" VALUES (702, 2.5, 2.0, 1.85, 79, 'Full Time', '96.1%');
INSERT INTO public."OverUnder" VALUES (703, 2.75, 2.2199999999999998, 1.6600000000000001, 79, 'Full Time', '95.0%');
INSERT INTO public."OverUnder" VALUES (704, 3.0, 2.7199999999999998, 1.46, 79, 'Full Time', '95.0%');
INSERT INTO public."OverUnder" VALUES (705, 3.25, 3.05, 1.38, 79, 'Full Time', '95.0%');
INSERT INTO public."OverUnder" VALUES (706, 3.5, 3.4, 1.32, 79, 'Full Time', '95.1%');
INSERT INTO public."OverUnder" VALUES (707, 4.5, 7.0, 1.11, 79, 'Full Time', '95.8%');
INSERT INTO public."OverUnder" VALUES (708, 5.5, 15.0, 1.03, 79, 'Full Time', '96.4%');
INSERT INTO public."OverUnder" VALUES (709, 6.5, 29.0, 1.01, 79, 'Full Time', '97.6%');
INSERT INTO public."OverUnder" VALUES (710, 0.5, 1.4, 3.0, 79, '1st Half', '95.5%');
INSERT INTO public."OverUnder" VALUES (711, 0.75, 1.55, 2.3, 79, '1st Half', '92.6%');
INSERT INTO public."OverUnder" VALUES (712, 1.0, 1.9300000000000002, 1.88, 79, '1st Half', '95.2%');
INSERT INTO public."OverUnder" VALUES (713, 1.25, 2.37, 1.52, 79, '1st Half', '92.6%');
INSERT INTO public."OverUnder" VALUES (714, 1.5, 2.85, 1.45, 79, '1st Half', '96.1%');
INSERT INTO public."OverUnder" VALUES (715, 2.5, 8.0, 1.1, 79, '1st Half', '96.7%');
INSERT INTO public."OverUnder" VALUES (716, 3.5, 23.0, 1.02, 79, '1st Half', '97.7%');
INSERT INTO public."OverUnder" VALUES (717, 4.5, 26.0, 1.01, 79, '1st Half', '97.2%');
INSERT INTO public."OverUnder" VALUES (718, 0.5, 1.3, 3.75, 79, '2nd Half', '96.5%');
INSERT INTO public."OverUnder" VALUES (719, 1.0, 1.43, 2.62, 79, '2nd Half', '92.5%');
INSERT INTO public."OverUnder" VALUES (720, 1.5, 2.25, 1.67, 79, '2nd Half', '95.9%');
INSERT INTO public."OverUnder" VALUES (721, 2.0, 3.4, 1.27, 79, '2nd Half', '92.5%');
INSERT INTO public."OverUnder" VALUES (722, 2.5, 5.0, 1.18, 79, '2nd Half', '95.5%');
INSERT INTO public."OverUnder" VALUES (723, 3.0, 8.2, 1.05, 79, '2nd Half', '93.1%');
INSERT INTO public."OverUnder" VALUES (724, 3.5, 13.0, 1.04, 79, '2nd Half', '96.3%');
INSERT INTO public."OverUnder" VALUES (725, 0.5, 1.08, 8.5, 82, 'Full Time', '95.8%');
INSERT INTO public."OverUnder" VALUES (726, 1.5, 1.4, 3.0, 82, 'Full Time', '95.5%');
INSERT INTO public."OverUnder" VALUES (727, 1.75, 1.49, 2.62, 82, 'Full Time', '95.0%');
INSERT INTO public."OverUnder" VALUES (728, 2.0, 1.6400000000000001, 2.25, 82, 'Full Time', '94.9%');
INSERT INTO public."OverUnder" VALUES (729, 2.25, 1.95, 1.9, 82, 'Full Time', '96.2%');
INSERT INTO public."OverUnder" VALUES (730, 2.5, 2.2, 1.6800000000000002, 82, 'Full Time', '95.3%');
INSERT INTO public."OverUnder" VALUES (731, 2.75, 2.55, 1.51, 82, 'Full Time', '94.8%');
INSERT INTO public."OverUnder" VALUES (732, 3.0, 3.25, 1.34, 82, 'Full Time', '94.9%');
INSERT INTO public."OverUnder" VALUES (733, 3.25, 3.63, 1.29, 82, 'Full Time', '95.2%');
INSERT INTO public."OverUnder" VALUES (734, 3.5, 4.0, 1.22, 82, 'Full Time', '93.5%');
INSERT INTO public."OverUnder" VALUES (735, 4.5, 9.0, 1.07, 82, 'Full Time', '95.6%');
INSERT INTO public."OverUnder" VALUES (736, 5.5, 19.0, 1.02, 82, 'Full Time', '96.8%');
INSERT INTO public."OverUnder" VALUES (737, 6.5, 41.0, NULL, 82, 'Full Time', '97.6%');
INSERT INTO public."OverUnder" VALUES (738, 0.5, 1.45, 2.63, 82, '1st Half', '93.5%');
INSERT INTO public."OverUnder" VALUES (739, 0.75, 1.6800000000000002, 2.17, 82, '1st Half', '94.7%');
INSERT INTO public."OverUnder" VALUES (740, 1.0, 2.0, 1.72, 82, '1st Half', '92.5%');
INSERT INTO public."OverUnder" VALUES (741, 1.25, 2.52, 1.46, 82, '1st Half', '92.4%');
INSERT INTO public."OverUnder" VALUES (742, 1.5, 3.4, 1.3599999999999999, 82, '1st Half', '97.1%');
INSERT INTO public."OverUnder" VALUES (743, 2.5, 10.0, 1.07, 82, '1st Half', '96.7%');
INSERT INTO public."OverUnder" VALUES (744, 3.5, 26.0, 1.01, 82, '1st Half', '97.2%');
INSERT INTO public."OverUnder" VALUES (745, 4.5, 29.0, NULL, 82, '1st Half', '96.7%');
INSERT INTO public."OverUnder" VALUES (746, 0.5, 1.33, 3.5, 82, '2nd Half', '96.4%');
INSERT INTO public."OverUnder" VALUES (747, 1.0, 1.5699999999999998, 2.25, 82, '2nd Half', '92.5%');
INSERT INTO public."OverUnder" VALUES (748, 1.5, 2.38, 1.5699999999999998, 82, '2nd Half', '94.6%');
INSERT INTO public."OverUnder" VALUES (749, 2.0, 4.15, 1.19, 82, '2nd Half', '92.5%');
INSERT INTO public."OverUnder" VALUES (750, 2.5, 5.5, 1.1400000000000001, 82, '2nd Half', '94.4%');
INSERT INTO public."OverUnder" VALUES (751, 3.0, 9.5, 1.03, 82, '2nd Half', '92.9%');
INSERT INTO public."OverUnder" VALUES (752, 3.5, 15.0, 1.03, 82, '2nd Half', '96.4%');
INSERT INTO public."OverUnder" VALUES (753, 0.5, 1.1, 7.0, 85, 'Full Time', '95.1%');
INSERT INTO public."OverUnder" VALUES (754, 1.25, 1.28, 3.72, 85, 'Full Time', '95.2%');
INSERT INTO public."OverUnder" VALUES (755, 1.5, 1.44, 2.8, 85, 'Full Time', '95.1%');
INSERT INTO public."OverUnder" VALUES (756, 1.75, 1.55, 2.45, 85, 'Full Time', '94.9%');
INSERT INTO public."OverUnder" VALUES (757, 2.0, 1.72, 2.12, 85, 'Full Time', '95.0%');
INSERT INTO public."OverUnder" VALUES (758, 2.25, 2.05, 1.8, 85, 'Full Time', '95.8%');
INSERT INTO public."OverUnder" VALUES (759, 2.5, 2.3200000000000003, 1.6, 85, 'Full Time', '94.7%');
INSERT INTO public."OverUnder" VALUES (760, 2.75, 2.7199999999999998, 1.46, 85, 'Full Time', '95.0%');
INSERT INTO public."OverUnder" VALUES (761, 3.0, 3.55, 1.3, 85, 'Full Time', '95.2%');
INSERT INTO public."OverUnder" VALUES (762, 3.5, 4.0, 1.22, 85, 'Full Time', '93.5%');
INSERT INTO public."OverUnder" VALUES (763, 4.5, 10.0, 1.06, 85, 'Full Time', '95.8%');
INSERT INTO public."OverUnder" VALUES (764, 5.5, 21.0, 1.02, 85, 'Full Time', '97.3%');
INSERT INTO public."OverUnder" VALUES (765, 6.5, 51.0, NULL, 85, 'Full Time', '98.1%');
INSERT INTO public."OverUnder" VALUES (766, 0.5, 1.5, 2.63, 85, '1st Half', '95.5%');
INSERT INTO public."OverUnder" VALUES (767, 0.75, 1.73, 2.08, 85, '1st Half', '94.4%');
INSERT INTO public."OverUnder" VALUES (768, 1.0, 2.25, 1.63, 85, '1st Half', '94.5%');
INSERT INTO public."OverUnder" VALUES (769, 1.25, 2.7, 1.4, 85, '1st Half', '92.2%');
INSERT INTO public."OverUnder" VALUES (770, 1.5, 3.4, 1.33, 85, '1st Half', '95.6%');
INSERT INTO public."OverUnder" VALUES (771, 2.5, 10.0, 1.07, 85, '1st Half', '96.7%');
INSERT INTO public."OverUnder" VALUES (772, 3.5, 17.0, 1.01, 85, '1st Half', '95.3%');
INSERT INTO public."OverUnder" VALUES (773, 4.5, 29.0, NULL, 85, '1st Half', '96.7%');
INSERT INTO public."OverUnder" VALUES (774, 0.5, 1.3599999999999999, 3.4, 85, '2nd Half', '97.1%');
INSERT INTO public."OverUnder" VALUES (775, 1.0, 1.6, 2.2, 85, '2nd Half', '92.6%');
INSERT INTO public."OverUnder" VALUES (776, 1.5, 2.5, 1.5699999999999998, 85, '2nd Half', '96.4%');
INSERT INTO public."OverUnder" VALUES (777, 2.0, 4.3, 1.18, 85, '2nd Half', '92.6%');
INSERT INTO public."OverUnder" VALUES (778, 2.5, 5.5, 1.1400000000000001, 85, '2nd Half', '94.4%');
INSERT INTO public."OverUnder" VALUES (779, 3.5, 15.0, 1.03, 85, '2nd Half', '96.4%');
INSERT INTO public."OverUnder" VALUES (780, 0.5, 1.05, 11.0, 88, 'Full Time', '95.9%');
INSERT INTO public."OverUnder" VALUES (781, 1.5, 1.26, 3.75, 88, 'Full Time', '94.3%');
INSERT INTO public."OverUnder" VALUES (782, 1.75, 1.34, 3.25, 88, 'Full Time', '94.9%');
INSERT INTO public."OverUnder" VALUES (783, 2.0, 1.42, 2.87, 88, 'Full Time', '95.0%');
INSERT INTO public."OverUnder" VALUES (784, 2.25, 1.6400000000000001, 2.25, 88, 'Full Time', '94.9%');
INSERT INTO public."OverUnder" VALUES (785, 2.5, 1.85, 2.0, 88, 'Full Time', '96.1%');
INSERT INTO public."OverUnder" VALUES (786, 2.75, 2.09, 1.74, 88, 'Full Time', '95.0%');
INSERT INTO public."OverUnder" VALUES (787, 3.0, 2.48, 1.54, 88, 'Full Time', '95.0%');
INSERT INTO public."OverUnder" VALUES (788, 3.25, 2.83, 1.43, 88, 'Full Time', '95.0%');
INSERT INTO public."OverUnder" VALUES (789, 3.5, 3.25, 1.3599999999999999, 88, 'Full Time', '95.9%');
INSERT INTO public."OverUnder" VALUES (790, 3.75, 3.8, 1.27, 88, 'Full Time', '95.2%');
INSERT INTO public."OverUnder" VALUES (791, 4.5, 6.0, 1.1400000000000001, 88, 'Full Time', '95.8%');
INSERT INTO public."OverUnder" VALUES (792, 5.5, 13.0, 1.04, 88, 'Full Time', '96.3%');
INSERT INTO public."OverUnder" VALUES (793, 6.5, 26.0, 1.01, 88, 'Full Time', '97.2%');
INSERT INTO public."OverUnder" VALUES (794, 7.5, 51.0, NULL, 88, 'Full Time', '98.1%');
INSERT INTO public."OverUnder" VALUES (795, 0.5, 1.3599999999999999, 3.25, 88, '1st Half', '95.9%');
INSERT INTO public."OverUnder" VALUES (796, 0.75, 1.47, 2.5, 88, '1st Half', '92.6%');
INSERT INTO public."OverUnder" VALUES (797, 1.0, 1.78, 2.0300000000000002, 88, '1st Half', '94.8%');
INSERT INTO public."OverUnder" VALUES (798, 1.25, 2.17, 1.6099999999999999, 88, '1st Half', '92.4%');
INSERT INTO public."OverUnder" VALUES (799, 1.5, 2.63, 1.5, 88, '1st Half', '95.5%');
INSERT INTO public."OverUnder" VALUES (800, 1.75, 3.25, 1.29, 88, '1st Half', '92.3%');
INSERT INTO public."OverUnder" VALUES (801, 2.5, 7.0, 1.13, 88, '1st Half', '97.3%');
INSERT INTO public."OverUnder" VALUES (802, 3.5, 19.0, 1.02, 88, '1st Half', '96.8%');
INSERT INTO public."OverUnder" VALUES (803, 4.5, 21.0, 1.01, 88, '1st Half', '96.4%');
INSERT INTO public."OverUnder" VALUES (804, 0.5, 1.29, 4.0, 88, '2nd Half', '97.5%');
INSERT INTO public."OverUnder" VALUES (805, 1.0, 1.41, 2.6799999999999997, 88, '2nd Half', '92.4%');
INSERT INTO public."OverUnder" VALUES (806, 1.5, 2.1, 1.73, 88, '2nd Half', '94.9%');
INSERT INTO public."OverUnder" VALUES (807, 2.0, 3.25, 1.29, 88, '2nd Half', '92.3%');
INSERT INTO public."OverUnder" VALUES (808, 2.5, 4.33, 1.2, 88, '2nd Half', '94.0%');
INSERT INTO public."OverUnder" VALUES (809, 3.0, 7.85, 1.05, 88, '2nd Half', '92.6%');
INSERT INTO public."OverUnder" VALUES (810, 3.5, 11.0, 1.05, 88, '2nd Half', '95.9%');
INSERT INTO public."OverUnder" VALUES (811, 4.5, NULL, NULL, 88, '2nd Half', '-');
INSERT INTO public."OverUnder" VALUES (812, 0.5, 1.07, 8.5, 91, 'Full Time', '95.0%');
INSERT INTO public."OverUnder" VALUES (813, 1.0, 1.1, 7.0, 91, 'Full Time', '95.1%');
INSERT INTO public."OverUnder" VALUES (814, 1.5, 1.37, 3.1, 91, 'Full Time', '95.0%');
INSERT INTO public."OverUnder" VALUES (815, 1.75, 1.46, 2.7199999999999998, 91, 'Full Time', '95.0%');
INSERT INTO public."OverUnder" VALUES (816, 2.0, 1.6, 2.34, 91, 'Full Time', '95.0%');
INSERT INTO public."OverUnder" VALUES (817, 2.25, 1.9, 1.95, 91, 'Full Time', '96.2%');
INSERT INTO public."OverUnder" VALUES (818, 2.5, 2.1399999999999997, 1.71, 91, 'Full Time', '95.0%');
INSERT INTO public."OverUnder" VALUES (819, 2.75, 2.48, 1.54, 91, 'Full Time', '95.0%');
INSERT INTO public."OverUnder" VALUES (820, 3.0, 3.1, 1.37, 91, 'Full Time', '95.0%');
INSERT INTO public."OverUnder" VALUES (821, 3.25, 3.45, 1.31, 91, 'Full Time', '94.9%');
INSERT INTO public."OverUnder" VALUES (822, 3.5, 3.75, 1.25, 91, 'Full Time', '93.8%');
INSERT INTO public."OverUnder" VALUES (823, 4.5, 8.0, 1.08, 91, 'Full Time', '95.2%');
INSERT INTO public."OverUnder" VALUES (824, 5.5, 19.0, 1.02, 91, 'Full Time', '96.8%');
INSERT INTO public."OverUnder" VALUES (825, 6.5, 41.0, NULL, 91, 'Full Time', '97.6%');
INSERT INTO public."OverUnder" VALUES (826, 0.5, 1.44, 2.63, 91, '1st Half', '93.1%');
INSERT INTO public."OverUnder" VALUES (827, 0.75, 1.6099999999999999, 2.17, 91, '1st Half', '92.4%');
INSERT INTO public."OverUnder" VALUES (828, 1.0, 2.08, 1.73, 91, '1st Half', '94.4%');
INSERT INTO public."OverUnder" VALUES (829, 1.25, 2.52, 1.46, 91, '1st Half', '92.4%');
INSERT INTO public."OverUnder" VALUES (830, 1.5, 3.25, 1.33, 91, '1st Half', '94.4%');
INSERT INTO public."OverUnder" VALUES (831, 2.5, 9.0, 1.07, 91, '1st Half', '95.6%');
INSERT INTO public."OverUnder" VALUES (832, 3.5, 26.0, 1.01, 91, '1st Half', '97.2%');
INSERT INTO public."OverUnder" VALUES (833, 0.5, 1.29, 3.5, 91, '2nd Half', '94.3%');
INSERT INTO public."OverUnder" VALUES (834, 1.0, 1.52, 2.37, 91, '2nd Half', '92.6%');
INSERT INTO public."OverUnder" VALUES (835, 1.5, 2.25, 1.5699999999999998, 91, '2nd Half', '92.5%');
INSERT INTO public."OverUnder" VALUES (836, 2.0, 3.9, 1.21, 91, '2nd Half', '92.3%');
INSERT INTO public."OverUnder" VALUES (837, 2.5, 5.5, 1.1400000000000001, 91, '2nd Half', '94.4%');
INSERT INTO public."OverUnder" VALUES (838, 3.0, 9.0, 1.03, 91, '2nd Half', '92.4%');
INSERT INTO public."OverUnder" VALUES (839, 3.5, 15.0, 1.03, 91, '2nd Half', '96.4%');
INSERT INTO public."OverUnder" VALUES (840, 0.5, 1.1, 7.5, 94, 'Full Time', '95.9%');
INSERT INTO public."OverUnder" VALUES (841, 1.25, 1.28, 3.72, 94, 'Full Time', '95.2%');
INSERT INTO public."OverUnder" VALUES (842, 1.5, 1.44, 2.8, 94, 'Full Time', '95.1%');
INSERT INTO public."OverUnder" VALUES (843, 1.75, 1.55, 2.45, 94, 'Full Time', '94.9%');
INSERT INTO public."OverUnder" VALUES (844, 2.0, 1.72, 2.12, 94, 'Full Time', '95.0%');
INSERT INTO public."OverUnder" VALUES (845, 2.25, 2.05, 1.8, 94, 'Full Time', '95.8%');
INSERT INTO public."OverUnder" VALUES (846, 2.5, 2.3200000000000003, 1.6099999999999999, 94, 'Full Time', '95.0%');
INSERT INTO public."OverUnder" VALUES (847, 2.75, 2.7199999999999998, 1.46, 94, 'Full Time', '95.0%');
INSERT INTO public."OverUnder" VALUES (848, 3.0, 3.55, 1.3, 94, 'Full Time', '95.2%');
INSERT INTO public."OverUnder" VALUES (849, 3.25, NULL, NULL, 94, 'Full Time', '-');
INSERT INTO public."OverUnder" VALUES (850, 3.5, 4.33, 1.22, 94, 'Full Time', '95.2%');
INSERT INTO public."OverUnder" VALUES (851, 4.5, 10.0, 1.06, 94, 'Full Time', '95.8%');
INSERT INTO public."OverUnder" VALUES (852, 5.5, 21.0, 1.02, 94, 'Full Time', '97.3%');
INSERT INTO public."OverUnder" VALUES (853, 6.5, 51.0, NULL, 94, 'Full Time', '98.1%');
INSERT INTO public."OverUnder" VALUES (854, 0.5, 1.5, 2.63, 94, '1st Half', '95.5%');
INSERT INTO public."OverUnder" VALUES (855, 0.75, 1.73, 2.08, 94, '1st Half', '94.4%');
INSERT INTO public."OverUnder" VALUES (856, 1.0, 2.25, 1.63, 94, '1st Half', '94.5%');
INSERT INTO public."OverUnder" VALUES (857, 1.25, 2.7, 1.4, 94, '1st Half', '92.2%');
INSERT INTO public."OverUnder" VALUES (858, 1.5, 3.5, 1.33, 94, '1st Half', '96.4%');
INSERT INTO public."OverUnder" VALUES (859, 2.5, 10.0, 1.06, 94, '1st Half', '95.8%');
INSERT INTO public."OverUnder" VALUES (860, 3.5, 17.0, 1.01, 94, '1st Half', '95.3%');
INSERT INTO public."OverUnder" VALUES (861, 4.5, 29.0, NULL, 94, '1st Half', '96.7%');
INSERT INTO public."OverUnder" VALUES (862, 0.5, 1.3599999999999999, 3.4, 94, '2nd Half', '97.1%');
INSERT INTO public."OverUnder" VALUES (863, 1.0, 1.6, 2.2, 94, '2nd Half', '92.6%');
INSERT INTO public."OverUnder" VALUES (864, 1.5, 2.3899999999999997, 1.53, 94, '2nd Half', '93.3%');
INSERT INTO public."OverUnder" VALUES (865, 2.0, 4.3, 1.18, 94, '2nd Half', '92.6%');
INSERT INTO public."OverUnder" VALUES (866, 2.5, 5.5, 1.1400000000000001, 94, '2nd Half', '94.4%');
INSERT INTO public."OverUnder" VALUES (867, 3.0, NULL, NULL, 94, '2nd Half', '-');
INSERT INTO public."OverUnder" VALUES (868, 3.5, 15.0, 1.03, 94, '2nd Half', '96.4%');
INSERT INTO public."OverUnder" VALUES (869, 0.5, 1.1, 7.5, 97, 'Full Time', '95.9%');
INSERT INTO public."OverUnder" VALUES (870, 1.25, 1.27, 3.8, 97, 'Full Time', '95.2%');
INSERT INTO public."OverUnder" VALUES (871, 1.5, 1.43, 2.83, 97, 'Full Time', '95.0%');
INSERT INTO public."OverUnder" VALUES (872, 1.75, 1.54, 2.48, 97, 'Full Time', '95.0%');
INSERT INTO public."OverUnder" VALUES (873, 2.0, 1.72, 2.12, 97, 'Full Time', '95.0%');
INSERT INTO public."OverUnder" VALUES (874, 2.25, 2.05, 1.8, 97, 'Full Time', '95.8%');
INSERT INTO public."OverUnder" VALUES (875, 2.5, 2.3, 1.62, 97, 'Full Time', '95.1%');
INSERT INTO public."OverUnder" VALUES (876, 2.75, 2.7199999999999998, 1.46, 97, 'Full Time', '95.0%');
INSERT INTO public."OverUnder" VALUES (877, 3.0, 3.55, 1.3, 97, 'Full Time', '95.2%');
INSERT INTO public."OverUnder" VALUES (878, 3.5, 4.33, 1.22, 97, 'Full Time', '95.2%');
INSERT INTO public."OverUnder" VALUES (879, 4.5, 10.0, 1.06, 97, 'Full Time', '95.8%');
INSERT INTO public."OverUnder" VALUES (880, 5.5, 21.0, 1.02, 97, 'Full Time', '97.3%');
INSERT INTO public."OverUnder" VALUES (881, 6.5, 51.0, NULL, 97, 'Full Time', '98.1%');
INSERT INTO public."OverUnder" VALUES (882, 0.5, 1.5, 2.63, 97, '1st Half', '95.5%');
INSERT INTO public."OverUnder" VALUES (883, 0.75, 1.73, 2.08, 97, '1st Half', '94.4%');
INSERT INTO public."OverUnder" VALUES (884, 1.0, 2.25, 1.63, 97, '1st Half', '94.5%');
INSERT INTO public."OverUnder" VALUES (885, 1.25, 2.7, 1.4, 97, '1st Half', '92.2%');
INSERT INTO public."OverUnder" VALUES (886, 1.5, 3.4, 1.3599999999999999, 97, '1st Half', '97.1%');
INSERT INTO public."OverUnder" VALUES (887, 2.5, 10.0, 1.07, 97, '1st Half', '96.7%');
INSERT INTO public."OverUnder" VALUES (888, 3.5, 17.0, 1.01, 97, '1st Half', '95.3%');
INSERT INTO public."OverUnder" VALUES (889, 4.5, 29.0, NULL, 97, '1st Half', '96.7%');
INSERT INTO public."OverUnder" VALUES (890, 0.5, 1.3599999999999999, 3.4, 97, '2nd Half', '97.1%');
INSERT INTO public."OverUnder" VALUES (891, 1.0, 1.6, 2.2, 97, '2nd Half', '92.6%');
INSERT INTO public."OverUnder" VALUES (892, 1.5, 2.5, 1.53, 97, '2nd Half', '94.9%');
INSERT INTO public."OverUnder" VALUES (893, 2.0, 4.3, 1.18, 97, '2nd Half', '92.6%');
INSERT INTO public."OverUnder" VALUES (894, 2.5, 6.0, 1.13, 97, '2nd Half', '95.1%');
INSERT INTO public."OverUnder" VALUES (895, 3.5, 17.0, 1.03, 97, '2nd Half', '97.1%');


--
-- TOC entry 3022 (class 0 OID 0)
-- Dependencies: 201
-- Name: Match_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Match_id_seq"', 99, true);


--
-- TOC entry 3023 (class 0 OID 0)
-- Dependencies: 203
-- Name: OverUnder_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."OverUnder_id_seq"', 895, true);


--
-- TOC entry 2872 (class 2606 OID 24763)
-- Name: OverUnder OverUnder_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."OverUnder"
    ADD CONSTRAINT "OverUnder_pkey" PRIMARY KEY (id) INCLUDE (value, match_id, half, id);


--
-- TOC entry 2874 (class 2606 OID 24765)
-- Name: OverUnder OverUnder_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."OverUnder"
    ADD CONSTRAINT "OverUnder_unique" UNIQUE (value, half, match_id);


--
-- TOC entry 2868 (class 2606 OID 24734)
-- Name: Match match_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Match"
    ADD CONSTRAINT match_pk PRIMARY KEY (id);


--
-- TOC entry 2870 (class 2606 OID 24736)
-- Name: Match match_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Match"
    ADD CONSTRAINT match_unique UNIQUE (home_team, guest_team, date_time);


--
-- TOC entry 2875 (class 2606 OID 24739)
-- Name: OverUnder over_under_match_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."OverUnder"
    ADD CONSTRAINT over_under_match_id_fk FOREIGN KEY (match_id) REFERENCES public."Match"(id) NOT VALID;


--
-- TOC entry 3017 (class 0 OID 0)
-- Dependencies: 5
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- TOC entry 3018 (class 0 OID 0)
-- Dependencies: 200
-- Name: TABLE "Match"; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE public."Match" FROM postgres;


--
-- TOC entry 3020 (class 0 OID 0)
-- Dependencies: 202
-- Name: TABLE "OverUnder"; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE public."OverUnder" FROM postgres;
GRANT ALL ON TABLE public."OverUnder" TO postgres WITH GRANT OPTION;


--
-- TOC entry 1722 (class 826 OID 24717)
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: -; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres REVOKE ALL ON TABLES  FROM postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres GRANT ALL ON TABLES  TO postgres WITH GRANT OPTION;


-- Completed on 2023-02-09 04:13:25

--
-- PostgreSQL database dump complete
--

-- Completed on 2023-02-09 04:13:25

--
-- PostgreSQL database cluster dump complete
--


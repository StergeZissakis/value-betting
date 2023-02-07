--
-- PostgreSQL database dump
--

-- Dumped from database version 13.9 (Debian 13.9-0+deb11u1)
-- Dumped by pg_dump version 15.1

-- Started on 2023-02-07 06:18:40

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

DROP DATABASE bettor;
--
-- TOC entry 3005 (class 1262 OID 16384)
-- Name: bettor; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE bettor WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'en_GB.UTF-8';


ALTER DATABASE bettor OWNER TO postgres;

\connect bettor

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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 201 (class 1259 OID 24578)
-- Name: Team; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Team" (
    id bigint NOT NULL,
    name character varying NOT NULL,
    english_name character varying
);


ALTER TABLE public."Team" OWNER TO postgres;

--
-- TOC entry 200 (class 1259 OID 24576)
-- Name: Team_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Team_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."Team_id_seq" OWNER TO postgres;

--
-- TOC entry 3006 (class 0 OID 0)
-- Dependencies: 200
-- Name: Team_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Team_id_seq" OWNED BY public."Team".id;


--
-- TOC entry 2865 (class 2604 OID 24581)
-- Name: Team id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Team" ALTER COLUMN id SET DEFAULT nextval('public."Team_id_seq"'::regclass);


--
-- TOC entry 2999 (class 0 OID 24578)
-- Dependencies: 201
-- Data for Name: Team; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 3007 (class 0 OID 0)
-- Dependencies: 200
-- Name: Team_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Team_id_seq"', 1, false);


--
-- TOC entry 2867 (class 2606 OID 24586)
-- Name: Team pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Team"
    ADD CONSTRAINT pk PRIMARY KEY (id);


-- Completed on 2023-02-07 06:18:40

--
-- PostgreSQL database dump complete
--


--
-- PostgreSQL database dump
--

-- Dumped from database version 13.9 (Debian 13.9-0+deb11u1)
-- Dumped by pg_dump version 15.1

-- Started on 2023-02-07 18:06:21

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
--SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', 'public', false);
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
-- TOC entry 626 (class 1247 OID 24614)
-- Name: MatchPart; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public."MatchPart" AS ENUM (
    'match',
    'frist_half',
    'second_half',
    'first_over_time',
    'second_over_time',
    'frist_penalties',
    'second_penalties'
);


ALTER TYPE public."MatchPart" OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 203 (class 1259 OID 24655)
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
-- TOC entry 202 (class 1259 OID 24653)
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
-- TOC entry 3016 (class 0 OID 0)
-- Dependencies: 202
-- Name: Match_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Match_id_seq" OWNED BY public."Match".id;


--
-- TOC entry 201 (class 1259 OID 24631)
-- Name: OverUnder; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."OverUnder" (
    id bigint NOT NULL,
    half public."MatchPart" NOT NULL,
    value numeric(4,4) NOT NULL,
    over numeric(4,4),
    under numeric(4,4),
    payout numeric(4,4),
    match_id bigint NOT NULL
);


ALTER TABLE public."OverUnder" OWNER TO postgres;

--
-- TOC entry 200 (class 1259 OID 24629)
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
-- TOC entry 3017 (class 0 OID 0)
-- Dependencies: 200
-- Name: OverUnder_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."OverUnder_id_seq" OWNED BY public."OverUnder".id;


--
-- TOC entry 2865 (class 2604 OID 24658)
-- Name: Match id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Match" ALTER COLUMN id SET DEFAULT nextval('public."Match_id_seq"'::regclass);


--
-- TOC entry 2864 (class 2604 OID 24634)
-- Name: OverUnder id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."OverUnder" ALTER COLUMN id SET DEFAULT nextval('public."OverUnder_id_seq"'::regclass);


--
-- TOC entry 3006 (class 0 OID 24655)
-- Dependencies: 203
-- Data for Name: Match; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 3004 (class 0 OID 24631)
-- Dependencies: 201
-- Data for Name: OverUnder; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 3018 (class 0 OID 0)
-- Dependencies: 202
-- Name: Match_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Match_id_seq"', 1, false);


--
-- TOC entry 3019 (class 0 OID 0)
-- Dependencies: 200
-- Name: OverUnder_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."OverUnder_id_seq"', 1, false);


--
-- TOC entry 2869 (class 2606 OID 24663)
-- Name: Match match_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Match"
    ADD CONSTRAINT match_pk PRIMARY KEY (id);


--
-- TOC entry 2871 (class 2606 OID 24665)
-- Name: Match match_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Match"
    ADD CONSTRAINT match_unique UNIQUE (home_team, guest_team, date_time);


--
-- TOC entry 2867 (class 2606 OID 24672)
-- Name: OverUnder over_under_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."OverUnder"
    ADD CONSTRAINT over_under_pk PRIMARY KEY (id) INCLUDE (half, value, match_id);


--
-- TOC entry 2872 (class 2606 OID 24666)
-- Name: OverUnder over_under_match_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."OverUnder"
    ADD CONSTRAINT over_under_match_id_fk FOREIGN KEY (match_id) REFERENCES public."Match"(id) NOT VALID;



--
-- TOC entry 3014 (class 0 OID 0)
-- Dependencies: 4
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- TOC entry 3015 (class 0 OID 0)
-- Dependencies: 203
-- Name: TABLE "Match"; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE public."Match" FROM postgres;


--
-- TOC entry 1721 (class 826 OID 24674)
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: -; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres REVOKE ALL ON TABLES  FROM postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres GRANT ALL ON TABLES  TO postgres WITH GRANT OPTION;


-- Completed on 2023-02-07 18:06:21

--
-- PostgreSQL database dump complete
--


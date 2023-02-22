--
-- PostgreSQL database dump
--

-- Dumped from database version 13.9 (Debian 13.9-0+deb11u1)
-- Dumped by pg_dump version 13.9 (Debian 13.9-0+deb11u1)

-- Started on 2023-02-22 16:08:51 EET

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

DROP DATABASE IF EXISTS postgres;
--
-- TOC entry 3083 (class 1262 OID 13445)
-- Name: postgres; Type: DATABASE; Schema: -; Owner: -
--

CREATE DATABASE postgres WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE = 'en_GB.UTF-8';


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
-- TOC entry 3084 (class 0 OID 0)
-- Dependencies: 3083
-- Name: DATABASE postgres; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON DATABASE postgres IS 'default administrative connection database';


--
-- TOC entry 671 (class 1247 OID 25025)
-- Name: BetResult; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."BetResult" AS ENUM (
    'Won',
    'Lost'
);


--
-- TOC entry 639 (class 1247 OID 24746)
-- Name: MatchTime; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."MatchTime" AS ENUM (
    'Full Time',
    '1st Half',
    '2nd Half'
);


--
-- TOC entry 642 (class 1247 OID 24790)
-- Name: OverUnderType; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."OverUnderType" AS ENUM (
    'Over',
    'Under'
);


--
-- TOC entry 212 (class 1255 OID 24984)
-- Name: ArchivePastMatches(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public."ArchivePastMatches"() RETURNS void
    LANGUAGE sql
    AS $$
INSERT INTO public."OverUnderHistorical"("Home_Team", "Guest_Team", "Date_Time", "Type", "Half", "Goals", "Odds_bet", "Margin", "Payout", "Bet_link")
SELECT SPLIT_PART(Event, ' - ', 1), SPLIT_PART(Event, ' - ', 2), DateTime, Type, Half, Goals, SafariOdds, Margin, SafariPayout, bookie 
FROM   public."PortalSafariBets"
WHERE  DateTime + interval '5 hours' < now();

DELETE FROM public."OddsPortalMatch" where date_time + interval '5 hours' < now();
DELETE FROM public."OddsSafariMatch" where date_time + interval '5 hours' < now();$$;


--
-- TOC entry 224 (class 1255 OID 25029)
-- Name: CalculateOverUnderResults(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public."CalculateOverUnderResults"() RETURNS void
    LANGUAGE sql
    AS $$UPDATE	public."OverUnderHistorical" AS t SET Won = 'Won'
WHERE 	(t."Home_Team_Goals" + t."Guest_Team_Goals") > t."Goals" AND  t."Type" = 'Over' AND t."Half" = 'Full Time';

UPDATE	public."OverUnderHistorical" AS t SET Won = 'Won'
WHERE 	(t."Home_Team_Goals" + t."Guest_Team_Goals") < t."Goals" AND  t."Type" = 'Under' AND t."Half" = 'Full Time';
$$;


--
-- TOC entry 210 (class 1255 OID 24779)
-- Name: update_updated_on_Match(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public."update_updated_on_Match"() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated = now();
    RETURN NEW;
END;
$$;


--
-- TOC entry 211 (class 1255 OID 24778)
-- Name: update_updated_on_OverUnder(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public."update_updated_on_OverUnder"() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated = now();
    RETURN NEW;
END;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 200 (class 1259 OID 24718)
-- Name: OddsPortalMatch; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."OddsPortalMatch" (
    id bigint NOT NULL,
    home_team character varying NOT NULL,
    guest_team character varying NOT NULL,
    date_time timestamp with time zone NOT NULL,
    created timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- TOC entry 201 (class 1259 OID 24724)
-- Name: Match_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."Match_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3086 (class 0 OID 0)
-- Dependencies: 201
-- Name: Match_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."Match_id_seq" OWNED BY public."OddsPortalMatch".id;


--
-- TOC entry 202 (class 1259 OID 24726)
-- Name: OddsPortalOverUnder; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."OddsPortalOverUnder" (
    id bigint NOT NULL,
    goals numeric NOT NULL,
    odds numeric(100,2),
    match_id bigint NOT NULL,
    half public."MatchTime" NOT NULL,
    payout character varying,
    created timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    type public."OverUnderType" NOT NULL,
    bet_links character varying[]
);


--
-- TOC entry 204 (class 1259 OID 24822)
-- Name: OddsSafariMatch; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."OddsSafariMatch" (
)
INHERITS (public."OddsPortalMatch");


--
-- TOC entry 205 (class 1259 OID 24836)
-- Name: OddsSafariOverUnder; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."OddsSafariOverUnder" (
)
INHERITS (public."OddsPortalOverUnder");


--
-- TOC entry 208 (class 1259 OID 24966)
-- Name: OverUnderHistorical; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."OverUnderHistorical" (
    id bigint NOT NULL,
    "Date_Time" timestamp with time zone NOT NULL,
    "Type" public."OverUnderType" NOT NULL,
    "Goals" numeric NOT NULL,
    "Odds_bet" numeric NOT NULL,
    "Margin" numeric NOT NULL,
    "Payout" character varying NOT NULL,
    "Bet_link" character varying NOT NULL,
    "Home_Team" character varying NOT NULL,
    "Guest_Team" character varying NOT NULL,
    "Home_Team_Goals" smallint,
    "Guest_Team_Goals" smallint,
    "Half" public."MatchTime",
    won public."BetResult"
);


--
-- TOC entry 207 (class 1259 OID 24964)
-- Name: OverUnderHistorical_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."OverUnderHistorical_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3091 (class 0 OID 0)
-- Dependencies: 207
-- Name: OverUnderHistorical_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."OverUnderHistorical_id_seq" OWNED BY public."OverUnderHistorical".id;


--
-- TOC entry 203 (class 1259 OID 24729)
-- Name: OverUnder_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."OverUnder_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3092 (class 0 OID 0)
-- Dependencies: 203
-- Name: OverUnder_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."OverUnder_id_seq" OWNED BY public."OddsPortalOverUnder".id;


--
-- TOC entry 206 (class 1259 OID 24910)
-- Name: PortalSafariMatch; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public."PortalSafariMatch" AS
 SELECT portal.id AS portal_id,
    portal.date_time AS portal_time,
    portal.home_team AS portal_home_team,
    portal.guest_team AS portal_guest_team,
    safari.id AS safari_id,
    safari.date_time AS safari_time,
    safari.home_team AS safari_home_team,
    safari.guest_team AS safari_guest_team
   FROM (public."OddsPortalMatch" portal
     JOIN public."OddsSafariMatch" safari ON ((portal.date_time = safari.date_time)))
  WHERE (((portal.home_team)::text = (safari.home_team)::text) AND ((portal.guest_team)::text = (safari.guest_team)::text))
  ORDER BY portal.date_time;


--
-- TOC entry 209 (class 1259 OID 24996)
-- Name: PortalSafariBets; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public."PortalSafariBets" AS
 SELECT global_match.portal_time AS datetime,
    concat(global_match.portal_home_team, ' - ', global_match.portal_guest_team) AS event,
    portal_over_under.type,
    portal_over_under.half,
    portal_over_under.goals,
    portal_over_under.odds AS portalodds,
    safari_over_under.odds AS safariodds,
    (safari_over_under.odds - portal_over_under.odds) AS margin,
    portal_over_under.payout AS portalpayout,
    safari_over_under.payout AS safaripayout,
    safari_over_under.bet_links AS bookie
   FROM ((public."PortalSafariMatch" global_match
     JOIN public."OddsPortalOverUnder" portal_over_under ON ((global_match.portal_id = portal_over_under.match_id)))
     JOIN public."OddsSafariOverUnder" safari_over_under ON ((global_match.safari_id = safari_over_under.match_id)))
  WHERE ((portal_over_under.type = safari_over_under.type) AND (portal_over_under.half = safari_over_under.half) AND (portal_over_under.goals = safari_over_under.goals) AND (safari_over_under.odds >= portal_over_under.odds) AND (portal_over_under.odds >= 1.7))
  ORDER BY global_match.portal_time, (concat(global_match.portal_home_team, ' - ', global_match.portal_guest_team)), portal_over_under.type, portal_over_under.goals, portal_over_under.odds, safari_over_under.odds, (portal_over_under.odds - safari_over_under.odds) DESC;


--
-- TOC entry 2900 (class 2604 OID 24731)
-- Name: OddsPortalMatch id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsPortalMatch" ALTER COLUMN id SET DEFAULT nextval('public."Match_id_seq"'::regclass);


--
-- TOC entry 2903 (class 2604 OID 24732)
-- Name: OddsPortalOverUnder id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsPortalOverUnder" ALTER COLUMN id SET DEFAULT nextval('public."OverUnder_id_seq"'::regclass);


--
-- TOC entry 2906 (class 2604 OID 24825)
-- Name: OddsSafariMatch id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsSafariMatch" ALTER COLUMN id SET DEFAULT nextval('public."Match_id_seq"'::regclass);


--
-- TOC entry 2907 (class 2604 OID 24826)
-- Name: OddsSafariMatch created; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsSafariMatch" ALTER COLUMN created SET DEFAULT CURRENT_TIMESTAMP;


--
-- TOC entry 2908 (class 2604 OID 24827)
-- Name: OddsSafariMatch updated; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsSafariMatch" ALTER COLUMN updated SET DEFAULT CURRENT_TIMESTAMP;


--
-- TOC entry 2909 (class 2604 OID 24839)
-- Name: OddsSafariOverUnder id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsSafariOverUnder" ALTER COLUMN id SET DEFAULT nextval('public."OverUnder_id_seq"'::regclass);


--
-- TOC entry 2910 (class 2604 OID 24840)
-- Name: OddsSafariOverUnder created; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsSafariOverUnder" ALTER COLUMN created SET DEFAULT CURRENT_TIMESTAMP;


--
-- TOC entry 2911 (class 2604 OID 24841)
-- Name: OddsSafariOverUnder updated; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsSafariOverUnder" ALTER COLUMN updated SET DEFAULT CURRENT_TIMESTAMP;


--
-- TOC entry 2912 (class 2604 OID 24969)
-- Name: OverUnderHistorical id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OverUnderHistorical" ALTER COLUMN id SET DEFAULT nextval('public."OverUnderHistorical_id_seq"'::regclass);


--
-- TOC entry 3070 (class 0 OID 24718)
-- Dependencies: 200
-- Data for Name: OddsPortalMatch; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."OddsPortalMatch" (id, home_team, guest_team, date_time, created, updated) FROM stdin;
618	Volos	Lamia	2023-02-24 20:00:00+02	2023-02-18 05:09:08.749075	2023-02-18 05:09:08.749075
621	AEK Athens FC	Asteras Tripolis	2023-02-25 17:30:00+02	2023-02-18 05:09:31.545758	2023-02-18 05:09:31.545758
624	Giannina	PAOK	2023-02-25 19:00:00+02	2023-02-18 05:09:53.101745	2023-02-18 05:09:53.101745
650	Olympiacos Piraeus	Panathinaikos	2023-02-25 20:30:00+02	2023-02-22 04:38:53.959357	2023-02-22 04:38:53.959357
653	Ionikos	OFI Crete	2023-02-26 16:00:00+02	2023-02-22 04:39:13.546139	2023-02-22 04:39:13.546139
656	Levadiakos	Panetolikos	2023-02-26 16:00:00+02	2023-02-22 04:39:32.575739	2023-02-22 04:39:32.575739
659	Aris	Atromitos	2023-02-26 19:30:00+02	2023-02-22 04:39:51.828087	2023-02-22 04:39:51.828087
\.


--
-- TOC entry 3072 (class 0 OID 24726)
-- Dependencies: 202
-- Data for Name: OddsPortalOverUnder; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."OddsPortalOverUnder" (id, goals, odds, match_id, half, payout, created, updated, type, bet_links) FROM stdin;
4655	1.0	1.73	624	1st Half	94.4%	2023-02-18 05:09:59.153478	2023-02-18 05:09:59.153478	Under	{}
4858	0.5	1.11	650	Full Time	97.5%	2023-02-22 04:38:55.959661	2023-02-22 04:38:55.959661	Over	{}
4859	0.5	8.00	650	Full Time	97.5%	2023-02-22 04:38:55.962504	2023-02-22 04:38:55.962504	Under	{}
4860	1.5	1.50	650	Full Time	96.4%	2023-02-22 04:38:55.964431	2023-02-22 04:38:55.964431	Over	{}
4861	1.5	2.70	650	Full Time	96.4%	2023-02-22 04:38:55.966	2023-02-22 04:38:55.966	Under	{}
4862	2.0	1.95	650	Full Time	96.2%	2023-02-22 04:38:55.968098	2023-02-22 04:38:55.968098	Over	{}
4863	2.0	1.90	650	Full Time	96.2%	2023-02-22 04:38:55.970185	2023-02-22 04:38:55.970185	Under	{}
4864	2.5	2.50	650	Full Time	95.7%	2023-02-22 04:38:55.97222	2023-02-22 04:38:55.97222	Over	{}
4865	2.5	1.55	650	Full Time	95.7%	2023-02-22 04:38:55.973715	2023-02-22 04:38:55.973715	Under	{}
4866	3.5	5.00	650	Full Time	94.8%	2023-02-22 04:38:55.975104	2023-02-22 04:38:55.975104	Over	{}
4867	3.5	1.17	650	Full Time	94.8%	2023-02-22 04:38:55.976589	2023-02-22 04:38:55.976589	Under	{}
4868	4.5	13.00	650	Full Time	97.2%	2023-02-22 04:38:55.978553	2023-02-22 04:38:55.978553	Over	{}
4869	4.5	1.05	650	Full Time	97.2%	2023-02-22 04:38:55.980563	2023-02-22 04:38:55.980563	Under	{}
4870	5.5	26.00	650	Full Time	98.1%	2023-02-22 04:38:55.982236	2023-02-22 04:38:55.982236	Over	{}
4871	5.5	1.02	650	Full Time	98.1%	2023-02-22 04:38:55.983237	2023-02-22 04:38:55.983237	Under	{}
4872	6.5	41.00	650	Full Time	97.6%	2023-02-22 04:38:55.984305	2023-02-22 04:38:55.984305	Over	{}
4873	0.5	1.53	650	1st Half	94.9%	2023-02-22 04:38:57.694588	2023-02-22 04:38:57.694588	Over	{}
4874	0.5	2.50	650	1st Half	94.9%	2023-02-22 04:38:59.53855	2023-02-22 04:38:59.53855	Under	{}
4875	0.75	1.85	650	1st Half	94.9%	2023-02-22 04:38:59.540892	2023-02-22 04:38:59.540892	Over	{}
4876	0.75	1.95	650	1st Half	94.9%	2023-02-22 04:38:59.543062	2023-02-22 04:38:59.543062	Under	{}
4877	1.5	3.55	650	1st Half	95.2%	2023-02-22 04:38:59.545633	2023-02-22 04:38:59.545633	Over	{}
4878	1.5	1.30	650	1st Half	95.2%	2023-02-22 04:38:59.547669	2023-02-22 04:38:59.547669	Under	{}
4879	2.5	11.00	650	1st Half	95.9%	2023-02-22 04:38:59.550134	2023-02-22 04:38:59.550134	Over	{}
4880	2.5	1.05	650	1st Half	95.9%	2023-02-22 04:38:59.55153	2023-02-22 04:38:59.55153	Under	{}
4881	3.5	31.00	650	1st Half	97.8%	2023-02-22 04:38:59.552666	2023-02-22 04:38:59.552666	Over	{}
4883	4.5	71.00	650	1st Half	98.6%	2023-02-22 04:38:59.554749	2023-02-22 04:38:59.554749	Over	{}
4884	0.5	1.36	650	2nd Half	95.9%	2023-02-22 04:39:01.705939	2023-02-22 04:39:01.705939	Over	{}
4885	0.5	3.25	650	2nd Half	95.9%	2023-02-22 04:39:02.665402	2023-02-22 04:39:02.665402	Under	{}
4886	1.5	2.63	650	2nd Half	93.1%	2023-02-22 04:39:02.667083	2023-02-22 04:39:02.667083	Over	{}
4887	1.5	1.44	650	2nd Half	93.1%	2023-02-22 04:39:02.668757	2023-02-22 04:39:02.668757	Under	{}
4888	2.5	6.50	650	2nd Half	94.8%	2023-02-22 04:39:02.670873	2023-02-22 04:39:02.670873	Over	{}
4889	2.5	1.11	650	2nd Half	94.8%	2023-02-22 04:39:02.672554	2023-02-22 04:39:02.672554	Under	{}
4890	3.5	19.00	650	2nd Half	96.8%	2023-02-22 04:39:02.674812	2023-02-22 04:39:02.674812	Over	{}
4891	3.5	1.02	650	2nd Half	96.8%	2023-02-22 04:39:02.67663	2023-02-22 04:39:02.67663	Under	{}
4892	0.5	1.08	653	Full Time	95.2%	2023-02-22 04:39:15.315092	2023-02-22 04:39:15.315092	Over	{}
4893	0.5	8.00	653	Full Time	95.2%	2023-02-22 04:39:15.316772	2023-02-22 04:39:15.316772	Under	{}
4894	1.5	1.40	653	Full Time	94.4%	2023-02-22 04:39:15.317699	2023-02-22 04:39:15.317699	Over	{}
4895	1.5	2.90	653	Full Time	94.4%	2023-02-22 04:39:15.318695	2023-02-22 04:39:15.318695	Under	{}
4896	2.25	2.02	653	Full Time	96.0%	2023-02-22 04:39:15.319479	2023-02-22 04:39:15.319479	Over	{}
4897	2.25	1.83	653	Full Time	96.0%	2023-02-22 04:39:15.320427	2023-02-22 04:39:15.320427	Under	{}
4898	2.5	2.25	653	Full Time	94.9%	2023-02-22 04:39:15.321423	2023-02-22 04:39:15.321423	Over	{}
4899	2.5	1.64	653	Full Time	94.9%	2023-02-22 04:39:15.322905	2023-02-22 04:39:15.322905	Under	{}
4900	3.5	4.30	653	Full Time	95.0%	2023-02-22 04:39:15.324092	2023-02-22 04:39:15.324092	Over	{}
4901	3.5	1.22	653	Full Time	95.0%	2023-02-22 04:39:15.3252	2023-02-22 04:39:15.3252	Under	{}
4902	4.5	10.00	653	Full Time	96.7%	2023-02-22 04:39:15.32601	2023-02-22 04:39:15.32601	Over	{}
4903	4.5	1.07	653	Full Time	96.7%	2023-02-22 04:39:15.326993	2023-02-22 04:39:15.326993	Under	{}
4904	5.5	21.00	653	Full Time	97.3%	2023-02-22 04:39:15.328073	2023-02-22 04:39:15.328073	Over	{}
4905	5.5	1.02	653	Full Time	97.3%	2023-02-22 04:39:15.329099	2023-02-22 04:39:15.329099	Under	{}
4906	6.5	34.00	653	Full Time	97.1%	2023-02-22 04:39:15.329821	2023-02-22 04:39:15.329821	Over	{}
4907	0.5	1.50	653	1st Half	95.4%	2023-02-22 04:39:17.754267	2023-02-22 04:39:17.754267	Over	{}
4908	0.5	2.62	653	1st Half	95.4%	2023-02-22 04:39:19.645078	2023-02-22 04:39:19.645078	Under	{}
4909	0.75	1.73	653	1st Half	94.4%	2023-02-22 04:39:19.646334	2023-02-22 04:39:19.646334	Over	{}
4910	0.75	2.08	653	1st Half	94.4%	2023-02-22 04:39:19.647289	2023-02-22 04:39:19.647289	Under	{}
4911	1.5	3.40	653	1st Half	97.1%	2023-02-22 04:39:19.648361	2023-02-22 04:39:19.648361	Over	{}
4912	1.5	1.36	653	1st Half	97.1%	2023-02-22 04:39:19.649325	2023-02-22 04:39:19.649325	Under	{}
4914	2.5	1.06	653	1st Half	95.8%	2023-02-22 04:39:19.651405	2023-02-22 04:39:19.651405	Under	{}
4915	3.5	26.00	653	1st Half	97.2%	2023-02-22 04:39:19.652511	2023-02-22 04:39:19.652511	Over	{}
4916	3.5	1.01	653	1st Half	97.2%	2023-02-22 04:39:19.653609	2023-02-22 04:39:19.653609	Under	{}
4917	4.5	61.00	653	1st Half	98.4%	2023-02-22 04:39:19.654816	2023-02-22 04:39:19.654816	Over	{}
4918	0.5	1.33	653	2nd Half	96.4%	2023-02-22 04:39:21.354681	2023-02-22 04:39:21.354681	Over	{}
4803	6.5	1.01	621	Full Time	97.2%	2023-02-22 04:38:17.887148	2023-02-22 04:38:17.887148	Under	{}
4621	1.5	1.44	621	1st Half	93.9%	2023-02-18 05:09:36.609202	2023-02-18 05:09:36.609202	Under	{}
4919	0.5	3.50	653	2nd Half	96.4%	2023-02-22 04:39:22.292822	2023-02-22 04:39:22.292822	Under	{}
4920	1.5	2.38	653	2nd Half	94.6%	2023-02-22 04:39:22.294028	2023-02-22 04:39:22.294028	Over	{}
4921	1.5	1.57	653	2nd Half	94.6%	2023-02-22 04:39:22.295214	2023-02-22 04:39:22.295214	Under	{}
4922	2.5	5.50	653	2nd Half	94.4%	2023-02-22 04:39:22.296452	2023-02-22 04:39:22.296452	Over	{}
4923	2.5	1.14	653	2nd Half	94.4%	2023-02-22 04:39:22.297705	2023-02-22 04:39:22.297705	Under	{}
4924	3.5	15.00	653	2nd Half	96.4%	2023-02-22 04:39:22.298885	2023-02-22 04:39:22.298885	Over	{}
4925	3.5	1.03	653	2nd Half	96.4%	2023-02-22 04:39:22.300081	2023-02-22 04:39:22.300081	Under	{}
4987	0.5	3.50	659	2nd Half	97.9%	2023-02-22 04:40:00.560956	2023-02-22 04:40:00.560956	Under	{}
4930	2.25	2.05	656	Full Time	95.8%	2023-02-22 04:39:34.467201	2023-02-22 04:39:34.467201	Over	{}
4931	2.25	1.80	656	Full Time	95.8%	2023-02-22 04:39:34.469352	2023-02-22 04:39:34.469352	Under	{}
4929	1.5	2.70	656	Full Time	93.9%	2023-02-22 04:39:34.464803	2023-02-22 04:39:34.464803	Under	{}
4932	2.5	2.45	656	Full Time	94.9%	2023-02-22 04:39:34.470936	2023-02-22 04:39:34.470936	Over	{}
4933	2.5	1.55	656	Full Time	94.9%	2023-02-22 04:39:34.472102	2023-02-22 04:39:34.472102	Under	{}
4934	3.5	4.90	656	Full Time	96.4%	2023-02-22 04:39:34.473397	2023-02-22 04:39:34.473397	Over	{}
4935	3.5	1.20	656	Full Time	96.4%	2023-02-22 04:39:34.474547	2023-02-22 04:39:34.474547	Under	{}
4936	4.5	11.00	656	Full Time	96.7%	2023-02-22 04:39:34.476755	2023-02-22 04:39:34.476755	Over	{}
4937	4.5	1.06	656	Full Time	96.7%	2023-02-22 04:39:34.478073	2023-02-22 04:39:34.478073	Under	{}
4938	5.5	23.00	656	Full Time	97.7%	2023-02-22 04:39:34.479312	2023-02-22 04:39:34.479312	Over	{}
4939	5.5	1.02	656	Full Time	97.7%	2023-02-22 04:39:34.480655	2023-02-22 04:39:34.480655	Under	{}
4940	6.5	51.00	656	Full Time	98.1%	2023-02-22 04:39:34.481941	2023-02-22 04:39:34.481941	Over	{}
4941	0.5	1.53	656	1st Half	96.6%	2023-02-22 04:39:36.105811	2023-02-22 04:39:36.105811	Over	{}
4942	0.5	2.62	656	1st Half	96.6%	2023-02-22 04:39:37.655761	2023-02-22 04:39:37.655761	Under	{}
4943	0.75	1.80	656	1st Half	94.7%	2023-02-22 04:39:37.656993	2023-02-22 04:39:37.656993	Over	{}
4944	0.75	2.00	656	1st Half	94.7%	2023-02-22 04:39:37.658187	2023-02-22 04:39:37.658187	Under	{}
4945	1.5	3.75	656	1st Half	98.2%	2023-02-22 04:39:37.65986	2023-02-22 04:39:37.65986	Over	{}
4946	1.5	1.33	656	1st Half	98.2%	2023-02-22 04:39:37.661159	2023-02-22 04:39:37.661159	Under	{}
4947	2.5	11.00	656	1st Half	96.7%	2023-02-22 04:39:37.66276	2023-02-22 04:39:37.66276	Over	{}
4948	2.5	1.06	656	1st Half	96.7%	2023-02-22 04:39:37.664257	2023-02-22 04:39:37.664257	Under	{}
4949	3.5	26.00	656	1st Half	97.2%	2023-02-22 04:39:37.665585	2023-02-22 04:39:37.665585	Over	{}
4950	3.5	1.01	656	1st Half	97.2%	2023-02-22 04:39:37.666668	2023-02-22 04:39:37.666668	Under	{}
4951	4.5	67.00	656	1st Half	98.5%	2023-02-22 04:39:37.667777	2023-02-22 04:39:37.667777	Over	{}
4952	0.5	1.36	656	2nd Half	95.9%	2023-02-22 04:39:39.809649	2023-02-22 04:39:39.809649	Over	{}
4953	0.5	3.25	656	2nd Half	95.9%	2023-02-22 04:39:40.962336	2023-02-22 04:39:40.962336	Under	{}
4954	1.5	2.63	656	2nd Half	95.5%	2023-02-22 04:39:40.964164	2023-02-22 04:39:40.964164	Over	{}
4955	1.5	1.50	656	2nd Half	95.5%	2023-02-22 04:39:40.966643	2023-02-22 04:39:40.966643	Under	{}
4957	2.5	1.12	656	2nd Half	95.5%	2023-02-22 04:39:40.971448	2023-02-22 04:39:40.971448	Under	{}
4958	3.5	19.00	656	2nd Half	96.8%	2023-02-22 04:39:40.97377	2023-02-22 04:39:40.97377	Over	{}
4959	3.5	1.02	656	2nd Half	96.8%	2023-02-22 04:39:40.9752	2023-02-22 04:39:40.9752	Under	{}
4960	0.5	1.08	659	Full Time	96.4%	2023-02-22 04:39:53.895554	2023-02-22 04:39:53.895554	Over	{}
4961	0.5	9.00	659	Full Time	96.4%	2023-02-22 04:39:53.898266	2023-02-22 04:39:53.898266	Under	{}
4962	1.5	1.40	659	Full Time	96.0%	2023-02-22 04:39:53.900993	2023-02-22 04:39:53.900993	Over	{}
4963	1.5	3.05	659	Full Time	96.0%	2023-02-22 04:39:53.902856	2023-02-22 04:39:53.902856	Under	{}
4964	2.25	1.95	659	Full Time	96.2%	2023-02-22 04:39:53.905023	2023-02-22 04:39:53.905023	Over	{}
4965	2.25	1.90	659	Full Time	96.2%	2023-02-22 04:39:53.906998	2023-02-22 04:39:53.906998	Under	{}
4966	2.5	2.18	659	Full Time	94.6%	2023-02-22 04:39:53.909479	2023-02-22 04:39:53.909479	Over	{}
4967	2.5	1.67	659	Full Time	94.6%	2023-02-22 04:39:53.910842	2023-02-22 04:39:53.910842	Under	{}
4968	3.5	4.20	659	Full Time	96.3%	2023-02-22 04:39:53.911754	2023-02-22 04:39:53.911754	Over	{}
4969	3.5	1.25	659	Full Time	96.3%	2023-02-22 04:39:53.912839	2023-02-22 04:39:53.912839	Under	{}
4970	4.5	9.00	659	Full Time	95.6%	2023-02-22 04:39:53.913879	2023-02-22 04:39:53.913879	Over	{}
4971	4.5	1.07	659	Full Time	95.6%	2023-02-22 04:39:53.916796	2023-02-22 04:39:53.916796	Under	{}
4972	5.5	19.00	659	Full Time	96.8%	2023-02-22 04:39:53.917959	2023-02-22 04:39:53.917959	Over	{}
4973	5.5	1.02	659	Full Time	96.8%	2023-02-22 04:39:53.91916	2023-02-22 04:39:53.91916	Under	{}
4974	6.5	41.00	659	Full Time	97.6%	2023-02-22 04:39:53.920459	2023-02-22 04:39:53.920459	Over	{}
4975	0.5	1.46	659	1st Half	94.8%	2023-02-22 04:39:55.454538	2023-02-22 04:39:55.454538	Over	{}
4976	0.5	2.70	659	1st Half	94.8%	2023-02-22 04:39:57.176598	2023-02-22 04:39:57.176598	Under	{}
4977	1.0	2.10	659	1st Half	93.9%	2023-02-22 04:39:57.178886	2023-02-22 04:39:57.178886	Over	{}
4978	1.0	1.70	659	1st Half	93.9%	2023-02-22 04:39:57.179852	2023-02-22 04:39:57.179852	Under	{}
4979	1.5	3.25	659	1st Half	95.9%	2023-02-22 04:39:57.180866	2023-02-22 04:39:57.180866	Over	{}
4980	1.5	1.36	659	1st Half	95.9%	2023-02-22 04:39:57.181782	2023-02-22 04:39:57.181782	Under	{}
4981	2.5	10.00	659	1st Half	96.7%	2023-02-22 04:39:57.182661	2023-02-22 04:39:57.182661	Over	{}
4982	2.5	1.07	659	1st Half	96.7%	2023-02-22 04:39:57.183742	2023-02-22 04:39:57.183742	Under	{}
4983	3.5	26.00	659	1st Half	97.2%	2023-02-22 04:39:57.184667	2023-02-22 04:39:57.184667	Over	{}
4984	3.5	1.01	659	1st Half	97.2%	2023-02-22 04:39:57.185682	2023-02-22 04:39:57.185682	Under	{}
4985	4.5	61.00	659	1st Half	98.4%	2023-02-22 04:39:57.186657	2023-02-22 04:39:57.186657	Over	{}
4986	0.5	1.36	659	2nd Half	97.9%	2023-02-22 04:39:59.495627	2023-02-22 04:39:59.495627	Over	{}
4988	1.5	2.40	659	2nd Half	93.4%	2023-02-22 04:40:00.562021	2023-02-22 04:40:00.562021	Over	{}
4989	1.5	1.53	659	2nd Half	93.4%	2023-02-22 04:40:00.562997	2023-02-22 04:40:00.562997	Under	{}
4990	2.5	5.50	659	2nd Half	94.4%	2023-02-22 04:40:00.563982	2023-02-22 04:40:00.563982	Over	{}
4927	0.5	8.00	656	Full Time	96.7%	2023-02-22 04:39:34.460428	2023-02-22 04:39:34.460428	Under	{}
4928	1.5	1.44	656	Full Time	93.9%	2023-02-22 04:39:34.462577	2023-02-22 04:39:34.462577	Over	{}
4579	4.5	8.50	618	Full Time	95.8%	2023-02-18 05:09:10.998557	2023-02-18 05:09:10.998557	Over	{}
4580	4.5	1.08	618	Full Time	95.8%	2023-02-18 05:09:11.000659	2023-02-18 05:09:11.000659	Under	{}
4581	5.5	19.00	618	Full Time	96.8%	2023-02-18 05:09:11.002091	2023-02-18 05:09:11.002091	Over	{}
4582	5.5	1.02	618	Full Time	96.8%	2023-02-18 05:09:11.003456	2023-02-18 05:09:11.003456	Under	{}
4583	6.5	34.00	618	Full Time	97.1%	2023-02-18 05:09:11.004677	2023-02-18 05:09:11.004677	Over	{}
4584	0.5	1.44	618	1st Half	95.7%	2023-02-18 05:09:12.691575	2023-02-18 05:09:12.691575	Over	{}
4585	0.5	2.85	618	1st Half	95.7%	2023-02-18 05:09:14.286059	2023-02-18 05:09:14.286059	Under	{}
4586	1.0	2.05	618	1st Half	94.4%	2023-02-18 05:09:14.288406	2023-02-18 05:09:14.288406	Over	{}
4587	1.0	1.75	618	1st Half	94.4%	2023-02-18 05:09:14.290122	2023-02-18 05:09:14.290122	Under	{}
4588	1.5	3.25	618	1st Half	95.9%	2023-02-18 05:09:14.29236	2023-02-18 05:09:14.29236	Over	{}
4589	1.5	1.36	618	1st Half	95.9%	2023-02-18 05:09:14.294579	2023-02-18 05:09:14.294579	Under	{}
4590	2.5	9.00	618	1st Half	95.6%	2023-02-18 05:09:14.296293	2023-02-18 05:09:14.296293	Over	{}
4591	2.5	1.07	618	1st Half	95.6%	2023-02-18 05:09:14.298678	2023-02-18 05:09:14.298678	Under	{}
4592	3.5	26.00	618	1st Half	98.1%	2023-02-18 05:09:14.300292	2023-02-18 05:09:14.300292	Over	{}
4991	2.5	1.14	659	2nd Half	94.4%	2023-02-22 04:40:00.565235	2023-02-22 04:40:00.565235	Under	{}
4992	3.5	15.00	659	2nd Half	96.4%	2023-02-22 04:40:00.566324	2023-02-22 04:40:00.566324	Over	{}
4993	3.5	1.03	659	2nd Half	96.4%	2023-02-22 04:40:00.567494	2023-02-22 04:40:00.567494	Under	{}
4569	0.5	1.07	618	Full Time	96.7%	2023-02-18 05:09:10.977183	2023-02-18 05:09:10.977183	Over	{}
4570	0.5	10.00	618	Full Time	96.7%	2023-02-18 05:09:10.98166	2023-02-18 05:09:10.98166	Under	{}
4571	1.5	1.36	618	Full Time	95.9%	2023-02-18 05:09:10.984119	2023-02-18 05:09:10.984119	Over	{}
4572	1.5	3.25	618	Full Time	95.9%	2023-02-18 05:09:10.986719	2023-02-18 05:09:10.986719	Under	{}
4573	2.25	1.85	618	Full Time	96.1%	2023-02-18 05:09:10.989024	2023-02-18 05:09:10.989024	Over	{}
4574	2.25	2.00	618	Full Time	96.1%	2023-02-18 05:09:10.990479	2023-02-18 05:09:10.990479	Under	{}
4575	2.5	2.08	618	Full Time	94.4%	2023-02-18 05:09:10.992211	2023-02-18 05:09:10.992211	Over	{}
4576	2.5	1.73	618	Full Time	94.4%	2023-02-18 05:09:10.993517	2023-02-18 05:09:10.993517	Under	{}
4577	3.5	3.95	618	Full Time	95.0%	2023-02-18 05:09:10.994971	2023-02-18 05:09:10.994971	Over	{}
4578	3.5	1.25	618	Full Time	95.0%	2023-02-18 05:09:10.99676	2023-02-18 05:09:10.99676	Under	{}
4639	1.5	3.20	624	Full Time	95.4%	2023-02-18 05:09:55.32853	2023-02-18 05:09:55.32853	Under	{}
4640	2.25	1.90	624	Full Time	96.2%	2023-02-18 05:09:55.330368	2023-02-18 05:09:55.330368	Over	{}
4651	6.5	1.01	624	Full Time	97.6%	2023-02-18 05:09:55.34786	2023-02-18 05:09:55.34786	Under	{}
4597	1.5	2.38	618	2nd Half	95.0%	2023-02-18 05:09:17.138729	2023-02-18 05:09:17.138729	Over	{}
4598	1.5	1.58	618	2nd Half	95.0%	2023-02-18 05:09:17.140699	2023-02-18 05:09:17.140699	Under	{}
4599	2.5	5.50	618	2nd Half	95.1%	2023-02-18 05:09:17.142691	2023-02-18 05:09:17.142691	Over	{}
4600	2.5	1.15	618	2nd Half	95.1%	2023-02-18 05:09:17.144657	2023-02-18 05:09:17.144657	Under	{}
4601	3.5	15.00	618	2nd Half	96.4%	2023-02-18 05:09:17.146551	2023-02-18 05:09:17.146551	Over	{}
4602	3.5	1.03	618	2nd Half	96.4%	2023-02-18 05:09:17.148387	2023-02-18 05:09:17.148387	Under	{}
4603	0.5	1.05	621	Full Time	97.2%	2023-02-18 05:09:33.52181	2023-02-18 05:09:33.52181	Over	{}
4604	0.5	13.00	621	Full Time	97.2%	2023-02-18 05:09:33.526386	2023-02-18 05:09:33.526386	Under	{}
4605	1.5	1.30	621	Full Time	97.8%	2023-02-18 05:09:33.529052	2023-02-18 05:09:33.529052	Over	{}
4606	1.5	3.95	621	Full Time	97.8%	2023-02-18 05:09:33.53132	2023-02-18 05:09:33.53132	Under	{}
4607	2.5	1.88	621	Full Time	96.4%	2023-02-18 05:09:33.533266	2023-02-18 05:09:33.533266	Over	{}
4608	2.5	1.98	621	Full Time	96.4%	2023-02-18 05:09:33.535247	2023-02-18 05:09:33.535247	Under	{}
4609	3.5	3.25	621	Full Time	95.9%	2023-02-18 05:09:33.537511	2023-02-18 05:09:33.537511	Over	{}
4610	3.5	1.36	621	Full Time	95.9%	2023-02-18 05:09:33.539499	2023-02-18 05:09:33.539499	Under	{}
4611	4.5	6.10	621	Full Time	95.3%	2023-02-18 05:09:33.541371	2023-02-18 05:09:33.541371	Over	{}
4612	4.5	1.13	621	Full Time	95.3%	2023-02-18 05:09:33.54367	2023-02-18 05:09:33.54367	Under	{}
4613	5.5	13.00	621	Full Time	96.3%	2023-02-18 05:09:33.545782	2023-02-18 05:09:33.545782	Over	{}
4614	5.5	1.04	621	Full Time	96.3%	2023-02-18 05:09:33.547267	2023-02-18 05:09:33.547267	Under	{}
4615	6.5	26.00	621	Full Time	97.2%	2023-02-18 05:09:33.548455	2023-02-18 05:09:33.548455	Over	{}
4616	0.5	1.36	621	1st Half	95.4%	2023-02-18 05:09:35.144799	2023-02-18 05:09:35.144799	Over	{}
4617	0.5	3.20	621	1st Half	95.4%	2023-02-18 05:09:36.604833	2023-02-18 05:09:36.604833	Under	{}
4618	1.0	1.80	621	1st Half	94.7%	2023-02-18 05:09:36.605983	2023-02-18 05:09:36.605983	Over	{}
4619	1.0	2.00	621	1st Half	94.7%	2023-02-18 05:09:36.607052	2023-02-18 05:09:36.607052	Under	{}
4620	1.5	2.70	621	1st Half	93.9%	2023-02-18 05:09:36.60816	2023-02-18 05:09:36.60816	Over	{}
4622	2.5	7.00	621	1st Half	95.1%	2023-02-18 05:09:36.610529	2023-02-18 05:09:36.610529	Over	{}
4623	2.5	1.10	621	1st Half	95.1%	2023-02-18 05:09:36.611702	2023-02-18 05:09:36.611702	Under	{}
4624	3.5	21.00	621	1st Half	97.3%	2023-02-18 05:09:36.612751	2023-02-18 05:09:36.612751	Over	{}
4625	3.5	1.02	621	1st Half	97.3%	2023-02-18 05:09:36.613698	2023-02-18 05:09:36.613698	Under	{}
4626	4.5	51.00	621	1st Half	99.0%	2023-02-18 05:09:36.614899	2023-02-18 05:09:36.614899	Over	{}
4627	4.5	1.01	621	1st Half	99.0%	2023-02-18 05:09:36.615896	2023-02-18 05:09:36.615896	Under	{}
4628	0.5	1.29	621	2nd Half	97.5%	2023-02-18 05:09:38.159055	2023-02-18 05:09:38.159055	Over	{}
4629	0.5	4.00	621	2nd Half	97.5%	2023-02-18 05:09:39.380405	2023-02-18 05:09:39.380405	Under	{}
4630	1.5	2.20	621	2nd Half	95.9%	2023-02-18 05:09:39.382326	2023-02-18 05:09:39.382326	Over	{}
4631	1.5	1.70	621	2nd Half	95.9%	2023-02-18 05:09:39.384381	2023-02-18 05:09:39.384381	Under	{}
4632	2.5	4.50	621	2nd Half	94.7%	2023-02-18 05:09:39.385908	2023-02-18 05:09:39.385908	Over	{}
4633	2.5	1.20	621	2nd Half	94.7%	2023-02-18 05:09:39.388191	2023-02-18 05:09:39.388191	Under	{}
4634	3.5	11.00	621	2nd Half	95.9%	2023-02-18 05:09:39.389858	2023-02-18 05:09:39.389858	Over	{}
4635	3.5	1.05	621	2nd Half	95.9%	2023-02-18 05:09:39.391931	2023-02-18 05:09:39.391931	Under	{}
4636	0.5	1.07	624	Full Time	96.2%	2023-02-18 05:09:55.32302	2023-02-18 05:09:55.32302	Over	{}
4637	0.5	9.50	624	Full Time	96.2%	2023-02-18 05:09:55.324962	2023-02-18 05:09:55.324962	Under	{}
4638	1.5	1.36	624	Full Time	95.4%	2023-02-18 05:09:55.326977	2023-02-18 05:09:55.326977	Over	{}
4641	2.25	1.95	624	Full Time	96.2%	2023-02-18 05:09:55.332137	2023-02-18 05:09:55.332137	Under	{}
4642	2.5	2.10	624	Full Time	94.9%	2023-02-18 05:09:55.333703	2023-02-18 05:09:55.333703	Over	{}
4643	2.5	1.73	624	Full Time	94.9%	2023-02-18 05:09:55.335269	2023-02-18 05:09:55.335269	Under	{}
4644	3.5	3.90	624	Full Time	96.9%	2023-02-18 05:09:55.336852	2023-02-18 05:09:55.336852	Over	{}
4645	3.5	1.29	624	Full Time	96.9%	2023-02-18 05:09:55.338514	2023-02-18 05:09:55.338514	Under	{}
4646	4.5	8.00	624	Full Time	95.2%	2023-02-18 05:09:55.339989	2023-02-18 05:09:55.339989	Over	{}
4647	4.5	1.08	624	Full Time	95.2%	2023-02-18 05:09:55.341484	2023-02-18 05:09:55.341484	Under	{}
4648	5.5	19.00	624	Full Time	96.8%	2023-02-18 05:09:55.343088	2023-02-18 05:09:55.343088	Over	{}
4649	5.5	1.02	624	Full Time	96.8%	2023-02-18 05:09:55.344731	2023-02-18 05:09:55.344731	Under	{}
4650	6.5	41.00	624	Full Time	97.6%	2023-02-18 05:09:55.346255	2023-02-18 05:09:55.346255	Over	{}
4652	0.5	1.44	624	1st Half	95.1%	2023-02-18 05:09:57.568083	2023-02-18 05:09:57.568083	Over	{}
4653	0.5	2.80	624	1st Half	95.1%	2023-02-18 05:09:59.148312	2023-02-18 05:09:59.148312	Under	{}
4654	1.0	2.08	624	1st Half	94.4%	2023-02-18 05:09:59.150989	2023-02-18 05:09:59.150989	Over	{}
4656	1.5	3.25	624	1st Half	95.9%	2023-02-18 05:09:59.155488	2023-02-18 05:09:59.155488	Over	{}
4657	1.5	1.36	624	1st Half	95.9%	2023-02-18 05:09:59.157478	2023-02-18 05:09:59.157478	Under	{}
4593	3.5	1.02	618	1st Half	98.1%	2023-02-18 05:09:14.302458	2023-02-18 05:09:14.302458	Under	{}
4595	0.5	1.33	618	2nd Half	98.2%	2023-02-18 05:09:16.010013	2023-02-18 05:09:16.010013	Over	{}
4596	0.5	3.75	618	2nd Half	98.2%	2023-02-18 05:09:17.136869	2023-02-18 05:09:17.136869	Under	{}
4663	4.5	1.01	624	1st Half	99.0%	2023-02-18 05:09:59.168748	2023-02-18 05:09:59.168748	Under	{}
4594	4.5	56.00	618	1st Half	98.2%	2023-02-18 05:09:14.304596	2023-02-18 05:09:14.304596	Over	{}
4658	2.5	9.00	624	1st Half	96.4%	2023-02-18 05:09:59.159659	2023-02-18 05:09:59.159659	Over	{}
4659	2.5	1.08	624	1st Half	96.4%	2023-02-18 05:09:59.161903	2023-02-18 05:09:59.161903	Under	{}
4660	3.5	26.00	624	1st Half	98.1%	2023-02-18 05:09:59.164486	2023-02-18 05:09:59.164486	Over	{}
4661	3.5	1.02	624	1st Half	98.1%	2023-02-18 05:09:59.16638	2023-02-18 05:09:59.16638	Under	{}
4662	4.5	56.00	624	1st Half	98.2%	2023-02-18 05:09:59.167614	2023-02-18 05:09:59.167614	Over	{}
4664	0.5	1.33	624	2nd Half	96.4%	2023-02-18 05:10:00.797874	2023-02-18 05:10:00.797874	Over	{}
4665	0.5	3.50	624	2nd Half	96.4%	2023-02-18 05:10:01.833603	2023-02-18 05:10:01.833603	Under	{}
4666	1.5	2.38	624	2nd Half	95.0%	2023-02-18 05:10:01.835863	2023-02-18 05:10:01.835863	Over	{}
4667	1.5	1.58	624	2nd Half	95.0%	2023-02-18 05:10:01.837686	2023-02-18 05:10:01.837686	Under	{}
4668	2.5	5.50	624	2nd Half	95.8%	2023-02-18 05:10:01.839711	2023-02-18 05:10:01.839711	Over	{}
4669	2.5	1.16	624	2nd Half	95.8%	2023-02-18 05:10:01.841736	2023-02-18 05:10:01.841736	Under	{}
4670	3.5	15.00	624	2nd Half	96.4%	2023-02-18 05:10:01.844265	2023-02-18 05:10:01.844265	Over	{}
4671	3.5	1.03	624	2nd Half	96.4%	2023-02-18 05:10:01.84696	2023-02-18 05:10:01.84696	Under	{}
4882	3.5	1.01	650	1st Half	97.8%	2023-02-22 04:38:59.553704	2023-02-22 04:38:59.553704	Under	{}
4913	2.5	10.00	653	1st Half	95.8%	2023-02-22 04:39:19.650341	2023-02-22 04:39:19.650341	Over	{}
4926	0.5	1.10	656	Full Time	96.7%	2023-02-22 04:39:34.456689	2023-02-22 04:39:34.456689	Over	{}
5210	2.0	1.85	656	Full Time	96.1%	2023-02-22 15:27:08.214162	2023-02-22 15:27:08.214162	Over	{}
5211	2.0	2.00	656	Full Time	96.1%	2023-02-22 15:27:08.216778	2023-02-22 15:27:08.216778	Under	{}
4956	2.5	6.50	656	2nd Half	95.5%	2023-02-22 04:39:40.969035	2023-02-22 04:39:40.969035	Over	{}
\.


--
-- TOC entry 3074 (class 0 OID 24822)
-- Dependencies: 204
-- Data for Name: OddsSafariMatch; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."OddsSafariMatch" (id, home_team, guest_team, date_time, created, updated) FROM stdin;
634	Volos	Lamia	2023-02-24 20:00:00+02	2023-02-18 05:15:58.841268	2023-02-18 05:15:58.841268
635	AEK	Asteras Tripolis	2023-02-25 17:30:00+02	2023-02-18 05:16:24.042607	2023-02-18 05:16:24.042607
636	PAS Giannina	PAOK	2023-02-25 19:00:00+02	2023-02-18 05:16:49.64921	2023-02-18 05:16:49.64921
637	Olympiacos	Panathinaikos	2023-02-25 20:30:00+02	2023-02-18 05:17:15.990048	2023-02-18 05:17:15.990048
638	Ionikos	OFI	2023-02-26 16:00:00+02	2023-02-18 05:17:41.314011	2023-02-18 05:17:41.314011
639	Levadiakos	Panetolikos	2023-02-26 16:00:00+02	2023-02-18 05:18:05.279829	2023-02-18 05:18:05.279829
640	Aris Salonika	Atromitos	2023-02-26 19:30:00+02	2023-02-18 05:18:28.578351	2023-02-18 05:18:28.578351
\.


--
-- TOC entry 3075 (class 0 OID 24836)
-- Dependencies: 205
-- Data for Name: OddsSafariOverUnder; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."OddsSafariOverUnder" (id, goals, odds, match_id, half, payout, created, updated, type, bet_links) FROM stdin;
4715	2.5	1.73	634	Full Time	4.54%	2023-02-18 05:16:09.30527	2023-02-18 05:16:09.30527	Under	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
4716	0.5	1.50	634	1st Half	2.33%	2023-02-18 05:16:14.305929	2023-02-18 05:16:14.305929	Over	{https://sports.bwin.gr/el/sports?wm=5273373,https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
4717	0.5	2.80	634	1st Half	2.33%	2023-02-18 05:16:14.311078	2023-02-18 05:16:14.311078	Under	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
4718	0.5	1.30	634	2nd Half	3.47%	2023-02-18 05:16:19.642677	2023-02-18 05:16:19.642677	Over	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
4719	0.5	3.75	634	2nd Half	3.47%	2023-02-18 05:16:19.646753	2023-02-18 05:16:19.646753	Under	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
4720	2.5	1.86	635	Full Time	4.80%	2023-02-18 05:16:34.188507	2023-02-18 05:16:34.188507	Over	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
4721	2.5	1.95	635	Full Time	4.80%	2023-02-18 05:16:34.19208	2023-02-18 05:16:34.19208	Under	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
4722	0.5	1.40	635	1st Half	3.08%	2023-02-18 05:16:40.031817	2023-02-18 05:16:40.031817	Over	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
4723	0.5	3.15	635	1st Half	3.08%	2023-02-18 05:16:40.037039	2023-02-18 05:16:40.037039	Under	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
4724	0.5	1.25	635	2nd Half	4.48%	2023-02-18 05:16:46.348524	2023-02-18 05:16:46.348524	Over	{https://sports.bwin.gr/el/sports?wm=5273373}
4725	0.5	4.05	635	2nd Half	4.48%	2023-02-18 05:16:46.355252	2023-02-18 05:16:46.355252	Under	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
4726	2.5	2.20	636	Full Time	2.84%	2023-02-18 05:16:59.918768	2023-02-18 05:16:59.918768	Over	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
4727	2.5	1.74	636	Full Time	2.84%	2023-02-18 05:16:59.921551	2023-02-18 05:16:59.921551	Under	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
4728	0.5	1.50	636	1st Half	2.33%	2023-02-18 05:17:05.708817	2023-02-18 05:17:05.708817	Over	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
4729	0.5	2.80	636	1st Half	2.33%	2023-02-18 05:17:05.712438	2023-02-18 05:17:05.712438	Under	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
4730	0.5	1.30	636	2nd Half	5.21%	2023-02-18 05:17:11.647585	2023-02-18 05:17:11.647585	Over	{https://sports.bwin.gr/el/sports?wm=5273373}
4731	0.5	3.50	636	2nd Half	5.21%	2023-02-18 05:17:11.653651	2023-02-18 05:17:11.653651	Under	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
4732	2.5	2.55	637	Full Time	0.94%	2023-02-18 05:17:25.90915	2023-02-18 05:17:25.90915	Over	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
4733	2.5	1.62	637	Full Time	0.94%	2023-02-18 05:17:25.91147	2023-02-18 05:17:25.91147	Under	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107,https://partners.opapaffiliates.gr/redirect.aspx?pid=2460&bid=1759}
4734	0.5	1.60	637	1st Half	3.21%	2023-02-18 05:17:31.889381	2023-02-18 05:17:31.889381	Over	{http://www.stoiximan.gr/}
4735	0.5	2.45	637	1st Half	3.21%	2023-02-18 05:17:31.896783	2023-02-18 05:17:31.896783	Under	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
4736	0.5	1.37	637	2nd Half	3.63%	2023-02-18 05:17:37.901678	2023-02-18 05:17:37.901678	Over	{https://sports.bwin.gr/el/sports?wm=5273373,http://www.stoiximan.gr/}
4737	0.5	3.25	637	2nd Half	3.63%	2023-02-18 05:17:37.904826	2023-02-18 05:17:37.904826	Under	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
4738	2.5	2.35	638	Full Time	2.72%	2023-02-18 05:17:50.936548	2023-02-18 05:17:50.936548	Over	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
4739	2.5	1.66	638	Full Time	2.72%	2023-02-18 05:17:50.939608	2023-02-18 05:17:50.939608	Under	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
4740	0.5	1.55	638	1st Half	2.20%	2023-02-18 05:17:56.215004	2023-02-18 05:17:56.215004	Over	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
4741	0.5	2.65	638	1st Half	2.20%	2023-02-18 05:17:56.217966	2023-02-18 05:17:56.217966	Under	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
4742	0.5	1.33	638	2nd Half	3.62%	2023-02-18 05:18:01.96025	2023-02-18 05:18:01.96025	Over	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
4743	0.5	3.50	638	2nd Half	3.62%	2023-02-18 05:18:01.974227	2023-02-18 05:18:01.974227	Under	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
4744	2.5	2.45	639	Full Time	4.32%	2023-02-18 05:18:14.665499	2023-02-18 05:18:14.665499	Over	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
4745	2.5	1.57	639	Full Time	4.32%	2023-02-18 05:18:14.670694	2023-02-18 05:18:14.670694	Under	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
4746	0.5	1.57	639	1st Half	3.56%	2023-02-18 05:18:20.486493	2023-02-18 05:18:20.486493	Over	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
4747	0.5	2.50	639	1st Half	3.56%	2023-02-18 05:18:20.495336	2023-02-18 05:18:20.495336	Under	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
4748	0.5	1.35	639	2nd Half	4.62%	2023-02-18 05:18:25.349735	2023-02-18 05:18:25.349735	Over	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
4749	0.5	3.25	639	2nd Half	4.62%	2023-02-18 05:18:25.352631	2023-02-18 05:18:25.352631	Under	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
4750	2.5	2.25	640	Full Time	3.16%	2023-02-18 05:18:38.124823	2023-02-18 05:18:38.124823	Over	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
4714	2.5	2.13	634	Full Time	4.54%	2023-02-18 05:16:09.300401	2023-02-18 05:16:09.300401	Over	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
4751	2.5	1.70	640	Full Time	3.16%	2023-02-18 05:18:38.129016	2023-02-18 05:18:38.129016	Under	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
4752	0.5	1.52	640	1st Half	2.75%	2023-02-18 05:18:44.197585	2023-02-18 05:18:44.197585	Over	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
4753	0.5	2.70	640	1st Half	2.75%	2023-02-18 05:18:44.203761	2023-02-18 05:18:44.203761	Under	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
4754	0.5	1.30	640	2nd Half	4.85%	2023-02-18 05:18:50.132981	2023-02-18 05:18:50.132981	Over	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
4755	0.5	3.55	640	2nd Half	4.85%	2023-02-18 05:18:50.137232	2023-02-18 05:18:50.137232	Under	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
\.


--
-- TOC entry 3077 (class 0 OID 24966)
-- Dependencies: 208
-- Data for Name: OverUnderHistorical; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."OverUnderHistorical" (id, "Date_Time", "Type", "Goals", "Odds_bet", "Margin", "Payout", "Bet_link", "Home_Team", "Guest_Team", "Home_Team_Goals", "Guest_Team_Goals", "Half", won) FROM stdin;
1	2023-02-18 17:00:00+02	Over	2.5	2.17	0.00	0.72%	{https://record.affiliates.betshop.gr/_xVrm1kU5pcRLcRLGwHoTKWNd7ZgqdRLk/1/}	Panathinaikos	Volos	2	0	\N	\N
2	2023-02-18 17:00:00+02	Under	0.5	2.80	0.00	2.33%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}	Panathinaikos	Volos	2	0	\N	\N
3	2023-02-18 17:00:00+02	Under	0.5	3.70	0.90	3.80%	{}	Panathinaikos	Volos	2	0	\N	\N
4	2023-02-18 17:00:00+02	Under	0.5	3.70	0.00	3.80%	{}	Panathinaikos	Volos	2	0	\N	\N
5	2023-02-18 17:00:00+02	Under	2.5	1.83	0.00	0.72%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}	Panathinaikos	Volos	2	0	\N	\N
11	2023-02-19 16:00:00+02	Under	0.5	2.95	0.00	2.78%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}	Lamia	Olympiacos	0	3	\N	\N
12	2023-02-19 16:00:00+02	Under	0.5	3.90	0.95	4.20%	{}	Lamia	Olympiacos	0	3	\N	\N
6	2023-02-18 20:00:00+02	Over	2.5	2.55	0.00	2.07%	{https://record.affiliates.betshop.gr/_xVrm1kU5pcRLcRLGwHoTKWNd7ZgqdRLk/1/}	Asteras Tripolis	PAS Giannina	1	1	\N	\N
7	2023-02-18 20:00:00+02	Under	0.5	2.45	0.00	3.21%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}	Asteras Tripolis	PAS Giannina	1	1	\N	\N
8	2023-02-18 20:00:00+02	Under	0.5	3.25	0.80	3.63%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}	Asteras Tripolis	PAS Giannina	1	1	\N	\N
9	2023-02-18 20:00:00+02	Under	0.5	3.25	0.00	3.63%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}	Asteras Tripolis	PAS Giannina	1	1	\N	\N
10	2023-02-19 16:00:00+02	Over	2.5	2.00	0.00	2.56%	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/,https://www.bet365.gr/olp/open-account?affiliate=365_01012107}	Lamia	Olympiacos	0	3	\N	Won
26	2023-02-20 18:00:00+02	Over	2.5	2.40	0.00	3.46%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}	Atromitos	Levadiakos	1	0	\N	\N
27	2023-02-20 18:00:00+02	Under	0.5	2.55	0.05	2.83%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}	Atromitos	Levadiakos	1	0	\N	\N
28	2023-02-20 18:00:00+02	Under	0.5	3.40	0.90	4.40%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}	Atromitos	Levadiakos	1	0	\N	\N
29	2023-02-20 18:00:00+02	Under	0.5	2.55	0.00	2.83%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}	Atromitos	Levadiakos	1	0	\N	\N
13	2023-02-19 16:00:00+02	Under	0.5	3.90	0.00	4.20%	{}	Lamia	Olympiacos	0	3	\N	\N
14	2023-02-19 16:00:00+02	Under	2.5	1.90	0.00	2.56%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}	Lamia	Olympiacos	0	3	\N	\N
33	2023-02-20 19:30:00+02	Over	2.5	2.40	0.00	3.28%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}	OFI	Aris Salonika	0	3	\N	Won
30	2023-02-20 18:00:00+02	Under	0.5	3.40	0.85	4.40%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}	Atromitos	Levadiakos	1	0	\N	\N
31	2023-02-20 18:00:00+02	Under	0.5	3.40	0.00	4.40%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}	Atromitos	Levadiakos	1	0	\N	\N
32	2023-02-20 18:00:00+02	Under	0.5	3.40	0.00	4.40%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}	Atromitos	Levadiakos	1	0	\N	\N
22	2023-02-19 20:30:00+02	Over	2.5	2.45	0.00	2.48%	{https://record.affiliates.betshop.gr/_xVrm1kU5pcRLcRLGwHoTKWNd7ZgqdRLk/1/}	PAOK	AEK	2	0	\N	\N
23	2023-02-19 20:30:00+02	Under	0.5	2.50	0.00	2.44%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}	PAOK	AEK	2	0	\N	\N
24	2023-02-19 20:30:00+02	Under	0.5	3.25	0.75	5.47%	{http://www.stoiximan.gr/,https://www.bet365.gr/olp/open-account?affiliate=365_01012107}	PAOK	AEK	2	0	\N	\N
25	2023-02-19 20:30:00+02	Under	0.5	3.25	0.00	5.47%	{http://www.stoiximan.gr/,https://www.bet365.gr/olp/open-account?affiliate=365_01012107}	PAOK	AEK	2	0	\N	\N
15	2023-02-19 19:30:00+02	Over	2.5	2.50	0.00	1.70%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107,https://partners.opapaffiliates.gr/redirect.aspx?pid=2460&bid=1759,https://record.affiliates.betshop.gr/_xVrm1kU5pcRLcRLGwHoTKWNd7ZgqdRLk/1/}	Panetolikos	Ionikos	1	0	\N	\N
16	2023-02-19 19:30:00+02	Over	2.5	2.50	0.00	1.70%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107,https://partners.opapaffiliates.gr/redirect.aspx?pid=2460&bid=1759,https://record.affiliates.betshop.gr/_xVrm1kU5pcRLcRLGwHoTKWNd7ZgqdRLk/1/}	Panetolikos	Ionikos	1	0	\N	\N
17	2023-02-19 19:30:00+02	Under	0.5	2.45	0.00	3.21%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}	Panetolikos	Ionikos	1	0	\N	\N
18	2023-02-19 19:30:00+02	Under	0.5	3.25	0.80	3.63%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}	Panetolikos	Ionikos	1	0	\N	\N
19	2023-02-19 19:30:00+02	Under	0.5	3.25	0.75	3.63%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}	Panetolikos	Ionikos	1	0	\N	\N
20	2023-02-19 19:30:00+02	Under	0.5	3.25	0.00	3.63%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}	Panetolikos	Ionikos	1	0	\N	\N
34	2023-02-20 19:30:00+02	Under	0.5	2.60	0.00	2.89%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}	OFI	Aris Salonika	0	3	\N	\N
35	2023-02-20 19:30:00+02	Under	0.5	3.40	0.80	4.40%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}	OFI	Aris Salonika	0	3	\N	\N
36	2023-02-20 19:30:00+02	Under	0.5	3.40	0.00	4.40%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}	OFI	Aris Salonika	0	3	\N	\N
21	2023-02-19 19:30:00+02	Under	0.5	3.25	0.00	3.63%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}	Panetolikos	Ionikos	1	0	\N	\N
\.


--
-- TOC entry 3095 (class 0 OID 0)
-- Dependencies: 201
-- Name: Match_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."Match_id_seq"', 738, true);


--
-- TOC entry 3096 (class 0 OID 0)
-- Dependencies: 207
-- Name: OverUnderHistorical_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."OverUnderHistorical_id_seq"', 36, true);


--
-- TOC entry 3097 (class 0 OID 0)
-- Dependencies: 203
-- Name: OverUnder_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."OverUnder_id_seq"', 5791, true);


--
-- TOC entry 2914 (class 2606 OID 24734)
-- Name: OddsPortalMatch OddsPortalMatch_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsPortalMatch"
    ADD CONSTRAINT "OddsPortalMatch_pk" PRIMARY KEY (id);


--
-- TOC entry 2916 (class 2606 OID 24736)
-- Name: OddsPortalMatch OddsPortalMatch_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsPortalMatch"
    ADD CONSTRAINT "OddsPortalMatch_unique" UNIQUE (home_team, guest_team, date_time);


--
-- TOC entry 2918 (class 2606 OID 24804)
-- Name: OddsPortalOverUnder OddsPortalOverUnder_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsPortalOverUnder"
    ADD CONSTRAINT "OddsPortalOverUnder_pk" PRIMARY KEY (id, match_id, half, type, goals);


--
-- TOC entry 2920 (class 2606 OID 24862)
-- Name: OddsPortalOverUnder OddsPortalOverUnder_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsPortalOverUnder"
    ADD CONSTRAINT "OddsPortalOverUnder_unique" UNIQUE (goals, match_id, half, type);


--
-- TOC entry 2923 (class 2606 OID 24833)
-- Name: OddsSafariMatch OddsSafariMatch_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsSafariMatch"
    ADD CONSTRAINT "OddsSafariMatch_pk" PRIMARY KEY (id);


--
-- TOC entry 2925 (class 2606 OID 24835)
-- Name: OddsSafariMatch OddsSafariMatch_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsSafariMatch"
    ADD CONSTRAINT "OddsSafariMatch_unique" UNIQUE (home_team, guest_team, date_time);


--
-- TOC entry 2927 (class 2606 OID 24846)
-- Name: OddsSafariOverUnder OddsSafariOverUnder_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsSafariOverUnder"
    ADD CONSTRAINT "OddsSafariOverUnder_pk" PRIMARY KEY (id);


--
-- TOC entry 2929 (class 2606 OID 24848)
-- Name: OddsSafariOverUnder OddsSafariOverUnder_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsSafariOverUnder"
    ADD CONSTRAINT "OddsSafariOverUnder_unique" UNIQUE (goals, match_id, half, type);


--
-- TOC entry 2933 (class 2606 OID 24974)
-- Name: OverUnderHistorical OverUnderHistorical_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OverUnderHistorical"
    ADD CONSTRAINT "OverUnderHistorical_pkey" PRIMARY KEY (id);


--
-- TOC entry 2921 (class 1259 OID 24995)
-- Name: fki_OddsPortalOverUnder_Match_fk; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "fki_OddsPortalOverUnder_Match_fk" ON public."OddsPortalOverUnder" USING btree (match_id);


--
-- TOC entry 2930 (class 1259 OID 24860)
-- Name: fki_OddsSafariOverUnder_Match_fk; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "fki_OddsSafariOverUnder_Match_fk" ON public."OddsSafariOverUnder" USING btree (match_id);


--
-- TOC entry 2931 (class 1259 OID 24854)
-- Name: fki_OddsSafariOverUnder_match_id_fk; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "fki_OddsSafariOverUnder_match_id_fk" ON public."OddsSafariOverUnder" USING btree (match_id);


--
-- TOC entry 2936 (class 2620 OID 24783)
-- Name: OddsPortalOverUnder update_updated_Match_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER "update_updated_Match_trigger" AFTER UPDATE ON public."OddsPortalOverUnder" FOR EACH ROW EXECUTE FUNCTION public."update_updated_on_Match"();


--
-- TOC entry 2937 (class 2620 OID 24782)
-- Name: OddsPortalOverUnder update_updated_OverUnder_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER "update_updated_OverUnder_trigger" AFTER UPDATE ON public."OddsPortalOverUnder" FOR EACH ROW EXECUTE FUNCTION public."update_updated_on_OverUnder"();


--
-- TOC entry 2934 (class 2606 OID 24990)
-- Name: OddsPortalOverUnder OddsPortalOverUnder_Match_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsPortalOverUnder"
    ADD CONSTRAINT "OddsPortalOverUnder_Match_fk" FOREIGN KEY (match_id) REFERENCES public."OddsPortalMatch"(id) ON UPDATE CASCADE ON DELETE CASCADE NOT VALID;


--
-- TOC entry 2935 (class 2606 OID 24985)
-- Name: OddsSafariOverUnder OddsSafariOverUnder_Match_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsSafariOverUnder"
    ADD CONSTRAINT "OddsSafariOverUnder_Match_fk" FOREIGN KEY (match_id) REFERENCES public."OddsSafariMatch"(id) ON UPDATE CASCADE ON DELETE CASCADE NOT VALID;


--
-- TOC entry 3085 (class 0 OID 0)
-- Dependencies: 200
-- Name: TABLE "OddsPortalMatch"; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE public."OddsPortalMatch" FROM postgres;


--
-- TOC entry 3087 (class 0 OID 0)
-- Dependencies: 202
-- Name: TABLE "OddsPortalOverUnder"; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE public."OddsPortalOverUnder" FROM postgres;
GRANT ALL ON TABLE public."OddsPortalOverUnder" TO postgres WITH GRANT OPTION;


--
-- TOC entry 3088 (class 0 OID 0)
-- Dependencies: 204
-- Name: TABLE "OddsSafariMatch"; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE public."OddsSafariMatch" FROM postgres;
GRANT ALL ON TABLE public."OddsSafariMatch" TO postgres WITH GRANT OPTION;


--
-- TOC entry 3089 (class 0 OID 0)
-- Dependencies: 205
-- Name: TABLE "OddsSafariOverUnder"; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE public."OddsSafariOverUnder" FROM postgres;
GRANT ALL ON TABLE public."OddsSafariOverUnder" TO postgres WITH GRANT OPTION;


--
-- TOC entry 3090 (class 0 OID 0)
-- Dependencies: 208
-- Name: TABLE "OverUnderHistorical"; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE public."OverUnderHistorical" FROM postgres;
GRANT ALL ON TABLE public."OverUnderHistorical" TO postgres WITH GRANT OPTION;


--
-- TOC entry 3093 (class 0 OID 0)
-- Dependencies: 206
-- Name: TABLE "PortalSafariMatch"; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE public."PortalSafariMatch" FROM postgres;
GRANT ALL ON TABLE public."PortalSafariMatch" TO postgres WITH GRANT OPTION;


--
-- TOC entry 3094 (class 0 OID 0)
-- Dependencies: 209
-- Name: TABLE "PortalSafariBets"; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE public."PortalSafariBets" FROM postgres;
GRANT ALL ON TABLE public."PortalSafariBets" TO postgres WITH GRANT OPTION;


--
-- TOC entry 1757 (class 826 OID 24717)
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: -; Owner: -
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres REVOKE ALL ON TABLES  FROM postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres GRANT ALL ON TABLES  TO postgres WITH GRANT OPTION;


-- Completed on 2023-02-22 16:08:51 EET

--
-- PostgreSQL database dump complete
--


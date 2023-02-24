--
-- PostgreSQL database dump
--

-- Dumped from database version 13.9 (Debian 13.9-0+deb11u1)
-- Dumped by pg_dump version 13.9 (Debian 13.9-0+deb11u1)

-- Started on 2023-02-24 02:50:49 EET

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
-- TOC entry 3096 (class 1262 OID 13445)
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
-- TOC entry 3097 (class 0 OID 0)
-- Dependencies: 3096
-- Name: DATABASE postgres; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON DATABASE postgres IS 'default administrative connection database';


--
-- TOC entry 673 (class 1247 OID 25025)
-- Name: BetResult; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."BetResult" AS ENUM (
    'Won',
    'Lost'
);


--
-- TOC entry 641 (class 1247 OID 24746)
-- Name: MatchTime; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."MatchTime" AS ENUM (
    'Full Time',
    '1st Half',
    '2nd Half'
);


--
-- TOC entry 644 (class 1247 OID 24790)
-- Name: OverUnderType; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."OverUnderType" AS ENUM (
    'Over',
    'Under'
);


--
-- TOC entry 214 (class 1255 OID 24984)
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
-- TOC entry 226 (class 1255 OID 25029)
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
-- TOC entry 212 (class 1255 OID 24779)
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
-- TOC entry 213 (class 1255 OID 24778)
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
-- TOC entry 3099 (class 0 OID 0)
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
    won public."BetResult",
    "Home_Team_Goals_1st_Half" smallint,
    "Home_Team_Goals_2nd_Half" smallint,
    "Guest_Team_Goals_1st_Half" smallint,
    "Guest_Team_Goals_2nd_Half" smallint
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
-- TOC entry 3104 (class 0 OID 0)
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
-- TOC entry 3105 (class 0 OID 0)
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
-- TOC entry 211 (class 1259 OID 25038)
-- Name: soccer_statistics; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.soccer_statistics (
    id bigint NOT NULL,
    home_team character varying NOT NULL,
    guest_team character varying NOT NULL,
    date_time timestamp with time zone NOT NULL,
    goals_home smallint NOT NULL,
    goals_guest smallint NOT NULL,
    full_time_home_win_odds numeric(3,2),
    full_time_draw_odds numeric(3,2),
    full_time_guest_win_odds smallint,
    fisrt_half_home_win_odds numeric(3,2),
    first_half_draw_odds numeric(3,2),
    second_half_goals_guest smallint NOT NULL,
    second_half_goals_home smallint NOT NULL,
    first_half_goals_guest smallint NOT NULL,
    first_half_goals_home smallint NOT NULL,
    first_half_guest_win_odds numeric(3,2),
    second_half_home_win_odds numeric(3,2),
    second_half_draw_odds numeric(3,2) NOT NULL,
    second_half_guest_win_odds numeric(3,2),
    full_time_over_under_goals numeric(3,2),
    full_time_over_odds numeric(3,2),
    full_time_under_odds numeric(3,2),
    full_time_payout numeric(3,1),
    first_half_over_under_goals numeric(3,2),
    first_half_over_odds numeric(3,2),
    firt_half_under_odds numeric(3,2),
    first_half_payout numeric(3,1),
    second_half_over_under_goals numeric(3,2),
    second_half_over_odds numeric(3,2),
    second_half_under_odds numeric(3,2),
    second_half_payout numeric(3,1),
    last_updated timestamp with time zone DEFAULT now() NOT NULL
);


--
-- TOC entry 210 (class 1259 OID 25036)
-- Name: soccer_statistics_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.soccer_statistics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3109 (class 0 OID 0)
-- Dependencies: 210
-- Name: soccer_statistics_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.soccer_statistics_id_seq OWNED BY public.soccer_statistics.id;


--
-- TOC entry 2907 (class 2604 OID 24731)
-- Name: OddsPortalMatch id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsPortalMatch" ALTER COLUMN id SET DEFAULT nextval('public."Match_id_seq"'::regclass);


--
-- TOC entry 2910 (class 2604 OID 24732)
-- Name: OddsPortalOverUnder id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsPortalOverUnder" ALTER COLUMN id SET DEFAULT nextval('public."OverUnder_id_seq"'::regclass);


--
-- TOC entry 2913 (class 2604 OID 24825)
-- Name: OddsSafariMatch id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsSafariMatch" ALTER COLUMN id SET DEFAULT nextval('public."Match_id_seq"'::regclass);


--
-- TOC entry 2914 (class 2604 OID 24826)
-- Name: OddsSafariMatch created; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsSafariMatch" ALTER COLUMN created SET DEFAULT CURRENT_TIMESTAMP;


--
-- TOC entry 2915 (class 2604 OID 24827)
-- Name: OddsSafariMatch updated; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsSafariMatch" ALTER COLUMN updated SET DEFAULT CURRENT_TIMESTAMP;


--
-- TOC entry 2916 (class 2604 OID 24839)
-- Name: OddsSafariOverUnder id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsSafariOverUnder" ALTER COLUMN id SET DEFAULT nextval('public."OverUnder_id_seq"'::regclass);


--
-- TOC entry 2917 (class 2604 OID 24840)
-- Name: OddsSafariOverUnder created; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsSafariOverUnder" ALTER COLUMN created SET DEFAULT CURRENT_TIMESTAMP;


--
-- TOC entry 2918 (class 2604 OID 24841)
-- Name: OddsSafariOverUnder updated; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsSafariOverUnder" ALTER COLUMN updated SET DEFAULT CURRENT_TIMESTAMP;


--
-- TOC entry 2919 (class 2604 OID 24969)
-- Name: OverUnderHistorical id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OverUnderHistorical" ALTER COLUMN id SET DEFAULT nextval('public."OverUnderHistorical_id_seq"'::regclass);


--
-- TOC entry 2920 (class 2604 OID 25041)
-- Name: soccer_statistics id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.soccer_statistics ALTER COLUMN id SET DEFAULT nextval('public.soccer_statistics_id_seq'::regclass);


--
-- TOC entry 3081 (class 0 OID 24718)
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
-- TOC entry 3083 (class 0 OID 24726)
-- Dependencies: 202
-- Data for Name: OddsPortalOverUnder; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."OddsPortalOverUnder" (id, goals, odds, match_id, half, payout, created, updated, type, bet_links) FROM stdin;
4861	1.5	2.58	650	Full Time	97.6%	2023-02-22 04:38:55.966	2023-02-22 04:38:55.966	Under	{}
4862	2.0	2.02	650	Full Time	98.7%	2023-02-22 04:38:55.968098	2023-02-22 04:38:55.968098	Over	{}
4863	2.0	1.93	650	Full Time	98.7%	2023-02-22 04:38:55.970185	2023-02-22 04:38:55.970185	Under	{}
4864	2.5	2.75	650	Full Time	97.9%	2023-02-22 04:38:55.97222	2023-02-22 04:38:55.97222	Over	{}
4865	2.5	1.52	650	Full Time	97.9%	2023-02-22 04:38:55.973715	2023-02-22 04:38:55.973715	Under	{}
4866	3.5	5.75	650	Full Time	97.2%	2023-02-22 04:38:55.975104	2023-02-22 04:38:55.975104	Over	{}
4867	3.5	1.17	650	Full Time	97.2%	2023-02-22 04:38:55.976589	2023-02-22 04:38:55.976589	Under	{}
4868	4.5	13.00	650	Full Time	97.2%	2023-02-22 04:38:55.978553	2023-02-22 04:38:55.978553	Over	{}
4869	4.5	1.05	650	Full Time	97.2%	2023-02-22 04:38:55.980563	2023-02-22 04:38:55.980563	Under	{}
4870	5.5	26.00	650	Full Time	98.1%	2023-02-22 04:38:55.982236	2023-02-22 04:38:55.982236	Over	{}
4871	5.5	1.02	650	Full Time	98.1%	2023-02-22 04:38:55.983237	2023-02-22 04:38:55.983237	Under	{}
4872	6.5	41.00	650	Full Time	97.6%	2023-02-22 04:38:55.984305	2023-02-22 04:38:55.984305	Over	{}
4873	0.5	1.60	650	1st Half	96.0%	2023-02-22 04:38:57.694588	2023-02-22 04:38:57.694588	Over	{}
4874	0.5	2.40	650	1st Half	96.0%	2023-02-22 04:38:59.53855	2023-02-22 04:38:59.53855	Under	{}
4875	0.75	1.89	650	1st Half	96.0%	2023-02-22 04:38:59.540892	2023-02-22 04:38:59.540892	Over	{}
4876	0.75	1.95	650	1st Half	96.0%	2023-02-22 04:38:59.543062	2023-02-22 04:38:59.543062	Under	{}
4877	1.5	3.90	650	1st Half	96.9%	2023-02-22 04:38:59.545633	2023-02-22 04:38:59.545633	Over	{}
4878	1.5	1.29	650	1st Half	96.9%	2023-02-22 04:38:59.547669	2023-02-22 04:38:59.547669	Under	{}
4879	2.5	11.00	650	1st Half	95.9%	2023-02-22 04:38:59.550134	2023-02-22 04:38:59.550134	Over	{}
4880	2.5	1.05	650	1st Half	95.9%	2023-02-22 04:38:59.55153	2023-02-22 04:38:59.55153	Under	{}
4881	3.5	41.00	650	1st Half	98.6%	2023-02-22 04:38:59.552666	2023-02-22 04:38:59.552666	Over	{}
4883	4.5	71.00	650	1st Half	98.6%	2023-02-22 04:38:59.554749	2023-02-22 04:38:59.554749	Over	{}
4884	0.5	1.40	650	2nd Half	95.5%	2023-02-22 04:39:01.705939	2023-02-22 04:39:01.705939	Over	{}
4885	0.5	3.00	650	2nd Half	95.5%	2023-02-22 04:39:02.665402	2023-02-22 04:39:02.665402	Under	{}
4886	1.5	2.85	650	2nd Half	95.7%	2023-02-22 04:39:02.667083	2023-02-22 04:39:02.667083	Over	{}
4887	1.5	1.44	650	2nd Half	95.7%	2023-02-22 04:39:02.668757	2023-02-22 04:39:02.668757	Under	{}
4888	2.5	7.00	650	2nd Half	95.8%	2023-02-22 04:39:02.670873	2023-02-22 04:39:02.670873	Over	{}
4889	2.5	1.11	650	2nd Half	95.8%	2023-02-22 04:39:02.672554	2023-02-22 04:39:02.672554	Under	{}
4890	3.5	19.00	650	2nd Half	96.8%	2023-02-22 04:39:02.674812	2023-02-22 04:39:02.674812	Over	{}
4891	3.5	1.02	650	2nd Half	96.8%	2023-02-22 04:39:02.67663	2023-02-22 04:39:02.67663	Under	{}
4892	0.5	1.11	653	Full Time	98.2%	2023-02-22 04:39:15.315092	2023-02-22 04:39:15.315092	Over	{}
4893	0.5	8.50	653	Full Time	98.2%	2023-02-22 04:39:15.316772	2023-02-22 04:39:15.316772	Under	{}
4894	1.5	1.45	653	Full Time	96.7%	2023-02-22 04:39:15.317699	2023-02-22 04:39:15.317699	Over	{}
4895	1.5	2.90	653	Full Time	96.7%	2023-02-22 04:39:15.318695	2023-02-22 04:39:15.318695	Under	{}
4896	2.25	2.10	653	Full Time	96.6%	2023-02-22 04:39:15.319479	2023-02-22 04:39:15.319479	Over	{}
4897	2.25	1.79	653	Full Time	96.6%	2023-02-22 04:39:15.320427	2023-02-22 04:39:15.320427	Under	{}
4898	2.5	2.36	653	Full Time	95.7%	2023-02-22 04:39:15.321423	2023-02-22 04:39:15.321423	Over	{}
4899	2.5	1.61	653	Full Time	95.7%	2023-02-22 04:39:15.322905	2023-02-22 04:39:15.322905	Under	{}
4900	3.5	4.33	653	Full Time	95.2%	2023-02-22 04:39:15.324092	2023-02-22 04:39:15.324092	Over	{}
4901	3.5	1.22	653	Full Time	95.2%	2023-02-22 04:39:15.3252	2023-02-22 04:39:15.3252	Under	{}
4902	4.5	10.00	653	Full Time	95.8%	2023-02-22 04:39:15.32601	2023-02-22 04:39:15.32601	Over	{}
4903	4.5	1.06	653	Full Time	95.8%	2023-02-22 04:39:15.326993	2023-02-22 04:39:15.326993	Under	{}
4904	5.5	21.00	653	Full Time	97.3%	2023-02-22 04:39:15.328073	2023-02-22 04:39:15.328073	Over	{}
4905	5.5	1.02	653	Full Time	97.3%	2023-02-22 04:39:15.329099	2023-02-22 04:39:15.329099	Under	{}
4906	6.5	51.00	653	Full Time	98.1%	2023-02-22 04:39:15.329821	2023-02-22 04:39:15.329821	Over	{}
4907	0.5	1.53	653	1st Half	96.6%	2023-02-22 04:39:17.754267	2023-02-22 04:39:17.754267	Over	{}
4908	0.5	2.62	653	1st Half	96.6%	2023-02-22 04:39:19.645078	2023-02-22 04:39:19.645078	Under	{}
4909	0.75	1.75	653	1st Half	94.8%	2023-02-22 04:39:19.646334	2023-02-22 04:39:19.646334	Over	{}
4910	0.75	2.07	653	1st Half	94.8%	2023-02-22 04:39:19.647289	2023-02-22 04:39:19.647289	Under	{}
4911	1.5	3.50	653	1st Half	97.9%	2023-02-22 04:39:19.648361	2023-02-22 04:39:19.648361	Over	{}
4912	1.5	1.36	653	1st Half	97.9%	2023-02-22 04:39:19.649325	2023-02-22 04:39:19.649325	Under	{}
4914	2.5	1.07	653	1st Half	97.5%	2023-02-22 04:39:19.651405	2023-02-22 04:39:19.651405	Under	{}
4915	3.5	34.00	653	1st Half	98.1%	2023-02-22 04:39:19.652511	2023-02-22 04:39:19.652511	Over	{}
4916	3.5	1.01	653	1st Half	98.1%	2023-02-22 04:39:19.653609	2023-02-22 04:39:19.653609	Under	{}
4917	4.5	61.00	653	1st Half	98.4%	2023-02-22 04:39:19.654816	2023-02-22 04:39:19.654816	Over	{}
4918	0.5	1.36	653	2nd Half	97.1%	2023-02-22 04:39:21.354681	2023-02-22 04:39:21.354681	Over	{}
6603	6.5	1.01	618	Full Time	97.6%	2023-02-24 01:22:32.902016	2023-02-24 01:22:32.902016	Under	{}
4621	1.5	1.50	621	1st Half	97.1%	2023-02-18 05:09:36.609202	2023-02-18 05:09:36.609202	Under	{}
4858	0.5	1.13	650	Full Time	98.2%	2023-02-22 04:38:55.959661	2023-02-22 04:38:55.959661	Over	{}
4859	0.5	7.50	650	Full Time	98.2%	2023-02-22 04:38:55.962504	2023-02-22 04:38:55.962504	Under	{}
4860	1.5	1.57	650	Full Time	97.6%	2023-02-22 04:38:55.964431	2023-02-22 04:38:55.964431	Over	{}
4655	1.0	1.79	624	1st Half	97.5%	2023-02-18 05:09:59.153478	2023-02-18 05:09:59.153478	Under	{}
4803	6.5	1.01	621	Full Time	96.8%	2023-02-22 04:38:17.887148	2023-02-22 04:38:17.887148	Under	{}
7251	7.5	51.00	621	Full Time	98.1%	2023-02-24 02:33:52.787384	2023-02-24 02:33:52.787384	Over	{}
7254	0.75	1.48	621	1st Half	95.0%	2023-02-24 02:33:57.251137	2023-02-24 02:33:57.251137	Over	{}
7255	0.75	2.65	621	1st Half	95.0%	2023-02-24 02:33:57.252579	2023-02-24 02:33:57.252579	Under	{}
7258	1.25	2.26	621	1st Half	95.4%	2023-02-24 02:33:57.256553	2023-02-24 02:33:57.256553	Over	{}
7259	1.25	1.65	621	1st Half	95.4%	2023-02-24 02:33:57.257885	2023-02-24 02:33:57.257885	Under	{}
7262	1.75	3.26	621	1st Half	93.4%	2023-02-24 02:33:57.262946	2023-02-24 02:33:57.262946	Over	{}
7263	1.75	1.31	621	1st Half	93.4%	2023-02-24 02:33:57.264432	2023-02-24 02:33:57.264432	Under	{}
7264	2.0	5.10	621	1st Half	95.2%	2023-02-24 02:33:57.266156	2023-02-24 02:33:57.266156	Over	{}
7265	2.0	1.17	621	1st Half	95.2%	2023-02-24 02:33:57.267421	2023-02-24 02:33:57.267421	Under	{}
7266	2.25	5.65	621	1st Half	93.5%	2023-02-24 02:33:57.269282	2023-02-24 02:33:57.269282	Over	{}
7267	2.25	1.12	621	1st Half	93.5%	2023-02-24 02:33:57.271347	2023-02-24 02:33:57.271347	Under	{}
7270	3.0	12.00	621	1st Half	94.0%	2023-02-24 02:33:57.276144	2023-02-24 02:33:57.276144	Over	{}
7271	3.0	1.02	621	1st Half	94.0%	2023-02-24 02:33:57.277778	2023-02-24 02:33:57.277778	Under	{}
7278	0.75	1.27	621	2nd Half	93.5%	2023-02-24 02:34:02.80945	2023-02-24 02:34:02.80945	Over	{}
7279	0.75	3.54	621	2nd Half	93.5%	2023-02-24 02:34:02.81173	2023-02-24 02:34:02.81173	Under	{}
7280	1.0	1.37	621	2nd Half	94.5%	2023-02-24 02:34:02.814595	2023-02-24 02:34:02.814595	Over	{}
7281	1.0	3.05	621	2nd Half	94.5%	2023-02-24 02:34:02.817184	2023-02-24 02:34:02.817184	Under	{}
6659	4.5	26.00	621	2nd Half	97.2%	2023-02-24 01:23:00.329776	2023-02-24 01:23:00.329776	Over	{}
6660	4.5	1.01	621	2nd Half	97.2%	2023-02-24 01:23:00.33217	2023-02-24 01:23:00.33217	Under	{}
4919	0.5	3.40	653	2nd Half	97.1%	2023-02-22 04:39:22.292822	2023-02-22 04:39:22.292822	Under	{}
4920	1.5	2.60	653	2nd Half	96.3%	2023-02-22 04:39:22.294028	2023-02-22 04:39:22.294028	Over	{}
4921	1.5	1.53	653	2nd Half	96.3%	2023-02-22 04:39:22.295214	2023-02-22 04:39:22.295214	Under	{}
4922	2.5	6.00	653	2nd Half	95.1%	2023-02-22 04:39:22.296452	2023-02-22 04:39:22.296452	Over	{}
4923	2.5	1.13	653	2nd Half	95.1%	2023-02-22 04:39:22.297705	2023-02-22 04:39:22.297705	Under	{}
4924	3.5	17.00	653	2nd Half	97.1%	2023-02-22 04:39:22.298885	2023-02-22 04:39:22.298885	Over	{}
7282	1.25	1.69	621	2nd Half	93.6%	2023-02-24 02:34:02.820095	2023-02-24 02:34:02.820095	Over	{}
7283	1.25	2.10	621	2nd Half	93.6%	2023-02-24 02:34:02.822427	2023-02-24 02:34:02.822427	Under	{}
7286	1.75	2.36	621	2nd Half	93.6%	2023-02-24 02:34:02.828931	2023-02-24 02:34:02.828931	Over	{}
7287	1.75	1.55	621	2nd Half	93.6%	2023-02-24 02:34:02.830141	2023-02-24 02:34:02.830141	Under	{}
7288	2.0	3.14	621	2nd Half	94.9%	2023-02-24 02:34:02.831366	2023-02-24 02:34:02.831366	Over	{}
7289	2.0	1.36	621	2nd Half	94.9%	2023-02-24 02:34:02.834245	2023-02-24 02:34:02.834245	Under	{}
7290	2.25	3.62	621	2nd Half	93.5%	2023-02-24 02:34:02.835813	2023-02-24 02:34:02.835813	Over	{}
7291	2.25	1.26	621	2nd Half	93.5%	2023-02-24 02:34:02.837227	2023-02-24 02:34:02.837227	Under	{}
4925	3.5	1.03	653	2nd Half	97.1%	2023-02-22 04:39:22.300081	2023-02-22 04:39:22.300081	Under	{}
4987	0.5	3.54	659	2nd Half	98.3%	2023-02-22 04:40:00.560956	2023-02-22 04:40:00.560956	Under	{}
7221	2.25	1.56	621	Full Time	95.6%	2023-02-24 02:33:52.750232	2023-02-24 02:33:52.750232	Over	{}
7222	2.25	2.47	621	Full Time	95.6%	2023-02-24 02:33:52.75184	2023-02-24 02:33:52.75184	Under	{}
6629	2.75	1.98	621	Full Time	96.4%	2023-02-24 01:22:53.181341	2023-02-24 01:22:53.181341	Over	{}
6630	2.75	1.88	621	Full Time	96.4%	2023-02-24 01:22:53.182568	2023-02-24 01:22:53.182568	Under	{}
7227	3.0	2.29	621	Full Time	95.9%	2023-02-24 02:33:52.760237	2023-02-24 02:33:52.760237	Over	{}
7228	3.0	1.65	621	Full Time	95.9%	2023-02-24 02:33:52.761903	2023-02-24 02:33:52.761903	Under	{}
7229	3.25	2.60	621	Full Time	95.1%	2023-02-24 02:33:52.763198	2023-02-24 02:33:52.763198	Over	{}
7230	3.25	1.50	621	Full Time	95.1%	2023-02-24 02:33:52.764212	2023-02-24 02:33:52.764212	Under	{}
7233	3.75	3.45	621	Full Time	94.9%	2023-02-24 02:33:52.767624	2023-02-24 02:33:52.767624	Over	{}
7234	3.75	1.31	621	Full Time	94.9%	2023-02-24 02:33:52.769113	2023-02-24 02:33:52.769113	Under	{}
7235	4.0	4.45	621	Full Time	93.9%	2023-02-24 02:33:52.770147	2023-02-24 02:33:52.770147	Over	{}
7236	4.0	1.19	621	Full Time	93.9%	2023-02-24 02:33:52.771235	2023-02-24 02:33:52.771235	Under	{}
7237	4.25	4.80	621	Full Time	94.1%	2023-02-24 02:33:52.77245	2023-02-24 02:33:52.77245	Over	{}
7238	4.25	1.17	621	Full Time	94.1%	2023-02-24 02:33:52.774056	2023-02-24 02:33:52.774056	Under	{}
7241	4.75	6.50	621	Full Time	94.1%	2023-02-24 02:33:52.777286	2023-02-24 02:33:52.777286	Over	{}
7242	4.75	1.10	621	Full Time	94.1%	2023-02-24 02:33:52.778676	2023-02-24 02:33:52.778676	Under	{}
7243	5.0	9.04	621	Full Time	94.1%	2023-02-24 02:33:52.779558	2023-02-24 02:33:52.779558	Over	{}
7244	5.0	1.05	621	Full Time	94.1%	2023-02-24 02:33:52.780541	2023-02-24 02:33:52.780541	Under	{}
7245	5.25	9.86	621	Full Time	94.1%	2023-02-24 02:33:52.781361	2023-02-24 02:33:52.781361	Over	{}
7246	5.25	1.04	621	Full Time	94.1%	2023-02-24 02:33:52.782238	2023-02-24 02:33:52.782238	Under	{}
7294	3.0	7.72	621	2nd Half	94.0%	2023-02-24 02:34:02.841706	2023-02-24 02:34:02.841706	Over	{}
7295	3.0	1.07	621	2nd Half	94.0%	2023-02-24 02:34:02.84323	2023-02-24 02:34:02.84323	Under	{}
7302	0.75	1.08	624	Full Time	94.7%	2023-02-24 02:34:21.488486	2023-02-24 02:34:21.488486	Over	{}
7303	0.75	7.70	624	Full Time	94.7%	2023-02-24 02:34:21.48944	2023-02-24 02:34:21.48944	Under	{}
7304	1.0	1.08	624	Full Time	92.9%	2023-02-24 02:34:21.490554	2023-02-24 02:34:21.490554	Over	{}
7305	1.0	6.65	624	Full Time	92.9%	2023-02-24 02:34:21.49153	2023-02-24 02:34:21.49153	Under	{}
7306	1.25	1.23	624	Full Time	94.1%	2023-02-24 02:34:21.492495	2023-02-24 02:34:21.492495	Over	{}
7307	1.25	4.00	624	Full Time	94.1%	2023-02-24 02:34:21.493545	2023-02-24 02:34:21.493545	Under	{}
4930	2.25	2.19	656	Full Time	96.0%	2023-02-22 04:39:34.467201	2023-02-22 04:39:34.467201	Over	{}
4933	2.5	1.55	656	Full Time	96.1%	2023-02-22 04:39:34.472102	2023-02-22 04:39:34.472102	Under	{}
4934	3.5	5.00	656	Full Time	96.8%	2023-02-22 04:39:34.473397	2023-02-22 04:39:34.473397	Over	{}
4937	4.5	1.06	656	Full Time	96.7%	2023-02-22 04:39:34.478073	2023-02-22 04:39:34.478073	Under	{}
4938	5.5	26.00	656	Full Time	98.1%	2023-02-22 04:39:34.479312	2023-02-22 04:39:34.479312	Over	{}
4939	5.5	1.02	656	Full Time	98.1%	2023-02-22 04:39:34.480655	2023-02-22 04:39:34.480655	Under	{}
4940	6.5	51.00	656	Full Time	98.1%	2023-02-22 04:39:34.481941	2023-02-22 04:39:34.481941	Over	{}
4941	0.5	1.55	656	1st Half	95.7%	2023-02-22 04:39:36.105811	2023-02-22 04:39:36.105811	Over	{}
4942	0.5	2.50	656	1st Half	95.7%	2023-02-22 04:39:37.655761	2023-02-22 04:39:37.655761	Under	{}
4943	0.75	1.81	656	1st Half	95.0%	2023-02-22 04:39:37.656993	2023-02-22 04:39:37.656993	Over	{}
4944	0.75	2.00	656	1st Half	95.0%	2023-02-22 04:39:37.658187	2023-02-22 04:39:37.658187	Under	{}
4945	1.5	3.60	656	1st Half	95.5%	2023-02-22 04:39:37.65986	2023-02-22 04:39:37.65986	Over	{}
4946	1.5	1.30	656	1st Half	95.5%	2023-02-22 04:39:37.661159	2023-02-22 04:39:37.661159	Under	{}
4947	2.5	11.00	656	1st Half	96.7%	2023-02-22 04:39:37.66276	2023-02-22 04:39:37.66276	Over	{}
4948	2.5	1.06	656	1st Half	96.7%	2023-02-22 04:39:37.664257	2023-02-22 04:39:37.664257	Under	{}
4949	3.5	34.00	656	1st Half	98.1%	2023-02-22 04:39:37.665585	2023-02-22 04:39:37.665585	Over	{}
4950	3.5	1.01	656	1st Half	98.1%	2023-02-22 04:39:37.666668	2023-02-22 04:39:37.666668	Under	{}
4951	4.5	67.00	656	1st Half	98.5%	2023-02-22 04:39:37.667777	2023-02-22 04:39:37.667777	Over	{}
4952	0.5	1.36	656	2nd Half	95.9%	2023-02-22 04:39:39.809649	2023-02-22 04:39:39.809649	Over	{}
4953	0.5	3.25	656	2nd Half	95.9%	2023-02-22 04:39:40.962336	2023-02-22 04:39:40.962336	Under	{}
4954	1.5	2.65	656	2nd Half	95.8%	2023-02-22 04:39:40.964164	2023-02-22 04:39:40.964164	Over	{}
4955	1.5	1.50	656	2nd Half	95.8%	2023-02-22 04:39:40.966643	2023-02-22 04:39:40.966643	Under	{}
4957	2.5	1.12	656	2nd Half	95.5%	2023-02-22 04:39:40.971448	2023-02-22 04:39:40.971448	Under	{}
4958	3.5	19.00	656	2nd Half	97.7%	2023-02-22 04:39:40.97377	2023-02-22 04:39:40.97377	Over	{}
4959	3.5	1.03	656	2nd Half	97.7%	2023-02-22 04:39:40.9752	2023-02-22 04:39:40.9752	Under	{}
4960	0.5	1.08	659	Full Time	97.0%	2023-02-22 04:39:53.895554	2023-02-22 04:39:53.895554	Over	{}
4961	0.5	9.50	659	Full Time	97.0%	2023-02-22 04:39:53.898266	2023-02-22 04:39:53.898266	Under	{}
4962	1.5	1.40	659	Full Time	96.2%	2023-02-22 04:39:53.900993	2023-02-22 04:39:53.900993	Over	{}
4963	1.5	3.07	659	Full Time	96.2%	2023-02-22 04:39:53.902856	2023-02-22 04:39:53.902856	Under	{}
4964	2.25	1.93	659	Full Time	97.2%	2023-02-22 04:39:53.905023	2023-02-22 04:39:53.905023	Over	{}
4965	2.25	1.96	659	Full Time	97.2%	2023-02-22 04:39:53.906998	2023-02-22 04:39:53.906998	Under	{}
4966	2.5	2.18	659	Full Time	96.8%	2023-02-22 04:39:53.909479	2023-02-22 04:39:53.909479	Over	{}
4967	2.5	1.74	659	Full Time	96.8%	2023-02-22 04:39:53.910842	2023-02-22 04:39:53.910842	Under	{}
4968	3.5	4.20	659	Full Time	96.3%	2023-02-22 04:39:53.911754	2023-02-22 04:39:53.911754	Over	{}
4969	3.5	1.25	659	Full Time	96.3%	2023-02-22 04:39:53.912839	2023-02-22 04:39:53.912839	Under	{}
4970	4.5	9.00	659	Full Time	95.6%	2023-02-22 04:39:53.913879	2023-02-22 04:39:53.913879	Over	{}
4971	4.5	1.07	659	Full Time	95.6%	2023-02-22 04:39:53.916796	2023-02-22 04:39:53.916796	Under	{}
4972	5.5	19.00	659	Full Time	96.8%	2023-02-22 04:39:53.917959	2023-02-22 04:39:53.917959	Over	{}
4973	5.5	1.02	659	Full Time	96.8%	2023-02-22 04:39:53.91916	2023-02-22 04:39:53.91916	Under	{}
4974	6.5	41.00	659	Full Time	97.6%	2023-02-22 04:39:53.920459	2023-02-22 04:39:53.920459	Over	{}
4975	0.5	1.46	659	1st Half	95.1%	2023-02-22 04:39:55.454538	2023-02-22 04:39:55.454538	Over	{}
4976	0.5	2.73	659	1st Half	95.1%	2023-02-22 04:39:57.176598	2023-02-22 04:39:57.176598	Under	{}
4977	1.0	2.10	659	1st Half	95.2%	2023-02-22 04:39:57.178886	2023-02-22 04:39:57.178886	Over	{}
4978	1.0	1.74	659	1st Half	95.2%	2023-02-22 04:39:57.179852	2023-02-22 04:39:57.179852	Under	{}
4979	1.5	3.26	659	1st Half	96.0%	2023-02-22 04:39:57.180866	2023-02-22 04:39:57.180866	Over	{}
4980	1.5	1.36	659	1st Half	96.0%	2023-02-22 04:39:57.181782	2023-02-22 04:39:57.181782	Under	{}
4981	2.5	9.00	659	1st Half	95.6%	2023-02-22 04:39:57.182661	2023-02-22 04:39:57.182661	Over	{}
4982	2.5	1.07	659	1st Half	95.6%	2023-02-22 04:39:57.183742	2023-02-22 04:39:57.183742	Under	{}
4983	3.5	26.00	659	1st Half	97.2%	2023-02-22 04:39:57.184667	2023-02-22 04:39:57.184667	Over	{}
4984	3.5	1.01	659	1st Half	97.2%	2023-02-22 04:39:57.185682	2023-02-22 04:39:57.185682	Under	{}
4985	4.5	61.00	659	1st Half	98.4%	2023-02-22 04:39:57.186657	2023-02-22 04:39:57.186657	Over	{}
4986	0.5	1.36	659	2nd Half	98.3%	2023-02-22 04:39:59.495627	2023-02-22 04:39:59.495627	Over	{}
4988	1.5	2.40	659	2nd Half	96.0%	2023-02-22 04:40:00.562021	2023-02-22 04:40:00.562021	Over	{}
4989	1.5	1.60	659	2nd Half	96.0%	2023-02-22 04:40:00.562997	2023-02-22 04:40:00.562997	Under	{}
4990	2.5	5.50	659	2nd Half	95.1%	2023-02-22 04:40:00.563982	2023-02-22 04:40:00.563982	Over	{}
7120	0.75	1.06	618	Full Time	94.2%	2023-02-24 02:33:24.544765	2023-02-24 02:33:24.544765	Over	{}
4928	1.5	1.51	656	Full Time	96.8%	2023-02-22 04:39:34.462577	2023-02-22 04:39:34.462577	Over	{}
4929	1.5	2.70	656	Full Time	96.8%	2023-02-22 04:39:34.464803	2023-02-22 04:39:34.464803	Under	{}
4935	3.5	1.20	656	Full Time	96.8%	2023-02-22 04:39:34.474547	2023-02-22 04:39:34.474547	Under	{}
4936	4.5	11.00	656	Full Time	96.7%	2023-02-22 04:39:34.476755	2023-02-22 04:39:34.476755	Over	{}
4931	2.25	1.71	656	Full Time	96.0%	2023-02-22 04:39:34.469352	2023-02-22 04:39:34.469352	Under	{}
4932	2.5	2.53	656	Full Time	96.1%	2023-02-22 04:39:34.470936	2023-02-22 04:39:34.470936	Over	{}
4581	5.5	17.00	618	Full Time	96.2%	2023-02-18 05:09:11.002091	2023-02-18 05:09:11.002091	Over	{}
4582	5.5	1.02	618	Full Time	96.2%	2023-02-18 05:09:11.003456	2023-02-18 05:09:11.003456	Under	{}
4583	6.5	29.00	618	Full Time	97.6%	2023-02-18 05:09:11.004677	2023-02-18 05:09:11.004677	Over	{}
4584	0.5	1.44	618	1st Half	96.8%	2023-02-18 05:09:12.691575	2023-02-18 05:09:12.691575	Over	{}
4585	0.5	2.95	618	1st Half	96.8%	2023-02-18 05:09:14.286059	2023-02-18 05:09:14.286059	Under	{}
7162	0.75	1.60	618	1st Half	95.5%	2023-02-24 02:33:30.011139	2023-02-24 02:33:30.011139	Over	{}
4586	1.0	1.99	618	1st Half	95.9%	2023-02-18 05:09:14.288406	2023-02-18 05:09:14.288406	Over	{}
4587	1.0	1.85	618	1st Half	95.9%	2023-02-18 05:09:14.290122	2023-02-18 05:09:14.290122	Under	{}
7166	1.25	2.56	618	1st Half	95.4%	2023-02-24 02:33:30.015791	2023-02-24 02:33:30.015791	Over	{}
7167	1.25	1.52	618	1st Half	95.4%	2023-02-24 02:33:30.016855	2023-02-24 02:33:30.016855	Under	{}
4588	1.5	3.11	618	1st Half	96.5%	2023-02-18 05:09:14.29236	2023-02-18 05:09:14.29236	Over	{}
7163	0.75	2.37	618	1st Half	95.5%	2023-02-24 02:33:30.012261	2023-02-24 02:33:30.012261	Under	{}
4589	1.5	1.40	618	1st Half	96.5%	2023-02-18 05:09:14.294579	2023-02-18 05:09:14.294579	Under	{}
7170	1.75	3.80	618	1st Half	93.5%	2023-02-24 02:33:30.020043	2023-02-24 02:33:30.020043	Over	{}
7171	1.75	1.24	618	1st Half	93.5%	2023-02-24 02:33:30.021155	2023-02-24 02:33:30.021155	Under	{}
7172	2.0	6.30	618	1st Half	93.6%	2023-02-24 02:33:30.022424	2023-02-24 02:33:30.022424	Over	{}
4590	2.5	8.00	618	1st Half	95.2%	2023-02-18 05:09:14.296293	2023-02-18 05:09:14.296293	Over	{}
4591	2.5	1.08	618	1st Half	95.2%	2023-02-18 05:09:14.298678	2023-02-18 05:09:14.298678	Under	{}
4991	2.5	1.15	659	2nd Half	95.1%	2023-02-22 04:40:00.565235	2023-02-22 04:40:00.565235	Under	{}
4992	3.5	15.00	659	2nd Half	96.4%	2023-02-22 04:40:00.566324	2023-02-22 04:40:00.566324	Over	{}
4993	3.5	1.03	659	2nd Half	96.4%	2023-02-22 04:40:00.567494	2023-02-22 04:40:00.567494	Under	{}
4569	0.5	1.06	618	Full Time	97.4%	2023-02-18 05:09:10.977183	2023-02-18 05:09:10.977183	Over	{}
4570	0.5	12.00	618	Full Time	97.4%	2023-02-18 05:09:10.98166	2023-02-18 05:09:10.98166	Under	{}
7121	0.75	8.50	618	Full Time	94.2%	2023-02-24 02:33:24.54852	2023-02-24 02:33:24.54852	Under	{}
7122	1.0	1.07	618	Full Time	93.6%	2023-02-24 02:33:24.550093	2023-02-24 02:33:24.550093	Over	{}
7123	1.0	7.50	618	Full Time	93.6%	2023-02-24 02:33:24.551669	2023-02-24 02:33:24.551669	Under	{}
7124	1.25	1.20	618	Full Time	94.1%	2023-02-24 02:33:24.553368	2023-02-24 02:33:24.553368	Over	{}
7125	1.25	4.35	618	Full Time	94.1%	2023-02-24 02:33:24.554978	2023-02-24 02:33:24.554978	Under	{}
4571	1.5	1.33	618	Full Time	95.6%	2023-02-18 05:09:10.984119	2023-02-18 05:09:10.984119	Over	{}
4572	1.5	3.40	618	Full Time	95.6%	2023-02-18 05:09:10.986719	2023-02-18 05:09:10.986719	Under	{}
7128	1.75	1.40	618	Full Time	94.1%	2023-02-24 02:33:24.559999	2023-02-24 02:33:24.559999	Over	{}
7129	1.75	2.87	618	Full Time	94.1%	2023-02-24 02:33:24.561652	2023-02-24 02:33:24.561652	Under	{}
4573	2.25	1.80	618	Full Time	96.1%	2023-02-18 05:09:10.989024	2023-02-18 05:09:10.989024	Over	{}
4574	2.25	2.06	618	Full Time	96.1%	2023-02-18 05:09:10.990479	2023-02-18 05:09:10.990479	Under	{}
4575	2.5	2.05	618	Full Time	96.7%	2023-02-18 05:09:10.992211	2023-02-18 05:09:10.992211	Over	{}
4576	2.5	1.83	618	Full Time	96.7%	2023-02-18 05:09:10.993517	2023-02-18 05:09:10.993517	Under	{}
7136	2.75	2.34	618	Full Time	95.4%	2023-02-24 02:33:24.572715	2023-02-24 02:33:24.572715	Over	{}
7137	2.75	1.61	618	Full Time	95.4%	2023-02-24 02:33:24.574403	2023-02-24 02:33:24.574403	Under	{}
7138	3.0	2.91	618	Full Time	95.4%	2023-02-24 02:33:24.576094	2023-02-24 02:33:24.576094	Over	{}
7139	3.0	1.42	618	Full Time	95.4%	2023-02-24 02:33:24.577694	2023-02-24 02:33:24.577694	Under	{}
7140	3.25	3.21	618	Full Time	94.5%	2023-02-24 02:33:24.578849	2023-02-24 02:33:24.578849	Over	{}
7141	3.25	1.34	618	Full Time	94.5%	2023-02-24 02:33:24.579812	2023-02-24 02:33:24.579812	Under	{}
4577	3.5	3.75	618	Full Time	96.5%	2023-02-18 05:09:10.994971	2023-02-18 05:09:10.994971	Over	{}
4578	3.5	1.30	618	Full Time	96.5%	2023-02-18 05:09:10.99676	2023-02-18 05:09:10.99676	Under	{}
7144	3.75	4.35	618	Full Time	94.1%	2023-02-24 02:33:24.58268	2023-02-24 02:33:24.58268	Over	{}
7145	3.75	1.20	618	Full Time	94.1%	2023-02-24 02:33:24.583675	2023-02-24 02:33:24.583675	Under	{}
7146	4.0	6.00	618	Full Time	93.7%	2023-02-24 02:33:24.584612	2023-02-24 02:33:24.584612	Over	{}
7147	4.0	1.11	618	Full Time	93.7%	2023-02-24 02:33:24.585691	2023-02-24 02:33:24.585691	Under	{}
7148	4.25	6.50	618	Full Time	94.1%	2023-02-24 02:33:24.586824	2023-02-24 02:33:24.586824	Over	{}
7149	4.25	1.10	618	Full Time	94.1%	2023-02-24 02:33:24.587875	2023-02-24 02:33:24.587875	Under	{}
4579	4.5	7.50	618	Full Time	95.9%	2023-02-18 05:09:10.998557	2023-02-18 05:09:10.998557	Over	{}
4580	4.5	1.10	618	Full Time	95.9%	2023-02-18 05:09:11.000659	2023-02-18 05:09:11.000659	Under	{}
7152	4.75	9.04	618	Full Time	94.9%	2023-02-24 02:33:24.591344	2023-02-24 02:33:24.591344	Over	{}
7153	4.75	1.06	618	Full Time	94.9%	2023-02-24 02:33:24.592335	2023-02-24 02:33:24.592335	Under	{}
7154	5.0	10.50	618	Full Time	93.8%	2023-02-24 02:33:24.593303	2023-02-24 02:33:24.593303	Over	{}
7155	5.0	1.03	618	Full Time	93.8%	2023-02-24 02:33:24.594238	2023-02-24 02:33:24.594238	Under	{}
7173	2.0	1.10	618	1st Half	93.6%	2023-02-24 02:33:30.023511	2023-02-24 02:33:30.023511	Under	{}
7130	2.0	1.53	618	Full Time	95.8%	2023-02-24 02:33:24.563276	2023-02-24 02:33:24.563276	Over	{}
7131	2.0	2.56	618	Full Time	95.8%	2023-02-24 02:33:24.564758	2023-02-24 02:33:24.564758	Under	{}
7174	2.25	6.90	618	1st Half	94.1%	2023-02-24 02:33:30.024621	2023-02-24 02:33:30.024621	Over	{}
7175	2.25	1.09	618	1st Half	94.1%	2023-02-24 02:33:30.025906	2023-02-24 02:33:30.025906	Under	{}
7178	2.75	8.70	618	1st Half	92.9%	2023-02-24 02:33:30.029348	2023-02-24 02:33:30.029348	Over	{}
7179	2.75	1.04	618	1st Half	92.9%	2023-02-24 02:33:30.03046	2023-02-24 02:33:30.03046	Under	{}
4645	3.5	1.26	624	Full Time	95.2%	2023-02-18 05:09:55.338514	2023-02-18 05:09:55.338514	Under	{}
4596	0.5	3.75	618	2nd Half	96.5%	2023-02-18 05:09:17.136869	2023-02-18 05:09:17.136869	Under	{}
4646	4.5	8.00	624	Full Time	95.2%	2023-02-18 05:09:55.339989	2023-02-18 05:09:55.339989	Over	{}
4597	1.5	2.30	618	2nd Half	95.4%	2023-02-18 05:09:17.138729	2023-02-18 05:09:17.138729	Over	{}
4603	0.5	1.05	621	Full Time	97.2%	2023-02-18 05:09:33.52181	2023-02-18 05:09:33.52181	Over	{}
4604	0.5	13.00	621	Full Time	97.2%	2023-02-18 05:09:33.526386	2023-02-18 05:09:33.526386	Under	{}
4605	1.5	1.25	621	Full Time	95.2%	2023-02-18 05:09:33.529052	2023-02-18 05:09:33.529052	Over	{}
4606	1.5	4.00	621	Full Time	95.2%	2023-02-18 05:09:33.53132	2023-02-18 05:09:33.53132	Under	{}
4607	2.5	1.80	621	Full Time	97.3%	2023-02-18 05:09:33.533266	2023-02-18 05:09:33.533266	Over	{}
4608	2.5	2.12	621	Full Time	97.3%	2023-02-18 05:09:33.535247	2023-02-18 05:09:33.535247	Under	{}
4609	3.5	3.15	621	Full Time	97.9%	2023-02-18 05:09:33.537511	2023-02-18 05:09:33.537511	Over	{}
4610	3.5	1.42	621	Full Time	97.9%	2023-02-18 05:09:33.539499	2023-02-18 05:09:33.539499	Under	{}
4611	4.5	6.10	621	Full Time	96.8%	2023-02-18 05:09:33.541371	2023-02-18 05:09:33.541371	Over	{}
4612	4.5	1.15	621	Full Time	96.8%	2023-02-18 05:09:33.54367	2023-02-18 05:09:33.54367	Under	{}
4613	5.5	12.00	621	Full Time	96.6%	2023-02-18 05:09:33.545782	2023-02-18 05:09:33.545782	Over	{}
4614	5.5	1.05	621	Full Time	96.6%	2023-02-18 05:09:33.547267	2023-02-18 05:09:33.547267	Under	{}
4615	6.5	23.00	621	Full Time	96.8%	2023-02-18 05:09:33.548455	2023-02-18 05:09:33.548455	Over	{}
4616	0.5	1.36	621	1st Half	96.3%	2023-02-18 05:09:35.144799	2023-02-18 05:09:35.144799	Over	{}
4617	0.5	3.30	621	1st Half	96.3%	2023-02-18 05:09:36.604833	2023-02-18 05:09:36.604833	Under	{}
4618	1.0	1.76	621	1st Half	97.4%	2023-02-18 05:09:36.605983	2023-02-18 05:09:36.605983	Over	{}
4619	1.0	2.18	621	1st Half	97.4%	2023-02-18 05:09:36.607052	2023-02-18 05:09:36.607052	Under	{}
4620	1.5	2.75	621	1st Half	97.1%	2023-02-18 05:09:36.60816	2023-02-18 05:09:36.60816	Over	{}
4622	2.5	7.00	621	1st Half	96.6%	2023-02-18 05:09:36.610529	2023-02-18 05:09:36.610529	Over	{}
4623	2.5	1.12	621	1st Half	96.6%	2023-02-18 05:09:36.611702	2023-02-18 05:09:36.611702	Under	{}
4624	3.5	19.00	621	1st Half	96.8%	2023-02-18 05:09:36.612751	2023-02-18 05:09:36.612751	Over	{}
4625	3.5	1.02	621	1st Half	96.8%	2023-02-18 05:09:36.613698	2023-02-18 05:09:36.613698	Under	{}
4626	4.5	46.00	621	1st Half	98.8%	2023-02-18 05:09:36.614899	2023-02-18 05:09:36.614899	Over	{}
4627	4.5	1.01	621	1st Half	98.8%	2023-02-18 05:09:36.615896	2023-02-18 05:09:36.615896	Under	{}
4628	0.5	1.29	621	2nd Half	98.7%	2023-02-18 05:09:38.159055	2023-02-18 05:09:38.159055	Over	{}
4629	0.5	4.20	621	2nd Half	98.7%	2023-02-18 05:09:39.380405	2023-02-18 05:09:39.380405	Under	{}
4630	1.5	2.20	621	2nd Half	99.0%	2023-02-18 05:09:39.382326	2023-02-18 05:09:39.382326	Over	{}
4631	1.5	1.80	621	2nd Half	99.0%	2023-02-18 05:09:39.384381	2023-02-18 05:09:39.384381	Under	{}
4632	2.5	4.50	621	2nd Half	96.6%	2023-02-18 05:09:39.385908	2023-02-18 05:09:39.385908	Over	{}
4633	2.5	1.23	621	2nd Half	96.6%	2023-02-18 05:09:39.388191	2023-02-18 05:09:39.388191	Under	{}
4634	3.5	11.00	621	2nd Half	96.7%	2023-02-18 05:09:39.389858	2023-02-18 05:09:39.389858	Over	{}
4635	3.5	1.06	621	2nd Half	96.7%	2023-02-18 05:09:39.391931	2023-02-18 05:09:39.391931	Under	{}
4636	0.5	1.07	624	Full Time	97.5%	2023-02-18 05:09:55.32302	2023-02-18 05:09:55.32302	Over	{}
4637	0.5	11.00	624	Full Time	97.5%	2023-02-18 05:09:55.324962	2023-02-18 05:09:55.324962	Under	{}
4638	1.5	1.38	624	Full Time	96.9%	2023-02-18 05:09:55.326977	2023-02-18 05:09:55.326977	Over	{}
4639	1.5	3.25	624	Full Time	96.9%	2023-02-18 05:09:55.32853	2023-02-18 05:09:55.32853	Under	{}
4640	2.25	1.92	624	Full Time	98.0%	2023-02-18 05:09:55.330368	2023-02-18 05:09:55.330368	Over	{}
4641	2.25	2.00	624	Full Time	98.0%	2023-02-18 05:09:55.332137	2023-02-18 05:09:55.332137	Under	{}
4642	2.5	2.19	624	Full Time	96.7%	2023-02-18 05:09:55.333703	2023-02-18 05:09:55.333703	Over	{}
4643	2.5	1.73	624	Full Time	96.7%	2023-02-18 05:09:55.335269	2023-02-18 05:09:55.335269	Under	{}
4644	3.5	3.90	624	Full Time	95.2%	2023-02-18 05:09:55.336852	2023-02-18 05:09:55.336852	Over	{}
4647	4.5	1.08	624	Full Time	95.2%	2023-02-18 05:09:55.341484	2023-02-18 05:09:55.341484	Under	{}
4648	5.5	17.00	624	Full Time	96.2%	2023-02-18 05:09:55.343088	2023-02-18 05:09:55.343088	Over	{}
4649	5.5	1.02	624	Full Time	96.2%	2023-02-18 05:09:55.344731	2023-02-18 05:09:55.344731	Under	{}
4650	6.5	34.00	624	Full Time	98.1%	2023-02-18 05:09:55.346255	2023-02-18 05:09:55.346255	Over	{}
4651	6.5	1.01	624	Full Time	98.1%	2023-02-18 05:09:55.34786	2023-02-18 05:09:55.34786	Under	{}
4653	0.5	2.80	624	1st Half	96.8%	2023-02-18 05:09:59.148312	2023-02-18 05:09:59.148312	Under	{}
4654	1.0	2.14	624	1st Half	97.5%	2023-02-18 05:09:59.150989	2023-02-18 05:09:59.150989	Over	{}
4656	1.5	3.35	624	1st Half	98.7%	2023-02-18 05:09:59.155488	2023-02-18 05:09:59.155488	Over	{}
4657	1.5	1.40	624	1st Half	98.7%	2023-02-18 05:09:59.157478	2023-02-18 05:09:59.157478	Under	{}
7180	3.0	14.00	618	1st Half	94.2%	2023-02-24 02:33:30.031554	2023-02-24 02:33:30.031554	Over	{}
4595	0.5	1.30	618	2nd Half	96.5%	2023-02-18 05:09:16.010013	2023-02-18 05:09:16.010013	Over	{}
4598	1.5	1.63	618	2nd Half	95.4%	2023-02-18 05:09:17.140699	2023-02-18 05:09:17.140699	Under	{}
4599	2.5	5.00	618	2nd Half	94.8%	2023-02-18 05:09:17.142691	2023-02-18 05:09:17.142691	Over	{}
4600	2.5	1.17	618	2nd Half	94.8%	2023-02-18 05:09:17.144657	2023-02-18 05:09:17.144657	Under	{}
4601	3.5	13.00	618	2nd Half	96.3%	2023-02-18 05:09:17.146551	2023-02-18 05:09:17.146551	Over	{}
4602	3.5	1.04	618	2nd Half	96.3%	2023-02-18 05:09:17.148387	2023-02-18 05:09:17.148387	Under	{}
4652	0.5	1.48	624	1st Half	96.8%	2023-02-18 05:09:57.568083	2023-02-18 05:09:57.568083	Over	{}
4663	4.5	1.01	624	1st Half	99.0%	2023-02-18 05:09:59.168748	2023-02-18 05:09:59.168748	Under	{}
4670	3.5	15.00	624	2nd Half	96.4%	2023-02-18 05:10:01.844265	2023-02-18 05:10:01.844265	Over	{}
4671	3.5	1.03	624	2nd Half	96.4%	2023-02-18 05:10:01.84696	2023-02-18 05:10:01.84696	Under	{}
4882	3.5	1.01	650	1st Half	98.6%	2023-02-22 04:38:59.553704	2023-02-22 04:38:59.553704	Under	{}
4913	2.5	11.00	653	1st Half	97.5%	2023-02-22 04:39:19.650341	2023-02-22 04:39:19.650341	Over	{}
4926	0.5	1.11	656	Full Time	97.8%	2023-02-22 04:39:34.456689	2023-02-22 04:39:34.456689	Over	{}
5210	2.0	1.88	656	Full Time	96.9%	2023-02-22 15:27:08.214162	2023-02-22 15:27:08.214162	Over	{}
5211	2.0	2.00	656	Full Time	96.9%	2023-02-22 15:27:08.216778	2023-02-22 15:27:08.216778	Under	{}
4956	2.5	6.50	656	2nd Half	95.5%	2023-02-22 04:39:40.969035	2023-02-22 04:39:40.969035	Over	{}
7181	3.0	1.01	618	1st Half	94.2%	2023-02-24 02:33:30.03267	2023-02-24 02:33:30.03267	Under	{}
4592	3.5	23.00	618	1st Half	97.7%	2023-02-18 05:09:14.300292	2023-02-18 05:09:14.300292	Over	{}
4593	3.5	1.02	618	1st Half	97.7%	2023-02-18 05:09:14.302458	2023-02-18 05:09:14.302458	Under	{}
4594	4.5	56.00	618	1st Half	98.2%	2023-02-18 05:09:14.304596	2023-02-18 05:09:14.304596	Over	{}
7187	0.75	1.35	618	2nd Half	93.5%	2023-02-24 02:33:35.323552	2023-02-24 02:33:35.323552	Over	{}
4658	2.5	9.00	624	1st Half	96.4%	2023-02-18 05:09:59.159659	2023-02-18 05:09:59.159659	Over	{}
4659	2.5	1.08	624	1st Half	96.4%	2023-02-18 05:09:59.161903	2023-02-18 05:09:59.161903	Under	{}
4660	3.5	26.00	624	1st Half	98.1%	2023-02-18 05:09:59.164486	2023-02-18 05:09:59.164486	Over	{}
4661	3.5	1.02	624	1st Half	98.1%	2023-02-18 05:09:59.16638	2023-02-18 05:09:59.16638	Under	{}
7188	0.75	3.04	618	2nd Half	93.5%	2023-02-24 02:33:35.326759	2023-02-24 02:33:35.326759	Under	{}
7189	1.0	1.50	618	2nd Half	94.0%	2023-02-24 02:33:35.329504	2023-02-24 02:33:35.329504	Over	{}
7190	1.0	2.52	618	2nd Half	94.0%	2023-02-24 02:33:35.331876	2023-02-24 02:33:35.331876	Under	{}
7191	1.25	1.87	618	2nd Half	93.5%	2023-02-24 02:33:35.334412	2023-02-24 02:33:35.334412	Over	{}
7192	1.25	1.87	618	2nd Half	93.5%	2023-02-24 02:33:35.336681	2023-02-24 02:33:35.336681	Under	{}
7195	1.75	2.70	618	2nd Half	93.5%	2023-02-24 02:33:35.344414	2023-02-24 02:33:35.344414	Over	{}
7196	1.75	1.43	618	2nd Half	93.5%	2023-02-24 02:33:35.346977	2023-02-24 02:33:35.346977	Under	{}
7197	2.0	3.80	618	2nd Half	94.1%	2023-02-24 02:33:35.348594	2023-02-24 02:33:35.348594	Over	{}
7198	2.0	1.25	618	2nd Half	94.1%	2023-02-24 02:33:35.349775	2023-02-24 02:33:35.349775	Under	{}
7199	2.25	4.38	618	2nd Half	93.6%	2023-02-24 02:33:35.350981	2023-02-24 02:33:35.350981	Over	{}
7200	2.25	1.19	618	2nd Half	93.6%	2023-02-24 02:33:35.352296	2023-02-24 02:33:35.352296	Under	{}
7203	3.0	8.50	618	2nd Half	92.7%	2023-02-24 02:33:35.356488	2023-02-24 02:33:35.356488	Over	{}
7204	3.0	1.04	618	2nd Half	92.7%	2023-02-24 02:33:35.357871	2023-02-24 02:33:35.357871	Under	{}
7209	0.75	1.03	621	Full Time	94.1%	2023-02-24 02:33:52.724937	2023-02-24 02:33:52.724937	Over	{}
4662	4.5	56.00	624	1st Half	98.2%	2023-02-18 05:09:59.167614	2023-02-18 05:09:59.167614	Over	{}
4664	0.5	1.33	624	2nd Half	98.2%	2023-02-18 05:10:00.797874	2023-02-18 05:10:00.797874	Over	{}
4665	0.5	3.75	624	2nd Half	98.2%	2023-02-18 05:10:01.833603	2023-02-18 05:10:01.833603	Under	{}
4666	1.5	2.38	624	2nd Half	95.0%	2023-02-18 05:10:01.835863	2023-02-18 05:10:01.835863	Over	{}
4667	1.5	1.58	624	2nd Half	95.0%	2023-02-18 05:10:01.837686	2023-02-18 05:10:01.837686	Under	{}
4668	2.5	5.50	624	2nd Half	95.1%	2023-02-18 05:10:01.839711	2023-02-18 05:10:01.839711	Over	{}
4669	2.5	1.15	624	2nd Half	95.1%	2023-02-18 05:10:01.841736	2023-02-18 05:10:01.841736	Under	{}
7210	0.75	10.85	621	Full Time	94.1%	2023-02-24 02:33:52.726755	2023-02-24 02:33:52.726755	Under	{}
7211	1.0	1.04	621	Full Time	94.1%	2023-02-24 02:33:52.728221	2023-02-24 02:33:52.728221	Over	{}
7212	1.0	9.86	621	Full Time	94.1%	2023-02-24 02:33:52.730104	2023-02-24 02:33:52.730104	Under	{}
7213	1.25	1.13	621	Full Time	94.1%	2023-02-24 02:33:52.732496	2023-02-24 02:33:52.732496	Over	{}
7214	1.25	5.62	621	Full Time	94.1%	2023-02-24 02:33:52.734886	2023-02-24 02:33:52.734886	Under	{}
7217	1.75	1.29	621	Full Time	95.2%	2023-02-24 02:33:52.740716	2023-02-24 02:33:52.740716	Over	{}
7218	1.75	3.63	621	Full Time	95.2%	2023-02-24 02:33:52.742498	2023-02-24 02:33:52.742498	Under	{}
7219	2.0	1.36	621	Full Time	95.3%	2023-02-24 02:33:52.745039	2023-02-24 02:33:52.745039	Over	{}
7220	2.0	3.18	621	Full Time	95.3%	2023-02-24 02:33:52.748244	2023-02-24 02:33:52.748244	Under	{}
7310	1.75	1.48	624	Full Time	96.2%	2023-02-24 02:34:21.496492	2023-02-24 02:34:21.496492	Over	{}
7311	1.75	2.75	624	Full Time	96.2%	2023-02-24 02:34:21.49816	2023-02-24 02:34:21.49816	Under	{}
7312	2.0	1.63	624	Full Time	96.7%	2023-02-24 02:34:21.499072	2023-02-24 02:34:21.499072	Over	{}
7313	2.0	2.38	624	Full Time	96.7%	2023-02-24 02:34:21.499996	2023-02-24 02:34:21.499996	Under	{}
7318	2.75	2.53	624	Full Time	96.5%	2023-02-24 02:34:21.505131	2023-02-24 02:34:21.505131	Over	{}
7319	2.75	1.56	624	Full Time	96.5%	2023-02-24 02:34:21.506352	2023-02-24 02:34:21.506352	Under	{}
7320	3.0	3.20	624	Full Time	94.9%	2023-02-24 02:34:21.508359	2023-02-24 02:34:21.508359	Over	{}
7321	3.0	1.35	624	Full Time	94.9%	2023-02-24 02:34:21.509481	2023-02-24 02:34:21.509481	Under	{}
7322	3.25	3.63	624	Full Time	94.6%	2023-02-24 02:34:21.510785	2023-02-24 02:34:21.510785	Over	{}
7323	3.25	1.28	624	Full Time	94.6%	2023-02-24 02:34:21.512571	2023-02-24 02:34:21.512571	Under	{}
7326	3.75	4.98	624	Full Time	94.1%	2023-02-24 02:34:21.516943	2023-02-24 02:34:21.516943	Over	{}
7327	3.75	1.16	624	Full Time	94.1%	2023-02-24 02:34:21.518128	2023-02-24 02:34:21.518128	Under	{}
7328	4.0	6.45	624	Full Time	92.5%	2023-02-24 02:34:21.518919	2023-02-24 02:34:21.518919	Over	{}
7329	4.0	1.08	624	Full Time	92.5%	2023-02-24 02:34:21.519548	2023-02-24 02:34:21.519548	Under	{}
7330	4.25	7.30	624	Full Time	94.1%	2023-02-24 02:34:21.52034	2023-02-24 02:34:21.52034	Over	{}
7331	4.25	1.08	624	Full Time	94.1%	2023-02-24 02:34:21.521053	2023-02-24 02:34:21.521053	Under	{}
7334	4.75	9.86	624	Full Time	94.1%	2023-02-24 02:34:21.52325	2023-02-24 02:34:21.52325	Over	{}
7335	4.75	1.04	624	Full Time	94.1%	2023-02-24 02:34:21.52395	2023-02-24 02:34:21.52395	Under	{}
7336	5.0	12.00	624	Full Time	94.0%	2023-02-24 02:34:21.524599	2023-02-24 02:34:21.524599	Over	{}
7337	5.0	1.02	624	Full Time	94.0%	2023-02-24 02:34:21.525587	2023-02-24 02:34:21.525587	Under	{}
7344	0.75	1.67	624	1st Half	94.9%	2023-02-24 02:34:26.798109	2023-02-24 02:34:26.798109	Over	{}
7345	0.75	2.20	624	1st Half	94.9%	2023-02-24 02:34:26.799402	2023-02-24 02:34:26.799402	Under	{}
7348	1.25	2.75	624	1st Half	95.8%	2023-02-24 02:34:26.802942	2023-02-24 02:34:26.802942	Over	{}
7349	1.25	1.47	624	1st Half	95.8%	2023-02-24 02:34:26.804138	2023-02-24 02:34:26.804138	Under	{}
7352	1.75	4.14	624	1st Half	93.6%	2023-02-24 02:34:26.807493	2023-02-24 02:34:26.807493	Over	{}
7353	1.75	1.21	624	1st Half	93.6%	2023-02-24 02:34:26.808525	2023-02-24 02:34:26.808525	Under	{}
7354	2.0	6.85	624	1st Half	94.0%	2023-02-24 02:34:26.809638	2023-02-24 02:34:26.809638	Over	{}
7355	2.0	1.09	624	1st Half	94.0%	2023-02-24 02:34:26.810769	2023-02-24 02:34:26.810769	Under	{}
7356	2.25	7.40	624	1st Half	93.5%	2023-02-24 02:34:26.81189	2023-02-24 02:34:26.81189	Over	{}
7357	2.25	1.07	624	1st Half	93.5%	2023-02-24 02:34:26.813849	2023-02-24 02:34:26.813849	Under	{}
7360	3.0	14.00	624	1st Half	94.2%	2023-02-24 02:34:26.816946	2023-02-24 02:34:26.816946	Over	{}
7361	3.0	1.01	624	1st Half	94.2%	2023-02-24 02:34:26.8184	2023-02-24 02:34:26.8184	Under	{}
7367	0.75	1.38	624	2nd Half	93.5%	2023-02-24 02:34:31.970862	2023-02-24 02:34:31.970862	Over	{}
7368	0.75	2.90	624	2nd Half	93.5%	2023-02-24 02:34:31.971954	2023-02-24 02:34:31.971954	Under	{}
7369	1.0	1.60	624	2nd Half	95.5%	2023-02-24 02:34:31.97347	2023-02-24 02:34:31.97347	Over	{}
7370	1.0	2.37	624	2nd Half	95.5%	2023-02-24 02:34:31.974737	2023-02-24 02:34:31.974737	Under	{}
7371	1.25	1.94	624	2nd Half	93.6%	2023-02-24 02:34:31.97586	2023-02-24 02:34:31.97586	Over	{}
7372	1.25	1.81	624	2nd Half	93.6%	2023-02-24 02:34:31.977183	2023-02-24 02:34:31.977183	Under	{}
7375	1.75	2.86	624	2nd Half	93.5%	2023-02-24 02:34:31.980641	2023-02-24 02:34:31.980641	Over	{}
7376	1.75	1.39	624	2nd Half	93.5%	2023-02-24 02:34:31.981799	2023-02-24 02:34:31.981799	Under	{}
7377	2.0	4.37	624	2nd Half	94.8%	2023-02-24 02:34:31.982849	2023-02-24 02:34:31.982849	Over	{}
7378	2.0	1.21	624	2nd Half	94.8%	2023-02-24 02:34:31.983883	2023-02-24 02:34:31.983883	Under	{}
7379	2.25	4.74	624	2nd Half	93.8%	2023-02-24 02:34:31.984887	2023-02-24 02:34:31.984887	Over	{}
7380	2.25	1.17	624	2nd Half	93.8%	2023-02-24 02:34:31.985976	2023-02-24 02:34:31.985976	Under	{}
7383	3.0	9.00	624	2nd Half	92.4%	2023-02-24 02:34:31.989691	2023-02-24 02:34:31.989691	Over	{}
7384	3.0	1.03	624	2nd Half	92.4%	2023-02-24 02:34:31.990942	2023-02-24 02:34:31.990942	Under	{}
7387	0.25	1.03	650	Full Time	94.1%	2023-02-24 02:34:43.560321	2023-02-24 02:34:43.560321	Over	{}
7388	0.25	10.85	650	Full Time	94.1%	2023-02-24 02:34:49.030117	2023-02-24 02:34:49.030117	Under	{}
7391	0.75	1.11	650	Full Time	94.1%	2023-02-24 02:34:49.036684	2023-02-24 02:34:49.036684	Over	{}
7392	0.75	6.17	650	Full Time	94.1%	2023-02-24 02:34:49.038657	2023-02-24 02:34:49.038657	Under	{}
7393	1.0	1.13	650	Full Time	91.8%	2023-02-24 02:34:49.040438	2023-02-24 02:34:49.040438	Over	{}
7394	1.0	4.90	650	Full Time	91.8%	2023-02-24 02:34:49.042336	2023-02-24 02:34:49.042336	Under	{}
7395	1.25	1.36	650	Full Time	96.1%	2023-02-24 02:34:49.044176	2023-02-24 02:34:49.044176	Over	{}
7396	1.25	3.27	650	Full Time	96.1%	2023-02-24 02:34:49.046108	2023-02-24 02:34:49.046108	Under	{}
7399	1.75	1.73	650	Full Time	97.2%	2023-02-24 02:34:49.052789	2023-02-24 02:34:49.052789	Over	{}
7400	1.75	2.22	650	Full Time	97.2%	2023-02-24 02:34:49.055125	2023-02-24 02:34:49.055125	Under	{}
7403	2.25	2.36	650	Full Time	97.1%	2023-02-24 02:34:49.059305	2023-02-24 02:34:49.059305	Over	{}
7404	2.25	1.65	650	Full Time	97.1%	2023-02-24 02:34:49.060824	2023-02-24 02:34:49.060824	Under	{}
7407	2.75	3.25	650	Full Time	95.9%	2023-02-24 02:34:49.065097	2023-02-24 02:34:49.065097	Over	{}
7408	2.75	1.36	650	Full Time	95.9%	2023-02-24 02:34:49.066848	2023-02-24 02:34:49.066848	Under	{}
7409	3.0	4.15	650	Full Time	94.3%	2023-02-24 02:34:49.068187	2023-02-24 02:34:49.068187	Over	{}
7410	3.0	1.22	650	Full Time	94.3%	2023-02-24 02:34:49.069773	2023-02-24 02:34:49.069773	Under	{}
7411	3.25	4.49	650	Full Time	94.1%	2023-02-24 02:34:49.071374	2023-02-24 02:34:49.071374	Over	{}
7412	3.25	1.19	650	Full Time	94.1%	2023-02-24 02:34:49.072717	2023-02-24 02:34:49.072717	Under	{}
7415	3.75	6.50	650	Full Time	94.1%	2023-02-24 02:34:49.077088	2023-02-24 02:34:49.077088	Over	{}
7416	3.75	1.10	650	Full Time	94.1%	2023-02-24 02:34:49.078846	2023-02-24 02:34:49.078846	Under	{}
7417	4.0	9.04	650	Full Time	94.1%	2023-02-24 02:34:49.080446	2023-02-24 02:34:49.080446	Over	{}
7418	4.0	1.05	650	Full Time	94.1%	2023-02-24 02:34:49.081941	2023-02-24 02:34:49.081941	Under	{}
7419	4.25	9.86	650	Full Time	94.1%	2023-02-24 02:34:49.083543	2023-02-24 02:34:49.083543	Over	{}
7420	4.25	1.04	650	Full Time	94.1%	2023-02-24 02:34:49.08485	2023-02-24 02:34:49.08485	Under	{}
7430	1.0	2.62	650	1st Half	96.2%	2023-02-24 02:34:55.114195	2023-02-24 02:34:55.114195	Over	{}
7431	1.0	1.52	650	1st Half	96.2%	2023-02-24 02:34:55.115641	2023-02-24 02:34:55.115641	Under	{}
7432	1.25	3.36	650	1st Half	96.3%	2023-02-24 02:34:55.116829	2023-02-24 02:34:55.116829	Over	{}
7433	1.25	1.35	650	1st Half	96.3%	2023-02-24 02:34:55.117937	2023-02-24 02:34:55.117937	Under	{}
7436	1.75	5.00	650	1st Half	93.5%	2023-02-24 02:34:55.121768	2023-02-24 02:34:55.121768	Over	{}
7437	1.75	1.15	650	1st Half	93.5%	2023-02-24 02:34:55.122898	2023-02-24 02:34:55.122898	Under	{}
7438	2.0	8.90	650	1st Half	93.9%	2023-02-24 02:34:55.124301	2023-02-24 02:34:55.124301	Over	{}
7439	2.0	1.05	650	1st Half	93.9%	2023-02-24 02:34:55.126027	2023-02-24 02:34:55.126027	Under	{}
7440	2.25	9.60	650	1st Half	93.8%	2023-02-24 02:34:55.127018	2023-02-24 02:34:55.127018	Over	{}
7441	2.25	1.04	650	1st Half	93.8%	2023-02-24 02:34:55.128126	2023-02-24 02:34:55.128126	Under	{}
7444	3.0	14.00	650	1st Half	94.2%	2023-02-24 02:34:55.132768	2023-02-24 02:34:55.132768	Over	{}
7445	3.0	1.01	650	1st Half	94.2%	2023-02-24 02:34:55.134374	2023-02-24 02:34:55.134374	Under	{}
7451	0.75	1.51	650	2nd Half	93.6%	2023-02-24 02:35:00.80214	2023-02-24 02:35:00.80214	Over	{}
7452	0.75	2.46	650	2nd Half	93.6%	2023-02-24 02:35:00.802959	2023-02-24 02:35:00.802959	Under	{}
7453	1.0	1.81	650	2nd Half	94.1%	2023-02-24 02:35:00.803808	2023-02-24 02:35:00.803808	Over	{}
7454	1.0	1.96	650	2nd Half	94.1%	2023-02-24 02:35:00.804592	2023-02-24 02:35:00.804592	Under	{}
7455	1.25	2.25	650	2nd Half	93.5%	2023-02-24 02:35:00.805477	2023-02-24 02:35:00.805477	Over	{}
7456	1.25	1.60	650	2nd Half	93.5%	2023-02-24 02:35:00.806329	2023-02-24 02:35:00.806329	Under	{}
7459	1.75	3.46	650	2nd Half	93.4%	2023-02-24 02:35:00.808925	2023-02-24 02:35:00.808925	Over	{}
7460	1.75	1.28	650	2nd Half	93.4%	2023-02-24 02:35:00.809905	2023-02-24 02:35:00.809905	Under	{}
7461	2.0	5.45	650	2nd Half	93.6%	2023-02-24 02:35:00.810845	2023-02-24 02:35:00.810845	Over	{}
7462	2.0	1.13	650	2nd Half	93.6%	2023-02-24 02:35:00.811922	2023-02-24 02:35:00.811922	Under	{}
7463	2.25	6.05	650	2nd Half	93.8%	2023-02-24 02:35:00.81308	2023-02-24 02:35:00.81308	Over	{}
7464	2.25	1.11	650	2nd Half	93.8%	2023-02-24 02:35:00.814072	2023-02-24 02:35:00.814072	Under	{}
7471	0.75	1.09	653	Full Time	92.8%	2023-02-24 02:35:19.508564	2023-02-24 02:35:19.508564	Over	{}
7472	0.75	6.25	653	Full Time	92.8%	2023-02-24 02:35:19.509989	2023-02-24 02:35:19.509989	Under	{}
7473	1.0	1.10	653	Full Time	91.7%	2023-02-24 02:35:19.511463	2023-02-24 02:35:19.511463	Over	{}
7474	1.0	5.50	653	Full Time	91.7%	2023-02-24 02:35:19.512885	2023-02-24 02:35:19.512885	Under	{}
7475	1.25	1.29	653	Full Time	95.2%	2023-02-24 02:35:19.514422	2023-02-24 02:35:19.514422	Over	{}
7476	1.25	3.63	653	Full Time	95.2%	2023-02-24 02:35:19.515731	2023-02-24 02:35:19.515731	Under	{}
7479	1.75	1.57	653	Full Time	95.4%	2023-02-24 02:35:19.521169	2023-02-24 02:35:19.521169	Over	{}
7480	1.75	2.43	653	Full Time	95.4%	2023-02-24 02:35:19.523714	2023-02-24 02:35:19.523714	Under	{}
7481	2.0	1.76	653	Full Time	95.3%	2023-02-24 02:35:19.526262	2023-02-24 02:35:19.526262	Over	{}
7482	2.0	2.08	653	Full Time	95.3%	2023-02-24 02:35:19.528151	2023-02-24 02:35:19.528151	Under	{}
7487	2.75	2.83	653	Full Time	95.4%	2023-02-24 02:35:19.537504	2023-02-24 02:35:19.537504	Over	{}
7488	2.75	1.44	653	Full Time	95.4%	2023-02-24 02:35:19.53849	2023-02-24 02:35:19.53849	Under	{}
7489	3.0	3.72	653	Full Time	95.2%	2023-02-24 02:35:19.539512	2023-02-24 02:35:19.539512	Over	{}
7490	3.0	1.28	653	Full Time	95.2%	2023-02-24 02:35:19.540469	2023-02-24 02:35:19.540469	Under	{}
7491	3.25	3.76	653	Full Time	92.7%	2023-02-24 02:35:19.541467	2023-02-24 02:35:19.541467	Over	{}
7492	3.25	1.23	653	Full Time	92.7%	2023-02-24 02:35:19.542434	2023-02-24 02:35:19.542434	Under	{}
7495	3.75	5.20	653	Full Time	92.8%	2023-02-24 02:35:19.545238	2023-02-24 02:35:19.545238	Over	{}
7496	3.75	1.13	653	Full Time	92.8%	2023-02-24 02:35:19.546491	2023-02-24 02:35:19.546491	Under	{}
7497	4.0	7.30	653	Full Time	91.8%	2023-02-24 02:35:19.547467	2023-02-24 02:35:19.547467	Over	{}
7498	4.0	1.05	653	Full Time	91.8%	2023-02-24 02:35:19.548449	2023-02-24 02:35:19.548449	Under	{}
7499	4.25	8.20	653	Full Time	92.3%	2023-02-24 02:35:19.549482	2023-02-24 02:35:19.549482	Over	{}
7500	4.25	1.04	653	Full Time	92.3%	2023-02-24 02:35:19.550458	2023-02-24 02:35:19.550458	Under	{}
7503	5.0	13.00	653	Full Time	93.7%	2023-02-24 02:35:19.553642	2023-02-24 02:35:19.553642	Over	{}
7504	5.0	1.01	653	Full Time	93.7%	2023-02-24 02:35:19.554687	2023-02-24 02:35:19.554687	Under	{}
7512	1.0	2.31	653	1st Half	94.9%	2023-02-24 02:35:25.617702	2023-02-24 02:35:25.617702	Over	{}
7513	1.0	1.61	653	1st Half	94.9%	2023-02-24 02:35:25.618663	2023-02-24 02:35:25.618663	Under	{}
7514	1.25	2.95	653	1st Half	95.4%	2023-02-24 02:35:25.619569	2023-02-24 02:35:25.619569	Over	{}
7515	1.25	1.41	653	1st Half	95.4%	2023-02-24 02:35:25.62051	2023-02-24 02:35:25.62051	Under	{}
7518	1.75	4.48	653	1st Half	93.4%	2023-02-24 02:35:25.623718	2023-02-24 02:35:25.623718	Over	{}
7519	1.75	1.18	653	1st Half	93.4%	2023-02-24 02:35:25.624784	2023-02-24 02:35:25.624784	Under	{}
7520	2.0	7.70	653	1st Half	93.9%	2023-02-24 02:35:25.626061	2023-02-24 02:35:25.626061	Over	{}
7521	2.0	1.07	653	1st Half	93.9%	2023-02-24 02:35:25.637652	2023-02-24 02:35:25.637652	Under	{}
7522	2.25	8.30	653	1st Half	93.2%	2023-02-24 02:35:25.641138	2023-02-24 02:35:25.641138	Over	{}
7523	2.25	1.05	653	1st Half	93.2%	2023-02-24 02:35:25.642338	2023-02-24 02:35:25.642338	Under	{}
7526	3.0	14.00	653	1st Half	94.2%	2023-02-24 02:35:25.645247	2023-02-24 02:35:25.645247	Over	{}
7527	3.0	1.01	653	1st Half	94.2%	2023-02-24 02:35:25.646475	2023-02-24 02:35:25.646475	Under	{}
7533	0.75	1.43	653	2nd Half	93.5%	2023-02-24 02:35:31.015764	2023-02-24 02:35:31.015764	Over	{}
7534	0.75	2.70	653	2nd Half	93.5%	2023-02-24 02:35:31.016808	2023-02-24 02:35:31.016808	Under	{}
7535	1.0	1.64	653	2nd Half	93.6%	2023-02-24 02:35:31.017898	2023-02-24 02:35:31.017898	Over	{}
7536	1.0	2.18	653	2nd Half	93.6%	2023-02-24 02:35:31.01913	2023-02-24 02:35:31.01913	Under	{}
7537	1.25	2.04	653	2nd Half	93.6%	2023-02-24 02:35:31.020072	2023-02-24 02:35:31.020072	Over	{}
7538	1.25	1.73	653	2nd Half	93.6%	2023-02-24 02:35:31.021056	2023-02-24 02:35:31.021056	Under	{}
7541	1.75	3.04	653	2nd Half	93.5%	2023-02-24 02:35:31.024166	2023-02-24 02:35:31.024166	Over	{}
7542	1.75	1.35	653	2nd Half	93.5%	2023-02-24 02:35:31.025135	2023-02-24 02:35:31.025135	Under	{}
7543	2.0	4.55	653	2nd Half	93.7%	2023-02-24 02:35:31.026212	2023-02-24 02:35:31.026212	Over	{}
7544	2.0	1.18	653	2nd Half	93.7%	2023-02-24 02:35:31.027295	2023-02-24 02:35:31.027295	Under	{}
7545	2.25	5.10	653	2nd Half	93.2%	2023-02-24 02:35:31.028701	2023-02-24 02:35:31.028701	Over	{}
7546	2.25	1.14	653	2nd Half	93.2%	2023-02-24 02:35:31.030564	2023-02-24 02:35:31.030564	Under	{}
4927	0.5	8.25	656	Full Time	97.8%	2023-02-22 04:39:34.460428	2023-02-22 04:39:34.460428	Under	{}
7553	0.75	1.09	656	Full Time	92.9%	2023-02-24 02:35:47.726533	2023-02-24 02:35:47.726533	Over	{}
7554	0.75	6.30	656	Full Time	92.9%	2023-02-24 02:35:47.728673	2023-02-24 02:35:47.728673	Under	{}
7555	1.0	1.10	656	Full Time	91.4%	2023-02-24 02:35:47.730911	2023-02-24 02:35:47.730911	Over	{}
7556	1.0	5.40	656	Full Time	91.4%	2023-02-24 02:35:47.733035	2023-02-24 02:35:47.733035	Under	{}
7557	1.25	1.32	656	Full Time	95.1%	2023-02-24 02:35:47.734974	2023-02-24 02:35:47.734974	Over	{}
7558	1.25	3.40	656	Full Time	95.1%	2023-02-24 02:35:47.736522	2023-02-24 02:35:47.736522	Under	{}
7561	1.75	1.65	656	Full Time	96.8%	2023-02-24 02:35:47.740419	2023-02-24 02:35:47.740419	Over	{}
7562	1.75	2.34	656	Full Time	96.8%	2023-02-24 02:35:47.741589	2023-02-24 02:35:47.741589	Under	{}
7569	2.75	3.05	656	Full Time	95.0%	2023-02-24 02:35:47.750729	2023-02-24 02:35:47.750729	Over	{}
7570	2.75	1.38	656	Full Time	95.0%	2023-02-24 02:35:47.75199	2023-02-24 02:35:47.75199	Under	{}
7571	3.0	3.80	656	Full Time	92.4%	2023-02-24 02:35:47.753315	2023-02-24 02:35:47.753315	Over	{}
7572	3.0	1.22	656	Full Time	92.4%	2023-02-24 02:35:47.754676	2023-02-24 02:35:47.754676	Under	{}
7573	3.25	4.18	656	Full Time	92.6%	2023-02-24 02:35:47.755824	2023-02-24 02:35:47.755824	Over	{}
7574	3.25	1.19	656	Full Time	92.6%	2023-02-24 02:35:47.757118	2023-02-24 02:35:47.757118	Under	{}
7577	3.75	5.95	656	Full Time	92.8%	2023-02-24 02:35:47.761033	2023-02-24 02:35:47.761033	Over	{}
7578	3.75	1.10	656	Full Time	92.8%	2023-02-24 02:35:47.762276	2023-02-24 02:35:47.762276	Under	{}
7579	4.0	8.30	656	Full Time	91.6%	2023-02-24 02:35:47.763444	2023-02-24 02:35:47.763444	Over	{}
7580	4.0	1.03	656	Full Time	91.6%	2023-02-24 02:35:47.764612	2023-02-24 02:35:47.764612	Under	{}
7590	1.0	2.45	656	1st Half	96.1%	2023-02-24 02:35:53.793781	2023-02-24 02:35:53.793781	Over	{}
7591	1.0	1.58	656	1st Half	96.1%	2023-02-24 02:35:53.794586	2023-02-24 02:35:53.794586	Under	{}
7592	1.25	3.14	656	1st Half	95.9%	2023-02-24 02:35:53.796002	2023-02-24 02:35:53.796002	Over	{}
7593	1.25	1.38	656	1st Half	95.9%	2023-02-24 02:35:53.797549	2023-02-24 02:35:53.797549	Under	{}
7596	1.75	4.74	656	1st Half	93.8%	2023-02-24 02:35:53.802445	2023-02-24 02:35:53.802445	Over	{}
7597	1.75	1.17	656	1st Half	93.8%	2023-02-24 02:35:53.804181	2023-02-24 02:35:53.804181	Under	{}
7598	2.0	8.30	656	1st Half	94.0%	2023-02-24 02:35:53.805906	2023-02-24 02:35:53.805906	Over	{}
7599	2.0	1.06	656	1st Half	94.0%	2023-02-24 02:35:53.807828	2023-02-24 02:35:53.807828	Under	{}
7600	2.25	8.90	656	1st Half	93.1%	2023-02-24 02:35:53.809503	2023-02-24 02:35:53.809503	Over	{}
7601	2.25	1.04	656	1st Half	93.1%	2023-02-24 02:35:53.810976	2023-02-24 02:35:53.810976	Under	{}
7604	3.0	14.00	656	1st Half	94.2%	2023-02-24 02:35:53.816453	2023-02-24 02:35:53.816453	Over	{}
7605	3.0	1.01	656	1st Half	94.2%	2023-02-24 02:35:53.818003	2023-02-24 02:35:53.818003	Under	{}
7611	0.75	1.47	656	2nd Half	93.5%	2023-02-24 02:35:59.997052	2023-02-24 02:35:59.997052	Over	{}
7612	0.75	2.57	656	2nd Half	93.5%	2023-02-24 02:35:59.999624	2023-02-24 02:35:59.999624	Under	{}
7613	1.0	1.72	656	2nd Half	93.5%	2023-02-24 02:36:00.001834	2023-02-24 02:36:00.001834	Over	{}
7614	1.0	2.05	656	2nd Half	93.5%	2023-02-24 02:36:00.004329	2023-02-24 02:36:00.004329	Under	{}
7615	1.25	2.16	656	2nd Half	93.5%	2023-02-24 02:36:00.006777	2023-02-24 02:36:00.006777	Over	{}
7616	1.25	1.65	656	2nd Half	93.5%	2023-02-24 02:36:00.008651	2023-02-24 02:36:00.008651	Under	{}
7619	1.75	3.26	656	2nd Half	93.4%	2023-02-24 02:36:00.015535	2023-02-24 02:36:00.015535	Over	{}
7620	1.75	1.31	656	2nd Half	93.4%	2023-02-24 02:36:00.017503	2023-02-24 02:36:00.017503	Under	{}
7621	2.0	5.10	656	2nd Half	93.8%	2023-02-24 02:36:00.019556	2023-02-24 02:36:00.019556	Over	{}
7622	2.0	1.15	656	2nd Half	93.8%	2023-02-24 02:36:00.021584	2023-02-24 02:36:00.021584	Under	{}
7623	2.25	5.65	656	2nd Half	93.5%	2023-02-24 02:36:00.023936	2023-02-24 02:36:00.023936	Over	{}
7624	2.25	1.12	656	2nd Half	93.5%	2023-02-24 02:36:00.026426	2023-02-24 02:36:00.026426	Under	{}
7631	0.75	1.06	659	Full Time	92.7%	2023-02-24 02:36:18.76405	2023-02-24 02:36:18.76405	Over	{}
7632	0.75	7.40	659	Full Time	92.7%	2023-02-24 02:36:18.765785	2023-02-24 02:36:18.765785	Under	{}
7633	1.0	1.07	659	Full Time	91.8%	2023-02-24 02:36:18.768405	2023-02-24 02:36:18.768405	Over	{}
7634	1.0	6.45	659	Full Time	91.8%	2023-02-24 02:36:18.770379	2023-02-24 02:36:18.770379	Under	{}
7635	1.25	1.21	659	Full Time	92.6%	2023-02-24 02:36:18.772107	2023-02-24 02:36:18.772107	Over	{}
7636	1.25	3.94	659	Full Time	92.6%	2023-02-24 02:36:18.773214	2023-02-24 02:36:18.773214	Under	{}
7639	1.75	1.47	659	Full Time	95.4%	2023-02-24 02:36:18.777986	2023-02-24 02:36:18.777986	Over	{}
7640	1.75	2.72	659	Full Time	95.4%	2023-02-24 02:36:18.779128	2023-02-24 02:36:18.779128	Under	{}
7641	2.0	1.62	659	Full Time	95.7%	2023-02-24 02:36:18.780119	2023-02-24 02:36:18.780119	Over	{}
7642	2.0	2.34	659	Full Time	95.7%	2023-02-24 02:36:18.781127	2023-02-24 02:36:18.781127	Under	{}
7647	2.75	2.50	659	Full Time	94.9%	2023-02-24 02:36:18.788234	2023-02-24 02:36:18.788234	Over	{}
7648	2.75	1.53	659	Full Time	94.9%	2023-02-24 02:36:18.78957	2023-02-24 02:36:18.78957	Under	{}
7649	3.0	3.00	659	Full Time	93.6%	2023-02-24 02:36:18.790736	2023-02-24 02:36:18.790736	Over	{}
7650	3.0	1.36	659	Full Time	93.6%	2023-02-24 02:36:18.791984	2023-02-24 02:36:18.791984	Under	{}
7651	3.25	3.35	659	Full Time	93.1%	2023-02-24 02:36:18.794133	2023-02-24 02:36:18.794133	Over	{}
7652	3.25	1.29	659	Full Time	93.1%	2023-02-24 02:36:18.795222	2023-02-24 02:36:18.795222	Under	{}
7655	3.75	4.44	659	Full Time	92.6%	2023-02-24 02:36:18.798535	2023-02-24 02:36:18.798535	Over	{}
7656	3.75	1.17	659	Full Time	92.6%	2023-02-24 02:36:18.799561	2023-02-24 02:36:18.799561	Under	{}
7657	4.0	6.10	659	Full Time	91.8%	2023-02-24 02:36:18.800571	2023-02-24 02:36:18.800571	Over	{}
7658	4.0	1.08	659	Full Time	91.8%	2023-02-24 02:36:18.802104	2023-02-24 02:36:18.802104	Under	{}
7659	4.25	6.65	659	Full Time	92.2%	2023-02-24 02:36:18.803542	2023-02-24 02:36:18.803542	Over	{}
7660	4.25	1.07	659	Full Time	92.2%	2023-02-24 02:36:18.805305	2023-02-24 02:36:18.805305	Under	{}
7663	5.0	11.50	659	Full Time	93.7%	2023-02-24 02:36:18.808517	2023-02-24 02:36:18.808517	Over	{}
7664	5.0	1.02	659	Full Time	93.7%	2023-02-24 02:36:18.809632	2023-02-24 02:36:18.809632	Under	{}
7670	0.75	1.65	659	1st Half	94.8%	2023-02-24 02:36:24.802432	2023-02-24 02:36:24.802432	Over	{}
7671	0.75	2.23	659	1st Half	94.8%	2023-02-24 02:36:24.804843	2023-02-24 02:36:24.804843	Under	{}
7674	1.25	2.68	659	1st Half	95.3%	2023-02-24 02:36:24.812317	2023-02-24 02:36:24.812317	Over	{}
7675	1.25	1.48	659	1st Half	95.3%	2023-02-24 02:36:24.814952	2023-02-24 02:36:24.814952	Under	{}
7678	1.75	4.00	659	1st Half	93.5%	2023-02-24 02:36:24.820141	2023-02-24 02:36:24.820141	Over	{}
7679	1.75	1.22	659	1st Half	93.5%	2023-02-24 02:36:24.821872	2023-02-24 02:36:24.821872	Under	{}
7680	2.0	6.60	659	1st Half	93.6%	2023-02-24 02:36:24.823477	2023-02-24 02:36:24.823477	Over	{}
7681	2.0	1.09	659	1st Half	93.6%	2023-02-24 02:36:24.824817	2023-02-24 02:36:24.824817	Under	{}
7682	2.25	7.30	659	1st Half	93.3%	2023-02-24 02:36:24.826465	2023-02-24 02:36:24.826465	Over	{}
7683	2.25	1.07	659	1st Half	93.3%	2023-02-24 02:36:24.827893	2023-02-24 02:36:24.827893	Under	{}
7686	3.0	14.00	659	1st Half	94.2%	2023-02-24 02:36:24.833421	2023-02-24 02:36:24.833421	Over	{}
7687	3.0	1.01	659	1st Half	94.2%	2023-02-24 02:36:24.835754	2023-02-24 02:36:24.835754	Under	{}
7693	0.75	1.36	659	2nd Half	93.5%	2023-02-24 02:36:30.399277	2023-02-24 02:36:30.399277	Over	{}
7694	0.75	2.99	659	2nd Half	93.5%	2023-02-24 02:36:30.401859	2023-02-24 02:36:30.401859	Under	{}
7695	1.0	1.53	659	2nd Half	93.6%	2023-02-24 02:36:30.403243	2023-02-24 02:36:30.403243	Over	{}
7696	1.0	2.41	659	2nd Half	93.6%	2023-02-24 02:36:30.405421	2023-02-24 02:36:30.405421	Under	{}
7697	1.25	1.89	659	2nd Half	93.5%	2023-02-24 02:36:30.406463	2023-02-24 02:36:30.406463	Over	{}
7698	1.25	1.85	659	2nd Half	93.5%	2023-02-24 02:36:30.407818	2023-02-24 02:36:30.407818	Under	{}
7701	1.75	2.74	659	2nd Half	93.5%	2023-02-24 02:36:30.414045	2023-02-24 02:36:30.414045	Over	{}
7702	1.75	1.42	659	2nd Half	93.5%	2023-02-24 02:36:30.416334	2023-02-24 02:36:30.416334	Under	{}
7703	2.0	3.90	659	2nd Half	93.5%	2023-02-24 02:36:30.418694	2023-02-24 02:36:30.418694	Over	{}
7704	2.0	1.23	659	2nd Half	93.5%	2023-02-24 02:36:30.421427	2023-02-24 02:36:30.421427	Under	{}
7705	2.25	4.50	659	2nd Half	93.5%	2023-02-24 02:36:30.423623	2023-02-24 02:36:30.423623	Over	{}
7706	2.25	1.18	659	2nd Half	93.5%	2023-02-24 02:36:30.425744	2023-02-24 02:36:30.425744	Under	{}
7709	3.0	8.70	659	2nd Half	92.9%	2023-02-24 02:36:30.43066	2023-02-24 02:36:30.43066	Over	{}
7710	3.0	1.04	659	2nd Half	92.9%	2023-02-24 02:36:30.432574	2023-02-24 02:36:30.432574	Under	{}
\.


--
-- TOC entry 3085 (class 0 OID 24822)
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
-- TOC entry 3086 (class 0 OID 24836)
-- Dependencies: 205
-- Data for Name: OddsSafariOverUnder; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."OddsSafariOverUnder" (id, goals, odds, match_id, half, payout, created, updated, type, bet_links) FROM stdin;
7715	2.5	2.15	634	1st Half	1.73%	2023-02-24 02:38:46.152128	2023-02-24 02:38:46.152128	Over	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
7716	2.5	1.81	634	1st Half	1.73%	2023-02-24 02:38:46.159992	2023-02-24 02:38:46.159992	Under	{https://partners.opapaffiliates.gr/redirect.aspx?pid=2460&bid=1759}
4716	0.5	1.50	634	1st Half	1.14%	2023-02-18 05:16:14.305929	2023-02-18 05:16:14.305929	Over	{https://sports.bwin.gr/el/sports?wm=5273373,https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
4717	0.5	2.90	634	1st Half	1.14%	2023-02-18 05:16:14.311078	2023-02-18 05:16:14.311078	Under	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
4719	0.5	3.75	634	2nd Half	4.02%	2023-02-18 05:16:19.646753	2023-02-18 05:16:19.646753	Under	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
4715	2.5	1.81	634	Full Time	1.73%	2023-02-18 05:16:09.30527	2023-02-18 05:16:09.30527	Under	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
4726	2.5	1.76	636	Full Time	4.25%	2023-02-18 05:16:59.918768	2023-02-18 05:16:59.918768	Over	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
4720	2.5	1.76	635	Full Time	4.25%	2023-02-18 05:16:34.188507	2023-02-18 05:16:34.188507	Over	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
4721	2.5	2.10	635	Full Time	4.25%	2023-02-18 05:16:34.19208	2023-02-18 05:16:34.19208	Under	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
4722	0.5	1.38	635	1st Half	2.69%	2023-02-18 05:16:40.031817	2023-02-18 05:16:40.031817	Over	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
4723	0.5	3.30	635	1st Half	2.69%	2023-02-18 05:16:40.037039	2023-02-18 05:16:40.037039	Under	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
4724	0.5	1.22	635	2nd Half	4.36%	2023-02-18 05:16:46.348524	2023-02-18 05:16:46.348524	Over	{https://sports.bwin.gr/el/sports?wm=5273373}
4725	0.5	4.40	635	2nd Half	4.36%	2023-02-18 05:16:46.355252	2023-02-18 05:16:46.355252	Under	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
4727	2.5	2.10	636	Full Time	4.25%	2023-02-18 05:16:59.921551	2023-02-18 05:16:59.921551	Under	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
4728	0.5	1.38	636	1st Half	2.69%	2023-02-18 05:17:05.708817	2023-02-18 05:17:05.708817	Over	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
4729	0.5	3.30	636	1st Half	2.69%	2023-02-18 05:17:05.712438	2023-02-18 05:17:05.712438	Under	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
4730	0.5	1.22	636	2nd Half	4.36%	2023-02-18 05:17:11.647585	2023-02-18 05:17:11.647585	Over	{https://sports.bwin.gr/el/sports?wm=5273373}
4731	0.5	4.40	636	2nd Half	4.36%	2023-02-18 05:17:11.653651	2023-02-18 05:17:11.653651	Under	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
4732	2.5	2.15	637	Full Time	3.83%	2023-02-18 05:17:25.90915	2023-02-18 05:17:25.90915	Over	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
4733	2.5	1.74	637	Full Time	3.83%	2023-02-18 05:17:25.91147	2023-02-18 05:17:25.91147	Under	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107,https://partners.opapaffiliates.gr/redirect.aspx?pid=2460&bid=1759}
4734	0.5	1.52	637	1st Half	1.48%	2023-02-18 05:17:31.889381	2023-02-18 05:17:31.889381	Over	{http://www.stoiximan.gr/}
4735	0.5	2.80	637	1st Half	1.48%	2023-02-18 05:17:31.896783	2023-02-18 05:17:31.896783	Under	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
4736	0.5	1.30	637	2nd Half	3.47%	2023-02-18 05:17:37.901678	2023-02-18 05:17:37.901678	Over	{https://sports.bwin.gr/el/sports?wm=5273373,http://www.stoiximan.gr/}
4737	0.5	3.75	637	2nd Half	3.47%	2023-02-18 05:17:37.904826	2023-02-18 05:17:37.904826	Under	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
4738	2.5	2.65	638	Full Time	1.41%	2023-02-18 05:17:50.936548	2023-02-18 05:17:50.936548	Over	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
4739	2.5	1.57	638	Full Time	1.41%	2023-02-18 05:17:50.939608	2023-02-18 05:17:50.939608	Under	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
4740	0.5	1.60	638	1st Half	4.00%	2023-02-18 05:17:56.215004	2023-02-18 05:17:56.215004	Over	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
4741	0.5	2.40	638	1st Half	4.00%	2023-02-18 05:17:56.217966	2023-02-18 05:17:56.217966	Under	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
4742	0.5	1.40	638	2nd Half	3.56%	2023-02-18 05:18:01.96025	2023-02-18 05:18:01.96025	Over	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
4743	0.5	3.10	638	2nd Half	3.56%	2023-02-18 05:18:01.974227	2023-02-18 05:18:01.974227	Under	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
4744	2.5	2.40	639	Full Time	2.93%	2023-02-18 05:18:14.665499	2023-02-18 05:18:14.665499	Over	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
4745	2.5	1.63	639	Full Time	2.93%	2023-02-18 05:18:14.670694	2023-02-18 05:18:14.670694	Under	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
4746	0.5	1.57	639	1st Half	2.83%	2023-02-18 05:18:20.486493	2023-02-18 05:18:20.486493	Over	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
4747	0.5	2.55	639	1st Half	2.83%	2023-02-18 05:18:20.495336	2023-02-18 05:18:20.495336	Under	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
4748	0.5	1.35	639	2nd Half	3.37%	2023-02-18 05:18:25.349735	2023-02-18 05:18:25.349735	Over	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
4749	0.5	3.40	639	2nd Half	3.37%	2023-02-18 05:18:25.352631	2023-02-18 05:18:25.352631	Under	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
4750	2.5	2.50	640	Full Time	3.19%	2023-02-18 05:18:38.124823	2023-02-18 05:18:38.124823	Over	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
4714	2.5	2.15	634	Full Time	1.73%	2023-02-18 05:16:09.300401	2023-02-18 05:16:09.300401	Over	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
4718	0.5	1.29	634	2nd Half	4.02%	2023-02-18 05:16:19.642677	2023-02-18 05:16:19.642677	Over	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
4751	2.5	1.58	640	Full Time	3.19%	2023-02-18 05:18:38.129016	2023-02-18 05:18:38.129016	Under	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
4752	0.5	1.57	640	1st Half	3.56%	2023-02-18 05:18:44.197585	2023-02-18 05:18:44.197585	Over	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
4753	0.5	2.50	640	1st Half	3.56%	2023-02-18 05:18:44.203761	2023-02-18 05:18:44.203761	Under	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
4754	0.5	1.35	640	2nd Half	4.62%	2023-02-18 05:18:50.132981	2023-02-18 05:18:50.132981	Over	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
4755	0.5	3.25	640	2nd Half	4.62%	2023-02-18 05:18:50.137232	2023-02-18 05:18:50.137232	Under	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
\.


--
-- TOC entry 3088 (class 0 OID 24966)
-- Dependencies: 208
-- Data for Name: OverUnderHistorical; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."OverUnderHistorical" (id, "Date_Time", "Type", "Goals", "Odds_bet", "Margin", "Payout", "Bet_link", "Home_Team", "Guest_Team", "Home_Team_Goals", "Guest_Team_Goals", "Half", won, "Home_Team_Goals_1st_Half", "Home_Team_Goals_2nd_Half", "Guest_Team_Goals_1st_Half", "Guest_Team_Goals_2nd_Half") FROM stdin;
20	2023-02-19 19:30:00+02	Under	0.5	3.25	0.00	3.63%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}	Panetolikos	Ionikos	1	0	\N	\N	0	1	0	0
11	2023-02-19 16:00:00+02	Under	0.5	2.95	0.00	2.78%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}	Lamia	Olympiacos	0	3	\N	\N	0	0	1	2
12	2023-02-19 16:00:00+02	Under	0.5	3.90	0.95	4.20%	{}	Lamia	Olympiacos	0	3	\N	\N	0	0	1	2
10	2023-02-19 16:00:00+02	Over	2.5	2.00	0.00	2.56%	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/,https://www.bet365.gr/olp/open-account?affiliate=365_01012107}	Lamia	Olympiacos	0	3	\N	Won	0	0	1	2
6	2023-02-18 20:00:00+02	Over	2.5	2.55	0.00	2.07%	{https://record.affiliates.betshop.gr/_xVrm1kU5pcRLcRLGwHoTKWNd7ZgqdRLk/1/}	Asteras Tripolis	PAS Giannina	1	1	\N	\N	1	0	1	0
7	2023-02-18 20:00:00+02	Under	0.5	2.45	0.00	3.21%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}	Asteras Tripolis	PAS Giannina	1	1	\N	\N	1	0	1	0
8	2023-02-18 20:00:00+02	Under	0.5	3.25	0.80	3.63%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}	Asteras Tripolis	PAS Giannina	1	1	\N	\N	1	0	1	0
9	2023-02-18 20:00:00+02	Under	0.5	3.25	0.00	3.63%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}	Asteras Tripolis	PAS Giannina	1	1	\N	\N	1	0	1	0
1	2023-02-18 17:00:00+02	Over	2.5	2.17	0.00	0.72%	{https://record.affiliates.betshop.gr/_xVrm1kU5pcRLcRLGwHoTKWNd7ZgqdRLk/1/}	Panathinaikos	Volos	2	0	\N	\N	0	2	0	0
2	2023-02-18 17:00:00+02	Under	0.5	2.80	0.00	2.33%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}	Panathinaikos	Volos	2	0	\N	\N	0	2	0	0
3	2023-02-18 17:00:00+02	Under	0.5	3.70	0.90	3.80%	{}	Panathinaikos	Volos	2	0	\N	\N	0	2	0	0
4	2023-02-18 17:00:00+02	Under	0.5	3.70	0.00	3.80%	{}	Panathinaikos	Volos	2	0	\N	\N	0	2	0	0
5	2023-02-18 17:00:00+02	Under	2.5	1.83	0.00	0.72%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}	Panathinaikos	Volos	2	0	\N	\N	0	2	0	0
26	2023-02-20 18:00:00+02	Over	2.5	2.40	0.00	3.46%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}	Atromitos	Levadiakos	1	0	\N	\N	1	0	0	0
27	2023-02-20 18:00:00+02	Under	0.5	2.55	0.05	2.83%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}	Atromitos	Levadiakos	1	0	\N	\N	1	0	0	0
28	2023-02-20 18:00:00+02	Under	0.5	3.40	0.90	4.40%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}	Atromitos	Levadiakos	1	0	\N	\N	1	0	0	0
29	2023-02-20 18:00:00+02	Under	0.5	2.55	0.00	2.83%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}	Atromitos	Levadiakos	1	0	\N	\N	1	0	0	0
33	2023-02-20 19:30:00+02	Over	2.5	2.40	0.00	3.28%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}	OFI	Aris Salonika	0	3	\N	Won	0	0	2	1
34	2023-02-20 19:30:00+02	Under	0.5	2.60	0.00	2.89%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}	OFI	Aris Salonika	0	3	\N	\N	0	0	2	1
30	2023-02-20 18:00:00+02	Under	0.5	3.40	0.85	4.40%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}	Atromitos	Levadiakos	1	0	\N	\N	1	0	0	0
31	2023-02-20 18:00:00+02	Under	0.5	3.40	0.00	4.40%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}	Atromitos	Levadiakos	1	0	\N	\N	1	0	0	0
35	2023-02-20 19:30:00+02	Under	0.5	3.40	0.80	4.40%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}	OFI	Aris Salonika	0	3	\N	\N	0	0	2	1
36	2023-02-20 19:30:00+02	Under	0.5	3.40	0.00	4.40%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}	OFI	Aris Salonika	0	3	\N	\N	0	0	2	1
22	2023-02-19 20:30:00+02	Over	2.5	2.45	0.00	2.48%	{https://record.affiliates.betshop.gr/_xVrm1kU5pcRLcRLGwHoTKWNd7ZgqdRLk/1/}	PAOK	AEK	2	0	\N	\N	1	1	0	0
23	2023-02-19 20:30:00+02	Under	0.5	2.50	0.00	2.44%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}	PAOK	AEK	2	0	\N	\N	1	1	0	0
24	2023-02-19 20:30:00+02	Under	0.5	3.25	0.75	5.47%	{http://www.stoiximan.gr/,https://www.bet365.gr/olp/open-account?affiliate=365_01012107}	PAOK	AEK	2	0	\N	\N	1	1	0	0
25	2023-02-19 20:30:00+02	Under	0.5	3.25	0.00	5.47%	{http://www.stoiximan.gr/,https://www.bet365.gr/olp/open-account?affiliate=365_01012107}	PAOK	AEK	2	0	\N	\N	1	1	0	0
15	2023-02-19 19:30:00+02	Over	2.5	2.50	0.00	1.70%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107,https://partners.opapaffiliates.gr/redirect.aspx?pid=2460&bid=1759,https://record.affiliates.betshop.gr/_xVrm1kU5pcRLcRLGwHoTKWNd7ZgqdRLk/1/}	Panetolikos	Ionikos	1	0	\N	\N	0	1	0	0
16	2023-02-19 19:30:00+02	Over	2.5	2.50	0.00	1.70%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107,https://partners.opapaffiliates.gr/redirect.aspx?pid=2460&bid=1759,https://record.affiliates.betshop.gr/_xVrm1kU5pcRLcRLGwHoTKWNd7ZgqdRLk/1/}	Panetolikos	Ionikos	1	0	\N	\N	0	1	0	0
17	2023-02-19 19:30:00+02	Under	0.5	2.45	0.00	3.21%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}	Panetolikos	Ionikos	1	0	\N	\N	0	1	0	0
18	2023-02-19 19:30:00+02	Under	0.5	3.25	0.80	3.63%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}	Panetolikos	Ionikos	1	0	\N	\N	0	1	0	0
13	2023-02-19 16:00:00+02	Under	0.5	3.90	0.00	4.20%	{}	Lamia	Olympiacos	0	3	\N	\N	0	0	1	2
14	2023-02-19 16:00:00+02	Under	2.5	1.90	0.00	2.56%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}	Lamia	Olympiacos	0	3	\N	\N	0	0	1	2
32	2023-02-20 18:00:00+02	Under	0.5	3.40	0.00	4.40%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}	Atromitos	Levadiakos	1	0	\N	\N	1	0	0	0
19	2023-02-19 19:30:00+02	Under	0.5	3.25	0.75	3.63%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}	Panetolikos	Ionikos	1	0	\N	\N	0	1	0	0
21	2023-02-19 19:30:00+02	Under	0.5	3.25	0.00	3.63%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}	Panetolikos	Ionikos	1	0	\N	\N	0	1	0	0
\.


--
-- TOC entry 3090 (class 0 OID 25038)
-- Dependencies: 211
-- Data for Name: soccer_statistics; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.soccer_statistics (id, home_team, guest_team, date_time, goals_home, goals_guest, full_time_home_win_odds, full_time_draw_odds, full_time_guest_win_odds, fisrt_half_home_win_odds, first_half_draw_odds, second_half_goals_guest, second_half_goals_home, first_half_goals_guest, first_half_goals_home, first_half_guest_win_odds, second_half_home_win_odds, second_half_draw_odds, second_half_guest_win_odds, full_time_over_under_goals, full_time_over_odds, full_time_under_odds, full_time_payout, first_half_over_under_goals, first_half_over_odds, firt_half_under_odds, first_half_payout, second_half_over_under_goals, second_half_over_odds, second_half_under_odds, second_half_payout, last_updated) FROM stdin;
\.


--
-- TOC entry 3110 (class 0 OID 0)
-- Dependencies: 201
-- Name: Match_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."Match_id_seq"', 893, true);


--
-- TOC entry 3111 (class 0 OID 0)
-- Dependencies: 207
-- Name: OverUnderHistorical_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."OverUnderHistorical_id_seq"', 36, true);


--
-- TOC entry 3112 (class 0 OID 0)
-- Dependencies: 203
-- Name: OverUnder_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."OverUnder_id_seq"', 7748, true);


--
-- TOC entry 3113 (class 0 OID 0)
-- Dependencies: 210
-- Name: soccer_statistics_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.soccer_statistics_id_seq', 1, false);


--
-- TOC entry 2923 (class 2606 OID 24734)
-- Name: OddsPortalMatch OddsPortalMatch_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsPortalMatch"
    ADD CONSTRAINT "OddsPortalMatch_pk" PRIMARY KEY (id);


--
-- TOC entry 2925 (class 2606 OID 24736)
-- Name: OddsPortalMatch OddsPortalMatch_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsPortalMatch"
    ADD CONSTRAINT "OddsPortalMatch_unique" UNIQUE (home_team, guest_team, date_time);


--
-- TOC entry 2927 (class 2606 OID 24804)
-- Name: OddsPortalOverUnder OddsPortalOverUnder_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsPortalOverUnder"
    ADD CONSTRAINT "OddsPortalOverUnder_pk" PRIMARY KEY (id, match_id, half, type, goals);


--
-- TOC entry 2929 (class 2606 OID 24862)
-- Name: OddsPortalOverUnder OddsPortalOverUnder_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsPortalOverUnder"
    ADD CONSTRAINT "OddsPortalOverUnder_unique" UNIQUE (goals, match_id, half, type);


--
-- TOC entry 2932 (class 2606 OID 24833)
-- Name: OddsSafariMatch OddsSafariMatch_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsSafariMatch"
    ADD CONSTRAINT "OddsSafariMatch_pk" PRIMARY KEY (id);


--
-- TOC entry 2934 (class 2606 OID 24835)
-- Name: OddsSafariMatch OddsSafariMatch_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsSafariMatch"
    ADD CONSTRAINT "OddsSafariMatch_unique" UNIQUE (home_team, guest_team, date_time);


--
-- TOC entry 2936 (class 2606 OID 24846)
-- Name: OddsSafariOverUnder OddsSafariOverUnder_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsSafariOverUnder"
    ADD CONSTRAINT "OddsSafariOverUnder_pk" PRIMARY KEY (id);


--
-- TOC entry 2938 (class 2606 OID 24848)
-- Name: OddsSafariOverUnder OddsSafariOverUnder_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsSafariOverUnder"
    ADD CONSTRAINT "OddsSafariOverUnder_unique" UNIQUE (goals, match_id, half, type);


--
-- TOC entry 2942 (class 2606 OID 24974)
-- Name: OverUnderHistorical OverUnderHistorical_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OverUnderHistorical"
    ADD CONSTRAINT "OverUnderHistorical_pkey" PRIMARY KEY (id);


--
-- TOC entry 2944 (class 2606 OID 25047)
-- Name: soccer_statistics soccer_statistics_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.soccer_statistics
    ADD CONSTRAINT soccer_statistics_pkey PRIMARY KEY (id);


--
-- TOC entry 2930 (class 1259 OID 24995)
-- Name: fki_OddsPortalOverUnder_Match_fk; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "fki_OddsPortalOverUnder_Match_fk" ON public."OddsPortalOverUnder" USING btree (match_id);


--
-- TOC entry 2939 (class 1259 OID 24860)
-- Name: fki_OddsSafariOverUnder_Match_fk; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "fki_OddsSafariOverUnder_Match_fk" ON public."OddsSafariOverUnder" USING btree (match_id);


--
-- TOC entry 2940 (class 1259 OID 24854)
-- Name: fki_OddsSafariOverUnder_match_id_fk; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "fki_OddsSafariOverUnder_match_id_fk" ON public."OddsSafariOverUnder" USING btree (match_id);


--
-- TOC entry 2947 (class 2620 OID 24783)
-- Name: OddsPortalOverUnder update_updated_Match_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER "update_updated_Match_trigger" AFTER UPDATE ON public."OddsPortalOverUnder" FOR EACH ROW EXECUTE FUNCTION public."update_updated_on_Match"();


--
-- TOC entry 2948 (class 2620 OID 24782)
-- Name: OddsPortalOverUnder update_updated_OverUnder_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER "update_updated_OverUnder_trigger" AFTER UPDATE ON public."OddsPortalOverUnder" FOR EACH ROW EXECUTE FUNCTION public."update_updated_on_OverUnder"();


--
-- TOC entry 2945 (class 2606 OID 24990)
-- Name: OddsPortalOverUnder OddsPortalOverUnder_Match_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsPortalOverUnder"
    ADD CONSTRAINT "OddsPortalOverUnder_Match_fk" FOREIGN KEY (match_id) REFERENCES public."OddsPortalMatch"(id) ON UPDATE CASCADE ON DELETE CASCADE NOT VALID;


--
-- TOC entry 2946 (class 2606 OID 24985)
-- Name: OddsSafariOverUnder OddsSafariOverUnder_Match_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsSafariOverUnder"
    ADD CONSTRAINT "OddsSafariOverUnder_Match_fk" FOREIGN KEY (match_id) REFERENCES public."OddsSafariMatch"(id) ON UPDATE CASCADE ON DELETE CASCADE NOT VALID;


--
-- TOC entry 3098 (class 0 OID 0)
-- Dependencies: 200
-- Name: TABLE "OddsPortalMatch"; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE public."OddsPortalMatch" FROM postgres;


--
-- TOC entry 3100 (class 0 OID 0)
-- Dependencies: 202
-- Name: TABLE "OddsPortalOverUnder"; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE public."OddsPortalOverUnder" FROM postgres;
GRANT ALL ON TABLE public."OddsPortalOverUnder" TO postgres WITH GRANT OPTION;


--
-- TOC entry 3101 (class 0 OID 0)
-- Dependencies: 204
-- Name: TABLE "OddsSafariMatch"; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE public."OddsSafariMatch" FROM postgres;
GRANT ALL ON TABLE public."OddsSafariMatch" TO postgres WITH GRANT OPTION;


--
-- TOC entry 3102 (class 0 OID 0)
-- Dependencies: 205
-- Name: TABLE "OddsSafariOverUnder"; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE public."OddsSafariOverUnder" FROM postgres;
GRANT ALL ON TABLE public."OddsSafariOverUnder" TO postgres WITH GRANT OPTION;


--
-- TOC entry 3103 (class 0 OID 0)
-- Dependencies: 208
-- Name: TABLE "OverUnderHistorical"; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE public."OverUnderHistorical" FROM postgres;
GRANT ALL ON TABLE public."OverUnderHistorical" TO postgres WITH GRANT OPTION;


--
-- TOC entry 3106 (class 0 OID 0)
-- Dependencies: 206
-- Name: TABLE "PortalSafariMatch"; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE public."PortalSafariMatch" FROM postgres;
GRANT ALL ON TABLE public."PortalSafariMatch" TO postgres WITH GRANT OPTION;


--
-- TOC entry 3107 (class 0 OID 0)
-- Dependencies: 209
-- Name: TABLE "PortalSafariBets"; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE public."PortalSafariBets" FROM postgres;
GRANT ALL ON TABLE public."PortalSafariBets" TO postgres WITH GRANT OPTION;


--
-- TOC entry 3108 (class 0 OID 0)
-- Dependencies: 211
-- Name: TABLE soccer_statistics; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE public.soccer_statistics FROM postgres;
GRANT ALL ON TABLE public.soccer_statistics TO postgres WITH GRANT OPTION;


--
-- TOC entry 1764 (class 826 OID 24717)
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: -; Owner: -
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres REVOKE ALL ON TABLES  FROM postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres GRANT ALL ON TABLES  TO postgres WITH GRANT OPTION;


-- Completed on 2023-02-24 02:50:49 EET

--
-- PostgreSQL database dump complete
--


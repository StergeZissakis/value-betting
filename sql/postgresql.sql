--
-- PostgreSQL database dump
--

-- Dumped from database version 13.9 (Debian 13.9-0+deb11u1)
-- Dumped by pg_dump version 13.9 (Debian 13.9-0+deb11u1)

-- Started on 2023-02-26 10:44:44 EET

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
-- TOC entry 3112 (class 1262 OID 13445)
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
-- TOC entry 3113 (class 0 OID 0)
-- Dependencies: 3112
-- Name: DATABASE postgres; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON DATABASE postgres IS 'default administrative connection database';


--
-- TOC entry 670 (class 1247 OID 25025)
-- Name: BetResult; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."BetResult" AS ENUM (
    'Won',
    'Lost'
);


--
-- TOC entry 643 (class 1247 OID 24746)
-- Name: MatchTime; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."MatchTime" AS ENUM (
    'Full Time',
    '1st Half',
    '2nd Half'
);


--
-- TOC entry 646 (class 1247 OID 24790)
-- Name: OverUnderType; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."OverUnderType" AS ENUM (
    'Over',
    'Under'
);


--
-- TOC entry 216 (class 1255 OID 24984)
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
-- TOC entry 228 (class 1255 OID 25029)
-- Name: CalculateOverUnderResults(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public."CalculateOverUnderResults"() RETURNS void
    LANGUAGE sql
    AS $$UPDATE	public."OverUnderHistorical" AS t SET Won = 'Won'
WHERE 	(t."Home_Team_Goals" + t."Guest_Team_Goals") > (t."Home_Team_Goals" + t."Guest_Team_Goals") AND  t."Type" = 'Over' AND t."Half" = 'Full Time';

UPDATE	public."OverUnderHistorical" AS t SET Won = 'Won'
WHERE 	(t."Home_Team_Goals" + t."Guest_Team_Goals") < (t."Home_Team_Goals" + t."Guest_Team_Goals") AND  t."Type" = 'Under' AND t."Half" = 'Full Time';

UPDATE	public."OverUnderHistorical" AS t SET Won = 'Won'
WHERE 	(t."Home_Team_Goals_1st_Half" + t."Guest_Team_Goals_1st_Half") > t."Goals" AND  t."Type" = 'Over' AND t."Half" = '1st Half';

UPDATE	public."OverUnderHistorical" AS t SET Won = 'Won'
WHERE 	(t."Home_Team_Goals_1st_Half" + t."Guest_Team_Goals_1st_Half") < t."Goals" AND  t."Type" = 'Over' AND t."Half" = '1st Half';

UPDATE	public."OverUnderHistorical" AS t SET Won = 'Won'
WHERE 	(t."Home_Team_Goals_2nd_Half" + t."Guest_Team_Goals_2nd_Half") > t."Goals" AND  t."Type" = 'Over' AND t."Half" = '2nd Half';

UPDATE	public."OverUnderHistorical" AS t SET Won = 'Won'
WHERE 	(t."Home_Team_Goals_2nd_Half" + t."Guest_Team_Goals_2nd_Half") < t."Goals" AND  t."Type" = 'Over' AND t."Half" = '2nd Half';

$$;


--
-- TOC entry 214 (class 1255 OID 24779)
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
-- TOC entry 215 (class 1255 OID 24778)
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
-- TOC entry 211 (class 1259 OID 25102)
-- Name: 1x2_oddsportal; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."1x2_oddsportal" (
    id bigint NOT NULL,
    date_time timestamp with time zone NOT NULL,
    home_team character varying NOT NULL,
    guest_team character varying NOT NULL,
    half public."MatchTime" NOT NULL,
    "1_odds" numeric(3,2) NOT NULL,
    x_odds numeric(3,2) NOT NULL,
    "2_odds" numeric(3,2) NOT NULL,
    created timestamp without time zone DEFAULT now() NOT NULL,
    updated timestamp without time zone DEFAULT now() NOT NULL
);


--
-- TOC entry 210 (class 1259 OID 25100)
-- Name: 1x2_oddsportal_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."1x2_oddsportal_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3115 (class 0 OID 0)
-- Dependencies: 210
-- Name: 1x2_oddsportal_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."1x2_oddsportal_id_seq" OWNED BY public."1x2_oddsportal".id;


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
-- TOC entry 3117 (class 0 OID 0)
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
-- TOC entry 213 (class 1259 OID 25135)
-- Name: OverUnderHistorical; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."OverUnderHistorical" (
    id bigint NOT NULL,
    "Date_Time" timestamp with time zone NOT NULL,
    "Home_Team" character varying NOT NULL,
    "Guest_Team" character varying NOT NULL,
    "Type" public."OverUnderType" NOT NULL,
    "Half" public."MatchTime",
    "Odds_bet" numeric NOT NULL,
    "Margin" numeric NOT NULL,
    won public."BetResult",
    "Goals" numeric NOT NULL,
    "Home_Team_Goals" smallint,
    "Guest_Team_Goals" smallint,
    "Home_Team_Goals_1st_Half" smallint,
    "Home_Team_Goals_2nd_Half" smallint,
    "Guest_Team_Goals_1st_Half" smallint,
    "Guest_Team_Goals_2nd_Half" smallint,
    "Payout" character varying NOT NULL,
    "Bet_link" character varying NOT NULL
);


--
-- TOC entry 212 (class 1259 OID 25133)
-- Name: OverUnderHistorical_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."OverUnderHistorical_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3122 (class 0 OID 0)
-- Dependencies: 212
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
-- TOC entry 3123 (class 0 OID 0)
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
-- TOC entry 207 (class 1259 OID 24996)
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
  WHERE ((portal_over_under.type = safari_over_under.type) AND (portal_over_under.half = safari_over_under.half) AND (portal_over_under.goals = safari_over_under.goals) AND (safari_over_under.odds >= portal_over_under.odds) AND (safari_over_under.odds >= 1.7))
  ORDER BY global_match.portal_time, (concat(global_match.portal_home_team, ' - ', global_match.portal_guest_team)), portal_over_under.type, portal_over_under.goals, portal_over_under.odds, safari_over_under.odds, (portal_over_under.odds - safari_over_under.odds) DESC;


--
-- TOC entry 209 (class 1259 OID 25038)
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
-- TOC entry 208 (class 1259 OID 25036)
-- Name: soccer_statistics_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.soccer_statistics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3127 (class 0 OID 0)
-- Dependencies: 208
-- Name: soccer_statistics_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.soccer_statistics_id_seq OWNED BY public.soccer_statistics.id;


--
-- TOC entry 2928 (class 2604 OID 25105)
-- Name: 1x2_oddsportal id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."1x2_oddsportal" ALTER COLUMN id SET DEFAULT nextval('public."1x2_oddsportal_id_seq"'::regclass);


--
-- TOC entry 2914 (class 2604 OID 24731)
-- Name: OddsPortalMatch id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsPortalMatch" ALTER COLUMN id SET DEFAULT nextval('public."Match_id_seq"'::regclass);


--
-- TOC entry 2917 (class 2604 OID 24732)
-- Name: OddsPortalOverUnder id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsPortalOverUnder" ALTER COLUMN id SET DEFAULT nextval('public."OverUnder_id_seq"'::regclass);


--
-- TOC entry 2920 (class 2604 OID 24825)
-- Name: OddsSafariMatch id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsSafariMatch" ALTER COLUMN id SET DEFAULT nextval('public."Match_id_seq"'::regclass);


--
-- TOC entry 2921 (class 2604 OID 24826)
-- Name: OddsSafariMatch created; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsSafariMatch" ALTER COLUMN created SET DEFAULT CURRENT_TIMESTAMP;


--
-- TOC entry 2922 (class 2604 OID 24827)
-- Name: OddsSafariMatch updated; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsSafariMatch" ALTER COLUMN updated SET DEFAULT CURRENT_TIMESTAMP;


--
-- TOC entry 2923 (class 2604 OID 24839)
-- Name: OddsSafariOverUnder id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsSafariOverUnder" ALTER COLUMN id SET DEFAULT nextval('public."OverUnder_id_seq"'::regclass);


--
-- TOC entry 2924 (class 2604 OID 24840)
-- Name: OddsSafariOverUnder created; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsSafariOverUnder" ALTER COLUMN created SET DEFAULT CURRENT_TIMESTAMP;


--
-- TOC entry 2925 (class 2604 OID 24841)
-- Name: OddsSafariOverUnder updated; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsSafariOverUnder" ALTER COLUMN updated SET DEFAULT CURRENT_TIMESTAMP;


--
-- TOC entry 2931 (class 2604 OID 25138)
-- Name: OverUnderHistorical id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OverUnderHistorical" ALTER COLUMN id SET DEFAULT nextval('public."OverUnderHistorical_id_seq"'::regclass);


--
-- TOC entry 2926 (class 2604 OID 25041)
-- Name: soccer_statistics id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.soccer_statistics ALTER COLUMN id SET DEFAULT nextval('public.soccer_statistics_id_seq'::regclass);


--
-- TOC entry 3104 (class 0 OID 25102)
-- Dependencies: 211
-- Data for Name: 1x2_oddsportal; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."1x2_oddsportal" (id, date_time, home_team, guest_team, half, "1_odds", x_odds, "2_odds", created, updated) FROM stdin;
\.


--
-- TOC entry 3095 (class 0 OID 24718)
-- Dependencies: 200
-- Data for Name: OddsPortalMatch; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."OddsPortalMatch" (id, home_team, guest_team, date_time, created, updated) FROM stdin;
653	Ionikos	OFI Crete	2023-02-26 16:00:00+02	2023-02-22 04:39:13.546139	2023-02-22 04:39:13.546139
656	Levadiakos	Panetolikos	2023-02-26 16:00:00+02	2023-02-22 04:39:32.575739	2023-02-22 04:39:32.575739
659	Aris	Atromitos	2023-02-26 19:30:00+02	2023-02-22 04:39:51.828087	2023-02-22 04:39:51.828087
\.


--
-- TOC entry 3097 (class 0 OID 24726)
-- Dependencies: 202
-- Data for Name: OddsPortalOverUnder; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."OddsPortalOverUnder" (id, goals, odds, match_id, half, payout, created, updated, type, bet_links) FROM stdin;
4897	2.25	1.80	653	Full Time	95.8%	2023-02-22 04:39:15.320427	2023-02-22 04:39:15.320427	Under	{}
4898	2.5	2.30	653	Full Time	95.4%	2023-02-22 04:39:15.321423	2023-02-22 04:39:15.321423	Over	{}
4899	2.5	1.63	653	Full Time	95.4%	2023-02-22 04:39:15.322905	2023-02-22 04:39:15.322905	Under	{}
4900	3.5	4.33	653	Full Time	95.2%	2023-02-22 04:39:15.324092	2023-02-22 04:39:15.324092	Over	{}
4901	3.5	1.22	653	Full Time	95.2%	2023-02-22 04:39:15.3252	2023-02-22 04:39:15.3252	Under	{}
4892	0.5	1.10	653	Full Time	96.7%	2023-02-22 04:39:15.315092	2023-02-22 04:39:15.315092	Over	{}
4893	0.5	8.00	653	Full Time	96.7%	2023-02-22 04:39:15.316772	2023-02-22 04:39:15.316772	Under	{}
4894	1.5	1.41	653	Full Time	94.9%	2023-02-22 04:39:15.317699	2023-02-22 04:39:15.317699	Over	{}
4895	1.5	2.90	653	Full Time	94.9%	2023-02-22 04:39:15.318695	2023-02-22 04:39:15.318695	Under	{}
4896	2.25	2.05	653	Full Time	95.8%	2023-02-22 04:39:15.319479	2023-02-22 04:39:15.319479	Over	{}
4902	4.5	10.00	653	Full Time	95.8%	2023-02-22 04:39:15.32601	2023-02-22 04:39:15.32601	Over	{}
4903	4.5	1.06	653	Full Time	95.8%	2023-02-22 04:39:15.326993	2023-02-22 04:39:15.326993	Under	{}
4904	5.5	21.00	653	Full Time	97.3%	2023-02-22 04:39:15.328073	2023-02-22 04:39:15.328073	Over	{}
4905	5.5	1.02	653	Full Time	97.3%	2023-02-22 04:39:15.329099	2023-02-22 04:39:15.329099	Under	{}
4906	6.5	36.00	653	Full Time	97.3%	2023-02-22 04:39:15.329821	2023-02-22 04:39:15.329821	Over	{}
4907	0.5	1.50	653	1st Half	95.1%	2023-02-22 04:39:17.754267	2023-02-22 04:39:17.754267	Over	{}
4908	0.5	2.60	653	1st Half	95.1%	2023-02-22 04:39:19.645078	2023-02-22 04:39:19.645078	Under	{}
4909	0.75	1.75	653	1st Half	94.4%	2023-02-22 04:39:19.646334	2023-02-22 04:39:19.646334	Over	{}
4910	0.75	2.05	653	1st Half	94.4%	2023-02-22 04:39:19.647289	2023-02-22 04:39:19.647289	Under	{}
4911	1.5	3.50	653	1st Half	96.4%	2023-02-22 04:39:19.648361	2023-02-22 04:39:19.648361	Over	{}
4912	1.5	1.33	653	1st Half	96.4%	2023-02-22 04:39:19.649325	2023-02-22 04:39:19.649325	Under	{}
4914	2.5	1.06	653	1st Half	96.7%	2023-02-22 04:39:19.651405	2023-02-22 04:39:19.651405	Under	{}
4915	3.5	26.00	653	1st Half	97.2%	2023-02-22 04:39:19.652511	2023-02-22 04:39:19.652511	Over	{}
4916	3.5	1.01	653	1st Half	97.2%	2023-02-22 04:39:19.653609	2023-02-22 04:39:19.653609	Under	{}
4917	4.5	67.00	653	1st Half	98.5%	2023-02-22 04:39:19.654816	2023-02-22 04:39:19.654816	Over	{}
4918	0.5	1.36	653	2nd Half	97.1%	2023-02-22 04:39:21.354681	2023-02-22 04:39:21.354681	Over	{}
8429	6.5	1.01	659	Full Time	97.6%	2023-02-26 09:29:12.841878	2023-02-26 09:29:12.841878	Under	{}
4919	0.5	3.40	653	2nd Half	97.1%	2023-02-22 04:39:22.292822	2023-02-22 04:39:22.292822	Under	{}
4920	1.5	2.50	653	2nd Half	94.9%	2023-02-22 04:39:22.294028	2023-02-22 04:39:22.294028	Over	{}
4921	1.5	1.53	653	2nd Half	94.9%	2023-02-22 04:39:22.295214	2023-02-22 04:39:22.295214	Under	{}
4922	2.5	5.50	653	2nd Half	94.4%	2023-02-22 04:39:22.296452	2023-02-22 04:39:22.296452	Over	{}
4923	2.5	1.14	653	2nd Half	94.4%	2023-02-22 04:39:22.297705	2023-02-22 04:39:22.297705	Under	{}
4924	3.5	15.00	653	2nd Half	96.4%	2023-02-22 04:39:22.298885	2023-02-22 04:39:22.298885	Over	{}
4925	3.5	1.03	653	2nd Half	96.4%	2023-02-22 04:39:22.300081	2023-02-22 04:39:22.300081	Under	{}
4987	0.5	3.75	659	2nd Half	99.8%	2023-02-22 04:40:00.560956	2023-02-22 04:40:00.560956	Under	{}
4930	2.25	2.19	656	Full Time	96.0%	2023-02-22 04:39:34.467201	2023-02-22 04:39:34.467201	Over	{}
4929	1.5	2.55	656	Full Time	94.4%	2023-02-22 04:39:34.464803	2023-02-22 04:39:34.464803	Under	{}
4936	4.5	12.00	656	Full Time	96.6%	2023-02-22 04:39:34.476755	2023-02-22 04:39:34.476755	Over	{}
4937	4.5	1.05	656	Full Time	96.6%	2023-02-22 04:39:34.478073	2023-02-22 04:39:34.478073	Under	{}
4940	6.5	41.00	656	Full Time	97.6%	2023-02-22 04:39:34.481941	2023-02-22 04:39:34.481941	Over	{}
4941	0.5	1.55	656	1st Half	94.9%	2023-02-22 04:39:36.105811	2023-02-22 04:39:36.105811	Over	{}
4942	0.5	2.45	656	1st Half	94.9%	2023-02-22 04:39:37.655761	2023-02-22 04:39:37.655761	Under	{}
4943	0.75	1.83	656	1st Half	95.1%	2023-02-22 04:39:37.656993	2023-02-22 04:39:37.656993	Over	{}
4944	0.75	1.98	656	1st Half	95.1%	2023-02-22 04:39:37.658187	2023-02-22 04:39:37.658187	Under	{}
4945	1.5	3.75	656	1st Half	96.0%	2023-02-22 04:39:37.65986	2023-02-22 04:39:37.65986	Over	{}
4946	1.5	1.29	656	1st Half	96.0%	2023-02-22 04:39:37.661159	2023-02-22 04:39:37.661159	Under	{}
4947	2.5	11.00	656	1st Half	95.9%	2023-02-22 04:39:37.66276	2023-02-22 04:39:37.66276	Over	{}
4948	2.5	1.05	656	1st Half	95.9%	2023-02-22 04:39:37.664257	2023-02-22 04:39:37.664257	Under	{}
4949	3.5	29.00	656	1st Half	97.6%	2023-02-22 04:39:37.665585	2023-02-22 04:39:37.665585	Over	{}
4950	3.5	1.01	656	1st Half	97.6%	2023-02-22 04:39:37.666668	2023-02-22 04:39:37.666668	Under	{}
4951	4.5	71.00	656	1st Half	98.6%	2023-02-22 04:39:37.667777	2023-02-22 04:39:37.667777	Over	{}
4952	0.5	1.40	656	2nd Half	97.8%	2023-02-22 04:39:39.809649	2023-02-22 04:39:39.809649	Over	{}
4953	0.5	3.25	656	2nd Half	97.8%	2023-02-22 04:39:40.962336	2023-02-22 04:39:40.962336	Under	{}
4954	1.5	2.75	656	2nd Half	94.5%	2023-02-22 04:39:40.964164	2023-02-22 04:39:40.964164	Over	{}
4955	1.5	1.44	656	2nd Half	94.5%	2023-02-22 04:39:40.966643	2023-02-22 04:39:40.966643	Under	{}
4957	2.5	1.11	656	2nd Half	94.8%	2023-02-22 04:39:40.971448	2023-02-22 04:39:40.971448	Under	{}
4958	3.5	19.00	656	2nd Half	96.8%	2023-02-22 04:39:40.97377	2023-02-22 04:39:40.97377	Over	{}
4959	3.5	1.02	656	2nd Half	96.8%	2023-02-22 04:39:40.9752	2023-02-22 04:39:40.9752	Under	{}
4960	0.5	1.08	659	Full Time	98.3%	2023-02-22 04:39:53.895554	2023-02-22 04:39:53.895554	Over	{}
4961	0.5	11.00	659	Full Time	98.3%	2023-02-22 04:39:53.898266	2023-02-22 04:39:53.898266	Under	{}
4962	1.5	1.40	659	Full Time	100.0%	2023-02-22 04:39:53.900993	2023-02-22 04:39:53.900993	Over	{}
4963	1.5	3.50	659	Full Time	100.0%	2023-02-22 04:39:53.902856	2023-02-22 04:39:53.902856	Under	{}
4966	2.5	2.18	659	Full Time	102.4%	2023-02-22 04:39:53.909479	2023-02-22 04:39:53.909479	Over	{}
4964	2.25	1.88	659	Full Time	96.4%	2023-02-22 04:39:53.905023	2023-02-22 04:39:53.905023	Over	{}
4965	2.25	1.98	659	Full Time	96.4%	2023-02-22 04:39:53.906998	2023-02-22 04:39:53.906998	Under	{}
4967	2.5	1.93	659	Full Time	102.4%	2023-02-22 04:39:53.910842	2023-02-22 04:39:53.910842	Under	{}
4968	3.5	4.20	659	Full Time	101.0%	2023-02-22 04:39:53.911754	2023-02-22 04:39:53.911754	Over	{}
4969	3.5	1.33	659	Full Time	101.0%	2023-02-22 04:39:53.912839	2023-02-22 04:39:53.912839	Under	{}
4970	4.5	9.00	659	Full Time	98.8%	2023-02-22 04:39:53.913879	2023-02-22 04:39:53.913879	Over	{}
4971	4.5	1.11	659	Full Time	98.8%	2023-02-22 04:39:53.916796	2023-02-22 04:39:53.916796	Under	{}
4972	5.5	14.50	659	Full Time	97.0%	2023-02-22 04:39:53.917959	2023-02-22 04:39:53.917959	Over	{}
4973	5.5	1.04	659	Full Time	97.0%	2023-02-22 04:39:53.91916	2023-02-22 04:39:53.91916	Under	{}
4974	6.5	29.00	659	Full Time	97.6%	2023-02-22 04:39:53.920459	2023-02-22 04:39:53.920459	Over	{}
4975	0.5	1.44	659	1st Half	94.5%	2023-02-22 04:39:55.454538	2023-02-22 04:39:55.454538	Over	{}
4976	0.5	2.75	659	1st Half	94.5%	2023-02-22 04:39:57.176598	2023-02-22 04:39:57.176598	Under	{}
4977	1.0	1.85	659	1st Half	94.9%	2023-02-22 04:39:57.178886	2023-02-22 04:39:57.178886	Over	{}
4978	1.0	1.95	659	1st Half	94.9%	2023-02-22 04:39:57.179852	2023-02-22 04:39:57.179852	Under	{}
4979	1.5	3.20	659	1st Half	97.4%	2023-02-22 04:39:57.180866	2023-02-22 04:39:57.180866	Over	{}
4980	1.5	1.40	659	1st Half	97.4%	2023-02-22 04:39:57.181782	2023-02-22 04:39:57.181782	Under	{}
4981	2.5	8.00	659	1st Half	95.2%	2023-02-22 04:39:57.182661	2023-02-22 04:39:57.182661	Over	{}
4982	2.5	1.08	659	1st Half	95.2%	2023-02-22 04:39:57.183742	2023-02-22 04:39:57.183742	Under	{}
4983	3.5	21.00	659	1st Half	97.3%	2023-02-22 04:39:57.184667	2023-02-22 04:39:57.184667	Over	{}
4984	3.5	1.02	659	1st Half	97.3%	2023-02-22 04:39:57.185682	2023-02-22 04:39:57.185682	Under	{}
4985	4.5	56.00	659	1st Half	98.2%	2023-02-22 04:39:57.186657	2023-02-22 04:39:57.186657	Over	{}
4986	0.5	1.36	659	2nd Half	99.8%	2023-02-22 04:39:59.495627	2023-02-22 04:39:59.495627	Over	{}
4988	1.5	2.40	659	2nd Half	96.7%	2023-02-22 04:40:00.562021	2023-02-22 04:40:00.562021	Over	{}
4989	1.5	1.62	659	2nd Half	96.7%	2023-02-22 04:40:00.562997	2023-02-22 04:40:00.562997	Under	{}
4990	2.5	5.50	659	2nd Half	96.5%	2023-02-22 04:40:00.563982	2023-02-22 04:40:00.563982	Over	{}
4928	1.5	1.50	656	Full Time	94.4%	2023-02-22 04:39:34.462577	2023-02-22 04:39:34.462577	Over	{}
4932	2.5	2.60	656	Full Time	95.9%	2023-02-22 04:39:34.470936	2023-02-22 04:39:34.470936	Over	{}
4933	2.5	1.52	656	Full Time	95.9%	2023-02-22 04:39:34.472102	2023-02-22 04:39:34.472102	Under	{}
4934	3.5	5.30	656	Full Time	95.8%	2023-02-22 04:39:34.473397	2023-02-22 04:39:34.473397	Over	{}
4935	3.5	1.17	656	Full Time	95.8%	2023-02-22 04:39:34.474547	2023-02-22 04:39:34.474547	Under	{}
4938	5.5	26.00	656	Full Time	97.2%	2023-02-22 04:39:34.479312	2023-02-22 04:39:34.479312	Over	{}
4939	5.5	1.01	656	Full Time	97.2%	2023-02-22 04:39:34.480655	2023-02-22 04:39:34.480655	Under	{}
4931	2.25	1.71	656	Full Time	96.0%	2023-02-22 04:39:34.469352	2023-02-22 04:39:34.469352	Under	{}
4991	2.5	1.17	659	2nd Half	96.5%	2023-02-22 04:40:00.565235	2023-02-22 04:40:00.565235	Under	{}
4992	3.5	13.00	659	2nd Half	96.3%	2023-02-22 04:40:00.566324	2023-02-22 04:40:00.566324	Over	{}
4993	3.5	1.04	659	2nd Half	96.3%	2023-02-22 04:40:00.567494	2023-02-22 04:40:00.567494	Under	{}
4913	2.5	11.00	653	1st Half	96.7%	2023-02-22 04:39:19.650341	2023-02-22 04:39:19.650341	Over	{}
4926	0.5	1.11	656	Full Time	96.7%	2023-02-22 04:39:34.456689	2023-02-22 04:39:34.456689	Over	{}
5210	2.0	1.93	656	Full Time	96.5%	2023-02-22 15:27:08.214162	2023-02-22 15:27:08.214162	Over	{}
5211	2.0	1.93	656	Full Time	96.5%	2023-02-22 15:27:08.216778	2023-02-22 15:27:08.216778	Under	{}
4956	2.5	6.50	656	2nd Half	94.8%	2023-02-22 04:39:40.969035	2023-02-22 04:39:40.969035	Over	{}
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
4927	0.5	7.50	656	Full Time	96.7%	2023-02-22 04:39:34.460428	2023-02-22 04:39:34.460428	Under	{}
\.


--
-- TOC entry 3099 (class 0 OID 24822)
-- Dependencies: 204
-- Data for Name: OddsSafariMatch; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."OddsSafariMatch" (id, home_team, guest_team, date_time, created, updated) FROM stdin;
638	Ionikos	OFI	2023-02-26 16:00:00+02	2023-02-18 05:17:41.314011	2023-02-18 05:17:41.314011
639	Levadiakos	Panetolikos	2023-02-26 16:00:00+02	2023-02-18 05:18:05.279829	2023-02-18 05:18:05.279829
640	Aris Salonika	Atromitos	2023-02-26 19:30:00+02	2023-02-18 05:18:28.578351	2023-02-18 05:18:28.578351
\.


--
-- TOC entry 3100 (class 0 OID 24836)
-- Dependencies: 205
-- Data for Name: OddsSafariOverUnder; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."OddsSafariOverUnder" (id, goals, odds, match_id, half, payout, created, updated, type, bet_links) FROM stdin;
4738	2.5	2.30	638	Full Time	4.26%	2023-02-18 05:17:50.936548	2023-02-18 05:17:50.936548	Over	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
4739	2.5	1.64	638	Full Time	4.26%	2023-02-18 05:17:50.939608	2023-02-18 05:17:50.939608	Under	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
4740	0.5	1.57	638	1st Half	2.11%	2023-02-18 05:17:56.215004	2023-02-18 05:17:56.215004	Over	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
4741	0.5	2.60	638	1st Half	2.11%	2023-02-18 05:17:56.217966	2023-02-18 05:17:56.217966	Under	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
4742	0.5	1.57	638	2nd Half	2.11%	2023-02-18 05:18:01.96025	2023-02-18 05:18:01.96025	Over	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
4743	0.5	2.60	638	2nd Half	2.11%	2023-02-18 05:18:01.974227	2023-02-18 05:18:01.974227	Under	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
4750	2.5	2.60	640	Full Time	1.72%	2023-02-18 05:18:38.124823	2023-02-18 05:18:38.124823	Over	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
4744	2.5	2.60	639	Full Time	1.72%	2023-02-18 05:18:14.665499	2023-02-18 05:18:14.665499	Over	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
4745	2.5	1.58	639	Full Time	1.72%	2023-02-18 05:18:14.670694	2023-02-18 05:18:14.670694	Under	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
4746	0.5	1.60	639	1st Half	3.21%	2023-02-18 05:18:20.486493	2023-02-18 05:18:20.486493	Over	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
4747	0.5	2.45	639	1st Half	3.21%	2023-02-18 05:18:20.495336	2023-02-18 05:18:20.495336	Under	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
4748	0.5	1.37	639	2nd Half	3.63%	2023-02-18 05:18:25.349735	2023-02-18 05:18:25.349735	Over	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
4749	0.5	3.25	639	2nd Half	3.63%	2023-02-18 05:18:25.352631	2023-02-18 05:18:25.352631	Under	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
4751	2.5	1.58	640	Full Time	1.72%	2023-02-18 05:18:38.129016	2023-02-18 05:18:38.129016	Under	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
4752	0.5	1.60	640	1st Half	3.21%	2023-02-18 05:18:44.197585	2023-02-18 05:18:44.197585	Over	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
4753	0.5	2.45	640	1st Half	3.21%	2023-02-18 05:18:44.203761	2023-02-18 05:18:44.203761	Under	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
4754	0.5	1.37	640	2nd Half	3.63%	2023-02-18 05:18:50.132981	2023-02-18 05:18:50.132981	Over	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
4755	0.5	3.25	640	2nd Half	3.63%	2023-02-18 05:18:50.137232	2023-02-18 05:18:50.137232	Under	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
\.


--
-- TOC entry 3106 (class 0 OID 25135)
-- Dependencies: 213
-- Data for Name: OverUnderHistorical; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."OverUnderHistorical" (id, "Date_Time", "Home_Team", "Guest_Team", "Type", "Half", "Odds_bet", "Margin", won, "Goals", "Home_Team_Goals", "Guest_Team_Goals", "Home_Team_Goals_1st_Half", "Home_Team_Goals_2nd_Half", "Guest_Team_Goals_1st_Half", "Guest_Team_Goals_2nd_Half", "Payout", "Bet_link") FROM stdin;
1	2023-02-18 17:00:00+02	Panathinaikos	Volos	Over	\N	2.17	0	\N	2.5	2	0	0	2	0	0	0.72%	{https://record.affiliates.betshop.gr/_xVrm1kU5pcRLcRLGwHoTKWNd7ZgqdRLk/1/}
37	2023-02-24 20:00:00+02	Volos	Lamia	Over	Full Time	2.15	0.1	\N	2.5	1	1	0	1	1	0	1.73%	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
38	2023-02-24 20:00:00+02	Volos	Lamia	Over	Full Time	2.15	0	\N	2.5	1	1	0	1	1	0	1.73%	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
40	2023-02-24 20:00:00+02	Volos	Lamia	Under	1st Half	2.9	0	\N	0.5	1	1	0	1	1	0	1.14%	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
41	2023-02-24 20:00:00+02	Volos	Lamia	Under	2nd Half	3.75	0	\N	0.5	1	1	0	1	1	0	4.02%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
42	2023-02-24 20:00:00+02	Volos	Lamia	Under	2nd Half	3.75	0	\N	0.5	1	1	0	1	1	0	4.02%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
43	2023-02-24 20:00:00+02	Volos	Lamia	Under	1st Half	1.81	0.73	\N	2.5	1	1	0	1	1	0	1.73%	{https://partners.opapaffiliates.gr/redirect.aspx?pid=2460&bid=1759}
45	2023-02-24 20:00:00+02	Volos	Lamia	Under	1st Half	1.81	0	\N	2.5	1	1	0	1	1	0	1.73%	{https://partners.opapaffiliates.gr/redirect.aspx?pid=2460&bid=1759}
20	2023-02-19 19:30:00+02	Panetolikos	Ionikos	Under	\N	3.25	0	\N	0.5	1	0	0	1	0	0	3.63%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
11	2023-02-19 16:00:00+02	Lamia	Olympiacos	Under	\N	2.95	0	\N	0.5	0	3	0	0	1	2	2.78%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
12	2023-02-19 16:00:00+02	Lamia	Olympiacos	Under	\N	3.9	0.95	\N	0.5	0	3	0	0	1	2	4.20%	{}
2	2023-02-18 17:00:00+02	Panathinaikos	Volos	Under	\N	2.8	0	\N	0.5	2	0	0	2	0	0	2.33%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
3	2023-02-18 17:00:00+02	Panathinaikos	Volos	Under	\N	3.7	0.9	\N	0.5	2	0	0	2	0	0	3.80%	{}
4	2023-02-18 17:00:00+02	Panathinaikos	Volos	Under	\N	3.7	0	\N	0.5	2	0	0	2	0	0	3.80%	{}
5	2023-02-18 17:00:00+02	Panathinaikos	Volos	Under	\N	1.83	0	\N	2.5	2	0	0	2	0	0	0.72%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
44	2023-02-24 20:00:00+02	Volos	Lamia	Under	Full Time	1.81	0	Won	2.5	1	1	0	1	1	0	1.73%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
10	2023-02-19 16:00:00+02	Lamia	Olympiacos	Over	\N	2	0	Won	2.5	0	3	0	0	1	2	2.56%	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/,https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
6	2023-02-18 20:00:00+02	Asteras Tripolis	PAS Giannina	Over	\N	2.55	0	\N	2.5	1	1	1	0	1	0	2.07%	{https://record.affiliates.betshop.gr/_xVrm1kU5pcRLcRLGwHoTKWNd7ZgqdRLk/1/}
7	2023-02-18 20:00:00+02	Asteras Tripolis	PAS Giannina	Under	\N	2.45	0	\N	0.5	1	1	1	0	1	0	3.21%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
39	2023-02-24 20:00:00+02	Volos	Lamia	Over	1st Half	2.15	0	Won	2.5	1	1	0	1	1	0	1.73%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
8	2023-02-18 20:00:00+02	Asteras Tripolis	PAS Giannina	Under	\N	3.25	0.8	\N	0.5	1	1	1	0	1	0	3.63%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
9	2023-02-18 20:00:00+02	Asteras Tripolis	PAS Giannina	Under	\N	3.25	0	\N	0.5	1	1	1	0	1	0	3.63%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
15	2023-02-19 19:30:00+02	Panetolikos	Ionikos	Over	\N	2.5	0	\N	2.5	1	0	0	1	0	0	1.70%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107,https://partners.opapaffiliates.gr/redirect.aspx?pid=2460&bid=1759,https://record.affiliates.betshop.gr/_xVrm1kU5pcRLcRLGwHoTKWNd7ZgqdRLk/1/}
16	2023-02-19 19:30:00+02	Panetolikos	Ionikos	Over	\N	2.5	0	\N	2.5	1	0	0	1	0	0	1.70%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107,https://partners.opapaffiliates.gr/redirect.aspx?pid=2460&bid=1759,https://record.affiliates.betshop.gr/_xVrm1kU5pcRLcRLGwHoTKWNd7ZgqdRLk/1/}
26	2023-02-20 18:00:00+02	Atromitos	Levadiakos	Over	\N	2.4	0	\N	2.5	1	0	1	0	0	0	3.46%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
27	2023-02-20 18:00:00+02	Atromitos	Levadiakos	Under	\N	2.55	0.05	\N	0.5	1	0	1	0	0	0	2.83%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
54	2023-02-25 20:30:00+02	Olympiacos	Panathinaikos	Over	Full Time	2.15	0	\N	2.5	0	0	0	0	0	0	3.83%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
50	2023-02-25 19:00:00+02	PAS Giannina	PAOK	Over	Full Time	1.76	0	\N	2.5	0	0	0	0	0	0	4.25%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
51	2023-02-25 19:00:00+02	PAS Giannina	PAOK	Under	1st Half	3.3	0	\N	0.5	0	0	0	0	0	0	2.69%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
52	2023-02-25 19:00:00+02	PAS Giannina	PAOK	Under	2nd Half	4.4	0	\N	0.5	0	0	0	0	0	0	4.36%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
28	2023-02-20 18:00:00+02	Atromitos	Levadiakos	Under	\N	3.4	0.9	\N	0.5	1	0	1	0	0	0	4.40%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
29	2023-02-20 18:00:00+02	Atromitos	Levadiakos	Under	\N	2.55	0	\N	0.5	1	0	1	0	0	0	2.83%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
46	2023-02-25 17:30:00+02	AEK	Asteras Tripolis	Over	Full Time	1.76	0	\N	2.5	2	0	1	1	0	0	4.25%	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
30	2023-02-20 18:00:00+02	Atromitos	Levadiakos	Under	\N	3.4	0.85	\N	0.5	1	0	1	0	0	0	4.40%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
17	2023-02-19 19:30:00+02	Panetolikos	Ionikos	Under	\N	2.45	0	\N	0.5	1	0	0	1	0	0	3.21%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
18	2023-02-19 19:30:00+02	Panetolikos	Ionikos	Under	\N	3.25	0.8	\N	0.5	1	0	0	1	0	0	3.63%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
31	2023-02-20 18:00:00+02	Atromitos	Levadiakos	Under	\N	3.4	0	\N	0.5	1	0	1	0	0	0	4.40%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
22	2023-02-19 20:30:00+02	PAOK	AEK	Over	\N	2.45	0	\N	2.5	2	0	1	1	0	0	2.48%	{https://record.affiliates.betshop.gr/_xVrm1kU5pcRLcRLGwHoTKWNd7ZgqdRLk/1/}
23	2023-02-19 20:30:00+02	PAOK	AEK	Under	\N	2.5	0	\N	0.5	2	0	1	1	0	0	2.44%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
13	2023-02-19 16:00:00+02	Lamia	Olympiacos	Under	\N	3.9	0	\N	0.5	0	3	0	0	1	2	4.20%	{}
14	2023-02-19 16:00:00+02	Lamia	Olympiacos	Under	\N	1.9	0	\N	2.5	0	3	0	0	1	2	2.56%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
47	2023-02-25 17:30:00+02	AEK	Asteras Tripolis	Under	1st Half	3.3	0	\N	0.5	2	0	1	1	0	0	2.69%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
48	2023-02-25 17:30:00+02	AEK	Asteras Tripolis	Under	2nd Half	4.4	0	\N	0.5	2	0	1	1	0	0	4.36%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
24	2023-02-19 20:30:00+02	PAOK	AEK	Under	\N	3.25	0.75	\N	0.5	2	0	1	1	0	0	5.47%	{http://www.stoiximan.gr/,https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
25	2023-02-19 20:30:00+02	PAOK	AEK	Under	\N	3.25	0	\N	0.5	2	0	1	1	0	0	5.47%	{http://www.stoiximan.gr/,https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
53	2023-02-25 19:00:00+02	PAS Giannina	PAOK	Under	Full Time	2.1	0	Won	2.5	0	0	0	0	0	0	4.25%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
49	2023-02-25 17:30:00+02	AEK	Asteras Tripolis	Under	Full Time	2.1	0	Won	2.5	2	0	1	1	0	0	4.25%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
33	2023-02-20 19:30:00+02	OFI	Aris Salonika	Over	\N	2.4	0	Won	2.5	0	3	0	0	2	1	3.28%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
34	2023-02-20 19:30:00+02	OFI	Aris Salonika	Under	\N	2.6	0	\N	0.5	0	3	0	0	2	1	2.89%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
35	2023-02-20 19:30:00+02	OFI	Aris Salonika	Under	\N	3.4	0.8	\N	0.5	0	3	0	0	2	1	4.40%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
36	2023-02-20 19:30:00+02	OFI	Aris Salonika	Under	\N	3.4	0	\N	0.5	0	3	0	0	2	1	4.40%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
55	2023-02-25 20:30:00+02	Olympiacos	Panathinaikos	Under	1st Half	2.8	0	\N	0.5	0	0	0	0	0	0	1.48%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
56	2023-02-25 20:30:00+02	Olympiacos	Panathinaikos	Under	2nd Half	3.75	0	\N	0.5	0	0	0	0	0	0	3.47%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
32	2023-02-20 18:00:00+02	Atromitos	Levadiakos	Under	\N	3.4	0	\N	0.5	1	0	1	0	0	0	4.40%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
19	2023-02-19 19:30:00+02	Panetolikos	Ionikos	Under	\N	3.25	0.75	\N	0.5	1	0	0	1	0	0	3.63%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
21	2023-02-19 19:30:00+02	Panetolikos	Ionikos	Under	\N	3.25	0	\N	0.5	1	0	0	1	0	0	3.63%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
57	2023-02-25 20:30:00+02	Olympiacos	Panathinaikos	Under	Full Time	1.74	0	Won	2.5	0	0	0	0	0	0	3.83%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107,https://partners.opapaffiliates.gr/redirect.aspx?pid=2460&bid=1759}
\.


--
-- TOC entry 3102 (class 0 OID 25038)
-- Dependencies: 209
-- Data for Name: soccer_statistics; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.soccer_statistics (id, home_team, guest_team, date_time, goals_home, goals_guest, full_time_home_win_odds, full_time_draw_odds, full_time_guest_win_odds, fisrt_half_home_win_odds, first_half_draw_odds, second_half_goals_guest, second_half_goals_home, first_half_goals_guest, first_half_goals_home, first_half_guest_win_odds, second_half_home_win_odds, second_half_draw_odds, second_half_guest_win_odds, full_time_over_under_goals, full_time_over_odds, full_time_under_odds, full_time_payout, first_half_over_under_goals, first_half_over_odds, firt_half_under_odds, first_half_payout, second_half_over_under_goals, second_half_over_odds, second_half_under_odds, second_half_payout, last_updated) FROM stdin;
\.


--
-- TOC entry 3128 (class 0 OID 0)
-- Dependencies: 210
-- Name: 1x2_oddsportal_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."1x2_oddsportal_id_seq"', 1, false);


--
-- TOC entry 3129 (class 0 OID 0)
-- Dependencies: 201
-- Name: Match_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."Match_id_seq"', 949, true);


--
-- TOC entry 3130 (class 0 OID 0)
-- Dependencies: 212
-- Name: OverUnderHistorical_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."OverUnderHistorical_id_seq"', 1, false);


--
-- TOC entry 3131 (class 0 OID 0)
-- Dependencies: 203
-- Name: OverUnder_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."OverUnder_id_seq"', 8460, true);


--
-- TOC entry 3132 (class 0 OID 0)
-- Dependencies: 208
-- Name: soccer_statistics_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.soccer_statistics_id_seq', 1, false);


--
-- TOC entry 2954 (class 2606 OID 25112)
-- Name: 1x2_oddsportal 1x2_oddsportal_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."1x2_oddsportal"
    ADD CONSTRAINT "1x2_oddsportal_pkey" PRIMARY KEY (id);


--
-- TOC entry 2956 (class 2606 OID 25114)
-- Name: 1x2_oddsportal 1x2_oddsportal_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."1x2_oddsportal"
    ADD CONSTRAINT "1x2_oddsportal_unique" UNIQUE (date_time, home_team, guest_team, half);


--
-- TOC entry 2933 (class 2606 OID 24734)
-- Name: OddsPortalMatch OddsPortalMatch_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsPortalMatch"
    ADD CONSTRAINT "OddsPortalMatch_pk" PRIMARY KEY (id);


--
-- TOC entry 2935 (class 2606 OID 24736)
-- Name: OddsPortalMatch OddsPortalMatch_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsPortalMatch"
    ADD CONSTRAINT "OddsPortalMatch_unique" UNIQUE (home_team, guest_team, date_time);


--
-- TOC entry 2937 (class 2606 OID 24804)
-- Name: OddsPortalOverUnder OddsPortalOverUnder_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsPortalOverUnder"
    ADD CONSTRAINT "OddsPortalOverUnder_pk" PRIMARY KEY (id, match_id, half, type, goals);


--
-- TOC entry 2939 (class 2606 OID 24862)
-- Name: OddsPortalOverUnder OddsPortalOverUnder_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsPortalOverUnder"
    ADD CONSTRAINT "OddsPortalOverUnder_unique" UNIQUE (goals, match_id, half, type);


--
-- TOC entry 2942 (class 2606 OID 24833)
-- Name: OddsSafariMatch OddsSafariMatch_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsSafariMatch"
    ADD CONSTRAINT "OddsSafariMatch_pk" PRIMARY KEY (id);


--
-- TOC entry 2944 (class 2606 OID 24835)
-- Name: OddsSafariMatch OddsSafariMatch_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsSafariMatch"
    ADD CONSTRAINT "OddsSafariMatch_unique" UNIQUE (home_team, guest_team, date_time);


--
-- TOC entry 2946 (class 2606 OID 24846)
-- Name: OddsSafariOverUnder OddsSafariOverUnder_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsSafariOverUnder"
    ADD CONSTRAINT "OddsSafariOverUnder_pk" PRIMARY KEY (id);


--
-- TOC entry 2948 (class 2606 OID 24848)
-- Name: OddsSafariOverUnder OddsSafariOverUnder_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsSafariOverUnder"
    ADD CONSTRAINT "OddsSafariOverUnder_unique" UNIQUE (goals, match_id, half, type);


--
-- TOC entry 2958 (class 2606 OID 25143)
-- Name: OverUnderHistorical OverUnderHistorical_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OverUnderHistorical"
    ADD CONSTRAINT "OverUnderHistorical_pkey" PRIMARY KEY (id);


--
-- TOC entry 2952 (class 2606 OID 25047)
-- Name: soccer_statistics soccer_statistics_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.soccer_statistics
    ADD CONSTRAINT soccer_statistics_pkey PRIMARY KEY (id);


--
-- TOC entry 2940 (class 1259 OID 24995)
-- Name: fki_OddsPortalOverUnder_Match_fk; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "fki_OddsPortalOverUnder_Match_fk" ON public."OddsPortalOverUnder" USING btree (match_id);


--
-- TOC entry 2949 (class 1259 OID 24860)
-- Name: fki_OddsSafariOverUnder_Match_fk; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "fki_OddsSafariOverUnder_Match_fk" ON public."OddsSafariOverUnder" USING btree (match_id);


--
-- TOC entry 2950 (class 1259 OID 24854)
-- Name: fki_OddsSafariOverUnder_match_id_fk; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "fki_OddsSafariOverUnder_match_id_fk" ON public."OddsSafariOverUnder" USING btree (match_id);


--
-- TOC entry 2961 (class 2620 OID 24783)
-- Name: OddsPortalOverUnder update_updated_Match_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER "update_updated_Match_trigger" AFTER UPDATE ON public."OddsPortalOverUnder" FOR EACH ROW EXECUTE FUNCTION public."update_updated_on_Match"();


--
-- TOC entry 2962 (class 2620 OID 24782)
-- Name: OddsPortalOverUnder update_updated_OverUnder_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER "update_updated_OverUnder_trigger" AFTER UPDATE ON public."OddsPortalOverUnder" FOR EACH ROW EXECUTE FUNCTION public."update_updated_on_OverUnder"();


--
-- TOC entry 2959 (class 2606 OID 24990)
-- Name: OddsPortalOverUnder OddsPortalOverUnder_Match_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsPortalOverUnder"
    ADD CONSTRAINT "OddsPortalOverUnder_Match_fk" FOREIGN KEY (match_id) REFERENCES public."OddsPortalMatch"(id) ON UPDATE CASCADE ON DELETE CASCADE NOT VALID;


--
-- TOC entry 2960 (class 2606 OID 24985)
-- Name: OddsSafariOverUnder OddsSafariOverUnder_Match_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsSafariOverUnder"
    ADD CONSTRAINT "OddsSafariOverUnder_Match_fk" FOREIGN KEY (match_id) REFERENCES public."OddsSafariMatch"(id) ON UPDATE CASCADE ON DELETE CASCADE NOT VALID;


--
-- TOC entry 3114 (class 0 OID 0)
-- Dependencies: 211
-- Name: TABLE "1x2_oddsportal"; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE public."1x2_oddsportal" FROM postgres;
GRANT ALL ON TABLE public."1x2_oddsportal" TO postgres WITH GRANT OPTION;


--
-- TOC entry 3116 (class 0 OID 0)
-- Dependencies: 200
-- Name: TABLE "OddsPortalMatch"; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE public."OddsPortalMatch" FROM postgres;


--
-- TOC entry 3118 (class 0 OID 0)
-- Dependencies: 202
-- Name: TABLE "OddsPortalOverUnder"; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE public."OddsPortalOverUnder" FROM postgres;
GRANT ALL ON TABLE public."OddsPortalOverUnder" TO postgres WITH GRANT OPTION;


--
-- TOC entry 3119 (class 0 OID 0)
-- Dependencies: 204
-- Name: TABLE "OddsSafariMatch"; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE public."OddsSafariMatch" FROM postgres;
GRANT ALL ON TABLE public."OddsSafariMatch" TO postgres WITH GRANT OPTION;


--
-- TOC entry 3120 (class 0 OID 0)
-- Dependencies: 205
-- Name: TABLE "OddsSafariOverUnder"; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE public."OddsSafariOverUnder" FROM postgres;
GRANT ALL ON TABLE public."OddsSafariOverUnder" TO postgres WITH GRANT OPTION;


--
-- TOC entry 3121 (class 0 OID 0)
-- Dependencies: 213
-- Name: TABLE "OverUnderHistorical"; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE public."OverUnderHistorical" FROM postgres;
GRANT ALL ON TABLE public."OverUnderHistorical" TO postgres WITH GRANT OPTION;


--
-- TOC entry 3124 (class 0 OID 0)
-- Dependencies: 206
-- Name: TABLE "PortalSafariMatch"; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE public."PortalSafariMatch" FROM postgres;
GRANT ALL ON TABLE public."PortalSafariMatch" TO postgres WITH GRANT OPTION;


--
-- TOC entry 3125 (class 0 OID 0)
-- Dependencies: 207
-- Name: TABLE "PortalSafariBets"; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE public."PortalSafariBets" FROM postgres;
GRANT ALL ON TABLE public."PortalSafariBets" TO postgres WITH GRANT OPTION;


--
-- TOC entry 3126 (class 0 OID 0)
-- Dependencies: 209
-- Name: TABLE soccer_statistics; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE public.soccer_statistics FROM postgres;
GRANT ALL ON TABLE public.soccer_statistics TO postgres WITH GRANT OPTION;


--
-- TOC entry 1771 (class 826 OID 24717)
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: -; Owner: -
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres REVOKE ALL ON TABLES  FROM postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres GRANT ALL ON TABLES  TO postgres WITH GRANT OPTION;


-- Completed on 2023-02-26 10:44:44 EET

--
-- PostgreSQL database dump complete
--


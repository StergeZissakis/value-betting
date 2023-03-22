--
-- PostgreSQL database dump
--

-- Dumped from database version 13.9 (Debian 13.9-0+deb11u1)
-- Dumped by pg_dump version 13.9 (Debian 13.9-0+deb11u1)

-- Started on 2023-03-22 05:15:06 EET

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
-- TOC entry 3113 (class 1262 OID 13445)
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
-- TOC entry 3114 (class 0 OID 0)
-- Dependencies: 3113
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
-- TOC entry 3116 (class 0 OID 0)
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
-- TOC entry 3118 (class 0 OID 0)
-- Dependencies: 201
-- Name: Match_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."Match_id_seq" OWNED BY public."OddsPortalMatch".id;


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
-- TOC entry 202 (class 1259 OID 24726)
-- Name: OddsPortalOverUnder; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."OddsPortalOverUnder" (
    id bigint DEFAULT nextval('public."OverUnder_id_seq"'::regclass) NOT NULL,
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
-- TOC entry 213 (class 1259 OID 25135)
-- Name: OverUnderHistorical; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."OverUnderHistorical" (
    id bigint DEFAULT nextval('public."OverUnderHistorical_id_seq"'::regclass) NOT NULL,
    "Date_Time" timestamp with time zone NOT NULL,
    "Home_Team" character varying NOT NULL,
    "Guest_Team" character varying NOT NULL,
    "Type" public."OverUnderType" NOT NULL,
    "Half" public."MatchTime",
    "Odds_bet" numeric NOT NULL,
    "Margin" numeric NOT NULL,
    won public."BetResult" DEFAULT 'Lost'::public."BetResult" NOT NULL,
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
-- TOC entry 3126 (class 0 OID 0)
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
-- TOC entry 2926 (class 2604 OID 25041)
-- Name: soccer_statistics id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.soccer_statistics ALTER COLUMN id SET DEFAULT nextval('public.soccer_statistics_id_seq'::regclass);


--
-- TOC entry 3105 (class 0 OID 25102)
-- Dependencies: 211
-- Data for Name: 1x2_oddsportal; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."1x2_oddsportal" (id, date_time, home_team, guest_team, half, "1_odds", x_odds, "2_odds", created, updated) FROM stdin;
\.


--
-- TOC entry 3096 (class 0 OID 24718)
-- Dependencies: 200
-- Data for Name: OddsPortalMatch; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."OddsPortalMatch" (id, home_team, guest_team, date_time, created, updated) FROM stdin;
\.


--
-- TOC entry 3098 (class 0 OID 24726)
-- Dependencies: 202
-- Data for Name: OddsPortalOverUnder; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."OddsPortalOverUnder" (id, goals, odds, match_id, half, payout, created, updated, type, bet_links) FROM stdin;
\.


--
-- TOC entry 3100 (class 0 OID 24822)
-- Dependencies: 204
-- Data for Name: OddsSafariMatch; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."OddsSafariMatch" (id, home_team, guest_team, date_time, created, updated) FROM stdin;
\.


--
-- TOC entry 3101 (class 0 OID 24836)
-- Dependencies: 205
-- Data for Name: OddsSafariOverUnder; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."OddsSafariOverUnder" (id, goals, odds, match_id, half, payout, created, updated, type, bet_links) FROM stdin;
\.


--
-- TOC entry 3107 (class 0 OID 25135)
-- Dependencies: 213
-- Data for Name: OverUnderHistorical; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."OverUnderHistorical" (id, "Date_Time", "Home_Team", "Guest_Team", "Type", "Half", "Odds_bet", "Margin", won, "Goals", "Home_Team_Goals", "Guest_Team_Goals", "Home_Team_Goals_1st_Half", "Home_Team_Goals_2nd_Half", "Guest_Team_Goals_1st_Half", "Guest_Team_Goals_2nd_Half", "Payout", "Bet_link") FROM stdin;
58	2023-02-26 16:00:00+02	Ionikos	OFI	Over	Full Time	2.30	0.00	Lost	2.5	0	0	0	0	0	2	4.26%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
59	2023-02-26 16:00:00+02	Ionikos	OFI	Under	2nd Half	2.60	0.00	Lost	0.5	0	0	0	0	0	2	2.11%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
60	2023-02-26 16:00:00+02	Ionikos	OFI	Under	1st Half	2.60	0.00	Lost	0.5	0	0	0	0	0	2	2.11%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
63	2023-02-26 16:00:00+02	Levadiakos	Panetolikos	Under	1st Half	2.45	0.00	Lost	0.5	0	0	0	0	0	0	3.21%	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
64	2023-02-26 16:00:00+02	Levadiakos	Panetolikos	Under	1st Half	2.45	0.00	Lost	0.5	0	0	0	0	0	0	3.21%	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
44	2023-02-24 20:00:00+02	Volos	Lamia	Under	Full Time	1.81	0	Won	2.5	1	1	0	1	1	0	1.73%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
30	2023-02-20 18:00:00+02	Atromitos	Levadiakos	Under	\N	3.4	0.85	Lost	0.5	1	1	1	0	0	0	4.40%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
74	2023-03-05 16:00:00+02	Olympiacos	Levadiakos	Under	1st Half	3.60	0.00	Lost	0.5	6	6	2	4	0	0	2.88%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
70	2023-03-04 20:00:00+02	Asteras Tripolis	Atromitos	Over	Full Time	2.30	0.00	Lost	2.5	1	1	0	1	1	0	4.61%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107,https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145,https://record.affiliates.betshop.gr/_xVrm1kU5pcRLcRLGwHoTKWNd7ZgqdRLk/1/}
71	2023-03-04 20:00:00+02	Asteras Tripolis	Atromitos	Under	1st Half	2.55	0.00	Lost	0.5	1	1	0	1	1	0	2.83%	{http://www.sportingbet.gr/,https://sports.bwin.gr/el/sports?wm=5273373,https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
72	2023-03-04 20:00:00+02	Asteras Tripolis	Atromitos	Under	2nd Half	3.40	0.00	Lost	0.5	1	1	0	1	1	0	4.40%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
31	2023-02-20 18:00:00+02	Atromitos	Levadiakos	Under	\N	3.4	0	Lost	0.5	1	1	1	0	0	0	4.40%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
32	2023-02-20 18:00:00+02	Atromitos	Levadiakos	Under	\N	3.4	0	Lost	0.5	1	1	1	0	0	0	4.40%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
21	2023-02-19 19:30:00+02	Panetolikos	Ionikos	Under	\N	3.25	0	Lost	0.5	1	1	0	1	0	0	3.63%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
10	2023-02-19 16:00:00+02	Lamia	Olympiacos	Over	\N	2	0	Won	2.5	0	0	0	0	1	2	2.56%	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/,https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
1	2023-02-18 17:00:00+02	Panathinaikos	Volos	Over	\N	2.17	0	Lost	2.5	2	2	0	2	0	0	0.72%	{https://record.affiliates.betshop.gr/_xVrm1kU5pcRLcRLGwHoTKWNd7ZgqdRLk/1/}
77	2023-03-05 17:00:00+02	PAS Giannina	Volos	Over	Full Time	2.30	0.00	Lost	2.5	0	0	0	0	0	1	3.59%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107,https://record.affiliates.betshop.gr/_xVrm1kU5pcRLcRLGwHoTKWNd7ZgqdRLk/1/}
78	2023-03-05 17:00:00+02	PAS Giannina	Volos	Under	1st Half	2.60	0.00	Lost	0.5	0	0	0	0	0	1	4.08%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436,https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
75	2023-03-05 16:00:00+02	Olympiacos	Levadiakos	Under	2nd Half	4.75	0.00	Lost	0.5	6	6	2	4	0	0	4.20%	{http://www.sportingbet.gr/,https://sports.bwin.gr/el/sports?wm=5273373}
76	2023-03-05 16:00:00+02	Olympiacos	Levadiakos	Under	Full Time	2.30	0.00	Lost	2.5	6	6	2	4	0	0	3.92%	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
33	2023-02-20 19:30:00+02	OFI	Aris Salonika	Over	\N	2.4	0	Won	2.5	0	3	0	0	2	1	3.28%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
20	2023-02-19 19:30:00+02	Panetolikos	Ionikos	Under	\N	3.25	0	Lost	0.5	1	1	0	1	0	0	3.63%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
11	2023-02-19 16:00:00+02	Lamia	Olympiacos	Under	\N	2.95	0	Lost	0.5	0	0	0	0	1	2	2.78%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
57	2023-02-25 20:30:00+02	Olympiacos	Panathinaikos	Under	Full Time	1.74	0	Won	2.5	0	0	0	0	0	0	3.83%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107,https://partners.opapaffiliates.gr/redirect.aspx?pid=2460&bid=1759}
12	2023-02-19 16:00:00+02	Lamia	Olympiacos	Under	\N	3.9	0.95	Lost	0.5	0	0	0	0	1	2	4.20%	{}
2	2023-02-18 17:00:00+02	Panathinaikos	Volos	Under	\N	2.8	0	Lost	0.5	2	2	0	2	0	0	2.33%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
3	2023-02-18 17:00:00+02	Panathinaikos	Volos	Under	\N	3.7	0.9	Lost	0.5	2	2	0	2	0	0	3.80%	{}
4	2023-02-18 17:00:00+02	Panathinaikos	Volos	Under	\N	3.7	0	Lost	0.5	2	2	0	2	0	0	3.80%	{}
5	2023-02-18 17:00:00+02	Panathinaikos	Volos	Under	\N	1.83	0	Lost	2.5	2	2	0	2	0	0	0.72%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
53	2023-02-25 19:00:00+02	PAS Giannina	PAOK	Under	Full Time	2.1	0	Won	2.5	0	0	0	0	0	0	4.25%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
49	2023-02-25 17:30:00+02	AEK	Asteras Tripolis	Under	Full Time	2.1	0	Won	2.5	2	2	1	1	0	0	4.25%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
37	2023-02-24 20:00:00+02	Volos	Lamia	Over	Full Time	2.15	0.1	Lost	2.5	1	1	0	1	1	0	1.73%	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
38	2023-02-24 20:00:00+02	Volos	Lamia	Over	Full Time	2.15	0	Lost	2.5	1	1	0	1	1	0	1.73%	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
40	2023-02-24 20:00:00+02	Volos	Lamia	Under	1st Half	2.9	0	Lost	0.5	1	1	0	1	1	0	1.14%	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
41	2023-02-24 20:00:00+02	Volos	Lamia	Under	2nd Half	3.75	0	Lost	0.5	1	1	0	1	1	0	4.02%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
50	2023-02-25 19:00:00+02	PAS Giannina	PAOK	Over	Full Time	1.76	0	Lost	2.5	0	0	0	0	0	0	4.25%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
51	2023-02-25 19:00:00+02	PAS Giannina	PAOK	Under	1st Half	3.3	0	Lost	0.5	0	0	0	0	0	0	2.69%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
46	2023-02-25 17:30:00+02	AEK	Asteras Tripolis	Over	Full Time	1.76	0	Lost	2.5	2	2	1	1	0	0	4.25%	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
47	2023-02-25 17:30:00+02	AEK	Asteras Tripolis	Under	1st Half	3.3	0	Lost	0.5	2	2	1	1	0	0	2.69%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
34	2023-02-20 19:30:00+02	OFI	Aris Salonika	Under	\N	2.6	0	Lost	0.5	0	3	0	0	2	1	2.89%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
35	2023-02-20 19:30:00+02	OFI	Aris Salonika	Under	\N	3.4	0.8	Lost	0.5	0	3	0	0	2	1	4.40%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
36	2023-02-20 19:30:00+02	OFI	Aris Salonika	Under	\N	3.4	0	Lost	0.5	0	3	0	0	2	1	4.40%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
26	2023-02-20 18:00:00+02	Atromitos	Levadiakos	Over	\N	2.4	0	Lost	2.5	1	1	1	0	0	0	3.46%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
27	2023-02-20 18:00:00+02	Atromitos	Levadiakos	Under	\N	2.55	0.05	Lost	0.5	1	1	1	0	0	0	2.83%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
80	2023-03-05 17:30:00+02	Lamia	Aris Salonika	Over	Full Time	2.09	0.00	Lost	2.5	2	2	2	0	1	0	3.00%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
81	2023-03-05 17:30:00+02	Lamia	Aris Salonika	Under	1st Half	2.90	0.00	Lost	0.5	2	2	2	0	1	0	2.45%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
79	2023-03-05 17:00:00+02	PAS Giannina	Volos	Under	2nd Half	3.40	0.00	Lost	0.5	0	0	0	0	0	1	4.40%	{http://www.sportingbet.gr/,https://sports.bwin.gr/el/sports?wm=5273373,https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/,http://www.stoiximan.gr/,https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
61	2023-02-26 16:00:00+02	Levadiakos	Panetolikos	Over	Full Time	2.60	0.00	Lost	2.5	0	0	0	0	0	0	1.72%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
62	2023-02-26 16:00:00+02	Levadiakos	Panetolikos	Over	Full Time	2.60	0.00	Lost	2.5	0	0	0	0	0	0	1.72%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
48	2023-02-25 17:30:00+02	AEK	Asteras Tripolis	Under	2nd Half	4.4	0	Lost	0.5	2	2	1	1	0	0	4.36%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
28	2023-02-20 18:00:00+02	Atromitos	Levadiakos	Under	\N	3.4	0.9	Lost	0.5	1	1	1	0	0	0	4.40%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
22	2023-02-19 20:30:00+02	PAOK	AEK	Over	\N	2.45	0	Lost	2.5	2	0	1	1	0	0	2.48%	{https://record.affiliates.betshop.gr/_xVrm1kU5pcRLcRLGwHoTKWNd7ZgqdRLk/1/}
23	2023-02-19 20:30:00+02	PAOK	AEK	Under	\N	2.5	0	Lost	0.5	2	0	1	1	0	0	2.44%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
24	2023-02-19 20:30:00+02	PAOK	AEK	Under	\N	3.25	0.75	Lost	0.5	2	0	1	1	0	0	5.47%	{http://www.stoiximan.gr/,https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
15	2023-02-19 19:30:00+02	Panetolikos	Ionikos	Over	\N	2.5	0	Lost	2.5	1	1	0	1	0	0	1.70%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107,https://partners.opapaffiliates.gr/redirect.aspx?pid=2460&bid=1759,https://record.affiliates.betshop.gr/_xVrm1kU5pcRLcRLGwHoTKWNd7ZgqdRLk/1/}
16	2023-02-19 19:30:00+02	Panetolikos	Ionikos	Over	\N	2.5	0	Lost	2.5	1	1	0	1	0	0	1.70%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107,https://partners.opapaffiliates.gr/redirect.aspx?pid=2460&bid=1759,https://record.affiliates.betshop.gr/_xVrm1kU5pcRLcRLGwHoTKWNd7ZgqdRLk/1/}
17	2023-02-19 19:30:00+02	Panetolikos	Ionikos	Under	\N	2.45	0	Lost	0.5	1	1	0	1	0	0	3.21%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
13	2023-02-19 16:00:00+02	Lamia	Olympiacos	Under	\N	3.9	0	Lost	0.5	0	0	0	0	1	2	4.20%	{}
14	2023-02-19 16:00:00+02	Lamia	Olympiacos	Under	\N	1.9	0	Lost	2.5	0	0	0	0	1	2	2.56%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
6	2023-02-18 20:00:00+02	Asteras Tripolis	PAS Giannina	Over	\N	2.55	0	Lost	2.5	1	1	1	0	1	0	2.07%	{https://record.affiliates.betshop.gr/_xVrm1kU5pcRLcRLGwHoTKWNd7ZgqdRLk/1/}
54	2023-02-25 20:30:00+02	Olympiacos	Panathinaikos	Over	Full Time	2.15	0	Lost	2.5	0	0	0	0	0	0	3.83%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
7	2023-02-18 20:00:00+02	Asteras Tripolis	PAS Giannina	Under	\N	2.45	0	Lost	0.5	1	1	1	0	1	0	3.21%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
55	2023-02-25 20:30:00+02	Olympiacos	Panathinaikos	Under	1st Half	2.8	0	Lost	0.5	0	0	0	0	0	0	1.48%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
56	2023-02-25 20:30:00+02	Olympiacos	Panathinaikos	Under	2nd Half	3.75	0	Lost	0.5	0	0	0	0	0	0	3.47%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
52	2023-02-25 19:00:00+02	PAS Giannina	PAOK	Under	2nd Half	4.4	0	Lost	0.5	0	0	0	0	0	0	4.36%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
25	2023-02-19 20:30:00+02	PAOK	AEK	Under	\N	3.25	0	Lost	0.5	2	0	1	1	0	0	5.47%	{http://www.stoiximan.gr/,https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
8	2023-02-18 20:00:00+02	Asteras Tripolis	PAS Giannina	Under	\N	3.25	0.8	Lost	0.5	1	1	1	0	1	0	3.63%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
9	2023-02-18 20:00:00+02	Asteras Tripolis	PAS Giannina	Under	\N	3.25	0	Lost	0.5	1	1	1	0	1	0	3.63%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
84	2023-03-05 19:30:00+02	OFI	AEK	Over	Full Time	2.00	0.00	Lost	2.5	0	0	0	0	1	2	1.78%	{}
85	2023-03-05 19:30:00+02	OFI	AEK	Under	1st Half	2.95	0.00	Lost	0.5	0	0	0	0	1	2	3.23%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
86	2023-03-05 19:30:00+02	OFI	AEK	Under	2nd Half	3.90	0.00	Lost	0.5	0	0	0	0	1	2	4.77%	{}
87	2023-03-05 19:30:00+02	OFI	AEK	Under	Full Time	1.93	0.00	Lost	2.5	0	0	0	0	1	2	1.78%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
82	2023-03-05 17:30:00+02	Lamia	Aris Salonika	Under	2nd Half	3.75	0.00	Lost	0.5	2	2	2	0	1	0	5.13%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
83	2023-03-05 17:30:00+02	Lamia	Aris Salonika	Under	Full Time	1.81	0.00	Lost	2.5	2	2	2	0	1	0	3.00%	{https://record.affiliates.betshop.gr/_xVrm1kU5pcRLcRLGwHoTKWNd7ZgqdRLk/1/}
29	2023-02-20 18:00:00+02	Atromitos	Levadiakos	Under	\N	2.55	0	Lost	0.5	1	1	1	0	0	0	2.83%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
18	2023-02-19 19:30:00+02	Panetolikos	Ionikos	Under	\N	3.25	0.8	Lost	0.5	1	1	0	1	0	0	3.63%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
113	2023-03-19 17:30:00+02	Volos	Olympiacos	Over	Full Time	1.78	0.00	Lost	2.5	\N	\N	\N	\N	\N	\N	1.61%	{}
100	2023-03-18 17:00:00+02	Asteras Tripolis	Panetolikos	Over	Full Time	2.52	0.00	Lost	2.5	\N	\N	\N	\N	\N	\N	2.14%	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
101	2023-03-18 17:00:00+02	Asteras Tripolis	Panetolikos	Under	1st Half	2.50	0.00	Lost	0.5	\N	\N	\N	\N	\N	\N	3.56%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
102	2023-03-18 17:00:00+02	Asteras Tripolis	Panetolikos	Under	2nd Half	3.25	0.00	Lost	0.5	\N	\N	\N	\N	\N	\N	4.62%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
19	2023-02-19 19:30:00+02	Panetolikos	Ionikos	Under	\N	3.25	0.75	Lost	0.5	1	1	0	1	0	0	3.63%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
114	2023-03-19 17:30:00+02	Volos	Olympiacos	Over	1st Half	1.78	0.00	Lost	2.5	\N	\N	\N	\N	\N	\N	1.61%	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
94	2023-03-06 19:30:00+02	Panathinaikos	Panetolikos	Over	Full Time	2.03	0.01	Lost	2.5	2	0	0	2	0	0	4.32%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
103	2023-03-18 17:30:00+02	OFI	Levadiakos	Over	Full Time	2.45	0.00	Lost	2.5	\N	\N	\N	\N	\N	\N	-0.36%	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
73	2023-03-04 20:00:00+02	Asteras Tripolis	Atromitos	Under	2nd Half	3.40	0.00	Lost	0.5	1	1	0	1	1	0	4.40%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
67	2023-02-26 19:30:00+02	Aris Salonika	Atromitos	Over	Full Time	2.60	0.00	Lost	2.5	2	1	2	0	0	1	1.72%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
68	2023-02-26 19:30:00+02	Aris Salonika	Atromitos	Under	1st Half	2.45	0.00	Lost	0.5	2	1	2	0	0	1	3.21%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
69	2023-02-26 19:30:00+02	Aris Salonika	Atromitos	Under	2nd Half	3.25	0.00	Lost	0.5	2	1	2	0	0	1	3.63%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
65	2023-02-26 16:00:00+02	Levadiakos	Panetolikos	Under	2nd Half	3.25	0.00	Lost	0.5	0	0	0	0	0	0	3.63%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
66	2023-02-26 16:00:00+02	Levadiakos	Panetolikos	Under	2nd Half	3.25	0.00	Lost	0.5	0	0	0	0	0	0	3.63%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
95	2023-03-06 19:30:00+02	Panathinaikos	Panetolikos	Over	Full Time	2.03	0.00	Lost	2.5	2	0	0	2	0	0	4.32%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
96	2023-03-06 19:30:00+02	Panathinaikos	Panetolikos	Under	1st Half	2.95	0.00	Lost	0.5	2	0	0	2	0	0	2.78%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
97	2023-03-06 19:30:00+02	Panathinaikos	Panetolikos	Under	2nd Half	3.75	0.00	Lost	0.5	2	0	0	2	0	0	5.13%	{http://www.sportingbet.gr/,https://sports.bwin.gr/el/sports?wm=5273373,https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
98	2023-03-06 19:30:00+02	Panathinaikos	Panetolikos	Under	2nd Half	3.75	0.00	Lost	0.5	2	0	0	2	0	0	5.13%	{http://www.sportingbet.gr/,https://sports.bwin.gr/el/sports?wm=5273373,https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
88	2023-03-05 20:30:00+02	PAOK	Ionikos	Over	Full Time	1.92	0.01	Lost	2.5	6	0	4	2	0	0	3.26%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
89	2023-03-05 20:30:00+02	PAOK	Ionikos	Over	Full Time	1.92	0.00	Lost	2.5	6	0	4	2	0	0	3.26%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
90	2023-03-05 20:30:00+02	PAOK	Ionikos	Under	1st Half	3.10	0.00	Lost	0.5	6	0	4	2	0	0	2.61%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
91	2023-03-05 20:30:00+02	PAOK	Ionikos	Under	2nd Half	4.05	0.05	Lost	0.5	6	0	4	2	0	0	4.48%	{http://www.stoiximan.gr/}
92	2023-03-05 20:30:00+02	PAOK	Ionikos	Under	2nd Half	4.05	0.00	Lost	0.5	6	0	4	2	0	0	4.48%	{http://www.stoiximan.gr/}
93	2023-03-05 20:30:00+02	PAOK	Ionikos	Under	Full Time	1.95	0.00	Lost	2.5	6	0	4	2	0	0	3.26%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436,https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/,https://www.bet365.gr/olp/open-account?affiliate=365_01012107,https://record.affiliates.betshop.gr/_xVrm1kU5pcRLcRLGwHoTKWNd7ZgqdRLk/1/}
42	2023-02-24 20:00:00+02	Volos	Lamia	Under	2nd Half	3.75	0	Lost	0.5	1	1	0	1	1	0	4.02%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
43	2023-02-24 20:00:00+02	Volos	Lamia	Under	1st Half	1.81	0.73	Lost	2.5	1	1	0	1	1	0	1.73%	{https://partners.opapaffiliates.gr/redirect.aspx?pid=2460&bid=1759}
45	2023-02-24 20:00:00+02	Volos	Lamia	Under	1st Half	1.81	0	Lost	2.5	1	1	0	1	1	0	1.73%	{https://partners.opapaffiliates.gr/redirect.aspx?pid=2460&bid=1759}
99	2023-03-06 19:30:00+02	Panathinaikos	Panetolikos	Under	Full Time	1.81	0.00	Lost	2.5	2	0	0	2	0	0	4.32%	{https://record.affiliates.betshop.gr/_xVrm1kU5pcRLcRLGwHoTKWNd7ZgqdRLk/1/}
104	2023-03-18 17:30:00+02	OFI	Levadiakos	Under	1st Half	2.60	0.00	Lost	0.5	\N	\N	\N	\N	\N	\N	2.89%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
105	2023-03-18 17:30:00+02	OFI	Levadiakos	Under	2nd Half	3.25	0.00	Lost	0.5	\N	\N	\N	\N	\N	\N	5.47%	{http://www.sportingbet.gr/,https://sports.bwin.gr/el/sports?wm=5273373,https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=,https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
106	2023-03-18 17:30:00+02	OFI	Levadiakos	Under	Full Time	1.70	0.00	Lost	2.5	\N	\N	\N	\N	\N	\N	-0.36%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
107	2023-03-18 19:30:00+02	Atromitos	Ionikos	Over	Full Time	2.72	0.00	Lost	2.5	\N	\N	\N	\N	\N	\N	0.46%	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
115	2023-03-19 17:30:00+02	Volos	Olympiacos	Under	1st Half	3.45	0.00	Lost	0.5	\N	\N	\N	\N	\N	\N	1.94%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
108	2023-03-18 19:30:00+02	Atromitos	Ionikos	Under	1st Half	2.40	0.00	Lost	0.5	\N	\N	\N	\N	\N	\N	3.28%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
109	2023-03-18 19:30:00+02	Atromitos	Ionikos	Under	2nd Half	3.25	0.00	Lost	0.5	\N	\N	\N	\N	\N	\N	3.13%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
110	2023-03-18 21:00:00+02	Lamia	PAS Giannina	Over	Full Time	2.77	0.00	Lost	2.5	\N	\N	\N	\N	\N	\N	1.44%	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
111	2023-03-18 21:00:00+02	Lamia	PAS Giannina	Under	1st Half	2.45	0.00	Lost	0.5	\N	\N	\N	\N	\N	\N	1.40%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
112	2023-03-18 21:00:00+02	Lamia	PAS Giannina	Under	2nd Half	3.25	0.00	Lost	0.5	\N	\N	\N	\N	\N	\N	2.64%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
116	2023-03-19 17:30:00+02	Volos	Olympiacos	Under	2nd Half	4.47	0.00	Lost	0.5	\N	\N	\N	\N	\N	\N	5.40%	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
117	2023-03-19 17:30:00+02	Volos	Olympiacos	Under	Full Time	2.20	0.00	Lost	2.5	\N	\N	\N	\N	\N	\N	1.61%	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
118	2023-03-19 17:30:00+02	Volos	Olympiacos	Under	1st Half	2.20	0.00	Lost	2.5	\N	\N	\N	\N	\N	\N	1.61%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
119	2023-03-19 19:00:00+02	Aris Salonika	PAOK	Over	Full Time	2.55	0.00	Lost	2.5	\N	\N	\N	\N	\N	\N	0.56%	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
120	2023-03-19 19:00:00+02	Aris Salonika	PAOK	Under	1st Half	2.45	0.00	Lost	0.5	\N	\N	\N	\N	\N	\N	4.32%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
121	2023-03-19 19:00:00+02	Aris Salonika	PAOK	Under	2nd Half	3.25	0.00	Lost	0.5	\N	\N	\N	\N	\N	\N	3.63%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
122	2023-03-19 21:30:00+02	AEK	Panathinaikos	Over	Full Time	2.60	0.00	Lost	2.5	\N	\N	\N	\N	\N	\N	2.50%	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
123	2023-03-19 21:30:00+02	AEK	Panathinaikos	Under	1st Half	2.45	0.00	Lost	0.5	\N	\N	\N	\N	\N	\N	3.21%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
124	2023-03-19 21:30:00+02	AEK	Panathinaikos	Under	2nd Half	3.25	0.00	Lost	0.5	\N	\N	\N	\N	\N	\N	3.63%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
39	2023-02-24 20:00:00+02	Volos	Lamia	Over	1st Half	2.15	0	Won	2.5	1	1	0	1	1	0	1.73%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
\.


--
-- TOC entry 3103 (class 0 OID 25038)
-- Dependencies: 209
-- Data for Name: soccer_statistics; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.soccer_statistics (id, home_team, guest_team, date_time, goals_home, goals_guest, full_time_home_win_odds, full_time_draw_odds, full_time_guest_win_odds, fisrt_half_home_win_odds, first_half_draw_odds, second_half_goals_guest, second_half_goals_home, first_half_goals_guest, first_half_goals_home, first_half_guest_win_odds, second_half_home_win_odds, second_half_draw_odds, second_half_guest_win_odds, full_time_over_under_goals, full_time_over_odds, full_time_under_odds, full_time_payout, first_half_over_under_goals, first_half_over_odds, firt_half_under_odds, first_half_payout, second_half_over_under_goals, second_half_over_odds, second_half_under_odds, second_half_payout, last_updated) FROM stdin;
\.


--
-- TOC entry 3127 (class 0 OID 0)
-- Dependencies: 210
-- Name: 1x2_oddsportal_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."1x2_oddsportal_id_seq"', 1, false);


--
-- TOC entry 3128 (class 0 OID 0)
-- Dependencies: 201
-- Name: Match_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."Match_id_seq"', 1134, true);


--
-- TOC entry 3129 (class 0 OID 0)
-- Dependencies: 212
-- Name: OverUnderHistorical_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."OverUnderHistorical_id_seq"', 124, true);


--
-- TOC entry 3130 (class 0 OID 0)
-- Dependencies: 203
-- Name: OverUnder_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."OverUnder_id_seq"', 10734, true);


--
-- TOC entry 3131 (class 0 OID 0)
-- Dependencies: 208
-- Name: soccer_statistics_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.soccer_statistics_id_seq', 1, false);


--
-- TOC entry 2955 (class 2606 OID 25112)
-- Name: 1x2_oddsportal 1x2_oddsportal_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."1x2_oddsportal"
    ADD CONSTRAINT "1x2_oddsportal_pkey" PRIMARY KEY (id);


--
-- TOC entry 2957 (class 2606 OID 25114)
-- Name: 1x2_oddsportal 1x2_oddsportal_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."1x2_oddsportal"
    ADD CONSTRAINT "1x2_oddsportal_unique" UNIQUE (date_time, home_team, guest_team, half);


--
-- TOC entry 2934 (class 2606 OID 24734)
-- Name: OddsPortalMatch OddsPortalMatch_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsPortalMatch"
    ADD CONSTRAINT "OddsPortalMatch_pk" PRIMARY KEY (id);


--
-- TOC entry 2936 (class 2606 OID 24736)
-- Name: OddsPortalMatch OddsPortalMatch_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsPortalMatch"
    ADD CONSTRAINT "OddsPortalMatch_unique" UNIQUE (home_team, guest_team, date_time);


--
-- TOC entry 2938 (class 2606 OID 24804)
-- Name: OddsPortalOverUnder OddsPortalOverUnder_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsPortalOverUnder"
    ADD CONSTRAINT "OddsPortalOverUnder_pk" PRIMARY KEY (id, match_id, half, type, goals);


--
-- TOC entry 2940 (class 2606 OID 24862)
-- Name: OddsPortalOverUnder OddsPortalOverUnder_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsPortalOverUnder"
    ADD CONSTRAINT "OddsPortalOverUnder_unique" UNIQUE (goals, match_id, half, type);


--
-- TOC entry 2943 (class 2606 OID 24833)
-- Name: OddsSafariMatch OddsSafariMatch_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsSafariMatch"
    ADD CONSTRAINT "OddsSafariMatch_pk" PRIMARY KEY (id);


--
-- TOC entry 2945 (class 2606 OID 24835)
-- Name: OddsSafariMatch OddsSafariMatch_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsSafariMatch"
    ADD CONSTRAINT "OddsSafariMatch_unique" UNIQUE (home_team, guest_team, date_time);


--
-- TOC entry 2947 (class 2606 OID 24846)
-- Name: OddsSafariOverUnder OddsSafariOverUnder_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsSafariOverUnder"
    ADD CONSTRAINT "OddsSafariOverUnder_pk" PRIMARY KEY (id);


--
-- TOC entry 2949 (class 2606 OID 24848)
-- Name: OddsSafariOverUnder OddsSafariOverUnder_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsSafariOverUnder"
    ADD CONSTRAINT "OddsSafariOverUnder_unique" UNIQUE (goals, match_id, half, type);


--
-- TOC entry 2959 (class 2606 OID 25143)
-- Name: OverUnderHistorical OverUnderHistorical_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OverUnderHistorical"
    ADD CONSTRAINT "OverUnderHistorical_pkey" PRIMARY KEY (id);


--
-- TOC entry 2953 (class 2606 OID 25047)
-- Name: soccer_statistics soccer_statistics_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.soccer_statistics
    ADD CONSTRAINT soccer_statistics_pkey PRIMARY KEY (id);


--
-- TOC entry 2941 (class 1259 OID 24995)
-- Name: fki_OddsPortalOverUnder_Match_fk; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "fki_OddsPortalOverUnder_Match_fk" ON public."OddsPortalOverUnder" USING btree (match_id);


--
-- TOC entry 2950 (class 1259 OID 24860)
-- Name: fki_OddsSafariOverUnder_Match_fk; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "fki_OddsSafariOverUnder_Match_fk" ON public."OddsSafariOverUnder" USING btree (match_id);


--
-- TOC entry 2951 (class 1259 OID 24854)
-- Name: fki_OddsSafariOverUnder_match_id_fk; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "fki_OddsSafariOverUnder_match_id_fk" ON public."OddsSafariOverUnder" USING btree (match_id);


--
-- TOC entry 2962 (class 2620 OID 24783)
-- Name: OddsPortalOverUnder update_updated_Match_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER "update_updated_Match_trigger" AFTER UPDATE ON public."OddsPortalOverUnder" FOR EACH ROW EXECUTE FUNCTION public."update_updated_on_Match"();


--
-- TOC entry 2963 (class 2620 OID 24782)
-- Name: OddsPortalOverUnder update_updated_OverUnder_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER "update_updated_OverUnder_trigger" AFTER UPDATE ON public."OddsPortalOverUnder" FOR EACH ROW EXECUTE FUNCTION public."update_updated_on_OverUnder"();


--
-- TOC entry 2960 (class 2606 OID 24990)
-- Name: OddsPortalOverUnder OddsPortalOverUnder_Match_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsPortalOverUnder"
    ADD CONSTRAINT "OddsPortalOverUnder_Match_fk" FOREIGN KEY (match_id) REFERENCES public."OddsPortalMatch"(id) ON UPDATE CASCADE ON DELETE CASCADE NOT VALID;


--
-- TOC entry 2961 (class 2606 OID 24985)
-- Name: OddsSafariOverUnder OddsSafariOverUnder_Match_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsSafariOverUnder"
    ADD CONSTRAINT "OddsSafariOverUnder_Match_fk" FOREIGN KEY (match_id) REFERENCES public."OddsSafariMatch"(id) ON UPDATE CASCADE ON DELETE CASCADE NOT VALID;


--
-- TOC entry 3115 (class 0 OID 0)
-- Dependencies: 211
-- Name: TABLE "1x2_oddsportal"; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE public."1x2_oddsportal" FROM postgres;
GRANT ALL ON TABLE public."1x2_oddsportal" TO postgres WITH GRANT OPTION;


--
-- TOC entry 3117 (class 0 OID 0)
-- Dependencies: 200
-- Name: TABLE "OddsPortalMatch"; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE public."OddsPortalMatch" FROM postgres;


--
-- TOC entry 3119 (class 0 OID 0)
-- Dependencies: 202
-- Name: TABLE "OddsPortalOverUnder"; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE public."OddsPortalOverUnder" FROM postgres;
GRANT ALL ON TABLE public."OddsPortalOverUnder" TO postgres WITH GRANT OPTION;


--
-- TOC entry 3120 (class 0 OID 0)
-- Dependencies: 204
-- Name: TABLE "OddsSafariMatch"; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE public."OddsSafariMatch" FROM postgres;
GRANT ALL ON TABLE public."OddsSafariMatch" TO postgres WITH GRANT OPTION;


--
-- TOC entry 3121 (class 0 OID 0)
-- Dependencies: 205
-- Name: TABLE "OddsSafariOverUnder"; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE public."OddsSafariOverUnder" FROM postgres;
GRANT ALL ON TABLE public."OddsSafariOverUnder" TO postgres WITH GRANT OPTION;


--
-- TOC entry 3122 (class 0 OID 0)
-- Dependencies: 213
-- Name: TABLE "OverUnderHistorical"; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE public."OverUnderHistorical" FROM postgres;
GRANT ALL ON TABLE public."OverUnderHistorical" TO postgres WITH GRANT OPTION;


--
-- TOC entry 3123 (class 0 OID 0)
-- Dependencies: 206
-- Name: TABLE "PortalSafariMatch"; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE public."PortalSafariMatch" FROM postgres;
GRANT ALL ON TABLE public."PortalSafariMatch" TO postgres WITH GRANT OPTION;


--
-- TOC entry 3124 (class 0 OID 0)
-- Dependencies: 207
-- Name: TABLE "PortalSafariBets"; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE public."PortalSafariBets" FROM postgres;
GRANT ALL ON TABLE public."PortalSafariBets" TO postgres WITH GRANT OPTION;


--
-- TOC entry 3125 (class 0 OID 0)
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


-- Completed on 2023-03-22 05:15:06 EET

--
-- PostgreSQL database dump complete
--


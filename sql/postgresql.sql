--
-- PostgreSQL database dump
--

-- Dumped from database version 13.10 (Debian 13.10-0+deb11u1)
-- Dumped by pg_dump version 13.10 (Debian 13.10-0+deb11u1)

-- Started on 2023-05-08 11:33:57 EEST

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
-- TOC entry 3115 (class 1262 OID 13445)
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
-- TOC entry 3116 (class 0 OID 0)
-- Dependencies: 3115
-- Name: DATABASE postgres; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON DATABASE postgres IS 'default administrative connection database';


--
-- TOC entry 640 (class 1247 OID 16385)
-- Name: BetResult; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."BetResult" AS ENUM (
    'Won',
    'Lost'
);


--
-- TOC entry 643 (class 1247 OID 16390)
-- Name: MatchTime; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."MatchTime" AS ENUM (
    'Full Time',
    '1st Half',
    '2nd Half'
);


--
-- TOC entry 646 (class 1247 OID 16398)
-- Name: OverUnderType; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."OverUnderType" AS ENUM (
    'Over',
    'Under'
);


--
-- TOC entry 214 (class 1255 OID 16403)
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
-- TOC entry 215 (class 1255 OID 16404)
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
-- TOC entry 216 (class 1255 OID 16405)
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
-- TOC entry 217 (class 1255 OID 16406)
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
-- TOC entry 200 (class 1259 OID 16407)
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
-- TOC entry 201 (class 1259 OID 16415)
-- Name: 1x2_oddsportal_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."1x2_oddsportal_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3118 (class 0 OID 0)
-- Dependencies: 201
-- Name: 1x2_oddsportal_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."1x2_oddsportal_id_seq" OWNED BY public."1x2_oddsportal".id;


--
-- TOC entry 202 (class 1259 OID 16417)
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
-- TOC entry 203 (class 1259 OID 16425)
-- Name: Match_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."Match_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3120 (class 0 OID 0)
-- Dependencies: 203
-- Name: Match_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."Match_id_seq" OWNED BY public."OddsPortalMatch".id;


--
-- TOC entry 204 (class 1259 OID 16427)
-- Name: OverUnder_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."OverUnder_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 205 (class 1259 OID 16429)
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
-- TOC entry 206 (class 1259 OID 16438)
-- Name: OddsSafariMatch; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."OddsSafariMatch" (
)
INHERITS (public."OddsPortalMatch");


--
-- TOC entry 207 (class 1259 OID 16446)
-- Name: OddsSafariOverUnder; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."OddsSafariOverUnder" (
)
INHERITS (public."OddsPortalOverUnder");


--
-- TOC entry 208 (class 1259 OID 16455)
-- Name: OverUnderHistorical_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."OverUnderHistorical_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 209 (class 1259 OID 16457)
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
-- TOC entry 210 (class 1259 OID 16465)
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
-- TOC entry 211 (class 1259 OID 16469)
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
-- TOC entry 213 (class 1259 OID 16586)
-- Name: soccer_statistics; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.soccer_statistics (
    id bigint NOT NULL,
    home_team character varying NOT NULL,
    guest_team character varying NOT NULL,
    date_time timestamp with time zone NOT NULL,
    goals_home smallint NOT NULL,
    goals_guest smallint NOT NULL,
    full_time_home_win_odds numeric,
    full_time_draw_odds numeric,
    full_time_guest_win_odds smallint,
    first_half_home_win_odds numeric,
    first_half_draw_odds numeric,
    second_half_goals_guest smallint NOT NULL,
    second_half_goals_home smallint NOT NULL,
    first_half_goals_guest smallint NOT NULL,
    first_half_goals_home smallint NOT NULL,
    first_half_guest_win_odds numeric,
    second_half_home_win_odds numeric,
    second_half_draw_odds numeric,
    second_half_guest_win_odds numeric,
    full_time_over_under_goals numeric[],
    full_time_over_odds numeric[],
    full_time_under_odds numeric[],
    first_half_over_under_goals numeric[],
    first_half_over_odds numeric[],
    first_half_under_odds numeric[],
    second_half_over_under_goals numeric[],
    second_half_over_odds numeric[],
    second_half_under_odds numeric[],
    url character varying,
    last_updated timestamp with time zone DEFAULT now() NOT NULL
);


--
-- TOC entry 212 (class 1259 OID 16584)
-- Name: soccer_statistics_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.soccer_statistics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3128 (class 0 OID 0)
-- Dependencies: 212
-- Name: soccer_statistics_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.soccer_statistics_id_seq OWNED BY public.soccer_statistics.id;


--
-- TOC entry 2916 (class 2604 OID 16557)
-- Name: 1x2_oddsportal id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."1x2_oddsportal" ALTER COLUMN id SET DEFAULT nextval('public."1x2_oddsportal_id_seq"'::regclass);


--
-- TOC entry 2919 (class 2604 OID 16558)
-- Name: OddsPortalMatch id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsPortalMatch" ALTER COLUMN id SET DEFAULT nextval('public."Match_id_seq"'::regclass);


--
-- TOC entry 2923 (class 2604 OID 16559)
-- Name: OddsSafariMatch id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsSafariMatch" ALTER COLUMN id SET DEFAULT nextval('public."Match_id_seq"'::regclass);


--
-- TOC entry 2924 (class 2604 OID 16560)
-- Name: OddsSafariMatch created; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsSafariMatch" ALTER COLUMN created SET DEFAULT CURRENT_TIMESTAMP;


--
-- TOC entry 2925 (class 2604 OID 16561)
-- Name: OddsSafariMatch updated; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsSafariMatch" ALTER COLUMN updated SET DEFAULT CURRENT_TIMESTAMP;


--
-- TOC entry 2926 (class 2604 OID 16562)
-- Name: OddsSafariOverUnder id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsSafariOverUnder" ALTER COLUMN id SET DEFAULT nextval('public."OverUnder_id_seq"'::regclass);


--
-- TOC entry 2927 (class 2604 OID 16563)
-- Name: OddsSafariOverUnder created; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsSafariOverUnder" ALTER COLUMN created SET DEFAULT CURRENT_TIMESTAMP;


--
-- TOC entry 2928 (class 2604 OID 16564)
-- Name: OddsSafariOverUnder updated; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsSafariOverUnder" ALTER COLUMN updated SET DEFAULT CURRENT_TIMESTAMP;


--
-- TOC entry 2931 (class 2604 OID 16589)
-- Name: soccer_statistics id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.soccer_statistics ALTER COLUMN id SET DEFAULT nextval('public.soccer_statistics_id_seq'::regclass);


--
-- TOC entry 3098 (class 0 OID 16407)
-- Dependencies: 200
-- Data for Name: 1x2_oddsportal; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."1x2_oddsportal" (id, date_time, home_team, guest_team, half, "1_odds", x_odds, "2_odds", created, updated) FROM stdin;
\.


--
-- TOC entry 3100 (class 0 OID 16417)
-- Dependencies: 202
-- Data for Name: OddsPortalMatch; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."OddsPortalMatch" (id, home_team, guest_team, date_time, created, updated) FROM stdin;
2324	Aris	AEK Athens FC	2023-05-07 20:00:00+01	2023-05-02 04:03:26.765845	2023-05-02 04:03:26.765845
2327	Olympiacos Piraeus	Panathinaikos	2023-05-07 20:00:00+01	2023-05-02 04:03:29.933178	2023-05-02 04:03:29.933178
2389	Volos	PAOK	2023-05-07 20:00:00+01	2023-05-04 04:02:50.042364	2023-05-04 04:02:50.042364
2455	Aris	AEK Athens FC	2023-05-08 21:00:00+01	2023-05-07 04:00:44.873984	2023-05-07 04:00:44.873984
2458	Olympiacos Piraeus	Panathinaikos	2023-05-08 21:00:00+01	2023-05-07 04:01:06.43293	2023-05-07 04:01:06.43293
2461	Volos	PAOK	2023-05-08 21:00:00+01	2023-05-07 04:01:28.044252	2023-05-07 04:01:28.044252
2464	Panetolikos	OFI Crete	2023-05-13 20:00:00+01	2023-05-07 04:02:24.090479	2023-05-07 04:02:24.090479
1628	AEK Athens FC	Olympiacos Piraeus	2023-05-03 18:00:00+01	2023-04-29 06:02:27.924686	2023-04-29 06:02:27.924686
1631	Aris	Volos	2023-05-03 18:00:00+01	2023-04-29 06:02:43.600466	2023-04-29 06:02:43.600466
1634	Panathinaikos	PAOK	2023-05-03 18:00:00+01	2023-04-29 06:02:59.185355	2023-04-29 06:02:59.185355
1665	Atromitos	Panetolikos	2023-05-06 18:00:00+01	2023-04-30 06:02:11.124829	2023-04-30 06:02:11.124829
1668	Giannina	Asteras Tripolis	2023-05-06 18:00:00+01	2023-04-30 06:02:26.011118	2023-04-30 06:02:26.011118
1671	Lamia	Levadiakos	2023-05-06 18:00:00+01	2023-04-30 06:02:41.155153	2023-04-30 06:02:41.155153
1674	OFI Crete	Ionikos	2023-05-06 18:00:00+01	2023-04-30 06:02:55.271301	2023-04-30 06:02:55.271301
\.


--
-- TOC entry 3103 (class 0 OID 16429)
-- Dependencies: 205
-- Data for Name: OddsPortalOverUnder; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."OddsPortalOverUnder" (id, goals, odds, match_id, half, payout, created, updated, type, bet_links) FROM stdin;
16274	0.5	1.06	1628	Full Time	95.8%	2023-04-29 06:02:29.291667	2023-04-29 06:02:29.291667	Over	{}
16734	6.5	29.00	1628	Full Time	97.6%	2023-05-01 06:00:30.177132	2023-05-01 06:00:30.177132	Over	{}
16735	6.5	1.01	1628	Full Time	97.6%	2023-05-01 06:00:30.178027	2023-05-01 06:00:30.178027	Under	{}
16738	1.0	1.85	1628	1st Half	94.9%	2023-05-01 06:00:32.777456	2023-05-01 06:00:32.777456	Over	{}
16739	1.0	1.95	1628	1st Half	94.9%	2023-05-01 06:00:32.778335	2023-05-01 06:00:32.778335	Under	{}
16756	4.5	26.00	1628	2nd Half	97.2%	2023-05-01 06:00:35.321326	2023-05-01 06:00:35.321326	Over	{}
16757	4.5	1.01	1628	2nd Half	97.2%	2023-05-01 06:00:35.322322	2023-05-01 06:00:35.322322	Under	{}
16770	6.5	26.00	1631	Full Time	97.2%	2023-05-01 06:00:44.1091	2023-05-01 06:00:44.1091	Over	{}
23156	6.5	29.00	2324	Full Time	97.6%	2023-05-05 04:02:17.709773	2023-05-05 04:02:17.709773	Over	{}
23157	6.5	1.01	2324	Full Time	97.6%	2023-05-05 04:02:17.713054	2023-05-05 04:02:17.713054	Under	{}
23160	1.0	1.93	2324	1st Half	95.2%	2023-05-05 04:02:21.74103	2023-05-05 04:02:21.74103	Over	{}
23161	1.0	1.88	2324	1st Half	95.2%	2023-05-05 04:02:21.743695	2023-05-05 04:02:21.743695	Under	{}
16771	6.5	1.01	1631	Full Time	97.2%	2023-05-01 06:00:44.109984	2023-05-01 06:00:44.109984	Under	{}
16774	1.0	1.80	1631	1st Half	94.7%	2023-05-01 06:00:47.006604	2023-05-01 06:00:47.006604	Over	{}
16775	1.0	2.00	1631	1st Half	94.7%	2023-05-01 06:00:47.007474	2023-05-01 06:00:47.007474	Under	{}
16328	1.5	2.10	1631	2nd Half	94.9%	2023-04-29 06:02:50.808097	2023-04-29 06:02:50.808097	Over	{}
16792	4.5	26.00	1631	2nd Half	97.2%	2023-05-01 06:00:49.500759	2023-05-01 06:00:49.500759	Over	{}
16793	4.5	1.01	1631	2nd Half	97.2%	2023-05-01 06:00:49.501778	2023-05-01 06:00:49.501778	Under	{}
16798	2.0	1.93	1634	Full Time	96.5%	2023-05-01 06:00:58.760467	2023-05-01 06:00:58.760467	Over	{}
16799	2.0	1.93	1634	Full Time	96.5%	2023-05-01 06:00:58.761438	2023-05-01 06:00:58.761438	Under	{}
16346	0.5	1.53	1634	1st Half	94.9%	2023-04-29 06:03:02.588068	2023-04-29 06:03:02.588068	Over	{}
16810	0.75	1.82	1634	1st Half	94.8%	2023-05-01 06:01:01.397642	2023-05-01 06:01:01.397642	Over	{}
16811	0.75	1.98	1634	1st Half	94.8%	2023-05-01 06:01:01.399034	2023-05-01 06:01:01.399034	Under	{}
16582	0.5	1.08	1665	Full Time	95.2%	2023-04-30 06:02:12.508018	2023-04-30 06:02:12.508018	Over	{}
16832	2.25	1.93	1665	Full Time	96.5%	2023-05-01 06:01:12.969825	2023-05-01 06:01:12.969825	Over	{}
16833	2.25	1.93	1665	Full Time	96.5%	2023-05-01 06:01:12.971121	2023-05-01 06:01:12.971121	Under	{}
16846	1.0	2.10	1665	1st Half	93.9%	2023-05-01 06:01:16.202331	2023-05-01 06:01:16.202331	Over	{}
16847	1.0	1.70	1665	1st Half	93.9%	2023-05-01 06:01:16.203388	2023-05-01 06:01:16.203388	Under	{}
16347	0.5	2.50	1634	1st Half	94.9%	2023-04-29 06:03:03.705718	2023-04-29 06:03:03.705718	Under	{}
16348	1.5	3.75	1634	1st Half	96.0%	2023-04-29 06:03:03.708006	2023-04-29 06:03:03.708006	Over	{}
16349	1.5	1.29	1634	1st Half	96.0%	2023-04-29 06:03:03.709554	2023-04-29 06:03:03.709554	Under	{}
16350	2.5	11.00	1634	1st Half	95.9%	2023-04-29 06:03:03.711136	2023-04-29 06:03:03.711136	Over	{}
16351	2.5	1.05	1634	1st Half	95.9%	2023-04-29 06:03:03.713484	2023-04-29 06:03:03.713484	Under	{}
16352	3.5	17.00	1634	1st Half	95.3%	2023-04-29 06:03:03.715575	2023-04-29 06:03:03.715575	Over	{}
16353	3.5	1.01	1634	1st Half	95.3%	2023-04-29 06:03:03.717616	2023-04-29 06:03:03.717616	Under	{}
16354	4.5	34.00	1634	1st Half	97.1%	2023-04-29 06:03:03.71956	2023-04-29 06:03:03.71956	Over	{}
16355	4.5	1.00	1634	1st Half	97.1%	2023-04-29 06:03:03.72074	2023-04-29 06:03:03.72074	Under	{}
16356	0.5	1.36	1634	2nd Half	95.9%	2023-04-29 06:03:05.415237	2023-04-29 06:03:05.415237	Over	{}
16357	0.5	3.25	1634	2nd Half	95.9%	2023-04-29 06:03:06.41289	2023-04-29 06:03:06.41289	Under	{}
16358	1.5	2.63	1634	2nd Half	95.5%	2023-04-29 06:03:06.415248	2023-04-29 06:03:06.415248	Over	{}
16359	1.5	1.50	1634	2nd Half	95.5%	2023-04-29 06:03:06.416704	2023-04-29 06:03:06.416704	Under	{}
16360	2.5	7.00	1634	2nd Half	95.8%	2023-04-29 06:03:06.418618	2023-04-29 06:03:06.418618	Over	{}
16361	2.5	1.11	1634	2nd Half	95.8%	2023-04-29 06:03:06.420606	2023-04-29 06:03:06.420606	Under	{}
16362	3.5	19.00	1634	2nd Half	96.8%	2023-04-29 06:03:06.422755	2023-04-29 06:03:06.422755	Over	{}
16363	3.5	1.02	1634	2nd Half	96.8%	2023-04-29 06:03:06.4247	2023-04-29 06:03:06.4247	Under	{}
16583	0.5	8.00	1665	Full Time	95.2%	2023-04-30 06:02:12.512464	2023-04-30 06:02:12.512464	Under	{}
16584	1.5	1.40	1665	Full Time	95.5%	2023-04-30 06:02:12.515331	2023-04-30 06:02:12.515331	Over	{}
16585	1.5	3.00	1665	Full Time	95.5%	2023-04-30 06:02:12.517559	2023-04-30 06:02:12.517559	Under	{}
16586	2.5	2.15	1665	Full Time	94.0%	2023-04-30 06:02:12.52016	2023-04-30 06:02:12.52016	Over	{}
16587	2.5	1.67	1665	Full Time	94.0%	2023-04-30 06:02:12.522741	2023-04-30 06:02:12.522741	Under	{}
16588	3.5	3.75	1665	Full Time	93.8%	2023-04-30 06:02:12.524956	2023-04-30 06:02:12.524956	Over	{}
16589	3.5	1.25	1665	Full Time	93.8%	2023-04-30 06:02:12.527355	2023-04-30 06:02:12.527355	Under	{}
16590	4.5	9.00	1665	Full Time	96.4%	2023-04-30 06:02:12.529148	2023-04-30 06:02:12.529148	Over	{}
16591	4.5	1.08	1665	Full Time	96.4%	2023-04-30 06:02:12.530021	2023-04-30 06:02:12.530021	Under	{}
16592	5.5	19.00	1665	Full Time	96.8%	2023-04-30 06:02:12.531061	2023-04-30 06:02:12.531061	Over	{}
16593	5.5	1.02	1665	Full Time	96.8%	2023-04-30 06:02:12.53192	2023-04-30 06:02:12.53192	Under	{}
16594	6.5	41.00	1665	Full Time	97.6%	2023-04-30 06:02:12.532732	2023-04-30 06:02:12.532732	Over	{}
16595	6.5	1.00	1665	Full Time	97.6%	2023-04-30 06:02:12.533721	2023-04-30 06:02:12.533721	Under	{}
16596	0.5	1.44	1665	1st Half	94.5%	2023-04-30 06:02:14.224392	2023-04-30 06:02:14.224392	Over	{}
16597	0.5	2.75	1665	1st Half	94.5%	2023-04-30 06:02:15.377346	2023-04-30 06:02:15.377346	Under	{}
16598	1.5	3.25	1665	1st Half	95.9%	2023-04-30 06:02:15.378807	2023-04-30 06:02:15.378807	Over	{}
16599	1.5	1.36	1665	1st Half	95.9%	2023-04-30 06:02:15.380077	2023-04-30 06:02:15.380077	Under	{}
16600	2.5	10.00	1665	1st Half	96.7%	2023-04-30 06:02:15.381215	2023-04-30 06:02:15.381215	Over	{}
16601	2.5	1.07	1665	1st Half	96.7%	2023-04-30 06:02:15.382601	2023-04-30 06:02:15.382601	Under	{}
16602	3.5	26.00	1665	1st Half	97.2%	2023-04-30 06:02:15.383888	2023-04-30 06:02:15.383888	Over	{}
16603	3.5	1.01	1665	1st Half	97.2%	2023-04-30 06:02:15.385019	2023-04-30 06:02:15.385019	Under	{}
16604	4.5	61.00	1665	1st Half	98.4%	2023-04-30 06:02:15.38613	2023-04-30 06:02:15.38613	Over	{}
16605	4.5	1.00	1665	1st Half	98.4%	2023-04-30 06:02:15.387329	2023-04-30 06:02:15.387329	Under	{}
16606	0.5	1.33	1665	2nd Half	96.4%	2023-04-30 06:02:17.116543	2023-04-30 06:02:17.116543	Over	{}
16607	0.5	3.50	1665	2nd Half	96.4%	2023-04-30 06:02:18.011883	2023-04-30 06:02:18.011883	Under	{}
16608	1.5	2.30	1665	2nd Half	93.3%	2023-04-30 06:02:18.013263	2023-04-30 06:02:18.013263	Over	{}
16609	1.5	1.57	1665	2nd Half	93.3%	2023-04-30 06:02:18.014518	2023-04-30 06:02:18.014518	Under	{}
16610	2.5	5.50	1665	2nd Half	94.4%	2023-04-30 06:02:18.015767	2023-04-30 06:02:18.015767	Over	{}
16611	2.5	1.14	1665	2nd Half	94.4%	2023-04-30 06:02:18.016881	2023-04-30 06:02:18.016881	Under	{}
16612	3.5	15.00	1665	2nd Half	96.4%	2023-04-30 06:02:18.017959	2023-04-30 06:02:18.017959	Over	{}
16613	3.5	1.03	1665	2nd Half	96.4%	2023-04-30 06:02:18.019132	2023-04-30 06:02:18.019132	Under	{}
16614	0.5	1.17	1668	Full Time	94.8%	2023-04-30 06:02:27.652172	2023-04-30 06:02:27.652172	Over	{}
23182	2.25	2.05	2327	Full Time	95.8%	2023-05-05 04:02:40.34088	2023-05-05 04:02:40.34088	Over	{}
23183	2.25	1.80	2327	Full Time	95.8%	2023-05-05 04:02:40.343473	2023-05-05 04:02:40.343473	Under	{}
23192	6.5	51.00	2327	Full Time	98.1%	2023-05-05 04:02:40.363718	2023-05-05 04:02:40.363718	Over	{}
23193	6.5	1.00	2327	Full Time	98.1%	2023-05-05 04:02:40.365888	2023-05-05 04:02:40.365888	Under	{}
23196	0.75	1.73	2327	1st Half	94.4%	2023-05-05 04:02:43.883749	2023-05-05 04:02:43.883749	Over	{}
23197	0.75	2.08	2327	1st Half	94.4%	2023-05-05 04:02:43.886293	2023-05-05 04:02:43.886293	Under	{}
23220	2.75	1.98	2389	Full Time	96.4%	2023-05-05 04:03:02.869313	2023-05-05 04:03:02.869313	Over	{}
23221	2.75	1.88	2389	Full Time	96.4%	2023-05-05 04:03:02.87178	2023-05-05 04:03:02.87178	Under	{}
23232	1.0	1.70	2389	1st Half	93.9%	2023-05-05 04:03:06.545609	2023-05-05 04:03:06.545609	Over	{}
23233	1.0	2.10	2389	1st Half	93.9%	2023-05-05 04:03:06.547855	2023-05-05 04:03:06.547855	Under	{}
23250	4.5	26.00	2389	2nd Half	97.2%	2023-05-05 04:03:09.808396	2023-05-05 04:03:09.808396	Over	{}
23251	4.5	1.01	2389	2nd Half	97.2%	2023-05-05 04:03:09.811228	2023-05-05 04:03:09.811228	Under	{}
16615	0.5	5.00	1668	Full Time	94.8%	2023-04-30 06:02:27.655619	2023-04-30 06:02:27.655619	Under	{}
16616	1.5	1.57	1668	Full Time	94.6%	2023-04-30 06:02:27.657773	2023-04-30 06:02:27.657773	Over	{}
16617	1.5	2.38	1668	Full Time	94.6%	2023-04-30 06:02:27.660078	2023-04-30 06:02:27.660078	Under	{}
16618	2.5	2.88	1668	Full Time	94.7%	2023-04-30 06:02:27.662674	2023-04-30 06:02:27.662674	Over	{}
16619	2.5	1.41	1668	Full Time	94.7%	2023-04-30 06:02:27.66488	2023-04-30 06:02:27.66488	Under	{}
16620	3.5	5.50	1668	Full Time	94.4%	2023-04-30 06:02:27.667332	2023-04-30 06:02:27.667332	Over	{}
16621	3.5	1.14	1668	Full Time	94.4%	2023-04-30 06:02:27.669628	2023-04-30 06:02:27.669628	Under	{}
16622	4.5	13.00	1668	Full Time	96.3%	2023-04-30 06:02:27.672618	2023-04-30 06:02:27.672618	Over	{}
16275	0.5	10.00	1628	Full Time	95.8%	2023-04-29 06:02:29.293317	2023-04-29 06:02:29.293317	Under	{}
16276	1.5	1.30	1628	Full Time	96.5%	2023-04-29 06:02:29.294227	2023-04-29 06:02:29.294227	Over	{}
16277	1.5	3.75	1628	Full Time	96.5%	2023-04-29 06:02:29.295147	2023-04-29 06:02:29.295147	Under	{}
16278	2.5	1.93	1628	Full Time	96.5%	2023-04-29 06:02:29.295956	2023-04-29 06:02:29.295956	Over	{}
16279	2.5	1.93	1628	Full Time	96.5%	2023-04-29 06:02:29.296929	2023-04-29 06:02:29.296929	Under	{}
16280	3.5	3.25	1628	Full Time	94.4%	2023-04-29 06:02:29.297939	2023-04-29 06:02:29.297939	Over	{}
16281	3.5	1.33	1628	Full Time	94.4%	2023-04-29 06:02:29.298938	2023-04-29 06:02:29.298938	Under	{}
16282	4.5	6.50	1628	Full Time	94.8%	2023-04-29 06:02:29.299677	2023-04-29 06:02:29.299677	Over	{}
16283	4.5	1.11	1628	Full Time	94.8%	2023-04-29 06:02:29.300657	2023-04-29 06:02:29.300657	Under	{}
16284	5.5	13.00	1628	Full Time	96.3%	2023-04-29 06:02:29.301782	2023-04-29 06:02:29.301782	Over	{}
16285	5.5	1.04	1628	Full Time	96.3%	2023-04-29 06:02:29.302815	2023-04-29 06:02:29.302815	Under	{}
16286	0.5	1.40	1628	1st Half	95.5%	2023-04-29 06:02:30.953613	2023-04-29 06:02:30.953613	Over	{}
16287	0.5	3.00	1628	1st Half	95.5%	2023-04-29 06:02:31.939593	2023-04-29 06:02:31.939593	Under	{}
16288	1.5	2.75	1628	1st Half	92.8%	2023-04-29 06:02:31.940842	2023-04-29 06:02:31.940842	Over	{}
16289	1.5	1.40	1628	1st Half	92.8%	2023-04-29 06:02:31.941901	2023-04-29 06:02:31.941901	Under	{}
16290	2.5	8.00	1628	1st Half	96.7%	2023-04-29 06:02:31.943029	2023-04-29 06:02:31.943029	Over	{}
16291	2.5	1.10	1628	1st Half	96.7%	2023-04-29 06:02:31.944182	2023-04-29 06:02:31.944182	Under	{}
16292	3.5	21.00	1628	1st Half	97.3%	2023-04-29 06:02:31.945278	2023-04-29 06:02:31.945278	Over	{}
16293	3.5	1.02	1628	1st Half	97.3%	2023-04-29 06:02:31.94632	2023-04-29 06:02:31.94632	Under	{}
16294	4.5	26.00	1628	1st Half	97.2%	2023-04-29 06:02:31.9473	2023-04-29 06:02:31.9473	Over	{}
16295	4.5	1.01	1628	1st Half	97.2%	2023-04-29 06:02:31.948296	2023-04-29 06:02:31.948296	Under	{}
16296	0.5	1.29	1628	2nd Half	97.5%	2023-04-29 06:02:33.554724	2023-04-29 06:02:33.554724	Over	{}
16297	0.5	4.00	1628	2nd Half	97.5%	2023-04-29 06:02:34.325883	2023-04-29 06:02:34.325883	Under	{}
16298	1.5	2.20	1628	2nd Half	96.8%	2023-04-29 06:02:34.328376	2023-04-29 06:02:34.328376	Over	{}
16299	1.5	1.73	1628	2nd Half	96.8%	2023-04-29 06:02:34.330577	2023-04-29 06:02:34.330577	Under	{}
16300	2.5	4.50	1628	2nd Half	94.7%	2023-04-29 06:02:34.333073	2023-04-29 06:02:34.333073	Over	{}
16301	2.5	1.20	1628	2nd Half	94.7%	2023-04-29 06:02:34.335085	2023-04-29 06:02:34.335085	Under	{}
16302	3.5	11.00	1628	2nd Half	95.9%	2023-04-29 06:02:34.337041	2023-04-29 06:02:34.337041	Over	{}
16303	3.5	1.05	1628	2nd Half	95.9%	2023-04-29 06:02:34.33908	2023-04-29 06:02:34.33908	Under	{}
16304	0.5	1.06	1631	Full Time	95.8%	2023-04-29 06:02:45.368371	2023-04-29 06:02:45.368371	Over	{}
16305	0.5	10.00	1631	Full Time	95.8%	2023-04-29 06:02:45.370465	2023-04-29 06:02:45.370465	Under	{}
16306	1.5	1.25	1631	Full Time	93.8%	2023-04-29 06:02:45.371735	2023-04-29 06:02:45.371735	Over	{}
16307	1.5	3.75	1631	Full Time	93.8%	2023-04-29 06:02:45.372733	2023-04-29 06:02:45.372733	Under	{}
16308	2.5	1.85	1631	Full Time	96.1%	2023-04-29 06:02:45.373885	2023-04-29 06:02:45.373885	Over	{}
16309	2.5	2.00	1631	Full Time	96.1%	2023-04-29 06:02:45.37493	2023-04-29 06:02:45.37493	Under	{}
16310	3.5	3.00	1631	Full Time	93.6%	2023-04-29 06:02:45.375931	2023-04-29 06:02:45.375931	Over	{}
16311	3.5	1.36	1631	Full Time	93.6%	2023-04-29 06:02:45.376841	2023-04-29 06:02:45.376841	Under	{}
16312	4.5	6.00	1631	Full Time	96.5%	2023-04-29 06:02:45.377843	2023-04-29 06:02:45.377843	Over	{}
16313	4.5	1.15	1631	Full Time	96.5%	2023-04-29 06:02:45.378914	2023-04-29 06:02:45.378914	Under	{}
16314	5.5	13.00	1631	Full Time	97.2%	2023-04-29 06:02:45.379959	2023-04-29 06:02:45.379959	Over	{}
16315	5.5	1.05	1631	Full Time	97.2%	2023-04-29 06:02:45.381044	2023-04-29 06:02:45.381044	Under	{}
16316	0.5	1.36	1631	1st Half	95.9%	2023-04-29 06:02:47.172029	2023-04-29 06:02:47.172029	Over	{}
16317	0.5	3.25	1631	1st Half	95.9%	2023-04-29 06:02:48.35327	2023-04-29 06:02:48.35327	Under	{}
16318	1.5	2.63	1631	1st Half	95.5%	2023-04-29 06:02:48.355006	2023-04-29 06:02:48.355006	Over	{}
16319	1.5	1.50	1631	1st Half	95.5%	2023-04-29 06:02:48.35689	2023-04-29 06:02:48.35689	Under	{}
23514	0.5	1.06	2455	Full Time	93.6%	2023-05-07 04:00:47.008818	2023-05-07 04:00:47.008818	Over	{}
23515	0.5	8.00	2455	Full Time	93.6%	2023-05-07 04:00:47.01441	2023-05-07 04:00:47.01441	Under	{}
23516	1.5	1.33	2455	Full Time	94.4%	2023-05-07 04:00:47.017008	2023-05-07 04:00:47.017008	Over	{}
23517	1.5	3.25	2455	Full Time	94.4%	2023-05-07 04:00:47.019552	2023-05-07 04:00:47.019552	Under	{}
23518	2.5	2.00	2455	Full Time	93.9%	2023-05-07 04:00:47.022022	2023-05-07 04:00:47.022022	Over	{}
23519	2.5	1.77	2455	Full Time	93.9%	2023-05-07 04:00:47.024738	2023-05-07 04:00:47.024738	Under	{}
23520	3.5	3.50	2455	Full Time	94.3%	2023-05-07 04:00:47.027222	2023-05-07 04:00:47.027222	Over	{}
23521	3.5	1.29	2455	Full Time	94.3%	2023-05-07 04:00:47.029603	2023-05-07 04:00:47.029603	Under	{}
23522	4.5	6.50	2455	Full Time	94.1%	2023-05-07 04:00:47.031643	2023-05-07 04:00:47.031643	Over	{}
23523	4.5	1.10	2455	Full Time	94.1%	2023-05-07 04:00:47.033857	2023-05-07 04:00:47.033857	Under	{}
23524	5.5	12.00	2455	Full Time	94.0%	2023-05-07 04:00:47.036088	2023-05-07 04:00:47.036088	Over	{}
23525	5.5	1.02	2455	Full Time	94.0%	2023-05-07 04:00:47.038241	2023-05-07 04:00:47.038241	Under	{}
23526	0.5	1.40	2455	1st Half	92.8%	2023-05-07 04:00:48.745192	2023-05-07 04:00:48.745192	Over	{}
23527	0.5	2.75	2455	1st Half	92.8%	2023-05-07 04:00:50.418711	2023-05-07 04:00:50.418711	Under	{}
23528	1.5	2.75	2455	1st Half	92.8%	2023-05-07 04:00:50.421365	2023-05-07 04:00:50.421365	Over	{}
23529	1.5	1.40	2455	1st Half	92.8%	2023-05-07 04:00:50.423834	2023-05-07 04:00:50.423834	Under	{}
23530	2.5	7.00	2455	1st Half	93.6%	2023-05-07 04:00:50.426227	2023-05-07 04:00:50.426227	Over	{}
23531	2.5	1.08	2455	1st Half	93.6%	2023-05-07 04:00:50.428672	2023-05-07 04:00:50.428672	Under	{}
23532	3.5	15.00	2455	1st Half	95.5%	2023-05-07 04:00:50.431044	2023-05-07 04:00:50.431044	Over	{}
23533	3.5	1.02	2455	1st Half	95.5%	2023-05-07 04:00:50.433435	2023-05-07 04:00:50.433435	Under	{}
23534	4.5	29.00	2455	1st Half	96.7%	2023-05-07 04:00:50.435842	2023-05-07 04:00:50.435842	Over	{}
23535	4.5	1.00	2455	1st Half	96.7%	2023-05-07 04:00:50.438407	2023-05-07 04:00:50.438407	Under	{}
23536	0.5	1.30	2455	2nd Half	94.0%	2023-05-07 04:00:52.303663	2023-05-07 04:00:52.303663	Over	{}
23537	0.5	3.40	2455	2nd Half	94.0%	2023-05-07 04:00:53.460786	2023-05-07 04:00:53.460786	Under	{}
23538	1.5	2.30	2455	2nd Half	93.3%	2023-05-07 04:00:53.463332	2023-05-07 04:00:53.463332	Over	{}
23539	1.5	1.57	2455	2nd Half	93.3%	2023-05-07 04:00:53.465855	2023-05-07 04:00:53.465855	Under	{}
23540	2.5	4.75	2455	2nd Half	92.6%	2023-05-07 04:00:53.468352	2023-05-07 04:00:53.468352	Over	{}
23541	2.5	1.15	2455	2nd Half	92.6%	2023-05-07 04:00:53.470691	2023-05-07 04:00:53.470691	Under	{}
23542	3.5	11.00	2455	2nd Half	94.2%	2023-05-07 04:00:53.472993	2023-05-07 04:00:53.472993	Over	{}
23543	3.5	1.03	2455	2nd Half	94.2%	2023-05-07 04:00:53.47531	2023-05-07 04:00:53.47531	Under	{}
23544	0.5	1.10	2458	Full Time	94.1%	2023-05-07 04:01:08.637734	2023-05-07 04:01:08.637734	Over	{}
23545	0.5	6.50	2458	Full Time	94.1%	2023-05-07 04:01:08.64081	2023-05-07 04:01:08.64081	Under	{}
23546	1.5	1.44	2458	Full Time	92.9%	2023-05-07 04:01:08.643053	2023-05-07 04:01:08.643053	Over	{}
23547	1.5	2.62	2458	Full Time	92.9%	2023-05-07 04:01:08.645263	2023-05-07 04:01:08.645263	Under	{}
23548	2.5	2.38	2458	Full Time	93.1%	2023-05-07 04:01:08.647745	2023-05-07 04:01:08.647745	Over	{}
23549	2.5	1.53	2458	Full Time	93.1%	2023-05-07 04:01:08.650038	2023-05-07 04:01:08.650038	Under	{}
23550	3.5	4.33	2458	Full Time	94.0%	2023-05-07 04:01:08.652615	2023-05-07 04:01:08.652615	Over	{}
23551	3.5	1.20	2458	Full Time	94.0%	2023-05-07 04:01:08.654928	2023-05-07 04:01:08.654928	Under	{}
23552	4.5	8.00	2458	Full Time	93.6%	2023-05-07 04:01:08.657268	2023-05-07 04:01:08.657268	Over	{}
23553	4.5	1.06	2458	Full Time	93.6%	2023-05-07 04:01:08.659544	2023-05-07 04:01:08.659544	Under	{}
23554	5.5	15.00	2458	Full Time	95.5%	2023-05-07 04:01:08.661842	2023-05-07 04:01:08.661842	Over	{}
23555	5.5	1.02	2458	Full Time	95.5%	2023-05-07 04:01:08.66417	2023-05-07 04:01:08.66417	Under	{}
23556	0.5	1.50	2458	1st Half	93.8%	2023-05-07 04:01:10.392333	2023-05-07 04:01:10.392333	Over	{}
23557	0.5	2.50	2458	1st Half	93.8%	2023-05-07 04:01:12.151372	2023-05-07 04:01:12.151372	Under	{}
23558	1.5	3.40	2458	1st Half	94.0%	2023-05-07 04:01:12.153727	2023-05-07 04:01:12.153727	Over	{}
23559	1.5	1.30	2458	1st Half	94.0%	2023-05-07 04:01:12.156078	2023-05-07 04:01:12.156078	Under	{}
23560	2.5	9.00	2458	1st Half	94.0%	2023-05-07 04:01:12.158289	2023-05-07 04:01:12.158289	Over	{}
23561	2.5	1.05	2458	1st Half	94.0%	2023-05-07 04:01:12.160573	2023-05-07 04:01:12.160573	Under	{}
23562	3.5	17.00	2458	1st Half	95.3%	2023-05-07 04:01:12.162838	2023-05-07 04:01:12.162838	Over	{}
23563	3.5	1.01	2458	1st Half	95.3%	2023-05-07 04:01:12.16512	2023-05-07 04:01:12.16512	Under	{}
23564	4.5	34.00	2458	1st Half	97.1%	2023-05-07 04:01:12.16732	2023-05-07 04:01:12.16732	Over	{}
23565	4.5	1.00	2458	1st Half	97.1%	2023-05-07 04:01:12.169613	2023-05-07 04:01:12.169613	Under	{}
23566	0.5	1.36	2458	2nd Half	93.6%	2023-05-07 04:01:14.057721	2023-05-07 04:01:14.057721	Over	{}
23567	0.5	3.00	2458	2nd Half	93.6%	2023-05-07 04:01:15.25427	2023-05-07 04:01:15.25427	Under	{}
16320	2.5	7.00	1631	1st Half	95.8%	2023-04-29 06:02:48.358164	2023-04-29 06:02:48.358164	Over	{}
16321	2.5	1.11	1631	1st Half	95.8%	2023-04-29 06:02:48.359541	2023-04-29 06:02:48.359541	Under	{}
16322	3.5	21.00	1631	1st Half	97.3%	2023-04-29 06:02:48.361104	2023-04-29 06:02:48.361104	Over	{}
16323	3.5	1.02	1631	1st Half	97.3%	2023-04-29 06:02:48.362638	2023-04-29 06:02:48.362638	Under	{}
16324	4.5	26.00	1631	1st Half	97.2%	2023-04-29 06:02:48.363977	2023-04-29 06:02:48.363977	Over	{}
16325	4.5	1.01	1631	1st Half	97.2%	2023-04-29 06:02:48.365245	2023-04-29 06:02:48.365245	Under	{}
16326	0.5	1.25	1631	2nd Half	95.2%	2023-04-29 06:02:49.909445	2023-04-29 06:02:49.909445	Over	{}
16327	0.5	4.00	1631	2nd Half	95.2%	2023-04-29 06:02:50.805258	2023-04-29 06:02:50.805258	Under	{}
16624	5.5	29.00	1668	Full Time	97.6%	2023-04-30 06:02:27.677642	2023-04-30 06:02:27.677642	Over	{}
16329	1.5	1.73	1631	2nd Half	94.9%	2023-04-29 06:02:50.810693	2023-04-29 06:02:50.810693	Under	{}
16330	2.5	4.33	1631	2nd Half	94.0%	2023-04-29 06:02:50.812659	2023-04-29 06:02:50.812659	Over	{}
16331	2.5	1.20	1631	2nd Half	94.0%	2023-04-29 06:02:50.814707	2023-04-29 06:02:50.814707	Under	{}
16332	3.5	11.00	1631	2nd Half	95.9%	2023-04-29 06:02:50.816513	2023-04-29 06:02:50.816513	Over	{}
16333	3.5	1.05	1631	2nd Half	95.9%	2023-04-29 06:02:50.817602	2023-04-29 06:02:50.817602	Under	{}
16625	5.5	1.01	1668	Full Time	97.6%	2023-04-30 06:02:27.680243	2023-04-30 06:02:27.680243	Under	{}
16626	6.5	46.00	1668	Full Time	97.9%	2023-04-30 06:02:27.681643	2023-04-30 06:02:27.681643	Over	{}
16627	6.5	1.00	1668	Full Time	97.9%	2023-04-30 06:02:27.683142	2023-04-30 06:02:27.683142	Under	{}
16628	0.5	1.65	1668	1st Half	94.3%	2023-04-30 06:02:29.338454	2023-04-30 06:02:29.338454	Over	{}
16629	0.5	2.20	1668	1st Half	94.3%	2023-04-30 06:02:30.454883	2023-04-30 06:02:30.454883	Under	{}
16630	1.5	4.00	1668	1st Half	94.7%	2023-04-30 06:02:30.457069	2023-04-30 06:02:30.457069	Over	{}
16631	1.5	1.24	1668	1st Half	94.7%	2023-04-30 06:02:30.458835	2023-04-30 06:02:30.458835	Under	{}
16632	2.5	13.00	1668	1st Half	96.3%	2023-04-30 06:02:30.461003	2023-04-30 06:02:30.461003	Over	{}
16633	2.5	1.04	1668	1st Half	96.3%	2023-04-30 06:02:30.462753	2023-04-30 06:02:30.462753	Under	{}
22910	0.5	1.06	2324	Full Time	95.8%	2023-05-04 04:02:08.402348	2023-05-04 04:02:08.402348	Over	{}
22911	0.5	10.00	2324	Full Time	95.8%	2023-05-04 04:02:10.610116	2023-05-04 04:02:10.610116	Under	{}
22912	1.5	1.33	2324	Full Time	95.6%	2023-05-04 04:02:10.612608	2023-05-04 04:02:10.612608	Over	{}
22913	1.5	3.40	2324	Full Time	95.6%	2023-05-04 04:02:10.614992	2023-05-04 04:02:10.614992	Under	{}
22914	2.5	2.12	2324	Full Time	98.8%	2023-05-04 04:02:10.617387	2023-05-04 04:02:10.617387	Over	{}
22915	2.5	1.85	2324	Full Time	98.8%	2023-05-04 04:02:10.619757	2023-05-04 04:02:10.619757	Under	{}
22916	3.5	4.00	2324	Full Time	98.1%	2023-05-04 04:02:10.622155	2023-05-04 04:02:10.622155	Over	{}
22917	3.5	1.30	2324	Full Time	98.1%	2023-05-04 04:02:10.624735	2023-05-04 04:02:10.624735	Under	{}
23568	1.5	2.50	2458	2nd Half	93.8%	2023-05-07 04:01:15.256588	2023-05-07 04:01:15.256588	Over	{}
23569	1.5	1.50	2458	2nd Half	93.8%	2023-05-07 04:01:15.258938	2023-05-07 04:01:15.258938	Under	{}
23570	2.5	5.50	2458	2nd Half	93.1%	2023-05-07 04:01:15.261483	2023-05-07 04:01:15.261483	Over	{}
23571	2.5	1.12	2458	2nd Half	93.1%	2023-05-07 04:01:15.264128	2023-05-07 04:01:15.264128	Under	{}
23572	3.5	13.00	2458	2nd Half	94.6%	2023-05-07 04:01:15.266451	2023-05-07 04:01:15.266451	Over	{}
23573	3.5	1.02	2458	2nd Half	94.6%	2023-05-07 04:01:15.268829	2023-05-07 04:01:15.268829	Under	{}
23574	0.5	1.05	2461	Full Time	94.0%	2023-05-07 04:01:30.470794	2023-05-07 04:01:30.470794	Over	{}
23575	0.5	9.00	2461	Full Time	94.0%	2023-05-07 04:01:30.473823	2023-05-07 04:01:30.473823	Under	{}
23576	1.5	1.25	2461	Full Time	93.8%	2023-05-07 04:01:30.476068	2023-05-07 04:01:30.476068	Over	{}
23577	1.5	3.75	2461	Full Time	93.8%	2023-05-07 04:01:30.478225	2023-05-07 04:01:30.478225	Under	{}
23578	2.5	1.80	2461	Full Time	92.7%	2023-05-07 04:01:30.480481	2023-05-07 04:01:30.480481	Over	{}
23579	2.5	1.91	2461	Full Time	92.7%	2023-05-07 04:01:30.482662	2023-05-07 04:01:30.482662	Under	{}
23580	3.5	2.75	2461	Full Time	92.8%	2023-05-07 04:01:30.484851	2023-05-07 04:01:30.484851	Over	{}
23581	3.5	1.40	2461	Full Time	92.8%	2023-05-07 04:01:30.487029	2023-05-07 04:01:30.487029	Under	{}
23582	4.5	5.00	2461	Full Time	92.8%	2023-05-07 04:01:30.489182	2023-05-07 04:01:30.489182	Over	{}
23583	4.5	1.14	2461	Full Time	92.8%	2023-05-07 04:01:30.491359	2023-05-07 04:01:30.491359	Under	{}
23584	5.5	9.00	2461	Full Time	94.0%	2023-05-07 04:01:30.493508	2023-05-07 04:01:30.493508	Over	{}
23585	5.5	1.05	2461	Full Time	94.0%	2023-05-07 04:01:30.49568	2023-05-07 04:01:30.49568	Under	{}
23586	0.5	1.33	2461	1st Half	94.4%	2023-05-07 04:01:32.206957	2023-05-07 04:01:32.206957	Over	{}
23587	0.5	3.25	2461	1st Half	94.4%	2023-05-07 04:01:34.054822	2023-05-07 04:01:34.054822	Under	{}
23588	1.5	2.50	2461	1st Half	93.8%	2023-05-07 04:01:34.057428	2023-05-07 04:01:34.057428	Over	{}
23589	1.5	1.50	2461	1st Half	93.8%	2023-05-07 04:01:34.059532	2023-05-07 04:01:34.059532	Under	{}
23590	2.5	5.50	2461	1st Half	93.1%	2023-05-07 04:01:34.061703	2023-05-07 04:01:34.061703	Over	{}
23591	2.5	1.12	2461	1st Half	93.1%	2023-05-07 04:01:34.063931	2023-05-07 04:01:34.063931	Under	{}
23592	3.5	13.00	2461	1st Half	94.6%	2023-05-07 04:01:34.066071	2023-05-07 04:01:34.066071	Over	{}
23593	3.5	1.02	2461	1st Half	94.6%	2023-05-07 04:01:34.068308	2023-05-07 04:01:34.068308	Under	{}
23594	4.5	26.00	2461	1st Half	97.2%	2023-05-07 04:01:34.070455	2023-05-07 04:01:34.070455	Over	{}
23595	4.5	1.01	2461	1st Half	97.2%	2023-05-07 04:01:34.072675	2023-05-07 04:01:34.072675	Under	{}
23596	0.5	1.25	2461	2nd Half	93.8%	2023-05-07 04:01:35.721218	2023-05-07 04:01:35.721218	Over	{}
23597	0.5	3.75	2461	2nd Half	93.8%	2023-05-07 04:01:37.238725	2023-05-07 04:01:37.238725	Under	{}
23598	1.5	2.00	2461	2nd Half	92.8%	2023-05-07 04:01:37.241274	2023-05-07 04:01:37.241274	Over	{}
16634	3.5	29.00	1668	1st Half	97.6%	2023-04-30 06:02:30.4644	2023-04-30 06:02:30.4644	Over	{}
16635	3.5	1.01	1668	1st Half	97.6%	2023-04-30 06:02:30.466499	2023-04-30 06:02:30.466499	Under	{}
16636	4.5	71.00	1668	1st Half	98.6%	2023-04-30 06:02:30.468678	2023-04-30 06:02:30.468678	Over	{}
16637	4.5	1.00	1668	1st Half	98.6%	2023-04-30 06:02:30.470384	2023-04-30 06:02:30.470384	Under	{}
16638	0.5	1.44	1668	2nd Half	97.3%	2023-04-30 06:02:32.050837	2023-04-30 06:02:32.050837	Over	{}
16639	0.5	3.00	1668	2nd Half	97.3%	2023-04-30 06:02:33.013052	2023-04-30 06:02:33.013052	Under	{}
16640	1.5	2.80	1668	2nd Half	95.1%	2023-04-30 06:02:33.015297	2023-04-30 06:02:33.015297	Over	{}
16641	1.5	1.44	1668	2nd Half	95.1%	2023-04-30 06:02:33.016906	2023-04-30 06:02:33.016906	Under	{}
16642	2.5	7.00	1668	2nd Half	95.1%	2023-04-30 06:02:33.019152	2023-04-30 06:02:33.019152	Over	{}
16643	2.5	1.10	1668	2nd Half	95.1%	2023-04-30 06:02:33.020384	2023-04-30 06:02:33.020384	Under	{}
16644	3.5	19.00	1668	2nd Half	96.8%	2023-04-30 06:02:33.021355	2023-04-30 06:02:33.021355	Over	{}
16645	3.5	1.02	1668	2nd Half	96.8%	2023-04-30 06:02:33.022372	2023-04-30 06:02:33.022372	Under	{}
22924	1.5	3.10	2324	1st Half	96.4%	2023-05-04 04:02:13.781984	2023-05-04 04:02:13.781984	Over	{}
22925	1.5	1.40	2324	1st Half	96.4%	2023-05-04 04:02:13.784982	2023-05-04 04:02:13.784982	Under	{}
16646	0.5	1.11	1671	Full Time	94.8%	2023-04-30 06:02:42.553042	2023-04-30 06:02:42.553042	Over	{}
16648	1.5	1.50	1671	Full Time	93.8%	2023-04-30 06:02:42.558397	2023-04-30 06:02:42.558397	Over	{}
16649	1.5	2.50	1671	Full Time	93.8%	2023-04-30 06:02:42.560169	2023-04-30 06:02:42.560169	Under	{}
16650	2.5	2.60	1671	Full Time	95.1%	2023-04-30 06:02:42.562576	2023-04-30 06:02:42.562576	Over	{}
22926	2.5	8.00	2324	1st Half	95.2%	2023-05-04 04:02:13.787252	2023-05-04 04:02:13.787252	Over	{}
22927	2.5	1.08	2324	1st Half	95.2%	2023-05-04 04:02:13.789583	2023-05-04 04:02:13.789583	Under	{}
22928	3.5	21.00	2324	1st Half	97.3%	2023-05-04 04:02:13.7919	2023-05-04 04:02:13.7919	Over	{}
22929	3.5	1.02	2324	1st Half	97.3%	2023-05-04 04:02:13.794465	2023-05-04 04:02:13.794465	Under	{}
22930	4.5	51.00	2324	1st Half	98.1%	2023-05-04 04:02:13.796883	2023-05-04 04:02:13.796883	Over	{}
22931	4.5	1.00	2324	1st Half	98.1%	2023-05-04 04:02:13.799253	2023-05-04 04:02:13.799253	Under	{}
22932	0.5	1.33	2324	2nd Half	98.2%	2023-05-04 04:02:16.090597	2023-05-04 04:02:16.090597	Over	{}
22933	0.5	3.75	2324	2nd Half	98.2%	2023-05-04 04:02:17.30607	2023-05-04 04:02:17.30607	Under	{}
22934	1.5	2.33	2324	2nd Half	97.3%	2023-05-04 04:02:17.308584	2023-05-04 04:02:17.308584	Over	{}
22935	1.5	1.67	2324	2nd Half	97.3%	2023-05-04 04:02:17.31101	2023-05-04 04:02:17.31101	Under	{}
22936	2.5	5.00	2324	2nd Half	94.8%	2023-05-04 04:02:17.313353	2023-05-04 04:02:17.313353	Over	{}
22937	2.5	1.17	2324	2nd Half	94.8%	2023-05-04 04:02:17.315764	2023-05-04 04:02:17.315764	Under	{}
16651	2.5	1.50	1671	Full Time	95.1%	2023-04-30 06:02:42.56442	2023-04-30 06:02:42.56442	Under	{}
16652	3.5	5.50	1671	Full Time	96.5%	2023-04-30 06:02:42.566758	2023-04-30 06:02:42.566758	Over	{}
16653	3.5	1.17	1671	Full Time	96.5%	2023-04-30 06:02:42.568729	2023-04-30 06:02:42.568729	Under	{}
16654	4.5	13.00	1671	Full Time	97.2%	2023-04-30 06:02:42.570679	2023-04-30 06:02:42.570679	Over	{}
16655	4.5	1.05	1671	Full Time	97.2%	2023-04-30 06:02:42.572521	2023-04-30 06:02:42.572521	Under	{}
16656	5.5	26.00	1671	Full Time	98.1%	2023-04-30 06:02:42.57473	2023-04-30 06:02:42.57473	Over	{}
16657	5.5	1.02	1671	Full Time	98.1%	2023-04-30 06:02:42.577012	2023-04-30 06:02:42.577012	Under	{}
16658	6.5	46.00	1671	Full Time	97.9%	2023-04-30 06:02:42.579202	2023-04-30 06:02:42.579202	Over	{}
16659	6.5	1.00	1671	Full Time	97.9%	2023-04-30 06:02:42.581016	2023-04-30 06:02:42.581016	Under	{}
16660	0.5	1.57	1671	1st Half	94.6%	2023-04-30 06:02:44.230019	2023-04-30 06:02:44.230019	Over	{}
16661	0.5	2.38	1671	1st Half	94.6%	2023-04-30 06:02:45.207469	2023-04-30 06:02:45.207469	Under	{}
16662	1.5	3.75	1671	1st Half	96.0%	2023-04-30 06:02:45.209076	2023-04-30 06:02:45.209076	Over	{}
16663	1.5	1.29	1671	1st Half	96.0%	2023-04-30 06:02:45.210473	2023-04-30 06:02:45.210473	Under	{}
16664	2.5	13.00	1671	1st Half	97.2%	2023-04-30 06:02:45.212228	2023-04-30 06:02:45.212228	Over	{}
16665	2.5	1.05	1671	1st Half	97.2%	2023-04-30 06:02:45.213819	2023-04-30 06:02:45.213819	Under	{}
16666	3.5	31.00	1671	1st Half	97.8%	2023-04-30 06:02:45.215349	2023-04-30 06:02:45.215349	Over	{}
16667	3.5	1.01	1671	1st Half	97.8%	2023-04-30 06:02:45.216853	2023-04-30 06:02:45.216853	Under	{}
16668	4.5	71.00	1671	1st Half	98.6%	2023-04-30 06:02:45.218599	2023-04-30 06:02:45.218599	Over	{}
16669	4.5	1.00	1671	1st Half	98.6%	2023-04-30 06:02:45.220012	2023-04-30 06:02:45.220012	Under	{}
16670	0.5	1.40	1671	2nd Half	95.5%	2023-04-30 06:02:46.903034	2023-04-30 06:02:46.903034	Over	{}
22918	4.5	8.50	2324	Full Time	98.2%	2023-05-04 04:02:10.627089	2023-05-04 04:02:10.627089	Over	{}
22919	4.5	1.11	2324	Full Time	98.2%	2023-05-04 04:02:10.629414	2023-05-04 04:02:10.629414	Under	{}
22920	5.5	15.00	2324	Full Time	96.4%	2023-05-04 04:02:10.631914	2023-05-04 04:02:10.631914	Over	{}
22921	5.5	1.03	2324	Full Time	96.4%	2023-05-04 04:02:10.634341	2023-05-04 04:02:10.634341	Under	{}
22922	0.5	1.40	2324	1st Half	92.8%	2023-05-04 04:02:12.251172	2023-05-04 04:02:12.251172	Over	{}
22923	0.5	2.75	2324	1st Half	92.8%	2023-05-04 04:02:13.778926	2023-05-04 04:02:13.778926	Under	{}
22938	3.5	13.00	2324	2nd Half	96.3%	2023-05-04 04:02:17.318106	2023-05-04 04:02:17.318106	Over	{}
22939	3.5	1.04	2324	2nd Half	96.3%	2023-05-04 04:02:17.320502	2023-05-04 04:02:17.320502	Under	{}
23599	1.5	1.73	2461	2nd Half	92.8%	2023-05-07 04:01:37.243484	2023-05-07 04:01:37.243484	Under	{}
23600	2.5	4.33	2461	2nd Half	94.0%	2023-05-07 04:01:37.245982	2023-05-07 04:01:37.245982	Over	{}
23601	2.5	1.20	2461	2nd Half	94.0%	2023-05-07 04:01:37.248334	2023-05-07 04:01:37.248334	Under	{}
23602	3.5	9.00	2461	2nd Half	94.0%	2023-05-07 04:01:37.250687	2023-05-07 04:01:37.250687	Over	{}
23603	3.5	1.05	2461	2nd Half	94.0%	2023-05-07 04:01:37.252985	2023-05-07 04:01:37.252985	Under	{}
16671	0.5	3.00	1671	2nd Half	95.5%	2023-04-30 06:02:47.761339	2023-04-30 06:02:47.761339	Under	{}
16672	1.5	2.63	1671	2nd Half	93.1%	2023-04-30 06:02:47.764233	2023-04-30 06:02:47.764233	Over	{}
16673	1.5	1.44	1671	2nd Half	93.1%	2023-04-30 06:02:47.766948	2023-04-30 06:02:47.766948	Under	{}
16674	2.5	7.00	1671	2nd Half	95.1%	2023-04-30 06:02:47.769342	2023-04-30 06:02:47.769342	Over	{}
16675	2.5	1.10	1671	2nd Half	95.1%	2023-04-30 06:02:47.772204	2023-04-30 06:02:47.772204	Under	{}
16676	3.5	21.00	1671	2nd Half	97.3%	2023-04-30 06:02:47.774815	2023-04-30 06:02:47.774815	Over	{}
16677	3.5	1.02	1671	2nd Half	97.3%	2023-04-30 06:02:47.776945	2023-04-30 06:02:47.776945	Under	{}
16679	0.5	8.50	1674	Full Time	95.8%	2023-04-30 06:02:56.752718	2023-04-30 06:02:56.752718	Under	{}
16680	1.5	1.40	1674	Full Time	95.5%	2023-04-30 06:02:56.754907	2023-04-30 06:02:56.754907	Over	{}
16681	1.5	3.00	1674	Full Time	95.5%	2023-04-30 06:02:56.757277	2023-04-30 06:02:56.757277	Under	{}
16682	2.5	2.20	1674	Full Time	94.9%	2023-04-30 06:02:56.759287	2023-04-30 06:02:56.759287	Over	{}
16868	2.0	2.10	1668	Full Time	96.0%	2023-05-01 06:01:26.506926	2023-05-01 06:01:26.506926	Over	{}
16869	2.0	1.77	1668	Full Time	96.0%	2023-05-01 06:01:26.507689	2023-05-01 06:01:26.507689	Under	{}
16623	4.5	1.04	1668	Full Time	96.3%	2023-04-30 06:02:27.674866	2023-04-30 06:02:27.674866	Under	{}
16882	0.75	1.95	1668	1st Half	94.9%	2023-05-01 06:01:29.018174	2023-05-01 06:01:29.018174	Over	{}
16883	0.75	1.85	1668	1st Half	94.9%	2023-05-01 06:01:29.019307	2023-05-01 06:01:29.019307	Under	{}
16647	0.5	6.50	1671	Full Time	94.8%	2023-04-30 06:02:42.555968	2023-04-30 06:02:42.555968	Under	{}
16904	2.0	2.00	1671	Full Time	96.1%	2023-05-01 06:01:41.60837	2023-05-01 06:01:41.60837	Over	{}
16905	2.0	1.85	1671	Full Time	96.1%	2023-05-01 06:01:41.609235	2023-05-01 06:01:41.609235	Under	{}
16918	0.75	1.88	1671	1st Half	95.2%	2023-05-01 06:01:44.241303	2023-05-01 06:01:44.241303	Over	{}
16919	0.75	1.93	1671	1st Half	95.2%	2023-05-01 06:01:44.242526	2023-05-01 06:01:44.242526	Under	{}
16683	2.5	1.67	1674	Full Time	94.9%	2023-04-30 06:02:56.761203	2023-04-30 06:02:56.761203	Under	{}
16684	3.5	4.00	1674	Full Time	95.2%	2023-04-30 06:02:56.763238	2023-04-30 06:02:56.763238	Over	{}
16685	3.5	1.25	1674	Full Time	95.2%	2023-04-30 06:02:56.76511	2023-04-30 06:02:56.76511	Under	{}
16686	4.5	9.00	1674	Full Time	95.6%	2023-04-30 06:02:56.767091	2023-04-30 06:02:56.767091	Over	{}
16687	4.5	1.07	1674	Full Time	95.6%	2023-04-30 06:02:56.768945	2023-04-30 06:02:56.768945	Under	{}
16688	5.5	19.00	1674	Full Time	96.8%	2023-04-30 06:02:56.770913	2023-04-30 06:02:56.770913	Over	{}
16689	5.5	1.02	1674	Full Time	96.8%	2023-04-30 06:02:56.772681	2023-04-30 06:02:56.772681	Under	{}
16690	6.5	34.00	1674	Full Time	97.1%	2023-04-30 06:02:56.77503	2023-04-30 06:02:56.77503	Over	{}
16691	6.5	1.00	1674	Full Time	97.1%	2023-04-30 06:02:56.776974	2023-04-30 06:02:56.776974	Under	{}
16692	0.5	1.46	1674	1st Half	93.9%	2023-04-30 06:02:58.378054	2023-04-30 06:02:58.378054	Over	{}
16693	0.5	2.63	1674	1st Half	93.9%	2023-04-30 06:02:59.455271	2023-04-30 06:02:59.455271	Under	{}
16694	1.5	3.25	1674	1st Half	95.9%	2023-04-30 06:02:59.457716	2023-04-30 06:02:59.457716	Over	{}
16695	1.5	1.36	1674	1st Half	95.9%	2023-04-30 06:02:59.460057	2023-04-30 06:02:59.460057	Under	{}
16696	2.5	10.00	1674	1st Half	96.7%	2023-04-30 06:02:59.461818	2023-04-30 06:02:59.461818	Over	{}
16697	2.5	1.07	1674	1st Half	96.7%	2023-04-30 06:02:59.464184	2023-04-30 06:02:59.464184	Under	{}
16698	3.5	26.00	1674	1st Half	97.2%	2023-04-30 06:02:59.466141	2023-04-30 06:02:59.466141	Over	{}
16699	3.5	1.01	1674	1st Half	97.2%	2023-04-30 06:02:59.468592	2023-04-30 06:02:59.468592	Under	{}
16700	4.5	61.00	1674	1st Half	98.4%	2023-04-30 06:02:59.471032	2023-04-30 06:02:59.471032	Over	{}
16701	4.5	1.00	1674	1st Half	98.4%	2023-04-30 06:02:59.472809	2023-04-30 06:02:59.472809	Under	{}
16702	0.5	1.33	1674	2nd Half	96.4%	2023-04-30 06:03:01.23474	2023-04-30 06:03:01.23474	Over	{}
16703	0.5	3.50	1674	2nd Half	96.4%	2023-04-30 06:03:02.012504	2023-04-30 06:03:02.012504	Under	{}
16704	1.5	2.38	1674	2nd Half	94.6%	2023-04-30 06:03:02.013579	2023-04-30 06:03:02.013579	Over	{}
16705	1.5	1.57	1674	2nd Half	94.6%	2023-04-30 06:03:02.014661	2023-04-30 06:03:02.014661	Under	{}
16706	2.5	5.50	1674	2nd Half	94.4%	2023-04-30 06:03:02.015717	2023-04-30 06:03:02.015717	Over	{}
16707	2.5	1.14	1674	2nd Half	94.4%	2023-04-30 06:03:02.016818	2023-04-30 06:03:02.016818	Under	{}
16708	3.5	15.00	1674	2nd Half	96.4%	2023-04-30 06:03:02.01796	2023-04-30 06:03:02.01796	Over	{}
16709	3.5	1.03	1674	2nd Half	96.4%	2023-04-30 06:03:02.01916	2023-04-30 06:03:02.01916	Under	{}
16678	0.5	1.08	1674	Full Time	95.8%	2023-04-30 06:02:56.74979	2023-04-30 06:02:56.74979	Over	{}
16940	2.25	1.93	1674	Full Time	96.5%	2023-05-01 06:01:57.388939	2023-05-01 06:01:57.388939	Over	{}
16941	2.25	1.93	1674	Full Time	96.5%	2023-05-01 06:01:57.390051	2023-05-01 06:01:57.390051	Under	{}
16954	1.0	2.10	1674	1st Half	93.9%	2023-05-01 06:01:59.848969	2023-05-01 06:01:59.848969	Over	{}
16955	1.0	1.70	1674	1st Half	93.9%	2023-05-01 06:01:59.849899	2023-05-01 06:01:59.849899	Under	{}
16334	0.5	1.11	1634	Full Time	94.8%	2023-04-29 06:03:00.812758	2023-04-29 06:03:00.812758	Over	{}
16335	0.5	6.50	1634	Full Time	94.8%	2023-04-29 06:03:00.815254	2023-04-29 06:03:00.815254	Under	{}
16336	1.5	1.50	1634	Full Time	93.8%	2023-04-29 06:03:00.816601	2023-04-29 06:03:00.816601	Over	{}
16337	1.5	2.50	1634	Full Time	93.8%	2023-04-29 06:03:00.818228	2023-04-29 06:03:00.818228	Under	{}
16338	2.5	2.50	1634	Full Time	94.9%	2023-04-29 06:03:00.81963	2023-04-29 06:03:00.81963	Over	{}
16339	2.5	1.53	1634	Full Time	94.9%	2023-04-29 06:03:00.821314	2023-04-29 06:03:00.821314	Under	{}
16340	3.5	5.00	1634	Full Time	94.8%	2023-04-29 06:03:00.822899	2023-04-29 06:03:00.822899	Over	{}
16341	3.5	1.17	1634	Full Time	94.8%	2023-04-29 06:03:00.824351	2023-04-29 06:03:00.824351	Under	{}
16342	4.5	11.00	1634	Full Time	95.9%	2023-04-29 06:03:00.82597	2023-04-29 06:03:00.82597	Over	{}
16343	4.5	1.05	1634	Full Time	95.9%	2023-04-29 06:03:00.827626	2023-04-29 06:03:00.827626	Under	{}
16344	5.5	26.00	1634	Full Time	98.1%	2023-04-29 06:03:00.829133	2023-04-29 06:03:00.829133	Over	{}
16345	5.5	1.02	1634	Full Time	98.1%	2023-04-29 06:03:00.830784	2023-04-29 06:03:00.830784	Under	{}
22940	0.5	1.08	2327	Full Time	95.8%	2023-05-04 04:02:29.590062	2023-05-04 04:02:29.590062	Over	{}
22941	0.5	8.50	2327	Full Time	95.8%	2023-05-04 04:02:31.627355	2023-05-04 04:02:31.627355	Under	{}
22942	1.5	1.41	2327	Full Time	93.8%	2023-05-04 04:02:31.629854	2023-05-04 04:02:31.629854	Over	{}
22943	1.5	2.80	2327	Full Time	93.8%	2023-05-04 04:02:31.632021	2023-05-04 04:02:31.632021	Under	{}
22944	2.5	2.38	2327	Full Time	95.7%	2023-05-04 04:02:31.634527	2023-05-04 04:02:31.634527	Over	{}
22945	2.5	1.60	2327	Full Time	95.7%	2023-05-04 04:02:31.636889	2023-05-04 04:02:31.636889	Under	{}
22946	3.5	4.80	2327	Full Time	97.3%	2023-05-04 04:02:31.639217	2023-05-04 04:02:31.639217	Over	{}
22947	3.5	1.22	2327	Full Time	97.3%	2023-05-04 04:02:31.641527	2023-05-04 04:02:31.641527	Under	{}
22948	4.5	10.50	2327	Full Time	97.1%	2023-05-04 04:02:31.644046	2023-05-04 04:02:31.644046	Over	{}
22949	4.5	1.07	2327	Full Time	97.1%	2023-05-04 04:02:31.646457	2023-05-04 04:02:31.646457	Under	{}
22950	5.5	21.00	2327	Full Time	97.3%	2023-05-04 04:02:31.648911	2023-05-04 04:02:31.648911	Over	{}
22951	5.5	1.02	2327	Full Time	97.3%	2023-05-04 04:02:31.651208	2023-05-04 04:02:31.651208	Under	{}
22952	0.5	1.50	2327	1st Half	95.4%	2023-05-04 04:02:33.408562	2023-05-04 04:02:33.408562	Over	{}
22953	0.5	2.62	2327	1st Half	95.4%	2023-05-04 04:02:34.929591	2023-05-04 04:02:34.929591	Under	{}
22954	1.5	3.50	2327	1st Half	97.9%	2023-05-04 04:02:34.932015	2023-05-04 04:02:34.932015	Over	{}
22955	1.5	1.36	2327	1st Half	97.9%	2023-05-04 04:02:34.93401	2023-05-04 04:02:34.93401	Under	{}
22956	2.5	10.00	2327	1st Half	95.8%	2023-05-04 04:02:34.936268	2023-05-04 04:02:34.936268	Over	{}
22957	2.5	1.06	2327	1st Half	95.8%	2023-05-04 04:02:34.938403	2023-05-04 04:02:34.938403	Under	{}
22958	3.5	26.00	2327	1st Half	97.2%	2023-05-04 04:02:34.940625	2023-05-04 04:02:34.940625	Over	{}
22959	3.5	1.01	2327	1st Half	97.2%	2023-05-04 04:02:34.942804	2023-05-04 04:02:34.942804	Under	{}
22960	4.5	67.00	2327	1st Half	98.5%	2023-05-04 04:02:34.945331	2023-05-04 04:02:34.945331	Over	{}
22961	4.5	1.00	2327	1st Half	98.5%	2023-05-04 04:02:34.947641	2023-05-04 04:02:34.947641	Under	{}
22962	0.5	1.33	2327	2nd Half	96.4%	2023-05-04 04:02:36.730201	2023-05-04 04:02:36.730201	Over	{}
22963	0.5	3.50	2327	2nd Half	96.4%	2023-05-04 04:02:37.935078	2023-05-04 04:02:37.935078	Under	{}
22964	1.5	2.60	2327	2nd Half	96.3%	2023-05-04 04:02:37.937573	2023-05-04 04:02:37.937573	Over	{}
22965	1.5	1.53	2327	2nd Half	96.3%	2023-05-04 04:02:37.939887	2023-05-04 04:02:37.939887	Under	{}
22966	2.5	5.50	2327	2nd Half	94.4%	2023-05-04 04:02:37.942212	2023-05-04 04:02:37.942212	Over	{}
22967	2.5	1.14	2327	2nd Half	94.4%	2023-05-04 04:02:37.944683	2023-05-04 04:02:37.944683	Under	{}
22968	3.5	15.00	2327	2nd Half	96.4%	2023-05-04 04:02:37.94704	2023-05-04 04:02:37.94704	Over	{}
22969	3.5	1.03	2327	2nd Half	96.4%	2023-05-04 04:02:37.949384	2023-05-04 04:02:37.949384	Under	{}
22970	0.5	1.04	2389	Full Time	96.3%	2023-05-04 04:02:52.035063	2023-05-04 04:02:52.035063	Over	{}
22971	0.5	13.00	2389	Full Time	96.3%	2023-05-04 04:02:52.037883	2023-05-04 04:02:52.037883	Under	{}
22972	1.5	1.25	2389	Full Time	95.2%	2023-05-04 04:02:52.040083	2023-05-04 04:02:52.040083	Over	{}
22973	1.5	4.00	2389	Full Time	95.2%	2023-05-04 04:02:52.042302	2023-05-04 04:02:52.042302	Under	{}
22974	2.5	1.83	2389	Full Time	97.4%	2023-05-04 04:02:52.044558	2023-05-04 04:02:52.044558	Over	{}
22975	2.5	2.08	2389	Full Time	97.4%	2023-05-04 04:02:52.046754	2023-05-04 04:02:52.046754	Under	{}
22976	3.5	3.25	2389	Full Time	97.8%	2023-05-04 04:02:52.048999	2023-05-04 04:02:52.048999	Over	{}
22977	3.5	1.40	2389	Full Time	97.8%	2023-05-04 04:02:52.051155	2023-05-04 04:02:52.051155	Under	{}
22978	4.5	6.40	2389	Full Time	97.5%	2023-05-04 04:02:52.053378	2023-05-04 04:02:52.053378	Over	{}
22981	5.5	1.05	2389	Full Time	95.9%	2023-05-04 04:02:52.05995	2023-05-04 04:02:52.05995	Under	{}
22982	6.5	23.00	2389	Full Time	96.8%	2023-05-04 04:02:52.062119	2023-05-04 04:02:52.062119	Over	{}
22988	2.5	6.50	2389	1st Half	94.8%	2023-05-04 04:02:55.354138	2023-05-04 04:02:55.354138	Over	{}
22979	4.5	1.15	2389	Full Time	97.5%	2023-05-04 04:02:52.055552	2023-05-04 04:02:52.055552	Under	{}
22980	5.5	11.00	2389	Full Time	95.9%	2023-05-04 04:02:52.057726	2023-05-04 04:02:52.057726	Over	{}
22983	6.5	1.01	2389	Full Time	96.8%	2023-05-04 04:02:52.064341	2023-05-04 04:02:52.064341	Under	{}
22984	0.5	1.36	2389	1st Half	95.9%	2023-05-04 04:02:53.818681	2023-05-04 04:02:53.818681	Over	{}
22985	0.5	3.25	2389	1st Half	95.9%	2023-05-04 04:02:55.346928	2023-05-04 04:02:55.346928	Under	{}
22986	1.5	2.70	2389	1st Half	96.4%	2023-05-04 04:02:55.349242	2023-05-04 04:02:55.349242	Over	{}
22987	1.5	1.50	2389	1st Half	96.4%	2023-05-04 04:02:55.351795	2023-05-04 04:02:55.351795	Under	{}
22989	2.5	1.11	2389	1st Half	94.8%	2023-05-04 04:02:55.356594	2023-05-04 04:02:55.356594	Under	{}
22990	3.5	19.00	2389	1st Half	96.8%	2023-05-04 04:02:55.358918	2023-05-04 04:02:55.358918	Over	{}
22991	3.5	1.02	2389	1st Half	96.8%	2023-05-04 04:02:55.361286	2023-05-04 04:02:55.361286	Under	{}
22992	4.5	41.00	2389	1st Half	98.6%	2023-05-04 04:02:55.363606	2023-05-04 04:02:55.363606	Over	{}
22993	4.5	1.01	2389	1st Half	98.6%	2023-05-04 04:02:55.365953	2023-05-04 04:02:55.365953	Under	{}
22994	0.5	1.25	2389	2nd Half	97.0%	2023-05-04 04:02:57.154511	2023-05-04 04:02:57.154511	Over	{}
22995	0.5	4.33	2389	2nd Half	97.0%	2023-05-04 04:02:58.355185	2023-05-04 04:02:58.355185	Under	{}
22996	1.5	2.10	2389	2nd Half	96.9%	2023-05-04 04:02:58.357931	2023-05-04 04:02:58.357931	Over	{}
22997	1.5	1.80	2389	2nd Half	96.9%	2023-05-04 04:02:58.36031	2023-05-04 04:02:58.36031	Under	{}
22998	2.5	4.33	2389	2nd Half	95.2%	2023-05-04 04:02:58.36268	2023-05-04 04:02:58.36268	Over	{}
22999	2.5	1.22	2389	2nd Half	95.2%	2023-05-04 04:02:58.365032	2023-05-04 04:02:58.365032	Under	{}
23000	3.5	11.00	2389	2nd Half	95.9%	2023-05-04 04:02:58.367341	2023-05-04 04:02:58.367341	Over	{}
23001	3.5	1.05	2389	2nd Half	95.9%	2023-05-04 04:02:58.369674	2023-05-04 04:02:58.369674	Under	{}
\.


--
-- TOC entry 3104 (class 0 OID 16438)
-- Dependencies: 206
-- Data for Name: OddsSafariMatch; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."OddsSafariMatch" (id, home_team, guest_team, date_time, created, updated) FROM stdin;
2396	Aris Salonika	AEK	2023-05-07 20:00:00+01	2023-05-04 04:04:37.594935	2023-05-04 04:04:37.594935
2397	Olympiacos	Panathinaikos	2023-05-07 20:00:00+01	2023-05-04 04:04:51.882679	2023-05-04 04:04:51.882679
2398	Volos	PAOK	2023-05-07 20:00:00+01	2023-05-04 04:05:05.758467	2023-05-04 04:05:05.758467
2467	Aris Salonika	AEK	2023-05-09 00:00:00+01	2023-05-07 04:03:09.688606	2023-05-07 04:03:09.688606
2468	Olympiacos	Panathinaikos	2023-05-09 00:00:00+01	2023-05-07 04:03:25.628091	2023-05-07 04:03:25.628091
2469	Volos	PAOK	2023-05-09 00:00:00+01	2023-05-07 04:03:41.479236	2023-05-07 04:03:41.479236
2470	Asteras Tripolis	Atromitos	2023-05-13 20:00:00+01	2023-05-07 04:03:56.316642	2023-05-07 04:03:56.316642
2471	Panetolikos	OFI	2023-05-13 20:00:00+01	2023-05-07 04:04:09.185428	2023-05-07 04:04:09.185428
1644	AEK	Olympiacos	2023-05-03 18:00:00+01	2023-04-29 06:09:21.620415	2023-04-29 06:09:21.620415
1645	Aris Salonika	Volos	2023-05-03 18:00:00+01	2023-04-29 06:09:33.004843	2023-04-29 06:09:33.004843
1646	Panathinaikos	PAOK	2023-05-03 18:00:00+01	2023-04-29 06:09:43.008413	2023-04-29 06:09:43.008413
1707	Atromitos	Panetolikos	2023-05-06 18:00:00+01	2023-05-01 06:07:22.867941	2023-05-01 06:07:22.867941
1708	Lamia	Levadiakos	2023-05-06 18:00:00+01	2023-05-01 06:07:32.779445	2023-05-01 06:07:32.779445
1709	OFI	Ionikos	2023-05-06 18:00:00+01	2023-05-01 06:07:42.21216	2023-05-01 06:07:42.21216
1710	PAS Giannina	Asteras Tripolis	2023-05-06 18:00:00+01	2023-05-01 06:07:52.110146	2023-05-01 06:07:52.110146
\.


--
-- TOC entry 3105 (class 0 OID 16446)
-- Dependencies: 207
-- Data for Name: OddsSafariOverUnder; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."OddsSafariOverUnder" (id, goals, odds, match_id, half, payout, created, updated, type, bet_links) FROM stdin;
23010	2.5	2.07	2396	Full Time	2.31%	2023-05-04 04:04:48.675236	2023-05-04 04:04:48.675236	Over	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145,https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
23011	2.5	1.85	2396	Full Time	2.31%	2023-05-04 04:04:48.681062	2023-05-04 04:04:48.681062	Under	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
23012	2.5	2.40	2397	Full Time	2.93%	2023-05-04 04:05:03.174599	2023-05-04 04:05:03.174599	Over	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
23013	2.5	1.63	2397	Full Time	2.93%	2023-05-04 04:05:03.179998	2023-05-04 04:05:03.179998	Under	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
23014	2.5	1.77	2398	Full Time	0.93%	2023-05-04 04:05:17.205687	2023-05-04 04:05:17.205687	Over	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
23015	2.5	2.25	2398	Full Time	0.93%	2023-05-04 04:05:17.2113	2023-05-04 04:05:17.2113	Under	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
16378	2.5	2.08	1644	Full Time	0.70%	2023-04-29 06:09:30.82503	2023-04-29 06:09:30.82503	Over	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
16379	2.5	1.90	1644	Full Time	0.70%	2023-04-29 06:09:30.829042	2023-04-29 06:09:30.829042	Under	{}
16380	2.5	1.87	1645	Full Time	3.36%	2023-04-29 06:09:41.201637	2023-04-29 06:09:41.201637	Over	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
16381	2.5	2.00	1645	Full Time	3.36%	2023-04-29 06:09:41.204308	2023-04-29 06:09:41.204308	Under	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
16382	2.5	2.55	1646	Full Time	1.31%	2023-04-29 06:09:51.128396	2023-04-29 06:09:51.128396	Over	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
16383	2.5	1.61	1646	Full Time	1.31%	2023-04-29 06:09:51.136805	2023-04-29 06:09:51.136805	Under	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
16978	2.5	2.35	1707	Full Time	1.70%	2023-05-01 06:07:30.836906	2023-05-01 06:07:30.836906	Over	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
16979	2.5	1.69	1707	Full Time	1.70%	2023-05-01 06:07:30.841219	2023-05-01 06:07:30.841219	Under	{https://record.affiliates.betshop.gr/_xVrm1kU5pcRLcRLGwHoTKWNd7ZgqdRLk/1/}
16980	2.5	2.65	1708	Full Time	2.20%	2023-05-01 06:07:40.67726	2023-05-01 06:07:40.67726	Over	{https://record.affiliates.betshop.gr/_xVrm1kU5pcRLcRLGwHoTKWNd7ZgqdRLk/1/}
16981	2.5	1.55	1708	Full Time	2.20%	2023-05-01 06:07:40.685742	2023-05-01 06:07:40.685742	Under	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
16982	2.5	2.18	1709	Full Time	4.80%	2023-05-01 06:07:50.202917	2023-05-01 06:07:50.202917	Over	{https://record.affiliates.betshop.gr/_xVrm1kU5pcRLcRLGwHoTKWNd7ZgqdRLk/1/}
16983	2.5	1.69	1709	Full Time	4.80%	2023-05-01 06:07:50.206659	2023-05-01 06:07:50.206659	Under	{https://record.affiliates.betshop.gr/_xVrm1kU5pcRLcRLGwHoTKWNd7ZgqdRLk/1/}
16984	2.5	3.05	1710	Full Time	3.11%	2023-05-01 06:08:00.769798	2023-05-01 06:08:00.769798	Over	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
16985	2.5	1.42	1710	Full Time	3.11%	2023-05-01 06:08:00.774402	2023-05-01 06:08:00.774402	Under	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
23604	2.5	2.05	2467	Full Time	2.76%	2023-05-07 04:03:22.716561	2023-05-07 04:03:22.716561	Over	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
23605	2.5	1.85	2467	Full Time	2.76%	2023-05-07 04:03:22.730212	2023-05-07 04:03:22.730212	Under	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
23606	2.5	2.40	2468	Full Time	3.28%	2023-05-07 04:03:37.727583	2023-05-07 04:03:37.727583	Over	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
23607	2.5	1.62	2468	Full Time	3.28%	2023-05-07 04:03:37.733514	2023-05-07 04:03:37.733514	Under	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
23608	2.5	1.82	2469	Full Time	-0.61%	2023-05-07 04:03:52.816793	2023-05-07 04:03:52.816793	Over	{}
23609	2.5	2.25	2469	Full Time	-0.61%	2023-05-07 04:03:52.822794	2023-05-07 04:03:52.822794	Under	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
23610	2.5	2.20	2470	Full Time	5.71%	2023-05-07 04:04:06.974996	2023-05-07 04:04:06.974996	Over	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
23611	2.5	1.65	2470	Full Time	5.71%	2023-05-07 04:04:06.980367	2023-05-07 04:04:06.980367	Under	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
23612	2.5	2.10	2471	Full Time	4.55%	2023-05-07 04:04:20.245281	2023-05-07 04:04:20.245281	Over	{}
23613	2.5	1.75	2471	Full Time	4.55%	2023-05-07 04:04:20.251416	2023-05-07 04:04:20.251416	Under	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
\.


--
-- TOC entry 3107 (class 0 OID 16457)
-- Dependencies: 209
-- Data for Name: OverUnderHistorical; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."OverUnderHistorical" (id, "Date_Time", "Home_Team", "Guest_Team", "Type", "Half", "Odds_bet", "Margin", won, "Goals", "Home_Team_Goals", "Guest_Team_Goals", "Home_Team_Goals_1st_Half", "Home_Team_Goals_2nd_Half", "Guest_Team_Goals_1st_Half", "Guest_Team_Goals_2nd_Half", "Payout", "Bet_link") FROM stdin;
21	2023-02-19 17:30:00+00	Panetolikos	Ionikos	Under	\N	3.25	0	Lost	0.5	1	1	0	1	0	0	3.63%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
20	2023-02-19 17:30:00+00	Panetolikos	Ionikos	Under	\N	3.25	0	Lost	0.5	1	1	0	1	0	0	3.63%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
10	2023-02-19 14:00:00+00	Lamia	Olympiacos	Over	\N	2	0	Won	2.5	0	0	0	0	1	2	2.56%	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/,https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
11	2023-02-19 14:00:00+00	Lamia	Olympiacos	Under	\N	2.95	0	Lost	0.5	0	0	0	0	1	2	2.78%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
1	2023-02-18 15:00:00+00	Panathinaikos	Volos	Over	\N	2.17	0	Lost	2.5	2	2	0	2	0	0	0.72%	{https://record.affiliates.betshop.gr/_xVrm1kU5pcRLcRLGwHoTKWNd7ZgqdRLk/1/}
2	2023-02-18 15:00:00+00	Panathinaikos	Volos	Under	\N	2.8	0	Lost	0.5	2	2	0	2	0	0	2.33%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
3	2023-02-18 15:00:00+00	Panathinaikos	Volos	Under	\N	3.7	0.9	Lost	0.5	2	2	0	2	0	0	3.80%	{}
12	2023-02-19 14:00:00+00	Lamia	Olympiacos	Under	\N	3.9	0.95	Lost	0.5	0	0	0	0	1	2	4.20%	{}
4	2023-02-18 15:00:00+00	Panathinaikos	Volos	Under	\N	3.7	0	Lost	0.5	2	2	0	2	0	0	3.80%	{}
5	2023-02-18 15:00:00+00	Panathinaikos	Volos	Under	\N	1.83	0	Lost	2.5	2	2	0	2	0	0	0.72%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
13	2023-02-19 14:00:00+00	Lamia	Olympiacos	Under	\N	3.9	0	Lost	0.5	0	0	0	0	1	2	4.20%	{}
14	2023-02-19 14:00:00+00	Lamia	Olympiacos	Under	\N	1.9	0	Lost	2.5	0	0	0	0	1	2	2.56%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
6	2023-02-18 18:00:00+00	Asteras Tripolis	PAS Giannina	Over	\N	2.55	0	Lost	2.5	1	1	1	0	1	0	2.07%	{https://record.affiliates.betshop.gr/_xVrm1kU5pcRLcRLGwHoTKWNd7ZgqdRLk/1/}
58	2023-02-26 14:00:00+00	Ionikos	OFI	Over	Full Time	2.30	0.00	Lost	2.5	0	0	0	0	0	2	4.26%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
59	2023-02-26 14:00:00+00	Ionikos	OFI	Under	2nd Half	2.60	0.00	Lost	0.5	0	0	0	0	0	2	2.11%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
63	2023-02-26 14:00:00+00	Levadiakos	Panetolikos	Under	1st Half	2.45	0.00	Lost	0.5	0	0	0	0	0	0	3.21%	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
64	2023-02-26 14:00:00+00	Levadiakos	Panetolikos	Under	1st Half	2.45	0.00	Lost	0.5	0	0	0	0	0	0	3.21%	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
57	2023-02-25 18:30:00+00	Olympiacos	Panathinaikos	Under	Full Time	1.74	0	Won	2.5	0	0	0	0	0	0	3.83%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107,https://partners.opapaffiliates.gr/redirect.aspx?pid=2460&bid=1759}
53	2023-02-25 17:00:00+00	PAS Giannina	PAOK	Under	Full Time	2.1	0	Won	2.5	0	0	0	0	0	0	4.25%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
50	2023-02-25 17:00:00+00	PAS Giannina	PAOK	Over	Full Time	1.76	0	Lost	2.5	0	0	0	0	0	0	4.25%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
51	2023-02-25 17:00:00+00	PAS Giannina	PAOK	Under	1st Half	3.3	0	Lost	0.5	0	0	0	0	0	0	2.69%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
49	2023-02-25 15:30:00+00	AEK	Asteras Tripolis	Under	Full Time	2.1	0	Won	2.5	2	2	1	1	0	0	4.25%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
46	2023-02-25 15:30:00+00	AEK	Asteras Tripolis	Over	Full Time	1.76	0	Lost	2.5	2	2	1	1	0	0	4.25%	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
47	2023-02-25 15:30:00+00	AEK	Asteras Tripolis	Under	1st Half	3.3	0	Lost	0.5	2	2	1	1	0	0	2.69%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
44	2023-02-24 18:00:00+00	Volos	Lamia	Under	Full Time	1.81	0	Won	2.5	1	1	0	1	1	0	1.73%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
37	2023-02-24 18:00:00+00	Volos	Lamia	Over	Full Time	2.15	0.1	Lost	2.5	1	1	0	1	1	0	1.73%	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
38	2023-02-24 18:00:00+00	Volos	Lamia	Over	Full Time	2.15	0	Lost	2.5	1	1	0	1	1	0	1.73%	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
40	2023-02-24 18:00:00+00	Volos	Lamia	Under	1st Half	2.9	0	Lost	0.5	1	1	0	1	1	0	1.14%	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
33	2023-02-20 17:30:00+00	OFI	Aris Salonika	Over	\N	2.4	0	Won	2.5	0	3	0	0	2	1	3.28%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
34	2023-02-20 17:30:00+00	OFI	Aris Salonika	Under	\N	2.6	0	Lost	0.5	0	3	0	0	2	1	2.89%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
35	2023-02-20 17:30:00+00	OFI	Aris Salonika	Under	\N	3.4	0.8	Lost	0.5	0	3	0	0	2	1	4.40%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
30	2023-02-20 16:00:00+00	Atromitos	Levadiakos	Under	\N	3.4	0.85	Lost	0.5	1	1	1	0	0	0	4.40%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
31	2023-02-20 16:00:00+00	Atromitos	Levadiakos	Under	\N	3.4	0	Lost	0.5	1	1	1	0	0	0	4.40%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
32	2023-02-20 16:00:00+00	Atromitos	Levadiakos	Under	\N	3.4	0	Lost	0.5	1	1	1	0	0	0	4.40%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
70	2023-03-04 18:00:00+00	Asteras Tripolis	Atromitos	Over	Full Time	2.30	0.00	Lost	2.5	1	1	0	1	1	0	4.61%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107,https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145,https://record.affiliates.betshop.gr/_xVrm1kU5pcRLcRLGwHoTKWNd7ZgqdRLk/1/}
71	2023-03-04 18:00:00+00	Asteras Tripolis	Atromitos	Under	1st Half	2.55	0.00	Lost	0.5	1	1	0	1	1	0	2.83%	{http://www.sportingbet.gr/,https://sports.bwin.gr/el/sports?wm=5273373,https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
60	2023-02-26 14:00:00+00	Ionikos	OFI	Under	1st Half	2.60	0.00	Lost	0.5	0	0	0	0	0	2	2.11%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
48	2023-02-25 15:30:00+00	AEK	Asteras Tripolis	Under	2nd Half	4.4	0	Lost	0.5	2	2	1	1	0	0	4.36%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
15	2023-02-19 17:30:00+00	Panetolikos	Ionikos	Over	\N	2.5	0	Lost	2.5	1	1	0	1	0	0	1.70%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107,https://partners.opapaffiliates.gr/redirect.aspx?pid=2460&bid=1759,https://record.affiliates.betshop.gr/_xVrm1kU5pcRLcRLGwHoTKWNd7ZgqdRLk/1/}
16	2023-02-19 17:30:00+00	Panetolikos	Ionikos	Over	\N	2.5	0	Lost	2.5	1	1	0	1	0	0	1.70%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107,https://partners.opapaffiliates.gr/redirect.aspx?pid=2460&bid=1759,https://record.affiliates.betshop.gr/_xVrm1kU5pcRLcRLGwHoTKWNd7ZgqdRLk/1/}
17	2023-02-19 17:30:00+00	Panetolikos	Ionikos	Under	\N	2.45	0	Lost	0.5	1	1	0	1	0	0	3.21%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
7	2023-02-18 18:00:00+00	Asteras Tripolis	PAS Giannina	Under	\N	2.45	0	Lost	0.5	1	1	1	0	1	0	3.21%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
8	2023-02-18 18:00:00+00	Asteras Tripolis	PAS Giannina	Under	\N	3.25	0.8	Lost	0.5	1	1	1	0	1	0	3.63%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
9	2023-02-18 18:00:00+00	Asteras Tripolis	PAS Giannina	Under	\N	3.25	0	Lost	0.5	1	1	1	0	1	0	3.63%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
107	2023-03-18 17:30:00+00	Atromitos	Ionikos	Over	Full Time	2.72	0.00	Lost	2.5	2	2	1	1	0	0	0.46%	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
100	2023-03-18 15:00:00+00	Asteras Tripolis	Panetolikos	Over	Full Time	2.52	0.00	Lost	2.5	2	2	1	1	0	1	2.14%	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
94	2023-03-06 17:30:00+00	Panathinaikos	Panetolikos	Over	Full Time	2.03	0.01	Lost	2.5	2	0	0	2	0	0	4.32%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
95	2023-03-06 17:30:00+00	Panathinaikos	Panetolikos	Over	Full Time	2.03	0.00	Lost	2.5	2	0	0	2	0	0	4.32%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
84	2023-03-05 17:30:00+00	OFI	AEK	Over	Full Time	2.00	0.00	Lost	2.5	0	0	0	0	1	2	1.78%	{}
85	2023-03-05 17:30:00+00	OFI	AEK	Under	1st Half	2.95	0.00	Lost	0.5	0	0	0	0	1	2	3.23%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
86	2023-03-05 17:30:00+00	OFI	AEK	Under	2nd Half	3.90	0.00	Lost	0.5	0	0	0	0	1	2	4.77%	{}
80	2023-03-05 15:30:00+00	Lamia	Aris Salonika	Over	Full Time	2.09	0.00	Lost	2.5	2	2	2	0	1	0	3.00%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
81	2023-03-05 15:30:00+00	Lamia	Aris Salonika	Under	1st Half	2.90	0.00	Lost	0.5	2	2	2	0	1	0	2.45%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
82	2023-03-05 15:30:00+00	Lamia	Aris Salonika	Under	2nd Half	3.75	0.00	Lost	0.5	2	2	2	0	1	0	5.13%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
79	2023-03-05 15:00:00+00	PAS Giannina	Volos	Under	2nd Half	3.40	0.00	Lost	0.5	0	0	0	0	0	1	4.40%	{http://www.sportingbet.gr/,https://sports.bwin.gr/el/sports?wm=5273373,https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/,http://www.stoiximan.gr/,https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
73	2023-03-04 18:00:00+00	Asteras Tripolis	Atromitos	Under	2nd Half	3.40	0.00	Lost	0.5	1	1	0	1	1	0	4.40%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
61	2023-02-26 14:00:00+00	Levadiakos	Panetolikos	Over	Full Time	2.60	0.00	Lost	2.5	0	0	0	0	0	0	1.72%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
62	2023-02-26 14:00:00+00	Levadiakos	Panetolikos	Over	Full Time	2.60	0.00	Lost	2.5	0	0	0	0	0	0	1.72%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
54	2023-02-25 18:30:00+00	Olympiacos	Panathinaikos	Over	Full Time	2.15	0	Lost	2.5	0	0	0	0	0	0	3.83%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
55	2023-02-25 18:30:00+00	Olympiacos	Panathinaikos	Under	1st Half	2.8	0	Lost	0.5	0	0	0	0	0	0	1.48%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
56	2023-02-25 18:30:00+00	Olympiacos	Panathinaikos	Under	2nd Half	3.75	0	Lost	0.5	0	0	0	0	0	0	3.47%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
39	2023-02-24 18:00:00+00	Volos	Lamia	Over	1st Half	2.15	0	Won	2.5	1	1	0	1	1	0	1.73%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
36	2023-02-20 17:30:00+00	OFI	Aris Salonika	Under	\N	3.4	0	Lost	0.5	0	3	0	0	2	1	4.40%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
26	2023-02-20 16:00:00+00	Atromitos	Levadiakos	Over	\N	2.4	0	Lost	2.5	1	1	1	0	0	0	3.46%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
27	2023-02-20 16:00:00+00	Atromitos	Levadiakos	Under	\N	2.55	0.05	Lost	0.5	1	1	1	0	0	0	2.83%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
28	2023-02-20 16:00:00+00	Atromitos	Levadiakos	Under	\N	3.4	0.9	Lost	0.5	1	1	1	0	0	0	4.40%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
29	2023-02-20 16:00:00+00	Atromitos	Levadiakos	Under	\N	2.55	0	Lost	0.5	1	1	1	0	0	0	2.83%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
22	2023-02-19 18:30:00+00	PAOK	AEK	Over	\N	2.45	0	Lost	2.5	2	0	1	1	0	0	2.48%	{https://record.affiliates.betshop.gr/_xVrm1kU5pcRLcRLGwHoTKWNd7ZgqdRLk/1/}
23	2023-02-19 18:30:00+00	PAOK	AEK	Under	\N	2.5	0	Lost	0.5	2	0	1	1	0	0	2.44%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
24	2023-02-19 18:30:00+00	PAOK	AEK	Under	\N	3.25	0.75	Lost	0.5	2	0	1	1	0	0	5.47%	{http://www.stoiximan.gr/,https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
115	2023-03-19 15:30:00+00	Volos	Olympiacos	Under	1st Half	3.45	0.00	Lost	0.5	0	0	0	0	2	1	1.94%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
108	2023-03-18 17:30:00+00	Atromitos	Ionikos	Under	1st Half	2.40	0.00	Lost	0.5	2	2	1	1	0	0	3.28%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
96	2023-03-06 17:30:00+00	Panathinaikos	Panetolikos	Under	1st Half	2.95	0.00	Lost	0.5	2	0	0	2	0	0	2.78%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
87	2023-03-05 17:30:00+00	OFI	AEK	Under	Full Time	1.93	0.00	Lost	2.5	0	0	0	0	1	2	1.78%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
18	2023-02-19 17:30:00+00	Panetolikos	Ionikos	Under	\N	3.25	0.8	Lost	0.5	1	1	0	1	0	0	3.63%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
19	2023-02-19 17:30:00+00	Panetolikos	Ionikos	Under	\N	3.25	0.75	Lost	0.5	1	1	0	1	0	0	3.63%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
117	2023-03-19 15:30:00+00	Volos	Olympiacos	Under	Full Time	2.20	0.00	Lost	2.5	0	0	0	0	2	1	1.61%	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
113	2023-03-19 15:30:00+00	Volos	Olympiacos	Over	Full Time	1.78	0.00	Lost	2.5	0	0	0	0	2	1	1.61%	{}
110	2023-03-18 19:00:00+00	Lamia	PAS Giannina	Over	Full Time	2.77	0.00	Lost	2.5	2	0	2	0	0	0	1.44%	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
122	2023-03-19 19:30:00+00	AEK	Panathinaikos	Over	Full Time	2.60	0.00	Lost	2.5	0	0	0	0	0	0	2.50%	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
111	2023-03-18 19:00:00+00	Lamia	PAS Giannina	Under	1st Half	2.45	0.00	Lost	0.5	2	0	2	0	0	0	1.40%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
103	2023-03-18 15:30:00+00	OFI	Levadiakos	Over	Full Time	2.45	0.00	Lost	2.5	1	1	0	1	0	1	-0.36%	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
104	2023-03-18 15:30:00+00	OFI	Levadiakos	Under	1st Half	2.60	0.00	Lost	0.5	1	1	0	1	0	1	2.89%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
105	2023-03-18 15:30:00+00	OFI	Levadiakos	Under	2nd Half	3.25	0.00	Lost	0.5	1	1	0	1	0	1	5.47%	{http://www.sportingbet.gr/,https://sports.bwin.gr/el/sports?wm=5273373,https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=,https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
101	2023-03-18 15:00:00+00	Asteras Tripolis	Panetolikos	Under	1st Half	2.50	0.00	Lost	0.5	2	2	1	1	0	1	3.56%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
99	2023-03-06 17:30:00+00	Panathinaikos	Panetolikos	Under	Full Time	1.81	0.00	Lost	2.5	2	0	0	2	0	0	4.32%	{https://record.affiliates.betshop.gr/_xVrm1kU5pcRLcRLGwHoTKWNd7ZgqdRLk/1/}
88	2023-03-05 18:30:00+00	PAOK	Ionikos	Over	Full Time	1.92	0.01	Lost	2.5	6	0	4	2	0	0	3.26%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
83	2023-03-05 15:30:00+00	Lamia	Aris Salonika	Under	Full Time	1.81	0.00	Lost	2.5	2	2	2	0	1	0	3.00%	{https://record.affiliates.betshop.gr/_xVrm1kU5pcRLcRLGwHoTKWNd7ZgqdRLk/1/}
77	2023-03-05 15:00:00+00	PAS Giannina	Volos	Over	Full Time	2.30	0.00	Lost	2.5	0	0	0	0	0	1	3.59%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107,https://record.affiliates.betshop.gr/_xVrm1kU5pcRLcRLGwHoTKWNd7ZgqdRLk/1/}
78	2023-03-05 15:00:00+00	PAS Giannina	Volos	Under	1st Half	2.60	0.00	Lost	0.5	0	0	0	0	0	1	4.08%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436,https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
72	2023-03-04 18:00:00+00	Asteras Tripolis	Atromitos	Under	2nd Half	3.40	0.00	Lost	0.5	1	1	0	1	1	0	4.40%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
67	2023-02-26 17:30:00+00	Aris Salonika	Atromitos	Over	Full Time	2.60	0.00	Lost	2.5	2	1	2	0	0	1	1.72%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
68	2023-02-26 17:30:00+00	Aris Salonika	Atromitos	Under	1st Half	2.45	0.00	Lost	0.5	2	1	2	0	0	1	3.21%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
69	2023-02-26 17:30:00+00	Aris Salonika	Atromitos	Under	2nd Half	3.25	0.00	Lost	0.5	2	1	2	0	0	1	3.63%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
65	2023-02-26 14:00:00+00	Levadiakos	Panetolikos	Under	2nd Half	3.25	0.00	Lost	0.5	0	0	0	0	0	0	3.63%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
66	2023-02-26 14:00:00+00	Levadiakos	Panetolikos	Under	2nd Half	3.25	0.00	Lost	0.5	0	0	0	0	0	0	3.63%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
42	2023-02-24 18:00:00+00	Volos	Lamia	Under	2nd Half	3.75	0	Lost	0.5	1	1	0	1	1	0	4.02%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
43	2023-02-24 18:00:00+00	Volos	Lamia	Under	1st Half	1.81	0.73	Lost	2.5	1	1	0	1	1	0	1.73%	{https://partners.opapaffiliates.gr/redirect.aspx?pid=2460&bid=1759}
45	2023-02-24 18:00:00+00	Volos	Lamia	Under	1st Half	1.81	0	Lost	2.5	1	1	0	1	1	0	1.73%	{https://partners.opapaffiliates.gr/redirect.aspx?pid=2460&bid=1759}
41	2023-02-24 18:00:00+00	Volos	Lamia	Under	2nd Half	3.75	0	Lost	0.5	1	1	0	1	1	0	4.02%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
25	2023-02-19 18:30:00+00	PAOK	AEK	Under	\N	3.25	0	Lost	0.5	2	0	1	1	0	0	5.47%	{http://www.stoiximan.gr/,https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
114	2023-03-19 15:30:00+00	Volos	Olympiacos	Over	1st Half	1.78	0.00	Won	2.5	0	0	0	0	2	1	1.61%	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
112	2023-03-18 19:00:00+00	Lamia	PAS Giannina	Under	2nd Half	3.25	0.00	Lost	0.5	2	0	2	0	0	0	2.64%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
89	2023-03-05 18:30:00+00	PAOK	Ionikos	Over	Full Time	1.92	0.00	Lost	2.5	6	0	4	2	0	0	3.26%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
120	2023-03-19 17:00:00+00	Aris Salonika	PAOK	Under	1st Half	2.45	0.00	Lost	0.5	1	1	1	0	0	2	4.32%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
121	2023-03-19 17:00:00+00	Aris Salonika	PAOK	Under	2nd Half	3.25	0.00	Lost	0.5	1	1	1	0	0	2	3.63%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
90	2023-03-05 18:30:00+00	PAOK	Ionikos	Under	1st Half	3.10	0.00	Lost	0.5	6	0	4	2	0	0	2.61%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
91	2023-03-05 18:30:00+00	PAOK	Ionikos	Under	2nd Half	4.05	0.05	Lost	0.5	6	0	4	2	0	0	4.48%	{http://www.stoiximan.gr/}
92	2023-03-05 18:30:00+00	PAOK	Ionikos	Under	2nd Half	4.05	0.00	Lost	0.5	6	0	4	2	0	0	4.48%	{http://www.stoiximan.gr/}
148	2023-04-02 16:00:00+01	Panathinaikos	Volos	Over	Full Time	1.77	0.00	Lost	2.5	0	0	0	0	0	0	3.95%	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
149	2023-04-02 16:00:00+01	Panathinaikos	Volos	Under	1st Half	3.40	0.05	Lost	0.5	0	0	0	0	0	0	4.92%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
150	2023-04-02 16:00:00+01	Panathinaikos	Volos	Under	1st Half	3.40	0.00	Lost	0.5	0	0	0	0	0	0	4.92%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
151	2023-04-02 16:00:00+01	Panathinaikos	Volos	Under	2nd Half	4.50	0.17	Lost	0.5	0	0	0	0	0	0	5.26%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
143	2023-04-01 19:00:00+01	Ionikos	Asteras Tripolis	Over	Full Time	2.75	0.05	Lost	2.5	1	0	1	0	0	0	2.94%	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
140	2023-04-01 17:30:00+01	PAS Giannina	OFI	Over	Full Time	2.55	0.00	Lost	2.5	0	0	0	0	1	0	3.60%	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
141	2023-04-01 17:30:00+01	PAS Giannina	OFI	Under	1st Half	2.39	0.00	Lost	0.5	0	0	0	0	1	0	5.21%	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
142	2023-04-01 17:30:00+01	PAS Giannina	OFI	Under	2nd Half	3.25	0.00	Lost	0.5	0	0	0	0	1	0	5.12%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
136	2023-04-01 15:30:00+01	Panetolikos	Lamia	Over	Full Time	2.60	0.00	Lost	2.5	1	1	0	1	0	3	3.68%	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
137	2023-04-01 15:30:00+01	Panetolikos	Lamia	Under	1st Half	2.35	0.00	Lost	0.5	1	1	0	1	0	3	5.84%	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
138	2023-04-01 15:30:00+01	Panetolikos	Lamia	Under	2nd Half	3.25	0.00	Lost	0.5	1	1	0	1	0	3	4.62%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
139	2023-04-01 15:30:00+01	Panetolikos	Lamia	Under	2nd Half	3.25	0.00	Lost	0.5	1	1	0	1	0	3	4.62%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
125	2023-04-01 15:00:00+01	Levadiakos	Atromitos	Over	Full Time	2.70	0.05	Lost	2.5	1	1	0	1	0	1	3.57%	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
126	2023-04-01 15:00:00+01	Levadiakos	Atromitos	Over	Full Time	2.70	0.05	Lost	2.5	1	1	0	1	0	1	3.57%	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
127	2023-04-01 15:00:00+01	Levadiakos	Atromitos	Over	Full Time	2.70	0.00	Lost	2.5	1	1	0	1	0	1	3.57%	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
128	2023-04-01 15:00:00+01	Levadiakos	Atromitos	Over	Full Time	2.70	0.00	Lost	2.5	1	1	0	1	0	1	3.57%	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
129	2023-04-01 15:00:00+01	Levadiakos	Atromitos	Under	1st Half	2.35	0.00	Lost	0.5	1	1	0	1	0	1	5.84%	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
130	2023-04-01 15:00:00+01	Levadiakos	Atromitos	Under	1st Half	2.35	0.00	Lost	0.5	1	1	0	1	0	1	5.84%	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
102	2023-03-18 15:00:00+00	Asteras Tripolis	Panetolikos	Under	2nd Half	3.25	0.00	Lost	0.5	2	2	1	1	0	1	4.62%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
98	2023-03-06 17:30:00+00	Panathinaikos	Panetolikos	Under	2nd Half	3.75	0.00	Lost	0.5	2	0	0	2	0	0	5.13%	{http://www.sportingbet.gr/,https://sports.bwin.gr/el/sports?wm=5273373,https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
158	2023-04-02 19:00:00+01	Olympiacos	Aris Salonika	Over	Full Time	2.20	0.00	Lost	2.5	2	2	1	1	0	2	3.47%	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
159	2023-04-02 19:00:00+01	Olympiacos	Aris Salonika	Under	1st Half	2.70	0.00	Lost	0.5	2	2	1	1	0	2	5.92%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
155	2023-04-02 17:30:00+01	PAOK	AEK	Over	Full Time	2.55	0.00	Lost	2.5	0	0	0	0	0	1	3.60%	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
156	2023-04-02 17:30:00+01	PAOK	AEK	Under	1st Half	2.45	0.00	Lost	0.5	0	0	0	0	0	1	4.28%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
157	2023-04-02 17:30:00+01	PAOK	AEK	Under	2nd Half	3.25	0.00	Lost	0.5	0	0	0	0	0	1	3.63%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
144	2023-04-01 19:00:00+01	Ionikos	Asteras Tripolis	Over	Full Time	2.75	0.00	Lost	2.5	1	0	1	0	0	0	2.94%	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
145	2023-04-01 19:00:00+01	Ionikos	Asteras Tripolis	Under	1st Half	2.26	0.00	Lost	0.5	1	0	1	0	0	0	6.32%	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
146	2023-04-01 19:00:00+01	Ionikos	Asteras Tripolis	Under	2nd Half	3.00	0.00	Lost	0.5	1	0	1	0	0	0	5.95%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107,https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
147	2023-04-01 19:00:00+01	Ionikos	Asteras Tripolis	Under	2nd Half	3.00	0.00	Lost	0.5	1	0	1	0	0	0	5.95%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107,https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
163	2023-04-10 12:45:00+01	Anagennisi Karditsas	PAOK B	Over	2nd Half	2.24	0.00	Lost	1.5	\N	\N	\N	\N	\N	\N	7.01%	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
164	2023-04-10 12:45:00+01	Anagennisi Karditsas	PAOK B	Over	Full Time	2.05	0.00	Lost	2.5	\N	\N	\N	\N	\N	\N	5.88%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436,https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
165	2023-04-10 12:45:00+01	Anagennisi Karditsas	PAOK B	Under	1st Half	2.60	0.00	Lost	0.5	\N	\N	\N	\N	\N	\N	6.91%	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
166	2023-04-10 12:45:00+01	Anagennisi Karditsas	PAOK B	Under	Full Time	1.74	0.00	Lost	2.5	\N	\N	\N	\N	\N	\N	5.88%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
167	2023-04-10 12:45:00+01	Apollon Pontou	Niki Volou	Over	2nd Half	2.50	0.00	Lost	1.5	\N	\N	\N	\N	\N	\N	7.43%	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
168	2023-04-10 12:45:00+01	Apollon Pontou	Niki Volou	Over	Full Time	2.40	0.00	Lost	2.5	\N	\N	\N	\N	\N	\N	6.56%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145,https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
169	2023-04-10 12:45:00+01	Apollon Pontou	Niki Volou	Under	1st Half	2.36	0.00	Lost	0.5	\N	\N	\N	\N	\N	\N	6.81%	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
170	2023-04-10 12:45:00+01	Panathinaikos B	Iraklis	Over	2nd Half	2.45	0.00	Lost	1.5	\N	\N	\N	\N	\N	\N	7.35%	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
171	2023-04-10 12:45:00+01	Panathinaikos B	Iraklis	Over	Full Time	2.31	0.00	Lost	2.5	\N	\N	\N	\N	\N	\N	1.08%	{https://record.affiliates.betshop.gr/_xVrm1kU5pcRLcRLGwHoTKWNd7ZgqdRLk/1/,http://www.sportingbet.gr/,https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
172	2023-04-10 12:45:00+01	Panathinaikos B	Iraklis	Under	1st Half	2.40	0.00	Lost	0.5	\N	\N	\N	\N	\N	\N	7.69%	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
173	2023-04-10 12:45:00+01	Panathinaikos B	Iraklis	Under	Full Time	1.73	0.00	Lost	2.5	\N	\N	\N	\N	\N	\N	1.08%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
174	2023-04-10 12:45:00+01	PAO Rouf	AEK B	Over	2nd Half	2.13	0.00	Lost	1.5	\N	\N	\N	\N	\N	\N	7.02%	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
175	2023-04-10 12:45:00+01	PAO Rouf	AEK B	Over	Full Time	2.00	0.00	Lost	2.5	\N	\N	\N	\N	\N	\N	5.26%	{}
176	2023-04-10 12:45:00+01	PAO Rouf	AEK B	Under	1st Half	2.75	0.00	Lost	0.5	\N	\N	\N	\N	\N	\N	7.23%	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
177	2023-04-10 12:45:00+01	PAO Rouf	AEK B	Under	Full Time	1.80	0.00	Lost	2.5	\N	\N	\N	\N	\N	\N	5.26%	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
178	2023-04-10 13:15:00+01	Kallithea	Kifisia	Over	2nd Half	2.70	0.00	Lost	1.5	\N	\N	\N	\N	\N	\N	7.37%	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
179	2023-04-10 13:15:00+01	Kallithea	Kifisia	Over	Full Time	2.60	0.00	Lost	2.5	\N	\N	\N	\N	\N	\N	4.48%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
180	2023-04-10 13:15:00+01	Kallithea	Kifisia	Under	1st Half	2.26	0.00	Lost	0.5	\N	\N	\N	\N	\N	\N	7.01%	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
160	2023-04-02 19:00:00+01	Olympiacos	Aris Salonika	Under	2nd Half	3.50	0.00	Lost	0.5	2	2	1	1	0	2	5.21%	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
152	2023-04-02 16:00:00+01	Panathinaikos	Volos	Under	2nd Half	4.50	0.00	Lost	0.5	0	0	0	0	0	0	5.26%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
153	2023-04-02 16:00:00+01	Panathinaikos	Volos	Under	Full Time	2.10	0.00	Lost	2.5	0	0	0	0	0	0	3.95%	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
135	2023-04-01 15:30:00+01	Panetolikos	Lamia	Over	Full Time	2.60	0.05	Lost	2.5	1	1	0	1	0	3	3.68%	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
131	2023-04-01 15:00:00+01	Levadiakos	Atromitos	Under	2nd Half	3.00	0.00	Lost	0.5	1	1	0	1	0	1	6.28%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
132	2023-04-01 15:00:00+01	Levadiakos	Atromitos	Under	2nd Half	3.00	0.00	Lost	0.5	1	1	0	1	0	1	6.28%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
133	2023-04-01 15:00:00+01	Levadiakos	Atromitos	Under	2nd Half	3.00	0.00	Lost	0.5	1	1	0	1	0	1	6.28%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
134	2023-04-01 15:00:00+01	Levadiakos	Atromitos	Under	2nd Half	3.00	0.00	Lost	0.5	1	1	0	1	0	1	6.28%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
123	2023-03-19 19:30:00+00	AEK	Panathinaikos	Under	1st Half	2.45	0.00	Lost	0.5	0	0	0	0	0	0	3.21%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
124	2023-03-19 19:30:00+00	AEK	Panathinaikos	Under	2nd Half	3.25	0.00	Lost	0.5	0	0	0	0	0	0	3.63%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
119	2023-03-19 17:00:00+00	Aris Salonika	PAOK	Over	Full Time	2.55	0.00	Lost	2.5	1	1	1	0	0	2	0.56%	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
116	2023-03-19 15:30:00+00	Volos	Olympiacos	Under	2nd Half	4.47	0.00	Lost	0.5	0	0	0	0	2	1	5.40%	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
118	2023-03-19 15:30:00+00	Volos	Olympiacos	Under	1st Half	2.20	0.00	Lost	2.5	0	0	0	0	2	1	1.61%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
109	2023-03-18 17:30:00+00	Atromitos	Ionikos	Under	2nd Half	3.25	0.00	Lost	0.5	2	2	1	1	0	0	3.13%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
106	2023-03-18 15:30:00+00	OFI	Levadiakos	Under	Full Time	1.70	0.00	Lost	2.5	1	1	0	1	0	1	-0.36%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
97	2023-03-06 17:30:00+00	Panathinaikos	Panetolikos	Under	2nd Half	3.75	0.00	Lost	0.5	2	0	0	2	0	0	5.13%	{http://www.sportingbet.gr/,https://sports.bwin.gr/el/sports?wm=5273373,https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
93	2023-03-05 18:30:00+00	PAOK	Ionikos	Under	Full Time	1.95	0.00	Lost	2.5	6	0	4	2	0	0	3.26%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436,https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/,https://www.bet365.gr/olp/open-account?affiliate=365_01012107,https://record.affiliates.betshop.gr/_xVrm1kU5pcRLcRLGwHoTKWNd7ZgqdRLk/1/}
74	2023-03-05 14:00:00+00	Olympiacos	Levadiakos	Under	1st Half	3.60	0.00	Lost	0.5	6	6	2	4	0	0	2.88%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
162	2023-04-08 15:00:00+01	Atromitos	PAS Giannina	Over	Full Time	2.50	0.00	Lost	2.5	1	1	1	0	1	0	3.56%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107,https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/,https://record.affiliates.betshop.gr/_xVrm1kU5pcRLcRLGwHoTKWNd7ZgqdRLk/1/}
161	2023-04-02 19:00:00+01	Olympiacos	Aris Salonika	Under	Full Time	1.72	0.00	Lost	2.5	2	2	1	1	0	2	3.47%	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
154	2023-04-02 16:00:00+01	Panathinaikos	Volos	Under	Full Time	2.10	0.00	Lost	2.5	0	0	0	0	0	0	3.95%	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
75	2023-03-05 14:00:00+00	Olympiacos	Levadiakos	Under	2nd Half	4.75	0.00	Lost	0.5	6	6	2	4	0	0	4.20%	{http://www.sportingbet.gr/,https://sports.bwin.gr/el/sports?wm=5273373}
76	2023-03-05 14:00:00+00	Olympiacos	Levadiakos	Under	Full Time	2.30	0.00	Lost	2.5	6	6	2	4	0	0	3.92%	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
52	2023-02-25 17:00:00+00	PAS Giannina	PAOK	Under	2nd Half	4.4	0	Lost	0.5	0	0	0	0	0	0	4.36%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
181	2023-04-22 17:00:00+01	Lamia	Atromitos	Over	Full Time	2.50	0.00	Lost	2.5	\N	\N	\N	\N	\N	\N	2.07%	{}
182	2023-04-22 17:00:00+01	Levadiakos	Ionikos	Over	Full Time	2.50	0.00	Lost	2.5	\N	\N	\N	\N	\N	\N	4.32%	{}
183	2023-04-22 17:00:00+01	OFI	Asteras Tripolis	Over	Full Time	2.25	0.00	Lost	2.5	\N	\N	\N	\N	\N	\N	5.48%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
184	2023-04-22 17:00:00+01	Olympiacos	AEK	Over	Full Time	2.30	0.00	Lost	2.5	\N	\N	\N	\N	\N	\N	5.29%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
185	2023-04-22 17:00:00+01	PAOK	Panathinaikos	Over	Full Time	2.50	0.00	Lost	2.5	\N	\N	\N	\N	\N	\N	4.32%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
186	2023-04-22 17:00:00+01	PAOK	Panathinaikos	Under	1st Half	2.50	0.00	Lost	0.5	\N	\N	\N	\N	\N	\N	6.25%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
187	2023-04-22 17:00:00+01	PAOK	Panathinaikos	Under	2nd Half	3.00	0.00	Lost	0.5	\N	\N	\N	\N	\N	\N	6.90%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
188	2023-04-22 17:00:00+01	PAS Giannina	Panetolikos	Over	Full Time	2.45	0.00	Lost	2.5	\N	\N	\N	\N	\N	\N	5.82%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
189	2023-04-22 17:00:00+01	Volos	Aris Salonika	Over	Full Time	2.25	0.00	Lost	2.5	\N	\N	\N	\N	\N	\N	1.88%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
190	2023-04-22 17:00:00+01	Volos	Aris Salonika	Under	1st Half	2.60	0.00	Lost	0.5	\N	\N	\N	\N	\N	\N	6.09%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
191	2023-04-22 17:00:00+01	Volos	Aris Salonika	Under	2nd Half	3.10	0.00	Lost	0.5	\N	\N	\N	\N	\N	\N	6.93%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
192	2023-04-22 17:00:00+01	Volos	Aris Salonika	Under	Full Time	1.74	0.00	Lost	2.5	\N	\N	\N	\N	\N	\N	1.88%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
193	2023-04-22 19:00:00+01	Lamia	Atromitos	Over	Full Time	2.45	0.00	Lost	2.5	\N	\N	\N	\N	\N	\N	2.84%	{}
194	2023-04-22 19:00:00+01	Lamia	Atromitos	Under	1st Half	2.38	0.00	Lost	0.5	\N	\N	\N	\N	\N	\N	6.84%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
195	2023-04-22 19:00:00+01	Levadiakos	Ionikos	Over	Full Time	2.60	0.00	Lost	2.5	\N	\N	\N	\N	\N	\N	3.29%	{}
196	2023-04-22 19:00:00+01	OFI	Asteras Tripolis	Over	Full Time	2.50	0.00	Lost	2.5	\N	\N	\N	\N	\N	\N	1.33%	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
197	2023-04-22 19:00:00+01	Olympiacos	AEK	Over	Full Time	2.30	0.00	Lost	2.5	\N	\N	\N	\N	\N	\N	-0.02%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
198	2023-04-22 19:00:00+01	Olympiacos	AEK	Under	Full Time	1.77	0.00	Lost	2.5	\N	\N	\N	\N	\N	\N	-0.02%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
199	2023-04-22 19:00:00+01	PAOK	Panathinaikos	Over	Full Time	2.65	0.00	Lost	2.5	\N	\N	\N	\N	\N	\N	3.41%	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
200	2023-04-22 19:00:00+01	PAS Giannina	Panetolikos	Over	Full Time	2.44	0.00	Lost	2.5	\N	\N	\N	\N	\N	\N	4.10%	{https://record.affiliates.betshop.gr/_xVrm1kU5pcRLcRLGwHoTKWNd7ZgqdRLk/1/}
201	2023-04-22 19:00:00+01	Volos	Aris Salonika	Over	Full Time	2.10	0.00	Lost	2.5	\N	\N	\N	\N	\N	\N	3.66%	{}
202	2023-04-22 19:00:00+01	Volos	Aris Salonika	Under	Full Time	1.78	0.00	Lost	2.5	\N	\N	\N	\N	\N	\N	3.66%	{https://record.affiliates.betshop.gr/_xVrm1kU5pcRLcRLGwHoTKWNd7ZgqdRLk/1/}
214	2023-04-26 18:00:00+01	Volos	Panathinaikos	Over	Full Time	1.87	0.05	Lost	2.5	0	0	0	0	0	2	2.66%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
212	2023-04-23 21:00:00+01	Olympiacos	AEK	Over	Full Time	2.10	0.00	Lost	2.5	1	3	0	1	1	2	3.37%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
210	2023-04-23 20:00:00+01	PAOK	Panathinaikos	Over	Full Time	2.70	0.00	Lost	2.5	1	1	0	1	1	1	2.34%	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
208	2023-04-23 17:30:00+01	Volos	Aris Salonika	Over	Full Time	2.09	0.00	Lost	2.5	0	0	0	0	1	2	3.87%	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
207	2023-04-22 19:15:00+01	PAS Giannina	Panetolikos	Over	Full Time	2.44	0.00	Lost	2.5	3	2	1	2	1	1	4.47%	{https://record.affiliates.betshop.gr/_xVrm1kU5pcRLcRLGwHoTKWNd7ZgqdRLk/1/}
203	2023-04-22 19:15:00+01	Lamia	Atromitos	Over	Full Time	2.40	0.05	Lost	2.5	1	1	0	1	0	0	3.28%	{https://record.affiliates.betshop.gr/_xVrm1kU5pcRLcRLGwHoTKWNd7ZgqdRLk/1/}
209	2023-04-23 17:30:00+01	Volos	Aris Salonika	Under	Full Time	1.78	0.00	Lost	2.5	0	0	0	0	1	2	3.87%	{https://record.affiliates.betshop.gr/_xVrm1kU5pcRLcRLGwHoTKWNd7ZgqdRLk/1/}
204	2023-04-22 19:15:00+01	Lamia	Atromitos	Over	Full Time	2.40	0.00	Lost	2.5	1	1	0	1	0	0	3.28%	{https://record.affiliates.betshop.gr/_xVrm1kU5pcRLcRLGwHoTKWNd7ZgqdRLk/1/}
205	2023-04-22 19:15:00+01	Levadiakos	Ionikos	Over	Full Time	2.65	0.00	Lost	2.5	2	2	0	2	1	1	2.20%	{}
206	2023-04-22 19:15:00+01	OFI	Asteras Tripolis	Over	Full Time	2.50	0.00	Lost	2.5	1	1	1	0	1	0	1.70%	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
213	2023-04-23 21:00:00+01	Olympiacos	AEK	Under	Full Time	1.79	0.00	Lost	2.5	1	3	0	1	1	2	3.37%	{https://record.affiliates.betshop.gr/_xVrm1kU5pcRLcRLGwHoTKWNd7ZgqdRLk/1/}
211	2023-04-23 20:00:00+01	PAOK	Panathinaikos	Over	Full Time	2.70	0.00	Lost	2.5	1	1	0	1	1	1	2.34%	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
227	2023-04-30 20:00:00+01	PAOK	Aris Salonika	Over	Full Time	2.35	0.00	Lost	2.5	3	3	0	3	1	1	3.06%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145,https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
221	2023-04-29 19:15:00+01	Asteras Tripolis	Lamia	Over	Full Time	2.65	0.00	Lost	2.5	0	0	0	0	0	0	3.81%	{}
222	2023-04-29 19:15:00+01	Atromitos	OFI	Over	Full Time	2.35	0.00	Lost	2.5	2	2	2	0	2	1	3.76%	{http://www.sportingbet.gr/,https://sports.bwin.gr/el/sports?wm=5273373}
223	2023-04-29 19:15:00+01	Ionikos	PAS Giannina	Over	Full Time	2.50	0.00	Lost	2.5	0	0	0	0	0	1	2.44%	{http://www.sportingbet.gr/,https://sports.bwin.gr/el/sports?wm=5273373}
224	2023-04-29 19:15:00+01	Panetolikos	Levadiakos	Over	Full Time	2.55	0.00	Lost	2.5	2	2	0	2	2	0	4.38%	{}
219	2023-04-26 21:00:00+01	AEK	PAOK	Over	Full Time	2.20	0.00	Lost	2.5	4	0	2	2	0	0	1.61%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
220	2023-04-26 21:00:00+01	AEK	PAOK	Under	Full Time	1.78	0.00	Lost	2.5	4	0	2	2	0	0	1.61%	{}
217	2023-04-26 19:00:00+01	Aris Salonika	Olympiacos	Over	Full Time	2.25	0.00	Lost	2.5	2	2	1	1	0	1	2.84%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
218	2023-04-26 19:00:00+01	Aris Salonika	Olympiacos	Under	Full Time	1.71	0.00	Lost	2.5	2	2	1	1	0	1	2.84%	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
215	2023-04-26 18:00:00+01	Volos	Panathinaikos	Over	Full Time	1.87	0.00	Lost	2.5	0	0	0	0	0	2	2.66%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
216	2023-04-26 18:00:00+01	Volos	Panathinaikos	Under	Full Time	2.03	0.00	Lost	2.5	0	0	0	0	0	2	2.66%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436,https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
233	2023-05-06 20:00:00+01	Atromitos	Panetolikos	Over	Full Time	2.15	0.00	Lost	2.5	\N	\N	\N	\N	\N	\N	3.22%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
234	2023-05-06 20:00:00+01	Atromitos	Panetolikos	Under	Full Time	1.76	0.06	Lost	2.5	\N	\N	\N	\N	\N	\N	3.22%	{https://record.affiliates.betshop.gr/_xVrm1kU5pcRLcRLGwHoTKWNd7ZgqdRLk/1/}
235	2023-05-06 20:00:00+01	Atromitos	Panetolikos	Under	Full Time	1.76	0.00	Lost	2.5	\N	\N	\N	\N	\N	\N	3.22%	{https://record.affiliates.betshop.gr/_xVrm1kU5pcRLcRLGwHoTKWNd7ZgqdRLk/1/}
228	2023-05-03 20:00:00+01	AEK	Olympiacos	Over	Full Time	1.96	0.00	Lost	2.5	0	0	0	0	0	0	4.30%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
229	2023-05-03 20:00:00+01	AEK	Olympiacos	Under	Full Time	1.87	0.00	Lost	2.5	0	0	0	0	0	0	4.30%	{http://www.sportingbet.gr/,https://sports.bwin.gr/el/sports?wm=5273373}
230	2023-05-03 20:00:00+01	Aris Salonika	Volos	Over	Full Time	1.78	0.00	Lost	2.5	4	4	2	2	0	2	3.45%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
236	2023-05-06 20:00:00+01	Lamia	Levadiakos	Over	Full Time	2.60	0.00	Lost	2.5	\N	\N	\N	\N	\N	\N	2.89%	{https://record.affiliates.betshop.gr/_xVrm1kU5pcRLcRLGwHoTKWNd7ZgqdRLk/1/}
237	2023-05-06 20:00:00+01	OFI	Ionikos	Over	Full Time	2.25	0.00	Lost	2.5	\N	\N	\N	\N	\N	\N	3.49%	{https://record.affiliates.betshop.gr/_xVrm1kU5pcRLcRLGwHoTKWNd7ZgqdRLk/1/}
238	2023-05-06 20:00:00+01	PAS Giannina	Asteras Tripolis	Over	Full Time	3.60	0.00	Lost	2.5	\N	\N	\N	\N	\N	\N	1.82%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
231	2023-05-03 20:00:00+01	Aris Salonika	Volos	Under	Full Time	2.11	0.00	Lost	2.5	4	4	2	2	0	2	3.45%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
232	2023-05-03 20:00:00+01	Panathinaikos	PAOK	Over	Full Time	2.50	0.00	Lost	2.5	1	1	1	0	0	1	3.19%	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
225	2023-04-30 20:00:00+01	Olympiacos	Volos	Under	Full Time	3.10	0.00	Lost	2.5	5	0	3	2	0	0	3.56%	{https://record.affiliates.betshop.gr/_xVrm1kU5pcRLcRLGwHoTKWNd7ZgqdRLk/1/}
226	2023-04-30 20:00:00+01	Panathinaikos	AEK	Over	Full Time	2.55	0.00	Lost	2.5	0	0	0	0	0	0	3.99%	{https://record.affiliates.betshop.gr/_xVrm1kU5pcRLcRLGwHoTKWNd7ZgqdRLk/1/}
\.


--
-- TOC entry 3109 (class 0 OID 16586)
-- Dependencies: 213
-- Data for Name: soccer_statistics; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.soccer_statistics (id, home_team, guest_team, date_time, goals_home, goals_guest, full_time_home_win_odds, full_time_draw_odds, full_time_guest_win_odds, first_half_home_win_odds, first_half_draw_odds, second_half_goals_guest, second_half_goals_home, first_half_goals_guest, first_half_goals_home, first_half_guest_win_odds, second_half_home_win_odds, second_half_draw_odds, second_half_guest_win_odds, full_time_over_under_goals, full_time_over_odds, full_time_under_odds, first_half_over_under_goals, first_half_over_odds, first_half_under_odds, second_half_over_under_goals, second_half_over_odds, second_half_under_odds, url, last_updated) FROM stdin;
2	Giannina	Asteras Tripolis	2023-05-06 20:00:00+01	1	0	3.0	2.05	4	\N	\N	0	1	0	0	\N	\N	\N	\N	{0.5,1.5,1.75,2.0,2.5,3.5,4.5,5.5,6.5}	{2.02,3.6}	{1.82,1.29}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.75}	{2.05}	{0.5,1.5,2.5,3.5}	\N	\N	https://www.oddsportal.com/football/greece/super-league/giannina-asteras-tripolis-djtfaBBj/#1X2;2	2023-05-07 17:43:45.483939+01
3	Lamia	Levadiakos	2023-05-06 20:00:00+01	1	1	2.1	3.2	4	3.0	1.91	0	1	1	0	4.75	2.5	2.2	4.2	{0.5,1.5,2.0,2.5,3.5,4.5,5.5,6.5}	{1.11,1.53,2.05,2.7,5.5,13.0,29.0,46.0}	{6.5,2.38,1.8,1.47,1.15,1.04,1.01,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.62,1.9,4.0,13.0,31.0,81.0}	{2.38,1.9,1.29,1.05,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.4,2.75,7.0,21.0}	{3.0,1.44,1.1,1.02}	https://www.oddsportal.com/football/greece/super-league/lamia-levadiakos-AgUyOfli/#1X2;2	2023-05-07 17:44:25.795798+01
8	OFI Crete	Ionikos	2023-05-06 20:00:00+01	2	2	2.45	3.2	3	3.1	2.05	1	1	1	1	3.6	2.88	2.3	3.25	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.08,1.36,1.88,2.1,3.75,8.0,17.0,29.0}	{9.0,3.25,1.98,1.7,1.25,1.08,1.02,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.46,2.08,3.25,10.0,26.0,56.0}	{2.63,1.73,1.36,1.07,1.02,1.0}	{0.5,1.5,2.5,3.5}	{1.33,2.38,5.5,15.0}	{3.5,1.58,1.15,1.03}	https://www.oddsportal.com/football/greece/super-league/ofi-crete-ionikos-Iasj0idp/#1X2;2	2023-05-07 18:24:18.938176+01
1	Atromitos	Panetolikos	2023-05-06 20:00:00+01	2	0	2.0	3.3	4	2.6	2.05	0	1	0	1	4.2	2.4	2.37	3.9	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.08,1.4,2.15,3.75,7.25,15.0,31.0}	{7.75,2.9,1.68,1.25,1.08,1.02,1.0}	{0.5,1.0,1.5,2.5,3.5,4.5}	{1.46,3.1,8.25,23.0,61.0}	{2.75,1.36,1.07,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.33,2.3,5.0,12.0}	{3.5,1.58,1.16,1.03}	https://www.oddsportal.com/football/greece/super-league/atromitos-panetolikos-x6aN4XmT/#1X2;2	2023-05-07 17:43:09.797806+01
9	AEK Athens FC	Olympiacos Piraeus	2023-05-03 20:00:00+01	0	0	1.63	4.0	6	2.2	2.25	0	0	0	0	5.5	1.95	2.6	5.5	{0.5,1.5,2.5,3.5,4.5,5.5,6.5}	{1.06,1.33,1.95,3.4,6.5,15.0,29.0}	{11.0,3.5,1.9,1.3,1.11,1.03,1.01}	{0.5,1.0,1.5,2.5,3.5,4.5}	{1.4,1.88,2.8,8.0,21.0,51.0}	{2.75,1.93,1.4,1.08,1.02,1.0}	{0.5,1.5,2.5,3.5,4.5}	{1.29,2.2,4.5,13.0}	{4.0,1.67,1.18,1.04}	https://www.oddsportal.com/football/greece/super-league/aek-olympiacos-piraeus-YB1XgeID/#1X2;2	2023-05-07 18:24:49.840728+01
15	Aris	Volos	2023-05-03 20:00:00+01	4	2	1.21	7.0	17	1.58	2.75	2	2	0	2	12.0	1.44	3.4	11.0	{0.5,1.5,2.5,2.75,3.0,3.5,4.5,5.5,6.5,7.5}	{1.03,1.2,1.67,1.8,2.05,2.5,4.5,10.0,19.0}	{15.0,4.5,2.25,2.05,1.8,1.5,1.2,1.07,1.02}	{0.5,1.0,1.25,1.5,2.5,3.5,4.5}	{1.33,2.02,2.38,5.5,15.0,36.0}	{3.5,1.77,1.53,1.14,1.03,1.01}	{0.5,1.5,2.5,3.5,4.5}	{1.22,2.0,3.75,9.0,21.0}	{5.0,1.9,1.27,1.07,1.02}	https://www.oddsportal.com/football/greece/super-league/aris-volos-xpSD2mMD/#1X2;2	2023-05-07 18:37:50.19685+01
16	Panathinaikos	PAOK	2023-05-03 20:00:00+01	1	1	1.75	3.4	5	2.5	2.0	1	0	0	1	6.0	2.2	2.3	5.5	{0.5,1.5,2.0,2.5,3.5,4.5,5.5,6.5}	{1.1,1.5,1.77,2.41,4.33,10.0,21.0,41.0}	{8.0,2.63,2.1,1.57,1.2,1.06,1.02,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.53,1.75,3.5,11.0,26.0,67.0}	{2.38,2.05,1.29,1.05,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.62,6.5,19.0}	{3.25,1.5,1.11,1.02}	https://www.oddsportal.com/football/greece/super-league/panathinaikos-paok-jmWH17yK/#1X2;2	2023-05-07 18:38:21.493975+01
17	Olympiacos Piraeus	Volos	2023-04-30 20:00:00+01	5	0	1.09	10.5	29	1.36	3.5	0	2	0	3	17.0	1.24	4.4	17.0	{0.5,1.5,2.5,3.0,3.25,3.5,4.5,5.5,6.5,7.5,8.5}	{1.02,1.11,1.36,1.91,3.0,5.0,10.0,19.0,34.0}	{23.0,7.0,3.4,1.87,1.39,1.17,1.06,1.02,1.0}	{0.5,1.25,1.5,2.5,3.5,4.5}	{1.2,1.95,4.0,10.0,26.0}	{4.33,1.85,1.25,1.06,1.02}	{0.5,1.5,2.5,3.5,4.5}	{1.15,1.67,3.0,6.0,15.0}	{6.5,2.3,1.43,1.14,1.03}	https://www.oddsportal.com/football/greece/super-league/olympiacos-piraeus-volos-neaLdcYf/#1X2;2	2023-05-07 18:38:55.834379+01
18	Panathinaikos	AEK Athens FC	2023-04-30 20:00:00+01	0	0	2.8	3.1	3	3.5	1.95	0	0	0	0	3.6	3.3	2.2	3.1	{0.5,1.5,2.0,2.5,3.5,4.5,5.5,6.5}	{1.11,1.53,1.88,2.62,5.0,11.0,26.0,46.0}	{7.0,2.63,1.98,1.5,1.17,1.05,1.01,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.57,1.82,3.75,11.0,29.0,71.0}	{2.38,1.98,1.25,1.05,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.4,2.75,6.5,19.0}	{3.25,1.44,1.11,1.02}	https://www.oddsportal.com/football/greece/super-league/panathinaikos-aek-QobPeHm1/#1X2;2	2023-05-07 18:39:28.363729+01
19	PAOK	Aris	2023-04-30 20:00:00+01	3	2	1.7	3.6	5	2.3	2.2	1	3	1	0	5.5	2.05	2.5	5.0	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.07,1.36,1.8,2.1,3.5,8.0,17.0,34.0}	{10.0,3.4,2.05,1.75,1.29,1.1,1.02,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.44,2.0,3.0,9.0,23.0,56.0}	{2.75,1.8,1.36,1.07,1.02,1.0}	{0.5,1.5,2.5,3.5}	{1.3,2.3,5.0,13.0}	{3.75,1.62,1.17,1.04}	https://www.oddsportal.com/football/greece/super-league/paok-aris-fL2Tfy37/#1X2;2	2023-05-07 18:40:00.743308+01
20	Asteras Tripolis	Lamia	2023-04-29 19:15:00+01	0	0	2.3	2.95	4	3.1	1.91	0	0	0	0	4.33	2.75	2.2	3.75	{0.5,1.5,2.0,2.5,3.5,4.5,5.5,6.5}	{1.11,1.53,2.0,2.62,5.5,13.0,26.0,46.0}	{6.5,2.5,1.85,1.48,1.15,1.04,1.01,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.57,1.88,3.75,13.0,31.0,71.0}	{2.3,1.93,1.29,1.05,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.4,2.65,7.0,19.0}	{3.0,1.44,1.1,1.02}	https://www.oddsportal.com/football/greece/super-league/asteras-tripolis-lamia-8Q768Fl4/#1X2;2	2023-05-07 18:40:32.07675+01
21	Atromitos	OFI Crete	2023-04-29 19:15:00+01	2	3	2.2	3.4	3	2.88	2.2	1	0	2	2	3.6	2.6	2.5	3.3	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.05,1.29,1.86,3.0,6.0,13.0,26.0}	{11.0,3.75,2.0,1.36,1.13,1.04,1.01}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.37,1.8,2.75,7.0,21.0,46.0}	{3.0,2.0,1.43,1.11,1.02,1.01}	{0.5,1.5,2.5,3.5,4.5}	{1.25,2.05,4.33,11.0,26.0}	{4.0,1.73,1.2,1.05,1.01}	https://www.oddsportal.com/football/greece/super-league/atromitos-ofi-crete-jkcB7Z3A/#1X2;2	2023-05-07 18:41:04.421146+01
22	Ionikos	Giannina	2023-04-29 19:15:00+01	0	1	2.1	3.25	4	2.88	1.95	1	0	0	0	4.6	2.62	2.2	4.0	{0.5,1.5,2.0,2.5,3.5,4.5,5.5,6.5}	{1.11,1.5,1.93,2.5,5.0,11.0,26.0,41.0}	{7.0,2.5,1.93,1.53,1.17,1.05,1.02,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.53,1.82,3.75,11.0,29.0,71.0}	{2.38,1.98,1.29,1.05,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.63,6.5,19.0}	{3.25,1.44,1.11,1.02}	https://www.oddsportal.com/football/greece/super-league/ionikos-giannina-4h1F6gJG/#1X2;2	2023-05-07 18:41:35.86281+01
23	Panetolikos	Levadiakos	2023-04-29 19:15:00+01	2	2	2.8	2.85	3	3.6	1.85	0	2	2	0	3.75	3.1	2.1	3.25	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.13,1.57,2.13,2.88,6.0,15.0,26.0,51.0}	{6.0,2.38,1.75,1.45,1.14,1.04,1.01,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.62,1.95,4.0,13.0,31.0,81.0}	{2.38,1.85,1.29,1.04,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.4,2.8,8.0,21.0}	{2.75,1.44,1.1,1.02}	https://www.oddsportal.com/football/greece/super-league/panetolikos-levadiakos-bF0J5DYM/#1X2;2	2023-05-07 18:42:06.868713+01
24	AEK Athens FC	PAOK	2023-04-26 21:00:00+01	4	0	1.53	4.2	7	2.1	2.25	0	2	0	2	6.5	1.85	2.6	6.1	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.06,1.33,2.06,3.85,8.0,15.0,29.0}	{11.0,3.5,1.85,1.3,1.1,1.03,1.01}	{0.5,1.0,1.5,2.5,3.5,4.5}	{1.44,1.93,3.05,8.0,23.0,51.0}	{2.85,1.88,1.4,1.08,1.02,1.0}	{0.5,1.5,2.5,3.5}	{1.3,2.3,4.75,13.0}	{3.75,1.67,1.18,1.04}	https://www.oddsportal.com/football/greece/super-league/aek-paok-zHJp3aeR/#1X2;2	2023-05-07 18:42:39.084215+01
25	Aris	Olympiacos Piraeus	2023-04-26 19:00:00+01	2	1	3.25	3.3	2	3.95	2.1	1	1	0	1	3.1	3.65	2.38	2.7	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.07,1.36,1.88,2.23,4.25,9.0,17.0,34.0}	{9.0,3.25,1.98,1.73,1.29,1.1,1.02,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.44,2.08,3.3,9.0,26.0,56.0}	{2.75,1.73,1.36,1.08,1.02,1.0}	{0.5,1.5,2.5,3.5}	{1.3,2.4,5.0,13.0}	{3.75,1.62,1.17,1.04}	https://www.oddsportal.com/football/greece/super-league/aris-olympiacos-piraeus-hd6CbJ3r/#1X2;2	2023-05-07 18:43:11.157734+01
26	Volos	Panathinaikos	2023-04-26 18:00:00+01	0	2	13.0	5.75	1	11.0	2.6	2	0	0	0	1.8	10.5	3.0	1.57	{0.5,1.5,2.25,2.5,2.75,3.5,4.5,5.5,6.5,7.5}	{1.06,1.33,1.82,2.05,3.75,8.0,17.0,34.0}	{11.5,3.5,2.02,1.81,1.29,1.1,1.03,1.0}	{0.5,1.0,1.25,1.5,2.5,3.5,4.5}	{1.4,2.0,3.0,8.0,23.0,51.0}	{3.05,1.8,1.4,1.1,1.02,1.0}	{0.5,1.5,2.5,3.5,4.5}	{1.33,2.3,5.0,13.0}	{3.75,1.62,1.17,1.04}	https://www.oddsportal.com/football/greece/super-league/volos-panathinaikos-4W9GcwJl/#1X2;2	2023-05-07 18:43:44.470805+01
27	Olympiacos Piraeus	AEK Athens FC	2023-04-23 21:00:00+01	1	3	2.4	3.25	3	3.1	2.05	2	1	1	0	3.6	2.75	2.38	3.3	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.07,1.36,1.88,2.1,3.75,8.0,19.0,41.0}	{10.0,3.25,1.98,1.73,1.25,1.08,1.02,1.0}	{0.5,1.0,1.5,2.5,3.5,4.5}	{1.44,2.08,3.25,10.0,26.0,56.0}	{2.75,1.73,1.36,1.07,1.02,1.0}	{0.5,1.5,2.5,3.5}	{1.3,2.25,5.5,15.0}	{3.5,1.62,1.15,1.03}	https://www.oddsportal.com/football/greece/super-league/olympiacos-piraeus-aek-vkQy5LQE/#1X2;2	2023-05-07 18:44:15.139834+01
28	PAOK	Panathinaikos	2023-04-23 20:00:00+01	1	2	2.21	3.1	4	3.0	1.91	1	1	1	0	4.33	2.7	2.2	3.8	{0.5,1.5,2.0,2.5,3.5,4.5,5.5,6.5}	{1.12,1.53,2.02,2.7,5.5,13.0,26.0,46.0}	{6.5,2.38,1.82,1.46,1.15,1.04,1.01,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.57,1.9,3.75,13.0,31.0,81.0}	{2.38,1.9,1.29,1.04,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.4,2.75,7.0,21.0}	{3.0,1.44,1.1,1.02}	https://www.oddsportal.com/football/greece/super-league/paok-panathinaikos-dQKt4utL/#1X2;2	2023-05-07 18:44:47.351016+01
29	Volos	Aris	2023-04-23 17:30:00+01	0	3	5.25	3.75	2	5.5	2.2	2	0	1	0	2.4	4.75	2.5	2.1	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.07,1.36,1.8,2.05,3.5,8.0,17.0,34.0}	{9.5,3.25,2.05,1.75,1.29,1.09,1.02,1.0}	{0.5,1.0,1.5,2.5,3.5,4.5}	{1.42,2.0,3.0,9.0,23.0,56.0}	{2.75,1.8,1.4,1.07,1.02,1.0}	{0.5,1.5,2.5,3.5}	{1.3,2.25,5.0,13.0}	{3.75,1.62,1.17,1.04}	https://www.oddsportal.com/football/greece/super-league/volos-aris-0bRX51B8/#1X2;2	2023-05-07 18:45:18.390369+01
30	Giannina	Panetolikos	2023-04-22 19:15:00+01	3	2	1.8	3.3	6	2.6	2.0	1	2	1	1	5.5	2.25	2.3	5.5	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.1,1.44,1.8,2.4,4.5,11.0,23.0,36.0}	{7.0,2.63,2.05,1.55,1.2,1.06,1.02,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.53,1.75,3.5,11.0,29.0,71.0}	{2.5,2.05,1.33,1.05,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.5,6.0,17.0}	{3.25,1.5,1.13,1.02}	https://www.oddsportal.com/football/greece/super-league/giannina-panetolikos-M99bAyKi/#1X2;2	2023-05-07 18:45:49.076611+01
31	Lamia	Atromitos	2023-04-22 19:15:00+01	1	0	1.9	3.5	5	2.75	2.05	0	1	0	0	5.5	2.4	2.3	4.5	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.1,1.44,2.05,2.3,4.33,10.0,21.0,36.0}	{8.0,2.75,1.8,1.6,1.2,1.06,1.02,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.5,1.73,3.4,10.0,26.0,67.0}	{2.5,2.08,1.3,1.06,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.5,6.0,17.0}	{3.4,1.5,1.13,1.02}	https://www.oddsportal.com/football/greece/super-league/lamia-atromitos-UZ829eZc/#1X2;2	2023-05-07 18:46:20.794528+01
32	Levadiakos	Ionikos	2023-04-22 19:15:00+01	2	2	2.3	3.1	4	3.1	1.91	1	2	1	0	4.5	2.8	2.1	3.9	{0.5,1.5,1.75,2.0,2.5,3.5,4.5,5.5,6.5}	{1.13,1.62,1.82,2.88,6.0,15.0,34.0,51.0}	{6.0,2.3,2.02,1.48,1.14,1.03,1.01,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.62,2.0,4.0,13.0,31.0,81.0}	{2.3,1.8,1.25,1.04,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.44,2.8,8.0,21.0}	{2.75,1.4,1.1,1.02}	https://www.oddsportal.com/football/greece/super-league/levadiakos-ionikos-tEWBnYRp/#1X2;2	2023-05-07 18:46:52.494038+01
33	OFI Crete	Asteras Tripolis	2023-04-22 19:15:00+01	1	1	1.95	3.5	4	2.7	2.05	0	0	1	1	4.75	2.5	2.35	4.33	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.08,1.44,1.95,2.25,4.0,9.0,19.0,41.0}	{9.0,3.0,1.9,1.67,1.23,1.07,1.02,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.5,2.1,3.4,10.0,26.0,61.0}	{2.5,1.7,1.3,1.06,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.38,6.0,17.0}	{3.4,1.55,1.14,1.02}	https://www.oddsportal.com/football/greece/super-league/ofi-crete-asteras-tripolis-rJAfBH4o/#1X2;2	2023-05-07 18:47:24.245713+01
119	PAOK	OFI Crete	2023-01-14 20:00:00+00	0	0	1.36	4.95	10	1.83	2.45	0	0	0	0	9.0	1.62	2.85	8.0	{0.5,1.5,2.5,3.5,4.5,5.5,6.5}	{1.06,1.29,1.93,3.35,6.75,15.0,26.0}	{12.0,3.7,1.93,1.36,1.12,1.04,1.01}	{0.5,1.0,1.5,2.5,3.5,4.5}	{1.36,1.85,2.75,7.0,21.0,41.0}	{3.1,1.95,1.5,1.11,1.02,1.01}	{0.5,1.5,2.5,3.5,4.5}	{1.29,2.1,4.33,11.0}	{4.0,1.73,1.2,1.05}	https://www.oddsportal.com/football/greece/super-league/paok-ofi-crete-Kfpsh0Cr/#1X2;2	2023-05-07 19:34:25.445033+01
34	Panathinaikos	Olympiacos Piraeus	2023-04-09 21:00:00+01	2	0	2.7	3.2	3	3.5	1.91	0	0	0	2	3.6	3.1	2.2	3.25	{0.5,1.5,2.0,2.5,3.5,4.5,5.5,6.5}	{1.12,1.53,2.05,2.7,5.5,13.0,29.0,46.0}	{7.0,2.38,1.8,1.44,1.15,1.04,1.01,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.57,1.93,3.75,13.0,29.0,71.0}	{2.5,1.88,1.29,1.05,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.4,2.75,7.0,19.0}	{3.0,1.44,1.1,1.02}	https://www.oddsportal.com/football/greece/super-league/panathinaikos-olympiacos-piraeus-YiZorbJ1/#1X2;2	2023-05-07 18:47:55.574941+01
35	PAOK	Volos	2023-04-09 20:30:00+01	4	2	1.18	7.15	19	1.57	2.75	2	0	0	4	13.0	1.4	3.3	12.0	{0.5,1.5,2.5,2.75,3.0,3.5,4.5,5.5,6.5,7.5}	{1.04,1.19,1.62,1.8,2.02,2.5,4.5,10.0,19.0,41.0}	{14.0,4.5,2.3,2.05,1.83,1.53,1.22,1.08,1.02,1.0}	{0.5,1.25,1.5,2.5,3.5,4.5}	{1.29,2.02,2.38,5.5,17.0,34.0}	{3.5,1.77,1.6,1.15,1.03,1.01}	{0.5,1.5,2.5,3.5,4.5}	{1.22,1.91,3.75,9.0,21.0}	{5.0,1.87,1.26,1.07,1.02}	https://www.oddsportal.com/football/greece/super-league/paok-volos-newjsIY7/#1X2;2	2023-05-07 18:48:28.036508+01
36	AEK Athens FC	Aris	2023-04-09 18:00:00+01	3	1	1.4	4.5	10	1.91	2.38	0	2	1	1	7.5	1.7	2.75	7.0	{0.5,1.5,2.5,3.5,4.5,5.5,6.5}	{1.05,1.29,1.93,3.25,6.5,15.0,29.0}	{11.0,3.5,1.93,1.36,1.12,1.04,1.01}	{0.5,1.0,1.5,2.5,3.5,4.5}	{1.37,1.85,2.75,7.0,21.0,46.0}	{3.0,1.95,1.44,1.1,1.02,1.01}	{0.5,1.5,2.5,3.5,4.5}	{1.25,2.1,4.5,11.0}	{4.0,1.73,1.2,1.05}	https://www.oddsportal.com/football/greece/super-league/aek-aris-jTqsqv4e/#1X2;2	2023-05-07 18:49:00.01828+01
37	Asteras Tripolis	Levadiakos	2023-04-08 19:30:00+01	0	1	2.25	2.88	4	3.2	1.8	0	0	1	0	5.0	2.75	2.0	4.2	{0.5,1.5,1.75,2.0,2.5,3.5,4.5,5.5,6.5}	{1.17,1.8,2.05,3.5,8.0,19.0,51.0,67.0}	{5.5,2.0,1.8,1.33,1.1,1.02,1.01,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.75,5.0,17.0,41.0,101.0}	{2.1,1.2,1.02,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.53,3.4,10.0,26.0}	{2.5,1.33,1.06,1.01}	https://www.oddsportal.com/football/greece/super-league/asteras-tripolis-levadiakos-vmBV62Da/#1X2;2	2023-05-07 18:49:31.635049+01
38	Panetolikos	Ionikos	2023-04-08 19:30:00+01	0	1	2.65	2.9	3	3.5	1.91	0	0	1	0	3.75	3.0	2.1	3.6	{0.5,1.5,1.75,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.12,1.57,2.1,2.7,5.5,13.0,23.0,51.0}	{6.5,2.38,1.77,1.47,1.14,1.04,1.01,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.62,1.95,4.0,13.0,31.0,81.0}	{2.38,1.85,1.25,1.04,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.44,2.8,7.0,21.0}	{3.0,1.4,1.1,1.02}	https://www.oddsportal.com/football/greece/super-league/panetolikos-ionikos-Uy4r40cI/#1X2;2	2023-05-07 18:50:04.145063+01
39	OFI Crete	Lamia	2023-04-08 17:30:00+01	4	1	2.15	3.25	4	2.88	2.05	0	2	1	2	4.0	2.5	2.38	3.75	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.08,1.4,1.95,2.2,4.0,9.0,19.0,41.0}	{9.0,3.0,1.9,1.67,1.23,1.08,1.02,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.46,2.1,3.25,10.0,26.0,56.0}	{2.63,1.7,1.36,1.07,1.02,1.0}	{0.5,1.5,2.5,3.5}	{1.33,2.3,5.5,15.0}	{3.5,1.57,1.14,1.03}	https://www.oddsportal.com/football/greece/super-league/ofi-crete-lamia-zF4v5trC/#1X2;2	2023-05-07 18:50:35.916563+01
40	Atromitos	Giannina	2023-04-08 17:00:00+01	1	1	2.55	3.2	3	3.4	1.95	0	0	1	1	3.6	2.88	2.25	3.3	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.1,1.44,1.8,2.38,4.5,11.0,23.0,36.0}	{8.0,2.63,2.05,1.57,1.2,1.06,1.02,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.53,1.77,3.5,11.0,26.0,67.0}	{2.5,2.02,1.33,1.05,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.5,6.0,17.0}	{3.25,1.5,1.13,1.02}	https://www.oddsportal.com/football/greece/super-league/atromitos-giannina-dO5z6MS5/#1X2;2	2023-05-07 18:51:07.119628+01
41	Olympiacos Piraeus	PAOK	2023-04-05 21:00:00+01	3	1	2.05	3.5	4	2.75	2.05	0	3	1	0	4.75	2.5	2.38	4.4	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.08,1.4,1.98,2.2,4.1,9.0,19.0,34.0}	{9.0,3.1,1.88,1.67,1.25,1.07,1.02,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.47,1.7,2.1,3.4,10.0,26.0,61.0}	{2.7,2.1,1.7,1.36,1.07,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.33,2.38,5.5,15.0}	{3.5,1.57,1.14,1.03}	https://www.oddsportal.com/football/greece/super-league/olympiacos-piraeus-paok-CxowpKlk/#1X2;2	2023-05-07 18:51:40.432831+01
42	Aris	Panathinaikos	2023-04-05 19:30:00+01	0	1	2.73	2.95	3	3.5	1.91	1	0	0	0	3.75	3.2	2.15	3.2	{0.5,1.5,2.0,2.5,3.5,4.5,5.5,6.5}	{1.12,1.57,2.13,2.88,6.0,15.0,29.0,51.0}	{6.75,2.5,1.75,1.45,1.14,1.04,1.01,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.62,1.95,4.0,13.0,34.0,81.0}	{2.35,1.85,1.29,1.04,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.44,2.75,7.0,21.0}	{3.0,1.4,1.1,1.02}	https://www.oddsportal.com/football/greece/super-league/aris-panathinaikos-Ghp8ktRR/#1X2;2	2023-05-07 18:52:11.809651+01
43	Volos	AEK Athens FC	2023-04-05 18:00:00+01	0	1	13.0	6.5	1	10.0	2.75	0	0	1	0	1.67	9.5	3.2	1.47	{0.5,1.5,2.5,2.75,3.5,4.5,5.5,6.5,7.5}	{1.03,1.2,1.65,1.8,2.75,5.2,10.0,19.0}	{15.0,4.5,2.3,2.05,1.5,1.2,1.07,1.02}	{0.5,1.0,1.25,1.5,2.5,3.5,4.5}	{1.33,2.02,2.43,5.5,17.0,36.0}	{3.55,1.77,1.53,1.14,1.03,1.01}	{0.5,1.5,2.5,3.5,4.5}	{1.22,1.91,4.0,9.0,21.0}	{5.0,1.9,1.28,1.07,1.02}	https://www.oddsportal.com/football/greece/super-league/volos-aek-I1WZp0Zr/#1X2;2	2023-05-07 18:52:44.754663+01
44	Olympiacos Piraeus	Aris	2023-04-02 21:00:00+01	2	2	1.26	5.75	11	1.73	2.63	2	1	0	1	8.5	1.53	3.2	8.0	{0.5,1.5,2.25,2.5,2.75,3.0,3.5,4.5,5.5,6.5,7.5}	{1.02,1.18,1.6,2.0,2.5,4.33,9.0,19.0}	{17.0,4.5,2.38,1.85,1.53,1.22,1.08,1.02}	{0.5,1.0,1.25,1.5,2.5,3.5,4.5}	{1.29,2.0,2.25,5.5,15.0,34.0}	{3.5,1.8,1.57,1.14,1.03,1.0}	{0.5,1.5,2.5,3.5,4.5}	{1.17,1.8,3.5,8.0,21.0}	{5.0,1.91,1.29,1.08,1.02}	https://www.oddsportal.com/football/greece/super-league/olympiacos-piraeus-aris-Q3iehrs9/#1X2;2	2023-05-07 18:53:18.233273+01
45	PAOK	AEK Athens FC	2023-04-02 19:30:00+01	0	1	2.45	3.1	3	3.2	1.95	1	0	0	0	4.0	2.8	2.2	3.5	{0.5,1.5,2.0,2.5,3.5,4.5,5.5,6.5}	{1.11,1.5,1.9,2.5,5.0,11.0,26.0,41.0}	{7.0,2.5,1.95,1.53,1.17,1.05,1.02,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.57,1.83,3.75,11.0,29.0,71.0}	{2.5,1.98,1.3,1.05,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.4,2.63,6.5,19.0}	{3.25,1.46,1.11,1.02}	https://www.oddsportal.com/football/greece/super-league/paok-aek-YTf3jMBL/#1X2;2	2023-05-07 18:53:49.174293+01
46	Panathinaikos	Volos	2023-04-02 18:00:00+01	0	0	1.2	6.5	17	1.62	2.65	0	0	0	0	12.0	1.44	3.25	11.0	{0.5,1.5,2.5,2.75,3.0,3.5,4.5,5.5,6.5,7.5}	{1.03,1.22,1.67,1.88,2.63,5.0,11.0,21.0,41.0}	{15.0,4.33,2.2,1.98,1.46,1.18,1.06,1.02,1.0}	{0.5,1.0,1.25,1.5,2.5,3.5,4.5}	{1.3,2.08,2.5,6.0,17.0,36.0}	{3.4,1.73,1.57,1.14,1.03,1.01}	{0.5,1.5,2.5,3.5,4.5}	{1.22,2.0,3.75,10.0,23.0}	{4.5,1.83,1.25,1.06,1.01}	https://www.oddsportal.com/football/greece/super-league/panathinaikos-volos-KQjai2dF/#1X2;2	2023-05-07 18:54:22.76118+01
47	Ionikos	Asteras Tripolis	2023-04-01 21:00:00+01	1	0	2.1	3.0	5	2.88	1.83	0	0	0	1	5.0	2.5	2.1	4.4	{0.5,1.5,1.75,2.0,2.5,3.5,4.5,5.5,6.5}	{1.14,1.62,1.88,3.1,6.5,17.0,34.0,56.0}	{6.0,2.2,1.98,1.38,1.12,1.03,1.01,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.62,2.02,4.0,15.0,34.0,81.0}	{2.25,1.77,1.25,1.04,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.5,3.0,8.0,23.0}	{2.75,1.36,1.08,1.02}	https://www.oddsportal.com/football/greece/super-league/ionikos-asteras-tripolis-27HiEpLP/#1X2;2	2023-05-07 18:54:54.081966+01
48	Giannina	OFI Crete	2023-04-01 19:30:00+01	0	1	2.42	3.0	3	3.2	1.95	0	0	1	0	4.0	2.75	2.2	3.7	{0.5,1.5,2.0,2.5,3.5,4.5,5.5,6.5}	{1.1,1.5,1.83,2.42,4.5,11.0,23.0,41.0}	{7.0,2.63,2.02,1.53,1.19,1.06,1.02,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.53,1.77,3.5,11.0,26.0,67.0}	{2.38,2.02,1.3,1.05,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.5,6.5,17.0}	{3.25,1.5,1.11,1.02}	https://www.oddsportal.com/football/greece/super-league/giannina-ofi-crete-0dCR7rbg/#1X2;2	2023-05-07 18:55:25.548939+01
49	Panetolikos	Lamia	2023-04-01 17:30:00+01	1	3	2.45	3.3	3	3.25	1.91	3	1	0	0	4.0	2.8	2.2	3.6	{0.5,1.5,2.0,2.5,3.5,4.5,5.5,6.5}	{1.11,1.53,1.98,2.6,5.5,13.0,26.0,46.0}	{7.0,2.5,1.88,1.5,1.16,1.05,1.01,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.57,1.85,3.75,13.0,31.0,71.0}	{2.38,1.95,1.29,1.05,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.4,2.63,7.0,21.0}	{3.0,1.44,1.1,1.02}	https://www.oddsportal.com/football/greece/super-league/panetolikos-lamia-6ZCN8Orm/#1X2;2	2023-05-07 18:55:56.669601+01
50	Levadiakos	Atromitos	2023-04-01 17:00:00+01	1	1	2.45	3.2	3	3.25	1.91	1	1	0	0	4.0	2.88	2.2	3.5	{0.5,1.5,2.0,2.5,3.5,4.5,5.5,6.5}	{1.11,1.5,1.98,2.6,5.5,13.0,26.0,46.0}	{6.5,2.5,1.88,1.5,1.16,1.04,1.01,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.57,1.85,3.75,13.0,31.0,71.0}	{2.3,1.95,1.29,1.05,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.4,2.63,7.0,19.0}	{3.0,1.44,1.1,1.02}	https://www.oddsportal.com/football/greece/super-league/levadiakos-atromitos-8lfK94Tt/#1X2;2	2023-05-07 18:56:28.141808+01
51	AEK Athens FC	Panathinaikos	2023-03-19 21:30:00+00	0	0	1.83	3.3	5	2.6	2.0	0	0	0	0	5.5	2.3	2.25	4.75	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.1,1.44,1.85,2.4,5.0,11.0,23.0,41.0}	{8.0,2.63,2.0,1.57,1.2,1.06,1.02,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.53,1.8,3.5,11.0,29.0,67.0}	{2.5,2.0,1.33,1.06,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.4,2.62,6.5,19.0}	{3.25,1.5,1.11,1.02}	https://www.oddsportal.com/football/greece/super-league/aek-panathinaikos-8UsfTz8t/#1X2;2	2023-05-07 18:57:00.630252+01
52	Aris	PAOK	2023-03-19 19:00:00+00	1	2	3.0	3.0	3	3.75	1.91	2	0	0	1	3.4	3.25	2.2	3.1	{0.5,1.5,2.0,2.5,3.5,4.5,5.5,6.5}	{1.12,1.53,1.95,2.62,5.0,13.0,26.0,46.0}	{6.5,2.5,1.9,1.5,1.17,1.04,1.01,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.57,1.85,3.75,13.0,31.0,71.0}	{2.38,1.95,1.29,1.05,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.4,2.63,7.0,19.0}	{3.25,1.44,1.1,1.02}	https://www.oddsportal.com/football/greece/super-league/aris-paok-jgXbSfNn/#1X2;2	2023-05-07 18:57:32.340607+01
53	Volos	Olympiacos Piraeus	2023-03-19 17:30:00+00	0	3	12.0	6.5	1	9.5	2.5	1	0	2	0	1.73	9.0	2.95	1.53	{0.5,1.5,2.5,2.75,3.0,3.25,3.5,4.5,5.5,6.5,7.5}	{1.04,1.25,1.75,2.02,3.0,5.5,13.0,26.0,51.0}	{13.0,3.75,2.1,1.83,1.4,1.15,1.05,1.01,1.0}	{0.5,1.0,1.25,1.5,2.5,3.5,4.5}	{1.33,1.73,2.63,6.5,19.0,41.0}	{3.25,2.08,1.53,1.12,1.02,1.01}	{0.5,1.5,2.5,3.5,4.5}	{1.25,2.05,4.33,11.0,26.0}	{4.33,1.75,1.22,1.05,1.01}	https://www.oddsportal.com/football/greece/super-league/volos-olympiacos-piraeus-bJz7QYia/#1X2;2	2023-05-07 18:58:04.49144+01
54	Lamia	Giannina	2023-03-18 21:00:00+00	2	0	2.25	3.1	4	3.1	1.83	0	0	0	2	4.5	2.8	2.1	3.9	{0.5,1.5,1.75,2.0,2.5,3.5,4.5,5.5,6.5}	{1.14,1.6,1.8,2.88,6.0,15.0,29.0,51.0}	{6.5,2.25,2.05,1.44,1.14,1.03,1.01,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.62,1.98,4.0,13.0,34.0,81.0}	{2.3,1.83,1.25,1.04,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.44,2.75,8.0,21.0}	{2.75,1.4,1.09,1.02}	https://www.oddsportal.com/football/greece/super-league/lamia-giannina-SbSNMjiO/#1X2;2	2023-05-07 18:58:35.691035+01
508	Atromitos	Lamia	2021-04-24 19:30:00+01	0	0	2.63	2.8	3	3.5	1.9	0	0	0	0	4.0	3.05	2.1	3.5	{0.5,1.5,2.0,2.5,3.5,4.5,5.5}	{1.13,1.55,2.05,2.7,5.5,13.0,26.0}	{6.25,2.48,1.8,1.45,1.15,1.04,1.01}	{0.5,0.75,1.5,2.5,3.5}	{1.62,1.95,3.8,13.0,11.0}	{2.28,1.85,1.25,1.04,1.01}	{0.5,1.5,2.5,3.5}	{1.4,2.75,7.0,19.0}	{3.0,1.44,1.11,1.02}	https://www.oddsportal.com/football/greece/super-league-2020-2021/atromitos-lamia-Qu7SEKxI/#1X2;2	2023-05-07 23:01:08.320619+01
55	Atromitos	Ionikos	2023-03-18 19:30:00+00	2	0	2.15	3.1	4	2.88	1.95	0	1	0	1	4.5	2.5	2.2	4.0	{0.5,1.5,2.0,2.5,3.5,4.5,5.5,6.5}	{1.1,1.44,1.88,2.5,5.0,11.0,23.0,41.0}	{7.0,2.63,1.98,1.53,1.2,1.06,1.02,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.53,1.8,3.75,11.0,26.0,67.0}	{2.5,2.0,1.3,1.05,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.63,6.5,19.0}	{3.25,1.5,1.12,1.02}	https://www.oddsportal.com/football/greece/super-league/atromitos-ionikos-foUFOCMB/#1X2;2	2023-05-07 18:59:06.282644+01
56	OFI Crete	Levadiakos	2023-03-18 17:30:00+00	1	1	1.75	3.55	5	2.5	2.0	1	1	0	0	5.5	2.1	2.35	5.5	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.1,1.44,1.85,2.1,2.4,5.0,11.0,23.0,36.0}	{8.0,2.65,2.0,1.77,1.57,1.2,1.06,1.02,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.53,1.8,3.5,11.0,26.0,67.0}	{2.5,2.0,1.3,1.06,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.63,6.5,19.0}	{3.25,1.52,1.13,1.02}	https://www.oddsportal.com/football/greece/super-league/ofi-crete-levadiakos-YyTJNWyI/#1X2;2	2023-05-07 18:59:37.717979+01
57	Asteras Tripolis	Panetolikos	2023-03-18 17:00:00+00	2	1	1.92	3.4	5	2.6	2.0	1	1	0	1	5.5	2.38	2.3	4.5	{0.5,1.5,2.0,2.5,3.5,4.5,5.5,6.5}	{1.1,1.5,1.8,2.5,4.5,11.0,23.0,51.0}	{7.5,2.63,2.05,1.57,1.18,1.06,1.02,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.52,1.77,3.5,11.0,29.0,71.0}	{2.5,2.02,1.33,1.05,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.62,6.5,17.0}	{3.25,1.5,1.12,1.02}	https://www.oddsportal.com/football/greece/super-league/asteras-tripolis-panetolikos-xAZAPh75/#1X2;2	2023-05-07 19:00:12.955684+01
58	AEK Athens FC	Olympiacos Piraeus	2023-03-12 19:00:00+00	1	3	1.85	3.55	4	2.5	2.2	3	1	0	0	4.5	2.15	2.5	4.2	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.06,1.3,1.98,3.25,6.5,15.0,29.0}	{11.0,3.5,1.88,1.33,1.11,1.03,1.01}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.4,1.9,3.0,8.0,23.0,46.0}	{2.75,1.9,1.4,1.1,1.02,1.0}	{0.5,1.5,2.5,3.5,4.5}	{1.29,2.1,4.5,13.0}	{4.0,1.67,1.2,1.04}	https://www.oddsportal.com/football/greece/super-league/aek-olympiacos-piraeus-z7Sxy2xp/#1X2;2	2023-05-07 19:00:44.271377+01
59	Aris	Giannina	2023-03-12 19:00:00+00	3	1	1.44	4.4	9	2.0	2.25	0	1	1	2	7.5	1.73	2.65	7.0	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.06,1.33,2.0,3.4,7.0,15.0,29.0}	{10.0,3.5,1.85,1.3,1.1,1.03,1.01}	{0.5,1.0,1.5,2.5,3.5,4.5}	{1.4,1.93,3.0,8.0,23.0,51.0}	{2.75,1.88,1.4,1.08,1.02,1.0}	{0.5,1.5,2.5,3.5}	{1.3,2.25,5.0,13.0}	{3.75,1.63,1.17,1.04}	https://www.oddsportal.com/football/greece/super-league/aris-giannina-IVHszMij/#1X2;2	2023-05-07 19:01:15.669015+01
60	Atromitos	Panathinaikos	2023-03-12 19:00:00+00	0	2	7.0	3.8	2	6.5	2.15	2	0	0	0	2.2	6.0	2.45	1.91	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.08,1.4,2.02,2.25,4.33,10.0,21.0,41.0}	{8.0,2.8,1.83,1.63,1.23,1.07,1.02,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.5,1.7,3.4,10.0,23.0,61.0}	{2.62,2.1,1.33,1.06,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.5,6.0,17.0}	{3.4,1.55,1.14,1.03}	https://www.oddsportal.com/football/greece/super-league/atromitos-panathinaikos-WYLoZu7d/#1X2;2	2023-05-07 19:01:58.472196+01
61	Ionikos	Asteras Tripolis	2023-03-12 19:00:00+00	1	0	2.8	3.0	3	3.5	1.91	0	0	0	1	3.75	3.2	2.2	3.2	{0.5,1.5,2.0,2.5,3.5,4.5,5.5,6.5}	{1.12,1.5,2.0,2.62,5.5,13.0,26.0,46.0}	{6.5,2.5,1.85,1.48,1.16,1.04,1.01,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.57,1.88,3.75,13.0,29.0,71.0}	{2.38,1.93,1.29,1.05,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.4,2.65,7.0,19.0}	{3.0,1.44,1.11,1.02}	https://www.oddsportal.com/football/greece/super-league/ionikos-asteras-tripolis-OS8Xdqa3/#1X2;2	2023-05-07 19:02:29.735758+01
62	Levadiakos	OFI Crete	2023-03-12 19:00:00+00	2	0	2.9	3.3	3	3.75	1.91	0	0	0	2	3.4	3.4	2.2	2.95	{0.5,1.5,1.75,2.0,2.5,3.5,4.5,5.5,6.5}	{1.11,1.53,1.95,2.56,5.0,13.0,26.0,46.0}	{7.0,2.5,1.9,1.5,1.17,1.05,1.01,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.57,1.85,3.75,13.0,29.0,71.0}	{2.38,1.95,1.29,1.05,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.4,2.63,7.0,19.0}	{3.0,1.44,1.11,1.02}	https://www.oddsportal.com/football/greece/super-league/levadiakos-ofi-crete-4vQUe3E9/#1X2;2	2023-05-07 19:03:02.434942+01
63	Panetolikos	Lamia	2023-03-12 19:00:00+00	1	1	2.25	3.1	4	3.1	1.95	1	1	0	0	4.33	2.7	2.2	3.7	{0.5,1.5,2.0,2.5,3.5,4.5,5.5,6.5}	{1.11,1.53,1.95,2.5,5.0,13.0,26.0,41.0}	{7.0,2.5,1.9,1.53,1.17,1.05,1.01,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.57,1.85,3.75,11.0,29.0,71.0}	{2.38,1.95,1.29,1.05,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.63,6.5,19.0}	{3.25,1.44,1.11,1.02}	https://www.oddsportal.com/football/greece/super-league/panetolikos-lamia-rVOYfNTF/#1X2;2	2023-05-07 19:03:33.714464+01
64	Volos	PAOK	2023-03-12 19:00:00+00	0	1	11.7	5.3	1	9.5	2.4	0	0	1	0	1.8	9.0	2.85	1.57	{0.5,1.5,2.5,2.75,3.5,4.5,5.5,6.5}	{1.05,1.3,1.94,3.25,6.0,13.0,26.0}	{11.0,3.75,1.98,1.36,1.13,1.04,1.01}	{0.5,1.0,1.25,1.5,2.5,3.5,4.5}	{1.4,1.8,2.63,7.0,21.0,46.0}	{3.0,2.0,1.44,1.1,1.02,1.01}	{0.5,1.5,2.5,3.5,4.5}	{1.29,2.1,4.5,11.0,26.0}	{4.0,1.73,1.2,1.05,1.01}	https://www.oddsportal.com/football/greece/super-league/volos-paok-pxATcPqc/#1X2;2	2023-05-07 19:04:06.332427+01
65	Atromitos	AEK Athens FC	2023-03-08 17:30:00+00	0	1	10.0	5.25	1	8.0	2.55	0	0	1	0	1.8	8.0	3.05	1.57	{0.5,1.5,2.25,2.5,2.75,3.5,4.5,5.5,6.5,7.5}	{1.04,1.22,1.7,1.8,2.75,5.1,10.0,19.0}	{15.0,4.5,2.25,2.05,1.5,1.18,1.06,1.02}	{0.5,1.0,1.25,1.5,2.5,3.5,4.5}	{1.36,2.02,2.45,6.0,17.0,41.0}	{3.4,1.77,1.53,1.13,1.02,1.01}	{0.5,1.5,2.5,3.5,4.5}	{1.22,2.0,4.0,9.0,21.0}	{5.0,1.83,1.25,1.07,1.02}	https://www.oddsportal.com/football/greece/super-league/atromitos-aek-bPsWNI2Q/#1X2;2	2023-05-07 19:04:39.057115+01
66	Panathinaikos	Panetolikos	2023-03-06 19:30:00+00	2	0	1.23	6.0	16	1.73	2.6	0	2	0	0	13.0	1.51	3.15	13.0	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.06,1.33,2.02,3.5,7.0,17.0,34.0}	{11.5,3.7,1.88,1.3,1.11,1.03,1.0}	{0.5,1.0,1.5,2.5,3.5,4.5}	{1.4,1.95,3.0,8.0,23.0,46.0}	{3.25,1.85,1.44,1.11,1.02,1.01}	{0.5,1.5,2.5,3.5}	{1.33,2.2,5.0,15.0}	{3.75,1.64,1.17,1.03}	https://www.oddsportal.com/football/greece/super-league/panathinaikos-panetolikos-r9mbrppA/#1X2;2	2023-05-07 19:05:11.463548+01
67	PAOK	Ionikos	2023-03-05 20:30:00+00	6	0	1.18	6.75	21	1.57	2.7	0	2	0	4	15.0	1.42	3.2	15.0	{0.5,1.5,2.5,2.75,3.5,4.5,5.5,6.5,7.5}	{1.04,1.25,1.83,2.0,3.05,6.0,13.0,26.0,51.0}	{13.0,4.1,2.05,1.85,1.44,1.15,1.05,1.01,1.0}	{0.5,1.0,1.25,1.5,2.5,3.5,4.5}	{1.36,1.75,2.63,7.0,19.0,41.0}	{3.25,2.05,1.5,1.12,1.02,1.01}	{0.5,1.5,2.5,3.5,4.5}	{1.25,2.0,4.33,11.0,26.0}	{4.1,1.73,1.22,1.05,1.01}	https://www.oddsportal.com/football/greece/super-league/paok-ionikos-QXx3s4aG/#1X2;2	2023-05-07 19:05:44.769804+01
68	OFI Crete	AEK Athens FC	2023-03-05 19:30:00+00	0	3	7.0	4.4	1	6.5	2.4	2	0	1	0	2.0	6.25	2.8	1.75	{0.5,1.5,2.25,2.5,2.75,3.5,4.5,5.5,6.5,7.5}	{1.05,1.25,1.85,3.1,6.0,11.0,23.0}	{13.0,4.0,2.05,1.4,1.14,1.05,1.01}	{0.5,1.0,1.25,1.5,2.5,3.5,4.5}	{1.36,1.75,2.63,7.0,19.0,46.0}	{3.2,2.05,1.44,1.1,1.02,1.01}	{0.5,1.5,2.5,3.5,4.5}	{1.25,2.1,4.33,11.0,26.0}	{4.33,1.75,1.22,1.05,1.01}	https://www.oddsportal.com/football/greece/super-league/ofi-crete-aek-WYqfqQU3/#1X2;2	2023-05-07 19:06:17.865927+01
69	Lamia	Aris	2023-03-05 17:30:00+00	2	1	5.25	3.55	2	5.5	2.08	0	0	1	2	2.5	5.0	2.35	2.1	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.1,1.44,1.8,2.13,2.4,4.6,11.0,23.0,51.0}	{8.5,2.85,2.05,1.75,1.57,1.2,1.06,1.02,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.53,1.77,3.5,11.0,23.0,61.0}	{2.75,2.02,1.36,1.07,1.01,1.0}	{0.5,1.5,2.5,3.5,4.5}	{1.36,2.62,6.5,17.0}	{3.25,1.5,1.12,1.02}	https://www.oddsportal.com/football/greece/super-league/lamia-aris-YctBurUS/#1X2;2	2023-05-07 19:06:51.003357+01
70	Giannina	Volos	2023-03-05 17:00:00+00	0	1	2.1	3.4	4	2.75	2.0	1	0	0	0	4.75	2.48	2.3	4.33	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.1,1.44,1.83,2.4,4.5,11.0,23.0,51.0}	{8.0,2.88,2.02,1.58,1.2,1.06,1.02,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.5,1.77,3.5,11.0,26.0,61.0}	{2.6,2.02,1.33,1.06,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.62,6.0,17.0}	{3.4,1.5,1.13,1.02}	https://www.oddsportal.com/football/greece/super-league/giannina-volos-4Oy7tOEM/#1X2;2	2023-05-07 19:07:23.788582+01
71	Olympiacos Piraeus	Levadiakos	2023-03-05 16:00:00+00	6	0	1.17	7.65	19	1.57	2.9	0	4	0	2	13.0	1.39	3.55	14.0	{0.5,1.5,2.5,2.75,3.0,3.5,4.5,5.5,6.5,7.5}	{1.03,1.22,1.67,1.85,2.7,5.1,10.0,21.0,41.0}	{15.0,4.5,2.25,2.0,1.5,1.2,1.07,1.02,1.0}	{0.5,1.25,1.5,2.5,3.5,4.5}	{1.33,2.05,2.5,6.0,17.0,36.0}	{3.5,1.75,1.53,1.14,1.02,1.01}	{0.5,1.5,2.5,3.5,4.5}	{1.22,1.91,4.0,10.0,23.0}	{4.5,1.85,1.25,1.06,1.01}	https://www.oddsportal.com/football/greece/super-league/olympiacos-piraeus-levadiakos-xCpjp6Fc/#1X2;2	2023-05-07 19:07:58.188808+01
72	Asteras Tripolis	Atromitos	2023-03-04 20:00:00+00	1	1	2.45	3.1	3	3.25	1.95	0	1	1	0	4.0	2.88	2.2	3.6	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.11,1.5,1.9,2.5,5.1,11.5,26.0,51.0}	{7.0,2.63,1.95,1.52,1.17,1.05,1.02,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.57,1.83,3.75,11.0,29.0,71.0}	{2.43,1.98,1.29,1.05,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.4,2.65,6.5,19.0}	{3.25,1.44,1.11,1.02}	https://www.oddsportal.com/football/greece/super-league/asteras-tripolis-atromitos-bLonon0i/#1X2;2	2023-05-07 19:08:30.485434+01
73	Aris	Atromitos	2023-02-26 19:30:00+00	2	1	1.47	4.0	8	2.05	2.25	1	0	0	2	7.0	1.85	2.6	6.0	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.06,1.32,1.8,2.05,3.5,7.0,17.0,34.0}	{10.0,3.4,2.05,1.84,1.33,1.11,1.03,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.4,1.98,3.0,8.0,23.0,51.0}	{2.75,1.83,1.44,1.08,1.02,1.0}	{0.5,1.5,2.5,3.5}	{1.29,2.2,5.0,13.0}	{3.75,1.62,1.17,1.04}	https://www.oddsportal.com/football/greece/super-league/aris-atromitos-jFOKUQFA/#1X2;2	2023-05-07 19:09:02.68664+01
74	Ionikos	OFI Crete	2023-02-26 16:00:00+00	0	2	2.8	3.0	3	3.5	1.95	2	0	0	0	3.5	3.2	2.2	3.1	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.11,1.44,1.85,2.4,4.5,11.0,23.0,36.0}	{7.0,2.63,2.0,1.53,1.2,1.06,1.02,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.53,1.8,3.75,11.0,26.0,67.0}	{2.5,2.0,1.33,1.05,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.5,6.5,19.0}	{3.25,1.5,1.12,1.02}	https://www.oddsportal.com/football/greece/super-league/ionikos-ofi-crete-CUCTS4pN/#1X2;2	2023-05-07 19:09:35.226908+01
75	Levadiakos	Panetolikos	2023-02-26 16:00:00+00	0	0	2.5	3.0	3	3.4	1.91	0	0	0	0	4.0	3.0	2.1	3.5	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.13,1.53,2.1,2.75,5.5,13.0,29.0,46.0}	{6.0,2.38,1.77,1.44,1.14,1.04,1.01,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.62,1.95,4.0,13.0,31.0,71.0}	{2.38,1.85,1.29,1.05,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.4,2.75,8.0,21.0}	{3.0,1.4,1.1,1.02}	https://www.oddsportal.com/football/greece/super-league/levadiakos-panetolikos-QXGXROaT/#1X2;2	2023-05-07 19:10:07.252989+01
76	Olympiacos Piraeus	Panathinaikos	2023-02-25 20:30:00+00	0	0	2.1	3.0	4	2.88	1.91	0	0	0	0	5.0	2.6	2.1	4.33	{0.5,1.5,1.75,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.13,1.57,1.77,2.88,6.0,15.0,29.0,51.0}	{6.0,2.3,2.1,1.44,1.14,1.04,1.01,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.62,1.95,4.0,15.0,31.0,81.0}	{2.3,1.85,1.29,1.04,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.44,3.0,8.0,23.0}	{2.75,1.4,1.1,1.02}	https://www.oddsportal.com/football/greece/super-league/olympiacos-piraeus-panathinaikos-rD3aNr8p/#1X2;2	2023-05-07 19:10:39.480569+01
77	Giannina	PAOK	2023-02-25 19:00:00+00	0	0	8.0	3.9	2	7.0	2.2	0	0	0	0	2.1	6.5	2.5	1.91	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.07,1.36,1.9,2.1,3.75,8.0,19.0,31.0}	{9.0,3.0,1.95,1.7,1.25,1.08,1.02,1.0}	{0.5,1.0,1.5,2.5,3.5,4.5}	{1.44,2.08,3.25,9.0,26.0,56.0}	{2.75,1.73,1.36,1.07,1.02,1.0}	{0.5,1.5,2.5,3.5}	{1.33,2.38,5.5,15.0}	{3.5,1.57,1.14,1.03}	https://www.oddsportal.com/football/greece/super-league/giannina-paok-M323M2Nj/#1X2;2	2023-05-07 19:11:13.46038+01
78	AEK Athens FC	Asteras Tripolis	2023-02-25 17:30:00+00	2	0	1.18	6.75	19	1.57	2.75	0	1	0	1	12.0	1.4	3.3	11.0	{0.5,1.5,2.5,2.75,3.5,4.5,5.5,6.5}	{1.03,1.22,1.67,1.83,2.63,4.5,10.0,19.0}	{15.0,4.33,2.2,2.02,1.44,1.2,1.06,1.02}	{0.5,1.0,1.25,1.5,2.5,3.5,4.5}	{1.3,2.02,2.38,6.0,17.0,36.0}	{3.4,1.77,1.53,1.14,1.02,1.01}	{0.5,1.5,2.5,3.5,4.5}	{1.25,2.0,4.0,9.0,21.0}	{4.5,1.85,1.25,1.07,1.02}	https://www.oddsportal.com/football/greece/super-league/aek-asteras-tripolis-dvAHV604/#1X2;2	2023-05-07 19:11:46.886169+01
79	Volos	Lamia	2023-02-24 20:00:00+00	1	1	1.95	3.5	4	2.75	2.05	0	1	1	0	4.5	2.38	2.3	4.33	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.08,1.4,2.05,2.3,4.33,10.0,21.0,51.0}	{9.0,2.75,1.8,1.62,1.22,1.07,1.02,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.5,1.73,3.4,10.0,26.0,61.0}	{2.62,2.08,1.33,1.06,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.38,6.0,17.0}	{3.4,1.53,1.13,1.02}	https://www.oddsportal.com/football/greece/super-league/volos-lamia-U5NOTpVG/#1X2;2	2023-05-07 19:12:19.743063+01
80	OFI Crete	Aris	2023-02-20 19:30:00+00	0	3	3.4	3.1	2	4.25	1.91	1	0	2	0	3.25	3.85	2.2	2.75	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.11,1.52,1.93,2.75,5.6,13.0,26.0,41.0}	{7.0,2.5,1.93,1.5,1.17,1.05,1.02,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.57,1.83,3.9,13.0,29.0,71.0}	{2.38,1.98,1.29,1.05,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.4,2.63,7.0,19.0}	{3.0,1.44,1.11,1.02}	https://www.oddsportal.com/football/greece/super-league/ofi-crete-aris-Wh6gRi9I/#1X2;2	2023-05-07 19:12:53.3379+01
81	Atromitos	Levadiakos	2023-02-20 18:00:00+00	1	0	1.85	3.2	5	2.6	2.0	0	0	0	1	5.6	2.25	2.25	5.1	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.1,1.44,1.85,2.48,5.0,11.0,23.0,36.0}	{7.5,2.65,2.0,1.53,1.19,1.06,1.02,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.53,1.8,3.6,12.5,26.0,61.0}	{2.5,2.0,1.3,1.06,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.4,2.63,6.0,17.0}	{3.25,1.5,1.13,1.02}	https://www.oddsportal.com/football/greece/super-league/atromitos-levadiakos-EHBlSXgC/#1X2;2	2023-05-07 19:13:25.298728+01
82	PAOK	AEK Athens FC	2023-02-19 20:30:00+00	2	0	2.7	3.0	3	3.5	1.91	0	1	0	1	3.75	3.2	2.2	3.2	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.11,1.5,1.95,2.6,5.2,13.0,26.0,41.0}	{7.0,2.6,1.9,1.5,1.17,1.05,1.02,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.57,1.85,3.75,11.0,29.0,71.0}	{2.5,1.95,1.3,1.05,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.7,6.5,19.0}	{3.25,1.5,1.11,1.02}	https://www.oddsportal.com/football/greece/super-league/paok-aek-zPL8XSVi/#1X2;2	2023-05-07 19:13:57.094391+01
83	Panetolikos	Ionikos	2023-02-19 19:30:00+00	1	0	2.1	3.0	4	2.88	1.95	0	1	0	0	4.5	2.55	2.2	4.2	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.11,1.5,1.88,2.5,5.0,11.0,26.0,51.0}	{7.5,2.65,1.98,1.51,1.18,1.05,1.02,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.53,1.8,3.75,11.0,29.0,71.0}	{2.5,2.0,1.3,1.06,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.63,6.5,19.0}	{3.25,1.5,1.11,1.02}	https://www.oddsportal.com/football/greece/super-league/panetolikos-ionikos-MLH4Y8Go/#1X2;2	2023-05-07 19:14:29.826038+01
84	Lamia	Olympiacos Piraeus	2023-02-19 16:00:00+00	0	3	12.0	4.8	1	10.0	2.4	2	0	1	0	1.83	9.5	2.88	1.65	{0.5,1.5,2.5,2.75,3.5,4.5,5.5,6.5}	{1.06,1.33,2.0,3.4,7.0,15.0,29.0}	{11.0,3.65,1.85,1.3,1.1,1.03,1.01}	{0.5,1.0,1.5,2.5,3.5,4.5}	{1.41,1.9,2.87,8.0,21.0,51.0}	{2.95,1.9,1.4,1.08,1.02,1.0}	{0.5,1.5,2.5,3.5,4.5}	{1.3,2.3,4.75,13.0}	{3.75,1.67,1.18,1.04}	https://www.oddsportal.com/football/greece/super-league/lamia-olympiacos-piraeus-ImBDWnob/#1X2;2	2023-05-07 19:15:02.834004+01
85	Asteras Tripolis	Giannina	2023-02-18 20:00:00+00	1	1	2.05	3.05	5	2.75	1.95	0	0	1	1	4.75	2.45	2.23	4.33	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.11,1.53,1.98,2.6,5.0,13.0,26.0,46.0}	{7.5,2.63,1.88,1.5,1.17,1.05,1.01,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.57,1.85,3.75,13.0,31.0,71.0}	{2.43,1.95,1.29,1.05,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.4,2.65,7.0,19.0}	{3.0,1.44,1.1,1.02}	https://www.oddsportal.com/football/greece/super-league/asteras-tripolis-giannina-zRCpTDv6/#1X2;2	2023-05-07 19:15:33.88343+01
86	Panathinaikos	Volos	2023-02-18 17:00:00+00	2	0	1.33	4.9	12	1.83	2.33	0	2	0	0	10.0	1.62	2.75	9.5	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.08,1.36,1.88,2.1,3.9,8.0,19.0,41.0}	{10.0,3.25,1.98,1.7,1.26,1.09,1.02,1.0}	{0.5,1.0,1.5,2.5,3.5,4.5}	{1.44,2.05,3.25,9.0,26.0,56.0}	{2.85,1.75,1.4,1.08,1.02,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.5,5.5,15.0}	{3.5,1.58,1.16,1.03}	https://www.oddsportal.com/football/greece/super-league/panathinaikos-volos-8ITM9Pwo/#1X2;2	2023-05-07 19:16:05.496967+01
87	Olympiacos Piraeus	Panetolikos	2023-02-13 21:00:00+00	6	1	1.18	7.3	17	1.57	2.75	1	4	0	2	13.0	1.42	3.25	11.0	{0.5,1.5,2.5,2.75,3.0,3.5,4.5,5.5,6.5,7.5}	{1.04,1.2,1.65,1.85,2.63,5.0,10.0,21.0,41.0}	{13.0,4.33,2.28,2.0,1.53,1.2,1.07,1.02,1.0}	{0.5,1.0,1.25,1.5,2.5,3.5,4.5}	{1.3,2.05,2.5,6.0,17.0,34.0}	{3.5,1.75,1.6,1.15,1.03,1.01}	{0.5,1.5,2.5,3.5,4.5}	{1.22,1.91,3.75,10.0,23.0}	{4.5,1.83,1.25,1.06,1.01}	https://www.oddsportal.com/football/greece/super-league/olympiacos-piraeus-panetolikos-n5KXVFfm/#1X2;2	2023-05-07 19:16:38.493858+01
88	AEK Athens FC	Levadiakos	2023-02-13 18:30:00+00	3	0	1.13	9.0	26	1.44	3.0	0	1	0	2	17.0	1.35	3.6	15.0	{0.5,1.5,2.5,2.75,3.0,3.5,4.5,5.5,6.5,7.5}	{1.02,1.17,1.53,1.9,2.38,4.0,8.0,17.0,29.0}	{19.0,5.0,2.4,1.95,1.57,1.22,1.08,1.03,1.01}	{0.5,1.25,1.5,2.5,3.5,4.5}	{1.29,1.93,2.25,5.5,15.0,29.0}	{3.75,1.88,1.67,1.17,1.04,1.01}	{0.5,1.5,2.5,3.5,4.5}	{1.2,1.8,3.5,8.0,21.0}	{5.0,1.91,1.29,1.08,1.02}	https://www.oddsportal.com/football/greece/super-league/aek-levadiakos-zRjFDYvJ/#1X2;2	2023-05-07 19:17:11.803742+01
89	Asteras Tripolis	PAOK	2023-02-13 18:00:00+00	2	2	5.75	3.4	2	6.5	2.0	1	2	1	0	2.4	5.8	2.25	2.05	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.11,1.5,1.9,2.5,5.0,11.0,26.0,41.0}	{7.0,2.5,1.95,1.5,1.18,1.05,1.02,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.57,1.83,3.75,11.0,29.0,67.0}	{2.5,1.98,1.33,1.06,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.4,2.63,7.0,19.0}	{3.0,1.44,1.11,1.02}	https://www.oddsportal.com/football/greece/super-league/asteras-tripolis-paok-GMT1yxXP/#1X2;2	2023-05-07 19:17:44.705315+01
90	Lamia	OFI Crete	2023-02-13 17:00:00+00	1	4	2.85	3.1	3	3.6	1.91	2	1	2	0	3.5	3.2	2.2	3.1	{0.5,1.5,1.75,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.12,1.53,1.95,2.62,5.0,13.0,26.0,46.0}	{7.0,2.5,1.9,1.5,1.17,1.04,1.01,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.57,1.85,3.75,13.0,29.0,71.0}	{2.38,1.95,1.29,1.05,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.4,2.65,7.0,19.0}	{3.25,1.44,1.1,1.02}	https://www.oddsportal.com/football/greece/super-league/lamia-ofi-crete-t4DtUgPa/#1X2;2	2023-05-07 19:18:17.340804+01
91	Aris	Panathinaikos	2023-02-12 20:00:00+00	1	2	2.63	2.8	3	3.6	1.8	1	0	1	1	4.33	3.1	1.98	3.6	{0.5,1.5,1.75,2.0,2.5,3.5,4.5,5.5,6.5}	{1.18,1.8,2.1,3.6,8.0,21.0,51.0,67.0}	{5.0,2.05,1.77,1.34,1.11,1.02,1.01,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.8,2.08,5.5,19.0,41.0,91.0}	{2.2,1.73,1.22,1.03,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.5,3.4,10.0,26.0}	{2.5,1.33,1.07,1.01}	https://www.oddsportal.com/football/greece/super-league/aris-panathinaikos-xWUcxIHJ/#1X2;2	2023-05-07 19:18:48.57595+01
92	Volos	Atromitos	2023-02-12 16:00:00+00	2	1	2.3	3.3	3	3.0	2.05	1	2	0	0	3.75	2.63	2.38	3.5	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.07,1.36,1.9,2.16,3.75,8.0,19.0,41.0}	{9.0,3.0,1.95,1.7,1.25,1.08,1.02,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.44,2.08,3.25,10.0,26.0,56.0}	{2.63,1.73,1.36,1.07,1.02,1.0}	{0.5,1.5,2.5,3.5}	{1.3,2.3,5.5,15.0}	{3.5,1.57,1.15,1.03}	https://www.oddsportal.com/football/greece/super-league/volos-atromitos-8ELTWeus/#1X2;2	2023-05-07 19:19:19.360952+01
93	Giannina	Ionikos	2023-02-11 20:00:00+00	0	0	2.0	3.3	4	2.75	1.95	0	0	0	0	4.75	2.45	2.25	4.2	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.11,1.46,1.88,2.4,5.0,11.0,26.0,41.0}	{8.0,2.63,1.98,1.53,1.18,1.05,1.02,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.53,1.8,3.75,11.0,29.0,67.0}	{2.5,2.0,1.33,1.06,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.4,2.63,6.5,19.0}	{3.25,1.44,1.11,1.02}	https://www.oddsportal.com/football/greece/super-league/giannina-ionikos-UT9xVZ9g/#1X2;2	2023-05-07 19:19:51.095486+01
94	Levadiakos	Volos	2023-02-06 16:00:00+00	0	3	2.4	2.95	3	3.25	1.91	3	0	0	0	4.1	2.88	2.15	3.65	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.13,1.53,2.05,2.7,5.5,13.0,26.0,46.0}	{6.75,2.6,1.8,1.48,1.16,1.05,1.01,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.62,1.93,4.0,13.0,29.0,71.0}	{2.35,1.88,1.29,1.05,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.4,2.75,7.0,21.0}	{3.0,1.44,1.1,1.02}	https://www.oddsportal.com/football/greece/super-league/levadiakos-volos-U7Y1IdQm/#1X2;2	2023-05-07 19:20:23.182087+01
95	PAOK	Olympiacos Piraeus	2023-02-05 20:30:00+00	0	0	2.4	3.1	3	3.25	1.95	0	0	0	0	4.0	2.9	2.2	3.7	{0.5,1.5,1.75,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.11,1.5,1.95,2.63,5.4,13.0,26.0,41.0}	{7.0,2.55,1.9,1.5,1.17,1.05,1.02,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.57,1.85,3.8,11.0,29.0,71.0}	{2.38,1.95,1.29,1.05,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.4,2.75,6.5,19.0}	{3.25,1.44,1.11,1.02}	https://www.oddsportal.com/football/greece/super-league/paok-olympiacos-piraeus-MNnBEEPC/#1X2;2	2023-05-07 19:20:56.624826+01
96	Panetolikos	Asteras Tripolis	2023-02-05 20:00:00+00	0	0	3.2	2.8	3	4.0	1.85	0	0	0	0	3.6	3.4	2.08	3.15	{0.5,1.5,1.75,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.14,1.57,1.8,2.13,2.88,6.0,15.0,26.0,51.0}	{6.1,2.43,2.05,1.75,1.44,1.13,1.03,1.01,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.67,1.98,4.33,15.0,31.0,81.0}	{2.3,1.83,1.25,1.04,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.44,3.0,8.0,23.0}	{2.75,1.4,1.08,1.02}	https://www.oddsportal.com/football/greece/super-league/panetolikos-asteras-tripolis-S0m7FfA6/#1X2;2	2023-05-07 19:21:28.896156+01
97	Panathinaikos	Lamia	2023-02-05 17:00:00+00	2	0	1.33	4.75	13	1.85	2.25	0	1	0	1	11.0	1.67	2.63	9.5	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.08,1.4,1.98,2.2,4.1,9.0,19.0,34.0}	{9.0,3.05,1.88,1.65,1.22,1.07,1.02,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.44,2.1,3.25,10.0,26.0,56.0}	{2.7,1.7,1.36,1.08,1.02,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.5,5.5,15.0}	{3.5,1.53,1.14,1.03}	https://www.oddsportal.com/football/greece/super-league/panathinaikos-lamia-lAl3Gze0/#1X2;2	2023-05-07 19:22:02.969777+01
98	Ionikos	Aris	2023-02-04 19:00:00+00	1	0	6.5	3.5	2	6.5	2.0	0	1	0	0	2.48	6.0	2.25	2.23	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.11,1.53,1.93,2.5,5.1,11.5,26.0,46.0}	{7.5,2.63,1.93,1.55,1.17,1.05,1.01,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.53,1.83,3.75,11.0,29.0,71.0}	{2.5,1.98,1.3,1.06,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.4,2.75,7.0,19.0}	{3.0,1.44,1.1,1.02}	https://www.oddsportal.com/football/greece/super-league/ionikos-aris-zoZcJxBs/#1X2;2	2023-05-07 19:22:34.271833+01
99	OFI Crete	Giannina	2023-02-04 17:00:00+00	0	0	2.02	3.4	4	2.75	2.1	0	0	0	0	4.75	2.43	2.38	4.2	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.08,1.44,1.93,2.3,4.1,9.0,19.0,34.0}	{9.0,3.0,1.93,1.67,1.25,1.07,1.02,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.46,1.68,2.1,3.25,10.0,26.0,61.0}	{2.65,2.15,1.7,1.33,1.06,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.38,5.5,15.0}	{3.5,1.57,1.14,1.03}	https://www.oddsportal.com/football/greece/super-league/ofi-crete-giannina-8bX5HGuf/#1X2;2	2023-05-07 19:23:06.333218+01
100	Asteras Tripolis	Panathinaikos	2023-01-30 21:00:00+00	1	0	5.0	3.15	2	5.5	1.92	0	1	0	0	2.75	5.0	2.18	2.4	{0.5,1.5,1.75,2.0,2.5,3.5,4.5,5.5,6.5}	{1.14,1.62,1.83,2.88,6.0,15.0,26.0,51.0}	{6.75,2.4,2.02,1.42,1.13,1.03,1.01,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.62,1.98,4.0,13.0,31.0,81.0}	{2.32,1.83,1.29,1.05,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.44,3.0,8.0,23.0}	{2.88,1.4,1.08,1.02}	https://www.oddsportal.com/football/greece/super-league/asteras-tripolis-panathinaikos-UggT3cBf/#1X2;2	2023-05-07 19:23:38.712352+01
101	Lamia	Ionikos	2023-01-30 19:30:00+00	0	2	2.15	3.05	4	2.88	1.93	0	0	2	0	4.6	2.7	2.2	4.1	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.12,1.57,2.02,2.75,5.5,13.0,26.0,46.0}	{7.0,2.5,1.83,1.46,1.15,1.04,1.01,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.57,1.9,3.8,13.0,29.0,71.0}	{2.38,1.9,1.29,1.05,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.44,2.75,7.0,19.0}	{3.0,1.44,1.1,1.02}	https://www.oddsportal.com/football/greece/super-league/lamia-ionikos-G0hRObmK/#1X2;2	2023-05-07 19:24:11.03499+01
102	PAOK	Levadiakos	2023-01-30 18:00:00+00	3	2	1.18	6.5	21	1.62	2.63	1	1	1	2	15.0	1.44	3.05	15.0	{0.5,1.5,2.5,2.75,3.5,4.5,5.5,6.5}	{1.06,1.36,2.06,3.9,8.0,15.0,26.0}	{11.0,3.5,1.9,1.3,1.11,1.03,1.0}	{0.5,1.0,1.5,2.5,3.5,4.5}	{1.4,1.85,3.0,8.0,21.0,46.0}	{3.0,1.95,1.4,1.1,1.02,1.01}	{0.5,1.5,2.5,3.5,4.5}	{1.33,2.38,5.0,13.0}	{4.0,1.67,1.18,1.04}	https://www.oddsportal.com/football/greece/super-league/paok-levadiakos-lf0u1eeD/#1X2;2	2023-05-07 19:24:43.584598+01
103	AEK Athens FC	Aris	2023-01-29 19:30:00+00	3	0	1.4	4.5	10	2.0	2.2	0	2	0	1	8.5	1.75	2.55	7.5	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.08,1.4,1.93,2.15,4.0,9.0,19.0,31.0}	{10.0,3.15,1.93,1.68,1.23,1.08,1.02,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.44,2.08,3.25,9.0,26.0,56.0}	{2.7,1.73,1.36,1.07,1.02,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.38,5.5,15.0}	{3.5,1.55,1.14,1.03}	https://www.oddsportal.com/football/greece/super-league/aek-aris-zXgP4wdl/#1X2;2	2023-05-07 19:25:17.149864+01
104	Olympiacos Piraeus	OFI Crete	2023-01-29 16:00:00+00	2	1	1.3	6.0	12	1.8	2.75	0	1	1	1	8.5	1.57	3.2	9.0	{0.5,1.5,2.5,2.75,3.5,4.5,5.5,6.5}	{1.04,1.25,1.75,2.0,2.88,5.5,11.0,23.0}	{15.0,4.25,2.08,1.85,1.4,1.14,1.05,1.01}	{0.5,1.0,1.25,1.5,2.5,3.5,4.5}	{1.33,1.73,2.63,6.5,19.0,41.0}	{3.45,2.08,1.46,1.11,1.02,1.0}	{0.5,1.5,2.5,3.5,4.5}	{1.2,1.95,4.0,11.0,26.0}	{4.33,1.8,1.22,1.05,1.01}	https://www.oddsportal.com/football/greece/super-league/olympiacos-piraeus-ofi-crete-A31y2yt7/#1X2;2	2023-05-07 19:25:49.440585+01
105	Giannina	Atromitos	2023-01-28 20:00:00+00	1	1	2.45	3.2	3	3.2	2.0	1	0	0	1	3.95	2.88	2.3	3.65	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.1,1.44,1.75,2.02,2.42,4.75,10.5,21.0,36.0}	{8.0,2.8,2.13,1.83,1.62,1.2,1.06,1.02,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.5,1.73,3.5,10.0,26.0,67.0}	{2.55,2.08,1.3,1.06,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.55,6.0,17.0}	{3.4,1.53,1.13,1.02}	https://www.oddsportal.com/football/greece/super-league/giannina-atromitos-xAgNPvYD/#1X2;2	2023-05-07 19:26:22.155048+01
106	Volos	Panetolikos	2023-01-28 19:30:00+00	2	3	1.78	3.5	5	2.4	2.12	2	1	1	1	5.0	2.16	2.43	4.6	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.07,1.36,1.88,2.1,3.95,8.5,19.0,29.0}	{10.0,3.25,1.98,1.7,1.26,1.09,1.02,1.0}	{0.5,1.0,1.5,2.5,3.5,4.5}	{1.44,2.05,3.25,9.0,26.0,56.0}	{2.8,1.75,1.36,1.07,1.02,1.0}	{0.5,1.5,2.5,3.5}	{1.3,2.3,5.0,15.0}	{3.75,1.62,1.17,1.03}	https://www.oddsportal.com/football/greece/super-league/volos-panetolikos-SvCW2HQ0/#1X2;2	2023-05-07 19:26:53.028121+01
107	Atromitos	Olympiacos Piraeus	2023-01-22 20:30:00+00	1	1	9.0	4.75	1	7.5	2.45	1	1	0	0	1.95	6.5	2.8	1.73	{0.5,1.5,2.5,2.75,3.5,4.5,5.5,6.5}	{1.05,1.29,1.93,3.4,6.5,15.0,26.0}	{13.0,3.85,1.96,1.33,1.12,1.04,1.01}	{0.5,1.0,1.25,1.5,2.5,3.5,4.5}	{1.36,1.85,2.75,7.0,21.0,46.0}	{3.2,1.95,1.44,1.11,1.02,1.01}	{0.5,1.5,2.5,3.5,4.5}	{1.29,2.2,4.5,13.0}	{4.0,1.68,1.19,1.04}	https://www.oddsportal.com/football/greece/super-league/atromitos-olympiacos-piraeus-SQWclIB7/#1X2;2	2023-05-07 19:27:24.544237+01
108	Panathinaikos	PAOK	2023-01-22 19:30:00+00	0	3	2.4	2.9	3	3.4	1.83	2	0	1	0	4.33	2.9	2.06	3.85	{0.5,1.5,1.75,2.0,2.5,3.5,4.5,5.5,6.5}	{1.15,1.67,1.93,3.1,7.0,17.0,29.0,56.0}	{6.0,2.23,1.93,1.36,1.11,1.03,1.01,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.67,2.05,4.33,15.0,34.0,81.0}	{2.3,1.75,1.25,1.04,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.5,3.25,9.0,26.0}	{2.7,1.37,1.07,1.02}	https://www.oddsportal.com/football/greece/super-league/panathinaikos-paok-GnDhAaYQ/#1X2;2	2023-05-07 19:27:56.699007+01
109	Levadiakos	Lamia	2023-01-22 17:00:00+00	0	0	2.4	2.9	4	3.4	1.85	0	0	0	0	4.5	2.9	2.0	4.0	{0.5,1.5,1.75,2.0,2.5,3.5,4.5,5.5,6.5}	{1.15,1.67,2.0,3.4,7.0,19.0,31.0,61.0}	{5.5,2.1,1.85,1.34,1.11,1.02,1.01,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.73,2.08,4.5,17.0,34.0,81.0}	{2.38,1.73,1.25,1.04,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.5,3.25,10.0,26.0}	{2.63,1.36,1.07,1.01}	https://www.oddsportal.com/football/greece/super-league/levadiakos-lamia-rZEpCL3E/#1X2;2	2023-05-07 19:28:28.374764+01
110	Ionikos	AEK Athens FC	2023-01-22 16:00:00+00	1	2	15.0	6.1	1	11.0	2.7	2	0	0	1	1.73	10.0	3.2	1.53	{0.5,1.5,2.5,2.75,3.5,4.5,5.5,6.5}	{1.04,1.25,1.83,2.0,3.0,6.0,13.0,26.0}	{14.0,4.25,2.11,1.85,1.44,1.17,1.05,1.01}	{0.5,1.0,1.25,1.5,2.5,3.5,4.5}	{1.36,1.75,2.1,2.63,7.0,19.0,41.0}	{3.35,2.05,1.7,1.53,1.12,1.02,1.01}	{0.5,1.5,2.5,3.5,4.5}	{1.25,2.05,4.33,11.0,26.0}	{4.1,1.75,1.22,1.05,1.01}	https://www.oddsportal.com/football/greece/super-league/ionikos-aek-UVAtD1l8/#1X2;2	2023-05-07 19:29:14.071658+01
111	Aris	Volos	2023-01-21 20:00:00+00	3	0	1.45	4.5	8	2.0	2.35	0	3	0	0	7.0	1.75	2.7	6.75	{0.5,1.5,2.5,3.5,4.5,5.5,6.5}	{1.05,1.3,1.98,3.55,7.5,15.0,23.0}	{11.0,3.5,1.88,1.33,1.11,1.03,1.0}	{0.5,1.0,1.5,2.5,3.5,4.5}	{1.4,1.9,2.88,8.0,21.0,46.0}	{3.0,1.9,1.4,1.1,1.02,1.01}	{0.5,1.5,2.5,3.5}	{1.3,2.2,4.75,13.0}	{4.0,1.67,1.18,1.04}	https://www.oddsportal.com/football/greece/super-league/aris-volos-lzYgkbd1/#1X2;2	2023-05-07 19:29:46.954257+01
112	OFI Crete	Asteras Tripolis	2023-01-21 17:00:00+00	1	0	2.1	3.4	4	2.88	2.05	0	1	0	0	4.33	2.62	2.3	4.0	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.1,1.44,2.02,2.48,5.0,11.0,21.0,36.0}	{8.0,2.75,1.83,1.62,1.22,1.07,1.02,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.5,1.73,3.6,11.0,26.0,61.0}	{2.62,2.08,1.33,1.06,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.33,2.5,6.0,17.0}	{3.4,1.53,1.13,1.02}	https://www.oddsportal.com/football/greece/super-league/ofi-crete-asteras-tripolis-xdElBuJK/#1X2;2	2023-05-07 19:30:20.848672+01
113	Panetolikos	Giannina	2023-01-20 20:30:00+00	1	1	2.55	3.0	3	3.4	1.91	1	1	0	0	3.9	3.0	2.2	3.55	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.12,1.57,1.93,2.7,5.6,13.0,26.0,46.0}	{7.0,2.5,1.93,1.5,1.17,1.05,1.01,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.57,1.83,3.85,13.0,31.0,71.0}	{2.38,1.98,1.29,1.05,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.4,2.8,7.0,19.0}	{3.25,1.44,1.1,1.02}	https://www.oddsportal.com/football/greece/super-league/panetolikos-giannina-dteL5Jtr/#1X2;2	2023-05-07 19:30:55.736883+01
114	Ionikos	Volos	2023-01-16 19:30:00+00	0	1	2.65	3.3	3	3.4	2.0	1	0	0	0	3.5	3.0	2.3	3.1	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.08,1.44,2.02,2.25,4.33,10.0,21.0,34.0}	{9.0,3.1,1.83,1.68,1.22,1.07,1.02,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.5,1.73,3.4,10.0,26.0,56.0}	{2.63,2.08,1.36,1.07,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.33,2.38,6.0,17.0}	{3.4,1.53,1.14,1.02}	https://www.oddsportal.com/football/greece/super-league/ionikos-volos-lCgBcMlL/#1X2;2	2023-05-07 19:31:29.912983+01
115	Giannina	Panathinaikos	2023-01-15 20:30:00+00	0	1	5.0	3.0	2	5.5	1.91	1	0	0	0	2.8	4.75	2.14	2.6	{0.5,1.5,1.75,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.13,1.62,1.83,2.1,2.88,6.0,15.0,26.0,51.0}	{6.5,2.48,2.02,1.77,1.43,1.14,1.03,1.01,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.62,2.0,4.0,13.0,31.0,81.0}	{2.38,1.8,1.29,1.05,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.44,2.9,8.0,21.0}	{2.75,1.4,1.08,1.02}	https://www.oddsportal.com/football/greece/super-league/giannina-panathinaikos-2JZoiKRl/#1X2;2	2023-05-07 19:32:05.915215+01
116	Olympiacos Piraeus	Aris	2023-01-15 19:30:00+00	1	0	1.5	4.1	8	2.05	2.2	0	1	0	0	7.5	1.85	2.55	7.0	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.08,1.44,2.05,2.3,4.33,10.0,21.0,34.0}	{9.0,3.05,1.8,1.64,1.22,1.07,1.02,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.5,1.73,2.1,3.25,10.0,26.0,61.0}	{2.75,2.08,1.7,1.33,1.06,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.5,5.5,15.0}	{3.5,1.53,1.14,1.03}	https://www.oddsportal.com/football/greece/super-league/olympiacos-piraeus-aris-rZhFdt4R/#1X2;2	2023-05-07 19:32:40.336887+01
117	Asteras Tripolis	Levadiakos	2023-01-15 17:00:00+00	0	0	1.71	3.5	6	2.4	2.0	0	0	0	0	6.0	2.1	2.3	5.5	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.11,1.5,1.83,2.5,5.0,11.5,23.0,41.0}	{8.0,2.65,2.02,1.53,1.18,1.05,1.02,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.53,1.77,3.6,11.0,29.0,67.0}	{2.5,2.02,1.33,1.05,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.65,6.5,19.0}	{3.25,1.5,1.11,1.02}	https://www.oddsportal.com/football/greece/super-league/asteras-tripolis-levadiakos-ALf7b2ZE/#1X2;2	2023-05-07 19:33:15.420028+01
118	AEK Athens FC	Panetolikos	2023-01-15 16:00:00+00	4	1	1.17	7.5	17	1.53	3.15	0	2	1	2	12.0	1.4	3.75	12.5	{0.5,1.5,2.5,2.75,3.0,3.5,4.5,5.5,6.5}	{1.02,1.2,1.57,1.9,2.38,4.2,8.0,17.0}	{17.0,5.4,2.48,1.95,1.55,1.22,1.08,1.02}	{0.5,1.0,1.25,1.5,2.5,3.5,4.5}	{1.3,1.93,2.25,5.5,15.0,31.0}	{3.95,1.88,1.6,1.15,1.03,1.01}	{0.5,1.5,2.5,3.5,4.5}	{1.2,1.85,3.75,8.0,19.0}	{5.0,1.97,1.29,1.08,1.02}	https://www.oddsportal.com/football/greece/super-league/aek-panetolikos-hp02arK8/#1X2;2	2023-05-07 19:33:52.034852+01
120	Lamia	Atromitos	2023-01-14 17:00:00+00	1	1	2.3	3.05	4	3.1	1.95	0	1	1	0	4.0	2.8	2.23	3.7	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.11,1.5,1.9,2.5,5.0,11.0,26.0,41.0}	{7.5,2.65,1.95,1.5,1.17,1.05,1.02,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.53,1.83,3.75,11.0,29.0,71.0}	{2.5,1.98,1.33,1.05,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.4,2.63,6.5,19.0}	{3.25,1.46,1.11,1.02}	https://www.oddsportal.com/football/greece/super-league/lamia-atromitos-tAYkjvse/#1X2;2	2023-05-07 19:35:01.143366+01
121	Panetolikos	OFI Crete	2023-01-09 17:00:00+00	0	4	2.55	3.0	3	3.3	1.92	3	0	1	0	4.0	3.0	2.2	3.4	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.12,1.53,1.95,2.62,5.0,13.0,26.0,46.0}	{7.0,2.63,1.9,1.5,1.17,1.05,1.01,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.57,1.85,3.75,13.0,29.0,71.0}	{2.43,1.95,1.3,1.05,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.4,2.63,7.0,19.0}	{3.25,1.44,1.11,1.02}	https://www.oddsportal.com/football/greece/super-league/panetolikos-ofi-crete-0jDGyuS1/#1X2;2	2023-05-07 19:35:34.638861+01
122	AEK Athens FC	Panathinaikos	2023-01-08 19:30:00+00	1	0	2.0	3.0	5	2.88	1.86	0	1	0	0	5.5	2.45	2.12	5.0	{0.5,1.5,1.75,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.14,1.62,1.85,2.95,6.5,15.0,26.0,51.0}	{6.25,2.28,2.0,1.42,1.13,1.03,1.01,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.67,2.0,4.33,15.0,31.0,81.0}	{2.3,1.8,1.25,1.04,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.44,3.0,8.0,23.0}	{2.8,1.4,1.08,1.02}	https://www.oddsportal.com/football/greece/super-league/aek-panathinaikos-M1gWdkbA/#1X2;2	2023-05-07 19:36:09.49495+01
123	Aris	Asteras Tripolis	2023-01-08 19:00:00+00	3	0	1.51	4.0	7	2.1	2.17	0	1	0	2	7.0	1.91	2.5	6.25	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.08,1.4,2.0,2.3,4.33,9.0,21.0,34.0}	{9.0,3.1,1.85,1.66,1.22,1.07,1.02,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.46,1.7,3.25,10.0,26.0,56.0}	{2.75,2.1,1.36,1.07,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.5,5.5,15.0}	{3.5,1.53,1.14,1.03}	https://www.oddsportal.com/football/greece/super-league/aris-asteras-tripolis-0hhzd9DG/#1X2;2	2023-05-07 19:36:41.612212+01
124	Atromitos	Ionikos	2023-01-08 17:00:00+00	2	0	2.1	3.25	4	2.75	2.05	0	1	0	1	4.7	2.45	2.38	4.3	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.08,1.4,1.88,2.28,4.4,9.5,19.0,31.0}	{9.0,3.25,1.98,1.7,1.25,1.08,1.02,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.5,1.7,2.08,3.35,9.0,26.0,56.0}	{2.63,2.1,1.73,1.36,1.07,1.02,1.0}	{0.5,1.5,2.5,3.5}	{1.33,2.48,5.5,15.0}	{3.5,1.58,1.15,1.03}	https://www.oddsportal.com/football/greece/super-league/atromitos-ionikos-S0L3vsrq/#1X2;2	2023-05-07 19:37:14.194777+01
125	Volos	Olympiacos Piraeus	2023-01-08 16:00:00+00	0	4	10.0	5.0	1	8.5	2.5	1	0	3	0	1.8	8.0	2.95	1.62	{0.5,1.5,2.5,2.75,3.5,4.5,5.5,6.5}	{1.04,1.25,1.77,1.95,3.05,6.0,11.0,23.0}	{13.0,4.0,2.08,1.9,1.41,1.16,1.05,1.01}	{0.5,1.0,1.25,1.5,2.5,3.5,4.5}	{1.34,2.1,2.63,6.5,19.0,41.0}	{3.25,1.7,1.5,1.11,1.02,1.01}	{0.5,1.5,2.5,3.5,4.5}	{1.25,2.0,4.33,10.0,23.0}	{4.33,1.8,1.24,1.06,1.01}	https://www.oddsportal.com/football/greece/super-league/volos-olympiacos-piraeus-6iK7w1ck/#1X2;2	2023-05-07 19:37:48.287899+01
126	Lamia	PAOK	2023-01-07 19:30:00+00	0	3	7.5	3.4	2	7.0	2.0	1	0	2	0	2.3	7.0	2.25	2.02	{0.5,1.5,1.75,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.11,1.53,1.77,1.98,2.63,5.4,13.0,26.0,46.0}	{7.0,2.5,2.1,1.88,1.48,1.17,1.04,1.01,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.57,1.85,3.75,11.5,29.0,71.0}	{2.38,1.95,1.3,1.05,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.44,2.75,7.0,19.0}	{3.0,1.44,1.1,1.02}	https://www.oddsportal.com/football/greece/super-league/lamia-paok-Eg1b0O42/#1X2;2	2023-05-07 19:38:21.665587+01
127	Levadiakos	Giannina	2023-01-07 17:30:00+00	1	3	2.55	3.05	3	3.4	1.95	2	1	1	0	3.75	2.9	2.2	3.4	{0.5,1.5,2.0,2.5,3.5,4.5,5.5,6.5}	{1.12,1.57,2.0,2.62,5.5,13.0,26.0,46.0}	{7.5,2.63,1.85,1.5,1.16,1.05,1.01,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.57,1.88,3.75,13.0,29.0,71.0}	{2.45,1.93,1.29,1.05,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.4,2.75,6.5,19.0}	{3.25,1.44,1.11,1.02}	https://www.oddsportal.com/football/greece/super-league/levadiakos-giannina-lG9CxLCe/#1X2;2	2023-05-07 19:38:54.830661+01
128	PAOK	Aris	2023-01-04 20:00:00+00	1	0	2.1	3.1	4	2.85	1.92	0	0	0	1	5.0	2.55	2.2	4.33	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.12,1.57,2.02,2.7,5.5,13.0,23.0,46.0}	{7.0,2.63,1.83,1.5,1.16,1.04,1.01,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.57,1.9,3.75,13.0,31.0,71.0}	{2.43,1.9,1.29,1.05,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.44,2.75,7.0,21.0}	{3.0,1.41,1.1,1.02}	https://www.oddsportal.com/football/greece/super-league/paok-aris-QZaNbBTc/#1X2;2	2023-05-07 19:39:28.272398+01
129	Panetolikos	Atromitos	2023-01-04 18:00:00+00	2	0	2.2	3.25	3	2.9	2.05	0	2	0	0	4.1	2.62	2.38	3.65	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.07,1.36,1.85,2.16,4.0,8.5,17.0,31.0}	{10.0,3.25,2.0,1.73,1.25,1.08,1.02,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.44,2.05,3.25,9.0,26.0,56.0}	{2.63,1.75,1.36,1.07,1.02,1.0}	{0.5,1.5,2.5,3.5}	{1.3,2.33,5.5,15.0}	{3.5,1.57,1.15,1.03}	https://www.oddsportal.com/football/greece/super-league/panetolikos-atromitos-WC0JaiEi/#1X2;2	2023-05-07 19:40:00.848101+01
130	Asteras Tripolis	Lamia	2023-01-04 17:00:00+00	3	0	1.85	3.2	5	2.63	1.94	0	0	0	3	5.6	2.38	2.2	5.3	{0.5,1.5,1.75,2.0,2.5,3.5,4.5,5.5,6.5}	{1.12,1.57,2.05,2.7,5.6,13.0,23.0,46.0}	{6.75,2.43,1.8,1.45,1.15,1.04,1.01,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.58,1.9,3.85,13.0,29.0,71.0}	{2.33,1.9,1.25,1.04,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.4,2.75,7.0,21.0}	{3.0,1.4,1.1,1.02}	https://www.oddsportal.com/football/greece/super-league/asteras-tripolis-lamia-8K8Bc1XN/#1X2;2	2023-05-07 19:40:34.424468+01
131	Ionikos	Olympiacos Piraeus	2023-01-03 21:30:00+00	0	2	10.5	5.5	1	8.0	2.48	0	0	2	0	1.83	7.5	2.9	1.7	{0.5,1.5,2.25,2.5,2.75,3.0,3.5,4.5,5.5,6.5}	{1.05,1.26,1.8,3.15,6.25,11.0,23.0}	{13.0,4.0,2.05,1.4,1.14,1.05,1.01}	{0.5,1.0,1.25,1.5,2.5,3.5,4.5}	{1.36,1.75,2.65,7.0,19.0,41.0}	{3.25,2.05,1.5,1.12,1.02,1.01}	{0.5,1.5,2.5,3.5,4.5}	{1.29,2.05,4.33,11.0,26.0}	{4.33,1.73,1.22,1.05,1.01}	https://www.oddsportal.com/football/greece/super-league/ionikos-olympiacos-piraeus-2s8FdLnU/#1X2;2	2023-05-07 19:41:08.027449+01
132	Giannina	AEK Athens FC	2023-01-03 20:00:00+00	2	1	11.0	4.75	1	8.5	2.4	1	0	0	2	1.88	7.5	2.75	1.7	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.05,1.3,1.87,3.35,6.75,13.0,26.0}	{11.5,3.75,2.02,1.36,1.13,1.04,1.01}	{0.5,1.0,1.5,2.5,3.5,4.5}	{1.37,1.75,2.75,7.0,19.0,46.0}	{3.05,2.05,1.44,1.1,1.02,1.01}	{0.5,1.5,2.5,3.5,4.5}	{1.29,2.1,4.5,11.0,26.0}	{4.33,1.73,1.2,1.05,1.01}	https://www.oddsportal.com/football/greece/super-league/giannina-aek-vw4RcVr4/#1X2;2	2023-05-07 19:41:40.95524+01
133	Levadiakos	Panathinaikos	2023-01-03 17:00:00+00	0	1	14.0	4.75	1	11.0	2.2	0	0	1	0	1.91	9.5	2.6	1.68	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.08,1.41,1.95,2.25,4.35,9.5,19.0,36.0}	{10.0,3.0,1.9,1.67,1.25,1.07,1.02,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.5,2.08,3.4,10.0,26.0,61.0}	{2.63,1.73,1.36,1.07,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.5,6.0,17.0}	{3.4,1.5,1.13,1.02}	https://www.oddsportal.com/football/greece/super-league/levadiakos-panathinaikos-hM1F0Xbo/#1X2;2	2023-05-07 19:42:13.667631+01
134	OFI Crete	Volos	2023-01-03 16:30:00+00	0	0	2.1	3.5	4	2.75	2.1	0	0	0	0	4.25	2.45	2.4	4.0	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.07,1.36,2.06,3.85,8.0,15.0,26.0}	{11.0,3.4,1.83,1.29,1.1,1.03,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.41,1.98,3.05,8.5,23.0,51.0}	{2.8,1.83,1.4,1.08,1.02,1.0}	{0.5,1.5,2.5,3.5}	{1.3,2.25,4.75,13.0}	{3.75,1.67,1.18,1.04}	https://www.oddsportal.com/football/greece/super-league/ofi-crete-volos-4jfshueo/#1X2;2	2023-05-07 19:42:48.114036+01
135	Lamia	Giannina	2022-12-29 18:30:00+00	1	1	2.0	3.2	5	2.75	1.95	1	1	0	0	5.0	2.38	2.2	4.5	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.1,1.46,1.85,2.45,4.8,11.0,23.0,41.0}	{7.0,2.7,2.0,1.53,1.2,1.05,1.02,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.53,1.8,3.75,11.0,26.0,67.0}	{2.5,2.0,1.3,1.05,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.4,2.63,6.5,19.0}	{3.25,1.5,1.11,1.02}	https://www.oddsportal.com/football/greece/super-league/lamia-giannina-fH47bsIH/#1X2;2	2023-05-07 19:43:19.534187+01
136	Aris	Panetolikos	2022-12-29 18:00:00+00	1	0	1.29	5.75	12	1.67	2.75	0	1	0	0	8.5	1.53	3.25	8.5	{0.5,1.5,2.5,2.75,3.0,3.5,4.5,5.5,6.5}	{1.03,1.17,1.61,1.9,2.63,4.9,8.0,17.0}	{17.0,5.0,2.4,1.95,1.57,1.22,1.08,1.02}	{0.5,1.0,1.25,1.5,2.5,3.5,4.5}	{1.29,1.95,2.38,5.5,15.0,31.0}	{3.75,1.85,1.62,1.17,1.04,1.01}	{0.5,1.5,2.5,3.5,4.5}	{1.2,1.85,3.75,8.0,19.0}	{5.0,2.0,1.3,1.08,1.02}	https://www.oddsportal.com/football/greece/super-league/aris-panetolikos-WxKs4olt/#1X2;2	2023-05-07 19:43:53.101198+01
137	Panathinaikos	OFI Crete	2022-12-28 21:30:00+00	1	1	1.3	5.25	12	1.8	2.6	1	1	0	0	10.0	1.62	3.05	9.0	{0.5,1.5,2.5,2.75,3.5,4.5,5.5,6.5}	{1.06,1.33,2.0,2.25,3.4,6.5,15.0,26.0}	{13.0,4.1,2.04,1.68,1.37,1.13,1.03,1.01}	{0.5,1.0,1.25,1.5,2.5,3.5,4.5}	{1.4,1.85,3.0,8.0,23.0,46.0}	{3.3,1.95,1.44,1.1,1.02,1.01}	{0.5,1.5,2.5,3.5,4.5}	{1.3,2.3,5.0,13.0,26.0}	{4.2,1.73,1.18,1.04,1.01}	https://www.oddsportal.com/football/greece/super-league/panathinaikos-ofi-crete-ChF2aN2B/#1X2;2	2023-05-07 19:44:24.873956+01
138	Atromitos	PAOK	2022-12-28 20:00:00+00	1	1	6.5	4.5	2	5.6	2.4	0	1	1	0	2.05	5.8	2.8	1.8	{0.5,1.5,2.25,2.5,2.75,3.5,4.5,5.5,6.5}	{1.04,1.21,1.7,1.9,2.85,5.4,11.0,21.0}	{15.0,4.35,2.12,1.95,1.5,1.17,1.06,1.02}	{0.5,0.75,1.0,1.25,1.5,2.5,3.5,4.5}	{1.33,2.1,2.5,6.0,17.0,41.0}	{3.35,1.7,1.5,1.14,1.02,1.01}	{0.5,1.5,2.5,3.5,4.5}	{1.22,1.91,4.1,10.0,23.0}	{4.5,1.85,1.25,1.06,1.01}	https://www.oddsportal.com/football/greece/super-league/atromitos-paok-rDNo353n/#1X2;2	2023-05-07 19:44:59.017971+01
139	Volos	AEK Athens FC	2022-12-28 19:30:00+00	0	4	8.5	5.0	1	7.0	2.63	1	0	3	0	1.91	6.5	3.05	1.7	{0.5,1.5,2.5,2.75,3.0,3.5,4.5,5.5,6.5}	{1.03,1.2,1.62,2.0,2.6,4.8,9.0,19.0}	{16.0,4.8,2.3,1.85,1.5,1.2,1.07,1.02}	{0.5,1.0,1.25,1.5,2.5,3.5,4.5}	{1.3,2.0,2.38,5.5,15.0,36.0}	{3.65,1.8,1.57,1.15,1.03,1.01}	{0.5,1.5,2.5,3.5,4.5}	{1.22,1.91,3.75,9.0,21.0}	{5.0,1.91,1.29,1.07,1.02}	https://www.oddsportal.com/football/greece/super-league/volos-aek-QyDj2PIh/#1X2;2	2023-05-07 19:45:32.733952+01
140	Olympiacos Piraeus	Asteras Tripolis	2022-12-28 18:00:00+00	5	0	1.36	5.0	12	1.83	2.6	0	3	0	2	8.5	1.62	3.05	7.5	{0.5,1.5,2.25,2.5,2.75,3.0,3.5,4.5,5.5,6.5}	{1.03,1.21,1.67,1.88,2.75,5.2,10.0,21.0}	{15.0,4.5,2.16,1.98,1.44,1.2,1.06,1.02}	{0.5,0.75,1.0,1.25,1.5,2.5,3.5,4.5}	{1.3,2.08,2.5,6.0,17.0,36.0}	{3.45,1.73,1.57,1.14,1.03,1.01}	{0.5,1.5,2.5,3.5,4.5}	{1.22,1.91,4.0,10.0,23.0}	{4.5,1.83,1.25,1.06,1.01}	https://www.oddsportal.com/football/greece/super-league/olympiacos-piraeus-asteras-tripolis-Y1Gb03m5/#1X2;2	2023-05-07 19:46:07.030723+01
141	Levadiakos	Ionikos	2022-12-28 17:00:00+00	1	0	2.5	3.0	4	3.3	1.95	0	0	0	1	4.0	2.95	2.2	3.5	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.11,1.5,1.9,2.5,5.0,11.0,26.0,41.0}	{7.5,2.75,1.95,1.55,1.18,1.05,1.02,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.53,1.83,3.75,11.0,26.0,67.0}	{2.5,1.98,1.3,1.05,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.4,2.62,6.5,19.0}	{3.25,1.5,1.11,1.02}	https://www.oddsportal.com/football/greece/super-league/levadiakos-ionikos-4SBf1qYb/#1X2;2	2023-05-07 19:46:39.969281+01
142	Panetolikos	PAOK	2022-12-22 19:30:00+00	0	2	6.5	3.75	2	6.5	2.12	1	0	1	0	2.25	5.8	2.45	1.95	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.08,1.41,2.05,2.3,4.33,10.0,21.0,36.0}	{9.0,3.0,1.8,1.62,1.22,1.07,1.02,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.5,1.73,3.4,10.0,23.0,61.0}	{2.65,2.08,1.36,1.07,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.5,6.0,17.0}	{3.4,1.5,1.13,1.02}	https://www.oddsportal.com/football/greece/super-league/panetolikos-paok-GQqYqr3O/#1X2;2	2023-05-07 19:47:13.256708+01
143	OFI Crete	Atromitos	2022-12-22 17:00:00+00	0	1	2.15	3.25	4	2.88	2.05	0	0	1	0	4.25	2.6	2.3	3.9	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.1,1.44,2.0,2.38,4.6,10.0,21.0,34.0}	{9.0,2.75,1.85,1.62,1.22,1.07,1.02,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.5,1.7,3.45,10.5,23.0,61.0}	{2.62,2.1,1.33,1.06,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.5,5.5,15.0}	{3.5,1.53,1.14,1.03}	https://www.oddsportal.com/football/greece/super-league/ofi-crete-atromitos-bkkTpOmI/#1X2;2	2023-05-07 19:47:45.574113+01
144	Ionikos	Panathinaikos	2022-12-21 21:30:00+00	1	1	11.0	4.5	1	9.0	2.25	0	1	1	0	1.95	8.5	2.6	1.7	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.08,1.37,1.95,2.23,4.35,9.5,19.0,31.0}	{9.0,3.0,1.9,1.67,1.25,1.08,1.02,1.0}	{0.5,1.0,1.5,2.5,3.5,4.5}	{1.44,2.1,3.25,10.0,26.0,56.0}	{2.75,1.7,1.4,1.07,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.45,5.5,15.0}	{3.5,1.53,1.14,1.03}	https://www.oddsportal.com/football/greece/super-league/ionikos-panathinaikos-QyiLnpJ5/#1X2;2	2023-05-07 19:48:20.697427+01
145	Giannina	Olympiacos Piraeus	2022-12-21 20:00:00+00	2	2	9.5	4.5	1	8.0	2.28	0	2	2	0	1.95	7.5	2.7	1.75	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.06,1.33,2.02,3.8,8.0,15.0,26.0}	{11.0,3.5,1.9,1.3,1.11,1.03,1.0}	{0.5,1.0,1.5,2.5,3.5,4.5}	{1.4,1.85,3.0,8.0,23.0,51.0}	{2.88,1.95,1.4,1.1,1.02,1.0}	{0.5,1.5,2.5,3.5,4.5}	{1.33,2.28,5.0,13.0}	{3.75,1.62,1.17,1.04}	https://www.oddsportal.com/football/greece/super-league/giannina-olympiacos-piraeus-fHrxq2IU/#1X2;2	2023-05-07 19:48:53.671713+01
146	AEK Athens FC	Lamia	2022-12-21 17:00:00+00	3	0	1.22	7.5	17	1.62	3.1	0	3	0	0	12.0	1.44	3.25	10.0	{0.5,1.5,2.5,2.75,3.0,3.5,4.5,5.5,6.5}	{1.03,1.2,1.67,1.85,2.1,2.63,5.0,10.0,21.0}	{15.0,5.5,2.55,2.0,1.77,1.57,1.21,1.07,1.02}	{0.5,1.25,1.5,2.5,3.5,4.5}	{1.3,2.05,2.5,6.0,17.0,31.0}	{3.5,1.75,1.62,1.15,1.03,1.01}	{0.5,1.5,2.5,3.5,4.5}	{1.22,1.91,3.75,10.0,23.0}	{4.6,1.87,1.26,1.07,1.01}	https://www.oddsportal.com/football/greece/super-league/aek-lamia-U9cCl6lg/#1X2;2	2023-05-07 19:49:25.621112+01
147	Asteras Tripolis	Volos	2022-12-21 17:00:00+00	0	0	2.1	3.35	4	2.75	2.1	0	0	0	0	4.33	2.45	2.4	3.85	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.08,1.4,2.0,2.25,4.0,9.0,21.0,31.0}	{9.5,3.2,1.85,1.7,1.23,1.07,1.02,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.47,1.7,2.08,3.4,10.0,26.0,56.0}	{2.8,2.1,1.73,1.36,1.07,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.33,2.5,5.5,15.0}	{3.5,1.57,1.14,1.03}	https://www.oddsportal.com/football/greece/super-league/asteras-tripolis-volos-CYnHmQ3a/#1X2;2	2023-05-07 19:49:58.076226+01
148	Levadiakos	Aris	2022-12-21 15:00:00+00	1	1	5.0	3.65	2	6.0	2.16	1	0	0	1	2.38	5.0	2.43	2.1	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.1,1.44,2.02,2.3,4.33,10.0,21.0,36.0}	{9.5,3.05,1.83,1.64,1.22,1.06,1.02,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.5,1.7,3.4,10.0,26.0,61.0}	{2.75,2.1,1.33,1.06,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.5,6.0,17.0}	{3.4,1.53,1.13,1.02}	https://www.oddsportal.com/football/greece/super-league/levadiakos-aris-KbjPo4YB/#1X2;2	2023-05-07 19:50:29.613058+01
149	OFI Crete	Levadiakos	2022-11-14 19:30:00+00	2	1	1.7	3.8	6	2.38	2.1	0	2	1	0	5.5	2.0	2.4	5.5	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.07,1.36,1.9,2.1,3.75,8.0,19.0,29.0}	{10.0,3.0,1.95,1.7,1.25,1.08,1.02,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.44,2.07,3.25,9.0,26.0,56.0}	{2.62,1.72,1.36,1.08,1.02,1.0}	{0.5,1.5,2.5,3.5}	{1.33,2.38,5.5,15.0}	{3.75,1.57,1.15,1.03}	https://www.oddsportal.com/football/greece/super-league/ofi-crete-levadiakos-QyVkX4JI/#1X2;2	2023-05-07 19:51:01.407607+01
150	Asteras Tripolis	Ionikos	2022-11-14 18:00:00+00	1	0	1.65	3.8	6	2.3	2.1	0	0	0	1	6.0	2.0	2.4	5.5	{0.5,1.5,1.75,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.08,1.4,1.98,2.2,4.0,9.0,19.0,34.0}	{9.0,3.0,1.88,1.65,1.22,1.07,1.02,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.5,1.7,2.1,3.4,10.0,26.0,61.0}	{2.62,2.1,1.7,1.33,1.07,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.5,6.0,17.0}	{3.4,1.53,1.13,1.02}	https://www.oddsportal.com/football/greece/super-league/asteras-tripolis-ionikos-hOWsZQl6/#1X2;2	2023-05-07 19:51:35.826702+01
151	PAOK	Volos	2022-11-13 21:30:00+00	3	0	1.41	4.5	8	1.95	2.37	0	1	0	2	7.5	1.75	2.75	6.5	{0.5,1.5,2.5,3.5,4.5,5.5,6.5}	{1.05,1.29,1.85,3.0,6.0,13.0,26.0}	{13.0,3.75,2.02,1.36,1.13,1.04,1.01}	{0.5,1.0,1.5,2.5,3.5,4.5}	{1.36,1.77,2.75,7.0,21.0,46.0}	{3.0,2.02,1.44,1.11,1.02,1.01}	{0.5,1.5,2.5,3.5,4.5}	{1.25,2.1,4.33,11.0,26.0}	{4.0,1.73,1.21,1.05,1.01}	https://www.oddsportal.com/football/greece/super-league/paok-volos-tpDxe8BP/#1X2;2	2023-05-07 19:52:06.827605+01
152	Olympiacos Piraeus	AEK Athens FC	2022-11-13 19:30:00+00	0	0	2.25	3.3	3	3.0	2.05	0	0	0	0	3.75	2.7	2.37	3.4	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.07,1.36,1.95,2.15,4.0,9.0,19.0,26.0}	{9.0,3.1,1.9,1.75,1.28,1.1,1.03,1.0}	{0.5,1.0,1.5,2.5,3.5,4.5}	{1.44,2.1,3.25,10.0,26.0,56.0}	{2.65,1.7,1.4,1.07,1.02,1.0}	{0.5,1.5,2.5,3.5}	{1.3,2.25,5.5,15.0}	{3.6,1.62,1.17,1.04}	https://www.oddsportal.com/football/greece/super-league/olympiacos-piraeus-aek-WEVoYp4C/#1X2;2	2023-05-07 19:52:38.124263+01
153	Lamia	Panetolikos	2022-11-13 18:00:00+00	1	3	2.1	3.2	4	2.88	1.95	1	0	2	1	4.5	2.5	2.2	4.0	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.11,1.5,1.93,2.5,5.0,11.0,26.0,41.0}	{7.0,2.5,1.93,1.5,1.17,1.05,1.02,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.55,1.82,3.75,11.0,29.0,71.0}	{2.38,1.97,1.29,1.05,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.4,2.62,6.5,19.0}	{3.25,1.46,1.11,1.02}	https://www.oddsportal.com/football/greece/super-league/lamia-panetolikos-jJb8knZn/#1X2;2	2023-05-07 19:53:10.605204+01
154	Panathinaikos	Atromitos	2022-11-13 17:15:00+00	2	0	1.34	4.75	12	1.83	2.25	0	2	0	0	10.0	1.67	2.65	9.0	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.06,1.36,1.85,2.07,3.75,8.0,17.0,29.0}	{10.0,3.25,2.0,1.77,1.29,1.1,1.02,1.0}	{0.5,1.0,1.5,2.5,3.5,4.5}	{1.44,2.02,3.25,9.0,26.0,51.0}	{2.75,1.77,1.44,1.08,1.02,1.0}	{0.5,1.5,2.5,3.5}	{1.33,2.3,5.5,15.0}	{3.5,1.57,1.14,1.03}	https://www.oddsportal.com/football/greece/super-league/panathinaikos-atromitos-vuZgWOYO/#1X2;2	2023-05-07 19:53:42.545407+01
155	Giannina	Aris	2022-11-13 16:00:00+00	0	4	4.5	3.4	2	5.0	2.05	4	0	0	0	2.6	4.5	2.35	2.3	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.08,1.4,2.0,2.25,4.0,9.0,21.0,36.0}	{9.0,2.75,1.85,1.62,1.22,1.07,1.02,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.5,1.7,3.4,10.0,26.0,67.0}	{2.62,2.1,1.33,1.06,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.5,6.0,17.0}	{3.4,1.53,1.13,1.02}	https://www.oddsportal.com/football/greece/super-league/giannina-aris-rga4jSJt/#1X2;2	2023-05-07 19:54:12.816925+01
156	Ionikos	PAOK	2022-11-10 21:30:00+00	0	3	4.9	3.6	2	5.5	2.1	1	0	2	0	2.4	5.0	2.4	2.15	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.08,1.4,1.95,2.23,4.3,9.0,19.0,34.0}	{9.0,3.0,1.9,1.7,1.22,1.07,1.02,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.47,1.7,2.1,3.25,10.0,26.0,61.0}	{2.65,2.1,1.7,1.36,1.07,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.33,2.43,5.5,15.0}	{3.5,1.57,1.14,1.03}	https://www.oddsportal.com/football/greece/super-league/ionikos-paok-2ZwVyT4m/#1X2;2	2023-05-07 19:54:44.76198+01
157	Volos	Giannina	2022-11-10 19:00:00+00	2	1	1.83	3.55	5	2.5	2.2	1	2	0	0	5.0	2.25	2.5	4.7	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.07,1.33,1.8,2.05,3.85,8.0,15.0,26.0}	{10.0,3.4,2.05,1.83,1.29,1.1,1.03,1.0}	{0.5,1.0,1.5,2.5,3.5,4.5}	{1.44,1.97,3.05,8.0,23.0,56.0}	{2.85,1.82,1.4,1.08,1.02,1.0}	{0.5,1.5,2.5,3.5}	{1.3,2.3,4.75,13.0}	{3.75,1.66,1.18,1.04}	https://www.oddsportal.com/football/greece/super-league/volos-giannina-4lLRx9ks/#1X2;2	2023-05-07 19:55:16.308592+01
158	AEK Athens FC	OFI Crete	2022-11-09 20:00:00+00	3	0	1.22	6.8	15	1.61	2.88	0	1	0	2	10.0	1.45	3.45	9.5	{0.5,1.5,2.5,2.75,3.0,3.25,3.5,4.5,5.5,6.5,7.5}	{1.02,1.15,1.5,2.05,2.25,3.85,7.5,15.0}	{17.0,5.75,2.63,1.8,1.62,1.25,1.1,1.03}	{0.5,1.25,1.5,2.5,3.5,4.5}	{1.25,1.85,2.2,5.0,13.0,29.0}	{4.0,1.95,1.67,1.17,1.04,1.01}	{0.5,1.5,2.5,3.5,4.5}	{1.2,1.8,3.4,7.0,19.0}	{5.5,2.05,1.33,1.1,1.02}	https://www.oddsportal.com/football/greece/super-league/aek-ofi-crete-W0jDJokJ/#1X2;2	2023-05-07 19:55:48.823423+01
159	Levadiakos	Olympiacos Piraeus	2022-11-09 20:00:00+00	0	1	9.4	4.75	1	8.0	2.38	0	0	1	0	1.9	8.0	2.8	1.67	{0.5,1.5,2.5,2.75,3.5,4.5,5.5,6.5}	{1.05,1.26,1.88,3.25,6.1,13.0,26.0}	{12.5,3.95,1.98,1.36,1.13,1.04,1.01}	{0.5,1.0,1.25,1.5,2.5,3.5,4.5}	{1.36,1.8,2.65,7.0,21.0,41.0}	{3.15,2.0,1.44,1.11,1.02,1.01}	{0.5,1.5,2.5,3.5,4.5}	{1.29,2.1,4.33,11.0,26.0}	{4.0,1.72,1.2,1.05,1.01}	https://www.oddsportal.com/football/greece/super-league/levadiakos-olympiacos-piraeus-ddwZzmKg/#1X2;2	2023-05-07 19:56:22.60847+01
160	Atromitos	Asteras Tripolis	2022-11-09 18:00:00+00	2	0	2.43	3.25	3	3.15	2.05	0	0	0	2	4.0	2.85	2.3	3.4	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.08,1.41,2.05,2.3,4.33,10.0,21.0,36.0}	{8.5,3.0,1.8,1.63,1.22,1.06,1.02,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.5,1.72,3.4,10.0,26.0,61.0}	{2.65,2.07,1.33,1.06,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.33,2.38,5.5,15.0}	{3.5,1.57,1.14,1.03}	https://www.oddsportal.com/football/greece/super-league/atromitos-asteras-tripolis-b7rasksQ/#1X2;2	2023-05-07 19:57:04.350649+01
161	Panetolikos	Panathinaikos	2022-11-09 17:00:00+00	0	1	5.75	3.5	2	6.0	2.02	1	0	0	0	2.5	5.75	2.25	2.2	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.12,1.55,2.1,2.7,5.75,13.0,26.0,51.0}	{7.5,2.48,1.77,1.44,1.14,1.04,1.01,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.58,1.92,4.0,13.0,34.0,81.0}	{2.4,1.87,1.29,1.04,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.4,2.85,8.0,21.0}	{3.0,1.4,1.1,1.02}	https://www.oddsportal.com/football/greece/super-league/panetolikos-panathinaikos-zmxwz7Za/#1X2;2	2023-05-07 19:57:36.310636+01
162	Aris	Lamia	2022-11-08 20:00:00+00	5	0	1.52	4.33	9	2.1	2.2	0	2	0	3	8.5	1.9	2.5	7.5	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.1,1.44,1.98,2.3,4.4,9.5,19.0,34.0}	{9.0,3.0,1.88,1.65,1.22,1.07,1.02,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.49,1.7,2.1,3.3,10.0,26.0,61.0}	{2.65,2.1,1.7,1.36,1.07,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.5,5.5,15.0}	{3.5,1.53,1.14,1.03}	https://www.oddsportal.com/football/greece/super-league/aris-lamia-KGqerVRJ/#1X2;2	2023-05-07 19:58:08.722564+01
163	Asteras Tripolis	AEK Athens FC	2022-11-06 20:30:00+00	1	1	6.5	3.8	2	6.0	2.2	1	1	0	0	2.2	5.8	2.55	1.91	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.07,1.33,2.02,3.6,7.5,15.0,26.0}	{10.5,3.45,1.83,1.3,1.1,1.03,1.0}	{0.5,1.0,1.5,2.5,3.5,4.5}	{1.41,1.95,3.0,8.0,23.0,51.0}	{2.9,1.85,1.4,1.08,1.02,1.0}	{0.5,1.5,2.5,3.5}	{1.3,2.25,4.75,13.0}	{3.75,1.66,1.18,1.04}	https://www.oddsportal.com/football/greece/super-league/asteras-tripolis-aek-6gLRtIjF/#1X2;2	2023-05-07 19:58:40.504745+01
164	Panathinaikos	Olympiacos Piraeus	2022-11-06 19:30:00+00	1	1	2.2	3.1	4	3.0	1.95	1	1	0	0	4.33	2.7	2.2	3.85	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.11,1.5,1.95,2.6,5.3,13.0,26.0,46.0}	{7.0,2.55,1.9,1.5,1.17,1.05,1.01,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.57,1.85,3.75,11.0,26.0,67.0}	{2.5,1.95,1.3,1.06,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.38,2.75,7.0,19.0}	{3.25,1.44,1.11,1.02}	https://www.oddsportal.com/football/greece/super-league/panathinaikos-olympiacos-piraeus-2LbdNTkf/#1X2;2	2023-05-07 19:59:12.142066+01
165	Panetolikos	Levadiakos	2022-11-06 16:00:00+00	0	0	1.88	3.3	5	2.5	2.05	0	0	0	0	5.0	2.3	2.33	4.4	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.08,1.4,2.0,2.25,4.3,9.0,19.0,34.0}	{8.5,3.0,1.85,1.62,1.25,1.07,1.02,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.5,1.7,3.4,10.0,26.0,61.0}	{2.63,2.1,1.36,1.07,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.43,5.5,15.0}	{3.5,1.57,1.14,1.03}	https://www.oddsportal.com/football/greece/super-league/panetolikos-levadiakos-drb0Mm50/#1X2;2	2023-05-07 19:59:43.760276+01
166	PAOK	Giannina	2022-11-05 21:00:00+00	2	0	1.36	5.0	9	1.9	2.37	0	0	0	2	8.0	1.67	2.75	7.0	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.05,1.3,1.96,3.45,7.0,15.0,26.0}	{13.0,3.55,1.9,1.33,1.12,1.04,1.01}	{0.5,1.0,1.5,2.5,3.5,4.5}	{1.37,1.85,2.85,8.0,21.0,46.0}	{3.0,1.95,1.44,1.1,1.02,1.01}	{0.5,1.5,2.5,3.5,4.5}	{1.29,2.16,4.5,13.0}	{4.0,1.67,1.18,1.04}	https://www.oddsportal.com/football/greece/super-league/paok-giannina-Ao24L7K6/#1X2;2	2023-05-07 20:00:15.772402+01
167	Atromitos	Aris	2022-11-05 19:00:00+00	0	0	3.65	3.3	2	4.35	2.05	0	0	0	0	2.87	4.0	2.3	2.6	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.1,1.42,2.0,2.38,4.5,10.0,21.0,36.0}	{9.0,2.85,1.85,1.61,1.22,1.07,1.02,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.5,1.7,3.4,10.0,26.0,61.0}	{2.55,2.1,1.3,1.06,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.5,5.5,15.0}	{3.5,1.53,1.14,1.03}	https://www.oddsportal.com/football/greece/super-league/atromitos-aris-rJrePkLs/#1X2;2	2023-05-07 20:00:47.539966+01
168	OFI Crete	Ionikos	2022-11-05 18:30:00+00	0	2	2.0	3.4	4	2.7	2.05	2	0	0	0	4.75	2.4	2.33	4.33	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.1,1.42,2.0,2.3,4.25,9.0,21.0,36.0}	{9.0,2.95,1.85,1.61,1.22,1.07,1.02,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.5,1.7,3.4,10.0,26.0,61.0}	{2.63,2.1,1.33,1.06,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.5,6.0,17.0}	{3.4,1.53,1.12,1.02}	https://www.oddsportal.com/football/greece/super-league/ofi-crete-ionikos-OUahO9zl/#1X2;2	2023-05-07 20:01:19.722931+01
169	Lamia	Volos	2022-11-05 15:45:00+00	2	2	2.75	3.3	3	3.6	1.95	1	0	1	2	3.5	3.2	2.25	3.2	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.11,1.5,1.9,2.5,5.0,11.0,26.0,41.0}	{8.0,2.7,1.95,1.52,1.2,1.06,1.02,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.53,1.82,3.75,11.0,29.0,71.0}	{2.45,1.97,1.3,1.05,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.62,6.5,19.0}	{3.25,1.47,1.12,1.02}	https://www.oddsportal.com/football/greece/super-league/lamia-volos-hAi9KRZC/#1X2;2	2023-05-07 20:01:51.395295+01
170	Giannina	Asteras Tripolis	2022-10-31 18:00:00+00	2	1	2.75	2.9	3	3.6	1.9	1	2	0	0	3.75	3.1	2.1	3.3	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.12,1.57,2.1,2.7,5.5,13.0,26.0,46.0}	{6.5,2.37,1.77,1.48,1.15,1.04,1.01,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.6,1.95,3.75,13.0,31.0,81.0}	{2.38,1.85,1.25,1.04,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.4,2.75,7.0,21.0}	{3.0,1.44,1.1,1.02}	https://www.oddsportal.com/football/greece/super-league/giannina-asteras-tripolis-CWLNsby9/#1X2;2	2023-05-07 20:02:22.834717+01
171	Aris	OFI Crete	2022-10-30 20:30:00+00	1	1	1.4	4.75	9	1.95	2.25	1	1	0	0	8.0	1.75	2.65	7.0	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.07,1.36,1.83,2.05,3.5,7.0,17.0,29.0}	{11.0,3.25,2.02,1.8,1.29,1.1,1.02,1.0}	{0.5,1.0,1.5,2.5,3.5,4.5}	{1.41,1.97,3.0,8.0,23.0,56.0}	{2.75,1.82,1.4,1.08,1.02,1.0}	{0.5,1.5,2.5,3.5}	{1.33,2.3,5.0,13.0}	{3.75,1.61,1.16,1.04}	https://www.oddsportal.com/football/greece/super-league/aris-ofi-crete-A7yPMdaq/#1X2;2	2023-05-07 20:02:54.134061+01
172	AEK Athens FC	PAOK	2022-10-30 19:30:00+00	2	0	1.67	3.5	6	2.37	2.05	0	1	0	1	6.0	2.05	2.37	5.5	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.08,1.4,2.02,2.25,4.33,10.0,21.0,34.0}	{8.0,2.75,1.83,1.61,1.22,1.07,1.02,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.5,1.7,3.4,10.0,23.0,61.0}	{2.62,2.1,1.36,1.07,1.02,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.5,6.0,17.0}	{3.4,1.53,1.13,1.02}	https://www.oddsportal.com/football/greece/super-league/aek-paok-4QbdRxiS/#1X2;2	2023-05-07 20:03:25.835412+01
173	Levadiakos	Atromitos	2022-10-30 16:30:00+00	2	1	2.9	3.2	3	3.75	1.95	1	1	0	1	3.4	3.3	2.2	2.9	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.11,1.5,1.9,2.5,5.0,11.0,26.0,41.0}	{7.0,2.5,1.95,1.53,1.2,1.05,1.02,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.53,1.82,3.75,11.0,26.0,67.0}	{2.5,1.97,1.3,1.05,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.62,6.5,19.0}	{3.25,1.5,1.11,1.02}	https://www.oddsportal.com/football/greece/super-league/levadiakos-atromitos-dOwyKfq2/#1X2;2	2023-05-07 20:03:57.554212+01
174	Olympiacos Piraeus	Lamia	2022-10-30 16:00:00+00	2	0	1.22	6.0	15	1.66	2.6	0	0	0	2	11.0	1.5	3.1	10.0	{0.5,1.5,2.5,2.75,3.5,4.5,5.5,6.5}	{1.03,1.23,1.72,1.88,2.7,5.0,11.0,21.0}	{15.0,4.33,2.15,1.98,1.44,1.17,1.06,1.01}	{0.5,1.0,1.25,1.5,2.5,3.5,4.5}	{1.36,1.7,2.07,2.5,6.5,19.0,41.0}	{3.25,2.1,1.72,1.53,1.12,1.02,1.01}	{0.5,1.5,2.5,3.5,4.5}	{1.25,2.0,4.0,10.0,26.0}	{4.33,1.8,1.23,1.06,1.01}	https://www.oddsportal.com/football/greece/super-league/olympiacos-piraeus-lamia-bTHJrvM2/#1X2;2	2023-05-07 20:04:29.212707+01
175	Volos	Panathinaikos	2022-10-29 19:30:00+01	1	5	4.75	3.3	2	5.0	2.0	3	1	2	0	2.6	4.5	2.3	2.3	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.1,1.44,1.77,2.35,4.33,10.0,21.0,36.0}	{8.0,2.62,2.1,1.57,1.2,1.06,1.02,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.51,1.75,3.5,11.0,26.0,67.0}	{2.5,2.05,1.33,1.06,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.5,6.0,17.0}	{3.4,1.5,1.12,1.02}	https://www.oddsportal.com/football/greece/super-league/volos-panathinaikos-lbzTLGEk/#1X2;2	2023-05-07 20:05:00.576328+01
176	Ionikos	Panetolikos	2022-10-29 17:00:00+01	1	1	2.05	3.3	4	2.75	2.05	0	0	1	1	4.33	2.45	2.3	4.0	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.08,1.4,2.0,2.25,4.0,9.0,21.0,34.0}	{9.0,2.75,1.85,1.63,1.22,1.07,1.02,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.5,1.7,3.4,10.0,26.0,61.0}	{2.62,2.1,1.36,1.06,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.38,5.5,15.0}	{3.5,1.53,1.14,1.03}	https://www.oddsportal.com/football/greece/super-league/ionikos-panetolikos-IXvXKzUe/#1X2;2	2023-05-07 20:05:38.567299+01
177	OFI Crete	Lamia	2022-10-24 20:00:00+01	0	0	2.37	3.3	3	3.1	2.0	0	0	0	0	3.8	2.7	2.3	3.5	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.09,1.4,2.05,2.32,4.33,10.0,21.0,34.0}	{8.0,2.75,1.8,1.6,1.22,1.07,1.02,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.5,1.72,3.4,10.0,26.0,61.0}	{2.5,2.07,1.33,1.06,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.38,5.5,15.0}	{3.5,1.53,1.14,1.03}	https://www.oddsportal.com/football/greece/super-league/ofi-crete-lamia-212uVKi3/#1X2;2	2023-05-07 20:06:10.730543+01
178	Levadiakos	AEK Athens FC	2022-10-24 18:00:00+01	0	2	11.0	5.5	1	9.0	2.5	2	0	0	0	1.75	8.0	2.95	1.62	{0.5,1.5,2.25,2.5,2.75,3.5,4.5,5.5,6.5,7.5}	{1.04,1.25,1.8,1.95,2.8,5.5,11.0,23.0}	{13.0,4.0,2.07,1.9,1.4,1.15,1.05,1.01}	{0.5,1.0,1.25,1.5,2.5,3.5,4.5}	{1.36,1.7,2.1,2.55,6.5,19.0,41.0}	{3.25,2.1,1.7,1.5,1.11,1.02,1.01}	{0.5,1.5,2.5,3.5,4.5}	{1.25,2.05,4.33,10.0,26.0}	{4.33,1.8,1.22,1.06,1.01}	https://www.oddsportal.com/football/greece/super-league/levadiakos-aek-OA3yW0xc/#1X2;2	2023-05-07 20:06:43.189552+01
179	Panathinaikos	Aris	2022-10-23 19:30:00+01	1	0	1.75	3.35	6	2.5	1.9	0	1	0	0	6.0	2.15	2.2	6.0	{0.5,1.5,1.75,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.12,1.57,2.1,2.7,5.5,13.0,23.0,51.0}	{6.5,2.37,1.77,1.48,1.14,1.04,1.01,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.61,1.92,4.0,13.0,31.0,81.0}	{2.3,1.87,1.25,1.04,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.44,2.75,8.0,21.0}	{2.8,1.4,1.09,1.02}	https://www.oddsportal.com/football/greece/super-league/panathinaikos-aris-KxcpUv79/#1X2;2	2023-05-07 20:07:14.205321+01
180	PAOK	Asteras Tripolis	2022-10-23 19:30:00+01	2	2	1.37	4.4	11	1.93	2.2	1	2	1	0	9.5	1.73	2.6	8.5	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.08,1.4,1.88,2.2,4.0,8.0,19.0,34.0}	{10.0,3.25,1.98,1.7,1.25,1.08,1.02,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.47,2.05,3.25,10.0,26.0,67.0}	{2.62,1.75,1.36,1.06,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.5,5.5,15.0}	{3.5,1.55,1.14,1.03}	https://www.oddsportal.com/football/greece/super-league/paok-asteras-tripolis-hjehSIyM/#1X2;2	2023-05-07 20:07:45.552762+01
181	Ionikos	Giannina	2022-10-23 16:00:00+01	2	2	1.92	3.5	5	2.5	2.1	2	0	0	2	5.0	2.25	2.37	4.5	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.08,1.4,1.95,2.25,4.0,9.0,19.0,34.0}	{9.0,3.0,1.9,1.66,1.22,1.07,1.02,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.47,1.67,2.1,3.25,10.0,26.0,61.0}	{2.62,2.15,1.7,1.33,1.07,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.38,5.5,15.0}	{3.5,1.57,1.14,1.03}	https://www.oddsportal.com/football/greece/super-league/ionikos-giannina-A7Fg7Had/#1X2;2	2023-05-07 20:08:16.9917+01
182	Panetolikos	Olympiacos Piraeus	2022-10-22 19:30:00+01	0	2	7.0	4.2	2	6.5	2.2	2	0	0	0	2.1	6.0	2.6	1.85	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.07,1.33,1.8,2.05,3.5,8.0,17.0,29.0}	{9.5,3.25,2.05,1.77,1.3,1.1,1.02,1.0}	{0.5,1.0,1.5,2.5,3.5,4.5}	{1.42,2.0,3.0,8.0,23.0,56.0}	{2.75,1.8,1.4,1.08,1.02,1.0}	{0.5,1.5,2.5,3.5}	{1.3,2.25,5.0,13.0}	{3.75,1.63,1.17,1.04}	https://www.oddsportal.com/football/greece/super-league/panetolikos-olympiacos-piraeus-bTelTbMF/#1X2;2	2023-05-07 20:08:48.143969+01
183	Atromitos	Volos	2022-10-22 19:00:00+01	0	2	2.45	3.3	3	3.0	2.1	1	0	1	0	3.75	2.8	2.37	3.2	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.07,1.36,1.9,2.1,3.75,8.0,19.0,29.0}	{9.0,3.0,1.95,1.72,1.26,1.08,1.02,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.44,2.07,3.25,9.0,26.0,56.0}	{2.75,1.72,1.36,1.07,1.02,1.0}	{0.5,1.5,2.5,3.5}	{1.33,2.3,5.0,13.0}	{3.75,1.61,1.16,1.04}	https://www.oddsportal.com/football/greece/super-league/atromitos-volos-d4Bk8cpj/#1X2;2	2023-05-07 20:09:21.248696+01
184	Olympiacos Piraeus	PAOK	2022-10-17 20:00:00+01	1	2	1.8	3.5	5	2.5	2.05	1	0	1	1	5.5	2.3	2.35	5.0	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.1,1.44,2.0,2.25,4.35,9.5,19.0,36.0}	{8.5,3.0,1.85,1.61,1.22,1.07,1.02,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.5,1.7,3.4,10.0,26.0,67.0}	{2.62,2.1,1.33,1.06,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.5,6.0,15.0}	{3.4,1.53,1.13,1.03}	https://www.oddsportal.com/football/greece/super-league/olympiacos-piraeus-paok-IeLFEa7M/#1X2;2	2023-05-07 20:09:55.461227+01
185	Asteras Tripolis	Panetolikos	2022-10-16 20:30:00+01	0	0	1.95	3.4	4	2.63	2.0	0	0	0	0	5.0	2.45	2.28	4.35	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.1,1.44,1.83,2.4,4.6,11.0,23.0,51.0}	{8.0,2.8,2.02,1.57,1.22,1.06,1.02,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.53,1.77,3.5,11.0,26.0,67.0}	{2.62,2.02,1.33,1.06,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.5,6.5,19.0}	{3.25,1.5,1.12,1.02}	https://www.oddsportal.com/football/greece/super-league/asteras-tripolis-panetolikos-dtX6GLxA/#1X2;2	2023-05-07 20:10:26.38585+01
186	Lamia	Panathinaikos	2022-10-16 19:30:00+01	0	2	5.4	3.15	2	5.8	1.94	1	0	1	0	2.75	5.4	2.23	2.38	{0.5,1.5,1.75,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.13,1.57,1.8,2.87,6.0,15.0,29.0,51.0}	{6.75,2.5,2.05,1.45,1.14,1.04,1.01,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.61,1.97,4.0,13.0,31.0,81.0}	{2.35,1.82,1.25,1.04,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.44,3.0,8.0,23.0}	{2.75,1.4,1.1,1.02}	https://www.oddsportal.com/football/greece/super-league/lamia-panathinaikos-EuMp9wVq/#1X2;2	2023-05-07 20:10:58.476029+01
187	Giannina	OFI Crete	2022-10-16 18:00:00+01	2	2	2.2	3.25	4	2.88	2.05	2	1	0	1	4.33	2.62	2.3	3.75	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.08,1.44,2.05,2.3,4.33,10.0,21.0,51.0}	{8.5,3.0,1.8,1.62,1.22,1.07,1.02,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.5,1.72,3.4,10.0,26.0,61.0}	{2.62,2.07,1.33,1.06,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.5,5.5,15.0}	{3.5,1.53,1.14,1.03}	https://www.oddsportal.com/football/greece/super-league/giannina-ofi-crete-CWZIDJMS/#1X2;2	2023-05-07 20:11:32.040382+01
188	AEK Athens FC	Atromitos	2022-10-16 16:00:00+01	1	0	1.3	6.0	11	1.8	2.63	0	1	0	0	9.0	1.57	3.05	8.0	{0.5,1.5,2.25,2.5,2.75,3.5,4.5,5.5,6.5,7.5}	{1.04,1.25,1.75,2.0,3.0,5.75,13.0,23.0}	{15.0,4.1,2.05,1.85,1.39,1.15,1.05,1.01}	{0.5,1.0,1.25,1.5,2.5,3.5,4.5}	{1.36,1.72,2.62,6.5,19.0,41.0}	{3.35,2.07,1.5,1.11,1.02,1.01}	{0.5,1.5,2.5,3.5,4.5}	{1.25,2.05,4.33,11.0,26.0}	{4.33,1.77,1.22,1.06,1.01}	https://www.oddsportal.com/football/greece/super-league/aek-atromitos-lGTbIs8c/#1X2;2	2023-05-07 20:12:05.561902+01
189	Aris	Ionikos	2022-10-15 20:30:00+01	2	1	1.4	5.0	9	1.93	2.37	0	2	1	0	8.0	1.73	2.75	7.0	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5,7.5}	{1.05,1.3,1.94,3.55,7.0,15.0,29.0}	{13.0,3.5,1.93,1.33,1.12,1.04,1.0}	{0.5,1.0,1.5,2.5,3.5,4.5}	{1.4,1.85,2.88,7.0,21.0,51.0}	{3.0,1.95,1.4,1.1,1.02,1.0}	{0.5,1.5,2.5,3.5}	{1.3,2.25,4.5,13.0}	{4.0,1.68,1.19,1.04}	https://www.oddsportal.com/football/greece/super-league/aris-ionikos-rwT2H1N3/#1X2;2	2023-05-07 20:12:36.887346+01
190	Volos	Levadiakos	2022-10-15 17:00:00+01	2	1	1.7	3.6	6	2.35	2.2	1	2	0	0	6.0	2.1	2.5	5.0	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.07,1.36,1.85,2.08,3.85,8.0,17.0,34.0}	{9.0,3.25,2.0,1.73,1.26,1.1,1.02,1.0}	{0.5,1.0,1.5,2.5,3.5,4.5}	{1.44,2.05,3.25,9.0,26.0,56.0}	{2.75,1.75,1.36,1.08,1.02,1.0}	{0.5,1.5,2.5,3.5}	{1.33,2.3,5.0,15.0}	{3.75,1.61,1.16,1.03}	https://www.oddsportal.com/football/greece/super-league/volos-levadiakos-v5MBFuhG/#1X2;2	2023-05-07 20:13:08.183602+01
191	Atromitos	Giannina	2022-10-10 18:00:00+01	2	1	1.98	3.2	5	2.7	2.0	1	2	0	0	5.0	2.43	2.25	4.5	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.1,1.46,1.83,2.55,5.1,11.5,23.0,51.0}	{7.5,2.63,2.02,1.53,1.2,1.06,1.02,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.53,1.77,3.65,11.0,29.0,71.0}	{2.43,2.02,1.3,1.05,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.7,6.5,17.0}	{3.25,1.5,1.11,1.02}	https://www.oddsportal.com/football/greece/super-league/atromitos-giannina-rw7X1MNG/#1X2;2	2023-05-07 20:13:40.688008+01
192	Aris	AEK Athens FC	2022-10-09 21:15:00+01	0	2	2.8	3.2	3	3.55	2.05	1	0	1	0	3.4	3.2	2.37	3.05	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.08,1.4,1.9,2.35,4.6,10.0,19.0,41.0}	{8.5,3.25,1.95,1.7,1.25,1.08,1.02,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.47,1.7,2.1,3.45,10.0,26.0,61.0}	{2.62,2.1,1.7,1.33,1.06,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.33,2.5,5.5,15.0}	{3.75,1.61,1.14,1.03}	https://www.oddsportal.com/football/greece/super-league/aris-aek-4n8T228A/#1X2;2	2023-05-07 20:14:13.538605+01
193	Panathinaikos	Asteras Tripolis	2022-10-09 19:30:00+01	1	0	1.45	4.25	9	2.05	2.23	0	1	0	0	8.0	1.75	2.6	7.5	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.08,1.4,2.0,2.25,4.0,9.0,21.0,41.0}	{9.5,3.15,1.85,1.7,1.23,1.07,1.02,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.46,1.7,2.1,3.4,10.0,26.0,61.0}	{2.75,2.1,1.7,1.36,1.07,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.33,2.38,6.0,17.0}	{3.4,1.53,1.14,1.03}	https://www.oddsportal.com/football/greece/super-league/panathinaikos-asteras-tripolis-Y7oCfvGj/#1X2;2	2023-05-07 20:14:46.518727+01
194	Levadiakos	PAOK	2022-10-09 16:30:00+01	1	1	5.32	3.75	2	5.6	2.1	1	1	0	0	2.4	5.5	2.37	2.12	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.08,1.4,1.95,2.33,4.5,10.0,19.0,41.0}	{9.0,3.0,1.9,1.68,1.25,1.08,1.02,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.46,2.1,3.4,10.0,26.0,61.0}	{2.62,1.7,1.36,1.07,1.02,1.0}	{0.5,1.5,2.5,3.5}	{1.33,2.5,5.5,15.0}	{3.5,1.53,1.14,1.03}	https://www.oddsportal.com/football/greece/super-league/levadiakos-paok-xx0t00hT/#1X2;2	2023-05-07 20:15:20.284016+01
195	OFI Crete	Olympiacos Piraeus	2022-10-09 16:00:00+01	1	2	7.0	4.0	2	6.5	2.17	2	0	0	1	2.2	5.75	2.5	1.95	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.07,1.36,1.85,2.1,3.9,8.0,17.0,41.0}	{10.0,3.25,2.0,1.73,1.25,1.08,1.02,1.0}	{0.5,1.0,1.5,2.5,3.5,4.5}	{1.44,2.02,3.25,9.0,26.0,56.0}	{2.75,1.77,1.36,1.08,1.02,1.0}	{0.5,1.5,2.5,3.5}	{1.33,2.3,5.5,15.0}	{3.5,1.57,1.14,1.03}	https://www.oddsportal.com/football/greece/super-league/ofi-crete-olympiacos-piraeus-fHn8eK0p/#1X2;2	2023-05-07 20:15:51.361971+01
196	Ionikos	Lamia	2022-10-08 19:30:00+01	1	1	2.37	3.15	3	3.2	2.0	0	1	1	0	4.0	2.75	2.25	3.6	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.1,1.5,1.9,2.5,5.0,11.0,26.0,51.0}	{8.0,2.7,1.95,1.53,1.18,1.05,1.02,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.57,1.82,3.75,11.0,29.0,71.0}	{2.5,1.97,1.29,1.05,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.62,6.5,19.0}	{3.25,1.5,1.11,1.02}	https://www.oddsportal.com/football/greece/super-league/ionikos-lamia-Q1dx1twN/#1X2;2	2023-05-07 20:16:22.545185+01
197	Panetolikos	Volos	2022-10-08 17:00:00+01	2	3	2.3	3.4	4	3.0	2.05	1	0	2	2	4.2	2.75	2.37	3.85	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.08,1.38,1.9,2.32,4.35,9.5,19.0,41.0}	{10.0,3.0,1.95,1.7,1.25,1.08,1.02,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.47,1.7,2.07,3.35,10.0,26.0,61.0}	{2.62,2.1,1.72,1.33,1.06,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.33,2.43,5.5,15.0}	{3.5,1.57,1.15,1.03}	https://www.oddsportal.com/football/greece/super-league/panetolikos-volos-APUfJNhi/#1X2;2	2023-05-07 20:16:54.416489+01
198	AEK Athens FC	Ionikos	2022-10-03 20:00:00+01	4	1	1.23	6.0	15	1.66	2.6	1	2	0	2	11.0	1.47	3.1	10.0	{0.5,1.5,2.5,2.75,3.5,4.5,5.5,6.5}	{1.04,1.22,1.7,1.93,2.75,5.0,11.0,21.0}	{15.0,4.0,2.11,1.93,1.44,1.17,1.06,1.01}	{0.5,1.25,1.5,2.5,3.5,4.5}	{1.33,2.1,2.5,6.5,19.0,36.0}	{3.25,1.7,1.53,1.12,1.02,1.01}	{0.5,1.5,2.5,3.5,4.5}	{1.25,2.0,4.0,10.0,26.0}	{4.33,1.8,1.23,1.06,1.01}	https://www.oddsportal.com/football/greece/super-league/aek-ionikos-4WJ5mN8N/#1X2;2	2023-05-07 20:17:25.94084+01
199	Giannina	Panetolikos	2022-10-03 18:00:00+01	1	4	2.25	3.1	4	3.0	1.95	2	0	2	1	4.5	2.7	2.2	3.8	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.11,1.5,1.95,2.6,5.0,13.0,26.0,41.0}	{7.0,2.5,1.9,1.52,1.17,1.05,1.02,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.57,1.85,3.75,13.0,29.0,71.0}	{2.38,1.95,1.3,1.05,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.62,7.0,19.0}	{3.0,1.57,1.11,1.02}	https://www.oddsportal.com/football/greece/super-league/giannina-panetolikos-dM4L4Owb/#1X2;2	2023-05-07 20:17:56.466643+01
200	PAOK	Panathinaikos	2022-10-02 21:30:00+01	1	2	2.35	3.0	4	3.2	1.83	2	0	0	1	4.5	2.88	2.1	3.75	{0.5,1.5,1.75,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.13,1.57,1.83,2.87,6.0,15.0,26.0,51.0}	{6.0,2.38,2.02,1.44,1.14,1.04,1.01,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.63,2.0,4.0,15.0,36.0,91.0}	{2.3,1.8,1.25,1.04,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.4,3.0,8.0,23.0}	{2.75,1.4,1.1,1.02}	https://www.oddsportal.com/football/greece/super-league/paok-panathinaikos-EcFG54Oi/#1X2;2	2023-05-07 20:18:27.375742+01
201	Volos	Aris	2022-10-02 19:30:00+01	2	0	4.2	3.6	2	5.0	2.05	0	0	0	2	2.62	4.33	2.3	2.45	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.1,1.44,2.02,2.25,4.33,10.0,21.0,36.0}	{9.0,2.75,1.83,1.62,1.22,1.06,1.02,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.5,1.72,3.4,10.0,26.0,67.0}	{2.62,2.07,1.33,1.06,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.5,6.0,17.0}	{3.4,1.51,1.13,1.02}	https://www.oddsportal.com/football/greece/super-league/volos-aris-niNUs1Wp/#1X2;2	2023-05-07 20:19:01.839229+01
202	Olympiacos Piraeus	Atromitos	2022-10-02 16:00:00+01	2	0	1.35	4.8	10	1.85	2.4	0	1	0	1	9.0	1.7	2.85	7.5	{0.5,1.5,2.5,3.5,4.5,5.5,6.5}	{1.05,1.26,1.85,3.0,6.0,13.0,26.0}	{13.0,3.75,2.0,1.36,1.14,1.05,1.01}	{0.5,1.0,1.5,2.5,3.5,4.5}	{1.37,1.77,2.62,7.0,21.0,46.0}	{3.0,2.02,1.5,1.1,1.02,1.01}	{0.5,1.5,2.5,3.5,4.5}	{1.25,2.1,4.33,11.0,26.0}	{4.1,1.75,1.21,1.05,1.01}	https://www.oddsportal.com/football/greece/super-league/olympiacos-piraeus-atromitos-0fBC6p9o/#1X2;2	2023-05-07 20:19:32.181943+01
203	Asteras Tripolis	OFI Crete	2022-10-02 15:00:00+01	2	0	2.0	3.3	4	2.75	2.0	0	0	0	2	4.75	2.38	2.3	4.2	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.1,1.44,2.05,2.3,4.33,10.0,21.0,36.0}	{7.5,2.75,1.8,1.6,1.2,1.06,1.02,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.5,1.72,3.4,10.0,26.0,67.0}	{2.62,2.07,1.33,1.06,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.4,6.0,17.0}	{3.4,1.53,1.12,1.02}	https://www.oddsportal.com/football/greece/super-league/asteras-tripolis-ofi-crete-pry3nsOT/#1X2;2	2023-05-07 20:20:03.022111+01
204	Lamia	Levadiakos	2022-10-01 19:30:00+01	1	0	2.05	3.25	4	2.87	1.95	0	1	0	0	4.75	2.5	2.2	4.2	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.12,1.53,1.98,2.6,5.5,13.0,26.0,46.0}	{7.0,2.5,1.88,1.52,1.16,1.05,1.01,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.57,1.85,3.75,13.0,29.0,71.0}	{2.38,1.95,1.29,1.05,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.4,2.62,7.0,19.0}	{3.0,1.44,1.1,1.02}	https://www.oddsportal.com/football/greece/super-league/lamia-levadiakos-zD3P3rg4/#1X2;2	2023-05-07 20:20:34.574738+01
205	Volos	Ionikos	2022-09-18 21:00:00+01	2	0	2.0	3.25	4	2.75	2.05	0	1	0	1	4.5	2.38	2.3	4.0	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.08,1.4,2.0,2.25,4.0,9.0,19.0,31.0}	{9.0,3.0,1.85,1.63,1.25,1.07,1.02,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.5,1.7,3.4,10.0,26.0,56.0}	{2.62,2.1,1.36,1.07,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.33,2.38,5.5,15.0}	{3.5,1.55,1.14,1.03}	https://www.oddsportal.com/football/greece/super-league/volos-ionikos-d0Tphofh/#1X2;2	2023-05-07 20:21:05.659247+01
206	Aris	Olympiacos Piraeus	2022-09-18 20:00:00+01	2	1	4.15	3.3	2	4.5	2.05	0	2	1	0	2.75	4.2	2.3	2.4	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.1,1.44,1.73,2.0,2.38,4.33,9.0,21.0,36.0}	{9.0,2.75,2.15,1.85,1.61,1.22,1.07,1.02,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.5,1.7,3.4,10.0,26.0,61.0}	{2.5,2.1,1.33,1.06,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.5,6.0,17.0}	{3.4,1.53,1.13,1.02}	https://www.oddsportal.com/football/greece/super-league/aris-olympiacos-piraeus-lzQxf7Pu/#1X2;2	2023-05-07 20:21:36.557654+01
207	OFI Crete	PAOK	2022-09-18 19:00:00+01	1	1	5.0	3.6	2	5.5	2.1	0	1	1	0	2.4	4.8	2.4	2.1	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.08,1.37,1.93,2.15,4.0,9.0,19.0,31.0}	{8.5,3.0,1.93,1.67,1.25,1.08,1.02,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.46,2.1,3.25,10.0,26.0,61.0}	{2.62,1.7,1.36,1.07,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.33,2.38,5.5,15.0}	{3.5,1.57,1.14,1.03}	https://www.oddsportal.com/football/greece/super-league/ofi-crete-paok-IFHgjPO4/#1X2;2	2023-05-07 20:22:07.304207+01
208	Levadiakos	Asteras Tripolis	2022-09-18 18:00:00+01	1	1	3.0	3.1	3	3.75	1.95	1	1	0	0	3.4	3.3	2.2	2.88	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.1,1.5,1.85,2.4,4.5,11.0,23.0,41.0}	{7.0,2.62,2.0,1.53,1.18,1.05,1.02,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.53,1.8,3.75,11.0,26.0,67.0}	{2.62,2.0,1.33,1.06,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.62,6.5,19.0}	{3.25,1.5,1.11,1.02}	https://www.oddsportal.com/football/greece/super-league/levadiakos-asteras-tripolis-ziSli59b/#1X2;2	2023-05-07 20:22:37.861949+01
209	Panathinaikos	Giannina	2022-09-17 21:30:00+01	3	0	1.36	4.8	11	1.9	2.3	0	2	0	1	9.0	1.62	2.75	8.0	{0.5,1.5,2.5,3.5,4.5,5.5,6.5}	{1.06,1.31,2.02,3.5,7.0,15.0,26.0}	{11.0,3.4,1.85,1.33,1.11,1.03,1.0}	{0.5,1.0,1.5,2.5,3.5,4.5}	{1.4,1.95,3.0,8.0,23.0,51.0}	{2.75,1.85,1.44,1.08,1.02,1.0}	{0.5,1.5,2.5,3.5}	{1.3,2.25,5.0,13.0}	{3.75,1.63,1.17,1.04}	https://www.oddsportal.com/football/greece/super-league/panathinaikos-giannina-WILckqvB/#1X2;2	2023-05-07 20:23:08.291192+01
210	Atromitos	Lamia	2022-09-17 20:00:00+01	0	0	1.95	3.3	5	2.75	2.0	0	0	0	0	5.0	2.38	2.25	4.4	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.1,1.5,1.93,2.5,5.0,11.0,26.0,41.0}	{7.0,2.62,1.93,1.57,1.2,1.05,1.02,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.53,1.82,3.75,11.0,26.0,67.0}	{2.5,1.97,1.33,1.06,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.62,6.5,19.0}	{3.25,1.44,1.11,1.02}	https://www.oddsportal.com/football/greece/super-league/atromitos-lamia-SQOtgRvn/#1X2;2	2023-05-07 20:23:48.18983+01
211	Panetolikos	AEK Athens FC	2022-09-17 20:00:00+01	0	2	5.0	3.6	2	5.5	2.1	2	0	0	0	2.37	5.0	2.4	2.05	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.07,1.36,1.9,2.1,3.75,8.0,19.0,29.0}	{9.0,3.0,1.95,1.7,1.29,1.08,1.02,1.0}	{0.5,1.0,1.5,2.5,3.5,4.5}	{1.44,2.07,3.25,9.0,26.0,56.0}	{2.62,1.72,1.4,1.08,1.02,1.0}	{0.5,1.5,2.5,3.5}	{1.33,2.3,5.5,15.0}	{3.5,1.57,1.15,1.03}	https://www.oddsportal.com/football/greece/super-league/panetolikos-aek-QuL1l3gH/#1X2;2	2023-05-07 20:24:22.992302+01
212	PAOK	Lamia	2022-09-12 19:00:00+01	1	0	1.4	4.8	9	1.95	2.25	0	0	0	1	8.5	1.67	2.75	7.5	{0.5,1.5,2.25,2.5,2.75,3.5,4.5,5.5,6.5}	{1.06,1.33,1.83,2.05,3.75,8.0,17.0,26.0}	{11.0,3.25,2.02,1.78,1.3,1.11,1.03,1.0}	{0.5,1.0,1.5,2.5,3.5,4.5}	{1.44,2.0,3.4,9.0,23.0,51.0}	{2.75,1.8,1.36,1.1,1.02,1.0}	{0.5,1.5,2.5,3.5,4.5}	{1.33,2.3,5.5,15.0}	{3.75,1.65,1.17,1.04}	https://www.oddsportal.com/football/greece/super-league/paok-lamia-jB4RnjIC/#1X2;2	2023-05-07 20:24:55.124751+01
213	Asteras Tripolis	Aris	2022-09-11 21:30:00+01	0	2	3.54	3.2	2	4.33	1.95	1	0	1	0	3.0	3.9	2.2	2.6	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.11,1.5,1.9,2.5,5.0,11.0,26.0,41.0}	{7.0,2.5,1.95,1.5,1.17,1.05,1.02,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.57,1.82,3.75,11.0,29.0,71.0}	{2.5,1.97,1.29,1.05,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.62,7.0,19.0}	{3.25,1.44,1.11,1.02}	https://www.oddsportal.com/football/greece/super-league/asteras-tripolis-aris-S8D6iE3s/#1X2;2	2023-05-07 20:25:26.681937+01
214	Panathinaikos	AEK Athens FC	2022-09-11 21:30:00+01	2	1	2.3	3.2	3	3.1	1.95	0	0	1	2	4.2	2.88	2.25	3.6	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.11,1.51,1.83,2.62,4.8,11.0,23.0,46.0}	{7.0,2.62,2.02,1.53,1.18,1.05,1.01,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.55,1.77,3.5,11.0,29.0,71.0}	{2.38,2.02,1.3,1.05,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.4,2.65,6.5,19.0}	{3.25,1.5,1.11,1.02}	https://www.oddsportal.com/football/greece/super-league/panathinaikos-aek-dl5NmW26/#1X2;2	2023-05-07 20:25:58.417663+01
215	Olympiacos Piraeus	Volos	2022-09-11 18:30:00+01	1	1	1.27	6.0	12	1.72	2.5	0	1	1	0	9.5	1.57	3.1	8.5	{0.5,1.5,2.5,2.75,3.5,4.5,5.5,6.5}	{1.03,1.25,1.73,1.98,2.75,5.5,11.0,23.0}	{15.0,4.0,2.07,1.88,1.4,1.15,1.05,1.01}	{0.5,1.0,1.25,1.5,2.5,3.5,4.5}	{1.33,1.7,2.62,6.5,19.0,41.0}	{3.25,2.1,1.5,1.11,1.02,1.01}	{0.5,1.5,2.5,3.5,4.5}	{1.25,2.05,4.33,11.0,26.0}	{4.33,1.8,1.23,1.06,1.01}	https://www.oddsportal.com/football/greece/super-league/olympiacos-piraeus-volos-0MBEkhYg/#1X2;2	2023-05-07 20:26:30.488573+01
216	Ionikos	Atromitos	2022-09-10 21:30:00+01	1	4	2.33	3.1	4	2.9	2.05	4	0	0	1	4.33	2.6	2.3	3.7	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.1,1.4,2.0,2.3,4.0,9.0,19.0,34.0}	{8.0,3.0,1.85,1.65,1.22,1.07,1.02,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.5,1.7,3.4,10.0,26.0,61.0}	{2.5,2.1,1.3,1.06,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.33,2.38,5.5,15.0}	{3.5,1.57,1.14,1.03}	https://www.oddsportal.com/football/greece/super-league/ionikos-atromitos-MVCAjYIm/#1X2;2	2023-05-07 20:27:02.101659+01
217	Giannina	Levadiakos	2022-09-10 19:15:00+01	2	1	2.05	3.3	4	2.87	1.95	0	1	1	1	4.75	2.6	2.2	4.0	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.1,1.5,1.88,2.4,5.0,11.0,26.0,41.0}	{8.0,2.62,1.98,1.57,1.2,1.05,1.02,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.53,1.8,3.75,11.0,29.0,71.0}	{2.5,2.0,1.3,1.05,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.62,6.5,19.0}	{3.25,1.5,1.11,1.02}	https://www.oddsportal.com/football/greece/super-league/giannina-levadiakos-ldNUoAXI/#1X2;2	2023-05-07 20:27:35.762597+01
218	OFI Crete	Panetolikos	2022-09-10 18:30:00+01	1	2	2.25	3.2	3	3.0	2.0	1	0	1	1	4.2	2.7	2.3	3.5	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.1,1.4,2.02,2.3,4.33,10.0,21.0,36.0}	{8.0,2.75,1.83,1.62,1.22,1.06,1.02,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.5,1.72,3.4,10.0,26.0,67.0}	{2.62,2.07,1.33,1.06,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.33,2.38,6.0,17.0}	{3.4,1.53,1.13,1.02}	https://www.oddsportal.com/football/greece/super-league/ofi-crete-panetolikos-Ic6JlCm0/#1X2;2	2023-05-07 20:28:07.490712+01
219	AEK Athens FC	Giannina	2022-09-04 21:30:00+01	2	0	1.25	6.0	13	1.66	2.6	0	1	0	1	10.0	1.5	3.2	9.0	{0.5,1.5,2.5,2.75,3.5,4.5,5.5,6.5}	{1.04,1.22,1.7,1.9,2.62,5.0,11.0,21.0}	{13.0,4.33,2.1,1.95,1.44,1.17,1.06,1.01}	{0.5,1.0,1.25,1.5,2.5,3.5,4.5}	{1.33,2.07,2.5,6.0,17.0,41.0}	{3.4,1.72,1.53,1.12,1.02,1.01}	{0.5,1.5,2.5,3.5,4.5}	{1.25,2.0,4.0,10.0,23.0}	{4.5,1.83,1.25,1.06,1.01}	https://www.oddsportal.com/football/greece/super-league/aek-giannina-S8iyxZ3f/#1X2;2	2023-05-07 20:28:39.091011+01
220	Aris	PAOK	2022-09-04 21:30:00+01	0	0	2.4	3.2	3	3.25	1.95	0	0	0	0	3.75	2.8	2.25	3.3	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.1,1.44,1.83,2.5,4.5,11.0,23.0,36.0}	{8.0,2.62,2.02,1.55,1.19,1.06,1.02,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.53,1.77,3.5,11.0,26.0,67.0}	{2.5,2.02,1.33,1.06,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.62,6.5,19.0}	{3.25,1.5,1.12,1.02}	https://www.oddsportal.com/football/greece/super-league/aris-paok-tCeuygJ0/#1X2;2	2023-05-07 20:29:11.798935+01
221	Volos	OFI Crete	2022-09-04 19:00:00+01	0	1	1.9	3.5	4	2.5	2.2	0	0	1	0	4.33	2.25	2.5	4.0	{0.5,1.5,2.5,3.5,4.5,5.5,6.5}	{1.06,1.33,2.0,3.4,6.5,15.0,23.0}	{10.0,3.5,1.9,1.33,1.11,1.03,1.0}	{0.5,1.0,1.5,2.5,3.5,4.5}	{1.4,1.9,2.75,8.0,21.0,51.0}	{2.75,1.9,1.4,1.1,1.02,1.01}	{0.5,1.5,2.5,3.5,4.5}	{1.29,2.2,4.5,11.0,26.0}	{4.0,1.72,1.2,1.05,1.01}	https://www.oddsportal.com/football/greece/super-league/volos-ofi-crete-2RqlZWmD/#1X2;2	2023-05-07 20:29:42.422715+01
222	Atromitos	Panetolikos	2022-09-04 18:30:00+01	1	1	2.1	3.15	4	2.75	2.05	0	1	1	0	4.5	2.5	2.3	4.0	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.1,1.41,2.02,2.25,4.1,10.0,21.0,36.0}	{8.0,2.75,1.83,1.65,1.22,1.06,1.02,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.5,1.72,3.4,10.0,26.0,61.0}	{2.62,2.07,1.33,1.06,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.4,5.5,15.0}	{3.4,1.53,1.14,1.03}	https://www.oddsportal.com/football/greece/super-league/atromitos-panetolikos-OzopzDY6/#1X2;2	2023-05-07 20:30:13.765547+01
223	Panathinaikos	Levadiakos	2022-09-03 20:30:00+01	1	0	1.16	7.0	23	1.61	2.55	0	0	0	1	17.0	1.4	3.2	15.0	{0.5,1.5,2.5,3.5,4.5,5.5,6.5}	{1.06,1.33,1.91,3.4,6.5,13.0,26.0}	{10.0,3.5,1.95,1.33,1.11,1.04,1.01}	{0.5,1.0,1.5,2.5,3.5,4.5}	{1.4,1.82,2.75,7.0,21.0,51.0}	{3.0,1.97,1.4,1.1,1.02,1.01}	{0.5,1.5,2.5,3.5}	{1.3,2.25,4.75,13.0}	{4.0,1.66,1.18,1.04}	https://www.oddsportal.com/football/greece/super-league/panathinaikos-levadiakos-UXXVcGQD/#1X2;2	2023-05-07 20:30:44.478662+01
224	Olympiacos Piraeus	Ionikos	2022-09-03 19:00:00+01	3	1	1.36	5.35	11	1.8	2.5	1	1	0	2	8.0	1.62	3.0	7.5	{0.5,1.5,2.5,2.75,3.5,4.5,5.5,6.5}	{1.04,1.22,1.67,1.88,2.62,5.0,10.0,21.0}	{15.0,4.33,2.25,1.98,1.44,1.17,1.06,1.01}	{0.5,1.25,1.5,2.5,3.5,4.5}	{1.31,2.07,2.5,6.0,17.0,36.0}	{3.4,1.72,1.53,1.12,1.02,1.01}	{0.5,1.5,2.5,3.5,4.5}	{1.22,2.0,4.0,10.0,23.0}	{4.5,1.83,1.25,1.06,1.01}	https://www.oddsportal.com/football/greece/super-league/olympiacos-piraeus-ionikos-8OWZdztK/#1X2;2	2023-05-07 20:31:15.471571+01
225	Lamia	Asteras Tripolis	2022-09-03 17:45:00+01	0	0	3.08	3.1	3	3.6	1.91	0	0	0	0	3.6	3.25	2.2	3.0	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.11,1.5,1.93,2.5,5.0,11.0,26.0,41.0}	{7.0,2.5,1.93,1.52,1.17,1.05,1.02,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.57,1.85,3.75,11.0,29.0,71.0}	{2.5,1.95,1.3,1.05,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.4,2.62,6.5,19.0}	{3.25,1.44,1.11,1.02}	https://www.oddsportal.com/football/greece/super-league/lamia-asteras-tripolis-jmMvdfeQ/#1X2;2	2023-05-07 20:31:45.670273+01
226	Asteras Tripolis	Olympiacos Piraeus	2022-08-29 19:00:00+01	0	0	5.75	3.4	2	5.5	2.05	0	0	0	0	2.45	5.1	2.37	2.2	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.1,1.46,2.0,2.48,5.0,11.5,19.5,41.0}	{8.0,3.0,1.85,1.61,1.22,1.07,1.02,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.51,1.7,3.6,10.0,26.0,67.0}	{2.5,2.1,1.33,1.06,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.65,6.0,16.0}	{3.5,1.53,1.14,1.03}	https://www.oddsportal.com/football/greece/super-league/asteras-tripolis-olympiacos-piraeus-UD9lows8/#1X2;2	2023-05-07 20:32:17.461151+01
227	PAOK	Atromitos	2022-08-28 21:45:00+01	2	1	1.47	4.25	8	2.0	2.3	1	1	0	1	7.0	1.81	2.7	6.5	{0.5,1.5,2.5,3.5,4.5,5.5,6.5}	{1.06,1.3,1.95,3.4,6.75,15.0,23.0}	{11.5,3.65,1.9,1.33,1.11,1.03,1.0}	{0.5,1.0,1.5,2.5,3.5,4.5}	{1.4,1.87,2.8,8.0,21.0,46.0}	{3.0,1.92,1.44,1.09,1.02,1.01}	{0.5,1.5,2.5,3.5}	{1.29,2.2,4.5,11.0}	{4.0,1.66,1.19,1.05}	https://www.oddsportal.com/football/greece/super-league/paok-atromitos-fegTweZs/#1X2;2	2023-05-07 20:32:48.641338+01
228	OFI Crete	Panathinaikos	2022-08-28 21:00:00+01	0	2	4.25	3.4	2	4.75	2.08	0	0	2	0	2.75	4.5	2.38	2.4	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.08,1.4,1.98,2.2,4.1,9.0,19.0,34.0}	{9.0,3.05,1.88,1.65,1.25,1.07,1.02,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.46,1.67,2.1,3.4,10.0,26.0,61.0}	{2.7,2.15,1.7,1.36,1.07,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.33,2.38,5.5,15.0}	{3.5,1.57,1.14,1.03}	https://www.oddsportal.com/football/greece/super-league/ofi-crete-panathinaikos-zBCdqHBK/#1X2;2	2023-05-07 20:33:20.307098+01
229	Panetolikos	Aris	2022-08-28 19:00:00+01	3	1	5.25	3.25	2	5.5	2.0	0	2	1	1	2.5	4.9	2.32	2.2	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.1,1.44,1.83,2.4,4.5,11.0,23.0,36.0}	{8.0,2.9,2.02,1.58,1.2,1.06,1.02,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.53,1.77,3.5,11.0,26.0,67.0}	{2.55,2.02,1.33,1.05,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.5,6.0,17.0}	{3.25,1.5,1.12,1.02}	https://www.oddsportal.com/football/greece/super-league/panetolikos-aris-E1B0ryRQ/#1X2;2	2023-05-07 20:33:52.250372+01
230	AEK Athens FC	Volos	2022-08-27 21:30:00+01	0	1	1.28	6.0	11	1.72	2.8	0	0	1	0	9.0	1.53	3.3	8.0	{0.5,1.5,2.5,3.0,3.5,4.5,5.5,6.5}	{1.02,1.17,1.57,1.95,2.45,4.5,9.0,17.0}	{18.0,5.1,2.4,1.9,1.53,1.22,1.08,1.02}	{0.5,1.25,1.5,2.5,3.5,4.5}	{1.3,1.97,2.3,5.5,15.0,34.0}	{3.85,1.82,1.57,1.15,1.03,1.01}	{0.5,1.5,2.5,3.5,4.5}	{1.22,1.91,3.75,8.0,21.0}	{5.0,1.95,1.29,1.08,1.01}	https://www.oddsportal.com/football/greece/super-league/aek-volos-Quq8xow8/#1X2;2	2023-05-07 20:34:22.99858+01
231	Giannina	Lamia	2022-08-27 20:00:00+01	1	1	2.0	3.2	4	2.75	1.98	1	0	0	1	5.0	2.43	2.23	4.33	{0.5,1.5,2.0,2.5,3.5,4.5,5.5,6.5}	{1.11,1.5,1.95,2.5,5.1,13.0,26.0,41.0}	{7.5,2.6,1.9,1.5,1.17,1.05,1.01,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.57,1.85,3.75,11.0,29.0,71.0}	{2.45,1.95,1.3,1.05,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.4,2.62,7.0,19.0}	{3.25,1.44,1.11,1.02}	https://www.oddsportal.com/football/greece/super-league/giannina-lamia-YohXxFll/#1X2;2	2023-05-07 20:34:54.602108+01
232	Ionikos	Levadiakos	2022-08-26 21:30:00+01	0	0	2.05	3.25	4	2.8	2.05	0	0	0	0	4.33	2.48	2.37	3.95	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.08,1.4,1.95,2.28,4.4,9.5,19.0,31.0}	{8.5,3.0,1.9,1.66,1.23,1.07,1.02,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.5,2.1,3.35,10.0,26.0,61.0}	{2.62,1.7,1.36,1.07,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.33,2.45,5.5,15.0}	{3.5,1.57,1.14,1.03}	https://www.oddsportal.com/football/greece/super-league/ionikos-levadiakos-tlDhpcdE/#1X2;2	2023-05-07 20:35:25.878128+01
233	Olympiacos Piraeus	Giannina	2022-08-21 22:00:00+01	2	0	1.28	5.8	11	1.73	2.5	0	2	0	0	9.5	1.57	3.0	8.5	{0.5,1.5,2.5,2.75,3.5,4.5,5.5,6.5}	{1.04,1.25,1.75,2.0,3.0,5.5,11.0,23.0}	{12.0,4.0,2.05,1.85,1.4,1.14,1.05,1.01}	{0.5,1.0,1.5,2.5,3.5,4.5}	{1.33,1.72,2.62,6.5,19.0,41.0}	{3.25,2.07,1.5,1.11,1.02,1.01}	{0.5,1.5,2.5,3.5,4.5}	{1.25,2.05,4.33,11.0,26.0}	{4.33,1.77,1.22,1.06,1.01}	https://www.oddsportal.com/football/greece/super-league/olympiacos-piraeus-giannina-d0iitTwq/#1X2;2	2023-05-07 20:35:57.480721+01
234	Aris	Levadiakos	2022-08-21 20:30:00+01	3	0	1.41	4.4	10	1.95	2.3	0	1	0	2	8.0	1.75	2.65	7.0	{0.5,1.5,2.5,3.5,4.5,5.5,6.5}	{1.06,1.33,2.02,3.5,7.0,15.0,26.0}	{10.0,3.4,1.83,1.29,1.1,1.03,1.0}	{0.5,1.0,1.5,2.5,3.5,4.5}	{1.41,1.95,3.0,8.0,23.0,51.0}	{2.75,1.85,1.4,1.08,1.02,1.0}	{0.5,1.5,2.5,3.5}	{1.33,2.2,5.0,13.0}	{3.75,1.66,1.17,1.04}	https://www.oddsportal.com/football/greece/super-league/aris-levadiakos-nR1HnV0F/#1X2;2	2023-05-07 20:36:27.476964+01
235	Panathinaikos	Ionikos	2022-08-21 20:00:00+01	1	0	1.36	5.25	11	1.83	2.37	0	0	0	1	8.5	1.62	2.87	8.0	{0.5,1.5,2.5,3.5,4.5,5.5,6.5}	{1.05,1.3,1.88,3.25,6.0,13.0,26.0}	{11.0,3.75,1.98,1.36,1.12,1.04,1.01}	{0.5,1.0,1.5,2.5,3.5,4.5}	{1.37,1.8,2.75,7.0,21.0,46.0}	{3.0,2.0,1.44,1.1,1.02,1.01}	{0.5,1.5,2.5,3.5,4.5}	{1.29,2.1,4.5,11.0,26.0}	{4.0,1.72,1.2,1.05,1.01}	https://www.oddsportal.com/football/greece/super-league/panathinaikos-ionikos-vPtdumgk/#1X2;2	2023-05-07 20:36:58.564475+01
236	PAOK	Panetolikos	2022-08-20 21:45:00+01	1	0	1.5	4.4	7	2.0	2.37	0	0	0	1	6.5	1.75	2.75	5.8	{0.5,1.5,2.5,2.75,3.5,4.5,5.5,6.5}	{1.04,1.25,1.78,2.0,2.8,5.5,11.0,23.0}	{13.0,4.0,2.05,1.85,1.4,1.15,1.05,1.01}	{0.5,1.0,1.25,1.5,2.5,3.5,4.5}	{1.36,1.72,2.62,6.5,19.0,41.0}	{3.25,2.07,1.5,1.11,1.02,1.01}	{0.5,1.5,2.5,3.5,4.5}	{1.25,2.0,4.0,10.0,26.0}	{4.33,1.8,1.22,1.06,1.01}	https://www.oddsportal.com/football/greece/super-league/paok-panetolikos-IFu0v78e/#1X2;2	2023-05-07 20:37:29.820603+01
237	Lamia	AEK Athens FC	2022-08-20 21:30:00+01	0	3	15.0	5.0	1	12.0	2.2	2	0	1	0	1.83	11.0	2.65	1.62	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.08,1.4,2.0,2.25,4.0,9.0,21.0,34.0}	{7.75,2.75,1.85,1.62,1.22,1.07,1.02,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.46,1.67,2.15,3.4,10.0,26.0,61.0}	{2.62,2.15,1.67,1.36,1.07,1.02,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.5,6.0,17.0}	{3.4,1.53,1.13,1.02}	https://www.oddsportal.com/football/greece/super-league/lamia-aek-nkp4wRN1/#1X2;2	2023-05-07 20:38:00.806334+01
238	Atromitos	OFI Crete	2022-08-20 20:00:00+01	3	1	2.2	3.25	4	2.87	2.1	0	1	1	2	4.0	2.5	2.4	3.7	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.07,1.36,1.8,2.05,3.5,7.0,17.0,26.0}	{10.0,3.4,2.05,1.75,1.29,1.1,1.03,1.0}	{0.5,1.0,1.5,2.5,3.5,4.5}	{1.44,2.0,3.0,9.0,23.0,56.0}	{2.62,1.8,1.36,1.08,1.02,1.0}	{0.5,1.5,2.5,3.5}	{1.3,2.25,5.0,13.0}	{3.75,1.66,1.17,1.04}	https://www.oddsportal.com/football/greece/super-league/atromitos-ofi-crete-QH0LokGL/#1X2;2	2023-05-07 20:38:31.280004+01
239	Volos	Asteras Tripolis	2022-08-19 21:30:00+01	3	3	2.45	3.4	3	3.2	2.05	2	2	1	1	3.6	2.88	2.3	3.25	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.08,1.4,1.95,2.2,4.0,9.0,19.0,34.0}	{9.0,3.0,1.9,1.66,1.25,1.07,1.02,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.47,2.15,3.4,10.0,26.0,61.0}	{2.62,1.67,1.36,1.07,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.33,2.38,5.5,15.0}	{3.5,1.57,1.14,1.03}	https://www.oddsportal.com/football/greece/super-league/volos-asteras-tripolis-Kv0Pp9VR/#1X2;2	2023-05-07 20:39:02.655148+01
241	Veria	Lamia	2022-06-11 18:45:00+01	1	2	2.95	3.1	3	3.7	1.9	1	1	1	0	3.6	3.3	2.2	3.0	{0.5,1.5,2.0,2.5,3.5,4.5,5.5,6.5}	{1.12,1.53,2.0,2.6,5.5,13.0,26.0,51.0}	{6.5,2.5,1.85,1.47,1.14,1.04,1.01,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.6,1.87,3.8,13.0,34.0,81.0}	{2.25,1.92,1.25,1.04,1.0,1.0}	{0.5,1.5,2.5,3.5}	{1.37,2.7,7.0,21.0}	{3.0,1.44,1.1,1.01}	https://www.oddsportal.com/football/greece/super-league-2021-2022/veria-lamia-OCjeCxom/#1X2;2	2023-05-07 20:40:32.40256+01
243	Giannina	Aris	2022-05-17 20:00:00+01	0	3	3.8	3.2	2	4.33	2.05	1	0	2	0	2.8	3.85	2.37	2.5	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.08,1.37,1.75,1.88,2.2,4.2,9.0,17.0,31.0}	{9.0,3.25,2.13,1.98,1.7,1.25,1.08,1.02,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.49,1.7,2.07,3.25,9.0,26.0,61.0}	{2.63,2.1,1.72,1.33,1.07,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.28,2.38,5.5,15.0}	{3.5,1.57,1.15,1.03}	https://www.oddsportal.com/football/greece/super-league-2021-2022/giannina-aris-SSJ6VVc8/#1X2;2	2023-05-07 20:41:37.25437+01
244	PAOK	Panathinaikos	2022-05-17 20:00:00+01	2	0	1.9	3.4	4	2.6	2.05	0	0	0	2	4.75	2.28	2.37	4.4	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.08,1.39,1.95,2.28,4.4,9.5,19.0,34.0}	{9.0,3.0,1.9,1.66,1.22,1.07,1.02,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.49,1.67,2.1,3.4,10.0,26.0,61.0}	{2.62,2.15,1.7,1.3,1.06,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.29,2.48,5.5,15.0}	{3.5,1.57,1.14,1.03}	https://www.oddsportal.com/football/greece/super-league-2021-2022/paok-panathinaikos-vDQO6nL7/#1X2;2	2023-05-07 20:42:09.930861+01
245	Asteras Tripolis	Apollon Smyrnis	2022-05-15 19:30:00+01	2	2	1.48	4.0	8	2.06	2.2	2	2	0	0	8.0	1.85	2.5	7.0	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.07,1.37,1.95,2.2,4.3,9.0,19.0,31.0}	{9.0,3.0,1.9,1.66,1.23,1.08,1.02,1.0}	{0.5,1.0,1.5,2.5,3.5,4.5}	{1.46,2.1,3.25,10.0,26.0,56.0}	{2.7,1.7,1.33,1.06,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.28,2.43,5.5,15.0}	{3.5,1.55,1.14,1.03}	https://www.oddsportal.com/football/greece/super-league-2021-2022/asteras-tripolis-apollon-smyrnis-Slesr9sE/#1X2;2	2023-05-07 20:42:41.015681+01
246	Ionikos	Panetolikos	2022-05-15 19:30:00+01	3	1	2.15	3.25	4	2.85	2.1	1	2	0	1	4.0	2.5	2.4	3.65	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.06,1.31,2.02,3.7,7.5,15.0,26.0}	{10.0,3.5,1.83,1.3,1.1,1.03,1.0}	{0.5,1.0,1.5,2.5,3.5,4.5}	{1.42,1.97,3.05,8.0,23.0,51.0}	{2.75,1.82,1.37,1.08,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.24,2.23,4.4,11.0}	{4.0,1.72,1.2,1.05}	https://www.oddsportal.com/football/greece/super-league-2021-2022/ionikos-panetolikos-6ufosTdK/#1X2;2	2023-05-07 20:43:13.504579+01
248	Aris	AEK Athens FC	2022-05-14 20:00:00+01	3	2	2.6	3.25	3	3.4	2.05	2	3	0	0	3.75	2.9	2.3	3.4	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.11,1.5,1.73,1.93,2.5,4.5,10.0,19.0,34.0}	{9.0,3.0,2.15,1.93,1.66,1.25,1.07,1.02,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.62,1.72,2.1,3.5,10.0,26.0,61.0}	{2.5,2.07,1.7,1.32,1.06,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.5,5.5,15.0}	{3.5,1.57,1.14,1.03}	https://www.oddsportal.com/football/greece/super-league-2021-2022/aris-aek-QkK8AULr/#1X2;2	2023-05-07 20:44:18.312073+01
249	Olympiacos Piraeus	PAOK	2022-05-14 20:00:00+01	1	1	2.3	3.4	3	3.0	2.2	0	0	1	1	3.65	2.8	2.5	3.3	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.06,1.3,2.02,3.7,7.5,13.0,26.0}	{11.0,3.75,1.95,1.33,1.12,1.04,1.01}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.4,1.85,3.05,8.0,21.0,46.0}	{2.8,1.95,1.4,1.08,1.02,1.0}	{0.5,1.5,2.5,3.5,4.5}	{1.29,2.23,4.5,11.0,26.0}	{4.0,1.72,1.2,1.05,1.01}	https://www.oddsportal.com/football/greece/super-league-2021-2022/olympiacos-piraeus-paok-KCJC9lyk/#1X2;2	2023-05-07 20:44:51.872474+01
250	Panathinaikos	Giannina	2022-05-14 20:00:00+01	4	0	1.22	6.75	23	1.67	2.63	0	3	0	1	15.0	1.57	3.25	13.0	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.06,1.3,1.91,3.4,6.5,13.0,26.0}	{13.0,3.75,2.02,1.36,1.14,1.04,1.01}	{0.5,1.0,1.5,2.5,3.5,4.5}	{1.44,1.75,2.75,6.5,19.0,46.0}	{3.25,2.05,1.44,1.11,1.02,1.01}	{0.5,1.5,2.5,3.5,4.5}	{1.3,2.25,4.75,11.0,26.0}	{4.33,1.75,1.22,1.05,1.01}	https://www.oddsportal.com/football/greece/super-league-2021-2022/panathinaikos-giannina-IcxG88je/#1X2;2	2023-05-07 20:45:23.291499+01
251	Volos	OFI Crete	2022-05-14 17:00:00+01	5	0	1.95	3.8	4	2.5	2.37	0	2	0	3	4.2	2.3	2.75	3.8	{0.5,1.5,2.5,2.75,3.5,4.5,5.5,6.5}	{1.04,1.22,1.7,1.83,2.65,4.9,10.0,19.0}	{15.0,4.7,2.23,2.02,1.45,1.18,1.06,1.02}	{0.5,1.0,1.25,1.5,2.5,3.5,4.5}	{1.4,1.7,2.07,2.62,6.5,17.0,41.0}	{3.45,2.1,1.72,1.53,1.12,1.02,1.01}	{0.5,1.5,2.5,3.5,4.5}	{1.25,2.0,3.8,8.75,21.0}	{5.0,1.9,1.28,1.08,1.01}	https://www.oddsportal.com/football/greece/super-league-2021-2022/volos-ofi-crete-QqHbJP4D/#1X2;2	2023-05-07 20:45:55.454816+01
252	Olympiacos Piraeus	Panathinaikos	2022-05-11 21:00:00+01	1	2	2.05	3.25	4	2.87	1.95	1	1	1	0	5.1	2.4	2.25	4.5	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.1,1.46,1.77,2.55,5.0,11.5,23.0,41.0}	{8.0,2.63,2.1,1.57,1.2,1.06,1.01,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.55,1.75,3.65,11.0,29.0,71.0}	{2.37,2.05,1.28,1.05,1.0,1.0}	{0.5,1.5,2.5,3.5}	{1.33,2.65,6.5,19.0}	{3.25,1.5,1.12,1.02}	https://www.oddsportal.com/football/greece/super-league-2021-2022/olympiacos-piraeus-panathinaikos-OtYtFADR/#1X2;2	2023-05-07 20:46:26.396135+01
253	AEK Athens FC	Giannina	2022-05-11 19:30:00+01	3	0	1.23	7.0	13	1.66	2.63	0	1	0	2	11.0	1.49	3.25	9.5	{0.5,1.5,2.25,2.5,2.75,3.5,4.5,5.5,6.5}	{1.03,1.22,1.76,1.85,3.05,6.0,10.0,21.0}	{15.0,4.33,2.2,2.0,1.46,1.18,1.06,1.01}	{0.5,1.0,1.25,1.5,2.5,3.5,4.5}	{1.31,2.05,2.6,6.0,17.0,36.0}	{3.4,1.75,1.53,1.12,1.02,1.0}	{0.5,1.5,2.5,3.5,4.5}	{1.18,2.0,3.75,10.0,23.0}	{4.6,1.87,1.26,1.07,1.01}	https://www.oddsportal.com/football/greece/super-league-2021-2022/aek-giannina-65wxGjbL/#1X2;2	2023-05-07 20:46:59.323697+01
418	Volos	OFI Crete	2021-11-20 15:00:00+00	0	2	2.35	3.3	3	3.0	2.1	1	0	1	0	3.7	2.75	2.5	3.3	{0.5,1.5,2.25,2.5,3.5,4.5,5.5}	{1.07,1.36,2.05,3.55,7.0,15.0}	{9.5,3.4,1.8,1.3,1.1,1.03}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.5,1.97,3.0,8.0,23.0,29.0}	{2.85,1.82,1.36,1.08,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.3,2.25,5.0,13.0}	{3.75,1.66,1.18,1.04}	https://www.oddsportal.com/football/greece/super-league-2021-2022/volos-ofi-crete-CnbPvl4p/#1X2;2	2023-05-07 22:14:18.417852+01
256	AEK Athens FC	Panathinaikos	2022-05-08 19:30:00+01	0	0	2.25	3.0	4	3.0	2.0	0	0	0	0	4.6	2.6	2.25	4.1	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.1,1.44,1.8,2.4,4.6,11.0,23.0,36.0}	{7.5,2.8,2.05,1.57,1.19,1.06,1.01,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.53,1.77,3.5,11.0,26.0,67.0}	{2.45,2.02,1.29,1.05,1.0,1.0}	{0.5,1.5,2.5,3.5}	{1.33,2.5,6.0,17.0}	{3.25,1.5,1.12,1.02}	https://www.oddsportal.com/football/greece/super-league-2021-2022/aek-panathinaikos-KlyQIhE2/#1X2;2	2023-05-07 20:48:33.730602+01
257	Giannina	PAOK	2022-05-08 18:00:00+01	1	0	5.5	3.25	2	5.5	2.0	0	1	0	0	2.6	4.8	2.3	2.3	{0.5,1.5,2.0,2.5,3.5,4.5,5.5,6.5}	{1.1,1.44,1.85,2.43,4.9,11.0,23.0,36.0}	{7.5,2.7,2.0,1.53,1.2,1.06,1.02,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.6,1.8,3.55,11.0,26.0,67.0}	{2.48,2.0,1.29,1.05,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.6,6.0,17.0}	{3.25,1.5,1.12,1.02}	https://www.oddsportal.com/football/greece/super-league-2021-2022/giannina-paok-Iqcsf9y2/#1X2;2	2023-05-07 20:49:06.019717+01
258	OFI Crete	Asteras Tripolis	2022-05-08 16:00:00+01	1	0	2.38	3.2	3	3.05	2.1	0	1	0	0	3.6	2.8	2.38	3.25	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.07,1.33,1.83,2.06,3.8,8.0,17.0,29.0}	{9.5,3.25,2.02,1.77,1.28,1.09,1.03,1.0}	{0.5,1.0,1.5,2.5,3.5,4.5}	{1.44,2.02,3.25,9.0,26.0,56.0}	{2.8,1.77,1.35,1.07,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.26,2.25,5.0,13.0}	{3.75,1.61,1.16,1.04}	https://www.oddsportal.com/football/greece/super-league-2021-2022/ofi-crete-asteras-tripolis-CtDfK5k7/#1X2;2	2023-05-07 20:49:37.673801+01
260	Atromitos	Ionikos	2022-05-07 19:30:00+01	0	1	2.2	3.25	4	2.87	2.1	1	0	0	0	4.0	2.5	2.4	3.65	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.06,1.3,1.98,3.55,7.5,13.0,26.0}	{11.0,3.75,1.93,1.33,1.11,1.04,1.01}	{0.5,1.0,1.5,2.5,3.5,4.5}	{1.42,1.87,3.0,8.0,23.0,51.0}	{2.8,1.92,1.38,1.08,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.23,2.17,4.5,11.0}	{4.0,1.66,1.19,1.05}	https://www.oddsportal.com/football/greece/super-league-2021-2022/atromitos-ionikos-vTEnMRKf/#1X2;2	2023-05-07 20:50:42.260921+01
262	PAOK	Olympiacos Piraeus	2022-05-04 19:00:00+01	1	2	2.3	3.1	3	3.05	2.0	2	0	0	1	4.0	2.7	2.25	3.6	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.1,1.44,1.83,2.1,2.4,4.5,11.0,23.0,41.0}	{8.0,2.85,2.02,1.77,1.57,1.19,1.06,1.01,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.53,1.77,3.5,11.0,26.0,67.0}	{2.55,2.02,1.28,1.05,1.0,1.0}	{0.5,1.5,2.5,3.5}	{1.33,2.5,6.0,17.0}	{3.25,1.5,1.12,1.02}	https://www.oddsportal.com/football/greece/super-league-2021-2022/paok-olympiacos-piraeus-UqvIU2Vi/#1X2;2	2023-05-07 20:51:45.694701+01
263	Asteras Tripolis	Lamia	2022-05-02 19:30:00+01	0	2	2.1	3.2	4	2.87	1.9	1	0	1	0	4.8	2.5	2.2	4.35	{0.5,1.5,2.0,2.5,3.5,4.5,5.5,6.5}	{1.12,1.53,2.02,2.7,5.5,13.0,23.0,46.0}	{6.5,2.48,1.83,1.47,1.15,1.04,1.0,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.58,1.9,3.85,13.0,31.0,71.0}	{2.28,1.9,1.25,1.04,1.0,1.0}	{0.5,1.5,2.5,3.5}	{1.37,2.75,7.0,21.0}	{3.0,1.41,1.1,1.01}	https://www.oddsportal.com/football/greece/super-league-2021-2022/asteras-tripolis-lamia-2oCJSTsR/#1X2;2	2023-05-07 20:52:17.027168+01
265	PAOK	AEK Athens FC	2022-05-01 21:00:00+01	1	1	2.2	3.25	4	2.87	2.05	0	0	1	1	4.25	2.5	2.3	3.85	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.08,1.4,2.05,2.3,4.33,10.0,21.0,34.0}	{8.5,3.0,1.8,1.62,1.22,1.07,1.01,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.5,1.72,3.4,10.0,26.0,61.0}	{2.6,2.07,1.32,1.06,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.3,2.38,5.5,15.0}	{3.5,1.57,1.14,1.03}	https://www.oddsportal.com/football/greece/super-league-2021-2022/paok-aek-vgbwekMe/#1X2;2	2023-05-07 20:53:18.419191+01
266	Panathinaikos	Aris	2022-05-01 19:00:00+01	1	0	2.1	2.9	4	2.9	1.9	0	0	0	1	5.0	2.6	2.1	4.5	{0.5,1.5,1.75,2.0,2.5,3.5,4.5,5.5,6.5}	{1.13,1.57,1.8,2.88,6.0,15.0,26.0,51.0}	{6.1,2.35,2.05,1.41,1.14,1.03,1.01,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.67,1.97,4.1,13.0,34.0,81.0}	{2.23,1.82,1.23,1.04,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.44,2.75,8.0,21.0}	{2.85,1.4,1.08,1.02}	https://www.oddsportal.com/football/greece/super-league-2021-2022/panathinaikos-aris-WSbZeV6k/#1X2;2	2023-05-07 20:53:50.898616+01
270	Giannina	AEK Athens FC	2022-04-18 18:00:00+01	2	3	5.25	3.3	2	5.5	2.05	1	2	2	0	2.48	5.0	2.35	2.23	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.09,1.41,2.05,2.3,4.5,10.0,21.0,36.0}	{8.0,2.88,1.8,1.61,1.21,1.06,1.01,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.51,1.72,3.4,10.0,26.0,67.0}	{2.55,2.07,1.3,1.06,1.0,1.0}	{0.5,1.5,2.5,3.5}	{1.3,2.5,6.0,17.0}	{3.4,1.52,1.13,1.02}	https://www.oddsportal.com/football/greece/super-league-2021-2022/giannina-aek-KYWUR0FA/#1X2;2	2023-05-07 20:56:01.408778+01
272	Aris	PAOK	2022-04-17 19:30:00+01	1	0	2.65	2.87	3	3.5	1.84	0	0	0	1	4.0	3.2	2.1	3.4	{0.5,1.5,1.75,2.0,2.5,3.5,4.5,5.5,6.5}	{1.14,1.6,1.83,2.95,6.4,15.0,26.0,56.0}	{6.1,2.28,2.02,1.4,1.12,1.03,1.0,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.66,2.0,4.2,15.0,36.0,81.0}	{2.23,1.8,1.22,1.03,1.0,1.0}	{0.5,1.5,2.5,3.5}	{1.41,3.0,8.0,23.0}	{2.75,1.37,1.08,1.01}	https://www.oddsportal.com/football/greece/super-league-2021-2022/aris-paok-C8TMTMpb/#1X2;2	2023-05-07 20:57:04.878298+01
273	Lamia	Ionikos	2022-04-17 17:15:00+01	0	1	2.05	3.25	4	2.87	2.0	0	0	1	0	5.0	2.5	2.28	4.4	{0.5,1.5,2.0,2.5,3.5,4.5,5.5,6.5}	{1.1,1.44,1.77,2.38,4.7,10.5,23.0,36.0}	{8.0,2.8,2.1,1.57,1.2,1.06,1.02,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.6,1.75,3.75,11.0,29.0,67.0}	{2.55,2.05,1.29,1.05,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.62,6.5,19.0}	{3.25,1.5,1.12,1.02}	https://www.oddsportal.com/football/greece/super-league-2021-2022/lamia-ionikos-ImaGZlDl/#1X2;2	2023-05-07 20:57:37.473694+01
275	Panetolikos	Asteras Tripolis	2022-04-16 19:30:00+01	0	0	2.82	3.1	3	3.6	2.0	0	0	0	0	3.4	3.25	2.3	3.0	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.09,1.42,2.02,2.43,4.8,10.5,21.0,36.0}	{8.0,2.75,1.83,1.61,1.22,1.06,1.01,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.52,1.72,3.55,10.0,26.0,67.0}	{2.5,2.07,1.3,1.06,1.0,1.0}	{0.5,1.5,2.5,3.5}	{1.31,2.55,5.5,15.0}	{3.5,1.53,1.14,1.03}	https://www.oddsportal.com/football/greece/super-league-2021-2022/panetolikos-asteras-tripolis-ClXrhcTF/#1X2;2	2023-05-07 20:58:41.00349+01
277	AEK Athens FC	Aris	2022-04-10 19:30:00+01	1	2	1.73	3.65	5	2.4	2.05	1	0	1	1	5.5	2.08	2.37	5.25	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.09,1.42,1.75,2.02,2.43,4.8,11.0,21.0,36.0}	{9.0,2.75,2.13,1.83,1.61,1.2,1.06,1.01,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.51,1.7,3.5,10.0,26.0,67.0}	{2.55,2.1,1.3,1.06,1.0,1.0}	{0.5,1.5,2.5,3.5}	{1.3,2.6,6.0,17.0}	{3.4,1.53,1.13,1.02}	https://www.oddsportal.com/football/greece/super-league-2021-2022/aek-aris-WbLEVrGo/#1X2;2	2023-05-07 20:59:44.389693+01
279	Panetolikos	Atromitos	2022-04-09 20:30:00+01	2	3	2.1	3.1	4	2.87	1.97	1	0	2	2	4.6	2.5	2.23	4.1	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.11,1.47,1.9,2.5,5.0,11.0,26.0,41.0}	{7.5,2.7,1.95,1.55,1.17,1.05,1.01,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.55,1.82,3.75,11.0,29.0,71.0}	{2.48,1.97,1.27,1.05,1.0,1.0}	{0.5,1.5,2.5,3.5}	{1.35,2.63,6.5,19.0}	{3.25,1.44,1.11,1.02}	https://www.oddsportal.com/football/greece/super-league-2021-2022/panetolikos-atromitos-GMwzfJb3/#1X2;2	2023-05-07 21:00:52.499032+01
280	Asteras Tripolis	Ionikos	2022-04-09 19:30:00+01	2	3	1.95	3.4	4	2.7	2.0	1	1	2	1	4.8	2.38	2.3	4.3	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.09,1.42,2.05,2.35,4.6,10.0,21.0,36.0}	{7.5,2.8,1.8,1.6,1.2,1.06,1.01,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.5,1.72,3.45,10.0,26.0,67.0}	{2.5,2.07,1.3,1.06,1.0,1.0}	{0.5,1.5,2.5,3.5}	{1.31,2.5,6.0,17.0}	{3.4,1.5,1.12,1.02}	https://www.oddsportal.com/football/greece/super-league-2021-2022/asteras-tripolis-ionikos-xWvWfaqc/#1X2;2	2023-05-07 21:01:23.894914+01
282	Volos	Lamia	2022-04-09 16:00:00+01	3	0	3.9	3.4	2	4.75	2.05	0	3	0	0	2.75	4.3	2.3	2.37	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.09,1.44,1.8,2.35,4.6,11.0,23.0,36.0}	{8.0,2.8,2.05,1.6,1.2,1.06,1.01,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.53,1.77,3.5,11.0,26.0,67.0}	{2.6,2.02,1.28,1.05,1.0,1.0}	{0.5,1.5,2.5,3.5}	{1.33,2.5,6.5,19.0}	{3.25,1.5,1.12,1.02}	https://www.oddsportal.com/football/greece/super-league-2021-2022/volos-lamia-ChmpXeij/#1X2;2	2023-05-07 21:02:28.093559+01
284	Panathinaikos	PAOK	2022-04-03 19:00:00+01	2	1	2.3	2.9	4	3.1	1.9	1	1	0	1	4.5	2.7	2.1	3.75	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.12,1.53,2.02,2.7,5.5,13.0,26.0,46.0}	{6.0,2.37,1.83,1.48,1.15,1.04,1.01,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.61,1.9,4.0,13.0,29.0,71.0}	{2.25,1.9,1.26,1.04,1.0,1.0}	{0.5,1.5,2.5,3.5}	{1.38,2.75,7.0,21.0}	{3.0,1.4,1.1,1.01}	https://www.oddsportal.com/football/greece/super-league-2021-2022/panathinaikos-paok-bBj0CLFN/#1X2;2	2023-05-07 21:03:31.33006+01
286	Apollon Smyrnis	Panetolikos	2022-04-02 20:30:00+01	1	0	2.75	3.2	3	3.5	2.0	0	0	0	1	3.4	3.0	2.25	2.95	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.09,1.43,2.05,2.3,4.33,10.0,21.0,36.0}	{7.5,2.75,1.8,1.6,1.2,1.06,1.01,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.52,1.75,3.5,10.0,26.0,67.0}	{2.5,2.05,1.28,1.06,1.0,1.0}	{0.5,1.5,2.5,3.5}	{1.32,2.4,6.0,17.0}	{3.4,1.53,1.12,1.02}	https://www.oddsportal.com/football/greece/super-league-2021-2022/apollon-smyrnis-panetolikos-UTcuYyxp/#1X2;2	2023-05-07 21:04:33.628075+01
287	Ionikos	Volos	2022-04-02 18:15:00+01	2	2	2.1	3.3	4	2.8	2.2	2	1	0	1	4.0	2.45	2.5	3.7	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.07,1.33,2.0,3.4,6.5,15.0,23.0}	{10.0,3.5,1.9,1.33,1.11,1.03,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.44,1.9,2.75,8.0,21.0,51.0}	{2.75,1.9,1.4,1.08,1.02,1.0}	{0.5,1.5,2.5,3.5,4.5}	{1.3,2.25,4.5,11.0,26.0}	{4.0,1.72,1.2,1.05,1.01}	https://www.oddsportal.com/football/greece/super-league-2021-2022/ionikos-volos-SKBDxITS/#1X2;2	2023-05-07 21:05:04.600885+01
289	Lamia	OFI Crete	2022-04-02 16:00:00+01	1	2	1.83	3.4	5	2.6	2.0	1	1	1	0	5.5	2.3	2.3	4.6	{0.5,1.5,2.0,2.5,3.5,4.5,5.5,6.5}	{1.1,1.5,1.83,2.5,4.5,11.0,23.0,41.0}	{7.0,2.62,2.02,1.55,1.18,1.05,1.02,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.57,1.77,3.5,11.0,29.0,71.0}	{2.37,2.02,1.29,1.05,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.5,6.5,19.0}	{3.25,1.5,1.12,1.02}	https://www.oddsportal.com/football/greece/super-league-2021-2022/lamia-ofi-crete-Kf85vvaG/#1X2;2	2023-05-07 21:06:04.475958+01
291	Aris	Panathinaikos	2022-03-20 19:00:00+00	0	0	1.83	3.4	5	2.62	1.9	0	0	0	0	5.5	2.25	2.2	5.0	{0.5,1.5,1.75,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.12,1.53,2.05,2.7,5.5,13.0,26.0,46.0}	{6.0,2.37,1.8,1.44,1.14,1.04,1.01,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.58,1.9,4.0,13.0,31.0,81.0}	{2.25,1.9,1.24,1.04,1.0,1.0}	{0.5,1.5,2.5,3.5}	{1.37,2.75,8.0,21.0}	{3.0,1.41,1.09,1.01}	https://www.oddsportal.com/football/greece/super-league-2021-2022/aris-panathinaikos-8ITeXawD/#1X2;2	2023-05-07 21:07:18.06201+01
293	Panetolikos	Lamia	2022-03-19 19:30:00+00	1	2	2.15	3.25	4	2.87	1.95	1	1	1	0	4.75	2.4	2.2	4.1	{0.5,1.5,2.0,2.5,3.5,4.5,5.5,6.5}	{1.11,1.5,1.9,2.5,5.0,11.0,26.0,41.0}	{7.0,2.5,1.95,1.5,1.16,1.05,1.01,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.57,1.82,3.75,11.0,29.0,71.0}	{2.3,1.97,1.27,1.05,1.0,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.62,7.0,19.0}	{3.25,1.44,1.1,1.02}	https://www.oddsportal.com/football/greece/super-league-2021-2022/panetolikos-lamia-tQ6Zz1NS/#1X2;2	2023-05-07 21:08:17.319737+01
294	Atromitos	Apollon Smyrnis	2022-03-19 17:15:00+00	1	0	1.65	3.75	6	2.3	2.05	0	1	0	0	6.5	1.98	2.37	5.5	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.09,1.41,2.05,2.3,4.33,10.0,21.0,36.0}	{7.5,2.75,1.8,1.6,1.21,1.06,1.01,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.5,1.72,3.4,10.0,26.0,61.0}	{2.5,2.07,1.31,1.06,1.0,1.0}	{0.5,1.5,2.5,3.5}	{1.31,2.5,6.0,17.0}	{3.4,1.5,1.12,1.02}	https://www.oddsportal.com/football/greece/super-league-2021-2022/atromitos-apollon-smyrnis-jyEMw3wA/#1X2;2	2023-05-07 21:08:48.21015+01
296	OFI Crete	Ionikos	2022-03-19 15:00:00+00	2	3	2.2	3.2	4	2.87	2.05	0	1	3	1	4.0	2.5	2.35	3.6	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.08,1.36,1.73,1.85,2.16,3.75,9.0,19.0,31.0}	{8.0,3.0,2.15,2.0,1.72,1.25,1.08,1.02,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.46,1.72,2.05,3.25,10.0,26.0,56.0}	{2.62,2.07,1.75,1.33,1.06,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.28,2.25,5.5,15.0}	{3.5,1.57,1.15,1.03}	https://www.oddsportal.com/football/greece/super-league-2021-2022/ofi-crete-ionikos-Cj2Vys8M/#1X2;2	2023-05-07 21:09:49.882784+01
427	AEK Athens FC	Aris	2021-10-31 19:30:00+00	2	1	1.88	3.4	4	2.6	2.05	1	0	0	2	4.6	2.38	2.35	4.2	{0.5,1.5,2.25,2.5,3.5,4.5,5.5}	{1.08,1.4,2.2,4.0,8.0,17.0}	{7.5,2.75,1.63,1.22,1.07,1.02}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.53,3.25,8.5,17.0,34.0}	{2.55,1.33,1.06,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.33,2.38,5.5,14.0}	{3.25,1.53,1.14,1.02}	https://www.oddsportal.com/football/greece/super-league-2021-2022/aek-aris-dfpcxern/#1X2;2	2023-05-07 22:18:45.557009+01
299	Olympiacos Piraeus	Aris	2022-03-13 19:00:00+00	2	1	1.66	3.4	6	2.37	2.0	1	1	0	1	6.5	2.05	2.25	5.75	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.12,1.5,1.95,2.5,5.0,11.0,26.0,41.0}	{6.5,2.5,1.9,1.52,1.16,1.05,1.01,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.53,1.82,3.75,11.0,29.0,71.0}	{2.37,1.97,1.26,1.05,1.0,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.62,7.0,19.0}	{3.0,1.44,1.1,1.02}	https://www.oddsportal.com/football/greece/super-league-2021-2022/olympiacos-piraeus-aris-4KBAt5gi/#1X2;2	2023-05-07 21:11:22.326377+01
300	AEK Athens FC	Asteras Tripolis	2022-03-06 19:00:00+00	2	1	1.65	3.75	6	2.25	2.2	1	1	0	1	6.0	1.95	2.5	5.25	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.07,1.35,1.9,2.1,3.75,8.0,17.0,29.0}	{8.5,3.25,1.95,1.75,1.25,1.08,1.02,1.0}	{0.5,1.0,1.5,2.5,3.5,4.5}	{1.44,2.07,3.25,9.0,26.0,56.0}	{2.62,1.72,1.34,1.07,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.27,2.2,5.0,15.0}	{3.75,1.61,1.16,1.03}	https://www.oddsportal.com/football/greece/super-league-2021-2022/aek-asteras-tripolis-viTLHxKo/#1X2;2	2023-05-07 21:11:52.634706+01
301	Aris	Olympiacos Piraeus	2022-03-06 19:00:00+00	2	1	3.2	2.75	3	4.0	1.83	0	2	1	0	3.5	3.5	2.05	3.0	{0.5,1.5,1.75,2.0,2.5,3.5,4.5,5.5,6.5}	{1.16,1.61,1.85,3.1,6.5,15.0,26.0,51.0}	{5.0,2.2,2.0,1.43,1.13,1.03,1.0,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.66,2.0,4.33,15.0,31.0,81.0}	{2.1,1.8,1.23,1.04,1.0,1.0}	{0.5,1.5,2.5,3.5}	{1.43,3.0,8.0,23.0}	{2.75,1.36,1.08,1.01}	https://www.oddsportal.com/football/greece/super-league-2021-2022/aris-olympiacos-piraeus-IsSPGdZi/#1X2;2	2023-05-07 21:12:23.785829+01
302	Atromitos	Panathinaikos	2022-03-06 19:00:00+00	0	2	4.0	3.2	2	4.5	2.0	2	0	0	0	2.8	4.0	2.25	2.45	{0.5,1.5,2.0,2.5,3.5,4.5,5.5,6.5}	{1.1,1.44,1.8,2.36,4.5,11.0,23.0,41.0}	{7.0,2.62,2.05,1.57,1.19,1.06,1.01,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.53,1.77,3.5,11.0,26.0,67.0}	{2.37,2.02,1.28,1.05,1.0,1.0}	{0.5,1.5,2.5,3.5}	{1.33,2.5,6.0,17.0}	{3.25,1.5,1.12,1.02}	https://www.oddsportal.com/football/greece/super-league-2021-2022/atromitos-panathinaikos-nHWTFGlb/#1X2;2	2023-05-07 21:12:56.812215+01
303	Ionikos	Panetolikos	2022-03-06 19:00:00+00	1	2	2.3	3.0	4	3.1	1.95	1	1	1	0	4.33	2.62	2.2	3.6	{0.5,1.5,2.0,2.5,3.5,4.5,5.5,6.5}	{1.11,1.47,1.93,2.56,5.0,11.0,26.0,41.0}	{6.5,2.62,1.93,1.5,1.17,1.05,1.01,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.53,1.82,3.75,11.0,29.0,71.0}	{2.37,1.97,1.27,1.05,1.0,1.0}	{0.5,1.5,2.5,3.5}	{1.35,2.62,6.5,19.0}	{3.25,1.44,1.11,1.02}	https://www.oddsportal.com/football/greece/super-league-2021-2022/ionikos-panetolikos-8WKxEfJA/#1X2;2	2023-05-07 21:13:28.412364+01
305	OFI Crete	Apollon Smyrnis	2022-03-06 19:00:00+00	2	0	1.5	4.2	8	2.05	2.3	0	2	0	0	6.5	1.78	2.75	6.0	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.06,1.25,1.85,3.25,6.0,13.0,26.0}	{10.0,3.75,2.02,1.36,1.13,1.04,1.01}	{0.5,1.0,1.5,2.5,3.5,4.5}	{1.36,1.77,2.75,7.0,21.0,46.0}	{3.0,2.02,1.42,1.1,1.01,1.0}	{0.5,1.5,2.5,3.5,4.5}	{1.22,2.0,4.33,11.0,26.0}	{4.1,1.75,1.21,1.05,1.01}	https://www.oddsportal.com/football/greece/super-league-2021-2022/ofi-crete-apollon-smyrnis-6HwtDEYG/#1X2;2	2023-05-07 21:14:29.962273+01
306	Volos	Giannina	2022-03-06 19:00:00+00	0	0	3.2	3.25	3	3.7	2.05	0	0	0	0	3.5	3.4	2.3	3.0	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.08,1.36,2.0,2.25,4.0,9.0,19.0,31.0}	{8.0,3.0,1.85,1.65,1.24,1.08,1.02,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.5,1.7,3.4,10.0,23.0,56.0}	{2.6,2.1,1.34,1.07,1.0,1.0}	{0.5,1.5,2.5,3.5}	{1.29,2.3,5.5,15.0}	{3.5,1.57,1.14,1.03}	https://www.oddsportal.com/football/greece/super-league-2021-2022/volos-giannina-Q7VXEz44/#1X2;2	2023-05-07 21:14:59.982129+01
308	AEK Athens FC	PAOK	2022-03-02 20:30:00+00	1	1	2.45	3.3	4	2.88	2.02	0	0	1	1	4.75	2.6	2.33	4.1	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.09,1.41,2.1,2.35,4.33,10.0,21.0,36.0}	{9.0,3.1,1.77,1.65,1.22,1.07,1.01,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.5,1.75,2.1,3.4,10.0,26.0,61.0}	{2.7,2.05,1.7,1.31,1.06,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.31,2.5,6.0,17.0}	{3.4,1.53,1.12,1.02}	https://www.oddsportal.com/football/greece/super-league-2021-2022/aek-paok-vZByWDM5/#1X2;2	2023-05-07 21:16:03.060729+01
309	Olympiacos Piraeus	Asteras Tripolis	2022-03-02 19:00:00+00	5	1	1.42	4.33	10	1.95	2.2	1	5	0	0	9.0	1.74	2.6	8.0	{0.5,1.5,2.25,2.5,2.75,3.5,4.5,5.5,6.5}	{1.08,1.36,1.93,2.15,3.85,8.0,19.0,29.0}	{9.5,3.25,1.93,1.71,1.25,1.08,1.02,1.0}	{0.5,1.0,1.25,1.5,2.5,3.5,4.5}	{1.44,2.07,3.25,9.0,26.0,51.0}	{2.75,1.72,1.35,1.07,1.01,1.0}	{0.5,1.5,2.5,3.5,4.5}	{1.28,2.28,5.5,15.0}	{3.5,1.57,1.14,1.03}	https://www.oddsportal.com/football/greece/super-league-2021-2022/olympiacos-piraeus-asteras-tripolis-rR8hSVLU/#1X2;2	2023-05-07 21:16:35.502537+01
310	Apollon Smyrnis	Atromitos	2022-02-28 19:30:00+00	0	2	3.43	3.0	2	4.2	1.95	2	0	0	0	3.2	3.75	2.25	2.75	{0.5,1.5,2.0,2.5,3.5,4.5,5.5,6.5}	{1.1,1.44,1.88,2.5,4.9,11.0,23.0,36.0}	{7.0,2.7,1.98,1.53,1.19,1.06,1.01,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.53,1.82,3.75,11.0,29.0,67.0}	{2.4,1.97,1.27,1.05,1.0,1.0}	{0.5,1.5,2.5,3.5}	{1.33,2.6,6.5,19.0}	{3.25,1.5,1.12,1.02}	https://www.oddsportal.com/football/greece/super-league-2021-2022/apollon-smyrnis-atromitos-Empb2cKb/#1X2;2	2023-05-07 21:17:06.430944+01
312	Olympiacos Piraeus	OFI Crete	2022-02-27 19:30:00+00	2	0	1.3	5.6	13	1.76	2.5	0	1	0	1	9.5	1.6	3.1	8.75	{0.5,1.5,2.5,2.75,3.5,4.5,5.5,6.5}	{1.05,1.24,1.82,1.98,3.25,6.4,11.0,23.0}	{12.0,4.0,2.07,1.88,1.4,1.15,1.05,1.01}	{0.5,1.0,1.5,2.5,3.5,4.5}	{1.34,1.7,2.7,7.0,19.0,41.0}	{3.25,2.1,1.46,1.11,1.02,1.0}	{0.5,1.5,2.5,3.5,4.5}	{1.2,1.9,4.0,11.0,26.0}	{4.33,1.8,1.22,1.06,1.01}	https://www.oddsportal.com/football/greece/super-league-2021-2022/olympiacos-piraeus-ofi-crete-n1r60ykB/#1X2;2	2023-05-07 21:18:07.858977+01
313	Panathinaikos	AEK Athens FC	2022-02-27 19:30:00+00	3	0	2.35	3.1	3	3.1	1.98	0	0	0	3	4.0	2.75	2.28	3.45	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.1,1.44,1.8,2.05,2.35,4.5,11.0,23.0,36.0}	{8.0,2.88,2.05,1.8,1.62,1.19,1.06,1.01,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.53,1.77,3.5,11.0,26.0,61.0}	{2.55,2.02,1.3,1.06,1.0,1.0}	{0.5,1.5,2.5,3.5}	{1.33,2.5,6.0,17.0}	{3.25,1.5,1.12,1.02}	https://www.oddsportal.com/football/greece/super-league-2021-2022/panathinaikos-aek-SCa3ae4H/#1X2;2	2023-05-07 21:18:39.133335+01
315	Panetolikos	Volos	2022-02-26 19:30:00+00	0	0	2.05	3.4	4	2.75	2.15	0	0	0	0	4.33	2.38	2.48	4.0	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.07,1.34,1.88,2.1,3.75,8.0,17.0,29.0}	{10.5,3.6,1.98,1.84,1.29,1.1,1.02,1.0}	{0.5,1.0,1.5,2.5,3.5,4.5}	{1.44,2.07,3.25,9.0,26.0,51.0}	{2.95,1.72,1.37,1.07,1.01,1.0}	{0.5,1.5,2.5,3.5,4.5}	{1.27,2.2,5.0,15.0}	{3.75,1.64,1.16,1.03}	https://www.oddsportal.com/football/greece/super-league-2021-2022/panetolikos-volos-63b7bFJN/#1X2;2	2023-05-07 21:19:41.083196+01
316	Asteras Tripolis	Aris	2022-02-26 17:15:00+00	0	2	3.05	2.87	3	4.0	1.8	1	0	1	0	4.0	3.65	2.0	3.3	{0.5,1.5,1.75,2.0,2.5,3.5,4.5,5.5,6.5}	{1.16,1.72,2.05,3.5,7.5,19.0,34.0,67.0}	{5.3,2.1,1.8,1.34,1.1,1.02,1.0,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.77,4.7,17.0,41.0,101.0}	{2.06,1.18,1.02,1.0,1.0}	{0.5,1.5,2.5,3.5}	{1.49,3.25,9.0,26.0}	{2.62,1.38,1.07,1.01}	https://www.oddsportal.com/football/greece/super-league-2021-2022/asteras-tripolis-aris-8Aq21HZ4/#1X2;2	2023-05-07 21:20:12.538197+01
319	Lamia	Asteras Tripolis	2022-02-23 17:30:00+00	0	2	3.2	3.0	3	4.0	1.9	0	0	2	0	3.4	3.4	2.2	3.05	{0.5,1.5,2.0,2.5,3.5,4.5,5.5,6.5}	{1.11,1.51,2.0,2.6,5.5,13.0,26.0,46.0}	{6.75,2.55,1.85,1.47,1.15,1.04,1.01,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.57,1.87,3.75,13.0,29.0,71.0}	{2.35,1.92,1.25,1.04,1.0,1.0}	{0.5,1.5,2.5,3.5}	{1.37,2.65,7.0,19.0}	{3.0,1.44,1.1,1.02}	https://www.oddsportal.com/football/greece/super-league-2021-2022/lamia-asteras-tripolis-pd8lnoU0/#1X2;2	2023-05-07 21:21:46.435318+01
321	Aris	PAOK	2022-02-20 19:30:00+00	0	0	2.85	2.87	3	3.7	1.85	0	0	0	0	4.0	3.3	2.15	3.25	{0.5,1.5,1.75,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.14,1.61,1.85,2.87,6.5,17.0,21.0,46.0}	{6.4,2.45,2.0,1.46,1.16,1.04,1.0,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.66,2.0,4.33,15.0,29.0,71.0}	{2.28,1.8,1.26,1.04,1.0,1.0}	{0.5,1.5,2.5,3.5}	{1.4,3.0,8.0,23.0}	{2.85,1.42,1.1,1.01}	https://www.oddsportal.com/football/greece/super-league-2021-2022/aris-paok-KjrRa4b0/#1X2;2	2023-05-07 21:22:47.991882+01
322	Volos	Olympiacos Piraeus	2022-02-20 17:15:00+00	0	1	6.02	3.95	2	5.6	2.3	1	0	0	0	2.25	5.5	2.65	1.98	{0.5,1.5,2.5,2.75,3.5,4.5,5.5,6.5}	{1.06,1.31,2.02,3.35,6.75,15.0,26.0}	{11.5,3.7,1.87,1.33,1.11,1.03,1.0}	{0.5,1.0,1.25,1.5,2.5,3.5,4.5}	{1.41,1.95,2.8,8.0,21.0,51.0}	{3.05,1.85,1.4,1.08,1.01,1.0}	{0.5,1.5,2.5,3.5,4.5}	{1.25,2.1,4.5,11.0}	{4.0,1.72,1.18,1.05}	https://www.oddsportal.com/football/greece/super-league-2021-2022/volos-olympiacos-piraeus-EkyzbrTC/#1X2;2	2023-05-07 21:23:18.843976+01
324	Atromitos	Asteras Tripolis	2022-02-19 19:30:00+00	2	0	2.3	3.1	4	3.0	1.95	0	1	0	1	4.33	2.65	2.2	3.85	{0.5,1.5,2.0,2.5,3.5,4.5,5.5,6.5}	{1.1,1.47,1.85,2.6,5.25,12.0,23.0,41.0}	{7.0,2.62,2.0,1.53,1.19,1.06,1.01,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.55,1.8,3.75,11.0,29.0,67.0}	{2.38,2.0,1.27,1.05,1.0,1.0}	{0.5,1.5,2.5,3.5}	{1.33,2.7,6.5,19.0}	{3.25,1.5,1.12,1.02}	https://www.oddsportal.com/football/greece/super-league-2021-2022/atromitos-asteras-tripolis-WQoVbOD6/#1X2;2	2023-05-07 21:24:22.610182+01
326	Ionikos	OFI Crete	2022-02-19 17:15:00+00	0	0	2.8	2.9	3	3.5	1.95	0	0	0	0	3.75	3.1	2.2	3.2	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.11,1.44,1.85,2.4,5.0,11.0,23.0,36.0}	{7.0,2.7,2.0,1.55,1.2,1.06,1.01,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.53,1.8,3.75,11.0,26.0,61.0}	{2.43,2.0,1.29,1.06,1.0,1.0}	{0.5,1.5,2.5,3.5}	{1.33,2.5,6.5,19.0}	{3.25,1.5,1.12,1.02}	https://www.oddsportal.com/football/greece/super-league-2021-2022/ionikos-ofi-crete-htzvc2rJ/#1X2;2	2023-05-07 21:25:25.71973+01
328	Atromitos	OFI Crete	2022-02-16 18:00:00+00	2	2	2.48	3.4	3	3.2	2.05	2	0	0	2	3.75	2.9	2.37	3.4	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.08,1.37,1.93,2.15,4.0,9.0,19.0,31.0}	{8.5,3.05,1.93,1.66,1.24,1.08,1.02,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.46,2.1,3.25,10.0,26.0,56.0}	{2.65,1.7,1.34,1.07,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.28,2.25,5.5,15.0}	{3.5,1.57,1.14,1.03}	https://www.oddsportal.com/football/greece/super-league-2021-2022/atromitos-ofi-crete-hbT9gTyR/#1X2;2	2023-05-07 21:26:29.754542+01
329	Panetolikos	Lamia	2022-02-16 16:00:00+00	1	0	2.1	3.25	5	3.0	1.95	0	1	0	0	5.0	2.62	2.2	4.5	{0.5,1.5,2.0,2.5,3.5,4.5,5.5,6.5}	{1.12,1.53,2.05,2.7,5.5,13.0,26.0,46.0}	{7.0,2.45,1.8,1.5,1.15,1.04,1.01,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.61,1.9,4.0,13.0,31.0,71.0}	{2.38,1.9,1.28,1.05,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.4,2.75,7.0,21.0}	{3.0,1.44,1.1,1.01}	https://www.oddsportal.com/football/greece/super-league-2021-2022/panetolikos-lamia-l8L0WsYo/#1X2;2	2023-05-07 21:27:01.77259+01
331	Olympiacos Piraeus	AEK Athens FC	2022-02-13 19:30:00+00	1	0	1.9	3.3	5	2.62	2.05	0	1	0	0	4.75	2.28	2.32	4.4	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.08,1.4,2.05,2.3,4.5,10.0,21.0,34.0}	{8.5,3.0,1.8,1.61,1.22,1.07,1.02,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.53,1.72,3.4,10.0,26.0,61.0}	{2.6,2.07,1.36,1.06,1.01,1.0}	{0.5,1.5,2.5,3.5,4.5}	{1.36,2.48,6.0,17.0}	{3.4,1.53,1.13,1.02}	https://www.oddsportal.com/football/greece/super-league-2021-2022/olympiacos-piraeus-aek-YV3r8SjK/#1X2;2	2023-05-07 21:28:06.746787+01
333	Panathinaikos	Lamia	2022-02-13 15:30:00+00	2	0	1.47	4.05	10	2.05	2.12	0	1	0	1	8.5	1.81	2.5	7.5	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.1,1.44,1.83,2.1,2.4,4.5,11.0,23.0,34.0}	{8.0,2.88,2.02,1.77,1.63,1.23,1.07,1.02,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.5,1.77,2.1,3.5,11.0,26.0,61.0}	{2.6,2.02,1.7,1.28,1.06,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.33,2.5,6.5,19.0}	{3.3,1.53,1.13,1.03}	https://www.oddsportal.com/football/greece/super-league-2021-2022/panathinaikos-lamia-U1kE26Es/#1X2;2	2023-05-07 21:29:09.265696+01
335	Apollon Smyrnis	Panetolikos	2022-02-12 19:30:00+00	0	0	3.0	2.95	3	4.2	1.9	0	0	0	0	3.6	3.45	2.15	3.1	{0.5,1.5,2.0,2.5,3.5,4.5,5.5,6.5}	{1.12,1.6,2.1,2.75,5.75,13.0,21.0,46.0}	{6.5,2.43,1.77,1.47,1.16,1.05,1.01,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.66,1.95,4.0,13.0,29.0,71.0}	{2.3,1.85,1.26,1.05,1.0,1.0}	{0.5,1.5,2.5,3.5}	{1.4,2.85,7.0,21.0}	{3.0,1.42,1.1,1.01}	https://www.oddsportal.com/football/greece/super-league-2021-2022/apollon-smyrnis-panetolikos-INLepPbD/#1X2;2	2023-05-07 21:30:12.095208+01
336	Asteras Tripolis	Ionikos	2022-02-12 19:30:00+00	2	3	1.61	3.6	7	2.4	2.07	3	1	0	1	7.0	2.05	2.33	6.0	{0.5,1.5,2.0,2.5,3.5,4.5,5.5,6.5}	{1.11,1.53,1.9,2.62,5.3,13.0,26.0,41.0}	{7.5,2.6,1.95,1.5,1.16,1.05,1.01,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.66,1.8,3.75,11.0,29.0,71.0}	{2.48,2.0,1.26,1.05,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.4,2.75,7.0,19.0}	{3.0,1.44,1.1,1.02}	https://www.oddsportal.com/football/greece/super-league-2021-2022/asteras-tripolis-ionikos-KSav98yE/#1X2;2	2023-05-07 21:30:43.95218+01
338	PAOK	Panathinaikos	2022-02-06 19:30:00+00	2	1	1.85	3.2	5	2.6	2.0	0	2	1	0	5.4	2.2	2.28	4.9	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.1,1.44,1.9,2.5,4.7,11.0,23.0,36.0}	{8.0,2.8,1.95,1.55,1.2,1.06,1.01,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.53,1.82,3.5,11.0,26.0,61.0}	{2.5,1.97,1.29,1.06,1.0,1.0}	{0.5,1.5,2.5,3.5}	{1.33,2.55,6.0,17.0}	{3.25,1.5,1.12,1.02}	https://www.oddsportal.com/football/greece/super-league-2021-2022/paok-panathinaikos-659pmREf/#1X2;2	2023-05-07 21:31:46.596089+01
499	Panetolikos	Atromitos	2021-05-08 19:30:00+01	1	3	2.1	3.0	4	3.0	1.9	1	1	2	0	5.1	2.5	2.2	4.6	{0.5,1.5,2.0,2.5,3.5,4.5,5.5}	{1.12,1.55,2.02,2.75,5.75,13.0,26.0}	{6.25,2.38,1.83,1.47,1.15,1.04,1.01}	{0.5,0.75,1.5,2.5,3.5}	{1.61,1.9,3.95,13.0,11.0}	{2.25,1.9,1.25,1.04,1.01}	{0.5,1.5,2.5,3.5}	{1.4,2.75,7.0,21.0}	{3.0,1.44,1.1,1.01}	https://www.oddsportal.com/football/greece/super-league-2020-2021/panetolikos-atromitos-xKzoX1hn/#1X2;2	2023-05-07 22:56:26.488538+01
340	AEK Athens FC	Apollon Smyrnis	2022-02-06 15:00:00+00	3	0	1.35	5.0	11	1.83	2.48	0	3	0	0	8.5	1.61	2.9	8.0	{0.5,1.5,2.5,3.5,4.5,5.5,6.5}	{1.06,1.26,1.88,3.3,6.5,13.0,26.0}	{12.0,3.75,1.98,1.35,1.13,1.04,1.01}	{0.5,1.0,1.5,2.5,3.5,4.5}	{1.36,1.8,2.75,7.0,21.0,46.0}	{3.1,2.0,1.43,1.1,1.01,1.0}	{0.5,1.5,2.5,3.5,4.5}	{1.22,2.1,4.33,11.0,26.0}	{4.0,1.72,1.2,1.05,1.01}	https://www.oddsportal.com/football/greece/super-league-2021-2022/aek-apollon-smyrnis-dWZ0ek7E/#1X2;2	2023-05-07 21:32:57.938739+01
341	Aris	Volos	2022-02-05 19:30:00+00	0	2	1.49	4.5	8	2.05	2.25	2	0	0	0	7.0	1.83	2.6	6.5	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.06,1.32,2.02,3.55,7.5,17.0,26.0}	{10.5,3.45,1.83,1.28,1.1,1.03,1.0}	{0.5,1.0,1.5,2.5,3.5,4.5}	{1.41,1.95,3.0,8.0,23.0,51.0}	{2.88,1.85,1.37,1.08,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.25,2.2,5.0,13.0}	{3.75,1.61,1.16,1.04}	https://www.oddsportal.com/football/greece/super-league-2021-2022/aris-volos-E7U5f9MK/#1X2;2	2023-05-07 21:33:28.487578+01
342	Panetolikos	Giannina	2022-02-05 19:30:00+00	0	1	2.65	3.1	3	3.3	1.96	1	0	0	0	4.0	2.95	2.25	3.4	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.1,1.44,1.8,2.4,4.5,11.0,23.0,36.0}	{8.0,2.85,2.05,1.57,1.2,1.06,1.01,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.53,1.77,3.5,11.0,26.0,61.0}	{2.55,2.02,1.3,1.06,1.0,1.0}	{0.5,1.5,2.5,3.5}	{1.33,2.5,6.0,17.0}	{3.25,1.5,1.12,1.02}	https://www.oddsportal.com/football/greece/super-league-2021-2022/panetolikos-giannina-OtKul7al/#1X2;2	2023-05-07 21:34:00.95954+01
343	Apollon Smyrnis	PAOK	2022-02-02 21:30:00+00	0	2	8.0	4.1	2	7.5	2.16	1	0	1	0	2.1	6.75	2.55	1.83	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.08,1.4,1.98,2.2,4.1,9.0,19.0,31.0}	{9.0,3.1,1.88,1.7,1.25,1.08,1.02,1.0}	{0.5,1.0,1.5,2.5,3.5,4.5}	{1.5,2.1,3.25,10.0,26.0,56.0}	{2.7,1.7,1.33,1.07,1.02,1.0}	{0.5,1.5,2.5,3.5}	{1.33,2.38,5.5,15.0}	{3.5,1.53,1.14,1.03}	https://www.oddsportal.com/football/greece/super-league-2021-2022/apollon-smyrnis-paok-044WuA7R/#1X2;2	2023-05-07 21:34:33.537656+01
344	Aris	AEK Athens FC	2022-02-02 19:30:00+00	2	1	2.5	2.9	3	3.4	1.85	1	1	0	1	4.33	3.0	2.1	3.7	{0.5,1.5,1.75,2.0,2.5,3.5,4.5,5.5,6.5}	{1.14,1.67,1.77,2.94,6.25,15.0,29.0,56.0}	{6.25,2.3,2.1,1.4,1.12,1.03,1.01,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.67,1.95,4.1,13.0,36.0,91.0}	{2.23,1.85,1.22,1.04,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.44,3.0,8.0,21.0}	{2.8,1.4,1.08,1.02}	https://www.oddsportal.com/football/greece/super-league-2021-2022/aris-aek-2DjbyUFr/#1X2;2	2023-05-07 21:35:05.730504+01
345	Volos	Ionikos	2022-02-02 19:30:00+00	1	1	2.15	3.4	4	2.87	2.08	1	0	0	1	4.6	2.5	2.38	4.1	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.07,1.36,1.9,2.1,3.9,8.0,19.0,31.0}	{9.5,3.2,1.95,1.7,1.25,1.08,1.02,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.53,2.07,3.25,9.0,26.0,56.0}	{2.75,1.72,1.35,1.07,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.33,2.3,5.5,15.0}	{3.5,1.57,1.15,1.03}	https://www.oddsportal.com/football/greece/super-league-2021-2022/volos-ionikos-h2qBYRa1/#1X2;2	2023-05-07 21:35:37.954063+01
347	Olympiacos Piraeus	Panetolikos	2022-02-02 17:15:00+00	3	1	1.35	5.25	9	1.85	2.5	0	1	1	2	7.5	1.7	2.87	7.0	{0.5,1.5,2.5,2.75,3.5,4.5,5.5,6.5}	{1.05,1.25,1.73,1.98,2.75,5.5,11.0,23.0}	{13.0,4.0,2.11,1.88,1.4,1.15,1.05,1.01}	{0.5,1.0,1.25,1.5,2.5,3.5,4.5}	{1.36,1.7,2.62,6.5,19.0,41.0}	{3.25,2.1,1.5,1.12,1.02,1.01}	{0.5,1.5,2.5,3.5,4.5}	{1.25,2.0,4.33,11.0,26.0}	{4.33,1.8,1.22,1.05,1.01}	https://www.oddsportal.com/football/greece/super-league-2021-2022/olympiacos-piraeus-panetolikos-4xmFXoF7/#1X2;2	2023-05-07 21:36:42.996801+01
348	Asteras Tripolis	Giannina	2022-02-02 15:00:00+00	2	0	1.9	3.2	6	2.65	1.95	0	0	0	2	6.0	2.38	2.23	5.5	{0.5,1.5,1.75,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.14,1.61,1.85,2.13,2.87,6.0,15.0,26.0,51.0}	{7.5,2.6,2.0,1.75,1.48,1.15,1.04,1.01,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.61,2.0,4.0,13.0,31.0,81.0}	{2.43,1.8,1.25,1.04,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.44,3.0,8.0,23.0}	{2.75,1.41,1.08,1.01}	https://www.oddsportal.com/football/greece/super-league-2021-2022/asteras-tripolis-giannina-Wne2zlVl/#1X2;2	2023-05-07 21:37:15.50915+01
349	PAOK	Olympiacos Piraeus	2022-01-30 19:30:00+00	1	1	2.6	3.05	3	3.5	1.91	0	0	1	1	4.0	3.2	2.1	3.4	{0.5,1.5,1.75,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.14,1.61,1.93,3.1,6.5,17.0,26.0,51.0}	{6.5,2.28,1.93,1.42,1.14,1.04,1.01,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.66,2.05,4.33,15.0,31.0,81.0}	{2.28,1.75,1.23,1.04,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.44,3.0,9.0,23.0}	{2.75,1.38,1.08,1.01}	https://www.oddsportal.com/football/greece/super-league-2021-2022/paok-olympiacos-piraeus-4xBNsWxF/#1X2;2	2023-05-07 21:37:48.422079+01
350	AEK Athens FC	Volos	2022-01-30 17:15:00+00	1	2	1.31	5.75	11	1.8	2.65	1	0	1	1	8.5	1.57	3.1	7.5	{0.5,1.5,2.5,2.75,3.0,3.5,4.5,5.5,6.5}	{1.04,1.22,1.7,1.88,2.05,2.7,5.0,10.0,21.0}	{16.0,4.7,2.23,1.98,1.8,1.49,1.19,1.07,1.02}	{0.5,1.0,1.25,1.5,2.5,3.5,4.5}	{1.33,2.07,2.5,6.0,17.0,34.0}	{3.6,1.72,1.57,1.14,1.03,1.01}	{0.5,1.5,2.5,3.5,4.5}	{1.22,1.91,4.0,10.0,23.0}	{4.6,1.88,1.26,1.07,1.01}	https://www.oddsportal.com/football/greece/super-league-2021-2022/aek-volos-bJ8WMU0k/#1X2;2	2023-05-07 21:38:20.250494+01
351	Giannina	Apollon Smyrnis	2022-01-30 15:00:00+00	2	0	1.7	3.75	7	2.38	2.04	0	1	0	1	7.5	2.12	2.35	6.5	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.11,1.5,1.9,2.2,2.5,5.0,11.0,26.0,41.0}	{8.5,2.88,1.95,1.7,1.58,1.19,1.05,1.01,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.57,1.8,3.75,11.0,26.0,67.0}	{2.6,2.0,1.28,1.05,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.4,2.62,7.0,19.0}	{3.25,1.47,1.11,1.02}	https://www.oddsportal.com/football/greece/super-league-2021-2022/giannina-apollon-smyrnis-ht8zMlGe/#1X2;2	2023-05-07 21:38:52.290354+01
352	Panetolikos	Aris	2022-01-30 15:00:00+00	0	2	4.75	3.05	2	5.5	1.85	0	0	2	0	3.0	4.8	2.06	2.62	{0.5,1.5,1.75,2.0,2.5,3.5,4.5,5.5,6.5}	{1.17,1.7,2.0,3.4,7.0,19.0,31.0,61.0}	{6.0,2.17,1.85,1.35,1.1,1.02,1.01,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.72,2.05,4.5,17.0,41.0,91.0}	{2.18,1.75,1.2,1.03,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.53,3.25,10.0,26.0}	{2.65,1.42,1.06,1.01}	https://www.oddsportal.com/football/greece/super-league-2021-2022/panetolikos-aris-AFBJrCN8/#1X2;2	2023-05-07 21:39:24.782014+01
354	Lamia	OFI Crete	2022-01-29 15:00:00+00	2	1	2.65	2.87	3	3.5	1.83	0	2	1	0	4.2	3.1	2.1	3.7	{0.5,1.5,1.75,2.0,2.5,3.5,4.5,5.5,6.5}	{1.15,1.67,1.85,3.05,6.5,15.0,26.0,51.0}	{5.5,2.2,2.0,1.4,1.12,1.03,1.01,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.73,2.0,4.33,15.0,34.0,81.0}	{2.1,1.8,1.22,1.03,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.44,3.0,8.0,23.0}	{2.75,1.36,1.08,1.02}	https://www.oddsportal.com/football/greece/super-league-2021-2022/lamia-ofi-crete-IuFRtjhL/#1X2;2	2023-05-07 21:40:30.237473+01
356	Asteras Tripolis	Apollon Smyrnis	2022-01-24 19:30:00+00	1	0	1.46	4.33	9	2.05	2.2	0	1	0	0	8.0	1.85	2.5	7.5	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.08,1.38,1.95,2.32,4.6,10.0,19.0,31.0}	{8.5,3.0,1.9,1.66,1.25,1.07,1.02,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.53,1.7,2.1,3.4,9.0,26.0,61.0}	{2.63,2.1,1.7,1.33,1.07,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.33,2.55,5.5,15.0}	{3.5,1.53,1.14,1.03}	https://www.oddsportal.com/football/greece/super-league-2021-2022/asteras-tripolis-apollon-smyrnis-C8HuXEOd/#1X2;2	2023-05-07 21:41:34.538305+01
357	Olympiacos Piraeus	Giannina	2022-01-23 19:30:00+00	2	0	1.33	5.5	11	1.83	2.55	0	1	0	1	9.0	1.61	3.1	8.5	{0.5,1.5,2.25,2.5,2.75,3.5,4.5,5.5,6.5}	{1.05,1.28,1.9,3.25,6.0,13.0,26.0}	{14.0,4.1,2.02,1.37,1.14,1.05,1.01}	{0.5,1.0,1.25,1.5,2.5,3.5,4.5}	{1.4,1.82,2.75,7.0,21.0,41.0}	{3.25,1.97,1.46,1.1,1.01,1.01}	{0.5,1.5,2.5,3.5,4.5}	{1.28,2.1,4.5,11.0}	{4.1,1.76,1.21,1.05}	https://www.oddsportal.com/football/greece/super-league-2021-2022/olympiacos-piraeus-giannina-vZRaSjwS/#1X2;2	2023-05-07 21:42:11.073397+01
358	Atromitos	AEK Athens FC	2022-01-23 17:15:00+00	0	2	4.8	3.5	2	5.0	2.2	1	0	1	0	2.5	4.6	2.5	2.15	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.07,1.36,1.8,2.05,3.75,8.0,17.0,26.0}	{9.5,3.4,2.05,1.88,1.3,1.1,1.03,1.0}	{0.5,1.0,1.5,2.5,3.5,4.5}	{1.5,1.9,3.05,8.0,23.0,51.0}	{2.75,1.9,1.38,1.08,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.33,2.3,5.0,13.0}	{3.75,1.65,1.18,1.04}	https://www.oddsportal.com/football/greece/super-league-2021-2022/atromitos-aek-AgzqWYw3/#1X2;2	2023-05-07 21:42:46.280568+01
359	Volos	PAOK	2022-01-23 17:15:00+00	0	4	4.75	3.75	2	4.8	2.2	2	0	2	0	2.5	4.4	2.55	2.15	{0.5,1.5,2.5,3.5,4.5,5.5,6.5}	{1.05,1.28,1.88,3.25,6.0,13.0,26.0}	{12.0,3.95,1.98,1.36,1.13,1.04,1.01}	{0.5,1.0,1.5,2.5,3.5,4.5}	{1.44,1.82,2.75,7.0,21.0,46.0}	{3.1,1.97,1.43,1.1,1.01,1.01}	{0.5,1.5,2.5,3.5,4.5}	{1.28,2.1,4.33,11.0,26.0}	{4.0,1.72,1.2,1.05,1.01}	https://www.oddsportal.com/football/greece/super-league-2021-2022/volos-paok-hIPmVhg9/#1X2;2	2023-05-07 21:43:17.436483+01
361	Ionikos	Panathinaikos	2022-01-22 19:30:00+00	0	1	5.25	3.7	2	6.0	2.14	0	0	1	0	2.45	5.5	2.38	2.1	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.1,1.46,2.0,2.37,4.6,10.0,21.0,41.0}	{9.0,2.85,1.85,1.65,1.22,1.06,1.01,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.53,1.7,3.4,10.0,26.0,67.0}	{2.7,2.1,1.33,1.06,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.62,6.0,17.0}	{3.4,1.5,1.12,1.02}	https://www.oddsportal.com/football/greece/super-league-2021-2022/ionikos-panathinaikos-0rTeTWNL/#1X2;2	2023-05-07 21:44:20.262367+01
362	OFI Crete	Panetolikos	2022-01-22 17:15:00+00	2	4	1.87	3.6	4	2.75	2.05	2	1	2	1	4.9	2.3	2.37	4.5	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.08,1.4,1.88,2.23,4.25,9.0,19.0,36.0}	{8.5,3.0,1.98,1.7,1.25,1.08,1.02,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.53,2.07,3.3,10.0,26.0,61.0}	{2.62,1.72,1.33,1.06,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.33,2.38,5.5,15.0}	{3.5,1.53,1.14,1.03}	https://www.oddsportal.com/football/greece/super-league-2021-2022/ofi-crete-panetolikos-pG4SNAoq/#1X2;2	2023-05-07 21:44:51.487534+01
363	Volos	Apollon Smyrnis	2022-01-19 15:00:00+00	1	0	1.7	3.7	6	2.37	2.2	0	0	0	1	5.5	2.0	2.5	5.0	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.07,1.36,2.05,3.55,7.5,15.0,29.0}	{10.0,3.45,1.8,1.28,1.1,1.03,1.0}	{0.5,1.0,1.5,2.5,3.5,4.5}	{1.5,2.0,3.0,8.0,23.0,51.0}	{2.88,1.8,1.36,1.08,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.3,2.25,5.0,13.0}	{3.75,1.66,1.16,1.04}	https://www.oddsportal.com/football/greece/super-league-2021-2022/volos-apollon-smyrnis-8EJkMxgs/#1X2;2	2023-05-07 21:45:23.476135+01
365	Panathinaikos	Olympiacos Piraeus	2022-01-16 19:30:00+00	0	0	3.1	3.2	2	3.75	1.95	0	0	0	0	3.25	3.25	2.25	2.88	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.1,1.44,2.15,2.4,4.5,11.0,23.0,34.0}	{7.0,2.7,1.73,1.6,1.22,1.07,1.02,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.53,1.77,3.5,11.0,23.0,61.0}	{2.5,2.02,1.33,1.06,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.5,6.5,19.0}	{3.25,1.53,1.13,1.02}	https://www.oddsportal.com/football/greece/super-league-2021-2022/panathinaikos-olympiacos-piraeus-QDCLRJnH/#1X2;2	2023-05-07 21:46:26.667026+01
366	AEK Athens FC	Panetolikos	2022-01-16 17:15:00+00	1	2	1.36	5.5	10	1.83	2.55	2	0	0	1	7.5	1.61	3.0	7.25	{0.5,1.5,2.5,2.75,3.5,4.5,5.5,6.5}	{1.04,1.25,1.8,2.05,2.75,5.5,11.0,23.0}	{13.0,4.0,2.11,1.8,1.41,1.16,1.05,1.01}	{0.5,1.0,1.25,1.5,2.5,3.5,4.5}	{1.36,1.75,2.1,2.62,6.5,19.0,41.0}	{3.25,2.05,1.7,1.5,1.12,1.02,1.0}	{0.5,1.5,2.5,3.5,4.5}	{1.25,2.05,4.33,11.0,26.0}	{4.33,1.8,1.23,1.06,1.01}	https://www.oddsportal.com/football/greece/super-league-2021-2022/aek-panetolikos-dYK4V1mh/#1X2;2	2023-05-07 21:46:58.412351+01
368	PAOK	OFI Crete	2022-01-15 19:30:00+00	3	0	1.53	4.5	7	2.1	2.3	0	3	0	0	6.5	1.8	2.7	6.0	{0.5,1.5,2.5,3.5,4.5,5.5,6.5}	{1.05,1.3,1.88,3.25,6.0,13.0,26.0}	{12.0,3.75,1.98,1.33,1.12,1.04,1.01}	{0.5,1.0,1.5,2.5,3.5,4.5}	{1.4,1.82,2.75,7.0,21.0,46.0}	{3.0,1.97,1.41,1.1,1.01,1.01}	{0.5,1.5,2.5,3.5}	{1.28,2.1,4.5,11.0}	{4.0,1.68,1.2,1.05}	https://www.oddsportal.com/football/greece/super-league-2021-2022/paok-ofi-crete-2wzkAiHq/#1X2;2	2023-05-07 21:48:00.499905+01
370	Lamia	Ionikos	2022-01-15 17:15:00+00	2	1	2.15	3.1	4	2.9	1.9	1	1	0	1	5.0	2.6	2.15	4.0	{0.5,1.5,1.75,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.12,1.57,1.8,2.1,2.87,6.0,15.0,26.0,46.0}	{6.0,2.38,2.05,1.77,1.5,1.15,1.04,1.01,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.62,1.97,4.0,13.0,31.0,81.0}	{2.2,1.82,1.25,1.05,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.4,2.75,8.0,21.0}	{2.8,1.4,1.1,1.02}	https://www.oddsportal.com/football/greece/super-league-2021-2022/lamia-ionikos-KEUg9BWk/#1X2;2	2023-05-07 21:49:04.975211+01
371	Apollon Smyrnis	OFI Crete	2022-01-12 17:15:00+00	0	3	3.45	3.0	3	4.3	1.9	1	0	2	0	3.5	3.9	2.1	3.0	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.13,1.57,2.1,2.75,5.6,13.0,26.0,51.0}	{6.25,2.4,1.77,1.44,1.14,1.04,1.01,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.62,1.95,4.0,13.0,34.0,81.0}	{2.25,1.85,1.25,1.04,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.4,2.8,8.0,21.0}	{3.0,1.4,1.1,1.02}	https://www.oddsportal.com/football/greece/super-league-2021-2022/apollon-smyrnis-ofi-crete-hrXphbv1/#1X2;2	2023-05-07 21:49:37.320334+01
373	Volos	Panathinaikos	2022-01-09 17:15:00+00	3	1	5.0	3.5	2	5.5	2.1	1	2	0	1	2.75	4.5	2.37	2.25	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.08,1.4,1.95,2.23,4.3,9.0,19.0,31.0}	{8.5,3.0,1.9,1.66,1.23,1.07,1.02,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.5,2.1,3.3,10.0,26.0,56.0}	{2.62,1.7,1.33,1.07,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.33,2.43,5.5,15.0}	{3.5,1.57,1.14,1.03}	https://www.oddsportal.com/football/greece/super-league-2021-2022/volos-panathinaikos-z15pUiiI/#1X2;2	2023-05-07 21:50:41.6086+01
376	Apollon Smyrnis	Olympiacos Piraeus	2022-01-05 19:30:00+00	0	0	16.5	6.0	1	13.0	2.4	0	0	0	0	1.72	12.0	2.95	1.55	{0.5,1.5,2.25,2.5,2.75,3.5,4.5,5.5,6.5}	{1.06,1.33,1.77,2.0,3.6,7.5,15.0,26.0}	{10.5,3.5,2.1,1.85,1.3,1.11,1.03,1.0}	{0.5,1.0,1.5,2.5,3.5,4.5}	{1.44,1.9,2.9,8.0,21.0,51.0}	{2.9,1.9,1.4,1.1,1.02,1.01}	{0.5,1.5,2.5,3.5,4.5}	{1.3,2.3,4.75,13.0}	{3.75,1.66,1.18,1.04}	https://www.oddsportal.com/football/greece/super-league-2021-2022/apollon-smyrnis-olympiacos-piraeus-McuBFhxP/#1X2;2	2023-05-07 21:52:19.408222+01
377	Lamia	AEK Athens FC	2022-01-05 17:15:00+00	0	2	5.1	3.4	2	5.5	2.05	1	0	1	0	2.5	4.9	2.38	2.2	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.08,1.4,2.02,2.25,4.33,10.0,21.0,31.0}	{8.5,3.05,1.83,1.64,1.23,1.07,1.02,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.53,1.7,3.4,10.0,23.0,61.0}	{2.63,2.1,1.33,1.06,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.33,2.37,6.0,17.0}	{3.4,1.53,1.14,1.03}	https://www.oddsportal.com/football/greece/super-league-2021-2022/lamia-aek-0rDXWg7a/#1X2;2	2023-05-07 21:52:50.722953+01
378	Asteras Tripolis	OFI Crete	2022-01-04 19:30:00+00	1	0	1.8	3.4	5	2.5	2.0	0	0	0	1	5.5	2.3	2.3	4.9	{0.5,1.5,2.0,2.5,3.5,4.5,5.5,6.5}	{1.11,1.5,1.8,2.5,4.8,10.5,21.0,36.0}	{7.5,2.7,2.05,1.57,1.2,1.06,1.02,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.57,1.77,3.55,11.0,26.0,61.0}	{2.5,2.02,1.3,1.06,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.62,6.0,17.0}	{3.4,1.5,1.12,1.02}	https://www.oddsportal.com/football/greece/super-league-2021-2022/asteras-tripolis-ofi-crete-ADYhvxFP/#1X2;2	2023-05-07 21:53:21.160304+01
379	Giannina	Ionikos	2022-01-04 17:15:00+00	1	0	1.95	3.2	4	2.75	2.0	0	1	0	0	5.0	2.45	2.3	4.6	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.1,1.44,1.8,2.45,4.9,11.0,21.0,36.0}	{7.5,2.7,2.05,1.57,1.2,1.06,1.02,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.57,1.77,3.55,11.0,29.0,71.0}	{2.5,2.02,1.29,1.05,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.6,6.0,17.0}	{3.4,1.51,1.13,1.02}	https://www.oddsportal.com/football/greece/super-league-2021-2022/giannina-ionikos-r7t7GYMI/#1X2;2	2023-05-07 21:53:53.554653+01
380	AEK Athens FC	OFI Crete	2021-12-20 19:30:00+00	1	2	1.37	5.0	9	1.95	2.5	1	0	1	1	8.0	1.67	2.87	7.0	{0.5,1.5,2.5,2.75,3.5,4.5,5.5,6.5}	{1.04,1.23,1.72,1.95,2.75,5.5,11.0,23.0}	{12.0,4.0,2.07,1.9,1.4,1.15,1.05,1.01}	{0.5,1.0,1.5,2.5,3.5,4.5}	{1.36,1.7,2.62,6.5,19.0,41.0}	{3.25,2.1,1.47,1.11,1.02,1.01}	{0.5,1.5,2.5,3.5,4.5}	{1.25,2.05,4.0,10.0,26.0}	{4.33,1.8,1.22,1.06,1.01}	https://www.oddsportal.com/football/greece/super-league-2021-2022/aek-ofi-crete-xWSJRbVJ/#1X2;2	2023-05-07 21:54:23.773341+01
375	Panathinaikos	Aris	2022-01-05 21:30:00+00	2	0	2.3	2.9	4	3.25	1.8	0	1	0	1	4.5	2.8	2.05	4.0	{0.5,1.5,1.75,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.16,1.66,1.95,3.15,7.0,17.0,26.0,56.0}	{5.75,2.2,1.9,1.38,1.12,1.03,1.01,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.72,2.05,4.5,15.0,34.0,81.0}	{2.16,1.75,1.22,1.03,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.5,3.25,9.0,26.0}	{2.65,1.37,1.08,1.01}	https://www.oddsportal.com/football/greece/super-league-2021-2022/panathinaikos-aris-foAPYFxm/#1X2;2	2023-05-07 21:51:46.299024+01
381	Aris	Ionikos	2021-12-20 19:30:00+00	1	0	1.46	4.2	10	2.05	2.05	0	1	0	0	10.0	1.85	2.37	9.0	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.11,1.53,1.93,2.62,5.0,13.0,26.0,46.0}	{6.5,2.5,1.93,1.53,1.17,1.05,1.01,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.57,1.82,3.75,11.0,29.0,71.0}	{2.37,1.97,1.29,1.05,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.4,2.75,7.0,21.0}	{3.0,1.44,1.1,1.02}	https://www.oddsportal.com/football/greece/super-league-2021-2022/aris-ionikos-jZWNQIpQ/#1X2;2	2023-05-07 21:54:54.732746+01
382	Panathinaikos	Giannina	2021-12-19 19:30:00+00	2	0	1.65	3.7	6	2.3	2.1	0	2	0	0	6.25	1.95	2.4	5.8	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.08,1.44,2.05,2.28,4.33,10.0,21.0,34.0}	{7.5,2.75,1.8,1.61,1.22,1.07,1.01,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.53,1.7,3.4,10.0,23.0,61.0}	{2.5,2.1,1.33,1.06,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.5,6.0,17.0}	{3.4,1.53,1.13,1.02}	https://www.oddsportal.com/football/greece/super-league-2021-2022/panathinaikos-giannina-ERljKGNg/#1X2;2	2023-05-07 21:55:25.253749+01
383	PAOK	Asteras Tripolis	2021-12-19 19:30:00+00	3	2	1.65	3.8	6	2.3	2.1	1	2	1	1	6.0	2.05	2.45	5.0	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.07,1.36,1.9,2.1,3.75,9.0,19.0,31.0}	{8.5,3.0,1.95,1.73,1.25,1.08,1.02,1.0}	{0.5,1.0,1.5,2.5,3.5,4.5}	{1.5,2.07,3.25,9.0,26.0,56.0}	{2.62,1.72,1.36,1.07,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.33,2.3,5.5,15.0}	{3.5,1.57,1.14,1.03}	https://www.oddsportal.com/football/greece/super-league-2021-2022/paok-asteras-tripolis-0ri2HE7C/#1X2;2	2023-05-07 21:55:55.624862+01
384	Olympiacos Piraeus	Lamia	2021-12-19 15:00:00+00	1	0	1.21	7.0	17	1.62	2.75	0	0	0	1	12.0	1.44	3.25	10.0	{0.5,1.5,2.5,2.75,3.0,3.5,4.5,5.5,6.5}	{1.03,1.22,1.67,1.83,2.0,2.62,4.5,9.0,19.0}	{15.0,4.5,2.35,2.02,1.85,1.5,1.2,1.07,1.02}	{0.5,1.0,1.25,1.5,2.5,3.5,4.5}	{1.36,1.7,1.97,2.38,5.5,15.0,36.0}	{3.5,2.1,1.82,1.57,1.14,1.03,1.01}	{0.5,1.5,2.5,3.5,4.5}	{1.22,2.0,4.0,9.0,21.0}	{5.0,1.9,1.28,1.07,1.01}	https://www.oddsportal.com/football/greece/super-league-2021-2022/olympiacos-piraeus-lamia-n5IgLd8m/#1X2;2	2023-05-07 21:56:26.89345+01
385	Panetolikos	Atromitos	2021-12-18 19:30:00+00	2	1	2.2	3.25	4	3.1	2.0	1	1	0	1	4.5	2.55	2.25	3.8	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.09,1.43,2.05,2.35,4.33,10.0,21.0,36.0}	{7.5,2.75,1.8,1.6,1.22,1.06,1.02,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.57,1.75,3.5,11.0,26.0,67.0}	{2.5,2.05,1.3,1.05,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.5,6.0,17.0}	{3.4,1.53,1.12,1.02}	https://www.oddsportal.com/football/greece/super-league-2021-2022/panetolikos-atromitos-numbIfh6/#1X2;2	2023-05-07 21:56:56.813605+01
386	Ionikos	AEK Athens FC	2021-12-16 19:30:00+00	0	1	8.5	4.75	1	9.0	2.2	0	0	1	0	2.05	7.5	2.55	1.78	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.08,1.4,1.98,2.16,4.1,9.0,19.0,34.0}	{9.0,3.1,1.88,1.66,1.25,1.07,1.02,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.53,2.1,3.4,10.0,26.0,61.0}	{2.7,1.7,1.33,1.06,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.33,2.38,5.5,17.0}	{3.5,1.53,1.14,1.02}	https://www.oddsportal.com/football/greece/super-league-2021-2022/ionikos-aek-S0oT4yO6/#1X2;2	2023-05-07 21:57:27.708996+01
387	OFI Crete	Aris	2021-12-16 17:00:00+00	1	1	3.8	3.4	2	5.0	1.92	1	0	0	1	3.0	4.33	2.2	2.8	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.11,1.53,2.1,2.62,5.5,13.0,26.0,46.0}	{7.0,2.55,1.77,1.48,1.15,1.04,1.01,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.57,1.9,3.75,13.0,31.0,71.0}	{2.38,1.9,1.29,1.05,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.4,2.75,7.0,21.0}	{3.0,1.44,1.1,1.02}	https://www.oddsportal.com/football/greece/super-league-2021-2022/ofi-crete-aris-dzjX3ewD/#1X2;2	2023-05-07 21:57:58.078758+01
388	Atromitos	Olympiacos Piraeus	2021-12-15 19:30:00+00	0	3	7.5	4.1	2	6.5	2.25	2	0	1	0	2.1	6.0	2.6	1.83	{0.5,1.5,2.5,3.5,4.5,5.5,6.5}	{1.06,1.33,2.0,3.4,7.0,15.0,26.0}	{11.0,3.6,1.85,1.33,1.11,1.03,1.0}	{0.5,1.0,1.5,2.5,3.5,4.5}	{1.44,1.9,2.85,8.0,21.0,51.0}	{2.95,1.9,1.4,1.1,1.02,1.01}	{0.5,1.5,2.5,3.5,4.5}	{1.3,2.2,4.5,13.0}	{4.0,1.66,1.18,1.04}	https://www.oddsportal.com/football/greece/super-league-2021-2022/atromitos-olympiacos-piraeus-lAnP5H80/#1X2;2	2023-05-07 21:58:29.793297+01
389	Giannina	PAOK	2021-12-15 17:15:00+00	0	4	3.3	3.5	2	4.0	2.05	3	0	1	0	3.0	3.55	2.37	2.7	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.08,1.37,1.88,2.11,3.9,8.0,19.0,34.0}	{9.0,3.25,1.98,1.7,1.25,1.08,1.02,1.0}	{0.5,1.0,1.5,2.5,3.5,4.5}	{1.53,2.07,3.25,9.0,26.0,61.0}	{2.65,1.72,1.33,1.07,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.33,2.3,5.5,15.0}	{3.5,1.57,1.14,1.03}	https://www.oddsportal.com/football/greece/super-league-2021-2022/giannina-paok-0lfC8JOs/#1X2;2	2023-05-07 21:59:01.35227+01
390	Lamia	Volos	2021-12-15 17:15:00+00	2	2	2.55	3.2	3	3.5	2.0	1	2	1	0	3.6	3.0	2.3	3.25	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.08,1.4,1.98,2.3,4.3,9.0,21.0,34.0}	{8.0,2.88,1.88,1.61,1.22,1.07,1.02,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.53,1.7,3.4,10.0,23.0,61.0}	{2.55,2.1,1.31,1.06,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.33,2.37,5.5,15.0}	{3.5,1.53,1.14,1.03}	https://www.oddsportal.com/football/greece/super-league-2021-2022/lamia-volos-zRly3FhJ/#1X2;2	2023-05-07 21:59:42.522094+01
391	Asteras Tripolis	Panetolikos	2021-12-14 17:15:00+00	1	0	1.67	3.5	6	2.4	2.0	0	1	0	0	6.5	2.05	2.3	5.8	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.11,1.5,1.93,2.6,5.3,12.0,26.0,41.0}	{7.5,2.6,1.93,1.55,1.17,1.05,1.01,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.62,1.82,3.75,11.0,29.0,71.0}	{2.43,1.97,1.29,1.05,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.4,2.75,7.0,19.0}	{3.0,1.44,1.11,1.02}	https://www.oddsportal.com/football/greece/super-league-2021-2022/asteras-tripolis-panetolikos-6ocK6cgf/#1X2;2	2023-05-07 22:00:14.507772+01
392	Olympiacos Piraeus	Aris	2021-12-12 19:30:00+00	1	0	1.58	4.0	6	2.2	2.2	0	1	0	0	6.0	2.05	2.55	5.5	{0.5,1.5,2.25,2.5,2.75,3.5,4.5,5.5,6.5}	{1.07,1.36,1.9,2.1,3.75,8.0,17.0,26.0}	{9.5,3.25,1.95,1.78,1.3,1.1,1.03,1.0}	{0.5,1.0,1.5,2.5,3.5,4.5}	{1.44,2.07,3.25,9.0,26.0,51.0}	{2.7,1.72,1.38,1.08,1.01,1.0}	{0.5,1.5,2.5,3.5,4.5}	{1.33,2.37,5.5,15.0}	{3.75,1.63,1.17,1.04}	https://www.oddsportal.com/football/greece/super-league-2021-2022/olympiacos-piraeus-aris-lAQgjx9D/#1X2;2	2023-05-07 22:00:48.931671+01
393	PAOK	Lamia	2021-12-12 17:15:00+00	2	1	1.44	6.0	13	2.05	2.3	0	1	1	1	7.0	1.83	2.6	6.5	{0.5,1.5,2.5,2.75,3.5,4.5,5.5,6.5}	{1.07,1.33,2.05,3.5,7.0,17.0,26.0}	{9.5,3.4,1.8,1.33,1.11,1.03,1.0}	{0.5,1.0,1.25,1.5,2.5,3.5,4.5}	{1.4,1.97,3.0,8.0,23.0,51.0}	{2.8,1.82,1.44,1.1,1.02,1.01}	{0.5,1.5,2.5,3.5,4.5}	{1.3,2.25,5.0,13.0}	{3.75,1.62,1.17,1.04}	https://www.oddsportal.com/football/greece/super-league-2021-2022/paok-lamia-bu8pDaGQ/#1X2;2	2023-05-07 22:01:19.523753+01
394	Asteras Tripolis	AEK Athens FC	2021-12-11 19:30:00+00	0	0	3.45	3.3	2	3.6	2.05	0	0	0	0	3.2	3.3	2.3	2.8	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.08,1.4,1.95,2.15,4.0,9.0,19.0,31.0}	{8.5,3.0,1.9,1.7,1.25,1.08,1.02,1.0}	{0.5,1.0,1.5,2.5,3.5,4.5}	{1.44,2.1,3.25,10.0,26.0,56.0}	{2.62,1.7,1.36,1.07,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.33,2.37,5.5,15.0}	{3.5,1.57,1.15,1.03}	https://www.oddsportal.com/football/greece/super-league-2021-2022/asteras-tripolis-aek-z7MkiIg7/#1X2;2	2023-05-07 22:01:49.899838+01
395	Panetolikos	Ionikos	2021-12-11 19:30:00+00	2	2	2.3	3.4	3	3.1	1.95	2	1	0	1	4.33	2.7	2.2	3.7	{0.5,1.5,2.0,2.5,3.5,4.5,5.5,6.5}	{1.11,1.53,2.05,2.7,5.5,13.0,26.0,41.0}	{7.0,2.55,1.8,1.57,1.19,1.06,1.01,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.6,1.9,3.75,13.0,26.0,67.0}	{2.4,1.9,1.29,1.05,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.4,2.62,7.0,21.0}	{3.0,1.46,1.11,1.02}	https://www.oddsportal.com/football/greece/super-league-2021-2022/panetolikos-ionikos-t4DuEu1K/#1X2;2	2023-05-07 22:02:19.677232+01
396	Giannina	Volos	2021-12-11 17:15:00+00	3	2	2.35	3.6	5	2.62	2.1	0	2	2	1	5.5	2.25	2.4	4.75	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.08,1.4,1.9,2.23,4.0,9.0,19.0,34.0}	{8.5,3.0,1.95,1.7,1.23,1.07,1.02,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.57,2.07,3.5,9.0,26.0,61.0}	{2.62,1.72,1.33,1.07,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.33,2.37,5.5,15.0}	{3.5,1.57,1.14,1.03}	https://www.oddsportal.com/football/greece/super-league-2021-2022/giannina-volos-EiYtgvPf/#1X2;2	2023-05-07 22:02:51.216433+01
397	Panathinaikos	Atromitos	2021-12-11 17:15:00+00	2	0	1.53	4.1	7	2.2	2.2	0	1	0	1	6.5	1.95	2.6	5.5	{0.5,1.5,2.5,3.5,4.5,5.5,6.5}	{1.06,1.33,2.0,3.4,7.0,15.0,29.0}	{10.0,3.4,1.85,1.3,1.11,1.03,1.0}	{0.5,1.0,1.5,2.5,3.5,4.5}	{1.44,1.92,3.0,8.0,23.0,51.0}	{2.75,1.87,1.4,1.08,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.3,2.25,4.75,13.0}	{3.75,1.66,1.18,1.04}	https://www.oddsportal.com/football/greece/super-league-2021-2022/panathinaikos-atromitos-2DEyFLoE/#1X2;2	2023-05-07 22:03:20.729542+01
398	Lamia	Giannina	2021-12-06 19:30:00+00	0	1	3.5	3.0	3	4.5	1.85	1	0	0	0	3.2	3.9	2.2	2.85	{0.5,1.5,1.75,2.0,2.5,3.5,4.5,5.5,6.5}	{1.14,1.61,1.8,2.87,6.0,15.0,26.0,51.0}	{6.25,2.33,2.05,1.42,1.13,1.03,1.01,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.66,1.97,4.0,13.0,34.0,81.0}	{2.25,1.82,1.25,1.04,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.44,3.0,8.0,23.0}	{2.75,1.37,1.08,1.01}	https://www.oddsportal.com/football/greece/super-league-2021-2022/lamia-giannina-6RYxfK9l/#1X2;2	2023-05-07 22:03:56.059077+01
399	AEK Athens FC	Panathinaikos	2021-12-05 19:30:00+00	1	0	1.85	3.35	5	2.6	2.05	0	0	0	1	5.5	2.3	2.4	4.75	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.1,1.4,2.0,2.3,4.4,10.0,21.0,31.0}	{8.5,2.95,1.85,1.66,1.25,1.08,1.02,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.53,1.7,3.4,10.0,23.0,56.0}	{2.63,2.1,1.34,1.07,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.5,6.0,17.0}	{3.4,1.57,1.15,1.03}	https://www.oddsportal.com/football/greece/super-league-2021-2022/aek-panathinaikos-O4zAjo3d/#1X2;2	2023-05-07 22:04:28.156242+01
400	Aris	Asteras Tripolis	2021-12-05 19:30:00+00	1	0	1.73	3.5	6	2.5	2.04	0	0	0	1	6.0	2.25	2.3	5.5	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.1,1.53,1.88,2.5,4.9,11.0,23.0,41.0}	{8.0,2.75,1.98,1.55,1.18,1.05,1.02,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.53,1.8,3.5,11.0,26.0,67.0}	{2.55,2.0,1.3,1.05,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.4,2.62,6.5,17.0}	{3.25,1.5,1.11,1.02}	https://www.oddsportal.com/football/greece/super-league-2021-2022/aris-asteras-tripolis-0MJhFUuc/#1X2;2	2023-05-07 22:04:58.981383+01
401	Ionikos	PAOK	2021-12-05 17:15:00+00	3	2	6.5	4.0	2	6.5	2.23	1	1	1	2	2.3	6.0	2.55	1.95	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.07,1.36,1.88,2.1,3.75,8.0,17.0,29.0}	{10.5,3.35,1.98,1.74,1.28,1.1,1.02,1.0}	{0.5,1.0,1.5,2.5,3.5,4.5}	{1.5,2.05,3.0,9.0,23.0,56.0}	{2.88,1.75,1.36,1.07,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.33,2.3,5.0,13.0}	{3.75,1.61,1.16,1.04}	https://www.oddsportal.com/football/greece/super-league-2021-2022/ionikos-paok-nwM4CSPF/#1X2;2	2023-05-07 22:05:30.663725+01
402	OFI Crete	Olympiacos Piraeus	2021-12-04 19:30:00+00	1	3	7.0	4.0	2	6.5	2.25	2	0	1	1	2.2	5.75	2.6	1.9	{0.5,1.5,2.5,3.5,4.5,5.5,6.5}	{1.06,1.31,1.97,3.6,7.5,15.0,26.0}	{10.5,3.4,1.8,1.33,1.11,1.03,1.0}	{0.5,1.0,1.5,2.5,3.5,4.5}	{1.43,1.92,3.0,8.0,23.0,51.0}	{2.9,1.87,1.4,1.1,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.3,2.1,4.5,13.0}	{4.0,1.66,1.18,1.04}	https://www.oddsportal.com/football/greece/super-league-2021-2022/ofi-crete-olympiacos-piraeus-SzzZf0fr/#1X2;2	2023-05-07 22:06:02.235609+01
403	Atromitos	Apollon Smyrnis	2021-12-04 17:15:00+00	4	1	2.0	3.2	5	2.8	1.95	0	2	1	2	4.75	2.5	2.25	4.35	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.1,1.44,1.85,2.5,4.8,11.0,23.0,36.0}	{7.5,2.75,2.0,1.55,1.2,1.06,1.01,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.57,1.8,3.55,11.0,26.0,67.0}	{2.48,2.0,1.3,1.05,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.62,6.5,19.0}	{3.25,1.5,1.12,1.02}	https://www.oddsportal.com/football/greece/super-league-2021-2022/atromitos-apollon-smyrnis-vDIdEle3/#1X2;2	2023-05-07 22:06:32.979375+01
404	Volos	Panetolikos	2021-12-04 17:15:00+00	1	2	1.8	3.6	6	2.6	2.25	0	0	2	1	5.5	2.16	2.5	4.5	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.06,1.33,2.02,3.75,8.0,15.0,26.0}	{10.0,3.5,1.83,1.33,1.11,1.03,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.5,1.85,3.25,8.0,21.0,56.0}	{2.88,1.95,1.4,1.08,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.33,2.25,4.75,11.0}	{4.0,1.66,1.18,1.05}	https://www.oddsportal.com/football/greece/super-league-2021-2022/volos-panetolikos-YZH0D8A9/#1X2;2	2023-05-07 22:07:04.092154+01
405	Panathinaikos	Panetolikos	2021-11-28 19:30:00+00	2	0	1.46	4.33	8	2.0	2.37	0	2	0	0	7.5	1.77	2.75	6.5	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.06,1.29,1.87,3.4,6.5,15.0,23.0}	{10.0,3.5,1.9,1.36,1.12,1.04,1.0}	{0.5,1.0,1.5,2.5,3.5,4.5}	{1.4,1.8,2.75,8.0,21.0,46.0}	{2.8,2.0,1.44,1.1,1.01,1.01}	{0.5,1.5,2.5,3.5}	{1.28,2.2,4.5,13.0}	{4.0,1.66,1.2,1.05}	https://www.oddsportal.com/football/greece/super-league-2021-2022/panathinaikos-panetolikos-jix2h7Yq/#1X2;2	2023-05-07 22:07:34.977159+01
406	PAOK	Aris	2021-11-28 19:30:00+00	0	1	1.72	3.9	6	2.37	2.1	0	0	1	0	5.75	2.05	2.5	5.5	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.07,1.4,1.93,2.14,3.75,8.0,19.0,31.0}	{9.0,3.0,1.93,1.7,1.25,1.08,1.02,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.5,2.1,3.25,9.0,26.0,61.0}	{2.62,1.7,1.33,1.07,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.33,2.37,5.5,15.0}	{3.5,1.57,1.15,1.03}	https://www.oddsportal.com/football/greece/super-league-2021-2022/paok-aris-pEy6iRmj/#1X2;2	2023-05-07 22:08:06.008187+01
407	OFI Crete	Ionikos	2021-11-28 15:00:00+00	2	1	1.78	3.6	5	2.6	2.05	1	1	0	1	5.5	2.2	2.37	5.0	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.1,1.44,2.05,2.36,4.33,10.0,21.0,41.0}	{8.0,2.75,1.8,1.57,1.2,1.06,1.02,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.57,1.72,3.4,10.0,26.0,67.0}	{2.5,2.07,1.3,1.06,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.5,6.0,17.0}	{3.4,1.53,1.12,1.02}	https://www.oddsportal.com/football/greece/super-league-2021-2022/ofi-crete-ionikos-UmWzcmQS/#1X2;2	2023-05-07 22:08:36.763718+01
408	Olympiacos Piraeus	Volos	2021-11-28 15:00:00+00	2	1	1.2	6.75	15	1.57	2.87	1	2	0	0	11.0	1.44	3.4	10.0	{0.5,1.5,2.5,2.75,3.0,3.5,4.5,5.5,6.5}	{1.03,1.16,1.5,1.85,2.3,3.75,8.0,15.0}	{15.5,5.5,2.5,2.0,1.57,1.25,1.1,1.03}	{0.5,1.25,1.5,2.5,3.5,4.5}	{1.3,1.87,2.25,5.0,13.0,31.0}	{3.75,1.92,1.61,1.16,1.04,1.01}	{0.5,1.5,2.5,3.5,4.5}	{1.2,1.8,3.5,8.0,19.0}	{5.5,2.0,1.3,1.09,1.02}	https://www.oddsportal.com/football/greece/super-league-2021-2022/olympiacos-piraeus-volos-nPtWcTAM/#1X2;2	2023-05-07 22:09:07.906302+01
409	Apollon Smyrnis	Lamia	2021-11-27 19:30:00+00	0	0	2.55	2.8	4	3.4	1.8	0	0	0	0	4.75	3.0	2.0	4.0	{0.5,1.5,1.75,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.17,1.73,2.05,3.5,7.0,19.0,31.0,61.0}	{5.0,2.05,1.8,1.33,1.1,1.02,1.01,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.75,2.07,4.5,15.0,36.0,91.0}	{2.05,1.72,1.2,1.03,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.53,3.25,10.0,26.0}	{2.62,1.33,1.07,1.01}	https://www.oddsportal.com/football/greece/super-league-2021-2022/apollon-smyrnis-lamia-vawOaktA/#1X2;2	2023-05-07 22:09:38.917104+01
410	Giannina	AEK Athens FC	2021-11-27 19:30:00+00	1	2	3.75	3.4	2	4.1	2.1	1	0	1	1	2.75	3.9	2.4	2.45	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.07,1.33,2.0,3.5,7.0,15.0,29.0}	{9.5,3.4,1.8,1.29,1.11,1.03,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.44,1.95,3.0,8.0,23.0,51.0}	{2.75,1.85,1.36,1.08,1.02,1.0}	{0.5,1.5,2.5,3.5}	{1.3,2.2,5.0,13.0}	{3.75,1.62,1.17,1.04}	https://www.oddsportal.com/football/greece/super-league-2021-2022/giannina-aek-08vK0VQ3/#1X2;2	2023-05-07 22:10:09.5695+01
411	Asteras Tripolis	Atromitos	2021-11-27 17:15:00+00	6	2	1.9	3.2	5	2.62	1.95	1	3	1	3	5.0	2.3	2.3	4.4	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.1,1.44,1.85,2.5,4.5,11.0,23.0,34.0}	{7.0,2.7,2.0,1.58,1.21,1.07,1.01,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.57,1.8,3.5,11.0,23.0,61.0}	{2.4,2.0,1.31,1.06,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.5,6.5,19.0}	{3.25,1.51,1.13,1.02}	https://www.oddsportal.com/football/greece/super-league-2021-2022/asteras-tripolis-atromitos-8YsSb9eG/#1X2;2	2023-05-07 22:10:40.323179+01
412	Lamia	Panathinaikos	2021-11-22 18:00:00+00	1	3	5.8	3.9	2	6.5	2.06	3	0	0	1	2.38	6.0	2.3	2.15	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5}	{1.11,1.5,1.85,2.55,5.5,13.0,26.0}	{7.5,2.55,2.0,1.5,1.17,1.05,1.02}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.6,1.77,3.75,11.0,17.0,34.0}	{2.48,2.02,1.29,1.05,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.4,2.7,7.0,19.0}	{3.0,1.44,1.11,1.02}	https://www.oddsportal.com/football/greece/super-league-2021-2022/lamia-panathinaikos-IqkF1BBc/#1X2;2	2023-05-07 22:11:12.346527+01
413	AEK Athens FC	Olympiacos Piraeus	2021-11-21 19:30:00+00	2	3	3.3	3.2	2	3.75	2.05	1	1	2	1	3.2	3.4	2.37	2.8	{0.5,1.5,2.25,2.5,3.5,4.5,5.5}	{1.08,1.4,1.9,2.2,3.95,9.0,19.0}	{9.0,3.15,1.95,1.68,1.25,1.08,1.02}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.53,2.07,3.4,10.0,26.0,29.0}	{2.7,1.72,1.34,1.07,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.3,2.3,5.5,15.0}	{3.5,1.57,1.15,1.03}	https://www.oddsportal.com/football/greece/super-league-2021-2022/aek-olympiacos-piraeus-z5edojRG/#1X2;2	2023-05-07 22:11:44.016536+01
414	Atromitos	PAOK	2021-11-21 19:30:00+00	2	0	5.8	3.75	2	5.8	2.15	0	1	0	1	2.3	5.6	2.48	2.0	{0.5,1.5,2.25,2.5,3.5,4.5,5.5}	{1.07,1.36,1.88,2.1,4.0,8.5,17.0}	{9.5,3.25,1.98,1.68,1.26,1.09,1.02}	{0.5,1.0,1.5,2.5,3.5,4.5}	{1.5,2.05,3.25,9.0,23.0,29.0}	{2.8,1.75,1.36,1.07,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.33,2.37,5.0,15.0}	{3.75,1.61,1.16,1.03}	https://www.oddsportal.com/football/greece/super-league-2021-2022/atromitos-paok-8Ig4qUeT/#1X2;2	2023-05-07 22:12:15.463284+01
415	Panetolikos	Apollon Smyrnis	2021-11-21 17:15:00+00	1	0	2.15	3.1	4	3.1	1.95	0	1	0	0	4.6	2.62	2.25	4.1	{0.5,1.5,2.0,2.5,3.5,4.5,5.5}	{1.12,1.5,1.9,2.5,5.0,11.0,26.0}	{7.0,2.65,1.95,1.52,1.18,1.06,1.02}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.57,1.82,3.75,11.0,17.0,34.0}	{2.38,1.97,1.28,1.05,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.63,6.5,19.0}	{3.25,1.46,1.11,1.02}	https://www.oddsportal.com/football/greece/super-league-2021-2022/panetolikos-apollon-smyrnis-4toB2idi/#1X2;2	2023-05-07 22:12:45.537263+01
416	Aris	Giannina	2021-11-20 19:30:00+00	0	5	1.55	3.75	8	2.3	2.05	3	0	2	0	7.5	2.0	2.4	6.25	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5}	{1.1,1.45,1.75,2.1,2.5,5.1,11.5,21.0}	{7.5,2.75,2.13,1.77,1.57,1.2,1.06,1.02}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.6,1.8,3.75,11.0,17.0,34.0}	{2.48,2.0,1.29,1.05,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.4,2.7,6.0,16.0}	{3.5,1.53,1.14,1.03}	https://www.oddsportal.com/football/greece/super-league-2021-2022/aris-giannina-URf0pAtN/#1X2;2	2023-05-07 22:13:17.37383+01
417	Ionikos	Asteras Tripolis	2021-11-20 19:30:00+00	1	1	3.5	3.1	2	4.33	1.9	0	0	1	1	3.2	3.7	2.1	3.0	{0.5,1.5,1.75,2.0,2.5,3.5,4.5,5.5}	{1.14,1.6,1.83,2.87,6.0,15.0,17.0}	{6.5,2.38,2.02,1.41,1.14,1.04,1.01}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.65,1.95,4.0,13.0,21.0,41.0}	{2.3,1.85,1.25,1.04,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.41,2.88,8.0,21.0}	{2.88,1.4,1.1,1.02}	https://www.oddsportal.com/football/greece/super-league-2021-2022/ionikos-asteras-tripolis-jwcTw8Jj/#1X2;2	2023-05-07 22:13:47.905804+01
419	Olympiacos Piraeus	Ionikos	2021-11-07 19:30:00+00	1	0	1.12	10.0	22	1.44	3.25	0	0	0	1	12.0	1.33	3.8	13.0	{0.5,1.5,2.5,2.75,3.0,3.25,3.5,4.5,5.5,6.5}	{1.02,1.15,1.5,2.2,3.75,6.75,13.0}	{13.0,5.0,2.5,1.61,1.25,1.1,1.03}	{0.5,1.25,1.5,2.5,3.5,4.5}	{1.3,2.25,4.6,11.5,17.0}	{4.0,1.65,1.17,1.04,1.01}	{0.5,1.5,2.5,3.5,4.5}	{1.2,1.8,3.5,7.0}	{5.0,1.98,1.3,1.08}	https://www.oddsportal.com/football/greece/super-league-2021-2022/olympiacos-piraeus-ionikos-0n3qlhsb/#1X2;2	2023-05-07 22:14:48.781612+01
420	Panathinaikos	PAOK	2021-11-07 19:30:00+00	1	3	2.75	3.1	3	3.4	1.87	2	1	1	0	3.4	3.0	2.2	3.1	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.1,1.42,2.25,4.1,8.5,17.5}	{7.0,2.75,1.65,1.22,1.06,1.02}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.53,3.4,9.0,17.0}	{2.37,1.3,1.06,1.01}	{0.5,1.5,2.5,3.5,4.5}	{1.33,2.4,5.5,14.5}	{3.25,1.53,1.12,1.02}	https://www.oddsportal.com/football/greece/super-league-2021-2022/panathinaikos-paok-M1ihnWBA/#1X2;2	2023-05-07 22:15:18.960813+01
421	Volos	Aris	2021-11-07 17:15:00+00	1	2	3.25	3.3	2	3.7	2.05	1	1	1	0	3.1	3.5	2.35	2.62	{0.5,1.5,2.25,2.5,3.5,4.5,5.5}	{1.07,1.36,2.11,3.75,7.0,14.0}	{8.0,3.0,1.71,1.26,1.09,1.02}	{0.5,1.0,1.5,2.5,3.5,4.5}	{1.5,3.25,8.0,15.0,29.0}	{2.65,1.36,1.07,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.33,2.3,4.8,12.0}	{3.5,1.58,1.15,1.03}	https://www.oddsportal.com/football/greece/super-league-2021-2022/volos-aris-WCbukYRi/#1X2;2	2023-05-07 22:15:48.749368+01
422	Asteras Tripolis	Lamia	2021-11-07 15:00:00+00	0	1	1.85	3.2	5	2.75	1.93	0	0	1	0	5.0	2.37	2.15	4.6	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5}	{1.12,1.53,2.62,5.25,11.0,17.0}	{6.0,2.37,1.45,1.15,1.05,1.01}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.6,3.75,11.0}	{2.25,1.25,1.05}	{0.5,1.5,2.5,3.5}	{1.4,2.75,7.0,19.0}	{2.8,1.44,1.1,1.01}	https://www.oddsportal.com/football/greece/super-league-2021-2022/asteras-tripolis-lamia-hMayjECo/#1X2;2	2023-05-07 22:16:18.491927+01
423	Apollon Smyrnis	AEK Athens FC	2021-11-06 19:30:00+00	2	2	7.5	4.0	2	6.75	2.1	1	1	1	1	2.15	6.25	2.6	1.85	{0.5,1.5,2.5,3.5,4.5,5.5}	{1.07,1.33,1.93,3.25,6.25,12.5}	{8.0,3.25,1.85,1.33,1.11,1.03}	{0.5,1.0,1.5,2.5,3.5,4.5}	{1.44,2.8,7.25,15.0}	{2.62,1.4,1.08,1.01}	{0.5,1.5,2.5,3.5}	{1.3,2.25,4.75,11.0}	{3.6,1.63,1.18,1.04}	https://www.oddsportal.com/football/greece/super-league-2021-2022/apollon-smyrnis-aek-jHLhRUZp/#1X2;2	2023-05-07 22:16:47.209287+01
424	Giannina	Panetolikos	2021-11-06 17:15:00+00	3	0	1.9	3.4	5	2.6	2.0	0	1	0	2	4.6	2.37	2.25	4.4	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5}	{1.1,1.44,2.3,4.4,9.25,15.0}	{7.0,2.75,1.6,1.22,1.06,1.01}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.53,3.3,9.5,17.0,34.0}	{2.45,1.33,1.06,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.5,6.0,16.0}	{3.0,1.5,1.12,1.02}	https://www.oddsportal.com/football/greece/super-league-2021-2022/giannina-panetolikos-GOUQVART/#1X2;2	2023-05-07 22:17:17.751088+01
425	OFI Crete	Atromitos	2021-11-06 17:15:00+00	2	0	2.3	3.15	3	3.1	1.95	0	0	0	2	3.8	2.75	2.25	3.4	{0.5,1.5,2.25,2.5,3.5,4.5,5.5}	{1.08,1.42,2.25,4.1,8.5,18.0}	{7.0,2.75,1.61,1.22,1.07,1.02}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.53,3.25,9.0,17.0,34.0}	{2.37,1.33,1.06,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.33,2.4,5.75,14.5}	{3.25,1.53,1.12,1.03}	https://www.oddsportal.com/football/greece/super-league-2021-2022/ofi-crete-atromitos-vw2mmCd4/#1X2;2	2023-05-07 22:17:46.376071+01
426	Ionikos	Volos	2021-11-01 19:30:00+00	1	1	2.8	3.1	3	3.5	1.93	1	1	0	0	3.25	3.1	2.25	3.0	{0.5,1.5,2.25,2.5,3.5,4.5,5.5}	{1.08,1.4,2.2,3.75,7.5,15.5}	{7.0,2.8,1.63,1.25,1.07,1.02}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.53,3.25,8.25,17.0,29.0}	{2.45,1.33,1.06,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.33,2.37,5.25,13.0}	{3.25,1.53,1.14,1.03}	https://www.oddsportal.com/football/greece/super-league-2021-2022/ionikos-volos-hMw6zZCb/#1X2;2	2023-05-07 22:18:15.746289+01
428	Giannina	Asteras Tripolis	2021-10-31 19:30:00+00	1	1	2.65	2.9	3	3.5	1.83	0	0	1	1	3.7	3.1	2.05	3.3	{0.5,1.5,1.75,2.0,2.25,2.5,3.5,4.5,5.5}	{1.12,1.6,2.75,5.5,12.5,17.0}	{5.5,2.3,1.41,1.14,1.03,1.01}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.7,4.0,11.5,21.0,41.0}	{2.15,1.22,1.04,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.41,2.9,7.5,15.0}	{2.75,1.4,1.1,1.02}	https://www.oddsportal.com/football/greece/super-league-2021-2022/giannina-asteras-tripolis-vJZ1yFch/#1X2;2	2023-05-07 22:19:15.940595+01
429	Panathinaikos	OFI Crete	2021-10-31 17:15:00+00	0	0	1.52	3.85	7	2.2	2.1	0	0	0	0	6.25	1.85	2.5	6.0	{0.5,1.5,2.25,2.5,3.5,4.5,5.5}	{1.07,1.34,2.03,3.5,6.75,14.0}	{8.0,3.25,1.72,1.28,1.1,1.02}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.43,3.0,7.75,15.0,29.0}	{2.75,1.36,1.07,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.33,2.3,4.8,12.0}	{3.5,1.58,1.15,1.03}	https://www.oddsportal.com/football/greece/super-league-2021-2022/panathinaikos-ofi-crete-nqwAZhS4/#1X2;2	2023-05-07 22:19:45.959511+01
430	Lamia	Atromitos	2021-10-31 15:00:00+00	2	2	2.35	3.0	3	3.4	1.88	1	1	1	1	3.9	2.8	2.15	3.6	{0.5,1.5,1.75,2.0,2.5,3.5,4.5,5.5}	{1.11,1.5,2.56,4.75,10.0,15.0}	{6.0,2.5,1.53,1.16,1.05,1.01}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.61,3.75,10.0,21.0,34.0}	{2.3,1.26,1.05,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.4,2.62,6.25,17.0}	{2.9,1.44,1.11,1.02}	https://www.oddsportal.com/football/greece/super-league-2021-2022/lamia-atromitos-M1VMWjCN/#1X2;2	2023-05-07 22:20:15.745864+01
431	Panetolikos	Olympiacos Piraeus	2021-10-30 19:30:00+01	1	2	9.0	4.75	1	7.0	2.4	1	0	1	1	1.93	7.0	2.75	1.71	{0.5,1.5,2.5,3.5,4.5,5.5,6.5}	{1.05,1.28,1.83,3.0,5.75,13.0,23.0}	{12.0,3.75,2.05,1.4,1.14,1.05,1.01}	{0.5,1.0,1.5,2.5,3.5,4.5}	{1.4,1.72,2.75,6.75,19.0}	{3.25,2.07,1.44,1.11,1.02}	{0.5,1.5,2.5,3.5,4.5}	{1.25,2.05,4.33,11.0,26.0}	{4.33,1.72,1.22,1.05,1.01}	https://www.oddsportal.com/football/greece/super-league-2021-2022/panetolikos-olympiacos-piraeus-QZyEYCsB/#1X2;2	2023-05-07 22:20:47.439049+01
432	PAOK	Apollon Smyrnis	2021-10-30 19:30:00+01	4	1	1.2	6.5	17	1.61	2.65	0	3	1	1	11.0	1.44	3.3	11.0	{0.5,1.5,2.5,2.75,3.0,3.5,4.5,5.5,6.5}	{1.04,1.22,1.66,1.8,2.62,5.0,10.0,21.0}	{13.0,4.33,2.25,2.05,1.5,1.2,1.07,1.02}	{0.5,1.25,1.5,2.5,3.5,4.5}	{1.33,2.02,2.5,6.0,17.0}	{3.4,1.77,1.57,1.14,1.02}	{0.5,1.5,2.5,3.5,4.5}	{1.22,1.9,4.0,10.0,23.0}	{4.6,1.88,1.26,1.07,1.01}	https://www.oddsportal.com/football/greece/super-league-2021-2022/paok-apollon-smyrnis-rBWIXWdH/#1X2;2	2023-05-07 22:21:19.304361+01
433	Olympiacos Piraeus	PAOK	2021-10-24 20:30:00+01	2	1	1.72	3.75	5	2.5	2.2	1	0	0	2	5.5	2.1	2.5	4.75	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.07,1.36,1.83,2.05,3.5,7.0,17.0}	{9.5,3.25,2.02,1.77,1.28,1.1,1.03}	{0.5,1.0,1.5,2.5,3.5,4.5}	{1.44,2.02,3.0,8.0,23.0,29.0}	{2.75,1.77,1.4,1.08,1.01,1.0}	{0.5,1.5,2.5,3.5,4.5}	{1.3,2.3,5.0,13.0}	{3.75,1.61,1.16,1.04}	https://www.oddsportal.com/football/greece/super-league-2021-2022/olympiacos-piraeus-paok-tUflIicU/#1X2;2	2023-05-07 22:21:50.129438+01
434	OFI Crete	Lamia	2021-10-24 18:15:00+01	0	0	2.25	3.25	4	3.1	2.0	0	0	0	0	4.33	2.7	2.3	3.6	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5}	{1.1,1.43,2.1,2.42,4.33,10.0,21.0}	{8.0,2.75,1.77,1.57,1.2,1.06,1.01}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.57,1.75,3.4,10.0,17.0,34.0}	{2.5,2.05,1.3,1.06,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.45,6.0,17.0}	{3.4,1.53,1.12,1.02}	https://www.oddsportal.com/football/greece/super-league-2021-2022/ofi-crete-lamia-I3ogwyTu/#1X2;2	2023-05-07 22:22:20.069057+01
435	Aris	Panetolikos	2021-10-24 16:00:00+01	5	1	1.46	4.2	9	2.1	2.2	1	1	0	4	7.5	1.8	2.5	7.5	{0.5,1.5,2.25,2.5,3.5,4.5,5.5}	{1.08,1.4,1.98,2.25,4.0,9.0,21.0}	{8.0,2.75,1.88,1.61,1.22,1.07,1.02}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.53,1.7,2.1,3.25,10.0,26.0}	{2.62,2.1,1.7,1.33,1.06,1.01}	{0.5,1.5,2.5,3.5}	{1.36,2.5,6.0,17.0}	{3.4,1.53,1.13,1.02}	https://www.oddsportal.com/football/greece/super-league-2021-2022/aris-panetolikos-Cl3XLZc5/#1X2;2	2023-05-07 22:22:51.004776+01
436	Volos	AEK Athens FC	2021-10-24 16:00:00+01	1	3	4.4	4.0	2	4.75	2.4	1	1	2	0	2.3	4.33	2.62	2.1	{0.5,1.5,2.5,2.75,3.5,4.5,5.5,6.5}	{1.04,1.23,1.72,1.93,2.75,5.0,11.0,21.0}	{13.0,4.0,2.1,1.93,1.44,1.16,1.05,1.01}	{0.5,1.0,1.25,1.5,2.5,3.5,4.5}	{1.4,1.7,2.1,2.62,6.5,17.0}	{3.25,2.1,1.7,1.5,1.11,1.02}	{0.5,1.5,2.5,3.5,4.5}	{1.22,2.0,4.0,10.0,23.0}	{4.5,1.83,1.25,1.06,1.01}	https://www.oddsportal.com/football/greece/super-league-2021-2022/volos-aek-2wdpJXsO/#1X2;2	2023-05-07 22:23:21.876238+01
437	Asteras Tripolis	Panathinaikos	2021-10-23 20:30:00+01	2	1	2.72	3.0	3	3.5	1.83	0	0	1	2	3.75	3.1	2.1	3.3	{0.5,1.5,1.75,2.0,2.25,2.5,3.5,4.5,5.5}	{1.14,1.58,1.8,2.87,6.0,15.0,17.0}	{6.0,2.3,2.05,1.45,1.14,1.03,1.01}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.62,1.95,4.0,13.0,21.0,34.0}	{2.2,1.85,1.25,1.04,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.44,2.87,8.0,21.0}	{2.75,1.4,1.08,1.02}	https://www.oddsportal.com/football/greece/super-league-2021-2022/asteras-tripolis-panathinaikos-6B2yLgDB/#1X2;2	2023-05-07 22:23:51.825459+01
438	Apollon Smyrnis	Giannina	2021-10-23 19:00:00+01	1	0	2.55	2.9	4	3.3	1.9	0	1	0	0	4.33	3.0	2.1	3.6	{0.5,1.5,1.75,2.0,2.5,3.5,4.5,5.5}	{1.12,1.57,2.02,2.75,5.5,13.0,17.0}	{6.0,2.37,1.83,1.45,1.15,1.04,1.01}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.66,1.9,4.0,13.0}	{2.25,1.9,1.25,1.04}	{0.5,1.5,2.5,3.5}	{1.44,2.75,7.0,21.0}	{3.0,1.4,1.1,1.01}	https://www.oddsportal.com/football/greece/super-league-2021-2022/apollon-smyrnis-giannina-Yc4TMFra/#1X2;2	2023-05-07 22:24:21.331306+01
439	Atromitos	Ionikos	2021-10-23 18:15:00+01	0	2	1.7	3.5	6	2.3	2.1	1	0	1	0	6.0	2.05	2.37	5.0	{0.5,1.5,2.25,2.5,3.5,4.5,5.5}	{1.08,1.4,1.98,2.2,4.0,9.0,19.0}	{8.0,3.0,1.88,1.66,1.25,1.07,1.02}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.53,2.1,3.25,10.0,26.0}	{2.62,1.7,1.33,1.06,1.01}	{0.5,1.5,2.5,3.5}	{1.36,2.5,5.5,15.0}	{3.5,1.53,1.14,1.03}	https://www.oddsportal.com/football/greece/super-league-2021-2022/atromitos-ionikos-KE6uKDSH/#1X2;2	2023-05-07 22:24:51.88614+01
440	Lamia	Aris	2021-10-18 19:30:00+01	0	1	3.6	2.9	2	4.33	1.83	1	0	0	0	3.4	3.7	2.1	2.9	{0.5,1.5,1.75,2.0,2.5,3.5,4.5,5.5}	{1.14,1.62,1.85,2.87,6.0,15.0,17.0}	{5.5,2.2,2.0,1.4,1.14,1.03,1.01}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.7,2.0,4.33,15.0,21.0,41.0}	{2.1,1.8,1.22,1.03,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.44,3.0,8.0,23.0}	{2.75,1.4,1.08,1.02}	https://www.oddsportal.com/football/greece/super-league-2021-2022/lamia-aris-GM9ONeTh/#1X2;2	2023-05-07 22:25:31.727508+01
441	AEK Athens FC	Atromitos	2021-10-17 20:30:00+01	3	0	1.32	5.5	12	1.8	2.5	0	2	0	1	8.5	1.66	3.0	8.0	{0.5,1.5,2.5,2.75,3.5,4.5,5.5,6.5}	{1.05,1.25,1.83,2.0,2.75,5.5,11.0,23.0}	{12.0,4.0,2.05,1.85,1.41,1.16,1.05,1.01}	{0.5,1.0,1.25,1.5,2.5,3.5,4.5}	{1.36,1.77,2.62,6.5,19.0,21.0}	{3.25,2.02,1.5,1.11,1.02,1.01}	{0.5,1.5,2.5,3.5,4.5}	{1.25,2.1,4.33,10.0,26.0}	{4.33,1.83,1.24,1.06,1.01}	https://www.oddsportal.com/football/greece/super-league-2021-2022/aek-atromitos-OU1dKMM0/#1X2;2	2023-05-07 22:26:02.541206+01
442	Giannina	Olympiacos Piraeus	2021-10-17 20:30:00+01	1	2	8.2	4.2	1	7.5	2.2	1	1	1	0	2.05	7.0	2.5	1.85	{0.5,1.5,2.25,2.5,3.5,4.5,5.5}	{1.08,1.4,2.0,2.25,4.0,8.0,17.0}	{9.0,3.25,1.85,1.75,1.25,1.08,1.02}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.5,1.67,2.1,3.25,9.0,26.0,29.0}	{2.62,2.15,1.7,1.33,1.07,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.5,5.5,15.0}	{3.75,1.61,1.16,1.03}	https://www.oddsportal.com/football/greece/super-league-2021-2022/giannina-olympiacos-piraeus-h460Jtx7/#1X2;2	2023-05-07 22:26:33.85244+01
443	Panetolikos	OFI Crete	2021-10-17 16:00:00+01	1	2	2.35	3.2	3	3.1	2.0	1	0	1	1	4.0	2.7	2.3	3.7	{0.5,1.5,2.25,2.5,3.5,4.5,5.5}	{1.1,1.44,2.13,2.35,4.33,10.0,21.0}	{7.5,2.75,1.75,1.6,1.2,1.06,1.01}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.53,1.75,3.4,10.0,17.0,29.0}	{2.5,2.05,1.3,1.06,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.5,6.0,17.0}	{3.4,1.53,1.12,1.02}	https://www.oddsportal.com/football/greece/super-league-2021-2022/panetolikos-ofi-crete-r9BGPHbt/#1X2;2	2023-05-07 22:27:04.548197+01
444	PAOK	Volos	2021-10-17 16:00:00+01	4	4	1.27	5.75	13	1.75	2.62	3	0	1	4	9.0	1.57	3.1	8.5	{0.5,1.5,2.5,2.75,3.5,4.5,5.5,6.5}	{1.05,1.22,1.7,1.9,2.62,5.0,10.0,21.0}	{12.5,4.33,2.11,1.95,1.44,1.17,1.06,1.01}	{0.5,1.0,1.25,1.5,2.5,3.5,4.5}	{1.36,2.07,2.5,6.0,17.0,21.0}	{3.4,1.72,1.5,1.12,1.02,1.01}	{0.5,1.5,2.5,3.5,4.5}	{1.25,2.0,4.0,10.0,23.0}	{4.5,1.83,1.25,1.06,1.01}	https://www.oddsportal.com/football/greece/super-league-2021-2022/paok-volos-xWAKOyEn/#1X2;2	2023-05-07 22:27:36.28428+01
445	Panathinaikos	Ionikos	2021-10-16 20:30:00+01	4	1	1.47	4.35	9	2.05	2.25	0	2	1	2	7.0	1.78	2.6	6.5	{0.5,1.5,2.5,3.5,4.5,5.5,6.5}	{1.07,1.32,1.98,3.4,7.0,15.0}	{9.5,3.4,1.88,1.33,1.11,1.03}	{0.5,1.0,1.5,2.5,3.5,4.5}	{1.44,1.9,2.8,8.0,21.0,29.0}	{2.75,1.9,1.4,1.1,1.02,1.0}	{0.5,1.5,2.5,3.5,4.5}	{1.29,2.2,4.6,13.0}	{3.75,1.66,1.18,1.04}	https://www.oddsportal.com/football/greece/super-league-2021-2022/panathinaikos-ionikos-YaqmspUD/#1X2;2	2023-05-07 22:28:07.623174+01
446	Apollon Smyrnis	Asteras Tripolis	2021-10-16 18:15:00+01	0	1	3.4	3.1	2	4.33	1.9	1	0	0	0	3.25	3.7	2.2	2.8	{0.5,1.5,2.0,2.5,3.5,4.5,5.5}	{1.11,1.53,2.05,2.7,5.5,13.0,17.0}	{6.5,2.37,1.8,1.46,1.16,1.04,1.01}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.61,1.9,4.0,13.0}	{2.25,1.9,1.25,1.04}	{0.5,1.5,2.5,3.5}	{1.4,2.75,7.0,21.0}	{3.0,1.44,1.1,1.01}	https://www.oddsportal.com/football/greece/super-league-2021-2022/apollon-smyrnis-asteras-tripolis-Wf54I0iD/#1X2;2	2023-05-07 22:28:37.879989+01
447	Ionikos	Lamia	2021-10-03 20:30:00+01	1	2	2.7	2.8	3	3.5	1.83	1	0	1	1	4.0	3.1	2.1	3.25	{0.5,1.5,1.75,2.0,2.5,3.5,4.5,5.5}	{1.12,1.57,1.77,2.1,2.75,5.5,15.0,26.0}	{6.0,2.3,2.1,1.77,1.44,1.14,1.04,1.01}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.66,1.9,4.0,13.0}	{2.2,1.9,1.25,1.04}	{0.5,1.5,2.5,3.5}	{1.4,2.75,8.0,21.0}	{2.75,1.4,1.09,1.01}	https://www.oddsportal.com/football/greece/super-league-2021-2022/ionikos-lamia-WWMHR4UQ/#1X2;2	2023-05-07 22:29:07.840544+01
448	Olympiacos Piraeus	Panathinaikos	2021-10-03 20:30:00+01	0	0	1.41	5.0	10	1.95	2.3	0	0	0	0	8.5	1.72	2.75	7.5	{0.5,1.5,2.25,2.5,3.5,4.5,5.5}	{1.06,1.31,1.95,3.5,7.0,15.0}	{10.0,3.4,1.9,1.33,1.11,1.03}	{0.5,1.0,1.5,2.5,3.5,4.5}	{1.44,1.85,3.0,8.0,23.0}	{2.75,1.95,1.4,1.1,1.01}	{0.5,1.5,2.5,3.5}	{1.3,2.2,4.75,13.0}	{4.0,1.66,1.18,1.04}	https://www.oddsportal.com/football/greece/super-league-2021-2022/olympiacos-piraeus-panathinaikos-lC9qNOxr/#1X2;2	2023-05-07 22:29:41.28276+01
449	OFI Crete	PAOK	2021-10-03 18:15:00+01	1	3	8.5	3.9	2	7.25	2.2	2	1	1	0	2.15	7.0	2.5	1.83	{0.5,1.5,2.25,2.5,3.5,4.5,5.5}	{1.08,1.4,1.98,2.2,4.0,9.0,19.0}	{8.5,3.0,1.88,1.65,1.22,1.08,1.02}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.5,2.1,3.25,9.0,26.0,29.0}	{2.62,1.7,1.33,1.07,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.5,5.5,15.0}	{3.5,1.57,1.14,1.03}	https://www.oddsportal.com/football/greece/super-league-2021-2022/ofi-crete-paok-2FDmMrhl/#1X2;2	2023-05-07 22:30:11.922063+01
450	Atromitos	Giannina	2021-10-03 16:00:00+01	1	1	2.35	3.1	3	3.1	2.0	1	0	0	1	3.8	2.75	2.25	3.5	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5}	{1.11,1.5,2.05,2.42,4.5,10.0,21.0}	{7.5,2.75,1.8,1.6,1.2,1.06,1.01}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.57,1.72,3.5,10.0,17.0}	{2.5,2.07,1.3,1.06,1.01}	{0.5,1.5,2.5,3.5}	{1.36,2.5,6.0,17.0}	{3.4,1.53,1.12,1.02}	https://www.oddsportal.com/football/greece/super-league-2021-2022/atromitos-giannina-CU6GTQaE/#1X2;2	2023-05-07 22:30:42.663131+01
451	Panetolikos	AEK Athens FC	2021-10-03 16:00:00+01	1	3	5.3	3.6	2	5.5	2.1	1	1	2	0	2.45	5.0	2.45	2.05	{0.5,1.5,2.25,2.5,3.5,4.5,5.5}	{1.08,1.36,1.9,2.1,3.75,8.0,19.0}	{8.5,3.0,1.95,1.75,1.28,1.09,1.02}	{0.5,1.0,1.5,2.5,3.5,4.5}	{1.5,2.07,3.25,10.0,26.0}	{2.65,1.72,1.36,1.07,1.01}	{0.5,1.5,2.5,3.5}	{1.33,2.37,5.0,15.0}	{3.75,1.61,1.16,1.03}	https://www.oddsportal.com/football/greece/super-league-2021-2022/panetolikos-aek-pv3hL27f/#1X2;2	2023-05-07 22:31:13.477539+01
452	Aris	Apollon Smyrnis	2021-10-02 20:30:00+01	0	0	1.48	4.33	9	2.1	2.25	0	0	0	0	7.25	1.8	2.65	6.75	{0.5,1.5,2.25,2.5,3.5,4.5,5.5}	{1.07,1.33,1.85,2.07,3.75,8.0,17.0}	{9.0,3.25,2.0,1.73,1.28,1.1,1.03}	{0.5,1.0,1.5,2.5,3.5,4.5}	{1.5,2.02,3.25,9.0,26.0,29.0}	{2.62,1.77,1.36,1.07,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.3,2.3,5.5,15.0}	{3.75,1.63,1.17,1.04}	https://www.oddsportal.com/football/greece/super-league-2021-2022/aris-apollon-smyrnis-Yw8CU6p8/#1X2;2	2023-05-07 22:31:43.402298+01
453	Volos	Asteras Tripolis	2021-10-02 16:00:00+01	2	1	2.85	3.1	3	3.6	1.95	1	1	0	1	3.6	3.2	2.25	3.1	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5}	{1.12,1.5,1.8,2.5,4.75,11.0,23.0}	{7.5,2.62,2.05,1.57,1.2,1.06,1.01}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.6,1.77,3.5,11.0,17.0,34.0}	{2.37,2.02,1.28,1.05,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.37,2.6,6.25,17.0}	{3.4,1.5,1.12,1.02}	https://www.oddsportal.com/football/greece/super-league-2021-2022/volos-asteras-tripolis-htODSpFK/#1X2;2	2023-05-07 22:32:14.576626+01
454	Apollon Smyrnis	Ionikos	2021-09-27 19:30:00+01	0	0	2.35	3.25	3	3.25	1.95	0	0	0	0	4.0	2.87	2.2	3.5	{0.5,1.5,2.0,2.5,3.5,4.5,5.5}	{1.11,1.5,1.93,2.5,5.0,11.0,26.0}	{7.0,2.5,1.93,1.53,1.17,1.05,1.01}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.57,1.82,3.75,11.0,17.0,34.0}	{2.37,1.97,1.28,1.05,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.62,6.5,19.0}	{3.25,1.45,1.11,1.02}	https://www.oddsportal.com/football/greece/super-league-2021-2022/apollon-smyrnis-ionikos-EZznEo0R/#1X2;2	2023-05-07 22:32:44.52541+01
455	Atromitos	Aris	2021-09-27 19:30:00+01	1	3	3.75	3.0	2	4.6	1.83	2	0	1	1	3.2	4.2	2.05	2.8	{0.5,1.5,1.75,2.0,2.25,2.5,3.5,4.5,5.5}	{1.14,1.66,1.93,2.1,3.1,6.5,17.0,21.0}	{5.5,2.2,1.93,1.77,1.4,1.12,1.02,1.01}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.66,2.02,4.33,15.0,21.0,41.0}	{2.1,1.77,1.22,1.03,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.5,3.25,9.0,26.0}	{2.65,1.36,1.07,1.01}	https://www.oddsportal.com/football/greece/super-league-2021-2022/atromitos-aris-pIRH8PNl/#1X2;2	2023-05-07 22:33:15.700447+01
456	Giannina	OFI Crete	2021-09-27 17:15:00+01	1	1	2.45	3.2	3	3.1	1.95	0	0	1	1	4.2	2.75	2.2	3.7	{0.5,1.5,2.0,2.5,3.5,4.5,5.5}	{1.12,1.53,2.05,2.7,5.0,13.0,26.0}	{7.0,2.5,1.8,1.48,1.16,1.04,1.01}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.61,1.9,3.75,11.0,17.0,34.0}	{2.25,1.9,1.25,1.05,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.4,2.65,7.0,19.0}	{3.0,1.44,1.1,1.02}	https://www.oddsportal.com/football/greece/super-league-2021-2022/giannina-ofi-crete-WAosFRpL/#1X2;2	2023-05-07 22:33:46.408331+01
457	PAOK	AEK Athens FC	2021-09-26 20:30:00+01	2	0	2.3	3.1	3	3.2	2.05	0	1	0	1	4.0	2.62	2.3	3.7	{0.5,1.5,2.25,2.5,3.5,4.5,5.5}	{1.1,1.4,1.98,2.25,4.33,10.0,21.0}	{7.5,2.75,1.88,1.65,1.22,1.07,1.01}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.53,1.7,3.4,10.0,19.5,34.0}	{2.5,2.1,1.33,1.06,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.37,6.0,17.0}	{3.4,1.53,1.13,1.02}	https://www.oddsportal.com/football/greece/super-league-2021-2022/paok-aek-6XFQ63h1/#1X2;2	2023-05-07 22:34:17.791416+01
458	Lamia	Panetolikos	2021-09-26 18:15:00+01	2	2	2.2	3.1	4	3.0	1.9	1	1	1	1	4.33	2.7	2.2	3.9	{0.5,1.5,1.75,2.0,2.5,3.5,4.5,5.5}	{1.12,1.57,1.8,2.1,2.87,5.0,13.0,26.0}	{6.5,2.5,2.05,1.77,1.48,1.16,1.04,1.01}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.66,1.95,3.75,13.0,29.0,34.0}	{2.25,1.85,1.25,1.04,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.4,2.75,7.0,19.0}	{3.0,1.44,1.1,1.02}	https://www.oddsportal.com/football/greece/super-league-2021-2022/lamia-panetolikos-KzKU5N77/#1X2;2	2023-05-07 22:34:49.671097+01
459	Asteras Tripolis	Olympiacos Piraeus	2021-09-26 16:00:00+01	0	2	5.77	3.65	2	6.0	2.1	0	0	2	0	2.37	5.5	2.45	2.0	{0.5,1.5,2.25,2.5,3.5,4.5,5.5}	{1.08,1.4,2.05,2.3,4.33,10.0,21.0}	{8.0,2.9,1.8,1.65,1.25,1.07,1.02}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.5,1.72,2.1,3.4,10.0,26.0,29.0}	{2.55,2.07,1.7,1.34,1.07,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.5,6.0,17.0}	{3.4,1.55,1.14,1.02}	https://www.oddsportal.com/football/greece/super-league-2021-2022/asteras-tripolis-olympiacos-piraeus-GrND958r/#1X2;2	2023-05-07 22:35:21.093505+01
460	Panathinaikos	Volos	2021-09-26 16:00:00+01	5	1	1.7	3.9	6	2.38	2.2	1	1	0	4	5.5	2.1	2.45	5.0	{0.5,1.5,2.25,2.5,3.5,4.5,5.5}	{1.07,1.36,1.88,2.1,3.75,8.0,19.0}	{9.0,3.0,1.98,1.7,1.25,1.08,1.02}	{0.5,1.0,1.5,2.5,3.5,4.5}	{1.5,2.05,3.25,9.0,26.0,29.0}	{2.75,1.75,1.35,1.07,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.33,2.38,5.5,15.0}	{3.5,1.57,1.14,1.03}	https://www.oddsportal.com/football/greece/super-league-2021-2022/panathinaikos-volos-O8QL7qwe/#1X2;2	2023-05-07 22:35:51.676095+01
461	Volos	Atromitos	2021-09-23 20:30:00+01	3	0	2.0	3.4	4	2.75	2.05	0	3	0	0	4.5	2.5	2.3	4.0	{0.5,1.5,2.25,2.5,3.5,4.5,5.5}	{1.08,1.4,2.02,2.25,4.35,9.5,21.0}	{8.0,2.95,1.83,1.65,1.22,1.07,1.02}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.53,1.7,3.4,10.0,26.0}	{2.55,2.1,1.34,1.06,1.01}	{0.5,1.5,2.5,3.5}	{1.33,2.43,5.5,15.0}	{3.5,1.55,1.14,1.03}	https://www.oddsportal.com/football/greece/super-league-2021-2022/volos-atromitos-ry0oAHsd/#1X2;2	2023-05-07 22:36:22.54908+01
462	Ionikos	Giannina	2021-09-23 18:15:00+01	0	0	2.45	3.0	3	3.25	1.9	0	0	0	0	4.2	2.85	2.2	3.7	{0.5,1.5,2.0,2.5,3.5,4.5,5.5}	{1.12,1.53,2.02,2.7,5.5,13.0,26.0}	{6.5,2.45,1.83,1.44,1.15,1.04,1.01}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.61,1.9,4.0,13.0,11.0}	{2.28,1.9,1.25,1.04,1.01}	{0.5,1.5,2.5,3.5}	{1.4,2.8,7.0,19.0}	{3.0,1.44,1.1,1.02}	https://www.oddsportal.com/football/greece/super-league-2021-2022/ionikos-giannina-MRbk9yc2/#1X2;2	2023-05-07 22:36:54.047409+01
463	AEK Athens FC	Lamia	2021-09-22 20:30:00+01	1	0	1.3	5.0	12	1.8	2.4	0	1	0	0	9.5	1.65	2.85	9.0	{0.5,1.5,2.25,2.5,2.75,3.5,4.5,5.5,6.5}	{1.07,1.33,1.77,1.98,3.5,7.0,15.0}	{11.5,3.65,2.1,1.88,1.3,1.11,1.03}	{0.5,1.0,1.5,2.5,3.5,4.5}	{1.44,1.87,3.0,8.0,23.0,26.0}	{3.05,1.92,1.4,1.1,1.01,1.01}	{0.5,1.5,2.5,3.5,4.5}	{1.3,2.3,5.0,13.0}	{3.75,1.62,1.16,1.04}	https://www.oddsportal.com/football/greece/super-league-2021-2022/aek-lamia-zBdwCwDq/#1X2;2	2023-05-07 22:37:25.710835+01
464	Aris	Panathinaikos	2021-09-22 20:30:00+01	1	0	2.0	3.25	4	2.87	1.9	0	0	0	1	5.5	2.45	2.2	4.5	{0.5,1.5,1.75,2.0,2.25,2.5,3.5,4.5,5.5}	{1.12,1.61,1.83,2.87,6.0,15.0,17.0}	{6.0,2.3,2.02,1.45,1.14,1.04,1.01}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.66,1.95,4.0,15.0,21.0,34.0}	{2.2,1.85,1.25,1.04,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.44,3.0,8.0,21.0}	{2.75,1.4,1.08,1.01}	https://www.oddsportal.com/football/greece/super-league-2021-2022/aris-panathinaikos-lE0sBcSk/#1X2;2	2023-05-07 22:37:57.900272+01
465	OFI Crete	Asteras Tripolis	2021-09-22 18:15:00+01	0	0	2.6	3.1	3	3.25	2.0	0	0	0	0	3.6	2.9	2.3	3.25	{0.5,1.5,2.25,2.5,3.5,4.5,5.5}	{1.1,1.44,2.05,2.3,4.33,10.0,21.0}	{7.5,2.75,1.8,1.61,1.22,1.06,1.01}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.53,1.72,3.4,10.0,17.0}	{2.5,2.07,1.33,1.06,1.01}	{0.5,1.5,2.5,3.5}	{1.33,2.4,6.0,17.0}	{3.4,1.53,1.12,1.02}	https://www.oddsportal.com/football/greece/super-league-2021-2022/ofi-crete-asteras-tripolis-v3TZGmG8/#1X2;2	2023-05-07 22:38:28.903891+01
466	Olympiacos Piraeus	Apollon Smyrnis	2021-09-22 18:15:00+01	4	1	1.2	8.0	19	1.57	2.88	1	3	0	1	10.5	1.44	3.5	10.0	{0.5,1.5,2.5,3.0,3.25,3.5,4.5,5.5,6.5,7.5}	{1.02,1.17,1.6,2.0,2.37,4.2,8.0,17.0}	{17.0,5.3,2.45,1.85,1.54,1.22,1.08,1.02}	{0.5,1.25,1.5,2.5,3.5,4.5}	{1.3,1.97,2.25,5.5,15.0,17.0}	{3.8,1.82,1.66,1.16,1.04,1.01}	{0.5,1.5,2.5,3.5,4.5}	{1.2,1.9,3.5,8.0,19.0}	{5.5,1.95,1.28,1.08,1.02}	https://www.oddsportal.com/football/greece/super-league-2021-2022/olympiacos-piraeus-apollon-smyrnis-0CUVHT02/#1X2;2	2023-05-07 22:38:59.786861+01
467	Panetolikos	PAOK	2021-09-22 18:15:00+01	1	2	7.0	3.6	2	6.5	2.1	1	1	1	0	2.25	6.0	2.43	1.95	{0.5,1.5,2.25,2.5,3.5,4.5,5.5}	{1.08,1.4,1.98,2.2,4.0,9.0,19.0}	{9.0,3.15,1.88,1.67,1.25,1.07,1.02}	{0.5,1.0,1.5,2.5,3.5,4.5}	{1.5,2.1,3.25,10.0,26.0}	{2.7,1.7,1.33,1.06,1.01}	{0.5,1.5,2.5,3.5}	{1.33,2.37,5.5,15.0}	{3.5,1.53,1.14,1.03}	https://www.oddsportal.com/football/greece/super-league-2021-2022/panetolikos-paok-YPSwG7VE/#1X2;2	2023-05-07 22:39:32.729115+01
468	Asteras Tripolis	PAOK	2021-09-19 20:30:00+01	0	1	3.8	3.2	2	4.0	2.05	0	0	1	0	2.87	3.5	2.37	2.6	{0.5,1.5,2.25,2.5,3.5,4.5,5.5}	{1.07,1.36,1.88,2.1,3.75,8.0,17.0}	{9.0,3.25,1.98,1.7,1.26,1.08,1.02}	{0.5,1.0,1.5,2.5,3.5,4.5}	{1.44,2.05,3.25,9.0,26.0,29.0}	{2.62,1.75,1.36,1.07,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.3,2.2,5.0,13.0}	{3.75,1.61,1.16,1.04}	https://www.oddsportal.com/football/greece/super-league-2021-2022/asteras-tripolis-paok-McXgK153/#1X2;2	2023-05-07 22:40:02.846283+01
469	Lamia	Olympiacos Piraeus	2021-09-19 20:30:00+01	1	2	9.0	4.6	1	7.25	2.3	0	1	2	0	2.05	7.0	2.85	1.8	{0.5,1.5,2.5,2.75,3.5,4.5,5.5,6.5}	{1.05,1.26,1.9,3.25,6.0,13.0,26.0}	{11.0,3.75,1.98,1.36,1.12,1.04,1.01}	{0.5,1.0,1.25,1.5,2.5,3.5,4.5}	{1.4,1.8,2.75,7.0,21.0,26.0}	{3.0,2.0,1.44,1.1,1.02,1.01}	{0.5,1.5,2.5,3.5,4.5}	{1.25,2.1,4.33,11.0,26.0}	{4.0,1.75,1.2,1.05,1.01}	https://www.oddsportal.com/football/greece/super-league-2021-2022/lamia-olympiacos-piraeus-UTJAGJ4S/#1X2;2	2023-05-07 22:40:33.46289+01
470	Atromitos	Panetolikos	2021-09-19 18:15:00+01	1	2	1.75	3.3	5	2.45	2.05	2	0	0	1	5.5	2.15	2.37	4.75	{0.5,1.5,2.25,2.5,3.5,4.5,5.5}	{1.08,1.4,2.0,2.25,4.0,9.0,19.0}	{8.0,3.0,1.85,1.66,1.25,1.07,1.02}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.5,1.7,2.1,3.25,10.0,26.0,29.0}	{2.62,2.1,1.7,1.33,1.07,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.33,2.37,5.5,15.0}	{3.5,1.57,1.14,1.03}	https://www.oddsportal.com/football/greece/super-league-2021-2022/atromitos-panetolikos-4MMbJLK9/#1X2;2	2023-05-07 22:41:05.018687+01
471	OFI Crete	AEK Athens FC	2021-09-19 18:15:00+01	3	3	5.5	3.75	2	5.5	2.2	1	3	2	0	2.3	4.8	2.55	2.0	{0.5,1.5,2.5,3.5,4.5,5.5,6.5}	{1.07,1.3,2.0,3.4,7.0,15.0,26.0}	{9.5,3.5,1.85,1.33,1.11,1.03,1.01}	{0.5,1.0,1.5,2.5,3.5,4.5}	{1.44,1.9,2.75,8.0,21.0,29.0}	{2.75,1.9,1.4,1.1,1.01,1.0}	{0.5,1.5,2.5,3.5,4.5}	{1.28,2.1,4.5,11.0,26.0}	{4.0,1.66,1.18,1.05,1.01}	https://www.oddsportal.com/football/greece/super-league-2021-2022/ofi-crete-aek-jwL6HakM/#1X2;2	2023-05-07 22:41:35.612857+01
472	Apollon Smyrnis	Volos	2021-09-19 16:00:00+01	1	3	2.35	3.0	3	3.2	1.95	2	1	1	0	4.0	2.75	2.25	3.5	{0.5,1.5,2.0,2.5,3.5,4.5,5.5}	{1.1,1.5,1.77,2.37,4.5,11.0,23.0}	{7.0,2.62,2.1,1.57,1.2,1.05,1.01}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.6,1.75,3.5,11.0,17.0,34.0}	{2.37,2.05,1.28,1.05,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.55,6.0,17.0}	{3.4,1.5,1.12,1.02}	https://www.oddsportal.com/football/greece/super-league-2021-2022/apollon-smyrnis-volos-8fTkLsjc/#1X2;2	2023-05-07 22:42:06.597116+01
473	Giannina	Panathinaikos	2021-09-18 20:30:00+01	1	0	3.2	3.1	2	3.9	1.95	0	0	0	1	3.3	3.6	2.25	2.87	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5}	{1.1,1.48,1.83,2.4,4.5,11.0,23.0}	{7.5,2.62,2.02,1.57,1.2,1.06,1.01}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.57,1.77,3.5,11.0,17.0,34.0}	{2.37,2.02,1.3,1.05,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.55,6.5,17.0}	{3.25,1.5,1.12,1.02}	https://www.oddsportal.com/football/greece/super-league-2021-2022/giannina-panathinaikos-fiu8dbDd/#1X2;2	2023-05-07 22:42:36.738+01
474	Ionikos	Aris	2021-09-17 19:00:00+01	1	0	4.8	3.4	2	5.5	2.05	0	1	0	0	2.5	4.75	2.3	2.25	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5}	{1.1,1.44,1.8,2.35,4.33,10.0,21.0}	{7.5,2.75,2.05,1.57,1.2,1.06,1.01}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.53,1.75,3.5,11.0,17.0}	{2.5,2.05,1.3,1.06,1.01}	{0.5,1.5,2.5,3.5}	{1.36,2.5,6.0,17.0}	{3.4,1.5,1.12,1.02}	https://www.oddsportal.com/football/greece/super-league-2021-2022/ionikos-aris-rDL2IuzG/#1X2;2	2023-05-07 22:43:06.869062+01
475	Aris	OFI Crete	2021-09-13 19:30:00+01	0	0	1.45	4.1	9	2.2	2.2	0	0	0	0	7.5	1.8	2.5	7.0	{0.5,1.5,2.25,2.5,3.5,4.5,5.5}	{1.08,1.44,1.9,2.25,4.0,9.0,21.0}	{8.0,2.75,1.95,1.7,1.22,1.07,1.02}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.53,1.67,2.05,3.25,9.0,26.0,29.0}	{2.62,2.15,1.75,1.33,1.07,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.5,6.0,17.0}	{3.4,1.53,1.12,1.02}	https://www.oddsportal.com/football/greece/super-league-2021-2022/aris-ofi-crete-6iY6ZwAE/#1X2;2	2023-05-07 22:43:38.376979+01
476	AEK Athens FC	Ionikos	2021-09-12 20:30:00+01	3	0	1.16	6.5	21	1.57	2.6	0	2	0	1	15.0	1.4	3.3	13.5	{0.5,1.5,2.5,2.75,3.5,4.5,5.5,6.5}	{1.05,1.25,1.76,1.98,2.75,5.5,11.0,23.0}	{11.0,4.0,2.07,1.88,1.4,1.15,1.05,1.01}	{0.5,1.0,1.25,1.5,2.5,3.5,4.5}	{1.36,1.7,2.1,2.5,6.5,19.0,26.0}	{3.25,2.1,1.7,1.5,1.12,1.02,1.01}	{0.5,1.5,2.5,3.5,4.5}	{1.28,2.1,4.33,11.0,26.0}	{4.33,1.8,1.22,1.05,1.01}	https://www.oddsportal.com/football/greece/super-league-2021-2022/aek-ionikos-S0Z2zKf8/#1X2;2	2023-05-07 22:44:08.86063+01
477	Olympiacos Piraeus	Atromitos	2021-09-12 20:30:00+01	0	0	1.18	6.5	19	1.61	2.62	0	0	0	0	13.0	1.44	3.2	12.5	{0.5,1.5,2.5,2.75,3.5,4.5,5.5,6.5}	{1.05,1.25,1.75,1.98,2.9,5.5,11.0,23.0}	{11.0,4.0,2.07,1.88,1.4,1.15,1.05,1.01}	{0.5,1.0,1.25,1.5,2.5,3.5,4.5}	{1.4,1.7,2.1,2.62,6.5,17.0,26.0}	{3.25,2.1,1.7,1.5,1.11,1.02,1.01}	{0.5,1.5,2.5,3.5,4.5}	{1.28,2.05,4.33,11.0,26.0}	{4.33,1.8,1.22,1.05,1.01}	https://www.oddsportal.com/football/greece/super-league-2021-2022/olympiacos-piraeus-atromitos-EHyFXHvR/#1X2;2	2023-05-07 22:44:39.245303+01
478	PAOK	Giannina	2021-09-12 19:00:00+01	0	1	1.18	6.5	19	1.66	2.55	1	0	0	0	12.0	1.44	3.1	12.5	{0.5,1.5,2.5,3.5,4.5,5.5,6.5}	{1.07,1.28,1.88,3.25,6.0,13.0,26.0}	{9.5,3.75,1.98,1.36,1.12,1.04,1.01}	{0.5,1.0,1.5,2.5,3.5,4.5}	{1.4,1.8,2.75,7.0,21.0,26.0}	{3.0,2.0,1.42,1.1,1.02,1.01}	{0.5,1.5,2.5,3.5,4.5}	{1.28,2.2,4.5,11.0,26.0}	{4.0,1.72,1.2,1.05,1.01}	https://www.oddsportal.com/football/greece/super-league-2021-2022/paok-giannina-SOHkRFHf/#1X2;2	2023-05-07 22:45:10.163421+01
479	Volos	Lamia	2021-09-12 18:15:00+01	2	1	2.2	3.0	4	3.0	1.95	1	0	0	2	4.4	2.62	2.25	4.0	{0.5,1.5,2.0,2.5,3.5,4.5,5.5}	{1.12,1.53,2.0,2.62,5.0,11.0,23.0}	{7.0,2.62,1.85,1.48,1.18,1.05,1.01}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.6,1.85,3.6,11.0,26.0,34.0}	{2.37,1.95,1.29,1.05,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.4,2.7,6.5,17.0}	{3.4,1.5,1.12,1.02}	https://www.oddsportal.com/football/greece/super-league-2021-2022/volos-lamia-0EXAYcPK/#1X2;2	2023-05-07 22:45:39.175341+01
480	Panathinaikos	Apollon Smyrnis	2021-09-11 20:30:00+01	4	0	1.5	4.1	7	2.2	2.1	0	2	0	2	6.5	1.91	2.5	6.25	{0.5,1.5,2.25,2.5,3.5,4.5,5.5}	{1.1,1.4,2.02,2.25,4.33,10.0,21.0}	{7.5,2.75,1.83,1.65,1.22,1.07,1.02}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.53,1.7,2.1,3.4,10.0,26.0,29.0}	{2.5,2.1,1.7,1.33,1.07,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.38,6.0,17.0}	{3.4,1.53,1.13,1.02}	https://www.oddsportal.com/football/greece/super-league-2021-2022/panathinaikos-apollon-smyrnis-KbEsTymr/#1X2;2	2023-05-07 22:46:08.85699+01
481	Panetolikos	Asteras Tripolis	2021-09-11 18:15:00+01	0	0	3.4	3.0	3	4.0	1.95	0	0	0	0	3.3	3.6	2.2	3.0	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5}	{1.11,1.5,1.93,2.5,4.6,11.0,23.0}	{6.5,2.62,1.93,1.53,1.18,1.05,1.02}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.57,1.85,3.5,11.0,17.0,34.0}	{2.37,1.95,1.29,1.05,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.65,6.5,17.0}	{3.25,1.5,1.11,1.02}	https://www.oddsportal.com/football/greece/super-league-2021-2022/panetolikos-asteras-tripolis-bkDoSe2l/#1X2;2	2023-05-07 22:46:39.2751+01
482	Panetolikos	Xanthi FC	2021-05-30 19:30:00+01	1	0	1.7	3.6	6	2.4	2.0	0	1	0	0	6.0	2.15	2.3	5.75	{0.5,1.5,2.0,2.5,3.5,4.5,5.5}	{1.11,1.53,1.98,2.62,5.0,13.0,26.0}	{6.5,2.5,1.88,1.48,1.16,1.04,1.01}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.62,1.82,3.75,11.0,17.0,34.0}	{2.35,1.97,1.29,1.05,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.4,2.75,7.0,19.0}	{3.0,1.44,1.1,1.02}	https://www.oddsportal.com/football/greece/super-league-2020-2021/panetolikos-xanthi-A1rJFfe6/#1X2;2	2023-05-07 22:47:36.768771+01
483	Xanthi FC	Panetolikos	2021-05-26 15:30:00+01	2	1	2.75	2.9	3	3.8	1.83	0	2	1	0	4.0	3.25	2.05	3.3	{0.5,1.5,1.75,2.0,2.5,3.5,4.5,5.5}	{1.15,1.67,1.98,3.4,7.0,17.0,21.0}	{5.5,2.15,1.88,1.37,1.11,1.02,1.01}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.73,2.05,4.33,15.0,31.0,41.0}	{2.1,1.75,1.2,1.03,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.5,3.25,9.0,26.0}	{2.62,1.36,1.08,1.02}	https://www.oddsportal.com/football/greece/super-league-2020-2021/xanthi-panetolikos-hQmEGzt0/#1X2;2	2023-05-07 22:48:07.724233+01
484	Giannina	Apollon Smyrnis	2021-05-19 17:15:00+01	0	2	2.25	3.1	4	3.0	1.96	1	0	1	0	4.33	2.6	2.25	3.95	{0.5,1.5,2.0,2.5,3.5,4.5,5.5}	{1.11,1.5,1.8,2.5,4.9,11.0,23.0}	{7.5,2.7,2.05,1.57,1.18,1.05,1.01}	{0.5,0.75,1.5,2.5,3.5}	{1.57,1.77,3.55,11.0,17.0}	{2.45,2.02,1.28,1.05,1.01}	{0.5,1.5,2.5,3.5}	{1.4,2.65,6.0,17.0}	{3.25,1.5,1.12,1.02}	https://www.oddsportal.com/football/greece/super-league-2020-2021/giannina-apollon-smyrnis-bg5zDb7U/#1X2;2	2023-05-07 22:48:38.524141+01
485	AEK Athens FC	Aris	2021-05-16 19:30:00+01	0	0	2.35	3.2	3	3.05	2.1	0	0	0	0	3.9	2.7	2.5	3.45	{0.5,1.5,2.25,2.5,3.5,4.5,5.5}	{1.07,1.35,1.8,2.08,3.8,8.0,15.0}	{10.0,3.5,2.05,1.88,1.33,1.11,1.03}	{0.5,1.0,1.5,2.5,3.5}	{1.45,1.9,3.25,9.0,26.0}	{2.75,1.9,1.4,1.08,1.01}	{0.5,1.5,2.5,3.5}	{1.28,2.23,5.0,13.0}	{3.75,1.66,1.16,1.04}	https://www.oddsportal.com/football/greece/super-league-2020-2021/aek-aris-Yy7dbglk/#1X2;2	2023-05-07 22:49:08.596022+01
486	Panathinaikos	Olympiacos Piraeus	2021-05-16 19:30:00+01	1	4	5.75	3.8	2	5.5	2.25	1	1	3	0	2.3	5.0	2.6	2.05	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.06,1.3,2.06,3.8,8.0,13.0,26.0}	{11.0,3.5,2.0,1.36,1.12,1.04,1.01}	{0.5,0.75,1.0,1.5,2.5,3.5}	{1.4,1.77,3.05,7.0,21.0}	{3.25,2.02,1.4,1.1,1.02}	{0.5,1.5,2.5,3.5}	{1.25,2.25,4.5,11.0}	{4.0,1.72,1.2,1.05}	https://www.oddsportal.com/football/greece/super-league-2020-2021/panathinaikos-olympiacos-piraeus-nuB0cD3e/#1X2;2	2023-05-07 22:49:42.713618+01
487	PAOK	Asteras Tripolis	2021-05-16 19:30:00+01	0	1	1.4	5.0	8	1.95	2.45	0	0	1	0	6.75	1.75	2.85	6.75	{0.5,1.5,2.5,2.75,3.5,4.5,5.5,6.5}	{1.05,1.25,1.78,1.95,3.1,6.1,11.0,23.0}	{13.0,4.0,2.11,1.9,1.4,1.15,1.05,1.01}	{0.5,1.0,1.25,1.5,2.5,3.5}	{1.4,1.7,2.1,2.63,6.5,19.0}	{3.25,2.1,1.7,1.48,1.11,1.02}	{0.5,1.5,2.5,3.5,4.5}	{1.22,2.02,4.33,10.0,26.0}	{4.33,1.8,1.22,1.06,1.01}	https://www.oddsportal.com/football/greece/super-league-2020-2021/paok-asteras-tripolis-U305dXI1/#1X2;2	2023-05-07 22:50:13.711047+01
488	AEL Larissa	Giannina	2021-05-15 19:30:00+01	2	0	2.7	3.4	3	3.5	2.0	0	0	0	2	3.6	3.0	2.25	3.25	{0.5,1.5,2.0,2.5,3.5,4.5,5.5}	{1.1,1.45,1.8,2.4,4.75,11.0,23.0}	{8.0,2.7,2.05,1.57,1.2,1.05,1.01}	{0.5,0.75,1.5,2.5,3.5}	{1.57,1.75,3.55,11.0,17.0}	{2.5,2.05,1.3,1.05,1.01}	{0.5,1.5,2.5,3.5}	{1.36,2.55,6.0,17.0}	{3.4,1.5,1.12,1.02}	https://www.oddsportal.com/football/greece/super-league-2020-2021/ael-larissa-giannina-QuTcUax5/#1X2;2	2023-05-07 22:50:45.892728+01
489	Apollon Smyrnis	Lamia	2021-05-15 19:30:00+01	0	1	2.5	3.2	3	3.3	2.0	0	0	1	0	3.9	2.95	2.25	3.4	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5}	{1.1,1.44,1.88,2.1,2.4,4.5,11.0,23.0}	{8.0,2.85,1.98,1.77,1.6,1.2,1.05,1.01}	{0.5,0.75,1.0,1.5,2.5,3.5}	{1.55,1.8,3.5,11.0,26.0}	{2.55,2.0,1.3,1.06,1.01}	{0.5,1.5,2.5,3.5}	{1.36,2.5,6.0,17.0}	{3.4,1.5,1.12,1.02}	https://www.oddsportal.com/football/greece/super-league-2020-2021/apollon-smyrnis-lamia-4WR1TJiB/#1X2;2	2023-05-07 22:51:16.969946+01
490	Atromitos	Volos	2021-05-15 19:30:00+01	1	0	1.72	3.75	6	2.37	2.23	0	1	0	0	5.0	2.0	2.6	4.8	{0.5,1.5,2.5,2.75,3.5,4.5,5.5,6.5}	{1.06,1.28,1.87,3.35,6.75,13.0,26.0}	{11.0,3.75,1.95,1.36,1.12,1.04,1.01}	{0.5,1.0,1.5,2.5,3.5}	{1.4,1.82,2.8,7.5,21.0}	{3.0,1.97,1.44,1.1,1.02}	{0.5,1.5,2.5,3.5,4.5}	{1.25,2.05,4.33,11.0,26.0}	{4.0,1.72,1.2,1.05,1.01}	https://www.oddsportal.com/football/greece/super-league-2020-2021/atromitos-volos-Y5W5Sw7H/#1X2;2	2023-05-07 22:51:48.387809+01
491	OFI Crete	Panetolikos	2021-05-15 19:30:00+01	2	2	1.72	3.6	5	2.4	2.1	2	1	0	1	5.5	2.12	2.4	5.0	{0.5,1.5,2.25,2.5,3.5,4.5,5.5}	{1.08,1.4,1.9,2.23,4.3,9.0,19.0}	{8.5,2.95,1.95,1.66,1.25,1.07,1.02}	{0.5,0.75,1.0,1.5,2.5,3.5}	{1.53,1.67,2.07,3.3,10.0,26.0}	{2.65,2.15,1.72,1.33,1.06,1.01}	{0.5,1.5,2.5,3.5}	{1.36,2.5,5.5,15.0}	{3.5,1.53,1.14,1.03}	https://www.oddsportal.com/football/greece/super-league-2020-2021/ofi-crete-panetolikos-rHwgVuNb/#1X2;2	2023-05-07 22:52:19.31846+01
492	Aris	Panathinaikos	2021-05-12 19:30:00+01	0	0	1.72	3.75	5	2.37	2.12	0	0	0	0	5.5	2.05	2.45	5.0	{0.5,1.5,2.5,3.5,4.5,5.5}	{1.07,1.36,2.1,4.0,9.0,19.0}	{9.5,3.2,1.72,1.28,1.08,1.02}	{0.5,1.5,2.5,3.5}	{1.5,3.25,9.0,26.0}	{2.8,1.36,1.08,1.01}	{0.5,1.5,2.5,3.5}	{1.33,2.3,5.5,15.0}	{3.5,1.57,1.14,1.03}	https://www.oddsportal.com/football/greece/super-league-2020-2021/aris-panathinaikos-KUQL4eBL/#1X2;2	2023-05-07 22:52:49.061775+01
493	Asteras Tripolis	AEK Athens FC	2021-05-12 19:30:00+01	1	1	3.75	3.4	2	4.0	2.2	1	1	0	0	2.75	3.7	2.5	2.45	{0.5,1.5,2.5,3.5,4.5,5.5,6.5}	{1.06,1.3,1.9,3.3,6.75,13.0,26.0}	{11.0,3.7,1.9,1.36,1.12,1.04,1.01}	{0.5,1.5,2.5,3.5}	{1.44,2.8,8.0,21.0}	{3.0,1.4,1.1,1.01}	{0.5,1.5,2.5,3.5,4.5}	{1.25,2.1,4.33,11.0,26.0}	{4.0,1.72,1.2,1.05,1.01}	https://www.oddsportal.com/football/greece/super-league-2020-2021/asteras-tripolis-aek-x6LQ3FQR/#1X2;2	2023-05-07 22:53:20.267996+01
494	Olympiacos Piraeus	PAOK	2021-05-12 19:30:00+01	1	0	1.78	3.5	5	2.5	2.25	0	0	0	1	4.75	2.15	2.5	4.4	{0.5,1.5,2.5,3.5,4.5,5.5,6.5}	{1.06,1.33,1.93,3.45,7.0,13.0,26.0}	{11.0,3.55,1.9,1.33,1.11,1.04,1.01}	{0.5,1.5,2.5,3.5}	{1.44,3.0,8.0,21.0}	{3.0,1.4,1.08,1.01}	{0.5,1.5,2.5,3.5}	{1.3,2.15,4.5,11.0}	{4.0,1.72,1.2,1.05}	https://www.oddsportal.com/football/greece/super-league-2020-2021/olympiacos-piraeus-paok-vF7haZYr/#1X2;2	2023-05-07 22:53:51.1327+01
495	Panathinaikos	AEK Athens FC	2021-05-09 19:30:00+01	0	1	3.2	3.15	2	3.8	2.0	1	0	0	0	3.2	3.5	2.3	2.8	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5}	{1.1,1.44,2.05,2.35,4.7,10.5,21.0}	{8.0,2.8,1.8,1.61,1.22,1.06,1.01}	{0.5,0.75,1.5,2.5,3.5}	{1.57,1.72,3.45,10.0,20.0}	{2.55,2.07,1.3,1.06,1.01}	{0.5,1.5,2.5,3.5}	{1.36,2.55,6.0,17.0}	{3.4,1.53,1.14,1.02}	https://www.oddsportal.com/football/greece/super-league-2020-2021/panathinaikos-aek-nHSD6Ht9/#1X2;2	2023-05-07 22:54:21.490957+01
496	Asteras Tripolis	Olympiacos Piraeus	2021-05-09 17:15:00+01	0	0	5.25	3.75	2	4.9	2.37	0	0	0	0	2.3	4.4	2.75	2.0	{0.5,1.5,2.25,2.5,2.75,3.0,3.5,4.5,5.5,6.5}	{1.04,1.2,1.66,1.85,2.05,2.6,4.8,9.0,19.0}	{14.0,4.7,2.23,2.0,1.8,1.5,1.2,1.07,1.02}	{0.5,1.0,1.25,1.5,2.5,3.5}	{1.36,1.72,2.07,2.8,6.0,15.0}	{3.4,2.07,1.72,1.53,1.13,1.03}	{0.5,1.5,2.5,3.5,4.5}	{1.2,2.05,3.75,8.0,21.0}	{5.0,1.9,1.28,1.08,1.01}	https://www.oddsportal.com/football/greece/super-league-2020-2021/asteras-tripolis-olympiacos-piraeus-zsP97cR2/#1X2;2	2023-05-07 22:54:53.188705+01
497	PAOK	Aris	2021-05-09 15:00:00+01	2	0	1.72	3.5	6	2.6	2.05	0	2	0	0	6.0	2.1	2.37	5.1	{0.5,1.5,2.25,2.5,3.5,4.5,5.5}	{1.1,1.42,2.02,2.28,4.35,10.0,21.0}	{8.0,2.9,1.83,1.61,1.22,1.07,1.01}	{0.5,0.75,1.5,2.5,3.5}	{1.53,1.7,3.4,10.0,26.0}	{2.55,2.1,1.33,1.06,1.01}	{0.5,1.5,2.5,3.5}	{1.36,2.5,5.5,15.0}	{3.5,1.53,1.14,1.03}	https://www.oddsportal.com/football/greece/super-league-2020-2021/paok-aris-tvSH5ydF/#1X2;2	2023-05-07 22:55:24.07701+01
498	Lamia	OFI Crete	2021-05-08 19:30:00+01	0	2	6.0	3.3	2	6.5	2.0	1	0	1	0	2.5	6.0	2.25	2.18	{0.5,1.5,2.0,2.5,3.5,4.5,5.5}	{1.11,1.55,1.98,2.6,5.2,13.0,26.0}	{7.0,2.55,1.88,1.5,1.16,1.05,1.01}	{0.5,0.75,1.5,2.5,3.5}	{1.66,1.82,3.75,11.0,26.0}	{2.43,1.97,1.25,1.05,1.01}	{0.5,1.5,2.5,3.5}	{1.4,2.75,7.0,19.0}	{3.0,1.44,1.1,1.02}	https://www.oddsportal.com/football/greece/super-league-2020-2021/lamia-ofi-crete-WtzkWL7h/#1X2;2	2023-05-07 22:55:55.459649+01
500	Volos	AEL Larissa	2021-05-08 19:30:00+01	3	1	1.9	3.5	4	2.8	2.02	1	1	0	2	4.6	2.37	2.25	4.6	{0.5,1.5,2.0,2.5,3.5,4.5,5.5}	{1.1,1.5,1.88,2.7,5.75,13.0,26.0}	{7.5,2.5,1.98,1.53,1.16,1.05,1.01}	{0.5,0.75,1.5,2.5,3.5}	{1.6,1.77,3.85,12.0,26.0}	{2.45,2.02,1.28,1.05,1.01}	{0.5,1.5,2.5,3.5}	{1.4,2.7,6.5,19.0}	{3.25,1.44,1.11,1.02}	https://www.oddsportal.com/football/greece/super-league-2020-2021/volos-ael-larissa-bTysYswt/#1X2;2	2023-05-07 22:56:57.396206+01
501	AEK Athens FC	PAOK	2021-05-05 21:30:00+01	1	2	3.2	3.1	3	3.6	2.0	2	1	0	0	3.25	3.25	2.3	2.9	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5}	{1.1,1.44,1.98,2.35,4.33,9.0,19.0}	{8.0,2.75,1.88,1.65,1.22,1.07,1.02}	{0.5,0.75,1.5,2.5,3.5}	{1.57,1.7,3.4,10.0,26.0}	{2.5,2.1,1.3,1.06,1.01}	{0.5,1.5,2.5,3.5}	{1.36,2.5,5.5,15.0}	{3.5,1.53,1.14,1.03}	https://www.oddsportal.com/football/greece/super-league-2020-2021/aek-paok-QBsJpzKk/#1X2;2	2023-05-07 22:57:27.727872+01
502	Panathinaikos	Asteras Tripolis	2021-05-05 19:30:00+01	2	2	1.75	3.3	6	2.5	1.95	0	1	2	1	6.0	2.2	2.25	5.5	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5}	{1.11,1.53,1.88,2.56,5.0,11.0,26.0}	{6.5,2.5,1.98,1.53,1.16,1.05,1.01}	{0.5,0.75,1.5,2.5,3.5}	{1.6,1.8,3.75,11.0,23.0}	{2.3,2.0,1.26,1.05,1.01}	{0.5,1.5,2.5,3.5}	{1.44,2.75,7.0,19.0}	{3.25,1.44,1.1,1.02}	https://www.oddsportal.com/football/greece/super-league-2020-2021/panathinaikos-asteras-tripolis-YyoRrEl2/#1X2;2	2023-05-07 22:57:57.278803+01
503	Aris	Olympiacos Piraeus	2021-05-05 17:15:00+01	1	1	1.9	3.5	4	2.6	2.2	1	0	0	1	4.33	2.3	2.5	4.0	{0.5,1.5,2.25,2.5,3.5,4.5,5.5}	{1.06,1.33,1.83,2.02,3.5,7.0,15.0}	{10.0,3.4,2.02,1.85,1.33,1.12,1.04}	{0.5,0.75,1.0,1.5,2.5,3.5}	{1.5,1.97,3.0,8.0,23.0}	{2.75,1.82,1.4,1.08,1.01}	{0.5,1.5,2.5,3.5}	{1.28,2.2,4.75,13.0}	{4.0,1.66,1.2,1.04}	https://www.oddsportal.com/football/greece/super-league-2020-2021/aris-olympiacos-piraeus-fonNqfZe/#1X2;2	2023-05-07 22:58:31.503978+01
504	Apollon Smyrnis	Volos	2021-04-26 19:30:00+01	0	0	2.05	3.2	4	2.87	2.0	0	0	0	0	4.75	2.45	2.3	4.2	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5}	{1.1,1.44,1.85,2.05,2.4,4.5,11.0,23.0}	{8.0,2.85,2.0,1.8,1.6,1.2,1.06,1.01}	{0.5,0.75,1.0,1.5,2.5,3.5}	{1.53,1.77,3.5,11.0,17.0}	{2.55,2.02,1.3,1.06,1.01}	{0.5,1.5,2.5,3.5}	{1.36,2.5,6.0,17.0}	{3.4,1.5,1.12,1.02}	https://www.oddsportal.com/football/greece/super-league-2020-2021/apollon-smyrnis-volos-K26WDvhO/#1X2;2	2023-05-07 22:59:03.083267+01
505	Olympiacos Piraeus	AEK Athens FC	2021-04-25 19:30:00+01	2	0	2.05	3.5	4	2.75	2.14	0	2	0	0	4.33	2.4	2.43	3.95	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.07,1.33,1.83,2.05,3.8,8.0,17.0}	{10.0,3.3,2.02,1.75,1.3,1.1,1.02}	{0.5,1.0,1.5,2.5,3.5}	{1.44,2.02,3.05,9.0,23.0}	{2.88,1.77,1.4,1.08,1.01}	{0.5,1.5,2.5,3.5,4.5}	{1.28,2.25,5.0,13.0}	{3.75,1.62,1.16,1.04}	https://www.oddsportal.com/football/greece/super-league-2020-2021/olympiacos-piraeus-aek-tv6njddS/#1X2;2	2023-05-07 22:59:33.051001+01
506	Asteras Tripolis	Aris	2021-04-25 17:15:00+01	1	1	4.2	3.4	2	4.75	2.05	1	1	0	0	2.7	4.33	2.3	2.37	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5}	{1.1,1.44,1.77,2.1,2.35,4.5,10.0,21.0}	{8.5,2.9,2.1,1.77,1.6,1.22,1.06,1.01}	{0.5,0.75,1.5,2.5,3.5}	{1.57,1.72,3.5,10.0,26.0}	{2.6,2.07,1.3,1.06,1.01}	{0.5,1.5,2.5,3.5}	{1.36,2.5,6.0,17.0}	{3.4,1.53,1.12,1.02}	https://www.oddsportal.com/football/greece/super-league-2020-2021/asteras-tripolis-aris-Sz2rixsM/#1X2;2	2023-05-07 23:00:04.398738+01
507	PAOK	Panathinaikos	2021-04-25 15:00:00+01	0	0	1.4	4.25	10	2.0	2.2	0	0	0	0	8.0	1.8	2.55	7.25	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5}	{1.08,1.36,1.85,2.18,4.2,9.0,19.0}	{9.0,3.05,2.0,1.72,1.25,1.08,1.02}	{0.5,0.75,1.0,1.5,2.5,3.5}	{1.53,1.7,2.02,3.25,9.0,26.0}	{2.7,2.1,1.77,1.34,1.07,1.01}	{0.5,1.5,2.5,3.5}	{1.33,2.4,5.5,15.0}	{3.5,1.57,1.14,1.03}	https://www.oddsportal.com/football/greece/super-league-2020-2021/paok-panathinaikos-nLrFoG4q/#1X2;2	2023-05-07 23:00:38.157629+01
509	AEL Larissa	OFI Crete	2021-04-24 17:15:00+01	0	1	2.5	3.1	3	3.4	1.96	0	0	1	0	4.2	2.87	2.2	3.7	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5}	{1.11,1.5,2.0,2.6,5.5,13.0,26.0}	{7.0,2.55,1.85,1.53,1.17,1.05,1.01}	{0.5,0.75,1.5,2.5,3.5}	{1.6,1.85,3.75,13.0,17.0}	{2.43,1.95,1.28,1.04,1.01}	{0.5,1.5,2.5,3.5}	{1.4,2.62,7.0,21.0}	{3.0,1.45,1.11,1.02}	https://www.oddsportal.com/football/greece/super-league-2020-2021/ael-larissa-ofi-crete-Cx3OF0NB/#1X2;2	2023-05-07 23:01:38.908163+01
510	Giannina	Panetolikos	2021-04-24 15:00:00+01	0	1	3.0	3.1	3	3.8	1.9	0	0	1	0	3.4	3.35	2.2	3.2	{0.5,1.5,1.75,2.0,2.5,3.5,4.5,5.5}	{1.12,1.57,2.05,2.8,6.0,14.0,26.0}	{6.5,2.38,1.8,1.45,1.14,1.04,1.01}	{0.5,0.75,1.5,2.5,3.5}	{1.61,1.9,4.0,13.0,11.0}	{2.3,1.9,1.25,1.04,1.01}	{0.5,1.5,2.5,3.5}	{1.4,2.75,7.0,21.0}	{3.0,1.44,1.1,1.02}	https://www.oddsportal.com/football/greece/super-league-2020-2021/giannina-panetolikos-UDDJGt85/#1X2;2	2023-05-07 23:02:09.294021+01
511	AEK Athens FC	Panathinaikos	2021-04-21 21:30:00+01	1	1	2.0	3.3	4	2.7	2.0	0	1	1	0	4.75	2.37	2.3	4.2	{0.5,1.5,2.25,2.5,3.5,4.5,5.5}	{1.1,1.45,2.13,2.37,4.33,10.0,21.0}	{7.5,2.75,1.75,1.57,1.2,1.06,1.01}	{0.5,0.75,1.0,1.5,2.5,3.5}	{1.53,1.75,3.5,11.0,17.0}	{2.5,2.05,1.3,1.05,1.01}	{0.5,1.5,2.5,3.5}	{1.36,2.55,6.0,17.0}	{3.4,1.5,1.12,1.02}	https://www.oddsportal.com/football/greece/super-league-2020-2021/aek-panathinaikos-S0Xwfvc3/#1X2;2	2023-05-07 23:02:39.741288+01
512	Aris	PAOK	2021-04-21 19:30:00+01	0	1	3.5	3.25	2	4.0	2.0	0	0	1	0	3.1	3.6	2.3	2.75	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5}	{1.1,1.44,2.05,2.3,4.33,10.0,21.0}	{8.0,2.75,1.8,1.6,1.2,1.06,1.01}	{0.5,0.75,1.5,2.5,3.5}	{1.53,1.72,3.4,10.0,17.0}	{2.5,2.07,1.3,1.06,1.01}	{0.5,1.5,2.5,3.5}	{1.36,2.5,5.5,15.0}	{3.5,1.53,1.14,1.03}	https://www.oddsportal.com/football/greece/super-league-2020-2021/aris-paok-fN3zgbC9/#1X2;2	2023-05-07 23:03:09.899507+01
513	Olympiacos Piraeus	Asteras Tripolis	2021-04-21 17:15:00+01	1	0	1.33	5.25	14	1.8	2.5	0	1	0	0	8.75	1.6	3.1	8.5	{0.5,1.5,2.5,2.75,3.5,4.5,5.5,6.5}	{1.04,1.2,1.66,1.85,2.62,5.0,10.0,21.0}	{13.0,4.33,2.2,2.0,1.45,1.2,1.06,1.01}	{0.5,1.0,1.25,1.5,2.5,3.5}	{1.36,2.05,2.5,6.0,17.0}	{3.4,1.75,1.5,1.12,1.02}	{0.5,1.5,2.5,3.5,4.5}	{1.25,2.0,3.75,9.0,21.0}	{4.5,1.85,1.25,1.07,1.01}	https://www.oddsportal.com/football/greece/super-league-2020-2021/olympiacos-piraeus-asteras-tripolis-YD2vhIRF/#1X2;2	2023-05-07 23:03:41.251201+01
514	Lamia	AEL Larissa	2021-04-19 19:30:00+01	0	0	2.8	2.75	3	3.7	1.83	0	0	0	0	4.0	3.3	2.1	3.4	{0.5,1.5,1.75,2.5,3.5,4.5,5.5}	{1.16,1.66,1.83,3.0,6.0,15.0,17.0}	{5.5,2.25,2.02,1.4,1.12,1.03,1.01}	{0.5,0.75,1.5,2.5,3.5}	{1.7,2.0,4.33,15.0,11.0}	{2.1,1.8,1.22,1.03,1.01}	{0.5,1.5,2.5,3.5}	{1.5,3.0,8.0,21.0}	{2.75,1.4,1.08,1.01}	https://www.oddsportal.com/football/greece/super-league-2020-2021/lamia-ael-larissa-jNEFHMha/#1X2;2	2023-05-07 23:04:11.21118+01
515	PAOK	Olympiacos Piraeus	2021-04-18 19:30:00+01	2	0	2.2	3.3	4	2.9	2.1	0	2	0	0	3.75	2.62	2.4	3.4	{0.5,1.5,2.25,2.5,3.5,4.5,5.5}	{1.06,1.33,1.77,2.03,3.4,7.0,15.0}	{10.0,3.4,2.1,1.85,1.3,1.11,1.03}	{0.5,1.0,1.5,2.5,3.5}	{1.5,1.95,3.0,8.0,23.0}	{2.75,1.85,1.4,1.08,1.01}	{0.5,1.5,2.5,3.5}	{1.28,2.15,4.6,13.0}	{4.0,1.66,1.18,1.04}	https://www.oddsportal.com/football/greece/super-league-2020-2021/paok-olympiacos-piraeus-lAYZfKsc/#1X2;2	2023-05-07 23:04:40.362974+01
516	AEK Athens FC	Asteras Tripolis	2021-04-18 17:15:00+01	3	1	1.52	4.0	7	2.2	2.25	0	2	1	1	6.5	1.9	2.6	5.5	{0.5,1.5,2.5,3.5,4.5,5.5}	{1.06,1.33,2.0,3.25,6.5,15.0}	{10.0,3.5,1.93,1.33,1.11,1.03}	{0.5,1.0,1.5,2.5,3.5}	{1.44,1.85,2.75,7.0,21.0}	{3.0,1.95,1.4,1.1,1.01}	{0.5,1.5,2.5,3.5}	{1.3,2.25,4.5,13.0}	{4.0,1.66,1.18,1.04}	https://www.oddsportal.com/football/greece/super-league-2020-2021/aek-asteras-tripolis-M3tlXGkj/#1X2;2	2023-05-07 23:05:09.70516+01
517	Panathinaikos	Aris	2021-04-18 15:00:00+01	1	2	2.7	3.1	3	3.6	1.9	2	0	0	1	3.7	3.1	2.1	3.3	{0.5,1.5,1.75,2.0,2.5,3.5,4.5,5.5}	{1.12,1.57,1.73,2.8,5.5,13.0,17.0}	{6.5,2.37,2.15,1.44,1.14,1.04,1.01}	{0.5,0.75,1.5,2.5,3.5}	{1.61,1.9,4.0,13.0,11.0}	{2.25,1.9,1.22,1.04,1.01}	{0.5,1.5,2.5,3.5}	{1.44,2.75,7.0,21.0}	{3.0,1.4,1.1,1.01}	https://www.oddsportal.com/football/greece/super-league-2020-2021/panathinaikos-aris-z7phWz5d/#1X2;2	2023-05-07 23:05:39.274845+01
518	Volos	Giannina	2021-04-17 19:30:00+01	1	1	2.65	2.9	3	3.6	1.95	0	0	1	1	3.6	3.0	2.25	3.2	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5}	{1.11,1.44,1.8,2.1,2.37,4.5,11.0,21.0}	{7.0,2.62,2.05,1.77,1.57,1.2,1.05,1.01}	{0.5,0.75,1.5,2.5,3.5}	{1.57,1.77,3.5,11.0,17.0}	{2.37,2.02,1.3,1.05,1.01}	{0.5,1.5,2.5,3.5}	{1.36,2.5,6.0,17.0}	{3.4,1.53,1.12,1.02}	https://www.oddsportal.com/football/greece/super-league-2020-2021/volos-giannina-rcFBI2wg/#1X2;2	2023-05-07 23:06:09.546121+01
519	Panetolikos	Apollon Smyrnis	2021-04-17 17:15:00+01	1	0	2.05	3.2	4	2.87	1.85	0	1	0	0	5.0	2.4	2.1	4.6	{0.5,1.5,1.75,2.0,2.5,3.5,4.5,5.5}	{1.12,1.61,1.83,2.87,6.0,15.0,17.0}	{6.0,2.25,2.02,1.4,1.12,1.03,1.01}	{0.5,0.75,1.5,2.5,3.5}	{1.7,1.97,4.0,13.0,11.0}	{2.2,1.82,1.22,1.04,1.01}	{0.5,1.5,2.5,3.5}	{1.44,3.0,8.0,23.0}	{2.75,1.4,1.08,1.01}	https://www.oddsportal.com/football/greece/super-league-2020-2021/panetolikos-apollon-smyrnis-46G7JrOn/#1X2;2	2023-05-07 23:06:39.615555+01
520	OFI Crete	Atromitos	2021-04-17 15:00:00+01	1	1	2.05	3.4	4	2.75	2.1	1	1	0	0	4.33	2.5	2.4	3.9	{0.5,1.5,2.25,2.5,3.5,4.5,5.5}	{1.07,1.4,1.83,2.16,3.8,8.0,17.0}	{9.5,3.25,2.02,1.75,1.25,1.08,1.02}	{0.5,0.75,1.0,1.5,2.5,3.5}	{1.53,1.7,2.02,3.1,9.0,23.0}	{2.62,2.1,1.77,1.36,1.07,1.01}	{0.5,1.5,2.5,3.5}	{1.3,2.35,5.25,13.0}	{3.75,1.61,1.16,1.04}	https://www.oddsportal.com/football/greece/super-league-2020-2021/ofi-crete-atromitos-MsR2KO8t/#1X2;2	2023-05-07 23:07:09.107055+01
521	Giannina	Lamia	2021-04-12 19:30:00+01	1	2	2.45	3.0	3	3.25	1.9	2	0	0	1	4.0	2.9	2.2	3.5	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5}	{1.12,1.5,2.02,2.7,5.0,13.0,26.0}	{6.5,2.5,1.83,1.53,1.18,1.05,1.01}	{0.5,0.75,1.5,2.5,3.5}	{1.6,1.87,3.75,13.0,17.0}	{2.25,1.92,1.28,1.04,1.01}	{0.5,1.5,2.5,3.5}	{1.4,2.62,7.0,19.0}	{3.25,1.48,1.11,1.02}	https://www.oddsportal.com/football/greece/super-league-2020-2021/giannina-lamia-pMZzP40P/#1X2;2	2023-05-07 23:07:39.626816+01
522	Olympiacos Piraeus	Panathinaikos	2021-04-11 19:30:00+01	3	1	1.52	4.2	7	2.2	2.2	0	2	1	1	6.0	1.9	2.55	5.75	{0.5,1.5,2.25,2.5,3.5,4.5,5.5}	{1.07,1.33,1.85,2.07,3.75,8.0,17.0}	{9.5,3.25,2.0,1.72,1.3,1.1,1.02}	{0.5,1.0,1.5,2.5,3.5}	{1.44,2.02,3.0,9.0,23.0}	{2.75,1.77,1.4,1.08,1.01}	{0.5,1.5,2.5,3.5}	{1.3,2.3,5.0,15.0}	{3.75,1.61,1.16,1.03}	https://www.oddsportal.com/football/greece/super-league-2020-2021/olympiacos-piraeus-panathinaikos-vuiqYdzp/#1X2;2	2023-05-07 23:08:09.989604+01
523	Asteras Tripolis	PAOK	2021-04-11 17:15:00+01	1	1	5.8	3.8	2	5.25	2.2	1	1	0	0	2.37	4.75	2.5	2.05	{0.5,1.5,2.5,3.5,4.5,5.5}	{1.07,1.33,2.1,3.5,7.0,17.0}	{9.5,3.25,1.8,1.3,1.1,1.02}	{0.5,1.0,1.5,2.5,3.5}	{1.44,2.0,3.0,9.0,23.0}	{2.75,1.8,1.36,1.08,1.01}	{0.5,1.5,2.5,3.5}	{1.28,2.2,5.0,13.0}	{3.75,1.61,1.16,1.04}	https://www.oddsportal.com/football/greece/super-league-2020-2021/asteras-tripolis-paok-xW4HxwSS/#1X2;2	2023-05-07 23:08:39.653647+01
524	Aris	AEK Athens FC	2021-04-11 15:00:00+01	1	3	2.4	3.2	3	3.1	2.05	0	1	3	0	4.0	2.87	2.3	3.5	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5}	{1.1,1.44,2.05,2.37,4.33,10.0,21.0}	{8.0,2.75,1.8,1.6,1.2,1.06,1.01}	{0.5,0.75,1.0,1.5,2.5,3.5}	{1.53,1.72,3.5,10.0,17.0}	{2.5,2.07,1.3,1.06,1.01}	{0.5,1.5,2.5,3.5}	{1.36,2.5,6.0,17.0}	{3.4,1.53,1.12,1.02}	https://www.oddsportal.com/football/greece/super-league-2020-2021/aris-aek-8d0DwJCM/#1X2;2	2023-05-07 23:09:10.345507+01
525	Atromitos	AEL Larissa	2021-04-10 19:30:00+01	0	1	2.7	3.1	3	3.25	1.95	0	0	1	0	4.0	2.9	2.25	3.4	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5}	{1.11,1.45,1.83,2.4,4.5,11.0,23.0}	{7.0,2.62,2.02,1.53,1.2,1.05,1.01}	{0.5,0.75,1.5,2.5,3.5}	{1.53,1.77,3.5,11.0,11.0}	{2.37,2.02,1.28,1.05,1.01}	{0.5,1.5,2.5,3.5}	{1.34,2.55,6.0,17.0}	{3.25,1.5,1.12,1.02}	https://www.oddsportal.com/football/greece/super-league-2020-2021/atromitos-ael-larissa-WIog0LNO/#1X2;2	2023-05-07 23:09:39.873219+01
526	Apollon Smyrnis	OFI Crete	2021-04-10 17:15:00+01	0	0	2.87	3.1	3	3.6	1.95	0	0	0	0	3.5	3.1	2.2	3.1	{0.5,1.5,2.0,2.5,3.5,4.5,5.5}	{1.11,1.5,1.9,2.5,5.0,11.0,23.0}	{7.0,2.62,1.95,1.5,1.16,1.05,1.01}	{0.5,0.75,1.5,2.5,3.5}	{1.55,1.82,3.75,11.0,11.0}	{2.37,1.97,1.26,1.05,1.01}	{0.5,1.5,2.5,3.5}	{1.36,2.62,6.5,19.0}	{3.25,1.44,1.11,1.02}	https://www.oddsportal.com/football/greece/super-league-2020-2021/apollon-smyrnis-ofi-crete-hSnk118I/#1X2;2	2023-05-07 23:10:09.425009+01
527	Volos	Panetolikos	2021-04-10 15:00:00+01	3	1	2.55	3.1	3	3.4	1.95	0	0	1	3	3.75	2.9	2.2	3.3	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5}	{1.11,1.5,1.9,2.5,5.0,11.0,26.0}	{7.0,2.55,1.95,1.53,1.18,1.05,1.01}	{0.5,0.75,1.0,1.5,2.5,3.5}	{1.57,1.82,3.75,11.0,11.0}	{2.35,1.97,1.28,1.05,1.01}	{0.5,1.5,2.5,3.5}	{1.34,2.62,6.5,19.0}	{3.25,1.45,1.11,1.02}	https://www.oddsportal.com/football/greece/super-league-2020-2021/volos-panetolikos-zihp2sgC/#1X2;2	2023-05-07 23:10:39.261101+01
528	AEK Athens FC	Olympiacos Piraeus	2021-04-04 19:30:00+01	1	5	3.55	3.3	2	4.33	2.05	1	1	4	0	3.0	3.6	2.3	2.6	{0.5,1.5,2.25,2.5,3.5,4.5,5.5}	{1.08,1.4,2.0,2.25,4.0,9.0,19.0}	{8.0,2.75,1.85,1.65,1.25,1.07,1.02}	{0.5,0.75,1.0,1.5,2.5,3.5}	{1.5,1.7,2.1,3.4,10.0,26.0}	{2.55,2.1,1.7,1.33,1.06,1.01}	{0.5,1.5,2.5,3.5}	{1.33,2.37,5.5,15.0}	{3.5,1.53,1.14,1.03}	https://www.oddsportal.com/football/greece/super-league-2020-2021/aek-olympiacos-piraeus-z780tLS3/#1X2;2	2023-05-07 23:11:09.014078+01
529	Aris	Asteras Tripolis	2021-04-04 17:15:00+01	2	0	1.6	3.8	7	2.25	2.05	0	2	0	0	6.5	2.0	2.37	6.0	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5}	{1.1,1.44,1.83,2.4,4.5,11.0,23.0}	{7.5,2.62,2.02,1.55,1.2,1.06,1.01}	{0.5,0.75,1.5,2.5,3.5}	{1.57,1.75,3.5,11.0,17.0}	{2.5,2.05,1.3,1.06,1.01}	{0.5,1.5,2.5,3.5}	{1.36,2.5,6.0,17.0}	{3.4,1.5,1.12,1.02}	https://www.oddsportal.com/football/greece/super-league-2020-2021/aris-asteras-tripolis-nsC4uurA/#1X2;2	2023-05-07 23:11:38.37897+01
530	Panathinaikos	PAOK	2021-04-04 15:00:00+01	3	0	4.2	3.1	2	4.75	2.0	0	2	0	1	2.87	4.2	2.3	2.45	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5}	{1.1,1.44,1.75,2.05,2.37,4.33,10.0,21.0}	{7.5,2.75,2.13,1.8,1.6,1.22,1.06,1.01}	{0.5,0.75,1.5,2.5,3.5}	{1.53,1.72,3.5,11.0,17.0}	{2.5,2.07,1.3,1.06,1.01}	{0.5,1.5,2.5,3.5}	{1.36,2.5,6.0,17.0}	{3.4,1.53,1.12,1.02}	https://www.oddsportal.com/football/greece/super-league-2020-2021/panathinaikos-paok-U519vacG/#1X2;2	2023-05-07 23:12:09.963811+01
531	AEL Larissa	Panetolikos	2021-04-03 19:30:00+01	1	1	2.02	3.25	4	2.87	1.91	1	0	0	1	5.0	2.5	2.2	4.33	{0.5,1.5,1.75,2.0,2.5,3.5,4.5,5.5}	{1.12,1.57,1.8,2.1,2.87,6.0,15.0,17.0}	{6.0,2.3,2.05,1.77,1.44,1.14,1.04,1.01}	{0.5,0.75,1.5,2.5,3.5}	{1.66,1.95,4.0,13.0,11.0}	{2.25,1.85,1.25,1.04,1.01}	{0.5,1.5,2.5,3.5}	{1.4,2.75,8.0,21.0}	{2.75,1.4,1.08,1.01}	https://www.oddsportal.com/football/greece/super-league-2020-2021/ael-larissa-panetolikos-2wfx43Oa/#1X2;2	2023-05-07 23:12:40.552956+01
532	Lamia	Volos	2021-04-03 19:30:00+01	1	1	2.05	3.3	4	2.87	2.0	1	1	0	0	4.75	2.4	2.3	4.5	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5}	{1.1,1.5,1.9,2.05,2.5,5.0,11.0,26.0}	{7.0,2.62,1.95,1.8,1.55,1.2,1.06,1.01}	{0.5,0.75,1.5,2.5,3.5}	{1.57,1.8,3.75,11.0,17.0}	{2.45,2.0,1.3,1.05,1.01}	{0.5,1.5,2.5,3.5}	{1.36,2.62,6.5,19.0}	{3.25,1.48,1.11,1.02}	https://www.oddsportal.com/football/greece/super-league-2020-2021/lamia-volos-d0gt3Nw6/#1X2;2	2023-05-07 23:13:20.221088+01
533	OFI Crete	Giannina	2021-04-03 17:15:00+01	2	1	2.4	3.2	3	3.25	1.95	0	2	1	0	3.9	2.75	2.2	3.5	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5}	{1.1,1.5,1.9,2.5,5.0,11.0,26.0}	{7.0,2.5,1.95,1.57,1.16,1.06,1.01}	{0.5,0.75,1.5,2.5,3.5}	{1.57,1.8,3.75,11.0,23.0}	{2.37,2.0,1.28,1.05,1.01}	{0.5,1.5,2.5,3.5}	{1.36,2.62,6.5,19.0}	{3.25,1.5,1.11,1.02}	https://www.oddsportal.com/football/greece/super-league-2020-2021/ofi-crete-giannina-4hyZ4q9g/#1X2;2	2023-05-07 23:13:50.403139+01
534	Atromitos	Apollon Smyrnis	2021-04-03 15:00:00+01	1	1	2.25	2.87	4	3.1	1.9	1	1	0	0	4.75	2.6	2.2	4.2	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5}	{1.11,1.5,1.9,2.5,5.0,11.0,23.0}	{6.5,2.62,1.95,1.53,1.2,1.05,1.01}	{0.5,0.75,1.5,2.5,3.5}	{1.57,1.82,3.75,11.0,17.0}	{2.3,1.97,1.3,1.05,1.01}	{0.5,1.5,2.5,3.5}	{1.4,2.62,6.5,19.0}	{3.25,1.5,1.12,1.02}	https://www.oddsportal.com/football/greece/super-league-2020-2021/atromitos-apollon-smyrnis-MToU5Pgm/#1X2;2	2023-05-07 23:14:21.854286+01
535	PAOK	AEK Athens FC	2021-03-21 19:30:00+00	3	1	1.8	3.45	5	2.45	2.1	0	2	1	1	5.5	2.2	2.37	4.75	{0.5,1.5,2.25,2.5,3.5,4.5,5.5}	{1.08,1.4,1.98,2.25,4.35,9.5,19.0}	{8.5,3.0,1.88,1.65,1.22,1.07,1.02}	{0.5,0.75,1.0,1.5,2.5,3.5}	{1.53,1.7,2.1,3.3,10.0,26.0}	{2.65,2.1,1.7,1.33,1.06,1.01}	{0.5,1.5,2.5,3.5}	{1.36,2.5,5.5,15.0}	{3.5,1.53,1.14,1.03}	https://www.oddsportal.com/football/greece/super-league-2020-2021/paok-aek-tp9ds1Dc/#1X2;2	2023-05-07 23:14:52.93004+01
536	Olympiacos Piraeus	Aris	2021-03-21 17:15:00+00	1	0	1.68	3.75	5	2.37	2.1	0	0	0	1	5.6	2.1	2.37	5.1	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.08,1.4,2.1,2.35,4.33,10.0,21.0}	{8.5,3.0,1.77,1.62,1.22,1.06,1.01}	{0.5,0.75,1.0,1.5,2.5,3.5}	{1.53,1.72,3.4,10.0,17.0}	{2.6,2.07,1.3,1.06,1.01}	{0.5,1.5,2.5,3.5}	{1.36,2.5,6.0,17.0}	{3.4,1.53,1.13,1.02}	https://www.oddsportal.com/football/greece/super-league-2020-2021/olympiacos-piraeus-aris-8fa9eiY7/#1X2;2	2023-05-07 23:15:23.670644+01
537	Asteras Tripolis	Panathinaikos	2021-03-21 15:00:00+00	2	2	2.9	3.2	3	3.75	1.95	2	2	0	0	3.5	3.4	2.15	3.1	{0.5,1.5,1.75,2.0,2.5,3.5,4.5,5.5}	{1.12,1.57,1.8,2.13,2.87,6.0,15.0,26.0}	{7.0,2.55,2.05,1.75,1.46,1.15,1.04,1.01}	{0.5,0.75,1.5,2.5,3.5}	{1.66,1.95,4.0,13.0,17.0}	{2.38,1.85,1.25,1.04,1.01}	{0.5,1.5,2.5,3.5}	{1.4,2.75,8.0,21.0}	{3.0,1.4,1.1,1.01}	https://www.oddsportal.com/football/greece/super-league-2020-2021/asteras-tripolis-panathinaikos-2gAhrsbi/#1X2;2	2023-05-07 23:15:54.385305+01
538	Giannina	Atromitos	2021-03-20 19:30:00+00	1	0	2.1	3.1	4	2.87	1.95	0	0	0	1	4.5	2.5	2.25	4.0	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5}	{1.1,1.5,1.9,2.5,4.7,11.0,23.0}	{8.0,2.8,1.95,1.57,1.18,1.05,1.01}	{0.5,0.75,1.0,1.5,2.5,3.5}	{1.57,1.8,3.5,11.0,17.0}	{2.5,2.0,1.3,1.06,1.01}	{0.5,1.5,2.5,3.5}	{1.36,2.55,6.0,17.0}	{3.25,1.5,1.12,1.02}	https://www.oddsportal.com/football/greece/super-league-2020-2021/giannina-atromitos-SbSVCh3r/#1X2;2	2023-05-07 23:16:25.080292+01
539	Panetolikos	Lamia	2021-03-20 19:30:00+00	0	3	2.7	3.05	3	3.5	1.89	0	0	3	0	4.0	3.1	2.05	3.5	{0.5,1.5,1.75,2.0,2.5,3.5,4.5,5.5}	{1.14,1.66,1.95,3.4,7.0,17.0,17.0}	{6.4,2.28,1.9,1.4,1.14,1.03,1.01}	{0.5,0.75,1.5,2.5,3.5}	{1.7,2.05,4.5,15.0,11.0}	{2.28,1.75,1.22,1.03,1.01}	{0.5,1.5,2.5,3.5}	{1.5,3.25,9.0,26.0}	{2.7,1.4,1.08,1.01}	https://www.oddsportal.com/football/greece/super-league-2020-2021/panetolikos-lamia-2HKrAjm1/#1X2;2	2023-05-07 23:16:56.959134+01
540	Volos	OFI Crete	2021-03-20 17:15:00+00	0	0	2.15	3.2	4	3.1	2.1	0	0	0	0	4.0	2.6	2.37	3.5	{0.5,1.5,2.25,2.5,3.5,4.5,5.5}	{1.07,1.36,1.93,2.16,3.5,8.0,17.0}	{9.0,3.25,1.93,1.7,1.28,1.08,1.02}	{0.5,0.75,1.0,1.5,2.5,3.5}	{1.5,2.1,3.0,9.0,23.0}	{2.62,1.7,1.36,1.07,1.01}	{0.5,1.5,2.5,3.5}	{1.3,2.25,5.0,13.0}	{3.75,1.61,1.16,1.04}	https://www.oddsportal.com/football/greece/super-league-2020-2021/volos-ofi-crete-OQLvBWXf/#1X2;2	2023-05-07 23:17:26.646613+01
541	Apollon Smyrnis	AEL Larissa	2021-03-20 15:00:00+00	0	2	2.4	3.25	3	3.25	1.95	2	0	0	0	4.1	2.87	2.2	3.5	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5}	{1.11,1.53,2.05,2.7,5.5,13.0,26.0}	{7.0,2.55,1.8,1.48,1.16,1.06,1.01}	{0.5,0.75,1.0,1.5,2.5,3.5}	{1.6,1.9,3.75,13.0,17.0}	{2.35,1.9,1.25,1.04,1.01}	{0.5,1.5,2.5,3.5}	{1.4,2.62,7.0,21.0}	{3.0,1.45,1.1,1.02}	https://www.oddsportal.com/football/greece/super-league-2020-2021/apollon-smyrnis-ael-larissa-6kRZBCIl/#1X2;2	2023-05-07 23:17:57.50441+01
542	AEL Larissa	Olympiacos Piraeus	2021-03-14 19:00:00+00	1	3	10.0	4.5	1	8.0	2.3	2	1	1	0	2.0	7.5	2.65	1.75	{0.5,1.5,2.5,3.5,4.5,5.5,6.5}	{1.07,1.33,2.0,3.4,7.0,15.0}	{9.5,3.4,1.8,1.3,1.1,1.03}	{0.5,1.0,1.5,2.5,3.5}	{1.44,1.95,2.75,8.0,21.0}	{2.9,1.85,1.4,1.08,1.01}	{0.5,1.5,2.5,3.5,4.5}	{1.3,2.3,5.0,13.0}	{3.75,1.66,1.17,1.04}	https://www.oddsportal.com/football/greece/super-league-2020-2021/ael-larissa-olympiacos-piraeus-6XwE4LIi/#1X2;2	2023-05-07 23:18:27.561215+01
543	Apollon Smyrnis	Panetolikos	2021-03-14 19:00:00+00	1	0	2.2	2.9	4	3.0	1.95	0	1	0	0	4.6	2.6	2.2	4.0	{0.5,1.5,2.0,2.5,3.5,4.5,5.5}	{1.12,1.53,2.0,2.62,5.0,13.0,26.0}	{6.5,2.5,1.85,1.48,1.17,1.04,1.01}	{0.5,0.75,1.5,2.5,3.5}	{1.6,1.85,3.75,11.0,17.0}	{2.3,1.95,1.28,1.05,1.01}	{0.5,1.5,2.5,3.5}	{1.4,2.62,7.0,19.0}	{3.0,1.45,1.1,1.02}	https://www.oddsportal.com/football/greece/super-league-2020-2021/apollon-smyrnis-panetolikos-z7rI3uYc/#1X2;2	2023-05-07 23:18:58.049244+01
544	Aris	OFI Crete	2021-03-14 19:00:00+00	1	0	1.45	4.33	11	2.05	2.2	0	0	0	1	7.5	1.8	2.6	7.0	{0.5,1.5,2.25,2.5,3.5,4.5,5.5}	{1.08,1.36,1.88,2.1,3.75,8.0,17.0}	{8.5,3.25,1.98,1.74,1.28,1.1,1.02}	{0.5,1.0,1.5,2.5,3.5}	{1.5,2.05,3.0,9.0,23.0}	{2.62,1.75,1.36,1.07,1.01}	{0.5,1.5,2.5,3.5}	{1.33,2.3,5.0,15.0}	{3.75,1.61,1.16,1.03}	https://www.oddsportal.com/football/greece/super-league-2020-2021/aris-ofi-crete-EcsM2am4/#1X2;2	2023-05-07 23:19:27.55504+01
545	Asteras Tripolis	Giannina	2021-03-14 19:00:00+00	0	1	2.45	3.1	4	3.25	1.9	1	0	0	0	4.33	2.75	2.1	3.9	{0.5,1.5,1.75,2.0,2.5,3.5,4.5,5.5}	{1.14,1.57,1.8,2.1,2.87,6.0,15.0,17.0}	{6.5,2.3,2.05,1.77,1.4,1.14,1.03,1.01}	{0.5,0.75,1.5,2.5,3.5}	{1.62,1.95,4.0,13.0,17.0}	{2.2,1.85,1.25,1.04,1.01}	{0.5,1.5,2.5,3.5}	{1.44,2.75,8.0,21.0}	{2.75,1.4,1.08,1.01}	https://www.oddsportal.com/football/greece/super-league-2020-2021/asteras-tripolis-giannina-dMWQ1J2A/#1X2;2	2023-05-07 23:19:57.309594+01
546	Lamia	Atromitos	2021-03-14 19:00:00+00	0	0	2.6	2.8	3	3.4	1.83	0	0	0	0	4.1	3.0	2.1	3.5	{0.5,1.5,1.75,2.0,2.5,3.5,4.5,5.5}	{1.14,1.61,1.85,2.87,6.0,15.0,17.0}	{5.5,2.25,2.0,1.4,1.14,1.03,1.01}	{0.5,0.75,1.5,2.5,3.5}	{1.66,2.0,4.0,13.0,11.0}	{2.2,1.8,1.22,1.04,1.01}	{0.5,1.5,2.5,3.5}	{1.4,3.0,8.0,23.0}	{2.75,1.4,1.08,1.01}	https://www.oddsportal.com/football/greece/super-league-2020-2021/lamia-atromitos-rwZxaHnT/#1X2;2	2023-05-07 23:20:26.758669+01
547	Panathinaikos	PAOK	2021-03-14 19:00:00+00	2	1	5.0	3.45	2	5.5	2.05	1	1	0	1	2.7	4.75	2.3	2.35	{0.5,1.5,2.0,2.5,3.5,4.5,5.5}	{1.1,1.5,1.77,2.45,4.75,10.0,21.0}	{7.5,2.62,2.1,1.58,1.2,1.06,1.01}	{0.5,0.75,1.5,2.5,3.5}	{1.6,1.75,3.5,11.0,17.0}	{2.5,2.05,1.28,1.05,1.01}	{0.5,1.5,2.5,3.5}	{1.4,2.65,6.25,17.0}	{3.4,1.5,1.12,1.02}	https://www.oddsportal.com/football/greece/super-league-2020-2021/panathinaikos-paok-4nzZacXM/#1X2;2	2023-05-07 23:20:57.073875+01
548	Volos	AEK Athens FC	2021-03-14 19:00:00+00	1	0	5.15	3.35	2	5.0	2.2	0	0	0	1	2.5	4.5	2.5	2.2	{0.5,1.5,2.25,2.5,3.5,4.5,5.5}	{1.08,1.4,1.95,2.2,3.8,7.25,15.0}	{9.5,3.4,1.9,1.8,1.3,1.1,1.03}	{0.5,0.75,1.0,1.5,2.5,3.5}	{1.5,1.95,3.25,8.0,23.0}	{2.75,1.85,1.36,1.08,1.01}	{0.5,1.5,2.5,3.5}	{1.3,2.35,5.25,13.0}	{3.75,1.66,1.18,1.04}	https://www.oddsportal.com/football/greece/super-league-2020-2021/volos-aek-APzV0wIG/#1X2;2	2023-05-07 23:21:27.333939+01
549	Lamia	AEL Larissa	2021-03-10 17:15:00+00	2	1	2.44	3.0	4	3.3	1.83	0	1	1	1	4.5	2.9	2.1	4.0	{0.5,1.5,1.75,2.0,2.5,3.5,4.5,5.5}	{1.15,1.66,1.98,3.4,7.0,17.0,17.0}	{6.1,2.38,1.88,1.41,1.13,1.03,1.01}	{0.5,0.75,1.5,2.5,3.5}	{1.7,2.05,4.33,15.0,11.0}	{2.23,1.75,1.22,1.03,1.01}	{0.5,1.5,2.5,3.5}	{1.5,3.25,9.0,26.0}	{2.7,1.36,1.08,1.01}	https://www.oddsportal.com/football/greece/super-league-2020-2021/lamia-ael-larissa-U3U1k7cs/#1X2;2	2023-05-07 23:21:57.766309+01
550	AEK Athens FC	Apollon Smyrnis	2021-03-08 19:30:00+00	2	0	1.32	5.0	9	1.83	2.5	0	0	0	2	7.5	1.61	2.95	7.5	{0.5,1.5,2.5,2.75,3.5,4.5,5.5,6.5}	{1.04,1.25,1.81,2.02,3.2,6.25,11.0,23.0}	{13.0,3.8,2.05,1.83,1.4,1.14,1.05,1.01}	{0.5,1.0,1.5,2.5,3.5}	{1.4,1.72,2.7,7.0,19.0}	{3.25,2.07,1.44,1.11,1.02}	{0.5,1.5,2.5,3.5,4.5}	{1.28,2.1,4.33,11.0,26.0}	{4.33,1.8,1.22,1.05,1.01}	https://www.oddsportal.com/football/greece/super-league-2020-2021/aek-apollon-smyrnis-M3IrktJ4/#1X2;2	2023-05-07 23:22:29.209817+01
551	PAOK	Aris	2021-03-07 19:30:00+00	2	2	1.75	3.6	5	2.5	2.1	1	2	1	0	5.5	2.15	2.4	4.75	{0.5,1.5,2.25,2.5,3.5,4.5,5.5}	{1.08,1.42,2.1,2.3,4.33,10.0,21.0}	{9.5,3.1,1.77,1.65,1.22,1.07,1.02}	{0.5,0.75,1.0,1.5,2.5,3.5}	{1.53,1.72,2.1,3.5,10.0,26.0}	{2.75,2.07,1.7,1.33,1.06,1.01}	{0.5,1.5,2.5,3.5}	{1.33,2.5,6.0,17.0}	{3.4,1.53,1.13,1.02}	https://www.oddsportal.com/football/greece/super-league-2020-2021/paok-aris-jqAaobIT/#1X2;2	2023-05-07 23:22:59.140792+01
552	Panetolikos	Volos	2021-03-07 17:15:00+00	1	0	2.1	3.15	4	3.0	1.96	0	1	0	0	4.5	2.6	2.25	4.1	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5}	{1.1,1.5,1.88,2.48,5.0,11.0,23.0}	{7.5,2.62,1.98,1.53,1.2,1.05,1.01}	{0.5,0.75,1.0,1.5,2.5,3.5}	{1.6,1.8,3.5,11.0,17.0}	{2.45,2.0,1.3,1.05,1.01}	{0.5,1.5,2.5,3.5}	{1.36,2.62,6.5,19.0}	{3.25,1.5,1.11,1.02}	https://www.oddsportal.com/football/greece/super-league-2020-2021/panetolikos-volos-Qy1RtIQp/#1X2;2	2023-05-07 23:23:29.392991+01
553	Olympiacos Piraeus	Lamia	2021-03-07 15:00:00+00	3	0	1.16	8.0	29	1.46	3.1	0	0	0	3	19.0	1.33	3.75	15.0	{0.5,1.5,2.5,2.75,3.0,3.5,4.5,5.5,6.5,7.5}	{1.04,1.16,1.57,1.83,2.45,4.5,7.0,15.0,26.0}	{13.0,5.0,2.5,2.02,1.61,1.25,1.1,1.03,1.01}	{0.5,1.25,1.5,2.5,3.5,4.5}	{1.3,1.82,2.28,4.75,13.0,17.0}	{3.75,1.97,1.66,1.18,1.04,1.01}	{0.5,1.5,2.5,3.5,4.5}	{1.2,1.85,3.75,7.5,17.0}	{5.5,2.1,1.33,1.1,1.02}	https://www.oddsportal.com/football/greece/super-league-2020-2021/olympiacos-piraeus-lamia-dMAenv3N/#1X2;2	2023-05-07 23:24:00.339046+01
554	Giannina	Panathinaikos	2021-03-06 19:30:00+00	1	0	3.1	3.0	3	3.9	1.9	0	0	0	1	3.4	3.45	2.2	2.95	{0.5,1.5,2.0,2.5,3.5,4.5,5.5}	{1.11,1.53,2.05,2.7,5.5,13.0,26.0}	{6.75,2.48,1.8,1.45,1.15,1.04,1.01}	{0.5,0.75,1.5,2.5,3.5}	{1.62,1.9,3.85,13.0,29.0}	{2.33,1.9,1.28,1.05,1.01}	{0.5,1.5,2.5,3.5}	{1.4,2.8,7.0,19.0}	{3.0,1.44,1.1,1.02}	https://www.oddsportal.com/football/greece/super-league-2020-2021/giannina-panathinaikos-StuA513o/#1X2;2	2023-05-07 23:24:29.925401+01
555	Atromitos	Asteras Tripolis	2021-03-06 17:15:00+00	1	1	3.6	2.85	3	4.0	1.9	1	0	0	1	3.35	3.4	2.2	3.0	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5}	{1.11,1.48,1.93,2.6,5.3,12.0,23.0}	{6.75,2.62,1.93,1.5,1.18,1.05,1.01}	{0.5,0.75,1.5,2.5,3.5}	{1.6,1.85,3.8,11.0,17.0}	{2.33,1.95,1.28,1.05,1.01}	{0.5,1.5,2.5,3.5}	{1.36,2.7,6.5,19.0}	{3.25,1.5,1.11,1.02}	https://www.oddsportal.com/football/greece/super-league-2020-2021/atromitos-asteras-tripolis-0fHnl0YA/#1X2;2	2023-05-07 23:25:00.082916+01
556	OFI Crete	AEL Larissa	2021-03-06 15:00:00+00	2	3	1.75	3.5	5	2.5	2.1	2	1	1	1	5.5	2.2	2.37	4.75	{0.5,1.5,2.25,2.5,3.5,4.5,5.5}	{1.08,1.4,1.98,2.2,4.25,9.0,19.0}	{8.5,3.0,1.88,1.66,1.25,1.08,1.02}	{0.5,0.75,1.0,1.5,2.5,3.5}	{1.5,1.72,2.1,3.25,10.0,26.0}	{2.65,2.07,1.7,1.33,1.07,1.01}	{0.5,1.5,2.5,3.5}	{1.33,2.37,5.5,15.0}	{3.5,1.57,1.14,1.03}	https://www.oddsportal.com/football/greece/super-league-2020-2021/ofi-crete-ael-larissa-IVBimKmH/#1X2;2	2023-05-07 23:25:30.358223+01
557	Volos	Olympiacos Piraeus	2021-03-01 19:30:00+00	1	2	10.5	5.0	1	8.5	2.6	1	0	1	1	1.8	8.0	3.05	1.61	{0.5,1.5,2.5,2.75,3.5,4.5,5.5,6.5}	{1.05,1.22,1.77,1.93,2.75,5.5,11.0,23.0}	{14.0,4.4,2.12,1.93,1.44,1.16,1.05,1.01}	{0.5,1.0,1.25,1.5,2.5,3.5}	{1.36,1.7,2.1,2.62,6.5,19.0}	{3.4,2.1,1.7,1.5,1.11,1.02}	{0.5,1.5,2.5,3.5,4.5}	{1.25,2.05,4.0,10.0,26.0}	{4.33,1.83,1.25,1.06,1.01}	https://www.oddsportal.com/football/greece/super-league-2020-2021/volos-olympiacos-piraeus-WEPVirZo/#1X2;2	2023-05-07 23:26:01.725558+01
558	Panathinaikos	AEK Athens FC	2021-02-28 19:30:00+00	1	1	3.3	3.25	2	4.0	2.0	1	1	0	0	3.2	3.5	2.25	2.88	{0.5,1.5,2.0,2.5,3.5,4.5,5.5}	{1.1,1.46,1.83,2.55,5.2,12.0,23.0}	{7.5,2.65,2.02,1.55,1.2,1.06,1.01}	{0.5,0.75,1.5,2.5,3.5}	{1.57,1.77,3.75,11.0,17.0}	{2.5,2.02,1.3,1.05,1.01}	{0.5,1.5,2.5,3.5}	{1.36,2.7,6.5,19.0}	{3.25,1.5,1.12,1.02}	https://www.oddsportal.com/football/greece/super-league-2020-2021/panathinaikos-aek-EwFzi2lh/#1X2;2	2023-05-07 23:26:31.71898+01
559	AEL Larissa	Panetolikos	2021-02-28 17:15:00+00	1	0	2.37	3.1	3	3.2	1.94	0	0	0	1	4.33	2.85	2.17	3.75	{0.5,1.5,1.75,2.0,2.5,3.5,4.5,5.5}	{1.12,1.57,1.75,2.1,2.7,5.5,13.0,17.0}	{7.0,2.48,2.13,1.77,1.44,1.14,1.04,1.01}	{0.5,0.75,1.5,2.5,3.5}	{1.61,1.9,4.0,13.0,11.0}	{2.38,1.9,1.25,1.04,1.01}	{0.5,1.5,2.5,3.5}	{1.4,2.9,7.0,21.0}	{3.0,1.4,1.1,1.01}	https://www.oddsportal.com/football/greece/super-league-2020-2021/ael-larissa-panetolikos-tp1DZ0JH/#1X2;2	2023-05-07 23:27:01.882712+01
560	Lamia	Giannina	2021-02-28 17:15:00+00	0	0	2.9	3.0	3	3.75	1.88	0	0	0	0	3.9	3.25	2.12	3.4	{0.5,1.5,1.75,2.0,2.5,3.5,4.5,5.5}	{1.14,1.61,1.85,2.87,6.5,15.0,17.0}	{6.4,2.38,2.0,1.4,1.13,1.03,1.01}	{0.5,0.75,1.5,2.5,3.5}	{1.7,2.0,4.33,15.0,11.0}	{2.28,1.8,1.22,1.03,1.01}	{0.5,1.5,2.5,3.5}	{1.44,3.0,8.0,23.0}	{2.75,1.36,1.08,1.01}	https://www.oddsportal.com/football/greece/super-league-2020-2021/lamia-giannina-StJvjM3b/#1X2;2	2023-05-07 23:27:31.829535+01
561	Aris	Atromitos	2021-02-28 15:00:00+00	3	0	1.55	3.8	8	2.15	2.1	0	2	0	1	7.0	1.87	2.5	6.5	{0.5,1.5,2.25,2.5,3.5,4.5,5.5}	{1.08,1.4,1.98,2.2,4.1,9.0,21.0}	{9.0,3.05,1.88,1.65,1.22,1.07,1.02}	{0.5,0.75,1.0,1.5,2.5,3.5}	{1.53,1.7,2.1,3.4,10.0,26.0}	{2.7,2.1,1.7,1.33,1.06,1.01}	{0.5,1.5,2.5,3.5}	{1.36,2.5,5.5,15.0}	{3.5,1.53,1.14,1.03}	https://www.oddsportal.com/football/greece/super-league-2020-2021/aris-atromitos-2akMXvlU/#1X2;2	2023-05-07 23:28:02.686733+01
562	Asteras Tripolis	PAOK	2021-02-27 19:30:00+00	2	1	5.8	3.8	2	5.5	2.2	1	1	0	1	2.3	5.25	2.5	2.0	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.07,1.34,1.8,2.1,3.9,8.0,17.0}	{9.5,3.25,2.05,1.8,1.3,1.1,1.03}	{0.5,1.0,1.5,2.5,3.5}	{1.44,2.0,3.1,9.0,23.0}	{2.8,1.8,1.36,1.07,1.01}	{0.5,1.5,2.5,3.5,4.5}	{1.3,2.3,5.0,13.0}	{3.75,1.61,1.16,1.04}	https://www.oddsportal.com/football/greece/super-league-2020-2021/asteras-tripolis-paok-hOQRhOJu/#1X2;2	2023-05-07 23:28:33.650661+01
563	Apollon Smyrnis	OFI Crete	2021-02-27 17:15:00+00	2	1	2.6	3.0	3	3.35	2.0	0	1	1	1	3.75	2.95	2.3	3.3	{0.5,1.5,2.25,2.5,3.5,4.5,5.5}	{1.08,1.4,1.98,2.23,4.2,9.0,19.0}	{8.0,3.0,1.88,1.65,1.25,1.08,1.02}	{0.5,0.75,1.0,1.5,2.5,3.5}	{1.53,1.7,2.1,3.4,10.0,26.0}	{2.5,2.1,1.7,1.33,1.06,1.01}	{0.5,1.5,2.5,3.5}	{1.33,2.37,5.5,15.0}	{3.5,1.57,1.14,1.03}	https://www.oddsportal.com/football/greece/super-league-2020-2021/apollon-smyrnis-ofi-crete-O8jIYKYN/#1X2;2	2023-05-07 23:29:04.242563+01
564	AEL Larissa	Lamia	2021-02-24 17:15:00+00	0	1	2.6	3.2	3	3.4	1.83	0	0	1	0	4.0	3.1	2.1	3.6	{0.5,1.5,1.75,2.0,2.25,2.5,3.5,4.5,5.5}	{1.14,1.66,1.98,2.05,3.4,7.0,17.0,26.0}	{6.0,2.25,1.88,1.8,1.4,1.13,1.02,1.01}	{0.5,0.75,1.0,1.5,2.5,3.5}	{1.7,2.02,4.4,15.0,29.0}	{2.16,1.77,1.25,1.03,1.01}	{0.5,1.5,2.5,3.5}	{1.5,3.0,9.0,26.0}	{2.75,1.4,1.08,1.01}	https://www.oddsportal.com/football/greece/super-league-2020-2021/ael-larissa-lamia-nPdpU7Hg/#1X2;2	2023-05-07 23:29:35.052639+01
565	Panetolikos	Panathinaikos	2021-02-22 19:30:00+00	1	0	4.5	3.3	2	5.0	1.96	0	0	0	1	2.75	4.75	2.25	2.37	{0.5,1.5,2.0,2.5,3.5,4.5,5.5}	{1.11,1.53,2.05,2.7,5.5,13.0,26.0}	{7.5,2.62,1.8,1.53,1.2,1.06,1.01}	{0.5,0.75,1.5,2.5,3.5}	{1.57,1.9,3.75,13.0,17.0}	{2.43,1.9,1.3,1.06,1.01}	{0.5,1.5,2.5,3.5}	{1.36,2.75,7.0,21.0}	{3.0,1.5,1.12,1.02}	https://www.oddsportal.com/football/greece/super-league-2020-2021/panetolikos-panathinaikos-YJc5yNl5/#1X2;2	2023-05-07 23:30:04.918181+01
566	Olympiacos Piraeus	Aris	2021-02-21 19:30:00+00	1	1	1.65	3.5	6	2.37	2.05	1	0	0	1	6.0	2.05	2.3	5.75	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.1,1.48,1.83,2.05,2.62,4.75,11.0,23.0}	{8.0,2.75,2.02,1.8,1.54,1.2,1.06,1.01}	{0.5,0.75,1.0,1.5,2.5,3.5}	{1.53,1.77,2.1,3.5,11.0,26.0}	{2.5,2.02,1.7,1.3,1.06,1.01}	{0.5,1.5,2.5,3.5,4.5}	{1.36,2.62,6.5,17.0}	{3.25,1.5,1.11,1.02}	https://www.oddsportal.com/football/greece/super-league-2020-2021/olympiacos-piraeus-aris-xh4dwqKh/#1X2;2	2023-05-07 23:30:36.427986+01
567	Giannina	OFI Crete	2021-02-21 17:15:00+00	1	0	2.15	3.1	4	2.88	2.0	0	0	0	1	4.4	2.55	2.3	3.9	{0.5,1.5,2.25,2.5,3.5,4.5,5.5}	{1.1,1.4,2.02,2.3,4.2,10.0,21.0}	{8.0,2.95,1.83,1.61,1.22,1.06,1.01}	{0.5,0.75,1.5,2.5,3.5}	{1.57,1.72,3.5,10.0,26.0}	{2.6,2.07,1.3,1.06,1.01}	{0.5,1.5,2.5,3.5}	{1.36,2.37,5.5,15.0}	{3.5,1.53,1.14,1.03}	https://www.oddsportal.com/football/greece/super-league-2020-2021/giannina-ofi-crete-Stc9zs4B/#1X2;2	2023-05-07 23:31:06.511216+01
568	PAOK	Lamia	2021-02-21 15:00:00+00	4	0	1.09	11.0	30	1.44	3.2	0	3	0	1	17.0	1.3	3.9	17.0	{0.5,1.5,2.5,2.75,3.0,3.5,4.5,5.5,6.5}	{1.03,1.2,1.6,1.85,2.5,4.35,8.0,17.0}	{15.0,5.0,2.42,2.0,1.6,1.25,1.09,1.02}	{0.5,1.0,1.25,1.5,2.5,3.5}	{1.36,1.87,2.5,5.5,15.0}	{3.75,1.92,1.62,1.16,1.03}	{0.5,1.5,2.5,3.5,4.5}	{1.22,1.9,3.75,8.0,19.0}	{5.5,2.05,1.3,1.09,1.02}	https://www.oddsportal.com/football/greece/super-league-2020-2021/paok-lamia-fTb1x3Zb/#1X2;2	2023-05-07 23:31:38.085685+01
569	Volos	Apollon Smyrnis	2021-02-21 15:00:00+00	2	0	2.45	2.87	3	3.25	2.0	0	1	0	1	4.0	2.85	2.3	3.55	{0.5,1.5,2.25,2.5,3.5,4.5,5.5}	{1.1,1.44,2.05,2.35,4.5,10.0,19.0}	{7.5,2.8,1.8,1.6,1.22,1.06,1.02}	{0.5,0.75,1.5,2.5,3.5}	{1.53,1.72,3.45,10.0,26.0}	{2.5,2.07,1.3,1.06,1.01}	{0.5,1.5,2.5,3.5}	{1.36,2.5,5.5,15.0}	{3.5,1.57,1.14,1.03}	https://www.oddsportal.com/football/greece/super-league-2020-2021/volos-apollon-smyrnis-b15hvP4n/#1X2;2	2023-05-07 23:32:08.707734+01
570	AEK Athens FC	Asteras Tripolis	2021-02-20 19:30:00+00	2	2	1.7	3.9	6	2.3	2.2	0	1	2	1	5.8	2.0	2.55	5.25	{0.5,1.5,2.25,2.5,2.75,3.0,3.5,4.5,5.5,6.5}	{1.07,1.33,1.8,2.05,3.65,7.5,17.0}	{10.5,3.45,2.05,1.85,1.33,1.11,1.03}	{0.5,1.0,1.25,1.5,2.5,3.5}	{1.4,2.0,3.25,8.0,23.0}	{2.9,1.8,1.4,1.1,1.01}	{0.5,1.5,2.5,3.5,4.5}	{1.28,2.2,4.5,13.0}	{4.0,1.66,1.18,1.04}	https://www.oddsportal.com/football/greece/super-league-2020-2021/aek-asteras-tripolis-ry0NqosP/#1X2;2	2023-05-07 23:32:41.059242+01
571	Atromitos	AEL Larissa	2021-02-20 17:15:00+00	1	1	2.14	3.0	5	2.9	2.0	0	1	1	0	5.0	2.6	2.3	4.33	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5}	{1.11,1.44,2.05,2.37,4.5,10.0,21.0}	{7.5,2.75,1.8,1.6,1.22,1.06,1.01}	{0.5,0.75,1.5,2.5,3.5}	{1.57,1.72,3.45,10.0,26.0}	{2.5,2.07,1.33,1.06,1.01}	{0.5,1.5,2.5,3.5}	{1.36,2.5,6.0,17.0}	{3.4,1.53,1.12,1.02}	https://www.oddsportal.com/football/greece/super-league-2020-2021/atromitos-ael-larissa-4v6lu5kt/#1X2;2	2023-05-07 23:33:11.963161+01
572	Apollon Smyrnis	Lamia	2021-02-18 17:15:00+00	0	1	2.7	2.87	4	3.5	1.9	0	0	1	0	4.0	3.1	2.1	3.45	{0.5,1.5,1.75,2.0,2.25,2.5,3.5,4.5,5.5}	{1.12,1.53,1.8,2.1,2.1,2.7,5.5,13.0,26.0}	{6.4,2.48,2.05,1.77,1.77,1.5,1.16,1.04,1.01}	{0.5,0.75,1.5,2.5,3.5}	{1.61,1.97,4.0,13.0,23.0}	{2.28,1.82,1.26,1.04,1.01}	{0.5,1.5,2.5,3.5}	{1.4,2.65,7.0,19.0}	{3.0,1.44,1.1,1.02}	https://www.oddsportal.com/football/greece/super-league-2020-2021/apollon-smyrnis-lamia-rToRFHdq/#1X2;2	2023-05-07 23:33:43.321303+01
573	AEL Larissa	AEK Athens FC	2021-02-15 17:15:00+00	2	4	7.5	3.8	2	7.0	2.08	2	2	2	0	2.25	7.0	2.35	1.95	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5}	{1.11,1.5,1.85,2.6,5.4,12.5,26.0}	{7.5,2.5,2.0,1.53,1.16,1.05,1.01}	{0.5,0.75,1.0,1.5,2.5,3.5}	{1.53,1.77,3.75,11.5,11.0}	{2.43,2.02,1.25,1.05,1.01}	{0.5,1.5,2.5,3.5}	{1.36,2.7,7.0,19.0}	{3.25,1.44,1.1,1.02}	https://www.oddsportal.com/football/greece/super-league-2020-2021/ael-larissa-aek-8fT5lRCm/#1X2;2	2023-05-07 23:34:13.052521+01
574	Giannina	PAOK	2021-02-15 17:15:00+00	0	2	12.0	4.5	1	8.5	2.4	2	0	0	0	1.91	8.5	2.75	1.72	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.06,1.33,1.8,2.0,3.6,7.5,13.0,26.0}	{10.5,3.75,2.05,1.95,1.33,1.12,1.04,1.01}	{0.5,0.75,1.0,1.5,2.5,3.5}	{1.44,1.82,3.0,7.0,21.0}	{3.0,1.97,1.44,1.1,1.01}	{0.5,1.5,2.5,3.5}	{1.3,2.25,4.6,11.0}	{4.0,1.72,1.2,1.05}	https://www.oddsportal.com/football/greece/super-league-2020-2021/giannina-paok-p0OUrNtP/#1X2;2	2023-05-07 23:34:43.536351+01
575	Panathinaikos	Olympiacos Piraeus	2021-02-14 19:30:00+00	2	1	5.25	3.6	2	5.5	2.1	1	1	0	1	2.45	5.5	2.4	2.1	{0.5,1.5,2.25,2.5,3.5,4.5,5.5}	{1.1,1.4,2.02,2.28,4.4,9.5,19.0}	{8.5,3.0,1.83,1.65,1.22,1.07,1.02}	{0.5,0.75,1.0,1.5,2.5,3.5}	{1.53,1.7,2.1,3.35,10.0,26.0}	{2.63,2.1,1.7,1.33,1.06,1.01}	{0.5,1.5,2.5,3.5}	{1.36,2.5,5.5,15.0}	{3.5,1.57,1.14,1.03}	https://www.oddsportal.com/football/greece/super-league-2020-2021/panathinaikos-olympiacos-piraeus-69PQq3RI/#1X2;2	2023-05-07 23:35:13.923148+01
576	OFI Crete	Volos	2021-02-14 17:15:00+00	1	2	2.15	3.4	4	2.87	2.0	0	1	2	0	4.5	2.5	2.3	4.1	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5}	{1.11,1.44,1.77,2.37,4.5,11.0,23.0}	{8.0,2.85,2.1,1.57,1.2,1.06,1.01}	{0.5,0.75,1.0,1.5,2.5,3.5}	{1.53,1.75,3.5,11.0,17.0}	{2.5,2.05,1.3,1.06,1.01}	{0.5,1.5,2.5,3.5}	{1.36,2.5,6.0,17.0}	{3.4,1.5,1.12,1.02}	https://www.oddsportal.com/football/greece/super-league-2020-2021/ofi-crete-volos-xzLMpqCC/#1X2;2	2023-05-07 23:35:44.033199+01
577	Aris	Panetolikos	2021-02-14 15:00:00+00	0	0	1.35	4.9	11	1.9	2.33	0	0	0	0	8.75	1.7	2.75	8.75	{0.5,1.5,2.25,2.5,3.5,4.5,5.5}	{1.07,1.34,1.88,2.1,3.8,8.0,17.0}	{10.5,3.3,1.98,1.77,1.28,1.1,1.02}	{0.5,1.0,1.5,2.5,3.5}	{1.44,2.05,3.0,9.0,23.0}	{2.88,1.75,1.36,1.08,1.01}	{0.5,1.5,2.5,3.5}	{1.33,2.37,5.0,15.0}	{3.75,1.61,1.16,1.03}	https://www.oddsportal.com/football/greece/super-league-2020-2021/aris-panetolikos-GKWDn5s0/#1X2;2	2023-05-07 23:36:14.372606+01
578	Apollon Smyrnis	Atromitos	2021-02-13 19:30:00+00	2	1	2.55	3.1	3	3.4	2.0	1	1	0	1	3.85	2.87	2.25	3.45	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5}	{1.11,1.44,1.77,2.05,2.37,4.5,10.0,21.0}	{7.5,2.75,2.1,1.8,1.57,1.2,1.06,1.01}	{0.5,0.75,1.5,2.5,3.5}	{1.53,1.75,3.5,11.0,17.0}	{2.5,2.05,1.3,1.05,1.01}	{0.5,1.5,2.5,3.5}	{1.36,2.5,6.0,17.0}	{3.4,1.5,1.12,1.02}	https://www.oddsportal.com/football/greece/super-league-2020-2021/apollon-smyrnis-atromitos-2HS9moSg/#1X2;2	2023-05-07 23:36:44.912628+01
579	Asteras Tripolis	Lamia	2021-02-13 17:15:00+00	0	0	1.83	3.1	6	2.75	1.95	0	0	0	0	6.25	2.25	2.25	5.5	{0.5,1.5,2.0,2.5,3.5,4.5,5.5}	{1.11,1.5,1.88,2.55,5.1,11.5,23.0}	{7.0,2.62,1.98,1.53,1.19,1.05,1.01}	{0.5,0.75,1.5,2.5,3.5}	{1.57,1.82,3.65,11.0,17.0}	{2.38,1.97,1.28,1.05,1.01}	{0.5,1.5,2.5,3.5}	{1.4,2.62,6.5,19.0}	{3.25,1.48,1.11,1.02}	https://www.oddsportal.com/football/greece/super-league-2020-2021/asteras-tripolis-lamia-bqMIoPd6/#1X2;2	2023-05-07 23:37:15.201939+01
580	Panetolikos	Giannina	2021-02-08 19:30:00+00	1	2	3.33	2.95	3	4.33	1.8	2	0	0	1	3.5	3.75	2.04	3.1	{0.5,1.5,1.75,2.0,2.25,2.5,3.5,4.5,5.5}	{1.16,1.8,2.05,2.0,3.5,8.0,19.0,34.0}	{5.8,2.25,1.8,1.85,1.36,1.11,1.02,1.01}	{0.5,0.75,1.0,1.5,2.5,3.5}	{1.75,2.07,5.0,17.0,34.0}	{2.18,1.72,1.22,1.03,1.01}	{0.5,1.5,2.5,3.5}	{1.5,3.4,10.0,26.0}	{2.75,1.36,1.07,1.01}	https://www.oddsportal.com/football/greece/super-league-2020-2021/panetolikos-giannina-jJlu7ZSE/#1X2;2	2023-05-07 23:37:46.518872+01
581	AEK Athens FC	Aris	2021-02-07 19:30:00+00	0	2	2.1	3.3	4	2.87	2.0	1	0	1	0	4.4	2.6	2.25	3.95	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5}	{1.1,1.5,1.85,2.0,2.4,4.7,11.0,23.0}	{7.5,2.8,2.0,1.85,1.55,1.2,1.05,1.01}	{0.5,0.75,1.0,1.5,2.5,3.5}	{1.53,1.8,3.5,11.0,26.0}	{2.5,2.0,1.33,1.06,1.01}	{0.5,1.5,2.5,3.5}	{1.36,2.62,6.5,19.0}	{3.25,1.5,1.11,1.02}	https://www.oddsportal.com/football/greece/super-league-2020-2021/aek-aris-O69tnYjk/#1X2;2	2023-05-07 23:38:16.404291+01
582	Olympiacos Piraeus	OFI Crete	2021-02-07 17:15:00+00	3	0	1.2	7.2	13	1.57	3.15	0	1	0	2	9.5	1.44	3.7	9.5	{0.5,1.5,2.5,3.25,3.5,4.5,5.5,6.5,7.5}	{1.02,1.14,1.5,2.0,2.2,3.65,7.0,13.0,26.0}	{19.0,6.1,2.75,1.85,1.66,1.28,1.11,1.04,1.01}	{0.5,1.25,1.5,2.5,3.5,4.5}	{1.25,1.82,2.1,4.6,13.0,17.0}	{4.3,1.97,1.67,1.2,1.05,1.01}	{0.5,1.5,2.5,3.5,4.5}	{1.16,1.72,3.4,7.0,17.0}	{5.5,2.1,1.34,1.1,1.02}	https://www.oddsportal.com/football/greece/super-league-2020-2021/olympiacos-piraeus-ofi-crete-bP1gqWz8/#1X2;2	2023-05-07 23:39:00.436168+01
583	Volos	Asteras Tripolis	2021-02-07 17:15:00+00	0	1	3.11	3.25	3	3.8	2.0	0	0	1	0	3.4	3.35	2.25	3.0	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5}	{1.11,1.48,1.93,2.5,4.8,11.0,23.0}	{7.5,2.65,1.93,1.54,1.18,1.05,1.01}	{0.5,0.75,1.0,1.5,2.5,3.5}	{1.6,1.82,3.55,11.0,17.0}	{2.43,1.97,1.28,1.05,1.01}	{0.5,1.5,2.5,3.5}	{1.36,2.62,6.5,19.0}	{3.25,1.5,1.11,1.02}	https://www.oddsportal.com/football/greece/super-league-2020-2021/volos-asteras-tripolis-pMckpCL1/#1X2;2	2023-05-07 23:39:30.830198+01
584	PAOK	Apollon Smyrnis	2021-02-07 15:00:00+00	2	2	1.25	5.75	12	1.75	2.8	2	1	0	1	8.5	1.55	3.25	8.0	{0.5,1.5,2.5,3.0,3.5,4.5,5.5,6.5}	{1.03,1.2,1.6,2.0,2.55,4.7,9.0,19.0}	{17.0,4.8,2.35,1.85,1.53,1.2,1.07,1.02}	{0.5,1.25,1.5,2.5,3.5}	{1.3,1.97,2.37,5.6,15.0}	{3.7,1.82,1.57,1.15,1.03}	{0.5,1.5,2.5,3.5,4.5}	{1.2,1.8,3.75,8.0,21.0}	{5.0,1.95,1.28,1.08,1.01}	https://www.oddsportal.com/football/greece/super-league-2020-2021/paok-apollon-smyrnis-CSky8FD8/#1X2;2	2023-05-07 23:40:01.391537+01
240	Lamia	Veria	2022-06-18 20:00:00+01	1	1	2.05	3.4	4	2.7	2.05	0	1	1	0	4.75	2.45	2.3	4.5	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.08,1.41,2.0,2.3,4.1,9.0,21.0,36.0}	{9.0,2.75,1.85,1.61,1.22,1.07,1.02,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.53,1.7,2.1,3.4,10.0,26.0,61.0}	{2.5,2.1,1.7,1.31,1.06,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.5,5.75,15.0}	{3.5,1.53,1.14,1.03}	https://www.oddsportal.com/football/greece/super-league-2021-2022/lamia-veria-tlo0Bd0g/#1X2;2	2023-05-07 20:40:01.549535+01
242	AEK Athens FC	Olympiacos Piraeus	2022-05-17 20:00:00+01	2	3	2.35	3.4	3	3.0	2.2	2	1	1	1	3.65	2.63	2.5	3.3	{0.5,1.5,2.5,3.5,4.5,5.5,6.5}	{1.06,1.29,1.95,3.3,6.75,15.0,23.0}	{11.0,3.65,1.9,1.33,1.11,1.03,1.0}	{0.5,1.0,1.5,2.5,3.5,4.5}	{1.4,1.9,2.85,8.0,21.0,51.0}	{2.95,1.9,1.4,1.08,1.01,1.0}	{0.5,1.5,2.5,3.5,4.5}	{1.23,2.08,4.33,11.0}	{4.0,1.72,1.2,1.05}	https://www.oddsportal.com/football/greece/super-league-2021-2022/aek-olympiacos-piraeus-0MRK7S51/#1X2;2	2023-05-07 20:41:04.733364+01
247	Lamia	Atromitos	2022-05-15 19:30:00+01	0	0	2.75	3.2	3	3.4	2.05	0	0	0	0	3.6	2.95	2.37	3.2	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.08,1.37,1.98,2.2,4.1,9.0,19.0,31.0}	{9.0,3.0,1.88,1.65,1.23,1.07,1.02,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.47,1.7,2.1,3.25,10.0,26.0,56.0}	{2.62,2.1,1.7,1.33,1.06,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.29,2.38,5.5,15.0}	{3.75,1.61,1.14,1.03}	https://www.oddsportal.com/football/greece/super-league-2021-2022/lamia-atromitos-zFbktmCQ/#1X2;2	2023-05-07 20:43:45.788462+01
254	PAOK	Aris	2022-05-11 18:30:00+01	0	1	2.15	3.1	4	2.95	1.95	1	0	0	0	4.6	2.6	2.2	4.1	{0.5,1.5,2.0,2.5,3.5,4.5,5.5,6.5}	{1.11,1.5,1.93,2.55,5.1,11.5,26.0,46.0}	{7.0,2.6,1.93,1.5,1.16,1.05,1.01,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.57,1.85,3.75,11.0,29.0,71.0}	{2.35,1.95,1.26,1.05,1.0,1.0}	{0.5,1.5,2.5,3.5}	{1.35,2.65,7.0,19.0}	{3.25,1.44,1.1,1.02}	https://www.oddsportal.com/football/greece/super-league-2021-2022/paok-aris-SEvYGWrF/#1X2;2	2023-05-07 20:47:31.125715+01
255	Aris	Olympiacos Piraeus	2022-05-08 21:00:00+01	0	1	1.57	4.0	7	2.2	2.28	1	0	0	0	7.0	1.85	2.63	6.25	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.07,1.33,1.73,2.05,3.7,7.5,15.0,26.0}	{11.0,3.5,2.15,1.85,1.3,1.1,1.03,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.5,1.9,3.0,8.0,23.0,56.0}	{2.9,1.9,1.36,1.08,1.02,1.0}	{0.5,1.5,2.5,3.5}	{1.33,2.3,5.0,13.0}	{3.75,1.65,1.18,1.04}	https://www.oddsportal.com/football/greece/super-league-2021-2022/aris-olympiacos-piraeus-YiuUHCT8/#1X2;2	2023-05-07 20:48:02.415964+01
259	Apollon Smyrnis	Lamia	2022-05-07 19:30:00+01	0	0	2.28	3.0	4	3.1	1.95	0	0	0	0	4.75	2.75	2.2	4.0	{0.5,1.5,2.0,2.5,3.5,4.5,5.5,6.5}	{1.12,1.51,1.95,2.7,5.6,13.0,26.0,46.0}	{6.5,2.5,1.9,1.47,1.16,1.04,1.01,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.6,1.85,3.9,12.0,29.0,71.0}	{2.25,1.95,1.25,1.05,1.0,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.62,6.5,19.0}	{3.25,1.44,1.11,1.02}	https://www.oddsportal.com/football/greece/super-league-2021-2022/apollon-smyrnis-lamia-bHckN75l/#1X2;2	2023-05-07 20:50:10.677656+01
261	Panetolikos	Volos	2022-05-07 19:30:00+01	0	0	2.05	3.65	4	2.62	2.28	0	0	0	0	4.0	2.3	2.6	3.75	{0.5,1.5,2.5,3.5,4.5,5.5,6.5}	{1.05,1.25,1.85,3.1,6.0,13.0,26.0}	{12.5,4.0,2.0,1.37,1.14,1.04,1.01}	{0.5,1.0,1.5,2.5,3.5,4.5}	{1.36,1.8,2.75,7.0,21.0,46.0}	{3.25,2.0,1.43,1.1,1.01,1.0}	{0.5,1.5,2.5,3.5,4.5}	{1.21,2.0,4.0,11.0,26.0}	{4.33,1.8,1.22,1.05,1.01}	https://www.oddsportal.com/football/greece/super-league-2021-2022/panetolikos-volos-IJDjLoz1/#1X2;2	2023-05-07 20:51:13.124552+01
264	Ionikos	Apollon Smyrnis	2022-05-02 19:30:00+01	5	1	3.75	3.8	2	4.5	2.23	1	3	0	2	2.62	4.0	2.45	2.33	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.07,1.35,1.85,2.07,3.9,8.0,17.0,29.0}	{10.5,3.25,2.0,1.72,1.25,1.08,1.02,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.44,2.05,3.25,9.0,26.0,56.0}	{2.95,1.75,1.33,1.07,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.26,2.3,5.5,15.0}	{3.75,1.58,1.15,1.03}	https://www.oddsportal.com/football/greece/super-league-2021-2022/ionikos-apollon-smyrnis-KQboOmjr/#1X2;2	2023-05-07 20:52:47.802979+01
267	Olympiacos Piraeus	Giannina	2022-05-01 17:00:00+01	3	2	1.22	6.0	15	1.66	2.6	1	1	1	2	12.0	1.47	3.1	11.0	{0.5,1.5,2.25,2.5,2.75,3.5,4.5,5.5,6.5}	{1.04,1.26,1.77,1.85,2.0,3.3,6.5,11.0,23.0}	{13.0,4.0,2.1,2.05,1.85,1.4,1.14,1.05,1.01}	{0.5,1.0,1.5,2.5,3.5,4.5}	{1.36,1.72,2.75,6.5,19.0,46.0}	{3.25,2.07,1.44,1.11,1.02,1.0}	{0.5,1.5,2.5,3.5,4.5}	{1.21,2.1,4.0,11.0,26.0}	{4.33,1.73,1.22,1.05,1.01}	https://www.oddsportal.com/football/greece/super-league-2021-2022/olympiacos-piraeus-giannina-hx0VdBiq/#1X2;2	2023-05-07 20:54:21.677641+01
268	Volos	Atromitos	2022-04-30 20:30:00+01	1	1	1.85	3.6	5	2.45	2.2	0	1	1	0	5.0	2.2	2.5	4.33	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.06,1.32,2.0,3.5,7.0,15.0,26.0}	{11.0,3.55,1.85,1.3,1.1,1.03,1.0}	{0.5,1.0,1.5,2.5,3.5,4.5}	{1.42,1.95,3.0,8.0,23.0,51.0}	{3.0,1.85,1.36,1.08,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.25,2.15,4.6,13.0}	{3.75,1.66,1.18,1.04}	https://www.oddsportal.com/football/greece/super-league-2021-2022/volos-atromitos-lr8FT9SK/#1X2;2	2023-05-07 20:54:57.488528+01
269	OFI Crete	Panetolikos	2022-04-30 17:30:00+01	0	1	2.0	3.5	4	2.7	2.25	1	0	0	0	4.0	2.45	2.6	3.6	{0.5,1.5,2.25,2.5,2.75,3.5,4.5,5.5,6.5}	{1.05,1.29,1.77,1.95,3.05,6.0,11.0,23.0}	{13.0,4.0,2.07,1.9,1.4,1.14,1.05,1.01}	{0.5,1.0,1.5,2.5,3.5,4.5}	{1.4,1.7,2.65,7.0,19.0,46.0}	{3.25,2.1,1.44,1.11,1.02,1.01}	{0.5,1.5,2.5,3.5,4.5}	{1.25,2.0,4.33,10.0,23.0}	{4.33,1.8,1.22,1.06,1.01}	https://www.oddsportal.com/football/greece/super-league-2021-2022/ofi-crete-panetolikos-6JIAUkDE/#1X2;2	2023-05-07 20:55:31.035231+01
271	Panathinaikos	Olympiacos Piraeus	2022-04-17 21:30:00+01	1	0	3.0	2.85	3	3.9	1.85	0	0	0	1	3.75	3.5	2.1	3.2	{0.5,1.5,1.75,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.12,1.57,1.8,2.13,2.87,6.0,15.0,26.0,51.0}	{6.4,2.35,2.05,1.75,1.47,1.14,1.04,1.01,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.62,1.97,4.1,13.0,34.0,81.0}	{2.28,1.82,1.25,1.04,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.4,2.8,8.0,21.0}	{2.85,1.4,1.1,1.02}	https://www.oddsportal.com/football/greece/super-league-2021-2022/panathinaikos-olympiacos-piraeus-jaSQSt04/#1X2;2	2023-05-07 20:56:33.462493+01
274	Atromitos	OFI Crete	2022-04-17 15:30:00+01	1	1	2.1	3.3	4	2.75	2.12	1	0	0	1	4.33	2.4	2.5	3.75	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.07,1.33,1.85,2.07,3.75,8.0,17.0,21.0}	{10.5,3.65,2.0,1.87,1.34,1.12,1.04,1.0}	{0.5,1.0,1.5,2.5,3.5,4.5}	{1.44,2.05,3.25,9.0,26.0,46.0}	{2.95,1.75,1.4,1.09,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.25,2.2,5.0,13.0}	{4.0,1.73,1.21,1.05}	https://www.oddsportal.com/football/greece/super-league-2021-2022/atromitos-ofi-crete-4peCzVcr/#1X2;2	2023-05-07 20:58:09.740776+01
276	Apollon Smyrnis	Volos	2022-04-16 16:00:00+01	1	1	2.02	3.4	5	2.62	2.1	1	1	0	0	5.0	2.25	2.43	4.6	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.08,1.37,1.93,2.16,3.85,9.0,19.0,31.0}	{9.5,3.25,1.93,1.71,1.25,1.08,1.02,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.47,1.67,2.1,3.25,10.0,26.0,61.0}	{2.8,2.15,1.7,1.33,1.06,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.28,2.28,5.5,15.0}	{3.5,1.57,1.14,1.03}	https://www.oddsportal.com/football/greece/super-league-2021-2022/apollon-smyrnis-volos-YcYvgwE9/#1X2;2	2023-05-07 20:59:12.686673+01
278	Giannina	Panathinaikos	2022-04-10 19:00:00+01	0	0	4.2	3.1	2	4.75	1.95	0	0	0	0	2.9	4.25	2.23	2.5	{0.5,1.5,2.0,2.5,3.5,4.5,5.5,6.5}	{1.12,1.5,2.0,2.7,5.5,13.0,21.0,46.0}	{7.5,2.65,1.85,1.52,1.16,1.05,1.01,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.61,1.87,3.75,13.0,31.0,71.0}	{2.45,1.92,1.25,1.04,1.0,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.63,7.0,21.0}	{3.0,1.44,1.1,1.02}	https://www.oddsportal.com/football/greece/super-league-2021-2022/giannina-panathinaikos-IeXW6awo/#1X2;2	2023-05-07 21:00:20.986109+01
281	OFI Crete	Apollon Smyrnis	2022-04-09 18:15:00+01	1	2	1.85	3.5	5	2.5	2.1	1	1	1	0	5.1	2.2	2.45	4.8	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.06,1.33,1.83,2.14,4.1,8.5,17.0,29.0}	{10.0,3.25,2.02,1.75,1.26,1.09,1.02,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.44,2.02,3.15,9.0,26.0,56.0}	{2.7,1.77,1.36,1.07,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.25,2.2,5.0,13.0}	{3.75,1.61,1.16,1.04}	https://www.oddsportal.com/football/greece/super-league-2021-2022/ofi-crete-apollon-smyrnis-OSjlWF6d/#1X2;2	2023-05-07 21:01:55.852971+01
283	Olympiacos Piraeus	AEK Athens FC	2022-04-03 20:00:00+01	1	1	1.9	3.75	4	2.55	2.1	0	0	1	1	4.75	2.38	2.4	4.33	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.08,1.36,1.88,2.1,3.75,8.0,19.0,29.0}	{9.0,3.0,1.98,1.75,1.25,1.08,1.02,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.5,2.07,3.25,9.0,26.0,56.0}	{2.62,1.72,1.34,1.07,1.02,1.0}	{0.5,1.5,2.5,3.5,4.5}	{1.33,2.38,5.5,15.0}	{3.5,1.57,1.15,1.03}	https://www.oddsportal.com/football/greece/super-league-2021-2022/olympiacos-piraeus-aek-Gno5BuVT/#1X2;2	2023-05-07 21:03:00.407484+01
285	Aris	Giannina	2022-04-03 17:00:00+01	0	0	1.57	3.6	7	2.25	2.0	0	0	0	0	7.5	1.93	2.3	6.5	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.11,1.5,2.0,2.25,2.6,5.0,13.0,26.0,46.0}	{6.5,2.5,1.85,1.68,1.47,1.16,1.05,1.01,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.57,1.85,3.75,11.0,29.0,71.0}	{2.3,1.95,1.26,1.05,1.0,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.65,7.0,19.0}	{3.0,1.44,1.1,1.02}	https://www.oddsportal.com/football/greece/super-league-2021-2022/aris-giannina-KKidD10H/#1X2;2	2023-05-07 21:04:03.212472+01
288	Asteras Tripolis	Atromitos	2022-04-02 17:15:00+01	0	0	2.0	3.2	4	2.75	1.95	0	0	0	0	4.75	2.37	2.2	4.1	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.11,1.5,1.9,2.5,5.0,11.0,26.0,41.0}	{6.5,2.5,1.95,1.58,1.18,1.05,1.01,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.53,1.82,3.75,11.0,26.0,67.0}	{2.37,1.97,1.28,1.05,1.0,1.0}	{0.5,1.5,2.5,3.5}	{1.34,2.62,6.5,19.0}	{3.25,1.46,1.11,1.02}	https://www.oddsportal.com/football/greece/super-league-2021-2022/asteras-tripolis-atromitos-bo79wbEM/#1X2;2	2023-05-07 21:05:34.066983+01
290	AEK Athens FC	PAOK	2022-03-20 19:30:00+00	0	1	1.83	3.4	5	2.5	2.1	1	0	0	0	5.0	2.2	2.4	4.33	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.08,1.36,1.9,2.1,4.0,9.0,19.0,31.0}	{8.0,3.0,1.95,1.7,1.24,1.08,1.02,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.46,2.07,3.25,10.0,26.0,61.0}	{2.62,1.72,1.33,1.06,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.28,2.25,5.5,15.0}	{3.5,1.57,1.15,1.03}	https://www.oddsportal.com/football/greece/super-league-2021-2022/aek-paok-n9SaWJhJ/#1X2;2	2023-05-07 21:06:46.78857+01
292	Giannina	Olympiacos Piraeus	2022-03-20 15:30:00+00	1	1	6.5	3.5	2	6.0	2.1	0	1	1	0	2.35	5.5	2.4	2.0	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.08,1.38,1.95,2.2,4.0,9.0,19.0,31.0}	{8.0,3.0,1.9,1.66,1.23,1.07,1.02,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.49,2.1,3.25,10.0,26.0,61.0}	{2.62,1.7,1.33,1.06,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.28,2.25,5.5,15.0}	{3.5,1.57,1.14,1.03}	https://www.oddsportal.com/football/greece/super-league-2021-2022/giannina-olympiacos-piraeus-EeUiYuO6/#1X2;2	2023-05-07 21:07:48.117268+01
295	Volos	Asteras Tripolis	2022-03-19 17:15:00+00	0	2	2.2	3.3	3	3.0	2.0	0	0	2	0	4.0	2.6	2.3	3.5	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.08,1.4,2.02,2.25,4.33,10.0,21.0,36.0}	{8.0,2.75,1.83,1.61,1.21,1.06,1.01,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.5,1.72,3.4,10.0,26.0,67.0}	{2.5,2.07,1.3,1.06,1.0,1.0}	{0.5,1.5,2.5,3.5}	{1.3,2.37,6.0,17.0}	{3.4,1.53,1.13,1.02}	https://www.oddsportal.com/football/greece/super-league-2021-2022/volos-asteras-tripolis-Ya3RxNhG/#1X2;2	2023-05-07 21:09:18.611634+01
297	PAOK	Giannina	2022-03-13 21:30:00+00	1	0	1.4	4.6	10	1.9	2.37	0	1	0	0	8.0	1.68	2.75	8.0	{0.5,1.5,2.5,3.5,4.5,5.5,6.5}	{1.06,1.29,1.9,3.25,6.0,13.0,26.0}	{9.75,3.75,1.95,1.33,1.12,1.04,1.01}	{0.5,1.0,1.5,2.5,3.5,4.5}	{1.36,1.82,2.75,7.0,21.0,51.0}	{3.0,1.97,1.4,1.1,1.01,1.0}	{0.5,1.5,2.5,3.5,4.5}	{1.23,2.1,4.5,11.0,26.0}	{4.0,1.72,1.2,1.05,1.01}	https://www.oddsportal.com/football/greece/super-league-2021-2022/paok-giannina-xY9IvqO3/#1X2;2	2023-05-07 21:10:20.96436+01
298	Panathinaikos	AEK Athens FC	2022-03-13 19:30:00+00	1	1	2.3	3.2	3	3.1	1.95	0	0	1	1	4.0	2.62	2.25	3.5	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.09,1.44,1.83,2.4,4.5,11.0,23.0,36.0}	{7.5,2.65,2.02,1.57,1.21,1.06,1.01,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.53,1.77,3.5,11.0,26.0,61.0}	{2.4,2.02,1.3,1.06,1.0,1.0}	{0.5,1.5,2.5,3.5}	{1.33,2.5,6.0,17.0}	{3.25,1.5,1.12,1.02}	https://www.oddsportal.com/football/greece/super-league-2021-2022/panathinaikos-aek-rBAEuP8c/#1X2;2	2023-05-07 21:10:52.025099+01
304	Lamia	PAOK	2022-03-06 19:00:00+00	0	2	5.1	3.6	2	5.0	2.2	1	0	1	0	2.37	4.5	2.5	2.05	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.06,1.33,1.85,2.07,3.5,7.0,15.0,29.0}	{9.5,3.4,2.0,1.75,1.28,1.1,1.03,1.0}	{0.5,1.0,1.5,2.5,3.5,4.5}	{1.43,2.05,3.0,8.0,23.0,56.0}	{2.75,1.75,1.36,1.08,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.26,2.2,5.0,13.0}	{3.75,1.61,1.16,1.04}	https://www.oddsportal.com/football/greece/super-league-2021-2022/lamia-paok-0vwpCYmN/#1X2;2	2023-05-07 21:13:59.319503+01
307	Atromitos	Volos	2022-03-03 19:30:00+00	2	1	2.1	3.3	4	2.75	2.1	0	1	1	1	4.2	2.45	2.37	3.85	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.07,1.36,1.9,2.16,4.1,8.5,17.0,29.0}	{9.0,3.25,1.95,1.7,1.26,1.09,1.02,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.44,2.07,3.25,9.0,26.0,56.0}	{2.7,1.72,1.36,1.07,1.02,1.0}	{0.5,1.5,2.5,3.5,4.5}	{1.33,2.35,5.0,13.0}	{3.75,1.61,1.16,1.04}	https://www.oddsportal.com/football/greece/super-league-2021-2022/atromitos-volos-CMKKZeNt/#1X2;2	2023-05-07 21:15:32.08012+01
311	Giannina	Lamia	2022-02-28 19:30:00+00	1	0	1.93	3.2	5	2.62	2.0	0	0	0	1	5.0	2.3	2.25	4.6	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.1,1.44,1.77,2.45,4.9,11.0,23.0,41.0}	{7.5,2.65,2.1,1.57,1.19,1.06,1.01,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.53,1.77,3.55,11.0,26.0,67.0}	{2.43,2.02,1.28,1.05,1.0,1.0}	{0.5,1.5,2.5,3.5}	{1.33,2.62,6.5,19.0}	{3.25,1.46,1.11,1.02}	https://www.oddsportal.com/football/greece/super-league-2021-2022/giannina-lamia-0ptf3w5h/#1X2;2	2023-05-07 21:17:36.836797+01
314	PAOK	Ionikos	2022-02-27 17:15:00+00	1	1	1.5	4.35	8	2.05	2.35	1	0	0	1	7.0	1.75	2.75	6.75	{0.5,1.5,2.5,2.75,3.5,4.5,5.5,6.5}	{1.06,1.27,1.88,3.25,6.4,13.0,26.0}	{11.5,3.8,1.98,1.34,1.12,1.04,1.01}	{0.5,1.0,1.5,2.5,3.5,4.5}	{1.36,1.82,2.75,7.0,21.0,46.0}	{3.05,1.97,1.43,1.1,1.01,1.0}	{0.5,1.5,2.5,3.5,4.5}	{1.22,2.08,4.33,11.0,26.0}	{4.0,1.72,1.2,1.05,1.01}	https://www.oddsportal.com/football/greece/super-league-2021-2022/paok-ionikos-0QcBcZYT/#1X2;2	2023-05-07 21:19:10.345522+01
317	Ionikos	Apollon Smyrnis	2022-02-23 19:30:00+00	4	0	1.7	3.8	7	2.4	2.05	0	1	0	3	7.5	2.12	2.37	6.5	{0.5,1.5,2.0,2.5,3.5,4.5,5.5,6.5}	{1.1,1.46,1.77,2.55,5.2,12.0,23.0,41.0}	{7.5,2.62,2.1,1.57,1.18,1.06,1.01,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.53,1.75,3.65,11.0,29.0,71.0}	{2.5,2.05,1.28,1.05,1.0,1.0}	{0.5,1.5,2.5,3.5}	{1.33,2.7,6.5,19.0}	{3.25,1.5,1.12,1.02}	https://www.oddsportal.com/football/greece/super-league-2021-2022/ionikos-apollon-smyrnis-UN4lTB6O/#1X2;2	2023-05-07 21:20:42.947494+01
318	Aris	Atromitos	2022-02-23 18:00:00+00	3	0	1.5	4.0	8	2.1	2.12	0	2	0	1	7.5	1.84	2.45	7.0	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.08,1.43,1.73,2.05,2.43,4.9,11.0,21.0,36.0}	{8.0,2.75,2.15,1.8,1.6,1.22,1.07,1.01,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.5,1.72,3.5,10.0,26.0,67.0}	{2.55,2.07,1.3,1.06,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.3,2.63,6.0,17.0}	{3.4,1.53,1.13,1.02}	https://www.oddsportal.com/football/greece/super-league-2021-2022/aris-atromitos-dA6tVXyC/#1X2;2	2023-05-07 21:21:15.181493+01
320	AEK Athens FC	Giannina	2022-02-20 19:30:00+00	2	0	1.4	5.0	10	1.85	2.37	0	2	0	0	9.0	1.67	2.8	8.0	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.06,1.3,1.83,2.07,3.9,8.0,15.0,26.0}	{10.0,3.5,2.02,1.9,1.3,1.11,1.03,1.0}	{0.5,1.0,1.5,2.5,3.5,4.5}	{1.4,1.85,3.05,8.0,21.0,51.0}	{3.0,1.95,1.4,1.08,1.01,1.0}	{0.5,1.5,2.5,3.5,4.5}	{1.23,2.3,4.5,13.0}	{4.0,1.66,1.18,1.04}	https://www.oddsportal.com/football/greece/super-league-2021-2022/aek-giannina-QTrN0pqf/#1X2;2	2023-05-07 21:22:16.871991+01
323	Lamia	Apollon Smyrnis	2022-02-20 15:00:00+00	1	2	2.0	3.2	5	2.8	1.9	1	1	1	0	5.5	2.5	2.15	4.5	{0.5,1.5,1.75,2.0,2.5,3.5,4.5,5.5,6.5}	{1.12,1.6,1.77,2.8,6.0,15.0,26.0,51.0}	{6.4,2.38,2.1,1.46,1.14,1.04,1.01,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.67,1.95,4.0,13.0,31.0,81.0}	{2.28,1.85,1.24,1.04,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.4,2.8,8.0,23.0}	{2.75,1.4,1.08,1.02}	https://www.oddsportal.com/football/greece/super-league-2021-2022/lamia-apollon-smyrnis-ILjk4Jkn/#1X2;2	2023-05-07 21:23:51.186544+01
325	Panetolikos	Panathinaikos	2022-02-19 19:30:00+00	1	0	3.65	3.15	2	4.3	2.0	0	1	0	0	3.2	4.0	2.28	2.75	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.1,1.42,2.05,2.32,4.5,10.0,21.0,36.0}	{8.0,2.85,1.8,1.6,1.2,1.06,1.01,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.5,1.72,3.5,11.0,23.0,61.0}	{2.55,2.07,1.31,1.06,1.0,1.0}	{0.5,1.5,2.5,3.5}	{1.33,2.5,6.0,17.0}	{3.4,1.53,1.12,1.02}	https://www.oddsportal.com/football/greece/super-league-2021-2022/panetolikos-panathinaikos-vVio5azt/#1X2;2	2023-05-07 21:24:53.734305+01
327	Apollon Smyrnis	Panathinaikos	2022-02-16 18:30:00+00	0	3	6.4	4.0	2	7.5	2.12	1	0	2	0	2.2	6.0	2.43	1.95	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.09,1.44,1.83,2.35,4.6,11.0,23.0,36.0}	{8.5,2.85,2.02,1.57,1.19,1.06,1.01,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.53,1.77,3.5,11.0,26.0,67.0}	{2.63,2.02,1.28,1.05,1.0,1.0}	{0.5,1.5,2.5,3.5}	{1.33,2.62,6.5,19.0}	{3.25,1.49,1.12,1.02}	https://www.oddsportal.com/football/greece/super-league-2021-2022/apollon-smyrnis-panathinaikos-fBgG7wvl/#1X2;2	2023-05-07 21:25:58.398624+01
330	Giannina	Aris	2022-02-14 19:30:00+00	2	0	3.6	2.75	3	4.35	1.8	0	2	0	0	3.6	3.9	2.05	3.0	{0.5,1.5,1.75,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.16,1.66,2.0,2.2,3.4,7.0,17.0,29.0,56.0}	{5.4,2.17,1.85,1.7,1.36,1.11,1.03,1.0,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.75,2.05,4.5,15.0,36.0,91.0}	{2.1,1.75,1.21,1.03,1.0,1.0}	{0.5,1.5,2.5,3.5}	{1.44,3.25,9.0,26.0}	{2.65,1.38,1.07,1.01}	https://www.oddsportal.com/football/greece/super-league-2021-2022/giannina-aris-vXMio5q7/#1X2;2	2023-05-07 21:27:33.080966+01
332	PAOK	Atromitos	2022-02-13 17:15:00+00	1	0	1.33	5.5	11	1.8	2.6	0	1	0	0	8.5	1.57	3.0	8.0	{0.5,1.5,2.5,2.75,3.5,4.5,5.5,6.5}	{1.05,1.25,1.75,1.98,3.0,5.75,11.0,23.0}	{14.0,4.1,2.07,1.88,1.4,1.14,1.05,1.01}	{0.5,1.0,1.25,1.5,2.5,3.5,4.5}	{1.33,1.7,2.1,2.62,6.5,19.0,46.0}	{3.4,2.1,1.7,1.44,1.11,1.02,1.0}	{0.5,1.5,2.5,3.5,4.5}	{1.21,2.0,4.2,10.0,26.0}	{4.33,1.8,1.22,1.06,1.01}	https://www.oddsportal.com/football/greece/super-league-2021-2022/paok-atromitos-nwpJ1QTm/#1X2;2	2023-05-07 21:28:37.824914+01
334	OFI Crete	Volos	2022-02-13 15:00:00+00	2	1	1.83	3.75	5	2.4	2.2	1	0	0	2	5.0	2.17	2.5	4.33	{0.5,1.5,2.5,3.5,4.5,5.5,6.5}	{1.06,1.31,1.93,3.3,6.5,15.0,26.0}	{11.0,3.65,1.93,1.33,1.11,1.03,1.0}	{0.5,1.0,1.5,2.5,3.5,4.5}	{1.4,1.85,2.8,8.0,21.0,51.0}	{3.0,1.95,1.4,1.08,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.25,2.15,4.6,11.0}	{4.0,1.72,1.2,1.05}	https://www.oddsportal.com/football/greece/super-league-2021-2022/ofi-crete-volos-Sh3n7n6Q/#1X2;2	2023-05-07 21:29:40.711598+01
337	Atromitos	Lamia	2022-02-10 17:15:00+00	3	1	2.25	3.1	4	3.0	1.9	0	3	1	0	4.33	2.7	2.2	3.9	{0.5,1.5,2.0,2.5,3.5,4.5,5.5,6.5}	{1.11,1.51,2.0,2.63,5.5,13.0,26.0,46.0}	{6.75,2.5,1.85,1.47,1.15,1.04,1.01,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.57,1.87,3.8,13.0,29.0,71.0}	{2.35,1.92,1.25,1.04,1.0,1.0}	{0.5,1.5,2.5,3.5}	{1.37,2.65,7.0,19.0}	{3.0,1.44,1.1,1.02}	https://www.oddsportal.com/football/greece/super-league-2021-2022/atromitos-lamia-Awf6Z7pe/#1X2;2	2023-05-07 21:31:15.436999+01
339	Ionikos	Olympiacos Piraeus	2022-02-06 17:15:00+00	0	3	8.45	4.5	1	8.5	2.2	2	0	1	0	2.05	7.5	2.5	1.8	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.08,1.41,1.98,2.25,4.4,9.5,21.0,36.0}	{8.5,2.95,1.88,1.65,1.22,1.07,1.01,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.47,2.1,3.3,10.0,26.0,61.0}	{2.65,1.7,1.33,1.06,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.3,2.48,6.0,17.0}	{3.5,1.53,1.12,1.02}	https://www.oddsportal.com/football/greece/super-league-2021-2022/ionikos-olympiacos-piraeus-AwGykmpr/#1X2;2	2023-05-07 21:32:16.985463+01
346	OFI Crete	Panathinaikos	2022-02-02 17:15:00+00	3	2	3.8	3.2	2	4.5	1.95	0	2	2	1	3.1	4.0	2.2	2.7	{0.5,1.5,2.0,2.5,3.5,4.5,5.5,6.5}	{1.11,1.5,1.85,2.5,5.0,11.0,26.0,41.0}	{7.5,2.75,2.0,1.54,1.18,1.05,1.02,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.57,1.8,3.75,11.0,26.0,67.0}	{2.43,2.0,1.29,1.05,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.62,6.5,19.0}	{3.25,1.5,1.11,1.02}	https://www.oddsportal.com/football/greece/super-league-2021-2022/ofi-crete-panathinaikos-IuycdVi8/#1X2;2	2023-05-07 21:36:12.150971+01
353	Ionikos	Atromitos	2022-01-29 17:15:00+00	2	1	2.6	3.1	3	3.4	1.95	1	0	0	2	3.8	3.0	2.2	3.4	{0.5,1.5,2.0,2.5,3.5,4.5,5.5,6.5}	{1.11,1.53,1.9,2.62,5.1,11.5,26.0,41.0}	{7.0,2.62,1.95,1.51,1.18,1.05,1.01,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.6,1.82,3.75,11.0,26.0,67.0}	{2.37,1.97,1.28,1.05,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.65,6.5,19.0}	{3.25,1.46,1.11,1.02}	https://www.oddsportal.com/football/greece/super-league-2021-2022/ionikos-atromitos-WW6vL8V1/#1X2;2	2023-05-07 21:39:56.676664+01
355	Panathinaikos	Asteras Tripolis	2022-01-29 15:00:00+00	0	1	1.66	3.5	7	2.5	2.02	1	0	0	0	7.0	2.05	2.32	6.0	{0.5,1.5,1.75,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.14,1.57,1.83,2.2,2.87,6.0,15.0,26.0,41.0}	{7.5,2.7,2.02,1.7,1.51,1.17,1.05,1.01,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.61,1.97,4.0,13.0,29.0,71.0}	{2.48,1.82,1.29,1.05,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.4,3.0,8.0,23.0}	{3.0,1.44,1.11,1.02}	https://www.oddsportal.com/football/greece/super-league-2021-2022/panathinaikos-asteras-tripolis-WOCFqh82/#1X2;2	2023-05-07 21:41:02.973235+01
360	Aris	Lamia	2022-01-23 15:00:00+00	0	0	1.55	3.75	8	2.25	2.05	0	0	0	0	7.5	1.95	2.35	6.5	{0.5,1.5,2.0,2.5,3.5,4.5,5.5,6.5}	{1.11,1.5,1.85,2.5,5.1,11.5,26.0,41.0}	{7.5,2.62,2.0,1.53,1.17,1.05,1.01,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.6,1.77,3.75,11.0,29.0,71.0}	{2.43,2.02,1.28,1.05,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.4,2.75,6.5,19.0}	{3.25,1.44,1.11,1.02}	https://www.oddsportal.com/football/greece/super-league-2021-2022/aris-lamia-b5Tc8Vod/#1X2;2	2023-05-07 21:43:48.993271+01
364	Giannina	Atromitos	2022-01-16 19:30:00+00	1	1	1.98	3.5	4	2.7	2.1	0	0	1	1	5.0	2.4	2.37	4.33	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.1,1.44,1.95,2.3,4.1,9.0,19.0,36.0}	{8.5,3.0,1.9,1.66,1.22,1.07,1.02,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.57,1.67,2.1,3.4,10.0,26.0,67.0}	{2.62,2.15,1.7,1.33,1.06,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.5,5.75,15.0}	{3.5,1.57,1.14,1.03}	https://www.oddsportal.com/football/greece/super-league-2021-2022/giannina-atromitos-zPJ8UL2b/#1X2;2	2023-05-07 21:45:55.775733+01
367	Apollon Smyrnis	Aris	2022-01-15 19:30:00+00	0	0	5.28	3.5	2	6.0	2.0	0	0	0	0	2.5	5.5	2.3	2.15	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.1,1.44,1.77,2.1,2.35,4.5,11.0,23.0,36.0}	{7.5,2.62,2.1,1.77,1.57,1.22,1.06,1.01,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.57,1.75,3.5,11.0,26.0,67.0}	{2.5,2.05,1.29,1.05,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.5,6.5,19.0}	{3.25,1.5,1.12,1.02}	https://www.oddsportal.com/football/greece/super-league-2021-2022/apollon-smyrnis-aris-Im9DTuI4/#1X2;2	2023-05-07 21:47:29.852214+01
369	Asteras Tripolis	Volos	2022-01-15 17:15:00+00	1	0	1.65	4.2	7	2.2	2.25	0	0	0	1	6.5	1.98	2.6	5.5	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.06,1.32,1.95,3.4,6.5,15.0,29.0}	{10.0,3.5,1.9,1.3,1.11,1.03,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.44,1.87,3.0,8.0,21.0,51.0}	{2.75,1.92,1.4,1.08,1.02,1.0}	{0.5,1.5,2.5,3.5}	{1.3,2.2,4.75,13.0}	{4.0,1.66,1.18,1.04}	https://www.oddsportal.com/football/greece/super-league-2021-2022/asteras-tripolis-volos-WjDHSaXA/#1X2;2	2023-05-07 21:48:31.578617+01
372	PAOK	Panetolikos	2022-01-12 17:15:00+00	2	0	1.42	5.0	8	1.95	2.55	0	1	0	1	6.5	1.72	3.0	6.4	{0.5,1.5,2.5,2.75,3.0,3.5,4.5,5.5,6.5}	{1.04,1.22,1.68,1.83,2.1,2.7,4.8,10.0,21.0}	{16.0,4.8,2.28,2.02,1.77,1.48,1.18,1.06,1.01}	{0.5,1.0,1.25,1.5,2.5,3.5,4.5}	{1.33,2.05,2.5,6.0,17.0,41.0}	{3.6,1.75,1.53,1.14,1.03,1.01}	{0.5,1.5,2.5,3.5,4.5}	{1.22,1.91,3.8,9.0,23.0}	{4.5,1.88,1.25,1.07,1.01}	https://www.oddsportal.com/football/greece/super-league-2021-2022/paok-panetolikos-6LDTXZig/#1X2;2	2023-05-07 21:50:11.021108+01
374	OFI Crete	Giannina	2022-01-08 17:15:00+00	1	1	2.35	3.1	4	3.25	1.95	1	1	0	0	4.33	2.75	2.23	3.75	{0.5,1.5,2.0,2.5,3.5,4.5,5.5,6.5}	{1.11,1.5,1.88,2.5,5.0,11.0,26.0,46.0}	{7.5,2.75,1.98,1.52,1.17,1.05,1.01,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.57,1.8,3.75,11.0,29.0,71.0}	{2.48,2.0,1.28,1.05,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.65,6.5,19.0}	{3.25,1.5,1.11,1.02}	https://www.oddsportal.com/football/greece/super-league-2021-2022/ofi-crete-giannina-AHMdXNIu/#1X2;2	2023-05-07 21:51:12.756973+01
\.


--
-- TOC entry 3129 (class 0 OID 0)
-- Dependencies: 201
-- Name: 1x2_oddsportal_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."1x2_oddsportal_id_seq"', 1, false);


--
-- TOC entry 3130 (class 0 OID 0)
-- Dependencies: 203
-- Name: Match_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."Match_id_seq"', 2471, true);


--
-- TOC entry 3131 (class 0 OID 0)
-- Dependencies: 208
-- Name: OverUnderHistorical_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."OverUnderHistorical_id_seq"', 238, true);


--
-- TOC entry 3132 (class 0 OID 0)
-- Dependencies: 204
-- Name: OverUnder_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."OverUnder_id_seq"', 23613, true);


--
-- TOC entry 3133 (class 0 OID 0)
-- Dependencies: 212
-- Name: soccer_statistics_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.soccer_statistics_id_seq', 720, true);


--
-- TOC entry 2934 (class 2606 OID 16493)
-- Name: 1x2_oddsportal 1x2_oddsportal_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."1x2_oddsportal"
    ADD CONSTRAINT "1x2_oddsportal_pkey" PRIMARY KEY (id);


--
-- TOC entry 2936 (class 2606 OID 16495)
-- Name: 1x2_oddsportal 1x2_oddsportal_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."1x2_oddsportal"
    ADD CONSTRAINT "1x2_oddsportal_unique" UNIQUE (date_time, home_team, guest_team, half);


--
-- TOC entry 2938 (class 2606 OID 16497)
-- Name: OddsPortalMatch OddsPortalMatch_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsPortalMatch"
    ADD CONSTRAINT "OddsPortalMatch_pk" PRIMARY KEY (id);


--
-- TOC entry 2940 (class 2606 OID 16499)
-- Name: OddsPortalMatch OddsPortalMatch_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsPortalMatch"
    ADD CONSTRAINT "OddsPortalMatch_unique" UNIQUE (home_team, guest_team, date_time);


--
-- TOC entry 2942 (class 2606 OID 16501)
-- Name: OddsPortalOverUnder OddsPortalOverUnder_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsPortalOverUnder"
    ADD CONSTRAINT "OddsPortalOverUnder_pk" PRIMARY KEY (id, match_id, half, type, goals);


--
-- TOC entry 2944 (class 2606 OID 16503)
-- Name: OddsPortalOverUnder OddsPortalOverUnder_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsPortalOverUnder"
    ADD CONSTRAINT "OddsPortalOverUnder_unique" UNIQUE (goals, match_id, half, type);


--
-- TOC entry 2947 (class 2606 OID 16505)
-- Name: OddsSafariMatch OddsSafariMatch_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsSafariMatch"
    ADD CONSTRAINT "OddsSafariMatch_pk" PRIMARY KEY (id);


--
-- TOC entry 2949 (class 2606 OID 16507)
-- Name: OddsSafariMatch OddsSafariMatch_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsSafariMatch"
    ADD CONSTRAINT "OddsSafariMatch_unique" UNIQUE (home_team, guest_team, date_time);


--
-- TOC entry 2951 (class 2606 OID 16509)
-- Name: OddsSafariOverUnder OddsSafariOverUnder_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsSafariOverUnder"
    ADD CONSTRAINT "OddsSafariOverUnder_pk" PRIMARY KEY (id);


--
-- TOC entry 2953 (class 2606 OID 16511)
-- Name: OddsSafariOverUnder OddsSafariOverUnder_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsSafariOverUnder"
    ADD CONSTRAINT "OddsSafariOverUnder_unique" UNIQUE (goals, match_id, half, type);


--
-- TOC entry 2957 (class 2606 OID 16513)
-- Name: OverUnderHistorical OverUnderHistorical_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OverUnderHistorical"
    ADD CONSTRAINT "OverUnderHistorical_pkey" PRIMARY KEY (id);


--
-- TOC entry 2959 (class 2606 OID 16595)
-- Name: soccer_statistics soccer_statistics_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.soccer_statistics
    ADD CONSTRAINT soccer_statistics_pkey PRIMARY KEY (id);


--
-- TOC entry 2961 (class 2606 OID 16597)
-- Name: soccer_statistics soccer_statistics_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.soccer_statistics
    ADD CONSTRAINT soccer_statistics_unique UNIQUE (home_team, guest_team, date_time);


--
-- TOC entry 2945 (class 1259 OID 16516)
-- Name: fki_OddsPortalOverUnder_Match_fk; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "fki_OddsPortalOverUnder_Match_fk" ON public."OddsPortalOverUnder" USING btree (match_id);


--
-- TOC entry 2954 (class 1259 OID 16517)
-- Name: fki_OddsSafariOverUnder_Match_fk; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "fki_OddsSafariOverUnder_Match_fk" ON public."OddsSafariOverUnder" USING btree (match_id);


--
-- TOC entry 2955 (class 1259 OID 16518)
-- Name: fki_OddsSafariOverUnder_match_id_fk; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "fki_OddsSafariOverUnder_match_id_fk" ON public."OddsSafariOverUnder" USING btree (match_id);


--
-- TOC entry 2964 (class 2620 OID 16519)
-- Name: OddsPortalOverUnder update_updated_Match_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER "update_updated_Match_trigger" AFTER UPDATE ON public."OddsPortalOverUnder" FOR EACH ROW EXECUTE FUNCTION public."update_updated_on_Match"();


--
-- TOC entry 2965 (class 2620 OID 16520)
-- Name: OddsPortalOverUnder update_updated_OverUnder_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER "update_updated_OverUnder_trigger" AFTER UPDATE ON public."OddsPortalOverUnder" FOR EACH ROW EXECUTE FUNCTION public."update_updated_on_OverUnder"();


--
-- TOC entry 2962 (class 2606 OID 16521)
-- Name: OddsPortalOverUnder OddsPortalOverUnder_Match_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsPortalOverUnder"
    ADD CONSTRAINT "OddsPortalOverUnder_Match_fk" FOREIGN KEY (match_id) REFERENCES public."OddsPortalMatch"(id) ON UPDATE CASCADE ON DELETE CASCADE NOT VALID;


--
-- TOC entry 2963 (class 2606 OID 16526)
-- Name: OddsSafariOverUnder OddsSafariOverUnder_Match_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsSafariOverUnder"
    ADD CONSTRAINT "OddsSafariOverUnder_Match_fk" FOREIGN KEY (match_id) REFERENCES public."OddsSafariMatch"(id) ON UPDATE CASCADE ON DELETE CASCADE NOT VALID;


--
-- TOC entry 3117 (class 0 OID 0)
-- Dependencies: 200
-- Name: TABLE "1x2_oddsportal"; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE public."1x2_oddsportal" FROM postgres;
GRANT ALL ON TABLE public."1x2_oddsportal" TO postgres WITH GRANT OPTION;


--
-- TOC entry 3119 (class 0 OID 0)
-- Dependencies: 202
-- Name: TABLE "OddsPortalMatch"; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE public."OddsPortalMatch" FROM postgres;


--
-- TOC entry 3121 (class 0 OID 0)
-- Dependencies: 205
-- Name: TABLE "OddsPortalOverUnder"; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE public."OddsPortalOverUnder" FROM postgres;
GRANT ALL ON TABLE public."OddsPortalOverUnder" TO postgres WITH GRANT OPTION;


--
-- TOC entry 3122 (class 0 OID 0)
-- Dependencies: 206
-- Name: TABLE "OddsSafariMatch"; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE public."OddsSafariMatch" FROM postgres;
GRANT ALL ON TABLE public."OddsSafariMatch" TO postgres WITH GRANT OPTION;


--
-- TOC entry 3123 (class 0 OID 0)
-- Dependencies: 207
-- Name: TABLE "OddsSafariOverUnder"; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE public."OddsSafariOverUnder" FROM postgres;
GRANT ALL ON TABLE public."OddsSafariOverUnder" TO postgres WITH GRANT OPTION;


--
-- TOC entry 3124 (class 0 OID 0)
-- Dependencies: 209
-- Name: TABLE "OverUnderHistorical"; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE public."OverUnderHistorical" FROM postgres;
GRANT ALL ON TABLE public."OverUnderHistorical" TO postgres WITH GRANT OPTION;


--
-- TOC entry 3125 (class 0 OID 0)
-- Dependencies: 210
-- Name: TABLE "PortalSafariMatch"; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE public."PortalSafariMatch" FROM postgres;
GRANT ALL ON TABLE public."PortalSafariMatch" TO postgres WITH GRANT OPTION;


--
-- TOC entry 3126 (class 0 OID 0)
-- Dependencies: 211
-- Name: TABLE "PortalSafariBets"; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE public."PortalSafariBets" FROM postgres;
GRANT ALL ON TABLE public."PortalSafariBets" TO postgres WITH GRANT OPTION;


--
-- TOC entry 3127 (class 0 OID 0)
-- Dependencies: 213
-- Name: TABLE soccer_statistics; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE public.soccer_statistics FROM postgres;
GRANT ALL ON TABLE public.soccer_statistics TO postgres WITH GRANT OPTION;


--
-- TOC entry 1771 (class 826 OID 16531)
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: -; Owner: -
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres REVOKE ALL ON TABLES  FROM postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres GRANT ALL ON TABLES  TO postgres WITH GRANT OPTION;


-- Completed on 2023-05-08 11:33:58 EEST

--
-- PostgreSQL database dump complete
--


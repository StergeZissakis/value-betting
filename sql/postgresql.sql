--
-- PostgreSQL database dump
--

-- Dumped from database version 13.9 (Debian 13.9-0+deb11u1)
-- Dumped by pg_dump version 13.9 (Debian 13.9-0+deb11u1)

-- Started on 2023-04-24 02:15:31 EEST

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
-- TOC entry 3116 (class 0 OID 0)
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
-- TOC entry 3118 (class 0 OID 0)
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
-- TOC entry 212 (class 1259 OID 16474)
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
-- TOC entry 213 (class 1259 OID 16481)
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
-- Dependencies: 213
-- Name: soccer_statistics_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.soccer_statistics_id_seq OWNED BY public.soccer_statistics.id;


--
-- TOC entry 2916 (class 2604 OID 16483)
-- Name: 1x2_oddsportal id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."1x2_oddsportal" ALTER COLUMN id SET DEFAULT nextval('public."1x2_oddsportal_id_seq"'::regclass);


--
-- TOC entry 2919 (class 2604 OID 16484)
-- Name: OddsPortalMatch id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsPortalMatch" ALTER COLUMN id SET DEFAULT nextval('public."Match_id_seq"'::regclass);


--
-- TOC entry 2923 (class 2604 OID 16485)
-- Name: OddsSafariMatch id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsSafariMatch" ALTER COLUMN id SET DEFAULT nextval('public."Match_id_seq"'::regclass);


--
-- TOC entry 2924 (class 2604 OID 16486)
-- Name: OddsSafariMatch created; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsSafariMatch" ALTER COLUMN created SET DEFAULT CURRENT_TIMESTAMP;


--
-- TOC entry 2925 (class 2604 OID 16487)
-- Name: OddsSafariMatch updated; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsSafariMatch" ALTER COLUMN updated SET DEFAULT CURRENT_TIMESTAMP;


--
-- TOC entry 2926 (class 2604 OID 16488)
-- Name: OddsSafariOverUnder id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsSafariOverUnder" ALTER COLUMN id SET DEFAULT nextval('public."OverUnder_id_seq"'::regclass);


--
-- TOC entry 2927 (class 2604 OID 16489)
-- Name: OddsSafariOverUnder created; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsSafariOverUnder" ALTER COLUMN created SET DEFAULT CURRENT_TIMESTAMP;


--
-- TOC entry 2928 (class 2604 OID 16490)
-- Name: OddsSafariOverUnder updated; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsSafariOverUnder" ALTER COLUMN updated SET DEFAULT CURRENT_TIMESTAMP;


--
-- TOC entry 2932 (class 2604 OID 16491)
-- Name: soccer_statistics id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.soccer_statistics ALTER COLUMN id SET DEFAULT nextval('public.soccer_statistics_id_seq'::regclass);


--
-- TOC entry 3096 (class 0 OID 16407)
-- Dependencies: 200
-- Data for Name: 1x2_oddsportal; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."1x2_oddsportal" (id, date_time, home_team, guest_team, half, "1_odds", x_odds, "2_odds", created, updated) FROM stdin;
\.


--
-- TOC entry 3098 (class 0 OID 16417)
-- Dependencies: 202
-- Data for Name: OddsPortalMatch; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."OddsPortalMatch" (id, home_team, guest_team, date_time, created, updated) FROM stdin;
1569	PAOK	Panathinaikos	2023-04-23 20:00:00+01	2023-04-17 22:29:20.952707	2023-04-17 22:29:20.952707
1572	Olympiacos Piraeus	AEK Athens FC	2023-04-23 21:00:00+01	2023-04-17 22:29:44.143685	2023-04-17 22:29:44.143685
1657	Volos	Panathinaikos	2023-04-26 18:00:00+01	2023-04-22 00:08:42.188932	2023-04-22 00:08:42.188932
1660	Aris	Olympiacos Piraeus	2023-04-26 19:00:00+01	2023-04-22 00:09:17.880024	2023-04-22 00:09:17.880024
1663	AEK Athens FC	PAOK	2023-04-26 21:00:00+01	2023-04-22 00:09:52.337102	2023-04-22 00:09:52.337102
1666	Asteras Tripolis	Lamia	2023-04-29 19:15:00+01	2023-04-22 00:10:26.473317	2023-04-22 00:10:26.473317
1669	Atromitos	OFI Crete	2023-04-29 19:15:00+01	2023-04-22 00:10:50.984349	2023-04-22 00:10:50.984349
1672	Ionikos	Giannina	2023-04-29 19:15:00+01	2023-04-22 00:11:24.448938	2023-04-22 00:11:24.448938
1675	Panetolikos	Levadiakos	2023-04-29 19:15:00+01	2023-04-22 00:11:57.407481	2023-04-22 00:11:57.407481
\.


--
-- TOC entry 3101 (class 0 OID 16429)
-- Dependencies: 205
-- Data for Name: OddsPortalOverUnder; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."OddsPortalOverUnder" (id, goals, odds, match_id, half, payout, created, updated, type, bet_links) FROM stdin;
20068	7.5	41.00	1657	Full Time	97.6%	2023-04-23 22:21:07.817802	2023-04-23 22:21:07.817802	Over	{}
20069	7.5	1.00	1657	Full Time	97.6%	2023-04-23 22:21:07.821188	2023-04-23 22:21:07.821188	Under	{}
20090	4.5	23.00	1657	2nd Half	96.8%	2023-04-23 22:21:14.249606	2023-04-23 22:21:14.249606	Over	{}
20091	4.5	1.01	1657	2nd Half	96.8%	2023-04-23 22:21:14.252251	2023-04-23 22:21:14.252251	Under	{}
20096	2.25	1.90	1660	Full Time	96.2%	2023-04-23 22:21:30.595414	2023-04-23 22:21:30.595414	Over	{}
20097	2.25	1.95	1660	Full Time	96.2%	2023-04-23 22:21:30.598261	2023-04-23 22:21:30.598261	Under	{}
20132	2.25	1.82	1663	Full Time	95.7%	2023-04-23 22:21:53.154488	2023-04-23 22:21:53.154488	Over	{}
20133	2.25	2.02	1663	Full Time	95.7%	2023-04-23 22:21:53.158001	2023-04-23 22:21:53.158001	Under	{}
20168	2.0	2.05	1666	Full Time	95.8%	2023-04-23 22:22:15.503481	2023-04-23 22:22:15.503481	Over	{}
20169	2.0	1.80	1666	Full Time	95.8%	2023-04-23 22:22:15.505932	2023-04-23 22:22:15.505932	Under	{}
20180	0.75	1.93	1666	1st Half	95.2%	2023-04-23 22:22:19.112882	2023-04-23 22:22:19.112882	Over	{}
20181	0.75	1.88	1666	1st Half	95.2%	2023-04-23 22:22:19.115384	2023-04-23 22:22:19.115384	Under	{}
15496	0.5	1.12	1569	Full Time	96.6%	2023-04-17 22:29:23.243535	2023-04-17 22:29:23.243535	Over	{}
15497	0.5	7.00	1569	Full Time	96.6%	2023-04-17 22:29:23.246082	2023-04-17 22:29:23.246082	Under	{}
15498	1.5	1.53	1569	Full Time	94.9%	2023-04-17 22:29:23.248527	2023-04-17 22:29:23.248527	Over	{}
15499	1.5	2.50	1569	Full Time	94.9%	2023-04-17 22:29:23.250806	2023-04-17 22:29:23.250806	Under	{}
15500	2.0	2.00	1569	Full Time	96.1%	2023-04-17 22:29:23.253441	2023-04-17 22:29:23.253441	Over	{}
15501	2.0	1.85	1569	Full Time	96.1%	2023-04-17 22:29:23.25584	2023-04-17 22:29:23.25584	Under	{}
15502	2.5	2.70	1569	Full Time	96.4%	2023-04-17 22:29:23.258251	2023-04-17 22:29:23.258251	Over	{}
15503	2.5	1.50	1569	Full Time	96.4%	2023-04-17 22:29:23.260692	2023-04-17 22:29:23.260692	Under	{}
15504	3.5	5.75	1569	Full Time	95.8%	2023-04-17 22:29:23.263094	2023-04-17 22:29:23.263094	Over	{}
15505	3.5	1.15	1569	Full Time	95.8%	2023-04-17 22:29:23.265453	2023-04-17 22:29:23.265453	Under	{}
15506	4.5	13.00	1569	Full Time	96.3%	2023-04-17 22:29:23.268999	2023-04-17 22:29:23.268999	Over	{}
15507	4.5	1.04	1569	Full Time	96.3%	2023-04-17 22:29:23.271413	2023-04-17 22:29:23.271413	Under	{}
15509	5.5	1.01	1569	Full Time	97.2%	2023-04-17 22:29:23.27593	2023-04-17 22:29:23.27593	Under	{}
15510	6.5	46.00	1569	Full Time	97.9%	2023-04-17 22:29:23.277992	2023-04-17 22:29:23.277992	Over	{}
15511	6.5	1.00	1569	Full Time	97.9%	2023-04-17 22:29:23.280188	2023-04-17 22:29:23.280188	Under	{}
15512	0.5	1.57	1569	1st Half	94.6%	2023-04-17 22:29:24.940413	2023-04-17 22:29:24.940413	Over	{}
15513	0.5	2.38	1569	1st Half	94.6%	2023-04-17 22:29:26.722385	2023-04-17 22:29:26.722385	Under	{}
15514	0.75	1.88	1569	1st Half	95.2%	2023-04-17 22:29:26.725089	2023-04-17 22:29:26.725089	Over	{}
15515	0.75	1.93	1569	1st Half	95.2%	2023-04-17 22:29:26.72743	2023-04-17 22:29:26.72743	Under	{}
15516	1.5	3.90	1569	1st Half	96.9%	2023-04-17 22:29:26.729784	2023-04-17 22:29:26.729784	Over	{}
15517	1.5	1.29	1569	1st Half	96.9%	2023-04-17 22:29:26.732066	2023-04-17 22:29:26.732066	Under	{}
15518	2.5	13.00	1569	1st Half	96.3%	2023-04-17 22:29:26.734171	2023-04-17 22:29:26.734171	Over	{}
15519	2.5	1.04	1569	1st Half	96.3%	2023-04-17 22:29:26.736314	2023-04-17 22:29:26.736314	Under	{}
15520	3.5	31.00	1569	1st Half	97.8%	2023-04-17 22:29:26.738371	2023-04-17 22:29:26.738371	Over	{}
15521	3.5	1.01	1569	1st Half	97.8%	2023-04-17 22:29:26.74053	2023-04-17 22:29:26.74053	Under	{}
15522	4.5	81.00	1569	1st Half	98.8%	2023-04-17 22:29:26.742597	2023-04-17 22:29:26.742597	Over	{}
15523	4.5	1.00	1569	1st Half	98.8%	2023-04-17 22:29:26.744677	2023-04-17 22:29:26.744677	Under	{}
15524	0.5	1.40	1569	2nd Half	95.5%	2023-04-17 22:29:28.855662	2023-04-17 22:29:28.855662	Over	{}
15525	0.5	3.00	1569	2nd Half	95.5%	2023-04-17 22:29:30.063515	2023-04-17 22:29:30.063515	Under	{}
15526	1.5	2.85	1569	2nd Half	95.7%	2023-04-17 22:29:30.065908	2023-04-17 22:29:30.065908	Over	{}
15527	1.5	1.44	1569	2nd Half	95.7%	2023-04-17 22:29:30.068081	2023-04-17 22:29:30.068081	Under	{}
15528	2.5	7.00	1569	2nd Half	95.1%	2023-04-17 22:29:30.070294	2023-04-17 22:29:30.070294	Over	{}
15529	2.5	1.10	1569	2nd Half	95.1%	2023-04-17 22:29:30.072589	2023-04-17 22:29:30.072589	Under	{}
15530	3.5	21.00	1569	2nd Half	97.3%	2023-04-17 22:29:30.074905	2023-04-17 22:29:30.074905	Over	{}
15531	3.5	1.02	1569	2nd Half	97.3%	2023-04-17 22:29:30.077158	2023-04-17 22:29:30.077158	Under	{}
15532	0.5	1.07	1572	Full Time	96.2%	2023-04-17 22:29:46.465449	2023-04-17 22:29:46.465449	Over	{}
15533	0.5	9.50	1572	Full Time	96.2%	2023-04-17 22:29:46.467985	2023-04-17 22:29:46.467985	Under	{}
15534	1.5	1.33	1572	Full Time	94.8%	2023-04-17 22:29:46.470269	2023-04-17 22:29:46.470269	Over	{}
15535	1.5	3.30	1572	Full Time	94.8%	2023-04-17 22:29:46.472515	2023-04-17 22:29:46.472515	Under	{}
15544	5.5	17.00	1572	Full Time	96.2%	2023-04-17 22:29:46.493557	2023-04-17 22:29:46.493557	Over	{}
15545	5.5	1.02	1572	Full Time	96.2%	2023-04-17 22:29:46.495823	2023-04-17 22:29:46.495823	Under	{}
15546	6.5	34.00	1572	Full Time	97.1%	2023-04-17 22:29:46.498076	2023-04-17 22:29:46.498076	Over	{}
15547	6.5	1.00	1572	Full Time	97.1%	2023-04-17 22:29:46.500403	2023-04-17 22:29:46.500403	Under	{}
15548	0.5	1.44	1572	1st Half	95.1%	2023-04-17 22:29:48.740717	2023-04-17 22:29:48.740717	Over	{}
15550	1.0	2.02	1572	1st Half	94.3%	2023-04-17 22:29:50.494907	2023-04-17 22:29:50.494907	Over	{}
15551	1.0	1.77	1572	1st Half	94.3%	2023-04-17 22:29:50.497023	2023-04-17 22:29:50.497023	Under	{}
15552	1.5	3.25	1572	1st Half	95.9%	2023-04-17 22:29:50.499143	2023-04-17 22:29:50.499143	Over	{}
15553	1.5	1.36	1572	1st Half	95.9%	2023-04-17 22:29:50.501212	2023-04-17 22:29:50.501212	Under	{}
15554	2.5	9.00	1572	1st Half	95.6%	2023-04-17 22:29:50.503264	2023-04-17 22:29:50.503264	Over	{}
15555	2.5	1.07	1572	1st Half	95.6%	2023-04-17 22:29:50.505674	2023-04-17 22:29:50.505674	Under	{}
15556	3.5	26.00	1572	1st Half	98.1%	2023-04-17 22:29:50.507925	2023-04-17 22:29:50.507925	Over	{}
15557	3.5	1.02	1572	1st Half	98.1%	2023-04-17 22:29:50.510105	2023-04-17 22:29:50.510105	Under	{}
15558	4.5	56.00	1572	1st Half	98.2%	2023-04-17 22:29:50.512505	2023-04-17 22:29:50.512505	Over	{}
15559	4.5	1.00	1572	1st Half	98.2%	2023-04-17 22:29:50.514794	2023-04-17 22:29:50.514794	Under	{}
15560	0.5	1.29	1572	2nd Half	96.0%	2023-04-17 22:29:52.308941	2023-04-17 22:29:52.308941	Over	{}
15561	0.5	3.75	1572	2nd Half	96.0%	2023-04-17 22:29:53.51475	2023-04-17 22:29:53.51475	Under	{}
15562	1.5	2.23	1572	2nd Half	93.8%	2023-04-17 22:29:53.517079	2023-04-17 22:29:53.517079	Over	{}
15563	1.5	1.62	1572	2nd Half	93.8%	2023-04-17 22:29:53.519306	2023-04-17 22:29:53.519306	Under	{}
15564	2.5	5.00	1572	2nd Half	94.8%	2023-04-17 22:29:53.521562	2023-04-17 22:29:53.521562	Over	{}
15565	2.5	1.17	1572	2nd Half	94.8%	2023-04-17 22:29:53.523766	2023-04-17 22:29:53.523766	Under	{}
15566	3.5	13.00	1572	2nd Half	96.3%	2023-04-17 22:29:53.525971	2023-04-17 22:29:53.525971	Over	{}
15567	3.5	1.04	1572	2nd Half	96.3%	2023-04-17 22:29:53.52827	2023-04-17 22:29:53.52827	Under	{}
15537	2.25	2.02	1572	Full Time	95.7%	2023-04-17 22:29:46.477261	2023-04-17 22:29:46.477261	Under	{}
15538	2.5	2.05	1572	Full Time	94.4%	2023-04-17 22:29:46.479442	2023-04-17 22:29:46.479442	Over	{}
15541	3.5	1.29	1572	Full Time	96.0%	2023-04-17 22:29:46.486633	2023-04-17 22:29:46.486633	Under	{}
15542	4.5	8.00	1572	Full Time	96.7%	2023-04-17 22:29:46.48897	2023-04-17 22:29:46.48897	Over	{}
15539	2.5	1.75	1572	Full Time	94.4%	2023-04-17 22:29:46.481976	2023-04-17 22:29:46.481976	Under	{}
15540	3.5	3.75	1572	Full Time	96.0%	2023-04-17 22:29:46.484315	2023-04-17 22:29:46.484315	Over	{}
15543	4.5	1.10	1572	Full Time	96.7%	2023-04-17 22:29:46.491287	2023-04-17 22:29:46.491287	Under	{}
16094	0.75	1.10	1569	Full Time	91.1%	2023-04-22 00:07:36.95475	2023-04-22 00:07:36.95475	Over	{}
16095	0.75	5.30	1569	Full Time	91.1%	2023-04-22 00:07:36.956967	2023-04-22 00:07:36.956967	Under	{}
16096	1.0	1.14	1569	Full Time	91.6%	2023-04-22 00:07:36.959119	2023-04-22 00:07:36.959119	Over	{}
16097	1.0	4.65	1569	Full Time	91.6%	2023-04-22 00:07:36.961287	2023-04-22 00:07:36.961287	Under	{}
16098	1.25	1.36	1569	Full Time	95.0%	2023-04-22 00:07:36.963481	2023-04-22 00:07:36.963481	Over	{}
16099	1.25	3.15	1569	Full Time	95.0%	2023-04-22 00:07:36.965635	2023-04-22 00:07:36.965635	Under	{}
16102	1.75	1.72	1569	Full Time	95.8%	2023-04-22 00:07:36.972707	2023-04-22 00:07:36.972707	Over	{}
16103	1.75	2.16	1569	Full Time	95.8%	2023-04-22 00:07:36.975671	2023-04-22 00:07:36.975671	Under	{}
16106	2.25	2.36	1569	Full Time	95.7%	2023-04-22 00:07:36.983054	2023-04-22 00:07:36.983054	Over	{}
16107	2.25	1.61	1569	Full Time	95.7%	2023-04-22 00:07:36.985743	2023-04-22 00:07:36.985743	Under	{}
16110	2.75	3.25	1569	Full Time	94.9%	2023-04-22 00:07:36.993281	2023-04-22 00:07:36.993281	Over	{}
16111	2.75	1.34	1569	Full Time	94.9%	2023-04-22 00:07:36.995649	2023-04-22 00:07:36.995649	Under	{}
16112	3.0	4.55	1569	Full Time	93.1%	2023-04-22 00:07:36.997957	2023-04-22 00:07:36.997957	Over	{}
16113	3.0	1.17	1569	Full Time	93.1%	2023-04-22 00:07:37.00031	2023-04-22 00:07:37.00031	Under	{}
16114	3.25	4.84	1569	Full Time	91.6%	2023-04-22 00:07:37.002677	2023-04-22 00:07:37.002677	Over	{}
16115	3.25	1.13	1569	Full Time	91.6%	2023-04-22 00:07:37.005017	2023-04-22 00:07:37.005017	Under	{}
16118	3.75	6.65	1569	Full Time	91.4%	2023-04-22 00:07:37.012474	2023-04-22 00:07:37.012474	Over	{}
16119	3.75	1.06	1569	Full Time	91.4%	2023-04-22 00:07:37.014823	2023-04-22 00:07:37.014823	Under	{}
16120	4.0	9.90	1569	Full Time	91.6%	2023-04-22 00:07:37.01715	2023-04-22 00:07:37.01715	Over	{}
16121	4.0	1.01	1569	Full Time	91.6%	2023-04-22 00:07:37.019429	2023-04-22 00:07:37.019429	Under	{}
16132	1.0	2.64	1569	1st Half	94.8%	2023-04-22 00:07:43.254369	2023-04-22 00:07:43.254369	Over	{}
16133	1.0	1.48	1569	1st Half	94.8%	2023-04-22 00:07:43.256591	2023-04-22 00:07:43.256591	Under	{}
16134	1.25	3.40	1569	1st Half	95.1%	2023-04-22 00:07:43.258771	2023-04-22 00:07:43.258771	Over	{}
16135	1.25	1.32	1569	1st Half	95.1%	2023-04-22 00:07:43.260942	2023-04-22 00:07:43.260942	Under	{}
16138	1.75	5.30	1569	1st Half	93.8%	2023-04-22 00:07:43.267612	2023-04-22 00:07:43.267612	Over	{}
16139	1.75	1.14	1569	1st Half	93.8%	2023-04-22 00:07:43.269799	2023-04-22 00:07:43.269799	Under	{}
16140	2.0	9.50	1569	1st Half	93.7%	2023-04-22 00:07:43.272027	2023-04-22 00:07:43.272027	Over	{}
16141	2.0	1.04	1569	1st Half	93.7%	2023-04-22 00:07:43.274159	2023-04-22 00:07:43.274159	Under	{}
16142	2.25	10.00	1569	1st Half	93.4%	2023-04-22 00:07:43.276354	2023-04-22 00:07:43.276354	Over	{}
16143	2.25	1.03	1569	1st Half	93.4%	2023-04-22 00:07:43.278487	2023-04-22 00:07:43.278487	Under	{}
16146	3.0	14.00	1569	1st Half	94.2%	2023-04-22 00:07:43.285256	2023-04-22 00:07:43.285256	Over	{}
16147	3.0	1.01	1569	1st Half	94.2%	2023-04-22 00:07:43.28777	2023-04-22 00:07:43.28777	Under	{}
16154	0.75	1.55	1569	2nd Half	93.7%	2023-04-22 00:07:49.256694	2023-04-22 00:07:49.256694	Over	{}
16155	0.75	2.37	1569	2nd Half	93.7%	2023-04-22 00:07:49.259027	2023-04-22 00:07:49.259027	Under	{}
16156	1.0	1.87	1569	2nd Half	94.2%	2023-04-22 00:07:49.2614	2023-04-22 00:07:49.2614	Over	{}
16157	1.0	1.90	1569	2nd Half	94.2%	2023-04-22 00:07:49.263699	2023-04-22 00:07:49.263699	Under	{}
16158	1.25	2.34	1569	2nd Half	93.6%	2023-04-22 00:07:49.266023	2023-04-22 00:07:49.266023	Over	{}
16159	1.25	1.56	1569	2nd Half	93.6%	2023-04-22 00:07:49.268431	2023-04-22 00:07:49.268431	Under	{}
16162	1.75	3.64	1569	2nd Half	93.6%	2023-04-22 00:07:49.275625	2023-04-22 00:07:49.275625	Over	{}
16163	1.75	1.26	1569	2nd Half	93.6%	2023-04-22 00:07:49.27796	2023-04-22 00:07:49.27796	Under	{}
16164	2.0	5.90	1569	2nd Half	94.1%	2023-04-22 00:07:49.280323	2023-04-22 00:07:49.280323	Over	{}
16165	2.0	1.12	1569	2nd Half	94.1%	2023-04-22 00:07:49.282634	2023-04-22 00:07:49.282634	Under	{}
16166	2.25	6.50	1569	2nd Half	94.1%	2023-04-22 00:07:49.284988	2023-04-22 00:07:49.284988	Over	{}
16167	2.25	1.10	1569	2nd Half	94.1%	2023-04-22 00:07:49.287355	2023-04-22 00:07:49.287355	Under	{}
16170	3.0	12.00	1569	2nd Half	93.2%	2023-04-22 00:07:49.293757	2023-04-22 00:07:49.293757	Over	{}
16171	3.0	1.01	1569	2nd Half	93.2%	2023-04-22 00:07:49.296034	2023-04-22 00:07:49.296034	Under	{}
16176	0.75	1.04	1572	Full Time	92.9%	2023-04-22 00:08:13.437258	2023-04-22 00:08:13.437258	Over	{}
16177	0.75	8.70	1572	Full Time	92.9%	2023-04-22 00:08:13.439751	2023-04-22 00:08:13.439751	Under	{}
16178	1.0	1.05	1572	Full Time	91.5%	2023-04-22 00:08:13.442129	2023-04-22 00:08:13.442129	Over	{}
16179	1.0	7.10	1572	Full Time	91.5%	2023-04-22 00:08:13.445135	2023-04-22 00:08:13.445135	Under	{}
16180	1.25	1.20	1572	Full Time	93.1%	2023-04-22 00:08:13.447771	2023-04-22 00:08:13.447771	Over	{}
16181	1.25	4.16	1572	Full Time	93.1%	2023-04-22 00:08:13.450367	2023-04-22 00:08:13.450367	Under	{}
16184	1.75	1.44	1572	Full Time	95.3%	2023-04-22 00:08:13.458147	2023-04-22 00:08:13.458147	Over	{}
16185	1.75	2.82	1572	Full Time	95.3%	2023-04-22 00:08:13.460739	2023-04-22 00:08:13.460739	Under	{}
16186	2.0	1.57	1572	Full Time	95.4%	2023-04-22 00:08:13.46326	2023-04-22 00:08:13.46326	Over	{}
16187	2.0	2.43	1572	Full Time	95.4%	2023-04-22 00:08:13.465785	2023-04-22 00:08:13.465785	Under	{}
16192	2.75	2.41	1572	Full Time	95.4%	2023-04-22 00:08:13.478078	2023-04-22 00:08:13.478078	Over	{}
16193	2.75	1.58	1572	Full Time	95.4%	2023-04-22 00:08:13.480895	2023-04-22 00:08:13.480895	Under	{}
16194	3.0	2.95	1572	Full Time	94.9%	2023-04-22 00:08:13.487115	2023-04-22 00:08:13.487115	Over	{}
16195	3.0	1.40	1572	Full Time	94.9%	2023-04-22 00:08:13.494202	2023-04-22 00:08:13.494202	Under	{}
16196	3.25	3.30	1572	Full Time	94.8%	2023-04-22 00:08:13.496593	2023-04-22 00:08:13.496593	Over	{}
16197	3.25	1.33	1572	Full Time	94.8%	2023-04-22 00:08:13.498852	2023-04-22 00:08:13.498852	Under	{}
16200	3.75	4.46	1572	Full Time	93.3%	2023-04-22 00:08:13.505638	2023-04-22 00:08:13.505638	Over	{}
16201	3.75	1.18	1572	Full Time	93.3%	2023-04-22 00:08:13.508117	2023-04-22 00:08:13.508117	Under	{}
16202	4.0	6.05	1572	Full Time	91.6%	2023-04-22 00:08:13.510288	2023-04-22 00:08:13.510288	Over	{}
16203	4.0	1.08	1572	Full Time	91.6%	2023-04-22 00:08:13.51255	2023-04-22 00:08:13.51255	Under	{}
16204	4.25	6.90	1572	Full Time	93.4%	2023-04-22 00:08:13.51474	2023-04-22 00:08:13.51474	Over	{}
16205	4.25	1.08	1572	Full Time	93.4%	2023-04-22 00:08:13.516911	2023-04-22 00:08:13.516911	Under	{}
16208	5.0	12.50	1572	Full Time	93.4%	2023-04-22 00:08:13.523512	2023-04-22 00:08:13.523512	Over	{}
16209	5.0	1.01	1572	Full Time	93.4%	2023-04-22 00:08:13.526018	2023-04-22 00:08:13.526018	Under	{}
16216	0.75	1.63	1572	1st Half	95.6%	2023-04-22 00:08:19.892259	2023-04-22 00:08:19.892259	Over	{}
16217	0.75	2.31	1572	1st Half	95.6%	2023-04-22 00:08:19.894667	2023-04-22 00:08:19.894667	Under	{}
16220	1.25	2.63	1572	1st Half	95.5%	2023-04-22 00:08:19.901614	2023-04-22 00:08:19.901614	Over	{}
16221	1.25	1.50	1572	1st Half	95.5%	2023-04-22 00:08:19.90463	2023-04-22 00:08:19.90463	Under	{}
16224	1.75	3.90	1572	1st Half	93.5%	2023-04-22 00:08:19.912117	2023-04-22 00:08:19.912117	Over	{}
16225	1.75	1.23	1572	1st Half	93.5%	2023-04-22 00:08:19.914813	2023-04-22 00:08:19.914813	Under	{}
16226	2.0	6.45	1572	1st Half	94.0%	2023-04-22 00:08:19.917278	2023-04-22 00:08:19.917278	Over	{}
16227	2.0	1.10	1572	1st Half	94.0%	2023-04-22 00:08:19.919666	2023-04-22 00:08:19.919666	Under	{}
16228	2.25	7.00	1572	1st Half	93.6%	2023-04-22 00:08:19.9221	2023-04-22 00:08:19.9221	Over	{}
16229	2.25	1.08	1572	1st Half	93.6%	2023-04-22 00:08:19.924625	2023-04-22 00:08:19.924625	Under	{}
16232	3.0	14.00	1572	1st Half	94.2%	2023-04-22 00:08:19.931524	2023-04-22 00:08:19.931524	Over	{}
16233	3.0	1.01	1572	1st Half	94.2%	2023-04-22 00:08:19.9338	2023-04-22 00:08:19.9338	Under	{}
15536	2.25	1.82	1572	Full Time	95.7%	2023-04-17 22:29:46.47468	2023-04-17 22:29:46.47468	Over	{}
15549	0.5	2.80	1572	1st Half	95.1%	2023-04-17 22:29:50.492695	2023-04-17 22:29:50.492695	Under	{}
16240	0.75	1.36	1572	2nd Half	93.6%	2023-04-22 00:08:25.787022	2023-04-22 00:08:25.787022	Over	{}
16241	0.75	3.00	1572	2nd Half	93.6%	2023-04-22 00:08:25.790193	2023-04-22 00:08:25.790193	Under	{}
16242	1.0	1.52	1572	2nd Half	94.5%	2023-04-22 00:08:25.79256	2023-04-22 00:08:25.79256	Over	{}
16243	1.0	2.50	1572	2nd Half	94.5%	2023-04-22 00:08:25.794857	2023-04-22 00:08:25.794857	Under	{}
16244	1.25	1.89	1572	2nd Half	93.7%	2023-04-22 00:08:25.797082	2023-04-22 00:08:25.797082	Over	{}
16245	1.25	1.86	1572	2nd Half	93.7%	2023-04-22 00:08:25.799293	2023-04-22 00:08:25.799293	Under	{}
16248	1.75	2.75	1572	2nd Half	93.6%	2023-04-22 00:08:25.806212	2023-04-22 00:08:25.806212	Over	{}
16249	1.75	1.42	1572	2nd Half	93.6%	2023-04-22 00:08:25.808564	2023-04-22 00:08:25.808564	Under	{}
16250	2.0	3.92	1572	2nd Half	94.2%	2023-04-22 00:08:25.811119	2023-04-22 00:08:25.811119	Over	{}
16251	2.0	1.24	1572	2nd Half	94.2%	2023-04-22 00:08:25.813524	2023-04-22 00:08:25.813524	Under	{}
16252	2.25	4.50	1572	2nd Half	93.5%	2023-04-22 00:08:25.815919	2023-04-22 00:08:25.815919	Over	{}
16253	2.25	1.18	1572	2nd Half	93.5%	2023-04-22 00:08:25.818324	2023-04-22 00:08:25.818324	Under	{}
16256	3.0	9.20	1572	2nd Half	93.4%	2023-04-22 00:08:25.825525	2023-04-22 00:08:25.825525	Over	{}
16257	3.0	1.04	1572	2nd Half	93.4%	2023-04-22 00:08:25.827947	2023-04-22 00:08:25.827947	Under	{}
16261	0.5	12.00	1657	Full Time	96.6%	2023-04-22 00:08:50.0569	2023-04-22 00:08:50.0569	Under	{}
16262	1.0	1.01	1657	Full Time	91.6%	2023-04-22 00:08:50.059	2023-04-22 00:08:50.059	Over	{}
16263	1.0	9.90	1657	Full Time	91.6%	2023-04-22 00:08:50.061255	2023-04-22 00:08:50.061255	Under	{}
16264	1.25	1.11	1657	Full Time	93.0%	2023-04-22 00:08:50.063446	2023-04-22 00:08:50.063446	Over	{}
16265	1.25	5.75	1657	Full Time	93.0%	2023-04-22 00:08:50.066011	2023-04-22 00:08:50.066011	Under	{}
16268	1.75	1.25	1657	Full Time	93.0%	2023-04-22 00:08:50.07309	2023-04-22 00:08:50.07309	Over	{}
16269	1.75	3.64	1657	Full Time	93.0%	2023-04-22 00:08:50.075392	2023-04-22 00:08:50.075392	Under	{}
16270	2.0	1.31	1657	Full Time	92.9%	2023-04-22 00:08:50.077709	2023-04-22 00:08:50.077709	Over	{}
16271	2.0	3.20	1657	Full Time	92.9%	2023-04-22 00:08:50.080035	2023-04-22 00:08:50.080035	Under	{}
16272	2.25	1.49	1657	Full Time	92.9%	2023-04-22 00:08:50.082317	2023-04-22 00:08:50.082317	Over	{}
16273	2.25	2.47	1657	Full Time	92.9%	2023-04-22 00:08:50.08468	2023-04-22 00:08:50.08468	Under	{}
16278	3.0	2.11	1657	Full Time	92.9%	2023-04-22 00:08:50.096218	2023-04-22 00:08:50.096218	Over	{}
16279	3.0	1.66	1657	Full Time	92.9%	2023-04-22 00:08:50.098481	2023-04-22 00:08:50.098481	Under	{}
16280	3.25	2.40	1657	Full Time	93.1%	2023-04-22 00:08:50.100847	2023-04-22 00:08:50.100847	Over	{}
16281	3.25	1.52	1657	Full Time	93.1%	2023-04-22 00:08:50.103157	2023-04-22 00:08:50.103157	Under	{}
16284	3.75	3.13	1657	Full Time	92.8%	2023-04-22 00:08:50.109482	2023-04-22 00:08:50.109482	Over	{}
16285	3.75	1.32	1657	Full Time	92.8%	2023-04-22 00:08:50.111657	2023-04-22 00:08:50.111657	Under	{}
16286	4.0	4.05	1657	Full Time	91.4%	2023-04-22 00:08:50.113811	2023-04-22 00:08:50.113811	Over	{}
16287	4.0	1.18	1657	Full Time	91.4%	2023-04-22 00:08:50.115991	2023-04-22 00:08:50.115991	Under	{}
16288	4.25	4.46	1657	Full Time	92.7%	2023-04-22 00:08:50.11813	2023-04-22 00:08:50.11813	Over	{}
16289	4.25	1.17	1657	Full Time	92.7%	2023-04-22 00:08:50.120615	2023-04-22 00:08:50.120615	Under	{}
16292	4.75	6.20	1657	Full Time	92.7%	2023-04-22 00:08:50.127268	2023-04-22 00:08:50.127268	Over	{}
16293	4.75	1.09	1657	Full Time	92.7%	2023-04-22 00:08:50.129476	2023-04-22 00:08:50.129476	Under	{}
16294	5.0	8.00	1657	Full Time	91.3%	2023-04-22 00:08:50.131663	2023-04-22 00:08:50.131663	Over	{}
16295	5.0	1.03	1657	Full Time	91.3%	2023-04-22 00:08:50.133827	2023-04-22 00:08:50.133827	Under	{}
16266	1.5	1.25	1657	Full Time	97.0%	2023-04-22 00:08:50.068391	2023-04-22 00:08:50.068391	Over	{}
16302	0.75	1.43	1657	1st Half	93.6%	2023-04-22 00:08:55.830086	2023-04-22 00:08:55.830086	Over	{}
16303	0.75	2.71	1657	1st Half	93.6%	2023-04-22 00:08:55.83239	2023-04-22 00:08:55.83239	Under	{}
16304	1.0	1.66	1657	1st Half	94.1%	2023-04-22 00:08:55.834605	2023-04-22 00:08:55.834605	Over	{}
16305	1.0	2.17	1657	1st Half	94.1%	2023-04-22 00:08:55.836854	2023-04-22 00:08:55.836854	Under	{}
16310	1.75	3.14	1657	1st Half	93.9%	2023-04-22 00:08:55.847918	2023-04-22 00:08:55.847918	Over	{}
16311	1.75	1.34	1657	1st Half	93.9%	2023-04-22 00:08:55.850153	2023-04-22 00:08:55.850153	Under	{}
16312	2.0	4.70	1657	1st Half	93.7%	2023-04-22 00:08:55.853307	2023-04-22 00:08:55.853307	Over	{}
16313	2.0	1.17	1657	1st Half	93.7%	2023-04-22 00:08:55.855688	2023-04-22 00:08:55.855688	Under	{}
16314	2.25	5.35	1657	1st Half	94.0%	2023-04-22 00:08:55.858043	2023-04-22 00:08:55.858043	Over	{}
16315	2.25	1.14	1657	1st Half	94.0%	2023-04-22 00:08:55.860456	2023-04-22 00:08:55.860456	Under	{}
16290	4.5	5.25	1657	Full Time	95.7%	2023-04-22 00:08:50.122882	2023-04-22 00:08:50.122882	Over	{}
16291	4.5	1.17	1657	Full Time	95.7%	2023-04-22 00:08:50.12511	2023-04-22 00:08:50.12511	Under	{}
16296	5.5	11.00	1657	Full Time	95.9%	2023-04-22 00:08:50.136037	2023-04-22 00:08:50.136037	Over	{}
16297	5.5	1.05	1657	Full Time	95.9%	2023-04-22 00:08:50.138512	2023-04-22 00:08:50.138512	Under	{}
16298	6.5	21.00	1657	Full Time	97.3%	2023-04-22 00:08:50.140869	2023-04-22 00:08:50.140869	Over	{}
16300	0.5	1.33	1657	1st Half	95.6%	2023-04-22 00:08:51.875045	2023-04-22 00:08:51.875045	Over	{}
16301	0.5	3.40	1657	1st Half	95.6%	2023-04-22 00:08:55.827729	2023-04-22 00:08:55.827729	Under	{}
16306	1.25	2.08	1657	1st Half	94.4%	2023-04-22 00:08:55.839055	2023-04-22 00:08:55.839055	Over	{}
16309	1.5	1.53	1657	1st Half	94.9%	2023-04-22 00:08:55.845692	2023-04-22 00:08:55.845692	Under	{}
16267	1.5	4.33	1657	Full Time	97.0%	2023-04-22 00:08:50.070765	2023-04-22 00:08:50.070765	Under	{}
16274	2.5	1.80	1657	Full Time	96.9%	2023-04-22 00:08:50.086967	2023-04-22 00:08:50.086967	Over	{}
16275	2.5	2.10	1657	Full Time	96.9%	2023-04-22 00:08:50.089294	2023-04-22 00:08:50.089294	Under	{}
16276	2.75	1.90	1657	Full Time	96.2%	2023-04-22 00:08:50.091577	2023-04-22 00:08:50.091577	Over	{}
16277	2.75	1.95	1657	Full Time	96.2%	2023-04-22 00:08:50.093912	2023-04-22 00:08:50.093912	Under	{}
16282	3.5	2.90	1657	Full Time	96.2%	2023-04-22 00:08:50.105186	2023-04-22 00:08:50.105186	Over	{}
16283	3.5	1.44	1657	Full Time	96.2%	2023-04-22 00:08:50.107329	2023-04-22 00:08:50.107329	Under	{}
16307	1.25	1.73	1657	1st Half	94.4%	2023-04-22 00:08:55.841263	2023-04-22 00:08:55.841263	Under	{}
16308	1.5	2.50	1657	1st Half	94.9%	2023-04-22 00:08:55.843494	2023-04-22 00:08:55.843494	Over	{}
16318	3.5	17.00	1657	1st Half	96.2%	2023-04-22 00:08:55.867762	2023-04-22 00:08:55.867762	Over	{}
16319	3.5	1.02	1657	1st Half	96.2%	2023-04-22 00:08:55.870168	2023-04-22 00:08:55.870168	Under	{}
16324	0.75	1.24	1657	2nd Half	93.6%	2023-04-22 00:09:01.663539	2023-04-22 00:09:01.663539	Over	{}
16325	0.75	3.82	1657	2nd Half	93.6%	2023-04-22 00:09:01.665673	2023-04-22 00:09:01.665673	Under	{}
16326	1.0	1.33	1657	2nd Half	93.6%	2023-04-22 00:09:01.667926	2023-04-22 00:09:01.667926	Over	{}
16327	1.0	3.16	1657	2nd Half	93.6%	2023-04-22 00:09:01.670421	2023-04-22 00:09:01.670421	Under	{}
16328	1.25	1.63	1657	2nd Half	93.6%	2023-04-22 00:09:01.672876	2023-04-22 00:09:01.672876	Over	{}
16329	1.25	2.20	1657	2nd Half	93.6%	2023-04-22 00:09:01.675214	2023-04-22 00:09:01.675214	Under	{}
16332	1.75	2.24	1657	2nd Half	93.7%	2023-04-22 00:09:01.682239	2023-04-22 00:09:01.682239	Over	{}
16333	1.75	1.61	1657	2nd Half	93.7%	2023-04-22 00:09:01.684604	2023-04-22 00:09:01.684604	Under	{}
16334	2.0	2.91	1657	2nd Half	93.6%	2023-04-22 00:09:01.686926	2023-04-22 00:09:01.686926	Over	{}
16335	2.0	1.38	1657	2nd Half	93.6%	2023-04-22 00:09:01.689246	2023-04-22 00:09:01.689246	Under	{}
16336	2.25	3.34	1657	2nd Half	93.6%	2023-04-22 00:09:01.692036	2023-04-22 00:09:01.692036	Over	{}
16337	2.25	1.30	1657	2nd Half	93.6%	2023-04-22 00:09:01.712461	2023-04-22 00:09:01.712461	Under	{}
16320	4.5	41.00	1657	1st Half	98.6%	2023-04-22 00:08:55.872528	2023-04-22 00:08:55.872528	Over	{}
16344	1.0	1.06	1660	Full Time	91.5%	2023-04-22 00:09:25.152478	2023-04-22 00:09:25.152478	Over	{}
16345	1.0	6.70	1660	Full Time	91.5%	2023-04-22 00:09:25.154993	2023-04-22 00:09:25.154993	Under	{}
16348	2.0	1.58	1660	Full Time	93.0%	2023-04-22 00:09:25.162007	2023-04-22 00:09:25.162007	Over	{}
16349	2.0	2.26	1660	Full Time	93.0%	2023-04-22 00:09:25.164288	2023-04-22 00:09:25.164288	Under	{}
16352	3.0	3.04	1660	Full Time	93.0%	2023-04-22 00:09:25.170896	2023-04-22 00:09:25.170896	Over	{}
16353	3.0	1.34	1660	Full Time	93.0%	2023-04-22 00:09:25.173394	2023-04-22 00:09:25.173394	Under	{}
16356	4.0	6.45	1660	Full Time	91.8%	2023-04-22 00:09:25.180883	2023-04-22 00:09:25.180883	Over	{}
16357	4.0	1.07	1660	Full Time	91.8%	2023-04-22 00:09:25.183291	2023-04-22 00:09:25.183291	Under	{}
16370	2.0	6.80	1660	1st Half	93.9%	2023-04-22 00:09:30.981606	2023-04-22 00:09:30.981606	Over	{}
16371	2.0	1.09	1660	1st Half	93.9%	2023-04-22 00:09:30.984184	2023-04-22 00:09:30.984184	Under	{}
16380	1.0	1.55	1660	2nd Half	93.9%	2023-04-22 00:09:36.82546	2023-04-22 00:09:36.82546	Over	{}
16381	1.0	2.38	1660	2nd Half	93.9%	2023-04-22 00:09:36.827808	2023-04-22 00:09:36.827808	Under	{}
16384	2.0	4.15	1660	2nd Half	93.7%	2023-04-22 00:09:36.834876	2023-04-22 00:09:36.834876	Over	{}
16385	2.0	1.21	1660	2nd Half	93.7%	2023-04-22 00:09:36.837163	2023-04-22 00:09:36.837163	Under	{}
16330	1.5	2.05	1657	2nd Half	96.7%	2023-04-22 00:09:01.677585	2023-04-22 00:09:01.677585	Over	{}
16331	1.5	1.83	1657	2nd Half	96.7%	2023-04-22 00:09:01.679946	2023-04-22 00:09:01.679946	Under	{}
16338	2.5	4.40	1657	2nd Half	97.3%	2023-04-22 00:09:01.796703	2023-04-22 00:09:01.796703	Over	{}
16339	2.5	1.25	1657	2nd Half	97.3%	2023-04-22 00:09:01.799195	2023-04-22 00:09:01.799195	Under	{}
16340	3.5	10.50	1657	2nd Half	96.3%	2023-04-22 00:09:01.801349	2023-04-22 00:09:01.801349	Over	{}
16342	0.5	1.07	1660	Full Time	95.0%	2023-04-22 00:09:25.146878	2023-04-22 00:09:25.146878	Over	{}
16343	0.5	8.50	1660	Full Time	95.0%	2023-04-22 00:09:25.150286	2023-04-22 00:09:25.150286	Under	{}
16346	1.5	1.37	1660	Full Time	94.1%	2023-04-22 00:09:25.157328	2023-04-22 00:09:25.157328	Over	{}
16347	1.5	3.00	1660	Full Time	94.1%	2023-04-22 00:09:25.159886	2023-04-22 00:09:25.159886	Under	{}
16350	2.5	2.10	1660	Full Time	94.9%	2023-04-22 00:09:25.166437	2023-04-22 00:09:25.166437	Over	{}
16351	2.5	1.73	1660	Full Time	94.9%	2023-04-22 00:09:25.168676	2023-04-22 00:09:25.168676	Under	{}
16354	3.5	3.75	1660	Full Time	93.8%	2023-04-22 00:09:25.175893	2023-04-22 00:09:25.175893	Over	{}
16355	3.5	1.25	1660	Full Time	93.8%	2023-04-22 00:09:25.178439	2023-04-22 00:09:25.178439	Under	{}
16358	4.5	8.00	1660	Full Time	95.2%	2023-04-22 00:09:25.185728	2023-04-22 00:09:25.185728	Over	{}
16359	4.5	1.08	1660	Full Time	95.2%	2023-04-22 00:09:25.187823	2023-04-22 00:09:25.187823	Under	{}
16360	5.5	19.00	1660	Full Time	96.8%	2023-04-22 00:09:25.19005	2023-04-22 00:09:25.19005	Over	{}
16361	5.5	1.02	1660	Full Time	96.8%	2023-04-22 00:09:25.19228	2023-04-22 00:09:25.19228	Under	{}
16362	6.5	31.00	1660	Full Time	96.9%	2023-04-22 00:09:25.194435	2023-04-22 00:09:25.194435	Over	{}
16363	6.5	1.00	1660	Full Time	96.9%	2023-04-22 00:09:25.196643	2023-04-22 00:09:25.196643	Under	{}
16364	0.5	1.44	1660	1st Half	94.5%	2023-04-22 00:09:27.009981	2023-04-22 00:09:27.009981	Over	{}
16365	0.5	2.75	1660	1st Half	94.5%	2023-04-22 00:09:30.970055	2023-04-22 00:09:30.970055	Under	{}
16366	1.0	2.08	1660	1st Half	94.4%	2023-04-22 00:09:30.972706	2023-04-22 00:09:30.972706	Over	{}
16369	1.5	1.40	1660	1st Half	97.8%	2023-04-22 00:09:30.979442	2023-04-22 00:09:30.979442	Under	{}
16372	2.5	9.00	1660	1st Half	96.4%	2023-04-22 00:09:30.986491	2023-04-22 00:09:30.986491	Over	{}
16373	2.5	1.08	1660	1st Half	96.4%	2023-04-22 00:09:30.988889	2023-04-22 00:09:30.988889	Under	{}
16374	3.5	26.00	1660	1st Half	98.1%	2023-04-22 00:09:30.991173	2023-04-22 00:09:30.991173	Over	{}
16375	3.5	1.02	1660	1st Half	98.1%	2023-04-22 00:09:30.993505	2023-04-22 00:09:30.993505	Under	{}
16376	4.5	56.00	1660	1st Half	98.2%	2023-04-22 00:09:30.995795	2023-04-22 00:09:30.995795	Over	{}
16377	4.5	1.00	1660	1st Half	98.2%	2023-04-22 00:09:30.998094	2023-04-22 00:09:30.998094	Under	{}
16378	0.5	1.33	1660	2nd Half	96.4%	2023-04-22 00:09:32.848164	2023-04-22 00:09:32.848164	Over	{}
16379	0.5	3.50	1660	2nd Half	96.4%	2023-04-22 00:09:36.823032	2023-04-22 00:09:36.823032	Under	{}
16382	1.5	2.30	1660	2nd Half	93.3%	2023-04-22 00:09:36.830178	2023-04-22 00:09:36.830178	Over	{}
16383	1.5	1.57	1660	2nd Half	93.3%	2023-04-22 00:09:36.832516	2023-04-22 00:09:36.832516	Under	{}
16321	4.5	1.01	1657	1st Half	98.6%	2023-04-22 00:08:55.874923	2023-04-22 00:08:55.874923	Under	{}
16322	0.5	1.25	1657	2nd Half	97.8%	2023-04-22 00:08:57.703178	2023-04-22 00:08:57.703178	Over	{}
16323	0.5	4.50	1657	2nd Half	97.8%	2023-04-22 00:09:01.660921	2023-04-22 00:09:01.660921	Under	{}
16367	1.0	1.73	1660	1st Half	94.4%	2023-04-22 00:09:30.974879	2023-04-22 00:09:30.974879	Under	{}
16368	1.5	3.25	1660	1st Half	97.8%	2023-04-22 00:09:30.97721	2023-04-22 00:09:30.97721	Over	{}
16387	2.5	1.14	1660	2nd Half	94.4%	2023-04-22 00:09:36.842178	2023-04-22 00:09:36.842178	Under	{}
16392	1.0	1.07	1663	Full Time	91.5%	2023-04-22 00:09:59.984809	2023-04-22 00:09:59.984809	Over	{}
16393	1.0	6.30	1663	Full Time	91.5%	2023-04-22 00:09:59.986986	2023-04-22 00:09:59.986986	Under	{}
16396	2.0	1.64	1663	Full Time	93.0%	2023-04-22 00:09:59.993498	2023-04-22 00:09:59.993498	Over	{}
16397	2.0	2.15	1663	Full Time	93.0%	2023-04-22 00:09:59.99567	2023-04-22 00:09:59.99567	Under	{}
16400	3.0	3.25	1663	Full Time	92.9%	2023-04-22 00:10:00.002197	2023-04-22 00:10:00.002197	Over	{}
16401	3.0	1.30	1663	Full Time	92.9%	2023-04-22 00:10:00.004397	2023-04-22 00:10:00.004397	Under	{}
16404	4.0	6.90	1663	Full Time	91.1%	2023-04-22 00:10:00.011644	2023-04-22 00:10:00.011644	Over	{}
16405	4.0	1.05	1663	Full Time	91.1%	2023-04-22 00:10:00.013905	2023-04-22 00:10:00.013905	Under	{}
16388	3.5	15.00	1660	2nd Half	96.4%	2023-04-22 00:09:36.844247	2023-04-22 00:09:36.844247	Over	{}
16418	2.0	7.20	1663	1st Half	93.9%	2023-04-22 00:10:05.710508	2023-04-22 00:10:05.710508	Over	{}
16419	2.0	1.08	1663	1st Half	93.9%	2023-04-22 00:10:05.712758	2023-04-22 00:10:05.712758	Under	{}
16428	1.0	1.60	1663	2nd Half	93.7%	2023-04-22 00:10:11.248862	2023-04-22 00:10:11.248862	Over	{}
16429	1.0	2.26	1663	2nd Half	93.7%	2023-04-22 00:10:11.251375	2023-04-22 00:10:11.251375	Under	{}
16432	2.0	4.45	1663	2nd Half	93.9%	2023-04-22 00:10:11.258694	2023-04-22 00:10:11.258694	Over	{}
16433	2.0	1.19	1663	2nd Half	93.9%	2023-04-22 00:10:11.26105	2023-04-22 00:10:11.26105	Under	{}
16389	3.5	1.03	1660	2nd Half	96.4%	2023-04-22 00:09:36.846439	2023-04-22 00:09:36.846439	Under	{}
16398	2.5	2.20	1663	Full Time	97.5%	2023-04-22 00:09:59.997846	2023-04-22 00:09:59.997846	Over	{}
16399	2.5	1.75	1663	Full Time	97.5%	2023-04-22 00:10:00.000057	2023-04-22 00:10:00.000057	Under	{}
16402	3.5	4.00	1663	Full Time	95.2%	2023-04-22 00:10:00.006975	2023-04-22 00:10:00.006975	Over	{}
16403	3.5	1.25	1663	Full Time	95.2%	2023-04-22 00:10:00.009335	2023-04-22 00:10:00.009335	Under	{}
16406	4.5	8.00	1663	Full Time	95.2%	2023-04-22 00:10:00.016277	2023-04-22 00:10:00.016277	Over	{}
16408	5.5	17.00	1663	Full Time	96.2%	2023-04-22 00:10:00.0209	2023-04-22 00:10:00.0209	Over	{}
16409	5.5	1.02	1663	Full Time	96.2%	2023-04-22 00:10:00.023153	2023-04-22 00:10:00.023153	Under	{}
16410	6.5	34.00	1663	Full Time	97.1%	2023-04-22 00:10:00.025485	2023-04-22 00:10:00.025485	Over	{}
16411	6.5	1.00	1663	Full Time	97.1%	2023-04-22 00:10:00.027773	2023-04-22 00:10:00.027773	Under	{}
16412	0.5	1.44	1663	1st Half	93.3%	2023-04-22 00:10:01.716888	2023-04-22 00:10:01.716888	Over	{}
16413	0.5	2.65	1663	1st Half	93.3%	2023-04-22 00:10:05.698869	2023-04-22 00:10:05.698869	Under	{}
16414	1.0	2.02	1663	1st Half	94.3%	2023-04-22 00:10:05.701261	2023-04-22 00:10:05.701261	Over	{}
16417	1.5	1.36	1663	1st Half	93.6%	2023-04-22 00:10:05.708165	2023-04-22 00:10:05.708165	Under	{}
16420	2.5	9.00	1663	1st Half	95.6%	2023-04-22 00:10:05.714963	2023-04-22 00:10:05.714963	Over	{}
16421	2.5	1.07	1663	1st Half	95.6%	2023-04-22 00:10:05.717163	2023-04-22 00:10:05.717163	Under	{}
16422	3.5	23.00	1663	1st Half	97.7%	2023-04-22 00:10:05.719288	2023-04-22 00:10:05.719288	Over	{}
16423	3.5	1.02	1663	1st Half	97.7%	2023-04-22 00:10:05.721461	2023-04-22 00:10:05.721461	Under	{}
16424	4.5	56.00	1663	1st Half	98.2%	2023-04-22 00:10:05.723634	2023-04-22 00:10:05.723634	Over	{}
16425	4.5	1.00	1663	1st Half	98.2%	2023-04-22 00:10:05.725774	2023-04-22 00:10:05.725774	Under	{}
16426	0.5	1.33	1663	2nd Half	98.2%	2023-04-22 00:10:07.558185	2023-04-22 00:10:07.558185	Over	{}
16427	0.5	3.75	1663	2nd Half	98.2%	2023-04-22 00:10:11.246239	2023-04-22 00:10:11.246239	Under	{}
16430	1.5	2.38	1663	2nd Half	96.4%	2023-04-22 00:10:11.253846	2023-04-22 00:10:11.253846	Over	{}
16431	1.5	1.62	1663	2nd Half	96.4%	2023-04-22 00:10:11.256354	2023-04-22 00:10:11.256354	Under	{}
16434	2.5	5.50	1663	2nd Half	96.5%	2023-04-22 00:10:11.264268	2023-04-22 00:10:11.264268	Over	{}
16435	2.5	1.17	1663	2nd Half	96.5%	2023-04-22 00:10:11.266491	2023-04-22 00:10:11.266491	Under	{}
16436	3.5	13.00	1663	2nd Half	96.3%	2023-04-22 00:10:11.26851	2023-04-22 00:10:11.26851	Over	{}
16437	3.5	1.04	1663	2nd Half	96.3%	2023-04-22 00:10:11.270715	2023-04-22 00:10:11.270715	Under	{}
16438	0.5	1.13	1666	Full Time	95.1%	2023-04-22 00:10:28.813617	2023-04-22 00:10:28.813617	Over	{}
16439	0.5	6.00	1666	Full Time	95.1%	2023-04-22 00:10:28.816373	2023-04-22 00:10:28.816373	Under	{}
16440	1.5	1.57	1666	Full Time	94.6%	2023-04-22 00:10:28.819406	2023-04-22 00:10:28.819406	Over	{}
16441	1.5	2.38	1666	Full Time	94.6%	2023-04-22 00:10:28.825749	2023-04-22 00:10:28.825749	Under	{}
16442	2.5	2.75	1666	Full Time	94.9%	2023-04-22 00:10:28.829151	2023-04-22 00:10:28.829151	Over	{}
16443	2.5	1.45	1666	Full Time	94.9%	2023-04-22 00:10:28.832469	2023-04-22 00:10:28.832469	Under	{}
16394	1.5	1.40	1663	Full Time	97.8%	2023-04-22 00:09:59.989173	2023-04-22 00:09:59.989173	Over	{}
16445	3.5	1.14	1666	Full Time	94.4%	2023-04-22 00:10:28.839018	2023-04-22 00:10:28.839018	Under	{}
16446	4.5	13.00	1666	Full Time	96.3%	2023-04-22 00:10:28.843114	2023-04-22 00:10:28.843114	Over	{}
16447	4.5	1.04	1666	Full Time	96.3%	2023-04-22 00:10:28.845777	2023-04-22 00:10:28.845777	Under	{}
16448	5.5	17.00	1666	Full Time	95.3%	2023-04-22 00:10:28.848268	2023-04-22 00:10:28.848268	Over	{}
16449	5.5	1.01	1666	Full Time	95.3%	2023-04-22 00:10:28.850721	2023-04-22 00:10:28.850721	Under	{}
16452	0.5	1.62	1666	1st Half	95.1%	2023-04-22 00:10:30.806632	2023-04-22 00:10:30.806632	Over	{}
16453	0.5	2.30	1666	1st Half	95.1%	2023-04-22 00:10:32.475239	2023-04-22 00:10:32.475239	Under	{}
16454	1.5	4.00	1666	1st Half	97.5%	2023-04-22 00:10:32.478274	2023-04-22 00:10:32.478274	Over	{}
16450	6.5	51.00	1666	Full Time	98.1%	2023-04-22 00:10:28.8527	2023-04-22 00:10:28.8527	Over	{}
16451	6.5	1.00	1666	Full Time	98.1%	2023-04-22 00:10:28.85487	2023-04-22 00:10:28.85487	Under	{}
16455	1.5	1.29	1666	1st Half	97.5%	2023-04-22 00:10:32.480506	2023-04-22 00:10:32.480506	Under	{}
16390	0.5	1.08	1663	Full Time	96.4%	2023-04-22 00:09:59.979881	2023-04-22 00:09:59.979881	Over	{}
16391	0.5	9.00	1663	Full Time	96.4%	2023-04-22 00:09:59.98272	2023-04-22 00:09:59.98272	Under	{}
16395	1.5	3.25	1663	Full Time	97.8%	2023-04-22 00:09:59.991348	2023-04-22 00:09:59.991348	Under	{}
16415	1.0	1.77	1663	1st Half	94.3%	2023-04-22 00:10:05.703559	2023-04-22 00:10:05.703559	Under	{}
16416	1.5	3.00	1663	1st Half	93.6%	2023-04-22 00:10:05.705834	2023-04-22 00:10:05.705834	Over	{}
16457	2.5	1.04	1666	1st Half	96.3%	2023-04-22 00:10:32.485842	2023-04-22 00:10:32.485842	Under	{}
16458	3.5	21.00	1666	1st Half	96.4%	2023-04-22 00:10:32.488218	2023-04-22 00:10:32.488218	Over	{}
16472	1.0	1.14	1669	Full Time	92.8%	2023-04-22 00:10:56.704619	2023-04-22 00:10:56.704619	Over	{}
16473	1.0	5.00	1669	Full Time	92.8%	2023-04-22 00:10:56.739549	2023-04-22 00:10:56.739549	Under	{}
16476	2.0	1.92	1669	Full Time	92.6%	2023-04-22 00:10:56.838591	2023-04-22 00:10:56.838591	Over	{}
16477	2.0	1.79	1669	Full Time	92.6%	2023-04-22 00:10:56.872295	2023-04-22 00:10:56.872295	Under	{}
16480	3.0	4.20	1669	Full Time	91.5%	2023-04-22 00:10:56.892018	2023-04-22 00:10:56.892018	Over	{}
16481	3.0	1.17	1669	Full Time	91.5%	2023-04-22 00:10:56.894381	2023-04-22 00:10:56.894381	Under	{}
16484	4.0	9.30	1669	Full Time	91.1%	2023-04-22 00:10:56.901664	2023-04-22 00:10:56.901664	Over	{}
16485	4.0	1.01	1669	Full Time	91.1%	2023-04-22 00:10:56.904083	2023-04-22 00:10:56.904083	Under	{}
16494	1.0	2.46	1669	1st Half	93.6%	2023-04-22 00:11:02.274526	2023-04-22 00:11:02.274526	Over	{}
16495	1.0	1.51	1669	1st Half	93.6%	2023-04-22 00:11:02.277203	2023-04-22 00:11:02.277203	Under	{}
16498	2.0	9.10	1669	1st Half	93.3%	2023-04-22 00:11:02.284181	2023-04-22 00:11:02.284181	Over	{}
16499	2.0	1.04	1669	1st Half	93.3%	2023-04-22 00:11:02.286431	2023-04-22 00:11:02.286431	Under	{}
16508	1.0	1.82	1669	2nd Half	93.7%	2023-04-22 00:11:07.384486	2023-04-22 00:11:07.384486	Over	{}
16509	1.0	1.93	1669	2nd Half	93.7%	2023-04-22 00:11:07.38646	2023-04-22 00:11:07.38646	Under	{}
16512	2.0	5.60	1669	2nd Half	93.3%	2023-04-22 00:11:07.393352	2023-04-22 00:11:07.393352	Over	{}
16513	2.0	1.12	1669	2nd Half	93.3%	2023-04-22 00:11:07.395599	2023-04-22 00:11:07.395599	Under	{}
16459	3.5	1.01	1666	1st Half	96.4%	2023-04-22 00:10:32.49048	2023-04-22 00:10:32.49048	Under	{}
16520	1.0	1.13	1672	Full Time	92.2%	2023-04-22 00:11:30.164227	2023-04-22 00:11:30.164227	Over	{}
16521	1.0	5.00	1672	Full Time	92.2%	2023-04-22 00:11:30.166382	2023-04-22 00:11:30.166382	Under	{}
16524	2.0	1.92	1672	Full Time	92.6%	2023-04-22 00:11:30.193448	2023-04-22 00:11:30.193448	Over	{}
16525	2.0	1.79	1672	Full Time	92.6%	2023-04-22 00:11:30.219961	2023-04-22 00:11:30.219961	Under	{}
16463	0.5	3.00	1666	2nd Half	97.3%	2023-04-22 00:10:35.657796	2023-04-22 00:10:35.657796	Under	{}
16464	1.5	2.75	1666	2nd Half	92.8%	2023-04-22 00:10:35.659948	2023-04-22 00:10:35.659948	Over	{}
16465	1.5	1.40	1666	2nd Half	92.8%	2023-04-22 00:10:35.662158	2023-04-22 00:10:35.662158	Under	{}
16466	2.5	7.00	1666	2nd Half	95.1%	2023-04-22 00:10:35.664673	2023-04-22 00:10:35.664673	Over	{}
16467	2.5	1.10	1666	2nd Half	95.1%	2023-04-22 00:10:35.667295	2023-04-22 00:10:35.667295	Under	{}
16468	3.5	21.00	1666	2nd Half	97.3%	2023-04-22 00:10:35.66963	2023-04-22 00:10:35.66963	Over	{}
16470	0.5	1.12	1669	Full Time	96.6%	2023-04-22 00:10:56.666347	2023-04-22 00:10:56.666347	Over	{}
16519	0.5	6.50	1672	Full Time	94.8%	2023-04-22 00:11:30.162081	2023-04-22 00:11:30.162081	Under	{}
16522	1.5	1.53	1672	Full Time	94.9%	2023-04-22 00:11:30.168619	2023-04-22 00:11:30.168619	Over	{}
16471	0.5	7.00	1669	Full Time	96.6%	2023-04-22 00:10:56.669324	2023-04-22 00:10:56.669324	Under	{}
16474	1.5	1.53	1669	Full Time	96.7%	2023-04-22 00:10:56.772208	2023-04-22 00:10:56.772208	Over	{}
16475	1.5	2.63	1669	Full Time	96.7%	2023-04-22 00:10:56.805127	2023-04-22 00:10:56.805127	Under	{}
16478	2.5	2.62	1669	Full Time	98.2%	2023-04-22 00:10:56.887207	2023-04-22 00:10:56.887207	Over	{}
16479	2.5	1.57	1669	Full Time	98.2%	2023-04-22 00:10:56.889491	2023-04-22 00:10:56.889491	Under	{}
16482	3.5	4.75	1669	Full Time	94.5%	2023-04-22 00:10:56.896874	2023-04-22 00:10:56.896874	Over	{}
16483	3.5	1.18	1669	Full Time	94.5%	2023-04-22 00:10:56.899236	2023-04-22 00:10:56.899236	Under	{}
16486	4.5	11.00	1669	Full Time	95.9%	2023-04-22 00:10:56.906366	2023-04-22 00:10:56.906366	Over	{}
16487	4.5	1.05	1669	Full Time	95.9%	2023-04-22 00:10:56.908703	2023-04-22 00:10:56.908703	Under	{}
16488	5.5	23.00	1669	Full Time	96.8%	2023-04-22 00:10:56.911114	2023-04-22 00:10:56.911114	Over	{}
16489	5.5	1.01	1669	Full Time	96.8%	2023-04-22 00:10:56.913689	2023-04-22 00:10:56.913689	Under	{}
16492	0.5	1.53	1669	1st Half	93.1%	2023-04-22 00:10:58.688191	2023-04-22 00:10:58.688191	Over	{}
16490	6.5	46.00	1669	Full Time	97.9%	2023-04-22 00:10:56.916148	2023-04-22 00:10:56.916148	Over	{}
16491	6.5	1.00	1669	Full Time	97.9%	2023-04-22 00:10:56.918441	2023-04-22 00:10:56.918441	Under	{}
16493	0.5	2.38	1669	1st Half	93.1%	2023-04-22 00:11:02.272015	2023-04-22 00:11:02.272015	Under	{}
16496	1.5	3.50	1669	1st Half	94.3%	2023-04-22 00:11:02.279516	2023-04-22 00:11:02.279516	Over	{}
16497	1.5	1.29	1669	1st Half	94.3%	2023-04-22 00:11:02.281854	2023-04-22 00:11:02.281854	Under	{}
16500	2.5	11.00	1669	1st Half	95.9%	2023-04-22 00:11:02.28883	2023-04-22 00:11:02.28883	Over	{}
16501	2.5	1.05	1669	1st Half	95.9%	2023-04-22 00:11:02.291107	2023-04-22 00:11:02.291107	Under	{}
16502	3.5	17.00	1669	1st Half	95.3%	2023-04-22 00:11:02.293443	2023-04-22 00:11:02.293443	Over	{}
16503	3.5	1.01	1669	1st Half	95.3%	2023-04-22 00:11:02.295818	2023-04-22 00:11:02.295818	Under	{}
16504	4.5	34.00	1669	1st Half	97.1%	2023-04-22 00:11:02.298221	2023-04-22 00:11:02.298221	Over	{}
16505	4.5	1.00	1669	1st Half	97.1%	2023-04-22 00:11:02.300582	2023-04-22 00:11:02.300582	Under	{}
16506	0.5	1.40	1669	2nd Half	97.8%	2023-04-22 00:11:03.933211	2023-04-22 00:11:03.933211	Over	{}
16507	0.5	3.25	1669	2nd Half	97.8%	2023-04-22 00:11:07.382115	2023-04-22 00:11:07.382115	Under	{}
16510	1.5	2.75	1669	2nd Half	97.1%	2023-04-22 00:11:07.38863	2023-04-22 00:11:07.38863	Over	{}
16511	1.5	1.50	1669	2nd Half	97.1%	2023-04-22 00:11:07.391085	2023-04-22 00:11:07.391085	Under	{}
16515	2.5	1.13	1669	2nd Half	96.3%	2023-04-22 00:11:07.400204	2023-04-22 00:11:07.400204	Under	{}
16516	3.5	17.00	1669	2nd Half	96.2%	2023-04-22 00:11:07.402453	2023-04-22 00:11:07.402453	Over	{}
16517	3.5	1.02	1669	2nd Half	96.2%	2023-04-22 00:11:07.404775	2023-04-22 00:11:07.404775	Under	{}
16518	0.5	1.11	1672	Full Time	94.8%	2023-04-22 00:11:30.158955	2023-04-22 00:11:30.158955	Over	{}
16523	1.5	2.50	1672	Full Time	94.9%	2023-04-22 00:11:30.170885	2023-04-22 00:11:30.170885	Under	{}
16460	4.5	34.00	1666	1st Half	97.1%	2023-04-22 00:10:32.49283	2023-04-22 00:10:32.49283	Over	{}
16461	4.5	1.00	1666	1st Half	97.1%	2023-04-22 00:10:32.4951	2023-04-22 00:10:32.4951	Under	{}
16462	0.5	1.44	1666	2nd Half	97.3%	2023-04-22 00:10:34.1163	2023-04-22 00:10:34.1163	Over	{}
16527	2.5	1.48	1672	Full Time	94.6%	2023-04-22 00:11:30.224758	2023-04-22 00:11:30.224758	Under	{}
16528	3.0	4.15	1672	Full Time	91.3%	2023-04-22 00:11:30.227113	2023-04-22 00:11:30.227113	Over	{}
16529	3.0	1.17	1672	Full Time	91.3%	2023-04-22 00:11:30.229481	2023-04-22 00:11:30.229481	Under	{}
16532	4.0	9.30	1672	Full Time	91.1%	2023-04-22 00:11:30.236535	2023-04-22 00:11:30.236535	Over	{}
16533	4.0	1.01	1672	Full Time	91.1%	2023-04-22 00:11:30.238888	2023-04-22 00:11:30.238888	Under	{}
16542	1.0	2.46	1672	1st Half	93.6%	2023-04-22 00:11:35.300451	2023-04-22 00:11:35.300451	Over	{}
16543	1.0	1.51	1672	1st Half	93.6%	2023-04-22 00:11:35.302883	2023-04-22 00:11:35.302883	Under	{}
16530	3.5	5.50	1672	Full Time	95.1%	2023-04-22 00:11:30.231811	2023-04-22 00:11:30.231811	Over	{}
16546	2.0	9.10	1672	1st Half	93.3%	2023-04-22 00:11:35.310026	2023-04-22 00:11:35.310026	Over	{}
16547	2.0	1.04	1672	1st Half	93.3%	2023-04-22 00:11:35.312447	2023-04-22 00:11:35.312447	Under	{}
16556	1.0	1.81	1672	2nd Half	93.6%	2023-04-22 00:11:40.406768	2023-04-22 00:11:40.406768	Over	{}
16557	1.0	1.94	1672	2nd Half	93.6%	2023-04-22 00:11:40.408982	2023-04-22 00:11:40.408982	Under	{}
16560	2.0	5.60	1672	2nd Half	93.3%	2023-04-22 00:11:40.478782	2023-04-22 00:11:40.478782	Over	{}
16561	2.0	1.12	1672	2nd Half	93.3%	2023-04-22 00:11:40.481341	2023-04-22 00:11:40.481341	Under	{}
16531	3.5	1.15	1672	Full Time	95.1%	2023-04-22 00:11:30.234168	2023-04-22 00:11:30.234168	Under	{}
16537	5.5	1.01	1672	Full Time	97.2%	2023-04-22 00:11:30.248263	2023-04-22 00:11:30.248263	Under	{}
16540	0.5	1.57	1672	1st Half	94.6%	2023-04-22 00:11:31.710356	2023-04-22 00:11:31.710356	Over	{}
16541	0.5	2.38	1672	1st Half	94.6%	2023-04-22 00:11:35.297733	2023-04-22 00:11:35.297733	Under	{}
16544	1.5	3.75	1672	1st Half	96.0%	2023-04-22 00:11:35.305297	2023-04-22 00:11:35.305297	Over	{}
16538	6.5	46.00	1672	Full Time	97.9%	2023-04-22 00:11:30.250578	2023-04-22 00:11:30.250578	Over	{}
16539	6.5	1.00	1672	Full Time	97.9%	2023-04-22 00:11:30.252887	2023-04-22 00:11:30.252887	Under	{}
16548	2.5	13.00	1672	1st Half	97.2%	2023-04-22 00:11:35.314839	2023-04-22 00:11:35.314839	Over	{}
16549	2.5	1.05	1672	1st Half	97.2%	2023-04-22 00:11:35.317211	2023-04-22 00:11:35.317211	Under	{}
16550	3.5	17.00	1672	1st Half	95.3%	2023-04-22 00:11:35.319585	2023-04-22 00:11:35.319585	Over	{}
16551	3.5	1.01	1672	1st Half	95.3%	2023-04-22 00:11:35.321941	2023-04-22 00:11:35.321941	Under	{}
16552	4.5	34.00	1672	1st Half	97.1%	2023-04-22 00:11:35.324362	2023-04-22 00:11:35.324362	Over	{}
16553	4.5	1.00	1672	1st Half	97.1%	2023-04-22 00:11:35.326743	2023-04-22 00:11:35.326743	Under	{}
16554	0.5	1.40	1672	2nd Half	95.5%	2023-04-22 00:11:37.009661	2023-04-22 00:11:37.009661	Over	{}
16555	0.5	3.00	1672	2nd Half	95.5%	2023-04-22 00:11:40.404458	2023-04-22 00:11:40.404458	Under	{}
16558	1.5	2.75	1672	2nd Half	92.8%	2023-04-22 00:11:40.411749	2023-04-22 00:11:40.411749	Over	{}
16559	1.5	1.40	1672	2nd Half	92.8%	2023-04-22 00:11:40.438375	2023-04-22 00:11:40.438375	Under	{}
16562	2.5	7.00	1672	2nd Half	95.1%	2023-04-22 00:11:40.483836	2023-04-22 00:11:40.483836	Over	{}
16563	2.5	1.10	1672	2nd Half	95.1%	2023-04-22 00:11:40.486284	2023-04-22 00:11:40.486284	Under	{}
16564	3.5	21.00	1672	2nd Half	97.3%	2023-04-22 00:11:40.488817	2023-04-22 00:11:40.488817	Over	{}
16565	3.5	1.02	1672	2nd Half	97.3%	2023-04-22 00:11:40.491214	2023-04-22 00:11:40.491214	Under	{}
16566	0.5	1.11	1675	Full Time	94.8%	2023-04-22 00:12:00.066102	2023-04-22 00:12:00.066102	Over	{}
16567	0.5	6.50	1675	Full Time	94.8%	2023-04-22 00:12:00.069697	2023-04-22 00:12:00.069697	Under	{}
16568	1.5	1.53	1675	Full Time	94.9%	2023-04-22 00:12:00.072357	2023-04-22 00:12:00.072357	Over	{}
16569	1.5	2.50	1675	Full Time	94.9%	2023-04-22 00:12:00.074499	2023-04-22 00:12:00.074499	Under	{}
16570	2.5	2.62	1675	Full Time	95.4%	2023-04-22 00:12:00.076757	2023-04-22 00:12:00.076757	Over	{}
16571	2.5	1.50	1675	Full Time	95.4%	2023-04-22 00:12:00.078971	2023-04-22 00:12:00.078971	Under	{}
16572	3.5	5.00	1675	Full Time	94.8%	2023-04-22 00:12:00.082714	2023-04-22 00:12:00.082714	Over	{}
16573	3.5	1.17	1675	Full Time	94.8%	2023-04-22 00:12:00.085599	2023-04-22 00:12:00.085599	Under	{}
16574	4.5	13.00	1675	Full Time	96.3%	2023-04-22 00:12:00.088235	2023-04-22 00:12:00.088235	Over	{}
16575	4.5	1.04	1675	Full Time	96.3%	2023-04-22 00:12:00.09077	2023-04-22 00:12:00.09077	Under	{}
16576	5.5	26.00	1675	Full Time	97.2%	2023-04-22 00:12:00.093333	2023-04-22 00:12:00.093333	Over	{}
16577	5.5	1.01	1675	Full Time	97.2%	2023-04-22 00:12:00.095906	2023-04-22 00:12:00.095906	Under	{}
16581	0.5	2.38	1675	1st Half	94.6%	2023-04-22 00:12:03.722482	2023-04-22 00:12:03.722482	Under	{}
16582	1.5	3.75	1675	1st Half	96.0%	2023-04-22 00:12:03.724748	2023-04-22 00:12:03.724748	Over	{}
16583	1.5	1.29	1675	1st Half	96.0%	2023-04-22 00:12:03.726946	2023-04-22 00:12:03.726946	Under	{}
16578	6.5	46.00	1675	Full Time	97.9%	2023-04-22 00:12:00.099883	2023-04-22 00:12:00.099883	Over	{}
16579	6.5	1.00	1675	Full Time	97.9%	2023-04-22 00:12:00.102576	2023-04-22 00:12:00.102576	Under	{}
16584	2.5	11.00	1675	1st Half	95.9%	2023-04-22 00:12:03.729217	2023-04-22 00:12:03.729217	Over	{}
16585	2.5	1.05	1675	1st Half	95.9%	2023-04-22 00:12:03.732285	2023-04-22 00:12:03.732285	Under	{}
16586	3.5	17.00	1675	1st Half	95.3%	2023-04-22 00:12:03.735128	2023-04-22 00:12:03.735128	Over	{}
16587	3.5	1.01	1675	1st Half	95.3%	2023-04-22 00:12:03.737457	2023-04-22 00:12:03.737457	Under	{}
16588	4.5	34.00	1675	1st Half	97.1%	2023-04-22 00:12:03.73968	2023-04-22 00:12:03.73968	Over	{}
16589	4.5	1.00	1675	1st Half	97.1%	2023-04-22 00:12:03.742196	2023-04-22 00:12:03.742196	Under	{}
16590	0.5	1.40	1675	2nd Half	97.8%	2023-04-22 00:12:05.514684	2023-04-22 00:12:05.514684	Over	{}
16591	0.5	3.25	1675	2nd Half	97.8%	2023-04-22 00:12:07.025908	2023-04-22 00:12:07.025908	Under	{}
16592	1.5	2.75	1675	2nd Half	94.5%	2023-04-22 00:12:07.02823	2023-04-22 00:12:07.02823	Over	{}
16593	1.5	1.44	1675	2nd Half	94.5%	2023-04-22 00:12:07.03121	2023-04-22 00:12:07.03121	Under	{}
16594	2.5	7.00	1675	2nd Half	95.1%	2023-04-22 00:12:07.034303	2023-04-22 00:12:07.034303	Over	{}
16595	2.5	1.10	1675	2nd Half	95.1%	2023-04-22 00:12:07.03671	2023-04-22 00:12:07.03671	Under	{}
16534	4.5	13.00	1672	Full Time	96.3%	2023-04-22 00:11:30.241211	2023-04-22 00:11:30.241211	Over	{}
16535	4.5	1.04	1672	Full Time	96.3%	2023-04-22 00:11:30.243544	2023-04-22 00:11:30.243544	Under	{}
16536	5.5	26.00	1672	Full Time	97.2%	2023-04-22 00:11:30.245866	2023-04-22 00:11:30.245866	Over	{}
16260	0.5	1.05	1657	Full Time	96.6%	2023-04-22 00:08:50.054063	2023-04-22 00:08:50.054063	Over	{}
16299	6.5	1.02	1657	Full Time	97.3%	2023-04-22 00:08:50.143198	2023-04-22 00:08:50.143198	Under	{}
16316	2.5	6.00	1657	1st Half	95.1%	2023-04-22 00:08:55.862805	2023-04-22 00:08:55.862805	Over	{}
16317	2.5	1.13	1657	1st Half	95.1%	2023-04-22 00:08:55.865405	2023-04-22 00:08:55.865405	Under	{}
16341	3.5	1.06	1657	2nd Half	96.3%	2023-04-22 00:09:01.80369	2023-04-22 00:09:01.80369	Under	{}
16386	2.5	5.50	1660	2nd Half	94.4%	2023-04-22 00:09:36.839443	2023-04-22 00:09:36.839443	Over	{}
16407	4.5	1.08	1663	Full Time	95.2%	2023-04-22 00:10:00.018528	2023-04-22 00:10:00.018528	Under	{}
16444	3.5	5.50	1666	Full Time	94.4%	2023-04-22 00:10:28.835723	2023-04-22 00:10:28.835723	Over	{}
16456	2.5	13.00	1666	1st Half	96.3%	2023-04-22 00:10:32.483333	2023-04-22 00:10:32.483333	Over	{}
16469	3.5	1.02	1666	2nd Half	97.3%	2023-04-22 00:10:35.672002	2023-04-22 00:10:35.672002	Under	{}
16514	2.5	6.50	1669	2nd Half	96.3%	2023-04-22 00:11:07.397845	2023-04-22 00:11:07.397845	Over	{}
16526	2.5	2.62	1672	Full Time	94.6%	2023-04-22 00:11:30.222113	2023-04-22 00:11:30.222113	Over	{}
16545	1.5	1.29	1672	1st Half	96.0%	2023-04-22 00:11:35.30766	2023-04-22 00:11:35.30766	Under	{}
16580	0.5	1.57	1675	1st Half	94.6%	2023-04-22 00:12:01.874382	2023-04-22 00:12:01.874382	Over	{}
16596	3.5	19.00	1675	2nd Half	96.8%	2023-04-22 00:12:07.038916	2023-04-22 00:12:07.038916	Over	{}
16597	3.5	1.02	1675	2nd Half	96.8%	2023-04-22 00:12:07.041417	2023-04-22 00:12:07.041417	Under	{}
15508	5.5	26.00	1569	Full Time	97.2%	2023-04-17 22:29:23.273851	2023-04-17 22:29:23.273851	Over	{}
\.


--
-- TOC entry 3102 (class 0 OID 16438)
-- Dependencies: 206
-- Data for Name: OddsSafariMatch; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."OddsSafariMatch" (id, home_team, guest_team, date_time, created, updated) FROM stdin;
1614	PAOK	Panathinaikos	2023-04-23 20:00:00+01	2023-04-19 04:03:14.178087	2023-04-19 04:03:14.178087
1615	Olympiacos	AEK	2023-04-23 21:00:00+01	2023-04-19 04:03:28.108684	2023-04-19 04:03:28.108684
1623	Volos	Panathinaikos	2023-04-26 18:00:00+01	2023-04-20 04:03:46.174406	2023-04-20 04:03:46.174406
1624	Aris Salonika	Olympiacos	2023-04-26 19:00:00+01	2023-04-20 04:03:59.405327	2023-04-20 04:03:59.405327
1625	AEK	PAOK	2023-04-26 21:00:00+01	2023-04-20 04:04:14.660184	2023-04-20 04:04:14.660184
1688	Atromitos	OFI	2023-04-29 19:15:00+01	2023-04-22 00:32:42.672861	2023-04-22 00:32:42.672861
1689	Ionikos	PAS Giannina	2023-04-29 19:15:00+01	2023-04-22 00:32:56.398066	2023-04-22 00:32:56.398066
1976	Asteras Tripolis	Lamia	2023-04-29 19:15:00+01	2023-04-22 21:38:37.688015	2023-04-22 21:38:37.688015
1979	Panetolikos	Levadiakos	2023-04-29 19:15:00+01	2023-04-22 21:39:20.900991	2023-04-22 21:39:20.900991
\.


--
-- TOC entry 3103 (class 0 OID 16446)
-- Dependencies: 207
-- Data for Name: OddsSafariOverUnder; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."OddsSafariOverUnder" (id, goals, odds, match_id, half, payout, created, updated, type, bet_links) FROM stdin;
15663	2.5	2.15	1623	Full Time	1.14%	2023-04-20 04:03:57.490306	2023-04-20 04:03:57.490306	Under	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436,https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
15664	2.5	2.25	1624	Full Time	2.52%	2023-04-20 04:04:11.995503	2023-04-20 04:04:11.995503	Over	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
15665	2.5	1.72	1624	Full Time	2.52%	2023-04-20 04:04:12.000527	2023-04-20 04:04:12.000527	Under	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
15666	2.5	2.20	1625	Full Time	2.53%	2023-04-20 04:04:26.961016	2023-04-20 04:04:26.961016	Over	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
15667	2.5	1.75	1625	Full Time	2.53%	2023-04-20 04:04:26.966227	2023-04-20 04:04:26.966227	Under	{}
19572	2.5	2.75	1976	Full Time	2.52%	2023-04-22 21:38:48.525496	2023-04-22 21:38:48.525496	Over	{}
19573	2.5	1.51	1976	Full Time	2.52%	2023-04-22 21:38:48.532391	2023-04-22 21:38:48.532391	Under	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
16618	2.5	2.60	1688	Full Time	0.95%	2023-04-22 00:32:54.574438	2023-04-22 00:32:54.574438	Over	{http://www.sportingbet.gr/,https://sports.bwin.gr/el/sports?wm=5273373}
16619	2.5	1.60	1688	Full Time	0.95%	2023-04-22 00:32:54.582221	2023-04-22 00:32:54.582221	Under	{http://www.sportingbet.gr/,https://sports.bwin.gr/el/sports?wm=5273373}
16620	2.5	2.65	1689	Full Time	0.62%	2023-04-22 00:33:06.981269	2023-04-22 00:33:06.981269	Over	{http://www.sportingbet.gr/,https://sports.bwin.gr/el/sports?wm=5273373}
16621	2.5	1.59	1689	Full Time	0.62%	2023-04-22 00:33:06.987041	2023-04-22 00:33:06.987041	Under	{http://www.sportingbet.gr/,https://sports.bwin.gr/el/sports?wm=5273373}
19578	2.5	2.60	1979	Full Time	4.08%	2023-04-22 21:39:32.609853	2023-04-22 21:39:32.609853	Over	{}
19579	2.5	1.52	1979	Full Time	4.08%	2023-04-22 21:39:32.617382	2023-04-22 21:39:32.617382	Under	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
15644	2.5	2.70	1614	Full Time	2.34%	2023-04-19 04:03:26.312457	2023-04-19 04:03:26.312457	Over	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
15645	2.5	1.53	1614	Full Time	2.34%	2023-04-19 04:03:26.318012	2023-04-19 04:03:26.318012	Under	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
15646	2.5	2.10	1615	Full Time	3.37%	2023-04-19 04:03:41.095903	2023-04-19 04:03:41.095903	Over	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
15662	2.5	1.83	1623	Full Time	1.14%	2023-04-20 04:03:57.483387	2023-04-20 04:03:57.483387	Over	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
15647	2.5	1.79	1615	Full Time	3.37%	2023-04-19 04:03:41.101083	2023-04-19 04:03:41.101083	Under	{https://record.affiliates.betshop.gr/_xVrm1kU5pcRLcRLGwHoTKWNd7ZgqdRLk/1/}
\.


--
-- TOC entry 3105 (class 0 OID 16457)
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
36	2023-02-20 17:30:00+00	OFI	Aris Salonika	Under	\N	3.4	0	Lost	0.5	0	3	0	0	2	1	4.40%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
26	2023-02-20 16:00:00+00	Atromitos	Levadiakos	Over	\N	2.4	0	Lost	2.5	1	1	1	0	0	0	3.46%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
27	2023-02-20 16:00:00+00	Atromitos	Levadiakos	Under	\N	2.55	0.05	Lost	0.5	1	1	1	0	0	0	2.83%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
28	2023-02-20 16:00:00+00	Atromitos	Levadiakos	Under	\N	3.4	0.9	Lost	0.5	1	1	1	0	0	0	4.40%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
29	2023-02-20 16:00:00+00	Atromitos	Levadiakos	Under	\N	2.55	0	Lost	0.5	1	1	1	0	0	0	2.83%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
22	2023-02-19 18:30:00+00	PAOK	AEK	Over	\N	2.45	0	Lost	2.5	2	0	1	1	0	0	2.48%	{https://record.affiliates.betshop.gr/_xVrm1kU5pcRLcRLGwHoTKWNd7ZgqdRLk/1/}
23	2023-02-19 18:30:00+00	PAOK	AEK	Under	\N	2.5	0	Lost	0.5	2	0	1	1	0	0	2.44%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
24	2023-02-19 18:30:00+00	PAOK	AEK	Under	\N	3.25	0.75	Lost	0.5	2	0	1	1	0	0	5.47%	{http://www.stoiximan.gr/,https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
39	2023-02-24 18:00:00+00	Volos	Lamia	Over	1st Half	2.15	0	Won	2.5	1	1	0	1	1	0	1.73%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
115	2023-03-19 15:30:00+00	Volos	Olympiacos	Under	1st Half	3.45	0.00	Lost	0.5	0	0	0	0	2	1	1.94%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
108	2023-03-18 17:30:00+00	Atromitos	Ionikos	Under	1st Half	2.40	0.00	Lost	0.5	2	2	1	1	0	0	3.28%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
96	2023-03-06 17:30:00+00	Panathinaikos	Panetolikos	Under	1st Half	2.95	0.00	Lost	0.5	2	0	0	2	0	0	2.78%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
87	2023-03-05 17:30:00+00	OFI	AEK	Under	Full Time	1.93	0.00	Lost	2.5	0	0	0	0	1	2	1.78%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
18	2023-02-19 17:30:00+00	Panetolikos	Ionikos	Under	\N	3.25	0.8	Lost	0.5	1	1	0	1	0	0	3.63%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
19	2023-02-19 17:30:00+00	Panetolikos	Ionikos	Under	\N	3.25	0.75	Lost	0.5	1	1	0	1	0	0	3.63%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
117	2023-03-19 15:30:00+00	Volos	Olympiacos	Under	Full Time	2.20	0.00	Lost	2.5	0	0	0	0	2	1	1.61%	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
113	2023-03-19 15:30:00+00	Volos	Olympiacos	Over	Full Time	1.78	0.00	Lost	2.5	0	0	0	0	2	1	1.61%	{}
114	2023-03-19 15:30:00+00	Volos	Olympiacos	Over	1st Half	1.78	0.00	Won	2.5	0	0	0	0	2	1	1.61%	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
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
207	2023-04-22 19:15:00+01	PAS Giannina	Panetolikos	Over	Full Time	2.44	0.00	Lost	2.5	3	2	1	2	1	1	4.47%	{https://record.affiliates.betshop.gr/_xVrm1kU5pcRLcRLGwHoTKWNd7ZgqdRLk/1/}
203	2023-04-22 19:15:00+01	Lamia	Atromitos	Over	Full Time	2.40	0.05	Lost	2.5	1	1	0	1	0	0	3.28%	{https://record.affiliates.betshop.gr/_xVrm1kU5pcRLcRLGwHoTKWNd7ZgqdRLk/1/}
204	2023-04-22 19:15:00+01	Lamia	Atromitos	Over	Full Time	2.40	0.00	Lost	2.5	1	1	0	1	0	0	3.28%	{https://record.affiliates.betshop.gr/_xVrm1kU5pcRLcRLGwHoTKWNd7ZgqdRLk/1/}
205	2023-04-22 19:15:00+01	Levadiakos	Ionikos	Over	Full Time	2.65	0.00	Lost	2.5	2	2	0	2	1	1	2.20%	{}
206	2023-04-22 19:15:00+01	OFI	Asteras Tripolis	Over	Full Time	2.50	0.00	Lost	2.5	1	1	1	0	1	0	1.70%	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
208	2023-04-23 17:30:00+01	Volos	Aris Salonika	Over	Full Time	2.09	0.00	Lost	2.5	0	0	0	0	1	2	3.87%	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
209	2023-04-23 17:30:00+01	Volos	Aris Salonika	Under	Full Time	1.78	0.00	Lost	2.5	0	0	0	0	1	2	3.87%	{https://record.affiliates.betshop.gr/_xVrm1kU5pcRLcRLGwHoTKWNd7ZgqdRLk/1/}
\.


--
-- TOC entry 3106 (class 0 OID 16474)
-- Dependencies: 212
-- Data for Name: soccer_statistics; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.soccer_statistics (id, home_team, guest_team, date_time, goals_home, goals_guest, full_time_home_win_odds, full_time_draw_odds, full_time_guest_win_odds, fisrt_half_home_win_odds, first_half_draw_odds, second_half_goals_guest, second_half_goals_home, first_half_goals_guest, first_half_goals_home, first_half_guest_win_odds, second_half_home_win_odds, second_half_draw_odds, second_half_guest_win_odds, full_time_over_under_goals, full_time_over_odds, full_time_under_odds, full_time_payout, first_half_over_under_goals, first_half_over_odds, firt_half_under_odds, first_half_payout, second_half_over_under_goals, second_half_over_odds, second_half_under_odds, second_half_payout, last_updated) FROM stdin;
\.


--
-- TOC entry 3127 (class 0 OID 0)
-- Dependencies: 201
-- Name: 1x2_oddsportal_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."1x2_oddsportal_id_seq"', 1, false);


--
-- TOC entry 3128 (class 0 OID 0)
-- Dependencies: 203
-- Name: Match_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."Match_id_seq"', 2073, true);


--
-- TOC entry 3129 (class 0 OID 0)
-- Dependencies: 208
-- Name: OverUnderHistorical_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."OverUnderHistorical_id_seq"', 209, true);


--
-- TOC entry 3130 (class 0 OID 0)
-- Dependencies: 204
-- Name: OverUnder_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."OverUnder_id_seq"', 20315, true);


--
-- TOC entry 3131 (class 0 OID 0)
-- Dependencies: 213
-- Name: soccer_statistics_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.soccer_statistics_id_seq', 1, false);


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
-- TOC entry 2959 (class 2606 OID 16515)
-- Name: soccer_statistics soccer_statistics_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.soccer_statistics
    ADD CONSTRAINT soccer_statistics_pkey PRIMARY KEY (id);


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
-- TOC entry 2962 (class 2620 OID 16519)
-- Name: OddsPortalOverUnder update_updated_Match_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER "update_updated_Match_trigger" AFTER UPDATE ON public."OddsPortalOverUnder" FOR EACH ROW EXECUTE FUNCTION public."update_updated_on_Match"();


--
-- TOC entry 2963 (class 2620 OID 16520)
-- Name: OddsPortalOverUnder update_updated_OverUnder_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER "update_updated_OverUnder_trigger" AFTER UPDATE ON public."OddsPortalOverUnder" FOR EACH ROW EXECUTE FUNCTION public."update_updated_on_OverUnder"();


--
-- TOC entry 2960 (class 2606 OID 16521)
-- Name: OddsPortalOverUnder OddsPortalOverUnder_Match_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsPortalOverUnder"
    ADD CONSTRAINT "OddsPortalOverUnder_Match_fk" FOREIGN KEY (match_id) REFERENCES public."OddsPortalMatch"(id) ON UPDATE CASCADE ON DELETE CASCADE NOT VALID;


--
-- TOC entry 2961 (class 2606 OID 16526)
-- Name: OddsSafariOverUnder OddsSafariOverUnder_Match_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsSafariOverUnder"
    ADD CONSTRAINT "OddsSafariOverUnder_Match_fk" FOREIGN KEY (match_id) REFERENCES public."OddsSafariMatch"(id) ON UPDATE CASCADE ON DELETE CASCADE NOT VALID;


--
-- TOC entry 3115 (class 0 OID 0)
-- Dependencies: 200
-- Name: TABLE "1x2_oddsportal"; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE public."1x2_oddsportal" FROM postgres;
GRANT ALL ON TABLE public."1x2_oddsportal" TO postgres WITH GRANT OPTION;


--
-- TOC entry 3117 (class 0 OID 0)
-- Dependencies: 202
-- Name: TABLE "OddsPortalMatch"; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE public."OddsPortalMatch" FROM postgres;


--
-- TOC entry 3119 (class 0 OID 0)
-- Dependencies: 205
-- Name: TABLE "OddsPortalOverUnder"; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE public."OddsPortalOverUnder" FROM postgres;
GRANT ALL ON TABLE public."OddsPortalOverUnder" TO postgres WITH GRANT OPTION;


--
-- TOC entry 3120 (class 0 OID 0)
-- Dependencies: 206
-- Name: TABLE "OddsSafariMatch"; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE public."OddsSafariMatch" FROM postgres;
GRANT ALL ON TABLE public."OddsSafariMatch" TO postgres WITH GRANT OPTION;


--
-- TOC entry 3121 (class 0 OID 0)
-- Dependencies: 207
-- Name: TABLE "OddsSafariOverUnder"; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE public."OddsSafariOverUnder" FROM postgres;
GRANT ALL ON TABLE public."OddsSafariOverUnder" TO postgres WITH GRANT OPTION;


--
-- TOC entry 3122 (class 0 OID 0)
-- Dependencies: 209
-- Name: TABLE "OverUnderHistorical"; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE public."OverUnderHistorical" FROM postgres;
GRANT ALL ON TABLE public."OverUnderHistorical" TO postgres WITH GRANT OPTION;


--
-- TOC entry 3123 (class 0 OID 0)
-- Dependencies: 210
-- Name: TABLE "PortalSafariMatch"; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE public."PortalSafariMatch" FROM postgres;
GRANT ALL ON TABLE public."PortalSafariMatch" TO postgres WITH GRANT OPTION;


--
-- TOC entry 3124 (class 0 OID 0)
-- Dependencies: 211
-- Name: TABLE "PortalSafariBets"; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE public."PortalSafariBets" FROM postgres;
GRANT ALL ON TABLE public."PortalSafariBets" TO postgres WITH GRANT OPTION;


--
-- TOC entry 3125 (class 0 OID 0)
-- Dependencies: 212
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


-- Completed on 2023-04-24 02:15:31 EEST

--
-- PostgreSQL database dump complete
--


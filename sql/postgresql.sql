--
-- PostgreSQL database dump
--

-- Dumped from database version 13.10 (Debian 13.10-0+deb11u1)
-- Dumped by pg_dump version 13.10 (Debian 13.10-0+deb11u1)

-- Started on 2023-05-05 12:27:51 EEST

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
-- TOC entry 209 (class 1259 OID 25102)
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
-- TOC entry 208 (class 1259 OID 25100)
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
-- Dependencies: 208
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
-- TOC entry 3120 (class 0 OID 0)
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
-- TOC entry 210 (class 1259 OID 25133)
-- Name: OverUnderHistorical_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."OverUnderHistorical_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 211 (class 1259 OID 25135)
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
-- TOC entry 213 (class 1259 OID 33416)
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
-- TOC entry 212 (class 1259 OID 33414)
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
-- TOC entry 2928 (class 2604 OID 25161)
-- Name: 1x2_oddsportal id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."1x2_oddsportal" ALTER COLUMN id SET DEFAULT nextval('public."1x2_oddsportal_id_seq"'::regclass);


--
-- TOC entry 2916 (class 2604 OID 25162)
-- Name: OddsPortalMatch id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsPortalMatch" ALTER COLUMN id SET DEFAULT nextval('public."Match_id_seq"'::regclass);


--
-- TOC entry 2920 (class 2604 OID 25163)
-- Name: OddsSafariMatch id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsSafariMatch" ALTER COLUMN id SET DEFAULT nextval('public."Match_id_seq"'::regclass);


--
-- TOC entry 2921 (class 2604 OID 25164)
-- Name: OddsSafariMatch created; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsSafariMatch" ALTER COLUMN created SET DEFAULT CURRENT_TIMESTAMP;


--
-- TOC entry 2922 (class 2604 OID 25165)
-- Name: OddsSafariMatch updated; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsSafariMatch" ALTER COLUMN updated SET DEFAULT CURRENT_TIMESTAMP;


--
-- TOC entry 2923 (class 2604 OID 25166)
-- Name: OddsSafariOverUnder id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsSafariOverUnder" ALTER COLUMN id SET DEFAULT nextval('public."OverUnder_id_seq"'::regclass);


--
-- TOC entry 2924 (class 2604 OID 25167)
-- Name: OddsSafariOverUnder created; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsSafariOverUnder" ALTER COLUMN created SET DEFAULT CURRENT_TIMESTAMP;


--
-- TOC entry 2925 (class 2604 OID 25168)
-- Name: OddsSafariOverUnder updated; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsSafariOverUnder" ALTER COLUMN updated SET DEFAULT CURRENT_TIMESTAMP;


--
-- TOC entry 2931 (class 2604 OID 33419)
-- Name: soccer_statistics id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.soccer_statistics ALTER COLUMN id SET DEFAULT nextval('public.soccer_statistics_id_seq'::regclass);


--
-- TOC entry 3105 (class 0 OID 25102)
-- Dependencies: 209
-- Data for Name: 1x2_oddsportal; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."1x2_oddsportal" (id, date_time, home_team, guest_team, half, "1_odds", x_odds, "2_odds", created, updated) FROM stdin;
\.


--
-- TOC entry 3098 (class 0 OID 24718)
-- Dependencies: 200
-- Data for Name: OddsPortalMatch; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."OddsPortalMatch" (id, home_team, guest_team, date_time, created, updated) FROM stdin;
1628	AEK Athens FC	Olympiacos Piraeus	2023-05-03 20:00:00+03	2023-04-29 06:02:27.924686	2023-04-29 06:02:27.924686
1631	Aris	Volos	2023-05-03 20:00:00+03	2023-04-29 06:02:43.600466	2023-04-29 06:02:43.600466
1634	Panathinaikos	PAOK	2023-05-03 20:00:00+03	2023-04-29 06:02:59.185355	2023-04-29 06:02:59.185355
1665	Atromitos	Panetolikos	2023-05-06 20:00:00+03	2023-04-30 06:02:11.124829	2023-04-30 06:02:11.124829
1668	Giannina	Asteras Tripolis	2023-05-06 20:00:00+03	2023-04-30 06:02:26.011118	2023-04-30 06:02:26.011118
1671	Lamia	Levadiakos	2023-05-06 20:00:00+03	2023-04-30 06:02:41.155153	2023-04-30 06:02:41.155153
1674	OFI Crete	Ionikos	2023-05-06 20:00:00+03	2023-04-30 06:02:55.271301	2023-04-30 06:02:55.271301
\.


--
-- TOC entry 3100 (class 0 OID 24726)
-- Dependencies: 202
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
16646	0.5	1.11	1671	Full Time	94.8%	2023-04-30 06:02:42.553042	2023-04-30 06:02:42.553042	Over	{}
16648	1.5	1.50	1671	Full Time	93.8%	2023-04-30 06:02:42.558397	2023-04-30 06:02:42.558397	Over	{}
16649	1.5	2.50	1671	Full Time	93.8%	2023-04-30 06:02:42.560169	2023-04-30 06:02:42.560169	Under	{}
16650	2.5	2.60	1671	Full Time	95.1%	2023-04-30 06:02:42.562576	2023-04-30 06:02:42.562576	Over	{}
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
\.


--
-- TOC entry 3102 (class 0 OID 24822)
-- Dependencies: 204
-- Data for Name: OddsSafariMatch; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."OddsSafariMatch" (id, home_team, guest_team, date_time, created, updated) FROM stdin;
1644	AEK	Olympiacos	2023-05-03 20:00:00+03	2023-04-29 06:09:21.620415	2023-04-29 06:09:21.620415
1645	Aris Salonika	Volos	2023-05-03 20:00:00+03	2023-04-29 06:09:33.004843	2023-04-29 06:09:33.004843
1646	Panathinaikos	PAOK	2023-05-03 20:00:00+03	2023-04-29 06:09:43.008413	2023-04-29 06:09:43.008413
1707	Atromitos	Panetolikos	2023-05-06 20:00:00+03	2023-05-01 06:07:22.867941	2023-05-01 06:07:22.867941
1708	Lamia	Levadiakos	2023-05-06 20:00:00+03	2023-05-01 06:07:32.779445	2023-05-01 06:07:32.779445
1709	OFI	Ionikos	2023-05-06 20:00:00+03	2023-05-01 06:07:42.21216	2023-05-01 06:07:42.21216
1710	PAS Giannina	Asteras Tripolis	2023-05-06 20:00:00+03	2023-05-01 06:07:52.110146	2023-05-01 06:07:52.110146
\.


--
-- TOC entry 3103 (class 0 OID 24836)
-- Dependencies: 205
-- Data for Name: OddsSafariOverUnder; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."OddsSafariOverUnder" (id, goals, odds, match_id, half, payout, created, updated, type, bet_links) FROM stdin;
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
\.


--
-- TOC entry 3107 (class 0 OID 25135)
-- Dependencies: 211
-- Data for Name: OverUnderHistorical; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."OverUnderHistorical" (id, "Date_Time", "Home_Team", "Guest_Team", "Type", "Half", "Odds_bet", "Margin", won, "Goals", "Home_Team_Goals", "Guest_Team_Goals", "Home_Team_Goals_1st_Half", "Home_Team_Goals_2nd_Half", "Guest_Team_Goals_1st_Half", "Guest_Team_Goals_2nd_Half", "Payout", "Bet_link") FROM stdin;
58	2023-02-26 16:00:00+02	Ionikos	OFI	Over	Full Time	2.30	0.00	Lost	2.5	0	0	0	0	0	2	4.26%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
59	2023-02-26 16:00:00+02	Ionikos	OFI	Under	2nd Half	2.60	0.00	Lost	0.5	0	0	0	0	0	2	2.11%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
63	2023-02-26 16:00:00+02	Levadiakos	Panetolikos	Under	1st Half	2.45	0.00	Lost	0.5	0	0	0	0	0	0	3.21%	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
64	2023-02-26 16:00:00+02	Levadiakos	Panetolikos	Under	1st Half	2.45	0.00	Lost	0.5	0	0	0	0	0	0	3.21%	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
53	2023-02-25 19:00:00+02	PAS Giannina	PAOK	Under	Full Time	2.1	0	Won	2.5	0	0	0	0	0	0	4.25%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
49	2023-02-25 17:30:00+02	AEK	Asteras Tripolis	Under	Full Time	2.1	0	Won	2.5	2	2	1	1	0	0	4.25%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
44	2023-02-24 20:00:00+02	Volos	Lamia	Under	Full Time	1.81	0	Won	2.5	1	1	0	1	1	0	1.73%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
21	2023-02-19 19:30:00+02	Panetolikos	Ionikos	Under	\N	3.25	0	Lost	0.5	1	1	0	1	0	0	3.63%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
20	2023-02-19 19:30:00+02	Panetolikos	Ionikos	Under	\N	3.25	0	Lost	0.5	1	1	0	1	0	0	3.63%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
10	2023-02-19 16:00:00+02	Lamia	Olympiacos	Over	\N	2	0	Won	2.5	0	0	0	0	1	2	2.56%	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/,https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
11	2023-02-19 16:00:00+02	Lamia	Olympiacos	Under	\N	2.95	0	Lost	0.5	0	0	0	0	1	2	2.78%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
1	2023-02-18 17:00:00+02	Panathinaikos	Volos	Over	\N	2.17	0	Lost	2.5	2	2	0	2	0	0	0.72%	{https://record.affiliates.betshop.gr/_xVrm1kU5pcRLcRLGwHoTKWNd7ZgqdRLk/1/}
2	2023-02-18 17:00:00+02	Panathinaikos	Volos	Under	\N	2.8	0	Lost	0.5	2	2	0	2	0	0	2.33%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
3	2023-02-18 17:00:00+02	Panathinaikos	Volos	Under	\N	3.7	0.9	Lost	0.5	2	2	0	2	0	0	3.80%	{}
37	2023-02-24 20:00:00+02	Volos	Lamia	Over	Full Time	2.15	0.1	Lost	2.5	1	1	0	1	1	0	1.73%	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
33	2023-02-20 19:30:00+02	OFI	Aris Salonika	Over	\N	2.4	0	Won	2.5	0	3	0	0	2	1	3.28%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
34	2023-02-20 19:30:00+02	OFI	Aris Salonika	Under	\N	2.6	0	Lost	0.5	0	3	0	0	2	1	2.89%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
30	2023-02-20 18:00:00+02	Atromitos	Levadiakos	Under	\N	3.4	0.85	Lost	0.5	1	1	1	0	0	0	4.40%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
31	2023-02-20 18:00:00+02	Atromitos	Levadiakos	Under	\N	3.4	0	Lost	0.5	1	1	1	0	0	0	4.40%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
181	2023-04-22 19:00:00+03	Lamia	Atromitos	Over	Full Time	2.45	0.00	Lost	2.5	\N	\N	\N	\N	\N	\N	2.84%	{}
182	2023-04-22 19:00:00+03	Lamia	Atromitos	Under	1st Half	2.38	0.00	Lost	0.5	\N	\N	\N	\N	\N	\N	6.84%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
183	2023-04-22 19:00:00+03	Lamia	Atromitos	Under	2nd Half	3.25	0.00	Lost	0.5	\N	\N	\N	\N	\N	\N	5.47%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
70	2023-03-04 20:00:00+02	Asteras Tripolis	Atromitos	Over	Full Time	2.30	0.00	Lost	2.5	1	1	0	1	1	0	4.61%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107,https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145,https://record.affiliates.betshop.gr/_xVrm1kU5pcRLcRLGwHoTKWNd7ZgqdRLk/1/}
71	2023-03-04 20:00:00+02	Asteras Tripolis	Atromitos	Under	1st Half	2.55	0.00	Lost	0.5	1	1	0	1	1	0	2.83%	{http://www.sportingbet.gr/,https://sports.bwin.gr/el/sports?wm=5273373,https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
60	2023-02-26 16:00:00+02	Ionikos	OFI	Under	1st Half	2.60	0.00	Lost	0.5	0	0	0	0	0	2	2.11%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
57	2023-02-25 20:30:00+02	Olympiacos	Panathinaikos	Under	Full Time	1.74	0	Won	2.5	0	0	0	0	0	0	3.83%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107,https://partners.opapaffiliates.gr/redirect.aspx?pid=2460&bid=1759}
50	2023-02-25 19:00:00+02	PAS Giannina	PAOK	Over	Full Time	1.76	0	Lost	2.5	0	0	0	0	0	0	4.25%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
51	2023-02-25 19:00:00+02	PAS Giannina	PAOK	Under	1st Half	3.3	0	Lost	0.5	0	0	0	0	0	0	2.69%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
46	2023-02-25 17:30:00+02	AEK	Asteras Tripolis	Over	Full Time	1.76	0	Lost	2.5	2	2	1	1	0	0	4.25%	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
47	2023-02-25 17:30:00+02	AEK	Asteras Tripolis	Under	1st Half	3.3	0	Lost	0.5	2	2	1	1	0	0	2.69%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
38	2023-02-24 20:00:00+02	Volos	Lamia	Over	Full Time	2.15	0	Lost	2.5	1	1	0	1	1	0	1.73%	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
35	2023-02-20 19:30:00+02	OFI	Aris Salonika	Under	\N	3.4	0.8	Lost	0.5	0	3	0	0	2	1	4.40%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
32	2023-02-20 18:00:00+02	Atromitos	Levadiakos	Under	\N	3.4	0	Lost	0.5	1	1	1	0	0	0	4.40%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
184	2023-04-22 19:00:00+03	Levadiakos	Ionikos	Over	Full Time	2.60	0.00	Lost	2.5	\N	\N	\N	\N	\N	\N	3.29%	{}
40	2023-02-24 20:00:00+02	Volos	Lamia	Under	1st Half	2.9	0	Lost	0.5	1	1	0	1	1	0	1.14%	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
185	2023-04-22 19:00:00+03	Levadiakos	Ionikos	Under	1st Half	2.50	0.00	Lost	0.5	\N	\N	\N	\N	\N	\N	4.70%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
12	2023-02-19 16:00:00+02	Lamia	Olympiacos	Under	\N	3.9	0.95	Lost	0.5	0	0	0	0	1	2	4.20%	{}
4	2023-02-18 17:00:00+02	Panathinaikos	Volos	Under	\N	3.7	0	Lost	0.5	2	2	0	2	0	0	3.80%	{}
5	2023-02-18 17:00:00+02	Panathinaikos	Volos	Under	\N	1.83	0	Lost	2.5	2	2	0	2	0	0	0.72%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
79	2023-03-05 17:00:00+02	PAS Giannina	Volos	Under	2nd Half	3.40	0.00	Lost	0.5	0	0	0	0	0	1	4.40%	{http://www.sportingbet.gr/,https://sports.bwin.gr/el/sports?wm=5273373,https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/,http://www.stoiximan.gr/,https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
61	2023-02-26 16:00:00+02	Levadiakos	Panetolikos	Over	Full Time	2.60	0.00	Lost	2.5	0	0	0	0	0	0	1.72%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
62	2023-02-26 16:00:00+02	Levadiakos	Panetolikos	Over	Full Time	2.60	0.00	Lost	2.5	0	0	0	0	0	0	1.72%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
94	2023-03-06 19:30:00+02	Panathinaikos	Panetolikos	Over	Full Time	2.03	0.01	Lost	2.5	2	0	0	2	0	0	4.32%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
84	2023-03-05 19:30:00+02	OFI	AEK	Over	Full Time	2.00	0.00	Lost	2.5	0	0	0	0	1	2	1.78%	{}
86	2023-03-05 19:30:00+02	OFI	AEK	Under	2nd Half	3.90	0.00	Lost	0.5	0	0	0	0	1	2	4.77%	{}
54	2023-02-25 20:30:00+02	Olympiacos	Panathinaikos	Over	Full Time	2.15	0	Lost	2.5	0	0	0	0	0	0	3.83%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
55	2023-02-25 20:30:00+02	Olympiacos	Panathinaikos	Under	1st Half	2.8	0	Lost	0.5	0	0	0	0	0	0	1.48%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
13	2023-02-19 16:00:00+02	Lamia	Olympiacos	Under	\N	3.9	0	Lost	0.5	0	0	0	0	1	2	4.20%	{}
14	2023-02-19 16:00:00+02	Lamia	Olympiacos	Under	\N	1.9	0	Lost	2.5	0	0	0	0	1	2	2.56%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
6	2023-02-18 20:00:00+02	Asteras Tripolis	PAS Giannina	Over	\N	2.55	0	Lost	2.5	1	1	1	0	1	0	2.07%	{https://record.affiliates.betshop.gr/_xVrm1kU5pcRLcRLGwHoTKWNd7ZgqdRLk/1/}
186	2023-04-22 19:00:00+03	Levadiakos	Ionikos	Under	2nd Half	3.40	0.00	Lost	0.5	\N	\N	\N	\N	\N	\N	2.35%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
187	2023-04-22 19:00:00+03	OFI	Asteras Tripolis	Over	Full Time	2.50	0.00	Lost	2.5	\N	\N	\N	\N	\N	\N	1.33%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
52	2023-02-25 19:00:00+02	PAS Giannina	PAOK	Under	2nd Half	4.4	0	Lost	0.5	0	0	0	0	0	0	4.36%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
26	2023-02-20 18:00:00+02	Atromitos	Levadiakos	Over	\N	2.4	0	Lost	2.5	1	1	1	0	0	0	3.46%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
27	2023-02-20 18:00:00+02	Atromitos	Levadiakos	Under	\N	2.55	0.05	Lost	0.5	1	1	1	0	0	0	2.83%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
188	2023-04-22 19:00:00+03	OFI	Asteras Tripolis	Under	1st Half	2.50	0.00	Lost	0.5	\N	\N	\N	\N	\N	\N	6.25%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
80	2023-03-05 17:30:00+02	Lamia	Aris Salonika	Over	Full Time	2.09	0.00	Lost	2.5	2	2	2	0	1	0	3.00%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
56	2023-02-25 20:30:00+02	Olympiacos	Panathinaikos	Under	2nd Half	3.75	0	Lost	0.5	0	0	0	0	0	0	3.47%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
48	2023-02-25 17:30:00+02	AEK	Asteras Tripolis	Under	2nd Half	4.4	0	Lost	0.5	2	2	1	1	0	0	4.36%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
36	2023-02-20 19:30:00+02	OFI	Aris Salonika	Under	\N	3.4	0	Lost	0.5	0	3	0	0	2	1	4.40%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
28	2023-02-20 18:00:00+02	Atromitos	Levadiakos	Under	\N	3.4	0.9	Lost	0.5	1	1	1	0	0	0	4.40%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
29	2023-02-20 18:00:00+02	Atromitos	Levadiakos	Under	\N	2.55	0	Lost	0.5	1	1	1	0	0	0	2.83%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
22	2023-02-19 20:30:00+02	PAOK	AEK	Over	\N	2.45	0	Lost	2.5	2	0	1	1	0	0	2.48%	{https://record.affiliates.betshop.gr/_xVrm1kU5pcRLcRLGwHoTKWNd7ZgqdRLk/1/}
23	2023-02-19 20:30:00+02	PAOK	AEK	Under	\N	2.5	0	Lost	0.5	2	0	1	1	0	0	2.44%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
24	2023-02-19 20:30:00+02	PAOK	AEK	Under	\N	3.25	0.75	Lost	0.5	2	0	1	1	0	0	5.47%	{http://www.stoiximan.gr/,https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
189	2023-04-22 19:00:00+03	OFI	Asteras Tripolis	Under	2nd Half	3.40	0.00	Lost	0.5	\N	\N	\N	\N	\N	\N	5.44%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
190	2023-04-22 19:00:00+03	Olympiacos	AEK	Over	Full Time	2.30	0.00	Lost	2.5	\N	\N	\N	\N	\N	\N	-0.02%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
191	2023-04-22 19:00:00+03	Olympiacos	AEK	Under	1st Half	2.63	0.00	Lost	0.5	\N	\N	\N	\N	\N	\N	6.95%	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
81	2023-03-05 17:30:00+02	Lamia	Aris Salonika	Under	1st Half	2.90	0.00	Lost	0.5	2	2	2	0	1	0	2.45%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
82	2023-03-05 17:30:00+02	Lamia	Aris Salonika	Under	2nd Half	3.75	0.00	Lost	0.5	2	2	2	0	1	0	5.13%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
15	2023-02-19 19:30:00+02	Panetolikos	Ionikos	Over	\N	2.5	0	Lost	2.5	1	1	0	1	0	0	1.70%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107,https://partners.opapaffiliates.gr/redirect.aspx?pid=2460&bid=1759,https://record.affiliates.betshop.gr/_xVrm1kU5pcRLcRLGwHoTKWNd7ZgqdRLk/1/}
192	2023-04-22 19:00:00+03	Olympiacos	AEK	Under	2nd Half	3.40	0.00	Lost	0.5	\N	\N	\N	\N	\N	\N	7.01%	{https://sports.bwin.gr/el/sports?wm=5273373}
16	2023-02-19 19:30:00+02	Panetolikos	Ionikos	Over	\N	2.5	0	Lost	2.5	1	1	0	1	0	0	1.70%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107,https://partners.opapaffiliates.gr/redirect.aspx?pid=2460&bid=1759,https://record.affiliates.betshop.gr/_xVrm1kU5pcRLcRLGwHoTKWNd7ZgqdRLk/1/}
17	2023-02-19 19:30:00+02	Panetolikos	Ionikos	Under	\N	2.45	0	Lost	0.5	1	1	0	1	0	0	3.21%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
7	2023-02-18 20:00:00+02	Asteras Tripolis	PAS Giannina	Under	\N	2.45	0	Lost	0.5	1	1	1	0	1	0	3.21%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
8	2023-02-18 20:00:00+02	Asteras Tripolis	PAS Giannina	Under	\N	3.25	0.8	Lost	0.5	1	1	1	0	1	0	3.63%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
9	2023-02-18 20:00:00+02	Asteras Tripolis	PAS Giannina	Under	\N	3.25	0	Lost	0.5	1	1	1	0	1	0	3.63%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
103	2023-03-18 17:30:00+02	OFI	Levadiakos	Over	Full Time	2.45	0.00	Lost	2.5	1	1	0	1	0	1	-0.36%	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
104	2023-03-18 17:30:00+02	OFI	Levadiakos	Under	1st Half	2.60	0.00	Lost	0.5	1	1	0	1	0	1	2.89%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
105	2023-03-18 17:30:00+02	OFI	Levadiakos	Under	2nd Half	3.25	0.00	Lost	0.5	1	1	0	1	0	1	5.47%	{http://www.sportingbet.gr/,https://sports.bwin.gr/el/sports?wm=5273373,https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=,https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
95	2023-03-06 19:30:00+02	Panathinaikos	Panetolikos	Over	Full Time	2.03	0.00	Lost	2.5	2	0	0	2	0	0	4.32%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
96	2023-03-06 19:30:00+02	Panathinaikos	Panetolikos	Under	1st Half	2.95	0.00	Lost	0.5	2	0	0	2	0	0	2.78%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
97	2023-03-06 19:30:00+02	Panathinaikos	Panetolikos	Under	2nd Half	3.75	0.00	Lost	0.5	2	0	0	2	0	0	5.13%	{http://www.sportingbet.gr/,https://sports.bwin.gr/el/sports?wm=5273373,https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
88	2023-03-05 20:30:00+02	PAOK	Ionikos	Over	Full Time	1.92	0.01	Lost	2.5	6	0	4	2	0	0	3.26%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
89	2023-03-05 20:30:00+02	PAOK	Ionikos	Over	Full Time	1.92	0.00	Lost	2.5	6	0	4	2	0	0	3.26%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
115	2023-03-19 17:30:00+02	Volos	Olympiacos	Under	1st Half	3.45	0.00	Lost	0.5	0	0	0	0	2	1	1.94%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
119	2023-03-19 19:00:00+02	Aris Salonika	PAOK	Over	Full Time	2.55	0.00	Lost	2.5	1	1	1	0	0	2	0.56%	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
90	2023-03-05 20:30:00+02	PAOK	Ionikos	Under	1st Half	3.10	0.00	Lost	0.5	6	0	4	2	0	0	2.61%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
116	2023-03-19 17:30:00+02	Volos	Olympiacos	Under	2nd Half	4.47	0.00	Lost	0.5	0	0	0	0	2	1	5.40%	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
107	2023-03-18 19:30:00+02	Atromitos	Ionikos	Over	Full Time	2.72	0.00	Lost	2.5	2	2	1	1	0	0	0.46%	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
110	2023-03-18 21:00:00+02	Lamia	PAS Giannina	Over	Full Time	2.77	0.00	Lost	2.5	2	0	2	0	0	0	1.44%	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
67	2023-02-26 19:30:00+02	Aris Salonika	Atromitos	Over	Full Time	2.60	0.00	Lost	2.5	2	1	2	0	0	1	1.72%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
65	2023-02-26 16:00:00+02	Levadiakos	Panetolikos	Under	2nd Half	3.25	0.00	Lost	0.5	0	0	0	0	0	0	3.63%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
111	2023-03-18 21:00:00+02	Lamia	PAS Giannina	Under	1st Half	2.45	0.00	Lost	0.5	2	0	2	0	0	0	1.40%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
66	2023-02-26 16:00:00+02	Levadiakos	Panetolikos	Under	2nd Half	3.25	0.00	Lost	0.5	0	0	0	0	0	0	3.63%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
112	2023-03-18 21:00:00+02	Lamia	PAS Giannina	Under	2nd Half	3.25	0.00	Lost	0.5	2	0	2	0	0	0	2.64%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
108	2023-03-18 19:30:00+02	Atromitos	Ionikos	Under	1st Half	2.40	0.00	Lost	0.5	2	2	1	1	0	0	3.28%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
73	2023-03-04 20:00:00+02	Asteras Tripolis	Atromitos	Under	2nd Half	3.40	0.00	Lost	0.5	1	1	0	1	1	0	4.40%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
68	2023-02-26 19:30:00+02	Aris Salonika	Atromitos	Under	1st Half	2.45	0.00	Lost	0.5	2	1	2	0	0	1	3.21%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
69	2023-02-26 19:30:00+02	Aris Salonika	Atromitos	Under	2nd Half	3.25	0.00	Lost	0.5	2	1	2	0	0	1	3.63%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
109	2023-03-18 19:30:00+02	Atromitos	Ionikos	Under	2nd Half	3.25	0.00	Lost	0.5	2	2	1	1	0	0	3.13%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
42	2023-02-24 20:00:00+02	Volos	Lamia	Under	2nd Half	3.75	0	Lost	0.5	1	1	0	1	1	0	4.02%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
39	2023-02-24 20:00:00+02	Volos	Lamia	Over	1st Half	2.15	0	Won	2.5	1	1	0	1	1	0	1.73%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
193	2023-04-22 19:00:00+03	Olympiacos	AEK	Under	Full Time	1.77	0.00	Lost	2.5	\N	\N	\N	\N	\N	\N	-0.02%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
194	2023-04-22 19:00:00+03	PAOK	Panathinaikos	Over	Full Time	2.65	0.00	Lost	2.5	\N	\N	\N	\N	\N	\N	3.41%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
195	2023-04-22 19:00:00+03	PAOK	Panathinaikos	Under	1st Half	2.45	0.00	Lost	0.5	\N	\N	\N	\N	\N	\N	6.20%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
91	2023-03-05 20:30:00+02	PAOK	Ionikos	Under	2nd Half	4.05	0.05	Lost	0.5	6	0	4	2	0	0	4.48%	{http://www.stoiximan.gr/}
92	2023-03-05 20:30:00+02	PAOK	Ionikos	Under	2nd Half	4.05	0.00	Lost	0.5	6	0	4	2	0	0	4.48%	{http://www.stoiximan.gr/}
43	2023-02-24 20:00:00+02	Volos	Lamia	Under	1st Half	1.81	0.73	Lost	2.5	1	1	0	1	1	0	1.73%	{https://partners.opapaffiliates.gr/redirect.aspx?pid=2460&bid=1759}
45	2023-02-24 20:00:00+02	Volos	Lamia	Under	1st Half	1.81	0	Lost	2.5	1	1	0	1	1	0	1.73%	{https://partners.opapaffiliates.gr/redirect.aspx?pid=2460&bid=1759}
196	2023-04-22 19:00:00+03	PAOK	Panathinaikos	Under	2nd Half	3.00	0.00	Lost	0.5	\N	\N	\N	\N	\N	\N	5.95%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
197	2023-04-22 19:00:00+03	PAS Giannina	Panetolikos	Over	Full Time	2.44	0.00	Lost	2.5	\N	\N	\N	\N	\N	\N	4.47%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
198	2023-04-22 19:00:00+03	PAS Giannina	Panetolikos	Under	1st Half	2.50	0.00	Lost	0.5	\N	\N	\N	\N	\N	\N	4.32%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
199	2023-04-22 19:00:00+03	PAS Giannina	Panetolikos	Under	2nd Half	3.40	0.00	Lost	0.5	\N	\N	\N	\N	\N	\N	4.40%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
114	2023-03-19 17:30:00+02	Volos	Olympiacos	Over	1st Half	1.78	0.00	Won	2.5	0	0	0	0	2	1	1.61%	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
215	2023-04-30 20:00:00+03	Olympiacos	Volos	Under	Full Time	3.10	0.00	Lost	2.5	5	0	3	2	0	0	3.56%	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/,https://record.affiliates.betshop.gr/_xVrm1kU5pcRLcRLGwHoTKWNd7ZgqdRLk/1/}
216	2023-04-30 20:00:00+03	Panathinaikos	AEK	Over	Full Time	2.55	0.00	Lost	2.5	0	0	0	0	0	0	3.99%	{}
106	2023-03-18 17:30:00+02	OFI	Levadiakos	Under	Full Time	1.70	0.00	Lost	2.5	1	1	0	1	0	1	-0.36%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
83	2023-03-05 17:30:00+02	Lamia	Aris Salonika	Under	Full Time	1.81	0.00	Lost	2.5	2	2	2	0	1	0	3.00%	{https://record.affiliates.betshop.gr/_xVrm1kU5pcRLcRLGwHoTKWNd7ZgqdRLk/1/}
125	2023-04-01 17:00:00+03	Levadiakos	Atromitos	Over	Full Time	2.70	0.05	Lost	2.5	1	1	0	1	0	1	3.57%	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
41	2023-02-24 20:00:00+02	Volos	Lamia	Under	2nd Half	3.75	0	Lost	0.5	1	1	0	1	1	0	4.02%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
72	2023-03-04 20:00:00+02	Asteras Tripolis	Atromitos	Under	2nd Half	3.40	0.00	Lost	0.5	1	1	0	1	1	0	4.40%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
126	2023-04-01 17:00:00+03	Levadiakos	Atromitos	Over	Full Time	2.70	0.05	Lost	2.5	1	1	0	1	0	1	3.57%	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
113	2023-03-19 17:30:00+02	Volos	Olympiacos	Over	Full Time	1.78	0.00	Lost	2.5	0	0	0	0	2	1	1.61%	{}
118	2023-03-19 17:30:00+02	Volos	Olympiacos	Under	1st Half	2.20	0.00	Lost	2.5	0	0	0	0	2	1	1.61%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
25	2023-02-19 20:30:00+02	PAOK	AEK	Under	\N	3.25	0	Lost	0.5	2	0	1	1	0	0	5.47%	{http://www.stoiximan.gr/,https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
77	2023-03-05 17:00:00+02	PAS Giannina	Volos	Over	Full Time	2.30	0.00	Lost	2.5	0	0	0	0	0	1	3.59%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107,https://record.affiliates.betshop.gr/_xVrm1kU5pcRLcRLGwHoTKWNd7ZgqdRLk/1/}
101	2023-03-18 17:00:00+02	Asteras Tripolis	Panetolikos	Under	1st Half	2.50	0.00	Lost	0.5	2	2	1	1	0	1	3.56%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
102	2023-03-18 17:00:00+02	Asteras Tripolis	Panetolikos	Under	2nd Half	3.25	0.00	Lost	0.5	2	2	1	1	0	1	4.62%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
78	2023-03-05 17:00:00+02	PAS Giannina	Volos	Under	1st Half	2.60	0.00	Lost	0.5	0	0	0	0	0	1	4.08%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436,https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
18	2023-02-19 19:30:00+02	Panetolikos	Ionikos	Under	\N	3.25	0.8	Lost	0.5	1	1	0	1	0	0	3.63%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
19	2023-02-19 19:30:00+02	Panetolikos	Ionikos	Under	\N	3.25	0.75	Lost	0.5	1	1	0	1	0	0	3.63%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
98	2023-03-06 19:30:00+02	Panathinaikos	Panetolikos	Under	2nd Half	3.75	0.00	Lost	0.5	2	0	0	2	0	0	5.13%	{http://www.sportingbet.gr/,https://sports.bwin.gr/el/sports?wm=5273373,https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
93	2023-03-05 20:30:00+02	PAOK	Ionikos	Under	Full Time	1.95	0.00	Lost	2.5	6	0	4	2	0	0	3.26%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436,https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/,https://www.bet365.gr/olp/open-account?affiliate=365_01012107,https://record.affiliates.betshop.gr/_xVrm1kU5pcRLcRLGwHoTKWNd7ZgqdRLk/1/}
200	2023-04-22 19:00:00+03	Volos	Aris Salonika	Over	Full Time	2.10	0.00	Lost	2.5	\N	\N	\N	\N	\N	\N	3.66%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
201	2023-04-22 19:00:00+03	Volos	Aris Salonika	Under	1st Half	2.60	0.00	Lost	0.5	\N	\N	\N	\N	\N	\N	4.88%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
202	2023-04-22 19:00:00+03	Volos	Aris Salonika	Under	2nd Half	3.40	0.00	Lost	0.5	\N	\N	\N	\N	\N	\N	4.40%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
203	2023-04-22 19:00:00+03	Volos	Aris Salonika	Under	Full Time	1.78	0.00	Lost	2.5	\N	\N	\N	\N	\N	\N	3.66%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
127	2023-04-01 17:00:00+03	Levadiakos	Atromitos	Over	Full Time	2.70	0.00	Lost	2.5	1	1	0	1	0	1	3.57%	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
122	2023-03-19 21:30:00+02	AEK	Panathinaikos	Over	Full Time	2.60	0.00	Lost	2.5	0	0	0	0	0	0	2.50%	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
217	2023-04-30 20:00:00+03	PAOK	Aris Salonika	Over	Full Time	2.35	0.00	Lost	2.5	3	3	0	3	1	1	3.06%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145,https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
135	2023-04-01 17:30:00+03	Panetolikos	Lamia	Over	Full Time	2.60	0.05	Lost	2.5	1	1	0	1	0	3	3.68%	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
136	2023-04-01 17:30:00+03	Panetolikos	Lamia	Over	Full Time	2.60	0.00	Lost	2.5	1	1	0	1	0	3	3.68%	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
123	2023-03-19 21:30:00+02	AEK	Panathinaikos	Under	1st Half	2.45	0.00	Lost	0.5	0	0	0	0	0	0	3.21%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
124	2023-03-19 21:30:00+02	AEK	Panathinaikos	Under	2nd Half	3.25	0.00	Lost	0.5	0	0	0	0	0	0	3.63%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
137	2023-04-01 17:30:00+03	Panetolikos	Lamia	Under	1st Half	2.35	0.00	Lost	0.5	1	1	0	1	0	3	5.84%	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
138	2023-04-01 17:30:00+03	Panetolikos	Lamia	Under	2nd Half	3.25	0.00	Lost	0.5	1	1	0	1	0	3	4.62%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
120	2023-03-19 19:00:00+02	Aris Salonika	PAOK	Under	1st Half	2.45	0.00	Lost	0.5	1	1	1	0	0	2	4.32%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
121	2023-03-19 19:00:00+02	Aris Salonika	PAOK	Under	2nd Half	3.25	0.00	Lost	0.5	1	1	1	0	0	2	3.63%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
117	2023-03-19 17:30:00+02	Volos	Olympiacos	Under	Full Time	2.20	0.00	Lost	2.5	0	0	0	0	2	1	1.61%	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
100	2023-03-18 17:00:00+02	Asteras Tripolis	Panetolikos	Over	Full Time	2.52	0.00	Lost	2.5	2	2	1	1	0	1	2.14%	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
209	2023-04-26 21:00:00+03	AEK	PAOK	Over	Full Time	2.20	0.00	Lost	2.5	4	0	2	2	0	0	2.53%	{}
207	2023-04-26 19:00:00+03	Aris Salonika	Olympiacos	Over	Full Time	2.20	0.00	Lost	2.5	2	2	1	1	0	1	3.47%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145,https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
208	2023-04-26 19:00:00+03	Aris Salonika	Olympiacos	Under	Full Time	1.72	0.00	Lost	2.5	2	2	1	1	0	1	3.47%	{}
155	2023-04-02 19:30:00+03	PAOK	AEK	Over	Full Time	2.55	0.00	Lost	2.5	0	0	0	0	0	1	3.60%	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
156	2023-04-02 19:30:00+03	PAOK	AEK	Under	1st Half	2.45	0.00	Lost	0.5	0	0	0	0	0	1	4.28%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
157	2023-04-02 19:30:00+03	PAOK	AEK	Under	2nd Half	3.25	0.00	Lost	0.5	0	0	0	0	0	1	3.63%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
148	2023-04-02 18:00:00+03	Panathinaikos	Volos	Over	Full Time	1.77	0.00	Lost	2.5	0	0	0	0	0	0	3.95%	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
149	2023-04-02 18:00:00+03	Panathinaikos	Volos	Under	1st Half	3.40	0.05	Lost	0.5	0	0	0	0	0	0	4.92%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
150	2023-04-02 18:00:00+03	Panathinaikos	Volos	Under	1st Half	3.40	0.00	Lost	0.5	0	0	0	0	0	0	4.92%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
151	2023-04-02 18:00:00+03	Panathinaikos	Volos	Under	2nd Half	4.50	0.17	Lost	0.5	0	0	0	0	0	0	5.26%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
152	2023-04-02 18:00:00+03	Panathinaikos	Volos	Under	2nd Half	4.50	0.00	Lost	0.5	0	0	0	0	0	0	5.26%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
143	2023-04-01 21:00:00+03	Ionikos	Asteras Tripolis	Over	Full Time	2.75	0.05	Lost	2.5	1	0	1	0	0	0	2.94%	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
144	2023-04-01 21:00:00+03	Ionikos	Asteras Tripolis	Over	Full Time	2.75	0.00	Lost	2.5	1	0	1	0	0	0	2.94%	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
145	2023-04-01 21:00:00+03	Ionikos	Asteras Tripolis	Under	1st Half	2.26	0.00	Lost	0.5	1	0	1	0	0	0	6.32%	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
146	2023-04-01 21:00:00+03	Ionikos	Asteras Tripolis	Under	2nd Half	3.00	0.00	Lost	0.5	1	0	1	0	0	0	5.95%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107,https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
140	2023-04-01 19:30:00+03	PAS Giannina	OFI	Over	Full Time	2.55	0.00	Lost	2.5	0	0	0	0	1	0	3.60%	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
141	2023-04-01 19:30:00+03	PAS Giannina	OFI	Under	1st Half	2.39	0.00	Lost	0.5	0	0	0	0	1	0	5.21%	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
142	2023-04-01 19:30:00+03	PAS Giannina	OFI	Under	2nd Half	3.25	0.00	Lost	0.5	0	0	0	0	1	0	5.12%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
210	2023-04-26 21:00:00+03	AEK	PAOK	Under	Full Time	1.75	0.00	Lost	2.5	4	0	2	2	0	0	2.53%	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/,https://www.bet365.gr/olp/open-account?affiliate=365_01012107,https://record.affiliates.betshop.gr/_xVrm1kU5pcRLcRLGwHoTKWNd7ZgqdRLk/1/}
204	2023-04-26 18:00:00+03	Volos	Panathinaikos	Over	Full Time	1.79	0.00	Lost	2.5	0	0	0	0	0	2	2.12%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
205	2023-04-26 18:00:00+03	Volos	Panathinaikos	Under	Full Time	2.16	0.06	Lost	2.5	0	0	0	0	0	2	2.12%	{https://record.affiliates.betshop.gr/_xVrm1kU5pcRLcRLGwHoTKWNd7ZgqdRLk/1/}
206	2023-04-26 18:00:00+03	Volos	Panathinaikos	Under	Full Time	2.16	0.00	Lost	2.5	0	0	0	0	0	2	2.12%	{https://record.affiliates.betshop.gr/_xVrm1kU5pcRLcRLGwHoTKWNd7ZgqdRLk/1/}
158	2023-04-02 21:00:00+03	Olympiacos	Aris Salonika	Over	Full Time	2.20	0.00	Lost	2.5	2	2	1	1	0	2	3.47%	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
159	2023-04-02 21:00:00+03	Olympiacos	Aris Salonika	Under	1st Half	2.70	0.00	Lost	0.5	2	2	1	1	0	2	5.92%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
160	2023-04-02 21:00:00+03	Olympiacos	Aris Salonika	Under	2nd Half	3.50	0.00	Lost	0.5	2	2	1	1	0	2	5.21%	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
161	2023-04-02 21:00:00+03	Olympiacos	Aris Salonika	Under	Full Time	1.72	0.00	Lost	2.5	2	2	1	1	0	2	3.47%	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
212	2023-04-29 19:15:00+03	Atromitos	OFI	Over	Full Time	2.35	0.00	Lost	2.5	2	2	2	0	2	1	3.76%	{}
162	2023-04-08 17:00:00+03	Atromitos	PAS Giannina	Over	Full Time	2.50	0.00	Lost	2.5	1	1	1	0	1	0	3.56%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107,https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/,https://record.affiliates.betshop.gr/_xVrm1kU5pcRLcRLGwHoTKWNd7ZgqdRLk/1/}
99	2023-03-06 19:30:00+02	Panathinaikos	Panetolikos	Under	Full Time	1.81	0.00	Lost	2.5	2	0	0	2	0	0	4.32%	{https://record.affiliates.betshop.gr/_xVrm1kU5pcRLcRLGwHoTKWNd7ZgqdRLk/1/}
85	2023-03-05 19:30:00+02	OFI	AEK	Under	1st Half	2.95	0.00	Lost	0.5	0	0	0	0	1	2	3.23%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
87	2023-03-05 19:30:00+02	OFI	AEK	Under	Full Time	1.93	0.00	Lost	2.5	0	0	0	0	1	2	1.78%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
211	2023-04-29 19:15:00+03	Asteras Tripolis	Lamia	Over	Full Time	2.65	0.00	Lost	2.5	0	0	0	0	0	0	3.81%	{https://record.affiliates.betshop.gr/_xVrm1kU5pcRLcRLGwHoTKWNd7ZgqdRLk/1/}
213	2023-04-29 19:15:00+03	Ionikos	PAS Giannina	Over	Full Time	2.49	0.00	Lost	2.5	0	0	0	0	0	1	2.59%	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/,https://record.affiliates.betshop.gr/_xVrm1kU5pcRLcRLGwHoTKWNd7ZgqdRLk/1/}
214	2023-04-29 19:15:00+03	Panetolikos	Levadiakos	Over	Full Time	2.55	0.00	Lost	2.5	2	2	0	2	2	0	4.38%	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
153	2023-04-02 18:00:00+03	Panathinaikos	Volos	Under	Full Time	2.10	0.00	Lost	2.5	0	0	0	0	0	0	3.95%	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
163	2023-04-10 14:45:00+03	Anagennisi Karditsas	PAOK B	Over	2nd Half	2.24	0.00	Lost	1.5	\N	\N	\N	\N	\N	\N	7.01%	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
164	2023-04-10 14:45:00+03	Anagennisi Karditsas	PAOK B	Over	Full Time	2.05	0.00	Lost	2.5	\N	\N	\N	\N	\N	\N	5.88%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436,https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
165	2023-04-10 14:45:00+03	Anagennisi Karditsas	PAOK B	Under	1st Half	2.60	0.00	Lost	0.5	\N	\N	\N	\N	\N	\N	6.91%	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
74	2023-03-05 16:00:00+02	Olympiacos	Levadiakos	Under	1st Half	3.60	0.00	Lost	0.5	6	6	2	4	0	0	2.88%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
75	2023-03-05 16:00:00+02	Olympiacos	Levadiakos	Under	2nd Half	4.75	0.00	Lost	0.5	6	6	2	4	0	0	4.20%	{http://www.sportingbet.gr/,https://sports.bwin.gr/el/sports?wm=5273373}
76	2023-03-05 16:00:00+02	Olympiacos	Levadiakos	Under	Full Time	2.30	0.00	Lost	2.5	6	6	2	4	0	0	3.92%	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
147	2023-04-01 21:00:00+03	Ionikos	Asteras Tripolis	Under	2nd Half	3.00	0.00	Lost	0.5	1	0	1	0	0	0	5.95%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107,https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
166	2023-04-10 14:45:00+03	Anagennisi Karditsas	PAOK B	Under	Full Time	1.74	0.00	Lost	2.5	\N	\N	\N	\N	\N	\N	5.88%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
167	2023-04-10 14:45:00+03	Apollon Pontou	Niki Volou	Over	2nd Half	2.50	0.00	Lost	1.5	\N	\N	\N	\N	\N	\N	7.43%	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
168	2023-04-10 14:45:00+03	Apollon Pontou	Niki Volou	Over	Full Time	2.40	0.00	Lost	2.5	\N	\N	\N	\N	\N	\N	6.56%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145,https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
169	2023-04-10 14:45:00+03	Apollon Pontou	Niki Volou	Under	1st Half	2.36	0.00	Lost	0.5	\N	\N	\N	\N	\N	\N	6.81%	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
170	2023-04-10 14:45:00+03	Panathinaikos B	Iraklis	Over	2nd Half	2.45	0.00	Lost	1.5	\N	\N	\N	\N	\N	\N	7.35%	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
171	2023-04-10 14:45:00+03	Panathinaikos B	Iraklis	Over	Full Time	2.31	0.00	Lost	2.5	\N	\N	\N	\N	\N	\N	1.08%	{https://record.affiliates.betshop.gr/_xVrm1kU5pcRLcRLGwHoTKWNd7ZgqdRLk/1/,http://www.sportingbet.gr/,https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
172	2023-04-10 14:45:00+03	Panathinaikos B	Iraklis	Under	1st Half	2.40	0.00	Lost	0.5	\N	\N	\N	\N	\N	\N	7.69%	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
173	2023-04-10 14:45:00+03	Panathinaikos B	Iraklis	Under	Full Time	1.73	0.00	Lost	2.5	\N	\N	\N	\N	\N	\N	1.08%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
174	2023-04-10 14:45:00+03	PAO Rouf	AEK B	Over	2nd Half	2.13	0.00	Lost	1.5	\N	\N	\N	\N	\N	\N	7.02%	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
175	2023-04-10 14:45:00+03	PAO Rouf	AEK B	Over	Full Time	2.00	0.00	Lost	2.5	\N	\N	\N	\N	\N	\N	5.26%	{}
176	2023-04-10 14:45:00+03	PAO Rouf	AEK B	Under	1st Half	2.75	0.00	Lost	0.5	\N	\N	\N	\N	\N	\N	7.23%	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
154	2023-04-02 18:00:00+03	Panathinaikos	Volos	Under	Full Time	2.10	0.00	Lost	2.5	0	0	0	0	0	0	3.95%	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
139	2023-04-01 17:30:00+03	Panetolikos	Lamia	Under	2nd Half	3.25	0.00	Lost	0.5	1	1	0	1	0	3	4.62%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
128	2023-04-01 17:00:00+03	Levadiakos	Atromitos	Over	Full Time	2.70	0.00	Lost	2.5	1	1	0	1	0	1	3.57%	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
129	2023-04-01 17:00:00+03	Levadiakos	Atromitos	Under	1st Half	2.35	0.00	Lost	0.5	1	1	0	1	0	1	5.84%	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
130	2023-04-01 17:00:00+03	Levadiakos	Atromitos	Under	1st Half	2.35	0.00	Lost	0.5	1	1	0	1	0	1	5.84%	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
177	2023-04-10 14:45:00+03	PAO Rouf	AEK B	Under	Full Time	1.80	0.00	Lost	2.5	\N	\N	\N	\N	\N	\N	5.26%	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
178	2023-04-10 15:15:00+03	Kallithea	Kifisia	Over	2nd Half	2.70	0.00	Lost	1.5	\N	\N	\N	\N	\N	\N	7.37%	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
179	2023-04-10 15:15:00+03	Kallithea	Kifisia	Over	Full Time	2.60	0.00	Lost	2.5	\N	\N	\N	\N	\N	\N	4.48%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
180	2023-04-10 15:15:00+03	Kallithea	Kifisia	Under	1st Half	2.26	0.00	Lost	0.5	\N	\N	\N	\N	\N	\N	7.01%	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
131	2023-04-01 17:00:00+03	Levadiakos	Atromitos	Under	2nd Half	3.00	0.00	Lost	0.5	1	1	0	1	0	1	6.28%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
132	2023-04-01 17:00:00+03	Levadiakos	Atromitos	Under	2nd Half	3.00	0.00	Lost	0.5	1	1	0	1	0	1	6.28%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
133	2023-04-01 17:00:00+03	Levadiakos	Atromitos	Under	2nd Half	3.00	0.00	Lost	0.5	1	1	0	1	0	1	6.28%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
134	2023-04-01 17:00:00+03	Levadiakos	Atromitos	Under	2nd Half	3.00	0.00	Lost	0.5	1	1	0	1	0	1	6.28%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
\.


--
-- TOC entry 3109 (class 0 OID 33416)
-- Dependencies: 213
-- Data for Name: soccer_statistics; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.soccer_statistics (id, home_team, guest_team, date_time, goals_home, goals_guest, full_time_home_win_odds, full_time_draw_odds, full_time_guest_win_odds, first_half_home_win_odds, first_half_draw_odds, second_half_goals_guest, second_half_goals_home, first_half_goals_guest, first_half_goals_home, first_half_guest_win_odds, second_half_home_win_odds, second_half_draw_odds, second_half_guest_win_odds, full_time_over_under_goals, full_time_over_odds, full_time_under_odds, first_half_over_under_goals, first_half_over_odds, first_half_under_odds, second_half_over_under_goals, second_half_over_odds, second_half_under_odds, url, last_updated) FROM stdin;
21	Panathinaikos	AEK Athens FC	2023-04-30 20:00:00+03	0	0	2.8	3.1	3	3.5	1.95	0	0	0	0	3.6	3.3	2.2	3.1	{0.5,1.5,2.0,2.5,3.5,4.5,5.5,6.5}	{1.11,1.53,1.88,2.62,5.0,11.0,26.0,46.0}	{7.0,2.63,1.98,1.5,1.17,1.05,1.01,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.57,1.82,3.75,11.0,29.0,71.0}	{2.38,1.98,1.25,1.05,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.4,2.75,6.5,19.0}	{3.25,1.44,1.11,1.02}	https://www.oddsportal.com/football/greece/super-league/panathinaikos-aek-QobPeHm1/#1X2;2	2023-05-05 06:31:45.368083+03
1	AEK Athens FC	Olympiacos Piraeus	2023-05-03 20:00:00+03	0	0	1.63	4.0	6	2.2	2.25	0	0	0	0	5.75	1.95	2.6	5.5	{0.5,1.5,2.5,3.5,4.5,5.5,6.5}	{1.06,1.33,1.95,3.4,6.75,15.0,29.0}	{11.0,3.6,1.9,1.3,1.11,1.03,1.01}	{0.5,1.0,1.5,2.5,3.5,4.5}	{1.4,1.88,2.85,8.0,21.0,51.0}	{2.95,1.93,1.4,1.08,1.02,1.0}	{0.5,1.5,2.5,3.5,4.5}	{1.29,2.2,4.5,13.0}	{4.0,1.67,1.18,1.04}	https://www.oddsportal.com/football/greece/super-league/aek-olympiacos-piraeus-YB1XgeID/#1X2;2	2023-05-05 05:33:56.865312+03
2	Aris	Volos	2023-05-03 20:00:00+03	4	2	1.22	7.0	17	1.61	2.75	2	2	0	2	12.0	1.47	3.4	11.0	{0.5,1.5,2.5,2.75,3.0,3.5,4.5,5.5,6.5,7.5}	{1.03,1.2,1.68,1.8,2.05,2.85,5.4,10.0,19.0}	{15.0,4.5,2.25,2.05,1.8,1.5,1.2,1.07,1.02}	{0.5,1.0,1.25,1.5,2.5,3.5,4.5}	{1.33,2.02,2.48,5.5,15.0,36.0}	{3.5,1.77,1.53,1.14,1.03,1.01}	{0.5,1.5,2.5,3.5,4.5}	{1.22,2.0,3.75,9.0,21.0}	{5.0,1.9,1.27,1.07,1.02}	https://www.oddsportal.com/football/greece/super-league/aris-volos-xpSD2mMD/#1X2;2	2023-05-05 05:34:07.289333+03
3	Panathinaikos	PAOK	2023-05-03 20:00:00+03	1	1	1.75	3.4	5	2.5	2.0	1	0	0	1	6.0	2.2	2.3	5.5	{0.5,1.5,2.0,2.5,3.5,4.5,5.5,6.5}	{1.1,1.5,1.77,2.55,5.2,12.0,21.0,41.0}	{8.0,2.63,2.1,1.57,1.2,1.06,1.02,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.53,1.75,3.65,11.0,26.0,67.0}	{2.43,2.05,1.29,1.05,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.7,6.5,19.0}	{3.25,1.5,1.11,1.02}	https://www.oddsportal.com/football/greece/super-league/panathinaikos-paok-jmWH17yK/#1X2;2	2023-05-05 05:34:17.843874+03
22	PAOK	Aris	2023-04-30 20:00:00+03	3	2	1.7	3.6	5	2.3	2.2	1	3	1	0	5.5	2.05	2.5	5.0	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.07,1.36,1.8,2.1,3.5,8.0,17.0,34.0}	{10.0,3.4,2.05,1.75,1.29,1.1,1.02,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.44,2.0,3.0,9.0,23.0,56.0}	{2.75,1.8,1.36,1.07,1.02,1.0}	{0.5,1.5,2.5,3.5}	{1.3,2.3,5.0,13.0}	{3.75,1.62,1.17,1.04}	https://www.oddsportal.com/football/greece/super-league/paok-aris-fL2Tfy37/#1X2;2	2023-05-05 06:32:03.510135+03
20	Olympiacos Piraeus	Volos	2023-04-30 20:00:00+03	5	0	1.09	10.5	29	1.36	3.5	0	2	0	3	17.0	1.24	4.4	17.0	{0.5,1.5,2.5,3.0,3.25,3.5,4.5,5.5,6.5,7.5,8.5}	{1.02,1.11,1.36,1.91,3.0,5.0,10.0,19.0,34.0}	{23.0,7.0,3.4,1.87,1.39,1.17,1.06,1.02,1.0}	{0.5,1.25,1.5,2.5,3.5,4.5}	{1.2,1.95,4.0,10.0,26.0}	{4.33,1.85,1.25,1.06,1.02}	{0.5,1.5,2.5,3.5,4.5}	{1.15,1.67,3.0,6.0,15.0}	{6.5,2.3,1.43,1.14,1.03}	https://www.oddsportal.com/football/greece/super-league/olympiacos-piraeus-volos-neaLdcYf/#1X2;2	2023-05-05 06:31:26.333492+03
29	Asteras Tripolis	Lamia	2023-04-29 19:15:00+03	0	0	2.3	2.95	4	3.1	1.91	0	0	0	0	4.33	2.75	2.2	3.75	{0.5,1.5,2.0,2.5,3.5,4.5,5.5,6.5}	{1.11,1.53,2.0,2.62,5.5,13.0,26.0,46.0}	{6.5,2.5,1.85,1.48,1.15,1.04,1.01,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.57,1.88,3.75,13.0,31.0,71.0}	{2.3,1.93,1.29,1.05,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.4,2.65,7.0,19.0}	{3.0,1.44,1.1,1.02}	https://www.oddsportal.com/football/greece/super-league/asteras-tripolis-lamia-8Q768Fl4/#1X2;2	2023-05-05 06:39:01.453761+03
30	Atromitos	OFI Crete	2023-04-29 19:15:00+03	2	3	2.2	3.4	3	2.88	2.2	1	0	2	2	3.6	2.6	2.5	3.3	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.05,1.29,1.86,3.0,6.0,13.0,26.0}	{11.0,3.75,2.0,1.36,1.13,1.04,1.01}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.37,1.8,2.75,7.0,21.0,46.0}	{3.0,2.0,1.43,1.11,1.02,1.01}	{0.5,1.5,2.5,3.5,4.5}	{1.25,2.05,4.33,11.0,26.0}	{4.0,1.73,1.2,1.05,1.01}	https://www.oddsportal.com/football/greece/super-league/atromitos-ofi-crete-jkcB7Z3A/#1X2;2	2023-05-05 06:39:20.198344+03
31	Ionikos	Giannina	2023-04-29 19:15:00+03	0	1	2.1	3.25	4	2.88	1.95	1	0	0	0	4.6	2.62	2.2	4.0	{0.5,1.5,2.0,2.5,3.5,4.5,5.5,6.5}	{1.11,1.5,1.93,2.5,5.0,11.0,26.0,41.0}	{7.0,2.5,1.93,1.53,1.17,1.05,1.02,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.53,1.82,3.75,11.0,29.0,71.0}	{2.38,1.98,1.29,1.05,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.63,6.5,19.0}	{3.25,1.44,1.11,1.02}	https://www.oddsportal.com/football/greece/super-league/ionikos-giannina-4h1F6gJG/#1X2;2	2023-05-05 06:39:38.482433+03
32	Panetolikos	Levadiakos	2023-04-29 19:15:00+03	2	2	2.8	2.85	3	3.6	1.85	0	2	2	0	3.75	3.1	2.1	3.25	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.13,1.57,2.13,2.88,6.0,15.0,26.0,51.0}	{6.0,2.38,1.75,1.45,1.14,1.04,1.01,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.62,1.95,4.0,13.0,31.0,81.0}	{2.38,1.85,1.29,1.04,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.4,2.8,8.0,21.0}	{2.75,1.44,1.1,1.02}	https://www.oddsportal.com/football/greece/super-league/panetolikos-levadiakos-bF0J5DYM/#1X2;2	2023-05-05 06:39:56.10328+03
33	AEK Athens FC	PAOK	2023-04-26 21:00:00+03	4	0	1.53	4.2	7	2.1	2.25	0	2	0	2	6.5	1.85	2.6	6.1	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.06,1.33,2.06,3.85,8.0,15.0,29.0}	{11.0,3.5,1.85,1.3,1.1,1.03,1.01}	{0.5,1.0,1.5,2.5,3.5,4.5}	{1.44,1.93,3.05,8.0,23.0,51.0}	{2.85,1.88,1.4,1.08,1.02,1.0}	{0.5,1.5,2.5,3.5}	{1.3,2.3,4.75,13.0}	{3.75,1.67,1.18,1.04}	https://www.oddsportal.com/football/greece/super-league/aek-paok-zHJp3aeR/#1X2;2	2023-05-05 06:40:13.536462+03
34	Aris	Olympiacos Piraeus	2023-04-26 19:00:00+03	2	1	3.25	3.3	2	3.95	2.1	1	1	0	1	3.1	3.65	2.38	2.7	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.07,1.36,1.88,2.23,4.25,9.0,17.0,34.0}	{9.0,3.25,1.98,1.73,1.29,1.1,1.02,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.44,2.08,3.3,9.0,26.0,56.0}	{2.75,1.73,1.36,1.08,1.02,1.0}	{0.5,1.5,2.5,3.5}	{1.3,2.4,5.0,13.0}	{3.75,1.62,1.17,1.04}	https://www.oddsportal.com/football/greece/super-league/aris-olympiacos-piraeus-hd6CbJ3r/#1X2;2	2023-05-05 06:40:31.690173+03
35	Volos	Panathinaikos	2023-04-26 18:00:00+03	0	2	13.0	5.75	1	11.0	2.6	2	0	0	0	1.8	10.5	3.0	1.57	{0.5,1.5,2.25,2.5,2.75,3.5,4.5,5.5,6.5,7.5}	{1.06,1.33,1.82,2.05,3.75,8.0,17.0,34.0}	{11.5,3.5,2.02,1.81,1.29,1.1,1.03,1.0}	{0.5,1.0,1.25,1.5,2.5,3.5,4.5}	{1.4,2.0,3.0,8.0,23.0,51.0}	{3.05,1.8,1.4,1.1,1.02,1.0}	{0.5,1.5,2.5,3.5,4.5}	{1.33,2.3,5.0,13.0}	{3.75,1.62,1.17,1.04}	https://www.oddsportal.com/football/greece/super-league/volos-panathinaikos-4W9GcwJl/#1X2;2	2023-05-05 06:40:49.270427+03
36	Olympiacos Piraeus	AEK Athens FC	2023-04-23 21:00:00+03	1	3	2.4	3.25	3	3.1	2.05	2	1	1	0	3.6	2.75	2.38	3.3	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.07,1.36,1.88,2.1,3.75,8.0,19.0,41.0}	{10.0,3.25,1.98,1.73,1.25,1.08,1.02,1.0}	{0.5,1.0,1.5,2.5,3.5,4.5}	{1.44,2.08,3.25,10.0,26.0,56.0}	{2.75,1.73,1.36,1.07,1.02,1.0}	{0.5,1.5,2.5,3.5}	{1.3,2.25,5.5,15.0}	{3.5,1.62,1.15,1.03}	https://www.oddsportal.com/football/greece/super-league/olympiacos-piraeus-aek-vkQy5LQE/#1X2;2	2023-05-05 06:41:07.340895+03
37	PAOK	Panathinaikos	2023-04-23 20:00:00+03	1	2	2.21	3.1	4	3.0	1.91	1	1	1	0	4.33	2.7	2.2	3.8	{0.5,1.5,2.0,2.5,3.5,4.5,5.5,6.5}	{1.12,1.53,2.02,2.7,5.5,13.0,26.0,46.0}	{6.5,2.38,1.82,1.46,1.15,1.04,1.01,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.57,1.9,3.75,13.0,31.0,81.0}	{2.38,1.9,1.29,1.04,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.4,2.75,7.0,21.0}	{3.0,1.44,1.1,1.02}	https://www.oddsportal.com/football/greece/super-league/paok-panathinaikos-dQKt4utL/#1X2;2	2023-05-05 06:41:24.236703+03
38	Volos	Aris	2023-04-23 17:30:00+03	0	3	5.25	3.75	2	5.5	2.2	2	0	1	0	2.4	4.75	2.5	2.1	{0.5,1.5,2.25,2.5,3.5,4.5,5.5,6.5}	{1.07,1.36,1.8,2.05,3.5,8.0,17.0,34.0}	{9.5,3.25,2.05,1.75,1.29,1.09,1.02,1.0}	{0.5,1.0,1.5,2.5,3.5,4.5}	{1.42,2.0,3.0,9.0,23.0,56.0}	{2.75,1.8,1.4,1.07,1.02,1.0}	{0.5,1.5,2.5,3.5}	{1.3,2.25,5.0,13.0}	{3.75,1.62,1.17,1.04}	https://www.oddsportal.com/football/greece/super-league/volos-aris-0bRX51B8/#1X2;2	2023-05-05 06:41:41.617138+03
39	Giannina	Panetolikos	2023-04-22 19:15:00+03	3	2	1.8	3.3	6	2.6	2.0	1	2	1	1	5.5	2.25	2.3	5.5	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.1,1.44,1.8,2.4,4.5,11.0,23.0,36.0}	{7.0,2.63,2.05,1.55,1.2,1.06,1.02,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.53,1.75,3.5,11.0,29.0,71.0}	{2.5,2.05,1.33,1.05,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.5,6.0,17.0}	{3.25,1.5,1.13,1.02}	https://www.oddsportal.com/football/greece/super-league/giannina-panetolikos-M99bAyKi/#1X2;2	2023-05-05 06:41:58.564517+03
40	Lamia	Atromitos	2023-04-22 19:15:00+03	1	0	1.9	3.5	5	2.75	2.05	0	1	0	0	5.5	2.4	2.3	4.5	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.1,1.44,2.05,2.3,4.33,10.0,21.0,36.0}	{8.0,2.75,1.8,1.6,1.2,1.06,1.02,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.5,1.73,3.4,10.0,26.0,67.0}	{2.5,2.08,1.3,1.06,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.5,6.0,17.0}	{3.4,1.5,1.13,1.02}	https://www.oddsportal.com/football/greece/super-league/lamia-atromitos-UZ829eZc/#1X2;2	2023-05-05 06:42:15.52244+03
41	Levadiakos	Ionikos	2023-04-22 19:15:00+03	2	2	2.3	3.1	4	3.1	1.91	1	2	1	0	4.5	2.8	2.1	3.9	{0.5,1.5,1.75,2.0,2.5,3.5,4.5,5.5,6.5}	{1.13,1.62,1.82,2.88,6.0,15.0,34.0,51.0}	{6.0,2.3,2.02,1.48,1.14,1.03,1.01,1.0}	{0.5,0.75,1.5,2.5,3.5,4.5}	{1.62,2.0,4.0,13.0,31.0,81.0}	{2.3,1.8,1.25,1.04,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.44,2.8,8.0,21.0}	{2.75,1.4,1.1,1.02}	https://www.oddsportal.com/football/greece/super-league/levadiakos-ionikos-tEWBnYRp/#1X2;2	2023-05-05 06:42:32.034007+03
42	OFI Crete	Asteras Tripolis	2023-04-22 19:15:00+03	1	1	1.95	3.5	4	2.7	2.05	0	0	1	1	4.75	2.5	2.35	4.33	{0.5,1.5,2.0,2.25,2.5,3.5,4.5,5.5,6.5}	{1.08,1.44,1.95,2.25,4.0,9.0,19.0,41.0}	{9.0,3.0,1.9,1.67,1.23,1.07,1.02,1.0}	{0.5,0.75,1.0,1.5,2.5,3.5,4.5}	{1.5,2.1,3.4,10.0,26.0,61.0}	{2.5,1.7,1.3,1.06,1.01,1.0}	{0.5,1.5,2.5,3.5}	{1.36,2.38,6.0,17.0}	{3.4,1.55,1.14,1.02}	https://www.oddsportal.com/football/greece/super-league/ofi-crete-asteras-tripolis-rJAfBH4o/#1X2;2	2023-05-05 06:42:48.820985+03
\.


--
-- TOC entry 3129 (class 0 OID 0)
-- Dependencies: 208
-- Name: 1x2_oddsportal_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."1x2_oddsportal_id_seq"', 1, false);


--
-- TOC entry 3130 (class 0 OID 0)
-- Dependencies: 201
-- Name: Match_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."Match_id_seq"', 1710, true);


--
-- TOC entry 3131 (class 0 OID 0)
-- Dependencies: 210
-- Name: OverUnderHistorical_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."OverUnderHistorical_id_seq"', 217, true);


--
-- TOC entry 3132 (class 0 OID 0)
-- Dependencies: 203
-- Name: OverUnder_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."OverUnder_id_seq"', 16985, true);


--
-- TOC entry 3133 (class 0 OID 0)
-- Dependencies: 212
-- Name: soccer_statistics_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.soccer_statistics_id_seq', 42, true);


--
-- TOC entry 2953 (class 2606 OID 25112)
-- Name: 1x2_oddsportal 1x2_oddsportal_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."1x2_oddsportal"
    ADD CONSTRAINT "1x2_oddsportal_pkey" PRIMARY KEY (id);


--
-- TOC entry 2955 (class 2606 OID 25114)
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
-- TOC entry 2957 (class 2606 OID 25143)
-- Name: OverUnderHistorical OverUnderHistorical_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OverUnderHistorical"
    ADD CONSTRAINT "OverUnderHistorical_pkey" PRIMARY KEY (id);


--
-- TOC entry 2959 (class 2606 OID 33425)
-- Name: soccer_statistics soccer_statistics_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.soccer_statistics
    ADD CONSTRAINT soccer_statistics_pkey PRIMARY KEY (id);


--
-- TOC entry 2961 (class 2606 OID 33427)
-- Name: soccer_statistics soccer_statistics_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.soccer_statistics
    ADD CONSTRAINT soccer_statistics_unique UNIQUE (home_team, guest_team, date_time);


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
-- TOC entry 2964 (class 2620 OID 24783)
-- Name: OddsPortalOverUnder update_updated_Match_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER "update_updated_Match_trigger" AFTER UPDATE ON public."OddsPortalOverUnder" FOR EACH ROW EXECUTE FUNCTION public."update_updated_on_Match"();


--
-- TOC entry 2965 (class 2620 OID 24782)
-- Name: OddsPortalOverUnder update_updated_OverUnder_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER "update_updated_OverUnder_trigger" AFTER UPDATE ON public."OddsPortalOverUnder" FOR EACH ROW EXECUTE FUNCTION public."update_updated_on_OverUnder"();


--
-- TOC entry 2962 (class 2606 OID 24990)
-- Name: OddsPortalOverUnder OddsPortalOverUnder_Match_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsPortalOverUnder"
    ADD CONSTRAINT "OddsPortalOverUnder_Match_fk" FOREIGN KEY (match_id) REFERENCES public."OddsPortalMatch"(id) ON UPDATE CASCADE ON DELETE CASCADE NOT VALID;


--
-- TOC entry 2963 (class 2606 OID 24985)
-- Name: OddsSafariOverUnder OddsSafariOverUnder_Match_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsSafariOverUnder"
    ADD CONSTRAINT "OddsSafariOverUnder_Match_fk" FOREIGN KEY (match_id) REFERENCES public."OddsSafariMatch"(id) ON UPDATE CASCADE ON DELETE CASCADE NOT VALID;


--
-- TOC entry 3117 (class 0 OID 0)
-- Dependencies: 209
-- Name: TABLE "1x2_oddsportal"; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE public."1x2_oddsportal" FROM postgres;
GRANT ALL ON TABLE public."1x2_oddsportal" TO postgres WITH GRANT OPTION;


--
-- TOC entry 3119 (class 0 OID 0)
-- Dependencies: 200
-- Name: TABLE "OddsPortalMatch"; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE public."OddsPortalMatch" FROM postgres;


--
-- TOC entry 3121 (class 0 OID 0)
-- Dependencies: 202
-- Name: TABLE "OddsPortalOverUnder"; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE public."OddsPortalOverUnder" FROM postgres;
GRANT ALL ON TABLE public."OddsPortalOverUnder" TO postgres WITH GRANT OPTION;


--
-- TOC entry 3122 (class 0 OID 0)
-- Dependencies: 204
-- Name: TABLE "OddsSafariMatch"; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE public."OddsSafariMatch" FROM postgres;
GRANT ALL ON TABLE public."OddsSafariMatch" TO postgres WITH GRANT OPTION;


--
-- TOC entry 3123 (class 0 OID 0)
-- Dependencies: 205
-- Name: TABLE "OddsSafariOverUnder"; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE public."OddsSafariOverUnder" FROM postgres;
GRANT ALL ON TABLE public."OddsSafariOverUnder" TO postgres WITH GRANT OPTION;


--
-- TOC entry 3124 (class 0 OID 0)
-- Dependencies: 211
-- Name: TABLE "OverUnderHistorical"; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE public."OverUnderHistorical" FROM postgres;
GRANT ALL ON TABLE public."OverUnderHistorical" TO postgres WITH GRANT OPTION;


--
-- TOC entry 3125 (class 0 OID 0)
-- Dependencies: 206
-- Name: TABLE "PortalSafariMatch"; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE public."PortalSafariMatch" FROM postgres;
GRANT ALL ON TABLE public."PortalSafariMatch" TO postgres WITH GRANT OPTION;


--
-- TOC entry 3126 (class 0 OID 0)
-- Dependencies: 207
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
-- TOC entry 1771 (class 826 OID 24717)
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: -; Owner: -
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres REVOKE ALL ON TABLES  FROM postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres GRANT ALL ON TABLES  TO postgres WITH GRANT OPTION;


-- Completed on 2023-05-05 12:27:51 EEST

--
-- PostgreSQL database dump complete
--


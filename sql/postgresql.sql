--
-- PostgreSQL database dump
--

-- Dumped from database version 13.9 (Debian 13.9-0+deb11u1)
-- Dumped by pg_dump version 13.9 (Debian 13.9-0+deb11u1)

-- Started on 2023-03-30 03:46:35 EEST

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
-- TOC entry 2930 (class 2604 OID 25150)
-- Name: 1x2_oddsportal id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."1x2_oddsportal" ALTER COLUMN id SET DEFAULT nextval('public."1x2_oddsportal_id_seq"'::regclass);


--
-- TOC entry 2916 (class 2604 OID 25151)
-- Name: OddsPortalMatch id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsPortalMatch" ALTER COLUMN id SET DEFAULT nextval('public."Match_id_seq"'::regclass);


--
-- TOC entry 2920 (class 2604 OID 25152)
-- Name: OddsSafariMatch id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsSafariMatch" ALTER COLUMN id SET DEFAULT nextval('public."Match_id_seq"'::regclass);


--
-- TOC entry 2921 (class 2604 OID 25153)
-- Name: OddsSafariMatch created; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsSafariMatch" ALTER COLUMN created SET DEFAULT CURRENT_TIMESTAMP;


--
-- TOC entry 2922 (class 2604 OID 25154)
-- Name: OddsSafariMatch updated; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsSafariMatch" ALTER COLUMN updated SET DEFAULT CURRENT_TIMESTAMP;


--
-- TOC entry 2923 (class 2604 OID 25155)
-- Name: OddsSafariOverUnder id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsSafariOverUnder" ALTER COLUMN id SET DEFAULT nextval('public."OverUnder_id_seq"'::regclass);


--
-- TOC entry 2924 (class 2604 OID 25156)
-- Name: OddsSafariOverUnder created; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsSafariOverUnder" ALTER COLUMN created SET DEFAULT CURRENT_TIMESTAMP;


--
-- TOC entry 2925 (class 2604 OID 25157)
-- Name: OddsSafariOverUnder updated; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OddsSafariOverUnder" ALTER COLUMN updated SET DEFAULT CURRENT_TIMESTAMP;


--
-- TOC entry 2927 (class 2604 OID 25158)
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
1135	Levadiakos	Atromitos	2023-04-01 17:00:00+03	2023-03-22 07:11:30.883083	2023-03-22 07:11:30.883083
1144	Panetolikos	Lamia	2023-04-01 17:30:00+03	2023-03-22 07:19:37.794791	2023-03-22 07:19:37.794791
1147	Giannina	OFI Crete	2023-04-01 19:30:00+03	2023-03-22 07:19:53.389985	2023-03-22 07:19:53.389985
1159	Ionikos	Asteras Tripolis	2023-04-01 21:00:00+03	2023-03-22 07:25:32.057301	2023-03-22 07:25:32.057301
1162	Panathinaikos	Volos	2023-04-02 18:00:00+03	2023-03-22 07:25:48.510105	2023-03-22 07:25:48.510105
1165	PAOK	AEK Athens FC	2023-04-02 19:30:00+03	2023-03-22 07:26:05.894519	2023-03-22 07:26:05.894519
1168	Olympiacos Piraeus	Aris	2023-04-02 21:00:00+03	2023-03-22 07:26:22.48866	2023-03-22 07:26:22.48866
\.


--
-- TOC entry 3098 (class 0 OID 24726)
-- Dependencies: 202
-- Data for Name: OddsPortalOverUnder; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."OddsPortalOverUnder" (id, goals, odds, match_id, half, payout, created, updated, type, bet_links) FROM stdin;
10852	1.5	2.63	1144	Full Time	96.7%	2023-03-22 07:19:39.712061	2023-03-22 07:19:39.712061	Under	{}
10746	4.5	1.04	1135	Full Time	96.3%	2023-03-22 07:11:32.908166	2023-03-22 07:11:32.908166	Under	{}
10747	5.5	29.00	1135	Full Time	97.6%	2023-03-22 07:11:32.909933	2023-03-22 07:11:32.909933	Over	{}
10748	5.5	1.01	1135	Full Time	97.6%	2023-03-22 07:11:32.911569	2023-03-22 07:11:32.911569	Under	{}
10805	0.5	1.57	1135	1st Half	94.9%	2023-03-22 07:17:25.262429	2023-03-22 07:17:25.262429	Over	{}
10806	0.5	2.40	1135	1st Half	94.9%	2023-03-22 07:17:26.752093	2023-03-22 07:17:26.752093	Under	{}
10807	0.75	1.90	1135	1st Half	96.2%	2023-03-22 07:17:26.75432	2023-03-22 07:17:26.75432	Over	{}
10808	0.75	1.95	1135	1st Half	96.2%	2023-03-22 07:17:26.756644	2023-03-22 07:17:26.756644	Under	{}
10809	1.5	3.85	1135	1st Half	96.6%	2023-03-22 07:17:26.75797	2023-03-22 07:17:26.75797	Over	{}
10810	1.5	1.29	1135	1st Half	96.6%	2023-03-22 07:17:26.759965	2023-03-22 07:17:26.759965	Under	{}
10811	2.5	13.00	1135	1st Half	97.2%	2023-03-22 07:17:26.761132	2023-03-22 07:17:26.761132	Over	{}
10812	2.5	1.05	1135	1st Half	97.2%	2023-03-22 07:17:26.762503	2023-03-22 07:17:26.762503	Under	{}
10813	3.5	31.00	1135	1st Half	97.8%	2023-03-22 07:17:26.763698	2023-03-22 07:17:26.763698	Over	{}
10814	3.5	1.01	1135	1st Half	97.8%	2023-03-22 07:17:26.764839	2023-03-22 07:17:26.764839	Under	{}
10815	4.5	71.00	1135	1st Half	98.6%	2023-03-22 07:17:26.766559	2023-03-22 07:17:26.766559	Over	{}
10841	0.5	1.40	1135	2nd Half	95.5%	2023-03-22 07:19:29.09543	2023-03-22 07:19:29.09543	Over	{}
10842	0.5	3.00	1135	2nd Half	95.5%	2023-03-22 07:19:30.121666	2023-03-22 07:19:30.121666	Under	{}
10843	1.5	2.85	1135	2nd Half	95.7%	2023-03-22 07:19:30.124764	2023-03-22 07:19:30.124764	Over	{}
10845	2.5	7.00	1135	2nd Half	95.1%	2023-03-22 07:19:30.12929	2023-03-22 07:19:30.12929	Over	{}
10846	2.5	1.10	1135	2nd Half	95.1%	2023-03-22 07:19:30.13207	2023-03-22 07:19:30.13207	Under	{}
10847	3.5	21.00	1135	2nd Half	97.3%	2023-03-22 07:19:30.134846	2023-03-22 07:19:30.134846	Over	{}
10848	3.5	1.02	1135	2nd Half	97.3%	2023-03-22 07:19:30.137065	2023-03-22 07:19:30.137065	Under	{}
10849	0.5	1.11	1144	Full Time	97.1%	2023-03-22 07:19:39.704129	2023-03-22 07:19:39.704129	Over	{}
10850	0.5	7.75	1144	Full Time	97.1%	2023-03-22 07:19:39.707307	2023-03-22 07:19:39.707307	Under	{}
10851	1.5	1.53	1144	Full Time	96.7%	2023-03-22 07:19:39.709832	2023-03-22 07:19:39.709832	Over	{}
10745	4.5	13.00	1135	Full Time	96.3%	2023-03-22 07:11:32.906771	2023-03-22 07:11:32.906771	Over	{}
10853	2.0	1.93	1144	Full Time	96.5%	2023-03-22 07:19:39.714404	2023-03-22 07:19:39.714404	Over	{}
10854	2.0	1.93	1144	Full Time	96.5%	2023-03-22 07:19:39.71623	2023-03-22 07:19:39.71623	Under	{}
10855	2.5	2.55	1144	Full Time	95.6%	2023-03-22 07:19:39.71791	2023-03-22 07:19:39.71791	Over	{}
10856	2.5	1.53	1144	Full Time	95.6%	2023-03-22 07:19:39.720234	2023-03-22 07:19:39.720234	Under	{}
10857	3.5	5.10	1144	Full Time	95.2%	2023-03-22 07:19:39.722936	2023-03-22 07:19:39.722936	Over	{}
10858	3.5	1.17	1144	Full Time	95.2%	2023-03-22 07:19:39.725475	2023-03-22 07:19:39.725475	Under	{}
10859	4.5	12.00	1144	Full Time	96.6%	2023-03-22 07:19:39.727584	2023-03-22 07:19:39.727584	Over	{}
10860	4.5	1.05	1144	Full Time	96.6%	2023-03-22 07:19:39.729172	2023-03-22 07:19:39.729172	Under	{}
10861	5.5	26.00	1144	Full Time	97.2%	2023-03-22 07:19:39.731257	2023-03-22 07:19:39.731257	Over	{}
10862	5.5	1.01	1144	Full Time	97.2%	2023-03-22 07:19:39.733474	2023-03-22 07:19:39.733474	Under	{}
10863	0.5	1.57	1144	1st Half	95.7%	2023-03-22 07:19:41.473777	2023-03-22 07:19:41.473777	Over	{}
10864	0.5	2.45	1144	1st Half	95.7%	2023-03-22 07:19:42.574312	2023-03-22 07:19:42.574312	Under	{}
10865	0.75	1.84	1144	1st Half	95.4%	2023-03-22 07:19:42.576203	2023-03-22 07:19:42.576203	Over	{}
10866	0.75	1.98	1144	1st Half	95.4%	2023-03-22 07:19:42.57827	2023-03-22 07:19:42.57827	Under	{}
10867	1.5	3.75	1144	1st Half	96.5%	2023-03-22 07:19:42.580068	2023-03-22 07:19:42.580068	Over	{}
10868	1.5	1.30	1144	1st Half	96.5%	2023-03-22 07:19:42.582408	2023-03-22 07:19:42.582408	Under	{}
10869	2.5	11.00	1144	1st Half	95.9%	2023-03-22 07:19:42.584083	2023-03-22 07:19:42.584083	Over	{}
10870	2.5	1.05	1144	1st Half	95.9%	2023-03-22 07:19:42.586316	2023-03-22 07:19:42.586316	Under	{}
10871	0.5	1.40	1144	2nd Half	97.8%	2023-03-22 07:19:44.384346	2023-03-22 07:19:44.384346	Over	{}
10872	0.5	3.25	1144	2nd Half	97.8%	2023-03-22 07:19:45.413843	2023-03-22 07:19:45.413843	Under	{}
10873	1.5	2.80	1144	2nd Half	95.5%	2023-03-22 07:19:45.414966	2023-03-22 07:19:45.414966	Over	{}
10874	1.5	1.45	1144	2nd Half	95.5%	2023-03-22 07:19:45.416007	2023-03-22 07:19:45.416007	Under	{}
10876	2.5	1.10	1144	2nd Half	95.1%	2023-03-22 07:19:45.418343	2023-03-22 07:19:45.418343	Under	{}
10877	3.5	19.00	1144	2nd Half	96.8%	2023-03-22 07:19:45.419658	2023-03-22 07:19:45.419658	Over	{}
10878	3.5	1.02	1144	2nd Half	96.8%	2023-03-22 07:19:45.421088	2023-03-22 07:19:45.421088	Under	{}
10879	0.5	1.11	1147	Full Time	96.7%	2023-03-22 07:19:55.269219	2023-03-22 07:19:55.269219	Over	{}
10735	0.5	1.11	1135	Full Time	96.7%	2023-03-22 07:11:32.886771	2023-03-22 07:11:32.886771	Over	{}
10736	0.5	7.50	1135	Full Time	96.7%	2023-03-22 07:11:32.89151	2023-03-22 07:11:32.89151	Under	{}
10737	1.5	1.54	1135	Full Time	95.6%	2023-03-22 07:11:32.893506	2023-03-22 07:11:32.893506	Over	{}
10738	1.5	2.52	1135	Full Time	95.6%	2023-03-22 07:11:32.895614	2023-03-22 07:11:32.895614	Under	{}
10739	2.0	2.02	1135	Full Time	96.6%	2023-03-22 07:11:32.897006	2023-03-22 07:11:32.897006	Over	{}
10740	2.0	1.85	1135	Full Time	96.6%	2023-03-22 07:11:32.898787	2023-03-22 07:11:32.898787	Under	{}
10741	2.5	2.65	1135	Full Time	95.8%	2023-03-22 07:11:32.900175	2023-03-22 07:11:32.900175	Over	{}
10742	2.5	1.50	1135	Full Time	95.8%	2023-03-22 07:11:32.901746	2023-03-22 07:11:32.901746	Under	{}
10743	3.5	5.50	1135	Full Time	95.1%	2023-03-22 07:11:32.903606	2023-03-22 07:11:32.903606	Over	{}
10744	3.5	1.15	1135	Full Time	95.1%	2023-03-22 07:11:32.905235	2023-03-22 07:11:32.905235	Under	{}
10890	4.5	1.05	1147	Full Time	96.6%	2023-03-22 07:19:55.284456	2023-03-22 07:19:55.284456	Under	{}
10891	5.5	26.00	1147	Full Time	98.1%	2023-03-22 07:19:55.2858	2023-03-22 07:19:55.2858	Over	{}
10892	5.5	1.02	1147	Full Time	98.1%	2023-03-22 07:19:55.287615	2023-03-22 07:19:55.287615	Under	{}
10893	0.5	1.57	1147	1st Half	96.4%	2023-03-22 07:19:57.025185	2023-03-22 07:19:57.025185	Over	{}
10894	0.5	2.50	1147	1st Half	96.4%	2023-03-22 07:19:58.656079	2023-03-22 07:19:58.656079	Under	{}
10895	0.75	1.83	1147	1st Half	96.2%	2023-03-22 07:19:58.658286	2023-03-22 07:19:58.658286	Over	{}
10896	0.75	2.03	1147	1st Half	96.2%	2023-03-22 07:19:58.660736	2023-03-22 07:19:58.660736	Under	{}
10897	1.5	3.75	1147	1st Half	96.5%	2023-03-22 07:19:58.663151	2023-03-22 07:19:58.663151	Over	{}
10898	1.5	1.30	1147	1st Half	96.5%	2023-03-22 07:19:58.665245	2023-03-22 07:19:58.665245	Under	{}
10899	2.5	11.00	1147	1st Half	95.9%	2023-03-22 07:19:58.667718	2023-03-22 07:19:58.667718	Over	{}
10900	2.5	1.05	1147	1st Half	95.9%	2023-03-22 07:19:58.669681	2023-03-22 07:19:58.669681	Under	{}
10901	3.5	41.00	1147	1st Half	98.6%	2023-03-22 07:19:58.671961	2023-03-22 07:19:58.671961	Over	{}
10902	3.5	1.01	1147	1st Half	98.6%	2023-03-22 07:19:58.673588	2023-03-22 07:19:58.673588	Under	{}
10903	4.5	71.00	1147	1st Half	98.6%	2023-03-22 07:19:58.675357	2023-03-22 07:19:58.675357	Over	{}
10904	0.5	1.40	1147	2nd Half	97.8%	2023-03-22 07:20:04.772563	2023-03-22 07:20:04.772563	Over	{}
10905	0.5	3.25	1147	2nd Half	97.8%	2023-03-22 07:20:05.797373	2023-03-22 07:20:05.797373	Under	{}
10906	1.5	2.75	1147	2nd Half	96.6%	2023-03-22 07:20:05.798521	2023-03-22 07:20:05.798521	Over	{}
10907	1.5	1.49	1147	2nd Half	96.6%	2023-03-22 07:20:05.799676	2023-03-22 07:20:05.799676	Under	{}
10908	2.5	6.50	1147	2nd Half	95.5%	2023-03-22 07:20:05.800722	2023-03-22 07:20:05.800722	Over	{}
10909	2.5	1.12	1147	2nd Half	95.5%	2023-03-22 07:20:05.80174	2023-03-22 07:20:05.80174	Under	{}
10910	3.5	19.00	1147	2nd Half	96.8%	2023-03-22 07:20:05.802969	2023-03-22 07:20:05.802969	Over	{}
10911	3.5	1.02	1147	2nd Half	96.8%	2023-03-22 07:20:05.804239	2023-03-22 07:20:05.804239	Under	{}
11008	0.5	1.13	1159	Full Time	97.3%	2023-03-22 07:25:33.665804	2023-03-22 07:25:33.665804	Over	{}
11009	0.5	7.00	1159	Full Time	97.3%	2023-03-22 07:25:33.668163	2023-03-22 07:25:33.668163	Under	{}
11010	1.5	1.57	1159	Full Time	96.4%	2023-03-22 07:25:33.670353	2023-03-22 07:25:33.670353	Over	{}
11011	1.5	2.50	1159	Full Time	96.4%	2023-03-22 07:25:33.671162	2023-03-22 07:25:33.671162	Under	{}
11012	2.0	2.03	1159	Full Time	96.8%	2023-03-22 07:25:33.672195	2023-03-22 07:25:33.672195	Over	{}
11013	2.0	1.85	1159	Full Time	96.8%	2023-03-22 07:25:33.673179	2023-03-22 07:25:33.673179	Under	{}
11014	2.5	2.70	1159	Full Time	95.6%	2023-03-22 07:25:33.674394	2023-03-22 07:25:33.674394	Over	{}
11015	2.5	1.48	1159	Full Time	95.6%	2023-03-22 07:25:33.675429	2023-03-22 07:25:33.675429	Under	{}
11016	3.5	5.60	1159	Full Time	95.4%	2023-03-22 07:25:33.676421	2023-03-22 07:25:33.676421	Over	{}
11017	3.5	1.15	1159	Full Time	95.4%	2023-03-22 07:25:33.677456	2023-03-22 07:25:33.677456	Under	{}
10887	3.5	5.00	1147	Full Time	96.1%	2023-03-22 07:19:55.281299	2023-03-22 07:19:55.281299	Over	{}
10888	3.5	1.19	1147	Full Time	96.1%	2023-03-22 07:19:55.282399	2023-03-22 07:19:55.282399	Under	{}
10889	4.5	12.00	1147	Full Time	96.6%	2023-03-22 07:19:55.283343	2023-03-22 07:19:55.283343	Over	{}
11018	4.5	14.00	1159	Full Time	96.8%	2023-03-22 07:25:33.678791	2023-03-22 07:25:33.678791	Over	{}
11019	4.5	1.04	1159	Full Time	96.8%	2023-03-22 07:25:33.680289	2023-03-22 07:25:33.680289	Under	{}
11020	5.5	26.00	1159	Full Time	97.2%	2023-03-22 07:25:33.681424	2023-03-22 07:25:33.681424	Over	{}
11021	5.5	1.01	1159	Full Time	97.2%	2023-03-22 07:25:33.682482	2023-03-22 07:25:33.682482	Under	{}
11022	0.5	1.60	1159	1st Half	95.2%	2023-03-22 07:25:35.582955	2023-03-22 07:25:35.582955	Over	{}
11023	0.5	2.35	1159	1st Half	95.2%	2023-03-22 07:25:37.176865	2023-03-22 07:25:37.176865	Under	{}
10875	2.5	7.00	1144	2nd Half	95.1%	2023-03-22 07:19:45.417048	2023-03-22 07:19:45.417048	Over	{}
11024	0.75	1.90	1159	1st Half	95.7%	2023-03-22 07:25:37.178946	2023-03-22 07:25:37.178946	Over	{}
11025	0.75	1.93	1159	1st Half	95.7%	2023-03-22 07:25:37.18081	2023-03-22 07:25:37.18081	Under	{}
11026	1.5	3.90	1159	1st Half	95.8%	2023-03-22 07:25:37.182581	2023-03-22 07:25:37.182581	Over	{}
11027	1.5	1.27	1159	1st Half	95.8%	2023-03-22 07:25:37.184168	2023-03-22 07:25:37.184168	Under	{}
11028	2.5	13.00	1159	1st Half	96.3%	2023-03-22 07:25:37.186135	2023-03-22 07:25:37.186135	Over	{}
11029	2.5	1.04	1159	1st Half	96.3%	2023-03-22 07:25:37.188336	2023-03-22 07:25:37.188336	Under	{}
11030	3.5	41.00	1159	1st Half	98.6%	2023-03-22 07:25:37.190328	2023-03-22 07:25:37.190328	Over	{}
11031	3.5	1.01	1159	1st Half	98.6%	2023-03-22 07:25:37.192229	2023-03-22 07:25:37.192229	Under	{}
11032	4.5	81.00	1159	1st Half	98.8%	2023-03-22 07:25:37.193566	2023-03-22 07:25:37.193566	Over	{}
10844	1.5	1.44	1135	2nd Half	95.7%	2023-03-22 07:19:30.127119	2023-03-22 07:19:30.127119	Under	{}
10880	0.5	7.50	1147	Full Time	96.7%	2023-03-22 07:19:55.271547	2023-03-22 07:19:55.271547	Under	{}
10881	1.5	1.50	1147	Full Time	97.1%	2023-03-22 07:19:55.273035	2023-03-22 07:19:55.273035	Over	{}
10882	1.5	2.75	1147	Full Time	97.1%	2023-03-22 07:19:55.274293	2023-03-22 07:19:55.274293	Under	{}
10883	2.0	1.93	1147	Full Time	98.9%	2023-03-22 07:19:55.275633	2023-03-22 07:19:55.275633	Over	{}
10884	2.0	2.03	1147	Full Time	98.9%	2023-03-22 07:19:55.277091	2023-03-22 07:19:55.277091	Under	{}
10885	2.5	2.50	1147	Full Time	96.4%	2023-03-22 07:19:55.279066	2023-03-22 07:19:55.279066	Over	{}
10886	2.5	1.57	1147	Full Time	96.4%	2023-03-22 07:19:55.279886	2023-03-22 07:19:55.279886	Under	{}
11042	0.5	15.00	1162	Full Time	98.1%	2023-03-22 07:25:50.983148	2023-03-22 07:25:50.983148	Under	{}
11043	1.5	1.29	1162	Full Time	98.1%	2023-03-22 07:25:50.984969	2023-03-22 07:25:50.984969	Over	{}
11044	1.5	4.10	1162	Full Time	98.1%	2023-03-22 07:25:50.986459	2023-03-22 07:25:50.986459	Under	{}
11045	2.5	1.80	1162	Full Time	96.9%	2023-03-22 07:25:50.988117	2023-03-22 07:25:50.988117	Over	{}
11046	2.5	2.10	1162	Full Time	96.9%	2023-03-22 07:25:50.989699	2023-03-22 07:25:50.989699	Under	{}
11047	2.75	1.98	1162	Full Time	96.4%	2023-03-22 07:25:50.991392	2023-03-22 07:25:50.991392	Over	{}
11048	2.75	1.88	1162	Full Time	96.4%	2023-03-22 07:25:50.993133	2023-03-22 07:25:50.993133	Under	{}
11049	3.5	3.05	1162	Full Time	97.4%	2023-03-22 07:25:50.994485	2023-03-22 07:25:50.994485	Over	{}
11052	4.5	1.15	1162	Full Time	96.5%	2023-03-22 07:25:50.998763	2023-03-22 07:25:50.998763	Under	{}
11053	5.5	11.00	1162	Full Time	95.9%	2023-03-22 07:25:51.000335	2023-03-22 07:25:51.000335	Over	{}
11054	5.5	1.05	1162	Full Time	95.9%	2023-03-22 07:25:51.00201	2023-03-22 07:25:51.00201	Under	{}
11055	6.5	23.00	1162	Full Time	96.8%	2023-03-22 07:25:51.003885	2023-03-22 07:25:51.003885	Over	{}
11050	3.5	1.43	1162	Full Time	97.4%	2023-03-22 07:25:50.995854	2023-03-22 07:25:50.995854	Under	{}
11051	4.5	6.00	1162	Full Time	96.5%	2023-03-22 07:25:50.997354	2023-03-22 07:25:50.997354	Over	{}
11056	6.5	1.01	1162	Full Time	96.8%	2023-03-22 07:25:51.005579	2023-03-22 07:25:51.005579	Under	{}
11057	0.5	1.36	1162	1st Half	96.7%	2023-03-22 07:25:52.865126	2023-03-22 07:25:52.865126	Over	{}
11058	0.5	3.35	1162	1st Half	96.7%	2023-03-22 07:25:54.360016	2023-03-22 07:25:54.360016	Under	{}
11059	1.25	2.24	1162	1st Half	95.0%	2023-03-22 07:25:54.362198	2023-03-22 07:25:54.362198	Over	{}
11060	1.25	1.65	1162	1st Half	95.0%	2023-03-22 07:25:54.363239	2023-03-22 07:25:54.363239	Under	{}
11064	2.5	1.12	1162	1st Half	95.5%	2023-03-22 07:25:54.367528	2023-03-22 07:25:54.367528	Under	{}
11065	3.5	19.00	1162	1st Half	96.8%	2023-03-22 07:25:54.368616	2023-03-22 07:25:54.368616	Over	{}
11066	3.5	1.02	1162	1st Half	96.8%	2023-03-22 07:25:54.369908	2023-03-22 07:25:54.369908	Under	{}
11067	4.5	41.00	1162	1st Half	98.6%	2023-03-22 07:25:54.372247	2023-03-22 07:25:54.372247	Over	{}
11068	4.5	1.01	1162	1st Half	98.6%	2023-03-22 07:25:54.373643	2023-03-22 07:25:54.373643	Under	{}
11062	1.5	1.53	1162	1st Half	97.9%	2023-03-22 07:25:54.365288	2023-03-22 07:25:54.365288	Under	{}
11063	2.5	6.50	1162	1st Half	95.5%	2023-03-22 07:25:54.366509	2023-03-22 07:25:54.366509	Over	{}
11069	0.5	1.29	1162	2nd Half	99.4%	2023-03-22 07:25:56.290553	2023-03-22 07:25:56.290553	Over	{}
11070	0.5	4.33	1162	2nd Half	99.4%	2023-03-22 07:25:57.666726	2023-03-22 07:25:57.666726	Under	{}
11071	1.5	2.05	1162	2nd Half	95.8%	2023-03-22 07:25:57.667581	2023-03-22 07:25:57.667581	Over	{}
11072	1.5	1.80	1162	2nd Half	95.8%	2023-03-22 07:25:57.668544	2023-03-22 07:25:57.668544	Under	{}
11073	2.5	4.50	1162	2nd Half	96.6%	2023-03-22 07:25:57.669391	2023-03-22 07:25:57.669391	Over	{}
11074	2.5	1.23	1162	2nd Half	96.6%	2023-03-22 07:25:57.670709	2023-03-22 07:25:57.670709	Under	{}
11075	3.5	11.00	1162	2nd Half	95.9%	2023-03-22 07:25:57.673045	2023-03-22 07:25:57.673045	Over	{}
11076	3.5	1.05	1162	2nd Half	95.9%	2023-03-22 07:25:57.675409	2023-03-22 07:25:57.675409	Under	{}
11077	4.5	26.00	1162	2nd Half	97.2%	2023-03-22 07:25:57.676905	2023-03-22 07:25:57.676905	Over	{}
11078	4.5	1.01	1162	2nd Half	97.2%	2023-03-22 07:25:57.678349	2023-03-22 07:25:57.678349	Under	{}
11079	0.5	1.11	1165	Full Time	97.1%	2023-03-22 07:26:07.708396	2023-03-22 07:26:07.708396	Over	{}
11080	0.5	7.75	1165	Full Time	97.1%	2023-03-22 07:26:07.711225	2023-03-22 07:26:07.711225	Under	{}
11081	1.5	1.50	1165	Full Time	95.1%	2023-03-22 07:26:07.713643	2023-03-22 07:26:07.713643	Over	{}
11082	1.5	2.60	1165	Full Time	95.1%	2023-03-22 07:26:07.716128	2023-03-22 07:26:07.716128	Under	{}
11083	2.0	1.90	1165	Full Time	96.2%	2023-03-22 07:26:07.718267	2023-03-22 07:26:07.718267	Over	{}
11084	2.0	1.95	1165	Full Time	96.2%	2023-03-22 07:26:07.720454	2023-03-22 07:26:07.720454	Under	{}
11085	2.5	2.55	1165	Full Time	95.6%	2023-03-22 07:26:07.723014	2023-03-22 07:26:07.723014	Over	{}
11086	2.5	1.53	1165	Full Time	95.6%	2023-03-22 07:26:07.724483	2023-03-22 07:26:07.724483	Under	{}
11087	3.5	5.10	1165	Full Time	95.2%	2023-03-22 07:26:07.726228	2023-03-22 07:26:07.726228	Over	{}
11088	3.5	1.17	1165	Full Time	95.2%	2023-03-22 07:26:07.727947	2023-03-22 07:26:07.727947	Under	{}
11089	4.5	12.00	1165	Full Time	96.6%	2023-03-22 07:26:07.729439	2023-03-22 07:26:07.729439	Over	{}
11090	4.5	1.05	1165	Full Time	96.6%	2023-03-22 07:26:07.731515	2023-03-22 07:26:07.731515	Under	{}
11091	5.5	26.00	1165	Full Time	97.2%	2023-03-22 07:26:07.733632	2023-03-22 07:26:07.733632	Over	{}
11093	0.5	1.57	1165	1st Half	96.4%	2023-03-22 07:26:09.941534	2023-03-22 07:26:09.941534	Over	{}
11094	0.5	2.50	1165	1st Half	96.4%	2023-03-22 07:26:11.490567	2023-03-22 07:26:11.490567	Under	{}
11095	0.75	1.83	1165	1st Half	95.6%	2023-03-22 07:26:11.492961	2023-03-22 07:26:11.492961	Over	{}
11096	0.75	2.00	1165	1st Half	95.6%	2023-03-22 07:26:11.497116	2023-03-22 07:26:11.497116	Under	{}
11097	1.5	3.75	1165	1st Half	96.5%	2023-03-22 07:26:11.499328	2023-03-22 07:26:11.499328	Over	{}
11034	0.5	3.00	1159	2nd Half	95.5%	2023-03-22 07:25:40.015194	2023-03-22 07:25:40.015194	Under	{}
11035	1.5	2.90	1159	2nd Half	96.2%	2023-03-22 07:25:40.017344	2023-03-22 07:25:40.017344	Over	{}
11036	1.5	1.44	1159	2nd Half	96.2%	2023-03-22 07:25:40.019314	2023-03-22 07:25:40.019314	Under	{}
11037	2.5	7.00	1159	2nd Half	95.1%	2023-03-22 07:25:40.021041	2023-03-22 07:25:40.021041	Over	{}
11038	2.5	1.10	1159	2nd Half	95.1%	2023-03-22 07:25:40.02314	2023-03-22 07:25:40.02314	Under	{}
11039	3.5	21.00	1159	2nd Half	97.3%	2023-03-22 07:25:40.025466	2023-03-22 07:25:40.025466	Over	{}
11040	3.5	1.02	1159	2nd Half	97.3%	2023-03-22 07:25:40.027942	2023-03-22 07:25:40.027942	Under	{}
11041	0.5	1.05	1162	Full Time	98.1%	2023-03-22 07:25:50.979984	2023-03-22 07:25:50.979984	Over	{}
11111	3.5	1.02	1165	2nd Half	96.8%	2023-03-22 07:26:14.31896	2023-03-22 07:26:14.31896	Under	{}
11116	2.25	1.85	1168	Full Time	98.1%	2023-03-22 07:26:24.400475	2023-03-22 07:26:24.400475	Over	{}
11117	2.25	2.09	1168	Full Time	98.1%	2023-03-22 07:26:24.40248	2023-03-22 07:26:24.40248	Under	{}
11121	3.5	1.31	1168	Full Time	97.1%	2023-03-22 07:26:24.407868	2023-03-22 07:26:24.407868	Under	{}
11122	4.5	8.00	1168	Full Time	96.7%	2023-03-22 07:26:24.409139	2023-03-22 07:26:24.409139	Over	{}
11126	6.5	34.00	1168	Full Time	98.1%	2023-03-22 07:26:24.415294	2023-03-22 07:26:24.415294	Over	{}
11127	0.5	1.44	1168	1st Half	98.3%	2023-03-22 07:26:26.174365	2023-03-22 07:26:26.174365	Over	{}
11128	0.5	3.10	1168	1st Half	98.3%	2023-03-22 07:26:27.87301	2023-03-22 07:26:27.87301	Under	{}
11131	1.5	3.01	1168	1st Half	94.6%	2023-03-22 07:26:27.878753	2023-03-22 07:26:27.878753	Over	{}
11132	1.5	1.38	1168	1st Half	94.6%	2023-03-22 07:26:27.880455	2023-03-22 07:26:27.880455	Under	{}
11133	2.5	9.00	1168	1st Half	96.4%	2023-03-22 07:26:27.882059	2023-03-22 07:26:27.882059	Over	{}
11134	2.5	1.08	1168	1st Half	96.4%	2023-03-22 07:26:27.88346	2023-03-22 07:26:27.88346	Under	{}
11136	3.5	1.01	1168	1st Half	97.2%	2023-03-22 07:26:27.886417	2023-03-22 07:26:27.886417	Under	{}
11137	4.5	56.00	1168	1st Half	98.2%	2023-03-22 07:26:27.889491	2023-03-22 07:26:27.889491	Over	{}
11138	0.5	1.30	1168	2nd Half	95.9%	2023-03-22 07:26:30.166996	2023-03-22 07:26:30.166996	Over	{}
11139	0.5	3.65	1168	2nd Half	95.9%	2023-03-22 07:26:31.35138	2023-03-22 07:26:31.35138	Under	{}
11140	1.5	2.35	1168	2nd Half	96.2%	2023-03-22 07:26:31.35414	2023-03-22 07:26:31.35414	Over	{}
11141	1.5	1.63	1168	2nd Half	96.2%	2023-03-22 07:26:31.356574	2023-03-22 07:26:31.356574	Under	{}
11142	2.5	5.50	1168	2nd Half	95.8%	2023-03-22 07:26:31.358702	2023-03-22 07:26:31.358702	Over	{}
11143	2.5	1.16	1168	2nd Half	95.8%	2023-03-22 07:26:31.36116	2023-03-22 07:26:31.36116	Under	{}
11144	3.5	15.00	1168	2nd Half	96.4%	2023-03-22 07:26:31.362896	2023-03-22 07:26:31.362896	Over	{}
11145	3.5	1.03	1168	2nd Half	96.4%	2023-03-22 07:26:31.364456	2023-03-22 07:26:31.364456	Under	{}
13147	0.75	1.10	1135	Full Time	91.8%	2023-03-30 02:50:28.558723	2023-03-30 02:50:28.558723	Over	{}
12553	3.5	31.00	1144	1st Half	97.8%	2023-03-25 21:44:55.930911	2023-03-25 21:44:55.930911	Over	{}
12554	3.5	1.01	1144	1st Half	97.8%	2023-03-25 21:44:55.932977	2023-03-25 21:44:55.932977	Under	{}
11061	1.5	2.72	1162	1st Half	97.9%	2023-03-22 07:25:54.364247	2023-03-22 07:25:54.364247	Over	{}
11092	5.5	1.01	1165	Full Time	97.2%	2023-03-22 07:26:07.735657	2023-03-22 07:26:07.735657	Under	{}
12682	6.5	51.00	1165	Full Time	98.1%	2023-03-25 21:46:05.787406	2023-03-25 21:46:05.787406	Over	{}
11098	1.5	1.30	1165	1st Half	96.5%	2023-03-22 07:26:11.500926	2023-03-22 07:26:11.500926	Under	{}
11099	2.5	11.00	1165	1st Half	95.9%	2023-03-22 07:26:11.50262	2023-03-22 07:26:11.50262	Over	{}
11101	3.5	34.00	1165	1st Half	98.1%	2023-03-22 07:26:11.504382	2023-03-22 07:26:11.504382	Over	{}
11102	3.5	1.01	1165	1st Half	98.1%	2023-03-22 07:26:11.505257	2023-03-22 07:26:11.505257	Under	{}
11103	4.5	71.00	1165	1st Half	98.6%	2023-03-22 07:26:11.506223	2023-03-22 07:26:11.506223	Over	{}
11104	0.5	1.40	1165	2nd Half	97.8%	2023-03-22 07:26:13.363644	2023-03-22 07:26:13.363644	Over	{}
11105	0.5	3.25	1165	2nd Half	97.8%	2023-03-22 07:26:14.309189	2023-03-22 07:26:14.309189	Under	{}
11106	1.5	2.75	1165	2nd Half	94.9%	2023-03-22 07:26:14.311014	2023-03-22 07:26:14.311014	Over	{}
11107	1.5	1.45	1165	2nd Half	94.9%	2023-03-22 07:26:14.312813	2023-03-22 07:26:14.312813	Under	{}
11108	2.5	6.50	1165	2nd Half	94.8%	2023-03-22 07:26:14.314344	2023-03-22 07:26:14.314344	Over	{}
11109	2.5	1.11	1165	2nd Half	94.8%	2023-03-22 07:26:14.316219	2023-03-22 07:26:14.316219	Under	{}
11110	3.5	19.00	1165	2nd Half	96.8%	2023-03-22 07:26:14.317574	2023-03-22 07:26:14.317574	Over	{}
11112	0.5	1.08	1168	Full Time	99.1%	2023-03-22 07:26:24.393681	2023-03-22 07:26:24.393681	Over	{}
11113	0.5	12.00	1168	Full Time	99.1%	2023-03-22 07:26:24.395708	2023-03-22 07:26:24.395708	Under	{}
11114	1.5	1.36	1168	Full Time	99.1%	2023-03-22 07:26:24.397803	2023-03-22 07:26:24.397803	Over	{}
11115	1.5	3.65	1168	Full Time	99.1%	2023-03-22 07:26:24.399167	2023-03-22 07:26:24.399167	Under	{}
11118	2.5	2.10	1168	Full Time	98.9%	2023-03-22 07:26:24.403885	2023-03-22 07:26:24.403885	Over	{}
11119	2.5	1.87	1168	Full Time	98.9%	2023-03-22 07:26:24.405297	2023-03-22 07:26:24.405297	Under	{}
11120	3.5	3.75	1168	Full Time	97.1%	2023-03-22 07:26:24.406722	2023-03-22 07:26:24.406722	Over	{}
11123	4.5	1.10	1168	Full Time	96.7%	2023-03-22 07:26:24.410566	2023-03-22 07:26:24.410566	Under	{}
11124	5.5	17.00	1168	Full Time	96.2%	2023-03-22 07:26:24.41261	2023-03-22 07:26:24.41261	Over	{}
11125	5.5	1.02	1168	Full Time	96.2%	2023-03-22 07:26:24.413862	2023-03-22 07:26:24.413862	Under	{}
11129	1.0	2.02	1168	1st Half	97.4%	2023-03-22 07:26:27.875654	2023-03-22 07:26:27.875654	Over	{}
11130	1.0	1.88	1168	1st Half	97.4%	2023-03-22 07:26:27.877193	2023-03-22 07:26:27.877193	Under	{}
11135	3.5	26.00	1168	1st Half	97.2%	2023-03-22 07:26:27.884861	2023-03-22 07:26:27.884861	Over	{}
12555	4.5	71.00	1144	1st Half	98.6%	2023-03-25 21:44:55.934099	2023-03-25 21:44:55.934099	Over	{}
12578	6.5	51.00	1147	Full Time	98.1%	2023-03-25 21:45:09.905933	2023-03-25 21:45:09.905933	Over	{}
12612	6.5	46.00	1159	Full Time	97.9%	2023-03-25 21:45:28.130549	2023-03-25 21:45:28.130549	Over	{}
11033	0.5	1.40	1159	2nd Half	95.5%	2023-03-22 07:25:38.759269	2023-03-22 07:25:38.759269	Over	{}
11861	1.0	1.75	1162	1st Half	95.5%	2023-03-23 23:20:00.628463	2023-03-23 23:20:00.628463	Over	{}
12544	6.5	51.00	1144	Full Time	98.1%	2023-03-25 21:44:51.684978	2023-03-25 21:44:51.684978	Over	{}
11862	1.0	2.10	1162	1st Half	95.5%	2023-03-23 23:20:00.631464	2023-03-23 23:20:00.631464	Under	{}
11100	2.5	1.05	1165	1st Half	95.9%	2023-03-22 07:26:11.503513	2023-03-22 07:26:11.503513	Under	{}
12510	6.5	46.00	1135	Full Time	97.9%	2023-03-25 21:44:35.199277	2023-03-25 21:44:35.199277	Over	{}
13149	1.0	1.13	1135	Full Time	91.8%	2023-03-30 02:50:28.566431	2023-03-30 02:50:28.566431	Over	{}
13150	1.0	4.90	1135	Full Time	91.8%	2023-03-30 02:50:28.567755	2023-03-30 02:50:28.567755	Under	{}
13151	1.25	1.35	1135	Full Time	94.9%	2023-03-30 02:50:28.56993	2023-03-30 02:50:28.56993	Over	{}
13152	1.25	3.20	1135	Full Time	94.9%	2023-03-30 02:50:28.571476	2023-03-30 02:50:28.571476	Under	{}
13155	1.75	1.68	1135	Full Time	95.1%	2023-03-30 02:50:28.577045	2023-03-30 02:50:28.577045	Over	{}
13156	1.75	2.19	1135	Full Time	95.1%	2023-03-30 02:50:28.578262	2023-03-30 02:50:28.578262	Under	{}
13159	2.25	2.30	1135	Full Time	95.1%	2023-03-30 02:50:28.582243	2023-03-30 02:50:28.582243	Over	{}
13160	2.25	1.62	1135	Full Time	95.1%	2023-03-30 02:50:28.583838	2023-03-30 02:50:28.583838	Under	{}
13163	2.75	3.20	1135	Full Time	94.9%	2023-03-30 02:50:28.58938	2023-03-30 02:50:28.58938	Over	{}
13164	2.75	1.35	1135	Full Time	94.9%	2023-03-30 02:50:28.590638	2023-03-30 02:50:28.590638	Under	{}
13165	3.0	4.25	1135	Full Time	92.4%	2023-03-30 02:50:28.591645	2023-03-30 02:50:28.591645	Over	{}
13166	3.0	1.18	1135	Full Time	92.4%	2023-03-30 02:50:28.592635	2023-03-30 02:50:28.592635	Under	{}
13167	3.25	4.62	1135	Full Time	91.4%	2023-03-30 02:50:28.593626	2023-03-30 02:50:28.593626	Over	{}
13168	3.25	1.14	1135	Full Time	91.4%	2023-03-30 02:50:28.594629	2023-03-30 02:50:28.594629	Under	{}
13171	3.75	6.35	1135	Full Time	91.6%	2023-03-30 02:50:28.597718	2023-03-30 02:50:28.597718	Over	{}
13172	3.75	1.07	1135	Full Time	91.6%	2023-03-30 02:50:28.598847	2023-03-30 02:50:28.598847	Under	{}
13173	4.0	9.30	1135	Full Time	91.9%	2023-03-30 02:50:28.599878	2023-03-30 02:50:28.599878	Over	{}
13174	4.0	1.02	1135	Full Time	91.9%	2023-03-30 02:50:28.600763	2023-03-30 02:50:28.600763	Under	{}
13184	1.0	2.54	1135	1st Half	94.7%	2023-03-30 02:50:33.187421	2023-03-30 02:50:33.187421	Over	{}
13185	1.0	1.51	1135	1st Half	94.7%	2023-03-30 02:50:33.188628	2023-03-30 02:50:33.188628	Under	{}
13186	1.25	3.24	1135	1st Half	94.8%	2023-03-30 02:50:33.189966	2023-03-30 02:50:33.189966	Over	{}
13187	1.25	1.34	1135	1st Half	94.8%	2023-03-30 02:50:33.191481	2023-03-30 02:50:33.191481	Under	{}
13190	1.75	5.10	1135	1st Half	93.2%	2023-03-30 02:50:33.196865	2023-03-30 02:50:33.196865	Over	{}
13191	1.75	1.14	1135	1st Half	93.2%	2023-03-30 02:50:33.198928	2023-03-30 02:50:33.198928	Under	{}
13192	2.0	9.10	1135	1st Half	93.3%	2023-03-30 02:50:33.200256	2023-03-30 02:50:33.200256	Over	{}
13193	2.0	1.04	1135	1st Half	93.3%	2023-03-30 02:50:33.201563	2023-03-30 02:50:33.201563	Under	{}
13194	2.25	9.80	1135	1st Half	94.0%	2023-03-30 02:50:33.203085	2023-03-30 02:50:33.203085	Over	{}
13198	3.0	14.00	1135	1st Half	94.2%	2023-03-30 02:50:33.209802	2023-03-30 02:50:33.209802	Over	{}
13199	3.0	1.01	1135	1st Half	94.2%	2023-03-30 02:50:33.210999	2023-03-30 02:50:33.210999	Under	{}
13205	0.75	1.52	1135	2nd Half	93.7%	2023-03-30 02:50:37.499401	2023-03-30 02:50:37.499401	Over	{}
13206	0.75	2.44	1135	2nd Half	93.7%	2023-03-30 02:50:37.501074	2023-03-30 02:50:37.501074	Under	{}
13207	1.0	1.82	1135	2nd Half	93.9%	2023-03-30 02:50:37.503352	2023-03-30 02:50:37.503352	Over	{}
13208	1.0	1.94	1135	2nd Half	93.9%	2023-03-30 02:50:37.504925	2023-03-30 02:50:37.504925	Under	{}
13209	1.25	2.27	1135	2nd Half	93.5%	2023-03-30 02:50:37.507216	2023-03-30 02:50:37.507216	Over	{}
13210	1.25	1.59	1135	2nd Half	93.5%	2023-03-30 02:50:37.508656	2023-03-30 02:50:37.508656	Under	{}
13213	1.75	3.54	1135	2nd Half	93.5%	2023-03-30 02:50:37.514589	2023-03-30 02:50:37.514589	Over	{}
13214	1.75	1.27	1135	2nd Half	93.5%	2023-03-30 02:50:37.516837	2023-03-30 02:50:37.516837	Under	{}
13215	2.0	5.60	1135	2nd Half	94.0%	2023-03-30 02:50:37.519004	2023-03-30 02:50:37.519004	Over	{}
13216	2.0	1.13	1135	2nd Half	94.0%	2023-03-30 02:50:37.521431	2023-03-30 02:50:37.521431	Under	{}
13217	2.25	6.25	1135	2nd Half	93.5%	2023-03-30 02:50:37.523557	2023-03-30 02:50:37.523557	Over	{}
13218	2.25	1.10	1135	2nd Half	93.5%	2023-03-30 02:50:37.526051	2023-03-30 02:50:37.526051	Under	{}
13225	0.75	1.09	1144	Full Time	92.2%	2023-03-30 02:50:50.040141	2023-03-30 02:50:50.040141	Over	{}
13226	0.75	6.00	1144	Full Time	92.2%	2023-03-30 02:50:50.042554	2023-03-30 02:50:50.042554	Under	{}
13227	1.0	1.12	1144	Full Time	92.8%	2023-03-30 02:50:50.045219	2023-03-30 02:50:50.045219	Over	{}
13228	1.0	5.40	1144	Full Time	92.8%	2023-03-30 02:50:50.047269	2023-03-30 02:50:50.047269	Under	{}
13229	1.25	1.32	1144	Full Time	95.1%	2023-03-30 02:50:50.049296	2023-03-30 02:50:50.049296	Over	{}
13230	1.25	3.40	1144	Full Time	95.1%	2023-03-30 02:50:50.051666	2023-03-30 02:50:50.051666	Under	{}
13233	1.75	1.66	1144	Full Time	95.5%	2023-03-30 02:50:50.058442	2023-03-30 02:50:50.058442	Over	{}
13234	1.75	2.25	1144	Full Time	95.5%	2023-03-30 02:50:50.061067	2023-03-30 02:50:50.061067	Under	{}
13237	2.25	2.23	1144	Full Time	95.5%	2023-03-30 02:50:50.068139	2023-03-30 02:50:50.068139	Over	{}
13238	2.25	1.67	1144	Full Time	95.5%	2023-03-30 02:50:50.069945	2023-03-30 02:50:50.069945	Under	{}
13241	2.75	3.05	1144	Full Time	95.0%	2023-03-30 02:50:50.074022	2023-03-30 02:50:50.074022	Over	{}
13242	2.75	1.38	1144	Full Time	95.0%	2023-03-30 02:50:50.075741	2023-03-30 02:50:50.075741	Under	{}
13243	3.0	3.74	1144	Full Time	91.4%	2023-03-30 02:50:50.076929	2023-03-30 02:50:50.076929	Over	{}
13244	3.0	1.21	1144	Full Time	91.4%	2023-03-30 02:50:50.078124	2023-03-30 02:50:50.078124	Under	{}
13245	3.25	4.28	1144	Full Time	92.5%	2023-03-30 02:50:50.07969	2023-03-30 02:50:50.07969	Over	{}
13246	3.25	1.18	1144	Full Time	92.5%	2023-03-30 02:50:50.080844	2023-03-30 02:50:50.080844	Under	{}
13250	3.75	1.09	1144	Full Time	92.4%	2023-03-30 02:50:50.086394	2023-03-30 02:50:50.086394	Under	{}
13251	4.0	8.60	1144	Full Time	92.0%	2023-03-30 02:50:50.087654	2023-03-30 02:50:50.087654	Over	{}
13252	4.0	1.03	1144	Full Time	92.0%	2023-03-30 02:50:50.088977	2023-03-30 02:50:50.088977	Under	{}
13262	1.0	2.46	1144	1st Half	95.5%	2023-03-30 02:50:54.693039	2023-03-30 02:50:54.693039	Over	{}
13263	1.0	1.56	1144	1st Half	95.5%	2023-03-30 02:50:54.693842	2023-03-30 02:50:54.693842	Under	{}
13265	1.25	1.37	1144	1st Half	95.7%	2023-03-30 02:50:54.695527	2023-03-30 02:50:54.695527	Under	{}
13268	1.75	4.84	1144	1st Half	93.6%	2023-03-30 02:50:54.698623	2023-03-30 02:50:54.698623	Over	{}
13269	1.75	1.16	1144	1st Half	93.6%	2023-03-30 02:50:54.699491	2023-03-30 02:50:54.699491	Under	{}
13270	2.0	8.50	1144	1st Half	93.5%	2023-03-30 02:50:54.700461	2023-03-30 02:50:54.700461	Over	{}
13271	2.0	1.05	1144	1st Half	93.5%	2023-03-30 02:50:54.701411	2023-03-30 02:50:54.701411	Under	{}
13272	2.25	9.10	1144	1st Half	93.3%	2023-03-30 02:50:54.702414	2023-03-30 02:50:54.702414	Over	{}
13273	2.25	1.04	1144	1st Half	93.3%	2023-03-30 02:50:54.70343	2023-03-30 02:50:54.70343	Under	{}
13276	3.0	14.00	1144	1st Half	94.2%	2023-03-30 02:50:54.706742	2023-03-30 02:50:54.706742	Over	{}
13277	3.0	1.01	1144	1st Half	94.2%	2023-03-30 02:50:54.707679	2023-03-30 02:50:54.707679	Under	{}
13283	0.75	1.48	1144	2nd Half	93.5%	2023-03-30 02:50:59.058277	2023-03-30 02:50:59.058277	Over	{}
13284	0.75	2.54	1144	2nd Half	93.5%	2023-03-30 02:50:59.06082	2023-03-30 02:50:59.06082	Under	{}
13285	1.0	1.74	1144	2nd Half	93.5%	2023-03-30 02:50:59.062549	2023-03-30 02:50:59.062549	Over	{}
13286	1.0	2.02	1144	2nd Half	93.5%	2023-03-30 02:50:59.065096	2023-03-30 02:50:59.065096	Under	{}
13287	1.25	2.20	1144	2nd Half	93.6%	2023-03-30 02:50:59.067444	2023-03-30 02:50:59.067444	Over	{}
13288	1.25	1.63	1144	2nd Half	93.6%	2023-03-30 02:50:59.069523	2023-03-30 02:50:59.069523	Under	{}
13291	1.75	3.32	1144	2nd Half	93.4%	2023-03-30 02:50:59.073059	2023-03-30 02:50:59.073059	Over	{}
13292	1.75	1.30	1144	2nd Half	93.4%	2023-03-30 02:50:59.074083	2023-03-30 02:50:59.074083	Under	{}
13293	2.0	5.25	1144	2nd Half	94.3%	2023-03-30 02:50:59.075141	2023-03-30 02:50:59.075141	Over	{}
13294	2.0	1.15	1144	2nd Half	94.3%	2023-03-30 02:50:59.076257	2023-03-30 02:50:59.076257	Under	{}
13295	2.25	5.80	1144	2nd Half	93.2%	2023-03-30 02:50:59.077607	2023-03-30 02:50:59.077607	Over	{}
13296	2.25	1.11	1144	2nd Half	93.2%	2023-03-30 02:50:59.078722	2023-03-30 02:50:59.078722	Under	{}
13303	0.75	1.09	1147	Full Time	92.6%	2023-03-30 02:51:11.57759	2023-03-30 02:51:11.57759	Over	{}
13304	0.75	6.15	1147	Full Time	92.6%	2023-03-30 02:51:11.579362	2023-03-30 02:51:11.579362	Under	{}
13305	1.0	1.11	1147	Full Time	91.8%	2023-03-30 02:51:11.581236	2023-03-30 02:51:11.581236	Over	{}
13306	1.0	5.30	1147	Full Time	91.8%	2023-03-30 02:51:11.583316	2023-03-30 02:51:11.583316	Under	{}
13307	1.25	1.30	1147	Full Time	95.2%	2023-03-30 02:51:11.584724	2023-03-30 02:51:11.584724	Over	{}
13308	1.25	3.55	1147	Full Time	95.2%	2023-03-30 02:51:11.58662	2023-03-30 02:51:11.58662	Under	{}
13312	1.75	2.39	1147	Full Time	96.9%	2023-03-30 02:51:11.593	2023-03-30 02:51:11.593	Under	{}
13315	2.25	2.20	1147	Full Time	97.2%	2023-03-30 02:51:11.598549	2023-03-30 02:51:11.598549	Over	{}
13316	2.25	1.74	1147	Full Time	97.2%	2023-03-30 02:51:11.600501	2023-03-30 02:51:11.600501	Under	{}
13319	2.75	2.90	1147	Full Time	95.3%	2023-03-30 02:51:11.60533	2023-03-30 02:51:11.60533	Over	{}
13320	2.75	1.42	1147	Full Time	95.3%	2023-03-30 02:51:11.606545	2023-03-30 02:51:11.606545	Under	{}
13321	3.0	3.82	1147	Full Time	95.3%	2023-03-30 02:51:11.608596	2023-03-30 02:51:11.608596	Over	{}
13322	3.0	1.27	1147	Full Time	95.3%	2023-03-30 02:51:11.610575	2023-03-30 02:51:11.610575	Under	{}
13323	3.25	4.26	1147	Full Time	92.4%	2023-03-30 02:51:11.611702	2023-03-30 02:51:11.611702	Over	{}
13324	3.25	1.18	1147	Full Time	92.4%	2023-03-30 02:51:11.612703	2023-03-30 02:51:11.612703	Under	{}
13327	3.75	6.00	1147	Full Time	92.2%	2023-03-30 02:51:11.616116	2023-03-30 02:51:11.616116	Over	{}
13328	3.75	1.09	1147	Full Time	92.2%	2023-03-30 02:51:11.618472	2023-03-30 02:51:11.618472	Under	{}
13329	4.0	8.50	1147	Full Time	91.9%	2023-03-30 02:51:11.619497	2023-03-30 02:51:11.619497	Over	{}
13330	4.0	1.03	1147	Full Time	91.9%	2023-03-30 02:51:11.620491	2023-03-30 02:51:11.620491	Under	{}
13340	1.0	2.37	1147	1st Half	94.4%	2023-03-30 02:51:17.150926	2023-03-30 02:51:17.150926	Over	{}
13341	1.0	1.57	1147	1st Half	94.4%	2023-03-30 02:51:17.1527	2023-03-30 02:51:17.1527	Under	{}
13342	1.25	3.04	1147	1st Half	94.4%	2023-03-30 02:51:17.154983	2023-03-30 02:51:17.154983	Over	{}
13343	1.25	1.37	1147	1st Half	94.4%	2023-03-30 02:51:17.157132	2023-03-30 02:51:17.157132	Under	{}
13346	1.75	4.80	1147	1st Half	93.4%	2023-03-30 02:51:17.161337	2023-03-30 02:51:17.161337	Over	{}
13347	1.75	1.16	1147	1st Half	93.4%	2023-03-30 02:51:17.162254	2023-03-30 02:51:17.162254	Under	{}
13348	2.0	8.40	1147	1st Half	93.3%	2023-03-30 02:51:17.163582	2023-03-30 02:51:17.163582	Over	{}
13349	2.0	1.05	1147	1st Half	93.3%	2023-03-30 02:51:17.164843	2023-03-30 02:51:17.164843	Under	{}
13350	2.25	9.10	1147	1st Half	93.3%	2023-03-30 02:51:17.165989	2023-03-30 02:51:17.165989	Over	{}
13351	2.25	1.04	1147	1st Half	93.3%	2023-03-30 02:51:17.167546	2023-03-30 02:51:17.167546	Under	{}
13354	3.0	14.00	1147	1st Half	94.2%	2023-03-30 02:51:17.172668	2023-03-30 02:51:17.172668	Over	{}
13355	3.0	1.01	1147	1st Half	94.2%	2023-03-30 02:51:17.174188	2023-03-30 02:51:17.174188	Under	{}
13361	0.75	1.48	1147	2nd Half	93.5%	2023-03-30 02:51:21.69145	2023-03-30 02:51:21.69145	Over	{}
13362	0.75	2.54	1147	2nd Half	93.5%	2023-03-30 02:51:21.693822	2023-03-30 02:51:21.693822	Under	{}
13363	1.0	1.74	1147	2nd Half	95.6%	2023-03-30 02:51:21.696152	2023-03-30 02:51:21.696152	Over	{}
13364	1.0	2.12	1147	2nd Half	95.6%	2023-03-30 02:51:21.698252	2023-03-30 02:51:21.698252	Under	{}
13365	1.25	2.18	1147	2nd Half	93.6%	2023-03-30 02:51:21.700916	2023-03-30 02:51:21.700916	Over	{}
13369	1.75	3.32	1147	2nd Half	93.4%	2023-03-30 02:51:21.709242	2023-03-30 02:51:21.709242	Over	{}
13370	1.75	1.30	1147	2nd Half	93.4%	2023-03-30 02:51:21.711369	2023-03-30 02:51:21.711369	Under	{}
13371	2.0	5.20	1147	2nd Half	95.5%	2023-03-30 02:51:21.713564	2023-03-30 02:51:21.713564	Over	{}
13372	2.0	1.17	1147	2nd Half	95.5%	2023-03-30 02:51:21.715781	2023-03-30 02:51:21.715781	Under	{}
13373	2.25	5.75	1147	2nd Half	93.7%	2023-03-30 02:51:21.717451	2023-03-30 02:51:21.717451	Over	{}
13381	0.75	1.11	1159	Full Time	92.4%	2023-03-30 02:51:35.331827	2023-03-30 02:51:35.331827	Over	{}
13382	0.75	5.50	1159	Full Time	92.4%	2023-03-30 02:51:35.333639	2023-03-30 02:51:35.333639	Under	{}
13383	1.0	1.14	1159	Full Time	92.3%	2023-03-30 02:51:35.335567	2023-03-30 02:51:35.335567	Over	{}
13384	1.0	4.85	1159	Full Time	92.3%	2023-03-30 02:51:35.337319	2023-03-30 02:51:35.337319	Under	{}
13385	1.25	1.37	1159	Full Time	95.0%	2023-03-30 02:51:35.338946	2023-03-30 02:51:35.338946	Over	{}
13386	1.25	3.10	1159	Full Time	95.0%	2023-03-30 02:51:35.339957	2023-03-30 02:51:35.339957	Under	{}
13389	1.75	1.73	1159	Full Time	95.7%	2023-03-30 02:51:35.34301	2023-03-30 02:51:35.34301	Over	{}
13390	1.75	2.14	1159	Full Time	95.7%	2023-03-30 02:51:35.344071	2023-03-30 02:51:35.344071	Under	{}
13393	2.25	2.37	1159	Full Time	95.5%	2023-03-30 02:51:35.347481	2023-03-30 02:51:35.347481	Over	{}
13394	2.25	1.60	1159	Full Time	95.5%	2023-03-30 02:51:35.34862	2023-03-30 02:51:35.34862	Under	{}
13397	2.75	3.30	1159	Full Time	94.8%	2023-03-30 02:51:35.352095	2023-03-30 02:51:35.352095	Over	{}
13398	2.75	1.33	1159	Full Time	94.8%	2023-03-30 02:51:35.353048	2023-03-30 02:51:35.353048	Under	{}
13399	3.0	4.30	1159	Full Time	91.4%	2023-03-30 02:51:35.3539	2023-03-30 02:51:35.3539	Over	{}
13400	3.0	1.16	1159	Full Time	91.4%	2023-03-30 02:51:35.355106	2023-03-30 02:51:35.355106	Under	{}
13401	3.25	4.74	1159	Full Time	92.5%	2023-03-30 02:51:35.355977	2023-03-30 02:51:35.355977	Over	{}
13402	3.25	1.15	1159	Full Time	92.5%	2023-03-30 02:51:35.356919	2023-03-30 02:51:35.356919	Under	{}
13405	3.75	6.80	1159	Full Time	92.5%	2023-03-30 02:51:35.359927	2023-03-30 02:51:35.359927	Over	{}
13406	3.75	1.07	1159	Full Time	92.5%	2023-03-30 02:51:35.360794	2023-03-30 02:51:35.360794	Under	{}
13407	4.0	9.60	1159	Full Time	91.4%	2023-03-30 02:51:35.362139	2023-03-30 02:51:35.362139	Over	{}
13408	4.0	1.01	1159	Full Time	91.4%	2023-03-30 02:51:35.363039	2023-03-30 02:51:35.363039	Under	{}
13418	1.0	2.65	1159	1st Half	95.4%	2023-03-30 02:51:40.033719	2023-03-30 02:51:40.033719	Over	{}
13419	1.0	1.49	1159	1st Half	95.4%	2023-03-30 02:51:40.035878	2023-03-30 02:51:40.035878	Under	{}
13420	1.25	3.39	1159	1st Half	95.5%	2023-03-30 02:51:40.037704	2023-03-30 02:51:40.037704	Over	{}
13421	1.25	1.33	1159	1st Half	95.5%	2023-03-30 02:51:40.039836	2023-03-30 02:51:40.039836	Under	{}
13424	1.75	5.20	1159	1st Half	93.5%	2023-03-30 02:51:40.044929	2023-03-30 02:51:40.044929	Over	{}
13425	1.75	1.14	1159	1st Half	93.5%	2023-03-30 02:51:40.046498	2023-03-30 02:51:40.046498	Under	{}
13426	2.0	9.30	1159	1st Half	93.5%	2023-03-30 02:51:40.048455	2023-03-30 02:51:40.048455	Over	{}
13428	2.25	9.90	1159	1st Half	93.3%	2023-03-30 02:51:40.051021	2023-03-30 02:51:40.051021	Over	{}
13429	2.25	1.03	1159	1st Half	93.3%	2023-03-30 02:51:40.052059	2023-03-30 02:51:40.052059	Under	{}
13432	3.0	14.00	1159	1st Half	94.2%	2023-03-30 02:51:40.055017	2023-03-30 02:51:40.055017	Over	{}
13433	3.0	1.01	1159	1st Half	94.2%	2023-03-30 02:51:40.055988	2023-03-30 02:51:40.055988	Under	{}
13439	0.75	1.53	1159	2nd Half	93.6%	2023-03-30 02:51:44.951315	2023-03-30 02:51:44.951315	Over	{}
13440	0.75	2.41	1159	2nd Half	93.6%	2023-03-30 02:51:44.953277	2023-03-30 02:51:44.953277	Under	{}
13441	1.0	1.84	1159	2nd Half	93.5%	2023-03-30 02:51:44.955361	2023-03-30 02:51:44.955361	Over	{}
13442	1.0	1.90	1159	2nd Half	93.5%	2023-03-30 02:51:44.957542	2023-03-30 02:51:44.957542	Under	{}
13443	1.25	2.31	1159	2nd Half	93.5%	2023-03-30 02:51:44.959408	2023-03-30 02:51:44.959408	Over	{}
13444	1.25	1.57	1159	2nd Half	93.5%	2023-03-30 02:51:44.961802	2023-03-30 02:51:44.961802	Under	{}
13447	1.75	3.54	1159	2nd Half	93.5%	2023-03-30 02:51:44.967985	2023-03-30 02:51:44.967985	Over	{}
13448	1.75	1.27	1159	2nd Half	93.5%	2023-03-30 02:51:44.970203	2023-03-30 02:51:44.970203	Under	{}
13449	2.0	5.75	1159	2nd Half	93.7%	2023-03-30 02:51:44.97133	2023-03-30 02:51:44.97133	Over	{}
13450	2.0	1.12	1159	2nd Half	93.7%	2023-03-30 02:51:44.972388	2023-03-30 02:51:44.972388	Under	{}
13451	2.25	6.35	1159	2nd Half	93.8%	2023-03-30 02:51:44.973438	2023-03-30 02:51:44.973438	Over	{}
13452	2.25	1.10	1159	2nd Half	93.8%	2023-03-30 02:51:44.974549	2023-03-30 02:51:44.974549	Under	{}
13459	0.75	1.01	1162	Full Time	92.5%	2023-03-30 02:51:58.586374	2023-03-30 02:51:58.586374	Over	{}
13460	0.75	11.00	1162	Full Time	92.5%	2023-03-30 02:51:58.588065	2023-03-30 02:51:58.588065	Under	{}
13461	1.0	1.02	1162	Full Time	91.6%	2023-03-30 02:51:58.589981	2023-03-30 02:51:58.589981	Over	{}
13462	1.0	9.00	1162	Full Time	91.6%	2023-03-30 02:51:58.591498	2023-03-30 02:51:58.591498	Under	{}
13463	1.25	1.13	1162	Full Time	93.0%	2023-03-30 02:51:58.59268	2023-03-30 02:51:58.59268	Over	{}
13464	1.25	5.25	1162	Full Time	93.0%	2023-03-30 02:51:58.593856	2023-03-30 02:51:58.593856	Under	{}
13467	1.75	1.30	1162	Full Time	95.2%	2023-03-30 02:51:58.596886	2023-03-30 02:51:58.596886	Over	{}
13468	1.75	3.55	1162	Full Time	95.2%	2023-03-30 02:51:58.59787	2023-03-30 02:51:58.59787	Under	{}
13469	2.0	1.37	1162	Full Time	95.0%	2023-03-30 02:51:58.59883	2023-03-30 02:51:58.59883	Over	{}
13470	2.0	3.10	1162	Full Time	95.0%	2023-03-30 02:51:58.599823	2023-03-30 02:51:58.599823	Under	{}
13471	2.25	1.58	1162	Full Time	96.1%	2023-03-30 02:51:58.60083	2023-03-30 02:51:58.60083	Over	{}
13472	2.25	2.45	1162	Full Time	96.1%	2023-03-30 02:51:58.601839	2023-03-30 02:51:58.601839	Under	{}
13477	3.0	2.34	1162	Full Time	96.4%	2023-03-30 02:51:58.607494	2023-03-30 02:51:58.607494	Over	{}
13478	3.0	1.64	1162	Full Time	96.4%	2023-03-30 02:51:58.608466	2023-03-30 02:51:58.608466	Under	{}
13480	3.25	1.51	1162	Full Time	96.2%	2023-03-30 02:51:58.610477	2023-03-30 02:51:58.610477	Under	{}
13483	3.75	3.55	1162	Full Time	95.2%	2023-03-30 02:51:58.613383	2023-03-30 02:51:58.613383	Over	{}
13484	3.75	1.30	1162	Full Time	95.2%	2023-03-30 02:51:58.614498	2023-03-30 02:51:58.614498	Under	{}
13485	4.0	4.30	1162	Full Time	91.4%	2023-03-30 02:51:58.615515	2023-03-30 02:51:58.615515	Over	{}
13486	4.0	1.16	1162	Full Time	91.4%	2023-03-30 02:51:58.616503	2023-03-30 02:51:58.616503	Under	{}
13488	4.25	1.16	1162	Full Time	93.2%	2023-03-30 02:51:58.618682	2023-03-30 02:51:58.618682	Under	{}
13491	5.0	8.60	1162	Full Time	92.0%	2023-03-30 02:51:58.621092	2023-03-30 02:51:58.621092	Over	{}
13492	5.0	1.03	1162	Full Time	92.0%	2023-03-30 02:51:58.621856	2023-03-30 02:51:58.621856	Under	{}
13497	7.5	51.00	1162	Full Time	98.1%	2023-03-30 02:51:58.626863	2023-03-30 02:51:58.626863	Over	{}
13500	0.75	1.47	1162	1st Half	94.3%	2023-03-30 02:52:03.285809	2023-03-30 02:52:03.285809	Over	{}
13501	0.75	2.63	1162	1st Half	94.3%	2023-03-30 02:52:03.287876	2023-03-30 02:52:03.287876	Under	{}
13508	1.75	3.28	1162	1st Half	93.6%	2023-03-30 02:52:03.301892	2023-03-30 02:52:03.301892	Over	{}
13509	1.75	1.31	1162	1st Half	93.6%	2023-03-30 02:52:03.303351	2023-03-30 02:52:03.303351	Under	{}
13510	2.0	5.05	1162	1st Half	93.7%	2023-03-30 02:52:03.30457	2023-03-30 02:52:03.30457	Over	{}
13511	2.0	1.15	1162	1st Half	93.7%	2023-03-30 02:52:03.30583	2023-03-30 02:52:03.30583	Under	{}
13512	2.25	5.65	1162	1st Half	93.5%	2023-03-30 02:52:03.307404	2023-03-30 02:52:03.307404	Over	{}
13513	2.25	1.12	1162	1st Half	93.5%	2023-03-30 02:52:03.308458	2023-03-30 02:52:03.308458	Under	{}
13522	0.75	1.26	1162	2nd Half	93.5%	2023-03-30 02:52:08.080258	2023-03-30 02:52:08.080258	Over	{}
13523	0.75	3.62	1162	2nd Half	93.5%	2023-03-30 02:52:08.081417	2023-03-30 02:52:08.081417	Under	{}
13524	1.0	1.36	1162	2nd Half	93.6%	2023-03-30 02:52:08.082474	2023-03-30 02:52:08.082474	Over	{}
13525	1.0	3.00	1162	2nd Half	93.6%	2023-03-30 02:52:08.083665	2023-03-30 02:52:08.083665	Under	{}
13526	1.25	1.66	1162	2nd Half	93.5%	2023-03-30 02:52:08.084661	2023-03-30 02:52:08.084661	Over	{}
13527	1.25	2.14	1162	2nd Half	93.5%	2023-03-30 02:52:08.085962	2023-03-30 02:52:08.085962	Under	{}
13530	1.75	2.30	1162	2nd Half	93.7%	2023-03-30 02:52:08.089365	2023-03-30 02:52:08.089365	Over	{}
13531	1.75	1.58	1162	2nd Half	93.7%	2023-03-30 02:52:08.09039	2023-03-30 02:52:08.09039	Under	{}
13532	2.0	3.05	1162	2nd Half	93.6%	2023-03-30 02:52:08.091442	2023-03-30 02:52:08.091442	Over	{}
13533	2.0	1.35	1162	2nd Half	93.6%	2023-03-30 02:52:08.092406	2023-03-30 02:52:08.092406	Under	{}
13534	2.25	3.48	1162	2nd Half	93.6%	2023-03-30 02:52:08.0937	2023-03-30 02:52:08.0937	Over	{}
13535	2.25	1.28	1162	2nd Half	93.6%	2023-03-30 02:52:08.095482	2023-03-30 02:52:08.095482	Under	{}
13538	3.0	7.10	1162	2nd Half	93.0%	2023-03-30 02:52:08.098431	2023-03-30 02:52:08.098431	Over	{}
13539	3.0	1.07	1162	2nd Half	93.0%	2023-03-30 02:52:08.099536	2023-03-30 02:52:08.099536	Under	{}
13546	0.75	1.09	1165	Full Time	93.0%	2023-03-30 02:52:20.297586	2023-03-30 02:52:20.297586	Over	{}
13548	1.0	1.11	1165	Full Time	91.6%	2023-03-30 02:52:20.302848	2023-03-30 02:52:20.302848	Over	{}
13549	1.0	5.25	1165	Full Time	91.6%	2023-03-30 02:52:20.305278	2023-03-30 02:52:20.305278	Under	{}
13550	1.25	1.32	1165	Full Time	95.1%	2023-03-30 02:52:20.307512	2023-03-30 02:52:20.307512	Over	{}
13551	1.25	3.40	1165	Full Time	95.1%	2023-03-30 02:52:20.309376	2023-03-30 02:52:20.309376	Under	{}
13554	1.75	1.64	1165	Full Time	94.9%	2023-03-30 02:52:20.314243	2023-03-30 02:52:20.314243	Over	{}
13555	1.75	2.25	1165	Full Time	94.9%	2023-03-30 02:52:20.315856	2023-03-30 02:52:20.315856	Under	{}
13558	2.25	2.20	1165	Full Time	95.6%	2023-03-30 02:52:20.321898	2023-03-30 02:52:20.321898	Over	{}
13559	2.25	1.69	1165	Full Time	95.6%	2023-03-30 02:52:20.32364	2023-03-30 02:52:20.32364	Under	{}
13562	2.75	3.00	1165	Full Time	95.0%	2023-03-30 02:52:20.329301	2023-03-30 02:52:20.329301	Over	{}
13563	2.75	1.39	1165	Full Time	95.0%	2023-03-30 02:52:20.331246	2023-03-30 02:52:20.331246	Under	{}
13564	3.0	3.90	1165	Full Time	92.9%	2023-03-30 02:52:20.332949	2023-03-30 02:52:20.332949	Over	{}
13565	3.0	1.22	1165	Full Time	92.9%	2023-03-30 02:52:20.33456	2023-03-30 02:52:20.33456	Under	{}
13566	3.25	4.34	1165	Full Time	92.8%	2023-03-30 02:52:20.336254	2023-03-30 02:52:20.336254	Over	{}
13567	3.25	1.18	1165	Full Time	92.8%	2023-03-30 02:52:20.337923	2023-03-30 02:52:20.337923	Under	{}
13570	3.75	6.35	1165	Full Time	93.0%	2023-03-30 02:52:20.343223	2023-03-30 02:52:20.343223	Over	{}
13571	3.75	1.09	1165	Full Time	93.0%	2023-03-30 02:52:20.345516	2023-03-30 02:52:20.345516	Under	{}
13572	4.0	8.60	1165	Full Time	92.0%	2023-03-30 02:52:20.347408	2023-03-30 02:52:20.347408	Over	{}
13573	4.0	1.03	1165	Full Time	92.0%	2023-03-30 02:52:20.34919	2023-03-30 02:52:20.34919	Under	{}
13583	1.0	2.45	1165	1st Half	95.3%	2023-03-30 02:52:25.49971	2023-03-30 02:52:25.49971	Over	{}
13584	1.0	1.56	1165	1st Half	95.3%	2023-03-30 02:52:25.501383	2023-03-30 02:52:25.501383	Under	{}
13585	1.25	3.13	1165	1st Half	95.3%	2023-03-30 02:52:25.503391	2023-03-30 02:52:25.503391	Over	{}
13586	1.25	1.37	1165	1st Half	95.3%	2023-03-30 02:52:25.505263	2023-03-30 02:52:25.505263	Under	{}
13589	1.75	4.84	1165	1st Half	93.6%	2023-03-30 02:52:25.51093	2023-03-30 02:52:25.51093	Over	{}
13590	1.75	1.16	1165	1st Half	93.6%	2023-03-30 02:52:25.512602	2023-03-30 02:52:25.512602	Under	{}
13591	2.0	8.50	1165	1st Half	93.5%	2023-03-30 02:52:25.514543	2023-03-30 02:52:25.514543	Over	{}
13592	2.0	1.05	1165	1st Half	93.5%	2023-03-30 02:52:25.516428	2023-03-30 02:52:25.516428	Under	{}
13593	2.25	9.20	1165	1st Half	93.4%	2023-03-30 02:52:25.518467	2023-03-30 02:52:25.518467	Over	{}
13594	2.25	1.04	1165	1st Half	93.4%	2023-03-30 02:52:25.520007	2023-03-30 02:52:25.520007	Under	{}
13602	0.75	1.48	1165	2nd Half	93.6%	2023-03-30 02:52:30.55655	2023-03-30 02:52:30.55655	Over	{}
13603	0.75	2.55	1165	2nd Half	93.6%	2023-03-30 02:52:30.559034	2023-03-30 02:52:30.559034	Under	{}
13605	1.0	2.02	1165	2nd Half	93.8%	2023-03-30 02:52:30.563604	2023-03-30 02:52:30.563604	Under	{}
13606	1.25	2.20	1165	2nd Half	93.6%	2023-03-30 02:52:30.565627	2023-03-30 02:52:30.565627	Over	{}
13607	1.25	1.63	1165	2nd Half	93.6%	2023-03-30 02:52:30.56719	2023-03-30 02:52:30.56719	Under	{}
13610	1.75	3.34	1165	2nd Half	93.6%	2023-03-30 02:52:30.571384	2023-03-30 02:52:30.571384	Over	{}
13611	1.75	1.30	1165	2nd Half	93.6%	2023-03-30 02:52:30.572312	2023-03-30 02:52:30.572312	Under	{}
13148	0.75	5.55	1135	Full Time	91.8%	2023-03-30 02:50:28.564555	2023-03-30 02:50:28.564555	Under	{}
13195	2.25	1.04	1135	1st Half	94.0%	2023-03-30 02:50:33.204524	2023-03-30 02:50:33.204524	Under	{}
13249	3.75	6.05	1144	Full Time	92.4%	2023-03-30 02:50:50.084772	2023-03-30 02:50:50.084772	Over	{}
13264	1.25	3.17	1144	1st Half	95.7%	2023-03-30 02:50:54.69469	2023-03-30 02:50:54.69469	Over	{}
13311	1.75	1.63	1147	Full Time	96.9%	2023-03-30 02:51:11.59125	2023-03-30 02:51:11.59125	Over	{}
13366	1.25	1.64	1147	2nd Half	93.6%	2023-03-30 02:51:21.703255	2023-03-30 02:51:21.703255	Under	{}
13374	2.25	1.12	1147	2nd Half	93.7%	2023-03-30 02:51:21.71932	2023-03-30 02:51:21.71932	Under	{}
13427	2.0	1.04	1159	1st Half	93.5%	2023-03-30 02:51:40.050059	2023-03-30 02:51:40.050059	Under	{}
13479	3.25	2.65	1162	Full Time	96.2%	2023-03-30 02:51:58.609447	2023-03-30 02:51:58.609447	Over	{}
13487	4.25	4.74	1162	Full Time	93.2%	2023-03-30 02:51:58.617505	2023-03-30 02:51:58.617505	Over	{}
13547	0.75	6.35	1165	Full Time	93.0%	2023-03-30 02:52:20.30069	2023-03-30 02:52:20.30069	Under	{}
13604	1.0	1.75	1165	2nd Half	93.8%	2023-03-30 02:52:30.56129	2023-03-30 02:52:30.56129	Over	{}
13613	2.0	1.14	1165	2nd Half	93.7%	2023-03-30 02:52:30.574174	2023-03-30 02:52:30.574174	Under	{}
13614	2.25	5.85	1165	2nd Half	94.0%	2023-03-30 02:52:30.575161	2023-03-30 02:52:30.575161	Over	{}
13615	2.25	1.12	1165	2nd Half	94.0%	2023-03-30 02:52:30.576171	2023-03-30 02:52:30.576171	Under	{}
13622	0.75	1.03	1168	Full Time	92.6%	2023-03-30 02:52:43.946687	2023-03-30 02:52:43.946687	Over	{}
13623	0.75	9.20	1168	Full Time	92.6%	2023-03-30 02:52:43.94876	2023-03-30 02:52:43.94876	Under	{}
13624	1.0	1.04	1168	Full Time	91.3%	2023-03-30 02:52:43.950061	2023-03-30 02:52:43.950061	Over	{}
13625	1.0	7.50	1168	Full Time	91.3%	2023-03-30 02:52:43.952351	2023-03-30 02:52:43.952351	Under	{}
13626	1.25	1.18	1168	Full Time	92.6%	2023-03-30 02:52:43.954447	2023-03-30 02:52:43.954447	Over	{}
13627	1.25	4.30	1168	Full Time	92.6%	2023-03-30 02:52:43.956314	2023-03-30 02:52:43.956314	Under	{}
13630	1.75	1.44	1168	Full Time	96.8%	2023-03-30 02:52:43.96315	2023-03-30 02:52:43.96315	Over	{}
13631	1.75	2.95	1168	Full Time	96.8%	2023-03-30 02:52:43.964511	2023-03-30 02:52:43.964511	Under	{}
13632	2.0	1.57	1168	Full Time	97.9%	2023-03-30 02:52:43.96636	2023-03-30 02:52:43.96636	Over	{}
13633	2.0	2.60	1168	Full Time	97.9%	2023-03-30 02:52:43.96815	2023-03-30 02:52:43.96815	Under	{}
13638	2.75	2.40	1168	Full Time	97.1%	2023-03-30 02:52:43.976921	2023-03-30 02:52:43.976921	Over	{}
13639	2.75	1.63	1168	Full Time	97.1%	2023-03-30 02:52:43.979207	2023-03-30 02:52:43.979207	Under	{}
13640	3.0	2.84	1168	Full Time	96.0%	2023-03-30 02:52:43.980082	2023-03-30 02:52:43.980082	Over	{}
13641	3.0	1.45	1168	Full Time	96.0%	2023-03-30 02:52:43.980905	2023-03-30 02:52:43.980905	Under	{}
13642	3.25	3.15	1168	Full Time	95.0%	2023-03-30 02:52:43.981986	2023-03-30 02:52:43.981986	Over	{}
13643	3.25	1.36	1168	Full Time	95.0%	2023-03-30 02:52:43.982853	2023-03-30 02:52:43.982853	Under	{}
13646	3.75	4.22	1168	Full Time	92.8%	2023-03-30 02:52:43.986671	2023-03-30 02:52:43.986671	Over	{}
13647	3.75	1.19	1168	Full Time	92.8%	2023-03-30 02:52:43.987539	2023-03-30 02:52:43.987539	Under	{}
13648	4.0	5.70	1168	Full Time	91.5%	2023-03-30 02:52:43.988732	2023-03-30 02:52:43.988732	Over	{}
13649	4.0	1.09	1168	Full Time	91.5%	2023-03-30 02:52:43.98959	2023-03-30 02:52:43.98959	Under	{}
13650	4.25	6.40	1168	Full Time	93.1%	2023-03-30 02:52:43.990458	2023-03-30 02:52:43.990458	Over	{}
13651	4.25	1.09	1168	Full Time	93.1%	2023-03-30 02:52:43.99134	2023-03-30 02:52:43.99134	Under	{}
13654	5.0	10.50	1168	Full Time	93.0%	2023-03-30 02:52:43.99407	2023-03-30 02:52:43.99407	Over	{}
13655	5.0	1.02	1168	Full Time	93.0%	2023-03-30 02:52:43.99493	2023-03-30 02:52:43.99493	Under	{}
13662	0.75	1.57	1168	1st Half	95.1%	2023-03-30 02:52:49.039391	2023-03-30 02:52:49.039391	Over	{}
13663	0.75	2.41	1168	1st Half	95.1%	2023-03-30 02:52:49.041351	2023-03-30 02:52:49.041351	Under	{}
13666	1.25	2.47	1168	1st Half	94.5%	2023-03-30 02:52:49.04759	2023-03-30 02:52:49.04759	Over	{}
13667	1.25	1.53	1168	1st Half	94.5%	2023-03-30 02:52:49.049142	2023-03-30 02:52:49.049142	Under	{}
13670	1.75	3.82	1168	1st Half	93.6%	2023-03-30 02:52:49.052671	2023-03-30 02:52:49.052671	Over	{}
13671	1.75	1.24	1168	1st Half	93.6%	2023-03-30 02:52:49.053695	2023-03-30 02:52:49.053695	Under	{}
13672	2.0	6.20	1168	1st Half	93.4%	2023-03-30 02:52:49.054695	2023-03-30 02:52:49.054695	Over	{}
13673	2.0	1.10	1168	1st Half	93.4%	2023-03-30 02:52:49.055697	2023-03-30 02:52:49.055697	Under	{}
13674	2.25	6.85	1168	1st Half	94.0%	2023-03-30 02:52:49.056703	2023-03-30 02:52:49.056703	Over	{}
13675	2.25	1.09	1168	1st Half	94.0%	2023-03-30 02:52:49.057728	2023-03-30 02:52:49.057728	Under	{}
13683	0.75	1.34	1168	2nd Half	93.6%	2023-03-30 02:52:54.320884	2023-03-30 02:52:54.320884	Over	{}
13684	0.75	3.10	1168	2nd Half	93.6%	2023-03-30 02:52:54.322829	2023-03-30 02:52:54.322829	Under	{}
13685	1.0	1.49	1168	2nd Half	93.6%	2023-03-30 02:52:54.324806	2023-03-30 02:52:54.324806	Over	{}
13686	1.0	2.52	1168	2nd Half	93.6%	2023-03-30 02:52:54.32681	2023-03-30 02:52:54.32681	Under	{}
13687	1.25	1.85	1168	2nd Half	93.7%	2023-03-30 02:52:54.328694	2023-03-30 02:52:54.328694	Over	{}
13688	1.25	1.90	1168	2nd Half	93.7%	2023-03-30 02:52:54.329958	2023-03-30 02:52:54.329958	Under	{}
13691	1.75	2.68	1168	2nd Half	93.7%	2023-03-30 02:52:54.333881	2023-03-30 02:52:54.333881	Over	{}
13692	1.75	1.44	1168	2nd Half	93.7%	2023-03-30 02:52:54.33509	2023-03-30 02:52:54.33509	Under	{}
13693	2.0	3.72	1168	2nd Half	93.6%	2023-03-30 02:52:54.336554	2023-03-30 02:52:54.336554	Over	{}
13694	2.0	1.25	1168	2nd Half	93.6%	2023-03-30 02:52:54.338319	2023-03-30 02:52:54.338319	Under	{}
13695	2.25	4.32	1168	2nd Half	93.9%	2023-03-30 02:52:54.339474	2023-03-30 02:52:54.339474	Over	{}
13696	2.25	1.20	1168	2nd Half	93.9%	2023-03-30 02:52:54.340698	2023-03-30 02:52:54.340698	Under	{}
13699	3.0	8.50	1168	2nd Half	94.2%	2023-03-30 02:52:54.344181	2023-03-30 02:52:54.344181	Over	{}
13700	3.0	1.06	1168	2nd Half	94.2%	2023-03-30 02:52:54.345322	2023-03-30 02:52:54.345322	Under	{}
13612	2.0	5.25	1165	2nd Half	93.7%	2023-03-30 02:52:30.5732	2023-03-30 02:52:30.5732	Over	{}
13659	6.5	1.01	1168	Full Time	98.1%	2023-03-30 02:52:43.998649	2023-03-30 02:52:43.998649	Under	{}
\.


--
-- TOC entry 3100 (class 0 OID 24822)
-- Dependencies: 204
-- Data for Name: OddsSafariMatch; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."OddsSafariMatch" (id, home_team, guest_team, date_time, created, updated) FROM stdin;
1135	Levadiakos	Atromitos	2023-04-01 17:00:00+03	2023-03-22 05:22:29.302635	2023-03-22 05:22:29.302635
1137	Panetolikos	Lamia	2023-04-01 17:30:00+03	2023-03-22 05:24:04.126547	2023-03-22 05:24:04.126547
1194	PAS Giannina	OFI	2023-04-01 19:30:00+03	2023-03-22 08:21:15.790341	2023-03-22 08:21:15.790341
1195	Ionikos	Asteras Tripolis	2023-04-01 21:00:00+03	2023-03-22 08:21:37.447677	2023-03-22 08:21:37.447677
1200	Panathinaikos	Volos	2023-04-02 18:00:00+03	2023-03-22 08:23:33.972208	2023-03-22 08:23:33.972208
1201	PAOK	AEK	2023-04-02 19:30:00+03	2023-03-22 08:23:57.464226	2023-03-22 08:23:57.464226
1202	Olympiacos	Aris Salonika	2023-04-02 21:00:00+03	2023-03-22 08:24:24.656583	2023-03-22 08:24:24.656583
\.


--
-- TOC entry 3101 (class 0 OID 24836)
-- Dependencies: 205
-- Data for Name: OddsSafariOverUnder; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."OddsSafariOverUnder" (id, goals, odds, match_id, half, payout, created, updated, type, bet_links) FROM stdin;
11390	0.5	1.35	1137	2nd Half	4.62%	2023-03-22 08:21:13.276684	2023-03-22 08:21:13.276684	Over	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
11391	0.5	3.25	1137	2nd Half	4.62%	2023-03-22 08:21:13.280523	2023-03-22 08:21:13.280523	Under	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
11392	2.5	2.55	1194	Full Time	3.60%	2023-03-22 08:21:25.106953	2023-03-22 08:21:25.106953	Over	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
11393	2.5	1.55	1194	Full Time	3.60%	2023-03-22 08:21:25.111236	2023-03-22 08:21:25.111236	Under	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
11432	0.5	1.37	1201	2nd Half	3.63%	2023-03-22 08:24:21.282206	2023-03-22 08:24:21.282206	Over	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
11433	0.5	3.25	1201	2nd Half	3.63%	2023-03-22 08:24:21.289472	2023-03-22 08:24:21.289472	Under	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
11434	2.5	2.20	1202	Full Time	3.47%	2023-03-22 08:24:35.545373	2023-03-22 08:24:35.545373	Over	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
11435	2.5	1.72	1202	Full Time	3.47%	2023-03-22 08:24:35.552519	2023-03-22 08:24:35.552519	Under	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
11436	0.5	1.44	1202	1st Half	5.92%	2023-03-22 08:24:41.180531	2023-03-22 08:24:41.180531	Over	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
11437	0.5	2.70	1202	1st Half	5.92%	2023-03-22 08:24:41.183247	2023-03-22 08:24:41.183247	Under	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
11394	0.5	1.57	1194	1st Half	5.21%	2023-03-22 08:21:31.065051	2023-03-22 08:21:31.065051	Over	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
11395	0.5	2.39	1194	1st Half	5.21%	2023-03-22 08:21:31.074881	2023-03-22 08:21:31.074881	Under	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
11396	0.5	1.34	1194	2nd Half	5.12%	2023-03-22 08:21:35.711896	2023-03-22 08:21:35.711896	Over	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
11397	0.5	3.25	1194	2nd Half	5.12%	2023-03-22 08:21:35.716663	2023-03-22 08:21:35.716663	Under	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
11424	0.5	1.32	1200	1st Half	4.92%	2023-03-22 08:23:49.779152	2023-03-22 08:23:49.779152	Over	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
11425	0.5	3.40	1200	1st Half	4.92%	2023-03-22 08:23:49.782131	2023-03-22 08:23:49.782131	Under	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
11426	0.5	1.20	1200	2nd Half	5.26%	2023-03-22 08:23:54.90321	2023-03-22 08:23:54.90321	Over	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
11427	0.5	4.50	1200	2nd Half	5.26%	2023-03-22 08:23:54.910559	2023-03-22 08:23:54.910559	Under	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
11428	2.5	2.55	1201	Full Time	3.60%	2023-03-22 08:24:07.887861	2023-03-22 08:24:07.887861	Over	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
11429	2.5	1.55	1201	Full Time	3.60%	2023-03-22 08:24:07.891599	2023-03-22 08:24:07.891599	Under	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
11430	0.5	1.57	1201	1st Half	4.28%	2023-03-22 08:24:14.850689	2023-03-22 08:24:14.850689	Over	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
11431	0.5	2.45	1201	1st Half	4.28%	2023-03-22 08:24:14.856591	2023-03-22 08:24:14.856591	Under	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
11438	0.5	1.30	1202	2nd Half	5.21%	2023-03-22 08:24:46.680497	2023-03-22 08:24:46.680497	Over	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
11439	0.5	3.50	1202	2nd Half	5.21%	2023-03-22 08:24:46.686791	2023-03-22 08:24:46.686791	Under	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
11388	0.5	1.57	1137	1st Half	5.84%	2023-03-22 08:21:07.05135	2023-03-22 08:21:07.05135	Over	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
11389	0.5	2.35	1137	1st Half	5.84%	2023-03-22 08:21:07.055598	2023-03-22 08:21:07.055598	Under	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
10737	0.5	1.57	1135	1st Half	5.84%	2023-03-22 05:23:00.526212	2023-03-22 05:23:00.526212	Over	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
10738	0.5	2.35	1135	1st Half	5.84%	2023-03-22 05:23:00.529881	2023-03-22 05:23:00.529881	Under	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
10739	0.5	1.36	1135	2nd Half	6.28%	2023-03-22 05:23:06.215869	2023-03-22 05:23:06.215869	Over	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
10740	0.5	3.00	1135	2nd Half	6.28%	2023-03-22 05:23:06.218109	2023-03-22 05:23:06.218109	Under	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
10747	2.5	2.60	1137	Full Time	3.68%	2023-03-22 05:24:13.465966	2023-03-22 05:24:13.465966	Over	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
10748	2.5	1.53	1137	Full Time	3.68%	2023-03-22 05:24:13.471101	2023-03-22 05:24:13.471101	Under	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
11416	2.5	2.75	1195	Full Time	2.94%	2023-03-22 08:23:11.029339	2023-03-22 08:23:11.029339	Over	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
11417	2.5	1.50	1195	Full Time	2.94%	2023-03-22 08:23:19.933837	2023-03-22 08:23:19.933837	Under	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
11418	0.5	1.60	1195	1st Half	6.32%	2023-03-22 08:23:26.154414	2023-03-22 08:23:26.154414	Over	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
11419	0.5	2.26	1195	1st Half	6.32%	2023-03-22 08:23:26.157797	2023-03-22 08:23:26.157797	Under	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
11420	0.5	1.37	1195	2nd Half	5.95%	2023-03-22 08:23:31.109847	2023-03-22 08:23:31.109847	Over	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
11421	0.5	3.00	1195	2nd Half	5.95%	2023-03-22 08:23:31.119707	2023-03-22 08:23:31.119707	Under	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107,https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
11422	2.5	1.77	1200	Full Time	3.95%	2023-03-22 08:23:43.417255	2023-03-22 08:23:43.417255	Over	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
11423	2.5	2.10	1200	Full Time	3.95%	2023-03-22 08:23:43.42565	2023-03-22 08:23:43.42565	Under	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
10735	2.5	2.70	1135	Full Time	3.57%	2023-03-22 05:22:54.625449	2023-03-22 05:22:54.625449	Over	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
10736	2.5	1.50	1135	Full Time	3.57%	2023-03-22 05:22:54.631381	2023-03-22 05:22:54.631381	Under	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
\.


--
-- TOC entry 3107 (class 0 OID 25135)
-- Dependencies: 213
-- Data for Name: OverUnderHistorical; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."OverUnderHistorical" (id, "Date_Time", "Home_Team", "Guest_Team", "Type", "Half", "Odds_bet", "Margin", won, "Goals", "Home_Team_Goals", "Guest_Team_Goals", "Home_Team_Goals_1st_Half", "Home_Team_Goals_2nd_Half", "Guest_Team_Goals_1st_Half", "Guest_Team_Goals_2nd_Half", "Payout", "Bet_link") FROM stdin;
44	2023-02-24 20:00:00+02	Volos	Lamia	Under	Full Time	1.81	0	Won	2.5	1	1	0	1	1	0	1.73%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
33	2023-02-20 19:30:00+02	OFI	Aris Salonika	Over	\N	2.4	0	Won	2.5	0	3	0	0	2	1	3.28%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
34	2023-02-20 19:30:00+02	OFI	Aris Salonika	Under	\N	2.6	0	Lost	0.5	0	3	0	0	2	1	2.89%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
30	2023-02-20 18:00:00+02	Atromitos	Levadiakos	Under	\N	3.4	0.85	Lost	0.5	1	1	1	0	0	0	4.40%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
31	2023-02-20 18:00:00+02	Atromitos	Levadiakos	Under	\N	3.4	0	Lost	0.5	1	1	1	0	0	0	4.40%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
21	2023-02-19 19:30:00+02	Panetolikos	Ionikos	Under	\N	3.25	0	Lost	0.5	1	1	0	1	0	0	3.63%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
20	2023-02-19 19:30:00+02	Panetolikos	Ionikos	Under	\N	3.25	0	Lost	0.5	1	1	0	1	0	0	3.63%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
10	2023-02-19 16:00:00+02	Lamia	Olympiacos	Over	\N	2	0	Won	2.5	0	0	0	0	1	2	2.56%	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/,https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
11	2023-02-19 16:00:00+02	Lamia	Olympiacos	Under	\N	2.95	0	Lost	0.5	0	0	0	0	1	2	2.78%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
12	2023-02-19 16:00:00+02	Lamia	Olympiacos	Under	\N	3.9	0.95	Lost	0.5	0	0	0	0	1	2	4.20%	{}
1	2023-02-18 17:00:00+02	Panathinaikos	Volos	Over	\N	2.17	0	Lost	2.5	2	2	0	2	0	0	0.72%	{https://record.affiliates.betshop.gr/_xVrm1kU5pcRLcRLGwHoTKWNd7ZgqdRLk/1/}
57	2023-02-25 20:30:00+02	Olympiacos	Panathinaikos	Under	Full Time	1.74	0	Won	2.5	0	0	0	0	0	0	3.83%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107,https://partners.opapaffiliates.gr/redirect.aspx?pid=2460&bid=1759}
53	2023-02-25 19:00:00+02	PAS Giannina	PAOK	Under	Full Time	2.1	0	Won	2.5	0	0	0	0	0	0	4.25%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
50	2023-02-25 19:00:00+02	PAS Giannina	PAOK	Over	Full Time	1.76	0	Lost	2.5	0	0	0	0	0	0	4.25%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
2	2023-02-18 17:00:00+02	Panathinaikos	Volos	Under	\N	2.8	0	Lost	0.5	2	2	0	2	0	0	2.33%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
3	2023-02-18 17:00:00+02	Panathinaikos	Volos	Under	\N	3.7	0.9	Lost	0.5	2	2	0	2	0	0	3.80%	{}
74	2023-03-05 16:00:00+02	Olympiacos	Levadiakos	Under	1st Half	3.60	0.00	Lost	0.5	6	6	2	4	0	0	2.88%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
75	2023-03-05 16:00:00+02	Olympiacos	Levadiakos	Under	2nd Half	4.75	0.00	Lost	0.5	6	6	2	4	0	0	4.20%	{http://www.sportingbet.gr/,https://sports.bwin.gr/el/sports?wm=5273373}
76	2023-03-05 16:00:00+02	Olympiacos	Levadiakos	Under	Full Time	2.30	0.00	Lost	2.5	6	6	2	4	0	0	3.92%	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
70	2023-03-04 20:00:00+02	Asteras Tripolis	Atromitos	Over	Full Time	2.30	0.00	Lost	2.5	1	1	0	1	1	0	4.61%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107,https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145,https://record.affiliates.betshop.gr/_xVrm1kU5pcRLcRLGwHoTKWNd7ZgqdRLk/1/}
71	2023-03-04 20:00:00+02	Asteras Tripolis	Atromitos	Under	1st Half	2.55	0.00	Lost	0.5	1	1	0	1	1	0	2.83%	{http://www.sportingbet.gr/,https://sports.bwin.gr/el/sports?wm=5273373,https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
58	2023-02-26 16:00:00+02	Ionikos	OFI	Over	Full Time	2.30	0.00	Lost	2.5	0	0	0	0	0	2	4.26%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
59	2023-02-26 16:00:00+02	Ionikos	OFI	Under	2nd Half	2.60	0.00	Lost	0.5	0	0	0	0	0	2	2.11%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
60	2023-02-26 16:00:00+02	Ionikos	OFI	Under	1st Half	2.60	0.00	Lost	0.5	0	0	0	0	0	2	2.11%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
63	2023-02-26 16:00:00+02	Levadiakos	Panetolikos	Under	1st Half	2.45	0.00	Lost	0.5	0	0	0	0	0	0	3.21%	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
49	2023-02-25 17:30:00+02	AEK	Asteras Tripolis	Under	Full Time	2.1	0	Won	2.5	2	2	1	1	0	0	4.25%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
46	2023-02-25 17:30:00+02	AEK	Asteras Tripolis	Over	Full Time	1.76	0	Lost	2.5	2	2	1	1	0	0	4.25%	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
37	2023-02-24 20:00:00+02	Volos	Lamia	Over	Full Time	2.15	0.1	Lost	2.5	1	1	0	1	1	0	1.73%	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
38	2023-02-24 20:00:00+02	Volos	Lamia	Over	Full Time	2.15	0	Lost	2.5	1	1	0	1	1	0	1.73%	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
35	2023-02-20 19:30:00+02	OFI	Aris Salonika	Under	\N	3.4	0.8	Lost	0.5	0	3	0	0	2	1	4.40%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
64	2023-02-26 16:00:00+02	Levadiakos	Panetolikos	Under	1st Half	2.45	0.00	Lost	0.5	0	0	0	0	0	0	3.21%	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
51	2023-02-25 19:00:00+02	PAS Giannina	PAOK	Under	1st Half	3.3	0	Lost	0.5	0	0	0	0	0	0	2.69%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
47	2023-02-25 17:30:00+02	AEK	Asteras Tripolis	Under	1st Half	3.3	0	Lost	0.5	2	2	1	1	0	0	2.69%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
32	2023-02-20 18:00:00+02	Atromitos	Levadiakos	Under	\N	3.4	0	Lost	0.5	1	1	1	0	0	0	4.40%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
4	2023-02-18 17:00:00+02	Panathinaikos	Volos	Under	\N	3.7	0	Lost	0.5	2	2	0	2	0	0	3.80%	{}
40	2023-02-24 20:00:00+02	Volos	Lamia	Under	1st Half	2.9	0	Lost	0.5	1	1	0	1	1	0	1.14%	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
5	2023-02-18 17:00:00+02	Panathinaikos	Volos	Under	\N	1.83	0	Lost	2.5	2	2	0	2	0	0	0.72%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
15	2023-02-19 19:30:00+02	Panetolikos	Ionikos	Over	\N	2.5	0	Lost	2.5	1	1	0	1	0	0	1.70%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107,https://partners.opapaffiliates.gr/redirect.aspx?pid=2460&bid=1759,https://record.affiliates.betshop.gr/_xVrm1kU5pcRLcRLGwHoTKWNd7ZgqdRLk/1/}
16	2023-02-19 19:30:00+02	Panetolikos	Ionikos	Over	\N	2.5	0	Lost	2.5	1	1	0	1	0	0	1.70%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107,https://partners.opapaffiliates.gr/redirect.aspx?pid=2460&bid=1759,https://record.affiliates.betshop.gr/_xVrm1kU5pcRLcRLGwHoTKWNd7ZgqdRLk/1/}
17	2023-02-19 19:30:00+02	Panetolikos	Ionikos	Under	\N	2.45	0	Lost	0.5	1	1	0	1	0	0	3.21%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
13	2023-02-19 16:00:00+02	Lamia	Olympiacos	Under	\N	3.9	0	Lost	0.5	0	0	0	0	1	2	4.20%	{}
14	2023-02-19 16:00:00+02	Lamia	Olympiacos	Under	\N	1.9	0	Lost	2.5	0	0	0	0	1	2	2.56%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
54	2023-02-25 20:30:00+02	Olympiacos	Panathinaikos	Over	Full Time	2.15	0	Lost	2.5	0	0	0	0	0	0	3.83%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
52	2023-02-25 19:00:00+02	PAS Giannina	PAOK	Under	2nd Half	4.4	0	Lost	0.5	0	0	0	0	0	0	4.36%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
48	2023-02-25 17:30:00+02	AEK	Asteras Tripolis	Under	2nd Half	4.4	0	Lost	0.5	2	2	1	1	0	0	4.36%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
6	2023-02-18 20:00:00+02	Asteras Tripolis	PAS Giannina	Over	\N	2.55	0	Lost	2.5	1	1	1	0	1	0	2.07%	{https://record.affiliates.betshop.gr/_xVrm1kU5pcRLcRLGwHoTKWNd7ZgqdRLk/1/}
100	2023-03-18 17:00:00+02	Asteras Tripolis	Panetolikos	Over	Full Time	2.52	0.00	Lost	2.5	2	2	1	1	0	1	2.14%	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
94	2023-03-06 19:30:00+02	Panathinaikos	Panetolikos	Over	Full Time	2.03	0.01	Lost	2.5	2	0	0	2	0	0	4.32%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
84	2023-03-05 19:30:00+02	OFI	AEK	Over	Full Time	2.00	0.00	Lost	2.5	0	0	0	0	1	2	1.78%	{}
80	2023-03-05 17:30:00+02	Lamia	Aris Salonika	Over	Full Time	2.09	0.00	Lost	2.5	2	2	2	0	1	0	3.00%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
81	2023-03-05 17:30:00+02	Lamia	Aris Salonika	Under	1st Half	2.90	0.00	Lost	0.5	2	2	2	0	1	0	2.45%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
82	2023-03-05 17:30:00+02	Lamia	Aris Salonika	Under	2nd Half	3.75	0.00	Lost	0.5	2	2	2	0	1	0	5.13%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
79	2023-03-05 17:00:00+02	PAS Giannina	Volos	Under	2nd Half	3.40	0.00	Lost	0.5	0	0	0	0	0	1	4.40%	{http://www.sportingbet.gr/,https://sports.bwin.gr/el/sports?wm=5273373,https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/,http://www.stoiximan.gr/,https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
61	2023-02-26 16:00:00+02	Levadiakos	Panetolikos	Over	Full Time	2.60	0.00	Lost	2.5	0	0	0	0	0	0	1.72%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
62	2023-02-26 16:00:00+02	Levadiakos	Panetolikos	Over	Full Time	2.60	0.00	Lost	2.5	0	0	0	0	0	0	1.72%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
55	2023-02-25 20:30:00+02	Olympiacos	Panathinaikos	Under	1st Half	2.8	0	Lost	0.5	0	0	0	0	0	0	1.48%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
36	2023-02-20 19:30:00+02	OFI	Aris Salonika	Under	\N	3.4	0	Lost	0.5	0	3	0	0	2	1	4.40%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
26	2023-02-20 18:00:00+02	Atromitos	Levadiakos	Over	\N	2.4	0	Lost	2.5	1	1	1	0	0	0	3.46%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
27	2023-02-20 18:00:00+02	Atromitos	Levadiakos	Under	\N	2.55	0.05	Lost	0.5	1	1	1	0	0	0	2.83%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
28	2023-02-20 18:00:00+02	Atromitos	Levadiakos	Under	\N	3.4	0.9	Lost	0.5	1	1	1	0	0	0	4.40%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
22	2023-02-19 20:30:00+02	PAOK	AEK	Over	\N	2.45	0	Lost	2.5	2	0	1	1	0	0	2.48%	{https://record.affiliates.betshop.gr/_xVrm1kU5pcRLcRLGwHoTKWNd7ZgqdRLk/1/}
56	2023-02-25 20:30:00+02	Olympiacos	Panathinaikos	Under	2nd Half	3.75	0	Lost	0.5	0	0	0	0	0	0	3.47%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
23	2023-02-19 20:30:00+02	PAOK	AEK	Under	\N	2.5	0	Lost	0.5	2	0	1	1	0	0	2.44%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
24	2023-02-19 20:30:00+02	PAOK	AEK	Under	\N	3.25	0.75	Lost	0.5	2	0	1	1	0	0	5.47%	{http://www.stoiximan.gr/,https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
7	2023-02-18 20:00:00+02	Asteras Tripolis	PAS Giannina	Under	\N	2.45	0	Lost	0.5	1	1	1	0	1	0	3.21%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
85	2023-03-05 19:30:00+02	OFI	AEK	Under	1st Half	2.95	0.00	Lost	0.5	0	0	0	0	1	2	3.23%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
86	2023-03-05 19:30:00+02	OFI	AEK	Under	2nd Half	3.90	0.00	Lost	0.5	0	0	0	0	1	2	4.77%	{}
87	2023-03-05 19:30:00+02	OFI	AEK	Under	Full Time	1.93	0.00	Lost	2.5	0	0	0	0	1	2	1.78%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
29	2023-02-20 18:00:00+02	Atromitos	Levadiakos	Under	\N	2.55	0	Lost	0.5	1	1	1	0	0	0	2.83%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
8	2023-02-18 20:00:00+02	Asteras Tripolis	PAS Giannina	Under	\N	3.25	0.8	Lost	0.5	1	1	1	0	1	0	3.63%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
9	2023-02-18 20:00:00+02	Asteras Tripolis	PAS Giannina	Under	\N	3.25	0	Lost	0.5	1	1	1	0	1	0	3.63%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
39	2023-02-24 20:00:00+02	Volos	Lamia	Over	1st Half	2.15	0	Won	2.5	1	1	0	1	1	0	1.73%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
115	2023-03-19 17:30:00+02	Volos	Olympiacos	Under	1st Half	3.45	0.00	Lost	0.5	0	0	0	0	2	1	1.94%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
116	2023-03-19 17:30:00+02	Volos	Olympiacos	Under	2nd Half	4.47	0.00	Lost	0.5	0	0	0	0	2	1	5.40%	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
119	2023-03-19 19:00:00+02	Aris Salonika	PAOK	Over	Full Time	2.55	0.00	Lost	2.5	1	1	1	0	0	2	0.56%	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
120	2023-03-19 19:00:00+02	Aris Salonika	PAOK	Under	1st Half	2.45	0.00	Lost	0.5	1	1	1	0	0	2	4.32%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
121	2023-03-19 19:00:00+02	Aris Salonika	PAOK	Under	2nd Half	3.25	0.00	Lost	0.5	1	1	1	0	0	2	3.63%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
117	2023-03-19 17:30:00+02	Volos	Olympiacos	Under	Full Time	2.20	0.00	Lost	2.5	0	0	0	0	2	1	1.61%	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
88	2023-03-05 20:30:00+02	PAOK	Ionikos	Over	Full Time	1.92	0.01	Lost	2.5	6	0	4	2	0	0	3.26%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
89	2023-03-05 20:30:00+02	PAOK	Ionikos	Over	Full Time	1.92	0.00	Lost	2.5	6	0	4	2	0	0	3.26%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
90	2023-03-05 20:30:00+02	PAOK	Ionikos	Under	1st Half	3.10	0.00	Lost	0.5	6	0	4	2	0	0	2.61%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
73	2023-03-04 20:00:00+02	Asteras Tripolis	Atromitos	Under	2nd Half	3.40	0.00	Lost	0.5	1	1	0	1	1	0	4.40%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
107	2023-03-18 19:30:00+02	Atromitos	Ionikos	Over	Full Time	2.72	0.00	Lost	2.5	2	2	1	1	0	0	0.46%	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
108	2023-03-18 19:30:00+02	Atromitos	Ionikos	Under	1st Half	2.40	0.00	Lost	0.5	2	2	1	1	0	0	3.28%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
109	2023-03-18 19:30:00+02	Atromitos	Ionikos	Under	2nd Half	3.25	0.00	Lost	0.5	2	2	1	1	0	0	3.13%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
103	2023-03-18 17:30:00+02	OFI	Levadiakos	Over	Full Time	2.45	0.00	Lost	2.5	1	1	0	1	0	1	-0.36%	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
95	2023-03-06 19:30:00+02	Panathinaikos	Panetolikos	Over	Full Time	2.03	0.00	Lost	2.5	2	0	0	2	0	0	4.32%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
96	2023-03-06 19:30:00+02	Panathinaikos	Panetolikos	Under	1st Half	2.95	0.00	Lost	0.5	2	0	0	2	0	0	2.78%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
97	2023-03-06 19:30:00+02	Panathinaikos	Panetolikos	Under	2nd Half	3.75	0.00	Lost	0.5	2	0	0	2	0	0	5.13%	{http://www.sportingbet.gr/,https://sports.bwin.gr/el/sports?wm=5273373,https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
99	2023-03-06 19:30:00+02	Panathinaikos	Panetolikos	Under	Full Time	1.81	0.00	Lost	2.5	2	0	0	2	0	0	4.32%	{https://record.affiliates.betshop.gr/_xVrm1kU5pcRLcRLGwHoTKWNd7ZgqdRLk/1/}
91	2023-03-05 20:30:00+02	PAOK	Ionikos	Under	2nd Half	4.05	0.05	Lost	0.5	6	0	4	2	0	0	4.48%	{http://www.stoiximan.gr/}
67	2023-02-26 19:30:00+02	Aris Salonika	Atromitos	Over	Full Time	2.60	0.00	Lost	2.5	2	1	2	0	0	1	1.72%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
68	2023-02-26 19:30:00+02	Aris Salonika	Atromitos	Under	1st Half	2.45	0.00	Lost	0.5	2	1	2	0	0	1	3.21%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
69	2023-02-26 19:30:00+02	Aris Salonika	Atromitos	Under	2nd Half	3.25	0.00	Lost	0.5	2	1	2	0	0	1	3.63%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
65	2023-02-26 16:00:00+02	Levadiakos	Panetolikos	Under	2nd Half	3.25	0.00	Lost	0.5	0	0	0	0	0	0	3.63%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
66	2023-02-26 16:00:00+02	Levadiakos	Panetolikos	Under	2nd Half	3.25	0.00	Lost	0.5	0	0	0	0	0	0	3.63%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
42	2023-02-24 20:00:00+02	Volos	Lamia	Under	2nd Half	3.75	0	Lost	0.5	1	1	0	1	1	0	4.02%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
43	2023-02-24 20:00:00+02	Volos	Lamia	Under	1st Half	1.81	0.73	Lost	2.5	1	1	0	1	1	0	1.73%	{https://partners.opapaffiliates.gr/redirect.aspx?pid=2460&bid=1759}
110	2023-03-18 21:00:00+02	Lamia	PAS Giannina	Over	Full Time	2.77	0.00	Lost	2.5	2	0	2	0	0	0	1.44%	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
111	2023-03-18 21:00:00+02	Lamia	PAS Giannina	Under	1st Half	2.45	0.00	Lost	0.5	2	0	2	0	0	0	1.40%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
104	2023-03-18 17:30:00+02	OFI	Levadiakos	Under	1st Half	2.60	0.00	Lost	0.5	1	1	0	1	0	1	2.89%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
105	2023-03-18 17:30:00+02	OFI	Levadiakos	Under	2nd Half	3.25	0.00	Lost	0.5	1	1	0	1	0	1	5.47%	{http://www.sportingbet.gr/,https://sports.bwin.gr/el/sports?wm=5273373,https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=,https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
92	2023-03-05 20:30:00+02	PAOK	Ionikos	Under	2nd Half	4.05	0.00	Lost	0.5	6	0	4	2	0	0	4.48%	{http://www.stoiximan.gr/}
45	2023-02-24 20:00:00+02	Volos	Lamia	Under	1st Half	1.81	0	Lost	2.5	1	1	0	1	1	0	1.73%	{https://partners.opapaffiliates.gr/redirect.aspx?pid=2460&bid=1759}
112	2023-03-18 21:00:00+02	Lamia	PAS Giannina	Under	2nd Half	3.25	0.00	Lost	0.5	2	0	2	0	0	0	2.64%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
72	2023-03-04 20:00:00+02	Asteras Tripolis	Atromitos	Under	2nd Half	3.40	0.00	Lost	0.5	1	1	0	1	1	0	4.40%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
41	2023-02-24 20:00:00+02	Volos	Lamia	Under	2nd Half	3.75	0	Lost	0.5	1	1	0	1	1	0	4.02%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
122	2023-03-19 21:30:00+02	AEK	Panathinaikos	Over	Full Time	2.60	0.00	Lost	2.5	0	0	0	0	0	0	2.50%	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
25	2023-02-19 20:30:00+02	PAOK	AEK	Under	\N	3.25	0	Lost	0.5	2	0	1	1	0	0	5.47%	{http://www.stoiximan.gr/,https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
18	2023-02-19 19:30:00+02	Panetolikos	Ionikos	Under	\N	3.25	0.8	Lost	0.5	1	1	0	1	0	0	3.63%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
19	2023-02-19 19:30:00+02	Panetolikos	Ionikos	Under	\N	3.25	0.75	Lost	0.5	1	1	0	1	0	0	3.63%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
114	2023-03-19 17:30:00+02	Volos	Olympiacos	Over	1st Half	1.78	0.00	Won	2.5	0	0	0	0	2	1	1.61%	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
123	2023-03-19 21:30:00+02	AEK	Panathinaikos	Under	1st Half	2.45	0.00	Lost	0.5	0	0	0	0	0	0	3.21%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
124	2023-03-19 21:30:00+02	AEK	Panathinaikos	Under	2nd Half	3.25	0.00	Lost	0.5	0	0	0	0	0	0	3.63%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
113	2023-03-19 17:30:00+02	Volos	Olympiacos	Over	Full Time	1.78	0.00	Lost	2.5	0	0	0	0	2	1	1.61%	{}
118	2023-03-19 17:30:00+02	Volos	Olympiacos	Under	1st Half	2.20	0.00	Lost	2.5	0	0	0	0	2	1	1.61%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
106	2023-03-18 17:30:00+02	OFI	Levadiakos	Under	Full Time	1.70	0.00	Lost	2.5	1	1	0	1	0	1	-0.36%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
101	2023-03-18 17:00:00+02	Asteras Tripolis	Panetolikos	Under	1st Half	2.50	0.00	Lost	0.5	2	2	1	1	0	1	3.56%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
102	2023-03-18 17:00:00+02	Asteras Tripolis	Panetolikos	Under	2nd Half	3.25	0.00	Lost	0.5	2	2	1	1	0	1	4.62%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
98	2023-03-06 19:30:00+02	Panathinaikos	Panetolikos	Under	2nd Half	3.75	0.00	Lost	0.5	2	0	0	2	0	0	5.13%	{http://www.sportingbet.gr/,https://sports.bwin.gr/el/sports?wm=5273373,https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
93	2023-03-05 20:30:00+02	PAOK	Ionikos	Under	Full Time	1.95	0.00	Lost	2.5	6	0	4	2	0	0	3.26%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436,https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/,https://www.bet365.gr/olp/open-account?affiliate=365_01012107,https://record.affiliates.betshop.gr/_xVrm1kU5pcRLcRLGwHoTKWNd7ZgqdRLk/1/}
83	2023-03-05 17:30:00+02	Lamia	Aris Salonika	Under	Full Time	1.81	0.00	Lost	2.5	2	2	2	0	1	0	3.00%	{https://record.affiliates.betshop.gr/_xVrm1kU5pcRLcRLGwHoTKWNd7ZgqdRLk/1/}
77	2023-03-05 17:00:00+02	PAS Giannina	Volos	Over	Full Time	2.30	0.00	Lost	2.5	0	0	0	0	0	1	3.59%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107,https://record.affiliates.betshop.gr/_xVrm1kU5pcRLcRLGwHoTKWNd7ZgqdRLk/1/}
78	2023-03-05 17:00:00+02	PAS Giannina	Volos	Under	1st Half	2.60	0.00	Lost	0.5	0	0	0	0	0	1	4.08%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436,https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
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

SELECT pg_catalog.setval('public."Match_id_seq"', 1413, true);


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

SELECT pg_catalog.setval('public."OverUnder_id_seq"', 14262, true);


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


-- Completed on 2023-03-30 03:46:36 EEST

--
-- PostgreSQL database dump complete
--


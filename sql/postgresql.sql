--
-- PostgreSQL database dump
--

-- Dumped from database version 13.9 (Debian 13.9-0+deb11u1)
-- Dumped by pg_dump version 13.9 (Debian 13.9-0+deb11u1)

-- Started on 2023-03-27 01:56:34 EEST

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
10849	0.5	1.11	1144	Full Time	95.8%	2023-03-22 07:19:39.704129	2023-03-22 07:19:39.704129	Over	{}
10743	3.5	5.50	1135	Full Time	96.5%	2023-03-22 07:11:32.903606	2023-03-22 07:11:32.903606	Over	{}
10744	3.5	1.17	1135	Full Time	96.5%	2023-03-22 07:11:32.905235	2023-03-22 07:11:32.905235	Under	{}
10745	4.5	13.00	1135	Full Time	97.2%	2023-03-22 07:11:32.906771	2023-03-22 07:11:32.906771	Over	{}
10746	4.5	1.05	1135	Full Time	97.2%	2023-03-22 07:11:32.908166	2023-03-22 07:11:32.908166	Under	{}
10747	5.5	29.00	1135	Full Time	97.6%	2023-03-22 07:11:32.909933	2023-03-22 07:11:32.909933	Over	{}
10748	5.5	1.01	1135	Full Time	97.6%	2023-03-22 07:11:32.911569	2023-03-22 07:11:32.911569	Under	{}
10805	0.5	1.57	1135	1st Half	94.6%	2023-03-22 07:17:25.262429	2023-03-22 07:17:25.262429	Over	{}
10806	0.5	2.38	1135	1st Half	94.6%	2023-03-22 07:17:26.752093	2023-03-22 07:17:26.752093	Under	{}
10807	0.75	1.90	1135	1st Half	95.0%	2023-03-22 07:17:26.75432	2023-03-22 07:17:26.75432	Over	{}
10808	0.75	1.90	1135	1st Half	95.0%	2023-03-22 07:17:26.756644	2023-03-22 07:17:26.756644	Under	{}
10809	1.5	3.75	1135	1st Half	96.5%	2023-03-22 07:17:26.75797	2023-03-22 07:17:26.75797	Over	{}
10810	1.5	1.30	1135	1st Half	96.5%	2023-03-22 07:17:26.759965	2023-03-22 07:17:26.759965	Under	{}
10811	2.5	13.00	1135	1st Half	97.2%	2023-03-22 07:17:26.761132	2023-03-22 07:17:26.761132	Over	{}
10812	2.5	1.05	1135	1st Half	97.2%	2023-03-22 07:17:26.762503	2023-03-22 07:17:26.762503	Under	{}
10813	3.5	31.00	1135	1st Half	97.8%	2023-03-22 07:17:26.763698	2023-03-22 07:17:26.763698	Over	{}
10814	3.5	1.01	1135	1st Half	97.8%	2023-03-22 07:17:26.764839	2023-03-22 07:17:26.764839	Under	{}
10815	4.5	71.00	1135	1st Half	98.6%	2023-03-22 07:17:26.766559	2023-03-22 07:17:26.766559	Over	{}
10841	0.5	1.40	1135	2nd Half	95.5%	2023-03-22 07:19:29.09543	2023-03-22 07:19:29.09543	Over	{}
10842	0.5	3.00	1135	2nd Half	95.5%	2023-03-22 07:19:30.121666	2023-03-22 07:19:30.121666	Under	{}
10843	1.5	2.75	1135	2nd Half	94.5%	2023-03-22 07:19:30.124764	2023-03-22 07:19:30.124764	Over	{}
10845	2.5	7.00	1135	2nd Half	95.8%	2023-03-22 07:19:30.12929	2023-03-22 07:19:30.12929	Over	{}
10846	2.5	1.11	1135	2nd Half	95.8%	2023-03-22 07:19:30.13207	2023-03-22 07:19:30.13207	Under	{}
10847	3.5	21.00	1135	2nd Half	97.3%	2023-03-22 07:19:30.134846	2023-03-22 07:19:30.134846	Over	{}
10848	3.5	1.02	1135	2nd Half	97.3%	2023-03-22 07:19:30.137065	2023-03-22 07:19:30.137065	Under	{}
10742	2.5	1.50	1135	Full Time	95.1%	2023-03-22 07:11:32.901746	2023-03-22 07:11:32.901746	Under	{}
10850	0.5	7.00	1144	Full Time	95.8%	2023-03-22 07:19:39.707307	2023-03-22 07:19:39.707307	Under	{}
10851	1.5	1.53	1144	Full Time	94.9%	2023-03-22 07:19:39.709832	2023-03-22 07:19:39.709832	Over	{}
10852	1.5	2.50	1144	Full Time	94.9%	2023-03-22 07:19:39.712061	2023-03-22 07:19:39.712061	Under	{}
10853	2.0	1.93	1144	Full Time	96.5%	2023-03-22 07:19:39.714404	2023-03-22 07:19:39.714404	Over	{}
10854	2.0	1.93	1144	Full Time	96.5%	2023-03-22 07:19:39.71623	2023-03-22 07:19:39.71623	Under	{}
10855	2.5	2.50	1144	Full Time	93.8%	2023-03-22 07:19:39.71791	2023-03-22 07:19:39.71791	Over	{}
10856	2.5	1.50	1144	Full Time	93.8%	2023-03-22 07:19:39.720234	2023-03-22 07:19:39.720234	Under	{}
10857	3.5	5.00	1144	Full Time	94.8%	2023-03-22 07:19:39.722936	2023-03-22 07:19:39.722936	Over	{}
10858	3.5	1.17	1144	Full Time	94.8%	2023-03-22 07:19:39.725475	2023-03-22 07:19:39.725475	Under	{}
10859	4.5	11.00	1144	Full Time	95.9%	2023-03-22 07:19:39.727584	2023-03-22 07:19:39.727584	Over	{}
10860	4.5	1.05	1144	Full Time	95.9%	2023-03-22 07:19:39.729172	2023-03-22 07:19:39.729172	Under	{}
10861	5.5	26.00	1144	Full Time	97.2%	2023-03-22 07:19:39.731257	2023-03-22 07:19:39.731257	Over	{}
10862	5.5	1.01	1144	Full Time	97.2%	2023-03-22 07:19:39.733474	2023-03-22 07:19:39.733474	Under	{}
10863	0.5	1.57	1144	1st Half	94.6%	2023-03-22 07:19:41.473777	2023-03-22 07:19:41.473777	Over	{}
10864	0.5	2.38	1144	1st Half	94.6%	2023-03-22 07:19:42.574312	2023-03-22 07:19:42.574312	Under	{}
10865	0.75	1.83	1144	1st Half	95.1%	2023-03-22 07:19:42.576203	2023-03-22 07:19:42.576203	Over	{}
10866	0.75	1.98	1144	1st Half	95.1%	2023-03-22 07:19:42.57827	2023-03-22 07:19:42.57827	Under	{}
10867	1.5	3.75	1144	1st Half	96.0%	2023-03-22 07:19:42.580068	2023-03-22 07:19:42.580068	Over	{}
10868	1.5	1.29	1144	1st Half	96.0%	2023-03-22 07:19:42.582408	2023-03-22 07:19:42.582408	Under	{}
10869	2.5	11.00	1144	1st Half	95.9%	2023-03-22 07:19:42.584083	2023-03-22 07:19:42.584083	Over	{}
10870	2.5	1.05	1144	1st Half	95.9%	2023-03-22 07:19:42.586316	2023-03-22 07:19:42.586316	Under	{}
10871	0.5	1.40	1144	2nd Half	97.8%	2023-03-22 07:19:44.384346	2023-03-22 07:19:44.384346	Over	{}
10872	0.5	3.25	1144	2nd Half	97.8%	2023-03-22 07:19:45.413843	2023-03-22 07:19:45.413843	Under	{}
10873	1.5	2.63	1144	2nd Half	93.1%	2023-03-22 07:19:45.414966	2023-03-22 07:19:45.414966	Over	{}
10874	1.5	1.44	1144	2nd Half	93.1%	2023-03-22 07:19:45.416007	2023-03-22 07:19:45.416007	Under	{}
10876	2.5	1.10	1144	2nd Half	95.1%	2023-03-22 07:19:45.418343	2023-03-22 07:19:45.418343	Under	{}
10877	3.5	19.00	1144	2nd Half	96.8%	2023-03-22 07:19:45.419658	2023-03-22 07:19:45.419658	Over	{}
10878	3.5	1.02	1144	2nd Half	96.8%	2023-03-22 07:19:45.421088	2023-03-22 07:19:45.421088	Under	{}
10879	0.5	1.11	1147	Full Time	94.8%	2023-03-22 07:19:55.269219	2023-03-22 07:19:55.269219	Over	{}
10735	0.5	1.11	1135	Full Time	94.8%	2023-03-22 07:11:32.886771	2023-03-22 07:11:32.886771	Over	{}
10736	0.5	6.50	1135	Full Time	94.8%	2023-03-22 07:11:32.89151	2023-03-22 07:11:32.89151	Under	{}
10737	1.5	1.53	1135	Full Time	94.9%	2023-03-22 07:11:32.893506	2023-03-22 07:11:32.893506	Over	{}
10738	1.5	2.50	1135	Full Time	94.9%	2023-03-22 07:11:32.895614	2023-03-22 07:11:32.895614	Under	{}
10739	2.0	2.02	1135	Full Time	96.0%	2023-03-22 07:11:32.897006	2023-03-22 07:11:32.897006	Over	{}
10740	2.0	1.83	1135	Full Time	96.0%	2023-03-22 07:11:32.898787	2023-03-22 07:11:32.898787	Under	{}
10741	2.5	2.60	1135	Full Time	95.1%	2023-03-22 07:11:32.900175	2023-03-22 07:11:32.900175	Over	{}
10887	3.5	5.00	1147	Full Time	94.8%	2023-03-22 07:19:55.281299	2023-03-22 07:19:55.281299	Over	{}
10888	3.5	1.17	1147	Full Time	94.8%	2023-03-22 07:19:55.282399	2023-03-22 07:19:55.282399	Under	{}
10889	4.5	11.00	1147	Full Time	95.9%	2023-03-22 07:19:55.283343	2023-03-22 07:19:55.283343	Over	{}
10890	4.5	1.05	1147	Full Time	95.9%	2023-03-22 07:19:55.284456	2023-03-22 07:19:55.284456	Under	{}
10891	5.5	26.00	1147	Full Time	98.1%	2023-03-22 07:19:55.2858	2023-03-22 07:19:55.2858	Over	{}
10892	5.5	1.02	1147	Full Time	98.1%	2023-03-22 07:19:55.287615	2023-03-22 07:19:55.287615	Under	{}
10893	0.5	1.57	1147	1st Half	96.4%	2023-03-22 07:19:57.025185	2023-03-22 07:19:57.025185	Over	{}
10894	0.5	2.50	1147	1st Half	96.4%	2023-03-22 07:19:58.656079	2023-03-22 07:19:58.656079	Under	{}
10895	0.75	1.83	1147	1st Half	95.1%	2023-03-22 07:19:58.658286	2023-03-22 07:19:58.658286	Over	{}
10896	0.75	1.98	1147	1st Half	95.1%	2023-03-22 07:19:58.660736	2023-03-22 07:19:58.660736	Under	{}
10897	1.5	3.75	1147	1st Half	96.0%	2023-03-22 07:19:58.663151	2023-03-22 07:19:58.663151	Over	{}
10898	1.5	1.29	1147	1st Half	96.0%	2023-03-22 07:19:58.665245	2023-03-22 07:19:58.665245	Under	{}
10899	2.5	11.00	1147	1st Half	95.9%	2023-03-22 07:19:58.667718	2023-03-22 07:19:58.667718	Over	{}
10900	2.5	1.05	1147	1st Half	95.9%	2023-03-22 07:19:58.669681	2023-03-22 07:19:58.669681	Under	{}
10901	3.5	29.00	1147	1st Half	97.6%	2023-03-22 07:19:58.671961	2023-03-22 07:19:58.671961	Over	{}
10902	3.5	1.01	1147	1st Half	97.6%	2023-03-22 07:19:58.673588	2023-03-22 07:19:58.673588	Under	{}
10903	4.5	71.00	1147	1st Half	98.6%	2023-03-22 07:19:58.675357	2023-03-22 07:19:58.675357	Over	{}
10904	0.5	1.40	1147	2nd Half	97.8%	2023-03-22 07:20:04.772563	2023-03-22 07:20:04.772563	Over	{}
10905	0.5	3.25	1147	2nd Half	97.8%	2023-03-22 07:20:05.797373	2023-03-22 07:20:05.797373	Under	{}
10906	1.5	2.63	1147	2nd Half	93.1%	2023-03-22 07:20:05.798521	2023-03-22 07:20:05.798521	Over	{}
10907	1.5	1.44	1147	2nd Half	93.1%	2023-03-22 07:20:05.799676	2023-03-22 07:20:05.799676	Under	{}
10908	2.5	6.50	1147	2nd Half	94.8%	2023-03-22 07:20:05.800722	2023-03-22 07:20:05.800722	Over	{}
10909	2.5	1.11	1147	2nd Half	94.8%	2023-03-22 07:20:05.80174	2023-03-22 07:20:05.80174	Under	{}
10910	3.5	19.00	1147	2nd Half	96.8%	2023-03-22 07:20:05.802969	2023-03-22 07:20:05.802969	Over	{}
10911	3.5	1.02	1147	2nd Half	96.8%	2023-03-22 07:20:05.804239	2023-03-22 07:20:05.804239	Under	{}
11008	0.5	1.12	1159	Full Time	96.6%	2023-03-22 07:25:33.665804	2023-03-22 07:25:33.665804	Over	{}
11009	0.5	7.00	1159	Full Time	96.6%	2023-03-22 07:25:33.668163	2023-03-22 07:25:33.668163	Under	{}
11010	1.5	1.53	1159	Full Time	93.1%	2023-03-22 07:25:33.670353	2023-03-22 07:25:33.670353	Over	{}
11011	1.5	2.38	1159	Full Time	93.1%	2023-03-22 07:25:33.671162	2023-03-22 07:25:33.671162	Under	{}
11012	2.0	2.02	1159	Full Time	96.0%	2023-03-22 07:25:33.672195	2023-03-22 07:25:33.672195	Over	{}
11013	2.0	1.83	1159	Full Time	96.0%	2023-03-22 07:25:33.673179	2023-03-22 07:25:33.673179	Under	{}
11014	2.5	2.70	1159	Full Time	94.3%	2023-03-22 07:25:33.674394	2023-03-22 07:25:33.674394	Over	{}
10884	2.0	1.93	1147	Full Time	96.5%	2023-03-22 07:19:55.277091	2023-03-22 07:19:55.277091	Under	{}
10885	2.5	2.50	1147	Full Time	93.8%	2023-03-22 07:19:55.279066	2023-03-22 07:19:55.279066	Over	{}
10886	2.5	1.50	1147	Full Time	93.8%	2023-03-22 07:19:55.279886	2023-03-22 07:19:55.279886	Under	{}
11015	2.5	1.45	1159	Full Time	94.3%	2023-03-22 07:25:33.675429	2023-03-22 07:25:33.675429	Under	{}
11016	3.5	5.50	1159	Full Time	94.4%	2023-03-22 07:25:33.676421	2023-03-22 07:25:33.676421	Over	{}
11017	3.5	1.14	1159	Full Time	94.4%	2023-03-22 07:25:33.677456	2023-03-22 07:25:33.677456	Under	{}
11018	4.5	13.00	1159	Full Time	96.3%	2023-03-22 07:25:33.678791	2023-03-22 07:25:33.678791	Over	{}
11019	4.5	1.04	1159	Full Time	96.3%	2023-03-22 07:25:33.680289	2023-03-22 07:25:33.680289	Under	{}
11020	5.5	29.00	1159	Full Time	97.6%	2023-03-22 07:25:33.681424	2023-03-22 07:25:33.681424	Over	{}
11021	5.5	1.01	1159	Full Time	97.6%	2023-03-22 07:25:33.682482	2023-03-22 07:25:33.682482	Under	{}
11022	0.5	1.62	1159	1st Half	94.2%	2023-03-22 07:25:35.582955	2023-03-22 07:25:35.582955	Over	{}
11023	0.5	2.25	1159	1st Half	94.2%	2023-03-22 07:25:37.176865	2023-03-22 07:25:37.176865	Under	{}
11024	0.75	1.90	1159	1st Half	95.0%	2023-03-22 07:25:37.178946	2023-03-22 07:25:37.178946	Over	{}
11025	0.75	1.90	1159	1st Half	95.0%	2023-03-22 07:25:37.18081	2023-03-22 07:25:37.18081	Under	{}
11026	1.5	3.75	1159	1st Half	93.8%	2023-03-22 07:25:37.182581	2023-03-22 07:25:37.182581	Over	{}
11027	1.5	1.25	1159	1st Half	93.8%	2023-03-22 07:25:37.184168	2023-03-22 07:25:37.184168	Under	{}
11028	2.5	13.00	1159	1st Half	96.3%	2023-03-22 07:25:37.186135	2023-03-22 07:25:37.186135	Over	{}
11029	2.5	1.04	1159	1st Half	96.3%	2023-03-22 07:25:37.188336	2023-03-22 07:25:37.188336	Under	{}
11030	3.5	34.00	1159	1st Half	98.1%	2023-03-22 07:25:37.190328	2023-03-22 07:25:37.190328	Over	{}
11031	3.5	1.01	1159	1st Half	98.1%	2023-03-22 07:25:37.192229	2023-03-22 07:25:37.192229	Under	{}
11032	4.5	81.00	1159	1st Half	98.8%	2023-03-22 07:25:37.193566	2023-03-22 07:25:37.193566	Over	{}
10844	1.5	1.44	1135	2nd Half	94.5%	2023-03-22 07:19:30.127119	2023-03-22 07:19:30.127119	Under	{}
10875	2.5	7.00	1144	2nd Half	95.1%	2023-03-22 07:19:45.417048	2023-03-22 07:19:45.417048	Over	{}
10880	0.5	6.50	1147	Full Time	94.8%	2023-03-22 07:19:55.271547	2023-03-22 07:19:55.271547	Under	{}
10881	1.5	1.50	1147	Full Time	93.8%	2023-03-22 07:19:55.273035	2023-03-22 07:19:55.273035	Over	{}
10882	1.5	2.50	1147	Full Time	93.8%	2023-03-22 07:19:55.274293	2023-03-22 07:19:55.274293	Under	{}
10883	2.0	1.93	1147	Full Time	96.5%	2023-03-22 07:19:55.275633	2023-03-22 07:19:55.275633	Over	{}
11040	3.5	1.02	1159	2nd Half	97.3%	2023-03-22 07:25:40.027942	2023-03-22 07:25:40.027942	Under	{}
11041	0.5	1.05	1162	Full Time	98.1%	2023-03-22 07:25:50.979984	2023-03-22 07:25:50.979984	Over	{}
11042	0.5	15.00	1162	Full Time	98.1%	2023-03-22 07:25:50.983148	2023-03-22 07:25:50.983148	Under	{}
11043	1.5	1.29	1162	Full Time	97.5%	2023-03-22 07:25:50.984969	2023-03-22 07:25:50.984969	Over	{}
11044	1.5	4.00	1162	Full Time	97.5%	2023-03-22 07:25:50.986459	2023-03-22 07:25:50.986459	Under	{}
11045	2.5	1.80	1162	Full Time	95.8%	2023-03-22 07:25:50.988117	2023-03-22 07:25:50.988117	Over	{}
11046	2.5	2.05	1162	Full Time	95.8%	2023-03-22 07:25:50.989699	2023-03-22 07:25:50.989699	Under	{}
11047	2.75	2.00	1162	Full Time	96.1%	2023-03-22 07:25:50.991392	2023-03-22 07:25:50.991392	Over	{}
11050	3.5	1.40	1162	Full Time	95.5%	2023-03-22 07:25:50.995854	2023-03-22 07:25:50.995854	Under	{}
11051	4.5	5.50	1162	Full Time	94.4%	2023-03-22 07:25:50.997354	2023-03-22 07:25:50.997354	Over	{}
11052	4.5	1.14	1162	Full Time	94.4%	2023-03-22 07:25:50.998763	2023-03-22 07:25:50.998763	Under	{}
11053	5.5	11.00	1162	Full Time	95.9%	2023-03-22 07:25:51.000335	2023-03-22 07:25:51.000335	Over	{}
11048	2.75	1.85	1162	Full Time	96.1%	2023-03-22 07:25:50.993133	2023-03-22 07:25:50.993133	Under	{}
11049	3.5	3.00	1162	Full Time	95.5%	2023-03-22 07:25:50.994485	2023-03-22 07:25:50.994485	Over	{}
11054	5.5	1.05	1162	Full Time	95.9%	2023-03-22 07:25:51.00201	2023-03-22 07:25:51.00201	Under	{}
11055	6.5	23.00	1162	Full Time	96.8%	2023-03-22 07:25:51.003885	2023-03-22 07:25:51.003885	Over	{}
11056	6.5	1.01	1162	Full Time	96.8%	2023-03-22 07:25:51.005579	2023-03-22 07:25:51.005579	Under	{}
11057	0.5	1.36	1162	1st Half	97.1%	2023-03-22 07:25:52.865126	2023-03-22 07:25:52.865126	Over	{}
11058	0.5	3.40	1162	1st Half	97.1%	2023-03-22 07:25:54.360016	2023-03-22 07:25:54.360016	Under	{}
11062	1.5	1.50	1162	1st Half	95.4%	2023-03-22 07:25:54.365288	2023-03-22 07:25:54.365288	Under	{}
11063	2.5	6.00	1162	1st Half	95.1%	2023-03-22 07:25:54.366509	2023-03-22 07:25:54.366509	Over	{}
11064	2.5	1.13	1162	1st Half	95.1%	2023-03-22 07:25:54.367528	2023-03-22 07:25:54.367528	Under	{}
11065	3.5	17.00	1162	1st Half	96.2%	2023-03-22 07:25:54.368616	2023-03-22 07:25:54.368616	Over	{}
11066	3.5	1.02	1162	1st Half	96.2%	2023-03-22 07:25:54.369908	2023-03-22 07:25:54.369908	Under	{}
11059	1.25	2.10	1162	1st Half	93.9%	2023-03-22 07:25:54.362198	2023-03-22 07:25:54.362198	Over	{}
11060	1.25	1.70	1162	1st Half	93.9%	2023-03-22 07:25:54.363239	2023-03-22 07:25:54.363239	Under	{}
11067	4.5	41.00	1162	1st Half	98.6%	2023-03-22 07:25:54.372247	2023-03-22 07:25:54.372247	Over	{}
11068	4.5	1.01	1162	1st Half	98.6%	2023-03-22 07:25:54.373643	2023-03-22 07:25:54.373643	Under	{}
11069	0.5	1.29	1162	2nd Half	100.3%	2023-03-22 07:25:56.290553	2023-03-22 07:25:56.290553	Over	{}
11070	0.5	4.50	1162	2nd Half	100.3%	2023-03-22 07:25:57.666726	2023-03-22 07:25:57.666726	Under	{}
11071	1.5	2.05	1162	2nd Half	95.8%	2023-03-22 07:25:57.667581	2023-03-22 07:25:57.667581	Over	{}
11072	1.5	1.80	1162	2nd Half	95.8%	2023-03-22 07:25:57.668544	2023-03-22 07:25:57.668544	Under	{}
11073	2.5	4.50	1162	2nd Half	96.0%	2023-03-22 07:25:57.669391	2023-03-22 07:25:57.669391	Over	{}
11074	2.5	1.22	1162	2nd Half	96.0%	2023-03-22 07:25:57.670709	2023-03-22 07:25:57.670709	Under	{}
11075	3.5	10.00	1162	2nd Half	95.8%	2023-03-22 07:25:57.673045	2023-03-22 07:25:57.673045	Over	{}
11076	3.5	1.06	1162	2nd Half	95.8%	2023-03-22 07:25:57.675409	2023-03-22 07:25:57.675409	Under	{}
11077	4.5	23.00	1162	2nd Half	96.8%	2023-03-22 07:25:57.676905	2023-03-22 07:25:57.676905	Over	{}
11078	4.5	1.01	1162	2nd Half	96.8%	2023-03-22 07:25:57.678349	2023-03-22 07:25:57.678349	Under	{}
11079	0.5	1.11	1165	Full Time	95.8%	2023-03-22 07:26:07.708396	2023-03-22 07:26:07.708396	Over	{}
11080	0.5	7.00	1165	Full Time	95.8%	2023-03-22 07:26:07.711225	2023-03-22 07:26:07.711225	Under	{}
11081	1.5	1.50	1165	Full Time	93.8%	2023-03-22 07:26:07.713643	2023-03-22 07:26:07.713643	Over	{}
11082	1.5	2.50	1165	Full Time	93.8%	2023-03-22 07:26:07.716128	2023-03-22 07:26:07.716128	Under	{}
11083	2.0	1.90	1165	Full Time	96.2%	2023-03-22 07:26:07.718267	2023-03-22 07:26:07.718267	Over	{}
11084	2.0	1.95	1165	Full Time	96.2%	2023-03-22 07:26:07.720454	2023-03-22 07:26:07.720454	Under	{}
11085	2.5	2.50	1165	Full Time	93.8%	2023-03-22 07:26:07.723014	2023-03-22 07:26:07.723014	Over	{}
11086	2.5	1.50	1165	Full Time	93.8%	2023-03-22 07:26:07.724483	2023-03-22 07:26:07.724483	Under	{}
11087	3.5	5.00	1165	Full Time	94.8%	2023-03-22 07:26:07.726228	2023-03-22 07:26:07.726228	Over	{}
11088	3.5	1.17	1165	Full Time	94.8%	2023-03-22 07:26:07.727947	2023-03-22 07:26:07.727947	Under	{}
11089	4.5	11.00	1165	Full Time	95.9%	2023-03-22 07:26:07.729439	2023-03-22 07:26:07.729439	Over	{}
11090	4.5	1.05	1165	Full Time	95.9%	2023-03-22 07:26:07.731515	2023-03-22 07:26:07.731515	Under	{}
11091	5.5	26.00	1165	Full Time	97.2%	2023-03-22 07:26:07.733632	2023-03-22 07:26:07.733632	Over	{}
11093	0.5	1.57	1165	1st Half	96.4%	2023-03-22 07:26:09.941534	2023-03-22 07:26:09.941534	Over	{}
11094	0.5	2.50	1165	1st Half	96.4%	2023-03-22 07:26:11.490567	2023-03-22 07:26:11.490567	Under	{}
11095	0.75	1.83	1165	1st Half	95.1%	2023-03-22 07:26:11.492961	2023-03-22 07:26:11.492961	Over	{}
11096	0.75	1.98	1165	1st Half	95.1%	2023-03-22 07:26:11.497116	2023-03-22 07:26:11.497116	Under	{}
11097	1.5	3.75	1165	1st Half	96.0%	2023-03-22 07:26:11.499328	2023-03-22 07:26:11.499328	Over	{}
11034	0.5	3.00	1159	2nd Half	95.5%	2023-03-22 07:25:40.015194	2023-03-22 07:25:40.015194	Under	{}
11035	1.5	2.75	1159	2nd Half	94.5%	2023-03-22 07:25:40.017344	2023-03-22 07:25:40.017344	Over	{}
11036	1.5	1.44	1159	2nd Half	94.5%	2023-03-22 07:25:40.019314	2023-03-22 07:25:40.019314	Under	{}
11037	2.5	7.00	1159	2nd Half	95.1%	2023-03-22 07:25:40.021041	2023-03-22 07:25:40.021041	Over	{}
11038	2.5	1.10	1159	2nd Half	95.1%	2023-03-22 07:25:40.02314	2023-03-22 07:25:40.02314	Under	{}
11039	3.5	21.00	1159	2nd Half	97.3%	2023-03-22 07:25:40.025466	2023-03-22 07:25:40.025466	Over	{}
11109	2.5	1.11	1165	2nd Half	94.8%	2023-03-22 07:26:14.316219	2023-03-22 07:26:14.316219	Under	{}
11114	1.5	1.38	1168	Full Time	94.5%	2023-03-22 07:26:24.397803	2023-03-22 07:26:24.397803	Over	{}
11115	1.5	3.00	1168	Full Time	94.5%	2023-03-22 07:26:24.399167	2023-03-22 07:26:24.399167	Under	{}
11119	2.5	1.67	1168	Full Time	94.0%	2023-03-22 07:26:24.405297	2023-03-22 07:26:24.405297	Under	{}
11120	3.5	4.00	1168	Full Time	95.2%	2023-03-22 07:26:24.406722	2023-03-22 07:26:24.406722	Over	{}
11124	5.5	19.00	1168	Full Time	96.8%	2023-03-22 07:26:24.41261	2023-03-22 07:26:24.41261	Over	{}
11125	5.5	1.02	1168	Full Time	96.8%	2023-03-22 07:26:24.413862	2023-03-22 07:26:24.413862	Under	{}
11126	6.5	41.00	1168	Full Time	97.6%	2023-03-22 07:26:24.415294	2023-03-22 07:26:24.415294	Over	{}
11129	1.0	2.08	1168	1st Half	94.4%	2023-03-22 07:26:27.875654	2023-03-22 07:26:27.875654	Over	{}
11130	1.0	1.73	1168	1st Half	94.4%	2023-03-22 07:26:27.877193	2023-03-22 07:26:27.877193	Under	{}
11131	1.5	3.25	1168	1st Half	94.4%	2023-03-22 07:26:27.878753	2023-03-22 07:26:27.878753	Over	{}
11132	1.5	1.33	1168	1st Half	94.4%	2023-03-22 07:26:27.880455	2023-03-22 07:26:27.880455	Under	{}
11134	2.5	1.07	1168	1st Half	95.6%	2023-03-22 07:26:27.88346	2023-03-22 07:26:27.88346	Under	{}
11135	3.5	26.00	1168	1st Half	97.2%	2023-03-22 07:26:27.884861	2023-03-22 07:26:27.884861	Over	{}
11136	3.5	1.01	1168	1st Half	97.2%	2023-03-22 07:26:27.886417	2023-03-22 07:26:27.886417	Under	{}
11137	4.5	61.00	1168	1st Half	98.4%	2023-03-22 07:26:27.889491	2023-03-22 07:26:27.889491	Over	{}
11138	0.5	1.29	1168	2nd Half	94.3%	2023-03-22 07:26:30.166996	2023-03-22 07:26:30.166996	Over	{}
11139	0.5	3.50	1168	2nd Half	94.3%	2023-03-22 07:26:31.35138	2023-03-22 07:26:31.35138	Under	{}
11140	1.5	2.35	1168	2nd Half	94.1%	2023-03-22 07:26:31.35414	2023-03-22 07:26:31.35414	Over	{}
11141	1.5	1.57	1168	2nd Half	94.1%	2023-03-22 07:26:31.356574	2023-03-22 07:26:31.356574	Under	{}
11142	2.5	5.50	1168	2nd Half	94.4%	2023-03-22 07:26:31.358702	2023-03-22 07:26:31.358702	Over	{}
11143	2.5	1.14	1168	2nd Half	94.4%	2023-03-22 07:26:31.36116	2023-03-22 07:26:31.36116	Under	{}
11144	3.5	15.00	1168	2nd Half	96.4%	2023-03-22 07:26:31.362896	2023-03-22 07:26:31.362896	Over	{}
11145	3.5	1.03	1168	2nd Half	96.4%	2023-03-22 07:26:31.364456	2023-03-22 07:26:31.364456	Under	{}
12510	6.5	46.00	1135	Full Time	97.9%	2023-03-25 21:44:35.199277	2023-03-25 21:44:35.199277	Over	{}
11861	1.0	1.70	1162	1st Half	93.9%	2023-03-23 23:20:00.628463	2023-03-23 23:20:00.628463	Over	{}
11862	1.0	2.10	1162	1st Half	93.9%	2023-03-23 23:20:00.631464	2023-03-23 23:20:00.631464	Under	{}
11061	1.5	2.62	1162	1st Half	95.4%	2023-03-22 07:25:54.364247	2023-03-22 07:25:54.364247	Over	{}
11092	5.5	1.01	1165	Full Time	97.2%	2023-03-22 07:26:07.735657	2023-03-22 07:26:07.735657	Under	{}
12682	6.5	41.00	1165	Full Time	97.6%	2023-03-25 21:46:05.787406	2023-03-25 21:46:05.787406	Over	{}
11099	2.5	11.00	1165	1st Half	95.9%	2023-03-22 07:26:11.50262	2023-03-22 07:26:11.50262	Over	{}
11100	2.5	1.05	1165	1st Half	95.9%	2023-03-22 07:26:11.503513	2023-03-22 07:26:11.503513	Under	{}
11101	3.5	31.00	1165	1st Half	97.8%	2023-03-22 07:26:11.504382	2023-03-22 07:26:11.504382	Over	{}
11102	3.5	1.01	1165	1st Half	97.8%	2023-03-22 07:26:11.505257	2023-03-22 07:26:11.505257	Under	{}
11103	4.5	71.00	1165	1st Half	98.6%	2023-03-22 07:26:11.506223	2023-03-22 07:26:11.506223	Over	{}
11104	0.5	1.40	1165	2nd Half	97.8%	2023-03-22 07:26:13.363644	2023-03-22 07:26:13.363644	Over	{}
11105	0.5	3.25	1165	2nd Half	97.8%	2023-03-22 07:26:14.309189	2023-03-22 07:26:14.309189	Under	{}
11106	1.5	2.63	1165	2nd Half	93.1%	2023-03-22 07:26:14.311014	2023-03-22 07:26:14.311014	Over	{}
11107	1.5	1.44	1165	2nd Half	93.1%	2023-03-22 07:26:14.312813	2023-03-22 07:26:14.312813	Under	{}
11108	2.5	6.50	1165	2nd Half	94.8%	2023-03-22 07:26:14.314344	2023-03-22 07:26:14.314344	Over	{}
11110	3.5	19.00	1165	2nd Half	96.8%	2023-03-22 07:26:14.317574	2023-03-22 07:26:14.317574	Over	{}
11111	3.5	1.02	1165	2nd Half	96.8%	2023-03-22 07:26:14.31896	2023-03-22 07:26:14.31896	Under	{}
11112	0.5	1.08	1168	Full Time	95.2%	2023-03-22 07:26:24.393681	2023-03-22 07:26:24.393681	Over	{}
11113	0.5	8.00	1168	Full Time	95.2%	2023-03-22 07:26:24.395708	2023-03-22 07:26:24.395708	Under	{}
11116	2.25	1.93	1168	Full Time	96.5%	2023-03-22 07:26:24.400475	2023-03-22 07:26:24.400475	Over	{}
11117	2.25	1.93	1168	Full Time	96.5%	2023-03-22 07:26:24.40248	2023-03-22 07:26:24.40248	Under	{}
11118	2.5	2.15	1168	Full Time	94.0%	2023-03-22 07:26:24.403885	2023-03-22 07:26:24.403885	Over	{}
11121	3.5	1.25	1168	Full Time	95.2%	2023-03-22 07:26:24.407868	2023-03-22 07:26:24.407868	Under	{}
11122	4.5	9.00	1168	Full Time	96.4%	2023-03-22 07:26:24.409139	2023-03-22 07:26:24.409139	Over	{}
11123	4.5	1.08	1168	Full Time	96.4%	2023-03-22 07:26:24.410566	2023-03-22 07:26:24.410566	Under	{}
11127	0.5	1.44	1168	1st Half	93.1%	2023-03-22 07:26:26.174365	2023-03-22 07:26:26.174365	Over	{}
11128	0.5	2.63	1168	1st Half	93.1%	2023-03-22 07:26:27.87301	2023-03-22 07:26:27.87301	Under	{}
11133	2.5	9.00	1168	1st Half	95.6%	2023-03-22 07:26:27.882059	2023-03-22 07:26:27.882059	Over	{}
12544	6.5	46.00	1144	Full Time	97.9%	2023-03-25 21:44:51.684978	2023-03-25 21:44:51.684978	Over	{}
12553	3.5	31.00	1144	1st Half	97.8%	2023-03-25 21:44:55.930911	2023-03-25 21:44:55.930911	Over	{}
12554	3.5	1.01	1144	1st Half	97.8%	2023-03-25 21:44:55.932977	2023-03-25 21:44:55.932977	Under	{}
12555	4.5	71.00	1144	1st Half	98.6%	2023-03-25 21:44:55.934099	2023-03-25 21:44:55.934099	Over	{}
12578	6.5	41.00	1147	Full Time	97.6%	2023-03-25 21:45:09.905933	2023-03-25 21:45:09.905933	Over	{}
12612	6.5	46.00	1159	Full Time	97.9%	2023-03-25 21:45:28.130549	2023-03-25 21:45:28.130549	Over	{}
11033	0.5	1.40	1159	2nd Half	95.5%	2023-03-22 07:25:38.759269	2023-03-22 07:25:38.759269	Over	{}
11098	1.5	1.29	1165	1st Half	96.0%	2023-03-22 07:26:11.500926	2023-03-22 07:26:11.500926	Under	{}
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
10735	2.5	2.70	1135	Full Time	3.99%	2023-03-22 05:22:54.625449	2023-03-22 05:22:54.625449	Over	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
10736	2.5	1.49	1135	Full Time	3.99%	2023-03-22 05:22:54.631381	2023-03-22 05:22:54.631381	Under	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
11421	0.5	3.00	1195	2nd Half	5.95%	2023-03-22 08:23:31.119707	2023-03-22 08:23:31.119707	Under	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107,https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
11422	2.5	1.77	1200	Full Time	3.95%	2023-03-22 08:23:43.417255	2023-03-22 08:23:43.417255	Over	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
11423	2.5	2.10	1200	Full Time	3.95%	2023-03-22 08:23:43.42565	2023-03-22 08:23:43.42565	Under	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
\.


--
-- TOC entry 3107 (class 0 OID 25135)
-- Dependencies: 213
-- Data for Name: OverUnderHistorical; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."OverUnderHistorical" (id, "Date_Time", "Home_Team", "Guest_Team", "Type", "Half", "Odds_bet", "Margin", won, "Goals", "Home_Team_Goals", "Guest_Team_Goals", "Home_Team_Goals_1st_Half", "Home_Team_Goals_2nd_Half", "Guest_Team_Goals_1st_Half", "Guest_Team_Goals_2nd_Half", "Payout", "Bet_link") FROM stdin;
57	2023-02-25 20:30:00+02	Olympiacos	Panathinaikos	Under	Full Time	1.74	0	Won	2.5	0	0	0	0	0	0	3.83%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107,https://partners.opapaffiliates.gr/redirect.aspx?pid=2460&bid=1759}
53	2023-02-25 19:00:00+02	PAS Giannina	PAOK	Under	Full Time	2.1	0	Won	2.5	0	0	0	0	0	0	4.25%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
50	2023-02-25 19:00:00+02	PAS Giannina	PAOK	Over	Full Time	1.76	0	Lost	2.5	0	0	0	0	0	0	4.25%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
49	2023-02-25 17:30:00+02	AEK	Asteras Tripolis	Under	Full Time	2.1	0	Won	2.5	2	2	1	1	0	0	4.25%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
46	2023-02-25 17:30:00+02	AEK	Asteras Tripolis	Over	Full Time	1.76	0	Lost	2.5	2	2	1	1	0	0	4.25%	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
44	2023-02-24 20:00:00+02	Volos	Lamia	Under	Full Time	1.81	0	Won	2.5	1	1	0	1	1	0	1.73%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
37	2023-02-24 20:00:00+02	Volos	Lamia	Over	Full Time	2.15	0.1	Lost	2.5	1	1	0	1	1	0	1.73%	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
38	2023-02-24 20:00:00+02	Volos	Lamia	Over	Full Time	2.15	0	Lost	2.5	1	1	0	1	1	0	1.73%	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
33	2023-02-20 19:30:00+02	OFI	Aris Salonika	Over	\N	2.4	0	Won	2.5	0	3	0	0	2	1	3.28%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
34	2023-02-20 19:30:00+02	OFI	Aris Salonika	Under	\N	2.6	0	Lost	0.5	0	3	0	0	2	1	2.89%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
35	2023-02-20 19:30:00+02	OFI	Aris Salonika	Under	\N	3.4	0.8	Lost	0.5	0	3	0	0	2	1	4.40%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
70	2023-03-04 20:00:00+02	Asteras Tripolis	Atromitos	Over	Full Time	2.30	0.00	Lost	2.5	1	1	0	1	1	0	4.61%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107,https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145,https://record.affiliates.betshop.gr/_xVrm1kU5pcRLcRLGwHoTKWNd7ZgqdRLk/1/}
71	2023-03-04 20:00:00+02	Asteras Tripolis	Atromitos	Under	1st Half	2.55	0.00	Lost	0.5	1	1	0	1	1	0	2.83%	{http://www.sportingbet.gr/,https://sports.bwin.gr/el/sports?wm=5273373,https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
58	2023-02-26 16:00:00+02	Ionikos	OFI	Over	Full Time	2.30	0.00	Lost	2.5	0	0	0	0	0	2	4.26%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
30	2023-02-20 18:00:00+02	Atromitos	Levadiakos	Under	\N	3.4	0.85	Lost	0.5	1	1	1	0	0	0	4.40%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
31	2023-02-20 18:00:00+02	Atromitos	Levadiakos	Under	\N	3.4	0	Lost	0.5	1	1	1	0	0	0	4.40%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
32	2023-02-20 18:00:00+02	Atromitos	Levadiakos	Under	\N	3.4	0	Lost	0.5	1	1	1	0	0	0	4.40%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
21	2023-02-19 19:30:00+02	Panetolikos	Ionikos	Under	\N	3.25	0	Lost	0.5	1	1	0	1	0	0	3.63%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
20	2023-02-19 19:30:00+02	Panetolikos	Ionikos	Under	\N	3.25	0	Lost	0.5	1	1	0	1	0	0	3.63%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
10	2023-02-19 16:00:00+02	Lamia	Olympiacos	Over	\N	2	0	Won	2.5	0	0	0	0	1	2	2.56%	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/,https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
11	2023-02-19 16:00:00+02	Lamia	Olympiacos	Under	\N	2.95	0	Lost	0.5	0	0	0	0	1	2	2.78%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
12	2023-02-19 16:00:00+02	Lamia	Olympiacos	Under	\N	3.9	0.95	Lost	0.5	0	0	0	0	1	2	4.20%	{}
1	2023-02-18 17:00:00+02	Panathinaikos	Volos	Over	\N	2.17	0	Lost	2.5	2	2	0	2	0	0	0.72%	{https://record.affiliates.betshop.gr/_xVrm1kU5pcRLcRLGwHoTKWNd7ZgqdRLk/1/}
2	2023-02-18 17:00:00+02	Panathinaikos	Volos	Under	\N	2.8	0	Lost	0.5	2	2	0	2	0	0	2.33%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
3	2023-02-18 17:00:00+02	Panathinaikos	Volos	Under	\N	3.7	0.9	Lost	0.5	2	2	0	2	0	0	3.80%	{}
59	2023-02-26 16:00:00+02	Ionikos	OFI	Under	2nd Half	2.60	0.00	Lost	0.5	0	0	0	0	0	2	2.11%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
60	2023-02-26 16:00:00+02	Ionikos	OFI	Under	1st Half	2.60	0.00	Lost	0.5	0	0	0	0	0	2	2.11%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
63	2023-02-26 16:00:00+02	Levadiakos	Panetolikos	Under	1st Half	2.45	0.00	Lost	0.5	0	0	0	0	0	0	3.21%	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
64	2023-02-26 16:00:00+02	Levadiakos	Panetolikos	Under	1st Half	2.45	0.00	Lost	0.5	0	0	0	0	0	0	3.21%	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
51	2023-02-25 19:00:00+02	PAS Giannina	PAOK	Under	1st Half	3.3	0	Lost	0.5	0	0	0	0	0	0	2.69%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
74	2023-03-05 16:00:00+02	Olympiacos	Levadiakos	Under	1st Half	3.60	0.00	Lost	0.5	6	6	2	4	0	0	2.88%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
75	2023-03-05 16:00:00+02	Olympiacos	Levadiakos	Under	2nd Half	4.75	0.00	Lost	0.5	6	6	2	4	0	0	4.20%	{http://www.sportingbet.gr/,https://sports.bwin.gr/el/sports?wm=5273373}
76	2023-03-05 16:00:00+02	Olympiacos	Levadiakos	Under	Full Time	2.30	0.00	Lost	2.5	6	6	2	4	0	0	3.92%	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
47	2023-02-25 17:30:00+02	AEK	Asteras Tripolis	Under	1st Half	3.3	0	Lost	0.5	2	2	1	1	0	0	2.69%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
4	2023-02-18 17:00:00+02	Panathinaikos	Volos	Under	\N	3.7	0	Lost	0.5	2	2	0	2	0	0	3.80%	{}
40	2023-02-24 20:00:00+02	Volos	Lamia	Under	1st Half	2.9	0	Lost	0.5	1	1	0	1	1	0	1.14%	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
5	2023-02-18 17:00:00+02	Panathinaikos	Volos	Under	\N	1.83	0	Lost	2.5	2	2	0	2	0	0	0.72%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
52	2023-02-25 19:00:00+02	PAS Giannina	PAOK	Under	2nd Half	4.4	0	Lost	0.5	0	0	0	0	0	0	4.36%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
48	2023-02-25 17:30:00+02	AEK	Asteras Tripolis	Under	2nd Half	4.4	0	Lost	0.5	2	2	1	1	0	0	4.36%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
36	2023-02-20 19:30:00+02	OFI	Aris Salonika	Under	\N	3.4	0	Lost	0.5	0	3	0	0	2	1	4.40%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
26	2023-02-20 18:00:00+02	Atromitos	Levadiakos	Over	\N	2.4	0	Lost	2.5	1	1	1	0	0	0	3.46%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
27	2023-02-20 18:00:00+02	Atromitos	Levadiakos	Under	\N	2.55	0.05	Lost	0.5	1	1	1	0	0	0	2.83%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
94	2023-03-06 19:30:00+02	Panathinaikos	Panetolikos	Over	Full Time	2.03	0.01	Lost	2.5	2	0	0	2	0	0	4.32%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
80	2023-03-05 17:30:00+02	Lamia	Aris Salonika	Over	Full Time	2.09	0.00	Lost	2.5	2	2	2	0	1	0	3.00%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
81	2023-03-05 17:30:00+02	Lamia	Aris Salonika	Under	1st Half	2.90	0.00	Lost	0.5	2	2	2	0	1	0	2.45%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
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
82	2023-03-05 17:30:00+02	Lamia	Aris Salonika	Under	2nd Half	3.75	0.00	Lost	0.5	2	2	2	0	1	0	5.13%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
79	2023-03-05 17:00:00+02	PAS Giannina	Volos	Under	2nd Half	3.40	0.00	Lost	0.5	0	0	0	0	0	1	4.40%	{http://www.sportingbet.gr/,https://sports.bwin.gr/el/sports?wm=5273373,https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/,http://www.stoiximan.gr/,https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
61	2023-02-26 16:00:00+02	Levadiakos	Panetolikos	Over	Full Time	2.60	0.00	Lost	2.5	0	0	0	0	0	0	1.72%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
62	2023-02-26 16:00:00+02	Levadiakos	Panetolikos	Over	Full Time	2.60	0.00	Lost	2.5	0	0	0	0	0	0	1.72%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
54	2023-02-25 20:30:00+02	Olympiacos	Panathinaikos	Over	Full Time	2.15	0	Lost	2.5	0	0	0	0	0	0	3.83%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
100	2023-03-18 17:00:00+02	Asteras Tripolis	Panetolikos	Over	Full Time	2.52	0.00	Lost	2.5	2	2	1	1	0	1	2.14%	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
84	2023-03-05 19:30:00+02	OFI	AEK	Over	Full Time	2.00	0.00	Lost	2.5	0	0	0	0	1	2	1.78%	{}
85	2023-03-05 19:30:00+02	OFI	AEK	Under	1st Half	2.95	0.00	Lost	0.5	0	0	0	0	1	2	3.23%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
86	2023-03-05 19:30:00+02	OFI	AEK	Under	2nd Half	3.90	0.00	Lost	0.5	0	0	0	0	1	2	4.77%	{}
87	2023-03-05 19:30:00+02	OFI	AEK	Under	Full Time	1.93	0.00	Lost	2.5	0	0	0	0	1	2	1.78%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
55	2023-02-25 20:30:00+02	Olympiacos	Panathinaikos	Under	1st Half	2.8	0	Lost	0.5	0	0	0	0	0	0	1.48%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
56	2023-02-25 20:30:00+02	Olympiacos	Panathinaikos	Under	2nd Half	3.75	0	Lost	0.5	0	0	0	0	0	0	3.47%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
29	2023-02-20 18:00:00+02	Atromitos	Levadiakos	Under	\N	2.55	0	Lost	0.5	1	1	1	0	0	0	2.83%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
7	2023-02-18 20:00:00+02	Asteras Tripolis	PAS Giannina	Under	\N	2.45	0	Lost	0.5	1	1	1	0	1	0	3.21%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
8	2023-02-18 20:00:00+02	Asteras Tripolis	PAS Giannina	Under	\N	3.25	0.8	Lost	0.5	1	1	1	0	1	0	3.63%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
9	2023-02-18 20:00:00+02	Asteras Tripolis	PAS Giannina	Under	\N	3.25	0	Lost	0.5	1	1	1	0	1	0	3.63%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
65	2023-02-26 16:00:00+02	Levadiakos	Panetolikos	Under	2nd Half	3.25	0.00	Lost	0.5	0	0	0	0	0	0	3.63%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
66	2023-02-26 16:00:00+02	Levadiakos	Panetolikos	Under	2nd Half	3.25	0.00	Lost	0.5	0	0	0	0	0	0	3.63%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
42	2023-02-24 20:00:00+02	Volos	Lamia	Under	2nd Half	3.75	0	Lost	0.5	1	1	0	1	1	0	4.02%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
73	2023-03-04 20:00:00+02	Asteras Tripolis	Atromitos	Under	2nd Half	3.40	0.00	Lost	0.5	1	1	0	1	1	0	4.40%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
67	2023-02-26 19:30:00+02	Aris Salonika	Atromitos	Over	Full Time	2.60	0.00	Lost	2.5	2	1	2	0	0	1	1.72%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
68	2023-02-26 19:30:00+02	Aris Salonika	Atromitos	Under	1st Half	2.45	0.00	Lost	0.5	2	1	2	0	0	1	3.21%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
43	2023-02-24 20:00:00+02	Volos	Lamia	Under	1st Half	1.81	0.73	Lost	2.5	1	1	0	1	1	0	1.73%	{https://partners.opapaffiliates.gr/redirect.aspx?pid=2460&bid=1759}
110	2023-03-18 21:00:00+02	Lamia	PAS Giannina	Over	Full Time	2.77	0.00	Lost	2.5	2	0	2	0	0	0	1.44%	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
111	2023-03-18 21:00:00+02	Lamia	PAS Giannina	Under	1st Half	2.45	0.00	Lost	0.5	2	0	2	0	0	0	1.40%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
112	2023-03-18 21:00:00+02	Lamia	PAS Giannina	Under	2nd Half	3.25	0.00	Lost	0.5	2	0	2	0	0	0	2.64%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
107	2023-03-18 19:30:00+02	Atromitos	Ionikos	Over	Full Time	2.72	0.00	Lost	2.5	2	2	1	1	0	0	0.46%	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
39	2023-02-24 20:00:00+02	Volos	Lamia	Over	1st Half	2.15	0	Won	2.5	1	1	0	1	1	0	1.73%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
119	2023-03-19 19:00:00+02	Aris Salonika	PAOK	Over	Full Time	2.55	0.00	Lost	2.5	1	1	1	0	0	2	0.56%	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
120	2023-03-19 19:00:00+02	Aris Salonika	PAOK	Under	1st Half	2.45	0.00	Lost	0.5	1	1	1	0	0	2	4.32%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
121	2023-03-19 19:00:00+02	Aris Salonika	PAOK	Under	2nd Half	3.25	0.00	Lost	0.5	1	1	1	0	0	2	3.63%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
115	2023-03-19 17:30:00+02	Volos	Olympiacos	Under	1st Half	3.45	0.00	Lost	0.5	0	0	0	0	2	1	1.94%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
116	2023-03-19 17:30:00+02	Volos	Olympiacos	Under	2nd Half	4.47	0.00	Lost	0.5	0	0	0	0	2	1	5.40%	{https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
103	2023-03-18 17:30:00+02	OFI	Levadiakos	Over	Full Time	2.45	0.00	Lost	2.5	1	1	0	1	0	1	-0.36%	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
104	2023-03-18 17:30:00+02	OFI	Levadiakos	Under	1st Half	2.60	0.00	Lost	0.5	1	1	0	1	0	1	2.89%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
117	2023-03-19 17:30:00+02	Volos	Olympiacos	Under	Full Time	2.20	0.00	Lost	2.5	0	0	0	0	2	1	1.61%	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
105	2023-03-18 17:30:00+02	OFI	Levadiakos	Under	2nd Half	3.25	0.00	Lost	0.5	1	1	0	1	0	1	5.47%	{http://www.sportingbet.gr/,https://sports.bwin.gr/el/sports?wm=5273373,https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=,https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
95	2023-03-06 19:30:00+02	Panathinaikos	Panetolikos	Over	Full Time	2.03	0.00	Lost	2.5	2	0	0	2	0	0	4.32%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
96	2023-03-06 19:30:00+02	Panathinaikos	Panetolikos	Under	1st Half	2.95	0.00	Lost	0.5	2	0	0	2	0	0	2.78%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
97	2023-03-06 19:30:00+02	Panathinaikos	Panetolikos	Under	2nd Half	3.75	0.00	Lost	0.5	2	0	0	2	0	0	5.13%	{http://www.sportingbet.gr/,https://sports.bwin.gr/el/sports?wm=5273373,https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
99	2023-03-06 19:30:00+02	Panathinaikos	Panetolikos	Under	Full Time	1.81	0.00	Lost	2.5	2	0	0	2	0	0	4.32%	{https://record.affiliates.betshop.gr/_xVrm1kU5pcRLcRLGwHoTKWNd7ZgqdRLk/1/}
88	2023-03-05 20:30:00+02	PAOK	Ionikos	Over	Full Time	1.92	0.01	Lost	2.5	6	0	4	2	0	0	3.26%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
89	2023-03-05 20:30:00+02	PAOK	Ionikos	Over	Full Time	1.92	0.00	Lost	2.5	6	0	4	2	0	0	3.26%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
90	2023-03-05 20:30:00+02	PAOK	Ionikos	Under	1st Half	3.10	0.00	Lost	0.5	6	0	4	2	0	0	2.61%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
69	2023-02-26 19:30:00+02	Aris Salonika	Atromitos	Under	2nd Half	3.25	0.00	Lost	0.5	2	1	2	0	0	1	3.63%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
91	2023-03-05 20:30:00+02	PAOK	Ionikos	Under	2nd Half	4.05	0.05	Lost	0.5	6	0	4	2	0	0	4.48%	{http://www.stoiximan.gr/}
92	2023-03-05 20:30:00+02	PAOK	Ionikos	Under	2nd Half	4.05	0.00	Lost	0.5	6	0	4	2	0	0	4.48%	{http://www.stoiximan.gr/}
45	2023-02-24 20:00:00+02	Volos	Lamia	Under	1st Half	1.81	0	Lost	2.5	1	1	0	1	1	0	1.73%	{https://partners.opapaffiliates.gr/redirect.aspx?pid=2460&bid=1759}
108	2023-03-18 19:30:00+02	Atromitos	Ionikos	Under	1st Half	2.40	0.00	Lost	0.5	2	2	1	1	0	0	3.28%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
109	2023-03-18 19:30:00+02	Atromitos	Ionikos	Under	2nd Half	3.25	0.00	Lost	0.5	2	2	1	1	0	0	3.13%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
98	2023-03-06 19:30:00+02	Panathinaikos	Panetolikos	Under	2nd Half	3.75	0.00	Lost	0.5	2	0	0	2	0	0	5.13%	{http://www.sportingbet.gr/,https://sports.bwin.gr/el/sports?wm=5273373,https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
93	2023-03-05 20:30:00+02	PAOK	Ionikos	Under	Full Time	1.95	0.00	Lost	2.5	6	0	4	2	0	0	3.26%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436,https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/,https://www.bet365.gr/olp/open-account?affiliate=365_01012107,https://record.affiliates.betshop.gr/_xVrm1kU5pcRLcRLGwHoTKWNd7ZgqdRLk/1/}
83	2023-03-05 17:30:00+02	Lamia	Aris Salonika	Under	Full Time	1.81	0.00	Lost	2.5	2	2	2	0	1	0	3.00%	{https://record.affiliates.betshop.gr/_xVrm1kU5pcRLcRLGwHoTKWNd7ZgqdRLk/1/}
77	2023-03-05 17:00:00+02	PAS Giannina	Volos	Over	Full Time	2.30	0.00	Lost	2.5	0	0	0	0	0	1	3.59%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107,https://record.affiliates.betshop.gr/_xVrm1kU5pcRLcRLGwHoTKWNd7ZgqdRLk/1/}
78	2023-03-05 17:00:00+02	PAS Giannina	Volos	Under	1st Half	2.60	0.00	Lost	0.5	0	0	0	0	0	1	4.08%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436,https://record.betssongroupaffiliates.com/_WbYFYUdzQPOWzcyEjjoakGNd7ZgqdRLk/1/}
72	2023-03-04 20:00:00+02	Asteras Tripolis	Atromitos	Under	2nd Half	3.40	0.00	Lost	0.5	1	1	0	1	1	0	4.40%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
41	2023-02-24 20:00:00+02	Volos	Lamia	Under	2nd Half	3.75	0	Lost	0.5	1	1	0	1	1	0	4.02%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
25	2023-02-19 20:30:00+02	PAOK	AEK	Under	\N	3.25	0	Lost	0.5	2	0	1	1	0	0	5.47%	{http://www.stoiximan.gr/,https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
18	2023-02-19 19:30:00+02	Panetolikos	Ionikos	Under	\N	3.25	0.8	Lost	0.5	1	1	0	1	0	0	3.63%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
19	2023-02-19 19:30:00+02	Panetolikos	Ionikos	Under	\N	3.25	0.75	Lost	0.5	1	1	0	1	0	0	3.63%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
122	2023-03-19 21:30:00+02	AEK	Panathinaikos	Over	Full Time	2.60	0.00	Lost	2.5	0	0	0	0	0	0	2.50%	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
114	2023-03-19 17:30:00+02	Volos	Olympiacos	Over	1st Half	1.78	0.00	Won	2.5	0	0	0	0	2	1	1.61%	{https://gml-grp.com/C.ashx?btag=a_11671b_1371c_&affid=3817&siteid=11671&adid=1371&c=}
123	2023-03-19 21:30:00+02	AEK	Panathinaikos	Under	1st Half	2.45	0.00	Lost	0.5	0	0	0	0	0	0	3.21%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
124	2023-03-19 21:30:00+02	AEK	Panathinaikos	Under	2nd Half	3.25	0.00	Lost	0.5	0	0	0	0	0	0	3.63%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
113	2023-03-19 17:30:00+02	Volos	Olympiacos	Over	Full Time	1.78	0.00	Lost	2.5	0	0	0	0	2	1	1.61%	{}
118	2023-03-19 17:30:00+02	Volos	Olympiacos	Under	1st Half	2.20	0.00	Lost	2.5	0	0	0	0	2	1	1.61%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
106	2023-03-18 17:30:00+02	OFI	Levadiakos	Under	Full Time	1.70	0.00	Lost	2.5	1	1	0	1	0	1	-0.36%	{https://rt.novibet.partners/o/w3W92s?lpage=2e4NMs&site_id=1000145}
101	2023-03-18 17:00:00+02	Asteras Tripolis	Panetolikos	Under	1st Half	2.50	0.00	Lost	0.5	2	2	1	1	0	1	3.56%	{https://affiliatesys.ads-tracking.com/redirect.aspx?pid=30676343&bid=8436}
102	2023-03-18 17:00:00+02	Asteras Tripolis	Panetolikos	Under	2nd Half	3.25	0.00	Lost	0.5	2	2	1	1	0	1	4.62%	{https://www.bet365.gr/olp/open-account?affiliate=365_01012107}
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

SELECT pg_catalog.setval('public."Match_id_seq"', 1359, true);


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

SELECT pg_catalog.setval('public."OverUnder_id_seq"', 13027, true);


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


-- Completed on 2023-03-27 01:56:34 EEST

--
-- PostgreSQL database dump complete
--


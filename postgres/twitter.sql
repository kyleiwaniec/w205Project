--
-- PostgreSQL database dump
--

SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA public IS 'Standard public schema';


--
-- Name: plpgsql; Type: PROCEDURAL LANGUAGE; Schema: -; Owner: postgres
--

CREATE PROCEDURAL LANGUAGE plpgsql;


ALTER PROCEDURAL LANGUAGE plpgsql OWNER TO postgres;

SET search_path = public;


--
-- Name: twitter_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE twitter_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.twitter_id_seq OWNER TO postgres;

--
-- Name: twitters; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

DROP TABLE IF EXISTS twitters;
CREATE TABLE twitters (
    twitters_id integer DEFAULT nextval('twitter_id_seq'::regclass) NOT NULL,
    row_created timestamp without time zone DEFAULT now() NOT NULL,
    user_id character varying(45) NOT NULL,
    tweet_id character varying(45) NOT NULL,
    tweet character varying(45) NOT NULL,
    num_words integer NOT NULL,
    created_ts character varying(45) NOT NULL,
    user_created_ts character varying(45) NOT NULL,
    num_following integer NOT NULL,
    num_followers integer NOT NULL,
    num_tweets integer NOT NULL,
    retweet_count integer NOT NULL,
    num_urls integer NOT NULL,
    num_mentions integer NOT NULL,
    num_hastags integer NOT NULL,
    isPolluter decimal NOT NULL
);


ALTER TABLE public.twitters OWNER TO postgres;


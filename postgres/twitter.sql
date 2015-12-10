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
DROP SEQUENCE IF EXISTS twitter_id_seq;
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
    id bigint DEFAULT nextval('twitter_id_seq'::regclass) NOT NULL,
    index int,
    row_created timestamp without time zone DEFAULT now() NOT NULL,
    user_id text,
    tweet_id text,
    tweet text,
    num_words integer,
    created_ts text,
    user_created_ts text,
    tweet_created_ts text,
    screen_name text,
    name text,
    num_following integer,
    num_followers integer,
    num_tweets integer,
    retweeted boolean,
    retweet_count integer,
    num_urls integer,
    num_mentions integer,
    num_hashtags integer,
    user_profile_url text,
    tweeted_urls text,
    is_polluter double precision
);


ALTER TABLE public.twitters OWNER TO postgres;


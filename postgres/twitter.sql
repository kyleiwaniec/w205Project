DROP DATABASE IF EXISTS twitter;
CREATE DATABASE twitter;
\c twitter

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
    START 1
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


-- Random sample functions - not in use.

CREATE OR REPLACE FUNCTION get_random_id() RETURNS INT4 as $BODY$
declare
    id_range record;
    reply INT4;
    try INT4 := 0;
BEGIN
    SELECT min(id), max(id) - min(id) + 1 as range INTO id_range FROM twitters;
    WHILE ( try < 10 ) LOOP
        try := try + 1;
        reply := floor( random() * id_range.range) + id_range.min;
        perform id FROM twitters WHERE id = reply;
        IF found THEN
            RETURN reply;
        END IF;
    END LOOP;
    RAISE EXCEPTION 'something strange happened - no record found in % tries', try;
END;

$BODY$ language plpgsql STABLE;

-- explain analyze select * from twitters where id = get_random_id();


CREATE OR REPLACE FUNCTION get_random_ids(in_table_name TEXT, want_elements INT4) RETURNS INT4[] as $BODY$
declare
    use_sql        TEXT;
    id_range       record;
    reply          INT4[];
    this_part      INT4[];
    try            INT4    := 0;
    i              INT4;
BEGIN
    use_sql := 'SELECT min(id), max(id) - min(id) + 1 as range FROM ' || quote_ident(in_table_name);
    EXECUTE use_sql INTO id_range;
    IF id_range.range < want_elements THEN
        raise exception 'not enough elements in % table.', in_table_name;
    END IF;
    WHILE ( try < 10000 ) LOOP
        try := try + 1;
        this_part := '{}'::INT4[];
        WHILE ( coalesce(array_upper( this_part, 1 ), 0) < want_elements - coalesce(array_upper(reply, 1), 0)) LOOP
            i := floor( random() * id_range.range) + id_range.min;
            IF NOT i = ANY(this_part) THEN
                this_part := this_part || i;
            END IF;
        END LOOP;

        use_sql := 'SELECT id FROM ' || quote_ident(in_table_name) || ' WHERE id = ANY(' || quote_literal(this_part::TEXT) || '::INT4[])';
        for i IN EXECUTE use_sql LOOP
            reply := reply || i;
        END LOOP;

        IF (coalesce(array_upper(reply, 1), 0) = want_elements) THEN
            RETURN reply;
        END IF;
    END LOOP;
    RAISE EXCEPTION 'something strange happened - requested records not found in % tries', try;
END;

$BODY$ language plpgsql STABLE;

--explain analyze select * from twitters where id = any(get_random_ids('twitters', 100));




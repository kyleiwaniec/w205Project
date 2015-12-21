DROP TABLE IF EXISTS classified_tweets_simple;
CREATE TABLE classified_tweets_simple (
    id bigint NOT NULL,    
    is_polluter double precision
);

ALTER TABLE public.twitters OWNER TO postgres;

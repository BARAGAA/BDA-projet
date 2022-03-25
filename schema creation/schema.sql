

BEGIN;
DROP SCHEMA IF EXISTS music_schema CASCADE ;


CREATE SCHEMA music_schema;

-- Artist Table
CREATE TABLE IF NOT EXISTS music_schema.artist
(
    artist_id text COLLATE pg_catalog."default" NOT NULL,
    artist_name text COLLATE pg_catalog."default",
    followers bigint,
    CONSTRAINT pk_artist PRIMARY KEY (artist_id)
);
-- Date Table

CREATE TABLE IF NOT EXISTS music_schema.date
(
	date_id date,
    day_number smallint NOT NULL,
    month_number smallint NOT NULL,
    year_number smallint NOT NULL,
    month_label text NOT NULL,
    week_day text NOT NULL,
    CONSTRAINT pk_date PRIMARY KEY (date_id)
);

-- Track Table

CREATE TABLE IF NOT EXISTS music_schema.track
(
    track_id text COLLATE pg_catalog."default" NOT NULL,
    track_name text COLLATE pg_catalog."default",
    release_date date,
    genre text COLLATE pg_catalog."default",
    duration integer,
    danceability double precision,
    speechiness double precision,
    energy double precision,
    loudness double precision,
    acousticness double precision,
    liveness double precision,
    valeance double precision,
    tempo double precision,
    CONSTRAINT pk_track PRIMARY KEY (track_id)
);

ALTER TABLE IF EXISTS music_schema.track
    ENABLE ROW LEVEL SECURITY;
	
-- Track_artist Table

CREATE TABLE IF NOT EXISTS music_schema.track_artist
(
    track_id text COLLATE pg_catalog."default" NOT NULL,
    artist_id text COLLATE pg_catalog."default" NOT NULL
);

ALTER TABLE IF EXISTS music_schema.track
    ADD FOREIGN KEY (release_date)
    REFERENCES music_schema.date (date_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID; --reduire le temps de scripte


--Conflit 



--ALTER TABLE IF EXISTS music_schema.track_artist
--    ADD FOREIGN KEY (track_id)
--    REFERENCES music_schema.track (track_id) MATCH SIMPLE
--    ON UPDATE NO ACTION
--    ON DELETE NO ACTION
--    NOT VALID; --reduire le temps de scripte



--ALTER TABLE IF EXISTS music_schema.track_artist
--    ADD FOREIGN KEY (artist_id)
--    REFERENCES music_schema.artist (artist_id) MATCH SIMPLE
--    ON UPDATE NO ACTION
--    ON DELETE NO ACTION
--    NOT VALID; --reduire le temps de scripte

--END;


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



-- ALTER TABLE IF EXISTS music_schema.track_artist
--     ADD FOREIGN KEY (track_id)
--     REFERENCES music_schema.track (track_id) MATCH SIMPLE
--     ON UPDATE NO ACTION
--     ON DELETE NO ACTION
--     NOT VALID; --reduire le temps de scripte



-- ALTER TABLE IF EXISTS music_schema.track_artist
--     ADD FOREIGN KEY (artist_id)
--     REFERENCES music_schema.artist (artist_id) MATCH SIMPLE
--     ON UPDATE NO ACTION
--     ON DELETE NO ACTION
--     NOT VALID; --reduire le temps de scripte

END;

--Trigger

CREATE OR REPLACE FUNCTION music_schema.insert_date()

  RETURNS trigger AS

$$

BEGIN

INSERT INTO music_schema.date (date_id,day_number,month_number,year_number,month_label,week_day) 
VALUES(NEW.release_date,EXTRACT(DAY FROM NEW.release_date),EXTRACT(MONTH FROM NEW.release_date),EXTRACT(YEAR FROM NEW.release_date),to_char(NEW.release_date, 'Mon'),to_char(NEW.release_date,'Day'))
ON CONFLICT (date_id ) DO NOTHING;

RETURN NEW;

END;

$$

LANGUAGE 'plpgsql';

CREATE OR REPLACE  TRIGGER date_insert_trigger
  BEFORE INSERT
  ON music_schema.track
  FOR EACH ROW
  EXECUTE PROCEDURE music_schema.insert_date();


-- Access Management


-- Suppression des roles
DROP POLICY IF EXISTS pop_editors ON music_schema.track;
DROP POLICY IF EXISTS rap_editors ON music_schema.track;

REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA music_schema FROM Pop_editor_1,Pop_editor_2,Rap_editor_1,editor,senior_editor,Rap_editor,Pop_editor,ADMIN_BD;
DROP ROLE IF EXISTS ADMIN_BD;
DROP ROLE IF EXISTS editor;
DROP ROLE IF EXISTS rap_editor;
DROP ROLE IF EXISTS pop_editor;
DROP ROLE IF EXISTS pop_editor_1;
DROP ROLE IF EXISTS pop_editor_2;
DROP ROLE IF EXISTS rap_editor_1;
DROP ROLE IF EXISTS senior_editor;
DROP ROLE IF EXISTS recent_track_editor;

DROP MATERIALIZED VIEW IF EXISTS music_schema.recent_tracks_view ;




-- Creation des groupes/utilisateurs
CREATE ROLE ADMIN_BD NOLOGIN  PASSWORD '12345' ;
CREATE ROLE senior_editor  LOGIN BYPASSRLS INHERIT PASSWORD '12345' ; -- utilisateur 
CREATE ROLE editor  NOLOGIN INHERIT PASSWORD '12345' ; -- Groupe 
CREATE ROLE pop_editor INHERIT NOLOGIN PASSWORD '12345'; -- Groupe (peuvent seulment interagir avec les genres pop )
CREATE ROLE rap_editor INHERIT NOLOGIN PASSWORD '12345'; -- Groupe (peuvent seulment interagir avec les genres rap )
CREATE ROLE pop_editor_1 LOGIN INHERIT PASSWORD '12345'; -- utilisateur  (de groupe)
CREATE ROLE pop_editor_2 LOGIN INHERIT PASSWORD '12345'; -- utilisateur
CREATE ROLE rap_editor_1 LOGIN INHERIT PASSWORD '12345'; -- utilisateur
CREATE ROLE recent_track_editor LOGIN INHERIT PASSWORD '12345'; -- utilisateur


-- Attribution de droits aux roles
-- admin/Senior_editor
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA music_schema TO ADMIN_BD;
GRANT ADMIN_BD TO Senior_editor;

-- editor
GRANT ALL on music_schema.track to editor ;



-- Pop_editor
GRANT editor TO pop_editor;
CREATE POLICY pop_editors ON music_schema.track
FOR ALL
TO Pop_editor
USING(track.genre like 'pop%' OR track.genre like '%-pop%' or track.genre  LIKE '% pop%' or track.genre  LIKE 'Pop%');
GRANT pop_editor TO pop_editor_1;
GRANT pop_editor TO pop_editor_2;




-- Rap_editor
GRANT editor TO rap_editor;
CREATE POLICY rap_editors ON music_schema.track
FOR ALL
TO Rap_editor
USING(track.genre LIKE 'rap%' OR track.genre LIKE '%-rap%' OR track.genre  LIKE '% rap%' );
GRANT rap_editor TO rap_editor_1;

-- Column level security peut être implementé par vues , vues materialisés et droits d'access

-- Pas d'option pour un VPD sans des ADD-ONS et extentions

    REVOKE ALL on music_schema.artist FROM pop_editor_2 ;
    GRANT SELECT(artist_id),SELECT(artist_name) on music_schema.artist TO pop_editor_2 ; 



-- Materialized view


CREATE MATERIALIZED VIEW music_schema.recent_tracks_view 
AS
SELECT track_id,track_name,release_date
FROM music_schema.track
Where release_date >= '2000-01-01' ;
REFRESH MATERIALIZED VIEW music_schema.recent_tracks_view ;


-- Privileges on materialized view
GRANT ALL ON music_schema.recent_tracks_view TO recent_track_editor ;

-- 
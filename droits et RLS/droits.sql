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
DROP MATERIALIZED VIEW IF EXISTS music_schema.recent_tracks_view ;
DROP ROLE IF EXISTS recent_track_editor;





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
GRANT ALL ON music_schema.recent_tracks_view TO recent_track_editor;

